<?php

declare(strict_types=1);

namespace App\Core;

final class Router
{
    private array $routes = [];

    public function get(string $path, callable|array $handler, bool $protected = false, ?string $permission = null): void
    {
        $this->add('GET', $path, $handler, $protected, $permission);
    }

    public function post(string $path, callable|array $handler, bool $protected = false, ?string $permission = null): void
    {
        $this->add('POST', $path, $handler, $protected, $permission);
    }

    private function add(string $method, string $path, callable|array $handler, bool $protected, ?string $permission): void
    {
        $this->routes[] = compact('method', 'path', 'handler', 'protected', 'permission');
    }

    public function dispatch(string $method, string $uri): void
    {
        $path = parse_url($uri, PHP_URL_PATH) ?: '/';
        $scriptName = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
        if ($scriptName !== '/' && $scriptName !== '.' && str_starts_with($path, $scriptName)) {
            $path = substr($path, strlen($scriptName)) ?: '/';
        }
        $path = '/' . trim($path, '/');
        $path = $path === '//' ? '/' : $path;

        foreach ($this->routes as $route) {
            if ($route['method'] !== $method) {
                continue;
            }

            $pattern = preg_replace('/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/', '(?P<$1>[^/]+)', $route['path']);
            if (!preg_match('#^' . $pattern . '$#', $path, $matches)) {
                continue;
            }

            if ($route['protected'] && !Auth::check()) {
                Session::flash('error', 'Debes iniciar sesión para continuar.');
                redirect('/login');
            }

            if ($route['permission'] !== null && !Auth::can($route['permission'])) {
                http_response_code(403);
                View::render('errors/403');
                return;
            }

            $parameters = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
            $handler = $route['handler'];
            if (is_array($handler)) {
                [ $class, $action ] = $handler;
                (new $class())->{$action}(...array_values($parameters));
                return;
            }

            $handler(...array_values($parameters));
            return;
        }

        http_response_code(404);
        View::render('errors/404', [], Auth::check() ? 'app' : 'auth');
    }
}
