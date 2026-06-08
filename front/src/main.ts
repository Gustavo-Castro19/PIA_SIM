import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { AppModule } from './app/app.module';
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';

/**
 * Bootstrap da aplicação Angular
 * 
 * Carrega o AppModule e renderiza o AppComponent
 * no elemento #app-root do HTML
 */
platformBrowserDynamic()
    .bootstrapModule(AppModule)
    .catch(err => console.error(err));
