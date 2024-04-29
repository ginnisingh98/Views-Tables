--------------------------------------------------------
--  DDL for Package Body PQH_FR_SPEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_SPEED" AS
/* $Header: pqchgspd.pkb 120.2 2005/06/09 16:58:22 deenath noship $ */
  --
  --Package Variables
    g_package  VARCHAR2(33) := 'PQH_FR_SPEED.';
  --
  ------------------------------------------------------------------------------
  ----------------------------< get_increased_index >---------------------------
  ------------------------------------------------------------------------------
  FUNCTION get_increased_index(p_comments       IN VARCHAR2
                              ,p_gross_index    IN NUMBER
                              ,p_effective_date IN DATE) RETURN NUMBER IS
  --
  --Cursor to fetch Increased Index
    CURSOR csr_increased_index IS
    SELECT increased_index
      FROM pqh_fr_global_indices_f
     WHERE gross_index    = p_gross_index
       AND type_of_record = 'IND' -- for indices
       AND p_effective_date BETWEEN effective_start_date and effective_end_date;
  --
  --Variable Declarations.
    l_increased_index PQH_FR_GLOBAL_INDICES_F.increased_index%TYPE;
    l_proc            VARCHAR2(72) := g_package||'get_increased_index';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    OPEN csr_increased_index;
    FETCH csr_increased_index INTO l_increased_index;
    CLOSE csr_increased_index;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
    RETURN l_increased_index;
  --
  END get_increased_index;
  --
  ------------------------------------------------------------------------------
  --------------------------------< chk_notify >--------------------------------
  ------------------------------------------------------------------------------
  FUNCTION chk_notify(p_ben_pgm_id     NUMBER
                     ,p_mgr_id         NUMBER
                     ,p_review_date    DATE
                     ,p_effective_date DATE) RETURN VARCHAR2 IS
  --
  --Cursor to fetch Review Length for the Corps from Extra Info
    CURSOR csr_review_length IS
    SELECT TO_NUMBER(pgi_information3)
      FROM ben_pgm_extra_info
     WHERE information_type = 'PQH_FR_CORP_INFO'
       AND pgm_id           = p_ben_pgm_id;
  --
  --Variable Declarations.
    l_review_length NUMBER;
    l_notify        VARCHAR2(01);
    l_proc          VARCHAR2(72) := g_package||'chk_notify';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    l_notify := NULL;
  --
    IF p_mgr_id IS NULL THEN
       l_notify := 'N';
    ELSIF p_review_date IS NULL THEN
       l_notify := 'Y';
    ELSE
     --
       l_review_length := NULL;
       OPEN csr_review_length;
       FETCH csr_review_length INTO l_review_length;
       IF csr_review_length%NOTFOUND THEN
          l_review_length := NULL;
       END IF;
       IF csr_review_length%ISOPEN THEN
          CLOSE csr_review_length;
       END IF;
     --
       IF l_review_length IS NULL THEN
          l_notify := 'Y';
       ELSE
          IF p_review_date < ADD_MONTHS(p_effective_date,-l_review_length) THEN
             l_notify := 'Y';
          ELSE
             l_notify := 'N';
          END IF;
       END IF;
     --
    END IF;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
    RETURN l_notify;
  --
  END chk_notify;
  --
  ------------------------------------------------------------------------------
  ------------------------------< get_appraisal >------------------------------
  ------------------------------------------------------------------------------
  FUNCTION get_appraisal(p_ben_pgm_id           NUMBER
                        ,p_person_id            NUMBER
                        ,p_assignment_id        NUMBER
                        ,p_appraisal_status     VARCHAR2
                        ,p_appraisal_start_date DATE
                        ,p_appraisal_end_date   DATE
                        ,p_effective_date       DATE) RETURN NUMBER IS
  --
  --Cursor to fetch Appraisal Type for the Corps
    CURSOR csr_appraisal_type IS
    SELECT pgi_information2
      FROM ben_pgm_extra_info
     WHERE information_type = 'PQH_FR_CORP_INFO'
       AND pgm_id           = p_ben_pgm_id;
  --
  --Cursor to fetch Appraisal Date
    CURSOR csr_appraisal(p_appraisal_type VARCHAR2) IS
    SELECT appraisal_id
      FROM per_appraisals
     WHERE appraisee_person_id     = p_person_id
       AND type                    = p_appraisal_type
       AND appraisal_system_status = p_appraisal_status
       AND appraisal_date         >= NVL(p_appraisal_start_date,HR_GENERAL.start_of_time)
       AND appraisal_date         <= NVL(p_appraisal_end_date,HR_GENERAL.end_of_time)
       AND appraisal_date         <= p_effective_date
     ORDER BY appraisal_date DESC;
  --
  --Variable Declarations.
    l_appraisal_type VARCHAR2(30);
    l_appraisal_id   NUMBER;
    l_proc           VARCHAR2(72) := g_package||'get_appraisal';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    l_appraisal_type := NULL;
    OPEN csr_appraisal_type;
    FETCH csr_appraisal_type INTO l_appraisal_type;
    IF csr_appraisal_type%NOTFOUND THEN
       l_appraisal_type := NULL;
    END IF;
    IF csr_appraisal_type%ISOPEN THEN
       CLOSE csr_appraisal_type;
    END IF;
  --
    l_appraisal_id := NULL;
  --
    IF l_appraisal_type IS NOT NULL THEN
       OPEN csr_appraisal(l_appraisal_type);
       FETCH csr_appraisal INTO l_appraisal_id;
       IF csr_appraisal%NOTFOUND THEN
          l_appraisal_id := NULL;
       END IF;
       IF csr_appraisal%ISOPEN THEN
          CLOSE csr_appraisal;
       END IF;
    END IF;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
    RETURN l_appraisal_id;
  --
  END get_appraisal;
  --
  ------------------------------------------------------------------------------
  --------------------------------< get_marks >---------------------------------
  ------------------------------------------------------------------------------
  FUNCTION get_marks(p_appraisal_id NUMBER) RETURN NUMBER IS
  --
  --Cursor to fetch Appraisal Date
    CURSOR csr_assessment IS
    SELECT assessment_id
      FROM per_assessments
     WHERE appraisal_id = p_appraisal_id;
  --
  --Variable Declarations.
    l_assessment_id NUMBER;
    l_marks         NUMBER;
    l_proc          VARCHAR2(72) := g_package||'get_marks';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    l_marks := 0;
    OPEN csr_assessment;
    FETCH csr_assessment INTO l_assessment_id;
    IF csr_assessment%NOTFOUND THEN
       l_marks := 0;
    ELSE
       l_marks := HR_APPRAISALS_UTIL_SS.get_assessment_score(l_assessment_id);
    END IF;
    IF csr_assessment%ISOPEN THEN
       CLOSE csr_assessment;
    END IF;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
    l_marks := ROUND(l_marks,2);  --Rounding to 2 decimal places.
  --
    RETURN l_marks;
  --
  END get_marks;
  --
  ------------------------------------------------------------------------------
  -----------------------------< chk_speed_quota >------------------------------
  ------------------------------------------------------------------------------
  PROCEDURE chk_speed_quota(p_ben_pgm_id     IN            NUMBER
                           ,p_grade_id       IN            NUMBER
                           ,p_speed          IN            VARCHAR2
                           ,p_effective_date IN            DATE
                           ,p_num_allowed       OUT NOCOPY NUMBER
                           ,p_speed_meaning     OUT NOCOPY VARCHAR2
                           ,p_return_status     OUT NOCOPY VARCHAR2) IS
  --
  --Cursor to fetch total people (fonctionaires only) in specified Corps and Grade
    CURSOR csr_tot_ppl_in_grd IS
    SELECT COUNT(asg.person_id)
      FROM per_all_assignments_f asg
          ,per_all_people_f      ppl
     WHERE asg.grade_ladder_pgm_id = p_ben_pgm_id
       AND asg.grade_id            = p_grade_id
       AND asg.primary_flag        = 'Y'
       AND ppl.person_id           = asg.person_id
       AND ppl.per_information15   = '01' --Fonctionaires only
       AND asg.assignment_status_type_id IN (SELECT assignment_status_type_id
                                               FROM per_assignment_status_types
                                              WHERE per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN'))
       AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
       AND p_effective_date BETWEEN ppl.effective_start_date AND ppl.effective_end_date;
  --
  --Cursor to fetch total people (fonctionaires only) in specified Speed within the Corps and Grade
    CURSOR csr_tot_ppl_in_speed IS
    SELECT COUNT(placement_id)
      FROM per_spinal_point_placements_f
     WHERE assignment_id IN (SELECT asg.assignment_id
                               FROM per_all_assignments_f asg
                                   ,per_all_people_f      ppl
                              WHERE asg.grade_ladder_pgm_id = p_ben_pgm_id
                                AND asg.grade_id            = p_grade_id
                                AND asg.primary_flag        = 'Y'
                                AND ppl.person_id           = asg.person_id
                                AND ppl.per_information15   = '01' --Fonctionaires only
                                AND asg.assignment_status_type_id IN (SELECT assignment_status_type_id
                                                                        FROM per_assignment_status_types
                                                                       WHERE per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN'))
                                AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
                                AND p_effective_date BETWEEN ppl.effective_start_date AND ppl.effective_end_date)
       AND information3   = p_speed
       AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  --Cursor to fetch Speed Quota for the specified Corps and Grade
    CURSOR csr_speed_quota IS
    SELECT NVL(cei.information6,-1)  --MAX Speed Quota
          ,NVL(cei.information7,-1)  --AVG Speed Quota
      FROM pqh_corps_definitions corps
          ,pqh_corps_extra_info  cei
     WHERE corps.ben_pgm_id        = p_ben_pgm_id
       AND cei.corps_definition_id = corps.corps_definition_id
       AND cei.information3        = TO_CHAR(p_grade_id)
       AND cei.information_type    = 'GRADE';
  --
  --Variable Declarations.
    l_tot_ppl_in_grd   NUMBER;
    l_tot_ppl_in_speed NUMBER;
    l_max_speed_quota  NUMBER;
    l_avg_speed_quota  NUMBER;
    l_speed_quota      NUMBER;
    l_speed_quota_chk  VARCHAR2(1);
    l_proc             VARCHAR2(72) := g_package||'chk_speed_quota';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    p_num_allowed   := 0;
    p_return_status := 'S';
    IF p_speed <> 'MIN' THEN
     --
       l_tot_ppl_in_grd := 0;
       OPEN csr_tot_ppl_in_grd;
       FETCH csr_tot_ppl_in_grd INTO l_tot_ppl_in_grd;
       IF csr_tot_ppl_in_grd%NOTFOUND THEN
          l_tot_ppl_in_grd := 0;
       END IF;
       IF csr_tot_ppl_in_grd%ISOPEN THEN
          CLOSE csr_tot_ppl_in_grd;
       END IF;
     --
       l_tot_ppl_in_speed := 0;
       OPEN csr_tot_ppl_in_speed;
       FETCH csr_tot_ppl_in_speed INTO l_tot_ppl_in_speed;
       IF csr_tot_ppl_in_speed%NOTFOUND THEN
          l_tot_ppl_in_speed := 0;
       END IF;
       IF csr_tot_ppl_in_speed%ISOPEN THEN
          CLOSE csr_tot_ppl_in_speed;
       END IF;
     --
       l_max_speed_quota := -1;
       l_avg_speed_quota := -1;
       OPEN csr_speed_quota;
       FETCH csr_speed_quota INTO l_max_speed_quota,l_avg_speed_quota;
       IF csr_speed_quota%NOTFOUND THEN
          l_max_speed_quota := -1;
          l_avg_speed_quota := -1;
       END IF;
       IF csr_speed_quota%ISOPEN THEN
          CLOSE csr_speed_quota;
       END IF;
     --
       l_speed_quota := -1;
       IF p_speed = 'MAX' AND l_max_speed_quota <> -1 THEN
          l_speed_quota := ROUND((l_max_speed_quota * l_tot_ppl_in_grd)/100);
       ELSIF p_speed = 'AVG' AND l_avg_speed_quota <> -1 THEN
          l_speed_quota := ROUND((l_avg_speed_quota * l_tot_ppl_in_grd)/100);
       END IF;
     --
       IF l_speed_quota <> -1 THEN
          IF (l_tot_ppl_in_speed + 1) > l_speed_quota THEN
             l_speed_quota_chk := 'F'; --Quota check failure
             ROLLBACK;                 --Rollback all preceeding transactions.
          ELSE
             l_speed_quota_chk := 'S'; --Quota check success
          END IF;
       ELSE
          l_speed_quota_chk := 'S'; --Quota check success because Speed Quota not defined
       END IF;
    --
       p_speed_meaning := HR_GENERAL.decode_lookup('FR_PQH_PROGRESSION_SPEED',p_speed);
       p_num_allowed   := l_speed_quota;
       p_return_status := l_speed_quota_chk;
    --
    END IF;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
  END chk_speed_quota;
  --
  ------------------------------------------------------------------------------
  -------------------------------< update_speed >-------------------------------
  ------------------------------------------------------------------------------
  PROCEDURE update_speed(p_place_id   IN            NUMBER
                        ,p_speed      IN            VARCHAR2
                        ,p_eff_dt     IN            DATE
                        ,p_ovn        IN OUT NOCOPY NUMBER
                        ,p_eff_st_dt     OUT NOCOPY DATE
                        ,p_eff_end_dt    OUT NOCOPY DATE) IS
  --
  --Variable Declarations.
    l_ovn            NUMBER;
    l_datetrack_mode VARCHAR2(100);
    l_proc           VARCHAR2(72) := g_package||'update_speed';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    l_ovn := p_ovn;
  --
    HR_UTILITY.set_location('OVN before update: '||l_ovn,20);
  --
    l_datetrack_mode := PQH_FR_UTILITY.get_datetrack_mode(p_eff_dt
                                                         ,'PER_SPINAL_POINT_PLACEMENTS_F'
                                                         ,'PLACEMENT_ID'
                                                         ,p_place_id);
  --
    HR_UTILITY.set_location('l_datetrack_mode: '||l_datetrack_mode,30);
  --
    HR_SP_PLACEMENT_API.update_spp(p_effective_date        => p_eff_dt
                                  ,p_datetrack_mode        => l_datetrack_mode
                                  ,p_placement_id          => p_place_id
                                  ,p_information3          => p_speed
                                  ,p_object_version_number => l_ovn
                                  ,p_effective_start_date  => p_eff_st_dt
                                  ,p_effective_end_date    => p_eff_end_dt);
  --
    HR_UTILITY.set_location('OVN after update: '||l_ovn,40);
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,50);
  --
  END update_speed;
  --
  ------------------------------------------------------------------------------
  ------------------------------< notify_manager >------------------------------
  ------------------------------------------------------------------------------
  PROCEDURE notify_manager(p_ItemType    IN VARCHAR2
                          ,p_ProcessName IN VARCHAR2
                          ,p_EmpNumber   IN VARCHAR2
                          ,p_EmpName     IN VARCHAR2
                          ,p_UserName    IN VARCHAR2
                          ,p_MgrUserName IN VARCHAR2
                          ,p_Corps       IN VARCHAR2
                          ,p_Grade       IN VARCHAR2
                          ,p_Step        IN VARCHAR2
                          ,p_Speed       IN VARCHAR2
                          ,p_LastApprDt  IN DATE
                          ,p_EffDt       IN DATE
                          ,p_Duration    IN NUMBER) IS
  --
  --Variable Declarations.
    l_itemKey VARCHAR2(240);
    l_proc    VARCHAR2(72) := g_package||'notify_manager';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    SELECT PQH_WORKFLOW_ITEM_KEY_S.nextval INTO l_itemKey FROM dual;
    l_itemKey := 'FRPS'||l_itemKey;
  --
  --Kick off the workflow process.
    WF_ENGINE.CreateProcess(p_itemtype,l_itemkey,p_processName);
  --
    IF p_userName is not null then
       WF_ENGINE.SetItemOwner(p_itemtype,l_itemkey,p_userName);
    END IF;
  --
  --Set the route by user (appears in from on worklist)
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'ROUTED_BY_USER'
                             ,avalue   => p_UserName);
  --
  --Set the manager user to be notified
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'FYI_USER'
                             ,avalue   => p_MgrUserName);
  --
  --Set the Effective Date
    WF_ENGINE.SetItemAttrDate(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'EFFECTIVE_DATE'
                             ,avalue   => p_EffDt);
  --
  --Set the person name
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PSV_PERSON_NAME'
                             ,avalue   => p_EmpName);
  --
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PARAMETER1_VALUE'
                             ,avalue   => p_EmpNumber);
  --
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PARAMETER2_VALUE'
                             ,avalue   => p_Corps);
  --
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PARAMETER3_VALUE'
                             ,avalue   => p_Grade);
  --
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PARAMETER4_VALUE'
                             ,avalue   => p_Step);
  --
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PARAMETER5_VALUE'
                             ,avalue   => p_Speed);
  --
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PARAMETER6_VALUE'
                             ,avalue   => TO_CHAR(p_Duration));
  --
    WF_ENGINE.SetItemAttrText(itemtype => p_ItemType
                             ,itemkey  => l_ItemKey
                             ,aname    => 'PARAMETER7_VALUE'
                             ,avalue   => p_LastApprDt);
  --
    WF_ENGINE.StartProcess(p_itemtype,l_itemkey);
  --
    COMMIT;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
  END notify_manager;
  --
  ------------------------------------------------------------------------------
  -------------------------------< get_speed >----------------------------------
  ------------------------------------------------------------------------------
  FUNCTION chk_speed_length(p_assignment_id  IN NUMBER
                           ,p_effective_date IN DATE) RETURN VARCHAR2 IS
  --
  --Cursor to fetch current assginment, step and speed details
    CURSOR csr_step_dtls IS
    SELECT asg.grade_id
          ,spp.step_id
          ,spp.information3
          ,MONTHS_BETWEEN(p_effective_date,spp.effective_start_date)
          ,p_effective_date-spp.effective_start_date
          ,spp.effective_start_date
      FROM per_all_assignments_f         asg
          ,per_spinal_point_placements_f spp
     WHERE asg.assignment_id        = p_assignment_id
       AND spp.assignment_id(+)     = asg.assignment_id
       AND p_effective_date BETWEEN asg.effective_start_date    AND asg.effective_end_date
       AND p_effective_date BETWEEN spp.effective_start_date(+) AND spp.effective_end_date(+);
  --
  --Cursor to fetch speed length for the Step
    CURSOR csr_speed_length(p_grade_id NUMBER
                           ,p_step_id  NUMBER
                           ,p_speed_cd VARCHAR) IS
    SELECT DECODE(p_speed_cd
                 ,'MIN',psp.information4
                 ,'AVG',psp.information5
                 ,'MAX',psp.information3
                 ,-1)                 speed_len
          ,NVL(pps.information2,'CM') speed_unit
      FROM per_grade_spines_f       gsp
          ,per_spinal_point_steps_f sps
          ,per_spinal_points        psp
          ,per_parent_spines        pps
     WHERE gsp.grade_id             = p_grade_id
       AND sps.step_id              = p_step_id
       AND sps.grade_spine_id       = gsp.grade_spine_id
       AND sps.business_group_id    = gsp.business_group_id
       AND psp.parent_spine_id      = gsp.parent_spine_id
       AND psp.spinal_point_id      = sps.spinal_point_id
       AND psp.business_group_id    = gsp.business_group_id
       AND psp.information_category = 'FR_PQH'
       AND pps.information_category = psp.information_category
       AND pps.business_group_id    = psp.business_group_id
       AND pps.parent_spine_id      = psp.parent_spine_id
       AND p_effective_date BETWEEN gsp.effective_start_date AND gsp.effective_end_date
       AND p_effective_date BETWEEN sps.effective_start_date AND sps.effective_end_date;
  --
  --Variable Declarations.
    l_grade_id       NUMBER;
    l_step_id        NUMBER;
    l_speed_cd       VARCHAR2(240);
    l_step_los_mon   NUMBER;
    l_step_los_day   NUMBER;
    l_speed_start_dt DATE;
    l_date           DATE;
    l_speed_len      NUMBER;
    l_speed_unit     VARCHAR2(10);
    l_return_cd      VARCHAR2(1);
    l_proc           VARCHAR2(72) := g_package||'chk_speed_length';
  --
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    OPEN csr_step_dtls;
    FETCH csr_step_dtls INTO l_grade_id,l_step_id,l_speed_cd,l_step_los_mon,l_step_los_day,l_speed_start_dt;
    IF csr_step_dtls%NOTFOUND THEN
       CLOSE csr_step_dtls;
       l_return_cd := 'N';       --Assignment not found. Return Failure.
     --
       HR_UTILITY.set_location('Leaving:'||l_proc,20);
     --
       RETURN l_return_cd;
    END IF;
    IF csr_step_dtls%ISOPEN THEN
       CLOSE csr_step_dtls;
    END IF;
  --
    IF l_step_id IS NULL OR l_speed_cd IS NULL THEN
       l_return_cd := 'N';       --Person not on Step or Speed not set for Person. Return Failure.
     --
       HR_UTILITY.set_location('Leaving:'||l_proc,20);
     --
       RETURN l_return_cd;
    ELSE
     --
       OPEN csr_speed_length(l_grade_id,l_step_id,l_speed_cd);
       FETCH csr_speed_length INTO l_speed_len,l_speed_unit;
       IF csr_speed_length%NOTFOUND THEN
          CLOSE csr_speed_length;
          l_return_cd := 'Y';    --Speed Lengths not defined in Corps Setup. Return Success.
        --
          HR_UTILITY.set_location('Leaving:'||l_proc,20);
        --
          RETURN l_return_cd;
       END IF;
       IF csr_speed_length%ISOPEN THEN
          CLOSE csr_speed_length;
       END IF;
     --
       IF l_speed_len IS NULL THEN
          l_return_cd := 'Y';    --Speed Lengths defined as NULL in Corps Setup. Return Success.
       ELSIF l_speed_len = -1 THEN
          l_return_cd := 'N';    --Invalid Speed Code for emp in SPP. Return Failure.
       ELSE
        --
          IF l_speed_unit = 'Y' THEN                 --Year
             l_speed_len := l_speed_len*12;
          ELSIF l_speed_unit = 'SY' THEN             --Semi Year
             l_speed_len := l_speed_len*6;
          ELSIF l_speed_unit = 'Q' THEN              --Quarter
             l_speed_len := l_speed_len*3;
          ELSIF l_speed_unit = 'BM' THEN             --Bi Month
             l_speed_len := l_speed_len*2;
          ELSIF l_speed_unit = 'CM' THEN             --Calendar Month
             l_speed_len := l_speed_len;
          ELSIF l_speed_unit = 'LM' THEN             --Lunar Month
             l_speed_len := l_speed_len*28;
          ELSIF l_speed_unit = 'SM' THEN             --Semi Month
             l_date := l_speed_start_dt;
             FOR i IN 1..l_speed_len
             LOOP
                l_date := TRUNC(l_date+TRUNC(((ADD_MONTHS(l_date,1)-l_date)/2)));
             END LOOP;
             l_speed_len := l_date-l_speed_start_dt;
          ELSIF l_speed_unit = 'F' THEN              --Fortnight/BiWeek
             l_speed_len := l_speed_len*14;
          ELSIF l_speed_unit = 'W' THEN              --Week
             l_speed_len := l_speed_len*7;
          END IF;
        --
          IF l_speed_unit IN ('Y','SY','Q','BM','CM') THEN  --Month Comparision
           --
             IF l_step_los_mon >= l_speed_len THEN
                l_return_cd := 'Y'; --Person has satisfied speed length. Return Success.
             ELSE
                l_return_cd := 'N'; --Pesron has not satisfied speed length. Return Failure.
             END IF;
           --
          ELSE                                              --Days Comparision
           --
             IF l_step_los_day >= l_speed_len THEN
                l_return_cd := 'Y'; --Person has satisfied speed length. Return Success.
             ELSE
                l_return_cd := 'N'; --Pesron has not satisfied speed length. Return Failure.
             END IF;
           --
          END IF;
        --
       END IF;
     --
    END IF;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
    RETURN l_return_cd;
  --
  END chk_speed_length;
  --
  ------------------------------------------------------------------------------
  -------------------------------< get_mgr_user >-------------------------------
  ------------------------------------------------------------------------------
  PROCEDURE get_mgr_user(p_effective_date IN            DATE
                        ,p_mgr_id         IN            NUMBER
                        ,p_mgr_username      OUT NOCOPY VARCHAR2) IS
  --
  --Cursor to fetch FNDUSER for Manager
    CURSOR csr_fnduser IS
    SELECT user_name
      FROM fnd_user
     WHERE employee_id = p_mgr_id
       AND p_effective_date BETWEEN NVL(start_date,HR_GENERAL.start_of_time) AND NVL(end_date,HR_GENERAL.end_of_time);
  --
  --Variable Declarations.
    l_proc VARCHAR2(72) := g_package||'get_mgr_user';
  BEGIN
  --
    HR_UTILITY.set_location('Entering:'||l_proc,10);
  --
    OPEN csr_fnduser;
    FETCH csr_fnduser INTO p_mgr_username;
    IF csr_fnduser%NOTFOUND THEN
       p_mgr_username := 'N';
    END IF;
    CLOSE csr_fnduser;
  --
    HR_UTILITY.set_location('Leaving:'||l_proc,20);
  --
  END get_mgr_user;
  --
--
END pqh_fr_speed;

/
