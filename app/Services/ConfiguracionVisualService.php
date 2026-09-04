<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\ConfiguracionVisualRepository;

final class ConfiguracionVisualService
{
    public const LOGO_PREDETERMINADO = '/assets/img/logo-toro.png';
    public const FONDO_PREDETERMINADO = '/assets/img/fondo-ganaderia.jpg';
    private const TAMANO_MAXIMO = 5 * 1024 * 1024;
    private const DIMENSION_MAXIMA = 8000;

    private ConfiguracionVisualRepository $repository;

    public function __construct()
    {
        $this->repository = new ConfiguracionVisualRepository();
    }

    public function obtener(): array
    {
        try {
            return $this->repository->obtener() ?? $this->predeterminada();
        } catch (\Throwable) {
            return $this->predeterminada();
        }
    }

    public function reemplazar(string $tipo, array $archivo, int $usuarioId): void
    {
        $this->validarTipo($tipo);
        [$extension, $mime] = $this->validarArchivo($archivo);

        $directorio = $this->directorioPublico();
        if (!is_dir($directorio) && !mkdir($directorio, 0755, true) && !is_dir($directorio)) {
            throw new \RuntimeException('No fue posible crear el directorio de imágenes.');
        }

        $nombreSeguro = $tipo . '-' . bin2hex(random_bytes(16)) . '.' . $extension;
        $destino = $directorio . DIRECTORY_SEPARATOR . $nombreSeguro;
        if (!move_uploaded_file((string) $archivo['tmp_name'], $destino)) {
            throw new \RuntimeException('No fue posible guardar la imagen cargada.');
        }
        @chmod($destino, 0644);

        $configuracionAnterior = $this->obtener();
        $rutaNueva = '/uploads/personalizacion/' . $nombreSeguro;

        try {
            $this->repository->actualizarImagen(
                $tipo,
                $rutaNueva,
                basename((string) ($archivo['name'] ?? $nombreSeguro)),
                $mime,
                $usuarioId
            );
        } catch (\Throwable $exception) {
            @unlink($destino);
            throw $exception;
        }

        $this->eliminarPersonalizada((string) ($configuracionAnterior[$tipo . '_ruta'] ?? ''));
    }

    public function restaurar(string $tipo, int $usuarioId): void
    {
        $this->validarTipo($tipo);
        $configuracionAnterior = $this->obtener();
        $rutaPredeterminada = $tipo === 'logo' ? self::LOGO_PREDETERMINADO : self::FONDO_PREDETERMINADO;

        $this->repository->actualizarImagen($tipo, $rutaPredeterminada, null, null, $usuarioId);
        $this->eliminarPersonalizada((string) ($configuracionAnterior[$tipo . '_ruta'] ?? ''));
    }

    private function validarArchivo(array $archivo): array
    {
        $error = (int) ($archivo['error'] ?? UPLOAD_ERR_NO_FILE);
        if ($error === UPLOAD_ERR_NO_FILE) {
            throw new \InvalidArgumentException('Debes seleccionar una imagen.');
        }
        if ($error === UPLOAD_ERR_INI_SIZE || $error === UPLOAD_ERR_FORM_SIZE) {
            throw new \InvalidArgumentException('La imagen supera el tamaño máximo permitido.');
        }
        if ($error !== UPLOAD_ERR_OK) {
            throw new \RuntimeException('La imagen no pudo cargarse correctamente.');
        }

        $temporal = (string) ($archivo['tmp_name'] ?? '');
        $tamano = (int) ($archivo['size'] ?? 0);
        if ($tamano < 1 || $tamano > self::TAMANO_MAXIMO) {
            throw new \InvalidArgumentException('La imagen debe pesar como máximo 5 MB.');
        }
        if ($temporal === '' || !is_uploaded_file($temporal)) {
            throw new \InvalidArgumentException('El archivo recibido no es una carga válida.');
        }

        $dimensiones = @getimagesize($temporal);
        if (!is_array($dimensiones) || ($dimensiones[0] ?? 0) < 1 || ($dimensiones[1] ?? 0) < 1) {
            throw new \InvalidArgumentException('El archivo seleccionado no es una imagen válida.');
        }
        if ($dimensiones[0] > self::DIMENSION_MAXIMA || $dimensiones[1] > self::DIMENSION_MAXIMA) {
            throw new \InvalidArgumentException('La imagen no puede superar 8000 píxeles por lado.');
        }

        $mime = class_exists(\finfo::class)
            ? (new \finfo(FILEINFO_MIME_TYPE))->file($temporal)
            : ($dimensiones['mime'] ?? null);
        $formatos = [
            'image/png' => 'png',
            'image/jpeg' => 'jpg',
            'image/webp' => 'webp',
        ];
        if (!is_string($mime) || !isset($formatos[$mime])) {
            throw new \InvalidArgumentException('Formato no permitido. Utiliza PNG, JPG, JPEG o WebP.');
        }

        return [$formatos[$mime], $mime];
    }

    private function validarTipo(string $tipo): void
    {
        if (!in_array($tipo, ['logo', 'fondo'], true)) {
            throw new \InvalidArgumentException('Tipo de imagen no permitido.');
        }
    }

    private function eliminarPersonalizada(string $ruta): void
    {
        if (!str_starts_with($ruta, '/uploads/personalizacion/')) {
            return;
        }

        $archivo = $this->directorioPublico() . DIRECTORY_SEPARATOR . basename($ruta);
        if (is_file($archivo)) {
            @unlink($archivo);
        }
    }

    private function directorioPublico(): string
    {
        return dirname(__DIR__, 2) . '/public/uploads/personalizacion';
    }

    private function predeterminada(): array
    {
        return [
            'id_configuracion_visual' => 1,
            'logo_ruta' => self::LOGO_PREDETERMINADO,
            'logo_nombre_original' => null,
            'logo_mime' => null,
            'fondo_ruta' => self::FONDO_PREDETERMINADO,
            'fondo_nombre_original' => null,
            'fondo_mime' => null,
            'fecha_actualizacion' => null,
            'id_usuario_actualizacion' => null,
        ];
    }
}
