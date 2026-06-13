import { HttpClient, HttpErrorResponse, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { environment } from '../../../environments/environment';
import {
    ErrorResponse,
    FiltrosPia,
    PiaCreateRequest,
    PiaCreateResponse,
    PiaListItem,
    PiaListResponse,
    PiaUpdateRequest,
    PiaUpdateResponse
} from '../models/pia.model';

@Injectable({
    providedIn: 'root'
})
export class PiaService {
    private readonly baseUrl = `${environment.apiUrl}/pia`;

    constructor(private http: HttpClient) { }

    listar(filtros?: FiltrosPia, pagina = 1, porPagina = 10): Observable<PiaListResponse> {
        let params = new HttpParams()
            .set('pagina', String(pagina))
            .set('por_pagina', String(porPagina));

        if (filtros?.risco) {
            params = params.set('risco', filtros.risco);
        }
        if (filtros?.status) {
            params = params.set('status', filtros.status);
        }

        return this.http.get<PiaListResponse>(this.baseUrl, { params }).pipe(
            catchError(this.handleError)
        );
    }

    buscarPorId(id: number): Observable<PiaListItem> {
        return this.http.get<PiaListItem>(`${this.baseUrl}/${id}`).pipe(
            catchError(this.handleError)
        );
    }

    criar(payload: PiaCreateRequest): Observable<PiaCreateResponse> {
        return this.http.post<PiaCreateResponse>(this.baseUrl, payload).pipe(
            catchError(this.handleError)
        );
    }

    atualizar(id: number, payload: PiaUpdateRequest): Observable<PiaUpdateResponse> {
        return this.http.put<PiaUpdateResponse>(`${this.baseUrl}/${id}`, payload).pipe(
            catchError(this.handleError)
        );
    }

    excluir(id: number): Observable<void> {
        return this.http.delete<void>(`${this.baseUrl}/${id}`).pipe(
            catchError(this.handleError)
        );
    }

    exportarCsv(): Observable<string> {
        return this.http.get(`${this.baseUrl}/export`, { responseType: 'text' }).pipe(
            catchError(this.handleError)
        );
    }

    baixarCsv(): void {
        this.exportarCsv().subscribe({
            next: (csv) => {
                const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
                const link = document.createElement('a');
                const url = URL.createObjectURL(blob);
                link.href = url;
                link.download = `relatorio-pia-${new Date().toISOString().split('T')[0]}.csv`;
                link.style.visibility = 'hidden';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                URL.revokeObjectURL(url);
            },
            error: (erro: Error) => {
                console.error('Erro ao exportar CSV:', erro.message);
            }
        });
    }

    private handleError(error: HttpErrorResponse): Observable<never> {
        return throwError(() => new Error(this.extrairMensagemErro(error)));
    }

    private extrairMensagemErro(error: HttpErrorResponse): string {
        if (error.error && typeof error.error === 'object' && 'message' in error.error) {
            const body = error.error as ErrorResponse;
            if (body.details?.length) {
                return `${body.message}: ${body.details.join(', ')}`;
            }
            return body.message;
        }

        if (error.status === 0) {
            return 'Não foi possível conectar ao servidor. Verifique se o backend está em execução.';
        }

        if (error.status === 404) {
            return 'Registro não encontrado.';
        }

        return error.message || 'Ocorreu um erro inesperado. Tente novamente.';
    }
}
