--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_003" AUTHID CURRENT_USER AS
 /* $Header: IGSPS03S.pls 120.3 2005/09/29 06:42:38 appldev ship $ */

-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    29-Sep-2005     Bug#4589117, changed the signature of the function CheckValid
  --sarakshi    26-Sep-2005     Bug#4589301, modified the signature of function CheckValid
  --sarakshi    21-oct-2003     Enh#3052452,added function enrollment_for_uoo_check
-------------------------------------------------------------------------------------------

PROCEDURE crsp_get_coo_key(
  p_coo_id IN OUT NOCOPY NUMBER ,
  p_course_cd IN OUT NOCOPY VARCHAR2 ,
  p_version_number IN OUT NOCOPY NUMBER ,
  p_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_location_cd IN OUT NOCOPY VARCHAR2 ,
  p_attendance_mode IN OUT NOCOPY VARCHAR2 ,
  p_attendance_type IN OUT NOCOPY VARCHAR2 )
;

PROCEDURE crsp_get_cop_key(
  p_cop_id IN OUT NOCOPY NUMBER ,
  p_course_cd IN OUT NOCOPY VARCHAR2 ,
  p_version_number IN OUT NOCOPY NUMBER ,
  p_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_ci_sequence_number IN OUT NOCOPY NUMBER ,
  p_location_cd IN OUT NOCOPY VARCHAR2 ,
  p_attendance_mode IN OUT NOCOPY VARCHAR2 ,
  p_attendance_type IN OUT NOCOPY VARCHAR2 )
;

FUNCTION crsp_get_cous_ind(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 )
RETURN VARCHAR2;

FUNCTION crsp_get_cous_subind(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER )
RETURN VARCHAR2;


PROCEDURE CRSP_INS_CI_COP (
errbuf  out NOCOPY  varchar2,
retcode out NOCOPY  number,
p_source_cal  IN VARCHAR2 ,
p_dest_cal  IN VARCHAR2 ,
p_org_unit  IN VARCHAR2,
p_org_id    IN NUMBER)
;

FUNCTION crsp_ins_coi_cop(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_source_cal_type IN VARCHAR2 ,
  p_source_sequence_number IN NUMBER ,
  p_dest_cal_type IN VARCHAR2 ,
  p_dest_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

PROCEDURE crsp_ins_cous(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_override_title IN VARCHAR2 ,
  p_only_as_sub_ind IN VARCHAR2 DEFAULT 'N')
;

FUNCTION enrollment_for_uoo_check(
  p_n_uoo_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION CheckValid(
		      p_n_uoo_id           NUMBER,
		      p_n_usec_occurs_id   NUMBER,
                      p_c_building_cd      VARCHAR2,
                      p_c_room_cd          VARCHAR2,
		      p_d_start_date       DATE,
		      p_d_end_date         DATE,
		      p_d_start_time       DATE,
		      p_d_end_time         DATE,
		      p_c_monday           VARCHAR2,
		      p_c_tuesday          VARCHAR2,
		      p_c_wednesday        VARCHAR2,
		      p_c_thrusday         VARCHAR2,
		      p_c_friday           VARCHAR2,
		      p_c_saturday         VARCHAR2,
		      p_c_sunday           VARCHAR2,
		      p_called_from        VARCHAR2 ,
		      p_c_clash_section    OUT NOCOPY VARCHAR2,
		      p_c_clash_occurrence OUT NOCOPY VARCHAR2
		      )
RETURN BOOLEAN;


END IGS_PS_GEN_003;

 

/
