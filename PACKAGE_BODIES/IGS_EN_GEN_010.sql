--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_010" AS
/* $Header: IGSEN10B.pls 120.22 2006/09/15 06:26:36 amanohar ship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rvangala  12-AUG-2005    Bug #4551013. EN320 Build
  -- bdeviset    29-JUL-2004     Modified Enrp_Ins_Snew_Prenrl,Enrp_Ins_Sret_Prenrl,create_unit_set,
  --        create_stream_unit_sets,update_stream_unit_sets.
  --                            Changed procedures create_unit_set,create_stream_unit_sets,update_stream_unit_sets
  --                            enrpl_copy_adm_unit_sets to functions which returns booleanfor bug 3149133.
  --
  --ckasu       05-Apr-2004     Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row  and
  --                            IGS_EN_STDNT_PS_ATT_Pkg.Insert_Row Procedure call as a part of bug 3544927.
  --rvangala    04-Dec-2003     Added call to igs_ss_enr_details.enrp_get_prgm_for_career to check for
  --                            primary program in enrp_valid_inst_sua
  --ijeddy, Dec 3, 2003        Grade Book Enh build, bug no 3201661

  -- rvivekan  3-Aug-2003         Added new parameters to ofr_enrollment_or_waitlist    |
  --                      as a part of Bulk Unit Upload Bug#3049009
  -- rvivekan   29-JUL-2003     Modified several message_name variables from varchar2(30) to varchar2(2000) as
  --                            a part of bug#3045405
  -- amuthu     04-JUL-2003     Removed the check for progression status and added it before the
  --                            the call to enrp_ins_snew_prenrl and enrp_ins_sret_prenrl in IGS_EN_GEN_008
  -- amuthu     10-JUN-2003     modified as per the UK Streaming and Repeat TD (bug 2829265)
  -- amuthu     04-FEB-2003     removed the exception section from enrp_ins_suao_discon
  --                            as part of bug 2782096.
  -- pradhakr    19-Dec-2002    Changed the call to the insert_row of igs_en_su_attempt
  --                            table to igs_en_sua_api.create_unit_attempt.
  --                            Changes wrt ENCR031 build. Bug#2643207
  --amuthu     23-Sep-02     Modified the code as per the EN Core Vs Option TD. Added logic
  --                     to call Enrp_Ins_Pre_Pos when the p_units_ind(icator) parameter
  --                                     value is either 'Y' or 'CORE_ONLY'
  --ayedubat   04-JUN-2002     Changed the functions: enrp_ins_snew_prenrl, enrp_ins_sret_prenrl for bug # 2391842
  --nalkumar    5-OCT-2001  Modified the IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW and IGS_EN_STDNT_PS_ATT_PKG.INSERT_ROW calls.
  --        Added four new parameters to call it as per the Bug# 2027984.
  --Aiyer 10-Oct-2001     Added the columns grading schema and gs_version_number in all
  --        Tbh calls of IGS_EN_SU_ATTEMPT_PKG as a part of the bug 2037897.
  --Bayadav 09-Nov-2001     Added the columns catalog cal type and catalog seq num in Enrp_ins_susa_hist
  --        as a part of build of career impact DLD
  --Nalin Kumar 11-Nov-2001 Added  Procedure 'adv_stand_trans' as part of the Career Impact DLD.
  --        Bug# 2027984.
  --Nalin Kumar 16-Nov-2001 Added  parameter key_program in IGS_EN_STDNT_PS_ATT_PKG.update_row call
  --        as pert of the Career Impact DLD. Bug# 2027984.
  --pmarada 27-nov-2001 Modified the adv_stand_trans procedure as part of AVCR001 Advanced standing dld..
  --pradhakr  06-Dec-2001 Added the column deg_aud_detail_id as part of Degree Audit Interfacec build. (Bug# 2033208)
  --svenkata  20-Dec-2001 Added columns student_career_transcript and Student_career_statistics as part of build Career
  --        Impact Part2 . Bug #2158626
  --svenkata  7-JAN-2002  Bug No. 2172405  Standard Flex Field columns have been added
  --        to table handler procedure calls as part of CCR - ENCR022.
  --Nalin Kumar 28-Jan-2002 Added  Procedure 'enrp_ins_sca_ukstat_trnsfr' and modified function enrp_ins_susa_trnsfr
  --        procedure as pert of the HESA Intregation DLD (ENCR019). Bug# 2201753.
  --prraj 21-Feb-2002 Added column QUAL_DETS_ID to the tbh calls of pkg
  --        IGS_AV_STND_UNIT_LVL_PKG (Bug# 2233334)
  --Added refernces to column ORG_UNIT_CD in call to IGS_EN_SU_ATTEMPT TBH call as a part of bug 1964697
  --pmarada     24-Feb-2002     Added the copy-hesa_details Procedure, for the hesa requirment.
  --Nishikant   03-May-2002     The Local procedure enrpl_copy_adm_unit_sets got modified to make Unit Sets Confirmed if
  --                            Program attempt got confirmed - due to the Enhancement Bug#2347141
  --smadadli    14-may-2002     Modified procedures copy_hesa_details , enrp_ins_snew_prenrl , enrp_ins_sret_prenrl for bug#2350629
  --pmarada   23 -May-2002      Modified the c_us_version_number cursor, to fetch the next year from the program offerring option.
  --nalkumar    05-June-2002   Removed the referances of the igs_av_stnd_unit/unit_lvl_pkg.(PREV_UNIT_CD and TEST_DETAILS_ID) parameter.
  --                           Modified the call to the igs_av_stnd_unit_pkg and igs_av_stnd_unit_lvl_pkg as per the bug# 2401170.
  --smaddali 12-jun-2002 bug 2391799 modified procedure enrpl_copy_adm_unit_sets
  --Nishikant   07OCT2002      UK Enhancement Build - Enh Bug#2580731 - Added the parameter p_selection_date in the Function Enrp_Ins_Sret_Prenrl
  --kkillams    16-06-2003     Three new parameters are added to the Enrp_Ins_Snew_Prenrl and Enrp_Ins_Sret_Prenrl functions
  --                           ENRP_INS_PRE_POS, ENRPL_CREATE_POS_SUA,ENRPL_COPY_ADM_SUA and ENRPL_COPY_PARAM_SUA procedures are modified as per TD
  --                           w.r.t. bug no 2829270
  --ptandon     6-Oct-2003     Modified the Procedure Enrp_Ins_Sua_Hist, Function Enrp_Vald_Inst_Sua, Procedure enrpl_copy_adm_sua
  --                           and Procedure enrpl_copy_param_sua(Inline procedures of Enrp_Ins_Snew_Prenrl), Procedure enrpl_copy_param_sua
  --                           (Inline procedure of Enrp_Ins_Sret_Prenrl) as part of Prevent Dropping Core Units. Enh Bug# 3052432.
  --svanukur    19-oct-2003    MOdified procedure enrpl_copy_param_sua, enrpl_copy_adm_sua in Enrp_Ins_Snew_Prenrl and Enrp_Ins_Sret_Prenrl
  --                           as part of placements build 3052438.
  --ptandon     11-Dec-2003    Modified procedure adv_stand_trans as part of Bug# 3271754.
  --ptandon     29-Dec-2003    Removed the Exception Handling sections of functions Enrp_Ins_Sut_Trnsfr and Enrp_Ins_Sua_Trnsfr
  --                           so that the correct error message is displayed. Bug# 3328083 and 3328268.
  --ptandon     13-Feb-2004    Modified the exception handling sections of enrpl_upd_candidature, enrpl_create_sca and enrp_ins_snew_prenrl
  --                           to log messages using FND logging instead of throwing unhandled exceptions. Bug# 3360336.
  --ptandon     23-Feb-2004    Modified procedure adv_stand_trans as part of Bug# 3461036.
  -- amuthu     21-NOV-2004    Modified as part of program transfer build, modified enrp_ins_sua_trnsfr.
  --                           Added new procedure to copy outcome and placement details and added a call to the same in enrp_ins_sua_trnsfr
  -- ckasu      08-DEC-2004    modfied enrf_unit_from_past procedure as a part  of bug#4048203 inorder
  --                           to move the status of  dicontinue,completed unit attempts as same only
  --                           when load calendar into which units enrolled equals the effective term
  --                           calendar for Transfer.
  -- ckasu      11-Dec-2004    Modified Enrp_del_all_Sua_Trnsfr inorder to retain unselected enrolled or waitlisted or invalid units
  --                           when transfer is across careers and discontinue source is set to no and removed Enrp_del_Sua_Trnsfr
  --                           as a part of bug#4061818
  -- ckasu      21-Dec-2004    modified Enrp_Ins_Sua_Trnsfr procedure inorder to Transfer Unit outcomes in ABA Transfer as a part
  --                           of bug# 4080883
  -- smaddali   21-dec-04      Modified procedure enrp_ins_sua_trnsfr ,Enrp_del_all_Sua_Trnsfr for bug#4083358
  -- sgurusam   17-Jun-05      Modified function enrp_vald_inst_sua, to pass additional parameter p_calling_obj= 'JOB'
  --                           Modified function Enrp_Ins_Sua_Trnsfr to pass additional parameter SS_SOURCE_IND='A' and UPD_AUDIT_FLAG='N'
  --                           Modified function Enrp_del_all_Sua_Trnsfr to add parameters for upd_audit_ind and ss_source_ind
  -- ckasu   28-Oct-2005       Impact for changes to check_usa_overlap as a part of bug #4672177
  -- smaddali 14-nov-05        modified enrp_ins_suai_trnsfr  for bug#4701301
  -- stuta    26-Nov-05        modified enrp_ins_suai_trnsfr  for bug#4744323
  -- smaddali 16-jan-2006      Modified cursors for performance repository bug#3699726
  -- ckasu     07-MAR-2006     modified as a part of bug#5070730
  -------------------------------------------------------------------------------------------
  g_module_head CONSTANT VARCHAR2(40) := 'igs.plsql.igs_en_gen_010.';
  --
  FUNCTION create_stream_unit_sets(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_new_admin_unit_set IN VARCHAR2,
    p_selection_dt IN DATE,
    p_confirmed_ind IN VARCHAR2,
    p_log_creation_dt IN DATE,
    p_message_name OUT NOCOPY VARCHAR2
  )
  RETURN BOOLEAN;
  FUNCTION create_unit_set(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_unit_set_cd IN VARCHAR2,
    p_us_version_number IN NUMBER,
    p_selection_dt IN DATE,
    p_confirmed_ind IN VARCHAR2,
    p_authorised_person_id IN NUMBER,
    p_authorised_on IN DATE,
    p_seqval OUT NOCOPY NUMBER,
    p_log_creation_dt IN DATE,
    p_message_name OUT NOCOPY VARCHAR2
  )
  RETURN BOOLEAN;

  FUNCTION update_stream_unit_sets(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_old_admin_unit_set IN VARCHAR2,
    p_rqrmnts_complete_ind IN VARCHAR2,
    p_rqrmnts_complete_dt IN DATE,
    p_selection_dt IN DATE,
    p_confirmed_ind IN VARCHAR2,
    p_log_creation_dt IN DATE,
    p_message_name OUT NOCOPY VARCHAR2
  )
  RETURN BOOLEAN;
PROCEDURE log_error_message(p_s_log_type          VARCHAR2,
                            p_creation_dt         DATE,
                            p_sle_key             VARCHAR2,
                            p_sle_message_name    VARCHAR2,
                            p_del                 VARCHAR2);

  FUNCTION enrp_val_sua_cnfrm_before_pt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ci_end_dt IN DATE ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_enrolled_dt IN DATE ,
  p_fail_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN;


  PROCEDURE copy_hesa_details (
            p_person_id IN NUMBER,
            p_course_cd IN VARCHAR2,
            p_crv_version_number IN VARCHAR2,
            p_old_unit_set_cd IN VARCHAR2,
            p_old_us_version_number IN NUMBER,
            p_old_sequence_number IN NUMBER ,
            p_new_unit_set_cd IN VARCHAR2,
            p_new_us_version_number IN NUMBER,
            p_new_sequence_number IN NUMBER
            ) IS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- smadali 14-may-2002 modified exception part to raise the exception ,
  --           added new parameter p_old_sequence_number and
  --           renamed p_sequence_number to p_new_sequence_number,for bug#2350629
  -------------------------------------------------------------------------------------------

     l_message_name VARCHAR2(2000) ;
     l_status NUMBER;

  BEGIN
   --copying the hesa details, call to the hesa enr procedure, hesa requirment, pmarada.
     IF fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' THEN
          l_message_name := NULL;
          l_Status   := NULL;
          IGS_EN_HESA_PKG.HESA_STATS_ENR(
                                  p_person_id           => p_person_id,
                                  p_course_cd           => p_course_cd,
                                  p_crv_version_number  => p_crv_version_number,
                                  p_message             => l_message_name,
                                  p_status              => l_status);

         IF NVL(l_Status,0) = 2 THEN -- ie. The procedure call has resulted in error.
               Fnd_Message.Set_Name('IGS', l_message_name);
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
         END IF;

         -- Calling the Hesa procedure
         l_message_name := NULL;
         l_Status   := NULL;
         IGS_EN_HESA_PKG.hesa_susa_enr(p_person_id              =>  p_person_id,
                                       p_course_cd              =>  p_course_cd,
                                       p_crv_version_number     =>  p_crv_version_number,
                                       p_old_unit_set_cd        =>  p_old_unit_set_cd,
                                       p_old_us_version_number  =>  p_old_us_version_number,
                                       p_old_sequence_number    =>  p_old_sequence_number,
                                       p_new_unit_set_cd        =>  p_new_unit_set_cd,
                                       p_new_us_version_number  =>  p_new_us_version_number,
                                       p_new_sequence_number    =>  p_new_sequence_number,
                                       p_message                =>  l_message_name,
                                       p_status                 =>  l_status);
         IF NVL(l_Status,0) = 2 THEN -- ie. The procedure call has resulted in error.
            Fnd_Message.Set_Name('IGS', l_message_name);
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
         END IF;

    END IF; --  IF fnd_profile.value('OSS_COUNTRY_CODE') = 'GB'

   EXCEPTION
     WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
       RAISE;
     WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.copy_hesa_details');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

  END copy_hesa_details;

FUNCTION Enrp_Ins_Snew_Prenrl(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_enrolment_cat               IN VARCHAR2 ,
  p_acad_cal_type               IN VARCHAR2 ,
  p_acad_sequence_number        IN NUMBER ,
  p_units_indicator             IN VARCHAR2 ,
  p_dflt_confirmed_course_ind   IN VARCHAR2 ,
  p_override_enr_form_due_dt    IN DATE ,
  p_override_enr_pckg_prod_dt   IN DATE ,
  p_check_eligibility_ind       IN VARCHAR2 ,
  p_acai_admission_appl_number  IN NUMBER ,
  p_acai_nominated_course_cd    IN VARCHAR2 ,
  p_acai_sequence_number        IN NUMBER ,
  p_unit1_unit_cd               IN VARCHAR2 ,
  p_unit1_cal_type              IN VARCHAR2 ,
  p_unit1_location_cd           IN VARCHAR2 ,
  p_unit1_unit_class            IN VARCHAR2 ,
  p_unit2_unit_cd               IN VARCHAR2 ,
  p_unit2_cal_type              IN VARCHAR2 ,
  p_unit2_location_cd           IN VARCHAR2 ,
  p_unit2_unit_class            IN VARCHAR2 ,
  p_unit3_unit_cd               IN VARCHAR2 ,
  p_unit3_cal_type              IN VARCHAR2 ,
  p_unit3_location_cd           IN VARCHAR2 ,
  p_unit3_unit_class            IN VARCHAR2 ,
  p_unit4_unit_cd               IN VARCHAR2 ,
  p_unit4_cal_type              IN VARCHAR2 ,
  p_unit4_location_cd           IN VARCHAR2 ,
  p_unit4_unit_class            IN VARCHAR2 ,
  p_unit5_unit_cd               IN VARCHAR2 ,
  p_unit5_cal_type              IN VARCHAR2 ,
  p_unit5_location_cd           IN VARCHAR2 ,
  p_unit5_unit_class            IN VARCHAR2 ,
  p_unit6_unit_cd               IN VARCHAR2 ,
  p_unit6_cal_type              IN VARCHAR2 ,
  p_unit6_location_cd           IN VARCHAR2 ,
  p_unit6_unit_class            IN VARCHAR2 ,
  p_unit7_unit_cd               IN VARCHAR2 ,
  p_unit7_cal_type              IN VARCHAR2 ,
  p_unit7_location_cd           IN VARCHAR2 ,
  p_unit7_unit_class            IN VARCHAR2 ,
  p_unit8_unit_cd               IN VARCHAR2 ,
  p_unit8_cal_type              IN VARCHAR2 ,
  p_unit8_location_cd           IN VARCHAR2 ,
  p_unit8_unit_class            IN VARCHAR2 ,
  p_log_creation_dt             IN DATE ,
  p_warn_level                  IN OUT NOCOPY VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2 ,
  --smaddali addded these 18 params for YOP-EN build bug#2156956
  p_unit9_unit_cd               IN VARCHAR2 ,
  p_unit9_cal_type              IN VARCHAR2 ,
  p_unit9_location_cd           IN VARCHAR2 ,
  p_unit9_unit_class            IN VARCHAR2 ,
  p_unit10_unit_cd              IN VARCHAR2 ,
  p_unit10_cal_type             IN VARCHAR2 ,
  p_unit10_location_cd          IN VARCHAR2 ,
  p_unit10_unit_class           IN VARCHAR2 ,
  p_unit11_unit_cd              IN VARCHAR2 ,
  p_unit11_cal_type             IN VARCHAR2 ,
  p_unit11_location_cd          IN VARCHAR2 ,
  p_unit11_unit_class           IN VARCHAR2 ,
  p_unit12_unit_cd              IN VARCHAR2 ,
  p_unit12_cal_type             IN VARCHAR2 ,
  p_unit12_location_cd          IN VARCHAR2 ,
  p_unit12_unit_class           IN VARCHAR2 ,
  p_unit_set_cd1                IN VARCHAR2 ,
  p_unit_set_cd2                IN VARCHAR2 ,
  p_progress_stat               IN VARCHAR2 ,
  p_dflt_enr_method             IN VARCHAR2 ,
  p_load_cal_type               IN VARCHAR2 ,
  p_load_ci_seq_num             IN NUMBER)
RETURN BOOLEAN AS
/* HISTORY
    WHO       WHEN          WHAT
   bdeviset  29-JUL-2004   Before calling IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW/INSERT_ROW in a check is
         made to see that their is no overlapping of selection,completion and
                           end dates for any two unit sets by calling check_usa_overlap.If it returns
                           false log entry is made and the insert or update is not carried out for bug 3149133.
   knag      29-OCT-2002   Bug 2647482 addded parameters attendance_mode, location_cd for calculation
                           of proposed completion date by procedure igs_ad_gen_004.admp_get_crv_comp_dt
   ayedubat  4-JUN-2002    Changed the Code of YOP for default Unit Set pre-enrollment before
                           the Units pre-enrollment Code for the bug fix: 2391842
   ayedubat  25-MAY-2002   Changed the cursors c_acaiv and c_acaiv1 to replace the view,IGS_AD_PS_APPL_INST_APLINST_V
                           with the base table,IGS_AD_PS_APPL_INST as part of the bug fix:2384449
   ayedubat  21-MAY-2002   Modified the cursor,c_first_us to select always the Unit Set with mapping
                           sequence number of '1' as part of the bug fix:2348709
   ayedubat  15-MAY-2002   Changed the cursor,c_chk_census_dt to consider only the SUA records with
                           unit attempt status 'ENROLLED','DISCONTIN','DUPLICATE' or 'COMPLETED' and
                           also added the TRUNC to SYDATE as part of the bug:2372892
   svanukur  10-jul-2003   checking for parameter P_PROGRESS_STAT , if it is set to 'ADVANCE' as part of bug #3043374
   knaraset  06-Aug-2003   Modified the Pre-enrollment of new students to pass NULL for Nominated completion columns while
                           creation of program attempt, and also removed the references to Admission's Nominated/expected completion columns.
   ptandon   06-Oct-2003   Modified the inline procedures enrpl_copy_adm_sua and enrpl_copy_param_sua
                           as part of Prevent Dropping Core Units. Enh Bug# 3052432.
   svanukur  02-jul-2004   MOdified Pre-enrollment of new students  to pass the selection date of unit set attempts
                           as the SPA commencement date instead of the sysdate in the YOP mode
                           as part of bug fix 3687470
   svanukur  20-jul-2004   Added a check after call to procedure enrpl_create_pos_sua to return false to igs_en_gen_008
                           so that the message successfully preenrolled is not shown in the log file. BUG 3032588.

 */
BEGIN -- enrp_ins_snew_prenrl
  -- This process will pre-enrol a single new student in the specified
  -- IGS_PS_COURSE. The following steps will be performed :
  -- * Check the students eligibility to enrol in the specified IGS_PS_COURSE
  --   in the specified academic calendar.
  -- * Create a IGS_EN_STDNT_PS_ATT record
  -- * Create a IGS_AS_SC_ATMPT_ENR record
  -- * Create any required IGS_AS_SU_SETATMPT details
  -- * Create default IGS_EN_STDNTPSHECSOP details
  -- * Pre-enrol IGS_PS_UNIT attempts entered during Admissions, as parameter
  --   to the process or through the Pattern of Study.
  -- If at any point it becomes impossible to pre-enrol the student,
  --   the routine will return FALSE and message number of a message
  --   indicating the reason for failure ; the log error indicator will be
  --   set if the error is one that should be logged if the pre-enrolments
  --   were happening in batch. This can be used by the calling routine
  --   (whether batch or online) to indicate who was and wasn?t pre-enrolled.
  -- Notes:
  -- p_check_eligbility_ind
  --  If this indicator is set to 'N' then the routine will assume that
  --  all of the eligibility checks associated with pre-enrolment have
  --  been already checked. eg. If the routine is called from admissions
  --  where all of these checks were performed prior to the offer being
  --  allowed.
  -- p_acai_nominated_course_cd
  -- p_acai_sequence_number
  --  If these values are specified then they will be used to search for
  --  the require details from the acai table. This should be used when
  --  the admissions context is already known.
  -- p_log_creation_dt
  --  The creation date of the log for the session of pre-enrolments. This
  --  is designed to be used only when the pre-enrolment process is being
  --  run in batch mode. The log is of type ?PRE-ENROL?. It is up to the
  --  calling routine to ensure that the log has already been created ;
  --  this process (and called processes) will only add entries to the
  --  existing log.
  -- To pre-enrol units as parameters it is assumed that the first
  --  IGS_PS_UNIT is specified

DECLARE
  e_resource_busy   EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_resource_busy, -54);

  -- Cursor to fetch the admission details of the list of students identified for pre-enrollment
  CURSOR  c_acaiv IS
    SELECT  acaiv.person_id,
      aa.acad_cal_type,
      NVL(acaiv.adm_cal_type,aa.adm_cal_type) adm_cal_type,
      NVL(acaiv.adm_ci_sequence_number,aa.adm_ci_sequence_number) adm_ci_sequence_number,
      acaiv.location_cd,
      acaiv.attendance_type,
      acaiv.attendance_mode,
      acaiv.admission_appl_number,
      acaiv.nominated_course_cd,
      acaiv.sequence_number,
      acaiv.course_cd,
      acaiv.crv_version_number,
      acaiv.fee_cat,
      acaiv.correspondence_cat,
      acaiv.enrolment_cat,
      acaiv.unit_set_cd,
      acaiv.us_version_number,
      acaiv.hecs_payment_option,
      acaiv.adm_outcome_status,
      acaiv.funding_source,
      aa.admission_cat,
      aa.s_admission_process_type,
      aos.s_adm_outcome_status,
      acaiv.adm_cndtnl_offer_status,
      acaiv.adm_offer_resp_status,
      aors.s_adm_offer_resp_status,
      acaiv.actual_response_dt,
      acaiv.expected_completion_yr,
      acaiv.expected_completion_perd,
      acaiv.offer_dt
    FROM  IGS_AD_PS_APPL_INST acaiv,
      IGS_AD_APPL     aa,
      IGS_AD_OU_STAT  aos,
      IGS_AD_OFR_RESP_STAT  aors
    WHERE
      acaiv.person_id     = p_person_id       AND
      acaiv.course_cd     = p_course_cd       AND
      aa.acad_cal_type    = p_acad_cal_type   AND
      aa.acad_ci_sequence_number  = p_acad_sequence_number     AND
      aa.person_id               = acaiv.person_id             AND
      aa.admission_appl_number   = acaiv.admission_appl_number AND
      aos.adm_outcome_status     = acaiv.adm_outcome_status    AND
      aors.adm_offer_resp_status = acaiv.adm_offer_resp_status AND
      aos.s_adm_outcome_status      IN ('OFFER','COND-OFFER')    AND
      aors.s_adm_offer_resp_status NOT IN ('LAPSED','REJECTED')
    ORDER BY acaiv.offer_dt DESC;

  -- Cursor to fetch the admission details of the list of students identified for pre-enrollment
  CURSOR  c_acaiv1 IS
    SELECT  acaiv.person_id,
      aa.acad_cal_type,
      NVL(acaiv.adm_cal_type,aa.adm_cal_type) adm_cal_type,
      NVL(acaiv.adm_ci_sequence_number,aa.adm_ci_sequence_number) adm_ci_sequence_number,
      acaiv.location_cd,
      acaiv.attendance_type,
      acaiv.attendance_mode,
      acaiv.admission_appl_number,
      acaiv.nominated_course_cd,
      acaiv.sequence_number,
      acaiv.course_cd,
      acaiv.crv_version_number,
      acaiv.fee_cat,
      acaiv.correspondence_cat,
      acaiv.enrolment_cat,
      acaiv.unit_set_cd,
      acaiv.us_version_number,
      acaiv.hecs_payment_option,
      acaiv.adm_outcome_status,
      acaiv.funding_source,
      aa.admission_cat,
      aa.s_admission_process_type,
      aos.s_adm_outcome_status,
      acaiv.adm_cndtnl_offer_status,
      acaiv.adm_offer_resp_status,
      aors.s_adm_offer_resp_status,
      acaiv.actual_response_dt,
      acaiv.expected_completion_yr,
      acaiv.expected_completion_perd,
      acaiv.offer_dt
    FROM  IGS_AD_PS_APPL_INST  acaiv,
          IGS_AD_APPL          aa,
          IGS_AD_OU_STAT       aos,
          IGS_AD_OFR_RESP_STAT aors
    WHERE acaiv.person_id     = p_person_id AND
      acaiv.course_cd     = p_course_cd     AND
      acaiv.admission_appl_number   = p_acai_admission_appl_number AND
      acaiv.nominated_course_cd   = p_acai_nominated_course_cd     AND
      acaiv.sequence_number     = p_acai_sequence_number           AND
      aa.person_id      = acaiv.person_id   AND
      aa.admission_appl_number  = acaiv.admission_appl_number AND
      aos.adm_outcome_status    =  acaiv.adm_outcome_status    AND
      aors.adm_offer_resp_status  = acaiv.adm_offer_resp_status;

    v_acaiv_rec   c_acaiv%ROWTYPE;
    -- output variables
    v_message_name    VARCHAR2(2000) ;
    v_warn_level    VARCHAR2(10);

    -- variables which store values that are used when inserting new records
    -- or updating existing records.
    v_funding_source  IGS_FI_FND_SRC_RSTN.funding_source%TYPE;
    v_fee_cat   IGS_FI_FEE_CAT_MAP.fee_cat%TYPE ;
    v_correspondence_cat  IGS_CO_CAT_MAP.correspondence_cat%TYPE
                 ;
    v_attendance_mode VARCHAR2(3) ;
    v_sca_commencement_dt DATE ;
    v_adm_added_ind   VARCHAR2(1);
    v_parm_added_ind  VARCHAR2(1);
    v_provisional_ind VARCHAR2(1);
    -- p_warn_level types
    cst_error   CONSTANT VARCHAR2(5) := 'ERROR';
    cst_minor   CONSTANT VARCHAR2(5) := 'MINOR';
    cst_major   CONSTANT VARCHAR2(5) := 'MAJOR';
    l_enc_message_name VARCHAR2(2000);
    l_app_short_name VARCHAR2(10);
    l_message_name VARCHAR2(100);
    l_mesg_txt VARCHAR2(4000);
    l_msg_index NUMBER;

    --bmerugu added for build 319
    l_sua_create   BOOLEAN   := TRUE;

    -- other constants
    cst_deleted   CONSTANT VARCHAR2(10)   := 'DELETED';
    cst_discontin   CONSTANT VARCHAR2(10) := 'DISCONTIN';
    cst_inactive    CONSTANT VARCHAR2(10) := 'INACTIVE';
    cst_lapsed    CONSTANT VARCHAR2(10)   := 'LAPSED';
    cst_new     CONSTANT VARCHAR2(10)     := 'NEW';
    cst_pre_enrol   CONSTANT VARCHAR2(10) := 'PRE-ENROL';
    cst_unconfirm   CONSTANT VARCHAR2(10) := 'UNCONFIRM';
    cst_accepted    CONSTANT VARCHAR2(10) := 'ACCEPTED';
    cst_cond_offer    CONSTANT VARCHAR2(10) := 'COND-OFFER';
    cst_offer     CONSTANT VARCHAR2(10)   := 'OFFER';
    cst_pending     CONSTANT VARCHAR2(10) := 'PENDING';
    cst_fee_cntrct    CONSTANT VARCHAR2(10) := 'FEE-CNTRCT';

    -- smaddali added these new cursors and function for YOP-EN dld bug#2156956
    l_confirmed_ind    VARCHAR2(1);
    l_seqval        igs_as_su_setatmpt.sequence_number%TYPE ;
    v_selection_dt  igs_as_su_setatmpt.selection_dt%TYPE ;
    v_rqrmnts_complete_dt igs_as_su_setatmpt.rqrmnts_complete_dt%TYPE;

    -- checks the eligibility of the student to be moved to the next year of program (unit set)
    -- by checking if there is any outcome preventing the progress of the student program attempt
    CURSOR  c_prog_outcome(cp_select_dt  igs_as_su_setatmpt.selection_dt%TYPE) IS
      SELECT  pou.decision_dt, pout.s_progression_outcome_type
      FROM  igs_pr_stdnt_pr_ou_all pou , igs_pr_ou_type pout
      WHERE   pou.person_id = p_person_id  AND
        pou.course_cd  = p_course_cd       AND
        pou.decision_status = 'APPROVED'   AND
        pou.decision_dt IS NOT NULL        AND
        pou.decision_dt  >  cp_select_dt   AND
        pou.progression_outcome_type = pout.progression_outcome_type
      ORDER BY pou.decision_dt desc ;
    c_prog_outcome_rec   c_prog_outcome%ROWTYPE;
    gv_progress_outcome_type  igs_pr_ou_type.s_progression_outcome_type%TYPE;


    -- get the currently active unit set for the person course attempt
    CURSOR c_active_us IS
      SELECT susa.*
      FROM  igs_as_su_setatmpt susa , igs_en_unit_set us , igs_en_unit_set_cat usc
      WHERE  susa.person_id = p_person_id  AND
        susa.course_cd  = p_course_cd      AND
        susa.selection_dt IS NOT NULL      AND
        susa.end_dt IS NULL                AND
        susa.rqrmnts_complete_dt  IS NULL  AND
        susa.unit_set_cd = us.unit_set_cd  AND
        us.unit_set_cat = usc.unit_set_cat AND
        usc.s_unit_set_cat  = 'PRENRL_YR' ;
      c_active_us_rec  c_active_us%ROWTYPE;

    --get the next unit set in sequence
    CURSOR  c_next_us(cp_unit_set_cd igs_ps_us_prenr_cfg.unit_set_cd%TYPE) IS
      SELECT cf1.unit_set_cd , cf1.sequence_no
      FROM   igs_ps_us_prenr_cfg cf1 , igs_ps_us_prenr_cfg  cf2
      WHERE  cf2.mapping_set_cd = cf1.mapping_set_cd  AND
        cf2.unit_set_cd = cp_unit_set_cd              AND
        cf1.sequence_no >  cf2.sequence_no
      ORDER BY cf1.sequence_no asc;
      c_next_us_rec   c_next_us%ROWTYPE;

    CURSOR c_us_version_number(cp_person_id  igs_en_stdnt_ps_att.person_id%TYPE,
                               cp_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE,
                               cp_unit_set_cd  igs_en_unit_set.unit_set_cd%TYPE) IS
      SELECT coous.us_version_number
      FROM  igs_en_unit_set_stat uss, igs_ps_ofr_opt_unit_set_v coous, igs_en_stdnt_ps_att sca
      WHERE  sca.person_id = cp_person_id AND
             sca.course_cd = cp_course_cd AND
             sca.coo_id = coous.coo_id AND
             coous.unit_set_cd = cp_unit_set_cd AND
             coous.expiry_dt  IS NULL AND
            coous.unit_set_status = uss.unit_set_status AND
            uss.s_unit_set_status = 'ACTIVE'  ;
      next_us_version  igs_en_unit_set.version_number%TYPE;

    -- Modified the cursor to select always the Unit Set with mapping sequence number of '1'
    -- not the first unit set in mapping by ayedubat as part of the bug fix:2348709
    CURSOR c_first_us  IS
      SELECT coou.unit_set_cd, coou.us_version_number
      FROM  igs_ps_ofr_opt_unit_set_v coou , igs_en_unit_set_cat usc
      WHERE coou.course_cd = p_course_cd  AND
        coou.crv_version_number = v_acaiv_rec.crv_version_number AND
        coou.cal_type = v_acaiv_rec.acad_cal_type  AND
        coou.location_cd = v_acaiv_rec.location_cd   AND
        coou.attendance_mode = v_acaiv_rec.attendance_mode AND
        coou.attendance_type = v_acaiv_rec.attendance_type AND
        coou.unit_set_cat = usc.unit_set_cat AND
        usc.s_unit_set_cat  = 'PRENRL_YR'  AND
        coou.unit_set_cd IN  ( SELECT a.unit_set_cd
                               FROM   igs_ps_us_prenr_cfg a
                               WHERE  a.sequence_no = 1 );

    l_first_us  c_first_us%ROWTYPE ;
    l_us_cat  VARCHAR2(1);
    v_unit_set_cd  igs_en_unit_set.unit_set_cd%TYPE;
    l_rowid VARCHAR2(25);

    CURSOR c_chk_census_dt(cp_unit_set_cd igs_en_unit_set.unit_set_cd%TYPE)  IS
      SELECT sua.*
      FROM  igs_en_sua_year_v sua
      WHERE  sua.person_id = p_person_id AND
         sua.course_cd  = p_course_cd  AND
         sua.unit_set_cd = cp_unit_set_cd AND
         sua.unit_attempt_status IN ('ENROLLED','DISCONTIN','DUPLICATE','COMPLETED') AND
         IGS_EN_GEN_015.get_effective_census_date(Null,Null,sua.cal_type,sua.ci_sequence_number) < TRUNC(SYSDATE) ;
      c_census_dt_rec  c_chk_census_dt%ROWTYPE ;

    -- check if susa already exists and if so update it
    CURSOR c_exists_susa(cp_unit_set_cd igs_as_su_setatmpt.unit_set_cd%TYPE ,
        cp_us_version_number  igs_as_su_setatmpt.us_version_number%TYPE ) IS
      SELECT sequence_number , student_confirmed_ind
      FROM IGS_AS_SU_SETATMPT
      WHERE  person_id = p_person_id AND
           course_cd = p_course_cd AND
           unit_set_cd = cp_unit_set_cd AND
           us_version_number =  cp_us_version_number ;
      c_exists_susa_rec   c_exists_susa%ROWTYPE ;

    CURSOR c_susa_upd ( cp_unit_set_cd igs_as_su_setatmpt.unit_set_cd%TYPE ,
        cp_us_version_number  igs_as_su_setatmpt.us_version_number%TYPE ,
        cp_sequence_number  igs_as_su_setatmpt.sequence_number%TYPE ) IS
      SELECT rowid,IGS_AS_SU_SETATMPT.*
      FROM IGS_AS_SU_SETATMPT
      WHERE  person_id = p_person_id AND
           course_cd = p_course_cd AND
           unit_set_cd = cp_unit_set_cd AND
           us_version_number =  cp_us_version_number  AND
           sequence_number = cp_sequence_number
       FOR UPDATE  OF RQRMNTS_COMPLETE_IND ,
                      RQRMNTS_COMPLETE_DT , student_confirmed_ind NOWAIT;
     c_susa_upd_rec  c_susa_upd%ROWTYPE  ;

     CURSOR c_load_cal(p_acad_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                       p_acad_seq_num  IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
     SELECT rel.sub_cal_type, rel.sub_ci_sequence_number FROM igs_ca_inst_rel rel,
                                                               igs_ca_inst ci,
                                                               igs_ca_type cal
                                                          WHERE rel.sup_cal_type           = p_acad_cal_type
                                                          AND   rel.sup_ci_sequence_number = p_acad_seq_num
                                                          AND   rel.sub_cal_type           = ci.cal_type
                                                          AND   rel.sub_ci_sequence_number = ci.sequence_number
                                                          AND   rel.sub_cal_type           = cal.cal_type
                                                          AND   cal.s_cal_cat              = 'LOAD'
                                                          AND   cal.closed_ind             = 'N'
                                                          ORDER BY ci.start_dt;

    CURSOR cur_spa IS
    SELECT  spa.commencement_dt
    FROM    IGS_EN_STDNT_PS_ATT spa
    WHERE   spa.person_id = p_person_id AND
              spa.course_cd = p_course_cd;

     l_load_cal_type         igs_ca_inst.cal_type%TYPE;
     l_load_seq_num          igs_ca_inst.sequence_number%TYPE;
     l_enr_method            igs_en_method_type.enr_method_type%TYPE;
     l_return_status         VARCHAR2(20);
     l_dummy_mesg            VARCHAR2(100);
  FUNCTION prenrl_year (cp_unit_set_cd  IN igs_en_unit_set.unit_set_cd%TYPE)
  RETURN BOOLEAN AS
  BEGIN
     DECLARE
       CURSOR c_us_cat IS
         SELECT 'X'
         FROM  igs_en_unit_set us , igs_en_unit_set_cat usc
         WHERE  us.unit_set_cd = cp_unit_set_cd  AND
          us.unit_set_cat = usc.unit_set_cat AND
          usc.s_unit_set_cat  = 'PRENRL_YR' ;
         l_us_cat  c_us_cat%ROWTYPE ;
      BEGIN
        OPEN c_us_cat ;
        FETCH c_us_cat INTO l_us_cat ;
        IF c_us_cat%FOUND THEN
           CLOSE c_us_cat ;
           RETURN TRUE;
        ELSE
           CLOSE c_us_cat;
           RETURN FALSE;
        END IF;
     END ;
   END prenrl_year;
   -- end of changes by smaddali

  FUNCTION enrpl_check_eligibility (
    p_message_name    OUT NOCOPY Varchar2 )
  RETURN BOOLEAN
  AS

  BEGIN -- enrpl_check_eligibility
    -- Check the eligibility of the student to enrol in the
    -- specified IGS_PS_COURSE in the specified academic calendar.
    DECLARE
      v_message_name    VARCHAR(2000);
    BEGIN
      p_message_name := null;
      -- Call routine to check the eligibility of the student.
      IF NOT IGS_EN_GEN_006.ENRP_GET_SCA_ELGBL(
        p_person_id,
        p_course_cd,
        cst_new,
        p_acad_cal_type,
        p_acad_sequence_number,
        p_dflt_confirmed_course_ind,
        v_message_name) THEN
        IF p_log_creation_dt IS NOT NULL THEN
          IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_minor || ',' ||
              TO_CHAR(p_person_id) || ',' ||
               p_course_cd,
            v_message_name,
            NULL);
        END IF;
        p_message_name := v_message_name;
        RETURN FALSE;
      END IF;
      RETURN TRUE;
    END;
  EXCEPTION
     WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
       RAISE;
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_check_eligibility');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END enrpl_check_eligibility;

  FUNCTION enrpl_check_offer(
    p_warn_level    OUT NOCOPY   VARCHAR2,
    p_message_name    OUT NOCOPY varchar2 )
  RETURN BOOLEAN
  AS

  BEGIN -- enrpl_check_offer
    DECLARE
    BEGIN
      p_warn_level := NULL;
      p_message_name := null;
      IF p_acai_admission_appl_number IS NULL OR
         p_acai_nominated_course_cd IS NULL OR
         p_acai_sequence_number IS NULL THEN
        OPEN c_acaiv;
        FETCH c_acaiv INTO v_acaiv_rec;
        IF c_acaiv%NOTFOUND THEN
          CLOSE c_acaiv;
          IF p_log_creation_dt IS NOT NULL THEN
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
              cst_pre_enrol,
              p_log_creation_dt,
              cst_error || ',' ||
                TO_CHAR(p_person_id) || ',' ||
                 p_course_cd,
              'IGS_EN_UNABLE_TO_FND_ADM',
              NULL);
          END IF;
          p_message_name := 'IGS_EN_UNABLE_TO_FND_ADM';
          p_warn_level := cst_error;
          RETURN FALSE;
        END IF;
        CLOSE c_acaiv;
      ELSE
        OPEN  c_acaiv1;
        FETCH c_acaiv1 INTO v_acaiv_rec;
        IF c_acaiv1%NOTFOUND THEN
          CLOSE c_acaiv1;
          -- Application not found - pre - enrolment not possible.
          IF p_log_creation_dt IS NOT NULL THEN
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
              cst_pre_enrol,
              p_log_creation_dt,
              cst_error || ',' ||
                TO_CHAR(p_person_id) || ',' ||
                 p_course_cd,
              'IGS_EN_UNABLE_TO_FND_ADM',
              NULL);
          END IF;
          p_message_name := 'IGS_EN_UNABLE_TO_FND_ADM';
          p_warn_level := cst_error;
          RETURN FALSE;
        END IF;
        CLOSE c_acaiv1;
      END IF;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_acaiv%ISOPEN THEN
          CLOSE c_acaiv;
        END IF;
        IF c_acaiv1%ISOPEN THEN
          CLOSE c_acaiv1;
        END IF;
        RAISE;
    END;
  EXCEPTION
     WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
       RAISE;
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_check_offer');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END enrpl_check_offer;

  FUNCTION enrpl_upd_candidature(
    p_warn_level    OUT NOCOPY   VARCHAR2,
    p_message_name    OUT NOCOPY varchar2 )
  RETURN BOOLEAN
  AS

  BEGIN -- enrpl_upd_candidature
    -- Update IGS_RE_CANDIDATURE Key Detail
    DECLARE
      CURSOR c_ca IS
        SELECT  ca.sequence_number
        FROM  IGS_RE_CANDIDATURE ca
        WHERE ca.person_id    = p_person_id AND
          ca.sca_course_cd  = p_course_cd;
      CURSOR c_ca2 IS
        SELECT  ca.sequence_number
        FROM  IGS_RE_CANDIDATURE ca
        WHERE ca.person_id      = p_person_id AND
          ca.acai_admission_appl_number   = v_acaiv_rec.admission_appl_number AND
          ca.acai_nominated_course_cd   = v_acaiv_rec.nominated_course_cd AND
          ca.acai_sequence_number   = v_acaiv_rec.sequence_number;
      CURSOR c_ca_upd (
        cp_sequence_number  IGS_RE_CANDIDATURE.sequence_number%TYPE) IS
        SELECT  ROWID,
                                  IGS_RE_CANDIDATURE.*
        FROM  IGS_RE_CANDIDATURE
        WHERE person_id     = p_person_id AND
          sequence_number   = cp_sequence_number
        FOR UPDATE OF
          acai_admission_appl_number,
          acai_nominated_course_cd,
          acai_sequence_number NOWAIT;

                  v_c_ca_upd_rec  c_ca_upd%ROWTYPE;

      v_ca_upd_exists     VARCHAR2(1);
      v_sca_ca_sequence_number  IGS_RE_CANDIDATURE.sequence_number%TYPE;
      v_acai_ca_sequence_number IGS_RE_CANDIDATURE.sequence_number%TYPE;

      BEGIN
        p_warn_level := NULL;
        p_message_name := null;
        -- Check if IGS_PE_PERSON has a IGS_RE_CANDIDATURE record linked
        -- to the student IGS_PS_COURSE attempt.
        OPEN c_ca;
        FETCH c_ca INTO v_sca_ca_sequence_number;
        CLOSE c_ca;
        -- Check if IGS_PE_PERSON has a IGS_RE_CANDIDATURE record linked to
        -- the admission IGS_PS_COURSE application instance.
        OPEN c_ca2;
        FETCH c_ca2 INTO v_acai_ca_sequence_number;
        CLOSE c_ca2;
        IF v_sca_ca_sequence_number <> v_acai_ca_sequence_number THEN
          -- It is not valid for the admission IGS_PS_COURSE application
          -- instance to be linked to a IGS_RE_CANDIDATURE and the student
          -- IGS_PS_COURSE attempt to be linked to a different IGS_RE_CANDIDATURE.
          -- Cannot determine which IGS_RE_CANDIDATURE should be used.
          -- Rollback to start of routine
          ROLLBACK TO sp_pre_enrol_student;
          IF p_log_creation_dt IS NOT NULL THEN
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                cst_pre_enrol,
                p_log_creation_dt,
                cst_error || ',' ||
                  TO_CHAR(p_person_id) || ',' ||
                   p_course_cd,
                'IGS_EN_INVALID_SUA_NOT_CONFIR',
                NULL);
          END IF;
          p_message_name := 'IGS_EN_NOT_DETERMINE_CONDID';
          p_warn_level := cst_error;
          RETURN FALSE;
        ELSIF v_sca_ca_sequence_number IS NOT NULL AND
            v_acai_ca_sequence_number IS NULL THEN
          -- The admission IGS_PS_COURSE application instance is not linked
          -- to a IGS_RE_CANDIDATURE - need to link it to the IGS_RE_CANDIDATURE
          -- record of the student IGS_PS_COURSE attempt.
          OPEN c_ca_upd(
            v_sca_ca_sequence_number);
          FETCH c_ca_upd INTO v_c_ca_upd_rec;

          IF c_ca_upd%FOUND THEN
               IGS_RE_CANDIDATURE_PKG.UPDATE_ROW(
                    X_ROWID => v_c_ca_upd_rec.rowid,
                    X_PERSON_ID  => v_c_ca_upd_rec.PERSON_ID,
                    X_SEQUENCE_NUMBER  => v_c_ca_upd_rec.SEQUENCE_NUMBER,
                    X_SCA_COURSE_CD => v_c_ca_upd_rec.SCA_COURSE_CD,
                    X_ACAI_ADMISSION_APPL_NUMBER  => v_acaiv_rec.admission_appl_number,
                    X_ACAI_NOMINATED_COURSE_CD => v_acaiv_rec.nominated_course_cd,
                    X_ACAI_SEQUENCE_NUMBER  => v_acaiv_rec.sequence_number,
                    X_ATTENDANCE_PERCENTAGE  => v_c_ca_upd_rec.ATTENDANCE_PERCENTAGE,
                    X_GOVT_TYPE_OF_ACTIVITY_CD => v_c_ca_upd_rec.GOVT_TYPE_OF_ACTIVITY_CD,
                    X_MAX_SUBMISSION_DT  => v_c_ca_upd_rec.MAX_SUBMISSION_DT,
                    X_MIN_SUBMISSION_DT  => v_c_ca_upd_rec.MIN_SUBMISSION_DT,
                    X_RESEARCH_TOPIC => v_c_ca_upd_rec.RESEARCH_TOPIC,
                    X_INDUSTRY_LINKS => v_c_ca_upd_rec.INDUSTRY_LINKS,
                    X_MODE =>  'R'  );

          END IF;
          CLOSE c_ca_upd;

        ELSIF v_sca_ca_sequence_number IS NULL AND
            v_acai_ca_sequence_number IS NOT NULL THEN
          -- The student IGS_PS_COURSE attempt is not linked to a IGS_RE_CANDIDATURE,
          -- need to link it to the IGS_RE_CANDIDATURE record of the admission
          -- IGS_PS_COURSE application instance.
          OPEN c_ca_upd(
            v_acai_ca_sequence_number);
          FETCH c_ca_upd INTO v_c_ca_upd_rec;

          IF c_ca_upd%FOUND THEN

            IGS_RE_CANDIDATURE_PKG.UPDATE_ROW(
                    X_ROWID => v_c_ca_upd_rec.rowid,
                    X_PERSON_ID  => v_c_ca_upd_rec.PERSON_ID,
                    X_SEQUENCE_NUMBER  => v_c_ca_upd_rec.SEQUENCE_NUMBER,
                    X_SCA_COURSE_CD => v_acaiv_rec.course_cd,
                    X_ACAI_ADMISSION_APPL_NUMBER  => v_c_ca_upd_rec.acai_admission_appl_number,
                    X_ACAI_NOMINATED_COURSE_CD => v_c_ca_upd_rec.acai_nominated_course_cd,
                    X_ACAI_SEQUENCE_NUMBER  => v_c_ca_upd_rec.acai_sequence_number,
                    X_ATTENDANCE_PERCENTAGE  => v_c_ca_upd_rec.ATTENDANCE_PERCENTAGE,
                    X_GOVT_TYPE_OF_ACTIVITY_CD => v_c_ca_upd_rec.GOVT_TYPE_OF_ACTIVITY_CD,
                    X_MAX_SUBMISSION_DT  => v_c_ca_upd_rec.MAX_SUBMISSION_DT,
                    X_MIN_SUBMISSION_DT  => v_c_ca_upd_rec.MIN_SUBMISSION_DT,
                    X_RESEARCH_TOPIC => v_c_ca_upd_rec.RESEARCH_TOPIC,
                    X_INDUSTRY_LINKS => v_c_ca_upd_rec.INDUSTRY_LINKS,
                    X_MODE => 'R'
                                                              );

          END IF;
          CLOSE c_ca_upd;
        END IF;
        -- Return the default value
        RETURN TRUE;
      EXCEPTION
        WHEN E_RESOURCE_BUSY THEN
          IF c_ca%ISOPEN THEN
            CLOSE c_ca;
          END IF;
          IF c_ca2%ISOPEN THEN
            CLOSE c_ca2;
          END IF;
          IF c_ca_upd%ISOPEN THEN
            CLOSE c_ca_upd;
          END IF;
          ROLLBACK TO sp_pre_enrol_student;
          IF p_log_creation_dt IS NOT NULL THEN
            Fnd_Message.Set_name('IGS','IGS_GE_RECORD_LOCKED');
            IGS_GE_MSG_STACK.ADD;
          END IF;
          p_message_name := 'IGS_EN_CANDID_KEY_DETAIL';
          p_warn_level := cst_error;
          RETURN FALSE;
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
          IF c_ca%ISOPEN THEN
            CLOSE c_ca;
          END IF;
          IF c_ca2%ISOPEN THEN
            CLOSE c_ca2;
          END IF;
          IF c_ca_upd%ISOPEN THEN
            CLOSE c_ca_upd;
          END IF;
          IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_upd_candidature.APP_EXP','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
          END IF;
          RAISE;
        WHEN OTHERS THEN
          IF c_ca%ISOPEN THEN
            CLOSE c_ca;
          END IF;
          IF c_ca2%ISOPEN THEN
            CLOSE c_ca2;
          END IF;
          IF c_ca_upd%ISOPEN THEN
            CLOSE c_ca_upd;
          END IF;
          IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_upd_candidature.UNH_EXP','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
          END IF;
          RAISE;
      END;
  END enrpl_upd_candidature;

  PROCEDURE enrpl_create_sca(
    p_warn_level    OUT NOCOPY   VARCHAR2,
    p_message_name    OUT NOCOPY VARCHAR2)
  AS
 /****************************************************************************
 History
  Who       When                   Why
  sarakshi  16-Nov-2004         Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the insert row,update call of IGS_EN_STDNT_PS_ATT_PKG
  ckasu     05-Apr-2004         Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
                                call as a part of bug 3544927.
  smaddali                      modified this procedure to create the HESA UK statistics record
                                whenever oss program attempt record is being created for bug#2350629
 svanukur  15-APR-2004          Passing the values for catalog fields while creating or updating a SPA. bug 3548376
 ctyagi       15-march-2005    Modify cursor cur_catalog_details for bug #4238062 (INCORRECT SPA CATALOG CODE  )
 *****************************************************************************/

  BEGIN -- enrpl_create_sca
    -- Create a IGS_EN_STDNT_PS_ATT record
    DECLARE

      CURSOR  c_crv IS
        SELECT  'x'
        FROM  IGS_PS_VER  crv,
          IGS_PS_TYPE   cty
        WHERE crv.course_cd     = v_acaiv_rec.course_cd AND
          crv.version_number  = v_acaiv_rec.crv_version_number AND
          cty.COURSE_TYPE   = crv.COURSE_TYPE AND
          cty.research_type_ind   = 'Y';
      v_crv_exists  VARCHAR2(1);

      CURSOR  c_sca IS
        SELECT  course_attempt_status,
          student_confirmed_ind,
          commencement_dt,
          discontinued_dt,
          fee_cat,
          correspondence_cat,
          funding_source,
          location_cd,
          attendance_mode,
          attendance_type,
          nominated_completion_yr,
          nominated_completion_perd,
          adm_admission_appl_number,
          adm_nominated_course_cd,
          adm_sequence_number,
          provisional_ind
        FROM  IGS_EN_STDNT_PS_ATT sca
        WHERE person_id = p_person_id AND
          course_cd = p_course_cd;
      v_sca_rec   c_sca%ROWTYPE;

      CURSOR  c_sca_upd IS
        SELECT  rowid,IGS_EN_STDNT_PS_ATT.*
        FROM  IGS_EN_STDNT_PS_ATT
        WHERE person_id = p_person_id AND
          course_cd = p_course_cd
        FOR UPDATE OF   course_attempt_status,
            fee_cat,
            correspondence_cat,
            funding_source,
            provisional_ind,
            location_cd,
            attendance_mode,
            attendance_type,
            adm_admission_appl_number,
            adm_nominated_course_cd,
            adm_sequence_number,
            catalog_cal_type,
            catalog_seq_num  NOWAIT;

      v_sca_upd_rec   c_sca_upd%ROWTYPE;
      v_confirmed_ind   VARCHAR2(1);
      v_course_attempt_status IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
      v_commencement_dt DATE ;
      v_description   IGS_FI_FEE_CAT.description%TYPE;
      v_funding_source  IGS_EN_STDNT_PS_ATT.funding_source%TYPE;

      --bmerugu added for build 319
      v_rowid VARCHAR2(25);
      v_program_type IGS_EN_STDNT_PS_ATT.primary_program_type%TYPE;

      -- bmerugu added this cursor for build 319
      CURSOR c_sca_ptype (cp_rowid VARCHAR2) IS
      SELECT  primary_program_type
      FROM  IGS_EN_STDNT_PS_ATT
      WHERE rowid = cp_rowid;

     CURSOR c_sca_ctype (cp_rowid VARCHAR2) IS
                SELECT  ps.course_type
                FROM    IGS_PS_VER ps,
			igs_en_stdnt_ps_att spa
                WHERE   spa.rowid= cp_rowid
		  AND	ps.course_cd      = spa.course_cd
		  AND   ps.version_number = spa.version_number;
      v_sca_ctype IGS_PS_VER.course_type%TYPE;

      CURSOR c_sca_primary(cp_course_type IGS_PS_VER.course_type%TYPE) IS
      SELECT  'X'
      FROM    igs_en_stdnt_ps_att spa,
              igs_ps_ver pv
      WHERE   spa.person_id = p_person_id
        AND   spa.primary_program_type = 'PRIMARY'
        AND   spa.course_cd = pv.course_cd
        AND   spa.version_number = pv.version_number
	AND   pv.course_type = cp_course_type;

      v_sca_primary_exists  VARCHAR2(1);

      l_message_name VARCHAR2(2000) ;
      l_status NUMBER;
-- cursor to fetch catalog details
   CURSOR cur_catalog_details(p_commencement_date DATE,p_cal_type igs_ca_inst.cal_type%type) IS
         SELECT  ci.cal_type catalog_cal_type,
                 ci.sequence_number catalog_seq_num
    FROM igs_ca_inst ci,
            igs_ca_type ct,
            igs_ca_stat cs,
            igs_ca_inst_rel cir
          WHERE ci.cal_type = ct.cal_type
            AND ct.s_cal_cat = 'LOAD'
            AND cs.cal_status = ci.cal_status
            AND cs.s_cal_status = 'ACTIVE'
            AND p_commencement_date BETWEEN ci.start_dt AND ci.end_dt
            AND ci.cal_type=cir.sub_cal_type
            AND ci.sequence_number=cir.sub_ci_sequence_number
            AND cir.sup_cal_type=p_cal_type
          ORDER BY ci.end_dt desc;

          catalog_cal_type igs_ca_inst.cal_type%TYPE;
          catalog_seq_num igs_ca_inst.sequence_number%TYPE;
    BEGIN
      p_warn_level := NULL;
      p_message_name := null;
      -- Determine research provisional indicator
      IF IGS_AD_GEN_008.ADMP_GET_SAOS(
          v_acaiv_rec.adm_outcome_status) = cst_cond_offer AND
        IGS_AD_GEN_007.ADMP_GET_SACOS(
          v_acaiv_rec.adm_cndtnl_offer_status) = cst_pending THEN
        -- Set provisional indicator to 'Y' if IGS_PS_COURSE attempt
        -- is a research IGS_PS_COURSE
        OPEN c_crv;
        FETCH c_crv INTO v_crv_exists;
        IF c_crv%NOTFOUND THEN
          CLOSE c_crv;
          v_provisional_ind := 'N';
        ELSE
          CLOSE c_crv;
          v_provisional_ind := 'Y';
        END IF;
      ELSE
        v_provisional_ind := 'N';
      END IF;

      -- Determine the default funding source from
      -- either (in order of priority) the acaiv
      -- detail or the IGS_PS_COURSE version default funding source.
      IF v_acaiv_rec.funding_source IS NOT NULL THEN
        v_funding_source := v_acaiv_rec.funding_source;
      ELSE
        v_funding_source := IGS_AD_GEN_005.ADMP_GET_DFLT_FS(
                v_acaiv_rec.course_cd,
                v_acaiv_rec.crv_version_number,
                v_description);
      END IF;

      -- Determine the default fee category from either (in order
      -- of priority) the acaiv detail or the admission category mapping.
      IF v_acaiv_rec.fee_cat IS NOT NULL THEN
        v_fee_cat := v_acaiv_rec.fee_cat;
      ELSE
        v_fee_cat := IGS_AD_GEN_005.ADMP_GET_DFLT_FCM(
              v_acaiv_rec.admission_cat,
              v_description);
      END IF;

      -- Determine the default correspondence category from either
      -- (in order of priority) the acaiv detail or the admission category mapping.
      IF v_acaiv_rec.correspondence_cat IS NOT NULL THEN
        v_correspondence_cat := v_acaiv_rec.correspondence_cat;
      ELSE
        v_correspondence_cat := IGS_AD_GEN_005.ADMP_GET_DFLT_CCM(
              v_acaiv_rec.admission_cat,
              v_description);
      END IF;

      -- Create IGS_EN_STDNT_PS_ATT record matching offer
      OPEN c_sca;
      FETCH c_sca INTO v_sca_rec;
      IF c_sca%NOTFOUND THEN
        CLOSE c_sca;
        IF p_dflt_confirmed_course_ind = 'N' THEN
          v_confirmed_ind := 'N';
          v_course_attempt_status := cst_unconfirm;
          v_commencement_dt := NULL;
        ELSE
          -- If the IGS_PS_COURSE attempt is the result of a transfer then it cannot
          -- be confirmed through pre-enrolment.
          IF IGS_EN_VAL_SCA.enrp_val_trnsfr_acpt(
                  p_person_id,
                  p_course_cd,
                  'Y',
                  v_acaiv_rec.admission_appl_number,
                  v_acaiv_rec.nominated_course_cd,
                  v_acaiv_rec.adm_offer_resp_status,
                  v_message_name) = TRUE THEN

                    v_confirmed_ind := 'Y';
                    v_course_attempt_status := cst_inactive;
                    v_commencement_dt := IGS_EN_GEN_002.ENRP_GET_ACAD_COMM(
                    p_acad_cal_type,
                    p_acad_sequence_number,
                    p_person_id,
                    p_course_cd,
                    v_acaiv_rec.admission_appl_number,
                    v_acaiv_rec.nominated_course_cd,
                    v_acaiv_rec.sequence_number,
                    'Y'); -- Check for proposed commencement date.
          ELSE

            v_confirmed_ind := 'N';
            v_course_attempt_status := cst_unconfirm;
            v_commencement_dt := NULL;
          END IF;
        END IF;

        DECLARE
          l_rowid VARCHAR2(25);
          l_org_id NUMBER := igs_ge_gen_003.get_org_id;
          BEGIN

         --set the catalog details only if SPA is confirmed.
             IF nvl(v_confirmed_ind,'N') = 'Y' THEN
                OPEN cur_catalog_details(v_commencement_dt,v_acaiv_rec.acad_cal_type);
                FETCH cur_catalog_details into catalog_cal_type, catalog_seq_num;
                CLOSE cur_catalog_details;
             END IF;

              IGS_EN_STDNT_PS_ATT_PKG.INSERT_ROW(
                x_rowid => l_rowid,
                x_person_id => p_person_id,
                x_course_cd => p_course_cd,
                x_version_number => v_acaiv_rec.crv_version_number,
                x_cal_type => v_acaiv_rec.acad_cal_type,
                x_location_cd => v_acaiv_rec.location_cd,
                x_attendance_mode => v_acaiv_rec.attendance_mode,
                x_attendance_type =>v_acaiv_rec.attendance_type ,
                x_coo_id => NULL,
                x_student_confirmed_ind => v_confirmed_ind,
                x_commencement_dt => v_commencement_dt,
                x_course_attempt_status => v_course_attempt_status,
                x_derived_att_type => NULL,
                x_derived_att_mode => NULL,
                x_provisional_ind => v_provisional_ind,
                x_discontinued_dt => NULL,
                x_discontinuation_reason_cd => NULL,
                x_lapsed_dt => NULL,
                x_funding_source => v_funding_source,
                x_exam_location_cd => NULL,
                x_derived_completion_yr => NULL,
                x_derived_completion_perd  => NULL,
                x_nominated_completion_yr => NULL,
                x_nominated_completion_perd  => NULL,
                x_rule_check_ind  => NULL,
                x_waive_option_check_ind  =>NULL,
                x_last_rule_check_dt => NULL,
                x_publish_outcomes_ind => NULL,
                x_course_rqrmnt_complete_ind => NULL,
                x_override_time_limitation => NULL,
                x_course_rqrmnts_complete_dt => NULL,
                x_advanced_standing_ind => NULL,
                x_fee_cat => v_fee_cat,
                x_correspondence_cat => v_correspondence_cat,
                x_self_help_group_ind => NULL,
                x_logical_delete_dt => NULL,
                x_adm_admission_appl_number => v_acaiv_rec.admission_appl_number,
                x_adm_nominated_course_cd => v_acaiv_rec.nominated_course_cd,
                x_adm_sequence_number =>v_acaiv_rec.sequence_number,
                x_mode => 'R',
                x_progression_status => NULL,
                X_S_COMPLETED_SOURCE_TYPE => 'MANUAL',
                x_org_id => l_org_id,
                x_last_date_of_attendance => NULL,
                x_dropped_by    => NULL,
                X_IGS_PR_CLASS_STD_ID => NULL,
                x_primary_program_type     => NULL,
                x_primary_prog_type_source => NULL,
                x_catalog_cal_type         => catalog_cal_type,
                x_catalog_seq_num          => catalog_seq_num,
                x_key_program              => NULL ,
                x_override_cmpl_dt  => NULL,
                x_manual_ovr_cmpl_dt_ind  => NULL,
                -- added by ckasu as aprt of bug # 3544927
                X_ATTRIBUTE_CATEGORY                => NULL,
                X_ATTRIBUTE1                        => NULL,
                X_ATTRIBUTE2                        => NULL,
                X_ATTRIBUTE3                        => NULL,
                X_ATTRIBUTE4                        => NULL,
                X_ATTRIBUTE5                        => NULL,
                X_ATTRIBUTE6                        => NULL,
                X_ATTRIBUTE7                        => NULL,
                X_ATTRIBUTE8                        => NULL,
                X_ATTRIBUTE9                        => NULL,
                X_ATTRIBUTE10                       => NULL,
                X_ATTRIBUTE11                       => NULL,
                X_ATTRIBUTE12                       => NULL,
                X_ATTRIBUTE13                       => NULL,
                X_ATTRIBUTE14                       => NULL,
                X_ATTRIBUTE15                       => NULL,
                X_ATTRIBUTE16                       => NULL,
                X_ATTRIBUTE17                       => NULL,
                X_ATTRIBUTE18                       => NULL,
                X_ATTRIBUTE19                       => NULL,
                X_ATTRIBUTE20                       => NULL,
    X_FUTURE_DATED_TRANS_FLAG           => 'N');

		--bmerugu added for build 319
		v_rowid := l_rowid;

		-- smaddali added this code for bug#235069
                 --creating the UK statistics hesa record
                IF fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' THEN
                         l_message_name := NULL;
                         l_status   := NULL;
                         IGS_EN_HESA_PKG.HESA_STATS_ENR(
                                p_person_id             =>  p_person_id,
                                p_course_cd             =>  p_course_cd,
                                p_crv_version_number    =>  v_acaiv_rec.crv_version_number,
                                p_message               =>  l_message_name,
                                p_status                =>  l_status);

                         IF NVL(l_Status,0) = 2 THEN
                              -- ie. The procedure call has resulted in error.
                                 Fnd_Message.Set_Name('IGS', l_message_name);
                                 IGS_GE_MSG_STACK.ADD;
                                 App_Exception.Raise_Exception;
                         END IF;

                 END IF;
                 -- end smaddali

              END;
        l_confirmed_ind  := v_confirmed_ind ;
        v_sca_commencement_dt := v_commencement_dt;
        -- Perform <Update IGS_RE_CANDIDATURE Key Detail>
        IF NOT enrpl_upd_candidature(
            p_warn_level,
            p_message_name) THEN
          RETURN;
        END IF;
      ELSE  -- c_sca%FOUND
        CLOSE c_sca;
        l_confirmed_ind  := v_sca_rec.student_confirmed_ind ;
        v_attendance_mode := v_sca_rec.attendance_mode;
        v_sca_commencement_dt := v_sca_rec.commencement_dt;
        -- Update the SCA details.
        -- IGS_GE_NOTE, the logical delete dt, discontinuation reason code and date
        -- are NULL?d to be sure that the student will revert back to the
        -- appropriate status.
        IF v_sca_rec.course_attempt_status IN (cst_unconfirm,
                  cst_deleted) AND
            (v_sca_rec.course_attempt_status = cst_deleted OR
            v_sca_rec.location_cd <> v_acaiv_rec.location_cd OR
            v_sca_rec.attendance_mode <> v_acaiv_rec.attendance_mode OR
            v_sca_rec.attendance_type <> v_acaiv_rec.attendance_type OR
            NVL(v_sca_rec.funding_source,'NULL') <> NVL(v_funding_source,'NULL') OR
            v_sca_rec.provisional_ind <> v_provisional_ind OR
            NVL(v_sca_rec.fee_cat,'NULL') <> NVL(v_fee_cat,'NULL') OR
            NVL(v_sca_rec.correspondence_cat,'NULL') <>
                     NVL(v_correspondence_cat,'NULL') OR
            NVL(v_sca_rec.nominated_completion_yr,9999) <>
                     NVL(v_acaiv_rec.expected_completion_yr,9999) OR
            NVL(v_sca_rec.nominated_completion_perd,'X') <>
                    NVL(v_acaiv_rec.expected_completion_perd,'X') OR
            NVL(v_sca_rec.adm_admission_appl_number,9999) <>
                    v_acaiv_rec.admission_appl_number OR
            NVL(v_sca_rec.adm_nominated_course_cd,'NULL') <>
                    v_acaiv_rec.nominated_course_cd OR
            NVL(v_sca_rec.adm_sequence_number,9999999) <>
                    v_acaiv_rec.sequence_number OR
            (v_sca_rec.course_attempt_status = cst_unconfirm AND
             p_dflt_confirmed_course_ind = 'Y')) THEN
           BEGIN
              OPEN c_sca_upd;
              FETCH c_sca_upd INTO v_sca_upd_rec;
              IF p_dflt_confirmed_course_ind = 'Y' AND
                 v_sca_rec.course_attempt_status = cst_unconfirm THEN
                -- If the IGS_PS_COURSE attempt is the result of a transfer then it cannot
                -- be confirmed through pre-enrolment.
                IF IGS_EN_VAL_SCA.enrp_val_trnsfr_acpt(
                        p_person_id,
                        p_course_cd,
                        'Y',
                        v_acaiv_rec.admission_appl_number,
                        v_acaiv_rec.nominated_course_cd,
                        v_acaiv_rec.adm_offer_resp_status,
                        v_message_name) = TRUE THEN

                        v_confirmed_ind := 'Y';
                        v_commencement_dt := IGS_EN_GEN_002.ENRP_GET_ACAD_COMM(
                        p_acad_cal_type,
                        p_acad_sequence_number,
                        p_person_id,
                        p_course_cd,
                        v_acaiv_rec.admission_appl_number,
                        v_acaiv_rec.nominated_course_cd,
                        v_acaiv_rec.sequence_number,
                        'Y'); -- Check for proposed commencement date.
                ELSE
                  v_confirmed_ind := v_sca_rec.student_confirmed_ind;
                  v_commencement_dt := v_sca_rec.commencement_dt;
                END IF;
              ELSE
                v_confirmed_ind := v_sca_rec.student_confirmed_ind;
                v_commencement_dt := v_sca_rec.commencement_dt;
              END IF;

              --set the catalog details only if SPA is confirmed.
              -- this part of the code executes when the student accepts the application offer
              --if the pre-enrolment step is not setup on offer .
           catalog_cal_type := NULL;
           catalog_seq_num := NULL;

           IF nvl(v_confirmed_ind,'N') = 'Y' THEN
                OPEN cur_catalog_details(v_commencement_dt,v_sca_upd_rec.cal_type);
                FETCH cur_catalog_details into catalog_cal_type, catalog_seq_num;
                CLOSE cur_catalog_details;
           END IF;

              IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                   X_ROWID => v_sca_upd_rec.rowid,
                   X_PERSON_ID  => v_sca_upd_rec.PERSON_ID,
                   X_COURSE_CD => v_sca_upd_rec.COURSE_CD,
                   X_ADVANCED_STANDING_IND => v_sca_upd_rec.ADVANCED_STANDING_IND,
                   X_FEE_CAT => v_fee_cat,
                   X_CORRESPONDENCE_CAT => v_correspondence_cat,
                   X_SELF_HELP_GROUP_IND => v_sca_upd_rec.SELF_HELP_GROUP_IND,
                   X_LOGICAL_DELETE_DT  => NULL,
                   X_ADM_ADMISSION_APPL_NUMBER  => v_acaiv_rec.admission_appl_number,
                   X_ADM_NOMINATED_COURSE_CD => v_acaiv_rec.nominated_course_cd,
                   X_ADM_SEQUENCE_NUMBER  => v_acaiv_rec.sequence_number,
                   X_VERSION_NUMBER  => v_sca_upd_rec.version_number,
                   X_CAL_TYPE => v_sca_upd_rec.cal_type,
                   X_LOCATION_CD => v_acaiv_rec.location_cd,
                   X_ATTENDANCE_MODE => v_acaiv_rec.attendance_mode,
                   X_ATTENDANCE_TYPE => v_acaiv_rec.attendance_type,
                   X_COO_ID  => v_sca_upd_rec.coo_id,
                   X_STUDENT_CONFIRMED_IND => v_confirmed_ind,
                   X_COMMENCEMENT_DT  =>  v_commencement_dt,
                   X_COURSE_ATTEMPT_STATUS => cst_unconfirm,
                   X_PROGRESSION_STATUS => v_sca_upd_rec.PROGRESSION_STATUS,
                   X_DERIVED_ATT_TYPE => v_sca_upd_rec.DERIVED_ATT_TYPE,
                   X_DERIVED_ATT_MODE => v_sca_upd_rec.DERIVED_ATT_MODE,
                   X_PROVISIONAL_IND => v_provisional_ind,
                   X_DISCONTINUED_DT  => NULL,
                   X_DISCONTINUATION_REASON_CD => NULL,
                   X_LAPSED_DT  => v_sca_upd_rec.LAPSED_DT,
                   X_FUNDING_SOURCE => v_funding_source,
                   X_EXAM_LOCATION_CD => v_sca_upd_rec.EXAM_LOCATION_CD,
                   X_DERIVED_COMPLETION_YR  => v_sca_upd_rec.DERIVED_COMPLETION_YR,
                   X_DERIVED_COMPLETION_PERD => v_sca_upd_rec.DERIVED_COMPLETION_PERD,
                   X_NOMINATED_COMPLETION_YR  => v_sca_upd_rec.nominated_completion_yr,
                   X_NOMINATED_COMPLETION_PERD => v_sca_upd_rec.nominated_completion_perd,
                   X_RULE_CHECK_IND => v_sca_upd_rec.RULE_CHECK_IND,
                   X_WAIVE_OPTION_CHECK_IND => v_sca_upd_rec.WAIVE_OPTION_CHECK_IND,
                   X_LAST_RULE_CHECK_DT  => v_sca_upd_rec.LAST_RULE_CHECK_DT,
                   X_PUBLISH_OUTCOMES_IND => v_sca_upd_rec.PUBLISH_OUTCOMES_IND,
                   X_COURSE_RQRMNT_COMPLETE_IND => v_sca_upd_rec.COURSE_RQRMNT_COMPLETE_IND,
                   X_COURSE_RQRMNTS_COMPLETE_DT  => v_sca_upd_rec.COURSE_RQRMNTS_COMPLETE_DT,
                   X_S_COMPLETED_SOURCE_TYPE => v_sca_upd_rec.S_COMPLETED_SOURCE_TYPE,
                   X_OVERRIDE_TIME_LIMITATION  => v_sca_upd_rec.OVERRIDE_TIME_LIMITATION,
                   X_MODE =>  'R',
                   x_last_date_of_attendance => v_sca_upd_rec.last_date_of_attendance,
                   x_dropped_by     => v_sca_upd_rec.dropped_by,
                   X_IGS_PR_CLASS_STD_ID => v_sca_upd_rec.igs_pr_class_std_id,
                   x_primary_program_type      => v_sca_upd_rec.primary_program_type,
                   x_primary_prog_type_source  => v_sca_upd_rec.primary_prog_type_source,
                   x_catalog_cal_type          => catalog_cal_type,
                   x_catalog_seq_num           => catalog_seq_num,
                   x_key_program               => v_sca_upd_rec.key_program,
                   x_override_cmpl_dt  => v_sca_upd_rec.override_cmpl_dt,
                   x_manual_ovr_cmpl_dt_ind  =>  v_sca_upd_rec.manual_ovr_cmpl_dt_ind,
        -- added by ckasu as aprt of bug # 3544927
                   X_ATTRIBUTE_CATEGORY                => v_sca_upd_rec.ATTRIBUTE_CATEGORY,
                   X_ATTRIBUTE1                        => v_sca_upd_rec.ATTRIBUTE1,
                   X_ATTRIBUTE2                        => v_sca_upd_rec.ATTRIBUTE2,
                   X_ATTRIBUTE3                        => v_sca_upd_rec.ATTRIBUTE3,
                   X_ATTRIBUTE4                        => v_sca_upd_rec.ATTRIBUTE4,
                   X_ATTRIBUTE5                        => v_sca_upd_rec.ATTRIBUTE5,
                   X_ATTRIBUTE6                        => v_sca_upd_rec.ATTRIBUTE6,
                   X_ATTRIBUTE7                        => v_sca_upd_rec.ATTRIBUTE7,
                   X_ATTRIBUTE8                        => v_sca_upd_rec.ATTRIBUTE8,
                   X_ATTRIBUTE9                        => v_sca_upd_rec.ATTRIBUTE9,
                   X_ATTRIBUTE10                       => v_sca_upd_rec.ATTRIBUTE10,
                   X_ATTRIBUTE11                       => v_sca_upd_rec.ATTRIBUTE11,
                   X_ATTRIBUTE12                       => v_sca_upd_rec.ATTRIBUTE12,
                   X_ATTRIBUTE13                       => v_sca_upd_rec.ATTRIBUTE13,
                   X_ATTRIBUTE14                       => v_sca_upd_rec.ATTRIBUTE14,
                   X_ATTRIBUTE15                       => v_sca_upd_rec.ATTRIBUTE15,
                   X_ATTRIBUTE16                       => v_sca_upd_rec.ATTRIBUTE16,
                   X_ATTRIBUTE17                       => v_sca_upd_rec.ATTRIBUTE17,
                   X_ATTRIBUTE18                       => v_sca_upd_rec.ATTRIBUTE18,
                   X_ATTRIBUTE19                       => v_sca_upd_rec.ATTRIBUTE19,
                   X_ATTRIBUTE20                       => v_sca_upd_rec.ATTRIBUTE20,
       X_FUTURE_DATED_TRANS_FLAG           => v_sca_upd_rec.FUTURE_DATED_TRANS_FLAG);

	      --bmerugu added for build 319
	      v_rowid :=	v_sca_upd_rec.rowid;

	      CLOSE c_sca_upd;
              l_confirmed_ind  := v_confirmed_ind ;
              v_sca_commencement_dt := v_commencement_dt;
              -- Perform <Update IGS_RE_CANDIDATURE Key Detail>
              IF NOT enrpl_upd_candidature(
                p_warn_level,
                p_message_name) THEN
                RETURN;
              END IF;
        EXCEPTION
          WHEN e_resource_busy THEN
            IF c_sca_upd%ISOPEN THEN
              CLOSE c_sca_upd;
            END IF;
            IF c_sca%ISOPEN THEN
              CLOSE c_sca;
            END IF;
            IF c_crv%ISOPEN THEN
              CLOSE c_crv;
            END IF;
            p_message_name := 'IGS_EN_STUD_PRG_REC_LOCKED';
            p_warn_level := cst_error;
            RETURN;
          WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
            IF c_sca_upd%ISOPEN THEN
              CLOSE c_sca_upd;
            END IF;
            IF c_sca%ISOPEN THEN
              CLOSE c_sca;
            END IF;
            IF c_crv%ISOPEN THEN
              CLOSE c_crv;
            END IF;
            IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_create_sca.APP_EXP1','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
            END IF;
            RAISE;
          WHEN OTHERS THEN
            IF c_sca_upd%ISOPEN THEN
              CLOSE c_sca_upd;
            END IF;
            IF c_sca%ISOPEN THEN
              CLOSE c_sca;
            END IF;
            IF c_crv%ISOPEN THEN
              CLOSE c_crv;
            END IF;
            /* commented for Bug 1510921
              Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_create_sca1');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
            */
            IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_create_sca.UNH_EXP1','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
            END IF;
            RAISE;
          END;
        ELSIF v_sca_rec.course_attempt_status = cst_discontin THEN
          -- Check if the IGS_PE_PERSON has been made an offer after
          -- they were discontinued.
          IF v_acaiv_rec.offer_dt >= v_sca_rec.discontinued_dt THEN
            BEGIN
            -- Lift the discontinuation and update details of the IGS_PS_COURSE
            -- attempt according to the new offer.
            OPEN c_sca_upd;
            FETCH c_sca_upd INTO v_sca_upd_rec;

                           IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                                                 X_ROWID => v_sca_upd_rec.rowid,
                                                 X_PERSON_ID  => v_sca_upd_rec.PERSON_ID,
                                                 X_COURSE_CD => v_sca_upd_rec.COURSE_CD,
                                                 X_ADVANCED_STANDING_IND => v_sca_upd_rec.ADVANCED_STANDING_IND,
                                                 X_FEE_CAT => v_fee_cat,
                                                 X_CORRESPONDENCE_CAT => v_correspondence_cat,
                                                 X_SELF_HELP_GROUP_IND => v_sca_upd_rec.SELF_HELP_GROUP_IND,
                                                 X_LOGICAL_DELETE_DT  => v_sca_upd_rec.LOGICAL_DELETE_DT,
                                                 X_ADM_ADMISSION_APPL_NUMBER  => v_acaiv_rec.admission_appl_number,
                                                 X_ADM_NOMINATED_COURSE_CD => v_acaiv_rec.nominated_course_cd,
                                                 X_ADM_SEQUENCE_NUMBER  => v_acaiv_rec.sequence_number,
                                                 X_VERSION_NUMBER  => v_sca_upd_rec.version_number,
                                                 X_CAL_TYPE => v_sca_upd_rec.cal_type,
                                                 X_LOCATION_CD => v_acaiv_rec.location_cd,
                                                 X_ATTENDANCE_MODE => v_acaiv_rec.attendance_mode,
                                                 X_ATTENDANCE_TYPE => v_acaiv_rec.attendance_type,
                                                 X_COO_ID  => v_sca_upd_rec.coo_id,
                                                 X_STUDENT_CONFIRMED_IND => v_sca_upd_rec.STUDENT_confirmed_ind,
                                                 X_COMMENCEMENT_DT  =>  v_sca_upd_rec.commencement_dt,
                                                 X_COURSE_ATTEMPT_STATUS => v_sca_upd_rec.COURSE_ATTEMPT_STATUS,
                                                 X_PROGRESSION_STATUS => v_sca_upd_rec.PROGRESSION_STATUS,
                                                 X_DERIVED_ATT_TYPE => v_sca_upd_rec.DERIVED_ATT_TYPE,
                                                 X_DERIVED_ATT_MODE => v_sca_upd_rec.DERIVED_ATT_MODE,
                                                 X_PROVISIONAL_IND => v_provisional_ind,
                                                 X_DISCONTINUED_DT  => NULL,
                                                 X_DISCONTINUATION_REASON_CD => NULL,
                                                 X_LAPSED_DT  => NULL,
                                                 X_FUNDING_SOURCE => v_funding_source,
                                                 X_EXAM_LOCATION_CD => v_sca_upd_rec.EXAM_LOCATION_CD,
                                                 X_DERIVED_COMPLETION_YR  => v_sca_upd_rec.DERIVED_COMPLETION_YR,
                                                 X_DERIVED_COMPLETION_PERD => v_sca_upd_rec.DERIVED_COMPLETION_PERD,
                                                 X_NOMINATED_COMPLETION_YR  => v_sca_upd_rec.nominated_completion_yr,
                                                 X_NOMINATED_COMPLETION_PERD => v_sca_upd_rec.nominated_completion_perd,
                                                 X_RULE_CHECK_IND => v_sca_upd_rec.RULE_CHECK_IND,
                                                 X_WAIVE_OPTION_CHECK_IND => v_sca_upd_rec.WAIVE_OPTION_CHECK_IND,
                                                 X_LAST_RULE_CHECK_DT  => v_sca_upd_rec.LAST_RULE_CHECK_DT,
                                                 X_PUBLISH_OUTCOMES_IND => v_sca_upd_rec.PUBLISH_OUTCOMES_IND,
                                                 X_COURSE_RQRMNT_COMPLETE_IND => v_sca_upd_rec.COURSE_RQRMNT_COMPLETE_IND,
                                                 X_COURSE_RQRMNTS_COMPLETE_DT  => v_sca_upd_rec.COURSE_RQRMNTS_COMPLETE_DT,
                                                 X_S_COMPLETED_SOURCE_TYPE => v_sca_upd_rec.S_COMPLETED_SOURCE_TYPE,
                                                 X_OVERRIDE_TIME_LIMITATION  => v_sca_upd_rec.OVERRIDE_TIME_LIMITATION,
                                                 X_MODE =>  'R',
                                                 x_last_date_of_attendance => v_sca_upd_rec.last_date_of_attendance,
                                                 x_dropped_by     => v_sca_upd_rec.dropped_by,
                                                 X_IGS_PR_CLASS_STD_ID => v_sca_upd_rec.igs_pr_class_std_id,
                                                 x_primary_program_type      => v_sca_upd_rec.primary_program_type,
                                                 x_primary_prog_type_source  => v_sca_upd_rec.primary_prog_type_source,
                                                 x_catalog_cal_type          => v_sca_upd_rec.catalog_cal_type,
                                                 x_catalog_seq_num           => v_sca_upd_rec.catalog_seq_num,
                                                 x_key_program               => v_sca_upd_rec.key_program,
                                                 x_override_cmpl_dt  => v_sca_upd_rec.override_cmpl_dt,
                                                 x_manual_ovr_cmpl_dt_ind  =>  v_sca_upd_rec.manual_ovr_cmpl_dt_ind,
                                              -- added by ckasu as aprt of bug # 3544927
                                                 X_ATTRIBUTE_CATEGORY                => v_sca_upd_rec.ATTRIBUTE_CATEGORY,
                                                 X_ATTRIBUTE1                        => v_sca_upd_rec.ATTRIBUTE1,
                                                 X_ATTRIBUTE2                        => v_sca_upd_rec.ATTRIBUTE2,
                                                 X_ATTRIBUTE3                        => v_sca_upd_rec.ATTRIBUTE3,
                                                 X_ATTRIBUTE4                        => v_sca_upd_rec.ATTRIBUTE4,
                                                 X_ATTRIBUTE5                        => v_sca_upd_rec.ATTRIBUTE5,
                                                 X_ATTRIBUTE6                        => v_sca_upd_rec.ATTRIBUTE6,
                                                 X_ATTRIBUTE7                        => v_sca_upd_rec.ATTRIBUTE7,
                                                 X_ATTRIBUTE8                        => v_sca_upd_rec.ATTRIBUTE8,
                                                 X_ATTRIBUTE9                        => v_sca_upd_rec.ATTRIBUTE9,
                                                 X_ATTRIBUTE10                       => v_sca_upd_rec.ATTRIBUTE10,
                                                 X_ATTRIBUTE11                       => v_sca_upd_rec.ATTRIBUTE11,
                                                 X_ATTRIBUTE12                       => v_sca_upd_rec.ATTRIBUTE12,
                                                 X_ATTRIBUTE13                       => v_sca_upd_rec.ATTRIBUTE13,
                                                 X_ATTRIBUTE14                       => v_sca_upd_rec.ATTRIBUTE14,
                                                 X_ATTRIBUTE15                       => v_sca_upd_rec.ATTRIBUTE15,
                                                 X_ATTRIBUTE16                       => v_sca_upd_rec.ATTRIBUTE16,
                                                 X_ATTRIBUTE17                       => v_sca_upd_rec.ATTRIBUTE17,
                                                 X_ATTRIBUTE18                       => v_sca_upd_rec.ATTRIBUTE18,
                                                 X_ATTRIBUTE19                       => v_sca_upd_rec.ATTRIBUTE19,
                                                 X_ATTRIBUTE20                       => v_sca_upd_rec.ATTRIBUTE20,
             X_FUTURE_DATED_TRANS_FLAG           => v_sca_upd_rec.FUTURE_DATED_TRANS_FLAG);

		--bmerugu added for build 319
		v_rowid := v_sca_upd_rec.rowid;

		    CLOSE c_sca_upd;
                 -- Perform <Update IGS_RE_CANDIDATURE Key Detail>
                 IF NOT enrpl_upd_candidature(
                    p_warn_level,
                    p_message_name) THEN
                   RETURN;
                 END IF;
              EXCEPTION
                WHEN e_resource_busy THEN
                  IF c_sca_upd%ISOPEN THEN
                    CLOSE c_sca_upd;
                  END IF;
                  IF c_sca%ISOPEN THEN
                    CLOSE c_sca;
                  END IF;
                  IF c_crv%ISOPEN THEN
                    CLOSE c_crv;
                  END IF;
                  p_message_name := 'IGS_EN_STUD_PRG_REC_LOCKED';
                  p_warn_level := cst_error;
                  RETURN;
                WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
                  IF c_sca_upd%ISOPEN THEN
                    CLOSE c_sca_upd;
                  END IF;
                  IF c_sca%ISOPEN THEN
                    CLOSE c_sca;
                  END IF;
                  IF c_crv%ISOPEN THEN
                    CLOSE c_crv;
                  END IF;
                  IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_create_sca.APP_EXP2','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
                  END IF;
                  RAISE;
                WHEN OTHERS THEN
                  IF c_sca_upd%ISOPEN THEN
                    CLOSE c_sca_upd;
                  END IF;
                  IF c_sca%ISOPEN THEN
                    CLOSE c_sca;
                  END IF;
                  IF c_crv%ISOPEN THEN
                    CLOSE c_crv;
                  END IF;
                  IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_create_sca.UNH_EXP2','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
                  END IF;
                  RAISE;
                END;
            ELSE
              -- IGS_PE_PERSON does not have a current admission offer.
              IF p_log_creation_dt IS NOT NULL THEN
                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                    cst_pre_enrol,
                    p_log_creation_dt,
                    cst_error || ',' ||
                      TO_CHAR(p_person_id) || ',' ||
                       p_course_cd,
                    'IGS_EN_DISCONT_NOTLIFT',
                    NULL);
              END IF;
              p_message_name := 'IGS_EN_DISCONT_NOTLIFT';
              p_warn_level := cst_error;
              RETURN;
            END IF;
          ELSIF (v_sca_rec.course_attempt_status = cst_lapsed AND
              v_acaiv_rec.s_adm_offer_resp_status <> cst_accepted) OR
              v_sca_rec.course_attempt_status = cst_inactive THEN
            BEGIN
              OPEN c_sca_upd;
              FETCH c_sca_upd INTO v_sca_upd_rec;

                    IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                             X_ROWID => v_sca_upd_rec.rowid,
                             X_PERSON_ID  => v_sca_upd_rec.PERSON_ID,
                             X_COURSE_CD => v_sca_upd_rec.COURSE_CD,
                             X_ADVANCED_STANDING_IND => v_sca_upd_rec.ADVANCED_STANDING_IND,
                             X_FEE_CAT => v_fee_cat,
                             X_CORRESPONDENCE_CAT => v_correspondence_cat,
                             X_SELF_HELP_GROUP_IND => v_sca_upd_rec.SELF_HELP_GROUP_IND,
                             X_LOGICAL_DELETE_DT  => v_sca_upd_rec.LOGICAL_DELETE_DT,
                             X_ADM_ADMISSION_APPL_NUMBER  => v_acaiv_rec.admission_appl_number,
                             X_ADM_NOMINATED_COURSE_CD => v_acaiv_rec.nominated_course_cd,
                             X_ADM_SEQUENCE_NUMBER  => v_acaiv_rec.sequence_number,
                             X_VERSION_NUMBER  => v_sca_upd_rec.version_number,
                             X_CAL_TYPE => v_sca_upd_rec.cal_type,
                             X_LOCATION_CD => v_acaiv_rec.location_cd,
                             X_ATTENDANCE_MODE => v_acaiv_rec.attendance_mode,
                             X_ATTENDANCE_TYPE => v_acaiv_rec.attendance_type,
                             X_COO_ID  => v_sca_upd_rec.coo_id,
                             X_STUDENT_CONFIRMED_IND => v_sca_upd_rec.STUDENT_confirmed_ind,
                             X_COMMENCEMENT_DT  =>  v_sca_upd_rec.commencement_dt,
                             X_COURSE_ATTEMPT_STATUS => v_sca_upd_rec.COURSE_ATTEMPT_STATUS,
                             X_PROGRESSION_STATUS => v_sca_upd_rec.PROGRESSION_STATUS,
                             X_DERIVED_ATT_TYPE => v_sca_upd_rec.DERIVED_ATT_TYPE,
                             X_DERIVED_ATT_MODE => v_sca_upd_rec.DERIVED_ATT_MODE,
                             X_PROVISIONAL_IND => v_provisional_ind,
                             X_DISCONTINUED_DT  => v_sca_upd_rec.DISCONTINUED_DT,
                             X_DISCONTINUATION_REASON_CD => v_sca_upd_rec.DISCONTINUATION_REASON_CD ,
                             X_LAPSED_DT  => NULL,
                             X_FUNDING_SOURCE => v_funding_source,
                             X_EXAM_LOCATION_CD => v_sca_upd_rec.EXAM_LOCATION_CD,
                             X_DERIVED_COMPLETION_YR  => v_sca_upd_rec.DERIVED_COMPLETION_YR,
                             X_DERIVED_COMPLETION_PERD => v_sca_upd_rec.DERIVED_COMPLETION_PERD,
                             X_NOMINATED_COMPLETION_YR  => v_sca_upd_rec.nominated_completion_yr,
                             X_NOMINATED_COMPLETION_PERD => v_sca_upd_rec.nominated_completion_perd,
                             X_RULE_CHECK_IND => v_sca_upd_rec.RULE_CHECK_IND,
                             X_WAIVE_OPTION_CHECK_IND => v_sca_upd_rec.WAIVE_OPTION_CHECK_IND,
                             X_LAST_RULE_CHECK_DT  => v_sca_upd_rec.LAST_RULE_CHECK_DT,
                             X_PUBLISH_OUTCOMES_IND => v_sca_upd_rec.PUBLISH_OUTCOMES_IND,
                             X_COURSE_RQRMNT_COMPLETE_IND => v_sca_upd_rec.COURSE_RQRMNT_COMPLETE_IND,
                             X_COURSE_RQRMNTS_COMPLETE_DT  => v_sca_upd_rec.COURSE_RQRMNTS_COMPLETE_DT,
                             X_S_COMPLETED_SOURCE_TYPE => v_sca_upd_rec.S_COMPLETED_SOURCE_TYPE,
                             X_OVERRIDE_TIME_LIMITATION  => v_sca_upd_rec.OVERRIDE_TIME_LIMITATION,
                             X_MODE =>  'R',
                             x_last_date_of_attendance => v_sca_upd_rec.last_date_of_attendance,
                             x_dropped_by     => v_sca_upd_rec.dropped_by,
                             X_IGS_PR_CLASS_STD_ID => v_sca_upd_rec.igs_pr_class_std_id,
                             x_primary_program_type      => v_sca_upd_rec.primary_program_type,
                             x_primary_prog_type_source  => v_sca_upd_rec.primary_prog_type_source,
                             x_catalog_cal_type          => v_sca_upd_rec.catalog_cal_type,
                             x_catalog_seq_num           => v_sca_upd_rec.catalog_seq_num,
                             x_key_program               => v_sca_upd_rec.key_program,
                             x_override_cmpl_dt  => v_sca_upd_rec.override_cmpl_dt,
                             x_manual_ovr_cmpl_dt_ind  =>  v_sca_upd_rec.manual_ovr_cmpl_dt_ind,
                        -- added by ckasu as aprt of bug # 3544927
                             X_ATTRIBUTE_CATEGORY                => v_sca_upd_rec.ATTRIBUTE_CATEGORY,
                             X_ATTRIBUTE1                        => v_sca_upd_rec.ATTRIBUTE1,
                             X_ATTRIBUTE2                        => v_sca_upd_rec.ATTRIBUTE2,
                             X_ATTRIBUTE3                        => v_sca_upd_rec.ATTRIBUTE3,
                             X_ATTRIBUTE4                        => v_sca_upd_rec.ATTRIBUTE4,
                             X_ATTRIBUTE5                        => v_sca_upd_rec.ATTRIBUTE5,
                             X_ATTRIBUTE6                        => v_sca_upd_rec.ATTRIBUTE6,
                             X_ATTRIBUTE7                        => v_sca_upd_rec.ATTRIBUTE7,
                             X_ATTRIBUTE8                        => v_sca_upd_rec.ATTRIBUTE8,
                             X_ATTRIBUTE9                        => v_sca_upd_rec.ATTRIBUTE9,
                             X_ATTRIBUTE10                       => v_sca_upd_rec.ATTRIBUTE10,
                             X_ATTRIBUTE11                       => v_sca_upd_rec.ATTRIBUTE11,
                             X_ATTRIBUTE12                       => v_sca_upd_rec.ATTRIBUTE12,
                             X_ATTRIBUTE13                       => v_sca_upd_rec.ATTRIBUTE13,
                             X_ATTRIBUTE14                       => v_sca_upd_rec.ATTRIBUTE14,
                             X_ATTRIBUTE15                       => v_sca_upd_rec.ATTRIBUTE15,
                             X_ATTRIBUTE16                       => v_sca_upd_rec.ATTRIBUTE16,
                             X_ATTRIBUTE17                       => v_sca_upd_rec.ATTRIBUTE17,
                             X_ATTRIBUTE18                       => v_sca_upd_rec.ATTRIBUTE18,
                             X_ATTRIBUTE19                       => v_sca_upd_rec.ATTRIBUTE19,
                             X_ATTRIBUTE20                       => v_sca_upd_rec.ATTRIBUTE20,
           X_FUTURE_DATED_TRANS_FLAG           => v_sca_upd_rec.FUTURE_DATED_TRANS_FLAG);

		--bmerugu added for build 319
		v_rowid := v_sca_upd_rec.rowid;

	      CLOSE c_sca_upd;
              -- Perform <Update IGS_RE_CANDIDATURE Key Detail>
              IF NOT enrpl_upd_candidature(
                    p_warn_level,
                    p_message_name) THEN
                RETURN;
              END IF;
          EXCEPTION
            WHEN e_resource_busy THEN
              IF c_sca_upd%ISOPEN THEN
                CLOSE c_sca_upd;
              END IF;
              IF c_sca%ISOPEN THEN
                CLOSE c_sca;
              END IF;
              IF c_crv%ISOPEN THEN
                CLOSE c_crv;
              END IF;
              p_message_name := 'IGS_EN_STUD_PRG_REC_LOCKED';
              p_warn_level := cst_minor;
              RETURN;
           WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
              IF c_sca_upd%ISOPEN THEN
                CLOSE c_sca_upd;
              END IF;
              IF c_sca%ISOPEN THEN
                CLOSE c_sca;
              END IF;
              IF c_crv%ISOPEN THEN
                CLOSE c_crv;
              END IF;
              IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_create_sca.APP_EXP3','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
              END IF;
              RAISE;
           WHEN OTHERS THEN
              IF c_sca_upd%ISOPEN THEN
                CLOSE c_sca_upd;
              END IF;
              IF c_sca%ISOPEN THEN
                CLOSE c_sca;
              END IF;
              IF c_crv%ISOPEN THEN
                CLOSE c_crv;
              END IF;
              IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_create_sca.UNH_EXP3','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
              END IF;
              RAISE;
          END;
        END IF;
      END IF;

      --bmerugu added for build 319
      IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' THEN
	BEGIN
	 OPEN  c_sca_ptype(v_rowid);
         FETCH c_sca_ptype INTO v_program_type;
	 CLOSE c_sca_ptype;

	 IF NVL(v_program_type,'SECONDARY') <> 'PRIMARY' THEN
	    BEGIN

		OPEN  c_sca_ctype(v_rowid);
		FETCH c_sca_ctype INTO v_sca_ctype;
		CLOSE c_sca_ctype;

		OPEN c_sca_primary(v_sca_ctype);
		FETCH c_sca_primary INTO v_sca_primary_exists;
		IF c_sca_primary%FOUND THEN
			l_sua_create := FALSE;
		END IF;
		CLOSE c_sca_primary;
	    END;
	 END IF; -- Secondary program check
	END;
      END IF; -- career mode check

      -- If any other status (COMPLETED,ENROLLED,INTERMIT)
      -- Do nothing - IGS_PS_COURSE attempt should remain as it is
      RETURN;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_sca_upd%ISOPEN THEN
          CLOSE c_sca_upd;
        END IF;
        IF c_sca%ISOPEN THEN
          CLOSE c_sca;
        END IF;
        IF c_crv%ISOPEN THEN
          CLOSE c_crv;
        END IF;
        IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.enrpl_create_sca.UNH_EXP','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
        END IF;
        RAISE;
    END;

    /*EXCEPTION
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_create_sca4');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;    */
    -- The exception part has been commented as a part of bug fix # 1520688 , as
    -- the Raise stmt trasferred control to when others , rather than showing
    -- the correct error message.

  END enrpl_create_sca;

  FUNCTION enrpl_create_scae(
    p_warn_level    OUT NOCOPY   VARCHAR2,
    p_message_name    OUT NOCOPY varchar2 )
  RETURN BOOLEAN
  AS

  BEGIN -- enrpl_create_scae
    -- Create a IGS_AS_SC_ATMPT_ENR record
    DECLARE
      CURSOR c_scae (
        cp_enr_cal_type   IGS_AS_SC_ATMPT_ENR.cal_type%TYPE,
        cp_enr_sequence_number  IGS_AS_SC_ATMPT_ENR.ci_sequence_number%TYPE) IS
        SELECT  enrolment_cat
        FROM  IGS_AS_SC_ATMPT_ENR scae
        WHERE person_id     = p_person_id AND
          course_cd     = p_course_cd AND
          cal_type    = cp_enr_cal_type AND
          ci_sequence_number  = cp_enr_sequence_number;
        v_scae_rec  c_scae%ROWTYPE;

      CURSOR c_scae_upd (
        cp_enr_cal_type   IGS_AS_SC_ATMPT_ENR.cal_type%TYPE,
        cp_enr_sequence_number  IGS_AS_SC_ATMPT_ENR.ci_sequence_number%TYPE) IS
        SELECT  rowid,
                IGS_AS_SC_ATMPT_ENR.*
        FROM  IGS_AS_SC_ATMPT_ENR
        WHERE person_id     = p_person_id AND
          course_cd     = p_course_cd AND
          cal_type    = cp_enr_cal_type AND
          ci_sequence_number  = cp_enr_sequence_number
        FOR UPDATE OF enrolment_cat NOWAIT;

      v_scae_upd_rec    c_scae_upd%ROWTYPE;

      -- output variables
      v_enr_cal_type      IGS_CA_INST.cal_type%TYPE;
      v_enr_sequence_number   IGS_CA_INST.sequence_number%TYPE;
      v_enrolment_cat     IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE;
      v_description   IGS_EN_ENROLMENT_CAT.description%TYPE;
    BEGIN
      p_warn_level := NULL;
      p_message_name := null;

      -- Call routine to determine enrolment period
      IF NOT IGS_EN_GEN_003.ENRP_GET_ENR_CI(
          v_acaiv_rec.adm_cal_type,
          v_acaiv_rec.adm_ci_sequence_number,
          v_enr_cal_type,
          v_enr_sequence_number) THEN
        IF p_log_creation_dt IS NOT NULL THEN
          ROLLBACK TO sp_pre_enrol_student;
          IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
              cst_pre_enrol,
              p_log_creation_dt,
              cst_error || ',' ||
                TO_CHAR(p_person_id) || ',' ||
                 p_course_cd,
              'IGS_EN_UNABLE_DETM_ENR_PERIOD',
              NULL);
        END IF;
        p_warn_level := cst_error;
        p_message_name := 'IGS_EN_UNABLE_DETM_ENR_PERIOD';
        RETURN FALSE;
      END IF;

      -- Determine the enrolment category for the pre-enrolment.
      IF v_acaiv_rec.enrolment_cat IS NOT NULL THEN
        v_enrolment_cat := v_acaiv_rec.enrolment_cat;
      ELSIF p_enrolment_cat IS NOT NULL THEN
        v_enrolment_cat := p_enrolment_cat;
      ELSE
        v_enrolment_cat := IGS_AD_GEN_005.ADMP_GET_DFLT_ECM(
                v_acaiv_rec.admission_cat,
                v_description);
        IF v_enrolment_cat IS NULL THEN
          -- Cannot continue without an enrolment category
          IF p_log_creation_dt IS NOT NULL THEN
            ROLLBACK TO sp_pre_enrol_student;
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                  cst_pre_enrol,
                p_log_creation_dt,
                cst_error || ',' ||
                  TO_CHAR(p_person_id) || ',' ||
                   p_course_cd,
                'IGS_EN_UNABLE_DETM_ENRCAT',
                NULL);
          END IF;
          p_warn_level := cst_error;
          p_message_name := 'IGS_EN_UNABLE_DETM_ENRCAT';
          RETURN FALSE;
        END IF;
      END IF;

      -- Check whether a record already exists.
      OPEN c_scae(
        v_enr_cal_type,
        v_enr_sequence_number);
      FETCH c_scae INTO v_scae_rec;
      IF c_scae%NOTFOUND THEN
        CLOSE c_scae;
        -- Insert student IGS_PS_COURSE attempt enrolment record

         DECLARE
           l_rowid VARCHAR2(25);
           BEGIN
             IGS_AS_SC_ATMPT_ENR_PKG.INSERT_ROW (
                x_rowid => l_rowid,
                x_person_id => p_person_id,
                x_course_cd => p_course_cd,
                x_cal_type => v_enr_cal_type,
                x_ci_sequence_number => v_enr_sequence_number,
                x_enrolment_cat => v_enrolment_cat,
                x_enrolled_dt => NULL,
                x_enr_form_due_dt =>  p_override_enr_form_due_dt,
                x_enr_pckg_prod_dt => p_override_enr_pckg_prod_dt,
                x_enr_form_received_dt => NULL   );
           END;

       ELSE  -- (record exists)
         CLOSE c_scae;
         -- If the enrolment category is not the same,
         -- update to the new default.enrolment category.
         IF v_scae_rec.enrolment_cat <> v_enrolment_cat THEN
           BEGIN
             OPEN c_scae_upd(
               v_enr_cal_type,
               v_enr_sequence_number);
             FETCH c_scae_upd INTO v_scae_upd_rec;

             IGS_AS_SC_ATMPT_ENR_PKG.UPDATE_ROW(
                X_ROWID => v_scae_upd_rec.rowid,
                X_PERSON_ID => v_scae_upd_rec.PERSON_ID,
                X_COURSE_CD => v_scae_upd_rec.COURSE_CD,
                X_CAL_TYPE  => v_scae_upd_rec.CAL_TYPE,
                X_CI_SEQUENCE_NUMBER => v_scae_upd_rec.CI_SEQUENCE_NUMBER,
                X_ENROLMENT_CAT  => v_enrolment_cat,
                X_ENROLLED_DT  => v_scae_upd_rec.ENROLLED_DT,
                X_ENR_FORM_DUE_DT  => v_scae_upd_rec.ENR_FORM_DUE_DT,
                X_ENR_PCKG_PROD_DT  =>  v_scae_upd_rec.ENR_PCKG_PROD_DT ,
                X_ENR_FORM_RECEIVED_DT  => v_scae_upd_rec.ENR_FORM_RECEIVED_DT,
                X_MODE  =>  'R'  );

              CLOSE c_scae_upd;
            EXCEPTION
              WHEN e_resource_busy THEN
                IF c_scae_upd%ISOPEN THEN
                  CLOSE c_scae_upd;
                END IF;
                p_message_name := 'IGS_EN_STUD_PRG_LAPSE_USER';
                p_warn_level := cst_error;
                RETURN FALSE;
              WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
                IF c_scae_upd%ISOPEN THEN
                  CLOSE c_scae_upd;
                END IF;
                RAISE;
              WHEN OTHERS THEN
                IF c_scae_upd%ISOPEN THEN
                  CLOSE c_scae_upd;
                END IF;
                Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_create_scae1');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
              END;
           END IF;
       END IF;
       RETURN TRUE;

     EXCEPTION
       WHEN OTHERS THEN
         IF c_scae%ISOPEN THEN
           CLOSE c_scae;
         END IF;
         IF c_scae_upd%ISOPEN THEN
           CLOSE c_scae_upd;
         END IF;
         RAISE;
       END;
    EXCEPTION
      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
        RAISE;
      WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_create_scae2');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

  END enrpl_create_scae;

  FUNCTION enrpl_copy_adm_unit_sets
  /* HISTORY
     WHO             WHEN              WHAT
     ayedubat        9-MAY-2002       Changed the condition from 'v_spa_rec.commencement_dt < TRUNC(SYSDATE)' to
                                      'v_spa_rec.commencement_dt > TRUNC(SYSDATE)'  and also added the TRUNC to SYDATE
                                     as part of the bug Fix: 2364102
    svanukur         01-jul-2004     setting the selection date of the unit set attempt to SPA commencement date
                                      as part of bug fix 3687470
   */
  RETURN BOOLEAN
  AS

  BEGIN -- enrpl_copy_adm_unit_sets
    -- Create any required IGS_AS_SU_SETATMPT details
  DECLARE
     -- Bug#2347141
     -- This cursor got modified to retrive the all the values of the columns which
     -- helps in case of updation
    CURSOR c_susa IS
      SELECT  susa.*,susa.rowid
      FROM  IGS_AS_SU_SETATMPT susa
      WHERE susa.person_id    = p_person_id AND
        susa.course_cd    = p_course_cd AND
        susa.unit_set_cd  = v_acaiv_rec.unit_set_cd AND
        susa.us_version_number  = v_acaiv_rec.us_version_number AND
        susa.end_dt IS NULL;

    -- Bug#2347141
    -- This cursor got modified to to include one more table IGS_EN_UNIT_SET_CAT
    -- in the from clause to check the System Category.
    CURSOR c_us (cp_unit_set_cd IGS_EN_UNIT_SET.unit_set_cd%TYPE,
        cp_version_number IGS_EN_UNIT_SET.version_number%TYPE) IS
    SELECT  us.authorisation_rqrd_ind,
              usc.s_unit_set_cat
    FROM  IGS_EN_UNIT_SET us,
              IGS_EN_UNIT_SET_CAT usc
    WHERE us.unit_set_cd = cp_unit_set_cd AND
        us.version_number = cp_version_number AND
        usc.unit_set_cat = us.unit_set_cat;

    -- Bug#2347141
    -- The Cursor has been added to check the Student Confirmed indicator is yes
    CURSOR c_spa IS
    SELECT  spa.student_confirmed_ind,
              spa.commencement_dt ,spa.version_number
    FROM    IGS_EN_STDNT_PS_ATT spa
    WHERE   spa.person_id = p_person_id AND
              spa.course_cd = p_course_cd;

    -- Bug#2347141
    -- The variable v_spa_rec is added newly, v_susa_rec modified to cursor Type.
    -- And also the variables v_confirmed_ind, v_selection_dt added newly.
    v_susa_rec  c_susa%ROWTYPE;
    v_us_rec        c_us%ROWTYPE;
    v_spa_rec       c_spa%ROWTYPE;
    v_authorised_person_id  IGS_AS_SU_SETATMPT.authorised_person_id%TYPE;
    v_authorised_on   IGS_AS_SU_SETATMPT.authorised_on%TYPE;

    v_confirmed_ind         IGS_AS_SU_SETATMPT.student_confirmed_ind%TYPE;
    v_selection_dt          IGS_AS_SU_SETATMPT.selection_dt%TYPE;


  BEGIN

    IF v_acaiv_rec.unit_set_cd IS NOT NULL THEN

      -- This block of Code added here for Bug#2347141 --
      OPEN c_us (v_acaiv_rec.unit_set_cd,   v_acaiv_rec.us_version_number);
      FETCH c_us INTO v_us_rec;
      CLOSE c_us;

      -- initializas these two variables
      v_confirmed_ind := 'N';
      v_selection_dt := NULL;

      -- It checks the Pre-Enrollment Year Profile option has been set and the Unit set does
      -- not require authorization  and  when the Unit Set being pre enrolled is a Pre-Enrollment Year ,
      -- Whose seeded value for Unit Set Category is 'PRENRL_YR'
      IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') ='Y' AND
         v_us_rec.authorisation_rqrd_ind = 'N' AND
         v_us_rec.s_unit_set_cat = 'PRENRL_YR' THEN


        OPEN c_spa;
        FETCH c_spa INTO v_spa_rec;
        IF  c_spa%NOTFOUND  THEN
                 CLOSE c_spa;
        ELSE
           -- If any record found for the Person and Course code, the Student Confirmed indicator
           -- has been set then the local variable for student Confirmed indicator has been set to yes.
           CLOSE c_spa;
           IF v_spa_rec.student_confirmed_ind='Y' THEN
                  v_confirmed_ind := 'Y';
               --set the selection date to the SPA commencement date
                  v_selection_dt := v_spa_rec.commencement_dt;
            END IF;
         END IF; -- if no spa found

      END IF; -- end of profile
      -- End of the Block of Code for Bug#2347141 --


      -- Check whether the IGS_PS_UNIT set has already been registered.
      -- Ignore any existing records which have been discontinued.
      OPEN c_susa;
      FETCH c_susa INTO v_susa_rec;
      IF c_susa%FOUND THEN

        IF v_susa_rec.student_confirmed_ind = 'N' AND
            v_confirmed_ind ='Y' THEN
      IF igs_en_gen_legacy.check_usa_overlap(
           v_susa_rec.person_id,
           v_susa_rec.course_cd,
           TRUNC(v_selection_dt),
           v_susa_rec.rqrmnts_complete_dt,
           v_susa_rec.end_dt,
           v_susa_rec.sequence_number,
           v_susa_rec.unit_set_cd,
           v_susa_rec.us_version_number,
           p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
              RETURN FALSE;
     END IF ;

          -- Bug#2347141
          -- Its updating the record in the Unit Set Attempt table with student conformed indicator as 'Y'
          -- and the Selection date as the value in the local variable.
          IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW(
                                            X_ROWID                     => v_susa_rec.rowid,
                                            X_PERSON_ID                 => v_susa_rec.person_id        ,
                                            X_COURSE_CD                 => v_susa_rec.course_cd        ,
                                            X_UNIT_SET_CD               => v_susa_rec.unit_set_cd      ,
                                            X_SEQUENCE_NUMBER           => v_susa_rec.sequence_number,
                                            X_US_VERSION_NUMBER         => v_susa_rec.us_version_number,
                                            X_SELECTION_DT              => TRUNC(v_selection_dt),
                                            X_STUDENT_CONFIRMED_IND     => v_confirmed_ind,
                                            X_END_DT                    => v_susa_rec.end_dt                   ,
                                            X_PARENT_UNIT_SET_CD        => v_susa_rec.parent_unit_set_cd       ,
                                            X_PARENT_SEQUENCE_NUMBER    => v_susa_rec.parent_sequence_number   ,
                                            X_PRIMARY_SET_IND           => v_susa_rec.primary_set_ind          ,
                                            X_VOLUNTARY_END_IND         => v_susa_rec.voluntary_end_ind        ,
                                            X_AUTHORISED_PERSON_ID      => v_susa_rec.authorised_person_id     ,
                                            X_AUTHORISED_ON             => v_susa_rec.authorised_on            ,
                                            X_OVERRIDE_TITLE            => v_susa_rec.override_title           ,
                                            X_RQRMNTS_COMPLETE_IND      => v_susa_rec.rqrmnts_complete_ind     ,
                                            X_RQRMNTS_COMPLETE_DT       => v_susa_rec.rqrmnts_complete_dt      ,
                                            X_S_COMPLETED_SOURCE_TYPE   => v_susa_rec.s_completed_source_type  ,
                                            X_CATALOG_CAL_TYPE          => v_susa_rec.catalog_cal_type   ,
                                            X_CATALOG_SEQ_NUM           => v_susa_rec.catalog_seq_num    ,
                                            X_ATTRIBUTE_CATEGORY        => v_susa_rec.attribute_category ,
                                            X_ATTRIBUTE1                => v_susa_rec.attribute1          ,
                                            X_ATTRIBUTE2                => v_susa_rec.attribute2          ,
                                            X_ATTRIBUTE3                => v_susa_rec.attribute3          ,
                                            X_ATTRIBUTE4                => v_susa_rec.attribute4          ,
                                            X_ATTRIBUTE5                => v_susa_rec.attribute5          ,
                                            X_ATTRIBUTE6                => v_susa_rec.attribute6          ,
                                            X_ATTRIBUTE7                => v_susa_rec.attribute7          ,
                                            X_ATTRIBUTE8                => v_susa_rec.attribute8          ,
                                            X_ATTRIBUTE9                => v_susa_rec.attribute9          ,
                                            X_ATTRIBUTE10               => v_susa_rec.attribute10         ,
                                            X_ATTRIBUTE11               => v_susa_rec.attribute11         ,
                                            X_ATTRIBUTE12               => v_susa_rec.attribute12         ,
                                            X_ATTRIBUTE13               => v_susa_rec.attribute13         ,
                                            X_ATTRIBUTE14               => v_susa_rec.attribute14         ,
                                            X_ATTRIBUTE15               => v_susa_rec.attribute15         ,
                                            X_ATTRIBUTE16               => v_susa_rec.attribute16         ,
                                            X_ATTRIBUTE17               => v_susa_rec.attribute17         ,
                                            X_ATTRIBUTE18               => v_susa_rec.attribute18         ,
                                            X_ATTRIBUTE19               => v_susa_rec.attribute19         ,
                                            X_ATTRIBUTE20               => v_susa_rec.attribute20         ,
                                            X_MODE                      => 'R');

          IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' AND
             v_us_rec.s_unit_set_cat = 'PRENRL_YR' THEN

            IF NOT update_stream_unit_sets(
          p_person_id,
          p_course_cd,
          v_susa_rec.unit_set_cd,
          v_susa_rec.rqrmnts_complete_ind,
          v_susa_rec.rqrmnts_complete_dt,
          v_selection_dt,
          v_confirmed_ind,
          p_log_creation_dt,
          p_message_name
        ) THEN
        RETURN FALSE;
        END IF;

          END IF;

        END IF;

      ELSE -- no susa record found
        CLOSE c_susa;

        -- If the Authorization required for the Unit set then get the authorized Person Id
        IF v_us_rec.authorisation_rqrd_ind ='Y'  THEN
          v_authorised_person_id := IGS_AD_GEN_003.ADMP_GET_ACAI_AOS_ID(
                  v_acaiv_rec.person_id,
                  v_acaiv_rec.admission_appl_number,
                  v_acaiv_rec.nominated_course_cd,
                  v_acaiv_rec.sequence_number,
                  v_authorised_on);
          IF v_authorised_person_id IS NULL THEN
            v_authorised_on := NULL;
          END IF;
        ELSE
          v_authorised_person_id := NULL;
          v_authorised_on := NULL;
        END IF;

        IF NOT create_unit_set(
      p_person_id,
      p_course_cd,
      v_acaiv_rec.unit_set_cd,
      v_acaiv_rec.us_version_number,
      v_selection_dt,
      v_confirmed_ind,
      v_authorised_person_id,
      v_authorised_on,
      l_seqval,
      p_log_creation_dt,
      p_message_name
    ) THEN
    RETURN FALSE;
   END IF;

        -- smaddali 12-jun-2002 added this call for bug#2391799 to create susa hesa details record for the newly pre-enrolled year
        IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' AND
           v_us_rec.s_unit_set_cat = 'PRENRL_YR' THEN

            IF NOT create_stream_unit_sets(
      p_person_id,
      p_course_cd,
      v_acaiv_rec.unit_set_cd,
      v_selection_dt,
      v_confirmed_ind,
      p_log_creation_dt,
      p_message_name
      ) THEN
      RETURN FALSE;
      END IF;

            IF l_seqval IS NOT NULL THEN
              copy_hesa_details(
                p_person_id,
                p_course_cd,
                v_acaiv_rec.crv_version_number,
                NULL,
                NULL,
                NULL ,
                v_acaiv_rec.unit_set_cd,
                v_acaiv_rec.us_version_number,
                l_seqval );
            END IF;
        END IF ;


      END IF;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_susa%ISOPEN THEN
        CLOSE c_susa;
      END IF;
      RAISE;
  END;
  EXCEPTION
     WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
       RAISE;
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_copy_adm_unit_sets');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;

  END enrpl_copy_adm_unit_sets;

  PROCEDURE enrpl_copy_adm_sua (
    p_warn_level    OUT NOCOPY   VARCHAR2,
    p_message_name  OUT NOCOPY   VARCHAR2,
    p_added_ind     OUT NOCOPY   VARCHAR2,
    p_enr_method                 IN VARCHAR2,
    p_lload_cal_type             IN VARCHAR2,
    p_lload_ci_seq_num           IN NUMBER)
  AS
  /*****************************************************/
  --Who         When            What
  --mesriniv    12-sep-2002     Added a new parameter waitlist_manual_ind in insert row of IGS_EN_SU_ATTEMPT
  --                            for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
  --ptandon     06-Oct-2003     Modified to get the value of core indicator and pass to Igs_En_Gen_010.enrp_vald_inst_sua
  --                            as part of Prevent Dropping Core Units. Enh Bug# 3052432.
  /****************************************************/

  BEGIN -- enrpl_copy_adm_sua
    -- Pre-enrol IGS_PS_UNIT attempts entered during Admissions, as parameter
    -- to the process or through the Pattern of Study.
  DECLARE
    --modifying cursor to join with unit_ofr_opt tabale to order by the sup_uoo_id
    --in order to process the superior units first, as part of placements build.
    CURSOR c_acaiu IS
      SELECT  acaiu.unit_cd,
        acaiu.uv_version_number,
        acaiu.cal_type,
        acaiu.ci_sequence_number,
        acaiu.location_cd,
        acaiu.unit_class
      FROM  IGS_AD_PS_APLINSTUNT  acaiu,
        IGS_AD_UNIT_OU_STAT     auos,
        IGS_PS_UNIT_OFR_OPT uoo
      WHERE acaiu.person_id     = v_acaiv_rec.person_id AND
        acaiu.admission_appl_number   = v_acaiv_rec.admission_appl_number AND
        acaiu.nominated_course_cd   = v_acaiv_rec.nominated_course_cd AND
        acaiu.acai_sequence_number  = v_acaiv_rec.sequence_number AND
        auos.ADM_UNIT_OUTCOME_STATUS  = acaiu.ADM_UNIT_OUTCOME_STATUS AND
        auos.s_adm_outcome_status   = cst_offer AND
        acaiu.unit_cd = uoo.unit_cd AND
        acaiu.uv_version_number = uoo.version_number AND
        acaiu.cal_type = uoo.cal_type AND
        acaiu.ci_sequence_number = uoo.ci_sequence_number AND
        acaiu.location_cd = uoo.location_cd AND
        acaiu.unit_class = uoo.unit_class
        ORDER BY uoo.sup_uoo_id DESC;

    CURSOR c_sua (
      cp_unit_cd    IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
      cp_uv_version_number  IGS_EN_SU_ATTEMPT.version_number%TYPE) IS
      SELECT  'x'
      FROM  IGS_EN_SU_ATTEMPT sua
      WHERE person_id   = p_person_id AND
        course_cd   = p_course_cd AND
        unit_cd   = cp_unit_cd AND
        version_number  = cp_uv_version_number;

    --
    --  Cursor to get the Uoo_Id - ptandon, Prevent Dropping Core Units build
    --
    CURSOR c_uoo_id (
      cp_unit_cd         IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE,
      cp_cal_type        IGS_PS_UNIT_OFR_OPT.cal_type%TYPE,
      cp_ci_sequence_number IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE,
      cp_location_cd     IGS_PS_UNIT_OFR_OPT.location_cd%TYPE,
      cp_unit_class      IGS_PS_UNIT_OFR_OPT.unit_class%TYPE)  IS
      SELECT  uoo_id
      FROM    IGS_PS_UNIT_OFR_OPT
      WHERE   unit_cd = cp_unit_cd
      AND     cal_type = cp_cal_type
      AND     ci_sequence_number = cp_ci_sequence_number
      AND     location_cd = cp_location_cd
      AND     unit_class = cp_unit_class;

  CURSOR c_sua_status(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
      SELECT DECODE(sua.unit_attempt_status, 'UNCONFIRM', 'N', 'WAITLISTED', 'Y' , NULL)
      FROM  IGS_EN_SU_ATTEMPT sua
      WHERE sua.person_id   = p_person_id AND
        sua.course_cd   = p_course_cd AND
        sua.uoo_id   = p_uoo_id;

   CURSOR c_teach_cal(p_uoo_Id igs_ps_unit_ofr_opt.uoo_Id%TYPE) IS
   SELECT cal_type, ci_sequence_number
   FROM igs_ps_unit_ofr_opt
   WHERE uoo_id = p_uoo_id;


    v_sua_rec   VARCHAR2(1);
    v_warn_level    VARCHAR2(10);
    vp_warn_level   VARCHAR2(10) := NULL;
    v_message_name    VARCHAR2(2000);
    v_log_creation_dt DATE;
    v_ci_start_dt   DATE;
    v_ci_end_dt   DATE;
    l_uoo_id     IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
    l_core_indicator IGS_EN_SU_ATTEMPT.core_indicator_code%TYPE;
    l_uoo_ids VARCHAR2(2000);
    l_enr_uoo_ids VARCHAR2(2000);
    l_waitlist_flag VARCHAR2(1) := NULL;
    l_out_uoo_ids VARCHAR2(2000);
    l_waitlist_uoo_ids VARCHAR2(2000);
    l_failed_uoo_ids VARCHAR2(2000);
    l_unit_attempt_status igs_en_su_Attempt.unit_attempt_status%type;
    l_cal_type IGS_PS_UNIT_OFR_OPT.cal_type%TYPE;
    l_seq_num IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE;
    l_sup_unit_cd IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE;
    l_unit_cd IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE;
    l_unit_cds VARCHAR2(2000);

  BEGIN
    p_added_ind := 'N';
    p_warn_level := NULL;
    p_message_name := null;
    FOR v_acaiu_rec IN c_acaiu LOOP
      -- Check if the IGS_PS_UNIT attempt already exists.
      OPEN c_sua(
        v_acaiu_rec.unit_cd,
        v_acaiu_rec.uv_version_number);
      FETCH c_sua INTO v_sua_rec;
      IF c_sua%NOTFOUND THEN
        CLOSE c_sua;
        --checking for the details of all parameters if unit_cd is not null.

        -- Call routine to check whether there is anything preventing
        -- the IGS_PS_UNIT attempt from being pre-enrolled (ie. advanced
        -- standing or encumbrances).
        --aspart of placements build, checking if all details of unit section are given
        IF v_acaiu_rec.unit_cd IS NOT NULL
                AND v_acaiu_rec.cal_type IS NOT NULL
                AND v_acaiu_rec.ci_sequence_number IS NOT NULL
                AND v_acaiu_rec.location_cd IS NOT NULL
                AND v_acaiu_rec.unit_class IS NOT NULL THEN

        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_pre(
            p_person_id,
            p_course_cd,
            v_acaiu_rec.unit_cd,
            v_log_creation_dt,
            v_warn_level,
            v_message_name) THEN
          IF p_log_creation_dt IS NOT NULL THEN
            -- If the log creation date is set then log the HECS error
            -- This is if the pre-enrolment is being performed in batch.
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
              cst_pre_enrol,
              p_log_creation_dt,
              v_warn_level || ',' ||
                TO_CHAR(p_person_id) || ',' ||
                 p_course_cd,
              v_message_name,
              NULL);
          END IF;
          IF vp_warn_level IS NULL OR
              (vp_warn_level = cst_minor AND
              v_warn_level IN (cst_major,
                  cst_error)) OR
              (vp_warn_level = cst_major AND
              v_warn_level = cst_error) THEN
            vp_warn_level := v_warn_level;
            p_message_name := v_message_name;
          END IF;
          -- continue with the next record
        ELSE  -- enrp_val_sua_pre = TRUE
          IGS_CA_GEN_001.calp_get_ci_dates(v_acaiu_rec.cal_type,
                                           v_acaiu_rec.ci_sequence_number,
                                           v_ci_start_dt,
                                           v_ci_end_dt);
          -- Get the Uoo_Id, ptandon - Prevent Dropping Core Units build
          OPEN c_uoo_id(v_acaiu_rec.unit_cd,
                        v_acaiu_rec.cal_type,
                        v_acaiu_rec.ci_sequence_number,
                        v_acaiu_rec.location_cd,
                        v_acaiu_rec.unit_class);
          FETCH c_uoo_id INTO l_uoo_id;
          CLOSE c_uoo_id;


          -- Get the Core Indicator for the Unit Section
          l_core_indicator := igs_en_gen_009.enrp_check_usec_core(p_person_id, p_course_cd, l_uoo_id);

          -- IGS_PS_UNIT doesn?t  exist against the students record or as
          -- advanced standing, so insert unconfirmed IGS_PS_UNIT attempt.
          IF igs_en_gen_010.enrp_vald_inst_sua(p_person_id      => p_person_id,
                                               p_course_cd      => p_course_cd,
                                               p_unit_cd        => v_acaiu_rec.unit_cd,
                                               p_version_number => v_acaiu_rec.uv_version_number,
                                               p_teach_cal_type => v_acaiu_rec.cal_type,
                                               p_teach_seq_num  => v_acaiu_rec.ci_sequence_number,
                                               p_load_cal_type  => p_lload_cal_type,
                                               p_load_seq_num   => p_lload_ci_seq_num,
                                               p_location_cd    => v_acaiu_rec.location_cd,
                                               p_unit_class     => v_acaiu_rec.unit_class,
                                               p_uoo_id         => NULL,
                                               p_enr_method     => p_enr_method,
                                               p_core_indicator_code => l_core_indicator, -- ptandon, Prevent Dropping Core Units build
                                               p_message        => v_message_name)
           THEN
                  p_added_ind := 'Y';
                  IF v_message_name IS NOT NULL THEN
                     p_warn_level:='MINOR';
                     p_message_name := v_message_name;
                  END IF;
             --fetch the watilist indicator, added as part of placements build to pass in teh call to
            --enr_sub_units to validate superior subordinate relationships
            --before enrolling the default enroll sub units.

             l_waitlist_flag := NULL;
             OPEN c_sua_status(l_uoo_id);
             FETCH c_sua_status INTO l_waitlist_flag;
             CLOSE c_sua_status;

                --fetch the teach cal type and teach seq number
             l_cal_type := NULL;
             l_seq_num := NULL;
             OPEN c_teach_cal(l_uoo_id);
             FETCH c_teach_cal INTO l_cal_type, l_seq_num;
             CLOSE c_teach_cal;

             l_failed_uoo_ids := NULL;
                igs_en_val_sua.enr_sub_units(
                p_person_id      => p_person_id,
                p_course_cd      => p_course_cd,
                p_uoo_id         => l_uoo_id,
                p_waitlist_flag  => l_waitlist_flag,
                p_load_cal_type  => p_lload_cal_type,
                p_load_seq_num   => p_lload_ci_seq_num,
                p_enrollment_date => NULL,
                p_enrollment_method =>p_enr_method,
                p_enr_uoo_ids     => l_enr_uoo_ids,
                p_uoo_ids         => l_out_uoo_ids,
                p_waitlist_uoo_ids => l_waitlist_uoo_ids,
                p_failed_uoo_ids  => l_failed_uoo_ids);

               IF l_failed_uoo_ids IS NOT NULL THEN
                 --log error message if sub units did not enroll
                   IF p_log_creation_dt IS NOT NULL THEN
                      l_unit_cds := NULL;
                    --following function returns a string of units codes for teh passed in string of uoo_ids
                     l_unit_cds := igs_en_gen_018.enrp_get_unitcds(l_failed_uoo_ids);
                     p_warn_level := cst_error;
                     v_message_name := 'IGS_EN_BLK_SUB_FAILED'||'*'||l_unit_cds;
                     -- If the log creation date is set then log the HECS error
                    -- This is if the pre-enrolment is being performed in batch.
                       log_error_message(p_s_log_type        =>cst_pre_enrol,
                                 p_creation_dt       =>p_log_creation_dt,
                                 p_sle_key           =>p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                 p_sle_message_name  =>v_message_name,
                                 p_del               => ';');
                   END IF;
             END IF;
          ELSE -- unit was not enrolled,enrp_vald_inst_sua returned false.
              p_warn_level := cst_error;
              p_message_name := v_message_name;
          END IF;
          IF (p_log_creation_dt IS NOT NULL) AND (v_message_name IS NOT NULL) THEN
               -- If the log creation date is set then log the HECS error
               -- This is if the pre-enrolment is being performed in batch.
               log_error_message(p_s_log_type        =>cst_pre_enrol,
                                 p_creation_dt       =>p_log_creation_dt,
                                 p_sle_key           =>p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                 p_sle_message_name  =>v_message_name,
                                 p_del               => ';');
          END IF;
        END IF;
     ELSE
        p_warn_level := cst_minor;
        p_message_name := 'IGS_EN_SPECIFY_ALLUNITPARAM';
     END IF; --unit section details
      ELSE  -- c_sua%FOUND
        CLOSE c_sua;
        -- continue with the next record
      END IF;
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_sua%ISOPEN THEN
        CLOSE c_sua;
      END IF;
      IF c_acaiu%ISOPEN THEN
        CLOSE c_acaiu;
      END IF;
      IF c_teach_cal%ISOPEN THEN
        CLOSE c_teach_cal;
      END IF;
      IF c_sua_status%ISOPEN THEN
        CLOSE c_sua_status;
      END IF;

      RAISE;
  END;
  EXCEPTION
     WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
       RAISE;
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_copy_adm_sua');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END enrpl_copy_adm_sua;

  PROCEDURE enrpl_copy_param_sua (
    p_warn_level       OUT NOCOPY   VARCHAR2,
    p_message_name     OUT NOCOPY   VARCHAR2,
    p_added_ind        OUT NOCOPY   VARCHAR2,
    p_enr_method                 IN VARCHAR2,
    p_lload_cal_type             IN VARCHAR2,
    p_lload_ci_seq_num           IN NUMBER)
  AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified the c_sua cursor w.r.t. bug number 2829262
  --ptandon     06-Oct-2003     Modified to get the value of core indicator and pass to Igs_En_Gen_010.enrp_vald_inst_sua
  --                            as part of Prevent Dropping Core Units. Enh Bug# 3052432.
  --svanukur    19-oct-2003     Made the following modifaications part of placements build:
  --                            Reordered the units so that the superior units are processed first becuase of the validation in
  --                            sua_api that checks for an appropriate superior unit attempt when a subordinate unit is enrolled.
  --                            for all the uoo_ids , made a call to ENR_SUB_UNITS in sua_api which enrolled all those untis
  --                            that are marked as default enroll whenever a superior unit is enrolled.
  -- ckasu     07-MAR-2006     modified as a part of bug#5070730
  -------------------------------------------------------------------------------------------
  BEGIN -- enrpl_copy_param_sua
    -- Pre-enrol IGS_PS_UNIT attempts entered during Admissions, as parameter
    -- to the process.

  DECLARE
    CURSOR c_am (
      cp_attendance_mode  IGS_EN_ATD_MODE.attendance_mode%TYPE) IS
      SELECT  am.GOVT_ATTENDANCE_MODE
      FROM  IGS_EN_ATD_MODE am
      WHERE am.attendance_mode = cp_attendance_mode;
    CURSOR c_cir (
      cp_cal_type   IGS_CA_INST.cal_type%TYPE) IS
      SELECT  ci.sequence_number
      FROM  IGS_CA_INST_REL   cir,
        IGS_CA_INST       ci,
        IGS_CA_TYPE       cat,
        IGS_CA_STAT       cs
      WHERE cir.sup_cal_type    = p_acad_cal_type AND
        cir.sup_ci_sequence_number  = p_acad_sequence_number AND
        ci.cal_type     = cir.sub_cal_type AND
        ci.sequence_number  = cir.sub_ci_sequence_number AND
        ci.cal_type   = cp_cal_type AND
        cat.cal_type    = ci.cal_type AND
        cat.S_CAL_CAT     = 'TEACHING' AND
        cs.CAL_STATUS     = ci.CAL_STATUS AND
        cs.s_cal_status   = 'ACTIVE'
      ORDER BY ci.start_dt;
    CURSOR c_sua (
      cp_person_id          IGS_EN_SU_ATTEMPT.person_id%TYPE,
      cp_course_cd          IGS_EN_SU_ATTEMPT.course_cd%TYPE,
      cp_unit_cd            IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
      cp_cal_type           IGS_EN_SU_ATTEMPT.cal_type%TYPE,
      cp_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
      cp_location_cd        IGS_EN_SU_ATTEMPT.location_cd%TYPE,
      cp_unit_class         IGS_EN_SU_ATTEMPT.unit_class%TYPE) IS
      SELECT  'x'
      FROM  IGS_EN_SU_ATTEMPT
      WHERE person_id               = cp_person_id          AND
            course_cd               = cp_course_cd          AND
            unit_cd                 = cp_unit_cd            AND
            cal_type                = cp_cal_type           AND
            ci_sequence_number      = cp_ci_sequence_number AND
            location_cd             = cp_location_cd        AND
            unit_class              = cp_unit_class;

      CURSOR c_sua_status(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
      SELECT DECODE(sua.unit_attempt_status, 'UNCONFIRM', 'N', 'WAITLISTED', 'Y' , NULL)
      FROM  IGS_EN_SU_ATTEMPT sua
      WHERE sua.person_id   = p_person_id AND
        sua.course_cd   = p_course_cd AND
        sua.uoo_id   = p_uoo_id;

      CURSOR c_rel_type(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
      SELECT relation_type
      FROM IGS_PS_UNIT_OFR_OPT
      WHERE uoo_id = p_uoo_id;

      CURSOR c_teach_cal(p_uoo_Id igs_ps_unit_ofr_opt.uoo_Id%TYPE) IS
      SELECT cal_type, ci_sequence_number
      FROM igs_ps_unit_ofr_opt
      WHERE uoo_id = p_uoo_id;

    v_am_rec                    c_am%ROWTYPE;
    v_sua_rec                   VARCHAR2(1);
    v_cir_rec                   c_cir%ROWTYPE;
    v_warn_level                VARCHAR2(10);
    v_log_creation_dt           DATE;
    vp_warn_level               VARCHAR2(10) := NULL;
    v_message_name              VARCHAR2(2000);
    v_attendance_mode           VARCHAR2(3);
    v_counter                   NUMBER := 0;
    v_uoo_id                    IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
    v_session_id                VARCHAR2(255);
    v_ci_start_dt               DATE;
    v_ci_end_dt                 DATE;
    -- variable used to keep the values on the
    -- parameter specified units.  p_unit<x>_....
    v_unit_cd                   IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE;
    v_cal_type                  IGS_PS_UNIT_OFR_OPT.cal_type%TYPE;
    v_location_cd               IGS_PS_UNIT_OFR_OPT.location_cd%TYPE;
    v_unit_class                IGS_PS_UNIT_OFR_OPT.unit_class%TYPE;
    l_core_indicator            IGS_EN_SU_ATTEMPT.core_indicator_code%TYPE;

    l_rel_type                  IGS_PS_UNIT_OFR_OPT.relation_type%TYPE;
    l_uoo_ids VARCHAR2(2000);
    l_enr_uoo_ids VARCHAR2(2000);
    l_out_uoo_ids VARCHAR2(2000);
    l_waitlist_uoo_ids VARCHAR2(2000);
    l_failed_uoo_ids VARCHAR2(2000);
    l_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
     TYPE t_params_table IS TABLE OF NUMBER(7) INDEX BY BINARY_INTEGER;
     t_sup_params t_params_table;
     t_sub_params t_params_table;
     t_ord_params t_params_table;
     v_sup_index BINARY_INTEGER := 1;
     v_sub_index BINARY_INTEGER := 1;
     v_ord_index BINARY_INTEGER := 1;
     l_waitlist_flag varchar2(1) := NULL;
     l_cal_type IGS_PS_UNIT_OFR_OPT.cal_type%TYPE;
      l_seq_num IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE;
      l_sup_unit_cd IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE;
    l_unit_cd IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE;
    l_unit_cds VARCHAR2(2000);

  BEGIN
    p_added_ind := 'N';
    vp_warn_level := NULL;
    p_message_name := null;
    -- Get the student?s IGS_PS_GOVT_ATD_MODE before the pre-enrolment
    -- starts. It is passed to the routine determining which UOO to
    -- select for a pre-enrolled IGS_PS_UNIT.
    OPEN c_am(
      v_attendance_mode);
    FETCH c_am INTO v_am_rec;
    CLOSE c_am;
    IF v_am_rec.GOVT_ATTENDANCE_MODE = '1' THEN
      v_attendance_mode := 'ON';
    ELSIF v_am_rec.GOVT_ATTENDANCE_MODE = '2' THEN
      v_attendance_mode := 'OFF';
    ELSE
      v_attendance_mode :=  '%';
    END IF;
    -- loop through each of the specified units
    FOR v_counter IN 1..12 LOOP
      -- insert the IGS_PS_UNIT values into the local variables
      SELECT  DECODE( v_counter,
          1, p_unit1_unit_cd,
          2, p_unit2_unit_cd,
          3, p_unit3_unit_cd,
          4, p_unit4_unit_cd,
          5, p_unit5_unit_cd,
          6, p_unit6_unit_cd,
          7, p_unit7_unit_cd,
          8, p_unit8_unit_cd,
          9, p_unit9_unit_cd,
          10, p_unit10_unit_cd,
          11, p_unit11_unit_cd,
          12, p_unit12_unit_cd,
          NULL),
        DECODE( v_counter,
          1, p_unit1_cal_type,
          2, p_unit2_cal_type,
          3, p_unit3_cal_type,
          4, p_unit4_cal_type,
          5, p_unit5_cal_type,
          6, p_unit6_cal_type,
          7, p_unit7_cal_type,
          8, p_unit8_cal_type,
          9, p_unit9_cal_type,
          10, p_unit10_cal_type,
          11, p_unit11_cal_type,
          12, p_unit12_cal_type,
          NULL),
        DECODE( v_counter,
          1, p_unit1_location_cd,
          2, p_unit2_location_cd,
          3, p_unit3_location_cd,
          4, p_unit4_location_cd,
          5, p_unit5_location_cd,
          6, p_unit6_location_cd,
          7, p_unit7_location_cd,
          8, p_unit8_location_cd,
          9, p_unit9_location_cd,
          10, p_unit10_location_cd,
          11, p_unit11_location_cd,
          12, p_unit12_location_cd,
          NULL),
        DECODE( v_counter,
          1, p_unit1_unit_class,
          2, p_unit2_unit_class,
          3, p_unit3_unit_class,
          4, p_unit4_unit_class,
          5, p_unit5_unit_class,
          6, p_unit6_unit_class,
          7, p_unit7_unit_class,
          8, p_unit8_unit_class,
          9, p_unit9_unit_class,
          10, p_unit10_unit_class,
          11, p_unit11_unit_class,
          12, p_unit12_unit_class,
          NULL)
      INTO  v_unit_cd,
            v_cal_type,
            v_location_cd,
            v_unit_class
      FROM  DUAL;
      IF v_unit_cd IS NOT NULL THEN
        p_added_ind := 'Y';
        -- Call routine to check whether there is anything preventing
        -- the IGS_PS_UNIT attempt from being pre-enrolled (ie. advanced
        -- standing or encumbrances).
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_pre(
            p_person_id,
            p_course_cd,
            v_unit_cd,
            p_log_creation_dt,
            v_warn_level,
            v_message_name) THEN
          IF p_log_creation_dt IS NOT NULL THEN
            -- If the log creation date is set then log the HECS error
            -- This is if the pre-enrolment is being performed in batch.
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
              cst_pre_enrol,
              p_log_creation_dt,
              cst_minor || ',' ||
                TO_CHAR(p_person_id) || ',' ||
                 p_course_cd,
              v_message_name,
              NULL);
          END IF;
          IF vp_warn_level IS NULL OR
            (vp_warn_level = cst_minor AND  v_warn_level IN (cst_major,cst_error)) OR
            (vp_warn_level = cst_major AND  v_warn_level = cst_error) THEN
             vp_warn_level := v_warn_level;
             p_message_name := v_message_name;
          END IF;
          p_warn_level := vp_warn_level;
          RETURN;
        END IF;
        -- For each of the specified units, determine the appropriate calendar
        -- instance and IGS_PS_UNIT offering option and add the IGS_PS_UNIT attempt.
        -- Determine the calendar instance of the pre-enrolment within the
        -- academic calendar instance; if multiple exist (straddling teaching
        -- periods) then pick the earliest.
        OPEN c_cir(
          v_cal_type);
        FETCH c_cir INTO v_cir_rec;
        IF c_cir%FOUND THEN
          CLOSE c_cir;
          -- use the first record found
          -- Check whether the student is already enrolled
          -- in the IGS_PS_UNIT attempt.
          OPEN c_sua(
            p_person_id,
            p_course_cd,
            v_unit_cd,
            v_cal_type,
            v_cir_rec.sequence_number,
            v_location_cd,
            v_unit_class);
          FETCH c_sua INTO v_sua_rec;
          IF c_sua%NOTFOUND THEN
            CLOSE c_sua;
            -- Call routine to get the UOO for the selected
            -- IGS_PS_UNIT.
            IF NOT IGS_EN_GEN_005.enrp_get_pre_uoo(
                v_unit_cd,
                v_cal_type,
                v_cir_rec.sequence_number,
                v_location_cd,
                v_unit_class,
                v_attendance_mode,
                v_acaiv_rec.location_cd,
                v_uoo_id) THEN
              IF p_log_creation_dt IS NOT NULL THEN
                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                  cst_pre_enrol,
                  p_log_creation_dt,
                  cst_minor || ',' ||
                    TO_CHAR(p_person_id) || ',' ||
                     p_course_cd,
                  'IGS_EN_UNABLE_LOCATE_UOO_MATC',
                  v_cal_type || ',' ||
                    v_unit_cd || ',' ||
                    v_location_cd || ',' ||
                    v_unit_class);
              END IF;
              p_warn_level := 'MINOR';
              p_message_name := 'IGS_EN_UNABLE_LOCATE_UOO_MATC';
            ELSE
              l_rel_type := NULL;
               OPEN c_rel_type(v_uoo_id);
               FETCH c_rel_type INTO l_rel_type;
               CLOSE c_rel_type;
               IF l_rel_type= 'SUPERIOR' THEN
                  t_sup_params(v_sup_index) := v_uoo_id;
                  v_sup_index :=v_sup_index+1;
               ELSIF l_rel_type = 'SUBORDINATE' THEN
                  t_sub_params(v_sub_index) := v_uoo_id;
                  v_sub_index := v_sub_index+1;
               ELSE
                    t_ord_params(v_ord_index) := v_uoo_id;
                  v_ord_index := v_ord_index+1;
              END IF;

            END IF;
          ELSE  -- c_sua%FOUND
            CLOSE c_sua;
          END IF;
        ELSE  -- c_cir%NOTFOUND
          CLOSE c_cir;
        END IF;
      END IF;
    END LOOP; -- 8 units
    -- add all the uoo_ids to one pl/sql table, with superiors, first, subordinate next and the rest .
       --concatenate uoo_ids to pass to enr_sub_units.
       IF t_sup_params.count > 0 THEN
           FOR i in 1 .. t_sup_params.count LOOP
            IF  l_uoo_ids IS NOT NULL then
                l_uoo_ids := l_uoo_ids ||','||t_sup_params(i);
            ELSE
                l_uoo_ids := t_sup_params(i);
            END IF;
           END LOOP;
       END IF;
      IF t_sub_params.count > 0 THEN
           FOR i in 1 .. t_sub_params.count LOOP
            IF  l_uoo_ids IS NOT NULL then
                l_uoo_ids := l_uoo_ids ||','||t_sub_params(i);
            ELSE
                l_uoo_ids := t_sub_params(i);
            END IF;
           END LOOP;
       END IF;
      IF t_ord_params.count > 0 THEN
           FOR i in 1 .. t_ord_params.count LOOP
            IF  l_uoo_ids IS NOT NULL then
                l_uoo_ids := l_uoo_ids ||','||t_ord_params(i);
            ELSE
                l_uoo_ids := t_ord_params(i);
            END IF;
           END LOOP;
       END IF;

  -- the concatenated uoo-ids are in l_uoo_ids in the order of superior, subordinate and then the rest.
  --for each of these , call the enrp_vald_inst_sua.
l_enr_uoo_ids := l_uoo_ids;

  WHILE l_enr_uoo_ids IS NOT NULL LOOP
  l_uoo_id := NULL;

          --extract the uoo_id
            IF(INSTR(l_enr_uoo_ids,',',1) = 0) THEN
                   l_uoo_id := TO_NUMBER(l_enr_uoo_ids);
            ELSE
                   l_uoo_id := TO_NUMBER(SUBSTR(l_enr_uoo_ids,0,INSTR(l_enr_uoo_ids,',',1)-1)) ;
            END IF;


                  IGS_CA_GEN_001.calp_get_ci_dates(
                  v_cal_type,
                  v_cir_rec.sequence_number,
                  v_ci_start_dt,
                  v_ci_end_dt);

                  -- Get the Core Indicator for the Unit Section
                   l_core_indicator := igs_en_gen_009.enrp_check_usec_core(p_person_id, p_course_cd, l_uoo_id);

                  IF igs_en_gen_010.enrp_vald_inst_sua(p_person_id      => p_person_id,
                                                       p_course_cd      => p_course_cd,
                                                       p_unit_cd        => NULL,
                                                       p_version_number => NULL,
                                                       p_teach_cal_type => NULL,
                                                       p_teach_seq_num  => NULL,
                                                       p_load_cal_type  => p_lload_cal_type,
                                                       p_load_seq_num   => p_lload_ci_seq_num,
                                                       p_location_cd    => NULL,
                                                       p_unit_class     => NULL,
                                                       p_uoo_id         => l_uoo_id,
                                                       p_enr_method     => p_enr_method,
                                                       p_core_indicator_code => l_core_indicator, -- ptandon, Prevent Dropping Core Units build
                                                       p_message        => v_message_name)
                 THEN
                      IF v_message_name IS NOT NULL THEN
                         p_warn_level := 'MINOR';
                         p_message_name := v_message_name;
                      END IF;

                     --call enr_sub_units to enroll any subordinate units that are marked as default enroll
                    --fetch the unit attempt status to check if it is unconfirmed or watilisted.

                     l_waitlist_flag := NULL;
                     OPEN c_sua_status(l_uoo_id);
                     FETCH c_sua_status INTO l_waitlist_flag;
                     CLOSE c_sua_status;

                     --fetch the teach cal type and teach seq number
                     l_cal_type := NULL;
                     l_seq_num := NULL;

                     OPEN c_teach_cal(l_uoo_id);
                     FETCH c_teach_cal INTO l_cal_type, l_seq_num;
                     CLOSE c_teach_cal;

                     l_failed_uoo_ids := NULL;
                     igs_en_val_sua.enr_sub_units(
                     p_person_id      => p_person_id,
                     p_course_cd      => p_course_cd,
                     p_uoo_id         => l_uoo_id,
                     p_waitlist_flag  => l_waitlist_flag,
                     p_load_cal_type  => p_lload_cal_type,
                     p_load_seq_num   => p_lload_ci_seq_num,
                     p_enrollment_date => NULL,
                     p_enrollment_method => p_enr_method,
                     p_enr_uoo_ids     => l_enr_uoo_ids,
                     p_uoo_ids         => l_out_uoo_ids,
                     p_waitlist_uoo_ids => l_waitlist_uoo_ids,
                     p_failed_uoo_ids  => l_failed_uoo_ids);

                    IF l_failed_uoo_ids IS NOT NULL THEN
                       --log error message if sub units did not enroll
                       IF p_log_creation_dt IS NOT NULL THEN
                          l_unit_cds := NULL;
                          --following function returns a string of units codes for teh passed in string of uoo_ids
                          l_unit_cds := igs_en_gen_018.enrp_get_unitcds(l_failed_uoo_ids);
                          p_warn_level := cst_error;
                          v_message_name := 'IGS_EN_BLK_SUB_FAILED'||'*'||l_unit_cds;

                        -- If the log creation date is set then log the HECS error
                        -- This is if the pre-enrolment is being performed in batch.
                           log_error_message(p_s_log_type        =>cst_pre_enrol,
                                 p_creation_dt       =>p_log_creation_dt,
                                 p_sle_key           =>p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                 p_sle_message_name  =>v_message_name,
                                 p_del               => ';');
                     END IF;
                   END IF;
                ELSE --the unit was not enrolled i.e enrp_vald_inst_sua returned false.

                     p_warn_level := cst_error;
                     p_message_name := v_message_name;
                END IF;

                  IF (p_log_creation_dt IS NOT NULL) AND (v_message_name IS NOT NULL) THEN
                      -- If the log creation date is set then log the HECS error
                      -- This is if the pre-enrolment is being performed in batch.
                      log_error_message(p_s_log_type        => cst_pre_enrol,
                                        p_creation_dt       => p_log_creation_dt,
                                        p_sle_key           => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                        p_sle_message_name  => v_message_name,
                                        p_del               => ';');
                  END IF;

        --remove the processed uoo_id from the list of uoo_ids.
         IF(INSTR(l_enr_uoo_ids,',',1) = 0) THEN
              l_enr_uoo_ids := NULL;
         ELSE
              l_enr_uoo_ids := SUBSTR(l_enr_uoo_ids,INSTR(l_enr_uoo_ids,',',1)+1);
         END IF;


     END LOOP;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_sua%ISOPEN THEN
        CLOSE c_sua;
      END IF;
      IF c_am%ISOPEN THEN
        CLOSE c_am;
      END IF;
      IF c_cir%ISOPEN THEN
        CLOSE c_cir;
      END IF;
      IF c_teach_cal%ISOPEN THEN
        CLOSE c_teach_cal;
      END IF;
      IF c_sua_status%ISOPEN THEN
        CLOSE c_sua_status;
      END IF;
      IF c_rel_type%ISOPEN THEN
        CLOSE c_rel_type;
      END IF;
      RAISE;
  END;
  EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_copy_param_sua');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END enrpl_copy_param_sua;

  PROCEDURE  enrpl_create_pos_sua (
    p_unit_set_cd        IN igs_en_unit_set.unit_set_cd%TYPE,
    p_warn_level         OUT NOCOPY   VARCHAR2,
    p_message_name       OUT NOCOPY   VARCHAR2,
    p_enr_method                   IN VARCHAR2,
    p_lload_cal_type               IN VARCHAR2,
    p_lload_ci_seq_num             IN NUMBER)
  AS

  BEGIN -- enrpl_create_pos_sua
    -- Pre-enrol IGS_PS_UNIT attempts entered during Admissions
    -- through the Pattern of Study.

  DECLARE
    v_warn_level      VARCHAR2(10);
    v_log_creation_dt DATE;
    v_message_name    VARCHAR2(2000);
    v_return          BOOLEAN;
  BEGIN

    p_warn_level := NULL;
    p_message_name := null;
    v_return := IGS_EN_GEN_009.enrp_ins_pre_pos(p_acad_cal_type         =>p_acad_cal_type,
                                                p_acad_sequence_number  =>p_acad_sequence_number,
                                                p_person_id             =>p_person_id,
                                                p_course_cd             =>p_course_cd,
                                                p_version_number        =>v_acaiv_rec.crv_version_number,
                                                p_location_cd           =>v_acaiv_rec.location_cd,
                                                p_attendance_mode       =>v_acaiv_rec.attendance_mode,
                                                p_attendance_type       =>v_acaiv_rec.attendance_type,
                                                p_unit_set_cd           =>p_unit_set_cd,
                                                p_adm_cal_type          =>v_acaiv_rec.adm_cal_type,
                                                p_admission_cat         =>v_acaiv_rec.admission_cat,
                                                p_log_creation_dt       =>p_log_creation_dt,
                                                p_units_indicator       =>p_units_indicator,
                                                p_warn_level            =>v_warn_level,
                                                p_message_name          =>v_message_name,
                                                p_progress_stat         =>p_progress_stat,
                                                p_progress_outcome_type =>gv_progress_outcome_type,
                                                p_enr_method            =>p_enr_method,
                                                p_load_cal_type         =>p_lload_cal_type,
                                                p_load_ci_seq_num       =>p_lload_ci_seq_num);

    IF (v_message_name IS NOT NULL) AND ( NOT v_return )THEN
      p_warn_level := cst_major;
      p_message_name := v_message_name;
    ELSE
      p_warn_level := v_warn_level;
      p_message_name := v_message_name;
    END IF;

    IF (p_log_creation_dt IS NOT NULL) AND (v_message_name IS NOT NULL) THEN
        -- If the log creation date is set then log the HECS error
        -- This is if the pre-enrolment is being performed in batch.
        log_error_message(p_s_log_type        => cst_pre_enrol,
                          p_creation_dt       => p_log_creation_dt,
                          p_sle_key           => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                          p_sle_message_name  => v_message_name,
                          p_del               => ';');
    END IF;
    RETURN;
  END;
  EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_create_pos_sua');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END enrpl_create_pos_sua;

  PROCEDURE  enrpl_create_fee_contract(
    p_warn_level    OUT NOCOPY   VARCHAR2,
    p_message_name    OUT NOCOPY VARCHAR2)
  AS

  BEGIN -- enrpl_create_fee_contract
    -- Create Fee Contract
  DECLARE
    CURSOR c_apcs IS
      SELECT  'x'
      FROM  IGS_AD_PRCS_CAT_STEP  apcs
      WHERE apcs.admission_cat    = v_acaiv_rec.admission_cat AND
        apcs.s_admission_process_type   = v_acaiv_rec.s_admission_process_type AND
        apcs.s_admission_step_type  = cst_fee_cntrct AND
        apcs.step_group_type <> 'TRACK'; -- 2402377
      v_apcs_exists   VARCHAR2(1);
      v_commencement_dt2
      IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE := v_sca_commencement_dt;
      v_completion_dt   IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE ;
  BEGIN
    p_warn_level := NULL;
    p_message_name := null;
    -- Check if a fee contract should be created.
    OPEN c_apcs;
    FETCH c_apcs INTO v_apcs_exists;
    IF c_apcs%FOUND THEN
      CLOSE c_apcs;
      -- Determine the IGS_PS_COURSE commencement date.
      IF v_commencement_dt2 IS NULL THEN
        v_commencement_dt2 := IGS_EN_GEN_002.ENRP_GET_ACAD_COMM(
                NULL, -- (Academic Cal Type)
                NULL, -- (Academic Sequence Number)
                v_acaiv_rec.person_id,
                v_acaiv_rec.course_cd,
                v_acaiv_rec.admission_appl_number,
                v_acaiv_rec.nominated_course_cd,
                v_acaiv_rec.sequence_number,
                'Y');
      END IF;
      IF v_commencement_dt2 IS NULL THEN
        IF p_log_creation_dt IS NOT NULL THEN
          IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_minor || ',' ||
              TO_CHAR(p_person_id) || ',' ||
              p_course_cd,
            'IGS_EN_FEE_CONTRACT_NOT_CREAT',
            NULL);
        END IF;
        p_warn_level := cst_minor;
        p_message_name := 'IGS_EN_FEE_CONTRACT_NOT_CREAT';
        RETURN;
      END IF;
      -- Determine the IGS_PS_COURSE completion date.
      IGS_AD_GEN_004.admp_get_crv_comp_dt (
          v_acaiv_rec.course_cd,
          v_acaiv_rec.crv_version_number,
          v_acaiv_rec.acad_cal_type,
          v_acaiv_rec.attendance_type,
          v_commencement_dt2, -- (Start Date)
          v_acaiv_rec.expected_completion_yr,
          v_acaiv_rec.expected_completion_perd,
          v_completion_dt,
          v_acaiv_rec.attendance_mode,
          v_acaiv_rec.location_cd);

      IF v_completion_dt IS NULL THEN
        IF p_log_creation_dt IS NOT NULL THEN
          IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_minor || ',' ||
              TO_CHAR(p_person_id) || ',' ||
              p_course_cd,
            'IGS_EN_FEE_CONTRACT_NOTCREATE',
            NULL);
        END IF;
        p_warn_level := cst_minor;
        p_message_name := 'IGS_EN_FEE_CONTRACT_NOTCREATE';
        RETURN;
      END IF;
      -- Create the Fee Contract.
      IF NOT IGS_FI_GEN_004.finp_prc_cfar(
          v_acaiv_rec.person_id,
          v_acaiv_rec.course_cd,
          v_commencement_dt2, -- (Start Date)
          v_completion_dt,   -- (End Date)
          v_message_name) THEN
        IF p_log_creation_dt IS NOT NULL THEN
          IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_minor || ',' ||
              TO_CHAR(p_person_id) || ',' ||
              p_course_cd,
            v_message_name,
            NULL);
        END IF;
        p_warn_level := cst_minor;
        p_message_name := v_message_name;
      END IF;
    ELSE
      CLOSE c_apcs;
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_apcs%ISOPEN THEN
        CLOSE c_apcs;
      END IF;
      RAISE;
  END;
  EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_create_fee_contract');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END enrpl_create_fee_contract;

BEGIN   -- begin of the function, Enrp_Ins_Snew_Prenrl

  SAVEPOINT sp_pre_enrol_student;
  --Defaults the enrollment method to Default bulk enrollment method.
  igs_en_gen_017.g_invoke_source := 'JOB';
  -- Initialise the out parameters.
  p_warn_level := NULL;
  p_message_name := null;

  IF p_load_cal_type IS NULL THEN
      OPEN c_load_cal(p_acad_cal_type,p_acad_sequence_number);
      FETCH c_load_cal INTO l_load_cal_type, l_load_seq_num;
      IF c_load_cal%NOTFOUND THEN
          CLOSE c_load_cal;
          p_warn_level := cst_error;
          p_message_name := 'IGS_EN_CN_FIND_TERM_CAL';
          IF p_log_creation_dt IS NOT NULL THEN
             IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                cst_pre_enrol,
                p_log_creation_dt,
                cst_error || ',' ||
                TO_CHAR(p_person_id) || ',' ||
                p_course_cd,
                p_message_name,
                NULL);
          END IF;
          RETURN FALSE;
      END IF;
      CLOSE c_load_cal;
  ELSE
      l_load_cal_type := p_load_cal_type;
      l_load_seq_num  := p_load_ci_seq_num;
  END IF;
  l_enr_method := p_dflt_enr_method;
  --If enrollment method not passed then derive the default enrollment method.
  IF p_dflt_enr_method IS NULL THEN
     igs_en_gen_017.enrp_get_enr_method(p_enr_method_type => l_enr_method,
                                        p_error_message   => l_dummy_mesg,
                                        p_ret_status      => l_return_status);
     IF l_return_status='FALSE' THEN
            p_warn_level := cst_error;
            p_message_name := 'IGS_SS_EN_NOENR_METHOD';
          IF p_log_creation_dt IS NOT NULL THEN
             IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                cst_pre_enrol,
                p_log_creation_dt,
                cst_error || ',' ||
                TO_CHAR(p_person_id) || ',' ||
                p_course_cd,
                p_message_name,
                NULL);
          END IF;
            RETURN FALSE;
     END IF;
  END IF;
  -- Check the eligibility
  IF p_check_eligibility_ind = 'Y' THEN
    IF NOT enrpl_check_eligibility(
          v_message_name) THEN
      p_warn_level := cst_error;
      p_message_name := v_message_name;
      RETURN FALSE;
    END IF;
  END IF;

  -- check offer
  IF NOT enrpl_check_offer(
        v_warn_level,
        v_message_name) THEN
      p_warn_level := v_warn_level;
      p_message_name := v_message_name;
      RETURN FALSE;
  END IF;

  -- create or update IGS_EN_STDNT_PS_ATT record
  enrpl_create_sca(
      v_warn_level,
      v_message_name);
  IF v_message_name is not null THEN
    p_warn_level := v_warn_level;
    p_message_name := v_message_name;
    RETURN FALSE;
  END IF;

  -- create or update IGS_AS_SC_ATMPT_ENR record
  IF NOT enrpl_create_scae(
        v_warn_level,
        v_message_name) THEN
    p_warn_level := v_warn_level;
    p_message_name := v_message_name;
    RETURN FALSE;
  END IF;

  -- Copy admissions IGS_PS_UNIT sets
  IF NOT enrpl_copy_adm_unit_sets THEN
        RETURN FALSE;
  END IF;

  -- Pre-enrollment of YOP unit Sets
  -- pass admission record's unit to en_gen_009 call
  v_unit_set_cd :=  v_acaiv_rec.unit_set_cd;

  -- In year of program mode do the following code
  -- added by smaddali for YOP-EN dld bug#2156956
  IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN

     -- If there is a currently active year of program then make it completed
     --and pre-enrol in the  next year of program , if it exists
     OPEN c_active_us ;
     FETCH c_active_us INTO c_active_us_rec;

     IF c_active_us%FOUND  THEN
         -- Check if trying to process a student who has just been pre-enrolled into the next year
         -- ie first time the process is called student is transferred to year 2 , if process is called
         -- again immediately then student should not again be pre-enrolled into year 3
         OPEN c_chk_census_dt(c_active_us_rec.unit_set_cd);
         FETCH c_chk_census_dt INTO  c_census_dt_rec;
         --moving this cursor up to fix bug 3043374, to check for the progression_outcome_type.

         OPEN  c_prog_outcome(c_active_us_rec.selection_dt) ;
             FETCH c_prog_outcome INTO c_prog_outcome_rec ;
             gv_progress_outcome_type := c_prog_outcome_rec.s_progression_outcome_type;
             CLOSE c_prog_outcome ;

         IF c_chk_census_dt%FOUND  AND NVL(P_PROGRESS_STAT,'ADVANCE') <> 'REPEATYR'
         AND NVL(gv_progress_outcome_type,'ADVANCE') = 'ADVANCE' THEN
             -- check if there is any progression outcome preventing this student
             -- from completing this unit set attempt and going into the next year of program

                 OPEN  c_susa_upd(c_active_us_rec.unit_set_cd,
                                 c_active_us_rec.us_version_number,
                                 c_active_us_rec.sequence_number) ;

                 FETCH c_susa_upd INTO c_susa_upd_rec ;

                 v_rqrmnts_complete_dt := NVL(c_prog_outcome_rec.decision_dt,TRUNC(SYSDATE));

     IF igs_en_gen_legacy.check_usa_overlap(
          c_susa_upd_rec.person_id,
          c_susa_upd_rec.course_cd,
          c_susa_upd_rec.selection_dt,
          v_rqrmnts_complete_dt,
          c_susa_upd_rec.end_dt,
          c_susa_upd_rec.sequence_number,
          c_susa_upd_rec.unit_set_cd,
          c_susa_upd_rec.us_version_number,
          p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
           END IF ;

     -- set the current year of program to completed
                 IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW (
                       X_ROWID => c_susa_upd_rec.rowid,
                       X_PERSON_ID  => c_susa_upd_rec.person_id ,
                       X_COURSE_CD  =>  c_susa_upd_rec.course_cd ,
                       X_UNIT_SET_CD  =>  c_susa_upd_rec.unit_set_cd ,
                       X_SEQUENCE_NUMBER =>  c_susa_upd_rec.sequence_number ,
                       X_US_VERSION_NUMBER =>  c_susa_upd_rec.us_version_number,
                       X_SELECTION_DT =>  c_susa_upd_rec.selection_dt ,
                       X_STUDENT_CONFIRMED_IND =>  c_susa_upd_rec.student_confirmed_ind ,
                       X_END_DT =>  c_susa_upd_rec.end_dt ,
                       X_PARENT_UNIT_SET_CD =>  c_susa_upd_rec.parent_unit_set_cd,
                       X_PARENT_SEQUENCE_NUMBER =>  c_susa_upd_rec.parent_sequence_number ,
                       X_PRIMARY_SET_IND =>  c_susa_upd_rec.primary_set_ind ,
                       X_VOLUNTARY_END_IND =>  c_susa_upd_rec.voluntary_end_ind ,
                       X_AUTHORISED_PERSON_ID =>  c_susa_upd_rec.authorised_person_id,
                       X_AUTHORISED_ON =>  c_susa_upd_rec.authorised_on ,
                       X_OVERRIDE_TITLE =>  c_susa_upd_rec.override_title ,
                       X_RQRMNTS_COMPLETE_IND =>  'Y' ,
                       X_RQRMNTS_COMPLETE_DT =>  v_rqrmnts_complete_dt ,
                       X_S_COMPLETED_SOURCE_TYPE =>  c_susa_upd_rec.s_completed_source_type,
                       X_CATALOG_CAL_TYPE =>  c_susa_upd_rec.catalog_cal_type ,
                       X_CATALOG_SEQ_NUM =>  c_susa_upd_rec.catalog_seq_num,
                       X_ATTRIBUTE_CATEGORY  => c_susa_upd_rec.attribute_category,
                       X_ATTRIBUTE1  => c_susa_upd_rec.attribute1 ,
                       X_ATTRIBUTE2  => c_susa_upd_rec.attribute2 ,
                       X_ATTRIBUTE3  => c_susa_upd_rec.attribute3,
                       X_ATTRIBUTE4  => c_susa_upd_rec.attribute4,
                       X_ATTRIBUTE5  => c_susa_upd_rec.attribute5,
                       X_ATTRIBUTE6  => c_susa_upd_rec.attribute6,
                       X_ATTRIBUTE7  => c_susa_upd_rec.attribute7,
                       X_ATTRIBUTE8  => c_susa_upd_rec.attribute8,
                       X_ATTRIBUTE9  => c_susa_upd_rec.attribute9,
                       X_ATTRIBUTE10  => c_susa_upd_rec.attribute10,
                       X_ATTRIBUTE11  => c_susa_upd_rec.attribute11,
                       X_ATTRIBUTE12  => c_susa_upd_rec.attribute12,
                       X_ATTRIBUTE13  => c_susa_upd_rec.attribute13,
                       X_ATTRIBUTE14  => c_susa_upd_rec.attribute14,
                       X_ATTRIBUTE15  => c_susa_upd_rec.attribute15,
                       X_ATTRIBUTE16  => c_susa_upd_rec.attribute16,
                       X_ATTRIBUTE17  => c_susa_upd_rec.attribute17,
                       X_ATTRIBUTE18  => c_susa_upd_rec.attribute18,
                       X_ATTRIBUTE19  => c_susa_upd_rec.attribute19,
                       X_ATTRIBUTE20  => c_susa_upd_rec.attribute20,
                       X_MODE =>  'R'  );

                       IF NOT update_stream_unit_sets(
               p_person_id,
         p_course_Cd,
         c_susa_upd_rec.unit_set_cd,
         'Y', --RQRMNTS_COMPLETE_IND
         v_rqrmnts_complete_dt,
         c_susa_upd_rec.selection_dt,
         c_susa_upd_rec.student_confirmed_ind,
         p_log_creation_dt,
         p_message_name
             ) THEN
             RETURN FALSE;
          END IF;

               CLOSE  c_susa_upd ;
               -- get the next year in sequence
               OPEN  c_next_us(c_active_us_rec.unit_set_cd) ;
               FETCH c_next_us  INTO  c_next_us_rec ;
               IF  c_next_us%FOUND  THEN

                  -- find the version number for the new unit set
                  OPEN c_us_version_number(p_person_id,p_course_cd,c_next_us_rec.unit_set_cd);
                  FETCH c_us_version_number INTO next_us_version;
                  IF c_us_version_number%FOUND  THEN

                     -- If next year of program exists then pre-enroll in it
                     IF NOT  create_unit_set(
               p_person_id,
               p_course_cd,
               c_next_us_rec.unit_set_cd,
               next_us_version,
               v_rqrmnts_complete_dt+1,
               l_confirmed_ind,
               NULL,
               NULL,
               l_seqval,
               p_log_creation_dt,
               p_message_name
             )  THEN
             RETURN FALSE;
         END IF;

                     v_unit_set_cd  :=   c_next_us_rec.unit_set_cd ;

                     IF NOT  create_stream_unit_sets(
               p_person_id,
               p_course_cd,
               c_next_us_rec.unit_set_cd,
               v_rqrmnts_complete_dt,
               l_confirmed_ind,
               p_log_creation_dt,
               p_message_name
             )  THEN
             RETURN FALSE;
         END IF;

                     -- smaddali 14-may-2002 added new parameter p_old_sequence_number for bug#2350629
                     IF l_seqval IS NOT NULL THEN
                       copy_hesa_details(
                        p_person_id,
                        p_course_cd,
                        v_acaiv_rec.crv_version_number,
                        c_active_us_rec.unit_set_cd,
                        c_active_us_rec.us_version_number,
                        c_active_us_rec.sequence_number ,
                        c_next_us_rec.unit_set_cd,
                        next_us_version,
                        l_seqval );
                     END IF;

                  ELSE
                      CLOSE c_us_version_number ;
                      CLOSE c_next_us ;
                      CLOSE  c_chk_census_dt ;
                      RETURN TRUE ;
                  END IF; -- if next unit set version is found
                  CLOSE c_us_version_number ;

               ELSE
                    CLOSE c_next_us ;
                    CLOSE  c_chk_census_dt ;
                    RETURN TRUE ;
               END IF; -- found next unit set in sequence
               CLOSE c_next_us ;

         END IF ; -- chk_census_dt
         CLOSE  c_chk_census_dt ;

      ELSE  -- no active unit set attempts found

         -- find the first  unit set  in sequence which is defined for the program ofering
         IF (v_acaiv_rec.unit_set_cd  IS NULL)  OR  (NOT prenrl_year(v_acaiv_rec.unit_set_cd)) THEN
             OPEN c_first_us ;
             FETCH c_first_us INTO l_first_us ;
             IF c_first_us%FOUND THEN
                -- set the selection_date
             --the selection date is set to the SPA commencement date as part of bug 3687470

                 v_selection_dt  := NULL;
                IF NVL(l_confirmed_ind,'N') = 'Y' THEN
                   OPEN cur_spa;
                   FETCH cur_spa INTO v_selection_dt;
                   CLOSE cur_spa;
               END IF;
                --check if this unit set attempt already exists
                OPEN c_exists_susa(l_first_us.unit_set_cd,l_first_us.us_version_number);
                FETCH c_exists_susa INTO  c_exists_susa_rec ;
                IF c_exists_susa%FOUND THEN
                  IF c_exists_susa_rec.student_confirmed_ind <> l_confirmed_ind THEN
                  OPEN  c_susa_upd(l_first_us.unit_set_cd,l_first_us.us_version_number, c_exists_susa_rec.sequence_number) ;
                  FETCH c_susa_upd INTO c_susa_upd_rec ;

      IF igs_en_gen_legacy.check_usa_overlap(
           c_susa_upd_rec.person_id,
           c_susa_upd_rec.course_cd,
           TRUNC(v_selection_dt),
           c_susa_upd_rec.RQRMNTS_COMPLETE_DT,
           c_susa_upd_rec.end_dt,
           c_susa_upd_rec.sequence_number,
           c_susa_upd_rec.unit_set_cd,
           c_susa_upd_rec.us_version_number,
           p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
            END IF;

                  IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW (
                     X_ROWID => c_susa_upd_rec.rowid,
                     X_PERSON_ID  => c_susa_upd_rec.person_id,
                     X_COURSE_CD  =>  c_susa_upd_rec.course_cd ,
                     X_UNIT_SET_CD  =>  c_susa_upd_rec.unit_set_cd ,
                     X_SEQUENCE_NUMBER =>  c_susa_upd_rec.sequence_number ,
                     X_US_VERSION_NUMBER =>  c_susa_upd_rec.us_version_number ,
                     X_SELECTION_DT => TRUNC(v_selection_dt) ,
                     X_STUDENT_CONFIRMED_IND =>  l_confirmed_ind ,
                     X_END_DT =>  c_susa_upd_rec.end_dt ,
                     X_PARENT_UNIT_SET_CD => c_susa_upd_rec.parent_unit_set_cd,
                     X_PARENT_SEQUENCE_NUMBER => c_susa_upd_rec.PARENT_SEQUENCE_NUMBER ,
                     X_PRIMARY_SET_IND =>  c_susa_upd_rec.PRIMARY_SET_IND ,
                     X_VOLUNTARY_END_IND =>  c_susa_upd_rec.VOLUNTARY_END_IND ,
                     X_AUTHORISED_PERSON_ID =>  c_susa_upd_rec.AUTHORISED_PERSON_ID ,
                     X_AUTHORISED_ON =>  c_susa_upd_rec.AUTHORISED_ON ,
                     X_OVERRIDE_TITLE =>  c_susa_upd_rec.OVERRIDE_TITLE  ,
                     X_RQRMNTS_COMPLETE_IND =>  c_susa_upd_rec.RQRMNTS_COMPLETE_IND ,
                     X_RQRMNTS_COMPLETE_DT =>   c_susa_upd_rec.RQRMNTS_COMPLETE_DT ,
                     X_S_COMPLETED_SOURCE_TYPE =>   c_susa_upd_rec.S_COMPLETED_SOURCE_TYPE,
                     X_CATALOG_CAL_TYPE =>   c_susa_upd_rec.CATALOG_CAL_TYPE,
                     X_CATALOG_SEQ_NUM =>   c_susa_upd_rec.CATALOG_SEQ_NUM,
                     X_ATTRIBUTE_CATEGORY  => c_susa_upd_rec.ATTRIBUTE_CATEGORY,
                     X_ATTRIBUTE1  => c_susa_upd_rec.ATTRIBUTE1,
                     X_ATTRIBUTE2  => c_susa_upd_rec.ATTRIBUTE2,
                     X_ATTRIBUTE3  => c_susa_upd_rec.ATTRIBUTE3,
                     X_ATTRIBUTE4  => c_susa_upd_rec.ATTRIBUTE4,
                     X_ATTRIBUTE5  => c_susa_upd_rec.ATTRIBUTE5,
                     X_ATTRIBUTE6  => c_susa_upd_rec.ATTRIBUTE6,
                     X_ATTRIBUTE7  => c_susa_upd_rec.ATTRIBUTE7,
                     X_ATTRIBUTE8  => c_susa_upd_rec.ATTRIBUTE8,
                     X_ATTRIBUTE9  => c_susa_upd_rec.ATTRIBUTE9,
                     X_ATTRIBUTE10  => c_susa_upd_rec.ATTRIBUTE10,
                     X_ATTRIBUTE11  =>c_susa_upd_rec.ATTRIBUTE11,
                     X_ATTRIBUTE12  => c_susa_upd_rec.ATTRIBUTE12,
                     X_ATTRIBUTE13  => c_susa_upd_rec.ATTRIBUTE13,
                     X_ATTRIBUTE14  => c_susa_upd_rec.ATTRIBUTE14,
                     X_ATTRIBUTE15  => c_susa_upd_rec.ATTRIBUTE15,
                     X_ATTRIBUTE16  => c_susa_upd_rec.ATTRIBUTE16,
                     X_ATTRIBUTE17  => c_susa_upd_rec.ATTRIBUTE17,
                     X_ATTRIBUTE18  => c_susa_upd_rec.ATTRIBUTE18,
                     X_ATTRIBUTE19  => c_susa_upd_rec.ATTRIBUTE19,
                     X_ATTRIBUTE20  => c_susa_upd_rec.ATTRIBUTE20,
                     X_MODE =>  'R'   );
                    CLOSE c_susa_upd ;

                    IF NOT update_stream_unit_sets(
            p_person_id,
            p_course_cd,
            c_susa_upd_rec.unit_set_cd,
            c_susa_upd_rec.rqrmnts_complete_ind,
            c_susa_upd_rec.rqrmnts_complete_dt,
            v_selection_dt,
            l_confirmed_ind,
            p_log_creation_dt,
            p_message_name
          ) THEN
          RETURN FALSE;
        END IF;

                  END IF;
                ELSE

                    IF NOT create_unit_set(
            p_person_id,
            p_course_cd,
            l_first_us.unit_set_cd,
            l_first_us.us_version_number,
            v_selection_dt,
            l_confirmed_ind,
            NULL,
            NULL,
            l_seqval,
            p_log_creation_dt,
            p_message_name
          ) THEN
          RETURN FALSE;
        END IF;
                    v_unit_set_cd  :=   l_first_us.unit_set_cd ;

                    IF NOT create_stream_unit_sets(
            p_person_id,
            p_course_cd,
            l_first_us.unit_set_cd,
            v_selection_dt,
            l_confirmed_ind,
            p_log_creation_dt,
            p_message_name
          )  THEN
          RETURN FALSE;
         END IF;


                    -- smaddali 14-may-2002 added new parameter p_old_sequence_number for bug#2350629
                    -- also the values passed were wrong ,so changed values passed for new unit set parameters
                    IF l_seqval IS NOT NULL THEN
                      copy_hesa_details( p_person_id,
                        p_course_cd,
                        v_acaiv_rec.crv_version_number,
                        NULL,
                        NULL,
                        NULL,
                        l_first_us.unit_set_cd,
                        l_first_us.us_version_number,
                        l_seqval
                      );
                    END IF;

                END IF; -- if susa already exists
                CLOSE c_exists_susa ;

             END IF; -- found the first unit set
             CLOSE  c_first_us ;
         END IF; -- if unit set selected in the admissions is not of type year

      END IF; -- found an active unit set attempt
      CLOSE  c_active_us ;
  END IF;   -- profile set to year of program

  --bmerugu added condition for build 319
  IF (l_sua_create = TRUE) THEN
     BEGIN
	  -- Pre-enrollment of Unit Attempts
	  -- copy admissions IGS_EN_SU_ATTEMPT
	  enrpl_copy_adm_sua(
	      v_warn_level,
	      v_message_name,
	      v_adm_added_ind,
	      l_enr_method,
	      l_load_cal_type,
	      l_load_seq_num);
	  IF v_message_name is not null THEN
	    IF p_warn_level IS NULL OR
		(p_warn_level = cst_minor AND
		      v_warn_level IN (cst_major,
		    cst_error)) OR
		(p_warn_level = cst_major AND
		v_warn_level = cst_error) THEN
	      p_warn_level := v_warn_level;
	      p_message_name := v_message_name;
	    END IF;
	  END IF;

	  IF v_adm_added_ind = 'N' THEN
	    -- Pre-enrol IGS_PS_UNIT attempts entered during Admissions, as parameter
	    -- to the process.
	    -- create parameter IGS_EN_SU_ATTEMPT
	    enrpl_copy_param_sua(
	      p_warn_level       => v_warn_level,
	      p_message_name     => v_message_name,
	      p_added_ind        => v_parm_added_ind,
	      p_enr_method       => l_enr_method,
	      p_lload_cal_type   => l_load_cal_type,
	      p_lload_ci_seq_num => l_load_seq_num);
	    IF v_message_name is not null THEN
	      IF p_warn_level IS NULL OR
		  (p_warn_level = cst_minor AND
		  v_warn_level IN (cst_major,
		      cst_error)) OR
		    (p_warn_level = cst_major AND
		  v_warn_level = cst_error) THEN
		p_warn_level := v_warn_level;
		p_message_name := v_message_name;
	      END IF;
	    END IF;

	    IF v_parm_added_ind = 'N' THEN
	       -- If pre enrolment of units is required then pre-enrol the units.
	       IF ( p_units_indicator = 'Y'  OR p_units_indicator = 'CORE_ONLY' )THEN

		   -- Pre-enrol IGS_PS_UNIT attempts entered during Admissions
		   -- through the Pattern of Study.
		   -- create pattern of study IGS_EN_SU_ATTEMPT
		   enrpl_create_pos_sua(
			p_unit_set_cd      => v_unit_set_cd,
			p_warn_level       => v_warn_level,
			p_message_name     => v_message_name,
			p_enr_method       => l_enr_method,
			p_lload_cal_type   => l_load_cal_type,
			p_lload_ci_seq_num => l_load_seq_num);
		   IF v_message_name is not null THEN
		      IF p_warn_level IS NULL OR
				(p_warn_level = cst_minor AND
			  v_warn_level IN (cst_major,
			      cst_error)) OR
			    (p_warn_level = cst_major AND
			  v_warn_level = cst_error) THEN
			  p_warn_level := v_warn_level;
			  p_message_name := v_message_name;
		      END IF;
		       --if the warn level is major then return false, since it implies that no units were enrolled.
		    IF v_warn_level = cst_major THEN
		    RETURN FALSE;
		    END IF;
		   END IF;
	       END IF; -- end of p_units_indicator
	    END IF; -- end of v_parm_added_ind
	  END IF; -- end of v_adm_added_ind
       END;
  END IF; -- end of l_sua_create


  enrpl_create_fee_contract(
         p_warn_level,
         p_message_name);
  RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_acaiv%ISOPEN THEN
        CLOSE c_acaiv;
      END IF;
      IF c_acaiv1%ISOPEN THEN
        CLOSE c_acaiv1;
      END IF;
      --checking if it is not an unhandled exception since unhandled exceptions may not b ein realtion to a particular student
    -- and may cause the process to fail for every student.
    -- hence raise the exception if it is and unhandled exceptions
    --rollback to the beginning of the rpocedure to undo the changes made for teh student who is erroring out.
      IF p_log_creation_dt IS NOT NULL THEN
          IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
          FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
          p_warn_level := cst_error;
          ROLLBACK TO sp_pre_enrol_student;
         IF l_message_name <> 'IGS_GE_UNHANDLED_EXP' THEN

               IF  (l_message_name IS NOT NULL) THEN
                   -- If the log creation date is set then log the HECS error
                    -- This is if the pre-enrolment is being performed in batch.
                    log_error_message(p_s_log_type        => cst_pre_enrol,
                                      p_creation_dt       => p_log_creation_dt,
                                      p_sle_key           => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                      p_sle_message_name  => l_message_name,
                                      p_del               => ';');
                END IF;
         ELSE
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                 FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_snew_prenrl');
                 l_mesg_txt := fnd_message.get;
                 igs_ge_gen_003.genp_ins_log_entry(p_s_log_type       => cst_pre_enrol,
                                                   p_creation_dt      => p_log_creation_dt,
                                                   p_key              => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                                   p_s_message_name   => 'IGS_GE_UNHANDLED_EXP',
                                                   p_text             => l_mesg_txt);
         END IF;
         l_message_name := NULL;
      ELSE
        IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_en_gen_010.enrp_ins_snew_prenrl.UNH_EXP','Unhandled Exception raised with code '||SQLCODE||' and error '||SQLERRM);
        END IF;
        RAISE;
      END IF;
  END;
END enrp_ins_snew_prenrl;

FUNCTION Enrp_Ins_Sret_Prenrl(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_enrolment_cat               IN VARCHAR2 ,
  p_acad_cal_type               IN VARCHAR2 ,
  p_acad_sequence_number        IN NUMBER ,
  p_enrol_cal_type              IN VARCHAR2 ,
  p_enrol_sequence_number       IN NUMBER ,
  p_units_ind                   IN VARCHAR2,
  p_override_enr_form_due_dt    IN DATE ,
  p_override_enr_pckg_prod_dt   IN DATE ,
  p_log_creation_dt             IN DATE ,
  p_warn_level                  OUT NOCOPY VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2  ,
  p_unit1_unit_cd               IN VARCHAR2 ,
  p_unit1_cal_type              IN VARCHAR2 ,
  p_unit1_location_cd           IN VARCHAR2 ,
  p_unit1_unit_class            IN VARCHAR2 ,
  p_unit2_unit_cd               IN VARCHAR2 ,
  p_unit2_cal_type              IN VARCHAR2 ,
  p_unit2_location_cd           IN VARCHAR2 ,
  p_unit2_unit_class            IN VARCHAR2 ,
  p_unit3_unit_cd               IN VARCHAR2 ,
  p_unit3_cal_type              IN VARCHAR2 ,
  p_unit3_location_cd           IN VARCHAR2 ,
  p_unit3_unit_class            IN VARCHAR2 ,
  p_unit4_unit_cd               IN VARCHAR2 ,
  p_unit4_cal_type              IN VARCHAR2 ,
  p_unit4_location_cd           IN VARCHAR2 ,
  p_unit4_unit_class            IN VARCHAR2 ,
  p_unit5_unit_cd               IN VARCHAR2 ,
  p_unit5_cal_type              IN VARCHAR2 ,
  p_unit5_location_cd           IN VARCHAR2 ,
  p_unit5_unit_class            IN VARCHAR2 ,
  p_unit6_unit_cd               IN VARCHAR2 ,
  p_unit6_cal_type              IN VARCHAR2 ,
  p_unit6_location_cd           IN VARCHAR2 ,
  p_unit6_unit_class            IN VARCHAR2 ,
  p_unit7_unit_cd               IN VARCHAR2 ,
  p_unit7_cal_type              IN VARCHAR2 ,
  p_unit7_location_cd           IN VARCHAR2 ,
  p_unit7_unit_class            IN VARCHAR2 ,
  p_unit8_unit_cd               IN VARCHAR2 ,
  p_unit8_cal_type              IN VARCHAR2 ,
  p_unit8_location_cd           IN VARCHAR2 ,
  p_unit8_unit_class            IN VARCHAR2 ,
  p_unit9_unit_cd               IN VARCHAR2 ,
  p_unit9_cal_type              IN VARCHAR2 ,
  p_unit9_location_cd           IN VARCHAR2 ,
  p_unit9_unit_class            IN VARCHAR2 ,
  p_unit10_unit_cd              IN VARCHAR2 ,
  p_unit10_cal_type             IN VARCHAR2 ,
  p_unit10_location_cd          IN VARCHAR2 ,
  p_unit10_unit_class           IN VARCHAR2 ,
  p_unit11_unit_cd              IN VARCHAR2 ,
  p_unit11_cal_type             IN VARCHAR2 ,
  p_unit11_location_cd          IN VARCHAR2 ,
  p_unit11_unit_class           IN VARCHAR2 ,
  p_unit12_unit_cd              IN VARCHAR2 ,
  p_unit12_cal_type             IN VARCHAR2 ,
  p_unit12_location_cd          IN VARCHAR2 ,
  p_unit12_unit_class           IN VARCHAR2 ,
  p_unit_set_cd1                IN VARCHAR2 ,
  p_unit_set_cd2                IN VARCHAR2 ,
  --Added the parameter p_selection_date - UK Enhancement Build - Enh Bug#2580731 - 07OCT2002
  p_selection_date              IN DATE ,
  --Added the parameter p_completion_date - ENCR030(UK Enh) Build - Enh Bug#2708430 - 16DEC2002
  p_completion_date             IN DATE ,
  p_progress_stat               IN VARCHAR2,
  p_dflt_enr_method             IN VARCHAR2,
  p_load_cal_type               IN VARCHAR2,
  p_load_ci_seq_num             IN NUMBER
 )
RETURN boolean AS
/* HISTORY
   WHO         WHEN         WHAT
   bdeviset  29-JUL-2004   Before calling IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW/INSERT_ROW in a check is
         made to see that their is no overlapping of selection,completion and
                           end dates for any two unit sets by calling check_usa_overlap.If it returns
                           false log entry is made and the insert or update is not carried out for bug 3149133.
   ayedubat  4-JUN-2002    Changed the Code of YOP for Unit Set pre-enrollment before
                           the Units pre-enrollment Code for the bug fix: 2391842
   ayedubat  25-MAY-2002   Changed the cursors c_acaiv to replace the view,IGS_AD_PS_APPL_INST_APLINST_V
                           with the base table,IGS_AD_PS_APPL_INST as part of the bug fix:2384449
   ayedubat   15-MAY-2002  Changed the cursor,c_chk_census_dt to consider only the SUA records with unit attempt status
                              'ENROLLED','DISCONTIN','DUPLICATE' or 'COMPLETED' as part of the bug:2372892
   Nishikant   07OCT2002    UK Enhancement Build - Enh Bug#2580731 - Added the parameter p_selection_date in this Function
   Nishikant   16DEC2002    ENCR030(UK Enh) Build - Enh Bug#2708430 - Added the parameter p_completion_date in this Function
   svanukur  10-jul-2003   checking for parameter P_PROGRESS_STAT , if it is set to 'ADVANCE' as part of bug #3043374
   ptandon   06-Oct-2003   Modified the inline procedure enrpl_copy_param_sua as part of Prevent Dropping Core Units.
                           Enh Bug# 3052432.
   svanukur  20-jul-2004   Added a check after call to procedure IGS_EN_GEN_009.enrp_ins_pre_pos to return false to igs_en_gen_008
                           so that the message successfully preenrolled is not shown in the log file. BUG 3032588.
 */
BEGIN -- enrp_ins_sret_prenrl
  -- This process will pre-enrol a single returning student in the specified
  -- IGS_PS_COURSE. The following steps will be performed :
  -- * Check the students eligibility to enrol in the specified IGS_PS_COURSE in the
  -- specified academic calendar.
  -- * Determine the enrolment category from either a previous pre-enrolment
  -- or the default enrolment category passed to the routine.
  -- * Create IGS_AS_SC_ATMPT_ENR record.
  -- * Pre-enrol the students IGS_EN_SU_ATTEMPT records (next phase)
  -- If at any point it becomes impossible to pre-enrol the student, the
  -- routine will return FALSE and message number of a message indicating the
  -- reason for failure. This can be used by the calling routine (whether batch
  -- or online) to indicate who was and wasn't pre-enrolled.


 DECLARE
  cst_return    CONSTANT VARCHAR2(10) := 'RETURN';
  cst_pre_enrol   CONSTANT VARCHAR2(10) := 'PRE-ENROL';
  -- warn level types
  cst_error   CONSTANT VARCHAR2(5) := 'ERROR';
  cst_minor   CONSTANT VARCHAR2(5) := 'MINOR';
  cst_major   CONSTANT VARCHAR2(5) := 'MAJOR';
  l_enc_message_name VARCHAR2(2000);
  l_app_short_name VARCHAR2(10);
  l_message_name VARCHAR2(100);
  l_mesg_txt VARCHAR2(4000);
  l_msg_index NUMBER;
  CURSOR c_sca_details IS
    SELECT  sca.cal_type,
      sca.course_cd,
      sca.version_number,
      sca.location_cd,
      sca.attendance_mode,
      sca.attendance_type,
      sca.adm_admission_appl_number,
      sca.adm_nominated_course_cd,
      sca.adm_sequence_number
    FROM  IGS_EN_STDNT_PS_ATT sca
    WHERE sca.person_id = p_person_id AND
      sca.course_cd = p_course_cd;
  v_sca_rec c_sca_details%ROWTYPE;

  CURSOR c_prev_enr_cat IS
    SELECT  scae.enrolment_cat
    FROM  IGS_AS_SC_ATMPT_ENR scae,
      IGS_CA_INST ci
    WHERE scae.person_id     = p_person_id  AND
      scae.course_cd     = p_course_cd  AND
      ci.cal_type      = scae.cal_type AND
      ci.sequence_number = scae.ci_sequence_number
    ORDER BY ci.end_dt DESC;

CURSOR c_scae_details IS
    SELECT  enrolment_cat
    FROM  IGS_AS_SC_ATMPT_ENR scae
    WHERE scae.person_id          = p_person_id AND
      scae.course_cd    = p_course_cd AND
      scae.cal_type     = p_enrol_cal_type  AND
      scae.ci_sequence_number = p_enrol_sequence_number;
  --v_scae_details  VARCHAR2(1);


  v_scae_details IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE;
  CURSOR c_scae_upd IS
        SELECT  rowid,
                IGS_AS_SC_ATMPT_ENR.*
        FROM  IGS_AS_SC_ATMPT_ENR
        WHERE person_id     = p_person_id AND
          course_cd     = p_course_cd AND
          cal_type    = p_enrol_cal_type AND
          ci_sequence_number  = p_enrol_sequence_number
        FOR UPDATE OF enrolment_cat NOWAIT;

      v_scae_upd_rec    c_scae_upd%ROWTYPE;



  CURSOR c_crv (
    cp_course_cd    IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
    cp_version_number   IGS_EN_STDNT_PS_ATT.version_number%TYPE,
    cp_cal_type     IGS_EN_STDNT_PS_ATT.cal_type%TYPE,
    cp_location_cd    IGS_EN_STDNT_PS_ATT.location_cd%TYPE,
    cp_attendance_mode  IGS_EN_STDNT_PS_ATT.attendance_mode%TYPE,
    cp_attendance_type  IGS_EN_STDNT_PS_ATT.attendance_type%TYPE) IS
    SELECT  'x'
    FROM  IGS_PS_VER    crv,
      IGS_PS_STAT     cs,
      IGS_PS_OFR_PAT cop
    WHERE crv.course_cd     = cp_course_cd AND
      crv.version_number  = cp_version_number AND
      crv.expiry_dt     IS NULL AND
      cs.COURSE_STATUS  = crv.COURSE_STATUS AND
      cs.s_course_status  = 'ACTIVE' AND
      cop.course_cd   = crv.course_cd AND
      cop.version_number  = crv.version_number AND
      cop.cal_type    = cp_cal_type AND
      cop.ci_sequence_number  = p_acad_sequence_number AND
      cop.location_cd   = cp_location_cd AND
      cop.attendance_mode   = cp_attendance_mode AND
      cop.attendance_type   = cp_attendance_type AND
      cop.offered_ind   = 'Y';
   v_crv_rec  VARCHAR2(1);

   -- Cursor to fetch the Unit Set and Admission Cal Type and Category of the pre-enrolling students.
   CURSOR c_acaiv(
       cp_adm_admission_appl_number IGS_EN_STDNT_PS_ATT.adm_admission_appl_number%TYPE,
       cp_adm_nominated_course_cd   IGS_EN_STDNT_PS_ATT.adm_nominated_course_cd%TYPE,
       cp_adm_sequence_number       IGS_EN_STDNT_PS_ATT.adm_sequence_number%TYPE ) IS
     SELECT acaiv.unit_set_cd,
            acaiv.adm_cal_type,
            aa.admission_cat
     FROM IGS_AD_PS_APPL_INST acaiv,
          IGS_AD_APPL         aa
     WHERE
          acaiv.person_id               = p_person_id                  AND
          acaiv.admission_appl_number   = cp_adm_admission_appl_number AND
          acaiv.nominated_course_cd     = cp_adm_nominated_course_cd   AND
          acaiv.sequence_number         = cp_adm_sequence_number       AND
          aa.person_id                  = acaiv.person_id              AND
          aa.admission_appl_number      = acaiv.admission_appl_number;

   v_acaiv_rec    c_acaiv%ROWTYPE;

   CURSOR c_susa IS
    SELECT  susa.unit_set_cd
    FROM  IGS_AS_SU_SETATMPT susa
    WHERE susa.person_id    = p_person_id AND
      susa.course_cd    = p_course_cd AND
      susa.student_confirmed_ind = 'Y' AND
      susa.end_dt     IS NULL;
  v_susa_rec    c_susa%ROWTYPE;
  v_enrolment_cat   IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE;
  v_enr_cat   IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE;
  v_unit_set_cd     IGS_AD_PS_APPL_INST_APLINST_V.unit_set_cd%TYPE;
  v_adm_cal_type    IGS_AD_PS_APPL_INST_APLINST_V.adm_cal_type%TYPE;
  v_admission_cat   IGS_AD_APPL.admission_cat%TYPE;
  v_warn_level    VARCHAR2(10) ;
  v_log_creation_dt DATE;
  v_message_name    VARCHAR2(2000);
  v_row_count     NUMBER(1) := 0;
  v_boolean     BOOLEAN;

  --The below variable added as part of ENCR030(UK Enh) - Bug#2708430 - 16DEC2002
  l_completion_date DATE;

        -- smaddali added these variables and cursors and local procedure enrpl_copy_param_sua for yop-en build bug# 2156956
  v_parm_added_ind  VARCHAR2(1);
        cst_unconfirm   CONSTANT VARCHAR2(10) := 'UNCONFIRM';
        l_pos_count             NUMBER(1)  := 0;
        l_rowid VARCHAR2(25);
    l_seqval        igs_as_su_setatmpt.sequence_number%TYPE ;

  CURSOR c_pos_unit_sets( cp_version_number igs_ps_pat_of_study.version_number%TYPE)  IS
  SELECT unit_set_cd
  FROM IGS_PS_PAT_OF_STUDY pos
  WHERE  course_cd = p_course_cd AND
         version_number = cp_version_number  AND
         cal_type = p_acad_cal_type AND
         unit_set_cd  IN
           ( SELECT susa.unit_set_cd
              FROM  IGS_AS_SU_SETATMPT susa
              WHERE susa.person_id    = p_person_id AND
                susa.course_cd    = pos.course_cd AND
                susa.student_confirmed_ind = 'Y' AND
                susa.end_dt     IS NULL);

   -- checks the eligibility of the student to be moved to the next year of program (unit set)
   -- by checking if there is any outcome preventing the progress of the student program attempt
   CURSOR  c_prog_outcome(cp_select_dt  igs_as_su_setatmpt.selection_dt%TYPE) IS
     SELECT  pou.decision_dt, pout.s_progression_outcome_type
     FROM  igs_pr_stdnt_pr_ou_all pou , igs_pr_ou_type pout
     WHERE   pou.person_id = p_person_id  AND
       pou.course_cd  = p_course_cd  AND
       pou.decision_status = 'APPROVED'  AND
       pou.decision_dt IS NOT NULL        AND
       pou.decision_dt  >  cp_select_dt AND
       pou.progression_outcome_type = pout.progression_outcome_type
     ORDER BY pou.decision_dt desc ;
      c_prog_outcome_rec   c_prog_outcome%ROWTYPE;
      gv_progress_outcome_type  igs_pr_ou_type.s_progression_outcome_type%TYPE;

      -- get the currently active unit set for the person course attempt
      CURSOR c_active_us IS
      SELECT susa.*
      FROM  igs_as_su_setatmpt susa , igs_en_unit_set us , igs_en_unit_set_cat usc
      WHERE  susa.person_id = p_person_id  AND
       susa.course_cd  = p_course_cd  AND
       susa.selection_dt IS NOT NULL AND
       susa.end_dt IS NULL AND
       susa.rqrmnts_complete_dt  IS NULL AND
       susa.unit_set_cd = us.unit_set_cd AND
       us.unit_set_cat = usc.unit_set_cat AND
       usc.s_unit_set_cat  = 'PRENRL_YR' ;
      c_active_us_rec  c_active_us%ROWTYPE;

      --get the next unit set in sequence
      CURSOR  c_next_us(cp_unit_set_cd igs_ps_us_prenr_cfg.unit_set_cd%TYPE) IS
      SELECT cf1.unit_set_cd , cf1.sequence_no
      FROM   igs_ps_us_prenr_cfg cf1 , igs_ps_us_prenr_cfg  cf2
      WHERE  cf2.mapping_set_cd = cf1.mapping_set_cd  AND
       cf2.unit_set_cd = cp_unit_set_cd  AND
       cf1.sequence_no >  cf2.sequence_no
      ORDER BY cf1.sequence_no asc;
      c_next_us_rec   c_next_us%ROWTYPE;

      CURSOR c_us_version_number(cp_person_id  igs_en_stdnt_ps_att.person_id%TYPE,
                                 cp_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE,
                                 cp_unit_set_cd  igs_en_unit_set.unit_set_cd%TYPE) IS
      SELECT coous.us_version_number
      FROM  igs_en_unit_set_stat uss, igs_ps_ofr_opt_unit_set_v  coous, igs_en_stdnt_ps_att sca
      WHERE  sca.person_id = cp_person_id AND
             sca.course_cd = cp_course_cd AND
             sca.coo_id = coous.coo_id AND
             coous.unit_set_cd = cp_unit_set_cd AND
             coous.expiry_dt  IS NULL AND
            coous.unit_set_status = uss.unit_set_status AND
            uss.s_unit_set_status = 'ACTIVE'  ;
      next_us_version  igs_en_unit_set.version_number%TYPE;

      -- find the last active unit set for the person program
      CURSOR c_last_us  IS
      SELECT susa.unit_set_cd, susa.us_version_number ,susa.sequence_number ,susa.rqrmnts_complete_dt
             , susa.selection_dt
      FROM  igs_as_su_setatmpt susa , igs_en_unit_set us , igs_en_unit_set_cat usc
      WHERE susa.person_id = p_person_id AND
        susa.course_cd = p_course_cd  AND
        susa.rqrmnts_complete_dt IS NOT NULL   AND
        susa.unit_set_cd = us.unit_set_cd AND
        us.unit_set_cat = usc.unit_set_cat AND
        usc.s_unit_set_cat  = 'PRENRL_YR'
      ORDER BY susa.rqrmnts_complete_dt  desc ;
      l_last_us  c_last_us%ROWTYPE ;

     CURSOR c_chk_census_dt(cp_unit_set_cd igs_en_unit_set.unit_set_cd%TYPE)  IS
     SELECT sua.*
     FROM  igs_en_sua_year_v sua
     WHERE  sua.person_id = p_person_id AND
         sua.course_cd  = p_course_cd  AND
         sua.unit_set_cd = cp_unit_set_cd AND
         sua.unit_attempt_status IN ('ENROLLED','DISCONTIN','DUPLICATE','COMPLETED') AND
         IGS_EN_GEN_015.get_effective_census_date(Null,Null,sua.cal_type,sua.ci_sequence_number) < TRUNC(SYSDATE);
      c_census_dt_rec  c_chk_census_dt%ROWTYPE ;
      v_dummy         VARCHAR2(1);

     CURSOR c_load_cal(p_acad_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                       p_acad_seq_num  IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
     SELECT rel.sub_cal_type, rel.sub_ci_sequence_number FROM igs_ca_inst_rel rel,
                                                               igs_ca_inst ci,
                                                               igs_ca_type cal
                                                          WHERE rel.sup_cal_type           = p_acad_cal_type
                                                          AND   rel.sup_ci_sequence_number = p_acad_seq_num
                                                          AND   rel.sub_cal_type           = ci.cal_type
                                                          AND   rel.sub_ci_sequence_number = ci.sequence_number
                                                          AND   rel.sub_cal_type           = cal.cal_type
                                                          AND   cal.s_cal_cat              = 'LOAD'
                                                          AND   cal.closed_ind             = 'N'
                                                          ORDER BY ci.start_dt;
     l_load_cal_type         igs_ca_inst.cal_type%TYPE;
     l_load_seq_num          igs_ca_inst.sequence_number%TYPE;
     l_enr_method            igs_en_method_type.enr_method_type%TYPE;
     l_return_status         VARCHAR2(20);
     l_dummy_mesg            VARCHAR2(100);

  PROCEDURE enrpl_copy_param_sua (
    p_warn_level    OUT NOCOPY   VARCHAR2,
    p_message_name    OUT NOCOPY VARCHAR2,
    p_added_ind     OUT NOCOPY   VARCHAR2,
    p_enr_method                 IN VARCHAR2,
    p_lload_cal_type             IN VARCHAR2,
    p_lload_ci_seq_num           IN NUMBER)
   AS
  /*-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified the c_sua cursor w.r.t. bug number 2829262
  --ptandon     06-Oct-2003     Modified to get the value of core indicator and pass to Igs_En_Gen_010.enrp_vald_inst_sua
  --                            as part of Prevent Dropping Core Units. Enh Bug# 3052432.
  --svanukur    19-oct-2003     MAde the following modifaications part of placements build:
  --                            Reordered the units so that the superior units are processed first becuase of the validation in
  --                            sua_api that checks for an appropriate superior unit attempt when a subordinate unit is enrolled.
  --                            for all the uoo_ids , made a call to ENR_SUB_UNITS in sua_api which enrolled all those untis
  --                            that are marked as default enroll whenever a superior unit is enrolled.
  -- ckasu     07-MAR-2006     modified as a part of bug#5070730
  -------------------------------------------------------------------------------------------*/
  BEGIN -- enrpl_copy_param_sua
    -- Pre-enrol IGS_PS_UNIT attempts entered during Admissions, as parameter
    -- to the process.
    DECLARE
    CURSOR c_am (
      cp_attendance_mode  IGS_EN_ATD_MODE.attendance_mode%TYPE) IS
      SELECT  am.GOVT_ATTENDANCE_MODE
      FROM  IGS_EN_ATD_MODE am
      WHERE am.attendance_mode = cp_attendance_mode;
    CURSOR c_cir (
      cp_cal_type   IGS_CA_INST.cal_type%TYPE) IS
      SELECT  ci.sequence_number
      FROM  IGS_CA_INST_REL   cir,
        IGS_CA_INST       ci,
        IGS_CA_TYPE       cat,
        IGS_CA_STAT       cs
      WHERE cir.sup_cal_type    = p_acad_cal_type AND
        cir.sup_ci_sequence_number  = p_acad_sequence_number AND
        ci.cal_type     = cir.sub_cal_type AND
        ci.sequence_number  = cir.sub_ci_sequence_number AND
        ci.cal_type   = cp_cal_type AND
        cat.cal_type    = ci.cal_type AND
        cat.S_CAL_CAT     = 'TEACHING' AND
        cs.CAL_STATUS     = ci.CAL_STATUS AND
        cs.s_cal_status   = 'ACTIVE'
      ORDER BY ci.start_dt;

    CURSOR c_sua (
      cp_person_id              IGS_EN_SU_ATTEMPT.person_id%TYPE,
      cp_course_cd              IGS_EN_SU_ATTEMPT.course_cd%TYPE,
      cp_unit_cd                IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
      cp_cal_type               IGS_EN_SU_ATTEMPT.cal_type%TYPE,
      cp_ci_sequence_number     IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
      cp_location_cd            IGS_EN_SU_ATTEMPT.location_cd%TYPE,
      cp_unit_class             IGS_EN_SU_ATTEMPT.unit_class%TYPE) IS
      SELECT  'x'
      FROM  IGS_EN_SU_ATTEMPT
      WHERE person_id               = cp_person_id          AND
            course_cd               = cp_course_cd          AND
            unit_cd                 = cp_unit_cd            AND
            cal_type                = cp_cal_type           AND
            ci_sequence_number      = cp_ci_sequence_number AND
            location_cd              = cp_location_cd        AND
            unit_class              = cp_unit_class;

    --cursor to select the unit section status , placements build.
      CURSOR c_sua_status(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
      SELECT DECODE(sua.unit_attempt_status, 'UNCONFIRM', 'N', 'WAITLISTED', 'Y' , NULL)
      FROM  IGS_EN_SU_ATTEMPT sua
      WHERE sua.person_id   = p_person_id AND
        sua.course_cd   = p_course_cd AND
        sua.uoo_id   = p_uoo_id;

    --cursor to select check if unit section is sup, sub or none.
      CURSOR c_rel_type(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
      SELECT relation_type
      FROM IGS_PS_UNIT_OFR_OPT
      WHERE uoo_id = p_uoo_id;

   --fetch the teach cal of the unit section
      CURSOR c_teach_cal(p_uoo_Id igs_ps_unit_ofr_opt.uoo_Id%TYPE) IS
      SELECT cal_type, ci_sequence_number
     FROM igs_ps_unit_ofr_opt
     WHERE uoo_id = p_uoo_id;

    v_am_rec                    c_am%ROWTYPE;
    v_sua_rec                   VARCHAR2(1);
    v_cir_rec                   c_cir%ROWTYPE;
    v_warn_level                VARCHAR2(10);
    v_log_creation_dt           DATE;
    vp_warn_level               VARCHAR2(10) := NULL;
    v_message_name              VARCHAR2(2000);
    v_attendance_mode           VARCHAR2(3);
    v_counter                   NUMBER := 0;
    v_uoo_id                    IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
    v_session_id                VARCHAR2(255);
    v_ci_start_dt               DATE;
    v_ci_end_dt                 DATE;
    -- variable used to keep the values on the
    -- parameter specified units.  p_unit<x>_....
    v_unit_cd                   IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE;
    v_cal_type                  IGS_PS_UNIT_OFR_OPT.cal_type%TYPE;
    v_location_cd               IGS_PS_UNIT_OFR_OPT.location_cd%TYPE;
    v_unit_class                IGS_PS_UNIT_OFR_OPT.unit_class%TYPE;
    l_core_indicator            IGS_EN_SU_ATTEMPT.core_indicator_code%TYPE;

--following vars added as part of placements build.
    l_rel_type                  IGS_PS_UNIT_OFR_OPT.relation_type%TYPE;
    l_uoo_ids VARCHAR2(2000);
    l_enr_uoo_ids VARCHAR2(2000);
    l_out_uoo_ids VARCHAR2(2000);
    l_waitlist_uoo_ids VARCHAR2(2000);
    l_failed_uoo_ids VARCHAR2(2000);
    l_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
    l_unit_cd IGS_PS_UNIT_OFR_OPT.unit_cd%TYPE;
    l_unit_cds VARCHAR2(2000);


    --pl/sql tables to hold the uooids based on whethere the unit section is superior , sobordinate or none.

     TYPE t_params_table IS TABLE OF NUMBER(7) INDEX BY BINARY_INTEGER;
     t_sup_params t_params_table;
     t_sub_params t_params_table;
     t_ord_params t_params_table;
     v_sup_index BINARY_INTEGER := 1;
     v_sub_index BINARY_INTEGER := 1;
     v_ord_index BINARY_INTEGER := 1;

     l_waitlist_flag varchar2(1);
     l_cal_type IGS_PS_UNIT_OFR_OPT.cal_type%TYPE;
      l_seq_num IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE;

   BEGIN
    p_added_ind := 'N';
    vp_warn_level := NULL;
    p_message_name := null;
    -- Get the student?s IGS_PS_GOVT_ATD_MODE before the pre-enrolment
    -- starts. It is passed to the routine determining which UOO to
    -- select for a pre-enrolled IGS_PS_UNIT.
    OPEN c_am(
      v_sca_rec.attendance_mode);
    FETCH c_am INTO v_am_rec;
    CLOSE c_am;
    IF v_am_rec.GOVT_ATTENDANCE_MODE = '1' THEN
      v_attendance_mode := 'ON';
    ELSIF v_am_rec.GOVT_ATTENDANCE_MODE = '2' THEN
      v_attendance_mode := 'OFF';
    ELSE
      v_attendance_mode :=  '%';
    END IF;
    -- loop through each of the specified units

    FOR v_counter IN 1..12 LOOP
      -- insert the IGS_PS_UNIT values into the local variables
      SELECT  DECODE( v_counter,
          1, p_unit1_unit_cd,
          2, p_unit2_unit_cd,
          3, p_unit3_unit_cd,
          4, p_unit4_unit_cd,
          5, p_unit5_unit_cd,
          6, p_unit6_unit_cd,
          7, p_unit7_unit_cd,
          8, p_unit8_unit_cd,
          9, p_unit9_unit_cd,
          10, p_unit10_unit_cd,
          11, p_unit11_unit_cd,
          12, p_unit12_unit_cd,
          NULL),
        DECODE( v_counter,
          1, p_unit1_cal_type,
          2, p_unit2_cal_type,
          3, p_unit3_cal_type,
          4, p_unit4_cal_type,
          5, p_unit5_cal_type,
          6, p_unit6_cal_type,
          7, p_unit7_cal_type,
          8, p_unit8_cal_type,
          9, p_unit9_cal_type,
          10, p_unit10_cal_type,
          11, p_unit11_cal_type,
          12, p_unit12_cal_type,
          NULL),
        DECODE( v_counter,
          1, p_unit1_location_cd,
          2, p_unit2_location_cd,
          3, p_unit3_location_cd,
          4, p_unit4_location_cd,
          5, p_unit5_location_cd,
          6, p_unit6_location_cd,
          7, p_unit7_location_cd,
          8, p_unit8_location_cd,
          9, p_unit9_location_cd,
          10, p_unit10_location_cd,
          11, p_unit11_location_cd,
          12, p_unit12_location_cd,
          NULL),
        DECODE( v_counter,
          1, p_unit1_unit_class,
          2, p_unit2_unit_class,
          3, p_unit3_unit_class,
          4, p_unit4_unit_class,
          5, p_unit5_unit_class,
          6, p_unit6_unit_class,
          7, p_unit7_unit_class,
          8, p_unit8_unit_class,
          9, p_unit9_unit_class,
          10, p_unit10_unit_class,
          11, p_unit11_unit_class,
          12, p_unit12_unit_class,
          NULL)
      INTO  v_unit_cd,
            v_cal_type,
            v_location_cd,
            v_unit_class
      FROM  DUAL;

      IF v_unit_cd IS NOT NULL THEN
        p_added_ind := 'Y';
        -- Call routine to check whether there is anything preventing
        -- the IGS_PS_UNIT attempt from being pre-enrolled (ie. advanced
        -- standing or encumbrances).
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_pre(
            p_person_id,
            p_course_cd,
            v_unit_cd,
            p_log_creation_dt,
            v_warn_level,
            v_message_name) THEN
          IF p_log_creation_dt IS NOT NULL THEN
            -- If the log creation date is set then log the HECS error
            -- This is if the pre-enrolment is being performed in batch.
            IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
              cst_pre_enrol,
              p_log_creation_dt,
              cst_minor || ',' ||
              TO_CHAR(p_person_id) || ',' ||
              p_course_cd,
              v_message_name,
              NULL);
          END IF;
          IF vp_warn_level IS NULL OR
            (vp_warn_level = cst_minor AND v_warn_level IN (cst_major,cst_error)) OR
            (vp_warn_level = cst_major AND v_warn_level = cst_error) THEN

            vp_warn_level := v_warn_level;
            p_message_name := v_message_name;
          END IF;
          p_warn_level := vp_warn_level;
          RETURN;
        END IF;
        -- For each of the specified units, determine the appropriate calendar
        -- instance and UNIT offering option and add the UNIT attempt.
        -- Determine the calendar instance of the pre-enrolment within the
        -- academic calendar instance; if multiple exist (straddling teaching
        -- periods) then pick the earliest.
        OPEN c_cir(
          v_cal_type);
        FETCH c_cir INTO v_cir_rec;
        IF c_cir%FOUND THEN
          CLOSE c_cir;
          -- use the first record found
          -- Check whether the student is already enrolled
          -- in UNIT attempt.
          OPEN c_sua(
            p_person_id,
            p_course_cd,
            v_unit_cd,
            v_cal_type,
            v_cir_rec.sequence_number,
            v_location_cd,
            v_unit_class);
          FETCH c_sua INTO v_sua_rec;
          IF c_sua%NOTFOUND THEN
            CLOSE c_sua;
            -- Call routine to get the UOO for the selected UNIT.
            IF NOT IGS_EN_GEN_005.enrp_get_pre_uoo(
                v_unit_cd,
                v_cal_type,
                v_cir_rec.sequence_number,
                v_location_cd,
                v_unit_class,
                v_sca_rec.attendance_mode,
                v_sca_rec.location_cd,
                v_uoo_id) THEN
              IF p_log_creation_dt IS NOT NULL THEN
                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                  cst_pre_enrol,
                  p_log_creation_dt,
                  cst_minor || ',' ||
                    TO_CHAR(p_person_id) || ',' ||
                     p_course_cd,
                  'IGS_EN_UNABLE_LOCATE_UOO_MATC',
                  v_cal_type || ',' ||
                    v_unit_cd || ',' ||
                    v_location_cd || ',' ||
                    v_unit_class);
              END IF;
              p_warn_level := 'MINOR';
              p_message_name := 'IGS_EN_UNABLE_LOCATE_UOO_MATC';
            ELSE
               l_rel_type := NULL;
               OPEN c_rel_type(v_uoo_id);
               FETCH c_rel_type INTO l_rel_type;
               CLOSE c_rel_type;
               IF l_rel_type= 'SUPERIOR' THEN
                  t_sup_params(v_sup_index) := v_uoo_id;
                  v_sup_index :=v_sup_index+1;
               ELSIF l_rel_type = 'SUBORDINATE' THEN
                  t_sub_params(v_sub_index) := v_uoo_id;
                  v_sub_index := v_sub_index+1;
               ELSE
                    t_ord_params(v_ord_index) := v_uoo_id;
                  v_ord_index := v_ord_index+1;
              END IF;

           END IF;

          ELSE  -- c_sua%FOUND
            CLOSE c_sua;
          END IF;
        ELSE  -- c_cir%NOTFOUND
          CLOSE c_cir;
        END IF;
      END IF;
    END LOOP; -- 8 units
    -- add all the uoo_ids to one pl/sql table, with superiors, first, subordinate next and the rest .
       --concatenate uoo_ids to pass to enr_sub_units.
       IF t_sup_params.count > 0 THEN
           FOR i in 1 .. t_sup_params.count LOOP
            IF  l_uoo_ids IS NOT NULL then
                l_uoo_ids := l_uoo_ids ||','||t_sup_params(i);
            ELSE
                l_uoo_ids := t_sup_params(i);
            END IF;
           END LOOP;
       END IF;
      IF t_sub_params.count > 0 THEN
           FOR i in 1 .. t_sub_params.count LOOP
            IF  l_uoo_ids IS NOT NULL then
                l_uoo_ids := l_uoo_ids ||','||t_sub_params(i);
            ELSE
                l_uoo_ids := t_sub_params(i);
            END IF;
           END LOOP;
       END IF;
      IF t_ord_params.count > 0 THEN
           FOR i in 1 .. t_ord_params.count LOOP
            IF  l_uoo_ids IS NOT NULL then
                l_uoo_ids := l_uoo_ids ||','||t_ord_params(i);
            ELSE
                l_uoo_ids := t_ord_params(i);
            END IF;
           END LOOP;
       END IF;

  -- the concatenated uoo-ids are in l_uoo_ids in the order of superior, subordinate and then the rest.
  --for each of these , call the enrp_vald_inst_sua.
      l_enr_uoo_ids := l_uoo_ids;

  WHILE l_enr_uoo_ids IS NOT NULL LOOP
             l_uoo_id := NULL;
             --extract the uoo_id
            IF(INSTR(l_enr_uoo_ids,',',1) = 0) THEN
                   l_uoo_id := TO_NUMBER(l_enr_uoo_ids);
            ELSE
                   l_uoo_id := TO_NUMBER(SUBSTR(l_enr_uoo_ids,0,INSTR(l_enr_uoo_ids,',',1)-1)) ;
            END IF;


               IGS_CA_GEN_001.calp_get_ci_dates(
                  v_cal_type,
                  v_cir_rec.sequence_number,
                  v_ci_start_dt,
                  v_ci_end_dt);

                  -- Get the Core Indicator for the Unit Section
                  l_core_indicator := igs_en_gen_009.enrp_check_usec_core(p_person_id, p_course_cd, l_uoo_id);

               IF igs_en_gen_010.enrp_vald_inst_sua(p_person_id      => p_person_id,
                                                       p_course_cd      => p_course_cd,
                                                       p_unit_cd        => NULL,
                                                       p_version_number => NULL,
                                                       p_teach_cal_type => NULL,
                                                       p_teach_seq_num  => NULL,
                                                       p_load_cal_type  => p_lload_cal_type,
                                                       p_load_seq_num   => p_lload_ci_seq_num,
                                                       p_location_cd    => NULL,
                                                       p_unit_class     => NULL,
                                                       p_uoo_id         => l_uoo_id,
                                                       p_enr_method     => p_enr_method,
                                                       p_core_indicator_code => l_core_indicator, -- ptandon, Prevent Dropping Core Units build
                                                       p_message        => v_message_name)
               THEN
                      IF v_message_name IS NOT NULL THEN
                         p_warn_level := 'MINOR';
                         p_message_name := v_message_name;
                      END IF;

                         --call enr_sub_units to enroll any subordinate units that are marked as default enroll

                        l_waitlist_flag := NULL;
                         OPEN c_sua_status(l_uoo_id);
                         FETCH c_sua_status INTO l_waitlist_flag;
                         CLOSE c_sua_status;
                        --fetch the teach cal type and teach seq number
                         l_cal_type := NULL;
                         l_seq_num := NULL;
                         OPEN c_teach_cal(l_uoo_id);
                         FETCH c_teach_cal INTO l_cal_type, l_seq_num;
                         CLOSE c_teach_cal;

                         l_failed_uoo_ids := NULL;
                         igs_en_val_sua.enr_sub_units(
                          p_person_id      => p_person_id,
                          p_course_cd      => p_course_cd,
                          p_uoo_id         => l_uoo_id,
                          p_waitlist_flag  => l_waitlist_flag,
                          p_load_cal_type  => p_lload_cal_type,
                          p_load_seq_num   => p_lload_ci_seq_num,
                          p_enrollment_date => NULL,
                          p_enrollment_method => p_enr_method,
                          p_enr_uoo_ids     => l_enr_uoo_ids,
                          p_uoo_ids         => l_out_uoo_ids,
                          p_waitlist_uoo_ids => l_waitlist_uoo_ids,
                          p_failed_uoo_ids  => l_failed_uoo_ids);

                   IF l_failed_uoo_ids IS NOT NULL THEN
                 --log error message if sub units did not enroll
                     IF p_log_creation_dt IS NOT NULL THEN
                        l_unit_cds := NULL;
                        --following function returns a string of units codes for teh passed in string of uoo_ids
                        l_unit_cds := igs_en_gen_018.enrp_get_unitcds(l_failed_uoo_ids);
                        p_warn_level := cst_error;
                        v_message_name := 'IGS_EN_BLK_SUB_FAILED'||'*'||l_unit_cds;
                      -- If the log creation date is set then log the HECS error
                      -- This is if the pre-enrolment is being performed in batch.
                      log_error_message(p_s_log_type        =>cst_pre_enrol,
                                 p_creation_dt       =>p_log_creation_dt,
                                 p_sle_key           =>p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                 p_sle_message_name  =>v_message_name,
                                 p_del               => ';');
                    END IF;
                END IF;

              ELSE --unit was not enrolled i.e enrp_vald_inst_sua returned false.
                      p_warn_level := cst_error;
                      p_message_name := v_message_name;

                  END IF;
                  IF (p_log_creation_dt IS NOT NULL) AND (v_message_name IS NOT NULL) THEN
                      -- If the log creation date is set then log the HECS error
                      -- This is if the pre-enrolment is being performed in batch.
                      log_error_message(p_s_log_type        => cst_pre_enrol,
                                        p_creation_dt       => p_log_creation_dt,
                                        p_sle_key           => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                        p_sle_message_name  => v_message_name,
                                        p_del               => ';');
                  END IF;

           --remove the processed uoo_id from the list.
           IF(INSTR(l_enr_uoo_ids,',',1) = 0) THEN
              l_enr_uoo_ids := NULL;
           ELSE
              l_enr_uoo_ids := SUBSTR(l_enr_uoo_ids,INSTR(l_enr_uoo_ids,',',1)+1);
           END IF;


     END LOOP;
    RETURN;
      EXCEPTION
    WHEN OTHERS THEN
      IF c_sua%ISOPEN THEN
        CLOSE c_sua;
      END IF;
      IF c_am%ISOPEN THEN
        CLOSE c_am;
      END IF;
      IF c_cir%ISOPEN THEN
        CLOSE c_cir;
      END IF;
      IF c_sua_status%ISOPEN THEN
        CLOSE c_sua_status;
      END IF;
     IF c_teach_cal%ISOPEN THEN
        CLOSE c_teach_cal;
      END IF;
     IF  c_rel_type%ISOPEN THEN
        CLOSE  c_rel_type;
      END IF;

      RAISE;
      END;
  EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_copy_param_sua');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END enrpl_copy_param_sua;


  BEGIN  -- enrp_ins_sret_prenrl
SAVEPOINT igs_ret_preenrol_sp;
    igs_en_gen_017.g_invoke_source := 'JOB';
    p_message_name := null;
    p_warn_level := NULL;
    --If passed load calendar is null then derive the load caledar based on academic calendar.
    IF p_load_cal_type IS NULL THEN
        OPEN c_load_cal(p_acad_cal_type,p_acad_sequence_number);
        FETCH c_load_cal INTO l_load_cal_type, l_load_seq_num;
        IF c_load_cal%NOTFOUND THEN
            CLOSE c_load_cal;
            IF p_log_creation_dt IS NOT NULL THEN
              IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type     => cst_pre_enrol,
                                                p_creation_dt    => p_log_creation_dt,
                                                p_key            => cst_error || ',' ||TO_CHAR(p_person_id) || ',' || p_course_cd,
                                                p_s_message_name =>'IGS_EN_CN_FIND_TERM_CAL',
                                                p_text           => NULL);
            END IF;
            p_warn_level := cst_error;
            p_message_name := 'IGS_EN_CN_FIND_TERM_CAL';
            RETURN FALSE;
        END IF;
        CLOSE c_load_cal;
    ELSE
        l_load_cal_type := p_load_cal_type;
        l_load_seq_num  := p_load_ci_seq_num;
    END IF;

    l_enr_method := p_dflt_enr_method;
    --If enrollment method not passed then derive the default enrollment method.
    IF l_enr_method IS NULL THEN
       igs_en_gen_017.enrp_get_enr_method(p_enr_method_type => l_enr_method,
                                          p_error_message   => l_dummy_mesg,
                                          p_ret_status      => l_return_status);
       IF l_return_status='FALSE' THEN
            IF p_log_creation_dt IS NOT NULL THEN
              IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                p_s_log_type     => cst_pre_enrol,
                                                p_creation_dt    => p_log_creation_dt,
                                                p_key            => cst_error || ',' ||TO_CHAR(p_person_id) || ',' || p_course_cd,
                                                p_s_message_name =>'IGS_SS_EN_NOENR_METHOD',
                                                p_text           => NULL);
            END IF;
            p_warn_level := cst_error;
            p_message_name := 'IGS_SS_EN_NOENR_METHOD';
            RETURN FALSE;
       END IF;
    END IF;
    -- call routine to check eligibility of the student
    IF NOT IGS_EN_GEN_006.ENRP_GET_SCA_ELGBL (
             p_person_id,
             p_course_cd,
             cst_return,
             p_acad_cal_type,
             p_acad_sequence_number,
         'Y', -- confirmed IGS_PS_COURSE attempt
        v_message_name) THEN

      IF p_log_creation_dt IS NOT NULL THEN
        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
          cst_pre_enrol,
          p_log_creation_dt,
          cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
             p_course_cd,
          v_message_name,
          NULL);
      END IF;

      p_message_name := v_message_name;
      p_warn_level := cst_error;
      RETURN FALSE;
    END IF;

    -- load the student IGS_PS_COURSE attempt detail of
    -- the specified IGS_PS_COURSE
    OPEN  c_sca_details;
    FETCH c_sca_details INTO v_sca_rec;
    IF c_sca_details%NOTFOUND THEN
      CLOSE c_sca_details;
      IF p_log_creation_dt IS NOT NULL THEN
        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
              TO_CHAR(p_person_id) || ',' ||
               p_course_cd,
            'IGS_EN_CAN_LOC_EXIS_STUD',
            NULL);
      END IF;
      p_message_name := 'IGS_EN_CAN_LOC_EXIS_STUD';
      p_warn_level := cst_error;
      RETURN FALSE;
    END IF;
    CLOSE c_sca_details;

    -- IF a parameter is passed for the enrolment category, then use it
    --else get the category from the previous enrolment period.
   v_enrolment_cat := null;
    -- insert student IGS_PS_COURSE attempt enrolment record
    --chk if record already exists

    OPEN c_scae_details;
    FETCH c_scae_details INTO v_scae_details;
    IF v_scae_details IS NOT NULL THEN

     --check if the passed in parameter is equal to the enrolment category.
    IF p_enrolment_cat IS NOT NULL THEN
                 IF v_scae_details <> p_enrolment_cat THEN
                     v_enrolment_cat := p_enrolment_cat;

                        --update the record
                             BEGIN

                                OPEN c_scae_upd;
                                FETCH c_scae_upd INTO v_scae_upd_rec;

                                    IGS_AS_SC_ATMPT_ENR_PKG.UPDATE_ROW(
                                        X_ROWID => v_scae_upd_rec.rowid,
                                        X_PERSON_ID => v_scae_upd_rec.PERSON_ID,
                                        X_COURSE_CD => v_scae_upd_rec.COURSE_CD,
                                        X_CAL_TYPE  => v_scae_upd_rec.CAL_TYPE,
                                        X_CI_SEQUENCE_NUMBER => v_scae_upd_rec.CI_SEQUENCE_NUMBER,
                                        X_ENROLMENT_CAT  => v_enrolment_cat,
                                        X_ENROLLED_DT  => v_scae_upd_rec.ENROLLED_DT,
                                        X_ENR_FORM_DUE_DT  => v_scae_upd_rec.ENR_FORM_DUE_DT,
                                        X_ENR_PCKG_PROD_DT  =>  v_scae_upd_rec.ENR_PCKG_PROD_DT ,
                                        X_ENR_FORM_RECEIVED_DT  => v_scae_upd_rec.ENR_FORM_RECEIVED_DT,
                                        X_MODE  =>  'R'  );

                                CLOSE c_scae_upd;
                              EXCEPTION
                               WHEN OTHERS THEN
                                IF c_scae_upd%ISOPEN THEN
                                CLOSE c_scae_upd;
                                END IF;
                                Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrpl_sret_preenrol');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                              END;
                 END IF; --v_scae_details <> p_enrolment_cat
       END IF; --p_enrolment_cat
   ELSE

        --  v_scae_details is null i.e c_scae_details%NOTFOUND hence create a new record
        --chk for parameter passed to the job
          IF p_enrolment_cat IS NOT NULL THEN
             v_enrolment_cat := p_enrolment_cat;
          ELSE

          --fetch previous enrolment category
                OPEN c_prev_enr_cat;
                FETCH c_prev_enr_cat INTO v_enr_cat;
                IF c_prev_enr_cat%NOTFOUND THEN
                        CLOSE c_prev_enr_cat;
                        IF p_log_creation_dt IS NOT NULL THEN
                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                cst_pre_enrol,
                                p_log_creation_dt,
                                cst_error || ',' ||
                                TO_CHAR(p_person_id) || ',' ||
                                 p_course_cd,
                                'IGS_EN_CANT_DETR_ENRL_CAT',
                                NULL);
                        END IF;
                                p_message_name := 'IGS_EN_CANT_DETR_ENRL_CAT';
                                p_warn_level := cst_error;
                                RETURN FALSE;
                ELSE    --category found
                        CLOSE c_prev_enr_cat;
                        v_enrolment_cat := v_enr_cat;
                END IF;
          END IF;
       --insert the record.
       DECLARE
            l_rowid VARCHAR2(25);
          BEGIN

            IGS_AS_SC_ATMPT_ENR_PKG.INSERT_ROW (
                  x_rowid => l_rowid,
                  x_person_id => p_person_id,
                  x_course_cd => p_course_cd,
                  x_cal_type => p_enrol_cal_type,
                  x_ci_sequence_number => p_enrol_sequence_number,
                  x_enrolment_cat => v_enrolment_cat,
                  x_enrolled_dt => NULL,
                  x_enr_form_due_dt => p_override_enr_form_due_dt,
                  x_enr_pckg_prod_dt => p_override_enr_pckg_prod_dt,
                  x_enr_form_received_dt => NULL  );
          END;
   END IF;
CLOSE c_scae_details;




    -- * Warn if the IGS_PS_COURSE is not being offered in the target
    -- academic period ; the student can still enrol as it strictly
    -- only applies to admission to the IGS_PS_COURSE.
    OPEN c_crv(
      v_sca_rec.course_cd,
      v_sca_rec.version_number,
      v_sca_rec.cal_type,
      v_sca_rec.location_cd,
      v_sca_rec.attendance_mode,
      v_sca_rec.attendance_type);
    FETCH c_crv INTO v_crv_rec;
    IF c_crv%NOTFOUND THEN
      CLOSE c_crv;
      -- * Warn that the IGS_PS_COURSE if not being offered
      IF p_log_creation_dt IS NOT NULL THEN
        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_minor || ',' ||
              TO_CHAR(p_person_id) || ',' ||
               p_course_cd,
            'IGS_EN_STUD_POO_TARGET_ACAPRD',
            NULL);
      END IF;
      p_message_name := 'IGS_EN_STUD_POO_TARGET_ACAPRD';
      p_warn_level := cst_minor;

    ELSE
      CLOSE c_crv;
    END IF;

    v_unit_set_cd :=  NULL ;

    IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'N' THEN
      -- attempt to get IGS_PS_UNIT set code from current enrolment.
      -- If there are multiple then don't attempt.
      FOR v_susa_rec IN c_susa LOOP
        v_row_count := 1;
        v_unit_set_cd := v_susa_rec.unit_set_cd;
        IF c_susa%ROWCOUNT > 1 THEN
          v_row_count := 2;
          EXIT;
        END IF;
      END LOOP;
      IF v_row_count > 1 THEN
         FOR v_pos_unit_sets IN c_pos_unit_sets(v_sca_rec.version_number) LOOP
            l_pos_count  := 1;
            v_unit_set_cd := v_pos_unit_sets.unit_set_cd;
            IF c_pos_unit_sets%ROWCOUNT > 1 THEN
               l_pos_count := 2;
               EXIT ;
            END IF;
         END LOOP;
         IF l_pos_count <> 1 THEN
           v_unit_set_cd := NULL ;
         END IF;  -- if l_pos_count <> 1
      ELSIF v_row_count = 0 THEN
             v_unit_set_cd := NULL ;
      END IF ; -- v_row_count <> 1
    END IF;

    -- In year of program mode do the following code
    IF NVL(FND_PROFILE.VALUE('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN

       -- If there is a currently active year of program then make it completed
       --and pre-enrol in the  next year of program , if it exists
       OPEN c_active_us ;
       FETCH c_active_us INTO c_active_us_rec;
       IF c_active_us%FOUND  THEN

            v_unit_set_cd := c_active_us_rec.unit_set_cd;
            -- check if there is any progression outcome preventing this student
            -- from completing this unit set attempt and going into the next year of program
            OPEN  c_prog_outcome(c_active_us_rec.selection_dt) ;
            FETCH c_prog_outcome INTO c_prog_outcome_rec ;
            CLOSE c_prog_outcome ;
            gv_progress_outcome_type := c_prog_outcome_rec.s_progression_outcome_type;
            IF NVL(gv_progress_outcome_type,'ADVANCE') = 'ADVANCE' THEN
              IF NVL(P_PROGRESS_STAT,'ADVANCE') <> 'REPEATYR' THEN

                  -- Check if trying to process a student who has just been pre-enrolled into the next year
                   -- ie first time the process is called student is transferred to year 2 , if process is called
                   -- again immediately then student should not again be pre-enrolled into year 3
                   OPEN c_chk_census_dt(c_active_us_rec.unit_set_cd);
                   FETCH c_chk_census_dt INTO  c_census_dt_rec;

                   IF c_chk_census_dt%FOUND  THEN

                     DECLARE
                         CURSOR c_susa_upd IS
                         SELECT rowid,IGS_AS_SU_SETATMPT.*
                        FROM IGS_AS_SU_SETATMPT
                         WHERE  person_id = c_active_us_rec.person_id AND
                         course_cd = c_active_us_rec.course_cd AND
                         unit_set_cd = c_active_us_rec.unit_set_cd AND
                         us_version_number =  c_active_us_rec.us_version_number  AND
                         sequence_number = c_active_us_rec.sequence_number
                         FOR UPDATE OF RQRMNTS_COMPLETE_IND ,
                           RQRMNTS_COMPLETE_DT  NOWAIT;
                        c_susa_upd_rec  c_susa_upd%ROWTYPE  ;
                     BEGIN
                         OPEN  c_susa_upd ;
                         FETCH c_susa_upd INTO c_susa_upd_rec ;

                         --The below condition to derive p_completion_date has been added
                         --as part of ENCR030(UK Enh) - Bug#2708430 - 16DEC2002.
                         --If p_completion_date is not available then either it will be SYSDATE - 1
                         --or p_selection_date - 1.
                         IF p_completion_date IS NULL AND p_selection_date IS NULL THEN
                              l_completion_date := SYSDATE - 1;
                         ELSIF p_completion_date IS NULL AND p_selection_date IS NOT NULL THEN
                              l_completion_date := p_selection_date - 1;
                         END IF;

      IF igs_en_gen_legacy.check_usa_overlap(
          c_susa_upd_rec.person_id,
          c_susa_upd_rec.course_cd,
          c_susa_upd_rec.selection_dt,
          NVL(p_completion_date, TRUNC(l_completion_date)),
          c_susa_upd_rec.end_dt,
          c_susa_upd_rec.sequence_number,
          c_susa_upd_rec.unit_set_cd,
          c_susa_upd_rec.us_version_number,
          p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
                   END IF ;

                         -- set the current year of program to completed
                         IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW (
                                X_ROWID => c_susa_upd_rec.rowid,
                                X_PERSON_ID  => c_susa_upd_rec.person_id ,
                                X_COURSE_CD  =>  c_susa_upd_rec.course_cd ,
                                X_UNIT_SET_CD  =>  c_susa_upd_rec.unit_set_cd ,
                                X_SEQUENCE_NUMBER =>  c_susa_upd_rec.sequence_number ,
                                X_US_VERSION_NUMBER =>  c_susa_upd_rec.us_version_number,
                                X_SELECTION_DT =>  c_susa_upd_rec.selection_dt ,
                                X_STUDENT_CONFIRMED_IND =>  c_susa_upd_rec.student_confirmed_ind ,
                                X_END_DT =>  c_susa_upd_rec.end_dt ,
                                X_PARENT_UNIT_SET_CD =>  c_susa_upd_rec.parent_unit_set_cd,
                                X_PARENT_SEQUENCE_NUMBER =>  c_susa_upd_rec.parent_sequence_number ,
                                X_PRIMARY_SET_IND =>  c_susa_upd_rec.primary_set_ind ,
                                X_VOLUNTARY_END_IND =>  c_susa_upd_rec.voluntary_end_ind ,
                                X_AUTHORISED_PERSON_ID =>  c_susa_upd_rec.authorised_person_id,
                                X_AUTHORISED_ON =>  c_susa_upd_rec.authorised_on ,
                                X_OVERRIDE_TITLE =>  c_susa_upd_rec.override_title ,
                                X_RQRMNTS_COMPLETE_IND =>  'Y' ,
                                -- The user entered parameter p_selection_date has been passed for the field X_RQRMNTS_COMPLETE_DT
                                -- In the UK Enh Build - Bug#2580731 - 04OCT2002.
                                -- In ENCR030(UK Enh) - Bug#2708430 - 16DEC2002. the X_RQRMNTS_COMPLETE_DT parameter below will be the parameter
                                -- p_completion_date or l_completion_date derived just above.
                                X_RQRMNTS_COMPLETE_DT =>  NVL(p_completion_date, TRUNC(l_completion_date)) ,
                                X_S_COMPLETED_SOURCE_TYPE =>  c_susa_upd_rec.s_completed_source_type,
                                X_CATALOG_CAL_TYPE =>  c_susa_upd_rec.catalog_cal_type ,
                                X_CATALOG_SEQ_NUM =>  c_susa_upd_rec.catalog_seq_num,
                                X_ATTRIBUTE_CATEGORY  => c_susa_upd_rec.attribute_category,
                                X_ATTRIBUTE1  => c_susa_upd_rec.attribute1 ,
                                X_ATTRIBUTE2  => c_susa_upd_rec.attribute2 ,
                                X_ATTRIBUTE3  => c_susa_upd_rec.attribute3,
                                X_ATTRIBUTE4  => c_susa_upd_rec.attribute4,
                                X_ATTRIBUTE5  => c_susa_upd_rec.attribute5,
                                X_ATTRIBUTE6  => c_susa_upd_rec.attribute6,
                                X_ATTRIBUTE7  => c_susa_upd_rec.attribute7,
                                X_ATTRIBUTE8  => c_susa_upd_rec.attribute8,
                                X_ATTRIBUTE9  => c_susa_upd_rec.attribute9,
                                X_ATTRIBUTE10  => c_susa_upd_rec.attribute10,
                                X_ATTRIBUTE11  => c_susa_upd_rec.attribute11,
                                X_ATTRIBUTE12  => c_susa_upd_rec.attribute12,
                                X_ATTRIBUTE13  => c_susa_upd_rec.attribute13,
                                X_ATTRIBUTE14  => c_susa_upd_rec.attribute14,
                                X_ATTRIBUTE15  => c_susa_upd_rec.attribute15,
                                X_ATTRIBUTE16  => c_susa_upd_rec.attribute16,
                                X_ATTRIBUTE17  => c_susa_upd_rec.attribute17,
                                X_ATTRIBUTE18  => c_susa_upd_rec.attribute18,
                                X_ATTRIBUTE19  => c_susa_upd_rec.attribute19,
                                X_ATTRIBUTE20  => c_susa_upd_rec.attribute20,
                                X_MODE =>  'R'
                           );
                           CLOSE  c_susa_upd ;

                           IF NOT  update_stream_unit_sets(
             p_person_id,
             p_course_cd,
             c_susa_upd_rec.unit_set_cd,
             'Y',
             NVL(p_completion_date, TRUNC(l_completion_date)),
             c_susa_upd_rec.selection_dt,
             c_susa_upd_rec.student_confirmed_ind,
             p_log_creation_dt,
             p_message_name
           ) THEN
           RETURN FALSE;
               END IF;

                     END ; -- complete the current unit set
                     -- get the next year in sequence
                     OPEN  c_next_us(c_active_us_rec.unit_set_cd) ;
                     FETCH c_next_us  INTO  c_next_us_rec ;
                     IF  c_next_us%FOUND  THEN
                           -- find the version number for the new unit set
                           OPEN c_us_version_number(p_person_id,p_course_cd, c_next_us_rec.unit_set_cd);
                           FETCH c_us_version_number INTO next_us_version;
                           IF c_us_version_number%FOUND  THEN
                               -- If next year of program exists then pre-enroll in it

                              IF NOT create_unit_set(
          p_person_id,
          p_course_cd,
          c_next_us_rec.unit_set_cd,
          next_us_version,
          NVL(p_selection_date,SYSDATE),
          'Y',
          NULL,
          NULL,
          l_seqval,
          p_log_creation_dt,
          p_message_name
              ) THEN
              RETURN FALSE;
                  END IF;
                                -- now pre-enroll the pattern of study units corresponding to
                                -- this new unit set
                              v_unit_set_cd  :=   c_next_us_rec.unit_set_cd ;


                              IF NOT create_stream_unit_sets(
          p_person_id,
          p_course_cd,
          c_next_us_rec.unit_set_cd,
          NVL(p_selection_date,TRUNC(SYSDATE)),
          'Y',
          p_log_creation_dt,
          p_message_name
              ) THEN
              RETURN FALSE;
            END IF;

                              -- smaddali 14-may-2002 added new parameter p_old_sequence_number for bug#2350629
                              IF l_seqval IS NOT NULL THEN
                                copy_hesa_details (
                                  p_person_id,
                                  p_course_cd,
                                  v_sca_rec.version_number,
                                  c_active_us_rec.unit_set_cd,
                                  c_active_us_rec.us_version_number,
                                  c_active_us_rec.sequence_number ,
                                  c_next_us_rec.unit_set_cd,
                                  next_us_version,
                                  l_seqval
                                 );
                             END IF;
                           ELSE
                                CLOSE c_us_version_number ;
                                CLOSE c_next_us ;
                                CLOSE c_chk_census_dt ;
                                RETURN TRUE ;
                           END IF; -- if next unit set version is found
                           CLOSE c_us_version_number ;
                     ELSE
                           CLOSE c_next_us ;
                           CLOSE c_chk_census_dt ;
                           RETURN TRUE ;
                     END IF; -- found next unit set in sequence
                     CLOSE c_next_us ;
                   END IF;  -- end chk_census_dt
                   CLOSE c_chk_census_dt ;
            END IF;  -- student is not eligible for progress
           END IF;
       ELSE  -- no active unit set attempts found
                -- find the last active unit set  under context program
             OPEN c_last_us ;
             FETCH c_last_us INTO l_last_us ;
             IF c_last_us%FOUND THEN

               v_unit_set_cd  := l_last_us.unit_set_cd;
               OPEN  c_prog_outcome(l_last_us.selection_dt) ;
               FETCH c_prog_outcome INTO c_prog_outcome_rec ;
               CLOSE c_prog_outcome ;
               gv_progress_outcome_type := c_prog_outcome_rec.s_progression_outcome_type;
               IF NVL(gv_progress_outcome_type, 'ADVANCE') = 'ADVANCE' THEN
               IF NVL(P_PROGRESS_STAT,'ADVANCE') <> 'REPEATYR' THEN

                 OPEN  c_next_us(l_last_us.unit_set_cd) ;
                 FETCH c_next_us  INTO  c_next_us_rec ;
                 IF  c_next_us%FOUND  THEN
                   -- find the version number for the new unit set
                   OPEN c_us_version_number(p_person_id,p_course_cd,c_next_us_rec.unit_set_cd);
                   FETCH c_us_version_number INTO next_us_version;
                   IF c_us_version_number%FOUND  THEN

                       -- If next year of program exists then pre-enroll in it
                          IF NOT  create_unit_set(
            p_person_id,
            p_course_cd,
            c_next_us_rec.unit_set_cd,
            next_us_version,
            NVL(p_selection_date,SYSDATE),
            'Y',
            NULL,
            NULL,
            l_seqval,
            p_log_creation_dt,
            p_message_name
          ) THEN
          RETURN FALSE;
         END IF;

                          -- now pre-enroll the pattern of study units corresponding to
                          -- this new unit set
                          v_unit_set_cd  :=   c_next_us_rec.unit_set_cd ;

                          IF NOT  create_stream_unit_sets(
            p_person_id,
            p_course_cd,
            c_next_us_rec.unit_set_cd,
            NVL(p_selection_date,TRUNC(SYSDATE)),
            'Y',
            p_log_creation_dt,
            p_message_name
          ) THEN
          RETURN FALSE;
              END IF;


                        -- smaddali 14-may-2002 added new parameter p_old_sequence_number for bug#2350629
                        IF l_seqval IS NOT NULL THEN
                          copy_hesa_details (
                            p_person_id,
                            p_course_cd,
                            v_sca_rec.version_number,
                            l_last_us.unit_set_cd,
                            l_last_us.us_version_number,
                            l_last_us.sequence_number ,
                            c_next_us_rec.unit_set_cd,
                            next_us_version,
                            l_seqval
                         );
                       END IF;

                   ELSE
                     CLOSE c_us_version_number ;
                     CLOSE c_next_us ;
                     CLOSE c_last_us ;
                     RETURN TRUE;
                   END IF; -- if next unit set version is found
                   CLOSE c_us_version_number ;
                END IF; -- found next unit set in sequence
                CLOSE c_next_us ;
                CLOSE c_last_us ;
                RETURN TRUE;
             END IF; -- found the last active us attempt
             CLOSE  c_last_us ;
             RETURN TRUE;
           END IF; -- IF NVL(P_PROGRESS_STAT,'ADVANCE') <> 'REPEATYR' THEN
           END IF;
       END IF; -- found an active unit set attempt
       CLOSE  c_active_us ;
    END IF;   -- profile set to year of program

    -- 5.  Pre-enrol student IGS_PS_UNIT attempts according to the
    -- pattern of study.
    -- * Attempt to determine required details from the
    -- admission application.
    IF v_sca_rec.adm_admission_appl_number IS NOT NULL THEN
      OPEN c_acaiv(
        v_sca_rec.adm_admission_appl_number,
        v_sca_rec.adm_nominated_course_cd,
        v_sca_rec.adm_sequence_number);
      FETCH c_acaiv INTO v_acaiv_rec;
      CLOSE c_acaiv;
      v_adm_cal_type := v_acaiv_rec.adm_cal_type;
      v_admission_cat := v_acaiv_rec.admission_cat;
    ELSE
      -- * No admissions details present.;
      -- The admissions fields are null if not available.
      v_adm_cal_type := NULL;
      v_admission_cat := NULL;
    END IF;

    -- Pre-enrol UNIT attempts passed as parameters to the process.
    -- create parameter IGS_EN_SU_ATTEMPT
   enrpl_copy_param_sua(
      p_warn_level       => v_warn_level,
      p_message_name     => v_message_name,
      p_added_ind        => v_parm_added_ind,
      p_enr_method       => l_enr_method,
      p_lload_cal_type   => l_load_cal_type,
      p_lload_ci_seq_num => l_load_seq_num );


    IF v_message_name is not null THEN
      IF p_warn_level IS NULL OR
           (p_warn_level = cst_minor AND
            v_warn_level IN (cst_major,
                cst_error)) OR
              (p_warn_level = cst_major AND
            v_warn_level = cst_error) THEN
          p_warn_level := v_warn_level;
          p_message_name := v_message_name;
       END IF;
     END IF;

    IF v_parm_added_ind = 'N' THEN
      -- If pre enrolment of units is required then pre-enrol the units.
      IF ( p_units_ind = 'Y' OR p_units_ind = 'CORE_ONLY' )   THEN

        v_boolean := IGS_EN_GEN_009.enrp_ins_pre_pos(p_acad_cal_type         => p_acad_cal_type,
                                                     p_acad_sequence_number  => p_acad_sequence_number,
                                                     p_person_id             => p_person_id,
                                                     p_course_cd             => p_course_cd,
                                                     p_version_number        => v_sca_rec.version_number,
                                                     p_location_cd           => v_sca_rec.location_cd,
                                                     p_attendance_mode       => v_sca_rec.attendance_mode,
                                                     p_attendance_type       => v_sca_rec.attendance_type,
                                                     p_unit_set_cd           => v_unit_set_cd,
                                                     p_adm_cal_type          => v_adm_cal_type,
                                                     p_admission_cat         => v_admission_cat,
                                                     p_log_creation_dt       => v_log_creation_dt,
                                                     p_units_indicator       => p_units_ind,
                                                     p_warn_level            => v_warn_level,
                                                     p_message_name          => v_message_name,
                                                     p_progress_stat         => p_progress_stat,
                                                     p_progress_outcome_type => gv_progress_outcome_type,
                                                     p_enr_method            => l_enr_method,
                                                     p_load_cal_type         => l_load_cal_type,
                                                     p_load_ci_seq_num       => l_load_seq_num);
            IF (v_message_name IS NOT NULL) AND ( NOT v_boolean )THEN
              p_warn_level := cst_major;
              p_message_name := v_message_name;
            ELSE
              p_warn_level := v_warn_level;
              p_message_name := v_message_name;
            END IF;
            IF (p_log_creation_dt IS NOT NULL) AND (v_message_name IS NOT NULL) THEN
                -- If the log creation date is set then log the HECS error
                -- This is if the pre-enrolment is being performed in batch.
                log_error_message(p_s_log_type        => cst_pre_enrol,
                                  p_creation_dt       => p_log_creation_dt,
                                  p_sle_key           => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                  p_sle_message_name  => v_message_name,
                                  p_del               => ';');
            END IF;
            --if the warn level is major then return false, since it implies that no units were enrolled.
            IF p_warn_level = cst_major THEN
            RETURN FALSE;
            END IF;
      END IF;  --  call units ind
    END IF; -- param sua call
    -- the default return type

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF  c_prev_enr_cat%ISOPEN THEN
        CLOSE c_prev_enr_cat;
      END IF;
      IF  c_sca_details%ISOPEN THEN
        CLOSE c_sca_details;
      END IF;
      IF  c_crv%ISOPEN THEN
        CLOSE c_crv;
      END IF;
      IF  c_acaiv%ISOPEN THEN
        CLOSE c_acaiv;
      END IF;
      IF  c_susa%ISOPEN THEN
        CLOSE c_susa;
      END IF;
     --getting the message of the stack to check if any exceptions realted to holds on a particular student were raised
     --these messages should be logged into the log table and shown to the user ; It should not cause the processing of the
     --entire process to stop.
     IF p_log_creation_dt IS NOT NULL THEN
          IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
          FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
          p_warn_level := cst_error;
        --checking if it is not an unhandled exception since unhandled exceptions may not b ein realtion to a particular student
        -- and may cause the process to fail for every student.
        -- hence raise the exception if it is and unhandled exceptions
        --rollback to the beginning of the rpocedure to undo the changes made for teh student who is erroring out.
         ROLLBACK to igs_ret_preenrol_sp;
         IF l_message_name <> 'IGS_GE_UNHANDLED_EXP' THEN
               IF l_message_name IS NOT NULL THEN
                   -- If the log creation date is set then log the HECS error
                    -- This is if the pre-enrolment is being performed in batch.
                    log_error_message(p_s_log_type        => cst_pre_enrol,
                                      p_creation_dt       => p_log_creation_dt,
                                      p_sle_key           => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                      p_sle_message_name  => l_message_name,
                                      p_del               => ';');
                END IF;
         ELSE -- unhandled exception
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                 FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_snew_prenrl');
                 l_mesg_txt := fnd_message.get;
                 igs_ge_gen_003.genp_ins_log_entry(p_s_log_type       => cst_pre_enrol,
                                                   p_creation_dt      => p_log_creation_dt,
                                                   p_key              => p_warn_level||','||TO_CHAR(p_person_id)||','||p_course_cd,
                                                   p_s_message_name   => 'IGS_GE_UNHANDLED_EXP',
                                                   p_text             => l_mesg_txt);
         END IF;
         l_message_name := NULL;
     ELSE -- no log creation date
            RAISE;
     END IF;

  END;
EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      RAISE;
  WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_sret_prenrl');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END enrp_ins_sret_prenrl;

FUNCTION Enrp_Ins_Suao_Discon(
 p_person_id                    IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_ci_start_dt                 IN DATE ,
  p_ci_end_dt                   IN DATE ,
  p_discontinued_dt             IN DATE ,
  p_administrative_unit_status  IN VARCHAR2 ,
  p_message_name                OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN  NUMBER)
RETURN BOOLEAN AS
-------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
--kkillams    -04-2003        New parameters  p_new_uoo_id and p_old_uoo_id to the function.
--                            w.r.t. bug number 2829262
-------------------------------------------------------------------------------------------
  gv_grading_schema_cd  IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  gv_version_number     IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  gv_admin_unit_status  IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE;
  gv_grade              IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  gv_discontinued_dt    IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;
  gv_message_name       VARCHAR2(2000);
  gv_input              BOOLEAN;
  l_exists              NUMBER(1);
BEGIN
DECLARE

  CURSOR  c_suao_details
    (cp_person_id       IGS_EN_SU_ATTEMPT.person_id%TYPE,
     cp_course_cd       IGS_EN_SU_ATTEMPT.course_cd%TYPE,
     cp_uoo_id          IGS_EN_SU_ATTEMPT.uoo_id%TYPE,
     cp_discontinued_dt IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE)  IS
    SELECT  1
    FROM  IGS_AS_SU_STMPTOUT
    WHERE person_id          = cp_person_id       AND
          course_cd          = cp_course_cd       AND
          uoo_id             = cp_uoo_id          AND
          outcome_dt         = cp_discontinued_dt;
BEGIN
  -- This module inserts a student IGS_PS_UNIT attempt
  -- outcome when student IGS_PS_UNIT attempt is
  -- discontinued.
  p_message_name := null;
  -- get the student IGS_PS_UNIT attempt grading schema
  IF (IGS_EN_VAL_SUA.enrp_get_sua_gs(p_discontinued_dt,
                                     p_administrative_unit_status,
                                     gv_grading_schema_cd,
                                     gv_version_number,
                                     p_message_name) = FALSE) THEN
    RETURN FALSE;
  END IF;
  -- get the administrative IGS_PS_UNIT status grading schema
  IF (IGS_EN_VAL_SUA.enrp_get_sua_ausg(p_administrative_unit_status,
                                       p_person_id,
                                       p_course_cd,
                                       p_unit_cd,
                                       p_cal_type,
                                       p_ci_sequence_number,
                                       p_discontinued_dt,
                                       gv_grading_schema_cd,
                                       gv_version_number,
                                       gv_grade,
                                       p_message_name,
                                       p_uoo_id) = FALSE) THEN
    RETURN FALSE;
  END IF;
  -- insert a student IGS_PS_UNIT attempt outcome record
  IF gv_grade IS NOT NULL THEN
    OPEN  c_suao_details(p_person_id,
                         p_course_cd,
                         p_uoo_id,
                         TRUNC(p_discontinued_dt));
    FETCH c_suao_details INTO l_exists;
    -- check if a record is found
    -- if it does, an outcome already exists
    IF (c_suao_details%FOUND) THEN
      p_message_name := 'IGS_EN_UNT_ATMP_ALREADY_EXIST';
      CLOSE c_suao_details;
      RETURN FALSE;
    ELSE -- a record is not found, therefore no outcome exists
                 -- so insert the record
      CLOSE c_suao_details;

                DECLARE
                     l_rowid VARCHAR2(25);
                     l_org_id NUMBER := igs_ge_gen_003.get_org_id;
                BEGIN
                     IGS_AS_SU_STMPTOUT_PKG.INSERT_ROW(
                                                x_rowid                         => l_rowid,
                                                x_person_id                     => p_person_id,
                                                x_course_cd                     => p_course_cd,
                                                x_unit_cd                       => p_unit_cd,
                                                x_cal_type                      => p_cal_type,
                                                x_ci_sequence_number            => p_ci_sequence_number,
                                                x_ci_start_dt                   => p_ci_start_dt,
                                                x_ci_end_dt                     => p_ci_end_dt,
                                                x_outcome_dt                    => p_discontinued_dt,
                                                x_grading_schema_cd             => gv_grading_schema_cd,
                                                x_version_number                => gv_version_number ,
                                                x_grade                         => gv_grade,
                                                x_s_grade_creation_method_type  => 'DISCONTIN',
                                                x_finalised_outcome_ind         =>  'Y',
                                                x_mark                          => NULL,
                                                X_number_times_keyed            => NULL,
                                                X_translated_grading_schema_cd  => NULL,
                                                X_translated_version_number     => NULL,
                                                X_translated_grade              => NULL,
                                                X_translated_dt                 => NULL,
                                                X_mode                          => 'R',
                                                x_org_id                        => l_org_id,
                                                X_attribute_category            => NULL,
                                                X_attribute1                    => NULL,
                                                X_attribute2                    => NULL,
                                                X_attribute3                    => NULL,
                                                X_attribute4                    => NULL,
                                                X_attribute5                    => NULL,
                                                X_attribute6                    => NULL,
                                                X_attribute7                    => NULL,
                                                X_attribute8                    => NULL,
                                                X_attribute9                    => NULL,
                                                X_attribute10                   => NULL,
                                                X_attribute11                   => NULL,
                                                X_attribute12                   => NULL,
                                                X_attribute13                   => NULL,
                                                X_attribute14                   => NULL,
                                                X_attribute15                   => NULL,
                                                X_attribute16                   => NULL,
                                                X_attribute17                   => NULL,
                                                X_attribute18                   => NULL,
                                                X_attribute19                   => NULL,
                                                X_attribute20                   => NULL,
                                                x_uoo_id                        => p_uoo_id,
                                                x_mark_capped_flag              => 'N',
                                                x_show_on_academic_histry_flag  => 'Y',
                                                x_release_date                  => NULL,
                                                x_manual_override_flag          => 'N',
                                                x_incomp_deadline_date          => NULL,
                                                x_incomp_grading_schema_cd      => NULL,
                                                x_incomp_version_number         => NULL,
                                                x_incomp_default_grade          => NULL,
                                                x_incomp_default_mark           => NULL,
                                                x_comments                      => NULL,
                                                x_grading_period_cd             => 'FINAL'
                                                );
               END;

    END IF;
  END IF;
  RETURN TRUE;
END;
END enrp_ins_suao_discon;

PROCEDURE Enrp_Ins_Sua_Hist(
  p_person_id                   IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd                   IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd                     IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_cal_type                    IN IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_ci_sequence_number          IN IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_new_version_number          IN IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_old_version_number          IN IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_new_location_cd             IN IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE ,
  p_old_location_cd             IN IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE ,
  p_new_unit_class              IN IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE ,
  p_old_unit_class              IN IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE ,
  p_new_enrolled_dt             IN IGS_EN_SU_ATTEMPT_ALL.enrolled_dt%TYPE ,
  p_old_enrolled_dt             IN IGS_EN_SU_ATTEMPT_ALL.enrolled_dt%TYPE ,
  p_new_unit_attempt_status     IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE ,
  p_old_unit_attempt_status     IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE ,
  p_new_admin_unit_status       IN IGS_EN_SU_ATTEMPT_ALL.administrative_unit_status%TYPE ,
  p_old_admin_unit_status       IN IGS_EN_SU_ATTEMPT_ALL.administrative_unit_status%TYPE ,
  p_new_discontinued_dt         IN IGS_EN_SU_ATTEMPT_ALL.discontinued_dt%TYPE ,
  p_old_discontinued_dt         IN IGS_EN_SU_ATTEMPT_ALL.discontinued_dt%TYPE ,
  p_new_rule_waived_dt          IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_dt%TYPE ,
  p_old_rule_waived_dt          IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_dt%TYPE ,
  p_new_rule_waived_person_id   IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_person_id%TYPE ,
  p_old_rule_waived_person_id   IN IGS_EN_SU_ATTEMPT_ALL.rule_waived_person_id%TYPE ,
  p_new_no_assessment_ind       IN IGS_EN_SU_ATTEMPT_ALL.no_assessment_ind%TYPE ,
  p_old_no_assessment_ind       IN IGS_EN_SU_ATTEMPT_ALL.no_assessment_ind%TYPE ,
  p_new_exam_location_cd        IN IGS_EN_SU_ATTEMPT_ALL.exam_location_cd%TYPE ,
  p_old_exam_location_cd        IN IGS_EN_SU_ATTEMPT_ALL.exam_location_cd%TYPE ,
  p_new_sup_unit_cd             IN IGS_EN_SU_ATTEMPT_ALL.sup_unit_cd%TYPE ,
  p_old_sup_unit_cd             IN IGS_EN_SU_ATTEMPT_ALL.sup_unit_cd%TYPE ,
  p_new_sup_version_number      IN IGS_EN_SU_ATTEMPT_ALL.sup_version_number%TYPE ,
  p_old_sup_version_number      IN IGS_EN_SU_ATTEMPT_ALL.sup_version_number%TYPE ,
  p_new_alternative_title       IN IGS_EN_SU_ATTEMPT_ALL.alternative_title%TYPE ,
  p_old_alternative_title       IN IGS_EN_SU_ATTEMPT_ALL.alternative_title%TYPE ,
  p_new_override_enrolled_cp    IN IGS_EN_SU_ATTEMPT_ALL.override_enrolled_cp%TYPE ,
  p_old_override_enrolled_cp    IN IGS_EN_SU_ATTEMPT_ALL.override_enrolled_cp%TYPE ,
  p_new_override_eftsu          IN IGS_EN_SU_ATTEMPT_ALL.override_eftsu%TYPE ,
  p_old_override_eftsu          IN IGS_EN_SU_ATTEMPT_ALL.override_eftsu%TYPE ,
  p_new_override_achievable_cp  IN IGS_EN_SU_ATTEMPT_ALL.override_achievable_cp%TYPE ,
  p_old_override_achievable_cp  IN IGS_EN_SU_ATTEMPT_ALL.override_achievable_cp%TYPE ,
  p_new_override_outcome_due_dt IN IGS_EN_SU_ATTEMPT_ALL.override_outcome_due_dt%TYPE ,
  p_old_override_outcome_due_dt IN IGS_EN_SU_ATTEMPT_ALL.override_outcome_due_dt%TYPE ,
  p_new_override_credit_reason  IN IGS_EN_SU_ATTEMPT_ALL.override_credit_reason%TYPE ,
  p_old_override_credit_reason  IN IGS_EN_SU_ATTEMPT_ALL.override_credit_reason%TYPE ,
  p_new_update_who              IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE ,
  p_old_update_who              IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE ,
  p_new_update_on               IN IGS_EN_SU_ATTEMPT_ALL.last_update_date%TYPE ,
  p_old_update_on               IN IGS_EN_SU_ATTEMPT_ALL.last_update_date%TYPE ,
  p_new_dcnt_reason_Cd          IN IGS_EN_SU_ATTEMPT_ALL.dcnt_reason_cd%TYPE,
  p_old_dcnt_reason_Cd          IN IGS_EN_SU_ATTEMPT_ALL.dcnt_reason_cd%TYPE,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT_ALL.uoo_id%TYPE,
  p_new_core_indicator_code     IN IGS_EN_SU_ATTEMPT_ALL.core_indicator_code%TYPE, -- ptandon, Prevent Dropping Core Units build
  p_old_core_indicator_code     IN IGS_EN_SU_ATTEMPT_ALL.core_indicator_code%TYPE  -- ptandon, Prevent Dropping Core Units build
)
AS
-------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
--kkillams    -04-2003        New parameters  p_new_uoo_id and p_old_uoo_id to the function.
--                            w.r.t. bug number 2829262
--ptandon     06-Oct-2003     New parameters p_new_core_indicator_code and p_old_core_indicator_code
--                            added to the function as part of Prevent Dropping Core Units.
--                            Enh Bug# 3052432.
-------------------------------------------------------------------------------------------
  gv_other_detail     VARCHAR2(255);
BEGIN
DECLARE
  r_suah        IGS_EN_SU_ATTEMPT_H%ROWTYPE;
  v_create_history      BOOLEAN := FALSE;
  v_aus_description     IGS_AD_ADM_UNIT_STAT.description%TYPE;
  v_elo_description     IGS_AD_LOCATION.description%TYPE;

  CURSOR c_find_aus_desc IS
    SELECT  description
    FROM  IGS_AD_ADM_UNIT_STAT
    WHERE administrative_unit_status = r_suah.administrative_unit_status;
  CURSOR c_find_elo_desc IS
    SELECT  description
    FROM  IGS_AD_LOCATION
    WHERE location_cd = r_suah.exam_location_cd;
BEGIN
  -- Create a history for a IGS_EN_SU_ATTEMPT record.
  -- Check if any of the non-primary key fields have been changed
  -- and set the flag v_create_history to indicate so.
  IF p_new_version_number <> p_old_version_number  THEN
    r_suah.version_number := p_old_version_number;
    v_create_history := TRUE;
  END IF;
  IF p_new_location_cd <> p_old_location_cd  THEN
    r_suah.location_cd := p_old_location_cd;
    v_create_history := TRUE;
  END IF;
  IF p_new_unit_class <> p_old_unit_class  THEN
    r_suah.unit_class := p_old_unit_class;
    v_create_history := TRUE;
  END IF;
  IF NVL(TRUNC(p_new_enrolled_dt), igs_ge_date.igsdate('1900/01/01')) <>
       NVL(TRUNC(p_old_enrolled_dt), igs_ge_date.igsdate('1900/01/01'))  THEN
    r_suah.enrolled_dt := TRUNC(p_old_enrolled_dt);
    v_create_history := TRUE;
  END IF;
  IF p_new_unit_attempt_status <> p_old_unit_attempt_status THEN
    r_suah.unit_attempt_status := p_old_unit_attempt_status;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_admin_unit_status, 'NULL') <>
      NVL(p_old_admin_unit_status, 'NULL')  THEN
    r_suah.administrative_unit_status := p_old_admin_unit_status;
    IF NVL(p_old_admin_unit_status, 'NULL') <> 'NULL' THEN
      -- get the administrative IGS_PS_UNIT status description
      OPEN  c_find_aus_desc;
      FETCH c_find_aus_desc  INTO r_suah.aus_description;
      CLOSE c_find_aus_desc;
    END IF;
    v_create_history := TRUE;
  END IF;
  IF NVL(TRUNC(p_new_discontinued_dt), igs_ge_date.igsdate('1900/01/01')) <>
       NVL(TRUNC(p_old_discontinued_dt), igs_ge_date.igsdate('1900/01/01'))  THEN
    r_suah.discontinued_dt := TRUNC(p_old_discontinued_dt);
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_rule_waived_dt, igs_ge_date.igsdate('1900/01/01')) <>
       NVL(p_old_rule_waived_dt, igs_ge_date.igsdate('1900/01/01'))  THEN
    r_suah.rule_waived_dt := p_old_rule_waived_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_rule_waived_person_id, 0) <>
      NVL(p_old_rule_waived_person_id, 0) THEN
    r_suah.rule_waived_person_id := p_old_rule_waived_person_id;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_no_assessment_ind, 'NULL') <>
      NVL(p_old_no_assessment_ind, 'NULL')  THEN
    r_suah.no_assessment_ind := p_old_no_assessment_ind;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_exam_location_cd, 'NULL') <>
      NVL(p_old_exam_location_cd, 'NULL') THEN
    r_suah.exam_location_cd := p_old_exam_location_cd;
    IF NVL(p_old_exam_location_cd, 'NULL') <> 'NULL' THEN
      -- get the exam IGS_AD_LOCATION description
      OPEN  c_find_elo_desc;
      FETCH c_find_elo_desc  INTO r_suah.elo_description;
      CLOSE c_find_elo_desc;
    END IF;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_sup_unit_cd, 'NULL') <> NVL(p_old_sup_unit_cd, 'NULL')  THEN
    r_suah.sup_unit_cd := p_old_sup_unit_cd;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_sup_version_number, 0) <> NVL(p_old_sup_version_number, 0)  THEN
    r_suah.sup_version_number := p_old_sup_version_number;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_alternative_title, 'NULL') <>
      NVL(p_old_alternative_title, 'NULL')  THEN
    r_suah.alternative_title := p_old_alternative_title;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_override_enrolled_cp, 0) <>
      NVL(p_old_override_enrolled_cp, 0) THEN
    r_suah.override_enrolled_cp := p_old_override_enrolled_cp;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_override_eftsu, 0) <> NVL(p_old_override_eftsu, 0)  THEN
    r_suah.override_eftsu := p_old_override_eftsu;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_override_achievable_cp, 0) <>
      NVL(p_old_override_achievable_cp, 0)  THEN
    r_suah.override_achievable_cp := p_old_override_achievable_cp;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_override_outcome_due_dt,
      igs_ge_date.igsdate('1900/01/01')) <>
       NVL(p_old_override_outcome_due_dt,
      igs_ge_date.igsdate('1900/01/01')) THEN
    r_suah.override_outcome_due_dt := p_old_override_outcome_due_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_override_credit_reason, 'NULL') <>
      NVL(p_old_override_credit_reason, 'NULL')  THEN
    r_suah.override_credit_reason := p_old_override_credit_reason;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_dcnt_reason_Cd, 'NULL') <>
      NVL(p_old_dcnt_reason_Cd, 'NULL')  THEN
    r_suah.dcnt_reason_Cd := p_old_dcnt_reason_Cd;
    v_create_history := TRUE;
  END IF;
  -- ptandon, Prevent Dropping Core Units build
  IF NVL(p_new_core_indicator_code, 'NULL') <>
      NVL(p_old_core_indicator_code, 'NULL')  THEN
    r_suah.core_indicator_code := p_old_core_indicator_code;
    v_create_history := TRUE;
  END IF;

  -- Create a history record if a column has changed value
  IF v_create_history = TRUE THEN
    r_suah.person_id          :=  p_person_id;
    r_suah.course_cd          :=  p_course_cd;
    r_suah.unit_cd            :=  p_unit_cd;
    r_suah.cal_type           :=  p_cal_type;
    r_suah.ci_sequence_number :=  p_ci_sequence_number;
    r_suah.hist_start_dt      := p_old_update_on;
    r_suah.hist_end_dt        := p_new_update_on;
    r_suah.hist_who           := p_old_update_who;
    r_suah.uoo_id             := p_uoo_id;
            -- remove one second from the hist_start_dt value
            -- when the hist_start_dt and hist_end_dt are the same
            -- to avoid a primary key constraint from occurring
            -- when saving the record
            IF (r_suah.hist_start_dt = r_suah.hist_end_dt) THEN
                          r_suah.hist_start_dt := r_suah.hist_start_dt - 1 /
               (60*24*60);
            END IF;

            DECLARE
                l_rowid VARCHAR2(25);
                l_org_id NUMBER := igs_ge_gen_003.get_org_id;
            BEGIN

            IGS_EN_SU_ATTEMPT_H_PKG.INSERT_ROW (
                                        x_rowid                         => l_rowid,
                                        x_person_id                     =>r_suah.person_id ,
                                        x_course_cd                     => r_suah.course_cd,
                                        x_unit_cd                       => r_suah.unit_cd,
                                        x_version_number                => r_suah.version_number,
                                        x_cal_type                      => r_suah.cal_type,
                                        x_ci_sequence_number            => r_suah.ci_sequence_number,
                                        x_hist_start_dt                 => r_suah.hist_start_dt,
                                        x_hist_end_dt                   => r_suah.hist_end_dt,
                                        x_hist_who                      => r_suah.hist_who,
                                        x_location_cd                   => r_suah.location_cd,
                                        x_unit_class                    => r_suah.unit_class,
                                        x_enrolled_dt                   => r_suah.enrolled_dt,
                                        x_unit_attempt_status           => r_suah.unit_attempt_status,
                                        x_administrative_unit_status    => r_suah.administrative_unit_status,
                                        x_aus_description               => r_suah.aus_description,
                                        x_discontinued_dt               => r_suah.discontinued_dt,
                                        x_rule_waived_dt                => r_suah.rule_waived_dt ,
                                        x_rule_waived_person_id         => r_suah.rule_waived_person_id ,
                                        x_no_assessment_ind             => r_suah.no_assessment_ind,
                                        x_exam_location_cd              => r_suah.exam_location_cd,
                                        x_elo_description               => r_suah.elo_description,
                                        x_sup_unit_cd                   => r_suah.sup_unit_cd,
                                        x_sup_version_number            => r_suah.sup_version_number,
                                        x_alternative_title             => r_suah.alternative_title,
                                        x_override_enrolled_cp          => r_suah.override_enrolled_cp,
                                        x_override_eftsu                => r_suah.override_eftsu,
                                        x_override_achievable_cp        => r_suah.override_achievable_cp,
                                        x_override_outcome_due_dt       => r_suah.override_outcome_due_dt,
                                        x_override_credit_reason        => r_suah.override_credit_reason,
                                        x_dcnt_reason_Cd                => r_suah.dcnt_reason_cd,
                                        x_uoo_id                        => r_suah.uoo_id,
                                        x_org_id                        => l_org_id, --,              --  x_deg_aud_detail_id  =>r_suah.deg_aud_detail_id
                                        x_core_indicator_code           => r_suah.core_indicator_code -- ptandon, Prevent Dropping Core Units build
          );

              END;
  END IF;
END;
/*EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_sua_hist');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;*/
END enrp_ins_sua_hist;


 FUNCTION  unit_effect_or_future_term( p_person_id igs_en_stdnt_ps_att_all.person_id%TYPE,
                                 p_dest_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE,
                                 p_uoo_id  igs_en_su_attempt_all.uoo_id%TYPE,
                                 p_term_cal_type igs_ca_inst_all.cal_type%TYPE,
                                 p_term_seq_num igs_ca_inst_all.sequence_number%TYPE)

 RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When           What
  -- smaddali  21-dec-04       created new function unit_effect_or_future_term for bug#4083358
  -------------------------------------------------------------------------------------------

    CURSOR c_sca_dtls IS
    SELECT cal_type
    FROM igs_en_stdnt_ps_att
    WHERE person_id = p_person_id AND
          course_cd  = p_dest_course_cd ;
    -- Cursor to get the term calendar start date for a given term calendar instance.
    CURSOR c_get_term_start_dt(cp_term_cal_type igs_ca_inst.cal_type%TYPE,
                               cp_term_ci_seq_num igs_ca_inst.sequence_number%TYPE)
    IS
     SELECT start_dt
     FROM   igs_ca_inst
     WHERE  cal_type = cp_term_cal_type
     AND    sequence_number = cp_term_ci_seq_num;

       -- Cursor to get the Term Calendar of the Unit.
       CURSOR c_get_term_cal(cp_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE,
                             cp_load_cal_type igs_ca_inst.cal_type%TYPE,
                             cp_load_ci_seq_num igs_ca_inst.sequence_number%TYPE)
       IS
        SELECT 'X'
        FROM   igs_ps_unit_ofr_opt uoo,
               igs_ca_teach_to_load_v tl
        WHERE  tl.teach_cal_type = uoo.cal_type
        AND    tl.teach_ci_sequence_number = uoo.ci_sequence_number
        AND    tl.load_cal_type = cp_load_cal_type
        AND    tl.load_ci_sequence_number = cp_load_ci_seq_num
        AND    uoo.uoo_id = cp_uoo_id;

        -- Cursor to get term calendars closest to the current term calendar and having
        -- a start date greater than the current term calendar.
       CURSOR cur_get_term_next(cp_acad_cal_type igs_ca_inst.cal_type%TYPE,
                                cp_curr_term_start_dt igs_ca_inst.start_dt%TYPE)
       IS
        SELECT cir.sub_cal_type term_cal_type,
               cir.sub_ci_sequence_number term_sequence_number
        FROM   igs_ca_inst_rel cir,
               igs_ca_inst ci,
               igs_ca_type ct,
               igs_ca_stat cs
        WHERE  cir.sup_cal_type = cp_acad_cal_type
        AND    ct.cal_type = cir.sub_cal_type
        AND    ct.s_cal_cat = 'LOAD'
        AND    ci.cal_type = cir.sub_cal_type
        AND    ci.sequence_number = cir.sub_ci_sequence_number
        AND    cs.cal_status = ci.cal_status
        AND    cs.s_cal_status = 'ACTIVE'
        AND    ci.start_dt > cp_curr_term_start_dt
        ORDER BY ci.start_dt ASC;

    l_acad_cal_type  igs_en_stdnt_ps_att.cal_type%TYPE;
    l_effect_or_future_term  BOOLEAN;
    l_load_ci_start_dt igs_ca_inst.start_dt%TYPE;
    l_dummy                                 VARCHAR2(1);

 BEGIN

    l_effect_or_future_term := FALSE;

    -- Get the effective term start date.
    OPEN c_get_term_start_dt(p_term_cal_type,p_term_seq_num);
    FETCH c_get_term_start_dt INTO l_load_ci_start_dt;
    CLOSE c_get_term_start_dt;

     -- Check whether the Effective term is related to the term with which
     -- the Unit Section is associated.
     OPEN c_get_term_cal(p_uoo_id,p_term_cal_type,p_term_seq_num);
     FETCH c_get_term_cal INTO l_dummy;
     -- If the unit belongs to the effective term, set l_effect_or_future_term flag to TRUE.
     IF c_get_term_cal%FOUND THEN
          l_effect_or_future_term := TRUE;
     END IF;
     CLOSE c_get_term_cal;

     -- If the unit doesn't belong to the effective term, check whether it belongs to any future term.
     IF l_effect_or_future_term = FALSE THEN
        -- get the academic calendar of the destination program
        OPEN c_sca_dtls;
        FETCH c_sca_dtls INTO l_acad_cal_type;
        CLOSE c_sca_dtls;
        -- Loop through the future terms belonging to this acadmic calendar.
        FOR get_term_next_rec IN cur_get_term_next(l_acad_cal_type,l_load_ci_start_dt)
        LOOP

          -- Check whether any of the future terms is related to the term with which
          -- the Unit Section is associated.
          OPEN c_get_term_cal(p_uoo_id,get_term_next_rec.term_cal_type,
                               get_term_next_rec.term_sequence_number);
          FETCH c_get_term_cal INTO l_dummy;
          -- If the unit belongs any future term, set l_effect_or_future_term flag to TRUE.
          IF c_get_term_cal%FOUND THEN
             l_effect_or_future_term := TRUE;
          END IF;
          CLOSE c_get_term_cal;

        END LOOP;

     END IF;

     RETURN l_effect_or_future_term ;

 END unit_effect_or_future_term;

PROCEDURE enrp_ins_sua_ref_trnsfr (
        p_person_id        IN NUMBER,
        p_source_course_cd IN VARCHAR2,
        p_dest_course_cd   IN VARCHAR2,
        p_uoo_id           IN NUMBER)
IS

Cursor c_source_ref_cd (cp_person_id NUMBER,
                        cp_source_course_cd VARCHAR2,
                        cp_uoo_id  NUMBER,
                        cp_dest_course_cd VARCHAR2) IS
  Select src_ref.rowid, src_ref.*
  From IGS_AS_SUA_REF_CDS src_ref
  Where person_id = cp_person_id
  And course_cd = cp_source_course_cd
  And uoo_id = cp_uoo_id
  And deleted_date is null
  And not exists ( Select 'x'
                 From IGS_AS_SUA_REF_CDS dest_ref
                 WHERE dest_ref.person_id = src_ref.person_id
                 And dest_ref.course_cd = cp_dest_course_cd
                 And dest_ref.uoo_id = src_ref.uoo_id
                 And dest_ref.deleted_date is null
                 And dest_ref. REFERENCE_CODE_ID = src_ref. REFERENCE_CODE_ID
                 And dest_ref. APPLIED_COURSE_CD  = src_ref. APPLIED_COURSE_CD
                );

  l_rowid VARCHAR2(25);
  l_suarid  igs_as_sua_ref_cds.suar_id%TYPE;
BEGIN

    FOR vc_source_ref_cd IN c_source_ref_cd(p_person_id,
                                            p_source_course_cd,
                                            p_uoo_id,
                                            p_dest_course_cd) LOOP

          igs_as_sua_ref_cds_pkg.insert_row (
             x_rowid                             => l_rowid,
             x_suar_id                           => l_suarid,
             x_person_id                         => vc_source_ref_cd.person_id,
             x_course_cd                         => p_dest_course_cd,
             x_uoo_id                            => vc_source_ref_cd.uoo_id,
             x_reference_code_id                 => vc_source_ref_cd.reference_code_id,
             x_reference_cd_type                 => vc_source_ref_cd.reference_cd_type,
             x_reference_cd                      => vc_source_ref_cd.reference_cd,
             x_applied_course_cd                 => vc_source_ref_cd.applied_course_cd,
             x_deleted_date                      => vc_source_ref_cd.deleted_date,
             x_mode                              => 'R' );

    END LOOP;

END enrp_ins_sua_ref_trnsfr;


FUNCTION Enrp_Ins_Sua_Trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 , -- source program
  p_transfer_course_cd IN VARCHAR2 ,  -- destination program
  p_coo_id              IN NUMBER ,
  p_unit_cd             IN VARCHAR2 ,
  p_version_number      IN NUMBER ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_return_type         OUT NOCOPY VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER,
  p_core_ind            IN VARCHAR2,
  p_term_cal_type       IN VARCHAR2,
  p_term_seq_num        IN NUMBER)
/*
||  Created By : pkpatel
||  Created On : 27-SEP-2002
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  kkillams        21-03-2003      Modified validation, to allow the unit transfer w.r.t bug 2863707
||  kkillams        25-04-2003      New parameter p_uoo_id is added w.r.t bug 2829262
||  ptandon         29-12-2003      Removed the Exception Handling section so that the correct
||                                  error message is displayed. Bug# 3328268.
|| ckasu            08-DEC-2004      modfied message name inorder to show invalid unit attempts can't
||                                  be transferred across careers message as a part  of bug#4048203
|| ckasu            21-Dec-2004     modified procedure inorder to Transfer Unit outcomes in ABA Transfer
||                                  as a part of bug# 4080883
|| smaddali         21-dec-04       Modified for bug#4083358 , to change logic for transfering unit attempts across terms
|| amuthu           18-May-2006     Removed the call to igs_en_val_sua.enrp_val_sua_cnfrm and replaced it with a local
||                                  procedure enrp_val_sua_cnfrm_before_pt. This is remove the holds validation.
||                                  the same has been added to IGS_EN_TRANSFER_APIS.enrp_val_excld_unit_pt
*/
RETURN BOOLEAN AS

BEGIN   -- enrp_ins_sua_trnsfr
  -- Transfer a IGS_EN_SU_ATTEMPT record as part of a IGS_PS_COURSE transfer.
DECLARE
  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
  cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
  cst_unconfirm CONSTANT  VARCHAR2(10) := 'UNCONFIRM';
  cst_dropped   CONSTANT  VARCHAR2(10) := 'DROPPED';
  cst_waitlist  CONSTANT  VARCHAR2(10) := 'WAITLISTED';
  cst_invalid  CONSTANT  VARCHAR2(10) := 'INVALID';
  -- These variables are declared as part Career Impact Part 2 DLD . Bug # 2158626
        v_source_course_type IGS_PS_VER.course_type%TYPE;
        v_destn_course_type IGS_PS_VER.course_type%TYPE;

  e_record_locked   EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_record_locked, -54);
  v_message_name      VARCHAR2(2000);
  v_fail_type     VARCHAR2(10) ;
  v_status      IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
  v_record_exists     BOOLEAN := FALSE;
  CURSOR c_sua IS
    SELECT  sua.person_id,
      sua.course_cd,
      sua.unit_cd,
      sua.version_number,
      sua.cal_type,
      sua.ci_sequence_number,
      sua.location_cd,
      sua.unit_class,
      sua.ci_start_dt,
      sua.ci_end_dt,
      sua.uoo_id,
      sua.enrolled_dt,
      sua.unit_attempt_status,
      sua.administrative_unit_status,
      sua.discontinued_dt,
      sua.waitlist_dt,
      sua.rule_waived_dt,
      sua.rule_waived_person_id,
      sua.no_assessment_ind,
      sua.sup_unit_cd,
      sua.sup_version_number,
      sua.exam_location_cd,
      sua.alternative_title,
      sua.override_enrolled_cp,
      sua.override_eftsu,
      sua.override_achievable_cp,
      sua.override_outcome_due_dt,
      sua.override_credit_reason,
      sua.org_unit_cd,
      sua.grading_schema_code,
      sua.gs_version_number,
      sua.deg_aud_detail_id,
      sua.student_career_transcript,
      sua.student_career_statistics,
      sua.administrative_priority,
      sua.dcnt_reason_cd,
      sua.session_id,
      sua.attribute_category,
      sua.attribute1,
      sua.attribute2,
      sua.attribute3,
      sua.attribute4,
      sua.attribute5,
      sua.attribute6,
      sua.attribute7,
      sua.attribute8,
      sua.attribute9,
      sua.attribute10,
      sua.attribute11,
      sua.attribute12,
      sua.attribute13,
      sua.attribute14,
      sua.attribute15,
      sua.attribute16,
      sua.attribute17,
      sua.attribute18,
      sua.attribute19,
      sua.attribute20,
      sua.waitlist_manual_ind,
      sua.wlst_priority_weight_num,
      sua.wlst_preference_weight_num,
      sua.core_indicator_code
    FROM  IGS_EN_SU_ATTEMPT sua
    WHERE sua.person_id           = p_person_id AND
          sua.course_cd           = p_course_cd AND
          sua.uoo_id              = p_uoo_id;
    v_sua_rec     c_sua%ROWTYPE;

  CURSOR c_sua_delete IS
    SELECT  sua.rowid rowid1,
            sua.unit_attempt_status unit_attempt_status
            FROM  IGS_EN_SU_ATTEMPT sua
            WHERE sua.person_id           = p_person_id AND
                  sua.course_cd           = p_transfer_course_cd AND
                  sua.uoo_id              = p_uoo_id
            FOR UPDATE OF sua.unit_attempt_status NOWAIT;

   CURSOR c_sua_career ( p_person_id IN igs_en_stdnt_ps_att.person_id%TYPE ,  p_course_cd IN igs_en_stdnt_ps_att.course_cd%TYPE ) IS
                SELECT  ver.course_type
                FROM    IGS_PS_VER ver ,
                        igs_en_stdnt_ps_att spa
                WHERE   ver.course_cd      = p_course_cd AND
                        ver.version_number = spa.version_number AND
                        spa.course_cd      = p_course_cd AND
                        spa.person_id      = p_person_id;


  l_unit_from_past_term BOOLEAN;
  l_sup_alread_transfered BOOLEAN;

BEGIN
      p_message_name := null;
      -- Check parameters.
      IF  p_person_id           IS NULL OR  p_course_cd           IS NULL OR
          p_transfer_course_cd  IS NULL OR  p_coo_id              IS NULL OR
          p_unit_cd             IS NULL OR  p_version_number      IS NULL OR
          p_cal_type            IS NULL OR  p_ci_sequence_number  IS NULL OR
          p_uoo_id              IS NULL THEN
                p_return_type := NULL;
                p_message_name := null;
                RETURN TRUE;
      END IF;
      -- Get the details of the IGS_EN_SU_ATTEMPT record which is to be
      -- transferred.
      OPEN c_sua;
      FETCH c_sua INTO v_sua_rec;
      IF (c_sua%NOTFOUND) THEN
        CLOSE c_sua;
        p_return_type := NULL;
        p_message_name := null;
        RETURN TRUE;
      END IF;
      CLOSE c_sua;

      -- check if the superior unit attempt exists
      l_sup_alread_transfered := TRUE;
      IF v_sua_rec.sup_unit_cd IS NOT NULL THEN
        IF NOT enrf_sup_sua_exists(
               p_person_id,
           p_transfer_course_cd,
           p_uoo_id) THEN
             p_return_type := NULL;
             p_message_name :=  'IGS_EN_INVALID_SUP';
             RETURN FALSE;
        END IF;
      END IF;

      -- get the source and destination careers
      OPEN  c_sua_career(p_person_id , p_course_cd);
      FETCH c_sua_career INTO v_source_course_type;
      CLOSE c_sua_career;
      OPEN  c_sua_career(p_person_id ,   p_transfer_course_cd);
      FETCH c_sua_career INTO v_destn_course_type;
      CLOSE c_sua_career;
      -- if career not setup then throw error
      IF v_source_course_type IS NULL OR  v_destn_course_type IS NULL THEN
            Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_sua_trnsfr');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
      END IF;

      -- set the unit attempt status for the destination
      IF v_sua_rec.unit_attempt_status = cst_enrolled THEN
            v_status := cst_enrolled;
      ELSIF v_sua_rec.unit_attempt_status = cst_unconfirm THEN
          -- only records in ENROLLED, COMPLETED, DISCONTINUED,
          -- DUPLICATE, WAITLISTED and INVALID statuses can be transferred.
            p_return_type := NULL;
            p_message_name := 'IGS_EN_SUA_ENR_COMPL_DISCN_DU';
            RETURN FALSE;
      ELSIF V_sua_rec.unit_attempt_status = cst_invalid THEN
            -- if the transfer is across career then do not allow the invalid unit to be transfered.
            IF v_source_course_type <> v_destn_course_type THEN
              p_return_type := NULL;
              p_message_name := 'IGS_EN_INV_SUA_TRAN';
              RETURN FALSE;
            END IF;
      END IF;

      -- Perform validations on the IGS_EN_SU_ATTEMPT record to be created.
      IF v_status = cst_enrolled THEN   -- perform confirmation validations
        IF enrp_val_sua_cnfrm_before_pt(p_person_id,
                                             p_transfer_course_cd,
                                             p_unit_cd,
                                             p_version_number,
                                             p_cal_type,
                                             p_ci_sequence_number,
                                             v_sua_rec.ci_end_dt,
                                             v_sua_rec.location_cd,
                                             v_sua_rec.unit_class,
                                             v_sua_rec.enrolled_dt,
                                             v_fail_type,
                                             v_message_name) = FALSE THEN
          p_return_type := v_fail_type;
          p_message_name := v_message_name;
          RETURN FALSE;
        END IF;
      END IF;

      -- Check that the record to be inserted does not already exist
      -- (primary key violation).
      FOR v_uas IN c_sua_delete LOOP
        -- If unit_attempt_status = 'UNCONFIRM' then delete the record
        -- added dropped  in the IF condition, to delete dropped unit records also, bug #2394594 by kkillams

        -- removed cst_dropped and added ELSIF by ckasu as a part of bug #4080883 inorder to allow update of
        -- unit attempt  rather than deleting of unit attempt when unit attempt status is 'DROPPED'
        IF v_uas.unit_attempt_status IN (cst_unconfirm) THEN
           IGS_EN_SU_ATTEMPT_PKG.DELETE_ROW( v_uas.rowid1 );
        ELSIF v_uas.unit_attempt_status <> cst_dropped THEN
          v_record_exists := TRUE;
          EXIT;
        END IF;
      END LOOP;
      -- Student IGS_PS_UNIT attempt already exists.
      IF v_record_exists = TRUE THEN
        p_return_type := NULL;
        p_message_name := 'IGS_EN_TRNS_SUA_EXISTS';
        RETURN FALSE;
      END IF;

    --  While transferring the Units check whether destination program is with in the same Career of the source program,
    --  If destination Program is of Different Career then assign NULL to the columns "STUDENT_CAREER_STATISTICS" and
    --  "STUDENT_CAREER_TRANSCRIPT" in the Unit Attempt Transferring into the destination Program.Bug # 2158626.


        IF v_source_course_type <> v_destn_course_type THEN
             v_sua_rec.student_career_transcript := NULL;
             v_sua_rec.student_career_statistics := NULL;
        END IF;
        --chceck for the waitlist priority/preference
        IF v_sua_rec.unit_attempt_status = cst_waitlist AND
           v_sua_rec.wlst_priority_weight_num IS NOT NULL AND
           v_sua_rec.wlst_preference_weight_num IS NOT NULL THEN

           v_sua_rec.wlst_priority_weight_num:=NULL;
           v_sua_rec.wlst_preference_weight_num:= NULL;
           v_sua_rec.administrative_priority:= NULL;
         END IF;

      -- Determine the unit_attempt_status for the transferred record
      l_unit_from_past_term := enrf_unit_from_past(p_person_id,
                                                   p_course_cd,
                             p_uoo_id,
                             v_sua_rec.unit_attempt_status,
                             v_sua_rec.discontinued_dt,
                             p_term_cal_type,
                             p_term_seq_num);

      IF v_sua_rec.unit_attempt_status = cst_completed THEN
        IF l_unit_from_past_term THEN
          v_sua_rec.unit_attempt_status := cst_duplicate;
        ELSE
          v_sua_rec.unit_attempt_status := cst_completed;
        END IF;
      ELSIF v_sua_rec.unit_attempt_status = cst_discontin THEN
        IF l_unit_from_past_term THEN
          v_sua_rec.unit_attempt_status := cst_duplicate;
        ELSE
          v_sua_rec.unit_attempt_status := cst_discontin;
        END IF;
      END IF;

        -- Transfer the student IGS_PS_UNIT attempt record
        DECLARE
                l_rowid VARCHAR2(25);
                l_org_id NUMBER := igs_ge_gen_003.get_org_id;
        BEGIN

                IF NVL(FND_PROFILE.VALUE('IGS_EN_CORE_VAL'),'N') = 'Y' THEN
                  v_sua_rec.core_indicator_code := NVL(p_core_ind, v_sua_rec.core_indicator_code);
                END IF;

		IF v_sua_rec.unit_attempt_status = cst_duplicate THEN
                v_sua_rec.administrative_unit_status := NULL;
                v_sua_rec.dcnt_reason_cd := NULL;
                v_sua_rec.discontinued_dt := NULL;
                END IF;



                IGS_EN_SU_ATTEMPT_PKG.INSERT_ROW  (
                                                   X_ROWID                       => l_rowid,
                                                   X_PERSON_ID                   => p_person_id,
                                                   X_COURSE_CD                   => p_transfer_course_cd,
                                                   X_UNIT_CD                     => p_unit_cd,
                                                   X_VERSION_NUMBER              => p_version_number,
                                                   X_CAL_TYPE                    => p_cal_type,
                                                   X_CI_SEQUENCE_NUMBER          => p_ci_sequence_number,
                                                   X_LOCATION_CD                 => v_sua_rec.location_cd,
                                                   X_UNIT_CLASS                  => v_sua_rec.unit_class,
                                                   X_CI_START_DT                 => v_sua_rec.ci_start_dt,
                                                   X_CI_END_DT                   => v_sua_rec.ci_end_dt,
                                                   X_UOO_ID                      => v_sua_rec.uoo_id,
                                                   X_ENROLLED_DT                 => v_sua_rec.enrolled_dt,
                                                   X_ADMINISTRATIVE_UNIT_STATUS  => v_sua_rec.administrative_unit_status,
                                                   X_ADMINISTRATIVE_PRIORITY     => v_sua_rec.administrative_priority,
                                                   X_unit_attempt_status         => v_sua_rec.unit_attempt_status,
                                                   X_DISCONTINUED_DT             => v_sua_rec.discontinued_dt,
                                                   X_RULE_WAIVED_DT              => v_sua_rec.rule_waived_dt,
                                                   X_RULE_WAIVED_PERSON_ID       => v_sua_rec.rule_waived_person_id,
                                                   X_NO_ASSESSMENT_IND           => v_sua_rec.no_assessment_ind,
                                                   X_SUP_UNIT_CD                 => v_sua_rec.sup_unit_cd,
                                                   X_SUP_VERSION_NUMBER          => v_sua_rec.sup_version_number,
                                                   X_EXAM_LOCATION_CD            => v_sua_rec.exam_location_cd,
                                                   X_ALTERNATIVE_TITLE           => v_sua_rec.alternative_title,
                                                   X_OVERRIDE_ENROLLED_CP        => v_sua_rec.override_enrolled_cp,
                                                   X_OVERRIDE_EFTSU              => v_sua_rec.override_eftsu,
                                                   X_OVERRIDE_ACHIEVABLE_CP      => v_sua_rec.override_achievable_cp,
                                                   X_OVERRIDE_OUTCOME_DUE_DT     => v_sua_rec.override_outcome_due_dt,
                                                   X_OVERRIDE_CREDIT_REASON      => v_sua_rec.override_credit_reason,
                                                   X_WAITLIST_DT                 => v_sua_rec.waitlist_dt,
                                                   X_DCNT_REASON_CD              => v_sua_rec.dcnt_reason_cd,
                                                   X_MODE                        => 'R',
                                                   X_ORG_ID                      => l_org_id,
                                                   X_ORG_UNIT_CD                 => v_sua_rec.org_unit_cd,
                                                   X_SESSION_ID                  => v_sua_rec.session_id, --This column has been added as per the Bug# 2172380.
                                                   -- Added the columns grading schema code and gs_version_number as a part of the bug 2037897. - aiyer
                                                   X_GRADING_SCHEMA_CODE         => v_sua_rec.grading_schema_code,
                                                   X_GS_VERSION_NUMBER           => v_sua_rec.gs_version_number,
                                                   -- Added the column deg_aud_detail_id as part of Degree Audit Interface build. (Bug# 2033208)
                                                   X_DEG_AUD_DETAIL_ID           => v_sua_rec.deg_aud_detail_id,
                                                   -- These columns insert values depending on whether the course being transferred to belongs to
                                                   -- the same Career (course Type) or not .Bug # 2158626.
                                                   X_STUDENT_CAREER_TRANSCRIPT   => v_sua_rec.student_career_transcript,
                                                   X_STUDENT_CAREER_STATISTICS   => v_sua_rec.student_career_statistics ,
                                                   X_ATTRIBUTE_CATEGORY          => v_sua_rec.attribute_category,
                                                   X_ATTRIBUTE1                  => v_sua_rec.attribute1,
                                                   X_ATTRIBUTE2                  => v_sua_rec.attribute2,
                                                   X_ATTRIBUTE3                  => v_sua_rec.attribute3,
                                                   X_ATTRIBUTE4                  => v_sua_rec.attribute4,
                                                   X_ATTRIBUTE5                  => v_sua_rec.attribute5,
                                                   X_ATTRIBUTE6                  => v_sua_rec.attribute6,
                                                   X_ATTRIBUTE7                  => v_sua_rec.attribute7,
                                                   X_ATTRIBUTE8                  => v_sua_rec.attribute8,
                                                   X_ATTRIBUTE9                  => v_sua_rec.attribute9,
                                                   X_ATTRIBUTE10                 => v_sua_rec.attribute10,
                                                   X_ATTRIBUTE11                 => v_sua_rec.attribute11,
                                                   X_ATTRIBUTE12                 => v_sua_rec.attribute12,
                                                   X_ATTRIBUTE13                 => v_sua_rec.attribute13,
                                                   X_ATTRIBUTE14                 => v_sua_rec.attribute14,
                                                   X_ATTRIBUTE15                 => v_sua_rec.attribute15,
                                                   X_ATTRIBUTE16                 => v_sua_rec.attribute16,
                                                   X_ATTRIBUTE17                 => v_sua_rec.attribute17,
                                                   X_ATTRIBUTE18                 => v_sua_rec.attribute18,
                                                   X_ATTRIBUTE19                 => v_sua_rec.attribute19,
                                                   X_ATTRIBUTE20                 => v_sua_rec.attribute20,
                                                   X_WAITLIST_MANUAL_IND         => v_sua_rec.waitlist_manual_ind,
                                                   X_wlst_priority_weight_num    => v_sua_rec.wlst_priority_weight_num,
                                                   X_wlst_preference_weight_num  => v_sua_rec.wlst_preference_weight_num,
                                                   X_CORE_INDICATOR_CODE         => v_sua_rec.core_indicator_code,
                                                   X_UPD_AUDIT_FLAG              => 'N',
                                                   X_SS_SOURCE_IND               => 'A');


             -- copy all the child records for the unit attempt if necessary
             IF v_sua_rec.unit_attempt_status in (cst_enrolled,cst_waitlist, cst_discontin,cst_completed) THEN
               enrp_ins_suai_trnsfr(
                 p_person_id        => p_person_id,
                 p_source_course_cd => p_course_cd,
                 p_dest_course_cd   => p_transfer_course_cd,
                 p_source_uoo_id    => p_uoo_id,
                 p_dest_uoo_id      => p_uoo_id,
                 p_delete_source    => TRUE );

                enrp_ins_suao_Trnsfr (
                 p_person_id        => p_person_id,
                 p_source_course_cd => p_course_cd,
                 p_dest_course_cd   => p_transfer_course_cd,
                 p_source_uoo_id    => p_uoo_id,
                 p_dest_uoo_id      => p_uoo_id,
                 p_delete_source    => TRUE);

                enrp_ins_splace_Trnsfr (
                 p_person_id        => p_person_id,
                 p_source_course_cd => p_course_cd,
                 p_dest_course_cd   => p_transfer_course_cd,
                 p_source_uoo_id    => p_uoo_id,
                 p_dest_uoo_id      => p_uoo_id);

             END IF;

             IF v_sua_rec.unit_attempt_status NOT IN ('UNCONFIRM', 'DUPLICATE') THEN
                 enrp_ins_sua_ref_trnsfr (
                    p_person_id        => p_person_id,
                    p_source_course_cd => p_course_cd,
                    p_dest_course_cd   => p_transfer_course_cd,
                    p_uoo_id           => p_uoo_id);
             END IF;


           END;

  RETURN TRUE;

EXCEPTION
  WHEN e_record_locked THEN
    p_return_type := NULL;
    p_message_name := 'IGS_EN_UNCONFIRM_SUA_EXISTS';
    RETURN FALSE;
  WHEN OTHERS THEN
    IF (c_sua%ISOPEN) THEN
      CLOSE c_sua;
    END IF;
    IF (c_sua_delete%ISOPEN) THEN
      CLOSE c_sua_delete;
    END IF;
    RAISE;
END;

END enrp_ins_sua_trnsfr;



Procedure Enrp_Ins_Susa_Hist(
  p_person_id         IN NUMBER ,
  p_course_cd         IN VARCHAR2 ,
  p_unit_set_cd       IN VARCHAR2 ,
  p_sequence_number   IN NUMBER ,
  p_new_us_version_number IN NUMBER ,
  p_old_us_version_number IN NUMBER ,
  p_new_selection_dt  IN DATE ,
  p_old_selection_dt  IN DATE ,
  p_new_student_confirmed_ind IN VARCHAR2 ,
  p_old_student_confirmed_ind IN VARCHAR2 ,
  p_new_end_dt IN DATE ,
  p_old_end_dt IN DATE ,
  p_new_parent_unit_set_cd IN VARCHAR2 ,
  p_old_parent_unit_set_cd IN VARCHAR2 ,
  p_new_parent_sequence_number IN NUMBER ,
  p_old_parent_sequence_number IN NUMBER ,
  p_new_primary_set_ind IN VARCHAR2 ,
  p_old_primary_set_ind IN VARCHAR2 ,
  p_new_voluntary_end_ind IN VARCHAR2 ,
  p_old_voluntary_end_ind IN VARCHAR2,
  p_new_authorised_person_id IN NUMBER ,
  p_old_authorised_person_id IN NUMBER ,
  p_new_authorised_on IN DATE ,
  p_old_authorised_on IN DATE ,
  p_new_override_title IN VARCHAR2 ,
  p_old_override_title IN VARCHAR2 ,
  p_new_rqrmnts_complete_ind IN VARCHAR2 ,
  p_old_rqrmnts_complete_ind IN VARCHAR2 ,
  p_new_rqrmnts_complete_dt IN DATE ,
  p_old_rqrmnts_complete_dt IN DATE ,
  p_new_s_completed_source_type IN VARCHAR2 ,
  p_old_s_completed_source_type IN VARCHAR2 ,
  p_new_catalog_cal_type  IN VARCHAR2  ,
  p_old_catalog_cal_type  IN VARCHAR2  ,
  p_new_catalog_seq_num IN NUMBER  ,
  p_old_catalog_seq_num IN NUMBER   ,
  p_new_update_who IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE ,
  p_old_update_who IN IGS_EN_SU_ATTEMPT_ALL.last_updated_by%TYPE ,
  p_new_update_on IN IGS_EN_SU_ATTEMPT_ALL.last_update_DATE%TYPE,
  p_old_update_on IN IGS_EN_SU_ATTEMPT_ALL.last_update_DATE%TYPE )
AS
  gv_other_detail     VARCHAR2(255);
BEGIN -- enrp_ins_susa_hist
  -- Create a history for an IGS_AD_APPL record
DECLARE
  v_susa_rec    IGS_AS_SU_SETATMPT_H%ROWTYPE;
  v_create_history  BOOLEAN := FALSE;
BEGIN
  -- Create a history for a IGS_AS_SU_SETATMPT record.
  -- Check if any of the non-primary key fields have been changed
  -- and set the flag v_create_history to indicate so.
  IF p_new_us_version_number <> p_old_us_version_number THEN
    v_susa_rec.us_version_number := p_old_us_version_number;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_selection_dt, igs_ge_date.igsdate('1900/01/01')) <>
      NVL(p_old_selection_dt,igs_ge_date.igsdate('1900/01/01'))  THEN
    v_susa_rec.selection_dt := p_old_selection_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_student_confirmed_ind,'U') <>
      NVL(p_old_student_confirmed_ind,'U') THEN
    v_susa_rec.student_confirmed_ind := p_old_student_confirmed_ind;
    v_create_history := TRUE;
  END IF;
  IF  NVL(p_new_end_dt,igs_ge_date.igsdate('1800/01/01')) <>
      NVL(p_old_end_dt,igs_ge_date.igsdate('1800/01/01')) THEN
    v_susa_rec.end_dt := p_old_end_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_parent_unit_set_cd, 'NULL') <>
      NVL(p_old_parent_unit_set_cd, 'NULL') THEN
    v_susa_rec.parent_unit_set_cd := p_old_parent_unit_set_cd;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_parent_sequence_number, -1) <>
      NVL(p_old_parent_sequence_number, -1) THEN
    v_susa_rec.parent_sequence_number := p_old_parent_sequence_number;
    v_create_history := TRUE;
  END IF;
  IF p_new_primary_set_ind <> p_old_primary_set_ind THEN
    v_susa_rec.primary_set_ind := p_old_primary_set_ind;
    v_create_history := TRUE;
  END IF;
  IF p_new_voluntary_end_ind <> p_old_voluntary_end_ind  THEN
    v_susa_rec.voluntary_end_ind := p_old_voluntary_end_ind;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_authorised_person_id, 0) <>
      NVL(p_old_authorised_person_id, 0) THEN
    v_susa_rec.authorised_person_id := p_old_authorised_person_id;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_authorised_on, igs_ge_date.igsdate('1800/01/01')) <>
      NVL(p_old_authorised_on, igs_ge_date.igsdate('1800/01/01')) THEN
    v_susa_rec.authorised_on := p_old_authorised_on;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_override_title,'NULL') <> NVL(p_old_override_title,'NULL') THEN
    v_susa_rec.override_title:= p_old_override_title;
    v_create_history := TRUE;
  END IF;
  IF p_new_rqrmnts_complete_ind <> p_old_rqrmnts_complete_ind THEN
    v_susa_rec.rqrmnts_complete_ind := p_old_rqrmnts_complete_ind;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_rqrmnts_complete_dt, igs_ge_date.igsdate('1800/01/01')) <>
      NVL(p_old_rqrmnts_complete_dt, igs_ge_date.igsdate('1800/01/01')) THEN
    v_susa_rec.rqrmnts_complete_dt := p_old_rqrmnts_complete_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_s_completed_source_type,'NULL') <>
      NVL(p_old_s_completed_source_type,'NULL') THEN
    v_susa_rec.s_completed_source_type := p_old_s_completed_source_type;
    v_create_history := TRUE;
  END IF;

        IF NVL(p_new_catalog_cal_type ,'NULL') <>
      NVL(p_old_catalog_cal_type,'NULL') THEN
    v_susa_rec.catalog_cal_type := p_old_catalog_cal_type;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_catalog_seq_num,-1) <>
      NVL(p_old_catalog_seq_num,-1) THEN
    v_susa_rec.catalog_seq_num := p_old_catalog_seq_num;
    v_create_history := TRUE;
  END IF;


  -- Create a history record if a column has changed value
  IF v_create_history = TRUE THEN
    v_susa_rec.person_id      := p_person_id;
    v_susa_rec.course_cd      := p_course_cd;
    v_susa_rec.unit_set_cd      := p_unit_set_cd;
    v_susa_rec.sequence_number    := p_sequence_number;
    v_susa_rec.hist_start_dt    := p_old_update_on;
    v_susa_rec.hist_end_dt      := p_new_update_on;
    v_susa_rec.hist_who     := p_old_update_who;


            DECLARE
                               l_rowid VARCHAR2(25);
                               l_org_id NUMBER := igs_ge_gen_003.get_org_id;
            BEGIN
    IGS_AS_SU_SETATMPT_H_PKG.INSERT_ROW (
                        x_rowid => l_rowid,
      x_person_id => v_susa_rec.person_id,
      x_course_cd => v_susa_rec.course_cd,
      x_unit_set_cd => v_susa_rec.unit_set_cd,
      x_us_version_number => v_susa_rec.us_version_number,
      x_sequence_number => v_susa_rec.sequence_number,
      x_hist_start_dt => v_susa_rec.hist_start_dt,
      x_hist_end_dt => v_susa_rec.hist_end_dt,
      x_hist_who => v_susa_rec.hist_who,
      x_selection_dt => v_susa_rec.selection_dt,
      x_student_confirmed_ind =>v_susa_rec.student_confirmed_ind ,
      x_end_dt => v_susa_rec.end_dt,
      x_parent_unit_set_cd => v_susa_rec.parent_unit_set_cd,
      x_parent_sequence_number => v_susa_rec.parent_sequence_number,
      x_primary_set_ind => v_susa_rec.primary_set_ind,
      x_voluntary_end_ind => v_susa_rec.voluntary_end_ind,
      x_authorised_person_id => v_susa_rec.authorised_person_id,
      x_authorised_on => v_susa_rec.authorised_on,
      x_override_title => v_susa_rec.override_title,
      x_rqrmnts_complete_ind => v_susa_rec.rqrmnts_complete_ind,
      x_rqrmnts_complete_dt => v_susa_rec.rqrmnts_complete_dt,
      x_s_completed_source_type => v_susa_rec.s_completed_source_type ,
      x_catalog_cal_type  => v_susa_rec.catalog_cal_type ,
                        x_catalog_seq_num => v_susa_rec.catalog_seq_num,
            x_org_id => l_org_id);

    END;
  END IF;
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_susa_hist');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END enrp_ins_susa_hist;

FUNCTION Enrp_Ins_Susa_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_primary_set_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS
    INVALID_PARAM  EXCEPTION ;

BEGIN -- enrp_ins_susa_trnsfr
  -- Transfer a IGS_AS_SU_SETATMPT record as part of a IGS_PS_COURSE transfer.
DECLARE

  CURSOR  c_susa IS
    SELECT  susa.us_version_number,
            susa.sequence_number,
      susa.selection_dt,
      susa.student_confirmed_ind,
      susa.end_dt,
      susa.parent_unit_set_cd,
      susa.parent_sequence_number,
      susa.voluntary_end_ind,
      susa.authorised_person_id,
      susa.authorised_on,
      susa.override_title,
      susa.rqrmnts_complete_ind,
      susa.rqrmnts_complete_dt,
      susa.s_completed_source_type
    FROM  IGS_AS_SU_SETATMPT susa
    WHERE susa.person_id    = p_person_id AND
      susa.course_cd    = p_course_cd AND
      susa.unit_set_cd  = p_unit_set_cd AND
      susa.us_version_number  = p_us_version_number AND
      susa.sequence_number  = p_sequence_number;
  CURSOR  c_susa1 IS
    SELECT  'x'
    FROM  IGS_AS_SU_SETATMPT  susa
    WHERE susa.person_id    = p_person_id AND
      susa.course_cd    = p_transfer_course_cd AND
      susa.unit_set_cd  = p_unit_set_cd AND
      susa.us_version_number  = p_us_version_number;
  v_primary_set_ind IGS_AS_SU_SETATMPT.primary_set_ind%TYPE ;
  v_ret     BOOLEAN ;
  v_message_name    VARCHAR2(2000);
  v_message_text    VARCHAR2(2000);
  v_c_susa_rec    c_susa%ROWTYPE;
  v_c_susa1_found   VARCHAR2(1) ;
    --
    --  Next cursor added as per the HESA DLD Buils ENCR019. Bug# 2201753.
    --
    l_status NUMBER(3);


BEGIN
  p_message_name := null;
  -- Check parameters
  IF p_person_id IS NULL OR
      p_course_cd IS NULL OR
      p_transfer_course_cd IS NULL OR
      p_unit_set_cd IS NULL OR
      p_us_version_number IS NULL THEN
    RETURN TRUE;
  END IF;
  -- Get the details of the student_unit_sew_attempt record
  -- which is to be transfered.
  OPEN c_susa;
  FETCH c_susa INTO v_c_susa_rec;
  IF (c_susa%NOTFOUND) THEN  -- this should not happen
    CLOSE c_susa;
    p_message_name := null;
    RETURN TRUE;
  END IF;
  CLOSE c_susa;
  -- Determine if IGS_AS_SU_SETATMPT is to be transferred
  -- as a primary IGS_PS_UNIT set.
  IF p_primary_set_ind = 'Y' THEN
    v_primary_set_ind := 'Y';
  ELSE
    v_primary_set_ind := 'N';
  END IF;
  -- Perform validations on the IGS_AS_SU_SETATMPT record to be created.
  -- Call enrp_val_susa in IGS_EN_VAL_SUSA package to perform validations.
  v_ret := IGS_EN_VAL_SUSA.enrp_val_susa (
            p_person_id,
            p_transfer_course_cd,
            p_unit_set_cd,
            v_c_susa_rec.sequence_number,
            p_us_version_number,
            v_c_susa_rec.selection_dt,
            v_c_susa_rec.student_confirmed_ind,
            v_c_susa_rec.end_dt,
            v_c_susa_rec.parent_unit_set_cd,
            v_c_susa_rec.parent_sequence_number,
            v_primary_set_ind,
            v_c_susa_rec.voluntary_end_ind,
            v_c_susa_rec.authorised_person_id,
            v_c_susa_rec.authorised_on,
            v_c_susa_rec.override_title,
            v_c_susa_rec.rqrmnts_complete_ind,
            v_c_susa_rec.rqrmnts_complete_dt,
            v_c_susa_rec.s_completed_source_type,
            'INSERT',
            v_message_name,
            v_message_text);
  -- Check v_ret
  IF v_ret = FALSE THEN
    IF v_message_name is not null and v_message_name <> 'IGS_EN_UNIT_SET_NOT_PARENT_EX' THEN
      p_message_name := v_message_name;
      RETURN FALSE;
    END IF;
  END IF;
  -- Check that the record to be inserted doesn't already exist.
  OPEN c_susa1;
  FETCH c_susa1 INTO v_c_susa1_found;
  IF (c_susa1%FOUND) THEN
    -- IGS_AS_SU_SETATMPT already exists.
    CLOSE c_susa1;
    p_message_name := 'IGS_EN_SUA_SET_ATT_TRNS_EXIST';
    RETURN FALSE;
  END IF;
  CLOSE c_susa1;
  -- Transfer the IGS_EN_SU_ATTEMPT.
                        DECLARE
                               l_rowid VARCHAR2(25) := NULL;
                        BEGIN
        IGS_AS_SU_SETATMPT_PKG.INSERT_ROW (
                                        x_rowid => l_rowid,
          x_person_id => p_person_id,
          x_course_cd => p_transfer_course_cd,
          x_unit_set_cd => p_unit_set_cd,
          x_us_version_number => p_us_version_number,
          x_sequence_number => v_c_susa_rec.sequence_number,
          x_selection_dt => v_c_susa_rec.selection_dt,
          x_end_dt => v_c_susa_rec.end_dt,
          x_parent_unit_set_cd => v_c_susa_rec.parent_unit_set_cd,
          x_parent_sequence_number => v_c_susa_rec.parent_sequence_number,
          x_primary_set_ind => v_primary_set_ind,
          x_voluntary_end_ind => v_c_susa_rec.voluntary_end_ind,
          x_authorised_person_id => v_c_susa_rec.authorised_person_id,
          x_authorised_on => v_c_susa_rec.authorised_on,
          x_override_title          => v_c_susa_rec.override_title,
          x_rqrmnts_complete_ind => v_c_susa_rec.rqrmnts_complete_ind,
          x_rqrmnts_complete_dt => v_c_susa_rec.rqrmnts_complete_dt,
          x_s_completed_source_type => v_c_susa_rec.s_completed_source_type,
          x_student_confirmed_ind => v_c_susa_rec.student_confirmed_ind,
          X_CATALOG_CAL_TYPE  => NULL,
          X_CATALOG_SEQ_NUM  => NULL,
          X_ATTRIBUTE_CATEGORY  => NULL,
          X_ATTRIBUTE1  => NULL,
          X_ATTRIBUTE2  => NULL,
          X_ATTRIBUTE3  => NULL,
          X_ATTRIBUTE4  => NULL,
          X_ATTRIBUTE5  => NULL,
          X_ATTRIBUTE6  => NULL,
          X_ATTRIBUTE7  => NULL,
          X_ATTRIBUTE8  => NULL,
          X_ATTRIBUTE9  => NULL,
          X_ATTRIBUTE10  => NULL,
          X_ATTRIBUTE11  => NULL,
          X_ATTRIBUTE12  => NULL,
          X_ATTRIBUTE13  => NULL,
          X_ATTRIBUTE14  => NULL,
          X_ATTRIBUTE15  => NULL,
          X_ATTRIBUTE16  => NULL,
          X_ATTRIBUTE17  => NULL,
          X_ATTRIBUTE18  => NULL,
          X_ATTRIBUTE19  => NULL,
          X_ATTRIBUTE20  => NULL,
          X_MODE => 'R');

        END;


  --
  --  New code added as per the HESA DLD Build. ENCR019 Bug# 2201753
  --

  --
  --  Get the OSS_COUNTRY_CODE
  --
  IF fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' THEN
      p_message_name := NULL;
      l_status  := NULL;
      IGS_HE_PROG_TRANSFER_PKG.HESA_STUD_SUSA_TRANS(
                    p_person_id             => p_person_id,
                    p_old_course_cd         => p_course_cd,
                    p_new_course_cd         => p_transfer_course_cd,
                    p_old_unit_set_cd       => p_unit_set_cd,
                    p_new_unit_set_cd       => p_unit_set_cd,
                    p_old_us_version_number => p_us_version_number,
                    p_new_us_version_number => p_us_version_number,
                    p_status                => l_status,
                    p_message_name          =>  p_message_name);
      IF NVL(l_Status,0) = 2 THEN -- ie. The procedure call has resulted in error.
         Raise INVALID_PARAM ;
      END IF;
  END IF;
  --
  --  End of the New code added as per the HESA DLD Build.
  --

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_susa%ISOPEN) THEN
      CLOSE c_susa;
    END IF;
    IF (c_susa1%ISOPEN) THEN
      CLOSE c_susa1;
    END IF;
    RAISE;
END;
EXCEPTION
        WHEN INVALID_PARAM THEN
             Fnd_Message.Set_Name('IGS', p_message_name);
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;

  WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_susa_trnsfr');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END enrp_ins_susa_trnsfr;

FUNCTION Enrp_Ins_Sut_Trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_transfer_course_cd  IN VARCHAR2 ,
  p_transfer_dt         IN DATE ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER )
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    25-04-2003      New parameter p_uoo_id is added w.r.t. bug number 2829262
  --ptandon     29-12-2003      Removed the Exception Handling section so that the correct
  --                            error message is displayed. Bug# 3328083.
  -------------------------------------------------------------------------------------------
RETURN BOOLEAN AS

BEGIN -- enrp_ins_sut_trnsfr
  -- Insert a record into the IGS_PS_STDNT_UNT_TRN table.
DECLARE
BEGIN
  p_message_name := null;
  IF (p_person_id IS NULL OR
      p_course_cd     IS NULL OR
      p_transfer_course_cd  IS NULL OR
      p_transfer_dt     IS NULL OR
      p_unit_cd     IS NULL OR
      p_cal_type    IS NULL OR
      p_ci_sequence_number  IS NULL) THEN
    RETURN TRUE;
  END IF;

            DECLARE
                   l_rowid VARCHAR2(25);
            BEGIN
            IGS_PS_STDNT_UNT_TRN_PKG.INSERT_ROW(
                                                 x_rowid                => l_rowid,
                                                 x_person_id            => p_person_id,
                                                 x_course_cd            => p_course_cd,
                                                 x_transfer_course_cd   =>p_transfer_course_cd ,
                                                 x_transfer_dt          => p_transfer_dt,
                                                 x_unit_cd              => p_unit_cd,
                                                 x_cal_type             => p_cal_type,
                                                 x_ci_sequence_number   => p_ci_sequence_number,
                                                 x_uoo_id               => p_uoo_id);
            END;
            RETURN TRUE;
END;
END enrp_ins_sut_trnsfr;
  --
  -- To transfer the Advance Standing from source Program to Destination Program.
  --
  PROCEDURE adv_stand_trans (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_course_cd_new                IN     VARCHAR2,
    p_version_number_new           IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) IS
    ------------------------------------------------------------------------------------------------
    --Created by  : Nalin Kumar, Oracle India
    --Date created: 08-Nov-2001
    --
    --Purpose: To transfer the Advance Standing from
    --         source Program to Destination Program.
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --pmarada    27-nov-2001  Added AV_STND_UNIT_ID column in Igs_Av_Stnd_Unit_Pkg.Insert_Row
    --                            Added AV_STND_UNIT_ID column in Igs_Av_Std_Unt_basis_Pkg.Insert_Row
    --        and obsolated some columns
    --                            Added AV_STND_UNIT_LVL_ID column in IGS_AV_STD_ULVLBASIS_PKG.Insert_Row
    --        and obsolated some columns
    --                            Added AV_STND_UNIT_ID column in Igs_Av_Stnd_alt_unit_Pkg.Insert_Row
    --        and obsolated some columns
    --rvivekan  10-dec-2002       Obsoleted column credit_percentage as a part of bug#3270446
    --ptandon   11-Dec-2003       Modified calls to Igs_Av_Std_Unt_Basis_Pkg.Insert_Row,
    --                            Igs_Av_Stnd_Alt_Unit_Pkg.Insert_Row and Igs_Av_Std_Ulvlbasis_Pkg.Insert_Row
    --                            to pass new value for Advanced Standing Unit ID as part of Bug# 3271754.
    --ptandon   23-Feb-2004       Put the cursor cur_adv_stnd in a cursor FOR LOOP so that transfer records
    --                            are created in igs_av_adv_standing_all table for all institutions.
    --                            Also modified the cursors cur_unit_dtls and cur_unit_lvl_dtls to pass
    --                            exemption_institution_cd parameter so that only the child records
    --                            corresponding to current parent record in igs_av_adv_standing_all table
    --                            are selected. Modified the cursors cur_unit_bas_dtls, cur_alt_unit_dtls
    --                            and cur_unit_lvl_bas_dtls to pass correct foreign key. Bug# 3461036.
    -------------------------------------------------------------------------------------------------
    --
    --  To get Org ID.
    --
    l_org_id                   NUMBER                                          := igs_ge_gen_003.get_org_id;
    --
    -- Cursor to get Exemption_Institution_Cd of the parent Program.
    --
    CURSOR cur_adv_stnd (cp_person_id NUMBER, cp_course_cd VARCHAR2, cp_version_number NUMBER) IS
      SELECT exemption_institution_cd
      FROM   igs_av_adv_standing
      WHERE  person_id = cp_person_id
      AND    course_cd = cp_course_cd
      AND    version_number = cp_version_number;
    --
    rec_adv_stnd             cur_adv_stnd%ROWTYPE;
    --
    -- Cursor to check whether any advanced standing record already exists in the destination program
    --
    CURSOR cur_dest_adv_stnd (
             cp_person_id NUMBER,
             cp_course_cd_new VARCHAR2,
             cp_version_number_new NUMBER,
             cp_exemption_institution_cd VARCHAR2
           ) IS
      SELECT avs.ROWID,
             avs.*
      FROM   igs_av_adv_standing avs
      WHERE  avs.person_id = cp_person_id
      AND    avs.course_cd = cp_course_cd_new
      AND    avs.version_number = cp_version_number_new
      AND    avs.exemption_institution_cd = cp_exemption_institution_cd;
    --
    rec_dest_adv_stnd        cur_dest_adv_stnd%ROWTYPE;
    --
    --  To get the Advance Standing Unit details records for the Source Program.
    --
    CURSOR cur_unit_dtls (
      cp_person_id                          NUMBER,
      cp_course_cd                          VARCHAR2,
      cp_version_number                     NUMBER,
      cp_exemption_institution_cd           VARCHAR2
    ) IS
      SELECT asu.ROWID,
             asu.*
      FROM   igs_av_stnd_unit_all asu
      WHERE  asu.person_id = cp_person_id
      AND    asu.as_course_cd = cp_course_cd
      AND    asu.as_version_number = cp_version_number
      AND    asu.exemption_institution_cd = cp_exemption_institution_cd
      AND    asu.s_adv_stnd_granting_status IN ('APPROVED', 'GRANTED');
    --
    l_av_stnd_unit_id          igs_av_stnd_unit.av_stnd_unit_id%TYPE;
    --
    --  To get the Advance Standing Unit details records for the Destination Program.
    --
    CURSOR cur_dest_unit_dtls (
      cp_person_id                          NUMBER,
      cp_as_course_cd                       VARCHAR2,
      cp_as_version_number                  NUMBER,
      cp_s_adv_stnd_type                    VARCHAR2,
      cp_unit_cd                            VARCHAR2,
      cp_version_number                     NUMBER,
      cp_exemption_institution_cd           VARCHAR2,
      cp_unit_details_id                    NUMBER,
      cp_tst_rslt_dtls_id                   NUMBER
    ) IS
      SELECT asu.ROWID,
             asu.*
      FROM   igs_av_stnd_unit_all asu
      WHERE  asu.person_id = cp_person_id
      AND    asu.as_course_cd = cp_as_course_cd
      AND    asu.as_version_number = cp_as_version_number
      AND    asu.s_adv_stnd_type = cp_s_adv_stnd_type
      AND    asu.unit_cd = cp_unit_cd
      AND    asu.version_number = cp_version_number
      AND    asu.exemption_institution_cd = cp_exemption_institution_cd
      AND    (asu.unit_details_id = cp_unit_details_id
      OR      asu.tst_rslt_dtls_id = cp_tst_rslt_dtls_id);
    --
    l_dest_av_stnd_unit_id   igs_av_stnd_unit.av_stnd_unit_id%TYPE;
    rec_dest_unit_dtls       cur_dest_unit_dtls%ROWTYPE;
    rec_dest_unit_dtls_found BOOLEAN;
    --
    --  To get the Advance Standing Basics Unit details records for the Source Program.
    --
    CURSOR cur_unit_bas_dtls (cp_av_stnd_unit_id NUMBER) IS
      SELECT *
      FROM   igs_av_std_unt_basis asub
      WHERE  asub.av_stnd_unit_id = cp_av_stnd_unit_id;
    --
    rec_unit_bas_dtls        cur_unit_bas_dtls%ROWTYPE;
    --
    --  To get the Advance Standing Alternate Unit details records for the Source Program.
    --
    CURSOR cur_alt_unit_dtls (cp_av_stnd_unit_id NUMBER) IS
      SELECT *
      FROM   igs_av_stnd_alt_unit asau
      WHERE  asau.av_stnd_unit_id = cp_av_stnd_unit_id;
    --
    rec_alt_unit_dtls        cur_alt_unit_dtls%ROWTYPE;
    --
    --  To get the Advance Standing Unit Level records for the Source Program.
    --
    CURSOR cur_unit_lvl_dtls (
      cp_person_id                          NUMBER,
      cp_course_cd                          VARCHAR2,
      cp_version_number                     NUMBER,
      cp_exemption_institution_cd           VARCHAR2
    ) IS
      SELECT asule.ROWID,
             asule.*
      FROM   igs_av_stnd_unit_lvl_all asule
      WHERE  asule.person_id = cp_person_id
      AND    asule.as_course_cd = cp_course_cd
      AND    asule.as_version_number = cp_version_number
      AND    asule.exemption_institution_cd = cp_exemption_institution_cd
      AND    asule.s_adv_stnd_granting_status IN ('APPROVED', 'GRANTED');
    --
    l_av_stnd_unit_lvl_id      igs_av_stnd_unit_lvl.av_stnd_unit_lvl_id%TYPE;
    --
    --  To get the Advance Standing Unit Level records for the Destination Program.
    --
    CURSOR cur_dest_unit_lvl_dtls (
      cp_person_id                          NUMBER,
      cp_as_course_cd                       VARCHAR2,
      cp_as_version_number                  NUMBER,
      cp_s_adv_stnd_type                    VARCHAR2,
      cp_unit_level                         VARCHAR2,
      cp_crs_group_ind                      VARCHAR2,
      cp_exemption_institution_cd           VARCHAR2,
      cp_unit_details_id                    NUMBER,
      cp_tst_rslt_dtls_id                   NUMBER,
      cp_qual_dets_id                       NUMBER
    ) IS
      SELECT asule.ROWID,
             asule.*
      FROM   igs_av_stnd_unit_lvl_all asule
      WHERE  asule.person_id = cp_person_id
      AND    asule.as_course_cd = cp_as_course_cd
      AND    asule.as_version_number = cp_as_version_number
      AND    asule.s_adv_stnd_type = cp_s_adv_stnd_type
      AND    asule.unit_level = cp_unit_level
      AND    asule.crs_group_ind = cp_crs_group_ind
      AND    asule.exemption_institution_cd = cp_exemption_institution_cd
      AND    (asule.unit_details_id = cp_unit_details_id
      OR      asule.tst_rslt_dtls_id = cp_tst_rslt_dtls_id
      OR      asule.qual_dets_id = cp_qual_dets_id);
    --
    l_dest_av_stnd_unit_lvl_id igs_av_stnd_unit_lvl.av_stnd_unit_lvl_id%TYPE;
    rec_dest_unit_lvl_dtls cur_dest_unit_lvl_dtls%ROWTYPE;
    rec_dest_unit_lvl_dtls_found BOOLEAN;
    --
    --  To get the Advance Standing Basics Unit Level records for the Source Program.
    --
    CURSOR cur_unit_lvl_bas_dtls (cp_av_stnd_unit_lvl_id NUMBER) IS
      SELECT *
      FROM   igs_av_std_ulvlbasis asuleb
      WHERE  asuleb.av_stnd_unit_lvl_id = cp_av_stnd_unit_lvl_id;
    --
    rec_unit_lvl_bas_dtls    cur_unit_lvl_bas_dtls%ROWTYPE;
    l_rowid1                   VARCHAR2 (25);
    l_rowid2                   VARCHAR2 (25);
    l_rowid3                   VARCHAR2 (25);
    l_rowid4                   VARCHAR2 (25);
    l_rowid5                   VARCHAR2 (25);
    l_rowid6                   VARCHAR2 (25);
    v_transfer_type            VARCHAR2(20) := 'NORMAL_TRANSFER';
    v_unt_transfer_flag        VARCHAR2(2) := 'Y';
    v_unt_lvl_transfer_flag    VARCHAR2(2) := 'Y';
    --
  BEGIN
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || 'adv_stand_trans.begin',
        'In Params : p_person_id => ' || p_person_id || ';' ||
        'p_course_cd => ' || p_course_cd || ';' ||
        'p_version_number => ' || p_version_number || ';' ||
        'p_course_cd_new => ' || p_course_cd_new || ';' ||
        'p_version_number_new => ' || p_version_number_new
      );
    END IF;
    --
    --  Creating the Advance Standing with the new Course_cd.
    --
    FOR rec_adv_stnd IN cur_adv_stnd (p_person_id, p_course_cd, p_version_number) LOOP
      --
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || 'adv_stand_trans.cur_adv_stnd',
          'Exemption Institution:' || rec_adv_stnd.exemption_institution_cd
        );
      END IF;
      --
      -- Creating the Advance Standing with the new Course_cd.
      -- First check if this is a case of Reverse Transfer
      --
      OPEN cur_dest_adv_stnd (
             p_person_id,
             p_course_cd_new,
             p_version_number_new,
             rec_adv_stnd.exemption_institution_cd
           );
      FETCH cur_dest_adv_stnd INTO rec_dest_adv_stnd;
      IF (cur_dest_adv_stnd%FOUND) THEN
        v_transfer_type := 'REVERSE_TRANSFER';
      ELSE
        v_transfer_type := 'NORMAL_TRANSFER';
      END IF;
      --
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_statement,
          g_module_head || 'adv_stand_trans.transfer_type',
          'Transfer Type:' || v_transfer_type
        );
      END IF;
      --
      CLOSE cur_dest_adv_stnd;
      --
      -- Advanced Standing Master record is to be created only during Normal Transfer.
      -- In case of Reverse Transfer the Advanced Standing Master record already exists.
      --
      IF (v_transfer_type = 'NORMAL_TRANSFER') THEN
        BEGIN
          l_rowid1 := NULL;
          igs_av_adv_standing_pkg.insert_row (
            x_rowid                        => l_rowid1,
            x_person_id                    => p_person_id,
            x_course_cd                    => p_course_cd_new,
            x_version_number               => p_version_number_new,
            x_total_exmptn_approved        => 0,
            x_total_exmptn_granted         => 0,
            x_total_exmptn_perc_grntd      => 0,
            x_exemption_institution_cd     => rec_adv_stnd.exemption_institution_cd,
            x_mode                         => 'R',
            x_org_id                       => l_org_id
          );
        EXCEPTION
          WHEN OTHERS THEN
            --
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string (
                fnd_log.level_exception,
                g_module_head || 'adv_stand_trans.igs_av_adv_standing_pkg_insert_exception',
                'Error:' || SQLERRM
              );
            END IF;
            RAISE;
        END;
      END IF;
      --
      --  Creating the Advance Standing details for Units.
      --
      FOR rec_unit_dtls IN cur_unit_dtls (
                               p_person_id,
                               p_course_cd,
                               p_version_number,
                               rec_adv_stnd.exemption_institution_cd
                             ) LOOP
        --
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || 'adv_stand_trans.cur_unit_dtls',
            rec_unit_dtls.person_id || ';' || rec_unit_dtls.as_course_cd || ';' ||
            rec_unit_dtls.as_version_number || ';' || rec_unit_dtls.s_adv_stnd_type || ';' ||
            rec_unit_dtls.unit_cd || ';' || rec_unit_dtls.version_number || ';' ||
            rec_unit_dtls.exemption_institution_cd || ';' || rec_unit_dtls.unit_details_id || ';' ||
            rec_unit_dtls.tst_rslt_dtls_id
          );
        END IF;
        --
        IF (v_transfer_type = 'REVERSE_TRANSFER') THEN
          --
          -- Get the destination advanced standing unit details
          --
          OPEN cur_dest_unit_dtls (
                 p_person_id,
                 p_course_cd_new,
                 p_version_number_new,
                 rec_unit_dtls.s_adv_stnd_type,
                 rec_unit_dtls.unit_cd,
                 rec_unit_dtls.version_number,
                 rec_unit_dtls.exemption_institution_cd,
                 rec_unit_dtls.unit_details_id,
                 rec_unit_dtls.tst_rslt_dtls_id
               );
          FETCH cur_dest_unit_dtls INTO rec_dest_unit_dtls;
          IF (cur_dest_unit_dtls%FOUND) THEN
            rec_dest_unit_dtls_found := TRUE;
          ELSE
            rec_dest_unit_dtls_found := FALSE;
          END IF;
          CLOSE cur_dest_unit_dtls;
          --
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || 'adv_stand_trans.dest_unit_dtls_found',
              rec_dest_unit_dtls.s_adv_stnd_granting_status
            );
          END IF;
          --
        END IF;
        --
        IF ((v_transfer_type = 'NORMAL_TRANSFER') OR
            ((v_transfer_type = 'REVERSE_TRANSFER') AND
             NOT (rec_dest_unit_dtls_found))) THEN
          --
          BEGIN
            l_rowid2 := NULL;
            l_av_stnd_unit_id := rec_unit_dtls.av_stnd_unit_id;
            igs_av_stnd_unit_pkg.insert_row (
              x_mode                         => 'R',
              x_rowid                        => l_rowid2,
              x_person_id                    => p_person_id,
              x_as_course_cd                 => p_course_cd_new,
              x_as_version_number            => p_version_number_new,
              x_s_adv_stnd_type              => rec_unit_dtls.s_adv_stnd_type,
              x_unit_cd                      => rec_unit_dtls.unit_cd,
              x_version_number               => rec_unit_dtls.version_number,
              x_s_adv_stnd_granting_status   => rec_unit_dtls.s_adv_stnd_granting_status,
              x_credit_percentage            => NULL,
              x_s_adv_stnd_recognition_type  => rec_unit_dtls.s_adv_stnd_recognition_type,
              x_approved_dt                  => rec_unit_dtls.approved_dt,
              x_authorising_person_id        => rec_unit_dtls.authorising_person_id,
              x_crs_group_ind                => rec_unit_dtls.crs_group_ind,
              x_exemption_institution_cd     => rec_unit_dtls.exemption_institution_cd,
              x_granted_dt                   => rec_unit_dtls.granted_dt,
              x_expiry_dt                    => rec_unit_dtls.expiry_dt,
              x_cancelled_dt                 => rec_unit_dtls.cancelled_dt,
              x_revoked_dt                   => rec_unit_dtls.revoked_dt,
              x_comments                     => rec_unit_dtls.comments,
              x_av_stnd_unit_id              => rec_unit_dtls.av_stnd_unit_id,
              x_cal_type                     => rec_unit_dtls.cal_type,
              x_ci_sequence_number           => rec_unit_dtls.ci_sequence_number,
              x_institution_cd               => rec_unit_dtls.institution_cd,
              x_unit_details_id              => rec_unit_dtls.unit_details_id,
              x_tst_rslt_dtls_id             => rec_unit_dtls.tst_rslt_dtls_id,
              x_grading_schema_cd            => rec_unit_dtls.grading_schema_cd,
              x_grd_sch_version_number       => rec_unit_dtls.grd_sch_version_number,
              x_grade                        => rec_unit_dtls.grade,
              x_achievable_credit_points     => rec_unit_dtls.achievable_credit_points,
              x_org_id                       => l_org_id,
              x_adv_stnd_trans               => 'Y'
            );
          EXCEPTION
            WHEN OTHERS THEN
              --
              IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string (
                  fnd_log.level_exception,
                  g_module_head || 'adv_stand_trans.igs_av_stnd_unit_pkg_insert_exception',
                  'Error:' || SQLERRM
                );
              END IF;
              RAISE;
          END;
          --
          --  Inserting the Basis Details of the Unit.
          --
          OPEN cur_unit_bas_dtls (l_av_stnd_unit_id);
          FETCH cur_unit_bas_dtls INTO  rec_unit_bas_dtls;
          IF cur_unit_bas_dtls%FOUND THEN
            BEGIN
              l_rowid3 := NULL;
              igs_av_std_unt_basis_pkg.insert_row (
                x_mode                         => 'R',
                x_rowid                        => l_rowid3,
                x_av_stnd_unit_id              => rec_unit_dtls.av_stnd_unit_id,
                x_basis_course_type            => rec_unit_bas_dtls.basis_course_type,
                x_basis_year                   => rec_unit_bas_dtls.basis_year,
                x_basis_completion_ind         => rec_unit_bas_dtls.basis_completion_ind,
                x_org_id                       => l_org_id
              );
            EXCEPTION
              WHEN OTHERS THEN
                --
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string (
                    fnd_log.level_exception,
                    g_module_head || 'adv_stand_trans.igs_av_std_unt_basis_pkg_insert_exception',
                    'Error:' || SQLERRM
                  );
                END IF;
                RAISE;
            END;
          END IF;
          CLOSE cur_unit_bas_dtls;
          --
          --  Processing Alternate Units.
          --
          IF rec_unit_dtls.s_adv_stnd_recognition_type = 'PRECLUSION' THEN
            FOR rec_alt_unit_dtls IN cur_alt_unit_dtls (l_av_stnd_unit_id) LOOP
              BEGIN
                l_rowid4 := NULL;
                igs_av_stnd_alt_unit_pkg.insert_row (
                  x_mode                         => 'R',
                  x_rowid                        => l_rowid4,
                  x_av_stnd_unit_id              => rec_unit_dtls.av_stnd_unit_id,
                  x_alt_unit_cd                  => rec_alt_unit_dtls.alt_unit_cd,
                  x_alt_version_number           => rec_alt_unit_dtls.alt_version_number,
                  x_optional_ind                 => rec_alt_unit_dtls.optional_ind
                );
              EXCEPTION
                WHEN OTHERS THEN
                  --
                  IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                    fnd_log.string (
                      fnd_log.level_exception,
                      g_module_head || 'adv_stand_trans.igs_av_stnd_alt_unit_pkg_insert_exception',
                      'Error:' || SQLERRM
                    );
                  END IF;
                  RAISE;
              END;
            END LOOP;
          END IF;
        ELSIF ((v_transfer_type = 'REVERSE_TRANSFER') AND
               (rec_dest_unit_dtls_found) AND
               (rec_dest_unit_dtls.s_adv_stnd_granting_status = 'TRANSFERRED')) THEN
          BEGIN
            igs_av_stnd_unit_pkg.update_row (
              x_mode                         => 'R',
              x_rowid                        => rec_dest_unit_dtls.ROWID,
              x_person_id                    => rec_dest_unit_dtls.person_id,
              x_as_course_cd                 => rec_dest_unit_dtls.as_course_cd,
              x_as_version_number            => rec_dest_unit_dtls.as_version_number,
              x_s_adv_stnd_type              => rec_dest_unit_dtls.s_adv_stnd_type,
              x_unit_cd                      => rec_dest_unit_dtls.unit_cd,
              x_version_number               => rec_dest_unit_dtls.version_number,
              x_s_adv_stnd_granting_status   => rec_unit_dtls.s_adv_stnd_granting_status,
              x_credit_percentage            => NULL,
              x_s_adv_stnd_recognition_type  => rec_dest_unit_dtls.s_adv_stnd_recognition_type,
              x_approved_dt                  => rec_dest_unit_dtls.approved_dt,
              x_authorising_person_id        => rec_dest_unit_dtls.authorising_person_id,
              x_crs_group_ind                => rec_dest_unit_dtls.crs_group_ind,
              x_exemption_institution_cd     => rec_dest_unit_dtls.exemption_institution_cd,
              x_granted_dt                   => rec_dest_unit_dtls.granted_dt,
              x_expiry_dt                    => rec_dest_unit_dtls.expiry_dt,
              x_cancelled_dt                 => rec_dest_unit_dtls.cancelled_dt,
              x_revoked_dt                   => rec_dest_unit_dtls.revoked_dt,
              x_comments                     => rec_dest_unit_dtls.comments,
              x_av_stnd_unit_id              => rec_dest_unit_dtls.av_stnd_unit_id,
              x_cal_type                     => rec_dest_unit_dtls.cal_type,
              x_ci_sequence_number           => rec_dest_unit_dtls.ci_sequence_number,
              x_institution_cd               => rec_dest_unit_dtls.institution_cd,
              x_unit_details_id              => rec_dest_unit_dtls.unit_details_id,
              x_tst_rslt_dtls_id             => rec_dest_unit_dtls.tst_rslt_dtls_id,
              x_grading_schema_cd            => rec_dest_unit_dtls.grading_schema_cd,
              x_grd_sch_version_number       => rec_dest_unit_dtls.grd_sch_version_number,
              x_grade                        => rec_dest_unit_dtls.grade,
              x_achievable_credit_points     => rec_dest_unit_dtls.achievable_credit_points
            );
          EXCEPTION
            WHEN OTHERS THEN
              --
              IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string (
                  fnd_log.level_exception,
                  g_module_head || 'adv_stand_trans.igs_av_stnd_unit_pkg_dest_update_exception',
                  'Error:' || SQLERRM
                );
              END IF;
              RAISE;
          END;
        ELSIF ((v_transfer_type = 'REVERSE_TRANSFER') AND
               (rec_dest_unit_dtls_found) AND
               (rec_dest_unit_dtls.s_adv_stnd_granting_status <> 'TRANSFERRED')) THEN
          p_message_name := 'IGS_EN_STDNT_ADV_STND_EXIST';
          v_unt_transfer_flag := 'N';
        END IF;
        BEGIN
	  IF (v_unt_transfer_flag = 'Y') THEN
          igs_av_stnd_unit_pkg.update_row (
            x_mode                         => 'R',
            x_rowid                        => rec_unit_dtls.ROWID,
            x_person_id                    => rec_unit_dtls.person_id,
            x_as_course_cd                 => rec_unit_dtls.as_course_cd,
            x_as_version_number            => rec_unit_dtls.as_version_number,
            x_s_adv_stnd_type              => rec_unit_dtls.s_adv_stnd_type,
            x_unit_cd                      => rec_unit_dtls.unit_cd,
            x_version_number               => rec_unit_dtls.version_number,
            x_s_adv_stnd_granting_status   => 'TRANSFERRED',
            x_credit_percentage            => NULL,
            x_s_adv_stnd_recognition_type  => rec_unit_dtls.s_adv_stnd_recognition_type,
            x_approved_dt                  => rec_unit_dtls.approved_dt,
            x_authorising_person_id        => rec_unit_dtls.authorising_person_id,
            x_crs_group_ind                => rec_unit_dtls.crs_group_ind,
            x_exemption_institution_cd     => rec_unit_dtls.exemption_institution_cd,
            x_granted_dt                   => rec_unit_dtls.granted_dt,
            x_expiry_dt                    => rec_unit_dtls.expiry_dt,
            x_cancelled_dt                 => rec_unit_dtls.cancelled_dt,
            x_revoked_dt                   => rec_unit_dtls.revoked_dt,
            x_comments                     => rec_unit_dtls.comments,
            x_av_stnd_unit_id              => rec_unit_dtls.av_stnd_unit_id,
            x_cal_type                     => rec_unit_dtls.cal_type,
            x_ci_sequence_number           => rec_unit_dtls.ci_sequence_number,
            x_institution_cd               => rec_unit_dtls.institution_cd,
            x_unit_details_id              => rec_unit_dtls.unit_details_id,
            x_tst_rslt_dtls_id             => rec_unit_dtls.tst_rslt_dtls_id,
            x_grading_schema_cd            => rec_unit_dtls.grading_schema_cd,
            x_grd_sch_version_number       => rec_unit_dtls.grd_sch_version_number,
            x_grade                        => rec_unit_dtls.grade,
            x_achievable_credit_points     => rec_unit_dtls.achievable_credit_points
          );
	  END IF;
        EXCEPTION
          WHEN OTHERS THEN
            --
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string (
                fnd_log.level_exception,
                g_module_head || 'adv_stand_trans.igs_av_stnd_unit_pkg_src_update_exception',
                'Error:' || SQLERRM
              );
            END IF;
            RAISE;
        END;
	v_unt_transfer_flag := 'Y';
      END LOOP;
      --
      --  Processing for Unit Level Details.
      --
      FOR rec_unit_lvl_dtls IN cur_unit_lvl_dtls (
                                   p_person_id,
                                   p_course_cd,
                                   p_version_number,
                                   rec_adv_stnd.exemption_institution_cd
                                 ) LOOP
        --
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_statement,
            g_module_head || 'adv_stand_trans.cur_unit_lvl_dtls',
            rec_unit_lvl_dtls.person_id || ';' || rec_unit_lvl_dtls.as_course_cd || ';' ||
            rec_unit_lvl_dtls.as_version_number || ';' || rec_unit_lvl_dtls.s_adv_stnd_type || ';' ||
            rec_unit_lvl_dtls.unit_level || ';' || rec_unit_lvl_dtls.crs_group_ind || ';' ||
            rec_unit_lvl_dtls.exemption_institution_cd || ';' || rec_unit_lvl_dtls.unit_details_id || ';' ||
            rec_unit_lvl_dtls.tst_rslt_dtls_id || ';' || rec_unit_lvl_dtls.qual_dets_id
          );
        END IF;
        --
        IF (v_transfer_type = 'REVERSE_TRANSFER') THEN
          --
          -- Get the destination advanced standing unit details
          --
          OPEN cur_dest_unit_lvl_dtls (
                 p_person_id,
                 p_course_cd_new,
                 p_version_number_new,
                 rec_unit_lvl_dtls.s_adv_stnd_type,
                 rec_unit_lvl_dtls.unit_level,
                 rec_unit_lvl_dtls.crs_group_ind,
                 rec_unit_lvl_dtls.exemption_institution_cd,
                 rec_unit_lvl_dtls.unit_details_id,
                 rec_unit_lvl_dtls.tst_rslt_dtls_id,
                 rec_unit_lvl_dtls.qual_dets_id
               );
          FETCH cur_dest_unit_lvl_dtls INTO rec_dest_unit_lvl_dtls;
          IF (cur_dest_unit_lvl_dtls%FOUND) THEN
            rec_dest_unit_lvl_dtls_found := TRUE;
          ELSE
            rec_dest_unit_lvl_dtls_found := FALSE;
          END IF;
          CLOSE cur_dest_unit_lvl_dtls;
          --
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || 'adv_stand_trans.dest_unit_lvl_dtls_found',
              rec_dest_unit_lvl_dtls.s_adv_stnd_granting_status
            );
          END IF;
          --
        END IF;
        --
        IF ((v_transfer_type = 'NORMAL_TRANSFER') OR
            ((v_transfer_type = 'REVERSE_TRANSFER') AND
             NOT (rec_dest_unit_lvl_dtls_found))) THEN
          BEGIN
            l_rowid5 := NULL;
            l_av_stnd_unit_lvl_id := rec_unit_lvl_dtls.av_stnd_unit_lvl_id;
            igs_av_stnd_unit_lvl_pkg.insert_row (
              x_mode                         => 'R',
              x_rowid                        => l_rowid5,
              x_person_id                    => p_person_id,
              x_as_course_cd                 => p_course_cd_new,
              x_as_version_number            => p_version_number_new,
              x_s_adv_stnd_type              => rec_unit_lvl_dtls.s_adv_stnd_type,
              x_unit_level                   => rec_unit_lvl_dtls.unit_level,
              x_crs_group_ind                => rec_unit_lvl_dtls.crs_group_ind,
              x_exemption_institution_cd     => rec_unit_lvl_dtls.exemption_institution_cd,
              x_s_adv_stnd_granting_status   => rec_unit_lvl_dtls.s_adv_stnd_granting_status,
              x_credit_points                => rec_unit_lvl_dtls.credit_points,
              x_approved_dt                  => rec_unit_lvl_dtls.approved_dt,
              x_authorising_person_id        => rec_unit_lvl_dtls.authorising_person_id,
              x_granted_dt                   => rec_unit_lvl_dtls.granted_dt,
              x_expiry_dt                    => rec_unit_lvl_dtls.expiry_dt,
              x_cancelled_dt                 => rec_unit_lvl_dtls.cancelled_dt,
              x_revoked_dt                   => rec_unit_lvl_dtls.revoked_dt,
              x_comments                     => rec_unit_lvl_dtls.comments,
              x_av_stnd_unit_lvl_id          => rec_unit_lvl_dtls.av_stnd_unit_lvl_id,
              x_cal_type                     => rec_unit_lvl_dtls.cal_type,
              x_ci_sequence_number           => rec_unit_lvl_dtls.ci_sequence_number,
              x_institution_cd               => rec_unit_lvl_dtls.institution_cd,
              x_unit_details_id              => rec_unit_lvl_dtls.unit_details_id,
              x_tst_rslt_dtls_id             => rec_unit_lvl_dtls.tst_rslt_dtls_id,
              x_org_id                       => l_org_id,
              x_adv_stnd_trans               => 'Y',
              x_qual_dets_id                 => rec_unit_lvl_dtls.qual_dets_id
            );
          EXCEPTION
            WHEN OTHERS THEN
              --
              IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string (
                  fnd_log.level_exception,
                  g_module_head || 'adv_stand_trans.igs_av_stnd_unit_lvl_pkg_insert_exception',
                  'Error:' || SQLERRM
                );
              END IF;
              RAISE;
          END;
          --
          --  Inserting the Basis Details of the Unit Level.
          --
          OPEN cur_unit_lvl_bas_dtls (l_av_stnd_unit_lvl_id);
          FETCH cur_unit_lvl_bas_dtls INTO  rec_unit_lvl_bas_dtls;
          IF cur_unit_lvl_bas_dtls%FOUND THEN
            BEGIN
              l_rowid6 := NULL;
              -- commented the bellow columns as part of AVCR001- Advanced standing dld obsolated these columns,bug 1960126
              igs_av_std_ulvlbasis_pkg.insert_row (
                x_mode                         => 'R',
                x_rowid                        => l_rowid6,
                x_av_stnd_unit_lvl_id          => rec_unit_lvl_dtls.av_stnd_unit_lvl_id,
                x_basis_course_type            => rec_unit_lvl_bas_dtls.basis_course_type,
                x_basis_year                   => rec_unit_lvl_bas_dtls.basis_year,
                x_basis_completion_ind         => rec_unit_lvl_bas_dtls.basis_completion_ind,
                x_org_id                       => l_org_id
              );
            EXCEPTION
              WHEN OTHERS THEN
                --
                IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                  fnd_log.string (
                    fnd_log.level_exception,
                    g_module_head || 'adv_stand_trans.igs_av_stnd_unit_lvl_pkg_insert_exception',
                    'Error:' || SQLERRM
                  );
                END IF;
                RAISE;
            END;
          END IF;
          CLOSE cur_unit_lvl_bas_dtls;
        ELSIF ((v_transfer_type = 'REVERSE_TRANSFER') AND
               (rec_dest_unit_lvl_dtls_found) AND
               (rec_dest_unit_lvl_dtls.s_adv_stnd_granting_status = 'TRANSFERRED')) THEN
          BEGIN
            igs_av_stnd_unit_lvl_pkg.update_row (
              x_mode                         => 'R',
              x_rowid                        => rec_dest_unit_lvl_dtls.ROWID,
              x_person_id                    => rec_dest_unit_lvl_dtls.person_id,
              x_as_course_cd                 => rec_dest_unit_lvl_dtls.as_course_cd,
              x_as_version_number            => rec_dest_unit_lvl_dtls.as_version_number,
              x_s_adv_stnd_type              => rec_dest_unit_lvl_dtls.s_adv_stnd_type,
              x_unit_level                   => rec_dest_unit_lvl_dtls.unit_level,
              x_crs_group_ind                => rec_dest_unit_lvl_dtls.crs_group_ind,
              x_exemption_institution_cd     => rec_dest_unit_lvl_dtls.exemption_institution_cd,
              x_s_adv_stnd_granting_status   => rec_unit_lvl_dtls.s_adv_stnd_granting_status,
              x_credit_points                => rec_dest_unit_lvl_dtls.credit_points,
              x_approved_dt                  => rec_dest_unit_lvl_dtls.approved_dt,
              x_authorising_person_id        => rec_dest_unit_lvl_dtls.authorising_person_id,
              x_granted_dt                   => rec_dest_unit_lvl_dtls.granted_dt,
              x_expiry_dt                    => rec_dest_unit_lvl_dtls.expiry_dt,
              x_cancelled_dt                 => rec_dest_unit_lvl_dtls.cancelled_dt,
              x_revoked_dt                   => rec_dest_unit_lvl_dtls.revoked_dt,
              x_comments                     => rec_dest_unit_lvl_dtls.comments,
              x_av_stnd_unit_lvl_id          => rec_dest_unit_lvl_dtls.av_stnd_unit_lvl_id,
              x_cal_type                     => rec_dest_unit_lvl_dtls.cal_type,
              x_ci_sequence_number           => rec_dest_unit_lvl_dtls.ci_sequence_number,
              x_institution_cd               => rec_dest_unit_lvl_dtls.institution_cd,
              x_unit_details_id              => rec_dest_unit_lvl_dtls.unit_details_id,
              x_tst_rslt_dtls_id             => rec_dest_unit_lvl_dtls.tst_rslt_dtls_id,
              x_qual_dets_id                 => rec_dest_unit_lvl_dtls.qual_dets_id
            );
          EXCEPTION
            WHEN OTHERS THEN
              --
              IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string (
                  fnd_log.level_exception,
                  g_module_head || 'adv_stand_trans.igs_av_stnd_unit_lvl_pkg_dest_update_exception',
                  'Error:' || SQLERRM
                );
              END IF;
              RAISE;
          END;
        ELSIF ((v_transfer_type = 'REVERSE_TRANSFER') AND
               (rec_dest_unit_lvl_dtls_found) AND
               (rec_dest_unit_lvl_dtls.s_adv_stnd_granting_status <> 'TRANSFERRED')) THEN
          p_message_name := 'IGS_EN_STDNT_ADV_STND_EXIST';
          v_unt_lvl_transfer_flag := 'N';
        END IF;
        BEGIN
	IF  (v_unt_lvl_transfer_flag = 'Y') THEN
          igs_av_stnd_unit_lvl_pkg.update_row (
            x_mode                         => 'R',
            x_rowid                        => rec_unit_lvl_dtls.ROWID,
            x_person_id                    => rec_unit_lvl_dtls.person_id,
            x_as_course_cd                 => rec_unit_lvl_dtls.as_course_cd,
            x_as_version_number            => rec_unit_lvl_dtls.as_version_number,
            x_s_adv_stnd_type              => rec_unit_lvl_dtls.s_adv_stnd_type,
            x_unit_level                   => rec_unit_lvl_dtls.unit_level,
            x_crs_group_ind                => rec_unit_lvl_dtls.crs_group_ind,
            x_exemption_institution_cd     => rec_unit_lvl_dtls.exemption_institution_cd,
            x_s_adv_stnd_granting_status   => 'TRANSFERRED',
            x_credit_points                => rec_unit_lvl_dtls.credit_points,
            x_approved_dt                  => rec_unit_lvl_dtls.approved_dt,
            x_authorising_person_id        => rec_unit_lvl_dtls.authorising_person_id,
            x_granted_dt                   => rec_unit_lvl_dtls.granted_dt,
            x_expiry_dt                    => rec_unit_lvl_dtls.expiry_dt,
            x_cancelled_dt                 => rec_unit_lvl_dtls.cancelled_dt,
            x_revoked_dt                   => rec_unit_lvl_dtls.revoked_dt,
            x_comments                     => rec_unit_lvl_dtls.comments,
            x_av_stnd_unit_lvl_id          => rec_unit_lvl_dtls.av_stnd_unit_lvl_id,
            x_cal_type                     => rec_unit_lvl_dtls.cal_type,
            x_ci_sequence_number           => rec_unit_lvl_dtls.ci_sequence_number,
            x_institution_cd               => rec_unit_lvl_dtls.institution_cd,
            x_unit_details_id              => rec_unit_lvl_dtls.unit_details_id,
            x_tst_rslt_dtls_id             => rec_unit_lvl_dtls.tst_rslt_dtls_id,
            x_qual_dets_id                 => rec_unit_lvl_dtls.qual_dets_id
          );
	  END IF;
        EXCEPTION
          WHEN OTHERS THEN
            --
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string (
                fnd_log.level_exception,
                g_module_head || 'adv_stand_trans.igs_av_stnd_unit_lvl_pkg_src_update_exception',
                'Error:' || SQLERRM
              );
            END IF;
            RAISE;
        END;
	v_unt_lvl_transfer_flag := 'Y';
      END LOOP;
    END LOOP;
  END adv_stand_trans;

  PROCEDURE  enrp_ins_sca_ukstat_trnsfr ( p_person_id             IN  NUMBER,
                  p_source_course_cd      IN  VARCHAR2,
                  p_destination_course_cd IN  VARCHAR2,
                  p_message_name          OUT NOCOPY VARCHAR2
                                        ) IS
  ------------------------------------------------------------------------------------------------
  --Created by  : Nalin Kumar, Oracle India
  --Date created: 28-Jan-2002
  --
  --Purpose: This procedure has been created as per the HESA Integration DLD. Bug# 2201753
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ------------------------------------------------------------------------------------------------
    l_status NUMBER(3) ;

  BEGIN

  --
  --Get the OSS_COUNTRY_CODE
  --
  IF fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' THEN
      l_status  := NULL;
      IGS_HE_PROG_TRANSFER_PKG.HESA_STUD_STAT_TRANS(
            p_person_id     =>  p_person_id,
            p_old_course_cd =>  p_source_course_cd,
            p_new_course_cd =>  p_destination_course_cd,
            p_status        =>  l_status,
            p_message_name  =>  p_message_name);

      IF NVL(l_Status,0) = 2 THEN -- ie. The procedure call has resulted in error.
             Fnd_Message.Set_Name('IGS', p_message_name);
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
      END IF;
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
        NULL;
  END enrp_ins_sca_ukstat_trnsfr;


  FUNCTION create_stream_unit_sets(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_new_admin_unit_set IN VARCHAR2,
    p_selection_dt IN DATE,
    p_confirmed_ind IN VARCHAR2,
    p_log_creation_dt IN DATE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

  ------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --bdeviset   29-JUL-2004    Added p_log_creation_dt as parameter.Before calling IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW/INSERT_ROW
  --            a check is made to see that their is no overlapping of selection,completion and
  --                          end dates for any two unit sets by calling check_usa_overlap.If it returns
  --                          false log entry is made and the insert or update is not carried out for bug 3149133.
   ------------------------------------------------------------------------------------------------
    CURSOR c_acad_us (cp_new_admin_unit_Set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE) IS
      SELECT usm.stream_unit_set_Cd
      FROM   igs_en_unit_set_map usm,
             igs_ps_us_prenr_cfg upc
      WHERE  upc.unit_set_cd = cp_new_admin_unit_set_cd
      AND    usm.mapping_set_cd = upc.mapping_set_cd
      AND    usm.sequence_no = upc.sequence_no;

    CURSOR c_us_version_number(cp_person_id  igs_en_stdnt_ps_att.person_id%TYPE,
                               cp_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE,
                               cp_unit_set_cd  igs_en_unit_set.unit_set_cd%TYPE) IS
      SELECT coous.us_version_number
      FROM igs_en_unit_set_stat uss, igs_ps_ofr_opt_unit_set_v coous, igs_en_stdnt_ps_att sca
      WHERE  sca.person_id = cp_person_id AND
             sca.course_cd = cp_course_cd AND
             sca.coo_id = coous.coo_id AND
             coous.unit_set_cd = cp_unit_set_cd AND
             coous.expiry_dt  IS NULL AND
            coous.unit_set_status = uss.unit_set_status AND
            uss.s_unit_set_status = 'ACTIVE'  ;

    CURSOR c_susa_exists (cp_stream_unit_Set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE,
                      cp_us_version_number IGS_AS_SU_SETATMPT.US_VERSION_NUMBER%TYPE,
                      cp_person_id IGS_AS_SU_SETATMPT.PERSON_ID%TYPE,
                      cp_course_cd IGS_AS_SU_SETATMPT.COURSE_CD%TYPE) IS
      SELECT susa.*, susa.rowid
      FROM   igs_as_su_setatmpt susa
      WHERE  susa.unit_set_cd = cp_stream_unit_set_cd
      AND    susa.us_version_number = cp_us_version_number
      AND    susa.person_id = cp_person_id
      AND    susa.course_cd  = cp_course_cd
      AND    susa.end_dt IS NULL
      ORDER BY susa.selection_dt desc;

    vc_susa_upd_rec         c_susa_exists%ROWTYPE;
    v_us_version_number     igs_en_unit_set.version_number%TYPE;
    v_selection_dt          igs_as_su_setatmpt.selection_dt%TYPE;
    vl_sequence_val         igs_as_su_setatmpt.SEQUENCE_NUMBER%TYPE;
    vl_rowid                VARCHAR2(25);
    v_confirmed_ind         igs_as_su_setatmpt.student_confirmed_ind%TYPE;
    p_warn_level varchar2(5);
    cst_pre_enrol   CONSTANT VARCHAR2(10) := 'PRE-ENROL';
    cst_error   CONSTANT VARCHAR2(5) := 'ERROR';

  BEGIN

    FOR vc_acad_us_rec in c_acad_us(p_new_admin_unit_set) LOOP

      OPEN c_us_version_number ( p_person_id, p_course_cd, vc_acad_us_rec.stream_unit_set_cd);
      FETCH c_us_version_number INTO v_us_version_number;

          IF c_us_version_number%FOUND THEN

            OPEN c_susa_exists(vc_acad_us_rec.stream_unit_set_cd,
                                   v_us_version_number,
                                                   p_person_id,
                                                   p_course_cd);
            FETCH c_susa_exists INTO vc_susa_upd_rec;

            v_confirmed_ind := NVL(p_confirmed_ind,'N');
            IF v_confirmed_ind = 'Y' THEN
              v_selection_dt := NVL(p_selection_dt,SYSDATE) ;
            ELSE
              v_selection_dt  := NULL;
            END IF;

            IF c_susa_exists%NOTFOUND THEN

              SELECT IGS_AS_SU_SETATMPT_SEQ_NUM_S.NEXTVAL INTO vl_sequence_val FROM dual;

        IF igs_en_gen_legacy.check_usa_overlap(
             p_person_id,
             p_course_cd,
             TRUNC(v_selection_dt),
             NULL,
             NULL,
             vl_sequence_val,
             vc_acad_us_rec.stream_unit_set_cd,
             v_us_version_number,
             p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
        END IF ;

              IGS_AS_SU_SETATMPT_PKG.INSERT_ROW (
                X_ROWID => vl_rowid,
                X_PERSON_ID  => p_person_id ,
                X_COURSE_CD  =>  p_course_cd ,
                X_UNIT_SET_CD  =>  vc_acad_us_rec.stream_unit_set_cd ,
                X_SEQUENCE_NUMBER =>  vl_sequence_val ,
                X_US_VERSION_NUMBER =>  v_us_version_number,
                X_SELECTION_DT => TRUNC(v_selection_dt)   ,
                X_STUDENT_CONFIRMED_IND =>  v_confirmed_ind ,
                X_END_DT =>  NULL ,
                X_PARENT_UNIT_SET_CD =>  NULL,
                X_PARENT_SEQUENCE_NUMBER => NULL ,
                X_PRIMARY_SET_IND =>  NULL ,
                X_VOLUNTARY_END_IND =>  NULL ,
                X_AUTHORISED_PERSON_ID =>   NULL ,
                X_AUTHORISED_ON =>  NULL ,
                X_OVERRIDE_TITLE =>   NULL ,
                X_RQRMNTS_COMPLETE_IND =>   NULL ,
                X_RQRMNTS_COMPLETE_DT =>   NULL,
                X_S_COMPLETED_SOURCE_TYPE =>   NULL,
                X_CATALOG_CAL_TYPE =>   NULL ,
                X_CATALOG_SEQ_NUM =>   NULL,
                X_ATTRIBUTE_CATEGORY  => NULL,
                X_ATTRIBUTE1  => NULL,
                X_ATTRIBUTE2  => NULL,
                X_ATTRIBUTE3  => NULL,
                X_ATTRIBUTE4  => NULL,
                X_ATTRIBUTE5  => NULL,
                X_ATTRIBUTE6  => NULL,
                X_ATTRIBUTE7  => NULL,
                X_ATTRIBUTE8  => NULL,
                X_ATTRIBUTE9  => NULL,
                X_ATTRIBUTE10  => NULL,
                X_ATTRIBUTE11  => NULL,
                X_ATTRIBUTE12  => NULL,
                X_ATTRIBUTE13  => NULL,
                X_ATTRIBUTE14  => NULL,
                X_ATTRIBUTE15  => NULL,
                X_ATTRIBUTE16  => NULL,
                X_ATTRIBUTE17  => NULL,
                X_ATTRIBUTE18  => NULL,
                X_ATTRIBUTE19  => NULL,
                X_ATTRIBUTE20  => NULL,
                X_MODE =>  'R'
              );
            ELSIF c_susa_exists%FOUND THEN

                  IF v_confirmed_ind = 'N' AND vc_susa_upd_rec.student_confirmed_ind = 'Y' THEN
                    v_confirmed_ind := vc_susa_upd_rec.student_confirmed_ind ;
                  END IF;

                  IF v_confirmed_ind = 'N' THEN
                    v_selection_dt :=  NULL;
                  ELSE
                    IF v_selection_dt IS NOT NULL AND vc_susa_upd_rec.selection_dt < v_selection_dt THEN
                      v_selection_dt := vc_susa_upd_rec.selection_dt;
                    END IF;
                    v_selection_dt := NVL(v_selection_dt,vc_susa_upd_rec.selection_dt);
                  END IF;

                  IF NVL(v_selection_dt,igs_ge_date.igsdate('1000/01/01 00:00:00') )
                      <> NVL(vc_susa_upd_rec.selection_dt,igs_ge_date.igsdate('1000/01/01 00:00:00'))
                    OR v_confirmed_ind <> vc_susa_upd_rec.student_confirmed_ind
                  THEN

        IF igs_en_gen_legacy.check_usa_overlap(
             vc_susa_upd_rec.person_id,
             vc_susa_upd_rec.course_cd,
             TRUNC(v_selection_dt),
             vc_susa_upd_rec.rqrmnts_complete_dt,
             vc_susa_upd_rec.end_dt,
             vc_susa_upd_rec.sequence_number,
             vc_susa_upd_rec.unit_set_cd,
             vc_susa_upd_rec.us_version_number,
             p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
              END IF ;

                    IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW (
                      X_ROWID => vc_susa_upd_rec.rowid,
                      X_PERSON_ID  => vc_susa_upd_rec.person_id ,
                      X_COURSE_CD  =>  vc_susa_upd_rec.course_cd ,
                      X_UNIT_SET_CD  =>  vc_susa_upd_rec.unit_set_cd ,
                      X_SEQUENCE_NUMBER =>  vc_susa_upd_rec.sequence_number ,
                      X_US_VERSION_NUMBER =>  vc_susa_upd_rec.us_version_number,
                      X_SELECTION_DT =>  TRUNC(v_selection_dt) ,
                      X_STUDENT_CONFIRMED_IND => v_confirmed_ind,
                      X_END_DT =>  vc_susa_upd_rec.end_dt ,
                      X_PARENT_UNIT_SET_CD =>  vc_susa_upd_rec.parent_unit_set_cd,
                      X_PARENT_SEQUENCE_NUMBER =>  vc_susa_upd_rec.parent_sequence_number ,
                      X_PRIMARY_SET_IND =>  vc_susa_upd_rec.primary_set_ind ,
                      X_VOLUNTARY_END_IND =>  vc_susa_upd_rec.voluntary_end_ind ,
                      X_AUTHORISED_PERSON_ID =>  vc_susa_upd_rec.authorised_person_id,
                      X_AUTHORISED_ON =>  vc_susa_upd_rec.authorised_on ,
                      X_OVERRIDE_TITLE =>  vc_susa_upd_rec.override_title ,
                      X_RQRMNTS_COMPLETE_IND =>  vc_susa_upd_rec.rqrmnts_complete_ind,
                      X_RQRMNTS_COMPLETE_DT =>  vc_susa_upd_rec.rqrmnts_complete_dt,
                      X_S_COMPLETED_SOURCE_TYPE =>  vc_susa_upd_rec.s_completed_source_type,
                      X_CATALOG_CAL_TYPE =>  vc_susa_upd_rec.catalog_cal_type ,
                      X_CATALOG_SEQ_NUM =>  vc_susa_upd_rec.catalog_seq_num,
                      X_ATTRIBUTE_CATEGORY  => vc_susa_upd_rec.attribute_category,
                      X_ATTRIBUTE1  => vc_susa_upd_rec.attribute1 ,
                      X_ATTRIBUTE2  => vc_susa_upd_rec.attribute2 ,
                      X_ATTRIBUTE3  => vc_susa_upd_rec.attribute3,
                      X_ATTRIBUTE4  => vc_susa_upd_rec.attribute4,
                      X_ATTRIBUTE5  => vc_susa_upd_rec.attribute5,
                      X_ATTRIBUTE6  => vc_susa_upd_rec.attribute6,
                      X_ATTRIBUTE7  => vc_susa_upd_rec.attribute7,
                      X_ATTRIBUTE8  => vc_susa_upd_rec.attribute8,
                      X_ATTRIBUTE9  => vc_susa_upd_rec.attribute9,
                      X_ATTRIBUTE10  => vc_susa_upd_rec.attribute10,
                      X_ATTRIBUTE11  => vc_susa_upd_rec.attribute11,
                      X_ATTRIBUTE12  => vc_susa_upd_rec.attribute12,
                      X_ATTRIBUTE13  => vc_susa_upd_rec.attribute13,
                      X_ATTRIBUTE14  => vc_susa_upd_rec.attribute14,
                      X_ATTRIBUTE15  => vc_susa_upd_rec.attribute15,
                      X_ATTRIBUTE16  => vc_susa_upd_rec.attribute16,
                      X_ATTRIBUTE17  => vc_susa_upd_rec.attribute17,
                      X_ATTRIBUTE18  => vc_susa_upd_rec.attribute18,
                      X_ATTRIBUTE19  => vc_susa_upd_rec.attribute19,
                      X_ATTRIBUTE20  => vc_susa_upd_rec.attribute20,
                      X_MODE =>  'R'
                    );
                  END IF;

            END IF;
            CLOSE c_susa_exists;

      END IF;
      CLOSE c_us_version_number;


    END LOOP;
    RETURN TRUE;


  END create_stream_unit_sets;


   FUNCTION create_unit_set(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_unit_set_cd IN VARCHAR2,
    p_us_version_number IN NUMBER,
    p_selection_dt IN DATE,
    p_confirmed_ind IN VARCHAR2,
    p_authorised_person_id IN NUMBER,
    p_authorised_on IN DATE,
    p_seqval OUT NOCOPY NUMBER,
    p_log_creation_dt IN DATE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

  ------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --bdeviset   29-JUL-2004    Added p_log_creation_dt as parameter.Before calling IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW/INSERT_ROW
  --            a check is made to see that their is no overlapping of selection,completion and
  --                          end dates for any two unit sets by calling check_usa_overlap.If it returns
  --                          false log entry is made and the insert or update is not carried out for bug 3149133.
   ------------------------------------------------------------------------------------------------

    p_warn_level varchar2(5);
    cst_pre_enrol   CONSTANT VARCHAR2(10) := 'PRE-ENROL';
    cst_error   CONSTANT VARCHAR2(5) := 'ERROR';
    l_rowid         VARCHAR2(25);
    l_seqval        IGS_AS_SU_SETATMPT.SEQUENCE_NUMBER%TYPE;
    v_selection_dt  IGS_AS_SU_SETATMPT.SELECTION_DT%TYPE;
    v_confirmed_ind IGS_AS_SU_SETATMPT.STUDENT_CONFIRMED_IND%TYPE;
      CURSOR c_next_susa_exists (cp_person_id IGS_AS_SU_SETATMPT.PERSON_ID%TYPE,
                                 cp_course_cd IGS_AS_SU_SETATMPT.COURSE_CD%TYPE,
                                 cp_unit_set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE,
                                 cp_us_version_number IGS_AS_SU_SETATMPT.US_VERSION_NUMBER%TYPE) IS
      SELECT  susa.*,susa.rowid
      FROM  IGS_AS_SU_SETATMPT susa
      WHERE susa.person_id = cp_person_id AND
        susa.course_cd    = cp_course_cd AND
        susa.unit_set_cd  = cp_unit_set_cd AND
        susa.us_version_number  = cp_us_version_number AND
        susa.end_dt IS NULL;
      v_susa_rec c_next_susa_exists%ROWTYPE;


  BEGIN

      p_seqval := NULL;

      OPEN c_next_susa_exists(p_person_id, p_course_cd,
                              p_unit_set_cd, p_us_version_number);
      FETCH c_next_susa_exists into v_susa_rec;
      IF c_next_susa_exists %FOUND THEN
        CLOSE c_next_susa_exists;

          p_seqval := v_susa_rec.sequence_number;
          v_confirmed_ind := NVL(p_confirmed_ind, v_susa_rec.student_confirmed_ind);
          IF NVL(p_confirmed_ind,'N') = 'N' AND v_susa_rec.student_confirmed_ind = 'Y' THEN
            v_confirmed_ind := 'Y';
          END IF;

          IF v_confirmed_ind = 'N' THEN
            v_Selection_Dt := null;
          ELSE
            IF p_selection_dt IS NOT NULL AND v_susa_rec.selection_dt < p_selection_dt THEN
              v_selection_dt := v_susa_rec.selection_dt;
            ELSE
              v_selection_Dt := p_selection_Dt;
            END IF;
            v_selection_dt := NVL(NVL(v_selection_dt,v_susa_rec.selection_dt),sysdate);
          END IF;

          IF NVL(v_selection_dt,igs_ge_date.igsdate('1000/01/01 00:00:00'))
              <> NVL(v_susa_rec.selection_dt,igs_ge_date.igsdate('1000/01/01 00:00:00'))
          OR v_confirmed_ind <> v_susa_rec.student_confirmed_ind
          THEN
      IF igs_en_gen_legacy.check_usa_overlap(
           v_susa_rec.person_id,
           v_susa_rec.course_cd,
           TRUNC(v_selection_dt),
           v_susa_rec.rqrmnts_complete_dt,
           v_susa_rec.end_dt,
           v_susa_rec.sequence_number,
           v_susa_rec.unit_set_cd ,
           v_susa_rec.us_version_number,
           p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
      END IF ;

            IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW (
              X_ROWID => v_susa_rec.rowid,
              X_PERSON_ID  => v_susa_rec.person_id ,
              X_COURSE_CD  =>  v_susa_rec.course_cd ,
              X_UNIT_SET_CD  =>  v_susa_rec.unit_set_cd ,
              X_SEQUENCE_NUMBER =>  v_susa_rec.sequence_number ,
              X_US_VERSION_NUMBER =>  v_susa_rec.us_version_number,
              X_SELECTION_DT =>  TRUNC(v_selection_dt),
              X_STUDENT_CONFIRMED_IND =>  v_confirmed_ind,
              X_END_DT =>  v_susa_rec.end_dt ,
              X_PARENT_UNIT_SET_CD =>  v_susa_rec.parent_unit_set_cd,
              X_PARENT_SEQUENCE_NUMBER =>  v_susa_rec.parent_sequence_number ,
              X_PRIMARY_SET_IND =>  v_susa_rec.primary_set_ind ,
              X_VOLUNTARY_END_IND =>  v_susa_rec.voluntary_end_ind ,
              X_AUTHORISED_PERSON_ID =>  NVL(p_authorised_person_id,v_susa_rec.authorised_person_id),
              X_AUTHORISED_ON =>  NVL(p_authorised_on,v_susa_rec.authorised_on),
              X_OVERRIDE_TITLE =>  v_susa_rec.override_title ,
              X_RQRMNTS_COMPLETE_IND =>  v_susa_rec.rqrmnts_complete_ind,
              X_RQRMNTS_COMPLETE_DT =>  v_susa_rec.rqrmnts_complete_dt,
              X_S_COMPLETED_SOURCE_TYPE =>  v_susa_rec.s_completed_source_type,
              X_CATALOG_CAL_TYPE =>  v_susa_rec.catalog_cal_type ,
              X_CATALOG_SEQ_NUM =>  v_susa_rec.catalog_seq_num,
              X_ATTRIBUTE_CATEGORY  => v_susa_rec.attribute_category,
              X_ATTRIBUTE1  => v_susa_rec.attribute1 ,
              X_ATTRIBUTE2  => v_susa_rec.attribute2 ,
              X_ATTRIBUTE3  => v_susa_rec.attribute3,
              X_ATTRIBUTE4  => v_susa_rec.attribute4,
              X_ATTRIBUTE5  => v_susa_rec.attribute5,
              X_ATTRIBUTE6  => v_susa_rec.attribute6,
              X_ATTRIBUTE7  => v_susa_rec.attribute7,
              X_ATTRIBUTE8  => v_susa_rec.attribute8,
              X_ATTRIBUTE9  => v_susa_rec.attribute9,
              X_ATTRIBUTE10  => v_susa_rec.attribute10,
              X_ATTRIBUTE11  => v_susa_rec.attribute11,
              X_ATTRIBUTE12  => v_susa_rec.attribute12,
              X_ATTRIBUTE13  => v_susa_rec.attribute13,
              X_ATTRIBUTE14  => v_susa_rec.attribute14,
              X_ATTRIBUTE15  => v_susa_rec.attribute15,
              X_ATTRIBUTE16  => v_susa_rec.attribute16,
              X_ATTRIBUTE17  => v_susa_rec.attribute17,
              X_ATTRIBUTE18  => v_susa_rec.attribute18,
              X_ATTRIBUTE19  => v_susa_rec.attribute19,
              X_ATTRIBUTE20  => v_susa_rec.attribute20,
              X_MODE =>  'R'
            );
          END IF;
      ELSE
        CLOSE c_next_susa_exists;
        SELECT IGS_AS_SU_SETATMPT_SEQ_NUM_S.NEXTVAL
        INTO l_seqval
        FROM dual;

        p_seqval := l_seqval;
        v_confirmed_ind := NVL(p_confirmed_ind,'N') ;
        IF v_confirmed_ind = 'Y' THEN
          v_selection_dt := NVL(p_selection_dt,sysdate);
        ELSE
          v_selection_dt :=  NULL;
        END IF;

  IF igs_en_gen_legacy.check_usa_overlap(
       p_person_id,
       p_course_cd,
       TRUNC(v_selection_dt),
       NULL,
       NULL,
       l_seqval,
       p_unit_set_cd,
       p_us_version_number,
       p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
  END IF ;


        IGS_AS_SU_SETATMPT_PKG.INSERT_ROW (
          x_rowid => l_rowid,
          x_person_id => p_person_id,
          x_course_cd => p_course_cd,
          x_unit_set_cd => p_unit_set_cd,
          x_sequence_number => l_seqval,
          x_us_version_number => p_us_version_number,
          x_selection_dt => TRUNC(v_selection_dt ),
          x_student_confirmed_ind =>v_confirmed_ind,
          x_end_dt => NULL,
          x_PARENT_UNIT_SET_CD => NULL,
          X_PARENT_SEQUENCE_NUMBER => NULL,
          X_PRIMARY_SET_IND => NULL,
          X_VOLUNTARY_END_IND => NULL,
          x_authorised_person_id => p_authorised_person_id,
          x_authorised_on => p_authorised_on,
          X_OVERRIDE_TITLE => NULL,
          X_RQRMNTS_COMPLETE_IND => NULL,
          X_RQRMNTS_COMPLETE_DT => NULL,
          X_S_COMPLETED_SOURCE_TYPE => NULL,
          X_CATALOG_CAL_TYPE  => NULL,
          X_CATALOG_SEQ_NUM  => NULL,
          X_ATTRIBUTE_CATEGORY  => NULL,
          X_ATTRIBUTE1  => NULL,
          X_ATTRIBUTE2  => NULL,
          X_ATTRIBUTE3  => NULL,
          X_ATTRIBUTE4  => NULL,
          X_ATTRIBUTE5  => NULL,
          X_ATTRIBUTE6  => NULL,
          X_ATTRIBUTE7  => NULL,
          X_ATTRIBUTE8  => NULL,
          X_ATTRIBUTE9  => NULL,
          X_ATTRIBUTE10  => NULL,
          X_ATTRIBUTE11  => NULL,
          X_ATTRIBUTE12  => NULL,
          X_ATTRIBUTE13  => NULL,
          X_ATTRIBUTE14  => NULL,
          X_ATTRIBUTE15  => NULL,
          X_ATTRIBUTE16  => NULL,
          X_ATTRIBUTE17  => NULL,
          X_ATTRIBUTE18  => NULL,
          X_ATTRIBUTE19  => NULL,
          X_ATTRIBUTE20  => NULL,
          x_mode => 'R');
     END IF;
     RETURN TRUE;
  END create_unit_set;



  FUNCTION update_stream_unit_sets(
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2,
    p_old_admin_unit_set IN VARCHAR2,
    p_rqrmnts_complete_ind IN VARCHAR2,
    p_rqrmnts_complete_dt IN DATE,
    p_selection_dt IN DATE,
    p_confirmed_ind IN VARCHAR2,
    p_log_creation_dt IN DATE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

  ------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --bdeviset   29-JUL-2004    Added p_log_creation_dt as parameter.Before calling IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW/INSERT_ROW
  --            a check is made to see that their is no overlapping of selection,completion and
  --                          end dates for any two unit sets by calling check_usa_overlap.If it returns
  --                          false log entry is made and the insert or update is not carried out for bug 3149133.
   ------------------------------------------------------------------------------------------------

    CURSOR c_acad_us (cp_old_admin_unit_Set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE) IS
      SELECT usm.stream_unit_set_Cd
      FROM   igs_en_unit_set_map usm,
             igs_ps_us_prenr_cfg upc
      WHERE  upc.unit_set_cd = cp_old_admin_unit_set_cd
      AND    usm.mapping_set_cd = upc.mapping_set_cd
      AND    usm.sequence_no = upc.sequence_no;

    CURSOR c_susa_upd (cp_stream_unit_Set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE,
                      cp_person_id IGS_AS_SU_SETATMPT.PERSON_ID%TYPE,
                      cp_course_cd IGS_AS_SU_SETATMPT.COURSE_CD%TYPE) IS
      SELECT susa.rowid, susa.*
      FROM   igs_as_su_setatmpt susa
      WHERE  susa.unit_set_cd = cp_stream_unit_set_cd
      AND    susa.person_id = cp_person_id
      AND    susa.course_cd  = cp_course_cd
      AND    susa.end_dt IS NULL
      order by selection_dt desc;

    vc_susa_upd_rec c_susa_upd%ROWTYPE;
    v_selection_dt  igs_as_su_setatmpt.selection_dt%TYPE;
    v_confirmed_ind igs_as_su_setatmpt.student_confirmed_ind%TYPE;
    v_rqrmnts_complete_ind igs_as_su_setatmpt.rqrmnts_complete_ind%TYPE;
    v_rqrmnts_complete_dt  igs_as_su_setatmpt.rqrmnts_complete_dt%TYPE;
    p_warn_level varchar2(5);
    cst_pre_enrol   CONSTANT VARCHAR2(10) := 'PRE-ENROL';
    cst_error   CONSTANT VARCHAR2(5) := 'ERROR';

  BEGIN

    FOR vc_acad_us_rec in c_acad_us(p_old_admin_unit_set) LOOP

      OPEN c_susa_upd ( vc_acad_us_rec.stream_unit_set_cd, p_person_id, p_course_cd);
      FETCH c_susa_upd INTO vc_susa_upd_rec;
      IF c_susa_upd%FOUND THEN
         v_confirmed_ind := NVL(p_confirmed_ind, vc_susa_upd_rec.student_confirmed_ind);
         IF NVL(p_confirmed_ind,'N') = 'N' AND vc_susa_upd_rec.student_confirmed_ind = 'Y' THEN
           v_confirmed_ind := 'Y';
         END IF;

         IF v_confirmed_ind = 'N' THEN
           v_Selection_Dt := null;
         ELSE
           IF p_selection_dt IS NOT NULL AND vc_susa_upd_rec.selection_dt < p_selection_dt THEN
             v_selection_dt := vc_susa_upd_rec.selection_dt;
           ELSE
             v_selection_Dt := p_selection_Dt;
           END IF;
           v_selection_dt := NVL(NVL(v_selection_dt,vc_susa_upd_rec.selection_dt),sysdate);
         END IF;


         IF NVL(p_rqrmnts_complete_ind,'N') = 'N' AND vc_susa_upd_rec.rqrmnts_complete_ind = 'Y' THEN
           v_rqrmnts_complete_ind := vc_susa_upd_rec.rqrmnts_complete_ind;
         END IF;
         v_rqrmnts_complete_ind := NVL(p_rqrmnts_complete_ind,vc_susa_upd_rec.rqrmnts_complete_ind );

         IF v_rqrmnts_complete_ind  = 'Y' THEN
           v_rqrmnts_complete_dt := NVL(NVL(p_rqrmnts_complete_dt,vc_susa_upd_rec.rqrmnts_complete_dt),sysdate-1);
         ELSE
           v_rqrmnts_complete_dt := NULL;
         END IF; -- end of IF v_rqrmnts_complete_ind  = 'Y' THEN


         IF  v_rqrmnts_complete_ind <> vc_susa_upd_rec.rqrmnts_complete_ind
          OR NVL(v_rqrmnts_complete_dt,igs_ge_date.igsdate('1000/01/01 00:00:00'))
              <> NVL(vc_susa_upd_rec.rqrmnts_complete_dt,igs_ge_date.igsdate('1000/01/01 00:00:00'))
          OR NVL(v_selection_dt,igs_ge_date.igsdate('1000/01/01 00:00:00'))
              <> NVL(vc_susa_upd_rec.selection_dt,igs_ge_date.igsdate('1000/01/01 00:00:00'))
          OR v_confirmed_ind <> vc_susa_upd_rec.student_confirmed_ind
         THEN

    IF igs_en_gen_legacy.check_usa_overlap(
          vc_susa_upd_rec.person_id,
          vc_susa_upd_rec.course_cd,
          TRUNC(v_selection_dt),
          v_rqrmnts_complete_dt,
          vc_susa_upd_rec.end_dt,
          vc_susa_upd_rec.sequence_number,
          vc_susa_upd_rec.unit_set_cd,
          vc_susa_upd_rec.us_version_number,
          p_message_name) = FALSE THEN

        p_warn_level := cst_error;
        IF p_log_creation_dt IS NOT NULL THEN
               IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
            cst_pre_enrol,
            p_log_creation_dt,
            cst_error || ',' ||
            TO_CHAR(p_person_id) || ',' ||
            p_course_cd,
            p_message_name,
            NULL);
        END IF;
        RETURN FALSE;
      END IF ;


          IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW (
            X_ROWID => vc_susa_upd_rec.rowid,
            X_PERSON_ID  => vc_susa_upd_rec.person_id ,
            X_COURSE_CD  =>  vc_susa_upd_rec.course_cd ,
            X_UNIT_SET_CD  =>  vc_susa_upd_rec.unit_set_cd ,
            X_SEQUENCE_NUMBER =>  vc_susa_upd_rec.sequence_number ,
            X_US_VERSION_NUMBER =>  vc_susa_upd_rec.us_version_number,
            X_SELECTION_DT =>  TRUNC(v_selection_dt),
            X_STUDENT_CONFIRMED_IND =>  v_confirmed_ind,
            X_END_DT =>  vc_susa_upd_rec.end_dt ,
            X_PARENT_UNIT_SET_CD =>  vc_susa_upd_rec.parent_unit_set_cd,
            X_PARENT_SEQUENCE_NUMBER =>  vc_susa_upd_rec.parent_sequence_number ,
            X_PRIMARY_SET_IND =>  vc_susa_upd_rec.primary_set_ind ,
            X_VOLUNTARY_END_IND =>  vc_susa_upd_rec.voluntary_end_ind ,
            X_AUTHORISED_PERSON_ID =>  vc_susa_upd_rec.authorised_person_id,
            X_AUTHORISED_ON =>  vc_susa_upd_rec.authorised_on ,
            X_OVERRIDE_TITLE =>  vc_susa_upd_rec.override_title ,
            X_RQRMNTS_COMPLETE_IND =>  v_rqrmnts_complete_ind,
            X_RQRMNTS_COMPLETE_DT =>  v_rqrmnts_complete_dt,
            X_S_COMPLETED_SOURCE_TYPE =>  vc_susa_upd_rec.s_completed_source_type,
            X_CATALOG_CAL_TYPE =>  vc_susa_upd_rec.catalog_cal_type ,
            X_CATALOG_SEQ_NUM =>  vc_susa_upd_rec.catalog_seq_num,
            X_ATTRIBUTE_CATEGORY  => vc_susa_upd_rec.attribute_category,
            X_ATTRIBUTE1  => vc_susa_upd_rec.attribute1 ,
            X_ATTRIBUTE2  => vc_susa_upd_rec.attribute2 ,
            X_ATTRIBUTE3  => vc_susa_upd_rec.attribute3,
            X_ATTRIBUTE4  => vc_susa_upd_rec.attribute4,
            X_ATTRIBUTE5  => vc_susa_upd_rec.attribute5,
            X_ATTRIBUTE6  => vc_susa_upd_rec.attribute6,
            X_ATTRIBUTE7  => vc_susa_upd_rec.attribute7,
            X_ATTRIBUTE8  => vc_susa_upd_rec.attribute8,
            X_ATTRIBUTE9  => vc_susa_upd_rec.attribute9,
            X_ATTRIBUTE10  => vc_susa_upd_rec.attribute10,
            X_ATTRIBUTE11  => vc_susa_upd_rec.attribute11,
            X_ATTRIBUTE12  => vc_susa_upd_rec.attribute12,
            X_ATTRIBUTE13  => vc_susa_upd_rec.attribute13,
            X_ATTRIBUTE14  => vc_susa_upd_rec.attribute14,
            X_ATTRIBUTE15  => vc_susa_upd_rec.attribute15,
            X_ATTRIBUTE16  => vc_susa_upd_rec.attribute16,
            X_ATTRIBUTE17  => vc_susa_upd_rec.attribute17,
            X_ATTRIBUTE18  => vc_susa_upd_rec.attribute18,
            X_ATTRIBUTE19  => vc_susa_upd_rec.attribute19,
            X_ATTRIBUTE20  => vc_susa_upd_rec.attribute20,
            X_MODE =>  'R'
          );
        END IF;
      END IF;

      CLOSE c_susa_upd;

    END LOOP;
    RETURN TRUE;

  END update_stream_unit_sets;

FUNCTION enrp_vald_inst_sua(
p_person_id             IN  igs_en_su_attempt.person_id%TYPE,
p_course_cd             IN  igs_en_su_attempt.course_cd%TYPE,
p_unit_cd               IN  igs_en_su_attempt.unit_cd%TYPE,
p_version_number        IN  igs_en_su_attempt.version_number%TYPE,
p_teach_cal_type        IN  igs_en_su_attempt.cal_type%TYPE,
p_teach_seq_num         IN  igs_en_su_attempt.ci_sequence_number%TYPE,
p_load_cal_type         IN  igs_en_su_attempt.cal_type%TYPE,
p_load_seq_num          IN  igs_en_su_attempt.ci_sequence_number%TYPE,
p_location_cd           IN  igs_en_su_attempt.location_cd%TYPE,
p_unit_class            IN  igs_en_su_attempt.unit_class%TYPE,
p_uoo_id                IN  igs_en_su_attempt.uoo_id%TYPE,
p_enr_method            IN  igs_en_method_type.enr_method_type%TYPE,
p_core_indicator_code   IN  igs_en_su_attempt.core_indicator_code%TYPE, -- ptandon, Prevent Dropping Core Units build
p_message               OUT NOCOPY VARCHAR2) RETURN BOOLEAN AS
------------------------------------------------------------------------------------------------
--Created by  :
--Date created:
--
--Purpose:
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--kkillams    11-Jul-2003     Added rollback statement in the function if deny message is returned
--                            from igs_ss_en_wrappers.insert_into_enr_worksheet function, to
--                            rollback the changes have done by the function. Bug no: 3036949
--ptandon     06-Oct-2003     Added a new parameter p_core_indicator_code as part of Prevent Dropping Core Units.
--                            Enh Bug# 3052432.
--rvangala    04-Dec-2003     Added call to igs_ss_enr_details.enrp_get_prgm_for_career to check for
--                            primary program
--rvivekan    07-dec-2003     Placements build. Added exception handling block for insert_into_enr_worksheet
------------------------------------------------------------------------------------------------
CURSOR cur_uoo_id IS
                  SELECT uoo_id FROM IGS_PS_UNIT_OFR_OPT
                                WHERE unit_cd             = p_unit_cd
                                AND   version_number      = p_version_number
                                AND   cal_type            = p_teach_cal_type
                                AND   ci_sequence_number  = p_teach_seq_num
                                AND   location_cd         = p_location_cd
                                AND   unit_class          = p_unit_class;
CURSOR c_per_num
       IS SELECT party_number  FROM      hz_parties
          WHERE     party_id  = p_person_id;

CURSOR cur_course_type (cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                        cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
         SELECT course_type
         FROM IGS_PS_VER pv,
              IGS_EN_STDNT_PS_ATT sca
         WHERE sca.person_id = cp_person_id
         AND   sca.course_cd = cp_course_cd
         AND   pv.course_cd  = sca.course_cd
         AND   pv.version_number = sca.version_number;

l_waitlist_ind           VARCHAR2(2);
l_unit_section_status    igs_en_su_attempt.unit_attempt_status%TYPE;
l_uoo_id                 igs_en_su_attempt.uoo_id%TYPE;
l_person_number          igs_pe_person.person_number%TYPE;
l_ret_stat               VARCHAR2(1);
l_unit_attempt_status   igs_en_su_attempt.unit_attempt_status%TYPE;
l_sub_sup_status        igs_en_su_attempt.unit_attempt_status%TYPE;
l_primary_program_cd    IGS_PS_VER_ALL.COURSE_CD%TYPE;
l_primary_program_vers  IGS_PS_VER_ALL.VERSION_NUMBER%TYPE;
l_all_program_title     VARCHAR2(2000);
l_profile               VARCHAR2(1);
l_career                IGS_EN_SCA_V.course_type%TYPE;

BEGIN ---Enrp_Vald_Inst_Sua

    l_primary_program_cd := NULL;

    --check whether system is in Career mode
    l_profile :=NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N');

    -- if system is in career mode
    IF (l_profile='Y') THEN
       OPEN cur_course_type(p_person_id, p_course_cd);
       FETCH cur_course_type INTO l_career;
       CLOSE cur_course_type;

       -- check whether there is a primary program for the passed
       -- in term calendar and career
       IGS_SS_ENR_DETAILS.enrp_get_prgm_for_career(
                           p_primary_program         => l_primary_program_cd,
                           p_primary_program_version => l_primary_program_vers,
                           p_programlist             => l_all_program_title,
                           p_person_id               => p_person_id,
                           p_carrer                  => l_career,
                           p_term_cal_type         => p_load_cal_type,
                           p_term_sequence_number  => p_load_seq_num);

    END IF;

    -- The primary program will be null if the career mode is not enabled or
    -- the system is in career mode but there is no primary program.
    IF l_primary_program_cd IS NULL THEN
      l_primary_program_cd := p_course_cd;
    END IF;

     SAVEPOINT enrp_vald_inst_sua;
     IF p_uoo_id IS NULL THEN
             OPEN  cur_uoo_id;
             FETCH cur_uoo_id INTO l_uoo_id;
             CLOSE cur_uoo_id;
     ELSE
         l_uoo_id :=p_uoo_id;
     END IF;
     OPEN c_per_num;
     FETCH c_per_num INTO l_person_number;
     CLOSE c_per_num;
     l_waitlist_ind := NULL;
     l_unit_section_status := NULL;


     --Following api checks the availbility of the seats for the given unit section.
     igs_en_gen_015.get_usec_status(p_uoo_id                  =>l_uoo_id,
                                    p_person_id               =>p_person_id,
                                    p_unit_section_status     =>l_unit_section_status,
                                    p_waitlist_ind            =>l_waitlist_ind,
                                    p_load_cal_type           =>p_load_cal_type,
                                    p_load_ci_sequence_number =>p_load_seq_num,
                                    p_course_cd               =>l_primary_program_cd );

     IF l_waitlist_ind IS NULL THEN
        --There is no seates are available for this unit section.
         p_message := 'IGS_EN_SS_CANNOT_WAITLIST';
         RETURN FALSE;
     ELSE
        --validate context student unit attempt against superior unit section attempt
      IF l_waitlist_ind = 'Y' THEN
         l_unit_attempt_status := 'WAITLISTED';
      ELSIF l_waitlist_ind = 'N' THEN
          l_unit_attempt_status := 'UNCONFIRM';
      END IF;

     IF NOT igs_en_sua_api.enr_sua_sup_sub_val(
        p_person_id => p_person_id,
        p_course_cd => l_primary_program_cd ,
        p_uoo_id    => l_uoo_id,
        p_unit_attempt_status => l_unit_attempt_status,
        p_sup_sub_status => l_sub_sup_status)  THEN

        p_message := 'IGS_EN_INVALID_SUP';
         RETURN FALSE;
      END IF;
         l_ret_stat:= NULL;
         --Following api will creates an unit attempt in unconfirm/waitlist status.

         BEGIN
           igs_ss_en_wrappers.insert_into_enr_worksheet(p_person_number       =>l_person_number,
                                                      p_course_cd             =>l_primary_program_cd ,
                                                      p_uoo_id                =>l_uoo_id,
                                                      p_waitlist_ind          =>l_waitlist_ind,
                                                      p_session_id            =>NULL,
                                                      p_return_status         =>l_ret_stat,
                                                      p_message               =>p_message,
                                                      p_cal_type              =>p_load_cal_type,
                                                      p_ci_sequence_number    =>p_load_seq_num,
                                                      p_audit_requested       =>'N',
                                                      p_enr_method            =>p_enr_method,
                                                      p_override_cp           =>null,
                                                      p_subtitle              =>null,
                                                      p_gradsch_cd            =>null,
                                                      p_gs_version_num        =>null,
                                                      p_core_indicator_code   =>p_core_indicator_code, -- ptandon, Prevent Dropping Core Units build
                                                      p_calling_obj           =>'JOB'
                                                      );
         EXCEPTION WHEN OTHERS THEN
           l_ret_stat := 'D';
         END;

         IF l_ret_stat = 'D' THEN
            ROLLBACK TO enrp_vald_inst_sua;
            RETURN FALSE;
         END IF;
     END IF;
     RETURN TRUE;
END enrp_vald_inst_sua;



PROCEDURE log_error_message(p_s_log_type          VARCHAR2,
                            p_creation_dt         DATE,
                            p_sle_key             VARCHAR2,
                            p_sle_message_name    VARCHAR2,
                            p_del                 VARCHAR2) AS
/*------------------------------------------------------
  --Created by  : KKILLAMS, Oracle IDC
  --Date created:
  --
  --Purpose:This procedure will logs the error/warn messages
  --Procedure logs the all error/warn messages.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  -- WHO               WHEN                 WHAT
---------------------------------------------------------*/
l_messages      VARCHAR2(2000) ;
l_mesg_name     VARCHAR2(100);
l_mesg_txt      VARCHAR2(2000);
l_msg_len       NUMBER ;
l_msg_token     VARCHAR2(100);
l_str_place     NUMBER(3);
BEGIN --log_error_message
l_messages := p_sle_message_name;
     IF SUBSTR(l_messages,1,1) = p_del THEN
        l_messages := SUBSTR(l_messages,2);
     END IF;
     IF SUBSTR(l_messages,-1,1) <> p_del THEN
        l_messages := l_messages||p_del;
     END IF;
     l_mesg_name := NULL;
     l_msg_len:= LENGTH(l_messages);
     FOR i IN 1 .. l_msg_len
     LOOP
         IF SUBSTR(l_messages,i,1) = p_del THEN
             --Following codes checks whether message token is exists or not.
             l_str_place :=INSTR(l_mesg_name,'*');
             IF l_str_place <> 0 THEN
                l_msg_token:= SUBSTR(l_mesg_name,l_str_place+1);
                l_mesg_name:= SUBSTR(l_mesg_name,1,l_str_place-1);
                fnd_message.set_name('IGS',l_mesg_name);
                fnd_message.set_token('UNIT_CD',l_msg_token);
             ELSE
                fnd_message.set_name('IGS',l_mesg_name);
             END IF;
             l_mesg_txt := fnd_message.get;
             igs_ge_gen_003.genp_ins_log_entry(p_s_log_type       => p_s_log_type,
                                               p_creation_dt      => p_creation_dt,
                                               p_key              => p_sle_key,
                                               p_s_message_name   => l_mesg_name,
                                               p_text             => l_mesg_txt);
             l_mesg_name := NULL;
         ELSE
            l_mesg_name := l_mesg_name||SUBSTR(l_messages,i,1);
         END IF;
     END LOOP;
END log_error_message;

FUNCTION enrf_unit_from_past(
  p_person_id IN NUMBER,
  p_source_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_unit_attempt_status IN VARCHAR2,
  p_discontinued_dt IN DATE,
  p_term_cal_type IN VARCHAR2,
  p_term_seq_num IN NUMBER) RETURN BOOLEAN AS
  /*------------------------------------------------------
  --Created by  : AMUTHU, Oracle IDC
  --Date created:
  --
  --Purpose:This procedure will logs the error/warn messages
  --Procedure logs the all error/warn messages.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  -- WHO               WHEN                 WHAT
  -- ckasu           08-DEC-2004      modfied as a part  of bug#4048203 inorder to move the status of
  --                                 dicontinue,completed unit attempts as same only when load calendar
  --                                 into which units enrolled equals the effective term calendar for
  --                                 Transfer.
---------------------------------------------------------*/

  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';

  CURSOR c_teach_to_load(cp_person_id IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE,
                         cp_source_course_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
             cp_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
    SELECT load_cal_type, load_ci_sequence_number, load_start_dt, teach_cal_type, teach_ci_sequence_number
  FROM IGS_EN_SU_ATTEMPT sua,
       IGS_CA_TEACH_TO_LOAD_V tl
  WHERE sua.person_id = cp_person_id
  AND sua.course_cd = cp_source_course_cd
  AND sua.uoo_id = cp_uoo_id
  AND sua.cal_type = tl.teach_cal_type
  AND sua.ci_sequence_number = tl.teach_ci_sequence_number
  order by tl.load_start_dt asc;

  v_teach_to_load_rec c_teach_to_load%ROWTYPE;

  CURSOR c_suao (cp_person_id IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE,
                 cp_source_course_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
         cp_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE,
                 cp_finalised_outcome_ind IGS_AS_SU_STMPTOUT.FINALISED_OUTCOME_IND%TYPE ) IS
  SELECT outcome_dt
      FROM   igs_as_su_stmptout source_suao
      WHERE  person_id = cp_person_id
      AND    course_cd = cp_source_course_cd
      AND    uoo_id = cp_uoo_id
      AND    finalised_outcome_ind = cp_finalised_outcome_ind
      ORDER BY outcome_dt desc;

  v_outcome_dt igs_as_su_stmptout.outcome_dt%TYPE;

  CURSOR c_load(cp_date IGS_EN_SU_ATTEMPT.DISCONTINUED_DT%TYPE,
                cp_load_start_dt IGS_CA_INST.START_DT%TYPE,
                cp_teach_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                cp_teach_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
  SELECT load_cal_type, load_ci_sequence_number, load_start_dt
  FROM IGS_CA_TEACH_TO_LOAD_V
  WHERE cp_date between load_start_dt and load_end_dt
  AND load_start_dt >= cp_load_start_dt
  AND teach_cal_type = cp_teach_Cal_type
  AND teach_ci_sequence_number = cp_teach_sequence_number
  ORDER BY load_start_dt asc;

  v_load_rec c_load%ROWTYPE;
  v_load_found BOOLEAN;

  CURSOR c_eff_term_start_dt (cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                              cp_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
  SELECT start_dt
  FROM IGS_CA_INST
  WHERE cal_type = cp_cal_type
  AND sequence_number = cp_sequence_number;

  v_eff_term_start_dt IGS_CA_INST.START_DT%TYPE;

BEGIN

  OPEN c_teach_to_load(p_person_id, p_source_course_cd, p_uoo_id);
  FETCH c_teach_to_load INTO v_teach_to_load_rec;
  CLOSE c_teach_to_load;

  v_load_found := FALSE;

  IF p_unit_attempt_status = cst_discontin THEN

    OPEN c_load(p_discontinued_dt,
                v_teach_to_load_rec.load_start_dt,
                v_teach_to_load_rec.teach_cal_type,
                v_teach_to_load_rec.teach_ci_sequence_number);
  FETCH c_load INTO v_load_rec;
  IF c_load%FOUND THEN
    v_load_found := TRUE;
  END IF;
  CLOSE c_load;

  ELSIF p_unit_attempt_status = cst_completed THEN

    OPEN c_suao(p_person_id, p_source_course_cd, p_uoo_id,'Y');
  FETCH c_suao INTO v_outcome_dt;
  CLOSE c_suao;

    OPEN c_load(v_outcome_dt,
                v_teach_to_load_rec.load_start_dt,
                v_teach_to_load_rec.teach_cal_type,
                v_teach_to_load_rec.teach_ci_sequence_number);
  FETCH c_load INTO v_load_rec;
  IF c_load%FOUND THEN
    v_load_found := TRUE;
  END IF;
  CLOSE c_load;
  ELSE
    RETURN FALSE;
  END IF;

  OPEN c_eff_term_start_dt(p_term_Cal_type,p_term_seq_num);
  FETCH c_eff_term_start_dt INTO v_eff_term_start_dt;
  CLOSE c_eff_term_start_dt;

  IF v_load_found THEN
    IF v_load_rec.load_start_dt < v_eff_term_start_dt  THEN
    RETURN TRUE;
  ELSE
      RETURN FALSE;
  END IF;
  ELSE
    IF v_teach_to_load_rec.load_start_dt  < v_eff_term_start_dt THEN
    RETURN TRUE;
  ELSE
      RETURN FALSE;
  END IF;
  END IF;

END enrf_unit_from_past;

PROCEDURE Enrp_Ins_Suao_Trnsfr (
  p_person_id IN NUMBER,
  p_source_course_cd IN VARCHAR2,
  p_dest_course_cd IN VARCHAR2,
  p_source_uoo_id IN NUMBER,
  p_dest_uoo_id IN NUMBER,
  p_delete_source IN BOOLEAN) AS

  CURSOR c_suao (cp_person_id IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE,
                 cp_source_course_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
                 cp_dest_course_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
                 cp_source_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE,
                 cp_dest_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
      SELECT source_suao.rowid,source_suao.*
      FROM   igs_as_su_stmptout source_suao
      WHERE  person_id = cp_person_id
      AND    course_cd = cp_source_course_cd
      AND    uoo_id = cp_source_uoo_id
      AND NOT EXISTS (SELECT 'x'
                      FROM igs_as_su_stmptout dest_suao
            WHERE dest_suao.person_id = source_suao.person_id
            AND dest_suao.course_cd = cp_dest_course_cd
            AND dest_suao.outcome_dt = source_suao.outcome_dt
            AND dest_suao.grading_period_cd = source_suao.grading_period_cd
            AND dest_suao.uoo_id = cp_dest_uoo_id)
      order by outcome_dt asc;

  CURSOR c_usec (cp_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
   SELECT usec.UNIT_CD,
          usec.CAL_TYPE,
          usec.CI_SEQUENCE_NUMBER,
          CI.START_DT,
          CI.END_DT
   FROM IGS_PS_UNIT_OFR_OPT usec,
        IGS_CA_INST ci
   WHERE usec.UOO_ID = cp_uoo_id
   and ci.cal_type = usec.cal_type
   and ci.sequence_number = usec.ci_sequence_number;

   v_dest_usec_rec c_usec%ROWTYPE;

  l_rowid VARCHAR2(25);
BEGIN

  FOR v_suao_rec in c_suao(p_person_id, p_source_course_cd, p_Dest_course_cd,
                   p_source_uoo_id, p_dest_uoo_id) LOOP

      IF p_delete_source THEN
         igs_as_su_stmptout_pkg.DELETE_ROW(v_suao_rec.rowid);
      END IF;

     OPEN c_usec (p_dest_uoo_id);
     FETCH c_usec INTO v_dest_usec_rec;
     CLOSE c_usec;

    igs_as_su_stmptout_pkg.insert_row(
      X_ROWID                         => l_ROWID                          ,
    X_ORG_ID                        => v_suao_rec.ORG_ID                         ,
    X_PERSON_ID                     => v_suao_rec.PERSON_ID                      ,
    X_COURSE_CD                     => P_DEST_COURSE_CD                      ,
    X_UNIT_CD                       => v_dest_usec_rec.UNIT_CD                        ,
    X_CAL_TYPE                      => v_dest_usec_rec.CAL_TYPE                       ,
    X_CI_SEQUENCE_NUMBER            => v_dest_usec_rec.CI_SEQUENCE_NUMBER             ,
    X_OUTCOME_DT                    => v_suao_rec.OUTCOME_DT                     ,
    X_CI_START_DT                   => v_dest_usec_rec.START_DT                    ,
    X_CI_END_DT                     => v_dest_usec_rec.END_DT                      ,
    X_GRADING_SCHEMA_CD             => v_suao_rec.GRADING_SCHEMA_CD              ,
    X_VERSION_NUMBER                => v_suao_rec.VERSION_NUMBER                 ,
    X_GRADE                         => v_suao_rec.GRADE                          ,
    X_S_GRADE_CREATION_METHOD_TYPE => v_suao_rec.S_GRADE_CREATION_METHOD_TYPE   ,
    X_FINALISED_OUTCOME_IND         => v_suao_rec.FINALISED_OUTCOME_IND          ,
    X_MARK                          => v_suao_rec.MARK                           ,
    X_NUMBER_TIMES_KEYED            => v_suao_rec.NUMBER_TIMES_KEYED             ,
    X_TRANSLATED_GRADING_SCHEMA_CD => v_suao_rec. TRANSLATED_GRADING_SCHEMA_CD   ,
    X_TRANSLATED_VERSION_NUMBER     => v_suao_rec.TRANSLATED_VERSION_NUMBER      ,
    X_TRANSLATED_GRADE              => v_suao_rec.TRANSLATED_GRADE               ,
    X_TRANSLATED_DT                 => v_suao_rec.TRANSLATED_DT                  ,
    X_MODE                          => 'R'                        ,
    X_GRADING_PERIOD_CD             => v_suao_rec.GRADING_PERIOD_CD              ,
    X_ATTRIBUTE_CATEGORY            => v_suao_rec.ATTRIBUTE_CATEGORY             ,
    X_ATTRIBUTE1                    => v_suao_rec.ATTRIBUTE1                     ,
    X_ATTRIBUTE2                    => v_suao_rec.ATTRIBUTE2                     ,
    X_ATTRIBUTE3                    => v_suao_rec.ATTRIBUTE3                     ,
    X_ATTRIBUTE4                    => v_suao_rec.ATTRIBUTE4                     ,
    X_ATTRIBUTE5                    => v_suao_rec.ATTRIBUTE5                     ,
    X_ATTRIBUTE6                    => v_suao_rec.ATTRIBUTE6                     ,
    X_ATTRIBUTE7                    => v_suao_rec.ATTRIBUTE7                     ,
    X_ATTRIBUTE8                    => v_suao_rec.ATTRIBUTE8                     ,
    X_ATTRIBUTE9                    => v_suao_rec.ATTRIBUTE9                     ,
    X_ATTRIBUTE10                   => v_suao_rec.ATTRIBUTE10                    ,
    X_ATTRIBUTE11                   => v_suao_rec.ATTRIBUTE11                    ,
    X_ATTRIBUTE12                   => v_suao_rec.ATTRIBUTE12                    ,
    X_ATTRIBUTE13                   => v_suao_rec.ATTRIBUTE13                    ,
    X_ATTRIBUTE14                   => v_suao_rec.ATTRIBUTE14                    ,
    X_ATTRIBUTE15                   => v_suao_rec.ATTRIBUTE15                    ,
    X_ATTRIBUTE16                   => v_suao_rec.ATTRIBUTE16                    ,
    X_ATTRIBUTE17                   => v_suao_rec.ATTRIBUTE17                    ,
    X_ATTRIBUTE18                   => v_suao_rec.ATTRIBUTE18                    ,
    X_ATTRIBUTE19                   => v_suao_rec.ATTRIBUTE19                    ,
    X_ATTRIBUTE20                   => v_suao_rec.ATTRIBUTE20                    ,
    X_INCOMP_DEADLINE_DATE          => v_suao_rec.INCOMP_DEADLINE_DATE           ,
    X_INCOMP_GRADING_SCHEMA_CD      => v_suao_rec.INCOMP_GRADING_SCHEMA_CD       ,
    X_INCOMP_VERSION_NUMBER         => v_suao_rec.INCOMP_VERSION_NUMBER          ,
    X_INCOMP_DEFAULT_GRADE          => v_suao_rec.INCOMP_DEFAULT_GRADE           ,
    X_INCOMP_DEFAULT_MARK           => v_suao_rec.INCOMP_DEFAULT_MARK            ,
    X_COMMENTS                      => v_suao_rec.COMMENTS                       ,
    X_UOO_ID                        => v_suao_rec.UOO_ID                         ,
    X_MARK_CAPPED_FLAG              => v_suao_rec.MARK_CAPPED_FLAG               ,
    X_RELEASE_DATE                  => v_suao_rec.RELEASE_DATE                   ,
    X_MANUAL_OVERRIDE_FLAG          => v_suao_rec.MANUAL_OVERRIDE_FLAG           ,
    X_SHOW_ON_ACADEMIC_HISTRY_FLAG => v_suao_rec. SHOW_ON_ACADEMIC_HISTRY_FLAG   );
  END LOOP;

END Enrp_Ins_Suao_Trnsfr;


PROCEDURE Enrp_Ins_Splace_Trnsfr (
  p_person_id IN NUMBER,
  p_source_course_cd IN VARCHAR2,
  p_dest_course_cd IN VARCHAR2,
  p_source_uoo_id IN NUMBER,
  p_dest_uoo_id IN NUMBER)  AS
  /*------------------------------------------------------
  --Created by  : AMUTHU, Oracle IDC
  --Date created:
  --
  --Purpose:This procedure will logs the error/warn messages
  --Procedure logs the all error/warn messages.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  -- WHO        WHEN             WHAT
  -- amuthu     06-JUL-2006      Replaced the value to the parameter in the call to
  --                             igs_en_splacements_pkg.insert_row from v_dest_splace.uoo_id to p_Dest_uoo_id
*/
  v_dummy VARCHAR2(1);

  CURSOR c_splace (cp_person_id IGS_EN_SPLACEMENTS.PERSON_ID%TYPE,
                   cp_course_cd IGS_EN_SPLACEMENTS.COURSE_CD%TYPE,
                   cp_uoo_id IGS_EN_SPLACEMENTS.UOO_ID%TYPE) IS
  SELECT rowid, SPLACEMENT_ID, person_id, course_cd, uoo_id,start_date,
         end_date, institution_code, title, description, category_code,
     placement_type_code, SPECIALTY_CODE, compensation_flag,
     attendance_type, location, notes
  FROM IGS_EN_SPLACEMENTS
  WHERE person_id = cp_person_id
  AND course_cd = cp_course_cd
  AND uoo_id = cp_uoo_id;

  v_source_splace c_splace%ROWTYPE;
  v_dest_splace c_splace%ROWTYPE;
  l_rowid VARCHAR2(25);
  l_splace_rowid VARCHAR2(25);
  l_splacement_id NUMBER;

  CURSOR cur_sp(c_splacement_id IGS_EN_SPLACEMENTS.SPLACEMENT_ID%TYPE) IS
   SELECT rowid, supervisor_id
   FROM IGS_EN_SPLACE_SUPS
   WHERE Splacement_id=c_splacement_id;

  CURSOR cur_fac(c_splacement_id IGS_EN_SPLACEMENTS.SPLACEMENT_ID%TYPE) IS
     SELECT rowid, FACULTY_ID
   FROM IGS_EN_SPLACE_FACS
   WHERE Splacement_id=c_splacement_id;

  l_sup_exists BOOLEAN;
  l_fac_exists BOOLEAN;

  TYPE r_sup_rec_type IS RECORD (
    supervisor_id HZ_PARTIES.PARTY_ID%TYPE);
  TYPE t_sup_tab IS TABLE of r_sup_rec_type INDEX BY BINARY_INTEGER;

  v_sup_tab t_sup_tab;
  v_sup_index BINARY_INTEGER;

  TYPE r_fac_rec_type IS RECORD (
    faculty_id HZ_PARTIES.PARTY_ID%TYPE);
  TYPE t_fac_tab IS TABLE of r_fac_rec_type INDEX BY BINARY_INTEGER;

  v_fac_tab t_fac_tab;
  v_fac_index BINARY_INTEGER;

BEGIN

  -- There can be only one placement details record for a given unit attempt
  -- An additional unique key is present to prevent the existence of placement
  -- record for the same person in the same instution with the same start date
  -- and title.

  -- check if the placement details exists for the source, if it does
  -- then check if it exists for the destination, if not then start
  -- copying the details. If either the placement detail does not exists
  -- for the source or already exists for the destination the return true

  -- First all the placement supervior and faculty details are stored in
  -- pl/sql table and deleted from the tables. Then the delete the placement
  -- record itself.

  -- create all the detials against the destination record


  OPEN c_splace(p_person_id, p_source_course_cd, p_source_uoo_id);
  FETCH c_splace INTO v_source_splace;
  IF c_splace%NOTFOUND THEN
    CLOSE c_splace;
  RETURN;
  END IF;
  CLOSE c_splace;

  OPEN c_splace(p_person_id, p_dest_course_cd, p_dest_uoo_id);
  FETCH c_splace INTO v_dest_splace;
  IF c_splace%FOUND THEN
    CLOSE c_splace;
  RETURN;
  END IF;
  CLOSE c_splace;


  l_sup_exists := FALSE;
  v_sup_index := 1;
  FOR v_cur_sp_rec in cur_sp(v_source_splace.splacement_id) LOOP
    l_sup_exists := TRUE;
  v_sup_tab(v_sup_index).supervisor_id := v_cur_sp_rec.supervisor_id;
  v_sup_index := v_sup_index + 1;
    igs_en_splace_sups_pkg.delete_ROW(v_cur_sp_rec.rowid);
  END LOOP;

  l_fac_exists := FALSE;
  v_fac_index := 1;
  FOR v_cur_fac_rec in cur_fac(v_source_splace.splacement_id) LOOP
    l_fac_exists := TRUE;
  v_fac_tab(v_fac_index).faculty_id := v_cur_fac_rec.faculty_id;
  v_fac_index := v_fac_index + 1;
    IGS_EN_SPLACE_FACS_pkg.delete_row(v_cur_fac_rec.rowid);
  END LOOP;


  igs_en_splacements_pkg.delete_row(v_source_splace.rowid);

  igs_en_splacements_pkg.insert_row (
    x_rowid              => l_splace_rowid              ,
    x_splacement_id      => l_splacement_id      ,
    x_person_id          => v_source_splace.person_id          ,
    x_course_cd          => p_dest_course_cd          ,
    x_uoo_id             => p_dest_uoo_id             ,
    x_start_date         => v_source_splace.start_date         ,
    x_end_date           => v_source_splace.end_date           ,
    x_institution_code   => v_source_splace.institution_code   ,
    x_title              => v_source_splace.title              ,
    x_description        => v_source_splace.description        ,
    x_category_code      => v_source_splace.category_code      ,
    x_placement_type_code=> v_source_splace.placement_type_code,
    x_specialty_code     => v_source_splace.specialty_code     ,
    x_compensation_flag  => v_source_splace.compensation_flag  ,
    x_attendance_type    => v_source_splace.attendance_type    ,
    x_location           => v_source_splace.location           ,
    x_notes              => v_source_splace.notes              ,
    x_mode               => 'R'              );

  IF l_sup_exists THEN
    FOR v_sup_index in v_sup_tab.FIRST..v_sup_tab.LAST LOOP
      l_rowid := NULL;

      igs_en_splace_sups_pkg.INSERT_ROW(
                        x_rowid         => l_rowid,
                      x_splacement_id => l_splacement_id,
                      x_supervisor_id => v_sup_tab(v_sup_index).supervisor_id,
                      x_mode          => 'R');
    END LOOP;
  END IF;

  IF l_fac_exists THEN
    FOR  v_fac_index in v_fac_tab.FIRST..v_fac_tab.LAST LOOP
    l_rowid := NULL;

      IGS_EN_SPLACE_FACS_pkg.INSERT_ROW(
                        x_rowid         => l_rowid,
                      x_splacement_id => l_splacement_id,
                      x_FACULTY_ID    => v_fac_tab(v_fac_index).faculty_id,
                      x_mode          => 'R');
    END LOOP;
  END IF;


END Enrp_Ins_Splace_Trnsfr;



FUNCTION Enrp_del_all_Sua_Trnsfr(
  p_person_id           IN NUMBER ,
  p_source_course_cd    IN VARCHAR2 ,
  p_dest_course_cd      IN VARCHAR2 ,
  p_uoo_ids             IN VARCHAR2,
  p_term_cal_type       IN VARCHAR2,
  p_term_seq_num        IN NUMBER,
  p_drop                IN BOOLEAN,
  p_message_name        OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

 /*

||  Created By : AMUTHU
||  Created On : 27-NOV-2004
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When             What
||  ckasu           08-DEC-2004      Modfied message name inorder to show invalid unit attempts can't
||                                   be transferred across careers message as a part  of bug#4048203
||  ckasu           11-Dec-2004      Modified signature of Enrp_del_all_Sua_Trnsfr inorder to retain
||                                   unselected enrolled or waitlisted or invalid units when transfer
||                                   is across careers and discontinue source is set to 'NO'  as a
||                                   part of bug#4061818
|| smaddali         21-dec-04       Modified for bug#4083358 , to change logic for dropping selected unit attempts across terms
 */


  v_uoo_id      IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE;
  l_message_name VARCHAR2(30);
  v_unit_from_past_term BOOLEAN;
  v_dummy       VARCHAR2(1);
  l_cindex      NUMBER;

  cst_dropped   CONSTANT  VARCHAR2(10) := 'DROPPED';
  cst_unconfirm   CONSTANT VARCHAR2(10) := 'UNCONFIRM';
  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
  cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
  cst_waitlist  CONSTANT  VARCHAR2(10) := 'WAITLISTED';
  cst_invalid  CONSTANT  VARCHAR2(10) := 'INVALID';

  CURSOR c_sua_source (cp_person_id IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE,
                cp_source_course_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
        cp_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
  SELECT *
  FROM IGS_EN_SU_ATTEMPT
  WHERE person_id = cp_person_id
  and course_cd = cp_source_course_cd
  and uoo_id = cp_uoo_id;

  v_sua_source_rec c_sua_source%ROWTYPE;

  CURSOR c_sub_sua_exists( cp_person_id IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE,
                           cp_source_program_cd IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE,
               cp_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
  SELECT 'X'
  FROM IGS_PS_UNIT_OFR_OPT uoo
  WHERE uoo.relation_type = 'SUBORDINATE'
  AND uoo.sup_uoo_id = cp_uoo_id
  AND exists (SELECT 'X'
                FROM IGS_EN_SU_ATTEMPT sub_sua
                WHERE sub_sua.person_id = cp_person_id
                AND sub_sua.course_cd = cp_source_program_cd
                AND sub_sua.uoo_id = uoo.uoo_id
        AND sub_sua.unit_attempt_status <> cst_dropped);

  -- get all the unit attempts selected and unselected by the user and order them so
  -- that subordinate is dropped first
  CURSOR c_get_all_units_in_src IS
     SELECT uoo_id FROM IGS_EN_SU_ATTEMPT
     WHERE person_id = p_person_id   AND
           course_cd = p_source_course_cd AND
           unit_attempt_status NOT IN (cst_dropped,cst_duplicate)
           ORDER BY SUP_UNIT_CD ;

  v_get_all_units_in_src_rec   c_get_all_units_in_src%ROWTYPE;
  l_temp_uoo_ids    VARCHAR2(1000);

  -- get the course type of the passed program attempt
  CURSOR c_sua_career ( cp_person_id IN igs_en_stdnt_ps_att.person_id%TYPE ,
                        cp_course_cd IN igs_en_stdnt_ps_att.course_cd%TYPE ) IS
   SELECT  ver.course_type
    FROM    IGS_PS_VER ver ,
            igs_en_stdnt_ps_att spa
    WHERE   ver.course_cd      = spa.course_cd AND
            ver.version_number = spa.version_number AND
            spa.course_cd      = cp_course_cd AND
            spa.person_id      = cp_person_id;
    l_source_course_type igs_ps_ver.course_type%TYPE;
    l_destn_course_type igs_ps_ver.course_type%TYPE;

    CURSOR c_unit_dcnt is
   SELECT DISCONTINUATION_REASON_CD
   FROM IGS_EN_DCNT_REASONCD
   WHERE S_DISCONTINUATION_REASON_TYPE = 'UNIT_TRANS'
   AND DCNT_UNIT_IND = 'Y'
   AND SYS_DFLT_IND = 'Y'
   AND CLOSED_IND = 'N';

   l_unt_disc_code IGS_EN_DCNT_REASONCD.DISCONTINUATION_REASON_CD%TYPE := null;
   l_dflt_disc_code IGS_EN_DCNT_REASONCD.DISCONTINUATION_REASON_CD%TYPE := null;

   CURSOR c_dcnt_rsn IS
   SELECT discontinuation_reason_cd
   FROM igs_en_dcnt_reasoncd
   WHERE  NVL(closed_ind,'N') ='N'
   AND  dflt_ind ='Y'
   AND dcnt_unit_ind ='Y'
   AND s_discontinuation_reason_type IS NULL;



BEGIN
    --get the unit discontinuation reason type as part of transfer
      OPEN c_unit_dcnt;
      FETCH c_unit_dcnt into l_unt_disc_code;
      CLOSE c_unit_dcnt;

     OPEN c_dcnt_rsn;
      FETCH c_dcnt_rsn INTO l_dflt_disc_code;
      CLOSE c_dcnt_rsn;


      l_temp_uoo_ids := ',' || p_uoo_ids || ',' ;

      -- get all the uoo_ids of units present in the source whose status is in
      -- other than duplicate,dropped,unconfirmed.
      FOR v_get_all_units_in_src_rec IN c_get_all_units_in_src
      LOOP

          -- get the unit detsils for the uoo_id in context
          OPEN c_sua_source(p_person_id, p_source_course_cd, v_get_all_units_in_src_rec.uoo_id);
          FETCH c_sua_source INTO v_sua_source_rec;
          CLOSE c_sua_source;

          --l_cindex contains value other than ZERO when the uoo_id present in the source
          --is one amongst the selected ones.
          l_cindex := INSTR(l_temp_uoo_ids,','||v_get_all_units_in_src_rec.uoo_id||',',1,1);
          IF  l_cindex <> 0  THEN

              -- donot drop selected enrolled/invalid/waitlisted unit attempts belonging to a past term
              -- compared to the effective term in inter career transfer or program mode
              -- added this logic for bug#4083358
              IF v_sua_source_rec.unit_attempt_status  IN ( cst_enrolled,cst_invalid,cst_waitlist ) AND
                    NOT unit_effect_or_future_term(p_person_id,p_dest_course_cd,v_sua_source_rec.uoo_id,p_term_cal_type,p_term_seq_num) THEN

                      -- get the source and destination careers
                      OPEN  c_sua_career(p_person_id , p_source_course_cd);
                      FETCH c_sua_career INTO l_source_course_type;
                      CLOSE c_sua_career;
                      OPEN  c_sua_career(p_person_id , p_dest_course_cd);
                      FETCH c_sua_career INTO l_destn_course_type;
                      CLOSE c_sua_career;
                      -- if career not setup then throw error
                      IF l_source_course_type IS NULL OR  l_destn_course_type IS NULL THEN
                            Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                            FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_010.enrp_ins_sua_trnsfr');
                            IGS_GE_MSG_STACK.ADD;
                            App_Exception.Raise_Exception;
                      END IF;

                    -- if it is an intra career transfer then drop unit from source reducing counts as this unit was not transfered
                    IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') =  'Y' AND
                        l_source_course_type =  l_destn_course_type THEN
                              -- superior unit cannot be drop even when one of its subordinates is enrolled
                              OPEN c_sub_sua_exists(p_person_id, p_source_course_cd, v_get_all_units_in_src_rec.uoo_id);
                              FETCH c_sub_sua_exists INTO v_dummy;
                              IF c_sub_sua_exists%FOUND THEN
                                 CLOSE c_sub_sua_exists;
                                 p_message_name := 'IGS_EN_SUP_DEL_NOTALWD';
                                 RETURN FALSE;
                              ELSE
                                 CLOSE c_sub_sua_exists;
                              END IF;

                              igs_en_sua_api.update_unit_attempt( -- calling the API since the counts have to be updated
                                  X_ROWID                      => v_sua_source_rec.ROW_ID,
                                  X_PERSON_ID                  => v_sua_source_rec.PERSON_ID,
                                  X_COURSE_CD                  => v_sua_source_rec.COURSE_CD ,
                                  X_UNIT_CD                    => v_sua_source_rec.UNIT_CD,
                                  X_CAL_TYPE                   => v_sua_source_rec.CAL_TYPE,
                                  X_CI_SEQUENCE_NUMBER         => v_sua_source_rec.CI_SEQUENCE_NUMBER ,
                                  X_VERSION_NUMBER             => v_sua_source_rec.VERSION_NUMBER ,
                                  X_LOCATION_CD                => v_sua_source_rec.LOCATION_CD,
                                  X_UNIT_CLASS                 => v_sua_source_rec.UNIT_CLASS ,
                                  X_CI_START_DT                => v_sua_source_rec.CI_START_DT,
                                  X_CI_END_DT                  => v_sua_source_rec.CI_END_DT,
                                  X_UOO_ID                     => v_sua_source_rec.UOO_ID ,
                                  X_ENROLLED_DT                => v_sua_source_rec.ENROLLED_DT,
                                  X_UNIT_ATTEMPT_STATUS        => cst_dropped, -- updating the status to dropped
                                  X_ADMINISTRATIVE_UNIT_STATUS => v_sua_source_rec.administrative_unit_status,
                                  X_ADMINISTRATIVE_PRIORITY    => v_sua_source_rec.administrative_PRIORITY,
                                  X_DISCONTINUED_DT            => nvl(v_sua_source_rec.discontinued_dt,trunc(SYSDATE)),
                                  X_DCNT_REASON_CD             => l_dflt_disc_code,
                                  X_RULE_WAIVED_DT             => v_sua_source_rec.RULE_WAIVED_DT ,
                                  X_RULE_WAIVED_PERSON_ID      => v_sua_source_rec.RULE_WAIVED_PERSON_ID ,
                                  X_NO_ASSESSMENT_IND          => v_sua_source_rec.NO_ASSESSMENT_IND,
                                  X_SUP_UNIT_CD                => v_sua_source_rec.SUP_UNIT_CD ,
                                  X_SUP_VERSION_NUMBER         => v_sua_source_rec.SUP_VERSION_NUMBER,
                                  X_EXAM_LOCATION_CD           => v_sua_source_rec.EXAM_LOCATION_CD,
                                  X_ALTERNATIVE_TITLE          => v_sua_source_rec.ALTERNATIVE_TITLE,
                                  X_OVERRIDE_ENROLLED_CP       => v_sua_source_rec.OVERRIDE_ENROLLED_CP,
                                  X_OVERRIDE_EFTSU             => v_sua_source_rec.OVERRIDE_EFTSU ,
                                  X_OVERRIDE_ACHIEVABLE_CP     => v_sua_source_rec.OVERRIDE_ACHIEVABLE_CP,
                                  X_OVERRIDE_OUTCOME_DUE_DT    => v_sua_source_rec.OVERRIDE_OUTCOME_DUE_DT,
                                  X_OVERRIDE_CREDIT_REASON     => v_sua_source_rec.OVERRIDE_CREDIT_REASON,
                                  X_WAITLIST_DT                => v_sua_source_rec.waitlist_dt,
                                  X_MODE                       =>  'R',
                                  X_GS_VERSION_NUMBER          => v_sua_source_rec.gs_version_number,
                                  X_ENR_METHOD_TYPE            => v_sua_source_rec.enr_method_type,
                                  X_FAILED_UNIT_RULE           => v_sua_source_rec.FAILED_UNIT_RULE,
                                  X_CART                       => v_sua_source_rec.CART,
                                  X_RSV_SEAT_EXT_ID            => v_sua_source_rec.RSV_SEAT_EXT_ID ,
                                  X_ORG_UNIT_CD                => v_sua_source_rec.org_unit_cd    ,
                                  X_SESSION_ID                 => v_sua_source_rec.session_id,
                                  X_GRADING_SCHEMA_CODE        => v_sua_source_rec.grading_schema_code,
                                  X_DEG_AUD_DETAIL_ID          => v_sua_source_rec.deg_aud_detail_id,
                                  X_SUBTITLE                   => v_sua_source_rec.subtitle,
                                  X_STUDENT_CAREER_TRANSCRIPT  => v_sua_source_rec.student_career_transcript,
                                  X_STUDENT_CAREER_STATISTICS  => v_sua_source_rec.student_career_statistics,
                                  X_ATTRIBUTE_CATEGORY         => v_sua_source_rec.attribute_category,
                                  X_ATTRIBUTE1                 => v_sua_source_rec.attribute1,
                                  X_ATTRIBUTE2                 => v_sua_source_rec.attribute2,
                                  X_ATTRIBUTE3                 => v_sua_source_rec.attribute3,
                                  X_ATTRIBUTE4                 => v_sua_source_rec.attribute4,
                                  X_ATTRIBUTE5                 => v_sua_source_rec.attribute5,
                                  X_ATTRIBUTE6                 => v_sua_source_rec.attribute6,
                                  X_ATTRIBUTE7                 => v_sua_source_rec.attribute7,
                                  X_ATTRIBUTE8                 => v_sua_source_rec.attribute8,
                                  X_ATTRIBUTE9                 => v_sua_source_rec.attribute9,
                                  X_ATTRIBUTE10                => v_sua_source_rec.attribute10,
                                  X_ATTRIBUTE11                => v_sua_source_rec.attribute11,
                                  X_ATTRIBUTE12                => v_sua_source_rec.attribute12,
                                  X_ATTRIBUTE13                => v_sua_source_rec.attribute13,
                                  X_ATTRIBUTE14                => v_sua_source_rec.attribute14,
                                  X_ATTRIBUTE15                => v_sua_source_rec.attribute15,
                                  X_ATTRIBUTE16                => v_sua_source_rec.attribute16,
                                  X_ATTRIBUTE17                => v_sua_source_rec.attribute17,
                                  X_ATTRIBUTE18                => v_sua_source_rec.attribute18,
                                  X_ATTRIBUTE19                => v_sua_source_rec.attribute19,
                                  X_ATTRIBUTE20                => v_sua_source_rec.attribute20,
                                  X_WAITLIST_MANUAL_IND        => v_sua_source_rec.waitlist_manual_ind,
                                  X_WLST_PRIORITY_WEIGHT_NUM   => v_sua_source_rec.wlst_priority_weight_num,
                                  X_WLST_PREFERENCE_WEIGHT_NUM => v_sua_source_rec.wlst_preference_weight_num,
                                  X_CORE_INDICATOR_CODE        => v_sua_source_rec.core_indicator_code
                                  );

                    END IF ; -- if intra career transfer

              -- else this selected unit was transfered , so drop
              ELSE

                  -- v_unit_from_past_term is assigned with TRUE for units which were enrolled in Term calendar other than
                  -- effective Term calendar of Transfer and also having unit status in DISCONTINUE/COMPLETED else FALSE.
                  -- for all other statuses this function returns False.

                  v_unit_from_past_term := enrf_unit_from_past(
                                             p_person_id,
                                             p_source_course_cd,
                                             v_get_all_units_in_src_rec.uoo_id,
                                             v_sua_source_rec.unit_attempt_status,
                                             v_sua_source_rec.discontinued_dt,
                                             p_term_cal_type,
                                             p_term_seq_num);

                  IF NOT v_unit_from_past_term THEN
                            -- superior unit cannot be drop even when one of its subordinates is enrolled
                            OPEN c_sub_sua_exists(p_person_id, p_source_course_cd, v_get_all_units_in_src_rec.uoo_id);
                            FETCH c_sub_sua_exists INTO v_dummy;
                            IF c_sub_sua_exists%FOUND THEN
                              CLOSE c_sub_sua_exists;
                              p_message_name := 'IGS_EN_SUP_DEL_NOTALWD';
                              RETURN FALSE;
                            ELSE
                              CLOSE c_sub_sua_exists;
                            END IF;

                            IF l_unt_disc_code IS NULL THEN
                                     -- implies no system reason for unit drop due to transfer is setup
                                     --hence throw error and return
                                    p_message_name := 'IGS_EN_NO_SYS_DFLT_REASON';
                                     RETURN FALSE;
                                     END IF;



                             IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW( -- calling the TBH since the count need not be updated
                                  X_ROWID                      => v_sua_source_rec.ROW_ID,
                                  X_PERSON_ID                  => v_sua_source_rec.PERSON_ID,
                                  X_COURSE_CD                  => v_sua_source_rec.COURSE_CD ,
                                  X_UNIT_CD                    => v_sua_source_rec.UNIT_CD,
                                  X_CAL_TYPE                   => v_sua_source_rec.CAL_TYPE,
                                  X_CI_SEQUENCE_NUMBER         => v_sua_source_rec.CI_SEQUENCE_NUMBER ,
                                  X_VERSION_NUMBER             => v_sua_source_rec.VERSION_NUMBER ,
                                  X_LOCATION_CD                => v_sua_source_rec.LOCATION_CD,
                                  X_UNIT_CLASS                 => v_sua_source_rec.UNIT_CLASS ,
                                  X_CI_START_DT                => v_sua_source_rec.CI_START_DT,
                                  X_CI_END_DT                  => v_sua_source_rec.CI_END_DT,
                                  X_UOO_ID                     => v_sua_source_rec.UOO_ID ,
                                  X_ENROLLED_DT                => v_sua_source_rec.ENROLLED_DT,
                                  X_UNIT_ATTEMPT_STATUS        => cst_dropped, -- modifying the status to dropped
                                  X_ADMINISTRATIVE_UNIT_STATUS => v_sua_source_rec.administrative_unit_status,
                                  X_ADMINISTRATIVE_PRIORITY    => v_sua_source_rec.administrative_PRIORITY,
                                  X_DISCONTINUED_DT            => nvl(v_sua_source_rec.discontinued_dt,SYSDATE),
                                  X_DCNT_REASON_CD             => l_unt_disc_code,
                                  X_RULE_WAIVED_DT             => v_sua_source_rec.RULE_WAIVED_DT ,
                                  X_RULE_WAIVED_PERSON_ID      => v_sua_source_rec.RULE_WAIVED_PERSON_ID ,
                                  X_NO_ASSESSMENT_IND          => v_sua_source_rec.NO_ASSESSMENT_IND,
                                  X_SUP_UNIT_CD                => v_sua_source_rec.SUP_UNIT_CD ,
                                  X_SUP_VERSION_NUMBER         => v_sua_source_rec.SUP_VERSION_NUMBER,
                                  X_EXAM_LOCATION_CD           => v_sua_source_rec.EXAM_LOCATION_CD,
                                  X_ALTERNATIVE_TITLE          => v_sua_source_rec.ALTERNATIVE_TITLE,
                                  X_OVERRIDE_ENROLLED_CP       => v_sua_source_rec.OVERRIDE_ENROLLED_CP,
                                  X_OVERRIDE_EFTSU             => v_sua_source_rec.OVERRIDE_EFTSU ,
                                  X_OVERRIDE_ACHIEVABLE_CP     => v_sua_source_rec.OVERRIDE_ACHIEVABLE_CP,
                                  X_OVERRIDE_OUTCOME_DUE_DT    => v_sua_source_rec.OVERRIDE_OUTCOME_DUE_DT,
                                  X_OVERRIDE_CREDIT_REASON     => v_sua_source_rec.OVERRIDE_CREDIT_REASON,
                                  X_WAITLIST_DT                => v_sua_source_rec.waitlist_dt,
                                  X_MODE                       =>  'R',
                                  X_GS_VERSION_NUMBER          => v_sua_source_rec.gs_version_number,
                                  X_ENR_METHOD_TYPE            => v_sua_source_rec.enr_method_type,
                                  X_FAILED_UNIT_RULE           => v_sua_source_rec.FAILED_UNIT_RULE,
                                  X_CART                       => v_sua_source_rec.CART,
                                  X_RSV_SEAT_EXT_ID            => v_sua_source_rec.RSV_SEAT_EXT_ID ,
                                  X_ORG_UNIT_CD                => v_sua_source_rec.org_unit_cd    ,
                                  X_SESSION_ID                 => v_sua_source_rec.session_id,
                                  X_GRADING_SCHEMA_CODE        => v_sua_source_rec.grading_schema_code,
                                  X_DEG_AUD_DETAIL_ID          => v_sua_source_rec.deg_aud_detail_id,
                                  X_SUBTITLE                   =>  v_sua_source_rec.subtitle,
                                  X_STUDENT_CAREER_TRANSCRIPT  => v_sua_source_rec.student_career_transcript,
                                  X_STUDENT_CAREER_STATISTICS  => v_sua_source_rec.student_career_statistics,
                                  X_ATTRIBUTE_CATEGORY         => v_sua_source_rec.attribute_category,
                                  X_ATTRIBUTE1                 => v_sua_source_rec.attribute1,
                                  X_ATTRIBUTE2                 => v_sua_source_rec.attribute2,
                                  X_ATTRIBUTE3                 => v_sua_source_rec.attribute3,
                                  X_ATTRIBUTE4                 => v_sua_source_rec.attribute4,
                                  X_ATTRIBUTE5                 => v_sua_source_rec.attribute5,
                                  X_ATTRIBUTE6                 => v_sua_source_rec.attribute6,
                                  X_ATTRIBUTE7                 => v_sua_source_rec.attribute7,
                                  X_ATTRIBUTE8                 => v_sua_source_rec.attribute8,
                                  X_ATTRIBUTE9                 => v_sua_source_rec.attribute9,
                                  X_ATTRIBUTE10                => v_sua_source_rec.attribute10,
                                  X_ATTRIBUTE11                => v_sua_source_rec.attribute11,
                                  X_ATTRIBUTE12                => v_sua_source_rec.attribute12,
                                  X_ATTRIBUTE13                => v_sua_source_rec.attribute13,
                                  X_ATTRIBUTE14                => v_sua_source_rec.attribute14,
                                  X_ATTRIBUTE15                => v_sua_source_rec.attribute15,
                                  X_ATTRIBUTE16                => v_sua_source_rec.attribute16,
                                  X_ATTRIBUTE17                => v_sua_source_rec.attribute17,
                                  X_ATTRIBUTE18                => v_sua_source_rec.attribute18,
                                  X_ATTRIBUTE19                => v_sua_source_rec.attribute19,
                                  X_ATTRIBUTE20                => v_sua_source_rec.attribute20,
                                  X_WAITLIST_MANUAL_IND        => v_sua_source_rec.waitlist_manual_ind ,
                                  X_WLST_PRIORITY_WEIGHT_NUM   => v_sua_source_rec.wlst_priority_weight_num,
                                  X_WLST_PREFERENCE_WEIGHT_NUM => v_sua_source_rec.wlst_preference_weight_num,
                                  X_CORE_INDICATOR_CODE        => v_sua_source_rec.core_indicator_code,
                                  X_UPD_AUDIT_FLAG             => v_sua_source_rec.upd_audit_flag,
                                  X_SS_SOURCE_IND              => v_sua_source_rec.ss_source_ind
                                  );
                  END IF;-- end of IF NOT v_unit_from_past_term THEN

              END IF ; -- if enrolled unit is in past term?

          -- this will executed when unchecked units are in status of enrolled,invalid,waitlisted inorder
          -- to reduce the count.
          -- UNCONFIRM are not show to user in Page but need to be droped when source become secondary or discontinue is 'Yes'.
          ELSIF  (p_drop  AND v_sua_source_rec.unit_attempt_status IN ('ENROLLED','INVALID','WAITLISTED','UNCONFIRM')) THEN

                      -- superior unit cannot be drop even when one of its subordinates is enrolled
                      OPEN c_sub_sua_exists(p_person_id, p_source_course_cd, v_get_all_units_in_src_rec.uoo_id);
                      FETCH c_sub_sua_exists INTO v_dummy;
                      IF c_sub_sua_exists%FOUND THEN
                         CLOSE c_sub_sua_exists;
                         p_message_name := 'IGS_EN_SUP_DEL_NOTALWD';
                         RETURN FALSE;
                      ELSE
                         CLOSE c_sub_sua_exists;
                      END IF;

                      igs_en_sua_api.update_unit_attempt( -- calling the API since the counts have to be updated
                          X_ROWID                      => v_sua_source_rec.ROW_ID,
                          X_PERSON_ID                  => v_sua_source_rec.PERSON_ID,
                          X_COURSE_CD                  => v_sua_source_rec.COURSE_CD ,
                          X_UNIT_CD                    => v_sua_source_rec.UNIT_CD,
                          X_CAL_TYPE                   => v_sua_source_rec.CAL_TYPE,
                          X_CI_SEQUENCE_NUMBER         => v_sua_source_rec.CI_SEQUENCE_NUMBER ,
                          X_VERSION_NUMBER             => v_sua_source_rec.VERSION_NUMBER ,
                          X_LOCATION_CD                => v_sua_source_rec.LOCATION_CD,
                          X_UNIT_CLASS                 => v_sua_source_rec.UNIT_CLASS ,
                          X_CI_START_DT                => v_sua_source_rec.CI_START_DT,
                          X_CI_END_DT                  => v_sua_source_rec.CI_END_DT,
                          X_UOO_ID                     => v_sua_source_rec.UOO_ID ,
                          X_ENROLLED_DT                => v_sua_source_rec.ENROLLED_DT,
                          X_UNIT_ATTEMPT_STATUS        => cst_dropped, -- updating the status to dropped
                          X_ADMINISTRATIVE_UNIT_STATUS => v_sua_source_rec.administrative_unit_status,
                          X_ADMINISTRATIVE_PRIORITY    => v_sua_source_rec.administrative_PRIORITY,
                          X_DISCONTINUED_DT            => nvl(v_sua_source_rec.discontinued_dt,trunc(SYSDATE)),
                          X_DCNT_REASON_CD             => l_dflt_disc_code,
                          X_RULE_WAIVED_DT             => v_sua_source_rec.RULE_WAIVED_DT ,
                          X_RULE_WAIVED_PERSON_ID      => v_sua_source_rec.RULE_WAIVED_PERSON_ID ,
                          X_NO_ASSESSMENT_IND          => v_sua_source_rec.NO_ASSESSMENT_IND,
                          X_SUP_UNIT_CD                => v_sua_source_rec.SUP_UNIT_CD ,
                          X_SUP_VERSION_NUMBER         => v_sua_source_rec.SUP_VERSION_NUMBER,
                          X_EXAM_LOCATION_CD           => v_sua_source_rec.EXAM_LOCATION_CD,
                          X_ALTERNATIVE_TITLE          => v_sua_source_rec.ALTERNATIVE_TITLE,
                          X_OVERRIDE_ENROLLED_CP       => v_sua_source_rec.OVERRIDE_ENROLLED_CP,
                          X_OVERRIDE_EFTSU             => v_sua_source_rec.OVERRIDE_EFTSU ,
                          X_OVERRIDE_ACHIEVABLE_CP     => v_sua_source_rec.OVERRIDE_ACHIEVABLE_CP,
                          X_OVERRIDE_OUTCOME_DUE_DT    => v_sua_source_rec.OVERRIDE_OUTCOME_DUE_DT,
                          X_OVERRIDE_CREDIT_REASON     => v_sua_source_rec.OVERRIDE_CREDIT_REASON,
                          X_WAITLIST_DT                => v_sua_source_rec.waitlist_dt,
                          X_MODE                       =>  'R',
                          X_GS_VERSION_NUMBER          => v_sua_source_rec.gs_version_number,
                          X_ENR_METHOD_TYPE            => v_sua_source_rec.enr_method_type,
                          X_FAILED_UNIT_RULE           => v_sua_source_rec.FAILED_UNIT_RULE,
                          X_CART                       => v_sua_source_rec.CART,
                          X_RSV_SEAT_EXT_ID            => v_sua_source_rec.RSV_SEAT_EXT_ID ,
                          X_ORG_UNIT_CD                => v_sua_source_rec.org_unit_cd    ,
                          X_SESSION_ID                 => v_sua_source_rec.session_id,
                          X_GRADING_SCHEMA_CODE        => v_sua_source_rec.grading_schema_code,
                          X_DEG_AUD_DETAIL_ID          => v_sua_source_rec.deg_aud_detail_id,
                          X_SUBTITLE                   =>  v_sua_source_rec.subtitle,
                          X_STUDENT_CAREER_TRANSCRIPT  => v_sua_source_rec.student_career_transcript,
                          X_STUDENT_CAREER_STATISTICS  => v_sua_source_rec.student_career_statistics,
                          X_ATTRIBUTE_CATEGORY         => v_sua_source_rec.attribute_category,
                          X_ATTRIBUTE1                 => v_sua_source_rec.attribute1,
                          X_ATTRIBUTE2                 => v_sua_source_rec.attribute2,
                          X_ATTRIBUTE3                 => v_sua_source_rec.attribute3,
                          X_ATTRIBUTE4                 => v_sua_source_rec.attribute4,
                          X_ATTRIBUTE5                 => v_sua_source_rec.attribute5,
                          X_ATTRIBUTE6                 => v_sua_source_rec.attribute6,
                          X_ATTRIBUTE7                 => v_sua_source_rec.attribute7,
                          X_ATTRIBUTE8                 => v_sua_source_rec.attribute8,
                          X_ATTRIBUTE9                 => v_sua_source_rec.attribute9,
                          X_ATTRIBUTE10                => v_sua_source_rec.attribute10,
                          X_ATTRIBUTE11                => v_sua_source_rec.attribute11,
                          X_ATTRIBUTE12                => v_sua_source_rec.attribute12,
                          X_ATTRIBUTE13                => v_sua_source_rec.attribute13,
                          X_ATTRIBUTE14                => v_sua_source_rec.attribute14,
                          X_ATTRIBUTE15                => v_sua_source_rec.attribute15,
                          X_ATTRIBUTE16                => v_sua_source_rec.attribute16,
                          X_ATTRIBUTE17                => v_sua_source_rec.attribute17,
                          X_ATTRIBUTE18                => v_sua_source_rec.attribute18,
                          X_ATTRIBUTE19                => v_sua_source_rec.attribute19,
                          X_ATTRIBUTE20                => v_sua_source_rec.attribute20,
                          X_WAITLIST_MANUAL_IND        => v_sua_source_rec.waitlist_manual_ind,
                          X_WLST_PRIORITY_WEIGHT_NUM   => v_sua_source_rec.wlst_priority_weight_num,
                          X_WLST_PREFERENCE_WEIGHT_NUM => v_sua_source_rec.wlst_preference_weight_num,
                          X_CORE_INDICATOR_CODE        => v_sua_source_rec.core_indicator_code
                          );

          END IF; -- end of  l_cindex <> 0 IF THEN

      END LOOP;-- end of get all units in source FOR LOOP


      RETURN TRUE;

END Enrp_del_all_Sua_Trnsfr;



FUNCTION enrf_sup_sua_exists(
   p_person_id IN NUMBER,
   p_course_cd IN VARCHAR2,
   p_uoo_id IN NUMBER)
   RETURN BOOLEAN  IS
 CURSOR cur_supuoo_id IS select sup_uoo_id
                                from IGS_PS_UNIT_OFR_OPT where uoo_id=p_uoo_id;

 CURSOR cur_sua (
                 cp_person_id IGS_EN_SU_ATTEMPT.person_id%TYPE,
                 cp_course_cd IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                 cp_uoo_id    IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
             IS
                 Select 1 from IGS_EN_SU_ATTEMPT
                    Where person_id=cp_person_id AND
                          course_cd=cp_course_cd AND
                          uoo_id=cp_uoo_id AND
              unit_attempt_status <> 'DROPPED';

 CURSOR c_sup_unit_cd (cp_person_id IGS_EN_SU_ATTEMPT.person_id%TYPE,
                 cp_course_cd IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                 cp_uoo_id    IGS_EN_SU_ATTEMPT.uoo_id%TYPE) IS
 SELECT sup_unit_Cd
 FROM IGS_EN_SU_ATTEMPT
 WHERE person_id = cp_person_id
 AND course_cd = cp_course_cd
 AND uoo_id = cp_uoo_id;

 l_sup_uoo_id IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE;
 l_sup_unit_Cd IGS_EN_SU_ATTEMPT.SUP_UNIT_CD%TYPE;
 l_cur_sua_rec cur_sua%ROWTYPE;
 l_result BOOLEAN;
 l_person_id IGS_EN_SU_ATTEMPT.person_id%TYPE;
 l_course_cd IGS_EN_SU_ATTEMPT.course_cd%TYPE;
BEGIN

   OPEN c_sup_unit_cd(p_person_id, p_course_cd, p_uoo_id);
   FETCH c_sup_unit_cd INTO l_sup_unit_Cd;
   CLOSE c_sup_unit_Cd;

   IF l_sup_unit_cd IS NULL THEN
     RETURN TRUE;
   END IF;

   OPEN cur_supuoo_id;
   FETCH cur_supuoo_id INTO l_sup_uoo_id;

   --if no records are returned by cur_supuoo_id
   IF cur_supuoo_id%NOTFOUND THEN
     l_result :=false;
   ELSE
     l_result:=true;
     IF l_sup_uoo_id IS NOT NULL THEN  --call cursor cur_sua
       OPEN cur_sua(p_person_id,p_course_cd,l_sup_uoo_id);
       FETCH cur_sua INTO l_cur_sua_rec;
       IF cur_sua%NOTFOUND THEN
         l_result:=false;
       ELSE
         l_result:=true;
       END IF;
   END IF;
   END IF;

   --close the cursors
   CLOSE cur_supuoo_id;
   --check whether cur_sua is open before closing it
   IF cur_sua%ISOPEN THEN
        CLOSE cur_sua;
   END IF;

   RETURN l_result;
END enrf_sup_sua_exists;

PROCEDURE Enrp_Ins_Suai_Trnsfr(
       p_person_id        IN NUMBER,
       p_source_course_cd IN VARCHAR2,
       p_dest_course_cd   IN VARCHAR2,
       p_source_uoo_id    IN NUMBER,
       p_dest_uoo_id      IN NUMBER,
       p_delete_source    IN BOOLEAN)
IS

Cursor c_source_ai_group(cp_person_id NUMBER,
                         cp_source_course_cd VARCHAR2,
                         cp_source_uoo_id    NUMBER) IS
SELECT sag.rowid, sag.*
  FROM IGS_AS_SUA_AI_GROUP sag
  WHERE sag.person_id = cp_person_id
  AND   sag.course_cd = cp_source_course_cd
  AND   sag.uoo_id    = cp_source_uoo_id
  AND   logical_delete_date IS NULL;


Cursor c_dest_ai_group (cp_person_id NUMBER,
                        cp_dest_course_cd VARCHAR2,
                        cp_dest_uoo_id NUMBER,
			cp_group_name VARCHAR2) IS
 SELECT GROUP_NAME
  FROM IGS_AS_SUA_AI_GROUP
  WHERE person_id = cp_person_id
  and course_cd = cp_dest_course_cd
  and uoo_id = cp_dest_uoo_id
  and group_name = cp_group_name;

CURSOR c_usec_level (cp_person_id NUMBER,
                        cp_dest_course_cd VARCHAR2,
                        cp_dest_uoo_id NUMBER) IS
      SELECT COUNT (person_id)
      FROM   igs_as_usecai_sua_v
      WHERE  person_id = cp_person_id
      AND    course_cd = cp_dest_course_cd
      AND    uoo_id = cp_dest_uoo_id
      AND    usai_logical_delete_dt IS NULL;

Cursor c_source_su_itm (cp_person_id NUMBER,
                        cp_course_cd VARCHAR2,
                        cp_uoo_id    NUMBER,
                        c_sua_ass_item_group_id NUMBER) IS
 SELECT asit.rowid, asit.*
  FROM IGS_AS_SU_ATMPT_ITM asit
  WHERE asit.person_id = cp_person_id
  and asit.course_cd = cp_course_cd
  and asit.uoo_id = cp_uoo_id
  and asit.SUA_ASS_ITEM_GROUP_ID =  c_sua_ass_item_group_id
  and asit.LOGICAL_DELETE_DT IS NULL;


CURSOR c_usec_ass_itm  (cp_unit_section_ass_item_id  NUMBER,
                       cp_dest_uoo_id NUMBER) IS
  SELECT usai_dest.UNIT_SECTION_ASS_ITEM_ID
  FROM igs_ps_unitass_item_v usai_source,
       igs_ps_unitass_item_v usai_dest,
       igs_as_assessmnt_itm ai_dest,
       igs_as_assessmnt_itm ai_source
 WHERE usai_source.unit_section_ass_item_id = cp_unit_section_ass_item_id
 and usai_dest.uoo_id = cp_dest_uoo_id
 and usai_dest.ass_id = ai_dest.ass_id
 and usai_source.ass_id = ai_source.ass_id
 and ai_source.ASSESSMENT_TYPE = ai_dest.ASSESSMENT_TYPE
 and usai_source.REFERENCE = usai_dest.REFERENCE
 and usai_source.GRADING_SCHEMA_CD = usai_dest.GRADING_SCHEMA_CD
 and usai_source.GS_VERSION_NUMBER = usai_dest.GS_VERSION_NUMBER;

CURSOR c_unit_ass_itm  (cp_person_id NUMBER,
                        cp_source_course_cd VARCHAR2,
                        cp_source_unit_ass_item_id  NUMBER,
                        cp_dest_course_cd VARCHAR2,
                       cp_dest_uoo_id NUMBER) IS
    SELECT suv_dest.unit_ass_item_id
    FROM igs_as_uai_sua_v suv_dest ,
         igs_as_assessmnt_itm ai_dest,
         igs_as_uai_sua_v suv_source
    WHERE suv_dest.uai_logical_delete_dt is null
    and ai_dest.ass_id = suv_dest.ass_id
    and suv_dest.person_id = cp_person_id
    and suv_dest.course_cd = cp_dest_course_cd
    and suv_dest.uoo_id = cp_dest_uoo_id
    and ai_dest.closed_ind = 'N'
    and suv_source.unit_ass_item_id = cp_source_unit_ass_item_id
    and suv_source.ass_id = suv_dest.ass_id
    and suv_source.sequence_number = suv_dest.sequence_number
    and suv_source.person_id = cp_person_id
    and suv_source.course_cd = cp_source_course_cd;


  l_group_name IGS_AS_SUA_AI_GROUP.group_name%TYPE;
  l_rowid VARCHAR2(25);
  l_sua_ass_itemgrp_id IGS_AS_SUA_AI_GROUP.sua_ass_item_group_id%TYPE;
  l_usec_ass_item_id igs_as_su_atmpt_itm.unit_section_ass_item_id%TYPE;
  l_unit_ass_item_id igs_as_su_atmpt_itm.unit_ass_item_id%TYPE;
  l_rowid2 VARCHAR2(25);
  l_dummy NUMBER;

  l_suai_valid BOOLEAN;

BEGIN
  --loop through the assessement item groups for the source unit section
  FOR vc_source_ai_group IN c_source_ai_group(p_person_id,
                                    p_source_course_cd,
                                    p_source_uoo_id) LOOP

     --check if assessment item group exists for the destination unit attempt
     OPEN c_dest_ai_group(p_person_id,p_dest_course_cd,p_dest_uoo_id,vc_source_ai_group.group_name);
     FETCH c_dest_ai_group INTO l_group_name;

     --if the assessment item group does not exist for the destination unit attempt
     IF c_dest_ai_group%NOTFOUND THEN
       CLOSE c_dest_ai_group;

       --Copy the student unit attempt assessment item groups from the source to the destination
       l_rowid := NULL;
       igs_as_sua_ai_group_pkg.insert_row (
    x_rowid                             => l_rowid,
    x_sua_ass_item_group_id             => l_sua_ass_itemgrp_id,
    x_person_id                         => vc_source_ai_group.person_id,
    x_course_cd                         => p_dest_course_cd,
    x_uoo_id                            => p_dest_uoo_id,
    x_group_name                        => vc_source_ai_group.group_name,
    x_midterm_formula_code              => vc_source_ai_group.midterm_formula_code,
    x_midterm_formula_qty               => vc_source_ai_group.midterm_formula_qty,
    x_midterm_weight_qty                => vc_source_ai_group.midterm_weight_qty,
    x_final_formula_code                => vc_source_ai_group.final_formula_code,
    x_final_formula_qty                 => vc_source_ai_group.final_formula_qty,
    x_final_weight_qty                  => vc_source_ai_group.final_weight_qty,
    x_unit_ass_item_group_id            => vc_source_ai_group.unit_ass_item_group_id,
    x_us_ass_item_group_id              => vc_source_ai_group.us_ass_item_group_id,
    x_logical_delete_date               => vc_source_ai_group.logical_delete_date,
    x_mode                              => 'R');

    --loop through the the assessement items under the group
    FOR vc_source_su_itm IN c_source_su_itm (p_person_id ,
                        p_source_course_cd ,
                        p_source_uoo_id ,
                        vc_source_ai_group.sua_ass_item_group_id ) LOOP
    -- smaddali modified the default values for these 2 variables for bug#4701301
     l_usec_ass_item_id := NULL;
     l_unit_ass_item_id := NULL;
     l_suai_valid := FALSE;
      --Check if the assessment type for the source is compatible with the destination
      IF p_source_uoo_id = p_dest_uoo_id THEN
         -- smaddali modified the default values for these 2 variables for bug#4701301
         l_usec_ass_item_id := vc_source_su_itm.unit_section_ass_item_id;
         l_unit_ass_item_id := vc_source_su_itm.unit_ass_item_id;
        l_suai_valid := TRUE;
      ELSE

	  -- the assessment item could be set up at two level one in psp and one in records
	  -- Depending on the results of this cursor  c_usec_level further validation have to
	  -- be performed.

        OPEN c_usec_level(p_person_id, p_dest_course_cd, p_dest_uoo_id);
        FETCH c_usec_level INTO l_dummy;
        CLOSE c_usec_level;

        IF l_dummy <> 0 THEN
              OPEN c_usec_ass_itm  (vc_source_su_itm.unit_section_ass_item_id ,
                               p_dest_uoo_id);
              FETCH c_usec_ass_itm INTO l_usec_ass_item_id;

              IF c_usec_ass_itm%FOUND THEN
                l_suai_valid := TRUE;
              ELSE
                l_suai_valid := FALSE;
              END IF;
              CLOSE c_usec_ass_itm;
        ELSE
              OPEN c_unit_ass_itm  (p_person_id , p_source_course_cd,vc_source_su_itm.unit_ass_item_id,
                        p_dest_course_cd , p_dest_uoo_id);
              FETCH c_unit_ass_itm INTO l_unit_ass_item_id;
              IF c_unit_ass_itm%FOUND THEN
                l_suai_valid := TRUE;
              ELSE
                l_suai_valid := FALSE;
              END IF;
              CLOSE c_unit_ass_itm;
        END IF;
      END IF;

      IF l_suai_valid THEN
          l_rowid2 := NULL;

          vc_source_su_itm.unit_section_ass_item_id := l_usec_ass_item_id;
          vc_source_su_itm.unit_ass_item_id := l_unit_ass_item_id;

          igs_as_su_atmpt_itm_pkg.insert_row (
           x_rowid                        => l_rowid2,
           x_person_id                    => p_person_id,
           x_course_cd                    => p_dest_course_cd,
           x_unit_cd                      => vc_source_su_itm.unit_cd,
           x_cal_type                     => vc_source_su_itm.cal_type,
           x_ci_sequence_number           => vc_source_su_itm.ci_sequence_number,
           x_ass_id                       => vc_source_su_itm.ass_id,
           x_creation_dt                  => vc_source_su_itm.creation_dt,
           x_attempt_number               => vc_source_su_itm.attempt_number,
           x_outcome_dt                   => vc_source_su_itm.outcome_dt,
           x_override_due_dt              => vc_source_su_itm.override_due_dt,
           x_tracking_id                  => vc_source_su_itm.tracking_id,
           x_logical_delete_dt            => vc_source_su_itm.logical_delete_dt,
           x_s_default_ind                => vc_source_su_itm.s_default_ind,
           x_ass_pattern_id               => vc_source_su_itm.ass_pattern_id,
           x_mode                         => 'R',
           x_grading_schema_cd            => vc_source_su_itm.grading_schema_cd,
           x_gs_version_number            => vc_source_su_itm.gs_version_number,
           x_grade                        => vc_source_su_itm.grade,
           x_outcome_comment_code         => vc_source_su_itm.outcome_comment_code,
           x_mark                         => vc_source_su_itm.mark,
           x_attribute_category           => vc_source_su_itm.attribute_category,
           x_attribute1                   => vc_source_su_itm.attribute1,
           x_attribute2                   => vc_source_su_itm.attribute2,
           x_attribute3                   => vc_source_su_itm.attribute3,
           x_attribute4                   => vc_source_su_itm.attribute4,
           x_attribute5                   => vc_source_su_itm.attribute5,
           x_attribute6                   => vc_source_su_itm.attribute6,
           x_attribute7                   => vc_source_su_itm.attribute7,
           x_attribute8                   => vc_source_su_itm.attribute8,
           x_attribute9                   => vc_source_su_itm.attribute9,
           x_attribute10                  => vc_source_su_itm.attribute10,
           x_attribute11                  => vc_source_su_itm.attribute11,
           x_attribute12                  => vc_source_su_itm.attribute12,
           x_attribute13                  => vc_source_su_itm.attribute13,
           x_attribute14                  => vc_source_su_itm.attribute14,
           x_attribute15                  => vc_source_su_itm.attribute15,
           x_attribute16                  => vc_source_su_itm.attribute16,
           x_attribute17                  => vc_source_su_itm.attribute17,
           x_attribute18                  => vc_source_su_itm.attribute18,
           x_attribute19                  => vc_source_su_itm.attribute19,
           x_attribute20                  => vc_source_su_itm.attribute20,
           x_uoo_id                       => p_dest_uoo_id,
           x_unit_section_ass_item_id     => vc_source_su_itm.unit_section_ass_item_id, -- this parameter is overriden
           x_unit_ass_item_id             => vc_source_su_itm.unit_ass_item_id,-- this parameter is overriden
           x_sua_ass_item_group_id        => l_sua_ass_itemgrp_id,
           x_midterm_mandatory_type_code  => vc_source_su_itm.midterm_mandatory_type_code,
           x_midterm_weight_qty           => vc_source_su_itm.midterm_weight_qty,
           x_final_mandatory_type_code    => vc_source_su_itm.final_mandatory_type_code,
           x_final_weight_qty             => vc_source_su_itm.final_weight_qty,
           x_submitted_date               => vc_source_su_itm.submitted_date,
           x_waived_flag                  => vc_source_su_itm.waived_flag,
           x_penalty_applied_flag         => vc_source_su_itm.penalty_applied_flag  );

          --delete the assessment item for the source unit attempt
           IF (p_delete_source = TRUE) THEN
            IGS_AS_SU_ATMPT_ITM_PKG.delete_row (x_rowid => vc_source_su_itm.rowid);
           END IF;


      END IF;

    END LOOP;
             --delete the assessment item group for the source unit attempt
	     IF (p_delete_source = TRUE) THEN
		IGS_AS_SUA_AI_GROUP_PKG.DELETE_ROW(x_rowid => vc_source_ai_group.rowid);
	     END IF;

     ELSE
     --the assessment item group exists for the destination unit attempt
       CLOSE c_dest_ai_group;
     END IF;



  END LOOP;

END enrp_ins_suai_trnsfr;

  -- Validate the confirmation of a student unit attempt.
  FUNCTION enrp_val_sua_cnfrm_before_pt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ci_end_dt IN DATE ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_enrolled_dt IN DATE ,
  p_fail_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --amuthu      18-May-2006     Created by copy most of the code from igs_en_Val_sua.enrp_val_sua_cnfrm
  --                            excluding the holds validations.
  -------------------------------------------------------------------------------------------

  BEGIN -- enrp_val_sua_cnfrm
        -- Perform all validations associated with the confirmation of a unit
        -- attempt for a student. This module is a grouping of existing
        -- validation modules.
        -- Performs the following modules:
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_insert;
        --      determine if the student is of the correct status to have
        --      a unit attempt added.
        -- Call IGS_EN_VAL_ENCMB.enrp_val_excld_unit;
        --      determine if the student is currently excluded from the unit.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_advstnd;
        --      determine if the student has already satisfied the unit
        --      through advanced standing.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_intrmt;
        --      determine if the attempt overlaps an existing period of
        --      intermission.
        -- Call IGS_EN_VAL_SUA.enrp_val_coo_loc;
        --      determine if the attempt is in line with students forced
        --      location (if applicable).
        -- Call IGS_EN_VAL_SUA.enrp_val_coo_mode;
        --      determine if the attemt is in line with students forced
        --      mode (if applicable).
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_enr_dt;
        --      validate the enrolled date.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_ci;
        --      validate that the teaching period of the unit is not prior to
        --      the commencement date of the student course attempt.
        -- Call IGS_EN_VAL_SUA.enrp_val_sua_dupl;
        --      determine if the student is already enrolled concurrently in the
        --      unit or has completed the unit with a pass or incomplete result type.
        -- Call IGS_EN_VAL_SUA.resp_val_sua_cnfrm;
        --       validate if attempting to confirm a research unit attempt.
        -- The current set of fail types are:
        -- course       The course isn?t in a correct state. ie.
        --              Discontinued or intermitted for the teaching period.
        -- ENCUMB       Excluded from the unit by either course/unit or person encumbrances
        -- ADVSTAND     Already granted in advanced standing
        -- CROSS        Breaches a cross-element restriction
        -- ENROLDT      Enrolment date invalid
        -- TEACHING     Teaching Period  invalid
        -- DUPLICATE    Already enrolled or completed unit attempt
  DECLARE
        cst_enrolled            CONSTANT VARCHAR2(10) := 'ENROLLED';
        cst_course              CONSTANT VARCHAR2(10) := 'course';
        cst_encumb              CONSTANT VARCHAR2(10) := 'ENCUMB';
        cst_advstand            CONSTANT VARCHAR2(10) := 'ADVSTAND';
        cst_cross               CONSTANT VARCHAR2(10) := 'CROSS';
        cst_enroldt             CONSTANT VARCHAR2(10) := 'ENROLDT';
        cst_teaching            CONSTANT VARCHAR2(10) := 'TEACHING';
        cst_duplicate           CONSTANT VARCHAR2(10) := 'DUPLICATE';
        CURSOR c_sca IS
                SELECT  sca.version_number,
                        sca.coo_id,
                        sca.commencement_dt
                FROM    IGS_EN_STDNT_PS_ATT sca
                WHERE   person_id       = p_person_id AND
                        course_cd       = p_course_cd;
        CURSOR c_sua IS
               SELECT uoo_id
               FROM igs_ps_unit_ofr_opt
               WHERE unit_cd            = p_unit_cd
               AND   version_number     = p_uv_version_number
               AND   cal_type           = p_cal_type
               AND   ci_sequence_number = p_ci_sequence_number
               AND   location_cd        = p_location_cd
               AND   unit_class         = p_unit_class;

        l_uoo_id                igs_en_su_attempt.uoo_id%TYPE;
        v_sca_rec               c_sca%ROWTYPE;
        v_return_val            BOOLEAN  :=  FALSE;
        v_message_name          varchar2(30);
        v_duplicate_course_cd   VARCHAR2(6);
  BEGIN
        -- Set the  :=  message number
        p_message_name := null;
        p_fail_type := NULL;
        OPEN c_sua;
        FETCH c_sua INTO l_uoo_id;
        CLOSE c_sua;
        -- Determine if the student is of the correct status to have a unit attempt
        -- added.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_insert(
                                        p_person_id,
                                        p_course_cd,
                                        cst_enrolled,
                                        v_message_name) THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the attempt overlaps an existing period of intermission.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_intrmt(
                                                p_person_id,
                                                p_course_cd,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                v_message_name) THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
        END IF;
        -- Validate research unit attempt
        IF NOT IGS_EN_VAL_SUA.resp_val_sua_cnfrm(
                                                p_person_id,
                                                p_course_cd,
                                                p_unit_cd,
                                                p_uv_version_number,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                v_message_name ,
                        'N' ) THEN
                p_fail_type := cst_course;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type :=  cst_course;
                p_message_name := v_message_name;
        END IF;
        -- Fetch student course attempt details
        OPEN c_sca;
        FETCH c_sca INTO v_sca_rec;
        CLOSE c_sca;
        -- Determine if the student has already satisfied the unit through advanced
        -- standing.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_advstnd(
                                                p_person_id,
                                                p_course_cd,
                                                v_sca_rec.version_number,
                                                p_unit_cd,
                                                p_uv_version_number,
                                                v_message_name ,
                        'N' ) THEN
                p_fail_type := cst_advstand;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_advstand;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the attempt is in line with students
        -- forced location (if applicable).
        IF NOT IGS_EN_VAL_SUA.enrp_val_coo_loc(
                                        v_sca_rec.coo_id,
                                        p_location_cd,
                                        v_message_name) THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the attempt is in line with students forced mode (if
        -- applicable).
        IF NOT IGS_EN_VAL_SUA.enrp_val_coo_mode(
                                        v_sca_rec.coo_id,
                                        p_unit_class,
                                        v_message_name) THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_cross;
                p_message_name := v_message_name;
        END IF;
        -- Validate the enrolled date.
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_enr_dt(
                                                p_person_id,
                                                p_course_cd,
                                                p_enrolled_dt,
                                                cst_enrolled,
                                                p_ci_end_dt,
                                                v_sca_rec.commencement_dt,
                                                v_message_name ,
                        'N' ) THEN
                p_fail_type := cst_enroldt;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL  THEN
                p_fail_type := cst_enroldt;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the student unit attempt has a teaching period
        -- which is prior to the commencement date of the student course attempt
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_ci(
                                        p_person_id,
                                        p_course_cd,
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        'ENROLLED',
                                        v_sca_rec.commencement_dt,
                                        'F',    -- commencement date is known
                                        v_message_name) THEN
                p_fail_type := cst_teaching;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_teaching;
                p_message_name := v_message_name;
        END IF;
        -- Determine if the student unit attempt already exists as
        -- enrolled or completed with pass or incomplete result
        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_dupl(
                                        p_person_id,
                                        p_course_cd,
                                        p_unit_cd,
                                        p_uv_version_number,
                                        p_cal_type,
                                        p_ci_sequence_number,
                                        cst_enrolled,   -- unit_attempt_status when confirming
                                        v_duplicate_course_cd,
                                        v_message_name,
                                        l_uoo_id) THEN
                p_fail_type := cst_duplicate;
                p_message_name := v_message_name;
                RETURN FALSE;
        END IF;
        IF v_message_name <> NULL THEN
                p_fail_type := cst_duplicate;
                p_message_name := v_message_name;
        END IF;
        -- Return the default value
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                RAISE;
  END;
  END enrp_val_sua_cnfrm_before_pt;



END IGS_EN_GEN_010;

/
