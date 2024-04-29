--------------------------------------------------------
--  DDL for Package IGR_I_E_TESTTYPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_E_TESTTYPS_PKG" AUTHID CURRENT_USER AS
	/* $Header: IGSRH11S.pls 120.0 2005/06/01 19:24:07 appldev noship $ */

	  PROCEDURE insert_row (
	    x_rowid                             IN OUT NOCOPY VARCHAR2,
	    x_ent_test_type_id                  IN OUT NOCOPY NUMBER,
	    x_admission_test_type               IN     VARCHAR2,
	    x_closed_ind                        IN     VARCHAR2,
	    x_mode                              IN     VARCHAR2    DEFAULT 'R',
	    x_inquiry_type_id			IN     NUMBER 	      --Added for APC Inegration  Apadegal
	  );

	  PROCEDURE lock_row (
	    x_rowid                             IN     VARCHAR2,
	    x_ent_test_type_id                  IN     NUMBER,
	    x_admission_test_type               IN     VARCHAR2,
	    x_closed_ind                        IN     VARCHAR2,
	    x_inquiry_type_id			IN     NUMBER 	      --Added for APC Inegration  Apadegal
	  );

	  PROCEDURE update_row (
	    x_rowid                             IN     VARCHAR2,
	    x_ent_test_type_id                  IN     NUMBER,
	    x_admission_test_type               IN     VARCHAR2,
	    x_closed_ind                        IN     VARCHAR2,
	    x_mode                              IN     VARCHAR2    DEFAULT 'R',
	    x_inquiry_type_id			IN     NUMBER 	      --Added for APC Inegration  Apadegal
	  );

	  PROCEDURE add_row (
	    x_rowid                             IN OUT NOCOPY VARCHAR2,
	    x_ent_test_type_id                  IN OUT NOCOPY NUMBER,
	    x_admission_test_type               IN     VARCHAR2,
	    x_closed_ind                        IN     VARCHAR2,
	    x_mode                              IN     VARCHAR2    DEFAULT 'R',
	    x_inquiry_type_id			IN     NUMBER 	      --Added for APC Inegration  Apadegal
	  );

	  PROCEDURE delete_row (
	    x_rowid                             IN     VARCHAR2
	  );

	  FUNCTION get_pk_for_validation (
	    x_ent_test_type_id                  IN     NUMBER
	  ) RETURN BOOLEAN;

	  FUNCTION get_uk_for_validation (
	    x_admission_test_type               IN     VARCHAR2,
	    x_inquiry_type_id	                IN     NUMBER --Added for APC Inegration -- Apadegal
	  ) RETURN BOOLEAN;


	  PROCEDURE get_fk_igs_ad_test_type (
	    x_admission_test_type               IN     VARCHAR2
	  );

	  PROCEDURE before_dml (
	    p_action                            IN     VARCHAR2,
	    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
	    x_ent_test_type_id                  IN     NUMBER      DEFAULT NULL,
	    x_admission_test_type               IN     VARCHAR2    DEFAULT NULL,
	    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
	    x_creation_date                     IN     DATE        DEFAULT NULL,
	    x_created_by                        IN     NUMBER      DEFAULT NULL,
	    x_last_update_date                  IN     DATE        DEFAULT NULL,
	    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
	    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
	    x_inquiry_type_id			IN     NUMBER 	   DEFAULT NULL   --Added for APC Inegration  Apadegal

	  );

	  PROCEDURE   get_fk_igr_i_inquiry_types (
	    x_inquiry_type_id	                IN     NUMBER
	  );
	END igr_i_e_testtyps_pkg;

 

/
