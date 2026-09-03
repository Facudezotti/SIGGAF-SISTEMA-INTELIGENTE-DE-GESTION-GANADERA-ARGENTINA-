const largo = document.querySelector('#largo');
const ancho = document.querySelector('#ancho');
const superficie = document.querySelector('#superficie-calculada');

function actualizarSuperficie() {
    const valorLargo = Number.parseFloat(largo?.value || '0');
    const valorAncho = Number.parseFloat(ancho?.value || '0');
    const resultado = valorLargo > 0 && valorAncho > 0 ? valorLargo * valorAncho : 0;
    if (superficie) {
        superficie.textContent = `${resultado.toLocaleString('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} m²`;
    }
}

largo?.addEventListener('input', actualizarSuperficie);
ancho?.addEventListener('input', actualizarSuperficie);

