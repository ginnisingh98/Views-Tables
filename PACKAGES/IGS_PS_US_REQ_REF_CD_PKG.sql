--------------------------------------------------------
--  DDL for Package IGS_PS_US_REQ_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_US_REQ_REF_CD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2TS.pls 115.5 2003/05/09 06:41:21 sarakshi ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_section_req_ref_cd_id        IN OUT NOCOPY NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_reference_code                    IN     VARCHAR2   DEFAULT NULL,
    x_reference_code_desc               IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_section_req_ref_cd_id        IN     NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_code                    IN     VARCHAR2   DEFAULT NULL,
    x_reference_code_desc               IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_section_req_ref_cd_id        IN     NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_reference_code                    IN     VARCHAR2   DEFAULT NULL,
    x_reference_code_desc               IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_section_req_ref_cd_id        IN OUT NOCOPY NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_reference_code                    IN     VARCHAR2   DEFAULT NULL,
    x_reference_code_desc               IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_unit_section_req_ref_cd_id        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_code                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ge_ref_cd (
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_code                    IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ge_ref_cd_type (
    x_reference_cd_type                 IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ps_usec_ref (
    x_unit_section_reference_id         IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_section_req_ref_cd_id        IN     NUMBER      DEFAULT NULL,
    x_unit_section_reference_id         IN     NUMBER      DEFAULT NULL,
    x_reference_cd_type                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_reference_code                    IN     VARCHAR2   DEFAULT NULL,
    x_reference_code_desc               IN     VARCHAR2   DEFAULT NULL
  );

END igs_ps_us_req_ref_cd_pkg;

 

/
