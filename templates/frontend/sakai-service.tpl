import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject, signal } from '@angular/core';
import { Observable, finalize } from 'rxjs';
import {
  [[EntityPlural]],
  [[EntityPlural]]CreateRequest,
  [[EntityPlural]]UpdateRequest,
  PagedResult,
} from '../models/[[FeatureName]].model';

export interface [[EntityPlural]]Query {
  page: number;
  pageSize: number;
  sortBy?: string;
  sortDir?: 'asc' | 'desc';
  search?: string;
}

/** Serviço HTTP de [[EntityPlural]] — comunica-se exclusivamente com a API REST. */
@Injectable({ providedIn: 'root' })
export class [[EntityPlural]]Service {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/[[Route]]';

  readonly items = signal<[[EntityPlural]][]>([]);
  readonly totalCount = signal(0);
  readonly loading = signal(false);

  list(query: [[EntityPlural]]Query): Observable<PagedResult<[[EntityPlural]]>> {
    let params = new HttpParams()
      .set('page', String(query.page))
      .set('pageSize', String(query.pageSize));

    if (query.sortBy) {
      params = params.set('sortBy', query.sortBy);
    }

    if (query.sortDir) {
      params = params.set('sortDir', query.sortDir);
    }

    if (query.search) {
      params = params.set('search', query.search);
    }

    this.loading.set(true);

    return this.http.get<PagedResult<[[EntityPlural]]>>(this.baseUrl, { params }).pipe(
      finalize(() => this.loading.set(false)),
    );
  }

  load(query: [[EntityPlural]]Query): void {
    this.list(query).subscribe({
      next: (result) => {
        this.items.set(result.items);
        this.totalCount.set(result.totalCount);
      },
      error: () => {
        this.items.set([]);
        this.totalCount.set(0);
      },
    });
  }

  get(id: [[PrimaryKeyTsType]]): Observable<[[EntityPlural]]> {
    return this.http.get<[[EntityPlural]]>(`${this.baseUrl}/${id}`);
  }

  create(dto: [[EntityPlural]]CreateRequest): Observable<[[EntityPlural]]> {
    return this.http.post<[[EntityPlural]]>(this.baseUrl, dto);
  }

  update(id: [[PrimaryKeyTsType]], dto: [[EntityPlural]]UpdateRequest): Observable<[[EntityPlural]]> {
    return this.http.put<[[EntityPlural]]>(`${this.baseUrl}/${id}`, dto);
  }

  remove(id: [[PrimaryKeyTsType]]): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }
}