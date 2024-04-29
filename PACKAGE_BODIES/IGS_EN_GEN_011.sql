--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_011
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_011" AS
/* $Header: IGSEN11B.pls 120.14 2006/05/02 23:52:34 ckasu ship $ */
------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created:
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ckasu      17-MAR-2006   Modified Enrp_Prc_Sua_Blk_E_D procedure inorder to pass p_no_assessment_ind  in call to
  --                         igs_ss_en_wrappers.insert_into_enr_worksheet as part of Bug 4590889.
  --rvangala  12-AUG-2005    Bug #4551013. EN320 Build
  --jtmathew   18-Jan-2005   Modified procedure enrpl_upd_sca_coo for HE350 changes
  --jtmathew   05-Nov-2004   Modified procedure enrpl_upd_sca_coo to update associated HESA records when
  --                         running the 'Bulk Program Offering Option Transfer Process' as per bug 3985220
  --ckasu      13-Sep-2004   Modified Enrp_Prc_Sua_Blk_E_D procedure inorder to consider Person step validations in
  --                         Discontinuing and Droping units as part of Bug 3823810.
  --vkarthik   31-Aug-2004   Deny all hold validation added to bulk enrollment/discontinuation job as part of Bug 3823810
  -- ckasu     05-Apr-2004   Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
  --                         call as a part of bug 3544927.

  --rvangala   13-Feb-2004   Bug 3433542. Modified Cursor c_sua in enrp_prc_sua_blk_trn to ensure that students with end_date
  --                         prior to sysdate are not processed
  --rvivekan   1-dec-2003    Bug 3264064 . Changed the message_token to varchar2(2000) for the enrp_val_discont_aus call.
  --rvivekan   22-oct-2003   Placements build#3052438. Added code to sort the usecs based on relation_type. Also added handling
  --                         to enroll subordinates when a superior is enrolled and to drop subordinates when a superior is dropped
  --                         in bulk unit e/d and in bulk unit section transfer.
  --ptandon    06-Oct-2003   Modified the Procedure Enrp_Prc_Sua_Blk_E_D as part of Prevent Dropping Core Units. Enh Bug# 3052432.
  -- rvivekan  3-Aug-2003    Added new parameters to ofr_enrollment_or_waitlist as a part of Bulk Unit Upload Bug#3049009
  -- rvivekan  11-Jul-2003   Added code to set the invoke source apropriately in Enrp_Prc_Sua_Blk_E_D and Enrp_prc_sua_blk_trn Bug 3036949
  --ptandon    03-07-2003    Modified the Procedure Enrp_Prc_Sua_Blk_E_D as per Bug# 3036433
  --svanukur   26-jun-2003    Passing discontinued date with a nvl substitution of sysdate in the call to the update_row api of
  --                          ig_en_su_attmept in case of a "dropped" unit attempt status as part of bug 2898213.
  -- knaraset  19-Jun-2003   Modified enrp_prc_sua_blk_trn as per Build ENCR035 - MUS bulk Unit section transfer, bug 2956146
  -- svenkata   3-Jun-2003   The function ENRP_VAL_COO_CROSS has been removed. All references to this API is removed. Bug# 2829272
  -- sarakshi  27-Feb-2003   Enh#2797116,modified the procedure enrpl_upd_sca_coo ,added delete_flag check in the where clause
  --                         of the cursor c_coo
  --ssawhney   17-feb-2003   Bug : 2758856  : Added the parameter x_external_reference in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW
  -- amuthu    27-Jan-2003   Bug# 2750538 changed p_deny_warn_att to NVL(p_deny_warn_att,l_notification_flag)
  --                         in the call to igs_en_elgbl_program.eval_unit_forced_type
  -- svenkata   7-Jan-2003   Bug#2737263 - Modifications made in enrp_prc_sua_blk_trn to get the Att Typ of the
  --                         Program before the unit is transferred.
  -- pradhakr  30-Dec-2002   Modified the logic to check the Grading Schema while transfering Unit Sections.
  --                         Changes as per bug# 2715516.
  -- svenkata  22-Dec-02     Bug # 2686793 - Added a call to routine igs_en_elgbl_program.eval_unit_forced_type to enforce
  --                         to enforce Attendance Type validations on transferring.Modifications made in enrp_prc_sua_blk_trn.
  -- pradhakr   15-Dec-2002  Changed the call to the update_row and update_row of
  --                         igs_en_su_attempt table to igs_en_sua_api.update_unit_attempt
  --                         and igs_en_sua_api.create_unit_attempt. Changes wrt ENCR031 build.
  --                         Bug#2643207
  --samaresh    02-DEC-2001  Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
  --                         To the function Enrp_Upd_Acai_Accept
  --pradhakr    12/07/2001   Added one parameter p_dcnt_reason_cd in
  --                         the procedure Enrp_prc_sua_enr_ds  as part
  --                         of Enrollment build (Bug # 1832130 )
  --smaddali    1-08-2001      Modified calls to igs_en_su_attempt and
  --                            igs_en_stdnt_ps_att and enrp_get_var_window
  --                            and enrp_get_rec_window , added new columns(Bug # 1832130 )
  --Bayadav     5-sep-2001    Added refernces to column ORG_UNIT_CD incall to
  --                          IGS_EN_SU_ATTEMPT TBH call as a part of bug 1964697
  --nalkumar    5-OCT-2001    Modified the IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW call.
  --                          Added four new parameters to call it as per the Bug# 2027984.
  --Aiyer     10-Oct-2001     Added the column grading schema in all Tbh calls of IGS_EN_SU_ATTEMPT_PKG as a part of the bug 2037897.
  --nalkumar   21-NOV-2001    Modified the IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW call.
  --                          Added key program parameter to call it as per the Bug# 2027984.
  --pradhakr   07-Dec-2001    Added the column deg_aud_detail_id in the
  --                          TBH calls as part of Degree Audit Interface build.
  --                          (Bug# 2033208)
  --svenkata   20-Dec-2001    Added the columns Student_career_transcrit , Student_career_statistics as part of Career Impact
  --                          Part 2 build . Bug #2158626
  -- svenkata  7-JAN-2002     Bug No. 2172405  Standard Flex Field columns have been added
  --                          to table handler procedure calls as part of CCR - ENCR022.
  --Nishikant  30-jan-2002     Added the column session_id  in the Tbh calls of IGS_EN_SU_ATTEMPT_PKG
  --                           as a part of the bug 2172380.
  --cdcruz    18-feb-2002    Bug 2217104 Admit to future term Enhancement,updated tbh call for
  --                         new columns being added to IGS_AD_PS_APPL_INST
  --cdcruz    21-feb-2002    Bug 2231567 Message cleanup activity
  --nshee     29-Aug-2002   Bug 2395510 added 6 columns in IGS_AD_PS_APPL_INST as part of deferments build
  --mesriniv  18-sep-2002   Added a new parameter waitlist_manual_ind in TBH calls of IGS_EN_SU_ATTEMPT
  --                        for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
  --pkpatel   3-OCT-2002    Bug No: 2600842
  --                        Added the parameter x_auth_resp_id in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW in the procedure Enrp_Set_Pen_Expry
  --                        Added the expiry date synchronization logic for table IGS_PE_FUND_EXCL in the procedure Enrp_Set_Pee_Expry
  --ssawhney  09-10-2002    Added the parameter x_auth_resp_id in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW in the procedure Enrp_Set_Pen_Expry
  --                        Added the expiry date synchronization logic for new table IGS_PE_FUND_EXCL in the procedure Enrp_Set_Pee_Expry
  --kkillams  03-10-2002    1)Three New  p_unit_loc_cd, p_unit_class,p_reason parameters are added to Enrp_Prc_Sua_Blk_E_D procedure.
  --                        2)Three New p_enforce_val,p_enroll_method,p_reason parameters are added to Enrp_Prc_Sua_Blk_Trn procedure.
  --                        w.r.t. build Drop Trasfer workflow notification(Bug no: 2599925)
  --svenkata  28-10-2002    Added new parameters to the call of fn eval_min_cp . Enrollment Eligibility and Valdns build - Bug# 2616692.
  --                        Changed the signature of the routine enrpl_upd_sua_uoo to pass details of academic calendar.
  --Nishikant  01NOV2002    SEVIS Build. Enh Bug#2641905.
  --                        The notification flag was being fetched from cursor earlier. now its
  --                        modified to call the function igs_ss_enr_details.get_notification,
  --                        to get the value for it and to make the way common across all the packages.
  --svenkata   20-NOV-2002   Modified the call to the function igs_en_val_sua.enrp_val_sua_discont to add value 'N' for the parameter
  --                         p_legacy. Bug#2661533.
  --bdeviset   11-Apr-2005  Modified cursor c_sca in procedure Enrp_Prc_Sca_Blk_Trn for bug# 3701057
  --sgurusam   29-Jun-2005  EN 317 TD: Imparted object modifications. Added parameter p_calling_obj with value 'JOB'
  --ctyagi     20-SEPT-2005 Modified call to eval_rsv_seat for bug 4362302
  --ckasu      17-MAR-2006   Modified Enrp_Prc_Sua_Blk_E_D procedure inorder to pass p_no_assessment_ind  in call to
  --                         igs_ss_en_wrappers.insert_into_enr_worksheet as part of Bug 5070742.
  --ckasu      02-May-2006     Modified as a part of bug#5191592
  --------------------------------------------------------------------------

TYPE r_sua_typ IS RECORD( unit_cd                 IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                          uv_version_number       IGS_EN_SU_ATTEMPT.version_number%TYPE,
                          location_cd             IGS_EN_SU_ATTEMPT.location_cd%TYPE,
                          unit_class              IGS_EN_SU_ATTEMPT.unit_class%TYPE);
r_sua                     r_sua_typ;
TYPE t_sua_typ IS TABLE OF r_sua%TYPE INDEX BY BINARY_INTEGER;

TYPE suar_record_type IS RECORD (
                        PERSON_ID         IGS_AS_SUA_REF_CDS.PERSON_ID%TYPE,
                        COURSE_CD         IGS_AS_SUA_REF_CDS.COURSE_CD%TYPE,
                        UOO_ID            IGS_AS_SUA_REF_CDS.UOO_ID%TYPE,
                        REFERENCE_CODE_ID IGS_AS_SUA_REF_CDS.REFERENCE_CODE_ID%TYPE,
                        REFERENCE_CD_TYPE IGS_AS_SUA_REF_CDS.REFERENCE_CD_TYPE%TYPE,
                        REFERENCE_CD      IGS_AS_SUA_REF_CDS.REFERENCE_CD%TYPE,
                        APPLIED_COURSE_CD IGS_AS_SUA_REF_CDS.APPLIED_COURSE_CD%TYPE);
TYPE suar_table_type IS TABLE OF suar_record_type INDEX BY BINARY_INTEGER;
empty_suar_table suar_table_type;
suar_table       suar_table_type;

FUNCTION enrl_sort_usecs ( p_suat       IN OUT NOCOPY t_sua_typ,
                            p_cal_type   IN igs_ca_inst.cal_type%TYPE,
                            p_ci_seq_num IN igs_ps_unit_ofr_opt.ci_sequence_number%TYPE
                          ) RETURN VARCHAR2 AS
------------------------------------------------------------------
  --Created by  : rvivekan, Oracle IDC
  --Date created:
  --
  --Purpose: to sort the usecs placing superiors before subordinates
  --         units which are neither may appear anywhere in the list
  --         This procedure makes a pass thro in the input table
  --         and keeps adding superior/none usecs to the front (starting from 1,upwards)
  --         while subordinates are added to the rear (starting from p_in_suat.count,downwards)
  --         of the l_out_suat table and then returning the l_out_suat table back.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
---------------------------------------------------------------------
CURSOR c_rel_type    (cp_unit_cd          igs_ps_unit_ofr_opt.unit_cd%TYPE,
                      cp_ver_num          igs_ps_unit_ofr_opt.version_number%TYPE,
                      cp_cal_type         igs_ps_unit_ofr_opt.cal_type%TYPE,
                      cp_ci_seq_num       igs_ps_unit_ofr_opt.ci_sequence_number%TYPE,
                      cp_unit_class       igs_ps_unit_ofr_opt.unit_class%TYPE,
                      cp_location_cd      igs_ps_unit_ofr_opt.location_cd%TYPE)IS
SELECT uoo_id, relation_type
FROM igs_ps_unit_ofr_opt
WHERE unit_cd            = cp_unit_cd
AND   version_number     = cp_ver_num
AND   cal_type           = cp_cal_type
AND   ci_sequence_number = cp_ci_seq_num
AND   unit_class         = cp_unit_class
AND   location_cd        = cp_location_cd;

l_sup_head NUMBER:=1;
l_sub_tail NUMBER;
l_last     NUMBER;
l_rel_type VARCHAR2(100);
l_out_stat t_sua_typ;
l_uoo_id   NUMBER;
l_uoo_ids  VARCHAR2(2000);

BEGIN
  l_last:=p_suat.last;
  l_sub_tail:=p_suat.count;
  IF l_sub_tail=0 THEN
   RETURN  NULL;
  END IF;
  FOR i IN p_suat.first..l_last LOOP
    OPEN c_rel_type (p_suat(i).unit_cd,p_suat(i).uv_version_number,p_cal_type,p_ci_seq_num,
                     p_suat(i).unit_class,p_suat(i).location_Cd);
    FETCH c_rel_type INTO l_uoo_id,l_rel_type;
    IF l_rel_type ='SUBORDINATE' THEN
      l_out_stat(l_sub_tail):=p_suat(i);
      l_sub_tail:=l_sub_tail-1;
    ELSE
      l_out_stat(l_sup_head):=p_suat(i);
      l_sup_head:=l_sup_head+1;
    END IF;
    CLOSE c_rel_type;
    l_uoo_ids:=l_uoo_ids||','||l_uoo_id;
  END LOOP;
  p_suat:=l_out_stat;
  RETURN SUBSTR(l_uoo_ids,2); --ignore the leading comma
END enrl_sort_usecs;


/* who          when            what
vkarthik        8-Dec-2003  As part of term record bug no: 2829263 1) added two
                            more parameters p_term_cal_type, p_term_sequence_number and
                            they are used to set spat.g_spa_term_cal_type and spat.g_spa_term_source
                            2) spat.g_spa_term_source is set to 'JOB'
stutta          3-Nov-2004  Added new parameter for p_course_attempt_status6 and modified c_sca
                            correspondingly for Program offering options change bug#3959306
bdeviset        11-Apr-2005 Modified cursor c_sca for bug# 3701057
*/
PROCEDURE Enrp_Prc_Sca_Blk_Trn(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number  NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_group_id IN NUMBER ,
  p_course_attempt_status1 IN VARCHAR2 ,
  p_course_attempt_status2 IN VARCHAR2 ,
  p_course_attempt_status3 IN VARCHAR2 ,
  p_course_attempt_status4 IN VARCHAR2 ,
  p_course_attempt_status5 IN VARCHAR2 ,
  p_course_attempt_status6 IN VARCHAR2 ,
  p_to_acad_cal_type IN VARCHAR2 ,
  p_to_crs_version_number IN NUMBER ,
  p_to_location_cd IN VARCHAR2 ,
  p_to_attendance_type IN VARCHAR2 ,
  p_to_attendance_mode IN VARCHAR2 ,
  p_term_cal_type IN VARCHAR2,
  p_term_sequence_number IN NUMBER,
  p_creation_dt IN OUT NOCOPY DATE )
AS

BEGIN   -- enrp_prc_sca_blk_trn
        -- The process transfers already enrolled (or unconfirmed) students
        -- between offering options within their selected course code. This
        -- may include a change to version_number, calendar type, IGS_AD_LOCATION
        -- code, attendance mode, attendance type or a combination thereof.
        -- This is typically used as the result of the shutting of a version,
        -- or the altering of the course offerings of the IGS_OR_INSTITUTION. eg. a
        -- course which due to lack of numbers is no longer offered at a
        -- campus ? all of the students which are enrolled need be transferred
        -- to a different campus.
        -- IGS_GE_NOTE: This module will be called from an exception report ENRR4420.

DECLARE
        e_resource_busy_exception               EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
        cst_enr_blk_co          CONSTANT VARCHAR2(10) := 'ENR-BLK-CO';
        cst_error               CONSTANT VARCHAR2(10) := 'ERROR';
        cst_information         CONSTANT VARCHAR2(12) := 'INFORMATION';
        cst_warning             CONSTANT VARCHAR2(10) := 'WARNING';
        cst_summary             CONSTANT VARCHAR2(10) := 'SUMMARY';
        cst_cross               CONSTANT VARCHAR2(10) := 'CROSS';
        cst_active              CONSTANT VARCHAR2(10) := 'ACTIVE';
        cst_blk_coo             CONSTANT        VARCHAR2 (36)  := 'BULK COURSE OFFERING OPTION TRANSFER';
        CURSOR c_sca IS
                SELECT  sca.person_id,
                        sca.course_cd,
                        sca.version_number,
                        sca.location_cd,
                        sca.attendance_mode,
                        sca.attendance_type,
                        sca.course_attempt_status,
                        sca.commencement_dt,
                        sca.coo_id,
                        sca.funding_source
                FROM    igs_en_stdnt_ps_att    sca
                WHERE
                        sca.course_cd          =      p_course_cd
                                                          AND
                                                                                         ((sca.person_id in (select person_id from IGS_PE_PRSID_GRP_MEM WHERE
                                                                                                                                                                                                 group_id  = p_group_id) AND
                                                                                                                                 p_group_id is NOT NULL) OR
                                                                                                                (p_group_id is NULL))
                                                                AND
                        (p_version_number  IS NULL OR
                        p_version_number =  igs_en_spa_terms_api.get_spat_program_version
                                                        (sca.person_id,  sca.course_cd, p_term_cal_type, p_term_sequence_number)) AND
                        (p_acad_cal_type  =  igs_en_spa_terms_api.get_spat_acad_cal_type
                                                        (sca.person_id,  sca.course_cd, p_term_cal_type, p_term_sequence_number)) AND
                        (p_location_cd    IS NULL OR
                                p_location_cd    =  igs_en_spa_terms_api.get_spat_location
                                                        (sca.person_id,  sca.course_cd, p_term_cal_type, p_term_sequence_number)) AND
                        (p_attendance_mode IS NULL OR
                                p_attendance_mode=  igs_en_spa_terms_api.get_spat_att_mode
                                                        (sca.person_id,  sca.course_cd, p_term_cal_type, p_term_sequence_number)) AND
                        (p_attendance_type IS NULL OR
                                p_attendance_type=  igs_en_spa_terms_api.get_spat_att_type
                                                        (sca.person_id,  sca.course_cd, p_term_cal_type, p_term_sequence_number)) AND
                        sca.course_attempt_status  IN (
                                p_course_attempt_status1,
                                NVL(p_course_attempt_status2,  p_course_attempt_status1),
                                NVL(p_course_attempt_status3,  p_course_attempt_status1),
                                NVL(p_course_attempt_status4,  p_course_attempt_status1),
                                NVL(p_course_attempt_status5,  p_course_attempt_status1),
                                NVL(p_course_attempt_status6,  p_course_attempt_status1))
                ORDER BY
                        sca.person_id,
                        sca.course_cd;

        v_rollback_occurred     BOOLEAN := FALSE;
        v_processing_occurred   BOOLEAN :=FALSE;
        v_course_key            VARCHAR2(255) ;
        v_creation_dt           IGS_GE_S_LOG.creation_dt%TYPE ;
        v_total_sca_count                       NUMBER := 0;
        v_total_sca_error_count                 NUMBER := 0;
        v_total_sca_warn_count                  NUMBER := 0;
        v_total_sca_trnsfr_count                NUMBER := 0;
        v_total_course_error_count              NUMBER := 0;
        v_total_course_warn_count               NUMBER := 0;
        v_total_lock_count                      NUMBER := 0;
        v_sca_error_count                       NUMBER := 0;
        v_sca_warn_count                        NUMBER := 0;
        v_sca_trnsfr_count                      NUMBER := 0;
        v_to_acad_cal_type              IGS_EN_STDNT_PS_ATT.cal_type%TYPE ;
        v_to_crs_version_number
                                        IGS_EN_STDNT_PS_ATT.version_number%TYPE ;
        v_to_location_cd                IGS_EN_STDNT_PS_ATT.location_cd%TYPE ;
        v_to_attendance_type            IGS_EN_STDNT_PS_ATT.attendance_type%TYPE ;
        v_to_attendance_mode            IGS_EN_STDNT_PS_ATT.attendance_mode%TYPE ;
        PROCEDURE enrpl_upd_sca_coo(
                p_person_id                     IGS_PE_PERSON.person_id%TYPE,
                p_course_cd                     IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                p_crv_version_number            IGS_EN_STDNT_PS_ATT.version_number%TYPE,
                p_cal_type                      IGS_CA_INST.cal_type%TYPE,
                p_acad_ci_sequence_number       IGS_CA_INST.sequence_number%TYPE,
                p_location_cd                   IGS_EN_STDNT_PS_ATT.location_cd%TYPE,
                p_attendance_type               IGS_EN_STDNT_PS_ATT.attendance_type%TYPE,
                p_attendance_mode               IGS_EN_STDNT_PS_ATT.attendance_mode%TYPE,
                p_funding_source                IGS_EN_STDNT_PS_ATT.funding_source%TYPE,
                p_course_attempt_status         IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE,
                p_to_crs_version_number         IGS_EN_STDNT_PS_ATT.version_number%TYPE,
                p_to_acad_cal_type              IGS_EN_STDNT_PS_ATT.cal_type%TYPE,
                p_to_location_cd                IGS_EN_STDNT_PS_ATT.location_cd%TYPE,
                p_to_attendance_type            IGS_EN_STDNT_PS_ATT.attendance_type%TYPE,
                p_to_attendance_mode            IGS_EN_STDNT_PS_ATT.attendance_mode%TYPE,
                p_sca_error_count               IN OUT NOCOPY  NUMBER,
                p_sca_warn_count                IN OUT NOCOPY  NUMBER,
                p_sca_trnsfr_count              IN OUT NOCOPY  NUMBER)
        AS


         /****************************************************************************
           History
             Who      When                   Why
         sarakshi 16-Nov-2004          Enh#4000939, added column FUTURE_DATED_TRANS_FLAG in the update row call of IGS_EN_STDNT_PS_ATT_PKG
             ckasu    05-Apr-2004          Modified IGS_EN_STDNT_PS_ATT_Pkg.update_Row procedure
                                           call as a part of bug 3544927.
             stutta   03-Nov-2004          Added call igs_en_val_sca.enrp_val_chgo_alwd to log a
                                           warning message. bug#3959306
             jtmathew 05-Nov-2004          Modifications as per HESA DLD for bug 3985220
         *****************************************************************************/
        BEGIN   -- enrpl_upd_sca_coo
                -- Local procedure to process the transfer of course offering option.
          DECLARE
                CURSOR c_coo IS
                        SELECT  coo.coo_id
                        FROM    IGS_PS_OFR_OPT  coo
                        WHERE   coo.course_cd           = p_course_cd AND
                                coo.version_number      = p_to_crs_version_number AND
                                coo.cal_type            = p_to_acad_cal_type AND
                                coo.location_cd         = p_to_location_cd AND
                                coo.attendance_type     = p_to_attendance_type AND
                                coo.attendance_mode     = p_to_attendance_mode AND
                                coo.delete_flag         = 'N';
                v_coo_rec       c_coo%ROWTYPE;
                CURSOR c_cv IS
                        SELECT  cs.s_course_status,
                                cv.expiry_dt
                        FROM    IGS_PS_VER      cv,
                                IGS_PS_STAT     cs
                        WHERE   cv.course_cd            = p_course_cd AND
                                cv.version_number       = p_to_crs_version_number AND
                                cs.COURSE_STATUS        = cv.COURSE_STATUS;
                v_cv_rec        c_cv%ROWTYPE;
                CURSOR c_susa IS
                        SELECT  susa.unit_set_cd,
                                susa.us_version_number
                        FROM    IGS_AS_SU_SETATMPT      susa
                        WHERE   susa.person_id                  = p_person_id AND
                                susa.course_cd                  = p_course_cd AND
                                susa.student_confirmed_ind      = 'Y' AND
                                susa.end_dt                     IS NULL;
                -- modified cursor for perf bug 3696293 : sql id : 14791636
                CURSOR c_coousv (
                        cp_unit_set_cd          IGS_PS_OFR_OPT_UNIT_SET_V.unit_set_cd%TYPE,
                        cp_us_version_number    IGS_PS_OFR_OPT_UNIT_SET_V.us_version_number%TYPE,
                        cp_coo_id               IGS_PS_OFR_OPT_UNIT_SET_V.coo_id%TYPE) IS
                        SELECT   'x' FROM
                              IGS_PS_OFR_UNIT_SET cous,
                              IGS_PS_OFR_OPT coo
                        WHERE
                              cous.unit_set_cd              = cp_unit_set_cd  and
                              cous.us_version_number        = cp_us_version_number and
                              coo.coo_id                   =  cp_coo_id and
                              coo.course_cd = cous.course_cd and
                              coo.version_number = cous.crv_version_number and
                              coo.CAL_TYPE = cous.CAL_TYPE and
                       NOT EXISTS (select course_cd from IGS_PS_OF_OPT_UNT_ST coous
                                  where
                                       coous.course_cd = cous.course_cd and
                                       coous.crv_version_number = cous.crv_version_number and
                                       coous.CAL_TYPE = cous.CAL_TYPE and
                                       coous.unit_set_cd = cous.unit_set_cd and
                                       coous.us_version_number = cous.us_version_number)
                      UNION ALL
                      SELECT 'x' FROM
                             IGS_PS_OF_OPT_UNT_ST coous
                        WHERE
                             coous.unit_set_cd              = cp_unit_set_cd and
                             coous.us_version_number        = cp_us_version_number and
                             coous.coo_id                   = cp_coo_id ;

                v_coousv_exists         VARCHAR2(1);
                CURSOR c_sca_upd IS
                        SELECT  rowid,IGS_EN_STDNT_PS_ATT.*
                        FROM    IGS_EN_STDNT_PS_ATT
                        WHERE   person_id = p_person_id AND
                                course_cd = p_course_cd
                        FOR UPDATE OF
                                        version_number,
                                        cal_type,
                                        location_cd,
                                        attendance_type,
                                        attendance_mode,
                                        coo_id NOWAIT;
                v_sca_upd_exists        VARCHAR2(1);
                --  Cursor added as per the HESA DLD  Bug 3985220
                --  Get the hesa program attempt details for update
                CURSOR c_he_spa_upd IS
                        SELECT spa.rowid , spa.*
                        FROM igs_he_st_spa_all spa
                        WHERE spa.person_id = p_person_id AND
                        spa.course_cd  = p_course_cd
                        FOR UPDATE NOWAIT;

                v_key                   VARCHAR2(255) ;
                v_update_coo            BOOLEAN := TRUE;
                v_exit_proc             BOOLEAN := FALSE;
                v_ret_dummy             BOOLEAN ;       --dummy variable
                v_message_name          Varchar2(30) ;
                v_message VARCHAR2(80);
                v_message_name1                 Varchar2(30) ;
                v_message_name2                 Varchar2(30) ;
                v_message_name3                 Varchar2(30) ;
                                l_message_name VARCHAR2(200);
          BEGIN
                -- Initialise the counters.
                p_sca_error_count := 0;
                p_sca_warn_count := 0;
                p_sca_trnsfr_count := 0;
                v_key := TO_CHAR(p_person_id) || '|' ||
                        p_course_cd || '|' ||
                        p_acad_cal_type || '|' ||
                        TO_CHAR(p_crv_version_number) || '|' ||
                        p_location_cd || '|' ||
                        p_attendance_type || '|' ||
                        p_attendance_mode || '|' ||
                        p_to_acad_cal_type || '|' ||
                        TO_CHAR(p_to_crs_version_number) || '|' ||
                        p_to_location_cd || '|' ||
                        p_to_attendance_type || '|' ||
                        p_to_attendance_mode;
                -- Validate that the course offering option exists.
                OPEN c_coo;
                FETCH c_coo INTO v_coo_rec;
                IF c_coo%NOTFOUND THEN
                        CLOSE c_coo;
                        -- Log error, unable to transfer student course attempt
                        -- option as the course option is not offered.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_co,
                                        cst_blk_coo,
                                        v_key,
                                        'IGS_EN_POO_NOT_EXISTS', -- Failed to transfer as option does not exist.
                                        cst_error || '|NO-COO');
                        p_sca_error_count := p_sca_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                END IF;
                CLOSE c_coo;
                -- Validate that the course version is allowable for transfers.
                OPEN c_cv;
                FETCH c_cv INTO v_cv_rec;
                CLOSE c_cv;
                IF v_cv_rec.s_course_status <> cst_active THEN
                        -- Log error, unable to transfer student course attempt
                        -- option as the course version is not active.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_co,
                                        cst_blk_coo,
                                        v_key,
                                        'IGS_EN_FAIL_TRNS_POO_INACTIVE', -- Failed to transfer as course version not active.
                                        cst_error || '|ACTIVE-CRV');
                        p_sca_error_count := p_sca_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                END IF;
                -- Check that the new course version is offered (expiry date null).
                -- If not null then check if the student is not transferring out NOCOPY of
                -- the version or the calendar type as this is considered a major
                -- change and is not allowed within this process.
                IF v_cv_rec.expiry_dt IS NOT NULL AND
                  (p_crv_version_number <> p_to_crs_version_number OR  p_acad_cal_type <> p_to_acad_cal_type) THEN
                        -- Log error, unable to transfer student course attempt option
                        -- as the course version expiry date set and student
                        -- transferring into another version and calendar type.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_co,
                                        cst_blk_coo,
                                        v_key,
                                        'IGS_EN_FAIL_TRNS_POO_EXPDT', -- Failed to transfer as course version expiry date set.
                                        cst_error || '|CRV-EXPIRED');
                        p_sca_error_count := p_sca_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                END IF; -- expiry date not null.
                v_update_coo := TRUE;
                -- If changing the calendar type
                IF p_acad_cal_type <> p_to_acad_cal_type THEN
                        -- Check if there is any enrolled/unconfirmed IGS_PS_UNIT attempt that
                        -- is not linked to the new academic period. (IGS_GE_NOTE: Routine
                        -- returns warnings only.)
                        v_ret_dummy := IGS_EN_VAL_SCA.enrp_val_sca_cat(
                                                        p_person_id,
                                                        p_course_cd,
                                                        p_to_acad_cal_type,
                                                        v_message_name);
                        IF v_message_name is not null THEN

                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                cst_enr_blk_co,
                                                cst_blk_coo,
                                                v_key,
                                                v_message_name,
                                                cst_warning || '|UNIT-ACAD');
                                p_sca_warn_count := p_sca_warn_count + 1;
                        END IF;
                        -- Check if the student is pre-enrolled in an enrolment calendar within the
                        -- new academic calendar. Get the latest enrolment record.
                        -- Check if the enrolment period of the existing academic type is also
                        -- a subordinate of the new academic type.
                        IF NOT IGS_EN_VAL_SCT.enrp_val_scae_acad(
                                                        p_person_id,
                                                        p_course_cd,
                                                        p_to_acad_cal_type,
                                                        v_message_name) THEN
                                IF v_message_name <> 'IGS_EN_NO_SPA_ENR_EXISTS' THEN

                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                        cst_enr_blk_co,
                                                        cst_blk_coo,
                                                        v_key,
                                                        'IGS_EN_STUD_NOT_PRE_ENROLLED', -- warn pre-enrolment may be necessary.
                                                        cst_warning || '|PRE-ENROL');
                                        p_sca_warn_count := p_sca_warn_count + 1;
                                END IF;
                        END IF;
                END IF;
                -- If the version number has been changed.
                IF p_crv_version_number <> p_to_crs_version_number AND
                                p_funding_source IS NOT NULL AND
                                NOT IGS_EN_VAL_SCA.enrp_val_sca_fs(
                                                        p_course_cd,
                                                        p_to_crs_version_number,
                                                        p_funding_source,
                                                        v_message_name) THEN

                        -- Log error, unable to transfer student course attempt option as
                        -- the course version is not active.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_co,
                                        cst_blk_coo,
                                        v_key,
                                        v_message_name, -- Failed to transfer as invalid funding source.
                                        cst_error || '|FUND-CRV');
                        p_sca_error_count := p_sca_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                END IF; -- version number changed.
                IF p_course_attempt_status <> 'UNCONFIRM' THEN
                        -- Check if any IGS_PS_UNIT sets are not permitted within the new course
                        -- offering option. If so, report error.
                        FOR v_susa_rec IN c_susa LOOP
                                -- Check if the IGS_PS_UNIT set allowed in the IGS_PS_OFR_OPT.
                                OPEN c_coousv(
                                        v_susa_rec.unit_set_cd,
                                        v_susa_rec.us_version_number,
                                        v_coo_rec.coo_id);
                                FETCH c_coousv INTO v_coousv_exists;
                                IF c_coousv%NOTFOUND THEN
                                        CLOSE c_coousv;

                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                        cst_enr_blk_co,
                                                        cst_blk_coo,
                                                        v_key,
                                                        'IGS_EN_SU_SETATT_EXISTS',
                                                        -- Failed to transfer as IGS_PS_UNIT sets exist that are
                                                        -- not applicable to the new course offering option.
                                                        cst_error || '|CRV-UNIT-SET');
                                        p_sca_error_count := p_sca_error_count + 1;
                                        -- Exit from the local procedure
                                        v_exit_proc := TRUE;
                                        EXIT;
                                END IF;
                                CLOSE c_coousv;
                        END LOOP; -- IGS_AS_SU_SETATMPT.
                END IF; -- status is not unconfirmed.
                IF v_exit_proc THEN
                        RETURN;
                END IF;
                -- Validate whether any of the students IGS_PS_UNIT attempts for the nominated
                -- academic calendar instance have breached cross IGS_AD_LOCATION or cross mode
                -- rules.
                IF p_course_attempt_status = 'ENROLLED' AND
                                NOT IGS_EN_VAL_SCA.enrp_val_sua_coo(
                                                        p_person_id,
                                                        p_course_cd,
                                                        v_coo_rec.coo_id,
                                                        p_to_acad_cal_type,
                                                        p_acad_ci_sequence_number,
                                                        v_message_name1,
                                                        v_message_name2,
                                                        v_message_name3,
                                                        p_term_cal_type,
                                                        p_term_sequence_number) THEN

                        IF v_message_name1 is not null THEN
                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                cst_enr_blk_co,
                                                cst_blk_coo,
                                                v_key,
                                                v_message_name1,
                                                cst_warning || '|' || cst_cross);
                                p_sca_warn_count := p_sca_warn_count + 1;
                        END IF;
                        IF v_message_name2 is not null THEN
                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                cst_enr_blk_co,
                                                cst_blk_coo,
                                                v_key,
                                                v_message_name2,
                                                cst_warning || '|' || cst_cross);
                                p_sca_warn_count := p_sca_warn_count + 1;
                        END IF;
                        IF v_message_name3 is not null THEN
                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                cst_enr_blk_co,
                                                cst_blk_coo,
                                                v_key,
                                                v_message_name3,
                                                cst_warning || '|' || cst_cross);
                                p_sca_warn_count := p_sca_warn_count + 1;
                        END IF;
                END IF; -- If enrolled.
                FOR v_sca_upd_exists In c_sca_upd LOOP
                        -- Update the record.
                         IGS_EN_STDNT_PS_ATT_PKG.UPDATE_ROW(
                                                 X_ROWID => v_sca_upd_exists.rowid,
                                                 X_PERSON_ID  => v_sca_upd_exists.PERSON_ID,
                                                 X_COURSE_CD => v_sca_upd_exists.COURSE_CD,
                                                 X_ADVANCED_STANDING_IND => v_sca_upd_exists.ADVANCED_STANDING_IND,
                                                 X_FEE_CAT => v_sca_upd_exists.FEE_CAT,
                                                 X_CORRESPONDENCE_CAT => v_sca_upd_exists.CORRESPONDENCE_CAT,
                                                 X_SELF_HELP_GROUP_IND => v_sca_upd_exists.SELF_HELP_GROUP_IND,
                                                 X_LOGICAL_DELETE_DT  => v_sca_upd_exists.LOGICAL_DELETE_DT,
                                                 X_ADM_ADMISSION_APPL_NUMBER  => v_sca_upd_exists.ADM_ADMISSION_APPL_NUMBER,
                                                 X_ADM_NOMINATED_COURSE_CD => v_sca_upd_exists.ADM_NOMINATED_COURSE_CD,
                                                 X_ADM_SEQUENCE_NUMBER  => v_sca_upd_exists.ADM_SEQUENCE_NUMBER,
                                                 X_VERSION_NUMBER  => p_to_crs_version_number,
                                                 X_CAL_TYPE => p_to_acad_cal_type,
                                                 X_LOCATION_CD => p_to_location_cd,
                                                 X_ATTENDANCE_MODE => p_to_attendance_mode,
                                                 X_ATTENDANCE_TYPE => p_to_attendance_type,
                                                 X_COO_ID  => v_coo_rec.coo_id,
                                                 X_STUDENT_CONFIRMED_IND => v_sca_upd_exists.STUDENT_CONFIRMED_IND,
                                                 X_COMMENCEMENT_DT  => v_sca_upd_exists.COMMENCEMENT_DT,
                                                 X_COURSE_ATTEMPT_STATUS => v_sca_upd_exists.COURSE_ATTEMPT_STATUS,
                                                 X_PROGRESSION_STATUS => v_sca_upd_exists.PROGRESSION_STATUS,
                                                 X_DERIVED_ATT_TYPE => v_sca_upd_exists.DERIVED_ATT_TYPE,
                                                 X_DERIVED_ATT_MODE => v_sca_upd_exists.DERIVED_ATT_MODE,
                                                 X_PROVISIONAL_IND => v_sca_upd_exists.PROVISIONAL_IND,
                                                 X_DISCONTINUED_DT  => v_sca_upd_exists.DISCONTINUED_DT,
                                                 X_DISCONTINUATION_REASON_CD => v_sca_upd_exists.DISCONTINUATION_REASON_CD,
                                                 X_LAPSED_DT  => v_sca_upd_exists.LAPSED_DT,
                                                 X_FUNDING_SOURCE => v_sca_upd_exists.EXAM_LOCATION_CD,
                                                 X_EXAM_LOCATION_CD => v_sca_upd_exists.EXAM_LOCATION_CD,
                                                 X_DERIVED_COMPLETION_YR  => v_sca_upd_exists.DERIVED_COMPLETION_YR,
                                                 X_DERIVED_COMPLETION_PERD => v_sca_upd_exists.DERIVED_COMPLETION_PERD,
                                                 X_NOMINATED_COMPLETION_YR  => v_sca_upd_exists.NOMINATED_COMPLETION_YR,
                                                 X_NOMINATED_COMPLETION_PERD => v_sca_upd_exists.NOMINATED_COMPLETION_PERD,
                                                 X_RULE_CHECK_IND => v_sca_upd_exists.RULE_CHECK_IND,
                                                 X_WAIVE_OPTION_CHECK_IND => v_sca_upd_exists.WAIVE_OPTION_CHECK_IND,
                                                 X_LAST_RULE_CHECK_DT  => v_sca_upd_exists.LAST_RULE_CHECK_DT,
                                                 X_PUBLISH_OUTCOMES_IND => v_sca_upd_exists.PUBLISH_OUTCOMES_IND,
                                                 X_COURSE_RQRMNT_COMPLETE_IND => v_sca_upd_exists.COURSE_RQRMNT_COMPLETE_IND,
                                                 X_COURSE_RQRMNTS_COMPLETE_DT  => v_sca_upd_exists.COURSE_RQRMNTS_COMPLETE_DT,
                                                 X_S_COMPLETED_SOURCE_TYPE => v_sca_upd_exists.S_COMPLETED_SOURCE_TYPE,
                                                 X_OVERRIDE_TIME_LIMITATION  => v_sca_upd_exists.OVERRIDE_TIME_LIMITATION,
                                                 X_MODE                      =>  'R',
                                                 x_last_date_of_attendance   => v_sca_upd_exists.last_date_of_attendance,
                                                 x_dropped_by                => v_sca_upd_exists.dropped_by  ,
                                                 x_igs_pr_class_std_id       => v_sca_upd_exists.igs_pr_class_std_id , --Enhancement Bug 1877222, pmarada
                                                 -- Added next four parameters as per the Career Impact Build Bug# 2027984
                                                 x_primary_program_type      => v_sca_upd_exists.primary_program_type,
                                                 x_primary_prog_type_source  => v_sca_upd_exists.primary_prog_type_source,
                                                 x_catalog_cal_type          => v_sca_upd_exists.catalog_cal_type,
                                                 x_catalog_seq_num           => v_sca_upd_exists.catalog_seq_num,
                                                 x_key_program               => v_sca_upd_exists.key_program,
                                                 -- The following two parameters were added as part of the build EN015. Bug# 2158654 - pradhakr
                                                 x_override_cmpl_dt          => v_sca_upd_exists.override_cmpl_dt,
                                                 x_manual_ovr_cmpl_dt_ind    => v_sca_upd_exists.manual_ovr_cmpl_dt_ind,
                                                 -- added by ckasu as part of bug # 3544927
                                                 X_ATTRIBUTE_CATEGORY                => v_sca_upd_exists.ATTRIBUTE_CATEGORY,
                                                 X_ATTRIBUTE1                        => v_sca_upd_exists.ATTRIBUTE1,
                                                 X_ATTRIBUTE2                        => v_sca_upd_exists.ATTRIBUTE2,
                                                 X_ATTRIBUTE3                        => v_sca_upd_exists.ATTRIBUTE3,
                                                 X_ATTRIBUTE4                        => v_sca_upd_exists.ATTRIBUTE4,
                                                 X_ATTRIBUTE5                        => v_sca_upd_exists.ATTRIBUTE5,
                                                 X_ATTRIBUTE6                        => v_sca_upd_exists.ATTRIBUTE6,
                                                 X_ATTRIBUTE7                        => v_sca_upd_exists.ATTRIBUTE7,
                                                 X_ATTRIBUTE8                        => v_sca_upd_exists.ATTRIBUTE8,
                                                 X_ATTRIBUTE9                        => v_sca_upd_exists.ATTRIBUTE9,
                                                 X_ATTRIBUTE10                       => v_sca_upd_exists.ATTRIBUTE10,
                                                 X_ATTRIBUTE11                       => v_sca_upd_exists.ATTRIBUTE11,
                                                 X_ATTRIBUTE12                       => v_sca_upd_exists.ATTRIBUTE12,
                                                 X_ATTRIBUTE13                       => v_sca_upd_exists.ATTRIBUTE13,
                                                 X_ATTRIBUTE14                       => v_sca_upd_exists.ATTRIBUTE14,
                                                 X_ATTRIBUTE15                       => v_sca_upd_exists.ATTRIBUTE15,
                                                 X_ATTRIBUTE16                       => v_sca_upd_exists.ATTRIBUTE16,
                                                 X_ATTRIBUTE17                       => v_sca_upd_exists.ATTRIBUTE17,
                                                 X_ATTRIBUTE18                       => v_sca_upd_exists.ATTRIBUTE18,
                                                 X_ATTRIBUTE19                       => v_sca_upd_exists.ATTRIBUTE19,
                                                 X_ATTRIBUTE20                       => v_sca_upd_exists.ATTRIBUTE20,
                                                 X_FUTURE_DATED_TRANS_FLAG           => v_sca_upd_exists.FUTURE_DATED_TRANS_FLAG);

                                                igs_en_spa_terms_api.create_update_term_rec(
                                                      p_person_id => v_sca_upd_exists.PERSON_ID,
                                                      p_program_cd => v_sca_upd_exists.COURSE_CD,
                                                      p_term_cal_type => p_term_cal_type,
                                                      p_term_sequence_number => p_term_sequence_number,
                                                      p_coo_id => v_coo_rec.coo_id,
                                                      p_ripple_frwrd => TRUE,
                                                      p_message_name => l_message_name,
                                                      p_update_rec => TRUE);

                        --  Check if the version number has been updated
                        --  and country code is 'GB', as per HESA bug 3985220
                        IF (v_sca_upd_exists.version_number <> p_to_crs_version_number AND
                             fnd_profile.value('OSS_COUNTRY_CODE') = 'GB' ) THEN

                               BEGIN
                                     FOR v_he_spa_upd_rec IN c_he_spa_upd LOOP

                                           -- update the version_number of the hesa program attempt record
                                           IGS_HE_ST_SPA_ALL_PKG.UPDATE_ROW (
                                                X_ROWID                       => v_he_spa_upd_rec.rowid   ,
                                                X_HESA_ST_SPA_ID              => v_he_spa_upd_rec.hesa_st_spa_id  ,
                                                X_ORG_ID                      => v_he_spa_upd_rec.org_id  ,
                                                X_PERSON_ID                   => v_he_spa_upd_rec.person_id  ,
                                                X_COURSE_CD                   => v_he_spa_upd_rec.course_cd  ,
                                                X_VERSION_NUMBER              => p_to_crs_version_number  ,
                                                X_FE_STUDENT_MARKER           => v_he_spa_upd_rec.fe_student_marker  ,
                                                X_DOMICILE_CD                 => v_he_spa_upd_rec.domicile_cd   ,
                                                X_INST_LAST_ATTENDED          => v_he_spa_upd_rec.inst_last_attended  ,
                                                X_YEAR_LEFT_LAST_INST         => v_he_spa_upd_rec.year_left_last_inst  ,
                                                X_HIGHEST_QUAL_ON_ENTRY       => v_he_spa_upd_rec.highest_qual_on_entry  ,
                                                X_DATE_QUAL_ON_ENTRY_CALC     => v_he_spa_upd_rec.date_qual_on_entry_calc  ,
                                                X_A_LEVEL_POINT_SCORE         => v_he_spa_upd_rec.a_level_point_score  ,
                                                X_HIGHERS_POINTS_SCORES       => v_he_spa_upd_rec.highers_points_scores  ,
                                                X_OCCUPATION_CODE             => v_he_spa_upd_rec.occupation_code  ,
                                                X_COMMENCEMENT_DT             => v_he_spa_upd_rec.commencement_dt  ,
                                                X_SPECIAL_STUDENT             => v_he_spa_upd_rec.special_student  ,
                                                X_STUDENT_QUAL_AIM            => v_he_spa_upd_rec.student_qual_aim  ,
                                                X_STUDENT_FE_QUAL_AIM         => v_he_spa_upd_rec.student_fe_qual_aim  ,
                                                X_TEACHER_TRAIN_PROG_ID       => v_he_spa_upd_rec.teacher_train_prog_id  ,
                                                X_ITT_PHASE                   => v_he_spa_upd_rec.itt_phase  ,
                                                X_BILINGUAL_ITT_MARKER        => v_he_spa_upd_rec.bilingual_itt_marker  ,
                                                X_TEACHING_QUAL_GAIN_SECTOR   => v_he_spa_upd_rec.teaching_qual_gain_sector  ,
                                                X_TEACHING_QUAL_GAIN_SUBJ1    => v_he_spa_upd_rec.teaching_qual_gain_subj1  ,
                                                X_TEACHING_QUAL_GAIN_SUBJ2    => v_he_spa_upd_rec.teaching_qual_gain_subj2  ,
                                                X_TEACHING_QUAL_GAIN_SUBJ3    => v_he_spa_upd_rec.teaching_qual_gain_subj3  ,
                                                X_STUDENT_INST_NUMBER         => v_he_spa_upd_rec.student_inst_number  ,
                                                X_DESTINATION                 => v_he_spa_upd_rec.destination  ,
                                                X_ITT_PROG_OUTCOME            => v_he_spa_upd_rec.itt_prog_outcome  ,
                                                X_HESA_RETURN_NAME            => v_he_spa_upd_rec.hesa_return_name   ,
                                                X_HESA_RETURN_ID              => v_he_spa_upd_rec.hesa_return_id  ,
                                                X_HESA_SUBMISSION_NAME        => v_he_spa_upd_rec.hesa_submission_name  ,
                                                X_ASSOCIATE_UCAS_NUMBER       => v_he_spa_upd_rec.associate_ucas_number  ,
                                                X_ASSOCIATE_SCOTT_CAND        => v_he_spa_upd_rec.associate_scott_cand  ,
                                                X_ASSOCIATE_TEACH_REF_NUM     => v_he_spa_upd_rec.associate_teach_ref_num  ,
                                                X_ASSOCIATE_NHS_REG_NUM       => v_he_spa_upd_rec.associate_nhs_reg_num   ,
                                                X_NHS_FUNDING_SOURCE          => v_he_spa_upd_rec.nhs_funding_source  ,
                                                X_UFI_PLACE                   => v_he_spa_upd_rec.ufi_place  ,
                                                X_POSTCODE                    => v_he_spa_upd_rec.postcode   ,
                                                X_SOCIAL_CLASS_IND            => v_he_spa_upd_rec.social_class_ind  ,
                                                X_OCCCODE                     => v_he_spa_upd_rec.occcode  ,
                                                X_TOTAL_UCAS_TARIFF           => v_he_spa_upd_rec.total_ucas_tariff  ,
                                                X_NHS_EMPLOYER                => v_he_spa_upd_rec.nhs_employer   ,
                                                X_RETURN_TYPE                 => v_he_spa_upd_rec.return_type  ,
                                                X_QUAL_AIM_SUBJ1              => v_he_spa_upd_rec.qual_aim_subj1  ,
                                                X_QUAL_AIM_SUBJ2              => v_he_spa_upd_rec.qual_aim_subj2  ,
                                                X_QUAL_AIM_SUBJ3              => v_he_spa_upd_rec.qual_aim_subj3  ,
                                                X_QUAL_AIM_PROPORTION         => v_he_spa_upd_rec.qual_aim_proportion ,
                                                X_DEPENDANTS_CD               => v_he_spa_upd_rec.dependants_cd ,
                                                X_IMPLIED_FUND_RATE           => v_he_spa_upd_rec.implied_fund_rate ,
                                                X_GOV_INITIATIVES_CD          => v_he_spa_upd_rec.gov_initiatives_cd ,
                                                X_UNITS_FOR_QUAL              => v_he_spa_upd_rec.units_for_qual ,
                                                X_DISADV_UPLIFT_ELIG_CD       => v_he_spa_upd_rec.disadv_uplift_elig_cd ,
                                                X_FRANCH_PARTNER_CD           => v_he_spa_upd_rec.franch_partner_cd,
                                                X_UNITS_COMPLETED             => v_he_spa_upd_rec.units_completed,
                                                X_FRANCH_OUT_ARR_CD           => v_he_spa_upd_rec.franch_out_arr_cd,
                                                X_EMPLOYER_ROLE_CD            => v_he_spa_upd_rec.employer_role_cd,
                                                X_DISADV_UPLIFT_FACTOR        => v_he_spa_upd_rec.disadv_uplift_factor,
                                                X_ENH_FUND_ELIG_CD            => v_he_spa_upd_rec.enh_fund_elig_cd,
                                                X_MODE                        => 'R'
                                           ) ;
                                     END LOOP ;
                               EXCEPTION
                               WHEN OTHERS THEN
                                        -- Log error if failed to update SPA HESA details
                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                                cst_enr_blk_co,
                                                                cst_blk_coo,
                                                                v_key,
                                                                'IGS_HE_UPD_SPA_FAIL',
                                                                cst_error || '| CRV-HESA-SPA' );
                                                                p_sca_error_count := p_sca_error_count + 1;
                                        RAISE;
                               END ;

                        END IF ; -- end of change in version and country code check
                        --  End of the New code added as per the HESA bug 3985220

                        IF igs_en_val_sca.enrp_val_chgo_alwd(p_person_id,
                           p_course_cd, v_message) THEN
                          -- if program offering option of a completed program attempt is changed
                          -- then log warning message.
                          IF  v_message IS NOT NULL THEN
                                    IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_co,
                                        cst_blk_coo,
                                        v_key,
                                        'IGS_EN_CHG_OPT_COMPL',
                                        cst_warning || '| COMPLETED');
                         END IF;

                        END IF;

                        -- Log that the IGS_PS_UNIT has been updated.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                cst_enr_blk_co,
                                                cst_blk_coo,
                                                v_key,
                                                'IGS_EN_STUD_SUCCESS_TRNS_POO',  -- Successfully transferred.
                                                cst_information || '| TRANSFERRED');
                        p_sca_trnsfr_count := p_sca_trnsfr_count + 1;
                END LOOP;
                RETURN;
          -- Local exception handler.
          EXCEPTION
                WHEN e_resource_busy_exception THEN
                        -- Roll back transaction.
                        ROLLBACK TO sp_sca_blk_trn;
                        -- Add to count and continue processing.
                        v_total_lock_count := v_total_lock_count + 1;
                        -- Log that a locked record exists and
                        -- rollback has occurred.
                        Fnd_Message.Set_name('IGS','IGS_EN_ALLALT_APPL_STUD_PRG');
                        IGS_GE_MSG_STACK.ADD;
                        RETURN;
                WHEN OTHERS THEN
                        IF c_coo%ISOPEN THEN
                                CLOSE c_coo;
                        END IF;
                        IF c_cv%ISOPEN THEN
                                CLOSE c_cv;
                        END IF;
                        IF c_susa%ISOPEN THEN
                                CLOSE c_susa;
                        END IF;
                        IF c_coousv%ISOPEN THEN
                                CLOSE c_coousv;
                        END IF;
                        IF c_sca_upd%ISOPEN THEN
                                CLOSE c_sca_upd;
                        END IF;
                        RAISE;
          END;
        END enrpl_upd_sca_coo;
  BEGIN
        IGS_GE_INS_SLE.genp_set_log_cntr;
        -- Determine students to be processed.
        FOR v_sca_rec IN c_sca LOOP
                SAVEPOINT sp_sca_blk_trn;
                v_rollback_occurred := FALSE;
                v_processing_occurred := FALSE;
                -- Set the key for the logging of IGS_GE_EXCEPTIONS.
                v_course_key := TO_CHAR(v_sca_rec.person_id) || '|' ||
                                v_sca_rec.course_cd || '|' ||
                                TO_CHAR(v_sca_rec.version_number);
                -- Determine the course offering option that the student course attempt
                -- is to be changed too.
                -- If parameter is null, use the existing values selected for the sua.
                v_to_acad_cal_type := NVL(p_to_acad_cal_type,
                                        p_acad_cal_type);
                v_to_crs_version_number := NVL(p_to_crs_version_number,
                                        v_sca_rec.version_number);
                v_to_location_cd := NVL(p_to_location_cd,
                                        v_sca_rec.location_cd);
                v_to_attendance_type := NVL(p_to_attendance_type,
                                        v_sca_rec.attendance_type);
                v_to_attendance_mode := NVL(p_to_attendance_mode,
                                        v_sca_rec.attendance_mode);
                -- If the IGS_PS_UNIT offering is not being changed,
                -- then skip the IGS_PS_UNIT attempt.
                IF p_acad_cal_type <> v_to_acad_cal_type OR
                                v_sca_rec.version_number <> v_to_crs_version_number OR
                                v_sca_rec.location_cd <> v_to_location_cd OR
                                v_sca_rec.attendance_type <> v_to_attendance_type OR
                                v_sca_rec.attendance_mode <> v_to_attendance_mode THEN
                        enrpl_upd_sca_coo(
                                        v_sca_rec.person_id,
                                        v_sca_rec.course_cd,
                                        v_sca_rec.version_number,
                                        p_acad_cal_type,
                                        p_acad_ci_sequence_number,
                                        v_sca_rec.location_cd,
                                        v_sca_rec.attendance_type,
                                        v_sca_rec.attendance_mode,
                                        v_sca_rec.funding_source,
                                        v_sca_rec.course_attempt_status,
                                        v_to_crs_version_number,
                                        v_to_acad_cal_type,
                                        v_to_location_cd,
                                        v_to_attendance_type,
                                        v_to_attendance_mode,
                                        v_sca_error_count,
                                        v_sca_warn_count,
                                        v_sca_trnsfr_count);
                        -- Add counts to total
                        v_total_sca_error_count := v_total_sca_error_count + v_sca_error_count;
                        v_total_sca_warn_count := v_total_sca_warn_count + v_sca_warn_count;
                        v_total_sca_trnsfr_count := v_total_sca_trnsfr_count + v_sca_trnsfr_count;
                END IF; -- Check if course version/offering being altered.
                -- Add counts to total
                v_total_sca_count := v_total_sca_count + 1;
        END LOOP;
        -- Log the summary counts.
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_co,
                        cst_blk_coo,
                        cst_summary,
                        NULL,
                        'Total program attempts processed|' ||
                                TO_CHAR(v_total_sca_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_co,
                        cst_blk_coo,
                        cst_summary,
                        NULL,
                        'Total errors when transferring program offering option|' ||
                                TO_CHAR(v_total_sca_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_co,
                        cst_blk_coo,
                        cst_summary,
                        NULL,
                        'Total warning when transferring program offering option|' ||
                                TO_CHAR(v_total_sca_warn_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_co,
                        cst_blk_coo,
                        cst_summary,
                        NULL,
                        'Total program offering options transferred|' ||
                                TO_CHAR(v_total_sca_trnsfr_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_co,
                        cst_blk_coo,
                        cst_summary,
                        NULL,
                        'Total locked record errors|' ||
                                TO_CHAR(v_total_lock_count));
        -- Insert the log entries.
        IGS_GE_INS_SLE.genp_ins_sle(
                                v_creation_dt);
        p_creation_dt := v_creation_dt;
        COMMIT;
        RETURN;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                RAISE;
  END;
END enrp_prc_sca_blk_trn;


FUNCTION match_term_sca_params (
                p_sca_person_id         IN      NUMBER,
                p_sca_course_cd         IN      VARCHAR2,
                p_sca_version_number    IN      NUMBER,
                p_sca_attendance_type   IN      VARCHAR2,
                p_sca_attendance_mode   IN      VARCHAR2,
                p_sca_location_cd       IN      VARCHAR2,
                p_para_course_cd        IN      VARCHAR2,
                p_para_version_number   IN      NUMBER,
                p_para_attendance_type  IN      VARCHAR2,
                p_para_attendance_mode  IN      VARCHAR2,
                p_para_location_cd      IN      VARCHAR2,
                p_term_cal_type         IN      VARCHAR2,
                p_term_sequence_number  IN      NUMBER)
        RETURN VARCHAR2 AS
------------------------------------------------------------------------------
  --Created by  : vkarthik, Oracle IDC
  --Date created: 2-Dec-2003
  --
  --Purpose: The function match_term_sca_term(...) takes person_id,
  --course_cd, version_number, attendance_type, attendance_mode, location_cd.
  --If term record exists for the context and if all the not null
  --parameter matches, function returns 'Y' else returns 'N'.  If term record
  --doesn't exist and program attempt record exists for the context and all the
  --not null parameters match, function retunrs 'Y' else returns 'N'

  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
------------------------------------------------------------------------------

        CURSOR c_terms IS
                SELECT attendance_type, attendance_mode, location_cd
                FROM igs_en_spa_terms
                WHERE
                        person_id               =       p_sca_person_id            AND
                        program_cd              =       p_sca_course_cd            AND
                        term_cal_type           =       p_term_cal_type            AND
                        term_sequence_number    =       p_term_sequence_number;

        lc_terms                        c_terms%ROWTYPE;
        l_return_status                 VARCHAR2(1);
        l_para_course_cd                igs_en_spa_terms.program_cd%TYPE;
        l_para_version_number           igs_en_spa_terms.program_version%TYPE;
        l_para_attendance_type          igs_en_spa_terms.attendance_type%TYPE;
        l_para_attendance_mode          igs_en_spa_terms.attendance_mode%TYPE;
        l_para_location_cd              igs_en_spa_terms.location_cd%TYPE;

        BEGIN
                l_return_status  := 'N';
                IF (NVL(p_para_course_cd,'%')='%') THEN
                        l_para_course_cd := NULL;
                ELSE
                      l_para_course_cd := p_para_course_cd ;
                END IF;

                l_para_version_number := p_para_version_number;

                IF (NVL(p_para_attendance_type,'%')='%') THEN
                        l_para_attendance_type := NULL;
                ELSE
                    l_para_attendance_type := p_para_attendance_type;
                END IF;

                IF (NVL(p_para_attendance_mode,'%')='%') THEN
                        l_para_attendance_mode := NULL;
                ELSE
                    l_para_attendance_mode := p_para_attendance_mode;
                END IF;

                IF (NVL(p_para_location_cd,'%')='%') THEN
                        l_para_location_cd := NULL;
                ELSE
                    l_para_location_cd := p_para_location_cd;
                END IF;

                IF (l_para_course_cd        IS NULL     AND
                    l_para_version_number   IS NULL     AND
                    l_para_attendance_type  IS NULL     AND
                    l_para_attendance_mode  IS NULL     AND
                    l_para_location_cd      IS NULL) THEN
                    RETURN 'Y';                 -- if all parameters are NULL return 'Y'
                END IF;

                OPEN c_terms;
                FETCH c_terms INTO lc_terms;

                IF c_terms%FOUND THEN
                        -- term record exists for the context
                        IF  lc_terms.attendance_type = NVL(l_para_attendance_type, lc_terms.attendance_type)   AND
                            lc_terms.attendance_mode = NVL(l_para_attendance_mode, lc_terms.attendance_mode)   AND
                            lc_terms.location_cd     = NVL(l_para_location_cd, lc_terms.location_cd)           THEN
                            l_return_status := 'Y';
                        ELSE
                            l_return_status := 'N';
                        END IF;
                ELSE
                        -- term record doesn't exist for the passed in term
                        IF  p_sca_attendance_type       = NVL(l_para_attendance_type, p_sca_attendance_type)   AND
                            p_sca_attendance_mode       = NVL(l_para_attendance_mode, p_sca_attendance_mode)   AND
                            p_sca_location_cd           = NVL(l_para_location_cd, p_sca_location_cd)           THEN
                            l_return_status := 'Y';
                        ELSE
                            l_return_status := 'N';
                        END IF;
                END IF;

                CLOSE c_terms;
                RETURN l_return_status;
        END match_term_sca_params;


-- modified this procedure for enrollment processes build bug #1832130
-- modified tbh calls ,and moved code by smaddali
PROCEDURE Enrp_Prc_Sua_Blk_E_D(
  p_teach_cal_type             IN VARCHAR2 ,
  p_teach_ci_sequence_number   IN NUMBER ,
  p_course_cd                  IN VARCHAR2 ,
  p_location_cd                IN VARCHAR2 ,
  p_attendance_type            IN VARCHAR2 ,
  p_attendance_mode            IN VARCHAR2 ,
  p_unit_cd                    IN VARCHAR2 ,
  p_uv_version_number          IN NUMBER ,
  p_group_id                   IN NUMBER ,
  p_person_id                  IN NUMBER ,
  p_action1                    IN VARCHAR2 ,
  p_unit_cd1                   IN VARCHAR2 ,
  p_uv_version_number1         IN NUMBER ,
  p_location_cd1               IN VARCHAR2 ,
  p_unit_class1                IN VARCHAR2 ,
  p_action2                    IN VARCHAR2 ,
  p_unit_cd2                   IN VARCHAR2 ,
  p_uv_version_number2         IN NUMBER ,
  p_location_cd2               IN VARCHAR2 ,
  p_unit_class2                IN VARCHAR2 ,
  p_action3                    IN VARCHAR2 ,
  p_unit_cd3                   IN VARCHAR2 ,
  p_uv_version_number3         IN NUMBER ,
  p_location_cd3               IN VARCHAR2 ,
  p_unit_class3                IN VARCHAR2 ,
  p_action4                    IN VARCHAR2 ,
  p_unit_cd4                   IN VARCHAR2 ,
  p_uv_version_number4         IN NUMBER ,
  p_location_cd4               IN VARCHAR2 ,
  p_unit_class4                IN VARCHAR2 ,
  p_action5                    IN VARCHAR2 ,
  p_unit_cd5                   IN VARCHAR2 ,
  p_uv_version_number5         IN NUMBER ,
  p_location_cd5               IN VARCHAR2 ,
  p_unit_class5                IN VARCHAR2 ,
  p_action6                    IN VARCHAR2 ,
  p_unit_cd6                   IN VARCHAR2 ,
  p_uv_version_number6         IN NUMBER ,
  p_location_cd6               IN VARCHAR2 ,
  p_unit_class6                IN VARCHAR2 ,
  p_action7                    IN VARCHAR2 ,
  p_unit_cd7                   IN VARCHAR2 ,
  p_uv_version_number7         IN NUMBER ,
  p_location_cd7               IN VARCHAR2 ,
  p_unit_class7                IN VARCHAR2 ,
  p_action8                    IN VARCHAR2 ,
  p_unit_cd8                   IN VARCHAR2 ,
  p_uv_version_number8         IN NUMBER ,
  p_location_cd8               IN VARCHAR2 ,
  p_unit_class8                IN VARCHAR2 ,
  p_confirmed_ind              IN VARCHAR2 ,
  p_enrolled_dt                IN DATE ,
  p_no_assessment_ind          IN VARCHAR2 ,
  p_exam_location_cd           IN VARCHAR2 ,
  p_alternative_title          IN VARCHAR2 ,
  p_override_enrolled_cp       IN NUMBER ,
  p_override_achievable_cp     IN NUMBER ,
  p_override_eftsu             IN NUMBER,
  p_override_credit_reason     IN VARCHAR2,
  p_administrative_unit_status IN VARCHAR2 ,
  p_discontinued_dt            IN DATE ,
  p_creation_dt                IN OUT NOCOPY DATE ,
  p_dcnt_reason_cd             IN VARCHAR2 ,
  p_unit_loc_cd                IN VARCHAR2 ,
  p_unit_class                 IN VARCHAR2 ,
  p_reason                     IN VARCHAR2,
  p_enr_method                 IN VARCHAR2,
  p_load_cal_type              IN VARCHAR2,
  p_load_cal_seq               IN NUMBER)

AS
/*--------------------------------------------------------------------------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created:
--
--Purpose:
-- enrp_prc_sua_blk_e_d
-- This module is a combined process to handle the enrolment and/or
-- discontinuation of one or more units within a given teaching period
-- for a specified group of students.
-- The module will process each student course attempt for the given
-- student course attempt selection parameters and then apply the IGS_PS_UNIT
-- alterations (enrol/discontinue) to the student's course.
-- It will write any IGS_GE_EXCEPTIONS and log information to the IGS_GE_S_LOG_ENTRY
-- table which will be used in an exception report.
-- After enrolling or discontinuing, a validation check is performed
-- for the student's course attempt to determine if any IGS_GE_EXCEPTIONS
-- exists for the students course enrolment.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
-- WHO               WHEN                 WHAT

-- kkillams          14-06-2003           Added three new parameters p_enr_method,p_load_cal_type and p_load_cal_seq to the job.
--                                        and Modified the all validations as per Validation TD. bug 2829270

-- ptandon           04-07-2003           Modified the cursor c_sca to fetch records when value for p_course_cd is not passed and
--                                        added logic to test for valid Administrative Unit Status while discontinuing unit attempts.
--                                        Bug# 3036433

-- ptandon           06-Oct-2003          Modified to add new validation to populate the column core_indicator_code in unit
--                                        attempt table as part of Prevent Dropping Core Units. Enh Bug# 3052432.
-- kkillams        08-10-2003             Remove the call to drop_all_workflow procedure and setting the
--                                        student unit attempt package variables as part of bug#3160856
--rvivekan   22-oct-2003                Placements build#3052438. Added code to sort the usecs based on relation_type. Also added handling
--                                      to enroll subordinates when a superior is enrolled and to drop subordinates when a superior is dropped
--vkarthik           02-Dec-2003        Modified c_sca to check for term records
--stutta          10-Feb-2004           Modified cursor c_get_sua_d to and made unit_class, location_cd optional. Modified fetch from
--                                      cursor c_get_sua_d  to a loop, to enable discontinuation of multiple unit attempt of a unit when
--                                      unit_class, location not passed as parameters. Modified c_sca and passed sca.person_id,sca.course_cd
--                                      to match_term_sca_params call. Introduced new variable l_disc_count to calculate total_disc_count.
--stutta         11-Feb-2004            Passed new parameter p_enrolled_dt to validate_enroll_validate call. Passing p_enrolled_dt,
--                                      p_discontinued_dt(instead of passing SYDATE always) to enr_sub_units, drop_sub_units respectively.
--stutta         18-Feb-2004            Changed logic to rollback the current action only for a failed user level validation. Changed logging
--                                      by resetting the log only when a program validation fails. Changed c_sca to check if the person group
--                                      is valid as on current date. BUG# 3158046, BUG# 3430661
-- vkarthik 31-Aug-2004     Deny all hold validation added to bulk enrollment/discontinuation job as part of Bug 3823810
--ckasu         13-Sep-2004             Modified  procedure inorder to consider Person step validations in  Discontinuing and Droping units.
--                                      as part of Bug 3823810
--stutta    07-Dec-2004                 Modified c_sca to select programs which are primary in the passed term calendar.
                                        As per bug#4046043
  --ckasu      17-MAR-2006              Modified  call to  igs_ss_en_wrappers.insert_into_enr_worksheet by passing p_no_assessment_ind
  --                                    as part of Bug 5070742.

--------------------------------------------------------------------------------------------------------------------------------------*/
e_resource_busy_exception       EXCEPTION;
PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
cst_enrol       CONSTANT        VARCHAR2 (35):= 'ENROL';
cst_course      CONSTANT        VARCHAR2 (35):= 'COURSE';
cst_encumb      CONSTANT        VARCHAR2 (35) := 'ENCUMB';
cst_advstand    CONSTANT        VARCHAR2 (35) := 'ADVSTAND';
cst_enroldt     CONSTANT        VARCHAR2 (35) := 'ENROLDT';
cst_teaching    CONSTANT        VARCHAR2 (35) := 'TEACHING';
cst_discontinue CONSTANT        VARCHAR2 (35) := 'DISCONTINUE';
cst_discontin   CONSTANT        VARCHAR2 (35) := 'DISCONTIN';
cst_unconfirm   CONSTANT        VARCHAR2 (35) := 'UNCONFIRM';
cst_drop        CONSTANT        VARCHAR2 (35) := 'DROPPED';
cst_waitlist    CONSTANT        VARCHAR2 (35) := 'WAITLISTED';
cst_invalid     CONSTANT        VARCHAR2 (35) := 'INVALID';
cst_enr_blk_ua  CONSTANT        igs_ge_s_log.s_log_type%TYPE := 'ENR-BLK-UA';
cst_blk_ua      CONSTANT        VARCHAR2 (35)  := 'BULK UNIT ENROLMENT/DISCONTINUATION';
cst_inactive    CONSTANT        VARCHAR2 (35) := 'INACTIVE';
cst_enrolled    CONSTANT        VARCHAR2 (35) := 'ENROLLED';
cst_intermit    CONSTANT        VARCHAR2 (35) := 'INTERMIT';
cst_complete    CONSTANT        VARCHAR2 (35) := 'COMPLETED';
cst_summary     CONSTANT        igs_ge_s_log_entry.key%TYPE := 'SUMMARY';



t_sua_enroll                    t_sua_typ;
t_sua_disc                      t_sua_typ;
t_sua_clear                     t_sua_typ;
l_discontinued_dt               DATE;
l_enrolled_dt                   DATE;
l_cntr_enroll                   NUMBER(2);
l_cntr_disc                     NUMBER(2);
l_total_exist_sua_count         NUMBER;
l_total_enrol_error_count       NUMBER;
l_total_enrol_warn_count        NUMBER;
l_total_enrol_count             NUMBER;
l_enrol_count                   NUMBER;
l_total_disc_not_enrol_count    NUMBER;
l_total_disc_error_count        NUMBER;
l_total_disc_warn_count         NUMBER;
l_total_disc_count              NUMBER;
l_disc_count                    NUMBER;
l_total_course_error_count      NUMBER;
l_total_course_warn_count       NUMBER;
l_total_encumb_error_count      NUMBER;
l_total_lock_count              NUMBER;
l_commencement_type             VARCHAR2(20) DEFAULT NULL;
l_message_name                  VARCHAR2(2000);
l_message_token                 VARCHAR2(2000);
l_deny_warn                     VARCHAR2(20);
l_waitlist_ind                  VARCHAR2(3);
l_return_status                 BOOLEAN;
l_ret_stat                      VARCHAR2(100);
l_ovrrdchk                      VARCHAR2(1);
l_ovrd_drop                     VARCHAR2(1);
l_processed                     BOOLEAN;
l_action_processed              BOOLEAN;
l_attendance_type_reach         BOOLEAN := TRUE;
l_att_type                      VARCHAR2(40);
l_attendance_types              VARCHAR2(100); -- As returned from the function igs_en_val_sca.enrp_val_coo_att
l_unit_attempt_status           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
l_uoo_id                        IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
l_person_type                   IGS_PE_PERSON_TYPES.person_type_code%TYPE;
l_en_cal_type                   IGS_CA_INST.CAL_TYPE%TYPE;
l_en_ci_seq_num                 IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
l_enrolment_cat                 IGS_PS_TYPE.ENROLMENT_CAT%TYPE;
l_unit_section_status           IGS_PS_UNIT_OFR_OPT.unit_section_status%TYPE DEFAULT NULL;
l_acad_cal_type                 IGS_CA_INST.CAL_TYPE%TYPE;
l_acad_ci_sequence_number       IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
l_acad_ci_start_dt              IGS_CA_INST.START_DT%TYPE;
l_acad_ci_end_dt                IGS_CA_INST.END_DT%TYPE;
l_alternate_code                IGS_CA_INST.ALTERNATE_CODE%TYPE;
l_key                           IGS_GE_S_LOG_ENTRY.key%TYPE;
l_course_key                    IGS_GE_S_LOG_ENTRY.key%TYPE;
l_unit_key                      IGS_GE_S_LOG_ENTRY.key%TYPE;
l_text                          IGS_GE_S_LOG_ENTRY.text%TYPE;
l_enroll                        IGS_LOOKUP_VALUES.meaning%TYPE;
l_discon                        IGS_LOOKUP_VALUES.meaning%TYPE;
l_eftsu_total                   IGS_EN_SU_ATTEMPT.override_eftsu%type;
l_total_credit_points           IGS_EN_SU_ATTEMPT.override_enrolled_cp%TYPE ;
l_administrative_unit_status    IGS_EN_SU_ATTEMPT_ALL.administrative_unit_status%TYPE;
l_person_number                 IGS_PE_PERSON.person_number%TYPE;
l_dummy                         VARCHAR2(100);
l_creation_dt                   DATE;
l_encoded_msg                   VARCHAR2(2000);
l_app_sht_name                  VARCHAR2(100);
l_msg_name                      VARCHAR2(2000);
l_temp_msg                      VARCHAR2(2000);
l_core_indicator_code           IGS_EN_SU_ATTEMPT.core_indicator_code%TYPE;
l_relation_type                 VARCHAR2(100);
l_enr_uoo_ids                   VARCHAR2(2000);
l_sub_success                   VARCHAR2(2000);
l_sub_waitlist                  VARCHAR2(2000);
l_sub_failed                    VARCHAR2(2000);
l_uoo_ids_list                  VARCHAR2(2000);
l_succ_msg                      VARCHAR2(100);
l_failed_uoo_ids                VARCHAR2(2000);

-- modified cursor for perf bug : 3696293 : sql id: 14791714
CURSOR c_per_num (cp_person_id   igs_pe_person.person_id%TYPE)
       IS SELECT party_number FROM      hz_parties
                               WHERE     party_id = cp_person_id;



CURSOR c_sca IS SELECT  sca.person_id,
                        sca.course_cd,
                        sca.version_number,
                        sca.coo_id
                FROM    IGS_EN_STDNT_PS_ATT     sca
                WHERE   -- person_id matches

                        (p_group_id             IS NULL OR
                        EXISTS (
                                SELECT  'X'
                                FROM    IGS_PE_PRSID_GRP_MEM    pig
                                WHERE   pig.group_id    = p_group_id AND
                                        pig.person_id   = sca.person_id AND
                                        (pig.start_date IS NULL OR pig.start_date <= TRUNC(SYSDATE)) AND
                                        (pig.end_date IS NULL OR pig.end_date >= TRUNC(SYSDATE))
                                        ))
                        AND sca.person_id = NVL (p_person_id,sca.person_id )
                        AND sca.course_cd like p_course_cd
                        AND match_term_sca_params (
                                        sca.person_id,
                                        sca.course_cd,
                                        NULL,
                                        sca.attendance_type,
                                        sca.attendance_mode,
                                        sca.location_cd,
                                        p_course_cd,
                                        NULL,
                                        p_attendance_type,
                                        p_attendance_mode,
                                        p_location_cd,
                                        p_load_cal_type,
                                        p_load_cal_seq )='Y'
                        AND sca.course_attempt_status IN (cst_inactive,cst_enrolled,cst_intermit,cst_complete)
                        AND (p_unit_cd              IS NULL OR
                        EXISTS (
                                SELECT  'X'
                                FROM    IGS_EN_SU_ATTEMPT       sua
                                WHERE   sua.person_id           = sca.person_id AND
                                        sua.unit_cd             = p_unit_cd AND
                                        sua.version_number      = NVL(p_uv_version_number, sua.version_number) AND
                                        sua.location_cd         = NVL(p_unit_loc_cd,sua.location_cd) AND
                                        sua.unit_class          = NVL(p_unit_class,sua.unit_class) AND
                                        sua.cal_type            = p_teach_cal_type AND
                                        sua.ci_sequence_number  = p_teach_ci_sequence_number))
                        AND (igs_en_spa_terms_api.get_spat_primary_prg(sca.person_id,sca.course_cd,
                                        p_load_cal_type,p_load_cal_seq) = 'PRIMARY'
                            OR NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N') = 'N')
                   ORDER BY  sca.person_id,
                             sca.course_cd
                   FOR UPDATE NOWAIT;
CURSOR c_enroll(cp_code igs_lookup_values.lookup_code%TYPE) IS
        SELECT meaning
        FROM   igs_lookup_values v1
        WHERE v1.lookup_Type = 'VS_EN_ACT_UNIT' AND
              v1.lookup_code=cp_code;
CURSOR cur_get_uoo(cp_unit_cd          igs_ps_unit_ofr_opt.unit_cd%TYPE,
                      cp_ver_num          igs_ps_unit_ofr_opt.version_number%TYPE,
                      cp_cal_type         igs_ps_unit_ofr_opt.cal_type%TYPE,
                      cp_ci_seq_num       igs_ps_unit_ofr_opt.ci_sequence_number%TYPE,
                      cp_unit_class       igs_ps_unit_ofr_opt.unit_class%TYPE,
                      cp_location_cd      igs_ps_unit_ofr_opt.location_cd%TYPE)IS
             SELECT uoo_id,relation_type
                    FROM igs_ps_unit_ofr_opt
             WHERE unit_cd            = cp_unit_cd
             AND   version_number     = cp_ver_num
             AND   cal_type           = cp_cal_type
             AND   ci_sequence_number = cp_ci_seq_num
             AND   unit_class         = cp_unit_class
             AND   location_cd        = cp_location_cd;
CURSOR cur_sua_stat (cp_person_id        igs_en_su_attempt.person_id%TYPE,
                      cp_course_cd        igs_en_su_attempt.course_cd%TYPE,
                      cp_uoo_id           igs_ps_unit_ofr_opt.uoo_id%TYPE)IS
             SELECT unit_attempt_status
                    FROM igs_en_su_attempt
             WHERE person_id          = cp_person_id
             AND   course_cd          = cp_course_cd
             AND   uoo_id             = cp_uoo_id;

CURSOR cur_cal_rel  (cp_teach_cal_type      igs_ca_inst.cal_type%TYPE,
                     cp_teach_seq_num       igs_ca_inst.sequence_number%TYPE,
                     cp_load_cal_type      igs_ca_inst.cal_type%TYPE,
                     cp_load_seq_num       igs_ca_inst.sequence_number%TYPE) IS
             SELECT '1'
                    FROM igs_ca_teach_to_load_v
                    WHERE teach_cal_type             = cp_teach_cal_type
                    AND   teach_ci_sequence_number   = cp_teach_seq_num
                    AND   load_cal_type              = cp_load_cal_type
                    AND   load_ci_sequence_number    = cp_load_seq_num;


CURSOR cur_get_sua_d (cp_person_id        igs_en_su_attempt.person_id%TYPE,
                      cp_course_cd        igs_en_su_attempt.course_cd%TYPE,
                      cp_unit_cd          igs_ps_unit_ofr_opt.unit_cd%TYPE,
                      cp_ver_num          igs_ps_unit_ofr_opt.version_number%TYPE,
                      cp_cal_type         igs_ps_unit_ofr_opt.cal_type%TYPE,
                      cp_ci_seq_num       igs_ps_unit_ofr_opt.ci_sequence_number%TYPE,
                      cp_unit_class       igs_ps_unit_ofr_opt.unit_class%TYPE,
                      cp_location_cd      igs_ps_unit_ofr_opt.location_cd%TYPE)IS
             SELECT sua.uoo_id,sua.unit_attempt_status,uoo.relation_type
                    FROM igs_en_su_attempt sua,
                         igs_ps_unit_ofr_opt uoo
             WHERE sua.person_id          = cp_person_id
             AND   sua.course_cd          = cp_course_cd
             AND   sua.unit_cd            = cp_unit_cd
             AND   sua.version_number     = NVL(cp_ver_num,sua.version_number)
             AND   sua.cal_type           = cp_cal_type
             AND   sua.ci_sequence_number = cp_ci_seq_num
             AND   sua.unit_class         = NVL(cp_unit_class, sua.unit_class)
             AND   sua.location_cd        = NVL(cp_location_cd, sua.location_cd)
             AND   sua.uoo_id             = uoo.uoo_id;



        PROCEDURE log_error_message(p_messages    VARCHAR2,
                                    p_del         VARCHAR2,
                                    p_key         VARCHAR2,
                                    p_type        VARCHAR2,
                                    p_c_u         VARCHAR2) AS
        /*------------------------------------------------------
          --Created by  : KKILLAMS, Oracle IDC
          --Date created:
          --
          --Purpose:This procedure will logs the error/warn messages
          --        p_messages --Concatenate error message
          --        p_del      --Deliminator
          --        p_key      --Key
          --        p_type     --Deny/Warn
          --        p_c_u      --C --> Course related errors/warns
          --                   --E --> Unit related errors/warns while enroll
          --                   --W --> Unit related errors/warns while discontinue
          --                   --I --> Information messages
          --Procedure logs the all error/warn messages.
          --Known limitations/enhancements and/or remarks:
          --
          --Change History:
          -- WHO               WHEN                 WHAT
        ---------------------------------------------------------*/
        cst_error  CONSTANT       VARCHAR2(10) := 'ERROR|';
        cst_warn   CONSTANT       VARCHAR2(10) := 'WARNING|';
        cst_information         CONSTANT VARCHAR2(12) := 'INFORMATION|';
        l_messages      VARCHAR2(2000);
        l_mesg_name     VARCHAR2(2000);
        l_mesg_txt      VARCHAR2(2000);
        l_key           IGS_GE_S_LOG_ENTRY.key%TYPE;
        l_err_type      VARCHAR2(30);
        l_msg_len       NUMBER ;
        l_msg_token     VARCHAR2(100);
        l_str_place     NUMBER(3);
        BEGIN --log_error_message
             l_messages := p_messages;
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
                     IF p_c_u <> 'I' THEN
                       IF (p_type = 'DENY') AND (i = l_msg_len) THEN
                          l_err_type := cst_error;
                          IF p_c_u = 'C' OR p_c_u = 'P' THEN
                             l_total_course_error_count := l_total_course_error_count + 1;
                          ELSIF p_c_u = 'E' THEN
                             l_total_enrol_error_count := l_total_enrol_error_count + 1;
                          ELSE
                             l_total_disc_error_count := l_total_disc_error_count + 1;
                          END IF;
                       ELSE
                          l_err_type := cst_warn;
                          IF p_c_u = 'C' OR p_c_u = 'P' THEN
                             l_total_course_warn_count:= l_total_course_warn_count + 1;
                          ELSIF p_c_u = 'E' THEN
                             l_total_enrol_warn_count := l_total_enrol_warn_count + 1;
                          ELSE
                             l_total_disc_warn_count:= l_total_disc_warn_count + 1;
                          END IF;
                       END IF;
                       IF p_c_u = 'P' THEN
                          l_err_type := l_err_type||'PERSON-CHECK|';
                       END IF;
                     ELSE  -- IF p_c_u is I (information message, dont increment any counters
                       l_err_type:=cst_information;
                     END IF;

                     IF LENGTH(l_mesg_name) <=30  THEN
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
                     ELSE
                       --exception has occured in igs_ss_en_wrappers and l_mesg_name contains
                       --the exception TEXT (not name)
                       --So pass the text and use a dummy message (smaller than 30chars)
                       --The dummy message needs to have the UNIT_CD token
                       --Because only in this scneario does the report read the p_text instead of the p_sle_message_name
                       l_mesg_txt :=l_mesg_name;
                       l_mesg_name:='IGS_EN_RULE_TEXT';
                     END IF;

                     igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                       p_sl_key           => cst_blk_ua,
                                                       p_sle_key          => p_key,
                                                       p_sle_message_name => l_mesg_name,
                                                       p_text             => l_err_type ||l_mesg_txt);
                     l_mesg_name := NULL;
                 ELSE
                    l_mesg_name := l_mesg_name||SUBSTR(l_messages,i,1);
                 END IF;
             END LOOP;
        END log_error_message;

BEGIN --Enrp_Prc_Sua_Blk_E_D
        l_discontinued_dt  := NVL(p_discontinued_dt,TRUNC(SYSDATE));
        l_enrolled_dt      := NVL(p_enrolled_dt,TRUNC(SYSDATE));

        --Changing the invoke source from NJOB to JOB to correct _actual counter handling
        igs_en_gen_017.g_invoke_source := 'JOB';

        OPEN c_enroll('ENROL');
        FETCH c_enroll INTO l_enroll;
        CLOSE c_enroll;
        OPEN c_enroll('DISCONTNUE');
        FETCH c_enroll INTO l_discon;
        CLOSE c_enroll;

        --Validate the input teach and load calendars whether the are having the relation ship.
        OPEN cur_cal_rel(p_teach_cal_type,
                         p_teach_ci_sequence_number,
                         p_load_cal_type,
                         p_load_cal_seq);
        FETCH cur_cal_rel INTO l_dummy;
        IF cur_cal_rel%NOTFOUND THEN
            CLOSE cur_cal_rel;
            fnd_message.set_name('IGS','IGS_EN_BULK_E_D_NO_CAL_REL');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
        END IF;
        CLOSE cur_cal_rel;
        -- Clear pl/sql table for writing IGS_GE_S_LOG_ENTRY records
        IGS_GE_INS_SLE.genp_set_log_cntr;
        -- Determine the (first) academic period of the teaching period.
        l_message_name := NULL;
        l_alternate_code := igs_en_gen_002.enrp_get_acad_alt_cd(p_cal_type                   =>p_teach_cal_type,
                                                                p_ci_sequence_number         =>p_teach_ci_sequence_number,
                                                                p_acad_cal_type              =>l_acad_cal_type,
                                                                p_acad_ci_sequence_number    =>l_acad_ci_sequence_number,
                                                                p_acad_ci_start_dt           =>l_acad_ci_start_dt,
                                                                p_acad_ci_end_dt             =>l_acad_ci_end_dt,
                                                                p_message_name               =>l_message_name);
        IF (l_message_name IS NOT NULL) THEN
                fnd_message.set_name('IGS',l_message_name);
                igs_ge_msg_stack.add;
                app_exception.raise_exception;
        END IF;
        -- Initialise counters
        l_total_exist_sua_count := 0;
        l_total_enrol_error_count := 0;
        l_total_enrol_warn_count := 0;
        l_total_enrol_count := 0;
        l_enrol_count := 0;
        l_total_disc_not_enrol_count := 0;
        l_total_disc_error_count := 0;
        l_total_disc_count := 0;
        l_disc_count := 0;
        l_total_course_error_count := 0;
        l_total_course_warn_count := 0;
        l_total_encumb_error_count := 0;
        l_total_lock_count := 0;
        l_total_disc_warn_count := 0;
        l_total_disc_error_count := 0;


        -- reset pl/sql table and counter
        l_cntr_enroll := 0;
        l_cntr_disc   := 0;

        -- Put parameters into pl/sql table
        IF p_action1 = cst_enrol AND p_unit_cd1 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd1;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number1;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd1;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class1;
        ELSIF p_action1 =  cst_discontinue AND p_unit_cd1 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd1;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number1;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd1;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class1;
        END IF;

        IF p_action2 = cst_enrol AND p_unit_cd2 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd2;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number2;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd2;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class2;
        ELSIF p_action2 =  cst_discontinue AND p_unit_cd2 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd2;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number2;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd2;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class2;
        END IF;

        IF p_action3 = cst_enrol AND p_unit_cd3 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd3;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number3;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd3;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class3;
        ELSIF p_action3 =  cst_discontinue AND p_unit_cd3 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd3;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number3;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd3;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class3;
        END IF;

        IF p_action4 = cst_enrol AND p_unit_cd4 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd4;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number4;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd4;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class4;
        ELSIF p_action4 =  cst_discontinue AND p_unit_cd4 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd4;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number4;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd4;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class4;
        END IF;

        IF p_action5 = cst_enrol AND p_unit_cd5 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd5;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number5;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd5;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class5;
        ELSIF p_action5 =  cst_discontinue AND p_unit_cd5 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd5;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number5;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd5;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class5;
        END IF;
        IF p_action6 = cst_enrol AND p_unit_cd6 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd6;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number6;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd6;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class6;
        ELSIF p_action6 =  cst_discontinue AND p_unit_cd6 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd6;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number6;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd6;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class6;
        END IF;
        IF p_action7 = cst_enrol AND p_unit_cd7 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd7;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number7;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd7;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class7;
        ELSIF p_action7 =  cst_discontinue AND p_unit_cd7 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd7;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number7;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd7;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class7;
        END IF;

        IF p_action8 = cst_enrol AND p_unit_cd8 IS NOT NULL THEN
                l_cntr_enroll := l_cntr_enroll+1;
                t_sua_enroll(l_cntr_enroll).unit_cd := p_unit_cd8;
                t_sua_enroll(l_cntr_enroll).uv_version_number := p_uv_version_number8;
                t_sua_enroll(l_cntr_enroll).location_cd := p_location_cd8;
                t_sua_enroll(l_cntr_enroll).unit_class := p_unit_class8;
        ELSIF p_action8 =  cst_discontinue AND p_unit_cd8 IS NOT NULL THEN
                l_cntr_disc := l_cntr_disc+1;
                t_sua_disc(l_cntr_disc).unit_cd := p_unit_cd8;
                t_sua_disc(l_cntr_disc).uv_version_number := p_uv_version_number8;
                t_sua_disc(l_cntr_disc).location_cd := p_location_cd8;
                t_sua_disc(l_cntr_disc).unit_class := p_unit_class8;
        END IF;

        IF p_confirmed_ind ='Y' AND l_cntr_enroll > 0 THEN
           l_ovrrdchk := 'Y';
        ELSE
           l_ovrrdchk := 'N';
        END IF;
        --Start of the main process
        --Sort usecs placing superiors before subordinates
        l_enr_uoo_ids:=enrl_sort_usecs(t_sua_disc,p_teach_cal_type,p_teach_ci_sequence_number); --l_enr_uoo_ids is used as a dummy here
        l_enr_uoo_ids:=enrl_sort_usecs(t_sua_enroll,p_teach_cal_type,p_teach_ci_sequence_number);--l_enr_uoo_ids passed to igs_en_val_sua.enr_sub_units

        FOR rec_sca IN c_sca
        LOOP
        BEGIN
            --initialising the plsql table to store messages
            --whenever any error occurs, flush the table
            --by calling genp_set_log_cntr (this remove any success messages)
            --and add the error message alone.
            IGS_GE_INS_SLE.genp_set_log_cntr;

            l_processed := TRUE;
            l_course_key :=TO_CHAR(rec_sca.person_id) || '|' ||rec_sca.course_cd;
            -- Following function will returns the person type of the log in
            l_person_type := Igs_En_Gen_008.enrp_get_person_type(p_course_cd =>NULL);

            OPEN c_per_num(rec_sca.person_id);
            FETCH c_per_num INTO l_person_number;
            CLOSE c_per_num;
            -- Determine the Enrollment method , Enrollment Commencement type.
            l_dummy := NULL;
            l_enrolment_cat:=IGS_EN_GEN_003.Enrp_Get_Enr_Cat(p_person_id                =>rec_sca.person_id,
                                                             p_course_cd                =>rec_sca.course_cd,
                                                             p_cal_type                 =>l_acad_cal_type,
                                                             p_ci_sequence_number       =>l_acad_ci_sequence_number,
                                                             p_session_enrolment_cat    =>NULL,
                                                             p_enrol_cal_type           =>l_en_cal_type,
                                                             p_enrol_ci_sequence_number =>l_en_ci_seq_num,
                                                             p_commencement_type        =>l_commencement_type,
                                                             p_enr_categories           =>l_dummy);
            SAVEPOINT sp_sua_blk_e_d;

            --Follwoing function will do the all person step validations for the context person.
            l_message_name :=NULL;
            l_deny_warn := NULL;

        -- deny all hold validation added as part of Bug 3823810
        igs_en_elgbl_person.eval_ss_deny_all_hold (
                            p_person_id                     =>rec_sca.person_id,
                            p_person_type                   =>l_person_type,
                            p_course_cd                 =>rec_sca.course_cd,
                            p_load_calendar_type            =>p_load_cal_type,
                            p_load_cal_sequence_number       =>p_load_cal_seq,
                            p_status                        =>l_deny_warn,
                            p_message                       =>l_message_name);
             IF l_deny_warn='E' THEN --deny all hold validation
            l_processed := FALSE;
            IGS_GE_INS_SLE.genp_set_log_cntr;
            log_error_message(
                   p_messages   =>l_message_name,
                                   p_del            =>';',
                                   p_key            =>l_course_key,
                                   p_type           =>'DENY',
                                   p_c_u            =>'P');
        END IF;

            --person steps not validated when deny all hold fails added for Bug 3823810
        l_message_name :=NULL;
        l_deny_warn := NULL;
        IF l_processed THEN
        IF NOT igs_en_elgbl_person.eval_person_steps( p_person_id                 =>rec_sca.person_id,
                                                          p_person_type               =>l_person_type,
                                                          p_load_calendar_type        =>p_load_cal_type,
                                                          p_load_cal_sequence_number  =>p_load_cal_seq,
                                                          p_program_cd                =>rec_sca.course_cd,
                                                          p_program_version           =>rec_sca.version_number,
                                                          p_enrollment_category       =>l_enrolment_cat,
                                                          p_comm_type                 =>l_commencement_type,
                                                          p_enrl_method               =>p_enr_method,
                                                          p_message                   =>l_message_name,
                                                          p_deny_warn                 =>l_deny_warn,
                                                          p_calling_obj               =>'JOB',
                                                          p_create_warning            =>'N') THEN
                 --function returns the error then log all the error message and abort the further processing for the context person.
                 IGS_GE_INS_SLE.genp_set_log_cntr;
                 log_error_message(p_messages =>l_message_name,
                                   p_del      =>';',
                                   p_key      =>l_course_key,
                                   p_type     =>'DENY',
                                   p_c_u      =>'P');
                 l_processed := FALSE;
            ELSE
                IF l_message_name IS NOT NULL THEN
                    log_error_message(p_messages =>l_message_name,
                                      p_del      =>';',
                                      p_key      =>l_course_key,
                                      p_type     =>'WARN',
                                      p_c_u      =>'P');
                END IF;
           END IF; --NOT igs_en_elgbl_person.eval_person_steps
       END IF;
           IF l_processed THEN
                   -- A call to igs_en_prc_load.enrp_clc_eftsu_total as part of- Enrollment Eligibility and validations .
                   -- The Total enrolled CP of the student has to be determined before the unit is dropped(l_total_credit_points) .
                   -- The unit is then dropped , and eval_min_cp is called with the value of l_total_enrolled_cp.
                   -- The value of l_total_enrolled_cp is essential to determine if the Min Credit Points is already reached
                   -- by the student before that Unit is dropped.
                   l_eftsu_total := igs_en_prc_load.enrp_clc_eftsu_total(p_person_id             => rec_sca.person_id,
                                                                         p_course_cd             => rec_sca.course_cd,
                                                                         p_acad_cal_type         => l_acad_cal_type,
                                                                         p_acad_sequence_number  => l_acad_ci_sequence_number,
                                                                         p_load_cal_type         => p_load_cal_type,
                                                                         p_load_sequence_number  => p_load_cal_seq,
                                                                         p_truncate_ind          => 'N',
                                                                         p_include_research_ind  => 'Y'  ,
                                                                         p_key_course_cd         => NULL ,
                                                                         p_key_version_number    => NULL ,
                                                                         p_credit_points         => l_total_credit_points );
                   -- Check if the Forced Attendance Type has already been reached for the Student before transferring .
                   l_message_name :=NULL;
                   -- Modfied as a part of bug#5191592.
                   l_attendance_type_reach := igs_en_val_sca.enrp_val_coo_att(p_person_id          => rec_sca.person_id,
                                                                              p_coo_id             => rec_sca.coo_id,
                                                                              p_cal_type           => l_acad_cal_type,
                                                                              p_ci_sequence_number => l_acad_ci_sequence_number,
                                                                              p_message_name       => l_message_name,
                                                                              p_attendance_types   => l_attendance_types,
                                                                              p_load_or_teach_cal_type => p_load_cal_type,
                                                                              p_load_or_teach_seq_number => p_load_cal_seq);
                   -- Assign values to the parameter p_deny_warn_att based on if Attendance Type has not been already reached or not.
                   IF l_attendance_type_reach THEN
                          l_att_type  := 'AttTypReached' ;
                   ELSE
                          l_att_type  := 'AttTypNotReached' ;
                   END IF ;
            END IF;  --        IF l_processed THEN

           IF l_processed THEN
           /**********************************************************************************************************************
                                             Discontinue /Drop the units
           **********************************************************************************************************************/

           l_disc_count := 0;
           FOR i IN REVERSE 1 .. l_cntr_disc  --Added reverse so that subordinates are dropped before the superiors
           LOOP

              l_unit_key := TO_CHAR(rec_sca.person_id)|| '|' || rec_sca.course_cd  || '|' ||t_sua_disc(i).unit_cd || '|' ||TO_CHAR(t_sua_disc(i).uv_version_number)|| '|' ||
                                    p_teach_cal_type || '|' ||TO_CHAR(p_teach_ci_sequence_number) || '|' ||UPPER(l_discon)|| '|' ||t_sua_disc(i).unit_class || '|' ||
                                    t_sua_disc(i).location_cd;

              FOR rec_get_sua_d IN cur_get_sua_d( rec_sca.person_id,
                                  rec_sca.course_cd,
                                  t_sua_disc(i).unit_cd,
                                  t_sua_disc(i).uv_version_number,
                                  p_teach_cal_type,
                                  p_teach_ci_sequence_number,
                                  t_sua_disc(i).unit_class,
                                  t_sua_disc(i).location_cd)
              LOOP  -- looping through all the unit sections when unit_class and location are null.
                SAVEPOINT sp_sua_blk_disc;
                l_action_processed := TRUE;
                IF igs_en_gen_008.enrp_get_ua_del_alwd(p_cal_type                 => p_teach_cal_type,
                                                     p_ci_sequence_number       => p_teach_ci_sequence_number,
                                                     p_effective_dt             => NVL(p_discontinued_dt,SYSDATE),
                                                     p_uoo_id                   => rec_get_sua_d.uoo_id) = 'N' THEN

                  l_message_name:=NULL;
                  l_message_token:=NULL;
                  IF igs_en_val_sua.enrp_val_discont_aus(p_administrative_unit_status     => p_administrative_unit_status,
                                                       p_discontinued_dt                => NVL(p_discontinued_dt,SYSDATE),
                                                       p_cal_type                       => p_teach_cal_type,
                                                       p_ci_sequence_number             => p_teach_ci_sequence_number,
                                                       p_message_name                   => l_message_name,
                                                       p_uoo_id                         => rec_get_sua_d.uoo_id,
                                                       p_message_token                  => l_message_token,
                                                       p_legacy                         => 'N') = FALSE THEN
                          l_temp_msg:=NULL;
                          fnd_message.set_name('IGS',l_message_name);
                          IF l_message_name = 'IGS_SS_EN_INVLD_ADMIN_UNITST' THEN
                                  fnd_message.set_token('LIST',l_message_token);
                          END IF;
                          l_temp_msg:=fnd_message.get;
                          fnd_file.put_line(Fnd_File.LOG,l_temp_msg);
                          IGS_GE_INS_SLE.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                                p_sl_key           =>cst_blk_ua,
                                                                p_sle_key          =>l_course_key,
                                                                p_sle_message_name =>l_message_name,
                                                                p_text             =>'ERROR|'||l_temp_msg);
                          l_action_processed := FALSE;
                          l_total_encumb_error_count := l_total_encumb_error_count + 1;
                  END IF;
                END IF;
              IF l_action_processed THEN
                 IF rec_get_sua_d.unit_attempt_status NOT IN(cst_enrolled,cst_waitlist,cst_invalid) THEN
                     igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                       p_sl_key           => cst_blk_ua,
                                                       p_sle_key          => l_unit_key,
                                                       p_sle_message_name => 'IGS_EN_UNABLE_DISCONT_UNIT',
                                                       p_text             => 'ERROR|'||cst_discontin);
                     l_action_processed := FALSE;
                     l_total_disc_error_count := l_total_disc_error_count + 1;
                 ELSE
                     l_total_exist_sua_count := l_total_exist_sua_count + 1;
                     -- Validate that the process has not been scheduled to run outside the
                     -- environment/variation windows for the teaching period.
                     --moved this code from the start of this procedure,to pass uoo_id  by smaddali
                     IF (igs_en_gen_008.enrp_get_var_window(p_cal_type           =>   p_teach_cal_type,
                                                            p_ci_sequence_number =>   p_teach_ci_sequence_number,
                                                            p_effective_dt       =>   NVL(p_enrolled_dt,SYSDATE),
                                                            p_uoo_id             =>   rec_get_sua_d.uoo_id ) = FALSE) THEN
                             igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                               p_sl_key           => cst_blk_ua,
                                                               p_sle_key          => l_unit_key,
                                                               p_sle_message_name => 'IGS_EN_TRN_ERR_VAR_WIND',
                                                               p_text             => 'ERROR|'||cst_discontin);
                        l_action_processed := FALSE;
                        l_total_disc_not_enrol_count := l_total_disc_not_enrol_count +1;
                     END IF;
                     --Drop subordinates if usec is a superior
                     --IF drop fails, log error and abort
                     IF rec_get_sua_d.relation_type='SUPERIOR'  AND l_action_processed THEN
                       l_message_name:= NULL;
                       igs_en_val_sua.drop_sub_units(
                                  p_person_id        => rec_sca.person_id  ,
                                  p_course_cd        => rec_sca.course_cd   ,
                                  p_uoo_id           => rec_get_sua_d.uoo_id ,
                                  p_load_cal_type    => p_load_cal_type  ,
                                  p_load_seq_num     => p_load_cal_seq  ,
                                  p_acad_cal_type    => l_acad_cal_type  ,
                                  p_acad_seq_num     => l_acad_ci_sequence_number  ,
                                  p_enrollment_method=> p_enr_method  ,
                                  p_confirmed_ind    => l_ovrrdchk,
                                  p_person_type      => l_person_type,
                                  p_effective_date   => NVL(p_discontinued_dt,SYSDATE)  ,
                                  p_course_ver_num   =>rec_sca.version_number,
                                  p_dcnt_reason_cd   => p_dcnt_reason_cd,
                                  p_admin_unit_status=> p_administrative_unit_status,
                                  p_uoo_ids          => l_uoo_ids_list ,
                                  p_error_message    => l_message_name);
                       IF l_message_name IS NOT NULL THEN
                         IGS_GE_INS_SLE.genp_set_log_cntr;
                         log_error_message(p_messages =>'IGS_EN_BLK_SUB_DROP_FAILED',
                          p_del      =>';',
                          p_key      =>l_course_key,
                          p_type     =>'DENY',
                          p_c_u      =>'D');
                         l_processed := FALSE;
                         EXIT;
                       END IF;
                     END IF;
                     IF l_action_processed THEN
                         l_message_name:= NULL;
                         l_return_status := TRUE;
                             --Raise workflow event to notify the student regarding the droping of the unit section.
                         igs_ss_en_wrappers.drop_notif_variable(p_reason,'ADMIN_DROP_JOB');
                         igs_ss_en_wrappers.blk_drop_units(p_uoo_id                =>rec_get_sua_d.uoo_id,
                                                       p_person_id             =>rec_sca.person_id,
                                                       p_person_type           =>l_person_type,
                                                       p_load_cal_type         =>p_load_cal_type,
                                                       p_load_sequence_number  =>p_load_cal_seq,
                                                       p_acad_cal_type         =>l_acad_cal_type,
                                                       p_acad_sequence_number  =>l_acad_ci_sequence_number,
                                                       p_program_cd            =>rec_sca.course_cd,
                                                       p_program_version       =>rec_sca.version_number,
                                                       p_dcnt_reason_cd        =>p_dcnt_reason_cd,
                                                       p_admin_unit_status     =>p_administrative_unit_status,
                                                       p_effective_date        =>NVL(p_discontinued_dt,TRUNC(SYSDATE)),
                                                       p_enrolment_cat         =>l_enrolment_cat,
                                                       p_comm_type             =>l_commencement_type,
                                                       p_enr_meth_type         =>p_enr_method,
                                                       p_total_credit_points   =>l_total_credit_points,
                                                       p_force_att_type        =>l_att_type,
                                                       p_val_ovrrd_chk         =>l_ovrrdchk,
                                                       p_ovrrd_drop            =>'N',
                                                       p_return_status         =>l_return_status,
                                                       p_message               =>l_message_name,
                                                       p_sub_unit              => 'N');
                         IF NOT l_return_status THEN
                             IGS_GE_INS_SLE.genp_set_log_cntr;
                             log_error_message(p_messages =>l_message_name,
                                          p_del      =>';',
                                          p_key      =>l_course_key,
                                          p_type     =>'DENY',
                                          p_c_u      =>'D');
                             l_processed := FALSE;
                             EXIT;
                         ELSIF l_message_name IS NOT NULL THEN
                             log_error_message(p_messages =>l_message_name,
                                             p_del      =>';',
                                             p_key      =>l_course_key,
                                             p_type     =>'WARN',
                                             p_c_u      =>'D');

                          END IF;
                          l_disc_count  := l_disc_count + 1;

                          IF ((p_confirmed_ind <>  'Y')  OR (l_cntr_enroll = 0)) THEN
                              igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                               p_sl_key           => cst_blk_ua,
                                                               p_sle_key          => l_unit_key,
                                                               p_sle_message_name => 'IGS_EN_SUA_DISCONTINUED',
                                                               p_text             => 'INFORMATION|'||cst_discontin);
                          END IF;
                     END IF;
                 END IF; --rec_get_sua_d.unit_attempt_status NOT IN(cst_enrolled,cst_waitlist,cst_invalid)

              END IF;
              IF NOT l_action_processed THEN
                         IF l_failed_uoo_ids IS NULL THEN
                                l_failed_uoo_ids :=  ','||rec_get_sua_d.uoo_id||',';
                         ELSE
                                l_failed_uoo_ids := l_failed_uoo_ids || rec_get_sua_d.uoo_id || ',';
                         END IF;
                         ROLLBACK TO sp_sua_blk_disc;
              END IF;

             END LOOP; -- rec_get_sua_d
             IF NOT l_processed THEN
                EXIT;
             END IF;
           END LOOP; --i IN 1 .. l_cntr_disc

          END IF;  --        IF l_processed THEN

           /**********************************************************************************************************************
                                             Enrolling the units
           **********************************************************************************************************************/
           l_enrol_count := 0;
           IF l_processed THEN
                   --Following code will enroll/attempt the unit
                   l_uoo_ids_list:=NULL;
                   FOR i IN 1 .. l_cntr_enroll
                   LOOP
                       l_unit_key := TO_CHAR(rec_sca.person_id)|| '|' || rec_sca.course_cd  || '|' ||t_sua_enroll(i).unit_cd || '|' ||TO_CHAR(t_sua_enroll(i).uv_version_number)|| '|' ||
                                    p_teach_cal_type || '|' ||TO_CHAR(p_teach_ci_sequence_number) || '|' ||UPPER(l_enroll)|| '|' ||t_sua_enroll(i).unit_class || '|' ||
                                    t_sua_enroll(i).location_cd;
                       l_uoo_id := NULL;
                       l_action_processed := true;
                       SAVEPOINT sp_sua_blk_enr;
                       OPEN cur_get_uoo(t_sua_enroll(i).unit_cd,
                                           t_sua_enroll(i).uv_version_number,
                                           p_teach_cal_type,
                                           p_teach_ci_sequence_number,
                                           t_sua_enroll(i).unit_class,
                                           t_sua_enroll(i).location_cd);
                       FETCH cur_get_uoo INTO l_uoo_id,l_relation_type;
                       CLOSE cur_get_uoo;
                       --if uoo_id is null means that there is no offering exist for this combination.
                       IF l_uoo_id IS NULL THEN
                          igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                            p_sl_key           => cst_blk_ua,
                                                            p_sle_key          => l_unit_key,
                                                            p_sle_message_name => 'IGS_EN_UOO_NOT_EXISTS_PARAM',
                                                            p_text             => 'ERROR|'||cst_enrol);
                          l_action_processed := FALSE;
                          l_total_enrol_error_count := l_total_enrol_error_count + 1;
                       END IF;
                       -- Validate that the process has not been scheduled to run outside the
                       -- environment/variation windows for the teaching period.
                       --moved this code from the start of this procedure,to pass uoo_id  by smaddali

                       IF (l_action_processed AND igs_en_gen_008.enrp_get_var_window(p_cal_type =>   p_teach_cal_type,
                                                              p_ci_sequence_number =>   p_teach_ci_sequence_number,
                                                              p_effective_dt       =>   NVL(p_enrolled_dt,SYSDATE),
                                                              p_uoo_id             =>   l_uoo_id ) = FALSE) THEN
                          igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                            p_sl_key           => cst_blk_ua,
                                                            p_sle_key          => l_unit_key,
                                                            p_sle_message_name => 'IGS_EN_TRN_ERR_VAR_WIND',
                                                            p_text             => 'ERROR|'||cst_enrol);
                          l_action_processed := FALSE;
                          l_total_disc_not_enrol_count := l_total_disc_not_enrol_count +1;

                       END IF;

                       l_message_name := NULL;
                       -- If any IGS_PS_UNIT attempt is being enrolled then check if allowed to be created
                       -- within the enrolment window.

                       IF (l_action_processed AND igs_en_gen_004.enrp_get_rec_window(p_cal_type =>   p_teach_cal_type,
                                                              p_ci_sequence_number =>   p_teach_ci_sequence_number,
                                                              p_effective_date     =>   NVL(p_enrolled_dt,SYSDATE),
                                                              p_uoo_id             =>   l_uoo_id,
                                                              p_message_name       =>   l_message_name) = FALSE) THEN

                          igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                            p_sl_key           => cst_blk_ua,
                                                            p_sle_key          => l_unit_key,
                                                            p_sle_message_name => l_message_name,
                                                            p_text             => 'ERROR|'||cst_enrol);
                          l_action_processed := FALSE;
                          l_total_enrol_error_count := l_total_enrol_error_count + 1;

                       END IF;
                       l_unit_attempt_status := NULL;
                       OPEN cur_sua_stat(rec_sca.person_id,
                                         rec_sca.course_cd,
                                         l_uoo_id);
                       FETCH cur_sua_stat INTO l_unit_attempt_status;
                       CLOSE cur_sua_stat;
                       IF l_action_processed THEN
                       IF l_unit_attempt_status = cst_enrolled THEN
                           IGS_GE_INS_SLE.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                             p_sl_key           =>cst_blk_ua,
                                                             p_sle_key          =>l_unit_key,
                                                             p_sle_message_name =>'IGS_EN_UNITVER_ATTEMPTED_STUD',
                                                             p_text             =>'ERROR|' || cst_enrol);
                           l_total_enrol_error_count := l_total_enrol_error_count + 1;
                       ELSE
                            l_waitlist_ind := NULL;
                            l_unit_section_status := NULL;
                            --Following api checks the availbility of the seats for the given unit section.
                            igs_en_gen_015.get_usec_status(p_uoo_id                  =>l_uoo_id,
                                                           p_person_id               =>rec_sca.person_id,
                                                           p_unit_section_status     =>l_unit_section_status,
                                                           p_waitlist_ind            =>l_waitlist_ind,
                                                           p_load_cal_type           =>p_load_cal_type,
                                                           p_load_ci_sequence_number =>p_load_cal_seq,
                                                           p_course_cd               =>rec_sca.course_cd);
                            IF l_waitlist_ind IS NULL THEN
                               --There is no seates are available for this unit section.
                               igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       => cst_enr_blk_ua,
                                                                 p_sl_key           => cst_blk_ua,
                                                                 p_sle_key          => l_unit_key,
                                                                 p_sle_message_name => 'IGS_EN_SS_CANNOT_WAITLIST',
                                                                 p_text             => 'ERROR|'||cst_enrol);
                               l_action_processed := FALSE;
                               l_total_enrol_error_count := l_total_enrol_error_count + 1;

                            ELSE
                                l_message_name := NULL;
                                l_ret_stat:= NULL;

                                --  Check whether the profile is set or not
                                --  If it is set to 'Y' determine the value of core indicator otherwise assign NULL to it
                                IF fnd_profile.value('IGS_EN_CORE_VAL') = 'Y' THEN
                                    l_core_indicator_code := igs_en_gen_009.enrp_check_usec_core(rec_sca.person_id,rec_sca.course_cd,l_uoo_id);
                                 ELSE
                                    l_core_indicator_code := NULL;
                                 END IF;

                                --Following api will creates an unit attempt in unconfirm/waitlist status.
                                BEGIN
                                  igs_ss_en_wrappers.insert_into_enr_worksheet(p_person_number         =>l_person_number,
                                                                             p_course_cd             =>rec_sca.course_cd,
                                                                             p_uoo_id                =>l_uoo_id,
                                                                             p_waitlist_ind          =>l_waitlist_ind,
                                                                             p_session_id            =>NULL,
                                                                             p_return_status         =>l_ret_stat,
                                                                             p_message               =>l_message_name,
                                                                             p_cal_type              =>p_load_cal_type,
                                                                             p_ci_sequence_number    =>p_load_cal_seq,
                                                                             p_audit_requested       =>p_no_assessment_ind,
                                                                             p_enr_method            =>p_enr_method,
                                                                             p_override_cp           =>null,
                                                                             p_subtitle              =>null,
                                                                             p_gradsch_cd            =>null,
                                                                             p_gs_version_num        =>null,
                                                                             p_core_indicator_code   =>l_core_indicator_code, -- ptandon, Prevent Dropping Core Units build
                                                                             p_calling_obj           =>'JOB'
                                                                             );
                                EXCEPTION WHEN OTHERS THEN
                                  --If an exception is thrown, get the error message text and save it in the message name variable
                                  IF IGS_GE_MSG_STACK.COUNT_MSG <> 0 THEN
                                     l_message_name := FND_MESSAGE.GET;
                                  ELSE
                                     l_message_name := SQLERRM;
                                  END IF;
                                  l_ret_stat  := 'D';
                                END;

                                IF l_ret_stat = 'D' THEN
                                   log_error_message(p_messages =>l_message_name,
                                                     p_del      =>';',
                                                     p_key      =>l_unit_key,
                                                     p_type     =>'DENY',
                                                     p_c_u      =>'E');
                                   l_action_processed := FALSE;

                                ELSIF l_message_name IS NOT NULL THEN
                                      log_error_message(p_messages =>l_message_name,
                                                        p_del      =>';',
                                                        p_key      =>l_unit_key,
                                                        p_type     =>'WARN',
                                                        p_c_u      =>'E');
                                END IF; ---l_ret_stat = 'D'
                                IF l_action_processed THEN
                                     l_enrol_count := l_enrol_count + 1;
                                     l_sub_success:=NULL;l_sub_waitlist:=NULL;l_sub_failed:=NULL;
                                     IF l_ret_stat <> 'D' AND  l_relation_type='SUPERIOR' THEN
                                           --enroll subordinates if
                                         igs_en_val_sua.enr_sub_units(
                                                        p_person_id           => rec_sca.person_id,
                                                        p_course_cd           => rec_sca.course_cd,
                                                        p_uoo_id              => l_uoo_id,
                                                        p_waitlist_flag       => l_waitlist_ind,
                                                        p_load_cal_type       => p_load_cal_type,
                                                        p_load_seq_num        => p_load_cal_seq,
                                                        p_enrollment_date     => NVL(p_enrolled_dt,SYSDATE),
                                                        p_enrollment_method   => p_enr_method,
                                                        p_enr_uoo_ids         => l_enr_uoo_ids,
                                                        p_uoo_ids             => l_sub_success,
                                                        p_waitlist_uoo_ids    => l_sub_waitlist,
                                                        p_failed_uoo_ids      => l_sub_failed);

                                          IF l_sub_success IS NOT NULL THEN
                                            log_error_message(p_messages =>'IGS_EN_BLK_SUB_SUCCESS*'||igs_en_gen_018.enrp_get_unitcds(l_sub_success),
                                                              p_del      =>';',
                                                              p_key      =>l_unit_key,
                                                              p_type     =>'WARN',
                                                              p_c_u      =>'I');
                                            l_sub_success :=','||l_sub_success ;
                                          END IF;
                                          IF l_sub_failed IS NOT NULL THEN
                                             log_error_message(p_messages =>'IGS_EN_BLK_SUB_FAILED*'||igs_en_gen_018.enrp_get_unitcds(l_sub_failed),
                                                              p_del      =>';',
                                                              p_key      =>l_unit_key,
                                                              p_type     =>'WARN',
                                                              p_c_u      =>'I');
                                          END IF;
                                      END IF;-- if superior and if l_ret_stat <> 'D'


                                      IF l_waitlist_ind = 'Y' THEN
                                          igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                                            p_sl_key           =>cst_blk_ua,
                                                                            p_sle_key          =>l_unit_key,
                                                                            p_sle_message_name =>'IGS_EN_STUD_SUCCESS_WAIT_UNIT',
                                                                            p_text             =>'INFORMATION|' || cst_enrol);
                                      ELSE
                                           IF p_confirmed_ind <> 'Y' THEN
                                             l_succ_msg:='IGS_EN_UA_SECCESS_ADDED_STUD';
                                           ELSE
                                             l_succ_msg:='IGS_EN_STUD_SUCCESS_ENR_UNIT';
                                           END IF;
                                           igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                                     p_sl_key           =>cst_blk_ua,
                                                                     p_sle_key          =>l_unit_key,
                                                                     p_sle_message_name =>l_succ_msg,
                                                                     p_text             =>'INFORMATION|' || cst_enrol);
                                      END IF;

                                END IF; --l_action_processed
                            END IF; --l_waitlist_ind IS NULL
                       END IF; --l_unit_attempt_status = cst_enrolled
                       END IF; --l_action_processed
                       IF l_action_processed AND p_confirmed_ind = 'Y' AND l_ret_stat <>'D' AND (l_waitlist_ind = 'N' OR
                                                                                        l_unit_attempt_status = cst_unconfirm) THEN
                               l_uoo_ids_list:=l_uoo_ids_list||l_uoo_id||l_sub_success||',';
                       END IF;
                       IF NOT l_action_processed THEN
                            ROLLBACK TO sp_sua_blk_enr;
                       END IF;
                       l_message_name := NULL;
                       l_ret_stat:= NULL;
                   END LOOP;  ---i IN 1 .. l_cntr_enroll
                   IF p_confirmed_ind = 'Y' AND l_uoo_ids_list IS NOT NULL AND l_processed THEN
                          BEGIN
                          igs_ss_en_wrappers.validate_enroll_validate(p_person_id               =>rec_sca.person_id,
                                                                      p_load_cal_type           =>p_load_cal_type,
                                                                      p_load_ci_sequence_number =>p_load_cal_seq,
                                                                      p_uoo_ids                 =>substr(l_uoo_ids_list,1,length(l_uoo_ids_list)-1) ,  --remove trailing ','
                                                                      p_program_cd              =>rec_sca.course_cd,
                                                                      p_message_name            =>l_message_name,
                                                                      p_deny_warn               =>l_deny_warn,
                                                                      p_return_status           =>l_ret_stat,
                                                                      p_enr_method              =>p_enr_method,
                                                                      p_enrolled_dt             =>NVL(p_enrolled_dt,SYSDATE));
                          EXCEPTION WHEN OTHERS THEN
                          --IF any exception is raised, return the exception string as the error message
                              IF IGS_GE_MSG_STACK.COUNT_MSG <> 0 THEN
                                l_message_name := FND_MESSAGE.GET;
                              ELSE
                                l_message_name := SQLERRM;
                              END IF;
                              l_deny_warn := 'DENY';
                              l_ret_stat  := 'FALSE';
                          END;

                          IF l_ret_stat = 'FALSE' AND l_deny_warn ='DENY' THEN
                             IGS_GE_INS_SLE.genp_set_log_cntr;
                              log_error_message(p_messages =>l_message_name,
                                                p_del      =>';',
                                                p_key      =>l_course_key,
                                                p_type     =>'DENY',
                                                p_c_u      =>'E');
                             l_processed := FALSE;
                           ELSIF l_message_name IS NOT NULL THEN
                               log_error_message(p_messages =>l_message_name,
                                                 p_del      =>';',
                                                 p_key      =>l_course_key,
                                                 p_type     =>'WARN',
                                                 p_c_u      =>'E');
                          END IF;
                   END IF;  --- p_confirmed_ind = 'Y' AND l_waitlist_ind IS NOT NULL
           END IF;
           /**********************************************************************************************************************
                        Perform the mincp,forceattd,coreq and prereq validations if it is not processed
           **********************************************************************************************************************/
           IF p_confirmed_ind = 'Y' AND l_cntr_enroll > 0 AND l_processed THEN
                   FOR i IN 1 .. l_cntr_disc
                   LOOP
                   IF l_processed THEN
                      l_unit_key := TO_CHAR(rec_sca.person_id)|| '|' || rec_sca.course_cd  || '|' ||t_sua_disc(i).unit_cd || '|' ||TO_CHAR(t_sua_disc(i).uv_version_number)|| '|' ||
                                    p_teach_cal_type || '|' ||TO_CHAR(p_teach_ci_sequence_number) || '|' ||UPPER(l_enroll)|| '|' ||t_sua_disc(i).unit_class || '|' ||
                                    t_sua_disc(i).location_cd;
                      FOR rec_get_sua_d IN cur_get_sua_d( rec_sca.person_id,
                                          rec_sca.course_cd,
                                          t_sua_disc(i).unit_cd,
                                          t_sua_disc(i).uv_version_number,
                                          p_teach_cal_type,
                                          p_teach_ci_sequence_number,
                                          t_sua_disc(i).unit_class,
                                          t_sua_disc(i).location_cd)
                      LOOP
                        SAVEPOINT sp_sua_blk_disc1; -- savepoint for  unit validation failure.
                        l_action_processed := TRUE;
                        -- if the uoo_id selected is not one of validation faied uoo_ids, then process it.
                        IF (INSTR(l_failed_uoo_ids,','||rec_get_sua_d.uoo_id||',',1) = 0 OR l_failed_uoo_ids IS NULL) THEN
                                IF igs_en_gen_008.enrp_get_ua_del_alwd(p_cal_type                 => p_teach_cal_type,
                                                             p_ci_sequence_number       => p_teach_ci_sequence_number,
                                                             p_effective_dt             => NVL(p_discontinued_dt,SYSDATE),
                                                             p_uoo_id                   => rec_get_sua_d.uoo_id) = 'N' THEN

                                l_message_name:=NULL;
                                l_message_token:=NULL;
                                        IF igs_en_val_sua.enrp_val_discont_aus(p_administrative_unit_status     => p_administrative_unit_status,
                                                               p_discontinued_dt                => NVL(p_discontinued_dt,SYSDATE),
                                                               p_cal_type                       => p_teach_cal_type,
                                                               p_ci_sequence_number             => p_teach_ci_sequence_number,
                                                               p_message_name                   => l_message_name,
                                                               p_uoo_id                         => rec_get_sua_d.uoo_id,
                                                               p_message_token                  => l_message_token,
                                                               p_legacy                         => 'N') = FALSE THEN
                                                l_temp_msg:=NULL;
                                                fnd_message.set_name('IGS',l_message_name);
                                                IF l_message_name = 'IGS_SS_EN_INVLD_ADMIN_UNITST' THEN
                                                        fnd_message.set_token('LIST',l_message_token);
                                                END IF;
                                                l_temp_msg:=fnd_message.get;
                                                fnd_file.put_line(Fnd_File.LOG,l_temp_msg);
                                                IGS_GE_INS_SLE.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                                        p_sl_key           =>cst_blk_ua,
                                                                        p_sle_key          =>l_course_key,
                                                                        p_sle_message_name =>l_message_name,
                                                                        p_text             =>'ERROR|'||l_temp_msg);
                                                l_action_processed := FALSE;
                                                l_total_encumb_error_count := l_total_encumb_error_count + 1;

                                        END IF;
                                END IF;
                                IF NVL(rec_get_sua_d.relation_type,'NONE')='SUPERIOR' AND l_action_processed THEN
                                        l_message_name:= NULL;
                                        igs_en_val_sua.drop_sub_units(
                                                  p_person_id        => rec_sca.person_id  ,
                                                  p_course_cd        => rec_sca.course_cd   ,
                                                  p_uoo_id           => rec_get_sua_d.uoo_id ,
                                                  p_load_cal_type    => p_load_cal_type  ,
                                                  p_load_seq_num     => p_load_cal_seq  ,
                                                  p_acad_cal_type    => l_acad_cal_type  ,
                                                  p_acad_seq_num     => l_acad_ci_sequence_number  ,
                                                  p_enrollment_method=> p_enr_method  ,
                                                  p_confirmed_ind    => NULL ,                             --Do not drop...just validate
                                                  p_person_type      => l_person_type,
                                                  p_effective_date   => NVL(p_discontinued_dt,SYSDATE)  ,
                                                  p_course_ver_num   =>rec_sca.version_number,
                                                  p_dcnt_reason_cd   => p_dcnt_reason_cd,
                                                  p_admin_unit_status=> p_administrative_unit_status,
                                                  p_uoo_ids          => l_uoo_ids_list ,
                                                  p_error_message    => l_message_name);
                                        IF l_message_name IS NOT NULL THEN
                                          IGS_GE_INS_SLE.genp_set_log_cntr;
                                          log_error_message(p_messages =>'IGS_EN_BLK_SUB_DROP_FAILED',
                                                            p_del      =>';',
                                                            p_key      =>l_course_key,
                                                            p_type     =>'DENY',
                                                            p_c_u      =>'D');
                                          l_processed := FALSE;
                                          EXIT;
                                        END IF;
                                END IF;


                             IF l_action_processed THEN
                                     l_message_name:= NULL;
                                     l_return_status := TRUE;
                                     igs_ss_en_wrappers.blk_drop_units(p_uoo_id                =>rec_get_sua_d.uoo_id,
                                                               p_person_id             =>rec_sca.person_id,
                                                               p_person_type           =>l_person_type,
                                                               p_load_cal_type         =>p_load_cal_type,
                                                               p_load_sequence_number  =>p_load_cal_seq,
                                                               p_acad_cal_type         =>l_acad_cal_type,
                                                               p_acad_sequence_number  =>l_acad_ci_sequence_number,
                                                               p_program_cd            =>rec_sca.course_cd,
                                                               p_program_version       =>rec_sca.version_number,
                                                               p_dcnt_reason_cd        =>p_dcnt_reason_cd,
                                                               p_admin_unit_status     =>p_administrative_unit_status,
                                                               p_effective_date        =>p_discontinued_dt,
                                                               p_enrolment_cat         =>l_enrolment_cat,
                                                               p_comm_type             =>l_commencement_type,
                                                               p_enr_meth_type         =>p_enr_method,
                                                               p_total_credit_points   =>l_total_credit_points,
                                                               p_force_att_type        =>l_att_type,
                                                               p_val_ovrrd_chk         =>'N', --Performs the mincp,forceattd,coreq and prereq validations.
                                                               p_ovrrd_drop            =>'Y', --Overrides the unit drop
                                                               p_return_status         =>l_return_status,
                                                               p_message               =>l_message_name,
                                                               p_sub_unit              => 'N');
                                     IF NOT l_return_status THEN
                                        IGS_GE_INS_SLE.genp_set_log_cntr;
                                        log_error_message(p_messages =>l_message_name,
                                                          p_del      =>';',
                                                          p_key      =>l_course_key,
                                                          p_type     =>'DENY',
                                                          p_c_u      =>'D');
                                        l_processed := FALSE;
                                        EXIT;
                                     ELSIF l_message_name IS NOT NULL THEN
                                           log_error_message(p_messages =>l_message_name,
                                                             p_del      =>';',
                                                             p_key      =>l_course_key,
                                                             p_type     =>'WARN',
                                                             p_c_u      =>'D');
                                     END IF;
                                     igs_ge_ins_sle.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                                       p_sl_key           =>cst_blk_ua,
                                                                       p_sle_key          =>l_unit_key,
                                                                       p_sle_message_name =>'IGS_EN_SUA_DISCONTINUED', -- Discontinue
                                                                       p_text             =>'INFORMATION|' || cst_discontin);
                             ELSE -- unit validation failed

                                   ROLLBACK TO sp_sua_blk_disc1;
                             END IF; -- l_action_processed
                          END IF; -- failed_uoo_ids
                      END LOOP; -- rec_get_sua_d
                   END IF; ---l_processed
                   IF NOT l_processed THEN
                        EXIT;
                   END IF;
                   END LOOP; --i IN 1 .. l_cntr_disc
           END IF; --p_confirmed_ind = 'Y' AND l_processed
           IF NOT l_processed THEN  -- if program validation fails
              ROLLBACK TO sp_sua_blk_e_d;
              IGS_GE_INS_SLE.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                   p_sl_key           =>cst_blk_ua,
                                   p_sle_key          =>l_course_key,
                                   p_sle_message_name =>'IGS_EN_BLK_CHG_UNDO',
                                   p_text             =>'ERROR|ENROL');

           ELSE
              l_total_enrol_count:= l_total_enrol_count + l_enrol_count;
              l_total_disc_count := l_total_disc_count + l_disc_count;
           END IF;
        EXCEPTION
        WHEN e_resource_busy_exception THEN
                -- Roll back transaction.
                ROLLBACK TO sp_sua_blk_e_d;
                fnd_file.put_line(Fnd_File.LOG,sqlerrm);
                -- Log that a locked record exists and rollback has occurred.
                IGS_GE_INS_SLE.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                  p_sl_key           =>cst_blk_ua,
                                                  p_sle_key          =>l_course_key,
                                                  p_sle_message_name =>'IGS_EN_ALLALT_APPL_STUD_PRG',
                                                  p_text             =>'ERROR|LOCK');
                -- Add to count and continue processing.
                l_total_lock_count := l_total_lock_count + 1;
        WHEN OTHERS THEN
                -- Roll back transaction.
                ROLLBACK TO sp_sua_blk_e_d;
                fnd_file.put_line(Fnd_File.LOG,sqlerrm);
                l_encoded_msg := fnd_message.get_encoded;
                fnd_message.parse_encoded(l_encoded_msg,l_app_sht_name,l_msg_name);
                IF l_msg_name IS NULL THEN
                   l_msg_name := 'IGS_EN_PRG_ROLLBCK_UNEXP';
                END IF;
                -- Log that a unhandled exception raised and rollback has occurred.
                IGS_GE_INS_SLE.genp_set_log_entry(p_s_log_type       =>cst_enr_blk_ua,
                                                  p_sl_key           =>cst_blk_ua,
                                                  p_sle_key          =>l_course_key,
                                                  p_sle_message_name =>l_msg_name,
                                                  p_text             =>'ERROR|ENROL');
                l_total_encumb_error_count := l_total_encumb_error_count + 1;
        END;  -- exception handler.
        IGS_GE_INS_SLE.genp_ins_sle(l_creation_dt);
        END LOOP;
        IGS_GE_INS_SLE.genp_set_log_cntr;
        -- Log the summary counts
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_ATTEMPTS')||'|'||TO_CHAR(l_total_exist_sua_count));

        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_PRG_ERR_COUNT')||'|'||TO_CHAR(l_total_course_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_PRG_WRN_COUNT')||'|'||TO_CHAR(l_total_course_warn_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_DIS_ERR_VAR_WIN')||'|'||TO_CHAR(l_total_disc_not_enrol_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_ATT_CRE')||'|'||TO_CHAR(l_total_enrol_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_ENR_ERR')||'|'||TO_CHAR(l_total_enrol_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_ERN_WRN')||'|'||TO_CHAR(l_total_enrol_warn_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_DIS_UNIT')||'|'||TO_CHAR(l_total_disc_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_DIS_ERROR')||'|'||TO_CHAR(l_total_disc_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_E_D_TOT_DIS_WARN')||'|'||TO_CHAR(l_total_disc_warn_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_ENCUM_COUNT')||'|'||TO_CHAR(l_total_encumb_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                                p_s_log_type       =>cst_enr_blk_ua,
                                p_sl_key           =>cst_blk_ua,
                                p_sle_key          =>cst_summary,
                                p_sle_message_name =>NULL,
                                p_text             =>FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_PRG_LCK_COUNT')||'|'||TO_CHAR(l_total_lock_count));
        -- Insert the log entries
        IGS_GE_INS_SLE.genp_ins_sle(l_creation_dt);
        p_creation_dt := l_creation_dt;
END Enrp_Prc_Sua_Blk_E_D;

-- procedure is used to store all the reference codes values
-- for the source unit attempt
PROCEDURE enrp_store_suar(p_person_id IN NUMBER,
                          p_course_cd IN VARCHAR2,
                          p_from_uoo_id IN NUMBER)
IS

 Cursor cur_sua_ref_cds(cp_person_id NUMBER,
                        cp_course_cd VARCHAR2,
                        cp_uoo_id NUMBER) IS
  Select suar.reference_code_id,
         suar.reference_cd_type,
         suar.reference_cd,
         suar.applied_course_cd
  From IGS_AS_SUA_REF_CDS suar
  Where suar.person_id = cp_person_id
  And   suar.course_cd = cp_course_cd
  And   suar.uoo_id = cp_uoo_id
  And   suar.deleted_date IS NULL;

  l_count NUMBER;

BEGIN
    l_count := 0;

    suar_table := empty_suar_table;

    FOR v_cur_sua_ref_cds IN cur_sua_ref_cds(p_person_id,p_course_cd,p_from_uoo_id) LOOP
      l_count := l_count + 1;
      suar_table(l_count).person_id := p_person_id;
      suar_table(l_count).course_cd := p_course_cd;
      suar_table(l_count).uoo_id    := p_from_uoo_id;
      suar_table(l_count).reference_code_id := v_cur_sua_ref_cds.reference_code_id;
      suar_table(l_count).reference_cd_type := v_cur_sua_ref_cds.reference_cd_type;
      suar_table(l_count).reference_cd := v_cur_sua_ref_cds.reference_cd;
      suar_table(l_count).applied_course_cd := v_cur_sua_ref_cds.applied_course_cd;
    END LOOP;


END enrp_store_suar;

--This procedure is to copy the stored values of the source
--unit attmept reference codes, to the destination unit attempt
PROCEDURE enrp_copy_suar(p_to_uoo_id IN NUMBER)
IS

 l_rowid VARCHAR2(25);
 l_suarid IGS_AS_SUA_REF_CDS.suar_id%TYPE;

BEGIN

 FOR l_count IN 1..suar_table.COUNT LOOP
    igs_as_sua_ref_cds_pkg.insert_row (
      x_rowid                  => l_rowid,
      x_suar_id                => l_suarid,
      x_person_id              => suar_table(l_count).person_id,
      x_course_cd              => suar_table(l_count).course_cd,
      x_uoo_id                 => p_to_uoo_id,
      x_reference_code_id      => suar_table(l_count).reference_code_id,
      x_reference_cd_type      => suar_table(l_count).reference_cd_type,
      x_reference_cd           => suar_table(l_count).reference_cd,
      x_applied_course_cd      => suar_table(l_count).applied_course_cd,
      x_deleted_date           => NULL);

 END LOOP;

END enrp_copy_suar;


PROCEDURE enrp_prc_sua_blk_trn(
  p_teach_cal_type           IN VARCHAR2,
  p_teach_ci_sequence_number IN NUMBER ,
  p_course_cd                IN VARCHAR2,
  p_location_cd              IN VARCHAR2,
  p_attendance_type          IN VARCHAR2,
  p_attendance_mode          IN VARCHAR2,
  p_group_id                 IN NUMBER ,
  p_from_unit_cd             IN VARCHAR2,
  p_from_uv_version_number   IN NUMBER ,
  p_from_location_cd         IN VARCHAR2,
  p_from_unit_class          IN VARCHAR2,
  p_unit_attempt_status1     IN VARCHAR2,
  p_unit_attempt_status2     IN VARCHAR2,
  p_unit_attempt_status3     IN VARCHAR2,
  p_to_uv_version_number     IN NUMBER ,
  p_to_location_cd           IN VARCHAR2,
  p_to_unit_class            IN VARCHAR2,
  p_creation_dt              IN OUT NOCOPY DATE,
  p_enforce_val              IN VARCHAR2,
  p_enroll_method            IN VARCHAR2,
  p_reason                   IN VARCHAR2)
 AS
/*------------------------------------------------------------------------------------------
  --Created by  : knaraset, Oracle IDC
  --Date created:
  --
  --Purpose:
  -- enrp_prc_sua_blk_trn
  -- The process transfers already enrolled (or unconfirmed) students
  -- between IGS_PS_UNIT offering options within an already selected IGS_PS_UNIT attempt.
  -- This may include a change to version_number, IGS_AD_LOCATION code, IGS_PS_UNIT class
  -- or a combination thereof.
  -- This is typically used as the result of the shutting of a version, or
  -- the altering of the IGS_PS_UNIT offerings of the IGS_OR_INSTITUTION. eg. a IGS_PS_UNIT which
  -- due to lack of numbers is no longer offered at a campus ? all of the
  -- students which are enrolled need be transferred to a different campus.
  -- The teaching calendar cannot be changed as this is not within the scope
  -- of simply changing the option. This is in effect doing an
  -- enrolment/discontinuation which should be handled through that process.
  -- IGS_GE_NOTE: This module will be called from an exception report ENRR4500.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ayedubat   18-APR-2002      Changed the usage of 'course' to 'program' in the log entry of summary columns
  --                           (ie 'Total course errors' to 'Total Program errors etc.)
  --kkillams   03-10-2002       1)Three new parameters are added to the procedure
  --                            New validation
  --                            1)Checking the availbility of seats in destination unit section
  --                            2)Validating the grading schema against the destination unit section
  --                            3)Validating the override credit points against the destination unit section
  --                            4)Validating the co-requisite rule against the destination unit section
  --                            5)Validating the pre-requisite rule against the destination unit section
  --                            6)Validating the destination unit section Special permission
  --                            7)Validating the Time Conflict against the destination unit section
  --                            8)Validating the unit incompatible against the destination unit section
  --                            9)Validating the program Min/Max Credit point validation
  --                            10)Validating the unit repeat  against the destination unit section
  --                            11)Validating the examination details between source and destination.
  --                            to the enrpl_upd_sua_uoo procedure.
  --                            w.r.t. Drop Transfer workflow notification Build, bug#2599925
  --svenkata  28-Oct-02        Calculate the Total enrolled Credit points of the student before Transfer .
  --                            Modify the call to the fn eval_min_cp to pass the total enr CP.
  --                            The signature of the routine enrpl_upd_sua_uoo has been modified to add Acad Cal dtls.
  --Nishikant    01NOV2002     SEVIS Build. Enh Bug#2641905. Two new parameters p_person_id, p_message
  --                           added to the calls igs_ss_enr_details.get_notification.
  --svenkata  22-Dec-02        Bug # 2686793 - Added a call to routine igs_en_elgbl_program.eval_unit_forced_type to enforce
  --                           to enforce Attendance Type validations on transferring a unit.The validation is done after the
  --                           unit is dropped.If validation fails(ERROR),transferred record is rolled back.If a warning is encountered,
  --                           the warning message is logged.Transfer is completed successfully.
  --kkillams  07-Jan-03        Logging new error message when source and destination unit section are same.
  --                           w.r.t. bug no: 2711193
  --svenkata    7-Jan-03      Incorporated the logic for 'When first Reach Attendance Type'. The routine enrp_val_coo_att is being called to get the
                              Att Typ before updating the CP.The  routine eval_unit_forced_type is then called called to evaluate with the
                              fetched value-Bug#2737263
  -- pradhakr   20-Jan-2003  Added a parameter no_assessment_ind to the procedue call IGS_EN_VAL_SUA.enrp_val_sua_ovrd_cp
  --                         as part of ENCR26 build.
  --rvivekan   22-oct-2003   Placements build#3052438. Added code to sort the usecs based on relation_type. Also added handling
  --                         to enroll subordinates when a superior is enrolled and to drop subordinates when a superior is dropped
  --  vkarthik 13-Feb-04     Waitlist priority/prefernce weightages were not passed to the API and hence
  --                         waitlist position was not getting calculated, modified to pass the weightages as part bug 3433446


  -------------------------------------------------------------------------------------------- */
BEGIN
  DECLARE
        e_resource_busy_exception               EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
        cst_enr_blk_uo          CONSTANT VARCHAR2(10) := 'ENR-BLK-UO';
        cst_unit_rule_check     CONSTANT VARCHAR2(15) := 'UNIT-RULE-CHECK';
        cst_rule_check          CONSTANT VARCHAR2(10) := 'RULE-CHECK';
        cst_invalid             CONSTANT VARCHAR2(10) := 'INVALID';
        cst_error               CONSTANT VARCHAR2(10) := 'ERROR';
        cst_att_valid           CONSTANT VARCHAR2(10) := 'ATT-VALID';
        cst_information         CONSTANT VARCHAR2(12) := 'INFORMATION';
        cst_changed             CONSTANT VARCHAR2(10) := 'CHANGED';
        cst_warning             CONSTANT VARCHAR2(10) := 'WARNING';
        cst_att_date            CONSTANT VARCHAR2(10) := 'ATT-DATE';
        cst_superior            CONSTANT VARCHAR2(10) := 'SUPERIOR';
        cst_encumb              CONSTANT VARCHAR2(10) := 'ENCUMB';
        cst_summary             CONSTANT VARCHAR2(10) := 'SUMMARY';
        cst_blk_uoo             CONSTANT VARCHAR2(34) := 'BULK UNIT OFFERING OPTION TRANSFER';
        l_deny_enrollment                   VARCHAR2(1);

        -- cursor considers the term records which is fetching the student unit attempts based
        -- on the given criteria for unit section transfer
        CURSOR c_sua (cp_load_Cal_type IGS_CA_INST.CAL_TYPE%TYPE
                      , cp_load_ci_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE)IS
                SELECT  sua.person_id,
                        sua.course_cd,
                        sua.location_cd,
                        sua.unit_class,
                        sua.unit_attempt_status,
                        sua.enrolled_dt,
                        sca.coo_id,
                        sua.version_number,
                        sca.version_number program_version_number,
                        sua.uoo_id
                FROM
                        igs_en_su_attempt sua,
                        igs_en_stdnt_ps_att sca
                WHERE (
                        (p_course_cd IS NULL OR sca.course_cd LIKE p_course_cd)                                         AND
                        (sca.course_attempt_status NOT IN ('LAPSED','DISCONTIN'))                                       AND
                        (p_location_cd IS NULL OR
                          p_location_cd = igs_en_spa_terms_api.get_spat_location(
                                sca.person_id, sca.course_cd, cp_load_cal_type, cp_load_ci_sequence_number))        AND
                        (p_attendance_mode IS NULL OR
                          p_attendance_mode = igs_en_spa_terms_api.get_spat_att_mode(
                                sca.person_id, sca.course_cd, cp_load_cal_type, cp_load_ci_sequence_number))        AND
                        (p_attendance_type IS NULL OR
                          p_attendance_type = igs_en_spa_terms_api.get_spat_att_type(
                                sca.person_id, sca.course_cd, cp_load_cal_type, cp_load_ci_sequence_number))        AND
                        sca.person_id                   =       sua.person_id                                           AND
                        sca.course_cd                   =       sua.course_cd                                           AND
                        sua.unit_cd                     =       p_from_unit_cd                                          AND
                        (p_from_uv_version_number IS NULL OR
                                sua.version_number      =       p_from_uv_version_number)                               AND
                        sua.cal_type                    =       p_teach_cal_type                                        AND
                        sua.ci_sequence_number          =       p_teach_ci_sequence_number                              AND
                        (p_from_location_cd IS NULL OR
                                sua.location_cd         =       p_from_location_cd)                                     AND
                        (p_from_unit_class IS NULL OR
                                sua.unit_class          =       p_from_unit_class)                                      AND
                        sua.unit_attempt_status IN (
                                                        p_unit_attempt_status1,
                                                        NVL(p_unit_attempt_status2, p_unit_attempt_status1),
                                                        NVL(p_unit_attempt_status3, p_unit_attempt_status1))            AND
                        (p_group_id IS NULL OR
                                EXISTS (
                                        SELECT 'X'
                                        FROM igs_pe_prsid_grp_mem pigm
                                        WHERE
                                                pigm.group_id   =       p_group_id AND
                                                pigm.person_id  =       sca.person_id AND
                                                (pigm.end_date IS NULL OR pigm.end_date >= trunc(sysdate)) AND
                                                (pigm.start_date IS NULL OR pigm.start_date <= trunc(sysdate))
                        )))
                        ORDER BY
                                sua.unit_cd, sua.enrolled_dt;

        CURSOR c_sle (
                cp_rule_creation_dt             DATE) IS
                SELECT  sle.key,
                        sle.message_name,
                        sle.text
                FROM    IGS_GE_S_LOG_ENTRY sle
                WHERE   sle.s_log_type  = cst_enr_blk_uo AND
                        sle.creation_dt = cp_rule_creation_dt
                ORDER BY sle.sequence_number;
        CURSOR c_sle_del (
                cp_rule_creation_dt             DATE) IS
                SELECT  rowid,'x'
                FROM    IGS_GE_S_LOG_ENTRY
                WHERE   s_log_type      = cst_enr_blk_uo AND
                        creation_dt     = cp_rule_creation_dt
                FOR UPDATE OF LAST_UPDATED_BY NOWAIT;
        v_sle_del_exists        VARCHAR2(1) ;
        CURSOR c_sl_del (
                cp_rule_creation_dt             DATE) IS
                SELECT  rowid,'x'
                FROM    IGS_GE_S_LOG
                WHERE   s_log_type      = cst_enr_blk_uo AND
                        creation_dt     = cp_rule_creation_dt
                FOR UPDATE OF LAST_UPDATED_BY NOWAIT;

        --Cursor to get the load calendar for a given teach calendar
        CURSOR cur_load1 IS
        SELECT    tl.load_cal_type ,
                  tl.load_ci_sequence_number
        FROM      igs_ca_teach_to_load_v tl,
                  IGS_CA_INST ci,
                  IGS_CA_STAT cs
        WHERE     tl.teach_cal_type           =  p_teach_cal_type
        AND       tl.teach_ci_sequence_number =  p_teach_ci_sequence_number
        AND       ci.cal_type = tl.load_cal_type
        AND       ci.sequence_number = tl.load_ci_sequence_number
        AND       ci.cal_status = cs.cal_status
        AND       cs.s_cal_status = 'ACTIVE'
        ORDER BY  load_start_dt ASC;

        v_sl_del_exists         VARCHAR2(1) ;
        -- counter variables
        v_total_sua_count               NUMBER := 0;
        v_total_sua_error_count         NUMBER := 0;
        v_total_encumb_error_count      NUMBER := 0;
        v_total_sua_warn_count          NUMBER := 0;
        v_total_sua_trnsfr_count        NUMBER := 0;
        v_total_course_error_count      NUMBER := 0;
        v_total_course_warn_count       NUMBER := 0;
        v_error_count                   NUMBER := 0;
        v_warn_count                    NUMBER := 0;
        v_sua_trnsfr_count              NUMBER := 0;
        v_total_lock_count              NUMBER := 0;
        -- output variables
        v_acad_cal_type                 IGS_CA_INST.cal_type%TYPE ;
        v_acad_ci_sequence_number       IGS_CA_INST.sequence_number%TYPE ;
        v_acad_ci_start_dt              IGS_CA_INST.start_dt%TYPE ;
        v_acad_ci_end_dt                IGS_CA_INST.end_dt%TYPE ;
        v_message_name                  Varchar2(30) ;
        v_teach_start_dt                IGS_CA_INST.start_dt%TYPE ;
        v_teach_end_dt                  IGS_CA_INST.end_dt%TYPE ;
        v_to_uv_version_number          IGS_EN_SU_ATTEMPT.version_number%TYPE := 0;
        v_to_location_cd                IGS_EN_SU_ATTEMPT.location_cd%TYPE ;
        v_to_unit_class                 IGS_EN_SU_ATTEMPT.unit_class%TYPE ;
        v_rollback_occurred             BOOLEAN := FALSE;
        v_processing_occurred           BOOLEAN :=FALSE;
        v_error_occurred                BOOLEAN := FALSE;
        v_validation_error              BOOLEAN := FALSE;
        v_course_key                    VARCHAR2(255) ;
        v_text                          VARCHAR2(255) ;
        v_fail_type                     VARCHAR2(10) ;
        v_alt_cd                        VARCHAR2(255) ; -- return parameter, useless
        v_rule_creation_dt              DATE ;
        v_creation_dt                   IGS_GE_S_LOG.creation_dt%TYPE ;

        l_enrolment_cat                 IGS_PS_TYPE.ENROLMENT_CAT%TYPE;
        l_commencement_type             VARCHAR2(20) DEFAULT NULL;
        l_en_cal_type                   IGS_CA_INST.CAL_TYPE%TYPE;
        l_en_ci_seq_num                 IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
        l_person_type                   IGS_PE_PERSON_TYPES.person_type_code%TYPE;
        l_waitlist_flag                 VARCHAR2(1) DEFAULT 'N';
        l_load_cal_type                 IGS_CA_INST.CAL_TYPE%TYPE;
        l_load_seq_number               IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
        l_unit_attempt_status           IGS_EN_SU_ATTEMPT.UNIT_ATTEMPT_STATUS%TYPE;
        l_destination_uoo_id            IGS_EN_SU_ATTEMPT.UOO_ID%TYPE;
        l_dummy1                        VARCHAR2(30);
        l_dummy2                        VARCHAR2(30);
        l_dummy                         VARCHAR2(200);

        PROCEDURE enrpl_upd_sua_uoo(
                p_person_id                     IGS_EN_SU_ATTEMPT.person_id%TYPE,
                p_course_cd                     IGS_PS_VER.course_cd%TYPE,
                p_version_number                IGS_PS_UNIT_VER.version_number%TYPE, --program version
                p_u_version_number              IGS_PS_UNIT_VER.version_number%TYPE, --unit version
                p_from_uoo_id                   IGS_EN_SU_ATTEMPT.UOO_ID%TYPE,
                p_teach_end_dt                  IGS_CA_INST.end_dt%TYPE,
                p_location_cd                   IGS_AD_LOCATION.location_cd%TYPE,
                p_unit_class                    IGS_AS_UNIT_CLASS.unit_class%TYPE,
                p_unit_attempt_status           IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE,
                p_enrolled_dt                   IGS_EN_SU_ATTEMPT.enrolled_dt%TYPE,
                p_to_uv_version_number          IGS_PS_UNIT_VER.version_number%TYPE,
                p_to_location_cd                IGS_AD_LOCATION.location_cd%TYPE,
                p_to_unit_class                 IGS_AS_UNIT_CLASS.unit_class%TYPE,
                p_sua_error_count               IN OUT NOCOPY  NUMBER,
                p_sua_warn_count                IN OUT NOCOPY  NUMBER,
                p_sua_trnsfr_count              IN OUT NOCOPY  NUMBER,
                p_processing_occurred           IN OUT NOCOPY  BOOLEAN,
                p_person_type                   IN  VARCHAR2,
                p_enrolment_cat                 IN  VARCHAR2,
                p_commencement_type             IN  VARCHAR2,
                p_enforce_val                   IN  VARCHAR2,
                p_enroll_meth                   IN  VARCHAR2,
                p_reason                        IN  VARCHAR2,
                p_load_cal_type                 IN  VARCHAR2,
                p_load_seq_number               IN  NUMBER,
                p_waitlist_flag                 OUT NOCOPY VARCHAR2,
                p_destination_uoo_id            IN  OUT NOCOPY IGS_EN_SU_ATTEMPT.UOO_ID%TYPE,
                p_acad_cal_type                 IN  VARCHAR2,
                p_acad_seq_number               IN  NUMBER )
         AS
         /*
          Who      What        when
          sarakshi 28-Jul-2003 Enh#2930935,modified cursor c_unit_enroll_cp,such that it picks enrolled
                               credit points from usec level if exists else from unit level also modified
                               the usage of the cursor apprpriately
         */

        BEGIN   -- enrpl_upd_sua_uoo
                -- Local procedure to process the transfer of IGS_PS_UNIT offering option.
        DECLARE
                cst_unconfirm           CONSTANT VARCHAR2(10) := 'UNCONFIRM';
                cst_waitlisted          CONSTANT VARCHAR2(10) := 'WAITLISTED';
                cst_duplicate           CONSTANT VARCHAR2(10) := 'DUPLICATE';
                cst_transferred         CONSTANT VARCHAR2(12) := 'TRANSFERRED';
                cst_active              CONSTANT VARCHAR2(10) := 'ACTIVE';
                CURSOR c_uoo IS
                        SELECT  uoo.uoo_id, uoo.reserved_seating_allowed
                        FROM    IGS_PS_UNIT_OFR_OPT uoo
                        WHERE   uoo.unit_cd             = p_from_unit_cd AND
                                uoo.version_number      = p_to_uv_version_number AND
                                uoo.cal_type            = p_teach_cal_type AND
                                uoo.ci_sequence_number  = p_teach_ci_sequence_number AND
                                uoo.location_cd         = p_to_location_cd AND
                                uoo.unit_class          = p_to_unit_class AND
                                uoo.offered_ind         = 'Y';

                CURSOR c_uv IS
                        SELECT  us.s_unit_status,
                                uv.expiry_dt
                        FROM    IGS_PS_UNIT_VER         uv,
                                IGS_PS_UNIT_STAT        us
                        WHERE   uv.unit_cd              = p_from_unit_cd AND
                                uv.version_number       = p_to_uv_version_number AND
                                us.UNIT_STATUS          = uv.UNIT_STATUS;
                v_uv_rec        c_uv%ROWTYPE;

                --Cursor to get the unit attempt attributes for a student unit attempt
                CURSOR cur_f_unit IS
                SELECT
                      grading_schema_code,
                      gs_version_number,
                      override_enrolled_cp,
                      no_assessment_ind
                FROM IGS_EN_SU_ATTEMPT
                WHERE person_id  = p_person_id
                AND   course_cd  = p_course_cd
                AND   uoo_id     = p_from_uoo_id;
                rec_f_unit    cur_f_unit%ROWTYPE;

                --Cursor to get the unit's enrolled_credit_points
                CURSOR c_unit_enroll_cp(cp_uoo_id   IN NUMBER) IS
                SELECT
                     NVL(cps.enrolled_credit_points,uv.enrolled_credit_points) enrolled_credit_points
                FROM IGS_PS_UNIT_OFR_OPT uoo,
                     IGS_PS_UNIT_VER uv,
                     IGS_PS_USEC_CPS cps
                WHERE  uoo.uoo_id = cps.uoo_id(+) AND
                       uoo.unit_cd = uv.unit_cd  AND
                       uoo.version_number = uv.version_number AND
                       uoo.uoo_id = cp_uoo_id;
                r_unit_enroll_cp c_unit_enroll_cp%ROWTYPE;
                r_unit_enroll_cp_1 c_unit_enroll_cp%ROWTYPE;

                --Cursor to get the examination details of an unit section.
                CURSOR cur_exam_loc(cp_uoo_id igs_ps_usec_as.uoo_id%TYPE)
                IS SELECT * FROM igs_ps_usec_as
                WHERE uoo_id = cp_uoo_id;
                src_exam_rec cur_exam_loc%ROWTYPE;
                dst_exam_rec cur_exam_loc%ROWTYPE;

                CURSOR c_dest_sua(p_d_uoo_id IGS_EN_SU_ATTEMPT.UOO_ID%TYPE) IS
                        SELECT  'X'
                        FROM    IGS_EN_SU_ATTEMPT       sua
                        WHERE   sua.person_id           = p_person_id   AND
                                sua.course_cd           = p_course_cd   AND
                                sua.uoo_id              = p_d_uoo_id AND
                                sua.unit_attempt_status <> 'DROPPED';
                r_dest_sua      c_dest_sua%ROWTYPE;

                CURSOR c_sua_upd IS
                        SELECT  sua.rowid, sua.*
                        FROM    IGS_EN_SU_ATTEMPT       sua
                        WHERE   sua.person_id           = p_person_id   AND
                                sua.course_cd           = p_course_cd   AND
                                sua.uoo_id              = p_from_uoo_id
                FOR UPDATE OF
                                sua.version_number,
                                sua.location_cd,
                                sua.unit_class,
                                sua.uoo_id NOWAIT;

                -- Curosr for getting the grading schema in Unit section level for
                -- the source
                CURSOR c_from_usec_grad_schm(l_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
                  SELECT grading_schema_code, grd_schm_version_number, default_flag
                  FROM igs_ps_usec_grd_schm
                  WHERE uoo_id = l_uoo_id
                  AND default_flag = 'Y';

                -- Curosr for getting the grading schema in Unit section level for the destination
                CURSOR c_usec_grad_schm(l_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
                  SELECT grading_schema_code, grd_schm_version_number, default_flag
                  FROM igs_ps_usec_grd_schm
                  WHERE uoo_id = l_uoo_id;

                -- Cursor to get the grading schema in Unit level
                CURSOR c_from_unit_grad_schm(l_unit_cd VARCHAR2, l_unit_version NUMBER) IS
                  SELECT grading_schema_code, grd_schm_version_number
                  FROM igs_ps_unit_grd_schm
                  WHERE unit_code = l_unit_cd
                  AND unit_version_number = l_unit_version
                  AND default_flag = 'Y';

                -- Cursor to check the grading schema in source Unit level is default for the destination unit
                CURSOR c_unit_grad_schm(l_unit_cd VARCHAR2, l_unit_version NUMBER,p_grading_schema_code VARCHAR2, p_grd_schm_version_number NUMBER) IS
                  SELECT grading_schema_code, grd_schm_version_number
                  FROM igs_ps_unit_grd_schm
                  WHERE unit_code = l_unit_cd
                  AND unit_version_number = l_unit_version
                  AND grading_schema_code = p_grading_schema_code
                  AND grd_schm_version_number = p_grd_schm_version_number
                  AND default_flag = 'Y';

                -- Cursor to get the unit code and version number for the passed uoo_id
                CURSOR c_unit_cd (l_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
                  SELECT unit_cd, version_number
                  FROM igs_ps_unit_ofr_opt
                  WHERE uoo_id = l_uoo_id ;

                -- Cursor to get the Relation_type for the passed uoo_id
                CURSOR c_uoo_rel_type (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
                  SELECT NVL(relation_type,'NONE'),sup_uoo_id
                  FROM igs_ps_unit_ofr_opt
                  WHERE uoo_id = cp_uoo_id ;


                -- Cursor to get the coo_id of the student from spat if exists else get
                -- from spa
                CURSOR cur_coo_id(
                        cp_person_id            IN NUMBER,
                        cp_course_cd            IN VARCHAR2,
                        cp_load_cal_type        IN VARCHAR2,
                        cp_load_sequence_number IN NUMBER)
                IS
                  SELECT NVL(spat.coo_id, spa.coo_id) coo_id
                  FROM igs_en_stdnt_ps_att spa,
                       igs_en_spa_terms spat
                  WHERE
                       spa.course_cd               =       cp_course_cd            AND
                       spa.person_id               =       cp_person_id            AND
                       spat.term_cal_type(+)       =       cp_load_cal_type        AND
                       spat.term_sequence_number(+)=       cp_load_sequence_number AND
                       spat.person_id(+)           =       spa.person_id           AND
                       spat.program_cd(+)          =       spa.course_cd;

                -- Cursor to get the assessment indicator value.
                CURSOR c_assessment IS
                  SELECT no_assessment_ind
                  FROM   igs_en_su_attempt
                  WHERE  person_id = p_person_id
                  AND    course_cd = p_course_cd
                  AND    uoo_id = p_destination_uoo_id;

                --Cursor to get waitlist position
                CURSOR c_admin_pri (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE,cp_waitlist_dt DATE) IS
                  SELECT NVL(MAX(administrative_priority),0)+1
                  FROM igs_en_su_attempt
                  WHERE uoo_id=cp_uoo_id
                  AND waitlist_dt<=cp_waitlist_dt
                  AND unit_attempt_status='WAITLISTED';

                CURSOR c_lock_dest_usec(cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
                  SELECT uoo_id
                  FROM igs_ps_unit_ofr_opt
                  WHERE uoo_id=cp_uoo_id FOR UPDATE;


                p_deny_warn_att VARCHAR2(20) := NULL ;
                l_attendance_type_reach BOOLEAN := TRUE;
                l_cur_coo_id  cur_coo_id%ROWTYPE;
                l_attendance_types        VARCHAR2(100); -- As returned from the function igs_en_val_sca.enrp_val_coo_att

                rec_unit_cd c_unit_cd%ROWTYPE;
                rec_from_unit_cd  c_unit_cd%ROWTYPE;
                rec_from_usec_grad_schm             c_usec_grad_schm%ROWTYPE;
                rec_destination_usec_grad_schm      c_usec_grad_schm%ROWTYPE;
                rec_from_unit_grad_schm             c_unit_grad_schm%ROWTYPE;
                rec_destination_unit_grad_schm      c_unit_grad_schm%ROWTYPE;
                l_grade_found   BOOLEAN := FALSE;
                l_usec_grad_schm_exist BOOLEAN := FALSE;

                v_sua_upd_exists               VARCHAR2(1);
                v_key                          VARCHAR2(255);
                v_update_uoo                   BOOLEAN ;
                v_fail_type                    VARCHAR2(10);
                v_message_name                 VARCHAR2(30) ;
                l_reserved_seating_allowed     igs_ps_unit_ofr_opt.reserved_seating_allowed%TYPE;
                l_unit_section_status          igs_ps_unit_ofr_opt.unit_section_status%TYPE DEFAULT NULL;
                l_waitlist_ind                 VARCHAR2(3)  DEFAULT NULL;
                l_dummy                        VARCHAR2(50) DEFAULT NULL;
                l_dummy_bolean                 BOOLEAN DEFAULT TRUE;
                l_message                      VARCHAR2(100) DEFAULT NULL;
                l_notification_flag            igs_en_cpd_ext.notification_flag%TYPE;
                l_override_enrolled_cp         igs_en_su_attempt.override_enrolled_cp%TYPE DEFAULT 0;
                l_repeat_flag                  VARCHAR2(1);
                l_source_enrolled_cp           igs_en_su_attempt.override_enrolled_cp%TYPE DEFAULT 0;
                l_dest_enrolled_cp           igs_en_su_attempt.override_enrolled_cp%TYPE DEFAULT 0;
                -- Added as part of Enrollment Eligibility and validations
                l_eftsu_total          igs_en_su_attempt.override_eftsu%type DEFAULT NULL ;
                l_total_credit_points  igs_en_su_attempt.override_enrolled_cp%TYPE ;
                l_credit_points        igs_en_su_attempt.override_enrolled_cp%TYPE DEFAULT NULL ;
                l_no_assessment_ind    igs_en_su_attempt.no_assessment_ind%TYPE;
                l_rowid VARCHAR2(25);
                l_encoded_msg VARCHAR2(2000);
                l_app_sht_name VARCHAR2(100);
                l_msg_name VARCHAR2(2000);

                l_wlst_position NUMBER := NULL;
                l_pri_weight NUMBER;
                l_pref_weight NUMBER;
                l_source_uoo_rel VARCHAR2(30);
                l_source_sup_uoo NUMBER;
                l_dest_uoo_rel VARCHAR2(30);
                l_dest_sup_uoo NUMBER;
                l_uoo_ids_list VARCHAR2(2000);
                l_sub_success           VARCHAR2(2000);
                l_sub_waitlist          VARCHAR2(2000);
                l_sub_failed            VARCHAR2(2000);
                l_message_name          VARCHAR2(2000):=NULL;
                l_deny_warn             VARCHAR2(20):=NULL;
                l_ret_stat              VARCHAR2(100):=NULL;


        BEGIN
                -- Initialise the counters.
                p_sua_error_count := 0;
                p_sua_warn_count := 0;
                p_sua_trnsfr_count := 0;
                v_key := TO_CHAR(p_person_id) || '|' ||
                        p_course_cd || '|' ||
                        p_from_unit_cd || '|' ||
                        p_teach_cal_type || '|' ||
                        TO_CHAR(p_teach_ci_sequence_number) || '|' ||
                        TO_CHAR(p_u_version_number) || '|' ||
                        p_location_cd || '|' ||
                        p_unit_class || '|' ||
                        TO_CHAR(p_to_uv_version_number) || '|' ||
                        p_to_location_cd || '|' ||
                        p_to_unit_class;

                -- Get the assessment indicator value
                OPEN c_assessment;
                FETCH c_assessment INTO l_no_assessment_ind;
                CLOSE c_assessment;

                -- Validate that the IGS_PS_UNIT offering option exists.
                OPEN c_uoo;
                FETCH c_uoo INTO p_destination_uoo_id,l_reserved_seating_allowed;
                IF c_uoo%NOTFOUND THEN
                        CLOSE c_uoo;

                        -- Log error, unable to transfer student IGS_PS_UNIT attempt
                        -- option as the IGS_PS_UNIT option is not offered.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_UOO_NOT_EXISTS', -- Failed to transfer as option does not exist.
                                        'ERROR|NO_UOO');
                        p_sua_error_count := p_sua_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                END IF;
                CLOSE c_uoo;

                --Check whether student is already enrolled in the destination unit.
                OPEN c_dest_sua(p_destination_uoo_id);
                FETCH c_dest_sua INTO r_dest_sua;
                IF c_dest_sua%FOUND THEN
                        -- Log error, unable to transfer student IGS_PS_UNIT attempt
                        -- as student is already enrolled in the destination unit.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_TRN_FAIL_DUP_ATT',
                                        'ERROR|DUP_ATT');
                        p_sua_error_count := p_sua_error_count + 1;
                        -- Exit from the local procedure
                        CLOSE c_dest_sua;
                        RETURN;
                END IF;
                CLOSE c_dest_sua;
                --Check if both source and dest have the same relation type .
                OPEN c_uoo_rel_type(p_destination_uoo_id);
                FETCH c_uoo_rel_type INTO l_dest_uoo_rel,l_dest_sup_uoo;
                CLOSE c_uoo_rel_type;
                OPEN c_uoo_rel_type(p_from_uoo_id);
                FETCH c_uoo_rel_type INTO l_source_uoo_rel,l_source_sup_uoo;
                CLOSE c_uoo_rel_type;
                IF l_source_uoo_rel='SUBORDINATE' AND (l_dest_uoo_Rel<>'SUBORDINATE' OR l_source_sup_uoo<>l_dest_sup_uoo) THEN
                        -- Log error, unable to transfer student unit oferring
                        -- option as the relation types are incosistent .
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_SUA_BLK_TRN_SUB_TO_SUP',
                                        cst_error || '|SUPERIOR-SUBORDINATE');
                        p_sua_error_count := p_sua_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                END IF;
                IF l_source_uoo_rel='SUPERIOR' AND l_dest_uoo_Rel='SUBORDINATE' THEN
                        -- Log error, unable to transfer student unit oferring
                        -- option as the relation types are incosistent.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_SUA_BLK_TRN_SUP_TO_SUB',
                                        cst_error || '|SUBORDINATE-SUPERIOR');
                        p_sua_error_count := p_sua_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                END IF;

                -- Validate that the IGS_PS_UNIT version is allowable for transfers.
                OPEN c_uv;
                FETCH c_uv INTO v_uv_rec;
                CLOSE c_uv;
                IF v_uv_rec.s_unit_status <> cst_active THEN

                        -- Log error, unable to transfer student IGS_PS_UNIT attempt
                        -- option as the IGS_PS_UNIT version is not active.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_FAIL_UNITVER_NOT_ACTIV', -- Failed to transfer as IGS_PS_UNIT version not active.
                                        cst_error || '|ACTIVE-UV');
                        p_sua_error_count := p_sua_error_count + 1;
                        -- Exit from the local procedure
                        RETURN;
                ELSE
                        IF v_uv_rec.expiry_dt IS NOT NULL THEN

                                IF p_u_version_number <> p_to_uv_version_number THEN

                                        -- Log error, unable to transfer student IGS_PS_UNIT attempt
                                        -- option as the IGS_PS_UNIT version is not active.
                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                        cst_enr_blk_uo,
                                                        cst_blk_uoo,
                                                        v_key,
                                                        'IGS_EN_FAIL_UNITVER_EXPDT_SET', -- Failed to transfer as IGS_PS_UNIT version expiry date set.
                                                        cst_error || '|UV-EXPIRED');
                                        p_sua_error_count := p_sua_error_count + 1;
                                        -- Exit from the local procedure
                                        RETURN;
                                END IF;
                        END IF;
                END IF;

                v_update_uoo := TRUE;
                --Getting student (Source)unit attempt details
                OPEN cur_f_unit;
                FETCH cur_f_unit INTO rec_f_unit;
                CLOSE cur_f_unit;

                --Checking for the seat availability
                IF (p_unit_attempt_status <> cst_unconfirm) THEN
                    igs_en_gen_015.get_usec_status(
                                                   p_destination_uoo_id,
                                                   p_person_id,
                                                   l_unit_section_status,
                                                   l_waitlist_ind,
                                                   p_load_cal_type,
                                                   p_load_seq_number,
                                                   p_course_cd);
                    IF l_waitlist_ind IN ('N','Y') THEN
                       IF p_enforce_val = 'Y' AND l_reserved_seating_allowed ='Y' AND l_waitlist_ind = 'N' THEN
                          -- getting the notification flag of reserve seat step
                          --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                           v_message_name := NULL;
                           l_notification_flag := NULL;
                           l_notification_flag  := igs_ss_enr_details.get_notification(
                                                                                        p_person_type         => p_person_type,
                                                                                        p_enrollment_category => p_enrolment_cat,
                                                                                        p_comm_type           => p_commencement_type,
                                                                                        p_enr_method_type     => p_enroll_meth,
                                                                                        p_step_group_type     => 'UNIT',
                                                                                        p_step_type           => 'RSV_SEAT',
                                                                                        p_person_id           => p_person_id,
                                                                                        p_message             => v_message_name
                                                                                        );
                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                           IF l_notification_flag IS NOT NULL THEN
                               --Checking the reserve seating validation.
                                l_dummy_bolean := igs_en_elgbl_unit.eval_rsv_seat (
                                                                                   p_person_id
                                                                                  ,p_load_cal_type
                                                                                  ,p_load_seq_number
                                                                                  ,p_destination_uoo_id
                                                                                  ,p_course_cd
                                                                                  ,p_version_number
                                                                                  ,l_message
                                                                                  ,l_notification_flag
                                                                                  ,'JOB',
                                                                                  l_deny_enrollment
                                                                                  );
                           END IF;
                       END IF;
                    ELSE
                         IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           'IGS_EN_TRN_FAIL_NO_SEATS', -- Failed to transfer.
                                                            cst_error || '|NO_SEATS'  );
                        p_sua_error_count := p_sua_error_count + 1;
                        v_update_uoo := FALSE;
                    END IF;
                END IF;
                --Validating the examination details at source and destination.
                IF ((p_unit_attempt_status <> cst_unconfirm) AND
                    (p_enforce_val = 'Y')) THEN
                        --Getting Examination details at Source level.
                        OPEN cur_exam_loc(p_from_uoo_id);
                        FETCH cur_exam_loc INTO src_exam_rec;
                        IF cur_exam_loc%NOTFOUND THEN
                           CLOSE cur_exam_loc;
                        ELSE
                           CLOSE cur_exam_loc;
                           --Getting Examination details at destination level.
                           OPEN cur_exam_loc(p_destination_uoo_id);
                           FETCH cur_exam_loc INTO dst_exam_rec;
                           --Comparing the source and destination examination details.
                           IF ((cur_exam_loc%NOTFOUND) OR
                              (dst_exam_rec.final_exam_date <> src_exam_rec.final_exam_date) OR
                              (dst_exam_rec.final_exam_date IS NULL AND src_exam_rec.final_exam_date IS NOT NULL) OR
                              (dst_exam_rec.final_exam_date IS NOT NULL AND src_exam_rec.final_exam_date IS NULL) OR
                              (dst_exam_rec.exam_start_time <> src_exam_rec.exam_start_time) OR
                              (dst_exam_rec.exam_end_time   <> src_exam_rec.exam_end_time) OR
                              (dst_exam_rec.exam_end_time IS NULL  AND src_exam_rec.exam_end_time IS NOT NULL) OR
                              (dst_exam_rec.exam_end_time IS NOT NULL  AND src_exam_rec.exam_end_time IS NULL) OR
                              (dst_exam_rec.location_cd <> src_exam_rec.location_cd) OR
                              (NVL(dst_exam_rec.building_code,-1) <> NVL(src_exam_rec.building_code,-1)) OR
                              (NVL(dst_exam_rec.room_code,-1)<> NVL(src_exam_rec.room_code,-1))
                              )
                               THEN
                                                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                                                cst_enr_blk_uo,
                                                                                cst_blk_uoo,
                                                                                v_key,
                                                                                'IGS_EN_TRN_WARN_EXAM_VAL',
                                                                                'WARNING|' ||'EXAM_DET');
                                                                p_sua_warn_count := p_sua_warn_count + 1;
                           END IF;
                           CLOSE cur_exam_loc;
                        END IF;
                END IF;
                --Validating the source unit attempt grading schema against destination unit attempt grading schema
                IF v_update_uoo THEN

                   IF ((rec_f_unit.grading_schema_code IS NOT NULL) AND (rec_f_unit.gs_version_number IS NOT NULL)) THEN

                      IF NOT igs_ss_en_wrappers.enr_val_grad_usec(
                                                               p_destination_uoo_id,
                                                               rec_f_unit.grading_schema_code,
                                                               rec_f_unit.gs_version_number) THEN

                          IGS_GE_INS_SLE.genp_set_log_entry(
                                                            cst_enr_blk_uo,
                                                            cst_blk_uoo,
                                                            v_key,
                                                            'IGS_EN_MISMATH_GRAD', -- Failed to transfer.
                                                            cst_error || '|GRAD_SCH');
                          p_sua_error_count := p_sua_error_count + 1;
                          v_update_uoo := FALSE;

                      END IF;

                  ELSE -- Grading schema not overridden at unit attempt level
                        -- Get the Grading schema for the source unit section
                        OPEN c_from_usec_grad_schm(p_from_uoo_id);
                        FETCH c_from_usec_grad_schm INTO rec_from_usec_grad_schm;
                        CLOSE c_from_usec_grad_schm;

                        IF rec_from_usec_grad_schm.grading_schema_code IS NOT NULL THEN

                            -- Loop through the destination unit section and get the Grading schema
                            FOR rec_destination_usec_grad_schm IN c_usec_grad_schm(p_destination_uoo_id) LOOP
                               -- If the grading schema in the source and the destincation are the same and if it is the
                               -- default one then return true and allow transfer of unit sections
                               -- else log an error message.
                               l_usec_grad_schm_exist := TRUE;
                               IF (rec_from_usec_grad_schm.grading_schema_code =  rec_destination_usec_grad_schm.grading_schema_code) AND
                                  (rec_from_usec_grad_schm.grd_schm_version_number = rec_destination_usec_grad_schm.grd_schm_version_number) AND
                                  (rec_destination_usec_grad_schm.default_flag = 'Y') THEN
                                       -- Grading Schema in Source unit section is default grading schema in destination unit section.
                                      l_grade_found := TRUE;
                                      EXIT;
                                ELSIF  (rec_from_usec_grad_schm.grading_schema_code =  rec_destination_usec_grad_schm.grading_schema_code) AND
                                       (rec_from_usec_grad_schm.grd_schm_version_number = rec_destination_usec_grad_schm.grd_schm_version_number) AND
                                       (rec_destination_usec_grad_schm.default_flag = 'N') THEN
                                       -- Grading Schema in Source unit section is not default grading schema in destination unit section.
                                          l_grade_found := FALSE;
                                          EXIT;
                                END IF;
                             END LOOP;

                             -- if Grading schema is not found in the unit section level, then
                             -- check the same in unit level.
                             IF NOT l_usec_grad_schm_exist THEN
                                   OPEN c_unit_cd(p_destination_uoo_id);
                                   FETCH c_unit_cd INTO rec_unit_cd;
                                   CLOSE c_unit_cd;

                                   OPEN c_unit_grad_schm(rec_unit_cd.unit_cd, rec_unit_cd.version_number,
                                                         rec_from_usec_grad_schm.grading_schema_code,rec_from_usec_grad_schm.grd_schm_version_number);
                                   FETCH c_unit_grad_schm INTO rec_destination_unit_grad_schm;

                                   -- If the grading schema is the same in both the source and destination
                                   -- then return true.
                                   IF c_unit_grad_schm%FOUND THEN
                                       l_grade_found := TRUE;
                                   ELSE
                                       l_grade_found := FALSE;
                                   END IF;
                                   CLOSE c_unit_grad_schm;
                             END IF;

                         ELSE
                              -- Grading schema for source is not found in the unit section,
                              -- so check in the unit level and compare the grading schema
                              -- with that of the destination in both unit section and
                              -- unit level. If found then allow transfer else log an error message.
                              OPEN c_unit_cd(p_from_uoo_id);
                              FETCH c_unit_cd INTO rec_from_unit_cd;
                              CLOSE c_unit_cd;

                              OPEN c_from_unit_grad_schm(rec_from_unit_cd.unit_cd, rec_from_unit_cd.version_number);
                              FETCH c_from_unit_grad_schm INTO rec_from_unit_grad_schm;
                              CLOSE c_from_unit_grad_schm;

                              -- If grading schema for source is found in the unit level then
                              -- loop thru the destination unit sections.
                              IF rec_from_unit_grad_schm.grading_schema_code IS NOT NULL THEN
                                 FOR rec_destination_usec_grad_schm IN c_usec_grad_schm(p_destination_uoo_id) LOOP

                                   -- If the grading schema in the source and the destincation are the same and if it is the
                                   -- default one then allow transfer of unit sections.
                                    l_usec_grad_schm_exist := TRUE;
                                    IF (rec_from_unit_grad_schm.grading_schema_code =  rec_destination_usec_grad_schm.grading_schema_code) AND
                                       (rec_from_unit_grad_schm.grd_schm_version_number = rec_destination_usec_grad_schm.grd_schm_version_number) AND
                                       (rec_destination_usec_grad_schm.default_flag = 'Y') THEN
                                          l_grade_found := TRUE;
                                          EXIT;
                                     ELSIF  (rec_from_unit_grad_schm.grading_schema_code =  rec_destination_usec_grad_schm.grading_schema_code) AND
                                            (rec_from_unit_grad_schm.grd_schm_version_number = rec_destination_usec_grad_schm.grd_schm_version_number) AND
                                            (rec_destination_usec_grad_schm.default_flag = 'N') THEN
                                              l_grade_found := FALSE;
                                              EXIT;
                                     END IF;

                                  END LOOP;

                                  -- If grading schema for destination is not found in unit section level,
                                  -- then check for the same in unit level.
                                  IF NOT l_usec_grad_schm_exist THEN

                                     OPEN c_unit_cd(p_destination_uoo_id);
                                     FETCH c_unit_cd INTO rec_unit_cd;
                                     CLOSE c_unit_cd;

                                     OPEN c_unit_grad_schm(rec_unit_cd.unit_cd, rec_unit_cd.version_number,
                                                         rec_from_unit_grad_schm.grading_schema_code,rec_from_unit_grad_schm.grd_schm_version_number);
                                     FETCH c_unit_grad_schm INTO rec_destination_unit_grad_schm;

                                     -- If the grading schema is the same in both the source and destination
                                     -- then return true.
                                      IF c_unit_grad_schm%FOUND THEN
                                        l_grade_found := TRUE;
                                      ELSE
                                        l_grade_found := FALSE;
                                      END IF;
                                      CLOSE c_unit_grad_schm;
                                   END IF;
                                 END IF; -- rec_from_unit_grad_schm.grading_schema_code IS NOT NULL
                            END IF; -- rec_from_usec_grad_schm.grading_schema_code IS NOT NULL


                            -- Source and destincation Grading schema are not the same, log an error message
                            IF NOT l_grade_found THEN

                               IGS_GE_INS_SLE.genp_set_log_entry(
                                                                 cst_enr_blk_uo,
                                                                 cst_blk_uoo,
                                                                 v_key,
                                                                 'IGS_EN_MISMATH_GRAD', -- Failed to transfer.
                                                                  cst_error || '|GRAD_SCH');
                                  p_sua_error_count := p_sua_error_count + 1;
                                  v_update_uoo := FALSE;
                            END IF;
                   END IF; --rec_f_unit.grading_schema_code IS NOT NULL

                END IF;  -- v_update_uoo


                --Getting source override enrolled credit points if exists for student in override table.
                l_override_enrolled_cp:= igs_en_gen_015.enrp_get_appr_cr_pt(p_person_id,p_destination_uoo_id);

                --Getting the enrolled credit points at unit level.
                r_unit_enroll_cp:= NULL;
                r_unit_enroll_cp_1:= NULL;

                OPEN c_unit_enroll_cp(p_from_uoo_id);
                FETCH c_unit_enroll_cp INTO r_unit_enroll_cp;
                CLOSE c_unit_enroll_cp;

                OPEN c_unit_enroll_cp(NVL(p_destination_uoo_id,p_from_uoo_id));
                FETCH c_unit_enroll_cp INTO r_unit_enroll_cp_1;
                CLOSE c_unit_enroll_cp;

                --Setting Source and Destination enrolled credits points,
                l_source_enrolled_cp := NVL(rec_f_unit.override_enrolled_cp,r_unit_enroll_cp.enrolled_credit_points);
                l_dest_enrolled_cp   := NVL(l_override_enrolled_cp,r_unit_enroll_cp_1.enrolled_credit_points);

                --Validating the source unit attempt enroll credit points destination unit attempt
                -- only when the unit is not a audit unit attempt
                IF v_update_uoo AND rec_f_unit.override_enrolled_cp IS NOT NULL AND rec_f_unit.no_assessment_ind <> 'Y' THEN
                       IF l_override_enrolled_cp IS NOT NULL THEN
                          IF l_override_enrolled_cp <> rec_f_unit.override_enrolled_cp  THEN
                            IGS_GE_INS_SLE.genp_set_log_entry(
                                                               cst_enr_blk_uo,
                                                               cst_blk_uoo,
                                                               v_key,
                                                               'IGS_EN_MISMATH_ENR_CP', -- Failed to transfer.
                                                               cst_error || '|OVER_EN_CP');
                            p_sua_error_count := p_sua_error_count + 1;
                            v_update_uoo := FALSE;
                          END IF;
                       ELSE
                          l_message := NULL;
                          l_dummy_bolean:= TRUE;
                          --Validating the enroll credit points
                          l_dummy_bolean:=IGS_EN_VAL_SUA.ENRP_VAL_SUA_OVRD_CP(
                                                                              p_from_unit_cd,
                                                                              p_to_uv_version_number,
                                                                              rec_f_unit.override_enrolled_cp,
                                                                              NULL,
                                                                              NULL,
                                                                              l_message,
                                                                              p_destination_uoo_id,
                                                                              l_no_assessment_ind);
                           IF NOT l_dummy_bolean AND l_message IN ('IGS_EN_OVERRIDE_EFTSU_VALUES','IGS_EN_OVERRIDE_ENR_CREDITPNT') THEN
                              OPEN c_unit_enroll_cp(p_from_uoo_id);
                              FETCH c_unit_enroll_cp INTO r_unit_enroll_cp;
                              CLOSE c_unit_enroll_cp;
                              IF r_unit_enroll_cp.enrolled_credit_points  <> rec_f_unit.override_enrolled_cp THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_MISMATH_ENR_CP', -- Failed to transfer.
                                                                      cst_error || '|OVER_EN_CP');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                              END IF;
                           END IF;
                       END IF;
                END IF;
                --Validating the destination unit section incompatibility rule
                IF ((v_update_uoo) AND (p_enforce_val = 'Y')) THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'INCMPT_UNT',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                                                        );
                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_unit.eval_incompatible(
                                                                               p_person_id
                                                                              ,p_load_cal_type
                                                                              ,p_load_seq_number
                                                                              ,p_destination_uoo_id
                                                                              ,p_course_cd
                                                                              ,p_version_number
                                                                              ,l_message
                                                                              ,l_notification_flag
                                                                              ,'JOB');
                        IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_INCMPT_RULE', -- Failed to transfer.
                                                                      cst_error || '|UV_INCMPT');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_INCMPT_RULE',
                                                                      cst_warning|| '|US_INCMPT');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                         END IF;

                     END IF;
                END IF;
                --Validating the special permission for destination unit section
                IF ((v_update_uoo) AND (p_enforce_val = 'Y') )  THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'SPL_PERM',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );
                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         --Checking the special permission validation.
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_unit.eval_spl_permission(
                                                                                 p_person_id
                                                                                ,p_load_cal_type
                                                                                ,p_load_seq_number
                                                                                ,p_destination_uoo_id
                                                                                ,p_course_cd
                                                                                ,p_version_number
                                                                                ,l_message
                                                                                ,l_notification_flag);
                        IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_SPL_PERM', -- Failed to transfer.
                                                                      cst_error || '|SPL_PERM');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_SPL_PERM',
                                                                      cst_warning || '|SPL_PERM');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                        END IF;
                     END IF;
                END IF;
                --Validating the Audit permission for destination unit section
                IF ((v_update_uoo) AND (p_enforce_val = 'Y') )  THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'AUDIT_PERM',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );
                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         --Checking the special permission validation.
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_unit.eval_audit_permission (p_person_id          => p_person_id,
                                                                                  p_load_cal_type        => p_load_cal_type,
                                                                                  p_load_sequence_number => p_load_seq_number,
                                                                                  p_uoo_id               => p_destination_uoo_id,
                                                                                  p_course_cd            => p_course_cd,
                                                                                  p_course_version       => p_version_number,
                                                                                  p_message              => l_message,
                                                                                  p_deny_warn            => l_notification_flag);
                        IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_AU_PERM', -- Failed to transfer.
                                                                      cst_error || '|AU_PERM');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_AU_PERM',
                                                                      cst_warning || '|AU_PERM');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                        END IF;
                     END IF;
                END IF;


                --Validating the Time conflict for destination unit section
                IF ((v_update_uoo) AND (p_enforce_val = 'Y') )  THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'TIME_CNFLT',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );

                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         --Checking the reserve seating validation.
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_unit.eval_time_conflict(p_person_id,
                                                                                p_load_cal_type,
                                                                                p_load_seq_number,
                                                                                p_destination_uoo_id,
                                                                                p_course_cd,
                                                                                p_version_number,
                                                                                l_message,
                                                                                l_notification_flag,
                                                                                'JOB');
                       IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_TIME_CNFLT', -- Failed to transfer.
                                                                      cst_error || '|TIME_CNFLT');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_TIME_CNFLT',
                                                                      cst_warning || '|TIME_CNFLT');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                       END IF;

                     END IF;
                END IF;
                --Validating the repeat unit validation for the unit attempt
                IF ((v_update_uoo) AND (p_enforce_val = 'Y'))  THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'UNIT_RPT',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );

                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_unit.eval_unit_repeat( p_person_id          => p_person_id,
                                                                              p_load_cal_type       =>  p_load_cal_type,
                                                                              p_load_cal_seq_number => p_load_seq_number,
                                                                              p_uoo_id              =>  p_destination_uoo_id,
                                                                              p_program_cd          =>  p_course_cd,
                                                                              p_program_version     =>  p_version_number,
                                                                              p_message             => l_message,
                                                                              p_deny_warn           => l_notification_flag,
                                                                              p_repeat_tag          =>  l_repeat_flag,
                                                                              p_unit_cd             => NULL,
                                                                              p_unit_version        => NULL,
                                                                              p_calling_obj         =>  'JOB');

                         IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_REPEAT', -- Failed to transfer.
                                                                      cst_error || '|UNIT_RPT');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_REPEAT',
                                                                      cst_warning || '|UNIT_REP');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                         END IF;
                     END IF;
                END IF;
                --Validating the MAX CP validation for the Program Attempt
                IF ((v_update_uoo) AND (p_enforce_val = 'Y') AND p_unit_attempt_status NOT IN (cst_unconfirm,cst_waitlisted))  THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'PROGRAM',
                                                   p_step_type           => 'FMAX_CRDT',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );
                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_program.eval_max_cp( p_person_id                  => p_person_id,
                                                                             p_load_calendar_type         => p_load_cal_type,
                                                                             p_load_cal_sequence_number   => p_load_seq_number,
                                                                             p_uoo_id                     => p_destination_uoo_id,
                                                                             p_program_cd                 => p_course_cd,
                                                                             p_program_version            => p_version_number,
                                                                             p_message                    => l_message,
                                                                             p_deny_warn                  => l_notification_flag,
                                                                             p_upd_cp                     => l_dest_enrolled_cp-l_source_enrolled_cp,
                                                                             p_calling_obj                =>  'JOB');
                         IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_MAX_CP', -- Failed to transfer.
                                                                      cst_error || '|PRG_MAXCP');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_MAX_CP',
                                                                      cst_warning || '|PRG_MAXCP');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                         END IF;
                     END IF;
                END IF;

                IF ((p_unit_attempt_status <> cst_unconfirm) AND
                    (p_enforce_val = 'Y')) THEN
                        -- Validate that the student is able to enrol in the IGS_PS_UNIT.
                        IF NOT IGS_EN_VAL_SUA.enrp_val_sua_cnfrm(
                                                        p_person_id,
                                                        p_course_cd,
                                                        p_from_unit_cd,
                                                        p_to_uv_version_number,
                                                        p_teach_cal_type,
                                                        p_teach_ci_sequence_number,
                                                        p_teach_end_dt,
                                                        p_to_location_cd,
                                                        p_to_unit_class,
                                                        p_enrolled_dt,
                                                        v_fail_type,
                                                        v_message_name) THEN
                                -- Check if the error encountered is not associated with a duplicate
                                -- existing (The duplicate would be the original IGS_PS_UNIT offering option.).
                                IF v_fail_type <> cst_duplicate THEN
                                        IF UPPER(v_fail_type) IN (
                                                                    'COURSE',
                                                                    'ENCUMB',
                                                                    'ADVSTAND',
                                                                    'ENROLDT',
                                                                    'TEACHING') THEN
                                                v_text := cst_error || '|' || v_fail_type;
                                                p_sua_error_count := p_sua_error_count + 1;
                                        ELSE
                                                v_text := cst_warning || '|' || v_fail_type;
                                                p_sua_warn_count := p_sua_warn_count + 1;
                                        END IF;
                                        -- Log the problem.
                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                        cst_enr_blk_uo,
                                                        cst_blk_uoo,
                                                        v_key,
                                                        v_message_name,
                                                        v_text);
                                        IF UPPER(v_fail_type) IN (
                                                                  'COURSE',
                                                                  'ENCUMB',
                                                                  'ADVSTAND',
                                                                  'ENROLDT',
                                                                  'TEACHING') THEN
                                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                                cst_enr_blk_uo,
                                                                cst_blk_uoo,
                                                                v_key,
                                                                'IGS_EN_STUD_NOTTRNS_UOO', -- Failed to transfer.
                                                                cst_information || '|' || v_fail_type);
                                                v_update_uoo := FALSE;
                                        END IF;
                                END IF;
                        ELSE    -- IGS_EN_VAL_SUA.enrp_val_sua_cnfrm
                                -- Check if warnings exist and log warnings.
                                IF v_message_name is not null THEN

                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                        cst_enr_blk_uo,
                                                        cst_blk_uoo,
                                                        v_key,
                                                        v_message_name,
                                                        'WARNING|' || v_fail_type);
                                        p_sua_warn_count := p_sua_warn_count + 1;
                                END IF;
                        END IF;
                END IF;
                --IF source uoo is a superior then drop all subordinates
                IF v_update_uoo AND l_source_uoo_rel='SUPERIOR' THEN
                  l_msg_name:=NULL;
                  igs_en_val_sua.drop_sub_units(
                                  p_person_id        => p_person_id  ,
                                  p_course_cd        => p_course_cd   ,
                                  p_uoo_id           => p_from_uoo_id ,
                                  p_load_cal_type    => p_load_cal_type  ,
                                  p_load_seq_num     => p_load_seq_number  ,
                                  p_acad_cal_type    => p_acad_cal_type  ,
                                  p_acad_seq_num     => p_acad_seq_number  ,
                                  p_enrollment_method=> p_enroll_meth  ,
                                  p_confirmed_ind    => 'N' ,
                                  p_person_type      =>   p_person_type,
                                  p_effective_date   => SYSDATE  ,
                                  p_course_ver_num   => p_version_number,
                                  p_dcnt_reason_cd   => NULL ,
                                  p_admin_unit_status=> NULL ,
                                  p_uoo_ids          => l_uoo_ids_list ,
                                  p_error_message    => l_msg_name);
                  IF l_msg_name IS NOT NULL THEN
                    --Log error and indicate that not all subordinates were dropped. Abort transfer
                    ROLLBACK TO sp_sua_blk_trn;
                    IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_BLK_SUB_DROP_FAILED',
                                        cst_error || '|DROPSUB');
                    p_sua_error_count := p_sua_error_count + 1;
                    v_update_uoo := FALSE;
                  END IF;
                END IF;

                IF v_update_uoo THEN

                -- Calculate the Total Enrolled Credit Points before Transferring the Unit from one Unit section to another .
                  l_eftsu_total := igs_en_prc_load.enrp_clc_eftsu_total(
                        p_person_id             => p_person_id,
                        p_course_cd             => p_course_cd ,
                        p_acad_cal_type         => p_acad_cal_type,
                        p_acad_sequence_number  => p_acad_seq_number,
                        p_load_cal_type         => p_load_cal_type,
                        p_load_sequence_number  => p_load_seq_number,
                        p_truncate_ind          => 'N',
                        p_include_research_ind  => 'Y'  ,
                        p_key_course_cd         => NULL ,
                        p_key_version_number    => NULL ,
                        p_credit_points         => l_total_credit_points );

                    OPEN  cur_coo_id(                                   ---*
                                p_person_id,
                                p_course_cd,
                                p_load_cal_type,
                                p_load_seq_number);
                    FETCH cur_coo_id INTO l_cur_coo_id;
                    CLOSE cur_coo_id;

                -- Check if the Forced Attendance Type has already been reached for the Student before transferring .
                --Modfied as a part of bug#5191592.
                l_attendance_type_reach := igs_en_val_sca.enrp_val_coo_att(p_person_id          => p_person_id,
                        p_coo_id             => l_cur_coo_id.coo_id,
                        p_cal_type           => p_acad_cal_type,
                        p_ci_sequence_number => p_acad_seq_number,
                        p_message_name       => v_message_name ,
                        p_attendance_types   => l_attendance_types,
                        p_load_or_teach_cal_type => p_load_cal_type,
                        p_load_or_teach_seq_number => p_load_seq_number);

                -- Assign values to the parameter p_deny_warn_att based on if Attendance Type has not been already reached or not.
                IF l_attendance_type_reach THEN
                    p_deny_warn_att := 'AttTypReached' ;
                ELSE
                    p_deny_warn_att := 'AttTypNotReached' ;
                END IF ;

                        -- Update the record.
                        FOR v_sua_upd_exists IN c_sua_upd LOOP
                                          -- Call the API to update the student unit attempt. This API is a
                                          -- wrapper to the update row of the TBH.
                                        BEGIN

                                          enrp_store_suar(p_person_id,
                                                          p_course_cd,
                                                          p_from_uoo_id);
                                          igs_en_sua_api.update_unit_attempt(
                                                                           X_ROWID                          => v_sua_upd_exists.rowid,
                                                                           X_PERSON_ID                      => v_sua_upd_exists.PERSON_ID,
                                                                           X_COURSE_CD                      => v_sua_upd_exists.COURSE_CD ,
                                                                           X_UNIT_CD                        => v_sua_upd_exists.UNIT_CD,
                                                                           X_CAL_TYPE                       => v_sua_upd_exists.CAL_TYPE,
                                                                           X_CI_SEQUENCE_NUMBER             => v_sua_upd_exists.CI_SEQUENCE_NUMBER ,
                                                                           X_VERSION_NUMBER                 => v_sua_upd_exists.version_number ,
                                                                           X_LOCATION_CD                    => v_sua_upd_exists.location_cd,
                                                                           X_UNIT_CLASS                     => v_sua_upd_exists.unit_class,
                                                                           X_CI_START_DT                    => v_sua_upd_exists.CI_START_DT,
                                                                           X_CI_END_DT                      => v_sua_upd_exists.CI_END_DT,
                                                                           X_UOO_ID                         => v_sua_upd_exists.uoo_id,
                                                                           X_ENROLLED_DT                    => v_sua_upd_exists.ENROLLED_DT,
                                                                           X_UNIT_ATTEMPT_STATUS            => 'DROPPED',
                                                                           X_ADMINISTRATIVE_UNIT_STATUS     => v_sua_upd_exists.administrative_unit_status,
                                                                           X_ADMINISTRATIVE_PRIORITY        => v_sua_upd_exists.administrative_priority,
                                                                           X_DISCONTINUED_DT                => nvl(v_sua_upd_exists.discontinued_dt,trunc(SYSDATE)),
                                                                           X_DCNT_REASON_CD                 => v_sua_upd_exists.DCNT_REASON_CD ,
                                                                           X_RULE_WAIVED_DT                 => v_sua_upd_exists.RULE_WAIVED_DT ,
                                                                           X_RULE_WAIVED_PERSON_ID          => v_sua_upd_exists.RULE_WAIVED_PERSON_ID ,
                                                                           X_NO_ASSESSMENT_IND              => v_sua_upd_exists.NO_ASSESSMENT_IND,
                                                                           X_SUP_UNIT_CD                    => v_sua_upd_exists.SUP_UNIT_CD ,
                                                                           X_SUP_VERSION_NUMBER             => v_sua_upd_exists.SUP_VERSION_NUMBER,
                                                                           X_EXAM_LOCATION_CD               => v_sua_upd_exists.EXAM_LOCATION_CD,
                                                                           X_ALTERNATIVE_TITLE              => v_sua_upd_exists.ALTERNATIVE_TITLE ,
                                                                           X_OVERRIDE_ENROLLED_CP           => v_sua_upd_exists.OVERRIDE_ENROLLED_CP,
                                                                           X_OVERRIDE_EFTSU                 => v_sua_upd_exists.OVERRIDE_EFTSU ,
                                                                           X_OVERRIDE_ACHIEVABLE_CP         => v_sua_upd_exists.OVERRIDE_ACHIEVABLE_CP,
                                                                           X_OVERRIDE_OUTCOME_DUE_DT        => v_sua_upd_exists.OVERRIDE_OUTCOME_DUE_DT,
                                                                           X_OVERRIDE_CREDIT_REASON         => v_sua_upd_exists.OVERRIDE_CREDIT_REASON,
                                                                           X_WAITLIST_DT                    => v_sua_upd_exists.waitlist_dt,
                                                                           X_MODE                           =>  'R' ,
                                                                           --bug#1832130 enrollment processes dld added following columns smaddali
                                                                           X_GS_VERSION_NUMBER              => v_sua_upd_exists.gs_version_number,
                                                                           --Updating the enrollment method type
                                                                           X_ENR_METHOD_TYPE                => v_sua_upd_exists.enr_method_type,
                                                                           X_FAILED_UNIT_RULE               => v_sua_upd_exists.failed_unit_rule ,
                                                                           X_CART                           => v_sua_upd_exists.cart ,
                                                                           X_RSV_SEAT_EXT_ID                => v_sua_upd_exists.rsv_seat_ext_id,
                                                                           X_ORG_UNIT_CD                    => v_sua_upd_exists.org_unit_cd,
                                                                           --session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                                                           X_SESSION_ID                     => v_sua_upd_exists.session_id,
                                                                           -- aiyer Added the column grading_schema_code as a part of the bug 2037897
                                                                           X_GRADING_SCHEMA_CODE            => v_sua_upd_exists.grading_schema_code,
                                                                           X_DEG_AUD_DETAIL_ID              => v_sua_upd_exists.deg_aud_detail_id,
                                                                           X_SUBTITLE                       => v_sua_upd_exists.subtitle,
                                                                           X_STUDENT_CAREER_TRANSCRIPT      =>v_sua_upd_exists.student_career_transcript ,
                                                                           X_STUDENT_CAREER_STATISTICS      => v_sua_upd_exists.student_career_statistics,
                                                                           X_ATTRIBUTE_CATEGORY             => v_sua_upd_exists.attribute_category,
                                                                           X_ATTRIBUTE1                     => v_sua_upd_exists.attribute1,
                                                                           X_ATTRIBUTE2                     => v_sua_upd_exists.attribute2,
                                                                           X_ATTRIBUTE3                     => v_sua_upd_exists.attribute3,
                                                                           X_ATTRIBUTE4                     => v_sua_upd_exists.attribute4,
                                                                           X_ATTRIBUTE5                     => v_sua_upd_exists.attribute5,
                                                                           X_ATTRIBUTE6                     => v_sua_upd_exists.attribute6,
                                                                           X_ATTRIBUTE7                     => v_sua_upd_exists.attribute7,
                                                                           X_ATTRIBUTE8                     => v_sua_upd_exists.attribute8,
                                                                           X_ATTRIBUTE9                     => v_sua_upd_exists.attribute9,
                                                                           X_ATTRIBUTE10                    => v_sua_upd_exists.attribute10,
                                                                           X_ATTRIBUTE11                    => v_sua_upd_exists.attribute11,
                                                                           X_ATTRIBUTE12                    => v_sua_upd_exists.attribute12,
                                                                           X_ATTRIBUTE13                    => v_sua_upd_exists.attribute13,
                                                                           X_ATTRIBUTE14                    => v_sua_upd_exists.attribute14,

                                                                           X_ATTRIBUTE15                    => v_sua_upd_exists.attribute15,
                                                                           X_ATTRIBUTE16                    => v_sua_upd_exists.attribute16,
                                                                           X_ATTRIBUTE17                    => v_sua_upd_exists.attribute17,
                                                                           X_ATTRIBUTE18                    => v_sua_upd_exists.attribute18,
                                                                           X_ATTRIBUTE19                    => v_sua_upd_exists.attribute19,
                                                                           X_ATTRIBUTE20                    => v_sua_upd_exists.attribute20,
                                                                           X_WAITLIST_MANUAL_IND            => v_sua_upd_exists.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109.
                                                                           X_WLST_PRIORITY_WEIGHT_NUM       => NULL,
                                                                           X_WLST_PREFERENCE_WEIGHT_NUM     => NULL,
                                                                           X_CORE_INDICATOR_CODE            => v_sua_upd_exists.core_indicator_code
                                           );


                                         --If destination unit attempt status is waitlisted then updating the unit attempt status is waitlisted.
                                         IF l_waitlist_ind = 'Y' THEN
                                             v_sua_upd_exists.waitlist_dt := NVL(v_sua_upd_exists.waitlist_dt,NVL(TRUNC(v_sua_upd_exists.enrolled_dt),SYSDATE));
                                             v_sua_upd_exists.UNIT_ATTEMPT_STATUS :='WAITLISTED';
                                             v_sua_upd_exists.ENROLLED_DT := NULL;
                                             igs_en_wlst_gen_proc.enrp_wlst_pri_pref_calc (p_person_id       => v_sua_upd_exists.person_id,
                                                                                           p_program_cd      =>p_course_cd,
                                                                                           p_uoo_id          =>p_destination_uoo_id,
                                                                                           p_priority_weight =>l_pri_weight,
                                                                                           p_preference_weight=>l_pref_weight);

                                             IF l_pri_weight IS NULL AND l_pref_weight IS NULL THEN
                                               OPEN c_lock_dest_usec(p_destination_uoo_id);
                                               CLOSE c_lock_dest_usec;
                                               OPEN c_admin_pri(p_destination_uoo_id,v_sua_upd_exists.waitlist_dt);
                                               FETCH c_admin_pri INTO v_sua_upd_exists.administrative_priority;
                                               CLOSE c_admin_pri;
                                                v_sua_upd_exists.wlst_priority_weight_num:=NULL;
                                                v_sua_upd_exists.wlst_preference_weight_num:=NULL;
                                             ELSE
                                                v_sua_upd_exists.wlst_priority_weight_num := l_pri_weight;
                                                v_sua_upd_exists.wlst_preference_weight_num := l_pref_weight;
                                                -- assigning NULL as the position has to be re-calculated, which is done in TBH
                                                v_sua_upd_exists.administrative_priority:=NULL;
                                             END IF;
                                             -- Set the waitlist flag to indicating student attempted in with waitlist
                                             p_waitlist_flag := 'Y';
                                          ELSIF l_waitlist_ind='N' AND v_sua_upd_exists.UNIT_ATTEMPT_STATUS='WAITLISTED' THEN
                                            v_sua_upd_exists.ENROLLED_DT:=v_sua_upd_exists.waitlist_dt;
                                            p_waitlist_flag := 'N';
                                            v_sua_upd_exists.administrative_priority:=NULL;
                                            v_sua_upd_exists.waitlist_dt:=NULL;
                                            v_sua_upd_exists.wlst_priority_weight_num:=NULL;
                                            v_sua_upd_exists.wlst_preference_weight_num:=NULL;
                                          ELSE
                                             -- Set the waitlist flag to indicating student attempted in with 'ENROLLED'
                                             p_waitlist_flag := 'N';
                                             v_sua_upd_exists.administrative_priority:=NULL;
                                          END IF;
                                            igs_en_sua_api.create_unit_attempt(
                                              x_rowid                              => l_rowid,
                                              x_person_id                          => v_sua_upd_exists.person_id,
                                              x_course_cd                          => v_sua_upd_exists.course_cd,
                                              x_ci_start_dt                        => v_sua_upd_exists.ci_start_dt,
                                              x_ci_end_dt                          => v_sua_upd_exists.ci_end_dt,
                                              x_uoo_id                             => p_destination_uoo_id,
                                              x_unit_attempt_status                => v_sua_upd_exists.unit_attempt_status ,
                                              x_unit_cd                            => v_sua_upd_exists.unit_cd,
                                              x_version_number                     => p_to_uv_version_number,
                                              x_cal_type                           => v_sua_upd_exists.cal_type,
                                              x_ci_sequence_number                 => v_sua_upd_exists.ci_sequence_number,
                                              x_location_cd                        => p_to_location_cd,
                                              x_unit_class                         => p_to_unit_class,
                                              x_enrolled_dt                        => v_sua_upd_exists.enrolled_dt,
                                              x_administrative_unit_status         => v_sua_upd_exists.administrative_unit_status,
                                              x_administrative_priority            => v_sua_upd_exists.administrative_priority,
                                              x_discontinued_dt                    => v_sua_upd_exists.discontinued_dt,
                                              x_dcnt_reason_cd                     => v_sua_upd_exists.dcnt_reason_cd,
                                              x_rule_waived_dt                     => v_sua_upd_exists.rule_waived_dt,
                                              x_rule_waived_person_id              => v_sua_upd_exists.rule_waived_person_id,
                                              x_no_assessment_ind                  => v_sua_upd_exists.no_assessment_ind,
                                              x_sup_unit_cd                        => v_sua_upd_exists.sup_unit_cd,
                                              x_sup_version_number                 => v_sua_upd_exists.sup_version_number,
                                              x_exam_location_cd                   => v_sua_upd_exists.exam_location_cd,
                                              x_alternative_title                  => v_sua_upd_exists.alternative_title ,
                                              x_override_enrolled_cp               => v_sua_upd_exists.override_enrolled_cp,
                                              x_override_eftsu                     => v_sua_upd_exists.override_eftsu,
                                              x_override_achievable_cp             => v_sua_upd_exists.override_achievable_cp,
                                              x_override_outcome_due_dt            => v_sua_upd_exists.override_outcome_due_dt ,
                                              x_override_credit_reason             => v_sua_upd_exists.override_credit_reason,
                                              x_waitlist_dt                        => v_sua_upd_exists.waitlist_dt ,
                                              x_enr_method_type                    => NVL(p_enroll_meth,v_sua_upd_exists.enr_method_type),
                                              x_mode                               => 'R',
                                              x_org_id                             => v_sua_upd_exists.org_id,
                                              x_org_unit_cd                        => v_sua_upd_exists.org_unit_cd,
                                              x_grading_schema_code                => v_sua_upd_exists.grading_schema_code,
                                              x_gs_version_number                  => v_sua_upd_exists.gs_version_number,
                                              x_session_id                         => v_sua_upd_exists.session_id,
                                              x_deg_aud_detail_id                  => v_sua_upd_exists.deg_aud_detail_id ,
                                              x_student_career_transcript          => v_sua_upd_exists.student_career_transcript ,
                                              x_student_career_statistics          => v_sua_upd_exists.student_career_statistics,
                                              x_attribute_category                 => v_sua_upd_exists.attribute_category,
                                              x_attribute1                         => v_sua_upd_exists.attribute1,
                                              x_attribute2                         => v_sua_upd_exists.attribute2,
                                              x_attribute3                         => v_sua_upd_exists.attribute3,
                                              x_attribute4                         => v_sua_upd_exists.attribute4,
                                              x_attribute5                         => v_sua_upd_exists.attribute5,
                                              x_attribute6                         => v_sua_upd_exists.attribute6,
                                              x_attribute7                         => v_sua_upd_exists.attribute7,
                                              x_attribute8                         => v_sua_upd_exists.attribute8,
                                              x_attribute9                         => v_sua_upd_exists.attribute9,
                                              x_attribute10                        => v_sua_upd_exists.attribute10,
                                              x_attribute11                        => v_sua_upd_exists.attribute11,
                                              x_attribute12                        => v_sua_upd_exists.attribute12,
                                              x_attribute13                        => v_sua_upd_exists.attribute13,
                                              x_attribute14                        => v_sua_upd_exists.attribute14,
                                              x_attribute15                        => v_sua_upd_exists.attribute15,
                                              x_attribute16                        => v_sua_upd_exists.attribute16,
                                              x_attribute17                        => v_sua_upd_exists.attribute17,
                                              x_attribute18                        => v_sua_upd_exists.attribute18,
                                              x_attribute19                        => v_sua_upd_exists.attribute19,
                                              x_attribute20                        => v_sua_upd_exists.attribute20,
                                              x_waitlist_manual_ind                => v_sua_upd_exists.waitlist_manual_ind ,
                                              x_wlst_priority_weight_num           => v_sua_upd_exists.wlst_priority_weight_num,
                                              x_wlst_preference_weight_num         => v_sua_upd_exists.wlst_preference_weight_num,
                                              x_core_indicator_code                => v_sua_upd_exists.core_indicator_code);

                                            IF l_waitlist_ind='Y' AND l_pri_weight IS NULL AND l_pref_weight IS NULL THEN
                                              igs_en_wlst_gen_proc.enrp_wlst_dt_reseq (p_person_id   => v_sua_upd_exists.person_id,
                                                                                         p_program_cd  => v_sua_upd_exists.course_cd,
                                                                                         p_uoo_id      => p_destination_uoo_id,
                                                                                         p_cur_position=> v_sua_upd_exists.administrative_priority);
                                            END IF;
                                           EXCEPTION
                                             WHEN OTHERS THEN
                                                v_update_uoo := FALSE;
                                                ROLLBACK TO sp_sua_blk_trn;
                                                -- Get the message raised and log the same
                                                l_encoded_msg := fnd_message.get_encoded;
                                                fnd_message.parse_encoded(l_encoded_msg,l_app_sht_name,l_msg_name);
                                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                                           cst_enr_blk_uo,
                                                                           cst_blk_uoo,
                                                                           v_key,
                                                                           l_msg_name,
                                                                           cst_error || '|UNH_EXP' );
                                                p_sua_error_count := p_sua_error_count + 1;
                                          END;
                        l_unit_attempt_status:=v_sua_upd_exists.unit_attempt_status;
                        END LOOP;
                END IF;

      --code to handle transfer of child items
          BEGIN
             SAVEPOINT s_enr_trn_pt;
             IF v_update_uoo AND l_unit_attempt_status
                        NOT IN ('UNCONFIRM','DUPLICATE') THEN
                 enrp_copy_suar(p_destination_uoo_id);
             END IF;

             IF v_update_uoo  AND
                l_unit_attempt_status in ('ENROLLED','WAITLISTED', 'DISCONTIN','COMPLETED') THEN

               --copy assessment items from source to destination
               igs_en_gen_010.enrp_ins_suai_trnsfr(
                 p_person_id        => p_person_id,
                 p_source_course_cd => p_course_cd,
                 p_dest_course_cd   => p_course_cd,
                 p_source_uoo_id    => p_from_uoo_id,
                 p_dest_uoo_id      => p_destination_uoo_id,
                 p_delete_source    => TRUE);

               --copy assessment outcomes from source to destination
               igs_en_gen_010.enrp_ins_suao_trnsfr (
                 p_person_id        => p_person_id,
                 p_source_course_cd => p_course_cd,
                 p_dest_course_cd   => p_course_cd,
                 p_source_uoo_id    => p_from_uoo_id,
                 p_dest_uoo_id      => p_destination_uoo_id,
                 p_delete_source    => TRUE);

                --copy placement information from source to destination
                igs_en_gen_010.enrp_ins_splace_trnsfr (
                 p_person_id        => p_person_id,
                 p_source_course_cd => p_course_cd,
                 p_dest_course_cd   => p_course_cd,
                 p_source_uoo_id    => p_from_uoo_id,
                 p_dest_uoo_id      => p_destination_uoo_id);

             END IF;

         EXCEPTION
          WHEN OTHERS THEN
           ROLLBACK TO s_enr_trn_pt;
           IGS_GE_INS_SLE.genp_set_log_entry(
             cst_enr_blk_uo,
             cst_blk_uoo,
             v_key,
             'IGS_EN_TRN_FAIL_CHILDS', -- Failed to transfer child records.
             cst_error || '|COURSE');
           p_sua_error_count := p_sua_error_count + 1;
           v_update_uoo := FALSE;
         END;


                --Attempt to enroll the subordinate unit sections if applicable.
                --Also confirm the subordinates if the superior is ENROLLED
                IF (v_update_uoo) AND l_dest_uoo_rel='SUPERIOR' THEN
                  l_sub_success:=NULL;l_sub_waitlist:=NULL;l_sub_failed:=NULL;
                  SAVEPOINT s_enr_sub_units;
                  igs_en_val_sua.enr_sub_units(
                        p_person_id           => p_person_id,
                        p_course_cd           => p_course_cd,
                        p_uoo_id              => p_destination_uoo_id,
                        p_waitlist_flag       => l_waitlist_ind,
                        p_load_cal_type       => p_load_cal_type,
                        p_load_seq_num        => p_load_seq_number,
                        p_enrollment_date     => SYSDATE,
                        p_enrollment_method   => p_enroll_meth,
                        p_enr_uoo_ids         => NULL,
                        p_uoo_ids             => l_sub_success,
                        p_waitlist_uoo_ids    => l_sub_waitlist,
                        p_failed_uoo_ids      => l_sub_failed);
                  IF l_sub_success IS NOT NULL AND l_unit_attempt_status ='ENROLLED' THEN
                     BEGIN
                       igs_ss_en_wrappers.validate_enroll_validate(p_person_id               =>p_person_id,
                                                                 p_load_cal_type           =>p_load_cal_type,
                                                                 p_load_ci_sequence_number =>p_load_seq_number,
                                                                 p_uoo_ids                 =>l_sub_success,
                                                                 p_program_cd              =>p_course_cd,
                                                                 p_message_name            =>l_message_name,
                                                                 p_deny_warn               =>l_deny_warn,
                                                                 p_return_status           =>l_ret_stat,
                                                                 p_enr_method              =>p_enroll_meth,
                                                                 p_enrolled_dt             =>NVL(p_enrolled_dt,SYSDATE));
                     EXCEPTION WHEN OTHERS THEN
                       l_deny_warn      := 'DENY';
                       l_ret_stat       := 'FALSE';
                     END;

                     IF l_ret_stat = 'FALSE' AND l_deny_warn ='DENY' THEN
                       --IF the units could not be confirmed then Rollback the changes and inlcude the success list in the failure list
                       ROLLBACK TO s_enr_sub_units;
                       IF l_sub_failed IS NULL THEN
                         l_sub_failed:=l_sub_success;
                       ELSE
                         l_sub_failed:=l_sub_failed||','||l_sub_success;
                       END IF;
                       l_sub_success:=NULL;
                     END IF;
                  END IF;


                  l_unit_attempt_status:=NULL;
                  IF l_sub_success IS NOT NULL THEN
                     fnd_message.set_name('IGS','IGS_EN_BLK_SUB_SUCCESS');
                     fnd_message.set_token('UNIT_CD',igs_en_gen_018.enrp_get_unitcds(l_sub_success));
                     IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_BLK_SUB_SUCCESS',  -- Subordinates enrolled successfully.
                                        cst_information || '|'||fnd_message.get);

                  END IF;
                  IF l_sub_waitlist IS NOT NULL THEN
                     fnd_message.set_name('IGS','IGS_EN_BLK_SUB_WLST');
                     fnd_message.set_token('UNIT_CD',igs_en_gen_018.enrp_get_unitcds(l_sub_waitlist));
                     IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_BLK_SUB_WLST',  -- Subordinates enrolled successfully.
                                        cst_information || '|'||fnd_message.get);
                  END IF;

                  IF l_sub_failed IS NOT NULL THEN
                    fnd_message.set_name('IGS','IGS_EN_BLK_SUB_FAILED');
                    fnd_message.set_token('UNIT_CD',igs_en_gen_018.enrp_get_unitcds(l_sub_failed));
                    IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_BLK_SUB_FAILED',  -- Subordinates enroll failed.
                                        cst_information || '|'||fnd_message.get);
                  END IF;
                END IF; --If superior

                --Validating the reenrollment unit validation for the unit attempt
                IF ((v_update_uoo) AND (p_enforce_val = 'Y'))  THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'REENROLL',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );

                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP'  );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_unit.eval_unit_reenroll( p_person_id             => p_person_id,
                                                                                 p_load_cal_type         => p_load_cal_type,
                                                                                 p_load_cal_seq_number   => p_load_seq_number,
                                                                                 p_uoo_id                => p_destination_uoo_id,
                                                                                 p_program_cd            => p_course_cd,
                                                                                 p_program_version       => p_version_number,
                                                                                 p_message               => l_message,
                                                                                 p_deny_warn             => l_notification_flag,
                                                                                 p_upd_cp                => NULL,
                                                                                 p_calling_obj           => 'JOB');
                         IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_REENROLL', -- Failed to transfer.
                                                                      cst_error || '|UNIT_REENR');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_REENROLL',
                                                                      cst_warning || '|UNIT_REENR');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                         END IF;
                     END IF;
                END IF;
                --Validating the MIN CP validation for the Program Attempt
                IF ((v_update_uoo) AND (p_enforce_val = 'Y') AND p_unit_attempt_status NOT IN (cst_unconfirm,cst_waitlisted))  THEN
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'PROGRAM',
                                                   p_step_type           => 'FMIN_CRDT',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );

                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP' );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;
                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         l_dummy_bolean := igs_en_elgbl_program.eval_min_cp( p_person_id              => p_person_id,
                                                                          p_load_calendar_type        => p_load_cal_type,
                                                                          p_load_cal_sequence_number  => p_load_seq_number,
                                                                          p_uoo_id                    => p_destination_uoo_id,
                                                                          p_program_cd                => p_course_cd,
                                                                          p_program_version           => p_version_number,
                                                                          p_message                   => l_message,
                                                                          p_deny_warn                 => l_notification_flag,
                                                                          p_credit_points             =>  l_credit_points ,
                                                                          p_enrollment_category       =>  p_enrolment_cat,
                                                                          p_comm_type                 =>  p_commencement_type,
                                                                          p_method_type               =>  p_enroll_meth ,
                                                                          p_min_credit_point          =>  l_total_credit_points,
                                                                          p_calling_obj               => 'JOB');
                         --
                         -- The value os the messages have to be checked to determine if the step evaluates to WARN / DENY programatically, based on the MinCP validation.
                         IF (NOT l_dummy_bolean) AND l_message = 'IGS_SS_WARN_MIN_CP_REACHED' THEN
                            l_notification_flag := 'WARN';
                         ELSIF (NOT l_dummy_bolean) AND l_message = 'IGS_SS_DENY_MIN_CP_REACHED' THEN
                            l_notification_flag := 'DENY';
                         END IF;

                         IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_MIN_CP', -- Failed to transfer.
                                                                      cst_error || '|PRG_MINCP');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                                    ROLLBACK TO sp_sua_blk_trn;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_MIN_CP',
                                                                      cst_warning || '|PRG_MINCP');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                         END IF;
                      END IF; ---l_notification_flag
                      IF (v_update_uoo) THEN
                          --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                          v_message_name := NULL;
                          l_notification_flag := NULL;
                          l_notification_flag  := igs_ss_enr_details.get_notification(
                                                       p_person_type         => p_person_type,
                                                       p_enrollment_category => p_enrolment_cat,
                                                       p_comm_type           => p_commencement_type,
                                                       p_enr_method_type     => p_enroll_meth,
                                                       p_step_group_type     => 'PROGRAM',
                                                       p_step_type           => 'FATD_TYPE',
                                                       p_person_id           => p_person_id,
                                                       p_message             => v_message_name
                                                       );
                          IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP' );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                          END IF;
                          IF l_notification_flag IS NOT NULL THEN
                             l_message:= NULL;
                             l_dummy_bolean:=NULL;
                             l_dummy_bolean := igs_en_elgbl_program.eval_unit_forced_type( p_person_id                 => p_person_id,
                                                                                           p_load_calendar_type        => p_load_cal_type,
                                                                                           p_load_cal_sequence_number  => p_load_seq_number,
                                                                                           p_uoo_id                    => p_destination_uoo_id,
                                                                                           p_course_cd                 => p_course_cd,
                                                                                           p_course_version            => p_version_number,
                                                                                           p_message                   => l_message,
                                                                                           p_deny_warn                 => NVL(p_deny_warn_att,l_notification_flag),
                                                                                           p_enrollment_category       => p_enrolment_cat,
                                                                                           p_comm_type                 => p_commencement_type,
                                                                                           p_method_type               => p_enroll_meth,
                                                                                           p_calling_obj               => 'JOB' );

                             --
                             -- The value of the messages have to be checked to determine if the step evaluates to WARN / DENY programatically, based on the MinCP validation.
                             IF (NOT l_dummy_bolean) AND l_message = 'IGS_SS_WARN_ATTYPE_CHK' THEN
                                l_notification_flag := 'WARN';
                             ELSIF (NOT l_dummy_bolean) AND l_message = 'IGS_SS_DENY_ATTYPE_CHK' THEN
                                l_notification_flag := 'DENY';
                             END IF;

                             IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                       IGS_GE_INS_SLE.genp_set_log_entry(
                                                                         cst_enr_blk_uo,
                                                                         cst_blk_uoo,
                                                                         v_key,
                                                                         'IGS_EN_TRN_FAIL_ATT_TYP', -- Failed to transfer.
                                                                          cst_error || '|PRG_ATT');
                                        p_sua_error_count := p_sua_error_count + 1;
                                        v_update_uoo := FALSE;
                                        ROLLBACK TO sp_sua_blk_trn;
                             ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                       IGS_GE_INS_SLE.genp_set_log_entry(
                                                                         cst_enr_blk_uo,
                                                                         cst_blk_uoo,
                                                                         v_key,
                                                                         'IGS_EN_TRN_WARN_ATT_TYP',
                                                                          cst_warning || '|PRG_ATT');
                                       p_sua_warn_count := p_sua_warn_count + 1;
                             END IF;
                          END IF;
                      END IF; -- IF (v_update_uoo)
                      IF (v_update_uoo) THEN
                          -- Validate Cross Location credit points
                          --Igs_Ss_Enr_Details.get_notification returns NULL means that Program step is not defined.
                          v_message_name := NULL;
                          l_notification_flag := NULL;
                          l_notification_flag  := igs_ss_enr_details.get_notification(
                                                       p_person_type         => p_person_type,
                                                       p_enrollment_category => p_enrolment_cat,
                                                       p_comm_type           => p_commencement_type,
                                                       p_enr_method_type     => p_enroll_meth,
                                                       p_step_group_type     => 'PROGRAM',
                                                       p_step_type           => 'CROSS_LOC',
                                                       p_person_id           => p_person_id,
                                                       p_message             => v_message_name
                                                       );
                               IF v_message_name IS NOT NULL THEN
                                     IGS_GE_INS_SLE.genp_set_log_entry(
                                                               cst_enr_blk_uo,
                                                               cst_blk_uoo,
                                                               v_key,
                                                               v_message_name,
                                                               cst_error || '|PERID_GRP' );
                                     p_sua_error_count := p_sua_error_count + 1;
                                     v_update_uoo := FALSE;
                               END IF;
                          IF l_notification_flag IS NOT NULL THEN
                             l_message:= NULL;
                             l_dummy_bolean:=NULL;
                             -- passing 0 to p_upd_cp as the unit attempt is created already, which would considered inside the function
                             -- for credit point calculation
                             l_dummy_bolean := igs_en_elgbl_program.eval_cross_validation ( p_person_id                 => p_person_id,
                                                                                           p_load_cal_type        => p_load_cal_type,
                                                                                           p_load_ci_sequence_number  => p_load_seq_number,
                                                                                           p_uoo_id                    => p_destination_uoo_id,
                                                                                           p_course_cd                 => p_course_cd,
                                                                                           p_program_version            => p_version_number,
                                                                                           p_message                   => l_message,
                                                                                           p_deny_warn                 =>  l_notification_flag,
                                                                                           p_upd_cp                    =>  NULL ,
                                                                                           p_eligibility_step_type       => 'CROSS_LOC',
                                                                                           p_calling_obj               => 'JOB' );
                             IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                       IGS_GE_INS_SLE.genp_set_log_entry(
                                                                         cst_enr_blk_uo,
                                                                         cst_blk_uoo,
                                                                         v_key,
                                                                         'IGS_EN_TRN_FAIL_CRS_LOC', -- Failed to transfer.
                                                                          cst_error || '|PRG_CL');
                                        p_sua_error_count := p_sua_error_count + 1;
                                        v_update_uoo := FALSE;
                                        ROLLBACK TO sp_sua_blk_trn;
                             ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                       IGS_GE_INS_SLE.genp_set_log_entry(
                                                                         cst_enr_blk_uo,
                                                                         cst_blk_uoo,
                                                                         v_key,
                                                                         'IGS_EN_TRN_WARN_CRS_LOC',
                                                                          cst_warning || '|PRG_CL');
                                       p_sua_warn_count := p_sua_warn_count + 1;
                             END IF;
                          END IF ;
                  END IF; -- IF (v_update_uoo)
                  IF (v_update_uoo) THEN
                      -- Validate Cross Mode credit points
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that Program step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'PROGRAM',
                                                   p_step_type           => 'CROSS_MOD',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );

                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name,
                                                           cst_error || '|PERID_GRP' );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         -- passing 0 to p_upd_cp as the unit attempt is created already, which would considered inside the function
                         -- for credit point calculation
                         l_dummy_bolean := igs_en_elgbl_program.eval_cross_validation (  p_person_id                 => p_person_id,
                                                                                       p_load_cal_type        => p_load_cal_type,
                                                                                       p_load_ci_sequence_number  => p_load_seq_number,
                                                                                       p_uoo_id                    => p_destination_uoo_id,
                                                                                       p_course_cd                 => p_course_cd,
                                                                                       p_program_version            => p_version_number,
                                                                                       p_message                   => l_message,
                                                                                       p_deny_warn                 =>  l_notification_flag,
                                                                                       p_upd_cp                    =>  NULL,
                                                                                       p_eligibility_step_type   => 'CROSS_MOD',
                                                                                       p_calling_obj               => 'JOB' );

                         IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_CRS_MOD', -- Failed to transfer.
                                                                      cst_error || '|PRG_CM');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                                    ROLLBACK TO sp_sua_blk_trn;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_CRS_MOD',
                                                                      cst_warning || '|PRG_CM');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                         END IF;
                    END IF ;
                  END IF; --  IF (v_update_uoo)
                  IF (v_update_uoo) THEN
                      -- Validate Cross Faculty credit points
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that Program step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'PROGRAM',
                                                   p_step_type           => 'CROSS_FAC',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );

                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name,
                                                           cst_error || '|PERID_GRP' );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         -- passing 0 to p_upd_cp as the unit attempt is created already, which would considered inside the function
                         -- for credit point calculation
                         l_dummy_bolean := igs_en_elgbl_program.eval_cross_validation ( p_person_id                 => p_person_id,
                                                                                       p_load_cal_type        => p_load_cal_type,
                                                                                       p_load_ci_sequence_number  => p_load_seq_number,
                                                                                       p_uoo_id                    => p_destination_uoo_id,
                                                                                       p_course_cd                 => p_course_cd,
                                                                                       p_program_version            => p_version_number,
                                                                                       p_message                   => l_message,
                                                                                       p_deny_warn                 =>  l_notification_flag,
                                                                                       p_upd_cp                    =>  NULL,
                                                                                       p_eligibility_step_type   => 'CROSS_FAC',
                                                                                       p_calling_obj               => 'JOB' );

                         IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_CRS_FAC', -- Failed to transfer.
                                                                      cst_error || '|PRG_CF');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                                    ROLLBACK TO sp_sua_blk_trn;
                         ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_CRS_FAC',
                                                                      cst_warning || '|PRG_CF');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                         END IF;
                    END IF ;
                  END IF; -- IF (v_update_uoo)
                END IF; ---MIN CP

                --Validating unit coreq unit section rule.
                IF ((v_update_uoo) AND (p_enforce_val = 'Y') AND (p_unit_attempt_status <> cst_unconfirm))  THEN
                      -- getting the notification flag for evaluate COREQ unit validation
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'COREQ',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );
                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP' );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         --Checking the co-req validation.
                         l_dummy_bolean := igs_en_elgbl_unit.eval_coreq(
                                                                         p_person_id
                                                                        ,p_load_cal_type
                                                                        ,p_load_seq_number
                                                                        ,p_destination_uoo_id
                                                                        ,p_course_cd
                                                                        ,p_version_number
                                                                        ,l_message
                                                                        ,l_notification_flag
                                                                        ,'JOB');
                          IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_COREQ_RULE', -- Failed to transfer.
                                                                      cst_error || '|COREQ');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                                    ROLLBACK TO sp_sua_blk_trn;
                          ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_COREQ_RULE',
                                                                      cst_warning || '|COREQ');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                          END IF;
                     END IF;
                END IF;

                --Validating unit pre-req unit section rule.
                IF ((v_update_uoo) AND (p_enforce_val = 'Y') )  THEN
                      -- getting the notification flag for evaluate Pre-REQ unit validation
                      --Igs_Ss_Enr_Details.get_notification returns NULL means that unit step is not defined.
                      v_message_name := NULL;
                      l_notification_flag := NULL;
                      l_notification_flag  := igs_ss_enr_details.get_notification(
                                                   p_person_type         => p_person_type,
                                                   p_enrollment_category => p_enrolment_cat,
                                                   p_comm_type           => p_commencement_type,
                                                   p_enr_method_type     => p_enroll_meth,
                                                   p_step_group_type     => 'UNIT',
                                                   p_step_type           => 'PREREQ',
                                                   p_person_id           => p_person_id,
                                                   p_message             => v_message_name
                                                   );

                           IF v_message_name IS NOT NULL THEN
                                 IGS_GE_INS_SLE.genp_set_log_entry(
                                                           cst_enr_blk_uo,
                                                           cst_blk_uoo,
                                                           v_key,
                                                           v_message_name, -- person belongs to more than one person ID group.
                                                           cst_error || '|PERID_GRP' );
                                 p_sua_error_count := p_sua_error_count + 1;
                                 v_update_uoo := FALSE;
                           END IF;

                      IF l_notification_flag IS NOT NULL THEN
                         l_message:= NULL;
                         l_dummy_bolean:=NULL;
                         --Checking the pre-req validation.
                         l_dummy_bolean := igs_en_elgbl_unit.eval_prereq(
                                                                         p_person_id
                                                                        ,p_load_cal_type
                                                                        ,p_load_seq_number
                                                                        ,p_destination_uoo_id
                                                                        ,p_course_cd
                                                                        ,p_version_number
                                                                        ,l_message
                                                                        ,l_notification_flag
                                                                        ,'JOB');
                          IF ((NOT l_dummy_bolean) AND (l_notification_flag = 'DENY')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_FAIL_PREREQ_RULE', -- Failed to transfer.
                                                                      cst_error || '|PREREQ');
                                    p_sua_error_count := p_sua_error_count + 1;
                                    v_update_uoo := FALSE;
                                    ROLLBACK TO sp_sua_blk_trn;
                          ELSIF ((NOT l_dummy_bolean) AND (l_notification_flag = 'WARN')) THEN
                                   IGS_GE_INS_SLE.genp_set_log_entry(
                                                                     cst_enr_blk_uo,
                                                                     cst_blk_uoo,
                                                                     v_key,
                                                                     'IGS_EN_TRN_WARN_PREREQ_RULE',
                                                                      cst_warning || '|PREREQ');
                                   p_sua_warn_count := p_sua_warn_count + 1;
                          END IF;
                     END IF;
                END IF;
                IF v_update_uoo THEN
                        -- Log that the IGS_PS_UNIT has been updated.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_key,
                                        'IGS_EN_STUD_SUCCESS_TRSF_UOO',  -- Successfully transferred.
                                        cst_information || '|' || cst_transferred);
                        p_sua_trnsfr_count := p_sua_trnsfr_count + 1;
                        -- Set the flag to indicate processing has occurred.
                        p_processing_occurred := TRUE;
                END IF;
                RETURN;
        -- Local exception handler.
        EXCEPTION
                WHEN e_resource_busy_exception THEN
                        -- Roll back transaction.
                        ROLLBACK TO sp_sua_blk_trn;
                        -- Log that a locked record exists and
                        -- rollback has occurred.
                        IGS_GE_INS_SLE.genp_set_log_entry(
                                        cst_enr_blk_uo,
                                        cst_blk_uoo,
                                        v_course_key,
                                        'IGS_EN_ALLALT_APPL_STUD_PRG',
                                        'ERROR|LOCK');
                        -- Add to count and continue processing.
                        v_total_lock_count := v_total_lock_count + 1;
                        RETURN;
                WHEN OTHERS THEN
                        IF c_uoo%ISOPEN THEN
                                CLOSE c_uoo;
                        END IF;
                        IF c_sua_upd%ISOPEN THEN
                                CLOSE c_sua_upd;
                        END IF;
                        RAISE;
        END;
        END enrpl_upd_sua_uoo;
  BEGIN -- enrp_prc_sua_blk_trn

        --adding invoke source to correct _actual counter handling of the USEC
        igs_en_gen_017.g_invoke_source := 'JOB';

        -- Determine the academic period for the teaching period.
        v_alt_cd := IGS_EN_GEN_002.enrp_get_acad_alt_cd(
                                                         p_teach_cal_type,
                                                         p_teach_ci_sequence_number,
                                                         v_acad_cal_type,
                                                         v_acad_ci_sequence_number,
                                                         v_acad_ci_start_dt,
                                                         v_acad_ci_end_dt,
                                                         v_message_name);

        IF v_message_name is not null THEN
                Fnd_Message.Set_name('IGS',v_message_name);
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END IF;
        -- Determine the start and end dates of the teaching
        -- period by calling calp_get_ci_dates.
        IGS_CA_GEN_001.calp_get_ci_dates(
                                          p_teach_cal_type,
                                          p_teach_ci_sequence_number,
                                       v_teach_start_dt,
                        v_teach_end_dt);
        IGS_GE_INS_SLE.genp_set_log_cntr;

        --Get the load calendar for a given calendar teaching calendar
        OPEN cur_load1;
        FETCH cur_load1 INTO l_load_cal_type,l_load_seq_number;
        CLOSE cur_load1;


        -- Determine students to be processed.
        FOR v_sua_rec IN c_sua(l_load_cal_type,l_load_seq_number) LOOP
            BEGIN       -- exception handler
                SAVEPOINT sp_sua_blk_trn;
                v_rollback_occurred := FALSE;
                v_processing_occurred := FALSE;
                -- Initialise counters
                v_error_count           := 0;
                v_warn_count            := 0;
                v_sua_trnsfr_count      := 0;
                v_course_key := TO_CHAR(v_sua_rec.person_id) || '|' ||
                v_sua_rec.course_cd;
                -- Determine the IGS_PS_UNIT offering option that the student IGS_PS_UNIT attempt
                -- is to be changed too.
                -- If parameter is null, use the existing values selected for the sua.
                v_to_uv_version_number  := NVL(p_to_uv_version_number,
                                                v_sua_rec.version_number);
                v_to_location_cd := NVL(p_to_location_cd,
                                        v_sua_rec.location_cd);
                v_to_unit_class := NVL(p_to_unit_class,
                                        v_sua_rec.unit_class);
                -- If the IGS_PS_UNIT offering is not being changed, then skip the IGS_PS_UNIT attempt.
                IF v_sua_rec.version_number <> v_to_uv_version_number OR
                   v_sua_rec.location_cd <> v_to_location_cd OR
                   v_sua_rec.unit_class <> v_to_unit_class THEN

                        -- Validate that the process has not been scheduled to run outside
                        -- the enrolment/variation windows for the teaching period.
                        --moved this call from BEGIN to here ,for enrollment processes dld
                        --bug#1832130 by smaddali , to include uoo_id
                        IF NOT IGS_EN_GEN_008.enrp_get_var_window(
                                        p_teach_cal_type,
                                        p_teach_ci_sequence_number,
                                        SYSDATE ,
                                        --added this parameter as impact of change in the procedure
                                        -- for enrollment processes dld bug#1832130
                                        v_sua_rec.uoo_id) THEN

                                v_text := 'ERROR|'||FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_ERR_VAR_WIND');
                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                                cst_enr_blk_uo,
                                                                cst_blk_uoo,
                                                                v_course_key,
                                                                'IGS_EN_SUA_NOTALT_CUTOFDT',
                                                                v_text);
                                v_error_count := v_error_count + 1;
                                -- skip this unit attempt
                        ELSE
                               -- Determine the Enrollment method , Enrollment Commencement type.
                               l_enrolment_cat:=IGS_EN_GEN_003.Enrp_Get_Enr_Cat(
                                                                                 v_sua_rec.person_id,
                                                                                 v_sua_rec.course_cd,
                                                                                 v_acad_cal_type,
                                                                                 v_acad_ci_sequence_number,
                                                                                 NULL,
                                                                                 l_en_cal_type,
                                                                                 l_en_ci_seq_num,
                                                                                 l_commencement_type,
                                                                                 l_dummy);
                               -- getting the person type of logged in person
                               l_person_type := Igs_En_Gen_008.enrp_get_person_type(p_course_cd =>NULL);
                               l_waitlist_flag := 'N';


                                enrpl_upd_sua_uoo(
                                                  v_sua_rec.person_id,
                                                  v_sua_rec.course_cd,
                                                  v_sua_rec.program_version_number,
                                                  v_sua_rec.version_number,
                                                  v_sua_rec.uoo_id,
                                                  v_teach_end_dt,
                                                  v_sua_rec.location_cd,
                                                  v_sua_rec.unit_class,
                                                  v_sua_rec.unit_attempt_status,
                                                  v_sua_rec.enrolled_dt,
                                                  v_to_uv_version_number,
                                                  v_to_location_cd,
                                                  v_to_unit_class,
                                                  v_error_count,
                                                  v_warn_count,
                                                  v_sua_trnsfr_count,
                                                  v_processing_occurred,
                                                  l_person_type,
                                                  l_enrolment_cat,
                                                  l_commencement_type,
                                                  p_enforce_val,
                                                  p_enroll_method,
                                                  p_reason,
                                                  l_load_cal_type,
                                                  l_load_seq_number,
                                                  l_waitlist_flag,
                                                  l_destination_uoo_id,
                                                  v_acad_cal_type,
                                                  v_acad_ci_sequence_number
                                                  );
                          -- Initialise the message number;
                          v_message_name := null;
                          v_error_occurred := FALSE;
                          IF v_processing_occurred AND p_enforce_val ='Y' THEN
                                -- Create a log entry to allow the
                                -- called module to log IGS_GE_EXCEPTIONS.
                                IGS_GE_GEN_003.genp_ins_log(
                                        cst_enr_blk_uo,
                                        cst_unit_rule_check,
                                        v_rule_creation_dt);
                                -- Call the routine to process the IGS_PS_UNIT
                                -- rules checking for a IGS_PE_PERSON's IGS_PS_COURSE.
                                IF NOT IGS_EN_GEN_012.enrp_upd_sca_urule(
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                v_sua_rec.person_id,
                                                v_sua_rec.course_cd,
                                                cst_enr_blk_uo,
                                                v_rule_creation_dt) THEN

                                        -- IGS_GE_EXCEPTIONS have been created by enrp_upd_sca_urule.
                                        -- Log them with the bulk processing and remove the
                                        -- entries created by enrp_upd_sca_urule.
                                        FOR v_sle_rec IN c_sle(
                                                                v_rule_creation_dt) LOOP
                                                -- Insert log entry.
                                                -- Set the IGS_PS_UNIT and teaching period details.
                                                v_text := cst_rule_check || '|' ||
                                                        IGS_GE_GEN_002.genp_get_delimit_str(
                                                                        v_sle_rec.key,
                                                                        6,
                                                                        ',') || '|' ||
                                                        IGS_GE_GEN_002.genp_get_delimit_str(
                                                                        v_sle_rec.key,
                                                                        7,
                                                                        ',') || '|' ||
                                                        IGS_GE_GEN_002.genp_get_delimit_str(
                                                                        v_sle_rec.key,
                                                                        8,
                                                                        ',');
                                                -- Determine the type of exception.
                                                v_validation_error := FALSE;
                                                IF IGS_GE_GEN_002.genp_get_delimit_str(
                                                                        v_sle_rec.key,
                                                                        2,
                                                                        ',') = cst_att_date THEN
                                                        v_text := cst_warning || '|' || v_text;
                                                ELSIF IGS_GE_GEN_002.genp_get_delimit_str(
                                                                        v_sle_rec.key,
                                                                        2,
                                                                        ',') = cst_changed THEN
                                                        v_text := cst_information || '|' || v_text;
                                                ELSIF IGS_GE_GEN_002.genp_get_delimit_str(
                                                                        v_sle_rec.key,
                                                                        2,
                                                                        ',') = cst_att_valid THEN
                                                        v_text := cst_error || '|' || v_text;
                                                        v_validation_error := TRUE;
                                                END IF;
                                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                                cst_enr_blk_uo,
                                                                cst_blk_uoo,
                                                                v_course_key,
                                                                v_sle_rec.message_name,
                                                                v_text);
                                                -- If the IGS_PS_UNIT is invalid, log the text returned
                                                -- from the IGS_RU_RULE checking routine explaining why
                                                -- the IGS_RU_RULE is invalid.
                                                IF IGS_GE_GEN_002.genp_get_delimit_str(
                                                                        v_sle_rec.key,
                                                                        3,
                                                                        ',') = cst_invalid THEN
                                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                                        cst_enr_blk_uo,
                                                                        cst_blk_uoo,
                                                                        v_course_key,
                                                                        NULL,
                                                                        v_sle_rec.text);
                                                END IF;
                                                IF v_validation_error THEN
                                                        -- Log a message indicating that the IGS_PS_UNIT was
                                                        -- not set to enrolled because of a validation error.
                                                        IGS_GE_INS_SLE.genp_set_log_entry(
                                                                        cst_enr_blk_uo,
                                                                        cst_blk_uoo,
                                                                        v_course_key,
                                                                        'IGS_EN_US_FAILS_ST_ENROLLED',
                                                                        cst_information || '|');
                                                END IF;
                                        END LOOP;
                                END IF; -- end of rules failed
                                -- Remove the temporary log entries.
                                FOR v_sle_del_exists IN c_sle_del(
                                                                v_rule_creation_dt) LOOP
                                                        IGS_GE_S_LOG_ENTRY_PKG.DELETE_ROW(
                                                                            v_sle_del_exists.rowid);

                                END LOOP;
                                -- Remove the temporary log entries.
                                FOR v_sl_del_exists IN c_sl_del(
                                                                v_rule_creation_dt) LOOP
                                             IGS_GE_S_LOG_PKG.DELETE_ROW(
                                                                     v_sl_del_exists.rowid);

                                END LOOP;
                                -- Log errors and continue.
                                IF NOT v_rollback_occurred THEN
                                        IF (v_message_name IS NOT NULL) THEN
                                                -- Log the warning returned form enrp_val_sua_cnfrm_p
                                                v_text := cst_warning || '|';
                                                v_text := v_text || v_fail_type;
                                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                                        cst_enr_blk_uo,
                                                                        cst_blk_uoo,
                                                                        v_course_key,
                                                                        v_message_name,
                                                                        v_text);
                                        END IF;
                                END IF; -- end of not rollback occured
                        END IF; -- end of processing occured
                  END IF; -- check if outside enrollment variation window  for the unit section
                ELSE
                     --Log error message saying, Cannot transfer the Unit Section between the same source and destination
                     IGS_GE_INS_SLE.genp_set_log_entry(
                                                       cst_enr_blk_uo,
                                                       cst_blk_uoo,
                                                       v_course_key,
                                                       'IGS_EN_NO_TRN_SAME_USEC', -- Failed to transfer as option does not exist.
                                                       'ERROR|NO_TRANS');
                     v_error_count := v_error_count + 1;
                END IF; -- Check if IGS_PS_UNIT version/offering being altered.

                --Calling  procedure to raise business event when unit is transferred
                IF v_processing_occurred THEN
                    IF l_waitlist_flag = 'Y' THEN
                       l_unit_attempt_status := 'WAITLISTED';
                    ELSE
                       l_unit_attempt_status := 'ENROLLED';
                    END IF;
                    --Calling  procedure to raise business event when unit is transferred
                    igs_ss_en_wrappers.transfer_workflow(
                                                         p_source_uoo_ids       => v_sua_rec.uoo_id,
                                                         p_dest_uoo_ids         => l_destination_uoo_id,
                                                         p_person_id            => v_sua_rec.person_id,
                                                         p_load_cal_type        => l_load_cal_type,
                                                         p_load_sequence_number => l_load_seq_number,
                                                         p_program_cd           => v_sua_rec.course_cd,
                                                         p_unit_attempt_status  => l_unit_attempt_status,
                                                         p_reason               => p_reason,
                                                         p_return_status        => l_dummy1,
                                                         p_message              => l_dummy1
                                                         );

                END IF; --end of workflow notification

                -- Add counts to total
                v_total_sua_count         := v_total_sua_count + 1;
                v_total_sua_error_count   := v_total_sua_error_count + v_error_count;
                v_total_sua_warn_count    := v_total_sua_warn_count + v_warn_count;
                v_total_sua_trnsfr_count  := v_total_sua_trnsfr_count + v_sua_trnsfr_count;
                -- Local exception handler.
                EXCEPTION
                        WHEN e_resource_busy_exception THEN
                                -- Roll back transaction.
                                ROLLBACK TO sp_sua_blk_trn;
                                -- Log that a locked record exists and
                                -- rollback has occurred.
                                IGS_GE_INS_SLE.genp_set_log_entry(
                                                cst_enr_blk_uo,
                                                cst_blk_uoo,
                                                v_course_key,
                                                'IGS_EN_ALLALT_APPL_STUD_PRG',
                                                'ERROR|LOCK');
                                -- Add to count and continue processing.
                                v_total_lock_count := v_total_lock_count + 1;
                        WHEN OTHERS THEN
                                RAISE;
                END;    -- exception handler.
        END LOOP; -- end of unit attempts loop
        -- Log the summary counts.
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_PROC_COUNT')||'|'||TO_CHAR(v_total_sua_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_ERR_COUNT')||'|'||TO_CHAR(v_total_sua_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_WARN_COUNT')||'|'||TO_CHAR(v_total_sua_warn_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_TRAN_COUNT')||'|'||TO_CHAR(v_total_sua_trnsfr_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_ENCUM_COUNT')||'|'||TO_CHAR(v_total_encumb_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_PRG_ERR_COUNT')||'|'||TO_CHAR(v_total_course_error_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_PRG_WRN_COUNT')||'|'||TO_CHAR(v_total_course_warn_count));
        IGS_GE_INS_SLE.genp_set_log_entry(
                        cst_enr_blk_uo,
                        cst_blk_uoo,
                        cst_summary,
                        NULL,
                        FND_MESSAGE.GET_STRING('IGS','IGS_EN_TRN_TOT_PRG_LCK_COUNT')||'|'||  TO_CHAR(v_total_lock_count));
        -- Insert the log entries.
        IGS_GE_INS_SLE.genp_ins_sle(
                                v_creation_dt);
        p_creation_dt := v_creation_dt;
        COMMIT;
        RETURN;
  EXCEPTION
        WHEN OTHERS THEN

                IF c_sua%ISOPEN THEN
                        CLOSE c_sua;
                END IF;
                IF c_sle%ISOPEN THEN
                        CLOSE c_sle;
                END IF;
                IF c_sle_del%ISOPEN THEN
                        CLOSE c_sle_del;
                END IF;
                IF c_sl_del%ISOPEN THEN
                        CLOSE c_sl_del;
                END IF;
                RAISE;
  END;
END enrp_prc_sua_blk_trn;


Procedure Enrp_Set_Pee_Expry(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_sequence_number IN NUMBER ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
 IS
/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         3-OCT-2002      Bug No: 2600842
  ||                                  Added logic for the new table IGS_PE_FUND_EXCL
  ||  (reverse chronological order - newest change first)
*/
BEGIN   -- enrp_set_pee_expry
        -- Set the expiry date for all cild records of the nominated pee
        -- when the expiry_dt is set
  DECLARE
        e_resource_busy         EXCEPTION;
        PRAGMA  EXCEPTION_INIT(e_resource_busy, -54);
        v_check         VARCHAR2(1);
        v_ret_val       BOOLEAN := TRUE;
        CURSOR c_person_crs_grp_exclusion IS
                SELECT  rowid, IGS_PE_CRS_GRP_EXCL.*
                FROM    IGS_PE_CRS_GRP_EXCL
                WHERE
                        person_id               = p_person_id           AND
                        encumbrance_type        = p_encumbrance_type    AND
                        pen_start_dt            = p_pen_start_dt        AND
                        s_encmb_effect_type     = p_effect_type         AND
                        pee_start_dt            = p_pee_start_dt        AND
                        pee_sequence_number     = p_sequence_number     AND
                        (expiry_dt              IS NULL OR
                         expiry_dt               > p_expiry_dt)
                FOR UPDATE OF expiry_dt NOWAIT;
        CURSOR c_person_course_exclusion IS
                SELECT  rowid,
                        IGS_PE_COURSE_EXCL.*
                FROM    IGS_PE_COURSE_EXCL
                WHERE
                        person_id               = p_person_id           AND
                        encumbrance_type        = p_encumbrance_type    AND
                        pen_start_dt            = p_pen_start_dt        AND
                        s_encmb_effect_type     = p_effect_type         AND
                        pee_start_dt            = pee_start_dt          AND
                        pee_sequence_number     = p_sequence_number     AND
                        (expiry_dt              IS NULL OR
                         expiry_dt              > p_expiry_dt)
                FOR UPDATE OF expiry_dt NOWAIT;
        CURSOR c_person_unit_exclusion IS
                SELECT  rowid,IGS_PE_PERS_UNT_EXCL.*
                FROM    IGS_PE_PERS_UNT_EXCL
                WHERE
                        person_id               = p_person_id           AND
                        encumbrance_type        = p_encumbrance_type    AND
                        pen_start_dt            = p_pen_start_dt        AND
                        s_encmb_effect_type     = p_effect_type         AND
                        pee_start_dt            = pee_start_dt          AND
                        pee_sequence_number     = p_sequence_number     AND
                        (expiry_dt              IS NULL OR
                         expiry_dt              > p_expiry_dt)
                FOR UPDATE OF expiry_dt NOWAIT;

        CURSOR fund_exclusion_cur IS
                SELECT  rowid,igs_pe_fund_excl.*
                FROM    igs_pe_fund_excl
                WHERE
                        person_id               = p_person_id           AND
                        encumbrance_type        = p_encumbrance_type    AND
                        pen_start_dt            = p_pen_start_dt        AND
                        s_encmb_effect_type     = p_effect_type         AND
                        pee_start_dt            = pee_start_dt          AND
                        pee_sequence_number     = p_sequence_number     AND
                        (expiry_dt              IS NULL OR
                         expiry_dt              > p_expiry_dt)
                FOR UPDATE OF expiry_dt NOWAIT;

        CURSOR c_person_unit_requirement IS
                SELECT  rowid,IGS_PE_UNT_REQUIRMNT.*
                FROM    IGS_PE_UNT_REQUIRMNT
                WHERE
                        person_id               = p_person_id           AND
                        encumbrance_type        = p_encumbrance_type    AND
                        pen_start_dt            = p_pen_start_dt        AND
                        s_encmb_effect_type     = p_effect_type         AND
                        pee_start_dt            = pee_start_dt          AND
                        pee_sequence_number     = p_sequence_number     AND
                        (expiry_dt              IS NULL OR
                         expiry_dt              > p_expiry_dt)
                FOR UPDATE OF expiry_dt NOWAIT;

               l_dcd_date  DATE;

  BEGIN
        p_message_name := null;
        -- Validate input parameters
        IF (    p_person_id             IS NULL OR
                p_encumbrance_type      IS NULL OR
                p_pen_start_dt          IS NULL OR
                p_effect_type           IS NULL OR
                p_pee_start_dt          IS NULL OR
                p_sequence_number       IS NULL OR
                p_expiry_dt             IS NULL) THEN
                RETURN;
        END IF;
        FOR v_pcge_rec IN c_person_crs_grp_exclusion LOOP


                              SELECT DECODE(GREATEST(v_pcge_rec.pcge_start_dt, p_expiry_dt),v_pcge_rec.pcge_start_dt, v_pcge_rec.pcge_start_dt, p_expiry_dt)
                              INTO   l_dcd_date
                              FROM DUAL;

                                 IGS_PE_CRS_GRP_EXCL_PKG.UPDATE_ROW(
                                        X_ROWID => v_pcge_rec.ROWID ,
                                        X_PERSON_ID  =>  v_pcge_rec.PERSON_ID ,
                                        X_ENCUMBRANCE_TYPE => v_pcge_rec.ENCUMBRANCE_TYPE ,
                                        X_PEN_START_DT  => v_pcge_rec.PEN_START_DT ,
                                        X_S_ENCMB_EFFECT_TYPE => v_pcge_rec.S_ENCMB_EFFECT_TYPE,
                                        X_PEE_START_DT  => v_pcge_rec.PEE_START_DT ,
                                        X_PEE_SEQUENCE_NUMBER  => v_pcge_rec.PEE_SEQUENCE_NUMBER,
                                        X_COURSE_GROUP_CD => v_pcge_rec.COURSE_GROUP_CD,
                                        X_PCGE_START_DT  => v_pcge_rec.PCGE_START_DT ,
                                        X_EXPIRY_DT  => l_dcd_date,
                                        X_MODE => 'R' );

        END LOOP;


        FOR v_pce_rec IN c_person_course_exclusion LOOP

                             SELECT DECODE(GREATEST(v_pce_rec.pce_start_dt, p_expiry_dt),v_pce_rec.pce_start_dt, v_pce_rec.pce_start_dt,p_expiry_dt)
                              INTO   l_dcd_date
                              FROM DUAL;


                                     IGS_PE_COURSE_EXCL_PKG.UPDATE_ROW(
                                                X_ROWID => v_pce_rec.ROWID ,
                                                X_PERSON_ID => v_pce_rec.PERSON_ID  ,
                                                X_ENCUMBRANCE_TYPE => v_pce_rec.ENCUMBRANCE_TYPE ,
                                                X_PEN_START_DT => v_pce_rec.PEN_START_DT  ,
                                                X_S_ENCMB_EFFECT_TYPE => v_pce_rec.S_ENCMB_EFFECT_TYPE ,
                                                X_PEE_START_DT => v_pce_rec.PEE_START_DT,
                                                X_PEE_SEQUENCE_NUMBER => v_pce_rec.PEE_SEQUENCE_NUMBER  ,
                                                X_COURSE_CD => v_pce_rec.COURSE_CD ,
                                                X_PCE_START_DT => v_pce_rec.PCE_START_DT  ,
                                                X_EXPIRY_DT =>  l_dcd_date ,
                                                X_MODE => 'R');

        END LOOP;
        FOR v_pue_rec IN c_person_unit_exclusion LOOP

                              SELECT DECODE(GREATEST(v_pue_rec.pue_start_dt, p_expiry_dt),
                                                                        v_pue_rec.pue_start_dt, v_pue_rec.pue_start_dt,
                                                                        p_expiry_dt)
                              INTO   l_dcd_date
                              FROM DUAL;

                              IGS_PE_PERS_UNT_EXCL_PKG.UPDATE_ROW(
                                                   X_ROWID => v_pue_rec.ROWID ,
                                                   X_PERSON_ID => v_pue_rec.PERSON_ID ,
                                                   X_ENCUMBRANCE_TYPE => v_pue_rec.ENCUMBRANCE_TYPE ,
                                                   X_PEN_START_DT => v_pue_rec.PEN_START_DT ,
                                                   X_S_ENCMB_EFFECT_TYPE => v_pue_rec.S_ENCMB_EFFECT_TYPE ,
                                                   X_PEE_START_DT => v_pue_rec.PEE_START_DT ,
                                                   X_PEE_SEQUENCE_NUMBER => v_pue_rec.PEE_SEQUENCE_NUMBER ,
                                                   X_UNIT_CD => v_pue_rec.UNIT_CD ,
                                                   X_PUE_START_DT => v_pue_rec.PUE_START_DT ,
                                                   X_EXPIRY_DT =>  l_dcd_date,
                                                   X_MODE  =>  'R'
                                                                );

        END LOOP;
        FOR v_pur_rec IN c_person_unit_requirement LOOP

                   SELECT  DECODE(GREATEST(v_pur_rec.pur_start_dt, p_expiry_dt),v_pur_rec.pur_start_dt, v_pur_rec.pur_start_dt,p_expiry_dt)
                              INTO   l_dcd_date
                              FROM DUAL;


                     IGS_PE_UNT_REQUIRMNT_PKG.UPDATE_ROW(
                                         X_ROWID => v_pur_rec.ROWID ,
                                         X_PERSON_ID => v_pur_rec.PERSON_ID ,
                                         X_ENCUMBRANCE_TYPE => v_pur_rec.ENCUMBRANCE_TYPE ,
                                         X_PEN_START_DT => v_pur_rec.PEN_START_DT ,
                                         X_S_ENCMB_EFFECT_TYPE => v_pur_rec.S_ENCMB_EFFECT_TYPE ,
                                         X_PEE_START_DT => v_pur_rec.PEE_START_DT ,
                                         X_PEE_SEQUENCE_NUMBER => v_pur_rec.PEE_SEQUENCE_NUMBER ,
                                         X_UNIT_CD => v_pur_rec.UNIT_CD ,
                                         X_PUR_START_DT => v_pur_rec.PUR_START_DT ,
                                         X_EXPIRY_DT => l_dcd_date ,
                                         X_MODE  =>  'R');

        END LOOP;

        FOR fund_exclusion_rec IN fund_exclusion_cur LOOP

                   SELECT  DECODE(GREATEST(fund_exclusion_rec.pfe_start_dt, p_expiry_dt),fund_exclusion_rec.pfe_start_dt, fund_exclusion_rec.pfe_start_dt,p_expiry_dt)
                              INTO   l_dcd_date
                              FROM DUAL;


                     IGS_PE_FUND_EXCL_PKG.UPDATE_ROW(
                                         X_ROWID            => fund_exclusion_rec.ROWID ,
                                         X_FUND_EXCL_ID     => fund_exclusion_rec.FUND_EXCL_ID,
                                         X_PERSON_ID        => fund_exclusion_rec.PERSON_ID ,
                                         X_ENCUMBRANCE_TYPE => fund_exclusion_rec.ENCUMBRANCE_TYPE ,
                                         X_PEN_START_DT     => fund_exclusion_rec.PEN_START_DT ,
                                         X_S_ENCMB_EFFECT_TYPE => fund_exclusion_rec.S_ENCMB_EFFECT_TYPE ,
                                         X_PEE_START_DT     => fund_exclusion_rec.PEE_START_DT ,
                                         X_PEE_SEQUENCE_NUMBER => fund_exclusion_rec.PEE_SEQUENCE_NUMBER ,
                                         X_FUND_CODE        => fund_exclusion_rec.FUND_CODE ,
                                         X_PFE_START_DT     => fund_exclusion_rec.PFE_START_DT ,
                                         X_EXPIRY_DT    => l_dcd_date ,
                                         X_MODE  =>  'R');

        END LOOP;
        -- RETURN TRUE;
        RETURN;
  EXCEPTION
        WHEN e_resource_busy THEN
                IF (c_person_crs_grp_exclusion%ISOPEN) THEN
                        CLOSE c_person_crs_grp_exclusion;
                END IF;
                IF (c_person_course_exclusion%ISOPEN) THEN
                        CLOSE c_person_course_exclusion;
                END IF;
                IF (c_person_unit_exclusion%ISOPEN) THEN
                        CLOSE c_person_unit_exclusion;
                END IF;
                IF (c_person_unit_requirement%ISOPEN) THEN
                        CLOSE c_person_unit_requirement;
                END IF;
                IF (fund_exclusion_cur%ISOPEN) THEN
                        CLOSE fund_exclusion_cur;
                END IF;
                p_message_name := 'IGS_EN_UNABLE_EXP_PRSNENCUMB';
                -- RETURN FALSE;
                RETURN;
        WHEN OTHERS THEN
                RAISE;
  END;
END enrp_set_pee_expry;

Procedure Enrp_Set_Pen_Expry(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_sequence_number IN NUMBER ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
 AS
/*
  ||  Created By : pkpatel
  ||  Created On : 27-SEP-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ssawhney        17-feb-2003     Bug : 2758856  : Added the parameter x_external_reference in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW
  ||  pkpatel         3-OCT-2002      Bug No: 2600842
  ||                                  Added the parameter x_auth_resp_id in the call to IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW
  ||  (reverse chronological order - newest change first)
*/
BEGIN   -- enrp_set_pen_expry
        -- Set the expiry date for parent IGS_PE_PERS_ENCUMB record of
        -- the nominated pee when expiry_dt of the effect is set
        -- and no other active effects remain.
  DECLARE
        e_resource_busy         EXCEPTION;
        PRAGMA                  EXCEPTION_INIT(e_resource_busy, -54);
        v_check         VARCHAR2(1);
        v_max_expiry_dt IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        v_expiry_dt     IGS_PE_PERSENC_EFFCT.expiry_dt%TYPE;
        CURSOR c_person_encumbrance_effect IS
                SELECT  'x'
                FROM    IGS_PE_PERSENC_EFFCT
                WHERE   person_id               = p_person_id           AND
                        encumbrance_type        = p_encumbrance_type    AND
                        pen_start_dt            = p_pen_start_dt        AND
                        sequence_number         <> p_sequence_number    AND
                        expiry_dt               IS NULL;
        CURSOR c_person_encumbrance IS
                SELECT  rowid, IGS_PE_PERS_ENCUMB.*
                FROM    IGS_PE_PERS_ENCUMB
                WHERE   person_id = p_person_id AND
                        encumbrance_type = p_encumbrance_type   AND
                        start_dt = p_pen_start_dt
                FOR UPDATE OF expiry_dt NOWAIT;
        v_pe_rec        c_person_encumbrance%ROWTYPE;
        CURSOR c_expiry_dt IS
                SELECT  MAX(pee.expiry_dt)
                FROM    IGS_PE_PERSENC_EFFCT pee
                WHERE   pee.person_id = p_person_id                     AND
                        pee.encumbrance_type = p_encumbrance_type       AND
                        pee.pen_start_dt = p_pen_start_dt               AND
                        pee.sequence_number <> p_sequence_number;
  BEGIN
        -- Set the default message number
        p_message_name := null;
        -- Validate the input parameters
        IF (    p_person_id             IS NULL OR
                p_encumbrance_type      IS NULL OR
                p_pen_start_dt          IS NULL OR
                p_sequence_number       IS NULL OR
                p_expiry_dt             IS NULL) THEN
                -- RETURN TRUE;
                RETURN;
        END IF;
        -- Check for any open IGS_PE_PERSENC_EFFCT
        OPEN c_person_encumbrance_effect;
        FETCH c_person_encumbrance_effect INTO v_check;
        IF (c_person_encumbrance_effect%NOTFOUND) THEN
                -- get the latest expiry dt of any
                -- IGS_PE_PERSENC_EFFCT record
                OPEN c_expiry_dt;
                FETCH c_expiry_dt INTO v_max_expiry_dt;
                -- set the value of expiry_dt to be used
                -- in the update below
                IF (c_expiry_dt%NOTFOUND) THEN
                        CLOSE c_expiry_dt;
                        v_expiry_dt := p_expiry_dt;
                ELSIF (p_expiry_dt < v_max_expiry_dt) THEN
                        CLOSE c_expiry_dt;
                        v_expiry_dt := v_max_expiry_dt;
                ELSE
                        CLOSE c_expiry_dt;
                        v_expiry_dt := p_expiry_dt;
                END IF;
                -- parent can be expired
                OPEN c_person_encumbrance;
                FETCH c_person_encumbrance INTO v_pe_rec;
                         IGS_PE_PERS_ENCUMB_PKG.UPDATE_ROW(
                                              X_ROWID => v_pe_rec.ROWID   ,
                                              X_PERSON_ID => v_pe_rec.PERSON_ID ,
                                              X_ENCUMBRANCE_TYPE => v_pe_rec.ENCUMBRANCE_TYPE   ,
                                              X_START_DT => v_pe_rec.START_DT   ,
                                              X_EXPIRY_DT => v_EXPIRY_DT   ,
                                              X_AUTHORISING_PERSON_ID => v_pe_rec.AUTHORISING_PERSON_ID ,
                                              X_COMMENTS => v_pe_rec.COMMENTS ,
                                              X_SPO_COURSE_CD => v_pe_rec.SPO_COURSE_CD,
                                              X_SPO_SEQUENCE_NUMBER => v_pe_rec.SPO_SEQUENCE_NUMBER,
                                              X_AUTH_RESP_ID        => v_pe_rec.auth_resp_id,
                                              X_EXTERNAL_REFERENCE  => v_pe_rec.external_reference,
                                              X_MODE  =>  'R' );

                CLOSE c_person_encumbrance;
        END IF;
        CLOSE c_person_encumbrance_effect;
        -- RETURN TRUE;
        RETURN;
  EXCEPTION
        WHEN e_resource_busy THEN
                IF (c_person_encumbrance_effect%ISOPEN) THEN
                        CLOSE c_person_encumbrance_effect;
                END IF;
                p_message_name := 'IGS_EN_UNABLE_EXP_PRSN_ENCUMB';
                -- RETURN FALSE;
                RETURN;
        WHEN OTHERS THEN
                RAISE;
  END;
END enrp_set_pen_expry;
Function Enrp_Upd_Acai_Accept(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_admission_appl_number IN NUMBER ,
  p_adm_nominated_course_cd IN VARCHAR2 ,
  p_adm_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean  AS

BEGIN   -- enrp_upd_acai_accept
        -- Accept the admissions offer for a course attempt on confirmation of the
        -- course.
  DECLARE
        e_resource_busy         EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
        cst_pending             CONSTANT VARCHAR2(10) := 'PENDING';
        cst_deferral            CONSTANT VARCHAR2(10) := 'DEFERRAL';
        cst_accepted            CONSTANT VARCHAR2(10) := 'ACCEPTED';
        ---IGS_AD_PS_APPL_INST_APLINST_V view replaced with  IGS_AD_PS_APPL_INST in the  c_acaiv and  c_acaiv_1 cursor
        --due to performance issues w.r.t. 2376233 by kkillams
        CURSOR c_acaiv IS
                SELECT  acaiv.person_id,
                        acaiv.admission_appl_number,
                        acaiv.nominated_course_cd,
                        acaiv.sequence_number,
                        acaiv.adm_offer_resp_status
                FROM    IGS_AD_PS_APPL_INST acaiv
                WHERE   acaiv.person_id                 = p_person_id AND
                        acaiv.admission_appl_number     = p_adm_admission_appl_number AND
                        acaiv.nominated_course_cd       = p_adm_nominated_course_cd AND
                        acaiv.sequence_number           = p_adm_sequence_number AND
                        IGS_EN_GEN_002.enrp_get_acai_offer(
                                        acaiv.adm_outcome_status,
                                        acaiv.adm_offer_resp_status) = 'Y' AND
                        IGS_EN_GEN_014.enrs_get_acai_cndtnl(
                                        acaiv.adm_cndtnl_offer_status,
                                        acaiv.cndtnl_offer_must_be_stsfd_ind) = 'Y'
                ORDER BY
                        acaiv.offer_dt DESC;
        CURSOR c_acaiv_1 IS
                SELECT  acaiv.person_id,
                        acaiv.admission_appl_number,
                        acaiv.nominated_course_cd,
                        acaiv.sequence_number,
                        acaiv.adm_offer_resp_status
                FROM    IGS_AD_PS_APPL_INST acaiv
                WHERE   acaiv.person_id = p_person_id AND
                        acaiv.course_cd = p_course_cd AND
                        IGS_EN_GEN_002.enrp_get_acai_offer(
                                        acaiv.adm_outcome_status,
                                        acaiv.adm_offer_resp_status) = 'Y' AND
                        IGS_EN_GEN_014.enrs_get_acai_cndtnl(
                                        acaiv.adm_cndtnl_offer_status,
                                        acaiv.cndtnl_offer_must_be_stsfd_ind) = 'Y'
                ORDER BY
                        acaiv.offer_dt DESC;
        CURSOR c_acai_upd (
                cp_person_id                    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_admission_appl_number
                                                IGS_EN_STDNT_PS_ATT.adm_admission_appl_number%TYPE,
                cp_nominated_course_cd          IGS_EN_STDNT_PS_ATT.adm_nominated_course_cd%TYPE,
                cp_sequence_number              IGS_EN_STDNT_PS_ATT.adm_sequence_number%TYPE) IS
                SELECT  rowid,acai.*
                FROM    IGS_AD_PS_APPL_INST acai
                WHERE   acai.person_id                  = cp_person_id AND
                        acai.admission_appl_number      = cp_admission_appl_number AND
                        acai.nominated_course_cd        = cp_nominated_course_cd AND
                        acai.sequence_number            = cp_sequence_number
                FOR UPDATE OF   acai.adm_offer_resp_status,
                                acai.actual_response_dt NOWAIT;
        v_acaiv_rec             c_acaiv%ROWTYPE;
        v_acai_exists           c_acai_upd%ROWTYPE;
        v_accepted_status       VARCHAR2(10);
  BEGIN
        -- Set the default message number
        p_message_name := null;
        -- If the admissions details have been passed then query the application.
        -- If not, attempt to query the offer based on the course attempt details.
        IF p_adm_admission_appl_number IS NOT NULL AND
                        p_adm_nominated_course_cd IS NOT NULL AND
                        p_adm_sequence_number IS NOT NULL THEN
                OPEN c_acaiv;
                FETCH c_acaiv INTO v_acaiv_rec;
                IF c_acaiv%NOTFOUND THEN
                        CLOSE c_acaiv;
                        RETURN TRUE;
                END IF;
                CLOSE c_acaiv;
        ELSE
                OPEN c_acaiv_1;
                FETCH c_acaiv_1 INTO v_acaiv_rec;
                IF c_acaiv_1%NOTFOUND THEN
                        CLOSE c_acaiv_1;
                        RETURN TRUE;
                END IF;

                CLOSE c_acaiv_1;
        END IF;
        -- If response isnt pending or deferral then it cannot be accepted.
        IF IGS_AD_GEN_008.admp_get_saors(
                        v_acaiv_rec.adm_offer_resp_status) NOT IN (
                                                                cst_pending,
                                                                cst_deferral) THEN

                RETURN TRUE;
        END IF;

        -- Select IGS_AD_PS_APPL_INST record for update
        BEGIN
                OPEN c_acai_upd(
                        v_acaiv_rec.person_id,
                        v_acaiv_rec.admission_appl_number,
                        v_acaiv_rec.nominated_course_cd,
                        v_acaiv_rec.sequence_number);
                FETCH c_acai_upd INTO v_acai_exists;
                IF c_acai_upd%FOUND THEN
                        -- Update application, setting it to accepted.
                        v_accepted_status := IGS_AD_GEN_009.admp_get_sys_aors(
                                                                cst_accepted);

                        IF v_accepted_status IS NOT NULL THEN
                                IGS_AD_PS_APPL_INST_PKG.UPDATE_ROW(
                                              X_ROWID  => v_acai_exists.ROWID ,
                                              X_PERSON_ID  => v_acai_exists.PERSON_ID ,
                                              X_ADMISSION_APPL_NUMBER  => v_acai_exists.ADMISSION_APPL_NUMBER ,
                                              X_NOMINATED_COURSE_CD  => v_acai_exists.NOMINATED_COURSE_CD ,
                                              X_SEQUENCE_NUMBER  => v_acai_exists.SEQUENCE_NUMBER ,
                                              X_ADM_CAL_TYPE  => v_acai_exists.ADM_CAL_TYPE ,
                                              X_ADM_CI_SEQUENCE_NUMBER  => v_acai_exists.ADM_CI_SEQUENCE_NUMBER ,
                                              X_COURSE_CD  => v_acai_exists.COURSE_CD ,
                                              X_CRV_VERSION_NUMBER  => v_acai_exists.CRV_VERSION_NUMBER ,
                                              X_LOCATION_CD  => v_acai_exists.LOCATION_CD ,
                                              X_ATTENDANCE_MODE  => v_acai_exists.ATTENDANCE_MODE ,
                                              X_ATTENDANCE_TYPE  => v_acai_exists.ATTENDANCE_TYPE ,
                                              X_UNIT_SET_CD  => v_acai_exists.UNIT_SET_CD ,
                                              X_US_VERSION_NUMBER  => v_acai_exists.US_VERSION_NUMBER ,
                                              X_PREFERENCE_NUMBER  => v_acai_exists.PREFERENCE_NUMBER ,
                                              X_ADM_DOC_STATUS  => v_acai_exists.ADM_DOC_STATUS ,
                                              X_ADM_ENTRY_QUAL_STATUS  => v_acai_exists.ADM_ENTRY_QUAL_STATUS ,
                                              X_LATE_ADM_FEE_STATUS  => v_acai_exists.LATE_ADM_FEE_STATUS ,
                                              X_ADM_OUTCOME_STATUS  => v_acai_exists.ADM_OUTCOME_STATUS ,
                                              X_ADM_OTCM_STAT_AUTH_PER_ID  => v_acai_exists.ADM_OTCM_STATUS_AUTH_PERSON_ID ,
                                              X_ADM_OUTCOME_STATUS_AUTH_DT  => v_acai_exists.ADM_OUTCOME_STATUS_AUTH_DT ,
                                              X_ADM_OUTCOME_STATUS_REASON  => v_acai_exists.ADM_OUTCOME_STATUS_REASON ,
                                              X_OFFER_DT  => v_acai_exists.OFFER_DT ,
                                              X_OFFER_RESPONSE_DT  => v_acai_exists.OFFER_RESPONSE_DT ,
                                              X_PRPSD_COMMENCEMENT_DT  => v_acai_exists.PRPSD_COMMENCEMENT_DT ,
                                              X_ADM_CNDTNL_OFFER_STATUS  => v_acai_exists.ADM_CNDTNL_OFFER_STATUS ,
                                              X_CNDTNL_OFFER_SATISFIED_DT  => v_acai_exists.CNDTNL_OFFER_SATISFIED_DT ,
                                              X_CNDNL_OFR_MUST_BE_STSFD_IND  => v_acai_exists.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                              X_ADM_OFFER_RESP_STATUS  => v_accepted_status ,
                                              X_ACTUAL_RESPONSE_DT  => SYSDATE ,
                                              X_ADM_OFFER_DFRMNT_STATUS  => v_acai_exists.ADM_OFFER_DFRMNT_STATUS ,
                                              X_DEFERRED_ADM_CAL_TYPE  => v_acai_exists.DEFERRED_ADM_CAL_TYPE ,
                                              X_DEFERRED_ADM_CI_SEQUENCE_NUM  => v_acai_exists.DEFERRED_ADM_CI_SEQUENCE_NUM ,
                                              X_DEFERRED_TRACKING_ID  => v_acai_exists.DEFERRED_TRACKING_ID ,
                                              X_ASS_RANK  => v_acai_exists.ASS_RANK ,
                                              X_SECONDARY_ASS_RANK  => v_acai_exists.SECONDARY_ASS_RANK ,
                                              X_INTR_ACCEPT_ADVICE_NUM  => v_acai_exists.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
                                              X_ASS_TRACKING_ID  => v_acai_exists.ASS_TRACKING_ID ,
                                              X_FEE_CAT  => v_acai_exists.FEE_CAT ,
                                              X_HECS_PAYMENT_OPTION  => v_acai_exists.HECS_PAYMENT_OPTION ,
                                              X_EXPECTED_COMPLETION_YR  => v_acai_exists.EXPECTED_COMPLETION_YR ,
                                              X_EXPECTED_COMPLETION_PERD  => v_acai_exists.EXPECTED_COMPLETION_PERD ,
                                              X_CORRESPONDENCE_CAT  => v_acai_exists.CORRESPONDENCE_CAT ,
                                              X_ENROLMENT_CAT  => v_acai_exists.ENROLMENT_CAT ,
                                              X_FUNDING_SOURCE  => v_acai_exists.FUNDING_SOURCE ,
                                              X_APPLICANT_ACPTNCE_CNDTN  => v_acai_exists.APPLICANT_ACPTNCE_CNDTN ,
                                              X_CNDTNL_OFFER_CNDTN  => v_acai_exists.CNDTNL_OFFER_CNDTN ,
                                              X_ATTRIBUTE_CATEGORY => v_acai_exists.attribute_Category,
                                              X_ATTRIBUTE1              => v_acai_exists.ATTRIBUTE1     ,
                                              X_ATTRIBUTE2              => v_acai_exists.ATTRIBUTE2     ,
                                              X_ATTRIBUTE3              => v_acai_exists.ATTRIBUTE3     ,
                                              X_ATTRIBUTE4              => v_acai_exists.ATTRIBUTE4     ,
                                              X_ATTRIBUTE5              => v_acai_exists.ATTRIBUTE5     ,
                                              X_ATTRIBUTE6              => v_acai_exists.ATTRIBUTE6     ,
                                              X_ATTRIBUTE7              => v_acai_exists.ATTRIBUTE7     ,
                                              X_ATTRIBUTE8              => v_acai_exists.ATTRIBUTE8     ,
                                              X_ATTRIBUTE9              => v_acai_exists.ATTRIBUTE9     ,
                                              X_ATTRIBUTE10              => v_acai_exists.ATTRIBUTE10     ,
                                              X_ATTRIBUTE11              => v_acai_exists.ATTRIBUTE11     ,
                                              X_ATTRIBUTE12              => v_acai_exists.ATTRIBUTE12     ,
                                              X_ATTRIBUTE13              => v_acai_exists.ATTRIBUTE13     ,
                                              X_ATTRIBUTE14              => v_acai_exists.ATTRIBUTE14     ,
                                              X_ATTRIBUTE15              => v_acai_exists.ATTRIBUTE15     ,
                                              X_ATTRIBUTE16              => v_acai_exists.ATTRIBUTE16     ,
                                              X_ATTRIBUTE17              => v_acai_exists.ATTRIBUTE17     ,
                                              X_ATTRIBUTE18              => v_acai_exists.ATTRIBUTE18     ,
                                              X_ATTRIBUTE19              => v_acai_exists.ATTRIBUTE19     ,
                                              X_ATTRIBUTE20              => v_acai_exists.ATTRIBUTE20     ,
                                              X_ACADEMIC_INDEX           => v_acai_exists.ACADEMIC_INDEX,
                                              X_APP_FILE_LOCATION        => v_acai_exists.APP_FILE_LOCATION,
                                              X_APPLY_FOR_FINAID         => v_acai_exists.APPLY_FOR_FINAID,
                                              X_ATTENT_OTHER_INST_CD     => v_acai_exists.ATTENT_OTHER_INST_CD,
                                              X_DECISION_DATE            => v_acai_exists.DECISION_DATE,
                                              X_DECISION_MAKE_ID         => v_acai_exists.DECISION_MAKE_ID,
                                              X_DECISION_NOTES           => v_acai_exists.DECISION_NOTES,
                                              X_DECISION_REASON_ID       => v_acai_exists.DECISION_REASON_ID,
                                              X_DEFICIENCY_IN_PREP       => v_acai_exists.DEFICIENCY_IN_PREP,
                                              X_EDU_GOAL_PRIOR_ENROLL_ID => v_acai_exists.EDU_GOAL_PRIOR_ENROLL_ID,
                                              X_FINAID_APPLY_DATE        => v_acai_exists.FINAID_APPLY_DATE,
                                              X_PENDING_REASON_ID        => v_acai_exists.PENDING_REASON_ID,
                                              X_PREDICTED_GPA            => v_acai_exists.PREDICTED_GPA,
                                              X_SPL_CONSIDER_COMMENTS    => v_acai_exists.SPL_CONSIDER_COMMENTS,
                                              X_WAITLIST_RANK            => v_acai_exists.WAITLIST_RANK ,
                                              X_WAITLIST_STATUS          => v_acai_exists.WAITLIST_STATUS ,
                                              X_APP_SOURCE_ID            => v_acai_exists.APP_SOURCE_ID,
                                              X_MODE                     => 'R' ,
                                              X_SS_APPLICATION_ID         => v_acai_exists.SS_APPLICATION_ID,
                                             X_SS_PWD                     =>  v_acai_exists.SS_PWD,
                                             X_AUTHORIZED_DT              => v_acai_exists.AUTHORIZED_DT, -- BUG Enh No : 1891835 Added two columns
                                             X_AUTHORIZING_PERS_ID        => v_acai_exists.AUTHORIZING_PERS_ID, -- BUG Enh No : 1891835 Added two columns
                                             X_ENTRY_STATUS               => v_acai_exists.ENTRY_STATUS, -- BUG Enh No : 1905651  . Added three columns in teh table IGS_AD_PS_APPL_INST_ALL
                                             X_ENTRY_LEVEL                => v_acai_exists.ENTRY_LEVEL,-- BUG Enh No :1905651 Added three columns in teh table IGS_AD_PS_APPL_INST_ALL
                                             X_SCH_APL_TO_ID              => v_acai_exists.SCH_APL_TO_ID, -- BUG Enh No : 1905651 Added three columns in teh table IGS_AD_PS_APPL_INST_ALL
               X_FUT_ACAD_CAL_TYPE                          => v_acai_exists.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                                             X_FUT_ACAD_CI_SEQUENCE_NUMBER                => v_acai_exists.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                                             X_FUT_ADM_CAL_TYPE                           => v_acai_exists.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                                             X_FUT_ADM_CI_SEQUENCE_NUMBER                 => v_acai_exists.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                                             X_PREV_TERM_ADM_APPL_NUMBER                 => v_acai_exists.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                                             X_PREV_TERM_SEQUENCE_NUMBER                 => v_acai_exists.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                                             X_FUT_TERM_ADM_APPL_NUMBER                   => v_acai_exists.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                                             X_FUT_TERM_SEQUENCE_NUMBER                   => v_acai_exists.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                                             X_DEF_ACAD_CAL_TYPE                                        => v_acai_exists.DEF_ACAD_CAL_TYPE, --Bug 2395510
                                             X_DEF_ACAD_CI_SEQUENCE_NUM                   => v_acai_exists.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                                             X_DEF_PREV_TERM_ADM_APPL_NUM           => v_acai_exists.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
                                             X_DEF_PREV_APPL_SEQUENCE_NUM              => v_acai_exists.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
                                             X_DEF_TERM_ADM_APPL_NUM                        => v_acai_exists.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
                                             X_DEF_APPL_SEQUENCE_NUM                           => v_acai_exists.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
                                             X_IDX_CALC_DATE              =>  v_acai_exists.IDX_CALC_DATE,
                                              X_ATTRIBUTE21             => v_acai_exists.ATTRIBUTE21,
                                              X_ATTRIBUTE22             => v_acai_exists.ATTRIBUTE22,
                                              X_ATTRIBUTE23             => v_acai_exists.ATTRIBUTE23,
                                              X_ATTRIBUTE24             => v_acai_exists.ATTRIBUTE24,
                                              X_ATTRIBUTE25             => v_acai_exists.ATTRIBUTE25,
                                              X_ATTRIBUTE26             => v_acai_exists.ATTRIBUTE26,
                                              X_ATTRIBUTE27             => v_acai_exists.ATTRIBUTE27,
                                              X_ATTRIBUTE28             => v_acai_exists.ATTRIBUTE28,
                                              X_ATTRIBUTE29             => v_acai_exists.ATTRIBUTE29,
                                              X_ATTRIBUTE30              => v_acai_exists.ATTRIBUTE30,
                                              X_ATTRIBUTE31              => v_acai_exists.ATTRIBUTE31,
                                              X_ATTRIBUTE32              => v_acai_exists.ATTRIBUTE32,
                                              X_ATTRIBUTE33              => v_acai_exists.ATTRIBUTE33,
                                              X_ATTRIBUTE34              => v_acai_exists.ATTRIBUTE34,
                                              X_ATTRIBUTE35              => v_acai_exists.ATTRIBUTE35,
                                              X_ATTRIBUTE36              => v_acai_exists.ATTRIBUTE36,
                                              X_ATTRIBUTE37              => v_acai_exists.ATTRIBUTE37,
                                              X_ATTRIBUTE38              => v_acai_exists.ATTRIBUTE38,
                                              X_ATTRIBUTE39              => v_acai_exists.ATTRIBUTE39,
                                              X_ATTRIBUTE40              => v_acai_exists.ATTRIBUTE40,
					      X_APPL_INST_STATUS	 => v_acai_exists.appl_inst_status,
					      x_ais_reason		 => v_acai_exists.ais_reason,
					      x_decline_ofr_reason	 => v_acai_exists.decline_ofr_reason
                                             );
                        END IF;
                END IF;
                CLOSE c_acai_upd;
        EXCEPTION
                WHEN e_resource_busy THEN
                        -- lock could not be obtained.
                        p_message_name := 'IGS_EN_NOTACPT_ADMOFFER';
                        RETURN FALSE;
                WHEN OTHERS THEN
                        IF c_acai_upd%ISOPEN THEN
                                CLOSE c_acai_upd;
                        END IF;
                        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_011.enrp_upd_acai_accept1');
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
        END;
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_acaiv%ISOPEN THEN
                        CLOSE c_acaiv;
                END IF;
                IF c_acaiv_1%ISOPEN THEN
                        CLOSE c_acaiv_1;
                END IF;
                IF c_acai_upd%ISOPEN THEN
                        CLOSE c_acai_upd;
                END IF;
                RAISE;
  END;
END enrp_upd_acai_accept;

Procedure Enrp_Upd_Enr_Pp(
  p_username IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_enrolment_cat IN VARCHAR2 ,
  p_enr_method_type IN VARCHAR2 )
 AS
BEGIN
  DECLARE
        v_person_id             IGS_PE_PERSON.person_id%TYPE;
        v_dummy                 IGS_PE_PERS_PREFS.LAST_UPDATED_BY%TYPE;
        CURSOR  c_person(
                        cp_username IGS_PE_PERSON.oracle_username%TYPE) IS
                SELECT  person_id
                FROM    IGS_PE_PERSON
                WHERE   oracle_username = cp_username;
        CURSOR  c_person_prefs(
                        cp_person_id IGS_PE_PERSON.person_id%TYPE) IS
                SELECT  LAST_UPDATED_BY
                FROM    IGS_PE_PERS_PREFS_all
                WHERE   person_id = cp_person_id;
        v_other_detail  VARCHAR2(255);
  BEGIN
        -- this module updates the enrolment values for a IGS_PE_PERSON's preference
        -- table

      -- added after ORACLE_USERNAME issue...
      v_person_id := FND_GLOBAL.USER_ID;


        OPEN    c_person_prefs(
                        v_person_id);
        FETCH   c_person_prefs INTO v_dummy;

        IF (c_person_prefs%NOTFOUND) THEN
                CLOSE   c_person_prefs;
                -- Call table handler for inserting into person_prefs...
            DECLARE
                    l_rowid VARCHAR2(25);
                    l_org_id NUMBER := igs_ge_gen_003.get_org_id;
            BEGIN

                IGS_PE_PERS_PREFS_PKG.INSERT_ROW(
                        X_ROWID => l_rowid,
                        x_PERSON_ID => v_person_id,
                        x_enr_acad_cal_type=> p_cal_type,
                        x_enr_acad_sequence_number=> p_sequence_number,
                        x_enr_enrolment_cat=> p_enrolment_cat,
                        x_enr_enr_method_type=> p_enr_method_type,
                        X_ADM_ACAD_CAL_TYPE => NULL,
                        X_ADM_ACAD_CI_SEQUENCE_NUMBER => NULL,
                        X_ADM_ADM_CAL_TYPE => NULL,
                        X_ADM_ADM_CI_SEQUENCE_NUMBER => NULL,
                        X_ADM_ADMISSION_CAT => NULL,
                        X_ADM_S_ADMISSION_PROCESS_TYPE => NULL,
                        X_ENQ_ACAD_CAL_TYPE => NULL,
                        X_ENQ_ACAD_CI_SEQUENCE_NUMBER => NULL,
                        X_ENQ_ADM_CAL_TYPE => NULL,
                        X_ENQ_ADM_CI_SEQUENCE_NUMBER => NULL,
                        X_SERVER_PRINTER_DFLT => NULL,
                        X_ALLOW_STND_REQ_IND => 'N',
                        x_org_id => l_org_id
                        );
            END;

                COMMIT;
        ELSE
                CLOSE   c_person_prefs;
                DECLARE
                         CURSOR c_IGS_PE_PERS_PREFS IS
                                SELECT  rowid,
                                        ppp.*
                                FROM    IGS_PE_PERS_PREFS_all ppp
                                WHERE   person_id = v_person_id;
                BEGIN
                     FOR v_pe_prefs_rec IN  c_IGS_PE_PERS_PREFS LOOP
                        IGS_PE_PERS_PREFS_PKG.UPDATE_ROW(
                                              X_ROWID => v_pe_prefs_rec.ROWID ,
                                              X_PERSON_ID => v_pe_prefs_rec.PERSON_ID ,
                                              X_ENR_ACAD_CAL_TYPE => p_cal_type ,
                                              X_ENR_ACAD_SEQUENCE_NUMBER => p_sequence_number ,
                                              X_ENR_ENROLMENT_CAT => p_enrolment_cat ,
                                              X_ENR_ENR_METHOD_TYPE => p_enr_method_type,
                                              X_ADM_ACAD_CAL_TYPE => v_pe_prefs_rec.ADM_ACAD_CAL_TYPE ,
                                              X_ADM_ACAD_CI_SEQUENCE_NUMBER => v_pe_prefs_rec.ADM_ACAD_CI_SEQUENCE_NUMBER ,
                                              X_ADM_ADM_CAL_TYPE => v_pe_prefs_rec.ADM_ADM_CAL_TYPE ,
                                              X_ADM_ADM_CI_SEQUENCE_NUMBER => v_pe_prefs_rec.ADM_ADM_CI_SEQUENCE_NUMBER ,
                                              X_ADM_ADMISSION_CAT => v_pe_prefs_rec.ADM_ADMISSION_CAT ,
                                              X_ADM_S_ADMISSION_PROCESS_TYPE => v_pe_prefs_rec.ADM_S_ADMISSION_PROCESS_TYPE ,
                                              X_ENQ_ACAD_CAL_TYPE => v_pe_prefs_rec.ENQ_ACAD_CAL_TYPE ,
                                              X_ENQ_ACAD_CI_SEQUENCE_NUMBER => v_pe_prefs_rec.ENQ_ACAD_CI_SEQUENCE_NUMBER ,
                                              X_ENQ_ADM_CAL_TYPE => v_pe_prefs_rec.ENQ_ADM_CAL_TYPE ,
                                              X_ENQ_ADM_CI_SEQUENCE_NUMBER => v_pe_prefs_rec.ENQ_ADM_CI_SEQUENCE_NUMBER ,
                                              X_SERVER_PRINTER_DFLT => v_pe_prefs_rec.SERVER_PRINTER_DFLT ,
                                              X_ALLOW_STND_REQ_IND => v_pe_prefs_rec.ALLOW_STND_REQ_IND ,
                                              X_MODE  => 'R'
                                              );
                     END LOOP;
               END;
                COMMIT;
        END IF;
        RETURN;
  END;
END enrp_upd_enr_pp;



END IGS_EN_GEN_011;

/
