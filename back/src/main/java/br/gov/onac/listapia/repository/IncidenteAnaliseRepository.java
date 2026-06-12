package br.gov.onac.listapia.repository;

import br.gov.onac.listapia.entity.IncidenteAnalise;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface IncidenteAnaliseRepository extends JpaRepository<IncidenteAnalise, Long> {

    Optional<IncidenteAnalise> findByIncidente_Id(Long incidenteId);
}
