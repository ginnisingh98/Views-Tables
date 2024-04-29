--------------------------------------------------------
--  DDL for Package IGS_HE_UCAS_IMP_ERR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_UCAS_IMP_ERR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI32S.pls 115.2 2002/11/29 04:43:42 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_error_interface_id                IN OUT NOCOPY NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_error_interface_id                IN     NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_error_interface_id                IN     NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_error_interface_id                IN OUT NOCOPY NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_error_interface_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_error_interface_id                IN     NUMBER      DEFAULT NULL,
    x_interface_hesa_id                 IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL,
    x_error_text                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ucas_imp_err_pkg;

 

/
