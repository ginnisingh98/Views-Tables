--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_012
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_012" AUTHID CURRENT_USER AS
/* $Header: IGSEN12S.pls 120.0 2005/06/01 18:05:49 appldev noship $ */
--Change History:
--Who         When            What
--amuthu       01-Oct-2002    Added p_source parameter to the enrp_upd_sca_discont
--                            as part of enh bug 2599925
--kkillams     21-03-2003     Added new parameter to the Enrp_Upd_Sca_Discont as
--                            part of the bug fix.2860412

Procedure Enrp_Upd_Expiry_Dts(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name out NOCOPY Varchar2 );

Function Enrp_Upd_Sca_Coo(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN boolean;


FUNCTION Enrp_Upd_Sca_Discont(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_version_number              IN NUMBER ,
  p_course_attempt_status       IN VARCHAR2 ,
  p_commencement_dt             IN DATE ,
  p_discontinued_dt             IN DATE ,
  p_discontinuation_reason_cd   IN VARCHAR2 ,
  p_message_name                OUT NOCOPY Varchar2,
  p_source                      IN VARCHAR2 DEFAULT NULL,
  p_transf_course_cd            IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;


Procedure Enrp_Upd_Sca_Lapse(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_grace_days IN NUMBER ,
  p_log_creation_dt OUT NOCOPY DATE,
  p_trm_or_tch_cal_type IN VARCHAR2,
  p_trm_or_tch_seq_number IN NUMBER );
-- Add p_trm_or_tch_cal_type,p_trm_or_tch_seq_number parameters
-- pmarada,
Function Enrp_Upd_Sca_Status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name out NOCOPY Varchar2 )
RETURN boolean;

Procedure Enrp_Upd_Sca_Statusb(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY number,
  p_org_id IN NUMBER);

Function Enrp_Upd_Sca_Urule(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE )
RETURN BOOLEAN;


Function Enrp_Upd_Scho_Tfn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_tax_file_number IN NUMBER ,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN;


END IGS_EN_GEN_012;


 

/
