--------------------------------------------------------
--  DDL for Package IGS_AD_SS_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SS_LOOKUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIH9S.pls 120.1 2005/09/08 14:57:46 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_admission_application_type        IN OUT NOCOPY VARCHAR2,
    x_ss_lookup_type                    IN     VARCHAR2,
    x_ss_lookup_code                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_ss_lookup_type                    IN     VARCHAR2,
    x_ss_lookup_code                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_ss_lookup_type                    IN     VARCHAR2,
    x_ss_lookup_code                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_admission_application_type        IN OUT NOCOPY VARCHAR2,
    x_ss_lookup_type                    IN     VARCHAR2,
    x_ss_lookup_code                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_admission_application_type        IN     VARCHAR2,
    x_ss_lookup_type                    IN     VARCHAR2,
    x_ss_lookup_code                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_ss_appl_typ (
    x_admission_application_type        IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_ss_lookup_type                    IN     VARCHAR2    DEFAULT NULL,
    x_ss_lookup_code                    IN     VARCHAR2    DEFAULT NULL,
    x_closed_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_ss_lookups_pkg;

 

/
