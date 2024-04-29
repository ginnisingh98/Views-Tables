--------------------------------------------------------
--  DDL for Package IGS_PE_STAT_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_STAT_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI72S.pls 120.1 2006/02/17 06:52:11 gmaheswa noship $ */

------------------------------------------------------------------
-- Change History
-- npalanis        11-SEP-2002     bug - 2608360
--                                 igs_pe_code_classes is
--                                  removed due to transition of code
--                                   class to lookups , new columns added
--                                   for codes. the  tbh  are  modified accordingly
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col added for
--                        Person DLD
--  Columns Obsoleted - CRIMINAL_CONVICT/ACAD_DISMISSAL/NON_ACAD_DISMISSAL/COUNTRY_CD3
--                      RES_STAT_ID/STATE_OF_RESIDENCE
--  Columns Added     - MATR_CAL_TYPE/MATR_SEQUENCE_NUMBER/INIT_CAL_TYPE/INIT_SEQUENCE_NUMBER
--                      RECENT_CAL_TYPE/RECENT_SEQUENCE_NUMBER/CATALOG_CAL_TYPE/CATALOG_SEQUENCE_NUMBER
--   Bayadav  31-Jan-2002  Bug number 2203778 .added descriptive flexfield columns (IGS_PE_PERS_STAT )
--   ssawhney Feb 5th, New col added person_id mandatory NOT NULL, will be a FK to HZ_PARTIES
--                   person_profile_id obsoleted. 2203778
------------------------------------------------------------------

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
   -- x_person_profile_id                 IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2 DEFAULT NULL,
   -- x_criminal_convict                  IN     VARCHAR2 DEFAULT NULL,
   -- x_acad_dismissal                    IN     VARCHAR2 DEFAULT NULL,
   -- x_non_acad_dismissal                IN     VARCHAR2 DEFAULT NULL,
   -- x_country_cd3                       IN     VARCHAR2 DEFAULT NULL,
   -- x_state_of_residence                IN     VARCHAR2 DEFAULT NULL,
   -- x_resid_stat_id                     IN     NUMBER DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd                 IN     VARCHAR2 DEFAULT NULL,
    X_MATR_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER      DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER      DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2    DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER      DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2    DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2 DEFAULT NULL,
	X_BIRTH_CNTRY_RESN_CODE		IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
   -- x_person_profile_id                 IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2 DEFAULT NULL,
    --x_criminal_convict                  IN     VARCHAR2 DEFAULT NULL,
    --x_acad_dismissal                    IN     VARCHAR2 DEFAULT NULL,
    --x_non_acad_dismissal                IN     VARCHAR2 DEFAULT NULL,
    --x_country_cd3                       IN     VARCHAR2 DEFAULT NULL,
    --x_state_of_residence                IN     VARCHAR2 DEFAULT NULL,
    --x_resid_stat_id                     IN     NUMBER DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd                 IN     VARCHAR2 DEFAULT NULL,
    X_MATR_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER      DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER      DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2    DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER      DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2    DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER      DEFAULT NULL,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2 DEFAULT NULL,
	X_BIRTH_CNTRY_RESN_CODE		IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
  --  x_person_profile_id                 IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2 DEFAULT NULL,
   -- x_criminal_convict                  IN     VARCHAR2 DEFAULT NULL,
   -- x_acad_dismissal                    IN     VARCHAR2 DEFAULT NULL,
   -- x_non_acad_dismissal                IN     VARCHAR2 DEFAULT NULL,
   -- x_country_cd3                       IN     VARCHAR2 DEFAULT NULL,
   -- x_state_of_residence                IN     VARCHAR2 DEFAULT NULL,
   -- x_resid_stat_id                     IN     NUMBER DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd                 IN     VARCHAR2 DEFAULT NULL,
    X_MATR_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER      DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER      DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2    DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER      DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2    DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2 DEFAULT NULL,
	X_BIRTH_CNTRY_RESN_CODE		IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
   -- x_person_profile_id                 IN     NUMBER,
    x_effective_start_date              IN     DATE,
    x_effective_end_date                IN     DATE,
    x_religion_cd                       IN     VARCHAR2 DEFAULT NULL,
   -- x_criminal_convict                  IN     VARCHAR2 DEFAULT NULL,
   -- x_acad_dismissal                    IN     VARCHAR2 DEFAULT NULL,
   -- x_non_acad_dismissal                IN     VARCHAR2 DEFAULT NULL,
   -- x_country_cd3                       IN     VARCHAR2 DEFAULT NULL,
   -- x_state_of_residence                IN     VARCHAR2 DEFAULT NULL,
   -- x_resid_stat_id                     IN     NUMBER DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2,
    x_in_state_tuition                  IN     VARCHAR2,
    x_tuition_st_date                   IN     DATE,
    x_tuition_end_date                  IN     DATE,
    x_further_education_cd                 IN     VARCHAR2 DEFAULT NULL,
    X_MATR_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER      DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER      DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2    DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER      DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2    DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2 DEFAULT NULL,
	X_BIRTH_CNTRY_RESN_CODE		IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

 /* FUNCTION get_pk_for_validation (
    x_person_profile_id                 IN     NUMBER
  ) RETURN BOOLEAN;
 */

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number  NUMBER
    );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
   -- x_person_profile_id                 IN     NUMBER      DEFAULT NULL,
    x_effective_start_date              IN     DATE        DEFAULT NULL,
    x_effective_end_date                IN     DATE        DEFAULT NULL,
    x_religion_cd                       IN     VARCHAR2      DEFAULT NULL,
   -- x_criminal_convict                  IN     VARCHAR2    DEFAULT NULL,
   -- x_acad_dismissal                    IN     VARCHAR2    DEFAULT NULL,
   -- x_non_acad_dismissal                IN     VARCHAR2    DEFAULT NULL,
   -- x_country_cd3                       IN     VARCHAR2    DEFAULT NULL,
   -- x_state_of_residence                IN     VARCHAR2    DEFAULT NULL,
   -- x_resid_stat_id                     IN     NUMBER      DEFAULT NULL,
    x_socio_eco_cd                      IN     VARCHAR2      DEFAULT NULL,
    x_next_to_kin                       IN     VARCHAR2    DEFAULT NULL,
    x_in_state_tuition                  IN     VARCHAR2    DEFAULT NULL,
    x_tuition_st_date                   IN     DATE        DEFAULT NULL,
    x_tuition_end_date                  IN     DATE        DEFAULT NULL,
    x_further_education_cd                 IN    VARCHAR2      DEFAULT NULL,
    X_MATR_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_MATR_SEQUENCE_NUMBER              IN     NUMBER      DEFAULT NULL,
    X_INIT_CAL_TYPE                     IN     VARCHAR2    DEFAULT NULL ,
    X_INIT_SEQUENCE_NUMBER             IN     NUMBER      DEFAULT NULL,
    X_RECENT_CAL_TYPE                   IN     VARCHAR2    DEFAULT NULL ,
    X_RECENT_SEQUENCE_NUMBER           IN     NUMBER      DEFAULT NULL,
    X_CATALOG_CAL_TYPE                  IN     VARCHAR2    DEFAULT NULL ,
    X_CATALOG_SEQUENCE_NUMBER          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL ,
    X_ATTRIBUTE_CATEGORY 		IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE1 			  IN VARCHAR2  DEFAULT NULL,
    X_ATTRIBUTE2 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE3 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE4 			  IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE5  			IN VARCHAR2 DEFAULT NULL,
    X_ATTRIBUTE6  			IN VARCHAR2 DEFAULT NULL,
   	X_ATTRIBUTE7  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE8  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE9 		  	IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE10 			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE11  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE12  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE13  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE14  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE15  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE16  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE17  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE18  			IN VARCHAR2 DEFAULT NULL,
	  X_ATTRIBUTE19  			IN VARCHAR2 DEFAULT NULL,
  	X_ATTRIBUTE20  			IN VARCHAR2 DEFAULT NULL,
	X_BIRTH_CNTRY_RESN_CODE		IN     VARCHAR2 DEFAULT NULL
  );

END igs_pe_stat_details_pkg;

 

/
