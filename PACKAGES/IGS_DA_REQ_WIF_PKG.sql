--------------------------------------------------------
--  DDL for Package IGS_DA_REQ_WIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_REQ_WIF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI43S.pls 115.0 2003/04/11 07:58:03 smanglm noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_catalog_cal_type                  IN     VARCHAR2,
    x_catalog_ci_seq_num                IN     NUMBER,
    x_major_unit_set_cd1                IN     VARCHAR2,
    x_major_unit_set_cd2                IN     VARCHAR2,
    x_major_unit_set_cd3                IN     VARCHAR2,
    x_minor_unit_set_cd1                IN     VARCHAR2,
    x_minor_unit_set_cd2                IN     VARCHAR2,
    x_minor_unit_set_cd3                IN     VARCHAR2,
    x_track_unit_set_cd1                IN     VARCHAR2,
    x_track_unit_set_cd2                IN     VARCHAR2,
    x_track_unit_set_cd3                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_da_rqst (
    x_batch_id                          IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_course (
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_wif_id                            IN     NUMBER      DEFAULT NULL,
    x_program_code                      IN     VARCHAR2    DEFAULT NULL,
    x_catalog_cal_type                  IN     VARCHAR2    DEFAULT NULL,
    x_catalog_ci_seq_num                IN     NUMBER      DEFAULT NULL,
    x_major_unit_set_cd1                IN     VARCHAR2    DEFAULT NULL,
    x_major_unit_set_cd2                IN     VARCHAR2    DEFAULT NULL,
    x_major_unit_set_cd3                IN     VARCHAR2    DEFAULT NULL,
    x_minor_unit_set_cd1                IN     VARCHAR2    DEFAULT NULL,
    x_minor_unit_set_cd2                IN     VARCHAR2    DEFAULT NULL,
    x_minor_unit_set_cd3                IN     VARCHAR2    DEFAULT NULL,
    x_track_unit_set_cd1                IN     VARCHAR2    DEFAULT NULL,
    x_track_unit_set_cd2                IN     VARCHAR2    DEFAULT NULL,
    x_track_unit_set_cd3                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_da_req_wif_pkg;

 

/
