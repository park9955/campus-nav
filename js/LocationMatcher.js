/**
 * 🗺️ LocationMatcher - 위도/경도 매칭 유틸리티 라이브러리
 * 
 * 용도:
 * - 3D도면의 마커와 CSV 위도/경도 자동 매칭
 * - 호실별 위치 검증
 * - 시각화 및 리포팅
 */

class LocationMatcher {
    constructor(options = {}) {
        this.tolerance = options.tolerance || 0.0005; // 약 50미터
        this.csvData = options.csvData || {};
        this.dbLocations = options.dbLocations || {};
        this.matchResults = {};
        this.canvas = options.canvas || null;
        this.ctx = this.canvas ? this.canvas.getContext('2d') : null;
    }

    /**
     * 하버사인 공식으로 두 지점 간 거리 계산 (km)
     */
    calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 6371; // 지구 반지름 (km)
        const dLat = (lat2 - lat1) * Math.PI / 180;
        const dLon = (lon2 - lon1) * Math.PI / 180;
        const a = 
            Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c * 1000; // 미터 단위
    }

    /**
     * 모든 마커를 분석하고 매칭 결과 생성
     */
    analyzeAllMarkers() {
        this.matchResults = {};

        for (let roomId in this.dbLocations) {
            const dbLoc = this.dbLocations[roomId];
            const dbLat = parseFloat(dbLoc.latitude);
            const dbLng = parseFloat(dbLoc.longitude);
            const building = dbLoc.building || '';

            let isMatched = false;
            let distance = null;
            let csvRef = null;

            // 같은 건물의 CSV 데이터와 비교
            if (this.csvData[building]) {
                const csvLoc = this.csvData[building];
                const csvLat = parseFloat(csvLoc.lat);
                const csvLng = parseFloat(csvLoc.lng);

                distance = this.calculateDistance(dbLat, dbLng, csvLat, csvLng);
                isMatched = distance < 50; // 50미터 이내
                csvRef = csvLoc;
            } else {
                // CSV 데이터가 없으면 DB 데이터 유효성 검증만
                isMatched = !isNaN(dbLat) && !isNaN(dbLng) && dbLat !== 0 && dbLng !== 0;
            }

            this.matchResults[roomId] = {
                roomId: roomId,
                roomName: dbLoc.roomName,
                building: building,
                floor: dbLoc.floor,
                matched: isMatched,
                dbLat: dbLat,
                dbLng: dbLng,
                distance: distance,
                csvRef: csvRef
            };
        }

        return this.matchResults;
    }

    /**
     * 특정 호실의 매칭 상태 조회
     */
    getStatus(roomId) {
        return this.matchResults[roomId] || null;
    }

    /**
     * 매칭 통계 계산
     */
    getStatistics() {
        const results = Object.values(this.matchResults);
        const matched = results.filter(r => r.matched).length;
        const total = results.length;
        
        return {
            total: total,
            matched: matched,
            mismatched: total - matched,
            matchRate: total > 0 ? ((matched / total) * 100).toFixed(1) : 0,
            avgDistance: this.getAverageDistance(),
            maxDistance: this.getMaxDistance(),
            floorStats: this.getFloorStats()
        };
    }

    /**
     * 평균 거리 계산
     */
    getAverageDistance() {
        const distances = Object.values(this.matchResults)
            .filter(r => r.distance !== null)
            .map(r => r.distance);
        
        if (distances.length === 0) return 0;
        return (distances.reduce((a, b) => a + b) / distances.length).toFixed(2);
    }

    /**
     * 최대 거리 조회
     */
    getMaxDistance() {
        const distances = Object.values(this.matchResults)
            .filter(r => r.distance !== null)
            .map(r => r.distance);
        
        return distances.length > 0 ? Math.max(...distances).toFixed(2) : 0;
    }

    /**
     * 층별 통계
     */
    getFloorStats() {
        const stats = {};
        
        for (let roomId in this.matchResults) {
            const result = this.matchResults[roomId];
            const floor = result.floor || '미지정';
            
            if (!stats[floor]) {
                stats[floor] = { total: 0, matched: 0, mismatched: 0 };
            }
            
            stats[floor].total++;
            result.matched ? stats[floor].matched++ : stats[floor].mismatched++;
        }
        
        return stats;
    }

    /**
     * 불일치 마커 조회
     */
    getMismatchedMarkers() {
        return Object.values(this.matchResults).filter(r => !r.matched);
    }

    /**
     * 일치 마커 조회
     */
    getMatchedMarkers() {
        return Object.values(this.matchResults).filter(r => r.matched);
    }

    /**
     * 특정 거리 범위 내의 호실 조회
     */
    getMarkersWithinDistance(minDistance, maxDistance) {
        return Object.values(this.matchResults).filter(r => 
            r.distance !== null && 
            r.distance >= minDistance && 
            r.distance <= maxDistance
        );
    }

    /**
     * 캔버스에 마커 그리기
     */
    drawMarkers(markerPositions) {
        if (!this.ctx || !this.canvas) return;

        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        for (let roomId in markerPositions) {
            const pos = markerPositions[roomId];
            const status = this.matchResults[roomId];

            if (!status) continue;

            // 색상 결정
            const color = status.matched ? '#16a34a' : '#9ca3af';
            const opacity = status.matched ? 1 : 0.3;

            // 마커 그리기
            this.ctx.save();
            this.ctx.globalAlpha = opacity;
            this.ctx.fillStyle = color;
            this.ctx.beginPath();
            this.ctx.arc(pos.x, pos.y, 8, 0, Math.PI * 2);
            this.ctx.fill();

            // 텍스트
            this.ctx.fillStyle = '#fff';
            this.ctx.font = 'bold 10px sans-serif';
            this.ctx.textAlign = 'center';
            this.ctx.textBaseline = 'middle';
            this.ctx.fillText(status.matched ? '✓' : '✗', pos.x, pos.y);
            this.ctx.restore();

            // 상태 표시 (호버시 표시)
            this.ctx.fillStyle = status.matched 
                ? 'rgba(22, 163, 74, 0.2)' 
                : 'rgba(156, 163, 175, 0.2)';
            this.ctx.fillRect(pos.x - 15, pos.y - 15, 30, 30);
        }
    }

    /**
     * HTML 리포트 생성
     */
    generateHTMLReport() {
        const stats = this.getStatistics();
        const mismatched = this.getMismatchedMarkers();

        return `
<div style="font-family: monospace; background: #f5f5f5; padding: 20px; border-radius: 8px;">
    <h3>📊 위도/경도 매칭 리포트</h3>
    
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin: 15px 0;">
        <div style="background: #e8f5e9; padding: 10px; border-radius: 4px;">
            <div style="font-size: 12px; color: #666;">일치</div>
            <div style="font-size: 20px; font-weight: bold; color: #16a34a;">${stats.matched}</div>
        </div>
        <div style="background: #ffebee; padding: 10px; border-radius: 4px;">
            <div style="font-size: 12px; color: #666;">불일치</div>
            <div style="font-size: 20px; font-weight: bold; color: #dc2626;">${stats.mismatched}</div>
        </div>
        <div style="background: #e3f2fd; padding: 10px; border-radius: 4px;">
            <div style="font-size: 12px; color: #666;">일치율</div>
            <div style="font-size: 20px; font-weight: bold; color: #1a56db;">${stats.matchRate}%</div>
        </div>
        <div style="background: #fff3e0; padding: 10px; border-radius: 4px;">
            <div style="font-size: 12px; color: #666;">평균 거리</div>
            <div style="font-size: 20px; font-weight: bold; color: #d97706;">${stats.avgDistance}m</div>
        </div>
    </div>

    <h4 style="margin-top: 20px;">🏢 층별 분석</h4>
    <table style="width: 100%; border-collapse: collapse; font-size: 12px;">
        <tr style="background: #ddd;">
            <th style="padding: 8px; text-align: left;">층</th>
            <th style="padding: 8px;">총 호실</th>
            <th style="padding: 8px;">일치</th>
            <th style="padding: 8px;">불일치</th>
        </tr>
        ${Object.entries(stats.floorStats).map(([floor, data]) => `
        <tr style="border-bottom: 1px solid #eee;">
            <td style="padding: 8px;">${floor}</td>
            <td style="padding: 8px; text-align: center;">${data.total}</td>
            <td style="padding: 8px; text-align: center; color: #16a34a;">✓ ${data.matched}</td>
            <td style="padding: 8px; text-align: center; color: #dc2626;">✗ ${data.mismatched}</td>
        </tr>
        `).join('')}
    </table>

    <h4 style="margin-top: 20px;">⚠️ 불일치 호실 목록</h4>
    ${mismatched.length > 0 ? `
    <ul style="font-size: 12px; color: #666;">
        ${mismatched.map(m => `
        <li>${m.roomName} (${m.building} ${m.floor}) 
            ${m.distance ? `- 거리: ${m.distance.toFixed(1)}m` : '- 위치 데이터 부재'}
        </li>
        `).join('')}
    </ul>
    ` : '<p style="color: #16a34a;">모든 호실이 일치합니다! ✓</p>'}
</div>
        `;
    }

    /**
     * 콘솔에 리포트 출력
     */
    logReport() {
        const stats = this.getStatistics();
        
        console.group('📊 위도/경도 매칭 리포트');
        console.log(`%c일치: ${stats.matched}개`, 'color: #16a34a; font-weight: bold;');
        console.log(`%c불일치: ${stats.mismatched}개`, 'color: #dc2626; font-weight: bold;');
        console.log(`%c일치율: ${stats.matchRate}%`, 'color: #1a56db; font-weight: bold;');
        console.log(`평균 거리: ${stats.avgDistance}m`);
        console.log(`최대 거리: ${stats.maxDistance}m`);
        
        console.group('층별 분석');
        for (let floor in stats.floorStats) {
            const data = stats.floorStats[floor];
            console.log(`${floor}: ${data.matched}/${data.total} 일치`);
        }
        console.groupEnd();

        if (this.getMismatchedMarkers().length > 0) {
            console.group('⚠️ 불일치 호실');
            this.getMismatchedMarkers().forEach(m => {
                const distance = m.distance ? ` (${m.distance.toFixed(1)}m)` : '';
                console.warn(`${m.roomName}${distance}`);
            });
            console.groupEnd();
        }

        console.groupEnd();
    }

    /**
     * CSV 파일 파싱 (클라이언트 사이드)
     */
    static parseCSV(csvText) {
        const lines = csvText.trim().split('\n');
        const data = {};

        for (let i = 1; i < lines.length; i++) {
            const parts = lines[i].split(',').map(s => s.trim());
            if (parts.length >= 4) {
                const building = parts[0];
                const lat = parts[1];
                const lng = parts[2];
                const floor = parts[3];

                if (building && lat && lng) {
                    data[building] = { lat, lng, floor };
                }
            }
        }

        return data;
    }

    /**
     * 내보내기 (JSON)
     */
    exportJSON() {
        return JSON.stringify({
            timestamp: new Date().toISOString(),
            statistics: this.getStatistics(),
            results: this.matchResults
        }, null, 2);
    }

    /**
     * 내보내기 (CSV)
     */
    exportCSV() {
        let csv = '호실ID,호실명,건물,층,일치,거리(m)\n';
        
        for (let roomId in this.matchResults) {
            const r = this.matchResults[roomId];
            csv += `"${r.roomId}","${r.roomName}","${r.building}","${r.floor}",` +
                   `"${r.matched ? '예' : '아니오'}","${r.distance ? r.distance.toFixed(2) : 'N/A'}"\n`;
        }
        
        return csv;
    }
}

// 사용 예제
/*
const matcher = new LocationMatcher({
    tolerance: 0.0005,
    csvData: {
        '1공학관': { lat: 37.396486, lng: 127.248024, floor: '1' },
        // ...
    },
    dbLocations: {
        'room_001': { 
            roomName: '1206호', 
            latitude: 37.396486, 
            longitude: 127.248024,
            floor: '12층',
            building: '1공학관'
        },
        // ...
    },
    canvas: document.getElementById('floorCanvas')
});

matcher.analyzeAllMarkers();
matcher.logReport();
document.getElementById('report').innerHTML = matcher.generateHTMLReport();
*/
