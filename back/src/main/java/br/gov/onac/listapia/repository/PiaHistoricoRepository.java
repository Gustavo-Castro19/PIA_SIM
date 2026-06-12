package br.gov.onac.listapia.repository;

import br.gov.onac.listapia.entity.PiaHistorico;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PiaHistoricoRepository extends JpaRepository<PiaHistorico, Long> {

    List<PiaHistorico> findByPia_IdOrderByDataOperacaoDesc(Long piaId);
}
