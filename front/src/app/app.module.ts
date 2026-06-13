import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { PiaModule } from './pia/pia.module';

/**
 * AppModule - Módulo raiz da aplicação
 * 
 * Importações:
 * - BrowserModule: Suporte para browser
 * - BrowserAnimationsModule: Suporte para animações Angular
 * - AppRoutingModule: Configuração de rotas
 * - PiaModule: Módulo de PIA
 */
@NgModule({
    declarations: [
        AppComponent
    ],
    imports: [
        BrowserModule,
        HttpClientModule,
        BrowserAnimationsModule,
        AppRoutingModule,
        PiaModule
    ],
    providers: [],
    bootstrap: [AppComponent]
})
export class AppModule { }
