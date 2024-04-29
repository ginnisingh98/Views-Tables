--------------------------------------------------------
--  DDL for Package IGS_AV_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSAV01S.pls 120.5 2005/11/24 01:15:16 appldev ship $ */


FUNCTION advp_del_adv_stnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_default_message OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION advp_get_as_total(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN NUMBER ;

PRAGMA RESTRICT_REFERENCES (advp_get_as_total,WNDS,WNPS);

PROCEDURE advp_upd_as_grant(errbuf   out NOCOPY   varchar2,
			    retcode  out NOCOPY   number,
			    p_org_id IN    NUMBER);

FUNCTION advp_upd_as_inst(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

PROCEDURE advp_upd_as_pe_expry
       ( errbuf   OUT NOCOPY  varchar2,
         retcode  OUT NOCOPY  number,
	 p_org_id IN   NUMBER  );

FUNCTION advp_upd_as_pe_grant(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_granted_dt IN DATE ,
  p_process_type IN VARCHAR2 ,
  p_s_log_type IN OUT NOCOPY VARCHAR2 ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION advp_upd_as_totals(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_exemption_institution_cd IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION advp_upd_sua_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_granted_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION upd_sua_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_granted_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 ;

 PROCEDURE advp_create_basis(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER );

  FUNCTION advp_val_basis_year(
  p_basis_year IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2;

FUNCTION eval_unit_repeat (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_repeat_tag                   OUT NOCOPY    VARCHAR2 ,
    p_unit_cd                      IN     VARCHAR2  ,
    p_unit_version                 IN     NUMBER,
    p_calling_obj	           IN VARCHAR2
  ) RETURN VARCHAR2 ;

 PROCEDURE advp_updt_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER );


 PROCEDURE adv_validate_grade(
  p_grdschcode IN VARCHAR2,
  p_grde IN VARCHAR2,
  p_grschverno IN NUMBER,
  validity OUT NOCOPY VARCHAR2 );

 PROCEDURE adv_cal_creditpts (
 p_personid IN NUMBER,
 p_coursecd IN VARCHAR2,
 p_unitsetcd IN VARCHAR2,
 p_usverno IN VARCHAR2,
 creditpts OUT NOCOPY NUMBER);

END IGS_AV_GEN_001 ;

 

/
