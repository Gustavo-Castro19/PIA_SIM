package br.gov.onac.listapia.repository;

import br.gov.onac.listapia.entity.Pia;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PiaRepository extends JpaRepository<Pia, Long> {
}
