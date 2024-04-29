--------------------------------------------------------
--  DDL for Package Body IGS_AS_PRC_TRANSCRPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_PRC_TRANSCRPT" AS
/* $Header: IGSAS08B.pls 120.1 2006/02/13 02:40:57 amanohar noship $ */
/* Change History :
   Who             When             What

   ckasu           19-APR-2004      BUG#3553220 - Modified declaration of v_out_string
                                    variable in procedure assp_get_trn_res_dtl
   jbegum          25-Jun-2003      BUG#2930935
                                    Modified local functions ASSP_GET_TRN_SUT_DTL,
                                    ASSP_GET_TRN_SUA_DTL.
*/
-- Retrieves graduation details for display on transcript
FUNCTION assp_get_trn_grd_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_grd_dtl
-- This module retrieves student graduation details for use in the
-- Correspondence Letter Facility for such correspondence as the Academic
-- Transcript.
--
-- The elements retrieved by this module are:
--     Gradiation Statement.
DECLARE
v_index              BINARY_INTEGER;
v_out_string  VARCHAR2(300);
CURSOR c_grd IS
SELECT sca.person_id,
sca.course_cd,
sca.course_rqrmnts_complete_dt,
SYSDATE,
ci.alternate_code,
gr.s_graduand_type,
gr.conferral_dt,
gst.s_graduand_status,
aw.award_title
FROM   IGS_EN_STDNT_PS_ATT  sca,
IGS_GR_GRADUAND             gr,
IGS_GR_STAT          gst,
IGS_CA_INST          ci,
IGS_PS_AWD                  aw
WHERE  sca.person_id               = p_person_id AND
sca.course_cd               = p_course_cd AND
sca.course_rqrmnt_complete_ind     = 'Y' AND
sca.person_id               = gr.person_id AND
sca.course_cd               = gr.course_cd AND
gr.GRADUAND_STATUS          = gst.GRADUAND_STATUS AND
gst.s_graduand_status              in ('ELIGIBLE','GRADUATED') AND
gr.award_cd                 = aw.award_cd AND
ci.CAL_TYPE                 = p_acad_cal_type AND
ci.sequence_number          = p_acad_ci_sequence_number AND
((sca.course_rqrmnts_complete_dt   BETWEEN ci.start_dt AND ci.end_dt) OR
(sca.course_rqrmnts_complete_dt >
ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind)))
UNION
SELECT sca.person_id,
sca.course_cd,
sca.course_rqrmnts_complete_dt,
SYSDATE,
ci.alternate_code,
NULL,
SYSDATE,
NULL,
NULL
FROM   IGS_EN_STDNT_PS_ATT  sca,
IGS_CA_INST          ci
WHERE  sca.person_id               = p_person_id AND
sca.course_cd               = p_course_cd AND
sca.course_rqrmnt_complete_ind     = 'Y' AND
ci.CAL_TYPE                 = p_acad_cal_type AND
ci.sequence_number          = p_acad_ci_sequence_number AND
((sca.course_rqrmnts_complete_dt   BETWEEN ci.start_dt AND ci.end_dt) OR
(sca.course_rqrmnts_complete_dt >
ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind))) AND
NOT EXISTS (select '1' from IGS_GR_GRADUAND gr
where gr.person_id = sca.person_id
and gr.course_cd = sca.course_cd)
ORDER BY 3;
BEGIN
-- Determine if this is the first time the procedure has been called for the
-- PERSON.
-- If so, then populate the PL/SQL table that will be used to retrieve the rest
-- of the records returned from the query.
IF p_record_number = 1 THEN
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index := 0;
FOR v_grd_rec IN c_grd LOOP
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index := c_grd%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_acad_alternate_code :=
v_grd_rec.alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_course_cd := v_grd_rec.course_cd;
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_completion_dt :=
v_grd_rec.course_rqrmnts_complete_dt;
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_conferral_dt :=
v_grd_rec.conferral_dt;
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_award_title :=
v_grd_rec.award_title;
IF v_grd_rec.s_graduand_type = 'ARTICULATE' THEN
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_type := 'COMP_NOAWD';
ELSIF v_grd_rec.s_graduand_status = 'GRADUATED' THEN
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_type := 'COMP_GRAD';
ELSIF v_grd_rec.s_graduand_status = 'ELIGIBLE' THEN
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_type := 'COMP_ELIG';
ELSE
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index).v_type := 'COMPLETED';
END IF;
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_parameter_type and the
-- p_record_number
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_grd_dtl_index THEN
IF p_record_number = 1 THEN  -- first time through, do a page throw.
IF p_s_letter_parameter_type = 'TRN_GRD_LN' THEN
IF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMP_GRAD' THEN
v_out_string := fnd_global.local_chr(10) || 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt) || '. AWARD OF ' ||
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_award_title
||' CONFERRED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_conferral_dt);
ELSIF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMP_ELIG' THEN
v_out_string := fnd_global.local_chr(10) || 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt) || '.  AWARD OF ' ||
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_award_title ||
' TO BE CONFERRED AT A FORTHCOMING GRADUATION CEREMONY.';
ELSIF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMP_NOAWD' THEN
v_out_string := fnd_global.local_chr(10) || 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt) || '.  PROCEEDING TO A HIGHER AWARD.';
ELSIF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMPLETED' THEN
v_out_string := fnd_global.local_chr(10) || 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt);
END IF;
ELSE
v_out_string := NULL;
END IF;
ELSE
IF p_s_letter_parameter_type = 'TRN_GRD_LN' THEN
IF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMP_GRAD' THEN
v_out_string := 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt) || '.  AWARD OF ' ||
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_award_title
||' CONFERRED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_conferral_dt);
ELSIF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMP_ELIG' THEN
v_out_string := 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt) || '.  AWARD OF ' ||
IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_award_title ||
' TO BE CONFERRED AT A FORTHCOMING GRADUATION CEREMONY.';
ELSIF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMP_NOAWD' THEN
v_out_string := 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt) || '.  PROCEEDING TO A HIGHER AWARD.';
ELSIF IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(v_index).v_type
= 'COMPLETED' THEN
v_out_string := 'COURSE REQUIREMENTS COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_grd_dtl_table(
v_index).v_completion_dt);
END IF;
ELSE
v_out_string := NULL;
END IF;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_grd%ISOPEN THEN
CLOSE c_grd;
END IF;
RAISE;
END;
END assp_get_trn_grd_dtl;
--
-- To get one component of a string which is delimited.
FUNCTION ASSP_GET_TRN_DESC(
p_extract_course_cd IN VARCHAR2 )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_desc
-- Parse the p_input_str, return the p_element_num_th
-- of the string delimited by p_delimiter.
DECLARE
v_ret_val            VARCHAR2(30);
BEGIN
-- Validate input parameter
IF p_extract_course_cd IS NULL THEN
RETURN NULL;
ELSE
v_ret_val := 'EXTRACT OF ACADEMIC RECORD';
RETURN v_ret_val;
END IF;
END;
END assp_get_trn_desc;
--
-- Retrieves research details for display on transcript.
FUNCTION assp_get_trn_res_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_res_dtl
-- Description.:This function determines if the PERSON has undertaken any
-- research for the nominated COURSE code.  It returns the THESIS TITLE
-- for use in the Correspondence Letter Facility for such correspondence
-- as the Academic Transcript.
--Who             When             What
--jbegum          25-Jun-2003      BUG#2930935 - Modified cursor c_sua.
--ckasu           19-APR-2004      BUG#3553220 - Modified declaration of
--                                 v_out_string variable

DECLARE
v_index                            BINARY_INTEGER;
v_out_string                VARCHAR2(2100);
CURSOR c_res IS
SELECT ca.person_id,
ca.sca_course_cd,
th.TITLE,
th.final_title_ind,
ci.alternate_code
FROM   IGS_RE_CANDIDATURE          ca,
IGS_RE_THESIS               th,
IGS_EN_STDNT_PS_ATT  sca,
IGS_CA_INST          ci
WHERE  ca.person_id         = p_person_id AND
ca.sca_course_cd     = p_course_cd AND
ca.person_id         = th.person_id AND
ca.sequence_number   = th.ca_sequence_number AND
ca.person_id         = sca.person_id AND
ca.sca_course_cd     = sca.course_cd AND
ci.CAL_TYPE          = p_acad_cal_type AND
ci.sequence_number   = p_acad_ci_sequence_number AND
((sca.commencement_dt       BETWEEN ci.start_dt AND ci.end_dt) OR
(sca.commencement_dt >
ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind)))
ORDER BY
sca.commencement_dt;
BEGIN
IF p_person_id IS NULL OR
p_course_cd IS NULL OR
p_s_letter_parameter_type IS NULL OR
p_acad_cal_type IS NULL OR
p_acad_ci_sequence_number IS NULL OR
p_record_number IS NULL THEN
RETURN NULL;
END IF;
IF p_record_number = 1 THEN
IGS_AS_PRC_TRANSCRPT.gv_res_dtl_index := 0;
FOR v_res_rec IN c_res LOOP
IGS_AS_PRC_TRANSCRPT.gv_res_dtl_index := c_res%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_res_dtl_index).v_teach_alternate_code :=
v_res_rec.alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_res_dtl_index).v_course_cd :=
v_res_rec.sca_course_cd;
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_res_dtl_index).v_title :=
v_res_rec.TITLE;
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_res_dtl_index).v_final_title_ind :=
v_res_rec.final_title_ind;
END LOOP;
END IF;
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_res_dtl_index THEN
IF p_s_letter_parameter_type = 'TRN_RES_LN' THEN
IF p_record_number = 1 THEN
IF IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(v_index).v_final_title_ind
= 'Y' THEN
v_out_string := fnd_global.local_chr(10) || 'THESIS TITLE: ' ||
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(v_index).v_title;
ELSE
v_out_string := fnd_global.local_chr(10) || 'WORKING THESIS TITLE: ' ||
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(v_index).v_title;
END IF;
ELSE
IF IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(v_index).v_final_title_ind
= 'Y' THEN
v_out_string := 'THESIS TITLE: ' ||
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(v_index).v_title;
ELSE
v_out_string := 'WORKING THESIS TITLE: ' ||
IGS_AS_PRC_TRANSCRPT.gt_res_dtl_table(v_index).v_title;
END IF;
END IF;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF (c_res%ISOPEN) THEN
CLOSE c_res;
END IF;
RAISE;
END;
END assp_get_trn_res_dtl;
--
-- Retrieves UNIT set attempt details for display on transcript.
FUNCTION assp_get_trn_us_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_us_dtl
-- This module retrieves student UNIT set attempt deatails for use in the
-- Correspondence Letter Facility for such correspondence as the
-- Academic Transcript.
--
-- The elements retrieved by this module are:
--     UNIT Set Code,
--     UNIT Set TITLE,
--     UNIT Set Category,
--     Selection Date,
--     Completion Date,
--     Primary Set Indicator
DECLARE
v_index                            BINARY_INTEGER;
v_out_string                VARCHAR2(300);
cst_trn_usc_al       CONSTANT      VARCHAR2(15) := 'TRN_USC_AL';
cst_trn_uss_al       CONSTANT      VARCHAR2(15) := 'TRN_USS_AL';
cst_trn_usc_ps       CONSTANT      VARCHAR2(15) := 'TRN_USC_PS';
cst_trn_uss_ps       CONSTANT      VARCHAR2(15) := 'TRN_USS_PS';
cst_trn_us_usc       CONSTANT      VARCHAR2(15) := 'TRN_US_USC';
cst_trn_us_tl CONSTANT      VARCHAR2(15) := 'TRN_US_TL';
cst_trn_us_cd CONSTANT      VARCHAR2(15) := 'TRN_US_CD';
CURSOR c_susa IS
SELECT susa.person_id,
susa.unit_set_cd,
NVL(susa.override_title, us.title) unit_set_title,
us.UNIT_SET_CAT,
usc.description,
susa.selection_dt,
susa.end_dt,
susa.rqrmnts_complete_dt,
susa.primary_set_ind
FROM   IGS_AS_SU_SETATMPT   susa,
IGS_EN_UNIT_SET                    us,
IGS_EN_UNIT_SET_CAT                usc,
IGS_CA_INST                 ci
WHERE  susa.person_id                     = p_person_id AND
susa.course_cd                     = p_course_cd AND
susa.student_confirmed_ind  = 'Y' AND
susa.rqrmnts_complete_ind   = 'Y' AND
susa.end_dt                 IS NULL AND
susa.unit_set_cd            = us.unit_set_cd AND
susa.us_version_number             = us.version_number AND
us.UNIT_SET_CAT                    = usc.UNIT_SET_CAT AND
ci.CAL_TYPE                 = p_acad_cal_type AND
ci.sequence_number          = p_acad_ci_sequence_number AND
(((susa.selection_dt        BETWEEN ci.start_dt AND ci.end_dt) OR
(susa.rqrmnts_complete_dt   BETWEEN ci.start_dt AND ci.end_dt)) OR
(susa.selection_dt >
ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind)) OR
(susa.rqrmnts_complete_dt >
ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind)))
ORDER BY
susa.unit_set_cd,
susa.selection_dt,
susa.rqrmnts_complete_dt;
BEGIN
-- Determine if this is the first time the procedure has been called for the
-- PERSON
-- (p_record_number = 1).
IF p_record_number = 1 THEN
-- Intialise the counter for the PL/SQL table.
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index := 0;
-- Populate the PL/SQL table.
FOR v_susa_rec IN c_susa LOOP
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index := c_susa%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index).v_unit_set_cd :=
v_susa_rec.unit_set_cd;
IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index).v_title :=
v_susa_rec.unit_set_title;
IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index).v_unit_set_cat :=
v_susa_rec.UNIT_SET_CAT;
IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index).v_unit_set_cat_desc :=
v_susa_rec.description;
IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index).v_selection_dt :=
v_susa_rec.selection_dt;
IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index).v_primary_set_ind :=
v_susa_rec.primary_set_ind;
IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index).v_completion_dt :=
v_susa_rec.rqrmnts_complete_dt;
END LOOP;
END IF;
-- Create thee output string based on the p_s_letter_parameter_type and the
-- p_record_number.
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_susa_dtl_index THEN
IF p_s_letter_parameter_type = cst_trn_usc_al THEN
-- all completed UNIT sets
IF IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_completion_dt IS NOT NULL THEN
IF p_record_number = 1 THEN
v_out_string := fnd_global.local_chr(10) || NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-') || ' COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_completion_dt);
ELSE
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-') || ' COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_completion_dt);
END IF;
END IF;
ELSIF p_s_letter_parameter_type = cst_trn_uss_al THEN
-- all selected UNIT sets.
IF IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_selection_dt IS NOT NULL THEN
IF p_record_number = 1 THEN
v_out_string := fnd_global.local_chr(10) || NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-')
|| ' SELECTED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_selection_dt);
ELSE
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-')
|| ' SELECTED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_selection_dt);
END IF;
END IF;
ELSIF p_s_letter_parameter_type = cst_trn_usc_ps THEN
-- only completed primary UNIT sets.
IF IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_primary_set_ind = 'Y' THEN
IF IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_completion_dt IS NOT NULL THEN
IF p_record_number = 1 THEN
v_out_string := fnd_global.local_chr(10) || NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-')
|| ' COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(v_index).v_completion_dt);
ELSE
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-')
|| ' COMPLETED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_completion_dt);
END IF;
END IF;
END IF;
ELSIF p_s_letter_parameter_type = cst_trn_uss_ps THEN
-- only selected primary UNIT sets.
IF IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_primary_set_ind = 'Y' THEN
IF IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_selection_dt IS NOT NULL THEN
IF p_record_number = 1 THEN
v_out_string := fnd_global.local_chr(10) || NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-')
|| ' SELECTED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_selection_dt);
ELSE
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-')
|| ' SELECTED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_selection_dt);
END IF;
END IF;
END IF;
ELSIF p_s_letter_parameter_type = cst_trn_us_usc THEN
v_out_string := RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_unit_set_cat,'-'),10);
ELSIF p_s_letter_parameter_type = cst_trn_us_tl THEN
v_out_string := RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_title,'-'),90);
ELSIF p_s_letter_parameter_type = cst_trn_us_cd THEN
v_out_string := RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_susa_dtl_table(
v_index).v_unit_set_cd,'-'),10);
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_susa%ISOPEN THEN
CLOSE c_susa;
END IF;
RAISE;
END;

END assp_get_trn_us_dtl;
--
-- Retrieves UNIT transfer details for display on transcript
FUNCTION assp_get_trn_sut_dtl(
p_person_id IN NUMBER ,
p_to_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_sut_dtl
-- This module retrieves transferred UNIT details for use in the
-- Correspondence Letter Facility for such correspondence as the
-- Academic Transcript.
--
-- The elements retrieved by this module are:
--     UNIT Code,
--     UNIT TITLE,
--     Credit POintsa Achievable,
--     UNIT Level,
--     Mark,
--     Grade.
DECLARE
v_index                                   BINARY_INTEGER;
v_out_string                       VARCHAR2(300);
v_s_result                         VARCHAR2(20);
v_outcome_dt                       DATE;
v_grading_schema_cd                IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
v_gs_version_number                IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
v_grade                                   IGS_AS_GRD_SCH_GRADE.grade%TYPE;
v_mark                             IGS_AS_GRD_SCH_GRADE.lower_mark_range%TYPE;
v_origin_course_cd                 IGS_PS_VER.course_cd%TYPE;
cst_trn_sut_ln              CONSTANT      VARCHAR2(15) := 'TRN_SUT_LN';
cst_trn_sut_cd              CONSTANT      VARCHAR2(15) := 'TRN_SUT_CD';
cst_trn_sut_ul              CONSTANT      VARCHAR2(15) := 'TRN_SUT_UL';
cst_trn_sut_tl              CONSTANT      VARCHAR2(15) := 'TRN_SUT_TL';
cst_trn_sut_pd              CONSTANT      VARCHAR2(15) := 'TRN_SUT_PD';
cst_trn_sut_yr              CONSTANT      VARCHAR2(15) := 'TRN_SUT_YR';
cst_trn_sut_mk              CONSTANT      VARCHAR2(15) := 'TRN_SUT_MK';
cst_trn_sut_gd              CONSTANT      VARCHAR2(15) := 'TRN_SUT_GD';
cst_trn_sut_gs              CONSTANT      VARCHAR2(15) := 'TRN_SUT_GS';
cst_trn_sut_gv              CONSTANT      VARCHAR2(15) := 'TRN_SUT_GV';
cst_trn_sut_cp              CONSTANT      VARCHAR2(15) := 'TRN_SUT_CP';

--Who             When             What
--jbegum          25-Jun-2003      BUG#2930935 - Modified cursor c_sut.
CURSOR c_sut IS
SELECT   sut.person_id, sut.course_cd, sut.unit_cd, sut.cal_type,
         sut.ci_sequence_number, sut.uoo_id, uv.short_title, uv.title,
         NVL (cps.achievable_credit_points, uv.achievable_credit_points),
         uv.unit_level,
         igs_en_gen_014.enrs_get_acad_alt_cd
                                  (sut.cal_type,
                                   sut.ci_sequence_number
                                  ) acad_alternate_code,
         igs_ca_gen_001.calp_get_alt_cd
                                 (sut.cal_type,
                                  sut.ci_sequence_number
                                 ) teach_alternate_code,
         ci.alternate_code,
         NVL (suav.override_achievable_cp,
              NVL (cps.achievable_credit_points, uv.achievable_credit_points)
             ) v_cp_achieved,
         NVL (suav.override_enrolled_cp,
              NVL (cps.enrolled_credit_points, uv.enrolled_credit_points)
             ) v_cp_achievable
    FROM igs_ps_stdnt_unt_trn sut,
         igs_ps_stdnt_trn sct,
         igs_en_su_attempt_all suav,
         igs_ps_usec_cps cps,
         igs_ps_unit_ver uv,
         igs_ca_inst ci
   WHERE sut.person_id = p_person_id
     AND sut.course_cd = p_to_course_cd
     AND sut.person_id = sct.person_id
     AND sut.course_cd = sct.course_cd
     AND sut.transfer_course_cd = sct.transfer_course_cd
     AND sut.unit_cd = uv.unit_cd
     AND suav.person_id = sut.person_id
     AND suav.course_cd = sut.transfer_course_cd
     AND suav.version_number = uv.version_number
     AND suav.uoo_id = sut.uoo_id
     AND suav.uoo_id = cps.uoo_id(+)
     AND ci.cal_type = p_acad_cal_type
     AND ci.sequence_number = p_acad_ci_sequence_number
     AND (sut.transfer_dt BETWEEN ci.start_dt AND ci.end_dt)
ORDER BY sut.unit_cd;

BEGIN
-- Determine if this is the first time the procedure has been run for the
-- PERSON.
IF p_record_number = 1 THEN
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index := 0;
FOR v_sut_rec IN c_sut LOOP
v_s_result := IGS_AS_GEN_003.ASSP_GET_SUA_OUTCOME(
v_sut_rec.person_id,
v_sut_rec.course_cd,
v_sut_rec.unit_cd,
v_sut_rec.CAL_TYPE,
v_sut_rec.ci_sequence_number,
'DUPLICATE',
'Y',
v_outcome_dt,
v_grading_schema_cd,
v_gs_version_number,
v_grade,
v_mark,
v_origin_course_cd,
-- anilk, 22-Apr-2003, Bug# 2829262
v_sut_rec.uoo_id,
---added by LKAKI----
'N');
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index := c_sut%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_acad_alternate_code :=
v_sut_rec.acad_alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_teach_alternate_code :=
v_sut_rec.teach_alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_unit_cd :=
v_sut_rec.unit_cd;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_short_title :=
v_sut_rec.short_title;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_title :=
v_sut_rec.TITLE;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_cp_achievable :=
v_sut_rec.v_cp_achievable;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_cp_achieved :=
v_sut_rec.v_cp_achieved;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_unit_level :=
v_sut_rec.UNIT_LEVEL;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_mark := v_mark;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_grade := v_grade;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_grading_schema_cd :=
v_grading_schema_cd;
IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index).v_gs_version_number :=
v_gs_version_number;
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_parameter_type and the
-- p_record_number
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_sut_dtl_index THEN
IF p_s_letter_parameter_type = cst_trn_sut_ln THEN
v_out_string := RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_teach_alternate_code,'-'),10)
|| fnd_global.local_chr(09) ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_unit_cd,'-'),10)
|| fnd_global.local_chr(09) ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_title,'-'),40);
ELSIF p_s_letter_parameter_type = cst_trn_sut_cd THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_unit_cd,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_tl THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_short_title,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_pd THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_teach_alternate_code,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_yr THEN
v_out_string := '(' || NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_acad_alternate_code,'-') || ')';
ELSIF p_s_letter_parameter_type = cst_trn_sut_ul THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_unit_level,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_mk THEN
v_out_string := NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_mark,'990'),'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_gd THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_grade,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_gs THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_grading_schema_cd,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_gv THEN
v_out_string := NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_gs_version_number),'-');
ELSIF p_s_letter_parameter_type = cst_trn_sut_cp THEN
v_out_string := NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sut_dtl_table(
v_index).v_cp_achievable,'990D99'),'-');
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_sut%ISOPEN THEN
CLOSE c_sut;
END IF;
RAISE;
END;
EXCEPTION WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_sut_dtl');
       --IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_sut_dtl;
--
-- Retrieves COURSE transfer details for display on transcript
FUNCTION assp_get_trn_sct_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_sct_dtl
-- This module retrieves student COURSE transfer details for use in the
-- Correspondence Letter Facility for such correspondence as the
-- Academic Transcript.
--
-- The elements retrieved by this module are:
--     COURSE Code,
--     Transfer COURSE Code,
--     Transfer Date
DECLARE
v_index              BINARY_INTEGER;
v_out_string  VARCHAR2(300);
v_sut_course_cd      IGS_PS_STDNT_UNT_TRN.transfer_course_cd%TYPE;
CURSOR c_sct IS
SELECT sct.person_id,
sct.transfer_course_cd,
sct.course_cd,
sct.transfer_dt,
ci.alternate_code
FROM   IGS_PS_STDNT_TRN     sct,
IGS_CA_INST          ci
WHERE  sct.person_id        = p_person_id AND
sct.course_cd        = p_course_cd AND
ci.CAL_TYPE          = p_acad_cal_type AND
ci.sequence_number   = p_acad_ci_sequence_number AND
(sct.transfer_Dt     BETWEEN ci.start_dt AND ci.end_dt)
ORDER BY
sct.transfer_dt;
CURSOR c_sut (
cp_from_course_cd    IGS_PS_STDNT_UNT_TRN.transfer_course_cd%TYPE) IS
SELECT sut.unit_cd
FROM   IGS_PS_STDNT_UNT_TRN sut,
IGS_CA_INST          ci
WHERE  sut.person_id        = p_person_id AND
sut.course_cd        = p_course_cd AND
sut.transfer_course_cd      = cp_from_course_cd AND
ci.CAL_TYPE          = p_acad_cal_type AND
ci.sequence_number   = p_acad_ci_sequence_number AND
(sut.transfer_dt     BETWEEN ci.start_dt AND ci.end_dt);
BEGIN
-- Determine if this is the first time the procedure has been run for
-- the PERSON.
IF p_record_number = 1 THEN
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index := 0;
FOR v_sct_rec IN c_sct LOOP
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index := c_sct%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index).v_teach_alternate_code :=
v_sct_rec.alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index).v_from_course :=
v_sct_rec.transfer_course_cd;
IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index).v_to_course :=
v_sct_rec.course_cd;
IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index).v_transfer_dt :=
v_sct_rec.transfer_dt;
-- Determine if any units were transferred with the COURSE.
OPEN   c_sut(v_sct_rec.transfer_course_cd);
FETCH  c_sut  INTO   v_sut_course_cd;
IF (c_sut%NOTFOUND) THEN
IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index).v_unit_ind := 'N';
CLOSE  c_sut;
ELSE
IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index).v_unit_ind := 'Y';
CLOSE  c_sut;
END IF;
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_parameter_type and the
-- p_record_number.
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_sct_dtl_index THEN
IF p_s_letter_parameter_type = 'TRN_SCT' THEN
IF p_record_number = 1 THEN
IF IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(v_index).v_unit_ind = 'Y' THEN
v_out_string := fnd_global.local_chr(10) || 'TRANSFERRED FROM COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_from_course,'-') || ' TO COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_to_course,'-') || ' ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_transfer_dt) ||
'.  UNIT ATTEMPTS TRANSFERRED:' || fnd_global.local_chr(10);
ELSE
v_out_string := fnd_global.local_chr(10) || 'TRANSFERRED FROM COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_from_course,'-') || ' TO COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_to_course,'-') || ' ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_transfer_dt) || '.' || fnd_global.local_chr(10);
END IF;
ELSE
IF IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(v_index).v_unit_ind = 'Y' THEN
v_out_string := 'TRANSFERRED FROM COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_from_course,'-') || ' TO COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_to_course,'-') || ' ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_transfer_dt) ||
'.  UNIT ATTEMPTS TRANSFERRED:' || fnd_global.local_chr(10);
ELSE
v_out_string := 'TRANSFERRED FROM COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_from_course,'-') || ' TO COURSE ' ||
NVL(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_to_course,'-') || ' ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_sct_dtl_table(
v_index).v_transfer_dt) || '.' || fnd_global.local_chr(10);
END IF;
END IF;
ELSE
v_out_string := NULL;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_sct%ISOPEN THEN
CLOSE c_sct;
END IF;
RAISE;
END;
EXCEPTION WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_sct_dtl');
       --IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_sct_dtl;
--
-- Retrieves COURSE standing details for display on transcript
FUNCTION assp_get_trn_crs_std(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_crs_std
-- This module retrieves student COURSE standing details for use in the
-- Correspondence Letter Facility for such correspondence as the Academic
-- Transcript.
--
-- The elements retrieved by this module are:
--     COURSE Standing Statement.
DECLARE
v_index              BINARY_INTEGER;
v_out_string  VARCHAR2(300);
CURSOR c_sci IS
SELECT 'INTERMIT'    rec_type,
sci.person_id,
sci.course_cd,
sci.start_dt  start_dt,
sci.end_dt    end_dt,
ci.alternate_code,
NULL n1,
SYSDATE ,
NULL n2,
NULL n3
FROM   IGS_EN_STDNT_PS_INTM sci,
IGS_CA_INST                 ci
WHERE  sci.person_id        = p_person_id AND
sci.course_cd        = p_course_cd AND
sci.end_dt           IS NOT NULL AND
ci.CAL_TYPE          = p_acad_cal_type AND
ci.sequence_number   = p_acad_ci_sequence_number AND
((sci.start_dt              BETWEEN ci.start_dt AND ci.end_dt) OR
(sci.start_dt > ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind)))
UNION
SELECT 'LAPSED' rec_type,
sca.person_id,
sca.course_cd,
sca.lapsed_dt,
SYSDATE,
ci.alternate_code,
NULL n4,
SYSDATE,
NULL n5,
NULL n6
FROM   IGS_EN_STDNT_PS_ATT  sca,
IGS_CA_INST          ci
WHERE  sca.person_id        = p_person_id AND
sca.course_cd        = p_course_cd AND
sca.lapsed_dt        IS NOT NULL AND
ci.CAL_TYPE          = p_acad_cal_type AND
ci.sequence_number   = p_acad_ci_sequence_number AND
((sca.lapsed_dt             BETWEEN ci.start_dt AND ci.end_dt) OR
(sca.lapsed_dt > ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind)))
UNION
SELECT 'DISCONTIN' rec_type,
sca.person_id,
sca.course_cd,
sca.discontinued_dt,
SYSDATE,
ci.alternate_code,
NULL n7,
SYSDATE,
NULL n8,
NULL n9
FROM   IGS_EN_STDNT_PS_ATT  sca,
IGS_CA_INST          ci
WHERE  sca.person_id        = p_person_id AND
sca.course_cd        = p_course_cd AND
sca.discontinued_dt  IS NOT NULL AND
ci.CAL_TYPE          = p_acad_cal_type AND
ci.sequence_number   = p_acad_ci_sequence_number AND
((sca.discontinued_dt       BETWEEN ci.start_dt AND ci.end_dt) OR
(sca.discontinued_dt > ci.start_dt AND SUBSTR(IGS_GE_DATE.IGSCHAR(ci.start_dt),1,4) =
IGS_AS_GEN_005.ASSP_VAL_SCA_FINAL (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind)))
ORDER BY 4;
BEGIN
-- Determine if this is the first time the procedure has been called for the
-- PERSON.
-- If so, then populate the PL/SQL table that will be used to retrieve the rest
-- of the records returned from the query.
IF p_record_number = 1 THEN
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index := 0;
FOR v_sci_rec IN c_sci LOOP
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index := c_sci%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_acad_alternate_code :=
v_sci_rec.alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_course_cd := v_sci_rec.course_cd;
IF v_sci_rec.rec_type = 'INTERMIT' THEN
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_int_start_dt :=
v_sci_rec.start_dt;
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_int_end_dt := v_sci_rec.end_dt;
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_type := 'INTERMIT';
END IF;
IF v_sci_rec.rec_type = 'LAPSED' THEN
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_lapsed_dt :=
v_sci_rec.start_dt;
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_type := 'LAPSED';
END IF;
IF v_sci_rec.rec_type = 'DISCONTIN' THEN
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_discontinued_dt :=
v_sci_rec.start_dt;
IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index).v_type := 'DISCONTIN';
END IF;
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_parameter_type and the
-- p_record_number
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_stdg_dtl_index THEN
IF p_record_number = 1 THEN  -- first time through, do a page throw.
IF p_s_letter_parameter_type = 'TRN_STDG' THEN
IF IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_type = 'INTERMIT' THEN
v_out_string := fnd_global.local_chr(10) || 'COURSE ENROLMENT INTERMITTED FROM ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_int_start_dt
) || ' TO ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_int_end_dt);
ELSIF IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_type = 'LAPSED' THEN
v_out_string := fnd_global.local_chr(10) || 'ENROLMENT LAPSED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_lapsed_dt);
ELSIF IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_type
= 'DISCONTIN' THEN
v_out_string := fnd_global.local_chr(10) || 'COURSE ENROLMENT DISCONTINUED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
v_index).v_discontinued_dt);
END IF;
ELSE
v_out_string := NULL;
END IF;
ELSE
IF p_s_letter_parameter_type = 'TRN_STDG' THEN
IF IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_type = 'INTERMIT' THEN
v_out_string := 'COURSE ENROLMENT INTERMITTED FROM ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_int_start_dt
) || ' TO ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_int_end_dt
);
ELSIF IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_type = 'LAPSED' THEN
v_out_string := 'ENROLEMENT LAPSED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_lapsed_dt
);
ELSIF IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(v_index).v_type
= 'DISCONTIN' THEN
v_out_string := 'COURSE ENROLMENT DISCONTINUED ON ' ||
FND_DATE.DATE_TO_DISPLAYDATE(IGS_AS_PRC_TRANSCRPT.gt_stdg_dtl_table(
v_index).v_discontinued_dt);
END IF;
ELSE
v_out_string := NULL;
END IF;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_sci%ISOPEN THEN
CLOSE c_sci;
END IF;
RAISE;
END;
EXCEPTION WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_crs_std');
       --IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_crs_std;
--
-- Retrieves basic UNIT details for display on transcript
FUNCTION assp_get_trn_sua_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_sua_dtl
-- This module retrieves student UNIT attempt details for use in the
-- Correspondence Letter Facility for such correspondece as the
-- Academic Transcript.
--
-- The elements retrieved by this module are:
--     Teaching Period Alternate Code,
--     UNIT Code,
--     UNIT TITLE,
--     Credit Points Achievable,
--     Credit POints Achieved,
--     UNIT Level,
--     Mark,
--     Grade,
--     Grading Schema Code,
--     Grading Schema Version Number.
DECLARE
cst_trn_sua_ln              CONSTANT      VARCHAR2(15) := 'TRN_UNIT';
cst_trn_sua_cd              CONSTANT      VARCHAR2(15) := 'TRN_SUA_CD';
cst_trn_sua_tl              CONSTANT      VARCHAR2(15) := 'TRN_SUA_TL';
cst_trn_sua_pd              CONSTANT      VARCHAR2(15) := 'TRN_SUA_PD';
cst_trn_sua_ul              CONSTANT      VARCHAR2(15) := 'TRN_SUA_UL';
cst_trn_sua_mk              CONSTANT      VARCHAR2(15) := 'TRN_SUA_MK';
cst_trn_sua_gd              CONSTANT      VARCHAR2(15) := 'TRN_SUA_GD';
cst_trn_sua_gs              CONSTANT      VARCHAR2(15) := 'TRN_SUA_GS';
cst_trn_ach_cp              CONSTANT      VARCHAR2(15) := 'TRN_ACH_CP';
cst_trn_enr_cp              CONSTANT      VARCHAR2(15) := 'TRN_ENR_CP';
cst_trn_sua_cp              CONSTANT      VARCHAR2(15) := 'TRN_SUA_CP';
cst_trn_sua_gv              CONSTANT      VARCHAR2(15) := 'TRN_SUA_GV';
v_index                                   BINARY_INTEGER;
v_outcome_dt                       DATE;
v_grading_schema_cd                IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
v_gs_version_number                IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
v_grade                                   IGS_AS_GRD_SCH_GRADE.grade%TYPE;
v_mark                             IGS_AS_GRD_SCH_GRADE.lower_mark_range%TYPE;
v_origin_course_cd                 IGS_PS_VER.course_cd%TYPE;
v_s_result_type                           VARCHAR2(20);
v_out_string                       VARCHAR2(200);

--Who             When             What
--jbegum          25-Jun-2003      BUG#2930935 - Modified cursor c_sua.

CURSOR c_sua IS
SELECT   suav.person_id,
         igs_ca_gen_001.calp_get_alt_cd
                                 (suav.cal_type,
                                  suav.ci_sequence_number
                                 ) teach_alternate_code,
         suav.unit_cd, NVL (suav.alternative_title, uv.title) v_unit_title,
         NVL (suav.alternative_title, uv.short_title) v_unit_short_title,
         uv.unit_level, suav.cal_type, suav.ci_sequence_number, suav.uoo_id,
         suav.ci_start_dt,
         NVL (suav.override_achievable_cp,
              NVL (cps.achievable_credit_points, uv.achievable_credit_points)
             ) v_cp_achieved,
         NVL (suav.override_enrolled_cp,
              NVL (cps.enrolled_credit_points, uv.enrolled_credit_points)
             ) v_cp_achievable,
         suav.unit_attempt_status, suav.administrative_unit_status
    FROM igs_en_su_attempt_all suav,
         igs_ps_usec_cps cps,
         igs_ps_unit_ver uv,
         igs_en_stdnt_ps_att sca
   WHERE suav.person_id = p_person_id
     AND suav.course_cd = p_course_cd
     AND sca.person_id = suav.person_id
     AND sca.course_cd = suav.course_cd
     AND uv.unit_cd = suav.unit_cd
     AND uv.version_number = suav.version_number
     AND suav.uoo_id = cps.uoo_id(+)
     AND suav.unit_attempt_status NOT IN ('UNCONFIRM', 'DUPLICATE')
     AND igs_as_gen_001.assp_val_sua_display (suav.person_id,
                                              suav.course_cd,
                                              sca.version_number,
                                              suav.unit_cd,
                                              suav.cal_type,
                                              suav.ci_sequence_number,
                                              suav.unit_attempt_status,
                                              suav.administrative_unit_status,
                                              'Y',
                                              p_include_fail_grade_ind,
                                              p_enrolled_units_ind,
                                              p_exclude_research_units_ind,
                                              p_exclude_unit_category,
                                              suav.uoo_id
                                             ) = 'Y'
     AND igs_en_gen_014.enrs_get_within_ci (p_acad_cal_type,
                                            p_acad_ci_sequence_number,
                                            suav.cal_type,
                                            suav.ci_sequence_number,
                                            'Y'
                                           ) = 'Y'
ORDER BY suav.ci_start_dt, suav.unit_cd;

---------------------------------------- Local Function ------------------------
FUNCTION asspl_val_dsp_unit(
p_person_id          IGS_EN_SU_ATTEMPT.person_id%TYPE,
p_course_cd          IGS_EN_SU_ATTEMPT.course_cd%TYPE,
p_unit_cd            IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
p_cal_type           IGS_CA_INST.CAL_TYPE%TYPE,
p_sequence_number    IGS_CA_INST.sequence_number%TYPE,
-- anilk, 22-Apr-2003, Bug# 2829262
p_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE )
RETURN BOOLEAN IS

BEGIN
DECLARE
v_dummy              VARCHAR2(1);
CURSOR c_cv IS
SELECT 'x'
FROM   IGS_EN_STDNT_PS_ATT  sca,
IGS_PS_VER           cv
WHERE  sca.person_id        = p_person_id AND
sca.course_cd        = p_course_cd AND
cv.course_cd         = sca.course_cd AND
cv.version_number    = sca.version_number AND
cv.generic_course_ind       = 'N';
CURSOR c_sut IS
SELECT 'x'
FROM   IGS_PS_STDNT_UNT_TRN sut
WHERE  sut.person_id        = p_person_id AND
sut.transfer_course_cd      = p_course_cd AND
-- anilk, 22-Apr-2003, Bug# 2829262
sut.uoo_id    = p_uoo_id;
BEGIN
OPEN c_cv;
FETCH c_cv INTO v_dummy;
IF c_cv%FOUND THEN
CLOSE c_cv;
RETURN TRUE;
END IF;
CLOSE c_cv;
-- If the COURSE is a generic COURSE, determine if the UNIT has
-- been transfered to another COURSE for the academic period.
-- If so, the we do not want to display it.
OPEN c_sut;
FETCH c_sut INTO v_dummy;
IF c_sut%FOUND THEN
-- The UNIT exists in the generic COURSE and has been
-- transfered to another COURSE.  This uni is not to
-- be displayed.
CLOSE c_sut;
RETURN FALSE;
END IF;
-- The UNIT within the generic COURSE has not been transfered,
-- display this UNIT.
CLOSE c_sut;
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
IF c_cv%ISOPEN THEN
CLOSE c_cv;
END IF;
IF c_sut%ISOPEN THEN
CLOSE c_sut;
END IF;
RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.asspl_val_dsp_unit');
       --IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END asspl_val_dsp_unit;
-------------------------------------------- Main Program ----------------------
BEGIN
IF p_record_number = 1 THEN
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index := 0;
FOR v_sua_rec IN c_sua LOOP
IF asspl_val_dsp_unit(
v_sua_rec.person_id,
p_course_cd,
v_sua_rec.unit_cd,
v_sua_rec.CAL_TYPE,
v_sua_rec.ci_sequence_number,
-- anilk, 22-Apr-2003, Bug# 2829262
v_sua_rec.uoo_id ) THEN
v_s_result_type := IGS_AS_GEN_003.ASSP_GET_SUA_OUTCOME(
v_sua_rec.person_id,
p_course_cd,
v_sua_rec.unit_cd,
v_sua_rec.CAL_TYPE,
v_sua_rec.ci_sequence_number,
v_sua_rec.unit_attempt_status,
'Y',
v_outcome_dt,  -- output
v_grading_schema_cd, -- output
v_gs_version_number, -- output
v_grade, -- output
v_mark, -- output
v_origin_course_cd,
-- anilk, 22-Apr-2003, Bug# 2829262
v_sua_rec.uoo_id,
---added by LKAKI---
'N');
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index := c_sua%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_teach_alternate_code :=
v_sua_rec.teach_alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_unit_cd := v_sua_rec.unit_cd;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_title := v_sua_rec.v_unit_title;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_short_title :=
v_sua_rec.v_unit_short_title;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_unit_level :=
v_sua_rec.UNIT_LEVEL;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_cp_achievable :=
v_sua_rec.v_cp_achievable;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_cp_achieved :=
v_sua_rec.v_cp_achieved;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_mark := v_mark;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_grade := v_grade;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_grading_schema_cd :=
v_grading_schema_cd;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_gs_version_number :=
v_gs_version_number;
IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index).v_s_result := v_s_result_type;
END IF;
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_parameter_type and the
-- p_record_number.
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_sua_dtl_index THEN
IF p_s_letter_parameter_type = cst_trn_sua_ln THEN
v_out_string := RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_teach_alternate_code,'-'),10)
|| fnd_global.local_chr(09) ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_unit_cd,'-'),10)
|| fnd_global.local_chr(09) ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_title,'-'),40);
ELSIF p_s_letter_parameter_type = cst_trn_sua_cd THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_unit_cd,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sua_tl THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_short_title,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sua_pd THEN
IF p_record_number = 1 THEN
v_out_string := fnd_global.local_chr(10) || NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_teach_alternate_code,'-');
ELSE
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_teach_alternate_code,'-');
END IF;
ELSIF p_s_letter_parameter_type = cst_trn_sua_ul THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_unit_level,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sua_mk THEN
v_out_string := NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_mark,990),'-');
ELSIF p_s_letter_parameter_type = cst_trn_sua_gd THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_grade,'-');
ELSIF p_s_letter_parameter_type = cst_trn_sua_gs THEN
v_out_string := NVL(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_grading_schema_cd,'-');
ELSIF p_s_letter_parameter_type = cst_trn_ach_cp THEN
v_out_string := RPAD(NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_cp_achieved,'990D99'),'-'),7);
ELSIF p_s_letter_parameter_type = cst_trn_enr_cp THEN
v_out_string := RPAD(NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_cp_achievable,'990D99'),'-'),7);
ELSIF p_s_letter_parameter_type = cst_trn_sua_cp THEN
IF IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(v_index).v_s_result <> 'PASS' THEN
v_out_string := NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_cp_achievable,'990D99'),'-');
ELSE
v_out_string := NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_cp_achieved,'990D99'),'-');
END IF;
ELSIF p_s_letter_parameter_type = cst_trn_sua_gv THEN
v_out_string := NVL(TO_CHAR(IGS_AS_PRC_TRANSCRPT.gt_sua_dtl_table(
v_index).v_gs_version_number),'-');
ELSE
v_out_string := NULL;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_sua%ISOPEN THEN
CLOSE c_sua;
END IF;
RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_sua_dtl');
       --IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_sua_dtl;
--
-- Retrieves adv standing UNIT level details for display on transcript
FUNCTION assp_get_trn_asl_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_asl_dtl
-- This module retrieves student advanced standing UNIT levels for use in the
-- Correspondence Letter Facility for such correspondence as the Academic
-- Transcript.
-- The elements retrieved by this module are:
--     UNIT Level,
--     Credit Points Granted,
--     Description
DECLARE
v_index                                   BINARY_INTEGER;
v_out_string                       VARCHAR2(500);
v_dummy                                   VARCHAR2(1);
v_current_yr                VARCHAR2(10);
cst_trn_asl_ln              CONSTANT      VARCHAR2(20) := 'TRN_ASL_LN';
cst_trn_asl_ul              CONSTANT      VARCHAR2(20) := 'TRN_ASL_UL';
cst_trn_asl_cp              CONSTANT      VARCHAR2(20) := 'TRN_ASL_CP';
cst_trn_asl_ds              CONSTANT      VARCHAR2(20) := 'TRN_ASL_DS';
CURSOR c_asule IS
SELECT asule.person_id,
asule.UNIT_LEVEL,
asule.credit_points
FROM   IGS_AV_STND_UNIT_LVL asule
WHERE  asule.person_id                           = p_person_id AND
asule.as_course_cd                 = p_course_cd AND
asule.s_adv_stnd_granting_status   = 'GRANTED'
ORDER BY
asule.UNIT_LEVEL;
CURSOR c_current_yr IS
SELECT SUBSTR(IGS_GE_DATE.IGSCHAR(start_dt),1,4)
FROM   IGS_CA_INST
WHERE  CAL_TYPE      = p_acad_cal_type AND
sequence_number      = p_acad_ci_sequence_number;
CURSOR c_check_yr (cp_year  IGS_CA_INST.ALTERNATE_CODE%TYPE) IS
SELECT 'x'
FROM   dual
WHERE  cp_year <= IGS_AS_GEN_005.ASSP_VAL_SCA_COMM (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind);
BEGIN
-- Determine if advanced standing has already been displayed in an earlier
-- academic period for the COURSE.  (Unlike UNIT attempt details, advanced
-- standing is only shown under the first occurrence of a COURSE regardless
-- of when it was actually granted).
OPEN c_current_yr;
FETCH c_current_yr INTO v_current_yr;
IF c_current_yr%NOTFOUND THEN
CLOSE c_current_yr;
RETURN NULL;
END IF;
CLOSE c_current_yr;
OPEN c_check_yr (v_current_yr);
FETCH c_check_yr INTO v_dummy;
IF c_check_yr%NOTFOUND THEN
CLOSE c_check_yr;
RETURN NULL;
END IF;
CLOSE c_check_yr;
-- Determine if this is the first time the procedure has been called for
-- the PERSON (p_record_number = 1). If so, then populate the PL/SQL table
-- that will be used to retrieve the rest of the records returned from the
-- query.
IF p_record_number = 1 THEN
-- Initialise the counter for the PL/SQL table.
IGS_AS_PRC_TRANSCRPT.gv_asule_dtl_index := 0;
FOR v_asule_rec IN c_asule LOOP
-- Store the UNIT in the PL/SQL table.
-- Increment the counter.
IGS_AS_PRC_TRANSCRPT.gv_asule_dtl_index := c_asule%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asule_dtl_index).v_unit_level
:= v_asule_rec.UNIT_LEVEL;
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asule_dtl_index).v_cp_granted
:= v_asule_rec.credit_points;
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asule_dtl_index).v_description
:= 'UNSPECIFIED CREDIT';
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_paramater_type and the
-- p_record_number.
v_index       := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_asule_dtl_index THEN
IF p_s_letter_parameter_type = cst_trn_asl_ln THEN
v_out_string := RPAD(NVL(
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(v_index).v_description,
'-'),50) || fnd_global.local_chr(09) ||
RPAD(NVL(TO_CHAR(
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(v_index).v_cp_granted
,'990D99'),'-'),7) || fnd_global.local_chr(09) ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(v_index).v_unit_level,
'-'),1);
ELSIF p_s_letter_parameter_type = cst_trn_asl_ds THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(v_index).v_description,'-');
ELSIF p_s_letter_parameter_type = cst_trn_asl_ul THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(v_index).v_unit_level,'-');
ELSIF p_s_letter_parameter_type = cst_trn_asl_cp THEN
v_out_string := NVL(TO_CHAR(
IGS_AS_PRC_TRANSCRPT.gt_asule_dtl_table(v_index).v_cp_granted
,'990D99'),'-');
ELSE
v_out_string := NULL;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_asule%ISOPEN THEN
CLOSE c_asule;
END IF;
IF c_current_yr%ISOPEN THEN
CLOSE c_current_yr;
END IF;
IF c_check_yr%ISOPEN THEN
CLOSE c_check_yr;
END IF;
RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_asl_dtl');
       IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_asl_dtl;
--
-- Retrieves advanced standing UNIT details for display on transcript
FUNCTION assp_get_trn_asu_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_asu_dtl
-- This module retrieves student advanced standing UNIT details for use in the
-- Correspondence Letter Facility for such correspondence as the Academic
-- Transcript.
-- The elements retrieved by this module are:
--     UNIT Code,
--     UNIT TITLE,
--     Credit Points Achievable,
--     UNIT Level
DECLARE
v_index                            BINARY_INTEGER;
v_out_string                VARCHAR2(500);
v_dummy                            VARCHAR2(1);
l_advgrant                      BOOLEAN;  --added as part of academic records maitenance DLD
l_credits                       NUMBER; --added as part of academic records maitenance DLD
l_s_adv_atnd_granting_status    igs_av_stnd_unit_all.s_adv_stnd_granting_status%TYPE; --added as part of academic records maitenance DLD
l_message                       VARCHAR2(2000); --added as part of academic records maitenance DLD
v_current_yr                VARCHAR2(10);
cst_trn_asu_ln       CONSTANT      VARCHAR2(20) := 'TRN_ASU';
cst_trn_asu_cd       CONSTANT      VARCHAR2(20) := 'TRN_ASU_CD';
cst_trn_asu_tl       CONSTANT      VARCHAR2(20) := 'TRN_ASU_TL';
cst_trn_asu_ul       CONSTANT      VARCHAR2(20) := 'TRN_ASU_UL';
cst_trn_asu_cp       CONSTANT      VARCHAR2(20) := 'TRN_ASU_CP';

CURSOR c_asu IS
SELECT asu.person_id,as_course_cd,as_version_number,
asu.unit_cd,asu.version_number,
uv.short_title,
uv.TITLE,
uv.UNIT_LEVEL
FROM   IGS_AV_STND_UNIT     asu,
IGS_PS_UNIT_VER      uv
WHERE  asu.person_id               = p_person_id AND
asu.as_course_cd            = p_course_cd AND
asu.s_adv_stnd_granting_status     = 'GRANTED' AND
asu.s_adv_stnd_recognition_type    = 'CREDIT' AND
(igs_av_val_asu.granted_adv_standing(person_id,as_course_cd,as_version_number,
 asu.unit_cd,asu.version_number,'GRANTED',NULL) ='TRUE') AND
asu.unit_cd                 = uv.unit_cd AND
asu.version_number          = uv.version_number
GROUP BY person_id,as_course_cd,as_version_number,asu.unit_cd,asu.version_number,uv.short_title,
uv.title,uv.unit_level
ORDER BY
asu.unit_cd,
asu.version_number;
CURSOR c_current_yr IS
SELECT SUBSTR(IGS_GE_DATE.IGSCHAR(start_dt),1,4)
FROM   IGS_CA_INST
WHERE  CAL_TYPE      = p_acad_cal_type AND
sequence_number      = p_acad_ci_sequence_number;
CURSOR c_check_yr (cp_year  IGS_CA_INST.ALTERNATE_CODE%TYPE) IS
SELECT 'x'
FROM   dual
WHERE  cp_year <= IGS_AS_GEN_005.ASSP_VAL_SCA_COMM (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind);
BEGIN
-- Determine if advanced standing has already been displayed in an earlier
-- academic
-- period for the COURSE.  (Unlike UNIT attempt details, advanced standing is
-- only shown under the first occurrence of a COURSE regardless of when it
-- was actually granted).
OPEN c_current_yr;
FETCH c_current_yr INTO v_current_yr;
IF c_current_yr%NOTFOUND THEN
CLOSE c_current_yr;
RETURN NULL;
END IF;
CLOSE c_current_yr;
OPEN c_check_yr (v_current_yr);
FETCH c_check_yr INTO v_dummy;
IF c_check_yr%NOTFOUND THEN
CLOSE c_check_yr;
RETURN NULL;
END IF;
CLOSE c_check_yr;
-- Determine if this is the first time the procedure has been called for
-- the PERSON (p_record_number = 1). If so, then populate the PL/SQL table
-- that will be used to retrieve the rest of the records returned from the
-- query.
IF p_record_number = 1 THEN
-- Initialise the counter for the PL/SQL table.
IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index := 0;
FOR v_asu_rec IN c_asu LOOP
-- Store the UNIT in the PL/SQL table.
-- Increment the counter.

 l_advgrant := igs_av_val_asu.adv_Credit_pts(p_person_id,p_course_cd,v_Asu_rec.as_version_number,
                                          v_asu_rec.unit_cd,v_asu_rec.version_number,
                                         'GRANTED',NULL,l_credits,l_s_adv_atnd_granting_status,l_message);-- academic records maint. DLD
IF NOT l_advgrant THEN
  l_credits := 0;
END IF;

IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index := c_asu%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index).v_unit_cd
:= v_asu_rec.unit_cd;
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index).v_short_title
:= v_asu_rec.short_title;
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index).v_title
:= v_asu_rec.TITLE;
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index).v_cp_achievable
:= l_credits; -- academic records maintenance DLD
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index).v_unit_level
:= v_asu_rec.UNIT_LEVEL;
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_paramater_type and the
-- p_record_number.
v_index       := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_asu_dtl_index THEN
IF p_s_letter_parameter_type = cst_trn_asu_ln THEN
v_out_string := RPAD(NVL(
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_unit_cd,
'-'),10) || fnd_global.local_chr(09) ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_title,
'-'),40) || fnd_global.local_chr(09) ||
RPAD(NVL(TO_CHAR(
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_cp_achievable
,'990D99'),'-'),7) || fnd_global.local_chr(09) ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_unit_level,
'-'),1);
ELSIF p_s_letter_parameter_type = cst_trn_asu_cd THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_unit_cd,'-');
ELSIF p_s_letter_parameter_type = cst_trn_asu_tl THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_short_title,'-');
ELSIF p_s_letter_parameter_type = cst_trn_asu_ul THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_unit_level,'-');
ELSIF p_s_letter_parameter_type = cst_trn_asu_cp THEN
v_out_string := NVL(TO_CHAR(
IGS_AS_PRC_TRANSCRPT.gt_asu_dtl_table(v_index).v_cp_achievable
,'990D99'),'-');
ELSE
v_out_string := NULL;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_asu%ISOPEN THEN
CLOSE c_asu;
END IF;
IF c_current_yr%ISOPEN THEN
CLOSE c_current_yr;
END IF;
IF c_check_yr%ISOPEN THEN
CLOSE c_check_yr;
END IF;
RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_asu_dtl');
       IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_asu_dtl;
--
-- Retrieves basic advanced standing details for display on transcript
FUNCTION assp_get_trn_adv_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_acad_cal_type IN VARCHAR2 ,
p_acad_ci_sequence_number IN NUMBER ,
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_adv_dtl
-- This function determines if the PERSON has been granted any advanced
-- standing  for the nominated COURSE code in the nominated academic period.
-- It returns a descriptive string for use in the Correspondence Letter
-- Facility for such correspondence as the Academic Transcript.
--
-- NOTE : This function will be extended in the future to include the basis on
-- which the advanced standing has been granted.  This is not possible
-- until the application component of advanced standing is built.
--
-- CHANGE : As part of academic records maintenance DLD the existing credit percentage
-- logic in the c_adv cursor is modified to look into igs_av_val_Asu.granted_Adv_standing
DECLARE
v_out_string                VARCHAR2(255);
v_index                            BINARY_INTEGER;
v_dummy                            VARCHAR2(1);
v_current_yr                VARCHAR2(10);
cst_trn_adv_ln       CONSTANT      VARCHAR2(20) := 'TRN_ADV';
CURSOR c_adv IS
SELECT adv.total_exmptn_granted
FROM   IGS_AV_ADV_STANDING         adv
WHERE  adv.person_id               = p_person_id AND
adv.course_cd               = p_course_cd AND
adv.total_exmptn_granted    > 0 AND
(EXISTS (SELECT      'x'
FROM   IGS_AV_STND_UNIT                   asu
WHERE  asu.person_id               = adv.person_id AND
asu.as_course_cd            = adv.course_cd AND
asu.s_adv_stnd_granting_status     = 'GRANTED' AND
asu.s_adv_stnd_recognition_type    = 'CREDIT' AND
(igs_av_val_asu.granted_adv_standing(person_id,as_course_cd,as_version_number,
 unit_cd,version_number,'GRANTED',NULL) ='TRUE')) OR
EXISTS (SELECT       'x'
FROM   IGS_AV_STND_UNIT_LVL asule
WHERE  asule.person_id             = adv.person_id AND
asule.as_course_cd   = adv.course_cd AND
asule.s_adv_stnd_granting_status = 'GRANTED'));
CURSOR c_current_yr IS
SELECT SUBSTR(IGS_GE_DATE.IGSCHAR(start_dt),1,4)
FROM   IGS_CA_INST
WHERE  CAL_TYPE      = p_acad_cal_type AND
sequence_number      = p_acad_ci_sequence_number;
CURSOR c_check_yr (cp_year  IGS_CA_INST.ALTERNATE_CODE%TYPE) IS
SELECT 'x'
FROM   dual
WHERE  cp_year <= IGS_AS_GEN_005.ASSP_VAL_SCA_COMM (
p_person_id,
p_course_cd,
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
p_include_related_crs_ind);
BEGIN
-- Validate parameters
IF p_person_id IS NULL OR
p_course_cd IS NULL OR
p_acad_cal_type IS NULL OR
p_acad_ci_sequence_number IS NULL OR
p_s_letter_parameter_type IS NULL OR
p_record_number IS NULL THEN
RETURN NULL;
END IF;
-- Determine if advanced standing has already been displayed in an earlier
-- academic period for the COURSE.  (Unlike UNIT details, advanced standing
-- is only shown under the first occurrence of a COURSE regardless of when
-- it was actually granted).
OPEN c_current_yr;
FETCH c_current_yr INTO v_current_yr;
IF c_current_yr%NOTFOUND THEN
CLOSE c_current_yr;
RETURN NULL;
END IF;
CLOSE c_current_yr;
OPEN c_check_yr (v_current_yr);
FETCH c_check_yr INTO v_dummy;
IF c_check_yr%NOTFOUND THEN
CLOSE c_check_yr;
RETURN NULL;
END IF;
CLOSE c_check_yr;
-- Determine if this is the first time the procedure has been called for
-- the PERSON (p_record_number = 1). If so, then populate the PL/SQL table
-- that will be used to retrieve the rest of the records returned from the
-- query.
IF p_record_number = 1 THEN
-- Initialise the counter for the PL/SQL table.
IGS_AS_PRC_TRANSCRPT.gv_adv_dtl_index := 0;
FOR v_adv_rec IN c_adv LOOP
IGS_AS_PRC_TRANSCRPT.gv_adv_dtl_index :=  c_adv%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_adv_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_adv_dtl_index).v_title :=
'ADVANCED STANDING GRANTED :';
END LOOP;
END IF;
-- Create the output string based on the p_s_letter_parameter_type
-- and the p_record_number.
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_adv_dtl_index THEN
IF p_s_letter_parameter_type = cst_trn_adv_ln THEN
IF p_record_number = 1 THEN
v_out_string := fnd_global.local_chr(10) || RPAD(NVL(
IGS_AS_PRC_TRANSCRPT.gt_adv_dtl_table(v_index).v_title,'-'),50) || fnd_global.local_chr(10);
ELSE
v_out_string := RPAD(NVL(
IGS_AS_PRC_TRANSCRPT.gt_adv_dtl_table(v_index).v_title,'-'),50) || fnd_global.local_chr(10);
END IF;
END IF;
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_adv%ISOPEN THEN
CLOSE c_adv;
END IF;
IF c_current_yr%ISOPEN THEN
CLOSE c_current_yr;
END IF;
IF c_check_yr%ISOPEN THEN
CLOSE c_check_yr;
END IF;
RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_adv_dtl');
       IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_adv_dtl;
--
-- Retrieves basic COURSE details for display on transcript
FUNCTION assp_get_trn_sca_dtl(
p_person_id IN NUMBER ,
p_course_cd IN VARCHAR2 ,
p_s_letter_parameter_type IN VARCHAR2 ,
p_order_by IN VARCHAR2 DEFAULT 'YEAR',
p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
p_exclude_unit_category IN VARCHAR2 ,
p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
p_record_number IN NUMBER ,
p_extra_context OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS

BEGIN  -- assp_get_trn_sca_dtl
-- This module retrieves COURSE details for use in the Correspondence Letter
-- Facility for such correspondence as the Academic Transcript.
-- The elements retrieved by this module are:
--     Academic Year,
--     COURSE Code,
--     COURSE TITLE,
--     COURSE Commencement Date,
--     COURSE Attendance Type,
--     COURSE IGS_AD_LOCATION
--     COURSE Stage.
DECLARE
v_index                            BINARY_INTEGER;
v_out_string                VARCHAR2(500);
v_orderby                   VARCHAR2(10);
cst_trn_course       CONSTANT      VARCHAR2(20) := 'TRN_COURSE';
cst_trn_crs_cd       CONSTANT      VARCHAR2(20) := 'TRN_CRS_CD';
cst_trn_crs_dt       CONSTANT      VARCHAR2(20) := 'TRN_CRS_DT';
cst_trn_crs_at       CONSTANT      VARCHAR2(20) := 'TRN_CRS_AT';
cst_trn_crs_lc       CONSTANT      VARCHAR2(20) := 'TRN_CRS_LC';
cst_trn_crs_t CONSTANT      VARCHAR2(20) := 'TRN_CRS_T';
CURSOR c_sca IS
SELECT sca.person_id,
suav.acad_alternate_code,
sca.course_cd,
cv.TITLE,
ci.CAL_TYPE,
ci.sequence_number,
ci.start_dt,
cop.attendance_type,
cop.location_cd,
sca.commencement_dt,
cv.generic_course_ind,
-- anilk, 22-Apr-2003, Bug# 2829262
suav.uoo_id
FROM   IGS_EN_STDNT_PS_ATT  sca,
IGS_EN_SUA_V  suav,
IGS_PS_VER           cv,
IGS_PS_OFR_PAT       cop,
IGS_CA_INST                 ci
WHERE  sca.person_id               = p_person_id AND
sca.person_id               = suav.person_id AND
sca.course_cd               = suav.course_cd AND
(sca.course_cd              = NVL(p_course_cd, suav.course_cd) OR
(p_course_cd IS NULL OR
(p_course_cd IS NOT NULL AND
p_include_related_crs_ind = 'N' AND
sca.course_cd = p_course_cd) OR
(p_course_cd IS NOT NULL AND
p_include_related_crs_ind = 'Y' AND
sca.course_cd IN (SELECT    cgm.course_cd
FROM   IGS_PS_GRP_MBR cgm,
IGS_PS_GRP cg,
IGS_PS_GRP_TYPE cgt
WHERE  cgm.course_group_cd = cg.course_group_cd
AND    cg.course_group_type = cgt.course_group_type
AND    cgt.s_course_group_type = 'RELATED'
AND    p_course_cd IN (SELECT      cgm1.course_cd
FROM   IGS_PS_GRP_MBR cgm1,
IGS_PS_GRP cg1,
IGS_PS_GRP_TYPE cgt1
WHERE  cgm1.course_group_cd = cg1.course_group_cd
AND    cg1.course_group_type = cgt1.course_group_type
AND    cgt1.s_course_group_type = 'RELATED'))))) AND
EXISTS(       SELECT 'X'
FROM   IGS_EN_SU_ATTEMPT sua
WHERE  sua.person_id        = suav.person_id AND
sua.course_cd               = suav.course_cd AND
-- anilk, 22-Apr-2003, Bug# 2829262
sua.uoo_id    = suav.uoo_id AND
IGS_AS_GEN_001.ASSP_VAL_SUA_DISPLAY(
sua.person_id,
sua.course_cd,
sca.version_number,
sua.unit_cd,
sua.CAL_TYPE,
sua.ci_sequence_number,
sua.unit_attempt_status,
sua.administrative_unit_status,
'Y',
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
-- anilk, 22-Apr-2003, Bug# 2829262
sua.uoo_id ) = 'Y') AND
cv.course_cd         = sca.course_cd AND
cv.version_number    = sca.version_number AND
sca.coo_id           = cop.coo_id AND
sca.location_cd      = cop.location_cd AND
sca.attendance_mode  = cop.attendance_mode AND
sca.attendance_type  = cop.attendance_type AND
cop.CAL_TYPE         = ci.CAL_TYPE AND
cop.ci_sequence_number      = ci.sequence_number AND
IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
cop.CAL_TYPE,
cop.ci_sequence_number,
suav.CAL_TYPE,
suav.ci_sequence_number,
'Y')          = 'Y'
GROUP BY
sca.person_id,
suav.acad_alternate_code,
sca.course_cd,
cv.TITLE,
ci.CAL_TYPE,
ci.sequence_number,
ci.start_dt,
cop.attendance_type,
cop.location_cd,
sca.commencement_dt,
cv.generic_course_ind
ORDER BY
sca.course_cd,
ci.start_dt;
CURSOR c_sca2 IS
SELECT sca.person_id,
suav.acad_alternate_code,
sca.course_cd,
cv.TITLE,
ci.CAL_TYPE,
ci.sequence_number,
ci.start_dt,
cop.attendance_type,
cop.location_cd,
sca.commencement_dt,
cv.generic_course_ind,
-- anilk, 22-Apr-2003, Bug# 2829262
suav.uoo_id
FROM   IGS_EN_STDNT_PS_ATT  sca,
IGS_EN_SUA_V  suav,
IGS_PS_VER           cv,
IGS_PS_OFR_PAT       cop,
IGS_CA_INST                 ci
WHERE  sca.person_id               = p_person_id AND
sca.person_id               = suav.person_id AND
--     sca.course_cd               = NVL(p_course_cd, suav.course_cd) AND
sca.course_cd               = suav.course_cd AND
(sca.course_cd              = NVL(p_course_cd, suav.course_cd) OR
(p_course_cd IS NULL OR
(p_course_cd IS NOT NULL AND
p_include_related_crs_ind = 'N' AND
sca.course_cd = p_course_cd) OR
(p_course_cd IS NOT NULL AND
p_include_related_crs_ind = 'Y' AND
sca.course_cd IN (SELECT    cgm.course_cd
FROM   IGS_PS_GRP_MBR cgm,
IGS_PS_GRP cg,
IGS_PS_GRP_TYPE cgt
WHERE  cgm.course_group_cd = cg.course_group_cd
AND    cg.course_group_type = cgt.course_group_type
AND    cgt.s_course_group_type = 'RELATED'
AND    p_course_cd IN (SELECT      cgm1.course_cd
FROM   IGS_PS_GRP_MBR cgm1,
IGS_PS_GRP cg1,
IGS_PS_GRP_TYPE cgt1
WHERE  cgm1.course_group_cd = cg1.course_group_cd
AND    cg1.course_group_type = cgt1.course_group_type
AND    cgt1.s_course_group_type = 'RELATED'))))) AND
EXISTS(       SELECT 'X'
FROM   IGS_EN_SU_ATTEMPT sua
WHERE  sua.person_id        = suav.person_id AND
sua.course_cd               = suav.course_cd AND
-- anilk, 22-Apr-2003, Bug# 2829262
sua.uoo_id    = suav.uoo_id AND
IGS_AS_GEN_001.ASSP_VAL_SUA_DISPLAY(
sua.person_id,
sua.course_cd,
sca.version_number,
sua.unit_cd,
sua.CAL_TYPE,
sua.ci_sequence_number,
sua.unit_attempt_status,
sua.administrative_unit_status,
'Y', -- finalised indicator
p_include_fail_grade_ind,
p_enrolled_units_ind,
p_exclude_research_units_ind,
p_exclude_unit_category,
-- anilk, 22-Apr-2003, Bug# 2829262
sua.uoo_id ) = 'Y') AND
cv.course_cd         = sca.course_cd AND
cv.version_number    = sca.version_number AND
sca.coo_id           = cop.coo_id AND
sca.location_cd      = cop.location_cd AND
sca.attendance_mode  = cop.attendance_mode AND
sca.attendance_type  = cop.attendance_type AND
cop.CAL_TYPE         = ci.CAL_TYPE AND
cop.ci_sequence_number      = ci.sequence_number AND
IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
cop.CAL_TYPE,
cop.ci_sequence_number,
suav.CAL_TYPE,
suav.ci_sequence_number,
'Y')          = 'Y'
GROUP BY
sca.person_id,
suav.acad_alternate_code,
sca.course_cd,
cv.TITLE,
ci.CAL_TYPE,
ci.sequence_number,
ci.start_dt,
cop.attendance_type,
cop.location_cd,
sca.commencement_dt,
cv.generic_course_ind
ORDER BY
ci.start_dt,
sca.course_cd;
---------------------------------------asspl_val_dsp_g_crs----------------------
FUNCTION asspl_val_dsp_g_crs(
p_person_id                 IGS_EN_SU_ATTEMPT.person_id%TYPE,
p_course_cd                 IGS_EN_SU_ATTEMPT.course_cd%TYPE,
p_generic_course_ind        IGS_PS_VER.generic_course_ind%TYPE,
p_acad_cal_type                    IGS_EN_SU_ATTEMPT.CAL_TYPE%TYPE,
p_acad_ci_sequence_number   IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE)
RETURN BOOLEAN IS

BEGIN  -- asspl_val_dsp_g_crs
-- local function to determine if a generic COURSE is displayed.
DECLARE
v_dummy                     VARCHAR2(1);
CURSOR c_sua IS
SELECT 'x'
FROM   IGS_EN_SU_ATTEMPT    sua
WHERE  sua.person_id        = p_person_id AND
sua.course_cd        = p_course_cd AND
(sua.unit_attempt_status IN (      'ENROLLED',
'COMPLETED',
'DUPLICATE') OR
(sua.unit_attempt_status = 'DISCONTIN' AND
IGS_AS_GEN_003.ASSP_GET_TRN_SUA_OUT(
p_person_id,
p_course_cd,
sua.unit_cd,
sua.CAL_TYPE,
sua.ci_sequence_number,
sua.unit_attempt_status,
'Y',
-- anilk, 22-Apr-2003, Bug# 2829262
sua.uoo_id)           = 'FAIL')) AND
IGS_EN_GEN_014.ENRS_GET_WITHIN_CI (
p_acad_cal_type,
p_acad_ci_sequence_number,
sua.CAL_TYPE,
sua.ci_sequence_number,
'Y')   = 'Y' AND
NOT EXISTS (  SELECT 'x'
FROM   IGS_PS_STDNT_UNT_TRN sut
WHERE  sut.person_id        = sua.person_id AND
sut.transfer_course_cd      = sua.course_cd AND
-- anilk, 22-Apr-2003, Bug# 2829262
sut.uoo_id    = sua.uoo_id);
BEGIN
IF p_generic_course_ind = 'N' THEN
RETURN TRUE;
END IF;
-- If the COURSE is a generic COURSE, determine if the COURSE contains
-- any units that have not been transferred to another COURSE for the
-- academic period.
OPEN c_sua;
FETCH c_sua INTO v_dummy;
IF c_sua%NOTFOUND THEN
CLOSE c_sua;
RETURN FALSE;
END IF;
CLOSE c_sua;
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
IF c_sua%ISOPEN THEN
CLOSE c_sua;
END IF;
RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.asspl_val_dsp_g_crs');
       IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END asspl_val_dsp_g_crs;
--------------------------------------------------------------------------------
---------------------------------------------Main Program----------------------
BEGIN
-- Determine if this is the first time the procedure has been called for
-- the PERSON (p_record_number = 1). If so, then populate the PL/SQL table
-- that will be used to retrieve the rest of the records returned from the
-- query.
IF p_record_number = 1 THEN
-- Initialise the counter for the PL/SQL table.
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index := 0;
-- Determine if the order by parameter is specified as to which
-- select statement to use.
IF p_order_by = 'COURSE' THEN
FOR v_sca_rec IN c_sca LOOP
-- Determine if the COURSE is a generic COURSE. If all the
-- units within this COURSE for the academic period have been
-- transferred to another COURSE, then do not show this COURSE.
IF asspl_val_dsp_g_crs(
v_sca_rec.person_id,
v_sca_rec.course_cd,
v_sca_rec.generic_course_ind,
v_sca_rec.CAL_TYPE,
v_sca_rec.sequence_number) THEN
-- Store the COURSE in the PL/SQL table.
-- Increment the counter.
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index := c_sca%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_alternate_code :=
v_sca_rec.acad_alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_course_cd :=
v_sca_rec.course_cd;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_title := v_sca_rec.TITLE;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_cal_type :=
v_sca_rec.CAL_TYPE;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_ci_sequence_number :=
v_sca_rec.sequence_number;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_start_dt :=
v_sca_rec.start_dt;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_attendance_type :=
v_sca_rec.attendance_type;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_location_cd :=
v_sca_rec.location_cd;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_commencement_dt :=
v_sca_rec.commencement_dt;
END IF;
END LOOP;
ELSE
--ELSIF p_order_by <> 'COURSE' THEN
-- order by academic period
FOR v_sca_rec IN c_sca2 LOOP
-- Determine if the COURSE is a generic COURSE. If all the
-- units within this COURSE for the academic period have been
-- transferred to another COURSE, then do not show this COURSE.
IF asspl_val_dsp_g_crs(
v_sca_rec.person_id,
v_sca_rec.course_cd,
v_sca_rec.generic_course_ind,
v_sca_rec.CAL_TYPE,
v_sca_rec.sequence_number) THEN
-- Store the COURSE in the PL/SQL table.
-- Increment the counter.
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index := c_sca2%ROWCOUNT;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_alternate_code :=
v_sca_rec.acad_alternate_code;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_course_cd :=
v_sca_rec.course_cd;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_title := v_sca_rec.TITLE;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_cal_type :=
v_sca_rec.CAL_TYPE;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_ci_sequence_number :=
v_sca_rec.sequence_number;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_acad_start_dt :=
v_sca_rec.start_dt;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_attendance_type :=
v_sca_rec.attendance_type;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_location_cd :=
v_sca_rec.location_cd;
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(
IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index).v_commencement_dt :=
v_sca_rec.commencement_dt;
END IF;
END LOOP;
END IF;
END IF;
-- Create the output string based on the p_s_letter_parameter_type
-- and the p_record_number.
v_index := p_record_number;
v_out_string := NULL;
IF v_index <= IGS_AS_PRC_TRANSCRPT.gv_sca_dtl_index THEN
IF p_s_letter_parameter_type = cst_trn_course THEN
v_out_string := fnd_global.local_chr(10) || RPAD(NVL(
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_acad_alternate_code,'-'),10)
|| ' ' ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_course_cd,'-'),10)
|| ' ' ||
RPAD(NVL(IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_title,'-'),90);
ELSIF p_s_letter_parameter_type = cst_trn_crs_cd THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_course_cd,'-');
ELSIF p_s_letter_parameter_type = cst_trn_crs_dt THEN
v_out_string := NVL(FND_DATE.DATE_TO_DISPLAYDATE(
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_commencement_dt
),'-');
ELSIF p_s_letter_parameter_type = cst_trn_crs_at THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_attendance_type,'-');
ELSIF p_s_letter_parameter_type = cst_trn_crs_lc THEN
v_out_string := NVL(
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_location_cd,'-');
ELSIF p_s_letter_parameter_type = cst_trn_crs_t THEN
v_out_string := INITCAP(NVL(
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_title,'-'));
ELSE
v_out_string := NULL;
END IF;
p_extra_context := IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_course_cd
|| '|' ||
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_acad_cal_type  || '|' ||
TO_CHAR(
IGS_AS_PRC_TRANSCRPT.gt_sca_dtl_table(v_index).v_acad_ci_sequence_number);
END IF;
RETURN v_out_string;
EXCEPTION
WHEN OTHERS THEN
IF c_sca%ISOPEN THEN
CLOSE c_sca;
END IF;
IF c_sca2%ISOPEN THEN
CLOSE c_sca2;
END IF;
RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.assp_get_trn_sca_dtl');
       IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
END assp_get_trn_sca_dtl;
END IGS_AS_PRC_TRANSCRPT;

/
