--------------------------------------------------------
--  DDL for Package IGS_EN_SS_DISP_STPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SS_DISP_STPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI77S.pls 120.0 2005/06/01 20:06:28 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ss_display_id                     IN     NUMBER,
    x_academic_year_flag                IN     VARCHAR2,
    x_core_req_ind                      IN     VARCHAR2 DEFAULT 'C',
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ss_display_id                     IN     NUMBER,
    x_academic_year_flag                IN     VARCHAR2,
    x_core_req_ind                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ss_display_id                     IN     NUMBER,
    x_academic_year_flag                IN     VARCHAR2,
    x_core_req_ind                      IN     VARCHAR2 DEFAULT 'C',
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ss_display_id                     IN     NUMBER,
    x_academic_year_flag                IN     VARCHAR2,
    x_core_req_ind                      IN     VARCHAR2 DEFAULT 'C',
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ss_display_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ss_display_id                     IN     NUMBER      DEFAULT NULL,
    x_academic_year_flag                IN     VARCHAR2    DEFAULT NULL,
    x_core_req_ind                      IN    VARCHAR2     DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_ss_disp_stps_pkg;

 

/
