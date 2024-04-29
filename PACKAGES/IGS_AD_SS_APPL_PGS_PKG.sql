--------------------------------------------------------
--  DDL for Package IGS_AD_SS_APPL_PGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SS_APPL_PGS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF9S.pls 120.2 2005/08/01 05:47:27 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_required_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_disp_order                        IN     NUMBER      DEFAULT NULL,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  );




  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_required_ind                      IN     VARCHAR2,
    x_disp_order                        IN     NUMBER      DEFAULT NULL,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_required_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_disp_order                        IN     NUMBER      DEFAULT NULL ,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_required_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_disp_order                        IN     NUMBER      DEFAULT NULL,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2
  ) RETURN BOOLEAN;


  Procedure Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);



    PROCEDURE get_fk_igs_ad_ss_appl_typ (
    x_admission_appl_type               IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_page_name                         IN     VARCHAR2    DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_include_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_required_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_disp_order                        IN     NUMBER      DEFAULT NULL,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  );

END igs_ad_ss_appl_pgs_pkg;

 

/
