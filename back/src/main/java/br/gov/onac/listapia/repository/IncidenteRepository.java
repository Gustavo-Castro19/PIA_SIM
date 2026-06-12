package br.gov.onac.listapia.repository;

import br.gov.onac.listapia.entity.Incidente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IncidenteRepository extends JpaRepository<Incidente, Long> {
}
