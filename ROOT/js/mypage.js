const defaultImagepath = 'img/profileshark.png';

function setDefaultImage() {
    document.getElementById('profileImage').src = defaultImagepath;
    // 기본 이미지 선택 플래그 설정
    document.getElementById('removeImage').value = '1';
}

function loadImage(event) {
    const imagefile = event.target.files[0]; // 사용자가 선택한 파일

    if (imagefile) {
        const reader = new FileReader(); // 파일을 읽기 위한 FileReader 객체 생성
        reader.onload = function(e) { // 이미지가 로드되면 프로필 이미지의 src를 새로운 이미지로 설정
            document.getElementById('profileImage').src = e.target.result;
            // 새 이미지를 선택했으므로 removeImage 플래그 초기화
            document.getElementById('removeImage').value = '0';
        };
        reader.readAsDataURL(imagefile); // 파일 내용을 읽어 Data URL 형식으로 변환
    }
}