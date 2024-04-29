--------------------------------------------------------
--  DDL for Package IGS_HE_SUBMSN_RETURN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SUBMSN_RETURN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI11S.pls 115.3 2002/11/29 04:37:34 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_rtn_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_rtn_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_rtn_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_rtn_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_submsn_header (
    x_submission_name                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_he_usr_rtn_clas (
    x_user_return_subclass              IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sub_rtn_id                        IN     NUMBER      DEFAULT NULL,
    x_submission_name                   IN     VARCHAR2    DEFAULT NULL,
    x_user_return_subclass              IN     VARCHAR2    DEFAULT NULL,
    x_return_name                       IN     VARCHAR2    DEFAULT NULL,
    x_lrr_start_date                    IN     DATE        DEFAULT NULL,
    x_lrr_end_date                      IN     DATE        DEFAULT NULL,
    x_record_id                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_submsn_return_pkg;

 

/
