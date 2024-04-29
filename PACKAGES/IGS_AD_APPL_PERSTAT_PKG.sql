--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_PERSTAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_PERSTAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIG3S.pls 120.0 2005/06/02 01:05:30 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_perstat_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_perstat_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_perstat_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_perstat_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_appl_perstat_id                      IN     NUMBER,
    x_person_id                            IN     NUMBER,
    x_admission_appl_number                IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_ad_per_stm_typ (
    x_persl_stat_type                   IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_perstat_id                   IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_persl_stat_type                   IN     VARCHAR2    DEFAULT NULL,
    x_date_received                     IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_appl_perstat_pkg;

 

/
