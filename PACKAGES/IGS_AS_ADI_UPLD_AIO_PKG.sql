--------------------------------------------------------
--  DDL for Package IGS_AS_ADI_UPLD_AIO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ADI_UPLD_AIO_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAS44S.pls 120.0 2005/07/05 11:31:46 appldev noship $ */
  --
  -- Get year of program for student unit set attempt
  --
  FUNCTION get_sua_yop (
    p_person_id                    IN     igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN     igs_en_su_attempt.course_cd%TYPE,
    p_teach_cal_type               IN     igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN     igs_en_su_attempt.ci_sequence_number%TYPE
  ) RETURN VARCHAR2;
  --
  -- Validate the records before inserting into base table and call the table handlers
  --
  PROCEDURE assessment_item_grade_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  );
  --
  -- Validate the records before inserting into base table and call the table handlers
  -- This is a wrapper API to the Grade Unit and Grade Assessment Item API's
  --
  PROCEDURE assmnt_item_grade_unit_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  );
  --
  -- Validate single Assessment Item Outcome record from the interface table before being uploaded.
  -- This validation is called from the interface table import routine,
  -- and also the ADI pre-validation functionality.
  --
  PROCEDURE igs_as_aio_val_upld (
    p_person_number                IN     VARCHAR2,
    p_person_id                    OUT NOCOPY NUMBER,
    p_anonymous_id                 IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN OUT NOCOPY VARCHAR2,
    p_ci_sequence_number           IN OUT NOCOPY NUMBER,
    p_alternate_code               IN     VARCHAR2,
    p_ass_id                       IN OUT NOCOPY NUMBER,
    p_assessment_type              IN     VARCHAR2,
    p_reference                    IN     VARCHAR2,
    p_grading_schema_cd            OUT NOCOPY VARCHAR2,
    p_gs_version_number            OUT NOCOPY NUMBER,
    p_grade                        IN OUT NOCOPY VARCHAR2,
    p_mark                         IN     NUMBER,
    p_error_code                   OUT NOCOPY VARCHAR2,
    p_ret_val                      OUT NOCOPY BOOLEAN,
    p_insert_flag                  OUT NOCOPY VARCHAR2,
    p_load_flag                    OUT NOCOPY VARCHAR2,
    p_unit_class                   IN     VARCHAR2 DEFAULT NULL,
    p_location_cd                  IN     VARCHAR2 DEFAULT NULL,
    p_override_due_dt              IN     DATE DEFAULT NULL,
    p_penalty_applied_flag         IN     VARCHAR2 DEFAULT NULL,
    p_waived_flag                  IN     VARCHAR2 DEFAULT NULL,
    p_submitted_date               IN     DATE DEFAULT NULL,
    p_uoo_id                       IN    NUMBER DEFAULT NULL
  );

--Validate the user while upload and download of ADI data
FUNCTION isvaliduser (
   p_userid     IN   NUMBER,
   p_uoo_id     IN   NUMBER DEFAULT NULL,
   p_group_id   IN   NUMBER DEFAULT NULL
)RETURN VARCHAR2;


END igs_as_adi_upld_aio_pkg;

 

/
