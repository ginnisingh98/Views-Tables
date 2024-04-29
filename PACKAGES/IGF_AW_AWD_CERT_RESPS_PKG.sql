--------------------------------------------------------
--  DDL for Package IGF_AW_AWD_CERT_RESPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWD_CERT_RESPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI75S.pls 120.0 2005/09/09 17:08:01 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_award_prd_cd                      IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_awd_cert_code                     IN     VARCHAR2    DEFAULT NULL,
    x_response_txt                      IN     VARCHAR2    DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_awd_cert_resps_pkg;

 

/
