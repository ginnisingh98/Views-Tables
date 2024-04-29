--------------------------------------------------------
--  DDL for Package IGS_AS_ADI_UPLD_PR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ADI_UPLD_PR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPR33S.pls 120.0 2005/07/05 11:26:29 appldev noship $ */
  --
  -- Validate the records before inserting into base table and call the table handlers
  --
  PROCEDURE progression_outcome_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  );
  --
  -- Validate single Grading Period record from the interface table before uploading.
  -- This validation is called from the interface table import routine,
  -- and also the ADI pre-validation functionality.
  --
  PROCEDURE igs_as_pr_val_upld (
    p_person_number                IN     VARCHAR2,
    p_anonymous_id                 IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_progression_outcome_type     IN     VARCHAR2,
    p_person_id                    OUT NOCOPY NUMBER,
    p_prg_cal_type                 OUT NOCOPY VARCHAR2,
    p_prg_ci_sequence_number       OUT NOCOPY NUMBER,
    p_error_code                   OUT NOCOPY VARCHAR2,
    p_load_file_flag               OUT NOCOPY VARCHAR2,
    p_load_record_flag             OUT NOCOPY VARCHAR2,
    p_unit_set_cd                  OUT NOCOPY igs_as_su_setatmpt.unit_set_cd%TYPE,
    p_us_version_number            OUT NOCOPY igs_as_su_setatmpt.us_version_number%TYPE,
    p_sequence_number              OUT NOCOPY igs_he_en_susa.sequence_number%TYPE,
    p_mark                         IN     NUMBER,
    p_grade                        IN OUT NOCOPY VARCHAR2
  );
  --
  -- API to upload the Progression and Unit Outcomes from Web ADI that is used
  -- to upload multiple outcomes for Progression and Unit together from a
  -- single spreadsheet.
  --
  -- This routine calls the existing routines for Progression and Unit Grading
  -- that validate and upload the data from Web ADI to corresponding OSS tables.
  --
  PROCEDURE prog_ug_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  );
  --
  -- API to upload the Progression, Unit and Assessment Item Outcomes from
  -- Web ADI that is used to upload multiple outcomes for Progression, Unit
  -- and Assessment Items together from a single spreadsheet.
  --
  -- This routine calls the existing routines for Progression, Unit Grading
  -- and Assessment Item that validate and upload the data from Web ADI to
  -- corresponding OSS tables.
  --
  PROCEDURE prog_ug_aio_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  );
  --
END igs_as_adi_upld_pr_pkg;

 

/
