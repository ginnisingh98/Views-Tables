--------------------------------------------------------
--  DDL for Package IGS_UC_CYC_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_CYC_DEFAULTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI53S.pls 115.1 2003/07/28 11:40:06 dsridhar noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL,
    x_ucas_cycle                        IN     NUMBER      DEFAULT NULL,
    x_ucas_interface                    IN     VARCHAR2    DEFAULT NULL,
    x_marvin_seq                        IN     NUMBER      DEFAULT NULL,
    x_clearing_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_extra_flag                        IN     VARCHAR2    DEFAULT NULL,
    x_cvname_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_cyc_defaults_pkg;

 

/
