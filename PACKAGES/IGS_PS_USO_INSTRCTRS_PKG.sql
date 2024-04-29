--------------------------------------------------------
--  DDL for Package IGS_PS_USO_INSTRCTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USO_INSTRCTRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2PS.pls 115.3 2002/11/29 02:18:57 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uso_instructor_id                 IN OUT NOCOPY NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_uso_instructor_id                 IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_instructor_id                     IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_uso_instructor_id                 IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uso_instructor_id                 IN OUT NOCOPY NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_instructor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_uso_instructor_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_section_occurrence_id        IN     NUMBER,
    x_instructor_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_usec_occurs (
    x_unit_section_occurrence_id        IN     NUMBER
  );

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_uso_instructor_id                 IN     NUMBER      DEFAULT NULL,
    x_unit_section_occurrence_id        IN     NUMBER      DEFAULT NULL,
    x_instructor_id                     IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_uso_instrctrs_pkg;

 

/
