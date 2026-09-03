<section class="page-heading">
    <div>
        <p class="eyebrow">Primera entrega</p>
        <h1>Panel principal</h1>
        <p>Accede a los módulos habilitados del Sistema Inteligente de Gestión Ganadera.</p>
    </div>
</section>

<section class="module-grid">
    <?php if (\App\Core\Auth::can('POTRERO_CONSULTAR')): ?>
    <a class="module-card" href="<?= e(url('/potreros')) ?>">
        <span class="module-icon" aria-hidden="true">▦</span>
        <div>
            <h2>Gestión de potreros</h2>
            <p>Registra dimensiones, consulta superficies y administra los recursos disponibles.</p>
        </div>
    </a>
    <?php else: ?>
        <article class="panel"><p>No tienes módulos operativos habilitados. Consulta con el administrador.</p></article>
    <?php endif; ?>
</section>
