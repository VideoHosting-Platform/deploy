const AWS = window.AWS;

// Настройка клиента (указываем MinIO endpoint)
const s3 = new AWS.S3({
    endpoint: "/minio",  // Адрес MinIO
    accessKeyId: "minioadmin",     // Логин MinIO
    secretAccessKey: "minioadmin", // Пароль MinIO
    s3ForcePathStyle: true,             // Обязательно для MinIO
    signatureVersion: "v4",             // Требуется для MinIO
    region: "us-east-1",                // Любой регион (MinIO игнорирует)
});

async function uploadVideo() {
    const fileInput = document.getElementById('videoUpload');
    const file = fileInput.files[0];
    
    if (!file) {
        alert('Выберите файл!');
        return;
    }

    const params = {
        Bucket: "videos",
        Key: `${file.name}`,
        Body: file,
        ContentType: file.type,
    };

    try {
        const data = await s3.upload(params).promise();
        console.log("Файл загружен:", data.Location);
        return data.Location;
    } catch (err) {
        console.error("Ошибка загрузки:", err);
        throw err;
    }
}