--------------------------------------------------------
--  DDL for Package Body IGF_AW_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_GEN_002" AS
  /* $Header: IGFAW10B.pls 120.3 2006/08/04 07:39:04 veramach ship $ */

--------------------------------------------------------------------------------------
--veramach    Oct 2004        FA 152/FA 137 - Changes to wrappers to include Award Period setup
-- veramach   24-Aug-2004     FA 145 Obsoleted pell_efc_range
-- veramach   08-Apr-2004     bug 3547237
--                            Obsoleted get_fed_efc. Replaced references with igf_aw_packng_subfns.get_fed_efc
-- sjalasut   10 Dec, 2003    FA132 Changes. commented the code for get_sectionii_stdnt
--                            get_sectionvi_fund, get_sectionvi_stdnt. DID NOT remove
--                            from the spec as the IGF_AW_FISAP_SECTION_II_V and
--                            IGF_AW_FISAP_SECTION_VI_V refer them. only commented the
--                            package body and all these functions return 0
-- rasahoo      25-Nov-2003   FA 128 ISIR update. Changed the ereference to paid_efc in
--                            all cursors and added the decode logic based on award_fmly_contribution_type
-- veramach     07-OCT-2003   FA 124
--                           Chaged cursor resource_cur in get_resource_need
-- cdcruz      01-Oct-2003   FA121 - Verification Worksheet changes
--                           new parameter added to compare_isirs procedure
-- rasahoo     02-Sep-2003   FA-114(Obsoletion of FA base record History)
--                           Removed the join with igf_ap_fa_base_h from appropriate cursors
-- cdcruz      17-Mar-2003   Bug 2807235
--                           Proc comp_fields changed insert_row call if new correction
--                           else update_row so that same field can be corrected more
--                           than once
--------------------------------------------------------------------------------------
-- sjadhav     03-Mar-2003   Bug 2781382
--                           removed nvl in get_fed_efc
--------------------------------------------------------------------------------------
FUNCTION get_sectionii_stdnt (p_depend_stat        IN igf_lookups_view.lookup_code%TYPE,
                              p_class_standing     IN igf_lookups_view.lookup_code%TYPE,
                              p_ci_cal_type        IN igs_ca_inst.cal_type%TYPE,
                              p_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                              p_minvalue           IN igf_aw_fi_inc_level.minvalue%TYPE,
                              p_maxvalue           IN igf_aw_fi_inc_level.maxvalue%TYPE,
                              p_efc                IN VARCHAR2)
RETURN NUMBER
IS

 ------------------------------------------------------------------------------------
    --Created by  : ssawhney ( Oracle IDC)
    --Date created: 2001/10/23
    --Purpose:  The function would be used to calculate the Student Count for a category
    --and Income Range. This function is used in the view IGF_AW_FISAP SECTIONII_V
    --and would retrieve the student count for a specific category which is An Award Year,
    -- Class Standing, Dependency Status and FISAP Section, combination.
    --Class Standing is matched with either "bach deg by date" or "deg beyond bach"
    --
    --Known limitations/enhancements and/or remarks:
    --Change History:
    --Who         When            What
    --cdcruz      05-feb-03       Bug# 2758804 FACR105
    --                            all cursors ref changed to pick active isisr
    --CDCRUZ      06-NOV-02       New procedure get_fed_efc
    --                            added as part of Bug 2613546 FA105/FA108
    --CDCRUZ      09-Dec-02       procedure get_fed_efc
    --                            modified so that it picks efc from ISIR part of Bug 2676394 FACR107
    --CDCRUZ      16-Dec-02       Bug# 2691811
    --                            Simulated awards should not be considered for FA Base Summation
    --                            Cursor in get_resource_need proc modified

-------------------------------------------------------------------------------------
-- return -1 if incorrect values passed for CLASS STANDING
-- return -2 if incorrect values passed for AUTO_ZERO_EFC
-- return -3 if any Unhandled Exception is Raised.

--This cursor is used for class standing 1 or 2 and AutoZERO EFC is false.
--It would retrieve the count of students for the Undergraduate with degree
--and Undergraduate without degree.

  /*CURSOR c_count_ungrad_std (
                            cp_depend_stat        igf_lookups_view.lookup_code%TYPE,
                            cp_class_standing     igf_lookups_view.lookup_code%TYPE,
                            cp_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                            cp_ci_sequence_number igs_ca_inst.sequence_number%TYPE)
  IS
  SELECT COUNT (isir.base_id)
    FROM igf_ap_isir_matched isir,
         igf_ap_fa_base_rec  fa
   WHERE isir.dependency_status=cp_depend_stat
     AND NVL(isir.auto_zero_efc,'N') <> 'Y'
     AND isir.active_isir ='Y'
     AND isir.citizenship_status='1'
     AND fa.ci_cal_type =cp_ci_cal_type
     AND fa.ci_sequence_number =cp_ci_sequence_number
     AND fa.base_id=isir.base_id
     AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
     AND EXISTS ( SELECT base.base_id
                    FROM igf_ap_fa_base_rec_all base,igs_ps_ver_all pv,igs_en_stdnt_ps_att att
                   WHERE base.base_id = isir.base_id
                     AND base.person_id = att.person_id
                     AND att.key_program = 'Y'
                     AND att.course_cd = pv.course_cd
                     AND att.version_number = pv.version_number
                     AND (pv.state_financial_aid='Y' OR pv.institutional_financial_aid='Y' OR pv.federal_financial_aid ='Y' )
                     AND igf_ap_gen_001.get_enrl_program_type(isir.base_id) IN ( SELECT cl.program_type
                                                                                  FROM igf_aw_career_map cl
                                                                                 WHERE cl.class_standing = cp_class_standing ));


--This cursor is for class standing is 3 and AutoZERO EFC is false.
--It would retrieve the data for the students whose career level is Graduate.

  CURSOR c_count_grad_std ( cp_depend_stat           igf_lookups_view.lookup_code%TYPE,
                            cp_class_standing        igf_lookups_view.lookup_code%TYPE,
                            cp_ci_cal_type           igs_ca_inst.cal_type%TYPE,
                            cp_ci_sequence_number    igs_ca_inst.sequence_number%TYPE,
                            cp_minvalue              igf_aw_fi_inc_level.minvalue%TYPE,
                            cp_maxvalue              igf_aw_fi_inc_level.maxvalue%TYPE,
                            cp_efc                   VARCHAR2 )
  IS
  SELECT COUNT (isir.base_id)
   FROM   igf_ap_isir_matched isir,
          igf_ap_fa_base_rec  fa
  WHERE   isir.dependency_status=cp_depend_stat
    AND   NVL(isir.auto_zero_efc,'N') <> 'Y'
    AND   isir.active_isir ='Y'
    AND   isir.citizenship_status='1'
    AND   fa.ci_cal_type =cp_ci_cal_type
    AND   fa.ci_sequence_number =cp_ci_sequence_number
    AND   fa.base_id=isir.base_id
    AND   DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
    AND   EXISTS
               (SELECT  base.base_id
                  FROM  igf_ap_fa_base_rec_all base,igs_ps_ver_all pv,igs_en_stdnt_ps_att att
                 WHERE  base.base_id = isir.base_id
                   AND  base.person_id = att.person_id
                   AND  att.key_program = 'Y'
                   AND att.course_cd = pv.course_cd
                   AND att.version_number = pv.version_number
                   AND (pv.state_financial_aid='Y' OR pv.institutional_financial_aid='Y' OR pv.federal_financial_aid ='Y' )
                   AND igf_ap_gen_001.get_enrl_program_type(isir.base_id) IN
                                                                           (SELECT cl.program_type
                                                                              FROM igf_aw_career_map cl
                                                                             WHERE cl.class_standing =cp_class_standing ));

--This cursor is used for class standing 1 or 2 and AutoZERO EFC is TRUE(Y).
--It would retrieve the count of students for the Undergraduate with degree
--and Undergraduate without degree

  CURSOR c_count_ungrad_std_efc (
                                cp_depend_stat           igf_lookups_view.lookup_code%TYPE,
                                cp_class_standing        igf_lookups_view.lookup_code%TYPE,
                                cp_ci_cal_type           igs_ca_inst.cal_type%TYPE,
                                cp_ci_sequence_number    igs_ca_inst.sequence_number%TYPE,
                                cp_minvalue              igf_aw_fi_inc_level.minvalue%TYPE,
                                cp_maxvalue              igf_aw_fi_inc_level.maxvalue%TYPE,
                                cp_efc                   VARCHAR2)
  IS
  SELECT  COUNT (isir.base_id)
    FROM igf_ap_isir_matched isir,
          igf_ap_fa_base_rec  fa
  WHERE   isir.dependency_status=cp_depend_stat
    AND   isir.auto_zero_efc = 'Y'
    AND   isir.active_isir ='Y'
    AND   isir.citizenship_status='1'
    AND   fa.ci_cal_type =cp_ci_cal_type
    AND   fa.ci_sequence_number =cp_ci_sequence_number
    AND   fa.base_id=isir.base_id
    AND   DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
    AND   EXISTS
                 (
                  SELECT base.base_id
                    FROM igf_ap_fa_base_rec_all base,
                         igs_ps_ver_all pv,
                         igs_en_stdnt_ps_att att
                   WHERE base.base_id = isir.base_id
                     AND  base.person_id = att.person_id
                     AND  att.key_program = 'Y'
                     AND att.course_cd = pv.course_cd
                     AND att.version_number = pv.version_number
                     AND (pv.state_financial_aid='Y' OR pv.institutional_financial_aid='Y' OR pv.federal_financial_aid ='Y' )
                     AND igf_ap_gen_001.get_enrl_program_type(isir.base_id) IN
                                                                             (SELECT cl.program_type
                                                                                FROM igf_aw_career_map cl
                                                                               WHERE cl.class_standing =cp_class_standing ));
--This cursor is for class standing is 3 and AutoZERO EFC is true (Y).
--It would retrieve the data for the students whose career level is Graduate.

  CURSOR c_count_grad_std_efc ( cp_depend_stat        igf_lookups_view.lookup_code%TYPE,
                                cp_class_standing     igf_lookups_view.lookup_code%TYPE,
                                cp_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                                cp_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                                cp_minvalue           igf_aw_fi_inc_level.minvalue%TYPE,
                                cp_maxvalue           igf_aw_fi_inc_level.maxvalue%TYPE,
                                cp_efc                VARCHAR2)
  IS
  SELECT COUNT (isir.base_id)
    FROM igf_ap_isir_matched isir,
         igf_ap_fa_base_rec  fa
   WHERE isir.dependency_status=cp_depend_stat
     AND isir.auto_zero_efc = 'Y'
     AND isir.active_isir ='Y'
     AND isir.citizenship_status='1'
     AND fa.ci_cal_type =cp_ci_cal_type
     AND fa.ci_sequence_number =cp_ci_sequence_number
     AND fa.base_id=isir.base_id
     AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
     AND   EXISTS
                (
                SELECT base.base_id
                  FROM igf_ap_fa_base_rec_all base,igs_ps_ver_all pv,igs_en_stdnt_ps_att att
                 WHERE base.base_id = isir.base_id
                   AND base.person_id = att.person_id
                   AND att.key_program = 'Y'
                   AND att.course_cd = pv.course_cd
                   AND att.version_number = pv.version_number
                   AND (pv.state_financial_aid='Y' OR pv.institutional_financial_aid='Y' OR pv.federal_financial_aid ='Y' )
                   AND igf_ap_gen_001.get_enrl_program_type(isir.base_id) IN
                                                                          (SELECT cl.program_type
                                                                             FROM igf_aw_career_map cl
                                                                            WHERE cl.class_standing =cp_class_standing ));

*/

l_std_cnt           igf_aw_fisap_ii_h.student_count%TYPE DEFAULT 0;
l_class_standing    igf_lookups_view.lookup_code%TYPE;
l_efc               VARCHAR2(10);

BEGIN
--  code commented as part of Fa132. function only returns 0 since this function is being used
-- in igf_aw_fisap_section_ii_v and igf_aw_fisap_section_vi_v
 /*
-- copy values of parameters into local variables.

  l_class_standing := p_class_standing;
  l_efc := p_efc;
  l_std_cnt := 0; -- initialise the count;

-- check if the minimum required parameters are passed or not
-- return -1 if incorrect values passed for CLASS STANDING
-- return -2 if incorrect values passed for AUTO_ZERO_EFC

  IF l_class_standing IS NULL OR
    l_class_standing NOT IN ('1','2','3') THEN
    l_std_cnt := -1;
    RETURN (l_std_cnt);
  END IF;

  IF l_efc IS NULL OR
    l_efc NOT IN ('TRUE','FALSE') THEN
    l_std_cnt := -2;
    RETURN (l_std_cnt);
  END IF;

-- open each cursor to get the count of students.
-- the opening of the cursor will depend on the passed p_class_standing and p_efc
-- parameters.

-- open the first cursor, the condition will be, CLASS_STANDING should be
-- 1 or 2 and EFC FALSE

  IF l_class_standing IN ('1','2') AND
     l_efc = 'FALSE' THEN
       OPEN c_count_ungrad_std(
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number );

  -- l_std_cnt:=0; -- re initalise the count
   FETCH c_count_ungrad_std INTO l_std_cnt;
         IF c_count_ungrad_std%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF c_count_ungrad_std%FOUND THEN
     RETURN (l_std_cnt);
         END IF;

       CLOSE c_count_ungrad_std;
-- open the second cursor, the condition will be, CLASS_STANDING should be 3
-- and EFC FALSE

  ELSIF
    l_class_standing ='3' AND
    l_efc = 'FALSE' THEN
      OPEN c_count_grad_std(
        p_depend_stat,
        p_class_standing ,
        p_ci_cal_type ,
        p_ci_sequence_number ,
        p_minvalue ,
        p_maxvaluE ,
        p_efc);

  FETCH c_count_grad_std INTO l_std_cnt;
        IF c_count_grad_std%NOTFOUND THEN
    l_std_cnt:=0;
    RETURN (l_std_cnt);
        ELSIF c_count_grad_std%FOUND THEN
    RETURN (l_std_cnt);
        END IF;
      CLOSE c_count_grad_std;
-- open the third cursor, the condition will be, CLASS_STANDING should be
-- 1 or 2 and EFC TRUE

  ELSIF
    l_class_standing IN ('1','2') AND
    l_efc = 'TRUE' THEN
      OPEN c_count_ungrad_std_efc(
        p_depend_stat,
        p_class_standing ,
        p_ci_cal_type ,
        p_ci_sequence_number ,
        p_minvalue ,
        p_maxvaluE ,
        p_efc);

  FETCH c_count_ungrad_std_efc INTO l_std_cnt;
        IF c_count_ungrad_std_efc%NOTFOUND THEN
    l_std_cnt:=0;
    RETURN (l_std_cnt);
        ELSIF  c_count_ungrad_std_efc%FOUND THEN
    RETURN (l_std_cnt);
        END IF;
      CLOSE c_count_ungrad_std_efc;
-- open the fourth cursor, the condition will be, CLASS_STANDING should be 3
-- and EFC TRUE

  ELSIF
    l_class_standing ='3' AND
    l_efc = 'TRUE' THEN
      OPEN c_count_grad_std_efc(
        p_depend_stat,
        p_class_standing ,
        p_ci_cal_type ,
        p_ci_sequence_number ,
        p_minvalue ,
        p_maxvaluE ,
        p_efc);

  FETCH c_count_grad_std_efc INTO l_std_cnt;
        IF c_count_grad_std_efc%NOTFOUND THEN
    l_std_cnt:=0;
    RETURN (l_std_cnt);
        ELSIF  c_count_grad_std_efc%FOUND THEN
    RETURN (l_std_cnt);
        END IF;
      CLOSE c_count_grad_std_efc;
  END IF;*/
  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    /*IF c_count_grad_std_efc%ISOPEN THEN
       CLOSE c_count_grad_std_efc;
    END IF;
    IF c_count_grad_std%ISOPEN THEN
       CLOSE c_count_grad_std;
    END IF;
    IF c_count_ungrad_std_efc%ISOPEN THEN
       CLOSE c_count_ungrad_std_efc;
    END IF;
    IF c_count_ungrad_std%ISOPEN THEN
       CLOSE c_count_ungrad_std;
    END IF;*/
    RETURN (-3); -- returning -3 means Unhandled exception raised

END get_sectionii_stdnt;


FUNCTION get_sectionvi_fund ( p_rec_type           IN igf_aw_fisap_vi_h.rec_type%TYPE,
                              p_fund_type          IN igf_aw_award_v.fed_fund_code%TYPE,
                              p_depend_stat        IN igf_lookups_view.lookup_code%TYPE,
                              p_class_standing     IN igf_lookups_view.lookup_code%TYPE,
                              p_ci_cal_type        IN igs_ca_inst.cal_type%TYPE,
                              p_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                              p_minvalue           IN igf_aw_fi_inc_level.minvalue%TYPE,
                              p_maxvalue           IN igf_aw_fi_inc_level.maxvalue%TYPE )
  RETURN NUMBER
  IS

 ------------------------------------------------------------------------------------
    --Created by  : ssawhney ( Oracle IDC)
    --Date created: 2001/10/23
    --Purpose:  The function would be used to calculate the Total Fund Amount for a category
    --and Income Range. This function is used in the view IGF_AW_FISAP SECTIONVI_V
    --and would retrieve the sum total for a specific category which is An Award Year,
    --Class Standing, Dependency Status and FISAP Section, combination.
    --Class Standing will be 4 for SectionVI records, so we will not check explicitly
    --
    --Known limitations/enhancements and/or remarks:
    --Change History:
    --Who         When            What
-------------------------------------------------------------------------------------

-- return -1 if incorrect values passed for CLASS STANDING
-- return -2 if incorrect values passed for AUTO_ZERO_EFC
-- return -3 if any Unhandled Exception is Raised.
/*
  CURSOR c_non_proff_fund_count (
                                  cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                                  cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                                  cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                                  cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                                  cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                  cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                  cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                                  cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
  SELECT NVL(SUM(awd.paid_amt),0)
    FROM igf_ap_isir_matched isir,
         igf_aw_award_v awd,
         igf_ap_fa_base_rec  fa
   WHERE awd.base_id =isir.base_id
     AND fa.base_id =isir.base_id
     AND isir.dependency_status =p_depend_stat
     AND awd.fed_fund_code =cp_fund_type
     AND awd.ci_cal_type =cp_ci_cal_type
     AND awd.ci_sequence_number =cp_ci_sequence_number
     AND NVL(isir.auto_zero_efc,'N') <> 'Y'
     AND isir.active_isir ='Y'
     AND isir.citizenship_status='1'
     AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
     AND awd.award_status IN ('ACCEPTED','OFFERED')
     AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) ='FT'
     AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                            (SELECT cl.program_type FROM igf_aw_career_map cl
                                                              WHERE cl.class_standing IN ('1','2') )
     AND isir.fti BETWEEN  cp_minvalue AND cp_maxvalue
     AND cp_rec_type ='NON_PROFESSIONAL';


  CURSOR c_proff_fund_count ( cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                              cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                              cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                              cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                              cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                              cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                              cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                              cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
  SELECT NVL(SUM(awd.paid_amt),0)
    FROM igf_ap_isir_matched isir,
         igf_aw_award_v awd,
         igf_ap_fa_base_rec  fa
  WHERE awd.base_id =isir.base_id
    AND fa.base_id =isir.base_id
    AND isir.dependency_status =p_depend_stat
    AND awd.fed_fund_code =cp_fund_type
    AND awd.ci_cal_type =cp_ci_cal_type
    AND awd.ci_sequence_number =cp_ci_sequence_number
    AND  NVL(isir.auto_zero_efc,'N') <> 'Y'
    AND isir.active_isir ='Y'
    AND isir.citizenship_status='1'
    AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
    AND awd.award_status IN ('ACCEPTED','OFFERED')
    AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) ='FT'
    AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                           (SELECT cl.program_type
                                                              FROM igf_aw_career_map cl
                                                             WHERE cl.class_standing ='3' )
    AND cp_rec_type ='PROFESSIONAL';

CURSOR c_less_ft_fund_count (
                            cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                            cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                            cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                            cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                            cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                            cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                            cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                            cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
IS
 SELECT NVL(SUM(awd.paid_amt),0)
   FROM igf_ap_isir_matched isir,
        igf_aw_award_v awd,
        igf_ap_fa_base_rec  fa
  WHERE awd.base_id =isir.base_id
    AND fa.base_id =isir.base_id
    AND isir.dependency_status IN ('I','D')
    AND awd.fed_fund_code =cp_fund_type
    AND awd.ci_cal_type =cp_ci_cal_type
    AND awd.ci_sequence_number =cp_ci_sequence_number
    AND awd.award_status IN ('ACCEPTED','OFFERED')
    AND NVL(isir.auto_zero_efc,'N') <> 'Y'
    AND isir.active_isir ='Y'
    AND isir.citizenship_status='1'
    AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
    AND NVL(igf_ap_gen_001.get_derived_attend_type(awd.base_id),'N') <>'FT'
    AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                            (SELECT cl.program_type
                                                               FROM igf_aw_career_map cl
                                                              WHERE cl.class_standing IN ('1','2','3') )
    AND cp_rec_type ='LESS_THAN_FULL_TIME';

  CURSOR c_auto_efc_fund_count (
                                cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                                cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                                cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                                cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                                cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                                cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
   SELECT NVL(SUM(awd.paid_amt),0)
     FROM igf_ap_isir_matched isir,
          igf_aw_award_v awd,
          igf_ap_fa_base_rec  fa
    WHERE awd.base_id =isir.base_id
      AND fa.base_id =isir.base_id
      AND isir.dependency_status IN ('I','D')
      AND awd.ci_cal_type =cp_ci_cal_type
      AND awd.ci_sequence_number =cp_ci_sequence_number
      AND awd.fed_fund_code =cp_fund_type
      AND awd.award_status IN ('ACCEPTED','OFFERED')
      AND isir.auto_zero_efc = 'Y'
      AND isir.active_isir ='Y'
      AND isir.citizenship_status='1'
      AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) = 'FT'
      AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
         (SELECT cl.program_type FROM igf_aw_career_map cl
           WHERE cl.class_standing IN ('1','2','3') )
      AND cp_rec_type ='AUTO_ZERO';
*/

l_fnd_cnt      igf_aw_fisap_vi_h.fseog_fund_total%TYPE DEFAULT 0;
-- fund total is same data type for
-- all the 3 funds.

l_rec_type     igf_aw_fisap_vi_h.rec_type%TYPE;
l_fund_type    igf_aw_award_v.fed_fund_code%TYPE;

BEGIN
--  code commented as part of Fa132. function only returns 0 since this function is being used
-- in igf_aw_fisap_section_ii_v and igf_aw_fisap_section_vi_v
 /*

-- copy values of parameters into local variables.

  l_rec_type := p_rec_type;
  l_fund_type := p_fund_type;
  l_fnd_cnt :=0; -- initialise the count

-- check if the minimum required parameters are passed or not
-- return -1 if incorrect values passed for REC_TYPE
-- return -2 if incorrect values passed for FUND_TYPE

  IF l_rec_type IS NULL OR
    l_rec_type NOT IN ('AUTO_ZERO','LESS_THAN_FULL_TIME',
                       'PROFESSIONAL','NON_PROFESSIONAL') THEN
    l_fnd_cnt := -1;
    RETURN (l_fnd_cnt);
  END IF;

  IF l_fund_type IS NULL OR
    l_fund_type NOT IN ('UNDUPL','FSEOG','FWS','PRK') THEN
    l_fnd_cnt := -2;
    RETURN (l_fnd_cnt);
  END IF;

-- For class standing 4 (ie profession and graduate) and if the Fund is FSEOG then return
-- Null/0, this is handled in the form.

-- open each cursor to get the fund total for students.
-- the opening of the cursor will depend on the passed p_rec_type and p_fund_type
-- parameters.

-- open first cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and non professional

  IF l_rec_type ='NON_PROFESSIONAL' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_non_proff_fund_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_non_proff_fund_count INTO l_fnd_cnt;
         IF c_non_proff_fund_count%NOTFOUND THEN
     l_fnd_cnt:=0;
     RETURN (l_fnd_cnt);
         ELSIF  c_non_proff_fund_count%FOUND THEN
     RETURN (l_fnd_cnt);
         END IF;
       CLOSE c_non_proff_fund_count;

-- open second cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and professional

   ELSIF
     l_rec_type ='PROFESSIONAL' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_proff_fund_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_proff_fund_count INTO l_fnd_cnt;
         IF c_proff_fund_count%NOTFOUND THEN
     l_fnd_cnt:=0;
     RETURN (l_fnd_cnt);
         ELSIF c_proff_fund_count%FOUND THEN
     RETURN (l_fnd_cnt);
         END IF;
       CLOSE c_proff_fund_count;

-- open third cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and less than full time

   ELSIF
     l_rec_type ='LESS_THAN_FULL_TIME' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_less_ft_fund_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_less_ft_fund_count INTO l_fnd_cnt;
         IF c_less_ft_fund_count%NOTFOUND THEN
     l_fnd_cnt:=0;
     RETURN (l_fnd_cnt);
         ELSIF c_less_ft_fund_count%FOUND THEN
     RETURN (l_fnd_cnt);
         END IF;
       CLOSE c_less_ft_fund_count;

-- open fourth cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and auto zero

   ELSIF
     l_rec_type ='AUTO_ZERO' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_auto_efc_fund_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_auto_efc_fund_count INTO l_fnd_cnt;
         IF c_auto_efc_fund_count%NOTFOUND THEN
     l_fnd_cnt:=0;
     RETURN (l_fnd_cnt);
         ELSIF  c_auto_efc_fund_count%FOUND THEN
     RETURN (l_fnd_cnt);
         END IF;
       CLOSE c_auto_efc_fund_count;

   END IF;*/
   RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
   /* IF c_non_proff_fund_count%ISOPEN THEN
       CLOSE c_non_proff_fund_count;
    END IF;
    IF c_proff_fund_count%ISOPEN THEN
       CLOSE c_proff_fund_count;
    END IF;
    IF c_less_ft_fund_count%ISOPEN THEN
       CLOSE c_less_ft_fund_count;
    END IF;
    IF c_auto_efc_fund_count%ISOPEN THEN
       CLOSE c_auto_efc_fund_count;
    END IF;*/
    RETURN (-3); -- returning -3 means Unhandled exception raised

END get_sectionvi_fund;


FUNCTION get_sectionvi_stdnt (p_rec_type            IN igf_aw_fisap_vi_h.rec_type%TYPE,
                              p_fund_type           IN igf_aw_award_v.fed_fund_code%TYPE,
                              p_depend_stat         IN igf_lookups_view.lookup_code%TYPE,
                              p_class_standing      IN igf_lookups_view.lookup_code%TYPE,
                              p_ci_cal_type         IN igs_ca_inst.cal_type%TYPE,
                              p_ci_sequence_number  IN igs_ca_inst.sequence_number%TYPE,
                              p_minvalue            IN igf_aw_fi_inc_level.minvalue%TYPE,
                              p_maxvalue            IN igf_aw_fi_inc_level.maxvalue%TYPE )
RETURN NUMBER
IS

------------------------------------------------------------------------------------
    --Created by  : ssawhney ( Oracle IDC)
    --Date created: 2001/10/23
    --Purpose:  The function would be used to calculate the Total Count of Students
    --for a category and Income Range. This function is used in the view
    --IGF_AW_FISAP SECTIONVI_V
    --and would retrieve the student count for a specific category which is An Award Year,
    --Class Standing, Dependency Status and FISAP Section, combination.
    --
    --Known limitations/enhancements and/or remarks:
    --Change History:
    --Who         When            What
-------------------------------------------------------------------------------------
-- return -1 if incorrect values passed for REC_TYPE
-- return -2 if incorrect values passed for FUND_TYPE
-- return -3 if any Unhandled Exception is Raised.

-- This cursor would check for the fund types "FWS, PRK, FSEOG"
-- and class Standing as 4 ( 4 combination of 1 and 2) and REC_TYPE as "NON_PROFESSIONAL"
/*
  CURSOR c_non_proff_std_count (cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                                cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                                cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                                cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                                cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                                cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
   SELECT COUNT (isir.base_id )
     FROM igf_ap_isir_matched isir,
          igf_aw_award_v awd,
          igf_ap_fa_base_rec  fa
    WHERE isir.dependency_status =cp_depend_stat
      AND fa.base_id =isir.base_id
      AND   awd.base_id = isir.base_id
      AND   NVL(isir.auto_zero_efc,'N') <> 'Y'
      AND   awd.fed_fund_code = cp_fund_type
      AND   awd.ci_cal_type =cp_ci_cal_type
      AND   awd.ci_sequence_number =cp_ci_sequence_number
      AND   awd.award_status IN ('ACCEPTED','OFFERED')
      AND   isir.active_isir ='Y'
      AND   isir.citizenship_status='1'
      AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) ='FT'
      AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                            (SELECT cl.program_type
                                                               FROM igf_aw_career_map cl
                                                              WHERE cl.class_standing IN ('1','2') )
      AND   isir.fti between cp_minvalue and cp_maxvalue
      AND   cp_rec_type ='NON_PROFESSIONAL';


-- This cursor will get for dependency Status  " I" and the
-- p_rec_type ='PROFESSIONAL' and the fund_type  'FWS' or 'PRK'
-- there is no FSEOG fund for Profession cat.

  CURSOR c_proff_std_count (cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                            cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                            cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                            cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                            cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                            cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                            cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                            cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
   SELECT COUNT (isir.base_id )
     FROM igf_ap_isir_matched isir,
          igf_aw_award_v awd,
          igf_ap_fa_base_rec  fa
    WHERE isir.dependency_status =cp_depend_stat
      AND awd.base_id= isir.base_id
      AND fa.base_id = isir.base_id
      AND awd.fed_fund_code = cp_fund_type
      AND awd.ci_cal_type = cp_ci_cal_type
      AND awd.ci_sequence_number =cp_ci_sequence_number
      AND awd.award_status IN ('ACCEPTED','OFFERED')
      AND   NVL(isir.auto_zero_efc,'N') <> 'Y'
      AND isir.active_isir ='Y'
      AND isir.citizenship_status='1'
      AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) ='FT'
      AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                             (SELECT cl.program_type
                                                                FROM igf_aw_career_map cl
                                                               WHERE  cl.class_standing ='3' )
      AND cp_rec_type ='PROFESSIONAL';


--For total Less than full Time students
--The dependency status passed to this "B", valid fed_fund_code and not 'UNDUPL'
--and class standing passed would be GRAD-UGRAD
  CURSOR c_less_ft_std_count (cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                              cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                              cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                              cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                              cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                              cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                              cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                              cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
   SELECT  COUNT (isir.base_id )
     FROM igf_ap_isir_matched isir,
          igf_aw_award_v awd,
          igf_ap_fa_base_rec  fa
    WHERE isir.dependency_status IN ('I','D')
      AND awd.base_id = isir.base_id
      AND fa.base_id =isir.base_id
      AND NVL(isir.auto_zero_efc,'N') <> 'Y'
      AND awd.fed_fund_code = cp_fund_type
      AND awd.ci_cal_type =cp_ci_cal_type
      AND awd.ci_sequence_number =cp_ci_sequence_number
      AND awd.award_status IN ('ACCEPTED','OFFERED')
      AND isir.active_isir ='Y'
      AND isir.citizenship_status='1'
      AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND NVL(igf_ap_gen_001.get_derived_attend_type(awd.base_id),'N') <> 'FT'
      AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                             (SELECT cl.program_type
                                                                FROM igf_aw_career_map cl
                                                               WHERE cl.class_standing IN ('1','2','3') )
      AND p_rec_type ='LESS_THAN_FULL_TIME';

--The dependency status passed to this "B", valid
--FED_FUND_CODE and not 'UNDUPL' and class standing passed would be GRAD-UGRAD

  CURSOR c_auto_efc_std_count ( cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                                cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                                cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                                cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                                cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                                cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
   SELECT COUNT ( isir.base_id )
     FROM igf_ap_isir_matched isir,
          igf_aw_award_v awd,
          igf_ap_fa_base_rec  fa
    WHERE isir.dependency_status IN ('I','D')
      AND awd.base_id = isir.base_id
      AND fa.base_id =isir.base_id
      AND awd.fed_fund_code = cp_fund_type
      AND awd.ci_cal_type =cp_ci_cal_type
      AND awd.ci_sequence_number =cp_ci_sequence_number
      AND awd.award_status IN ('ACCEPTED','OFFERED')
      AND isir.auto_zero_efc = 'Y'
      AND isir.active_isir ='Y'
      AND isir.citizenship_status='1'
      AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) = 'FT'
      AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                             (SELECT cl.program_type
                                                                FROM igf_aw_career_map cl
                                                               WHERE cl.class_standing IN ('1','2','3') )
      AND cp_rec_type ='AUTO_ZERO';
-- This cursor would check for the fund types "FWS, PRK, FSEOG"
-- and class Standing as 4 and REC_TYPE as "NON_PROFESSIONAL" and Unduplicate student

  CURSOR c_non_proff_und_std_count (cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                                    cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                                    cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                                    cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                                    cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                    cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                    cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                                    cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
   SELECT COUNT ( DISTINCT (isir.base_id ) )
     FROM   igf_ap_isir_matched isir,
            igf_aw_award_v awd,
            igf_ap_fa_base_rec  fa
    WHERE isir.dependency_status = cp_depend_stat
      AND   awd.base_id = isir.base_id
      AND   fa.base_id =isir.base_id
      AND   awd.fed_fund_code IN ('FWS','FSEOG','PRK')
      AND   awd.ci_cal_type =cp_ci_cal_type
      AND   awd.ci_sequence_number =cp_ci_sequence_number
      AND   awd.award_status IN ('ACCEPTED','OFFERED')
      AND   NVL(isir.auto_zero_efc,'N') <> 'Y'
      AND   isir.active_isir ='Y'
      AND   isir.citizenship_status='1'
      AND   DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND   igf_ap_gen_001.get_derived_attend_type(awd.base_id) ='FT'
      AND   igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                               (SELECT cl.program_type
                                                                  FROM igf_aw_career_map cl
                                                                 WHERE cl.class_standing IN ('1','2') )
      AND   isir.fti between cp_minvalue and cp_maxvalue
      AND   cp_rec_type ='NON_PROFESSIONAL';


-- This cursor will get for dependency Status  " I" and the
-- p_rec_type ='PROFESSIONAL' and the fund_type  'FWS' or 'PRK' and Unduplicate
-- there is no FSEOG fund for Profession cat.

  CURSOR c_proff_und_std_count (cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                                cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                                cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                                cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                                cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                                cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE ) IS
   SELECT COUNT (DISTINCT (isir.base_id ) )
     FROM igf_ap_isir_matched isir,
          igf_aw_award_v awd,
          igf_ap_fa_base_rec  fa
    WHERE isir.dependency_status =cp_depend_stat
      AND awd.base_id = isir.base_id
      AND fa.base_id =isir.base_id
      AND awd.fed_fund_code IN ('FWS','FSEOG','PRK')
      AND awd.ci_cal_type =cp_ci_cal_type
      AND awd.ci_sequence_number =cp_ci_sequence_number
      AND awd.award_status IN ('ACCEPTED','OFFERED')
      AND NVL(isir.auto_zero_efc,'N') <> 'Y'
      AND isir.active_isir ='Y'
      AND isir.citizenship_status='1'
      AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) ='FT'
      AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                             (SELECT program_type
                                                                FROM igf_aw_career_map cl
                                                               WHERE cl.class_standing ='3' )
      AND cp_rec_type ='PROFESSIONAL';


--For total Less than full Time students
--The dependency status passed to this "B", valid fed_fund_code and 'UNDUPL'
--and class standing passed would be GRAD-UGRAD

  CURSOR c_less_ft_und_std_count (cp_rec_type  igf_aw_fisap_vi_h.rec_type%TYPE,
                                  cp_fund_type  igf_aw_award_v.fed_fund_code%TYPE,
                                  cp_depend_stat   igf_lookups_view.lookup_code%TYPE,
                                  cp_class_standing  igf_lookups_view.lookup_code%TYPE,
                                  cp_ci_cal_type  igs_ca_inst.cal_type%TYPE,
                                  cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                  cp_minvalue  igf_aw_fi_inc_level.minvalue%TYPE,
                                  cp_maxvalue  igf_aw_fi_inc_level.maxvalue%TYPE )
  IS
   SELECT COUNT (DISTINCT(isir.base_id ))
     FROM igf_ap_isir_matched isir,
          igf_aw_award_v awd,
          igf_ap_fa_base_rec  fa
    WHERE isir.dependency_status IN ('I','D')
      AND awd.base_id = isir.base_id
      AND fa.base_id = isir.base_id
      AND awd.fed_fund_code IN ('FWS','FSEOG','PRK')
      AND awd.ci_cal_type =cp_ci_cal_type
      AND awd.ci_sequence_number =cp_ci_sequence_number
      AND awd.award_status IN ('ACCEPTED','OFFERED')
      AND NVL(isir.auto_zero_efc,'N') <> 'Y'
      AND isir.active_isir ='Y'
      AND isir.citizenship_status='1'
      AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
      AND NVL(igf_ap_gen_001.get_derived_attend_type(awd.base_id),'N') <> 'FT'
      AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                              (SELECT cl.program_type
                                                                 FROM igf_aw_career_map cl
                                                                WHERE cl.class_standing IN ('1','2','3') )
      AND cp_rec_type ='LESS_THAN_FULL_TIME';


--The dependency status passed to this "B", valid
--FED_FUND_CODE and 'UNDUPL' and class standing passed would be GRAD-UGRAD

CURSOR c_auto_efc_und_std_count ( cp_rec_type            igf_aw_fisap_vi_h.rec_type%TYPE,
                                  cp_fund_type           igf_aw_award_v.fed_fund_code%TYPE,
                                  cp_depend_stat         igf_lookups_view.lookup_code%TYPE,
                                  cp_class_standing      igf_lookups_view.lookup_code%TYPE,
                                  cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                  cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                                  cp_minvalue            igf_aw_fi_inc_level.minvalue%TYPE,
                                  cp_maxvalue            igf_aw_fi_inc_level.maxvalue%TYPE )
IS
 SELECT COUNT (DISTINCT(isir.base_id ))
   FROM igf_ap_isir_matched isir,
        igf_aw_award_v awd,
        igf_ap_fa_base_rec  fa
  WHERE isir.dependency_status IN ('I','D')
    AND awd.fed_fund_code IN ('FWS','FSEOG','PRK')
    AND awd.ci_cal_type =cp_ci_cal_type
    AND awd.ci_sequence_number =cp_ci_sequence_number
    AND awd.award_status IN ('ACCEPTED','OFFERED')
    AND awd.base_id = isir.base_id
    AND fa.base_id =isir.base_id
    AND isir.auto_zero_efc = 'Y'
    AND isir.active_isir ='Y'
    AND isir.citizenship_status='1'
    AND DECODE(fa.award_fmly_contribution_type, 2, isir.secondary_efc, isir.primary_efc) IS NOT NULL
    AND igf_ap_gen_001.get_derived_attend_type(awd.base_id) = 'FT'
    AND igf_ap_gen_001.get_enrl_program_type(awd.base_id) IN
                                                            (SELECT cl.program_type
                                                               FROM igf_aw_career_map cl
                                                              WHERE cl.class_standing IN ('1','2','3') )
    AND cp_rec_type ='AUTO_ZERO';
*/
l_std_cnt      igf_aw_fisap_ii_h.student_count%TYPE DEFAULT 0;
l_rec_type     igf_aw_fisap_vi_h.rec_type%TYPE;
l_fund_type    igf_aw_award_v.fed_fund_code%TYPE;

BEGIN
--  code commented as part of Fa132. function only returns 0 since this function is being used
-- in igf_aw_fisap_section_ii_v and igf_aw_fisap_section_vi_v
 /*

-- copy values of parameters into local variables.

  l_rec_type := p_rec_type;
  l_fund_type := p_fund_type;

-- check if the minimum required parameters are passed or not
-- return -1 if incorrect values passed for REC_TYPE
-- return -2 if incorrect values passed for FUND_TYPE

  IF l_rec_type IS NULL OR
    l_rec_type NOT IN ('AUTO_ZERO','LESS_THAN_FULL_TIME',
                       'PROFESSIONAL','NON_PROFESSIONAL') THEN
    l_std_cnt := -1;
    RETURN (l_std_cnt);
  END IF;

  IF l_fund_type IS NULL OR
    l_fund_type NOT IN ('UNDUPL','FSEOG','FWS','PRK') THEN
    l_std_cnt := -2;
    RETURN (l_std_cnt);
  END IF;

-- open each cursor to get the count of students.
-- the opening of the cursor will depend on the passed p_rec_type and p_fund_type
-- parameters.

-- open first cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and non professional

  IF l_rec_type ='NON_PROFESSIONAL' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_non_proff_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_non_proff_std_count INTO l_std_cnt;
         IF c_non_proff_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF c_non_proff_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_non_proff_std_count;

-- count for UNduplicated records now.

   ELSIF
     l_rec_type ='NON_PROFESSIONAL' AND
     l_fund_type = 'UNDUPL' THEN
       OPEN c_non_proff_und_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_non_proff_und_std_count INTO l_std_cnt;
         IF c_non_proff_und_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF c_non_proff_und_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_non_proff_und_std_count;

-- open second cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and professional

   ELSIF
     l_rec_type ='PROFESSIONAL' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_proff_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_proff_std_count INTO l_std_cnt;
         IF c_proff_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF c_proff_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_proff_std_count;

-- now count for Undulicated records
   ELSIF
     l_rec_type ='PROFESSIONAL' AND
     l_fund_type = 'UNDUPL' THEN
       OPEN c_proff_und_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_proff_und_std_count INTO l_std_cnt;
         IF c_proff_und_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF c_proff_und_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_proff_und_std_count;

-- open third cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and Not FULL TIME

   ELSIF
     l_rec_type ='LESS_THAN_FULL_TIME' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_less_ft_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_less_ft_std_count INTO l_std_cnt;
         IF c_less_ft_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF c_less_ft_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_less_ft_std_count;

-- now open for Unduplicated record.

   ELSIF
     l_rec_type ='LESS_THAN_FULL_TIME' AND
     l_fund_type = 'UNDUPL' THEN
       OPEN c_less_ft_und_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_less_ft_und_std_count INTO l_std_cnt;
         IF c_less_ft_und_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF c_less_ft_und_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_less_ft_und_std_count;

-- open fourth cursor, count of all students having any of the funds in
-- FWS, PRK,FSEOG and un duplicate records, and AUTO ZERO EFC

   ELSIF
     l_rec_type ='AUTO_ZERO' AND
     l_fund_type <> 'UNDUPL' THEN
       OPEN c_auto_efc_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_auto_efc_std_count INTO l_std_cnt;
         IF c_auto_efc_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF  c_auto_efc_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_auto_efc_std_count;

-- now count for unduplicate recs.

   ELSIF
     l_rec_type ='AUTO_ZERO' AND
     l_fund_type = 'UNDUPL' THEN
       OPEN c_auto_efc_und_std_count(
         p_rec_type,
         p_fund_type,
         p_depend_stat,
         p_class_standing ,
         p_ci_cal_type ,
         p_ci_sequence_number ,
         p_minvalue ,
         p_maxvalue
         );
   FETCH c_auto_efc_und_std_count INTO l_std_cnt;
         IF c_auto_efc_und_std_count%NOTFOUND THEN
     l_std_cnt:=0;
     RETURN (l_std_cnt);
         ELSIF  c_auto_efc_und_std_count%FOUND THEN
     RETURN (l_std_cnt);
         END IF;
       CLOSE c_auto_efc_und_std_count;
     END IF;
*/
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    /*IF c_auto_efc_und_std_count%ISOPEN THEN
       CLOSE c_auto_efc_und_std_count;
    END IF;
    IF c_auto_efc_std_count%ISOPEN THEN
       CLOSE c_auto_efc_std_count;
    END IF;
    IF c_less_ft_und_std_count%ISOPEN THEN
       CLOSE c_less_ft_und_std_count;
    END IF;
    IF c_less_ft_std_count%ISOPEN THEN
       CLOSE c_less_ft_std_count;
    END IF;
    IF c_proff_und_std_count%ISOPEN THEN
       CLOSE c_proff_und_std_count;
    END IF;
    IF c_proff_std_count%ISOPEN THEN
       CLOSE c_proff_std_count;
    END IF;
    IF c_less_ft_std_count%ISOPEN THEN
       CLOSE c_less_ft_std_count;
    END IF;
    IF c_non_proff_std_count %ISOPEN THEN
       CLOSE c_non_proff_std_count ;
    END IF;*/

    RETURN (-3); -- returning -3 means Unhandled exception raised

END get_sectionvi_stdnt;


  --Procedure for Comparing ISIR Applications
  PROCEDURE  compare_isirs(
                           p_isir_id       igf_ap_isir_matched_all.isir_id%TYPE,
                           p_corr_isir_id  igf_ap_isir_matched_all.isir_id%TYPE,
                           p_cal_type      igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                           p_seq_num       igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                           p_corr_status   igf_ap_isir_corr.correction_status%TYPE
                          ) AS

    /***************************************************************
     Created By   : mesriniv
     Date Created By  : 2001/20/12
     Purpose    : This Procedure is added for Comparison of ISIR Fields.
                                  This procedure is being called in the IGFAP003.pld for
                                  Save as Correction ISIR
     Known Limitations,Enhancements or Remarks

     Change History :
     Enh Bug 2142666 EFC Build 2002 Jul
     Who      When    What
     brajendr  28-Nov-2002   Modified the parameters. Removed the Row Type and changed to ISIR ID
     ***************************************************************/

    -- Get ISIR details
    CURSOR c_get_org_isir( cp_isir_id  igf_ap_isir_matched_all.isir_id%TYPE ) IS
       SELECT *
         FROM igf_ap_isir_matched
        WHERE isir_id = cp_isir_id;

    p_isir_corr  c_get_org_isir%ROWTYPE;
    p_isir_pay   c_get_org_isir%ROWTYPE;
    -- Get system award details
    CURSOR c_sys_awd_yr(
                        cp_cal_type      igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        cp_seq_num       igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                       ) IS
      SELECT sys_award_year
        FROM igf_ap_batch_aw_map
       WHERE ci_cal_type = cp_cal_type
         AND ci_sequence_number = cp_seq_num;

      lc_sys_awd_yr c_sys_awd_yr%ROWTYPE;


    PROCEDURE comp_fields(
                           p_field_corr   IN  VARCHAR2,
                           p_field_pay    IN  VARCHAR2,
                           p_field_name   IN  VARCHAR2
                          ) AS

      -- ## Cursor to get the changed code values
      -- cursor modifed as part of FACR 113  SAR Updates
      CURSOR c_chg_code ( cp_cal_type    igf_ap_batch_aw_map.ci_cal_type%TYPE,
                          cp_seq_num     igf_ap_batch_aw_map.ci_sequence_number%TYPE )  IS
         SELECT sar.sar_field_number
           FROM igf_ap_batch_aw_map  map,
                Igf_fc_sar_cd_mst    sar
          WHERE map.ci_cal_type        = cp_cal_type
            AND map.ci_sequence_number = cp_seq_num
            AND sar.sys_award_year     = map.sys_award_year
            AND sar.sar_field_name     = p_field_name ;


     CURSOR chk_corr_exists(v_isir_id     NUMBER,
                            v_cal_type    VARCHAR2,
                            v_seq_num     NUMBER,
                            v_sar_fld     VARCHAR2
                            ) IS
        SELECT row_id , isirc_id,correction_status
          FROM igf_ap_isir_corr
         WHERE isir_id            = v_isir_id
           AND ci_cal_type        = v_cal_type
           AND ci_sequence_number = v_seq_num
           AND sar_field_number   = v_sar_fld    ;


      lc_chg_code   igf_lookups_view.lookup_code%TYPE;
      l_rowid       VARCHAR2(25);
      l_isirc_id    igf_ap_isir_corr.isirc_id%TYPE;
      p_batch_id    igf_ap_isir_corr.batch_id%TYPE;
      lv_corr_status VARCHAR2(30);

      l_chk_corr_exists chk_corr_exists%rowtype;

    BEGIN

      --Compare the Fields and insert if they have diff values
      IF (p_field_corr IS NULL AND p_field_pay IS NULL) OR
         (p_field_corr = p_field_pay) THEN
          NULL;
      ELSE

        OPEN  c_chg_code (p_cal_type, p_seq_num);
        FETCH c_chg_code INTO lc_chg_code;
        IF c_chg_code%NOTFOUND THEN
           CLOSE c_chg_code;
          --Raise an error as No such Field Defined
          fnd_message.set_name('IGF','IGF_AP_NO_SUCH_CHNG_CODE');
          fnd_message.set_token('CHANGE_CODE',p_field_name);
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;

        BEGIN
          --Insert this Change Code and Its changed value for tracking

          OPEN  chk_corr_exists(p_isir_pay.isir_id,p_cal_type,p_seq_num,lc_chg_code);
          FETCH chk_corr_exists INTO l_chk_corr_exists;
          CLOSE chk_corr_exists;

    IF l_chk_corr_exists.isirc_id IS NULL THEN

    igf_ap_isir_corr_pkg.insert_row(
                                          X_ROWID                 => l_rowid,
                                          X_ISIRC_ID              => l_isirc_id,
                                          X_ISIR_ID               => p_isir_pay.isir_id,
                                          X_CI_SEQUENCE_NUMBER    => p_seq_num,
                                          X_CI_CAL_TYPE           => p_cal_type,
                                          X_SAR_FIELD_NUMBER      => lc_chg_code,
                                          X_ORIGINAL_VALUE        => p_field_pay,
                                          X_BATCH_ID              => NULL,
                                          X_CORRECTED_VALUE       => p_field_corr,
                                          X_CORRECTION_STATUS     => p_corr_status,
                                          X_MODE                  => 'R'
                                         );
  ELSE
  l_rowid :=  l_chk_corr_exists.row_id ;

  IF l_chk_corr_exists.correction_status = 'HOLD' THEN
     lv_corr_status := 'HOLD' ;
  ELSE
     lv_corr_status := p_corr_status ;
  END IF;
    igf_ap_isir_corr_pkg.update_row(
                                          X_ROWID                 => l_rowid,
                                          X_ISIRC_ID              => l_chk_corr_exists.isirc_id,
                                          X_ISIR_ID               => p_isir_pay.isir_id,
                                          X_CI_SEQUENCE_NUMBER    => p_seq_num,
                                          X_CI_CAL_TYPE           => p_cal_type,
                                          X_SAR_FIELD_NUMBER      => lc_chg_code,
                                          X_ORIGINAL_VALUE        => p_field_pay,
                                          X_BATCH_ID              => NULL,
                                          X_CORRECTED_VALUE       => p_field_corr,
                                          X_CORRECTION_STATUS     => lv_corr_status,
                                          X_MODE                  => 'R'
                                         );

  END IF;
  EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        CLOSE c_chg_code;    -- ## Close the Cursor

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','igf_ap_compare_fields');
         igs_ge_msg_stack.add;
         APP_EXCEPTION.RAISE_EXCEPTION;
    END comp_fields;

  BEGIN
    -- Get record record of Original ISIR
    OPEN  c_get_org_isir(p_isir_id);
    FETCH c_get_org_isir INTO p_isir_pay;
    CLOSE c_get_org_isir;

    -- Get record record of Correction ISIR
    OPEN  c_get_org_isir(p_corr_isir_id);
    FETCH c_get_org_isir INTO p_isir_corr;
    CLOSE c_get_org_isir;

    -- Compare all the fields which are registered as Lookup Codes and which can change
    comp_fields( p_isir_corr.LAST_NAME,p_isir_pay.LAST_NAME,'LAST_NAME');
    comp_fields( p_isir_corr.PHONE_NUMBER,p_isir_pay.PHONE_NUMBER,'PHONE_NUMBER') ;
    comp_fields( p_isir_corr.PREPARER_SSN,p_isir_pay.PREPARER_SSN,'PREPARER_SSN');
    comp_fields( p_isir_corr.PREPARER_EMP_ID_NUMBER,p_isir_pay.PREPARER_EMP_ID_NUMBER,'PREPARER_EMP_ID_NUMBER');
    comp_fields( p_isir_corr.PREPARER_SIGN,p_isir_pay.PREPARER_SIGN,'PREPARER_SIGN');

    -- bug 3277173
    comp_fields( p_isir_corr.DATE_OF_BIRTH,p_isir_pay.DATE_OF_BIRTH,'DATE_OF_BIRTH');

    comp_fields( p_isir_corr.DEPENDENCY_OVERRIDE_IND,p_isir_pay.DEPENDENCY_OVERRIDE_IND,'DEPENDENCY_OVERRIDE_IND');
    comp_fields( p_isir_corr.FAA_ADJUSTMENT,p_isir_pay.FAA_ADJUSTMENT,'FAA_ADJUSTMENT');
    comp_fields( p_isir_corr.DRIVER_LICENSE_NUMBER,p_isir_pay.DRIVER_LICENSE_NUMBER,'DRIVER_LICENSE_NUMBER');

    comp_fields( p_isir_corr.DRN,p_isir_pay.DRN,'DRN');
    comp_fields( p_isir_corr.DRIVER_LICENSE_STATE,p_isir_pay.DRIVER_LICENSE_STATE,'DRIVER_LICENSE_STATE');
    comp_fields( p_isir_corr.CITIZENSHIP_STATUS,p_isir_pay.CITIZENSHIP_STATUS,'CITIZENSHIP_STATUS');

    comp_fields( p_isir_corr.ALIEN_REG_NUMBER,p_isir_pay.ALIEN_REG_NUMBER,'ALIEN_REG_NUMBER');
    comp_fields( p_isir_corr.S_MARITAL_STATUS,p_isir_pay.S_MARITAL_STATUS,'S_MARITAL_STATUS');
    comp_fields( p_isir_corr.S_MARITAL_STATUS_DATE,p_isir_pay.S_MARITAL_STATUS_DATE,'S_MARITAL_STATUS_DATE');
    comp_fields( p_isir_corr.SUMM_ENRL_STATUS,p_isir_pay.SUMM_ENRL_STATUS,'SUMM_ENRL_STATUS');
    comp_fields( p_isir_corr.FALL_ENRL_STATUS,p_isir_pay.FALL_ENRL_STATUS,'FALL_ENRL_STATUS');

    comp_fields( p_isir_corr.WINTER_ENRL_STATUS,p_isir_pay.WINTER_ENRL_STATUS,'WINTER_ENRL_STATUS');
    comp_fields( p_isir_corr.FIRST_NAME,p_isir_pay.FIRST_NAME,'FIRST_NAME');
    comp_fields( p_isir_corr.SPRING_ENRL_STATUS,p_isir_pay.SPRING_ENRL_STATUS,'SPRING_ENRL_STATUS');
    comp_fields( p_isir_corr.SUMM2_ENRL_STATUS,p_isir_pay.SUMM2_ENRL_STATUS,'SUMM2_ENRL_STATUS');
    comp_fields( p_isir_corr.FATHERS_HIGHEST_EDU_LEVEL,p_isir_pay.FATHERS_HIGHEST_EDU_LEVEL,'FATHERS_HIGHEST_EDU_LEVEL');

    comp_fields( p_isir_corr.MOTHERS_HIGHEST_EDU_LEVEL,p_isir_pay.MOTHERS_HIGHEST_EDU_LEVEL,'MOTHERS_HIGHEST_EDU_LEVEL');
    comp_fields( p_isir_corr.S_STATE_LEGAL_RESIDENCE,p_isir_pay.S_STATE_LEGAL_RESIDENCE,'S_STATE_LEGAL_RESIDENCE');
    comp_fields( p_isir_corr.LEGAL_RESIDENCE_BEFORE_DATE,p_isir_pay.LEGAL_RESIDENCE_BEFORE_DATE,'LEGAL_RESIDENCE_BEFORE_DATE') ;
    comp_fields( p_isir_corr.S_LEGAL_RESD_DATE,p_isir_pay.S_LEGAL_RESD_DATE,'S_LEGAL_RESD_DATE');
    comp_fields( p_isir_corr.SS_R_U_MALE,p_isir_pay.SS_R_U_MALE,'SS_R_U_MALE') ;

    comp_fields( p_isir_corr.SELECTIVE_SERVICE_REG,p_isir_pay.SELECTIVE_SERVICE_REG,'SELECTIVE_SERVICE_REG');
    comp_fields( p_isir_corr.DEGREE_CERTIFICATION,p_isir_pay.DEGREE_CERTIFICATION,'DEGREE_CERTIFICATION') ;
    comp_fields( p_isir_corr.MIDDLE_INITIAL,p_isir_pay.MIDDLE_INITIAL,'MIDDLE_INITIAL');
    comp_fields( p_isir_corr.GRADE_LEVEL_IN_COLLEGE,p_isir_pay.GRADE_LEVEL_IN_COLLEGE,'GRADE_LEVEL_IN_COLLEGE') ;
    comp_fields( p_isir_corr.HIGH_SCHOOL_DIPLOMA_GED,p_isir_pay.HIGH_SCHOOL_DIPLOMA_GED,'HIGH_SCHOOL_DIPLOMA_GED');

    comp_fields( p_isir_corr.FIRST_BACHELOR_DEG_BY_DATE,p_isir_pay.FIRST_BACHELOR_DEG_BY_DATE,'FIRST_BACHELOR_DEG_BY_DATE');
    comp_fields( p_isir_corr.INTEREST_IN_LOAN,p_isir_pay.INTEREST_IN_LOAN,'INTEREST_IN_LOAN');
    comp_fields( p_isir_corr.INTEREST_IN_STUD_EMPLOYMENT,p_isir_pay.INTEREST_IN_STUD_EMPLOYMENT,'INTEREST_IN_STUD_EMPLOYMENT');
    comp_fields( p_isir_corr.DRUG_OFFENCE_CONVICTION,p_isir_pay.DRUG_OFFENCE_CONVICTION,'DRUG_OFFENCE_CONVICTION');
    comp_fields( p_isir_corr.S_TAX_RETURN_STATUS,p_isir_pay.S_TAX_RETURN_STATUS,'S_TAX_RETURN_STATUS');

    comp_fields( p_isir_corr.S_TYPE_TAX_RETURN,p_isir_pay.S_TYPE_TAX_RETURN,'S_TYPE_TAX_RETURN')  ;
    comp_fields( p_isir_corr.S_ELIG_1040EZ,p_isir_pay.S_ELIG_1040EZ,'S_ELIG_1040EZ');
    comp_fields( p_isir_corr.S_ADJUSTED_GROSS_INCOME,p_isir_pay.S_ADJUSTED_GROSS_INCOME,'S_ADJUSTED_GROSS_INCOME');
    comp_fields( p_isir_corr.PERM_MAIL_ADD,p_isir_pay.PERM_MAIL_ADD,'PERM_MAIL_ADD');
    comp_fields( p_isir_corr.S_FED_TAXES_PAID,p_isir_pay.S_FED_TAXES_PAID,'S_FED_TAXES_PAID');

    comp_fields( p_isir_corr.S_EXEMPTIONS,p_isir_pay.S_EXEMPTIONS,'S_EXEMPTIONS');
    comp_fields( p_isir_corr.S_INCOME_FROM_WORK,p_isir_pay.S_INCOME_FROM_WORK,'S_INCOME_FROM_WORK') ;
    comp_fields( p_isir_corr.SPOUSE_INCOME_FROM_WORK,p_isir_pay.SPOUSE_INCOME_FROM_WORK,'SPOUSE_INCOME_FROM_WORK');
    comp_fields( p_isir_corr.S_TOA_AMT_FROM_WSA,p_isir_pay.S_TOA_AMT_FROM_WSA,'S_TOA_AMT_FROM_WSA')  ;
    comp_fields( p_isir_corr.S_TOA_AMT_FROM_WSB,p_isir_pay.S_TOA_AMT_FROM_WSB,'S_TOA_AMT_FROM_WSB');

    comp_fields( p_isir_corr.S_TOA_AMT_FROM_WSC,p_isir_pay.S_TOA_AMT_FROM_WSC,'S_TOA_AMT_FROM_WSC');
    comp_fields( p_isir_corr.S_INVESTMENT_NETWORTH,p_isir_pay.S_INVESTMENT_NETWORTH,'S_INVESTMENT_NETWORTH');
    comp_fields( p_isir_corr.S_BUSI_FARM_NETWORTH,p_isir_pay.S_BUSI_FARM_NETWORTH,'S_BUSI_FARM_NETWORTH');
    comp_fields( p_isir_corr.S_CASH_SAVINGS,p_isir_pay.S_CASH_SAVINGS,'S_CASH_SAVINGS');
    comp_fields( p_isir_corr.PERM_CITY,p_isir_pay.PERM_CITY,'PERM_CITY');

    comp_fields( p_isir_corr.VA_MONTHS,p_isir_pay.VA_MONTHS,'VA_MONTHS');
    comp_fields( p_isir_corr.VA_AMOUNT,p_isir_pay.VA_AMOUNT,'VA_AMOUNT');
    comp_fields( p_isir_corr.STUD_DOB_BEFORE_DATE,p_isir_pay.STUD_DOB_BEFORE_DATE,'STUD_DOB_BEFORE_DATE');
    comp_fields( p_isir_corr.DEG_BEYOND_BACHELOR,p_isir_pay.DEG_BEYOND_BACHELOR,'DEG_BEYOND_BACHELOR');
    comp_fields( p_isir_corr.S_MARRIED,p_isir_pay.S_MARRIED,'S_MARRIED');

    comp_fields( p_isir_corr.S_HAVE_CHILDREN,p_isir_pay.S_HAVE_CHILDREN,'S_HAVE_CHILDREN');
    comp_fields( p_isir_corr.LEGAL_DEPENDENTS,p_isir_pay.LEGAL_DEPENDENTS,'LEGAL_DEPENDENTS');
    comp_fields( p_isir_corr.ORPHAN_WARD_OF_COURT,p_isir_pay.ORPHAN_WARD_OF_COURT,'ORPHAN_WARD_OF_COURT');
    comp_fields( p_isir_corr.S_VETERAN,p_isir_pay.S_VETERAN,'S_VETERAN');
    comp_fields( p_isir_corr.P_MARITAL_STATUS,p_isir_pay.P_MARITAL_STATUS,'P_MARITAL_STATUS');
    -- added parent_marital_status_date as part of nov 03 bug 3273581
    comp_fields( p_isir_corr.PARENT_MARITAL_STATUS_DATE,p_isir_pay.PARENT_MARITAL_STATUS_DATE,'PARENT_MARITAL_STATUS_DATE');

    comp_fields( p_isir_corr.PERM_STATE,p_isir_pay.PERM_STATE,'PERM_STATE');
    comp_fields( p_isir_corr.FATHER_SSN,p_isir_pay.FATHER_SSN,'FATHER_SSN');
    comp_fields( p_isir_corr.F_LAST_NAME,p_isir_pay.F_LAST_NAME,'F_LAST_NAME');
    comp_fields( p_isir_corr.MOTHER_SSN,p_isir_pay.MOTHER_SSN,'MOTHER_SSN');
    comp_fields( p_isir_corr.M_LAST_NAME,p_isir_pay.M_LAST_NAME,'M_LAST_NAME');

    comp_fields( p_isir_corr.P_NUM_FAMILY_MEMBER,p_isir_pay.P_NUM_FAMILY_MEMBER,'P_NUM_FAMILY_MEMBER');
    comp_fields( p_isir_corr.P_NUM_IN_COLLEGE,p_isir_pay.P_NUM_IN_COLLEGE,'P_NUM_IN_COLLEGE');
    comp_fields( p_isir_corr.P_STATE_LEGAL_RESIDENCE,p_isir_pay.P_STATE_LEGAL_RESIDENCE,'P_STATE_LEGAL_RESIDENCE');
    comp_fields( p_isir_corr.P_STATE_LEGAL_RES_BEFORE_DT,p_isir_pay.P_STATE_LEGAL_RES_BEFORE_DT,'P_STATE_LEGAL_RES_BEFORE_DT');
    comp_fields( p_isir_corr.P_LEGAL_RES_DATE,p_isir_pay.P_LEGAL_RES_DATE,'P_LEGAL_RES_DATE');

    comp_fields( p_isir_corr.PERM_ZIP_CODE,p_isir_pay.PERM_ZIP_CODE,'PERM_ZIP_CODE');
    comp_fields( p_isir_corr.P_TAX_RETURN_STATUS,p_isir_pay.P_TAX_RETURN_STATUS,'P_TAX_RETURN_STATUS');
    comp_fields( p_isir_corr.P_TYPE_TAX_RETURN,p_isir_pay.P_TYPE_TAX_RETURN,'P_TYPE_TAX_RETURN');
    comp_fields( p_isir_corr.P_ELIG_1040AEZ,p_isir_pay.P_ELIG_1040AEZ,'P_ELIG_1040AEZ');

    comp_fields( p_isir_corr.P_ADJUSTED_GROSS_INCOME,p_isir_pay.P_ADJUSTED_GROSS_INCOME,'P_ADJUSTED_GROSS_INCOME');
    comp_fields( p_isir_corr.P_TAXES_PAID,p_isir_pay.P_TAXES_PAID,'P_TAXES_PAID');
    comp_fields( p_isir_corr.P_EXEMPTIONS,p_isir_pay.P_EXEMPTIONS,'P_EXEMPTIONS');
    comp_fields( p_isir_corr.F_INCOME_WORK,p_isir_pay.F_INCOME_WORK,'F_INCOME_WORK');
    comp_fields( p_isir_corr.M_INCOME_WORK,p_isir_pay.M_INCOME_WORK,'M_INCOME_WORK');

    comp_fields( p_isir_corr.P_INCOME_WSA,p_isir_pay.P_INCOME_WSA,'P_INCOME_WSA');
    comp_fields( p_isir_corr.P_INCOME_WSB,p_isir_pay.P_INCOME_WSB,'P_INCOME_WSB');
    comp_fields( p_isir_corr.CURRENT_SSN,p_isir_pay.CURRENT_SSN,'CURRENT_SSN');
    comp_fields( p_isir_corr.P_INCOME_WSC,p_isir_pay.P_INCOME_WSC,'P_INCOME_WSC');
    comp_fields( p_isir_corr.P_INVESTMENT_NETWORTH,p_isir_pay.P_INVESTMENT_NETWORTH,'P_INVESTMENT_NETWORTH');

    comp_fields( p_isir_corr.P_BUSINESS_NETWORTH,p_isir_pay.P_BUSINESS_NETWORTH,'P_BUSINESS_NETWORTH');
    comp_fields( p_isir_corr.P_CASH_SAVING,p_isir_pay.P_CASH_SAVING,'P_CASH_SAVING')    ;
    comp_fields( p_isir_corr.S_NUM_FAMILY_MEMBERS,p_isir_pay.S_NUM_FAMILY_MEMBERS,'S_NUM_FAMILY_MEMBERS') ;
    -- bug 3277173
    comp_fields( p_isir_corr.S_NUM_IN_COLLEGE,p_isir_pay.S_NUM_IN_COLLEGE,'S_NUM_IN_COLLEGE');
    -- bug 3277173
    comp_fields( p_isir_corr.FIRST_COLLEGE,p_isir_pay.FIRST_COLLEGE,'FIRST_COLLEGE');
    comp_fields( p_isir_corr.FIRST_HOUSE_PLAN,p_isir_pay.FIRST_HOUSE_PLAN,'FIRST_HOUSE_PLAN');
    comp_fields( p_isir_corr.SECOND_COLLEGE,p_isir_pay.SECOND_COLLEGE,'SECOND_COLLEGE');
    comp_fields( p_isir_corr.SECOND_HOUSE_PLAN,p_isir_pay.SECOND_HOUSE_PLAN,'SECOND_HOUSE_PLAN');
    comp_fields( p_isir_corr.THIRD_COLLEGE  ,p_isir_pay.THIRD_COLLEGE  ,'THIRD_COLLEGE');
    comp_fields( p_isir_corr.THIRD_HOUSE_PLAN,p_isir_pay.THIRD_HOUSE_PLAN,'THIRD_HOUSE_PLAN');
    comp_fields( p_isir_corr.FOURTH_COLLEGE  ,p_isir_pay.FOURTH_COLLEGE  ,'FOURTH_COLLEGE');
    comp_fields( p_isir_corr.FOURTH_HOUSE_PLAN,p_isir_pay.FOURTH_HOUSE_PLAN,'FOURTH_HOUSE_PLAN');
    comp_fields( p_isir_corr.FIFTH_COLLEGE  ,p_isir_pay.FIFTH_COLLEGE  ,'FIFTH_COLLEGE');
    comp_fields( p_isir_corr.FIFTH_HOUSE_PLAN,p_isir_pay.FIFTH_HOUSE_PLAN,'FIFTH_HOUSE_PLAN');
    comp_fields( p_isir_corr.SIXTH_COLLEGE  ,p_isir_pay.SIXTH_COLLEGE  ,'SIXTH_COLLEGE');
    comp_fields( p_isir_corr.SIXTH_HOUSE_PLAN,p_isir_pay.SIXTH_HOUSE_PLAN,'SIXTH_HOUSE_PLAN');
     -- bug 3277173
     comp_fields( p_isir_corr.SIGNED_BY,p_isir_pay.SIGNED_BY,'SIGNED_BY');
     comp_fields( p_isir_corr.PREPARER_SIGN  ,p_isir_pay.PREPARER_SIGN  ,'PREPARER_SIGN');

     lc_sys_awd_yr := NULL;
      OPEN c_sys_awd_yr(p_cal_type, p_seq_num);
      FETCH c_sys_awd_yr INTO lc_sys_awd_yr;
      CLOSE c_sys_awd_yr;
      IF lc_sys_awd_yr.sys_award_year IN ('0203','0304') THEN
        comp_fields( p_isir_corr.FAA_FEDRAL_SCHL_CODE,p_isir_pay.FAA_FEDRAL_SCHL_CODE,'FAA_FEDRAL_SCHL_CODE');
        comp_fields( p_isir_corr.TRANSACTION_RECEIPT_DATE,p_isir_pay.TRANSACTION_RECEIPT_DATE,'TRANSACTION_RECEIPT_DATE');
        comp_fields( p_isir_corr.AGE_OLDER_PARENT,p_isir_pay.AGE_OLDER_PARENT,'AGE_OLDER_PARENT');
        comp_fields( p_isir_corr.EARLY_ANALYSIS_FLAG,p_isir_pay.EARLY_ANALYSIS_FLAG,'EARLY_ANALYSIS_FLAG');
        comp_fields( p_isir_corr.DATE_APP_COMPLETED,p_isir_pay.DATE_APP_COMPLETED,'DATE_APP_COMPLETED');
      ELSIF lc_sys_awd_yr.sys_award_year IN ('0405', '0506', '0607') THEN
        comp_fields( p_isir_corr.father_first_name_initial_txt,p_isir_pay.father_first_name_initial_txt,'FATHER_FIRST_NAME_INITIAL_TXT');
        comp_fields( p_isir_corr.father_step_father_birth_date,p_isir_pay.father_step_father_birth_date,'FATHER_STEP_FATHER_BIRTH_DATE');
        comp_fields( p_isir_corr.mother_first_name_initial_txt,p_isir_pay.mother_first_name_initial_txt,'MOTHER_FIRST_NAME_INITIAL_TXT');
        comp_fields( p_isir_corr.mother_step_mother_birth_date,p_isir_pay.mother_step_mother_birth_date,'MOTHER_STEP_MOTHER_BIRTH_DATE');
        comp_fields( p_isir_corr.parents_email_address_txt,p_isir_pay.parents_email_address_txt,'PARENTS_EMAIL_ADDRESS_TXT');
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_compare_isirs');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END compare_isirs;


PROCEDURE get_resource_need
  (
    p_base_id           IN      igf_ap_fa_base_rec.base_id%TYPE,
    p_resource_f        OUT NOCOPY     NUMBER,
    p_resource_i        OUT NOCOPY     NUMBER,
    p_unmet_need_f      OUT NOCOPY     NUMBER,
    p_unmet_need_i      OUT NOCOPY     NUMBER,
    p_resource_f_fc     OUT NOCOPY     NUMBER,
    p_resource_i_fc     OUT NOCOPY     NUMBER,
    p_awd_prd_code      IN  igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
    p_calc_for_subz_loan  IN  VARCHAR2  DEFAULT 'N'
  )
   AS
  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 08-JAN-2001
  ||  Purpose : Bug No: 2154941. This procedure takes the base_id (Student and Award Year) as in parameter. It passes out NOCOPY the
  ||            Federal and Institutional resources for that base id, and  Federal and institutional unmet
  ||            need/Overaward for that base_id.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        12-Oct-2004     FA 152 - Added p_awd_prd_code to the signature
  ||  bkkumar         12-May-2004     Bug 3620500 Added the code to correctly include the sponsorship awards while
  ||                                  calculating total awards.
  ||  veramach        07-OCT-2003     FA 124
  ||                                  cursor resource_cur modified -it does not select resource_fm_i
  ||  cdcruz          16-Dec-2002     Bug # 2691811
  ||                                  Modified the cursor resource_cur , Award Status filter added
  ||  cdcruz          26-oct-2002     Bug Id 2613546
  ||                                  Cursor resource_cur modified to include Familty Contribution calc as well
  ||  adhawan         25-oct-2002     Bug Id 2613546
  ||  brajendr        08-May-2002     Bug # 2348285
  ||                                  Modified the cursor resource_cur to have award_status condition
  ||  (reverse chronological order - newest change first)
  ||
  ||  Variables description -
  ||  p_resource_f      - SUM of all awards the Student has received
  ||  p_resource_i      - SUM of all Institutional awards the Student has received
  ||  p_resource_f_fc   - SUM of all Replace_EFC awards the Student has received
  */
    -- Cursor to determine the Total Awarded Amount for Federal and Institutional Methodology.
    -- As part of the Bug 3620500 The resource_f will include all the awards irrespective of the methodology
    -- and the replace_fc flad is applicable only to the federal methodology funds.
   CURSOR resource_cur IS
    SELECT NVL(SUM(NVL(disb.disb_gross_amt,0)),0) resource_f,
           NVL(SUM(DECODE(fm.fm_fc_methd,'INSTITUTIONAL',NVL(disb.disb_gross_amt,0),0)),0) resource_i,
           NVL(SUM(DECODE(fm.replace_fc,'Y',NVL(disb.disb_gross_amt,0),0)),0) resource_fm_f
    FROM igf_aw_awd_disb_all  disb,
         igf_aw_award_all     awd,
         igf_aw_fund_mast_all fm,
         igf_aw_fund_cat_all  fcat,
       ( SELECT base_id, ld_cal_type, ld_sequence_number
           FROM igf_aw_coa_itm_terms
          WHERE base_id  = p_base_id
          GROUP BY base_id,ld_cal_type,ld_sequence_number
       ) coa
    WHERE awd.fund_id             = fm.fund_id
     AND awd.award_id            = disb.award_id
     AND fm.fund_code            = fcat.fund_code
     AND awd.base_id             = p_base_id
     AND disb.ld_cal_type        = coa.ld_cal_type
     AND disb.ld_sequence_number = coa.ld_sequence_number
     AND awd.base_id             = coa.base_id
     AND disb.trans_type  <> 'C'
     AND awd.award_status IN ('OFFERED','ACCEPTED')
     AND (
            (p_calc_for_subz_loan = 'Y' AND fcat.fed_fund_code NOT IN ('VA30','AMERICORPS')) OR
            (p_calc_for_subz_loan = 'N')
         );
    resource_rec    resource_cur%ROWTYPE;

   CURSOR resource_cur_awd IS
    SELECT NVL(SUM(NVL(disb.disb_gross_amt, 0)), 0) resource_f,
           NVL(SUM(DECODE(fm.fm_fc_methd,'INSTITUTIONAL', NVL(disb.disb_gross_amt, 0),0)),0) resource_i,
           NVL(SUM(DECODE(fm.replace_fc,'Y', NVL(disb.disb_gross_amt, 0),0)), 0) resource_fm_f
      FROM igf_aw_awd_disb_all disb,
           igf_aw_award_all awd,
           igf_aw_fund_mast_all fm,
           igf_aw_fund_cat_all  fcat,
           igf_ap_fa_base_rec_all fa,
           igf_aw_awd_prd_term aprd,
           (SELECT   base_id,
                     ld_cal_type,
                     ld_sequence_number
                FROM igf_aw_coa_itm_terms
               WHERE base_id = p_base_id
            GROUP BY base_id, ld_cal_type, ld_sequence_number) coa
     WHERE awd.fund_id = fm.fund_id
       AND awd.award_id = disb.award_id
       AND fm.fund_code = fcat.fund_code
       AND awd.base_id = p_base_id
       AND disb.ld_cal_type = coa.ld_cal_type
       AND disb.ld_sequence_number = coa.ld_sequence_number
       AND awd.base_id = coa.base_id
       AND awd.base_id = fa.base_id
       AND fa.ci_cal_type = aprd.ci_cal_type
       AND fa.ci_sequence_number = aprd.ci_sequence_number
       AND disb.ld_cal_type = aprd.ld_cal_type
       AND disb.ld_sequence_number = aprd.ld_sequence_number
       AND aprd.award_prd_cd = p_awd_prd_code
       AND disb.trans_type <> 'C'
       AND awd.award_status IN('OFFERED','ACCEPTED')
       AND (
              (p_calc_for_subz_loan = 'Y' AND fcat.fed_fund_code NOT IN ('VA30','AMERICORPS')) OR
              (p_calc_for_subz_loan = 'N')
           );

    l_coa igf_aw_coa_items.amount%TYPE;

    ln_efc_f NUMBER;
    ln_efc_i NUMBER;
    ln_award_from_efc_meeting_need NUMBER;

    BEGIN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','Parameter List - START');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','p_base_id: ' ||p_base_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','p_awd_prd_code: ' ||p_awd_prd_code);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','p_calc_for_subz_loan: ' ||p_calc_for_subz_loan);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','Parameter List - END');
      END IF;

      IF p_awd_prd_code IS NULL THEN
        -- AP not available
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','Awarding Period NOT available. Considering all awards for the Student in the Awd Yr as resource');
        END IF;

        OPEN  resource_cur;
        FETCH resource_cur  INTO  resource_rec;
        CLOSE resource_cur;
      ELSE
        -- AP available
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','Awarding Period is available. Considering awards ONLY in Awarding Period ' ||p_awd_prd_code|| ' for the Student as resource');
        END IF;

        OPEN  resource_cur_awd;
        FETCH resource_cur_awd  INTO  resource_rec;
        CLOSE resource_cur_awd;
      END IF;

      l_coa := igf_aw_coa_gen.coa_amount(p_base_id,p_awd_prd_code);

      ln_efc_f := NVL(igf_aw_gen_004.efc_f(p_base_id,p_awd_prd_code),0);
      ln_efc_i := NVL(igf_aw_gen_004.efc_i(p_base_id,p_awd_prd_code),0);

      -- The p_resource_f will contain all the awards from FEDERAL, INSTITUTIONAL Methodology including the
      -- Sponsorships Funds.
      p_resource_f     := resource_rec.resource_f;

      p_resource_i     := resource_rec.resource_i;
      p_unmet_need_i   := NVL(l_coa,0) - ln_efc_i - NVL(p_resource_f,0);
      p_resource_i_fc  := NULL;

      -- If the replace efc awards are more than the Fed EFC then reduce the resource_fm_f to the FED EFC.
      IF NVL(resource_rec.resource_fm_f,0) > ln_efc_f THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','Reducing p_resource_f_fc to EFC, bcoz the Replace_FC awds got by the student is > EFC');
        END IF;

         p_resource_f_fc := ln_efc_f;
      ELSE
         p_resource_f_fc := resource_rec.resource_fm_f;
      END IF;
      -- Here the unmet need is adjusted with the replace FC funds.
      p_unmet_need_f := NVL(l_coa,0) - ln_efc_f - NVL(p_resource_f,0) + NVL(p_resource_f_fc,0);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','l_coa: ' ||l_coa);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','ln_efc_f: ' ||ln_efc_f|| ', ln_efc_i: ' ||ln_efc_i);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','p_resource_f: ' ||p_resource_f|| ', p_resource_i: ' ||p_resource_i);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','p_resource_f_fc: ' ||p_resource_f_fc|| ', p_resource_i_fc: ' ||p_resource_i_fc);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_gen_002.get_resource_need.debug','p_unmet_need_f: ' ||p_unmet_need_f|| ', p_unmet_need_i: ' ||p_unmet_need_i);
      END IF;

  END get_resource_need;

END igf_aw_gen_002;

/
