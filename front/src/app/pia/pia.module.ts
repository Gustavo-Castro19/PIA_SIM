import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { PiaRoutingModule } from './pia-routing.module';

import { PiaListComponent } from './pages/pia-list/pia-list.component';
import { PiaDetailComponent } from './pages/pia-detail/pia-detail.component';
import { PiaModalCriarComponent } from './components/pia-modal-criar/pia-modal-criar.component';

@NgModule({
    declarations: [
        PiaListComponent,
        PiaDetailComponent,
        PiaModalCriarComponent
    ],
    imports: [
        CommonModule,
        FormsModule,
        ReactiveFormsModule,
        PiaRoutingModule
    ]
})
export class PiaModule { }
