--------------------------------------------------------
--  DDL for Package IGS_CO_LTR_PR_RSTCN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_LTR_PR_RSTCN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI12S.pls 115.8 2002/11/29 01:05:22 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_letter_parameter_type             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
   ) ;

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_letter_parameter_type             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_letter_parameter_type             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_co_type (
    x_correspondence_type               IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_co_ltr_parm_type (
    x_letter_parameter_type             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_letter_parameter_type             IN     VARCHAR2    DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_ltr_pr_rstcn_pkg;

 

/
