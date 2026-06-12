package br.gov.onac.listapia.repository;

import br.gov.onac.listapia.entity.Incidente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface IncidenteRepository extends JpaRepository<Incidente, Long> {

    List<Incidente> findByPia_Id(Long piaId);
}
