import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { PiaListComponent } from './pages/pia-list/pia-list.component';
import { PiaDetailComponent } from './pages/pia-detail/pia-detail.component';

const routes: Routes = [
    {
        path: '',
        component: PiaListComponent
    },
    {
        path: ':id',
        component: PiaDetailComponent
    }
];

@NgModule({
    imports: [RouterModule.forChild(routes)],
    exports: [RouterModule]
})
export class PiaRoutingModule { }
