--------------------------------------------------------
--  DDL for Package IGS_PS_USO_FACILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USO_FACILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2OS.pls 115.3 2002/11/29 02:18:42 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uso_facility_id                   IN OUT NOCOPY NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_uso_facility_id                   IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_uso_facility_id                   IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uso_facility_id                   IN OUT NOCOPY NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_uso_facility_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_usec_occurs (
    x_unit_section_occurrence_id        IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_media_equip (
    x_media_code                        IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_uso_facility_id                   IN     NUMBER      DEFAULT NULL,
    x_unit_section_occurrence_id        IN     NUMBER      DEFAULT NULL,
    x_facility_code                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_uso_facility_pkg;

 

/
