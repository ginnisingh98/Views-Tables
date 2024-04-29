--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SCHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SCHO" AUTHID CURRENT_USER AS
/* $Header: IGSEN63S.pls 115.4 2002/11/29 00:06:28 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function Declaration GENP_VAL_STRT_END_DT
  --                            removed .
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function Declaration GENP_VAL_SDTT_SESS
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- The pl/sql table of rowid has been removed according to vaw008 step 3.9
  -- Dt :08-Nov-99

  cst_error CONSTANT VARCHAR2(1) DEFAULT 'E';
  --
  --
  cst_warn CONSTANT VARCHAR2(1) DEFAULT 'W';
  --
  --
  cst_info CONSTANT VARCHAR2(1) DEFAULT 'I';
  --
  --
  cst_collection_yr CONSTANT NUMBER(4) DEFAULT TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'));
  --
  --
  cst_hecs_deferred CONSTANT VARCHAR2(10) DEFAULT '10';
  --
  --
  cst_hecs_upfront_discount CONSTANT VARCHAR2(10) DEFAULT '11';
  --
  --
  cst_hecs_upfront CONSTANT VARCHAR2(10) DEFAULT '12';
  --
  --
  cst_hecs_os_spec_crs CONSTANT VARCHAR2(10) DEFAULT '72';
  --
  --
  cst_hecs_non_os_spec_crs CONSTANT VARCHAR2(10) DEFAULT '71';
  --
  --
  cst_hecs_non_os_fee_paying_ug CONSTANT VARCHAR2(10) DEFAULT '19';
  --
  --
  cst_hecs_fee_paying_pg CONSTANT VARCHAR2(10) DEFAULT '20';
  --
  --
  cst_hecs_fee_paying_os CONSTANT VARCHAR2(10) DEFAULT '22';
  --
  --
  cst_hecs_os_student_charge CONSTANT VARCHAR2(10) DEFAULT '23';
  --
  --
  cst_hecs_fee_paying_os_spnsr CONSTANT VARCHAR2(10) DEFAULT '24';
  --
  --
  cst_hecs_enabling_crs CONSTANT VARCHAR2(10) DEFAULT '25';
  --
  --
  cst_hecs_non_award_crs CONSTANT VARCHAR2(10) DEFAULT '26';
  --
  --
  cst_hecs_employer_funded_crs CONSTANT VARCHAR2(10) DEFAULT '27';
  --
  --
  cst_hecs_os_exchange_student CONSTANT VARCHAR2(10) DEFAULT '30';
  --
  --
  cst_hecs_non_os_comm_ug_dis CONSTANT VARCHAR2(10) DEFAULT '31';
  --
  --
  cst_hecs_comm_industry CONSTANT VARCHAR2(10) DEFAULT '32';
  --
  --
  cst_hecs_work_experience CONSTANT VARCHAR2(10) DEFAULT '33';
  --
  --
  cst_hecs_pg_award CONSTANT VARCHAR2(10) DEFAULT '40';
  --
  --
  cst_hecs_special_course CONSTANT VARCHAR2(10) DEFAULT '70';
  --
  --
  cst_hecs_avondale_special CONSTANT VARCHAR2(10) DEFAULT '99';
  --
  --
  cst_hecs_type_deferred CONSTANT VARCHAR2(10) DEFAULT 'DEFERRED';
  --
  --
  cst_hecs_type_upfront_discount CONSTANT VARCHAR2(10) DEFAULT 'UPFRONT_D';
  --
  --
  cst_hecs_type_upfront CONSTANT VARCHAR2(10) DEFAULT 'UPFRONT';
  --
  --
  cst_hecs_type_exempt CONSTANT VARCHAR2(10) DEFAULT 'EXEMPT';
  --
  --
  cst_fee_paying_not CONSTANT NUMBER(1) DEFAULT 1;
  --
  --
  cst_fee_paying_os CONSTANT NUMBER(1) DEFAULT 2;
  --
  --
  cst_fee_paying_pg_course CONSTANT NUMBER(1) DEFAULT 3;
  --
  --
  cst_crs_higher_doctorate CONSTANT NUMBER(2) DEFAULT 1;
  --
  --
  cst_crs_cross_inst_pg CONSTANT NUMBER(2) DEFAULT 42;
  --
  --
  cst_crs_cross_inst_ug CONSTANT NUMBER(2) DEFAULT 41;
  --
  --
  cst_other_award CONSTANT NUMBER(2) DEFAULT 22;
  --
  --
  cst_crs_diploma CONSTANT NUMBER(2) DEFAULT 21;
  --
  --
  cst_crs_adv_diploma CONSTANT NUMBER(2) DEFAULT 20;
  --
  --
  cst_crs_assoc_degree CONSTANT NUMBER(2) DEFAULT 13;
  --
  --
  cst_crs_bachelor_pass CONSTANT NUMBER(2) DEFAULT 10;
  --
  --
  cst_crs_doctorate_research CONSTANT NUMBER(2) DEFAULT 2;
  --
  --
  cst_crs_masters_research CONSTANT NUMBER(2) DEFAULT 3;
  --
  --
  cst_crs_masters_crs_work CONSTANT NUMBER(2) DEFAULT 4;
  --
  --
  cst_crs_postgrad CONSTANT NUMBER(2) DEFAULT 5;
  --
  --
  cst_crs_grad_dip_pg_dip_new CONSTANT NUMBER(2) DEFAULT 6;
  --
  --
  cst_crs_grad_dip_pg_dip_extend CONSTANT NUMBER(2) DEFAULT 7;
  --
  --
  cst_crs_bachelor_graduate CONSTANT NUMBER(2) DEFAULT 8;
  --
  --
  cst_crs_bachelor_honours CONSTANT NUMBER(2) DEFAULT 9;
  --
  --
  cst_crs_graduate CONSTANT NUMBER(2) DEFAULT 11;
  --
  --
  cst_crs_doctorate_crs_work CONSTANT NUMBER(2) DEFAULT 12;
  --
  --
  cst_crs_enabling CONSTANT NUMBER(2) DEFAULT 30;
  --
  --
  cst_crs_cross_inst CONSTANT NUMBER(2) DEFAULT 40;
  --
  --
  cst_crs_non_award CONSTANT NUMBER(2) DEFAULT 50;
  --
  --
  cst_spcl_crs_amc CONSTANT VARCHAR2(2) DEFAULT '15';
  --
  --
  cst_citizen_aust CONSTANT NUMBER(1) DEFAULT 1;
  --
  --
  cst_citizen_nz CONSTANT NUMBER(1) DEFAULT 2;
  --
  --
  cst_citizen_perm CONSTANT NUMBER(1) DEFAULT 3;
  --
  --
  cst_citizen_temp_dip CONSTANT NUMBER(1) DEFAULT 4;
  --
  --
  cst_citizen_other CONSTANT NUMBER(1) DEFAULT 5;
  --
  --
  cst_perm_no CONSTANT NUMBER(1) DEFAULT 0;
  --
  --
  cst_born_os_no_info CONSTANT VARCHAR2(4) DEFAULT 'S999';
  --
  --
  cst_perm_in_out_aust_crs CONSTANT NUMBER(1) DEFAULT 1;
  --
  --
  cst_perm_out_aust_not_crs CONSTANT NUMBER(1) DEFAULT 2;
  --
  --
  cst_perm CONSTANT NUMBER(1) DEFAULT 3;
  --
  --
  cst_deleted CONSTANT VARCHAR2(7) DEFAULT 'DELETED';
  --
  --
  cst_completed CONSTANT VARCHAR2(9) DEFAULT 'COMPLETED';
  --
  --
  cst_off_shore CONSTANT VARCHAR2(2) DEFAULT '00';
  --
  --
  cst_no_arrival CONSTANT VARCHAR2(2) DEFAULT '01';
  --
  --
  cst_arrival_prior_1903 CONSTANT VARCHAR2(2) DEFAULT '02';
  --
  --
  cst_arrival_no_info CONSTANT VARCHAR2(2) DEFAULT 'A8';
  --
  --
  cst_no_info_aust CONSTANT VARCHAR2(2) DEFAULT 'A9';
  --
  -- Validate the delete of a student course HECS option record.
  FUNCTION enrp_val_scho_trgdel(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_scho_trgdel, WNDS);
  --
  -- To perform all validations on a scho record
  FUNCTION ENRP_VAL_SCHO_ALL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_differential_hecs_ind IN VARCHAR2 ,
  p_diff_hecs_ind_update_who IN VARCHAR2 ,
  p_diff_hecs_ind_update_on IN DATE ,
  p_diff_hecs_ind_update_comment IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 ,
  p_nz_citizen_ind IN VARCHAR2 ,
  p_nz_citizen_less2yr_ind IN VARCHAR2 ,
  p_nz_citizen_not_res_ind IN VARCHAR2 ,
  p_safety_net_ind IN VARCHAR2 ,
  p_tax_file_number IN NUMBER ,
  p_tax_file_number_collected_dt IN DATE ,
  p_tax_file_invalid_dt IN DATE ,
  p_tax_file_certificate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_SCHO_ALL, WNDS);

  --
  --
  -- Validate that there are no other open ended student course hecs option
  FUNCTION ENRP_VAL_SCHO_OPEN(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_SCHO_OPEN , WNDS);
  --
  -- Check for overlap in a students course hecs option records
  FUNCTION enrp_val_scho_ovrlp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scho_ovrlp , WNDS);
  --
  -- Validate student course HECS option start and end date.
  FUNCTION enrp_val_scho_st_end(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_scho_st_end, WNDS);
  --
  -- Validate student course attempt HECS payment option visa indicators.
  FUNCTION enrp_val_scho_visa(
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yrind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scho_visa , WNDS);
  --
  -- Validate student course attempt HECS payment option tax file number.
  FUNCTION enrp_val_scho_tfn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_tax_file_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_scho_tfn, WNDS);
  --
  -- To validate the HECS Payment Option for a Student course HECS option
  FUNCTION enrp_val_scho_hpo(
  p_hecs_payment_option IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_safety_net_ind IN VARCHAR2 DEFAULT 'N',
  p_tax_file_number IN NUMBER ,
  p_tax_file_number_collected_dt IN DATE ,
  p_tax_file_certificate_number IN NUMBER ,
  p_differential_hecs_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_scho_hpo, WNDS);
  --
  -- Validate the insert of a student course HECS option record.
  FUNCTION enrp_val_scho_insert(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scho_insert , WNDS);
  --
  -- Validate the update of a student course HECS option record.
  FUNCTION enrp_val_scho_update(
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scho_update , WNDS);
  --
  -- Validate the delete of a student course HECS option record.
  FUNCTION enrp_val_scho_delete(
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_scho_delete , WNDS);
  --
  -- Validate HECS option, citizenship code and permanent resident.
  FUNCTION enrp_val_ho_cic_prc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_perm_resident_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_ho_cic_prc, WNDS);
  --
  -- Validate HECS visa indicators, citizenship cd and permanent resident.
  FUNCTION enrp_val_vis_cic_prc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_perm_resident_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_vis_cic_prc, WNDS);
  --
  -- Validate the HECS Payment Option against the course type.
  FUNCTION enrp_val_hpo_crs_typ(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_hpo_crs_typ , WNDS);
  --
  -- Validate the HECS Payment Option against the special course type.
  FUNCTION enrp_val_hpo_spc_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_hpo_spc_crs , WNDS);
  --
  -- Validate HECS payment option, visa indicators and citizenship code.
  FUNCTION enrp_val_hpo_vis_cic(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 ,
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_yr_arrival IN VARCHAR2 ,
  p_citizenship_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_hpo_vis_cic , WNDS);
  --
  -- Validate HECS payment option, citizenship code and permanent resident.
  FUNCTION enrp_val_hpo_cic_prc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_perm_resident_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_hpo_cic_prc , WNDS);
  --
  -- Validate the HECS pay option, the course type and the citizenship cd.
  FUNCTION enrp_val_hpo_crs_cic(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_hpo_crs_cic, WNDS);
  --
  -- Validate HECS payment option and the citizenship code.
  FUNCTION enrp_val_hpo_cic(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_hpo_cic , WNDS);
  --
  -- Validate the HECS payment option closed indicator.
  FUNCTION enrp_val_hpo_closed(
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_hpo_closed , WNDS);
  --
  -- Validate HECS payment option, citizenship code and other statistics.
  FUNCTION enrp_val_hpo_cic_ps(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_yr_arrival IN VARCHAR2 ,
  p_term_location_country IN VARCHAR2 ,
  p_term_location_postcode IN NUMBER ,
  p_collection_yr IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_hpo_cic_ps, WNDS);
  --
  -- Validate that scho end date is in accordance with expiry restriction.
  FUNCTION enrp_val_scho_expire(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the HECS option tax file number certificate number.
  FUNCTION enrp_val_tfn_crtfct(
  p_tax_file_number IN NUMBER ,
  p_tax_file_invalid_dt IN DATE ,
  p_tax_file_certificate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_tfn_crtfct , WNDS);
  --
  -- Validate the HECS option tax file number invalid date.
  FUNCTION enrp_val_tfn_invalid(
  p_tax_file_number IN NUMBER ,
  p_tax_file_invalid_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_tfn_invalid , WNDS);
END IGS_EN_VAL_SCHO;

 

/
