--------------------------------------------------------
--  DDL for Package IGF_AP_ATTEND_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ATTEND_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI44S.pls 115.7 2002/11/28 14:02:11 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_atm_id                            IN OUT NOCOPY NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_atm_id                            IN     NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_atm_id                            IN     NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_atm_id                            IN OUT NOCOPY NUMBER,
    x_attendance_type                   IN     VARCHAR2,
    x_pell_att_code                     IN     VARCHAR2,
    x_cl_att_code                       IN     VARCHAR2,
    x_ap_att_code                       IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_atm_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_attendance_type                   IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
   x_cal_type                          IN     VARCHAR2,
   x_sequence_number                   IN     NUMBER
  );
  PROCEDURE get_fk_igs_en_atd_type_all (
    x_attendance_type                   IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_atm_id                            IN     NUMBER      DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_pell_att_code                     IN     VARCHAR2    DEFAULT NULL,
    x_cl_att_code                       IN     VARCHAR2    DEFAULT NULL,
    x_ap_att_code                       IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_attend_map_pkg;

 

/
