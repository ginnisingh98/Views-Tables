--------------------------------------------------------
--  DDL for Package IGS_CO_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSCO02S.pls 120.1 2005/09/08 16:24:33 appldev noship $ */
PROCEDURE CORP_UPD_OC_DT_SENT(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  varchar2,
  p_reference_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_issue_dt_c IN VARCHAR2 ,
  p_dt_sent_c IN VARCHAR2 );
--
FUNCTION CORP_DEL_CORI_SPL(
  p_correspondence_type IN VARCHAR2 ,
  p_reference_number IN NUMBER ,
  p_letter_delete IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2 )
RETURN BOOLEAN ;
--
FUNCTION CORP_INS_SPLP(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_spl_sequence_number IN NUMBER ,
  p_letter_parameter_type IN VARCHAR2 ,
  p_letter_repeating_group_cd IN VARCHAR2 ,
  p_splrg_sequence_number IN NUMBER ,
  p_record_number IN NUMBER ,
  p_letter_context_parameter IN VARCHAR2 ,
  p_extra_context OUT NOCOPY VARCHAR2 ,
  p_stored_ind OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2,
  p_letter_order_number IN NUMBER)
RETURN BOOLEAN ;
--
FUNCTION CORP_INS_SPL_DETAIL(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_letter_context_parameter IN VARCHAR2 ,
  p_spl_sequence_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
RETURN BOOLEAN ;
--

PROCEDURE corp_get_ocv_details(
  p_person_id IN OUT NOCOPY IGS_CO_OU_CO.person_id%TYPE ,
  p_correspondence_type IN OUT NOCOPY IGS_CO_ITM.CORRESPONDENCE_TYPE%TYPE ,
  p_cal_type IN OUT NOCOPY IGS_CO_OU_CO_REF.CAL_TYPE%TYPE ,
  p_ci_sequence_number IN OUT NOCOPY IGS_CO_OU_CO_REF.ci_sequence_number%TYPE,
  p_course_cd IN OUT NOCOPY IGS_CO_OU_CO_REF.course_cd%TYPE ,
  p_cv_version_number IN OUT NOCOPY IGS_CO_OU_CO_REF.cv_version_number%TYPE ,
  p_unit_cd IN OUT NOCOPY IGS_CO_OU_CO_REF.unit_cd%TYPE ,
  p_uv_version_number IN OUT NOCOPY IGS_CO_OU_CO_REF.uv_version_number%TYPE ,
  p_s_other_reference_type IN OUT NOCOPY IGS_CO_OU_CO_REF.S_OTHER_REFERENCE_TYPE%TYPE ,
  p_other_reference IN OUT NOCOPY IGS_CO_OU_CO_REF.other_reference%TYPE ,
  p_addr_type IN OUT NOCOPY IGS_CO_OU_CO.ADDR_TYPE%TYPE ,
  p_tracking_id IN OUT NOCOPY IGS_CO_OU_CO.tracking_id%TYPE ,
  p_request_num IN OUT NOCOPY IGS_CO_ITM.request_num%TYPE ,
  p_s_job_name IN OUT NOCOPY IGS_CO_ITM.s_job_name%TYPE ,
  p_request_job_id IN OUT NOCOPY IGS_CO_ITM.request_job_id%TYPE ,
  p_request_job_run_id IN OUT NOCOPY IGS_CO_ITM.request_job_run_id%TYPE,
  p_correspondence_cat OUT NOCOPY VARCHAR2 ,
  p_reference_number OUT NOCOPY IGS_CO_ITM.reference_number%TYPE ,
  p_issue_dt OUT NOCOPY IGS_CO_OU_CO.issue_dt%TYPE ,
  p_dt_sent OUT NOCOPY IGS_CO_OU_CO.dt_sent%TYPE ,
  p_unknown_return_dt OUT NOCOPY IGS_CO_OU_CO.unknown_return_dt%TYPE ,
  p_adt_description OUT NOCOPY varchar2,
  p_create_dt OUT NOCOPY IGS_CO_ITM.create_dt%TYPE ,
  p_originator_person_id OUT NOCOPY IGS_CO_ITM.originator_person_id%TYPE ,
  p_output_num OUT NOCOPY IGS_CO_ITM.output_num%TYPE ,
  p_oc_comments OUT NOCOPY IGS_CO_OU_CO.comments%TYPE ,
  p_cori_comments OUT NOCOPY IGS_CO_ITM.comments%TYPE ,
  p_message_name OUT NOCOPY varchar2 );
--
END IGS_CO_GEN_002;

 

/
