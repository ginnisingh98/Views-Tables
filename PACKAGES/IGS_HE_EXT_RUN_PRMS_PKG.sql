--------------------------------------------------------
--  DDL for Package IGS_HE_EXT_RUN_PRMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EXT_RUN_PRMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI07S.pls 115.3 2002/11/29 04:36:25 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_run_prms_id                       IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_param_type                        IN     VARCHAR2,
    x_exclude                           IN     VARCHAR2,
    x_only                              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_run_prms_id                       IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_param_type                        IN     VARCHAR2,
    x_exclude                           IN     VARCHAR2,
    x_only                              IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_run_prms_id                       IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_param_type                        IN     VARCHAR2,
    x_exclude                           IN     VARCHAR2,
    x_only                              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_run_prms_id                       IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_param_type                        IN     VARCHAR2,
    x_exclude                           IN     VARCHAR2,
    x_only                              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_run_prms_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_ext_run_dtls (
    x_extract_run_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_run_prms_id                       IN     NUMBER      DEFAULT NULL,
    x_extract_run_id                    IN     NUMBER      DEFAULT NULL,
    x_param_type                        IN     VARCHAR2    DEFAULT NULL,
    x_exclude                           IN     VARCHAR2    DEFAULT NULL,
    x_only                              IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ext_run_prms_pkg;

 

/
