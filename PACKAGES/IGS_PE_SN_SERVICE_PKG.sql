--------------------------------------------------------
--  DDL for Package IGS_PE_SN_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_SN_SERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI89S.pls 120.0 2005/06/01 21:37:35 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sn_service_id                     IN OUT NOCOPY NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd                IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sn_service_id                     IN     NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd                IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sn_service_id                     IN     NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd                IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sn_service_id                     IN OUT NOCOPY NUMBER,
    x_disability_id                     IN     NUMBER,
    x_special_service_cd                IN     VARCHAR2,
    x_documented_ind                    IN     VARCHAR2,
    x_start_dt				IN     DATE,
    x_end_dt				IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_sn_service_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_disability_id                     IN     NUMBER,
    x_special_service_cd                IN     VARCHAR2,
    x_start_dt				IN     DATE
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_pe_pers_disablty (
    x_igs_pe_pers_disablty_id           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sn_service_id                     IN     NUMBER      DEFAULT NULL,
    x_disability_id                     IN     NUMBER      DEFAULT NULL,
    x_special_service_cd                IN     VARCHAR2    DEFAULT NULL,
    x_documented_ind                    IN     VARCHAR2    DEFAULT NULL,
    x_start_dt				IN     DATE	   DEFAULT NULL,
    x_end_dt				IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_sn_service_pkg;

 

/
