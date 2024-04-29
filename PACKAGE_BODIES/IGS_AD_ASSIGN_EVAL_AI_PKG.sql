--------------------------------------------------------
--  DDL for Package Body IGS_AD_ASSIGN_EVAL_AI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ASSIGN_EVAL_AI_PKG" AS
/* $Header: IGSADB4B.pls 120.3 2006/02/02 02:39:15 pfotedar ship $ */

PROCEDURE Assign_Eval_To_Appl_Inst(
	       Errbuf                   OUT NOCOPY VARCHAR2,
         Retcode                  OUT NOCOPY NUMBER,
         p_review_profile_id      IN  NUMBER DEFAULT NULL,
         p_review_group_code      IN  NUMBER DEFAULT NULL,
         p_unassigned_appl        IN  VARCHAR2 DEFAULT NULL,
         p_org_id                 IN  NUMBER
)
AS

 /*************************************************************
  Created By :nsinha
  Date : 20-NOV-2001
  Created By : Navin.Sinha
  Purpose : This Procedure Assigns Evaluators to Applications
            that have been assigned Review Groups with no Evaluator.
            This procedure is created as part of Enh# : 2097333.
  Know limitations, enhancements or remarks
  Change History
  Who             When              What
  rghosh       8-may-2003   Modified code so that the evaluation sequence assigned to each evaluator will be the same
                                               bug#2871426
  nsinha	19-May-03   Corrected the cursor parameter value while opening c_appl_rev_profile.
  ***************************************************************/

  INVALID_PARAMETER    EXCEPTION;

  l_rating_exists VARCHAR2(1);
  l_appl_revprof_revgr_id      igs_ad_apl_rprf_rgr.appl_revprof_revgr_id%TYPE;


  CURSOR c_common_no_eval(cp_review_profile_id  igs_ad_appl_arp.appl_rev_profile_id%TYPE,
                          cp_appl_revprof_revgr_id  igs_ad_appl_arp.appl_revprof_revgr_id%TYPE) IS
    SELECT apl.person_id,
           apl.admission_appl_number,
           apl.nominated_course_cd,
           apl.sequence_number,
      	   arp.appl_rev_profile_id,
      	   arp.appl_revprof_revgr_id
    FROM 	 igs_ad_ps_appl_inst_all apl,
           igs_ad_appl_arp arp
    WHERE  apl.person_id = arp.person_id
    AND    apl.admission_appl_number = arp.admission_appl_number
    AND    apl.nominated_course_cd = arp.nominated_course_cd
    AND 	 apl.sequence_number = arp.sequence_number
    AND    arp.appl_revprof_revgr_id IS NOT NULL
    AND EXISTS (SELECT '1'
                FROM   igs_ad_ou_stat ou
                WHERE  ou.s_adm_outcome_status = 'PENDING'
                AND    apl.adm_outcome_status = ou.adm_outcome_status )
    AND NOT EXISTS (SELECT  '1'
                    FROM igs_ad_appl_eval aev
                    WHERE aev.person_id = apl.person_id
                    AND aev.admission_appl_number =  apl.admission_appl_number
                    AND aev.nominated_course_cd = apl.nominated_course_cd
                    AND aev.sequence_number = apl.sequence_number );

    CURSOR c_common_no_eval_prf(cp_review_profile_id  igs_ad_appl_arp.appl_rev_profile_id%TYPE,
                          cp_appl_revprof_revgr_id  igs_ad_appl_arp.appl_revprof_revgr_id%TYPE) IS
    SELECT apl.person_id,
           apl.admission_appl_number,
           apl.nominated_course_cd,
           apl.sequence_number,
      	   arp.appl_rev_profile_id,
      	   arp.appl_revprof_revgr_id
    FROM 	 igs_ad_ps_appl_inst_all apl,
           igs_ad_appl_arp arp
    WHERE  apl.person_id = arp.person_id
    AND    apl.admission_appl_number = arp.admission_appl_number
    AND    apl.nominated_course_cd = arp.nominated_course_cd
    AND 	 apl.sequence_number = arp.sequence_number
    AND    arp.appl_revprof_revgr_id IS NOT NULL
    AND EXISTS (SELECT '1'
                FROM   igs_ad_ou_stat ou
                WHERE  ou.s_adm_outcome_status = 'PENDING'
                AND    apl.adm_outcome_status = ou.adm_outcome_status )
    AND NOT EXISTS (SELECT  '1'
                    FROM igs_ad_appl_eval aev
                    WHERE aev.person_id = apl.person_id
                    AND aev.admission_appl_number =  apl.admission_appl_number
                    AND aev.nominated_course_cd = apl.nominated_course_cd
                    AND aev.sequence_number = apl.sequence_number )
    AND    arp.appl_rev_profile_id = cp_review_profile_id;

    CURSOR c_common_no_eval_grp(cp_review_profile_id  igs_ad_appl_arp.appl_rev_profile_id%TYPE,
                          cp_appl_revprof_revgr_id  igs_ad_appl_arp.appl_revprof_revgr_id%TYPE) IS
    SELECT apl.person_id,
           apl.admission_appl_number,
           apl.nominated_course_cd,
           apl.sequence_number,
      	   arp.appl_rev_profile_id,
      	   arp.appl_revprof_revgr_id
    FROM 	 igs_ad_ps_appl_inst_all apl,
           igs_ad_appl_arp arp
    WHERE  apl.person_id = arp.person_id
    AND    apl.admission_appl_number = arp.admission_appl_number
    AND    apl.nominated_course_cd = arp.nominated_course_cd
    AND 	 apl.sequence_number = arp.sequence_number
    AND    arp.appl_revprof_revgr_id IS NOT NULL
    AND EXISTS (SELECT '1'
                FROM   igs_ad_ou_stat ou
                WHERE  ou.s_adm_outcome_status = 'PENDING'
                AND    apl.adm_outcome_status = ou.adm_outcome_status )
    AND NOT EXISTS (SELECT  '1'
                    FROM igs_ad_appl_eval aev
                    WHERE aev.person_id = apl.person_id
                    AND aev.admission_appl_number =  apl.admission_appl_number
                    AND aev.nominated_course_cd = apl.nominated_course_cd
                    AND aev.sequence_number = apl.sequence_number )
    AND    arp.appl_revprof_revgr_id = cp_appl_revprof_revgr_id;

  l_common_no_eval_rec     c_common_no_eval%ROWTYPE;
  l_common_no_eval_prf_rec c_common_no_eval_prf%ROWTYPE;
  l_common_no_eval_grp_rec c_common_no_eval_grp%ROWTYPE;


  CURSOR c_appl_rev_profile (cp_appl_rev_profile_id igs_ad_apl_rev_prf.appl_rev_profile_id%TYPE) IS
    SELECT review_profile_name
    FROM igs_ad_apl_rev_prf
    WHERE appl_rev_profile_id = cp_appl_rev_profile_id;

  l_review_profile_name igs_ad_apl_rev_prf.review_profile_name%TYPE;

  CURSOR c_appl_rev_group (cp_review_group_code igs_ad_apl_rprf_rgr.revprof_revgr_cd%TYPE) IS
    SELECT revprof_revgr_cd
    FROM igs_ad_apl_rprf_rgr
    WHERE appl_revprof_revgr_id = cp_review_group_code;

  l_review_group_code igs_ad_apl_rprf_rgr.revprof_revgr_cd%TYPE;

  l_unassigned_appl VARCHAR2(3);

BEGIN

  IGS_GE_GEN_003.Set_org_id(p_org_id);

  OPEN c_appl_rev_profile(p_review_profile_id);
  FETCH c_appl_rev_profile INTO l_review_profile_name;
  CLOSE c_appl_rev_profile;

  OPEN c_appl_rev_group(p_review_group_code);
  FETCH c_appl_rev_group INTO l_review_group_code;
  CLOSE c_appl_rev_group;

  IF p_unassigned_appl = '1' THEN l_unassigned_appl := 'YES';
  ELSIF p_unassigned_appl = '2' THEN l_unassigned_appl := 'NO';
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'Review Profile Name          :' || l_review_profile_name);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Review Group Code            :' || l_review_group_code);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'All Unassigned Applications  :' || l_unassigned_appl);

  IF p_review_profile_id IS NULL AND
     p_review_group_code IS NULL AND
     p_unassigned_appl IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_FI_SELECT_COMBN_NORECORDS');
       FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
       RAISE INVALID_PARAMETER;
  END IF;

  IF p_review_profile_id IS NOT NULL AND
     p_review_group_code IS NOT NULL AND
     p_unassigned_appl = '1' THEN -- p_unassigned_appl is passed as 'Y' interpreted as '1'
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_PROCESS_PARAM');
       FND_MESSAGE.SET_TOKEN('PARAM_NAME',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ALL_UNASGN_APL'));
       FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

  ELSIF p_review_profile_id IS NOT NULL AND
        p_review_group_code IS NOT NULL AND
        NVL(p_unassigned_appl,'0') <> '1' THEN -- p_unassigned_appl is passed as 'Y' interpreted as '1'
          FND_MESSAGE.SET_NAME('IGS','IGS_AD_PROCESS_PARAM');
          FND_MESSAGE.SET_TOKEN('PARAM_NAME',FND_MESSAGE.GET_STRING('IGS','IGS_AD_REV_PROF_NAME'));
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

  ELSIF p_review_profile_id IS NULL AND
        p_review_group_code IS NOT NULL AND
        NVL(p_unassigned_appl,'0') <> '1' THEN -- p_unassigned_appl is passed as 'Y' interpreted as '1'
          FND_MESSAGE.SET_NAME('IGS','IGS_AD_PROCESS_PARAM');
          FND_MESSAGE.SET_TOKEN('PARAM_NAME',FND_MESSAGE.GET_STRING('IGS','IGS_AD_REV_GR_CD'));
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
  END IF;


  -- Initialize l_appl_revprof_revgr_id based on wether user has provided the
  -- value for Review Group Code or Review Group Name.

  IF p_review_profile_id IS NULL AND p_review_group_code IS NOT NULL THEN
    l_appl_revprof_revgr_id := p_review_group_code;
  END IF;

  Retcode := 0;

  IF p_unassigned_appl = '1' THEN -- p_unassigned_appl is passed as 'Y'

    FOR  l_common_no_eval_rec IN c_common_no_eval(NULL,NULL)
    LOOP
      -- Loop through all the Application Instances for which there has been a
      -- Review Group Code assigned but no evaluators have been assigned.

      Assign_Eval_To_Ai(
        Errbuf,
        Retcode,
        l_common_no_eval_rec.appl_rev_profile_id,
        l_common_no_eval_rec.appl_revprof_revgr_id,
        l_common_no_eval_rec.person_id,
        l_common_no_eval_rec.admission_appl_number,
        l_common_no_eval_rec.nominated_course_cd,
        l_common_no_eval_rec.sequence_number);

    END LOOP;

  ELSIF p_review_profile_id IS NOT NULL THEN      -- 2.  Else If p_REVIEW_PROFILE_NAME is NOT NULL

    FOR l_common_no_eval_prf_rec IN c_common_no_eval_prf(p_review_profile_id,NULL)
    LOOP
      -- Loop through all the Application Instances where Review_Profile_Id is same
      -- as the parameter passed and for which there has been a Review Group Code
      -- assigned but no evaluators have been assigned.

      Assign_Eval_To_Ai(
        Errbuf,
        Retcode,
        l_common_no_eval_prf_rec.appl_rev_profile_id,
        l_common_no_eval_prf_rec.appl_revprof_revgr_id,
        l_common_no_eval_prf_rec.person_id,
        l_common_no_eval_prf_rec.admission_appl_number,
        l_common_no_eval_prf_rec.nominated_course_cd,
        l_common_no_eval_prf_rec.sequence_number);

    END LOOP;

  ELSIF l_appl_revprof_revgr_id IS NOT NULL THEN      -- 3.  Else If P_REVIEW_GROUP_CODE IS NOT NULL

    FOR l_common_no_eval_grp_rec IN c_common_no_eval_grp(NULL,l_appl_revprof_revgr_id)
    LOOP
      -- Loop through all the Application Instances where Review_Group_Code is same
      -- as the parameter passed and for which there has been no evaluator assigned.
      Assign_Eval_To_Ai(
	       Errbuf,
         Retcode,
         l_common_no_eval_grp_rec.appl_rev_profile_id,
         l_appl_revprof_revgr_id,
         l_common_no_eval_grp_rec.person_id,
         l_common_no_eval_grp_rec.admission_appl_number,
         l_common_no_eval_grp_rec.nominated_course_cd,
         l_common_no_eval_grp_rec.sequence_number);
    END LOOP;

  END IF;

EXCEPTION
  WHEN INVALID_PARAMETER  THEN
    Retcode := 2;

  WHEN OTHERS THEN
    IF c_common_no_eval%ISOPEN THEN
      CLOSE c_common_no_eval;
    END IF;
    IF c_common_no_eval_prf%ISOPEN THEN
      CLOSE c_common_no_eval_prf;
    END IF;
    IF c_common_no_eval_grp%ISOPEN THEN
      CLOSE c_common_no_eval_grp;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,sqlerrm(sqlcode));
    Retcode := 2;
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','Assign_Eval_To_Appl_Inst');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    Igs_Ge_Msg_Stack.conc_exception_hndl;

END Assign_Eval_To_Appl_Inst;


PROCEDURE Assign_Eval_To_Ai(
	       Errbuf                   OUT NOCOPY VARCHAR2,
         Retcode                  OUT NOCOPY NUMBER,
         p_appl_rev_profile_id    IN  NUMBER,
         p_appl_revprof_revgr_id  IN  NUMBER,
         p_person_id              IN  NUMBER,
         p_admission_appl_number  IN  NUMBER,
         p_nominated_course_cd    IN  VARCHAR2,
         p_sequence_number        IN  NUMBER
)
AS

 /*************************************************************
  Created By :nsinha
  Date : 20-NOV-2001
  Created By : Navin.Sinha
  Purpose : API to assign the Evaluators of the p_appl_revprof_revgr_id
            Review Group Code to the Application Instance.
            This procedure is created as part of Enh# : 2097333.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
    rghosh       8-may-2003   Modified code so that the evaluation sequence assigned to each evaluator will be the same
                                               bug#2871426
  ***************************************************************/

  invalid_parameter    EXCEPTION;

  -- Select all the Evaluators assigned for this Review Profile Code
  CURSOR c_appl_rev_prof_evaluator(cp_appl_revprof_revgr_id NUMBER) IS
    SELECT   person_id,
             person_number,
  	         evaluation_sequence
    FROM     igs_ad_rvgr_evaltr ev
    WHERE    appl_revprof_revgr_id  = cp_appl_revprof_revgr_id
    ORDER BY evaluation_sequence;

  l_appl_rev_prof_evaluator_rec c_appl_rev_prof_evaluator%ROWTYPE;

  CURSOR c_seq_conc_ind (cp_appl_rev_profile_id igs_ad_apl_rev_prf_all.APPL_REV_PROFILE_ID%TYPE) IS
    SELECT  sequential_concurrent_ind
    FROM  igs_ad_apl_rev_prf_all
    WHERE APPL_REV_PROFILE_ID = cp_appl_rev_profile_id;

  l_seq_conc_ind igs_ad_apl_rev_prf_all.sequential_concurrent_ind%TYPE;

  CURSOR c_arp_rate_scale(cp_appl_rev_profile_id number) IS
  SELECT *
  FROM   igs_ad_apl_rvpf_rsl arr
  WHERE  arr.appl_rev_profile_id = cp_appl_rev_profile_id;

  arp_rate_scale_rec c_arp_rate_scale%ROWTYPE;

  CURSOR c_igs_ad_appl_eval_s
  IS
  SELECT Igs_ad_appl_eval_s.nextval
  FROM DUAL;

  -- Cursor fetching the review_profile_name for the corresponding review profile id (rghosh bug#2871426)
  CURSOR c_appl_rev_profile (cp_appl_rev_profile_id igs_ad_apl_rev_prf.appl_rev_profile_id%TYPE) IS
    SELECT review_profile_name
    FROM igs_ad_apl_rev_prf
    WHERE appl_rev_profile_id = cp_appl_rev_profile_id;

  l_review_profile_name igs_ad_apl_rev_prf.review_profile_name%TYPE;


  -- Cursor to get the existing evaluators (rghosh bug #2986802)
  CURSOR c_existing_evaluators (cp_person_id igs_ad_appl_eval.person_id%TYPE,
                                cp_admission_appl_number igs_ad_appl_eval.admission_appl_number%TYPE,
			                          cp_nominated_course_cd igs_ad_appl_eval.nominated_course_cd%TYPE,
			                          cp_sequence_number igs_ad_appl_eval.sequence_number%TYPE ) IS
    SELECT *
    FROM igs_ad_appl_eval_v
    WHERE person_id = cp_person_id
    AND admission_appl_number = cp_admission_appl_number
    AND nominated_course_cd = cp_nominated_course_cd
    AND sequence_number = cp_sequence_number;

  l_existing_evaluators_rec c_existing_evaluators%ROWTYPE;

  -- Cursor to fetch the next evaluation sequence that is available for that particular application instance (rghosh bug #2986802)
  CURSOR c_max_evaluation_sequence(cp_person_id igs_ad_appl_eval.person_id%TYPE,
                                   cp_admission_appl_number igs_ad_appl_eval.admission_appl_number%TYPE,
		                     	         cp_nominated_course_cd igs_ad_appl_eval.nominated_course_cd%TYPE,
                     			         cp_sequence_number igs_ad_appl_eval.sequence_number%TYPE) IS
    SELECT (max(evaluation_sequence))
    FROM igs_ad_appl_eval
    WHERE person_id = cp_person_id
    AND admission_appl_number = cp_admission_appl_number
    AND nominated_course_cd = cp_nominated_course_cd
    AND sequence_number = cp_sequence_number;

  l_max_evaluation_sequence NUMBER;

  TYPE l_evalexist_record IS RECORD (
        person_number igs_ad_rvgr_evaltr.person_number%TYPE,
        evaluation_sequence igs_ad_rvgr_evaltr.evaluation_sequence%TYPE);

  TYPE l_evalexist_table IS TABLE OF l_evalexist_record INDEX BY BINARY_INTEGER;

  l_eval_exists l_evalexist_table;

  x NUMBER := 0;

  TYPE revgrp_list IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  my_revgrp_list revgrp_list;

  l_rating_exists VARCHAR2(1);
  l_evaluators_exists VARCHAR2(1);
  l_matching_ind VARCHAR2(1);

  lv_rowid                     VARCHAR2(25);
  l_igs_ad_appl_eval_s         NUMBER;
  l_sequence_number            NUMBER:= 0;
  i                            NUMBER:= 0;
  l_exists VARCHAR2(1);
  l_list_count BINARY_INTEGER := 0 ;
  j BINARY_INTEGER := 0;
  k BINARY_INTEGER := 0;

  l_person_id NUMBER;
  l_person_name VARCHAR2(320);
  l_full_name VARCHAR2(1000);
  l_display_name VARCHAR2(360);


BEGIN

  l_exists := 'N' ;

  IF p_appl_rev_profile_id IS NULL OR
     p_appl_revprof_revgr_id IS NULL OR
     p_person_id IS NULL OR
     p_admission_appl_number IS NULL OR
     p_nominated_course_cd IS NULL OR
     p_sequence_number IS NULL
     THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_COMBI_OF_PARAMS');
       FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
       RAISE INVALID_PARAMETER;
  END IF;

  Retcode := 0;

  OPEN c_seq_conc_ind(p_appl_rev_profile_id);
  FETCH c_seq_conc_ind INTO l_seq_conc_ind;
  CLOSE c_seq_conc_ind;

  l_rating_exists := 'N';

  l_evaluators_exists := 'N';

  IF l_seq_conc_ind = 'S' THEN -- Sequential Evaluation.

    FOR l_existing_evaluators_rec IN c_existing_evaluators (p_person_id,p_admission_appl_number,p_nominated_course_cd,p_sequence_number)
    LOOP
      l_eval_exists(x).person_number := l_existing_evaluators_rec.person_number;
      l_eval_exists(x).evaluation_sequence := l_existing_evaluators_rec.evaluation_sequence;
      l_evaluators_exists := 'Y';
      x := x+1;
    END LOOP;
  END IF;

    FOR l_appl_rev_prof_evaluator_rec IN c_appl_rev_prof_evaluator(p_appl_revprof_revgr_id)
    LOOP

      IF l_seq_conc_ind = 'S' THEN -- Sequential Evaluation.

        l_matching_ind := 'N';

        IF l_evaluators_exists = 'Y' THEN
        FOR y IN 0..(l_eval_exists.count-1)
        LOOP
          IF l_appl_rev_prof_evaluator_rec.person_number = l_eval_exists(y).person_number THEN
            l_sequence_number := l_eval_exists(y).evaluation_sequence;
            l_matching_ind := 'Y';
            EXIT;
          END IF;
        END LOOP;
        END IF;

        IF l_evaluators_exists = 'Y' AND l_matching_ind = 'N' THEN
          OPEN c_max_evaluation_sequence(p_person_id,p_admission_appl_number,p_nominated_course_cd,p_sequence_number);
          FETCH c_max_evaluation_sequence INTO l_max_evaluation_sequence;
          CLOSE c_max_evaluation_sequence;
          l_sequence_number := l_max_evaluation_sequence + 1;
        ELSIF l_evaluators_exists = 'N' THEN
          l_sequence_number := l_sequence_number + 1;
        END IF;

      ELSE  -- Concurrent Evaluation.
        l_sequence_number := 1;
      END IF;

      OPEN c_arp_rate_scale(p_appl_rev_profile_id);
      LOOP   -- Loop through all the Rating Scales of that Application Review Profile.
        FETCH c_arp_rate_scale INTO arp_rate_scale_rec;
        EXIT WHEN c_arp_rate_scale%NOTFOUND;

        -- Get the next sequence value for table igs_ad_appl_eval.
        OPEN  c_igs_ad_appl_eval_s;
        FETCH c_igs_ad_appl_eval_s INTO l_igs_ad_appl_eval_s;
        CLOSE c_igs_ad_appl_eval_s;
        l_rating_exists := 'Y';
        Igs_ad_appl_eval_pkg.insert_row(
          x_rowid => lv_rowid,
          x_appl_eval_id => l_igs_ad_appl_eval_s,
          x_person_id => p_person_id,
          x_admission_appl_number => p_admission_appl_number,
          x_nominated_course_cd => p_nominated_course_cd,
          x_sequence_number=> p_sequence_number,
          x_evaluator_id => l_appl_rev_prof_evaluator_rec.person_id,
          x_assign_type => 'M',
          x_assign_date => SYSDATE,
          x_evaluation_date => NULL,
          x_rating_type_id => arp_rate_scale_rec.rating_type_id,
          x_rating_values_id => NULL,
          x_rating_notes => NULL,
	        x_evaluation_sequence => l_sequence_number,
          x_rating_scale_id => arp_rate_scale_rec.rating_scale_id,
	        x_closed_ind => 'N'
	      );

        /*********** New Feature ****** For Sending notification to Evaluators: bug 2864696 *************/

--              fnd_file.put_line(fnd_file.log,'Value of seq ind is '|| l_seq_conc_ind);

                IF l_seq_conc_ind = 'S'  and l_sequence_number = 1 THEN

                        IF my_revgrp_list.count = 0 THEN
                                my_revgrp_list(0) := l_appl_rev_prof_evaluator_rec.person_id;
                        END IF;

                ELSIF l_seq_conc_ind = 'C' THEN

                        l_exists := 'N';

                        FOR j IN 0..(my_revgrp_list.COUNT-1)
                        LOOP
                        IF my_revgrp_list(j) = l_appl_rev_prof_evaluator_rec.person_id THEN
--                              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Record already present in table');
                                l_exists := 'Y';
                                EXIT;
                        END IF;
                        END LOOP;

                        IF l_exists = 'N' THEN
                            my_revgrp_list(my_revgrp_list.COUNT) := l_appl_rev_prof_evaluator_rec.person_id;
                        END IF;

                END IF;
	/*****************************************/

      END LOOP;   -- End of looping through all the Rating Scales of that Application Review Profile.
      CLOSE c_arp_rate_scale;

      OPEN c_appl_rev_profile(p_appl_rev_profile_id);
      FETCH c_appl_rev_profile INTO l_review_profile_name;
      CLOSE c_appl_rev_profile;

      IF l_rating_exists = 'N' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_MISS_RS_SETUP');
        FND_MESSAGE.SET_TOKEN ('REVIEW_PROFILE', l_review_profile_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
	      EXIT;
      END IF;

    END LOOP;   -- End of looping through all the evaluators of that Review Profile Group.

      /**************************************/
       FOR k IN 0..(my_revgrp_list.COUNT-1)

        LOOP
        l_person_id := NVL(my_revgrp_list(k),0);

--      FND_FILE.PUT_LINE (FND_FILE.LOG, 'eval is '|| l_person_id );

        Wf_Directory.GetRoleName('HZ_PARTY', l_person_id, l_person_name, l_full_name);

               IF l_person_name IS NOT NULL THEN

            /* Evaluators are being printed without any application context information.
               Hence commenting out the following as part of fix for bug# 3224891

               FND_FILE.PUT_LINE (FND_FILE.LOG, '');
               FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
               FND_MESSAGE.SET_TOKEN ('PNAME', l_full_name);
               FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());  */

               Wf_Inform_Evaluator_Appl (l_person_id, l_person_name, l_full_name);

            /* Evaluators are being printed without any application context information.
               Hence commenting out the following as part of fix for bug# 3224891

              ELSE
               FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF4');
               FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET()); */

               END IF ; -- l_person_name
        END LOOP;
	/**************************************/

EXCEPTION
  WHEN INVALID_PARAMETER  THEN
    Retcode := 2;
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,sqlerrm(sqlcode));
    Retcode := 2;
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','Assign_Eval_To_Ai');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    Igs_Ge_Msg_Stack.add;

END Assign_Eval_To_Ai;



PROCEDURE  Wf_Inform_Evaluator_Appl
                       (  p_evaluator_id       	IN   NUMBER,
			  p_evaluator_name     	IN   VARCHAR2,
			  p_evaluator_full_name	IN   VARCHAR2
                        )
IS

    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    l_incomplt_appl_url   varchar2(1000);


     CURSOR cur_seq IS
         SELECT IGS_AD_WF_EVAL_S.NEXTVAL
         FROM dual;


BEGIN

         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);

         OPEN cur_seq ;
         FETCH cur_seq INTO l_itemKey ;
         CLOSE cur_seq ;


	 wf_event.AddParameterToList ( 	p_Name => 'IA_PERSON_ID',
					p_Value => p_evaluator_id,
					p_parameterlist=>l_parameter_list_t);
 	wf_event.AddParameterToList ( 	p_Name => 'IA_PERSON_NAME',
					p_Value => p_evaluator_name,
					p_parameterlist=>l_parameter_list_t);
 	wf_event.AddParameterToList ( 	p_Name => 'IA_PERSON_FULL_NAME',
					p_Value => p_evaluator_full_name,
					p_parameterlist=>l_parameter_list_t);
--
-- raise the event
--
	WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.ad.appl.eval_appl',
       		         p_event_key  => l_itemKey,
               		 p_parameters => l_parameter_list_t);

 	l_parameter_list_t.delete;
EXCEPTION
	WHEN OTHERS THEN
       		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END Wf_Inform_Evaluator_Appl;

/*************************************/

Function Calc_Ratstat(
	p_person_id IN igs_ad_ps_appl_inst_all.person_id%TYPE,
	p_admission_appl_number IN igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
	p_nominated_course_cd IN igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
	p_sequence_number IN igs_ad_ps_appl_inst_all.sequence_number%TYPE,
	p_faculty_id IN igs_ad_appl_eval.evaluator_id%TYPE,
	p_roletype IN  VARCHAR2,
	p_eval_type IN VARCHAR2,
	p_eval_seq_number IN NUMBER)
RETURN VARCHAR2 IS

l_no_of_evaluators NUMBER := 0;
l_count		   NUMBER := 0;
l_prev_count	   NUMBER := 0;
l_prev_seq_number NUMBER := 0;

BEGIN

IF p_roletype = 'ADMIN' THEN

	Select count(rowid)
	Into l_no_of_evaluators
	From igs_ad_appl_eval
	Where person_id = p_person_id
	And Admission_appl_number = p_admission_appl_number
	And Nominated_course_cd = p_nominated_course_cd
	And sequence_number = p_sequence_number;

	Select count(rowid)
	Into l_count
	From igs_ad_appl_eval
	Where person_id = p_person_id
	And Admission_appl_number = p_admission_appl_number
	And Nominated_course_cd = p_nominated_course_cd
	And sequence_number = p_sequence_number
	And rating_type_id is not null
	And rating_values_id is not null
	And evaluation_date is not null
	And rating_scale_id is not null;

 	IF l_count = l_no_of_evaluators AND l_count <> 0 THEN
		RETURN 'R';

        ELSIF l_count = l_no_of_evaluators and l_count = 0 THEN
		RETURN 'U';

	ELSE
		RETURN 'N';

	END IF;

ELSIF p_roletype = 'FACULTY' THEN

	Select count(rowid)
	Into l_no_of_evaluators
	From igs_ad_appl_eval
	Where person_id = p_person_id
	And Admission_appl_number = p_admission_appl_number
	And Nominated_course_cd = p_nominated_course_cd
	And sequence_number = p_sequence_number
	AND EVALUATOR_ID = p_faculty_id;

	Select count(rowid)
	Into l_count
	From igs_ad_appl_eval
	Where person_id = p_person_id
	And Admission_appl_number = p_admission_appl_number
	And Nominated_course_cd = p_nominated_course_cd
	And sequence_number = p_sequence_number
	And rating_type_id is not null
	And rating_values_id is not null
	And evaluation_date is not null
	And rating_scale_id is not null
	And evaluator_id = p_faculty_id;

	l_prev_seq_number := igs_ad_appl_eval_pkg.find_prev_seq_number(p_person_id,
									p_admission_appl_number,
									p_nominated_course_cd,
									p_sequence_number,
									p_eval_seq_number);
	Select count(rowid)
	Into l_prev_count
	From igs_ad_appl_eval
	Where person_id = p_person_id
	And Admission_appl_number = p_admission_appl_number
	And Nominated_course_cd = p_nominated_course_cd
	And sequence_number = p_sequence_number
	And evaluation_sequence = l_prev_seq_number
	And rating_values_id is  null
	And evaluation_date is null;

	IF p_eval_type = 'S' THEN

     		IF l_no_of_evaluators = 0 THEN
  	  	RETURN 'U';

     		ELSIF l_count = l_no_of_evaluators and l_count <> 0 then
	  	RETURN 'R';

     		ELSIF l_prev_count <>  0 and p_eval_seq_number <> 1 Then
	  	RETURN 'D';

     		ELSE
	 	RETURN 'N';

     		END IF;

	ELSIF (p_eval_type = 'C' OR p_eval_type IS NULL) THEN
		IF l_no_of_evaluators = 0 THEN
  		  RETURN 'U';

    		ELSIF l_count = l_no_of_evaluators and l_count <> 0 then
		RETURN 'R';

    		ELSE
		RETURN 'N';

    		END IF;

	END IF;

END IF;

EXCEPTION
     WHEN OTHERS THEN
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END Calc_Ratstat;

--------------------------------
  FUNCTION rule_function (p_subscription in RAW,
                          p_event        in out NOCOPY WF_EVENT_T) return varchar2 is
 l_rule                  VARCHAR2(20);
 l_parameter_list        wf_parameter_list_t;
 l_parameter_t           wf_parameter_t;
 i_parameter_name        l_parameter_t.name%type;
 i_parameter_value       l_parameter_t.value%type;
 i                       pls_integer;


 BEGIN

    l_parameter_list        := wf_parameter_list_t();
    l_parameter_t           := wf_parameter_t(null, null);

    l_parameter_list := p_event.getParameterList();
        if l_parameter_list is not null
        then
                i := l_parameter_list.FIRST;
                while ( i <= l_parameter_list.LAST )
                loop
                        i_parameter_name := null;
                        i_parameter_value := null;

                        i_parameter_name := l_parameter_list(i).getName();
                        i_parameter_value := l_parameter_list(i).getValue();

                        i := l_parameter_list.NEXT(i);
                end loop;

          end if;


         l_rule :=  wf_rule.default_rule(p_subscription,p_event);

   return ('SUCCESS');

 END rule_function;


/************************/

-- this procedure will set the package variable g_dns_ind according to the value of the checkbox do not send notification in ratings forms(IGSAD090)
-- rghosh (bug # 2871426 - Evaluator entry and assignment
PROCEDURE set_dns_ind (x_do_not_send_notif IN VARCHAR2) IS
  BEGIN
    IF NVL(x_do_not_send_notif,'N') = 'N' THEN
      igs_ad_appl_eval_pkg.g_dns_ind := 'N';
    ELSE
      igs_ad_appl_eval_pkg.g_dns_ind := 'Y';
    END IF;
  END set_dns_ind;

--this function will return the value of the next sequence number that has to be assigned to new evaluator who is added manually
-- rghosh (bug#2871426 - Evaluator entry and assignment)
FUNCTION set_eval_sequence (p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                                                            p_admission_appl_number  igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
                                                            p_nominated_course_cd   igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
                                                            p_sequence_number   igs_ad_ps_appl_inst_all.sequence_number%TYPE,
							    p_evaluator_id igs_ad_appl_eval.evaluator_id%TYPE,
							    p_rating_type_id igs_ad_appl_eval.rating_type_id%TYPE,
							    p_rating_scale_id igs_ad_appl_eval.rating_scale_id%TYPE ) RETURN NUMBER IS

CURSOR eval_type_cur( cp_person_id    igs_ad_appl_arp.person_id%TYPE,
                                              cp_admission_appl_number  igs_ad_appl_arp.admission_appl_number%TYPE,
                                              cp_nominated_course_cd   igs_ad_appl_arp.nominated_course_cd%TYPE,
                                              cp_sequence_number   igs_ad_appl_arp.sequence_number%TYPE) IS
        SELECT
                distinct sequential_concurrent_ind
        FROM
                igs_ad_apl_rev_prf_all
        WHERE
                appl_rev_profile_id = (select appl_rev_profile_id
		                                         from igs_ad_appl_arp
							 where person_id = cp_person_id
							 and admission_appl_number = cp_admission_appl_number
							 and nominated_course_cd = cp_nominated_course_cd
							 and sequence_number = cp_sequence_number);

  CURSOR c_max_evaluation_sequence(
    cp_person_id    igs_ad_appl_eval.person_id%TYPE,
    cp_adm_apl_num  igs_ad_appl_eval.admission_appl_number%TYPE,
    cp_nom_crs_cd   igs_ad_appl_eval.nominated_course_cd%TYPE,
    cp_seq_number   igs_ad_appl_eval.sequence_number%TYPE) IS
        SELECT
                (max(evaluation_sequence)+1)
        FROM
                igs_ad_appl_eval
        WHERE
                person_id = cp_person_id AND
                admission_appl_number = cp_adm_apl_num AND
                nominated_course_cd = cp_nom_crs_cd AND
                sequence_number = cp_seq_number;

  CURSOR c_next_seq (
    cp_person_id    igs_ad_appl_eval.person_id%TYPE,
    cp_adm_apl_num  igs_ad_appl_eval.admission_appl_number%TYPE,
    cp_nom_crs_cd   igs_ad_appl_eval.nominated_course_cd%TYPE,
    cp_seq_number   igs_ad_appl_eval.sequence_number%TYPE,
    cp_evaluator_id igs_ad_appl_eval.evaluator_id%TYPE) IS
      SELECT *
      FROM igs_ad_appl_eval
      WHERE person_id = cp_person_id
      AND admission_appl_number = cp_adm_apl_num
      AND nominated_course_cd = cp_nom_crs_cd
      AND sequence_number = cp_seq_number
      AND evaluator_id = cp_evaluator_id;

    l_next_seq c_next_seq%ROWTYPE;
    l_exist_eval_type igs_ad_apl_rev_prf_all.sequential_concurrent_ind%TYPE;
    l_exist_arp_id    igs_ad_appl_arp_v.appl_rev_profile_id%TYPE;
    l_count   igs_ad_appl_eval.evaluation_sequence%TYPE;
    l_max_evaluation_sequence  igs_ad_appl_eval.evaluation_sequence%TYPE;
    l_chk_rating_val_null VARCHAR2(1);

  BEGIN
    OPEN eval_type_cur(p_person_id,p_admission_appl_number,p_nominated_course_cd,p_sequence_number);
    FETCH eval_type_cur INTO l_exist_eval_type;
    CLOSE eval_type_cur;
    l_chk_rating_val_null := 'N' ;

    IF l_exist_eval_type = 'S' THEN
      OPEN c_max_evaluation_sequence(p_person_id,p_admission_appl_number,p_nominated_course_cd,p_sequence_number);
      FETCH c_max_evaluation_sequence into l_max_evaluation_sequence;
      CLOSE c_max_evaluation_sequence;

      FOR l_next_seq IN c_next_seq(p_person_id,p_admission_appl_number,p_nominated_course_cd,p_sequence_number,
                                                                p_evaluator_id)       LOOP
	IF l_next_seq.rating_values_id IS NULL AND NVL(l_next_seq.closed_ind,'N') = 'N' THEN
	  IF (p_rating_type_id = l_next_seq.rating_type_id AND p_rating_scale_id = l_next_seq.rating_scale_id ) THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_AD_MAND_RATING');
            IGS_GE_MSG_STACK.ADD;
 	    APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
	  l_chk_rating_val_null := 'Y' ;
	  l_count := l_next_seq.evaluation_sequence;
	  EXIT;
        END IF;
        IF l_next_seq.rating_values_id IS NOT NULL AND NVL(l_next_seq.closed_ind,'N') = 'N' THEN
	  IF (p_rating_type_id = l_next_seq.rating_type_id AND p_rating_scale_id = l_next_seq.rating_scale_id ) THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACT_EVL_RT_RS');
            IGS_GE_MSG_STACK.ADD;
 	    APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
        END IF;
      END LOOP;
      IF l_chk_rating_val_null = 'N' THEN
        IF l_max_evaluation_sequence IS NOT NULL THEN
	 l_count := l_max_evaluation_sequence;
        ELSE
	  l_count := 1;
        END IF;
      END IF;

    ELSIF l_exist_eval_type = 'C' THEN
     l_count:=1;

     fnd_message.set_name('IGS','IGS_AD_NO_WF_NOTIF');
     IGS_GE_MSG_STACK.ADD;

    ELSE
     l_count:=1;
    END IF;
RETURN l_count;
END set_eval_sequence;

END igs_ad_assign_eval_ai_pkg;

/
