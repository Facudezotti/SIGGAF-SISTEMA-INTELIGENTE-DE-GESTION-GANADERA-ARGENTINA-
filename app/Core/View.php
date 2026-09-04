<?php

declare(strict_types=1);

namespace App\Core;

use App\Services\ConfiguracionVisualService;

final class View
{
    public static function render(string $view, array $data = [], string $layout = 'app'): void
    {
        $viewFile = dirname(__DIR__, 2) . '/resources/views/' . $view . '.php';
        $layoutFile = dirname(__DIR__, 2) . '/resources/views/layouts/' . $layout . '.php';

        if (!is_file($viewFile) || !is_file($layoutFile)) {
            throw new \RuntimeException('No se encontró la vista solicitada.');
        }

        extract($data, EXTR_SKIP);
        $configuracionVisual = (new ConfiguracionVisualService())->obtener();
        ob_start();
        require $viewFile;
        $content = (string) ob_get_clean();
        require $layoutFile;
    }
}
