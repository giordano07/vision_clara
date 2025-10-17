// Vista previa de imagen en formularios de ActiveAdmin
document.addEventListener('DOMContentLoaded', function() {
  const imageInput = document.querySelector('input[type="file"][accept*="image"], input[type="file"][name*="imagen"]');
  const previewContainer = document.getElementById('image-preview');
  const previewImage = document.getElementById('preview-image');
  
  if (imageInput && previewContainer && previewImage) {
    imageInput.addEventListener('change', function(e) {
      const file = e.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
          previewImage.src = e.target.result;
          previewContainer.style.display = 'block';
        };
        reader.readAsDataURL(file);
      } else {
        previewContainer.style.display = 'none';
      }
    });
  }
});
