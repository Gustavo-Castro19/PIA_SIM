import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

/**
 * Configuração de rotas da aplicação
 * 
 * Rotas:
 * - /pia: Módulo PIA (lazy loaded)
 * - /: Redireciona para /pia
 */
const routes: Routes = [
    {
        path: 'pia',
        loadChildren: () => import('./pia/pia.module').then(m => m.PiaModule)
    },
    {
        path: '',
        redirectTo: '/pia',
        pathMatch: 'full'
    },
    {
        path: '**',
        redirectTo: '/pia'
    }
];

@NgModule({
    imports: [RouterModule.forRoot(routes)],
    exports: [RouterModule]
})
export class AppRoutingModule { }
