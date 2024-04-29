--------------------------------------------------------
--  DDL for Package IGS_EN_HESA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_HESA_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSHE16S.pls 115.4 2002/11/22 12:17:50 knaraset noship $ */

PROCEDURE hesa_susa_enr(
      p_person_id IN NUMBER,
      p_course_cd IN VARCHAR2,
      p_crv_version_number IN NUMBER,
      p_old_unit_set_cd IN VARCHAR2,
      p_old_us_version_number IN NUMBER,
      p_old_sequence_number IN NUMBER ,
      p_new_unit_set_cd IN VARCHAR2,
      p_new_us_version_number IN NUMBER,
      p_new_sequence_number IN NUMBER,
      p_message OUT NOCOPY VARCHAR2,
      p_status OUT NOCOPY NUMBER);

PROCEDURE hesa_stats_enr(
      p_person_id IN NUMBER,
      p_course_cd IN VARCHAR2,
      p_crv_version_number IN NUMBER,
      p_message OUT NOCOPY VARCHAR2,
      p_status OUT NOCOPY NUMBER);

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: Function to validate whether the given award code exists
--         against system award type COURSE
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION validate_program_aim(
    p_award_cd IN VARCHAR2)
RETURN BOOLEAN;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to validate whether the specified combination of subj_qualaim's and qualaim_proportion is valid
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION val_sub_qual_proportion(
    p_subj_qualaim1 IN VARCHAR2,
    p_subj_qualaim2 IN VARCHAR2,
    p_subj_qualaim3 IN VARCHAR2,
    p_qualaim_proportion IN VARCHAR2)
RETURN BOOLEAN;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to check whether the given highest qual on entry is exists against the
--         grading schema defined for HESA code HESA_HIGH_QUAL_ON_ENT.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION val_highest_qual_entry(
    p_highest_qual_on_entry IN VARCHAR2)
RETURN BOOLEAN;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to get the unit set category for the given unit set
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION get_unit_set_cat(
    p_unit_set_cd IN VARCHAR2,
    p_us_version_number IN NUMBER)
RETURN VARCHAR2;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to check whether the given institution exists with institution type Post-Secondary
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION check_teach_inst(
    p_teaching_inst IN VARCHAR2)
RETURN BOOLEAN;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: function to check whether the given grade is exists against the grading schema defined in Unit set statistics.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION check_grading_sch_grade(
    p_person_id IN NUMBER,
    p_program_cd IN VARCHAR2,
    p_unit_set_cd IN VARCHAR2,
    p_grad_sch_grade IN VARCHAR2)
RETURN BOOLEAN;

END igs_en_hesa_pkg;


 

/
