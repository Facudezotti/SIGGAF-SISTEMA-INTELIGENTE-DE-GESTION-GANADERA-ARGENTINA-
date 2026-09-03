const toggle = document.querySelector('#alternar-contrasena');
const password = document.querySelector('#contrasena');

toggle?.addEventListener('click', () => {
    const showing = password.type === 'text';
    password.type = showing ? 'password' : 'text';
    toggle.textContent = showing ? 'Ver' : 'Ocultar';
    toggle.setAttribute('aria-label', showing ? 'Mostrar contraseña' : 'Ocultar contraseña');
});

document.querySelector('#recuperacion-pendiente')?.addEventListener('click', () => {
    const message = document.querySelector('#mensaje-recuperacion');
    message.hidden = !message.hidden;
});

