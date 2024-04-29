--------------------------------------------------------
--  DDL for Package IGS_CO_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSCO20S.pls 120.1 2005/09/30 04:10:28 appldev ship $ */

  /*******************************************************************************
  Created by   : rbezawad
  Date created : 04-Feb-2002
  Purpose      : Function to Get Person Name and Address for Correspondence.

  Known limitations/enhancements/remarks:

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What

  *******************************************************************************/
  FUNCTION get_per_addr_for_corr (
    p_person_id                    IN     NUMBER,
    p_case_type                    IN     VARCHAR2 DEFAULT 'INITCAP'
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_per_addr_for_corr,WNDS,WNPS);


  /*******************************************************************************
  Created by   : rbezawad
  Date created : 04-Feb-2002
  Purpose      : Function to get Application Instance Descriptive Flex-Field values.

  Known limitations/enhancements/remarks:

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What

  *******************************************************************************/
  FUNCTION get_prg_appl_inst_dff_values (
    p_person_id IN NUMBER,
    p_admission_appl_number IN NUMBER,
    p_nominated_course_cd IN VARCHAR2,
    p_sequence_number IN NUMBER
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_prg_appl_inst_dff_values,WNDS,WNPS);


  /*******************************************************************************
  Created by   : rbezawad
  Date created : 04-Feb-2002
  Purpose      : Function to get Expected Program Completion Date.

  Known limitations/enhancements/remarks:

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  knag            29-OCT-2002     For bug 2647482 Added parameters
                                  p_attendance_type and p_location_cd
  *******************************************************************************/
  FUNCTION get_program_completion_dt (
    p_course_cd IN igs_ad_ps_appl_inst_aplinst_v.course_cd%TYPE,
    p_version_number IN igs_ad_ps_appl_inst_aplinst_v.crv_version_number%TYPE,
    p_acad_cal_type  IN igs_ad_ps_appl_inst_aplinst_v.acad_cal_type%TYPE,
    p_adm_cal_type   IN igs_ad_ps_appl_inst_aplinst_v.adm_cal_type%TYPE,
    p_adm_ci_sequence_number IN igs_ad_ps_appl_inst_aplinst_v.adm_ci_sequence_number%TYPE,
    p_attendance_type IN igs_ad_ps_appl_inst_aplinst_v.attendance_type%TYPE,
    p_attendance_mode IN igs_ad_ps_appl_inst_aplinst_v.attendance_mode%TYPE DEFAULT NULL,
    p_location_cd IN igs_ad_ps_appl_inst_aplinst_v.location_cd%TYPE DEFAULT NULL
  ) RETURN DATE;



  /*******************************************************************************
  Created by   : rbezawad
  Date created : 04-Feb-2002
  Purpose      : Function to get the Residency Descriptive Flex-Field values.

  Known limitations/enhancements/remarks:

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What

  *******************************************************************************/
  FUNCTION get_residency_dff_values (
    p_resident_details_id IN NUMBER
  ) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_residency_dff_values,WNDS,WNPS);


  /*******************************************************************************
  Created by   : rbezawad
  Date created : 04-Feb-2002
  Purpose      : Function to get the Student Citizenship Status.

  Known limitations/enhancements/remarks:

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What

  *******************************************************************************/
  FUNCTION get_student_citizenship_status(
    p_person_id IN NUMBER
  ) RETURN  VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(get_student_citizenship_status,WNDS,WNPS);

END igs_co_gen_003;

 

/
