# 🎬 PeliApp - Flutter Movie Explorer

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![TMDB API](https://img.shields.io/badge/TMDB_API-%2301B4E4.svg?style=for-the-badge&logo=themoviedb&logoColor=white)

Una aplicación móvil moderna, rápida y atractiva desarrollada en Flutter para descubrir películas, explorar categorías, ver tráilers oficiales y encontrar recomendaciones personalizadas. Consume los datos en tiempo real desde la API de The Movie Database (TMDB).

<p align="center">
  <!-- Aquí puedes agregar un banner o screenshots de tu app -->
  <!-- <img src="assets/screenshots/home.png" width="200"/> -->
  <!-- <img src="assets/screenshots/details.png" width="200"/> -->
</p>

##  Características Principales

* **Interfaz Moderna (Glassmorphism):** Diseño elegante en modo oscuro con efectos de transparencia, gradientes vibrantes y navegación persistente fluida.
* **Exploración Dinámica:** 
  * Carrusel de estrenos en cines.
  * Sección de películas populares con *Scroll Infinito*.
* **Categorías Inteligentes:** Explora películas por género con un sistema de paginación infinita conectado directamente a TMDB.
* **Detalles Completos:** Pósters en alta resolución, sinopsis, calificaciones y listado del reparto de actores (Hero animations incluidas).
* **Tráilers Integrados:** Reproducción directa de tráilers oficiales desde YouTube gracias a la integración con `url_launcher`.
* **Recomendaciones Algorítmicas:** Módulo de películas recomendadas ("Películas Similares") en la pantalla de detalles usando el motor de sugerencias de TMDB.
* **Búsqueda Avanzada:** Buscador en tiempo real con *debounce* para optimizar las peticiones HTTP.

##  Tecnologías Usadas

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Gestor de Estado:** [Provider](https://pub.dev/packages/provider)
* **Peticiones HTTP:** [http](https://pub.dev/packages/http)
* **Diseño UI:** Componentes nativos optimizados + Carruseles de `card_swiper`
* **Navegación:** Nested Navigation (Shell) para mantener la BottomNavigationBar persistente en todas las vistas.
* **API Externa:** [The Movie DB (TMDB) API](https://developers.themoviedb.org/3/getting-started/introduction)

##  Instalación y Ejecución

Sigue estos pasos para correr el proyecto localmente en tu computadora:

### Prerrequisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
- Un emulador (Android/iOS) o dispositivo físico conectado.
- Cuenta de [TMDB](https://www.themoviedb.org/) para obtener una API Key (si deseas usar tu propia llave).

### Clonar el Repositorio
```bash
git clone https://github.com/johan-850/peliculas_app.git
cd peliculas_app
```

### Instalar Dependencias
```bash
flutter pub get
```

### Configuración de la API Key (Opcional)
Actualmente el proyecto contiene una API Key embebida en la clase `MoviesProvider` con propósitos de desarrollo. Para ambientes de producción, se recomienda:
1. Ir al archivo `lib/providers/movies_provider.dart`
2. Reemplazar la variable `_apiKey` con tu clave personal de TMDB.

### Compilar y Ejecutar
Para correr la app en el dispositivo conectado:
```bash
flutter run
```

---
*Hecho con ❤️ y ☕ para el mundo de Flutter.*
