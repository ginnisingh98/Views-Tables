--------------------------------------------------------
--  DDL for Package IGS_AS_ADI_UPLD_UG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ADI_UPLD_UG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAS43S.pls 120.0 2005/07/05 12:31:11 appldev noship $ */
  --
  -- Validate the records before inserting into base table and call the table handlers
  --
  PROCEDURE grading_period_grade_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  );
  --
  -- Validate single Grading Period record from the interface table before
  -- being uploaded. This validation is called from the interface table import
  -- routine, and also the ADI pre-validation functionality.
  --
  PROCEDURE igs_as_ug_val_upld (
    p_person_number                IN     VARCHAR2,
    p_anonymous_id                 IN     VARCHAR2,
    p_alternate_code               IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_grading_period_cd            IN     VARCHAR2,
    p_mark                         IN     NUMBER,
    p_grade                        IN OUT NOCOPY VARCHAR2,
    p_person_id                    OUT NOCOPY NUMBER,
    p_cal_type                     IN OUT NOCOPY VARCHAR2,
    p_ci_sequence_number           IN OUT NOCOPY NUMBER,
    p_ci_start_dt                  OUT NOCOPY DATE,
    p_ci_end_dt                    OUT NOCOPY DATE,
    p_grading_schema_cd            OUT NOCOPY VARCHAR2,
    p_gs_version_number            OUT NOCOPY NUMBER,
    p_error_code                   OUT NOCOPY VARCHAR2,
    p_load_file_flag               OUT NOCOPY VARCHAR2,
    p_load_record_flag             OUT NOCOPY VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_location_cd                  IN     VARCHAR2,
    manual_override_flag           IN     VARCHAR2,
    mark_capped_flag               IN     VARCHAR2,
    release_date                   IN     DATE,
    p_uoo_id                      IN   NUMBER DEFAULT NULL
  );
END igs_as_adi_upld_ug_pkg;

 

/
