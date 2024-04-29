--------------------------------------------------------
--  DDL for Package IGS_HE_SUBMSN_AWD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SUBMSN_AWD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI49S.pls 120.0 2006/02/06 19:22:02 jtmathew noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_awd_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_awd_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_awd_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_awd_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2,
    x_award_start_date                  IN     DATE,
    x_award_end_date                    IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_sub_awd_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_submission_name                   IN     VARCHAR2,
    x_type                              IN     VARCHAR2,
    x_key1                              IN     VARCHAR2,
    x_key2                              IN     VARCHAR2,
    x_key3                              IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_submsn_header (
    x_submission_name                   IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sub_awd_id                        IN     NUMBER      DEFAULT NULL,
    x_submission_name                   IN     VARCHAR2    DEFAULT NULL,
    x_type                              IN     VARCHAR2    DEFAULT NULL,
    x_key1                              IN     VARCHAR2    DEFAULT NULL,
    x_key2                              IN     VARCHAR2    DEFAULT NULL,
    x_key3                              IN     VARCHAR2    DEFAULT NULL,
    x_award_start_date                  IN     DATE        DEFAULT NULL,
    x_award_end_date                    IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_submsn_awd_pkg;

 

/
