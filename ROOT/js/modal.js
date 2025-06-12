function openModal() {
    var modal = document.getElementById('myModal');
    var profileIcon = document.querySelector('.profile-icon');
    updateModalPosition(modal, profileIcon);

    // 모달 창을 화면에 표시
    modal.style.display = 'block';
}

// 창 크기 조정 시 모달 위치 재조정
window.onresize = function() {
    var modal = document.getElementById('myModal');
    var profileIcon = document.querySelector('.profile-icon');
    if (modal && modal.style.display === 'block') {
        updateModalPosition(modal, profileIcon);
    }
};

// 모달 위치 업데이트 함수
function updateModalPosition(modal, profileIcon) {
    var rect = profileIcon.getBoundingClientRect();
    var modalWidth = 250; // 모달의 너비 (픽셀 단위, CSS와 일치)

    // 화면 오른쪽을 넘어가지 않도록 조정
    var leftPosition = rect.left;
    if (leftPosition + modalWidth > window.innerWidth) {
        leftPosition = window.innerWidth - modalWidth - 10; // 화면 너비를 넘지 않도록 조정 
    }

    // 모달 위치를 업데이트
    modal.style.position = 'fixed';
    modal.style.top = (rect.bottom + 10) + 'px'; // 프로필 이미지 바로 아래 위치
    modal.style.left = leftPosition + 'px'; // 조정된 왼쪽 위치
}

window.onclick = function(event) {
    var modal = document.getElementById('myModal');
    if (event.target !== modal && !modal.contains(event.target) && event.target !== document.querySelector('.profile-icon')) {
        modal.style.display = 'none';
    }
};