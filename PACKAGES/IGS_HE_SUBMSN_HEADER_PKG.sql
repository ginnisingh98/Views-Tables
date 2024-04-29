--------------------------------------------------------
--  DDL for Package IGS_HE_SUBMSN_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SUBMSN_HEADER_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI10S.pls 115.6 2002/11/29 04:37:17 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_hdr_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_hdr_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_hdr_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_hdr_id                        IN OUT NOCOPY    NUMBER,
    x_submission_name                   IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_submission_name                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sub_hdr_id                        IN       NUMBER    DEFAULT NULL,
    x_submission_name                   IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_enrolment_start_date              IN     DATE        DEFAULT NULL,
    x_enrolment_end_date                IN     DATE        DEFAULT NULL,
    x_offset_days                       IN     NUMBER      DEFAULT NULL,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2    DEFAULT NULL,
    x_apply_to_inst_st_dt               IN     VARCHAR2    DEFAULT NULL,
    x_complete_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_validation_country                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_submsn_header_pkg;

 

/
