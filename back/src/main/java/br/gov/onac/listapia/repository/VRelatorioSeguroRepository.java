package br.gov.onac.listapia.repository;

import br.gov.onac.listapia.entity.VRelatorioSeguro;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VRelatorioSeguroRepository extends JpaRepository<VRelatorioSeguro, Long> {

    List<VRelatorioSeguro> findAllByOrderByPiaIdAsc();
}
