--------------------------------------------------------
--  DDL for Package IGS_CO_S_LTR_PR_RSTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_S_LTR_PR_RSTN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI20S.pls 115.5 2002/11/29 01:07:17 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_co_type (
    x_correspondence_type               IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_co_s_ltr_param (
    x_s_letter_parameter_type           IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_parameter_type           IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_s_ltr_pr_rstn_pkg;

 

/
