--------------------------------------------------------
--  DDL for Package IGS_UC_SYS_CALNDRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_SYS_CALNDRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI54S.pls 120.0 2005/06/01 21:33:36 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_system_code                       IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL,
    x_entry_year                        IN     NUMBER      DEFAULT NULL,
    x_entry_month                       IN     NUMBER      DEFAULT NULL,
    x_aca_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_aca_cal_seq_no                    IN     NUMBER      DEFAULT NULL,
    x_adm_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_adm_cal_seq_no                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_sys_calndrs_pkg;

 

/
