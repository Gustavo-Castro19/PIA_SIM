package br.gov.onac.listapia.repository;

import br.gov.onac.listapia.entity.VListaPia;
import br.gov.onac.listapia.entity.enums.Risco;
import br.gov.onac.listapia.entity.enums.StatusPia;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface VListaPiaRepository extends JpaRepository<VListaPia, Long> {

    @Query("""
            SELECT v FROM VListaPia v
            WHERE (:risco IS NULL OR v.risco = :risco)
              AND (:status IS NULL OR v.status = :status)
            """)
    Page<VListaPia> findByFiltros(
            @Param("risco") Risco risco,
            @Param("status") StatusPia status,
            Pageable pageable
    );
}
