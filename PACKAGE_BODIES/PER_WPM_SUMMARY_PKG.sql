--------------------------------------------------------
--  DDL for Package Body PER_WPM_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_WPM_SUMMARY_PKG" AS
/* $Header: pewpmsum.pkb 120.2.12010000.4 2008/10/21 05:52:57 rvagvala ship $ */
  --
  --
  g_package VARCHAR2(40) := 'per_wpm_summary_pkg.';
  TYPE sup_level_rec IS RECORD
  (supervisor_id       NUMBER(15),
   supervisor_name     VARCHAR2(240),
   level_num           NUMBER(15) );
  TYPE t_sup_level IS TABLE OF sup_level_rec INDEX BY BINARY_INTEGER;
  TYPE t_appr_period_rec IS RECORD
  (appraisal_period_id NUMBER(15),
   start_date     DATE,
   end_date       DATE,
   rating_scale_id NUMBER(15) );
  --
  g_appr_period_rec t_appr_period_rec;
  --
  TYPE rating_level_rec IS RECORD
  (rating_level_id  NUMBER(15),
   level_name       VARCHAR2(100) );
  TYPE t_rating_levels IS TABLE OF rating_level_rec INDEX BY BINARY_INTEGER;
  g_rating_levels   t_rating_levels ;
  --
  g_errmsg VARCHAR2(2000);
  --
  --
  PROCEDURE populate_plan_hierarchy_cp(errbuf  OUT NOCOPY VARCHAR2
                ,retcode OUT NOCOPY NUMBER
                ,p_plan_id IN number
                ,p_effective_date IN VARCHAR2) IS
   l_effective_date DATE;
   l_proc VARCHAR2(80) := g_package||'main';
  BEGIN
     hr_utility.set_location('Entering : '||l_proc,10);
     l_effective_date := fnd_date.canonical_to_date(p_effective_date);
     populate_plan_hierarchy(p_plan_id => p_plan_id
                            ,p_effective_date => l_effective_date);
     hr_utility.set_location('Leaving : '||l_proc,10);
  EXCEPTION
     WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,Sqlerrm);
        retcode := 2;
        errbuf := SQLERRM;
        RAISE;
  END populate_plan_hierarchy_cp;
  --
  -- This procedure is obsolete and is not used
  PROCEDURE insert_next_levels(p_plan_id NUMBER
                              ,p_supervisor_id NUMBER
                              ,p_sup_chain t_sup_level
                              ,p_level_num NUMBER) IS
     CURSOR csr_directs (p_plan_id NUMBER, p_supervisor_id NUMBER) IS
       SELECT DISTINCT
           ppf.full_name employee_name
           ,ppf.person_id employee_id
           ,ppf2.full_name supervisor_name
           ,ppf2.person_id supervisor_id
           ,pmp.plan_id
       FROM   per_perf_mgmt_plans pmp
             ,per_assignments_f paf
             ,per_people_f ppf
             ,per_people_f ppf2
     WHERE  pmp.plan_id = p_plan_id
     AND    paf.supervisor_id = p_supervisor_id
     AND    paf.primary_flag = 'Y'
     AND    trunc(sysdate) between paf.effective_start_date AND paf.effective_end_date
     AND    paf.person_id = ppf.person_id
     AND    trunc(sysdate) between ppf.effective_start_date AND ppf.effective_end_date
     AND    paf.supervisor_id = ppf2.person_id
     AND    trunc(sysdate) between ppf2.effective_start_date AND ppf2.effective_end_date
     AND    paf.person_id IN (select person_id FROM per_personal_scorecards WHERE plan_id = p_plan_id);
     l_sup_level   t_sup_level;
     l_last  NUMBER;
     l_max_level NUMBER;
     l_counter NUMBER;
     l_proc VARCHAR2(80) := g_package||'insert_next_levels';
  BEGIN
       hr_utility.set_location('Entering:'||l_proc,10);
       --

       --
       FOR i in csr_directs(p_plan_id, p_supervisor_id)
       LOOP
         l_sup_level := p_sup_chain;
         hr_utility.trace('INSIDE insert_next_levels: '||l_sup_level.count);
         hr_utility.trace('INSIDE insert_next_levels: '||p_level_num);
         hr_utility.trace('Inserting directs for:'||i.supervisor_name);
         hr_utility.trace('Inserting direct:'||i.employee_name);
         INSERT INTO per_wpm_plan_hierarchy
	                               (wpm_plan_hierarchy_id
	                               ,plan_id
	                               ,employee_person_id
	                               ,employee_name
	                               ,supervisor_person_id
	                               ,supervisor_name
	                               ,level_num)
	                                VALUES (per_wpm_plan_hierarchy_s.nextval
	                                       ,i.plan_id
	                                       ,i.employee_id
	                                       ,i.employee_name
	                                       ,i.supervisor_id
	                                       ,i.supervisor_name
                                               ,1);
           l_max_level := l_sup_level(l_sup_level.LAST).level_num;
           l_counter := 0;
            FOR j in l_sup_level.FIRST .. l_sup_level.LAST
            LOOP
              hr_utility.trace('Looping for supervisors for :'||i.employee_name);
              hr_utility.trace('Supervisor:'||l_sup_level(j).supervisor_name);
              hr_utility.trace('Supervisor level:'||((l_max_level - l_counter)+1));
              INSERT INTO per_wpm_plan_hierarchy
                              (wpm_plan_hierarchy_id
                              ,plan_id
                              ,employee_person_id
                              ,employee_name
                              ,supervisor_person_id
                              ,supervisor_name
                              ,level_num)
                               VALUES (per_wpm_plan_hierarchy_s.nextval
                                      ,i.plan_id
                                      ,i.employee_id
                                      ,i.employee_name
                                      ,l_sup_level(j).supervisor_id
                                      ,l_sup_level(j).supervisor_name
                                      ,(l_max_level - l_counter)+1  );
              l_counter := l_counter+1;
            END LOOP;
         l_last := NVL(l_sup_level.LAST,0);
         l_sup_level(l_last+1).supervisor_id := i.supervisor_id;
         l_sup_level(l_last+1).supervisor_name := i.supervisor_name;
         l_sup_level(l_last+1).level_num     :=    NVL(p_level_num,1)+1;
         hr_utility.trace('INSIDE insert_next_levels: '||l_sup_level.count);
         hr_utility.trace('INSIDE insert_next_levels: '||l_sup_level(l_last+1).level_num);
         insert_next_levels(p_plan_id, i.employee_id,l_sup_level, l_sup_level(l_last+1).level_num );
         l_sup_level.DELETE;
       END LOOP;
       hr_utility.set_location('Leaving:'||l_proc,100);
  END insert_next_levels;
  --
  --
  PROCEDURE build_hierarchy_for_sc(p_plan_id   IN NUMBER,
                                   p_sc_id   IN NUMBER DEFAULT NULL) IS
    CURSOR csr_plan_dtls (p_plan_id IN NUMBER) IS
     SELECT *
     FROM  per_perf_mgmt_plans pmp
     WHERE plan_id = p_plan_id;
     --
     l_pl_rec per_perf_mgmt_plans%ROWTYPE;
     --
     CURSOR csr_sc_dtls(p_sc_id IN NUMBER) IS
      SELECT sc.scorecard_id
            ,sc.person_id
            ,sc.assignment_id
            ,ppf.full_name
     FROM   per_personal_scorecards sc,
            per_people_f ppf
     WHERE  scorecard_id = p_sc_id
     AND    sc.person_id = ppf.person_id
     AND    trunc(sysdate) between ppf.effective_start_date AND
ppf.effective_end_date;
     --
     CURSOR csr_all_scs(p_plan_id IN NUMBER) IS
      SELECT sc.scorecard_id
            ,sc.person_id
            ,sc.assignment_id
            ,ppf.full_name
      FROM   per_personal_scorecards sc
            ,per_people_f ppf
      WHERE  sc.plan_id = p_plan_id
      AND    sc.person_id = ppf.person_id
      AND    trunc(sysdate) between ppf.effective_start_date AND
ppf.effective_end_date;
    --
    --
    CURSOR csr_sc_hrchy(p_plan_id IN NUMBER,p_assignment_id IN NUMBER) IS
    SELECT level, e.*
    FROM
    (SELECT paf.assignment_id
          ,paf.person_id
          ,paf.supervisor_id
          ,ppf2.full_name "SUPERVISOR_NAME"
          ,paf.position_id
          ,paf.organization_id
          ,ppf.full_name "EMPLOYEE_NAME"
    FROM   per_people_f ppf
          ,per_all_people_f ppf2
          ,per_assignments_f paf
          ,per_personal_scorecards sc
    WHERE sc.plan_id = p_plan_id
    AND   sc.assignment_id = paf.assignment_id
    AND   paf.supervisor_id = ppf2.person_id
    AND   paf.person_id = ppf.person_id
    AND   trunc(sysdate) between paf.effective_start_date AND
paf.effective_end_date
    AND   trunc(sysdate) between ppf.effective_start_date AND
ppf.effective_end_date
    AND   trunc(sysdate) between ppf2.effective_start_date AND
ppf2.effective_end_date) e
    START WITH assignment_id = p_assignment_id
    CONNECT BY prior supervisor_id = person_id;
    --
    TYPE r_sc_hrchy IS RECORD (level NUMBER(15)
                              ,assignment_id number(15)
                              ,person_id     number(15)
                              ,supervisor_id number(15)
                              ,supervisor_name per_people_f.full_name%TYPE
                              ,position_id   number(15)
                              ,organization_id number(15)
                              ,employee_name per_people_f.full_name%TYPE);
    TYPE t_sc_hrchy IS TABLE OF r_sc_hrchy INDEX BY BINARY_INTEGER;
    l_sc_hrchy t_sc_hrchy;
  BEGIN
     OPEN csr_plan_dtls(p_plan_id);
     FETCH csr_plan_dtls INTO l_pl_rec;
     CLOSE csr_plan_dtls;
     IF p_sc_id IS NOT NULL THEN
         FOR i IN csr_sc_dtls(p_sc_id)
         LOOP
           l_sc_hrchy.DELETE;
           OPEN csr_sc_hrchy(p_plan_id,i.assignment_id);
           FETCH csr_sc_hrchy BULK COLLECT INTO l_sc_hrchy;
           CLOSE csr_sc_hrchy;
           IF l_sc_hrchy.COUNT > 0 THEN
            FOR j IN l_sc_hrchy.FIRST .. l_sc_hrchy.LAST
            LOOP
             IF (l_sc_hrchy(j).person_id = l_pl_rec.supervisor_id OR
                 l_sc_hrchy(j).assignment_id = l_pl_rec.supervisor_assignment_id
OR
                 l_sc_hrchy(j).organization_id = l_pl_rec.top_organization_id OR
                 l_sc_hrchy(j).position_id = l_pl_rec.top_position_id ) THEN
      -- No need to insert anything as this is the top most record in the hierarchy
                 NULL;
             ELSE
               INSERT INTO per_wpm_plan_hierarchy
                              (wpm_plan_hierarchy_id
                              ,plan_id
                              ,employee_person_id
                              ,employee_name
                              ,supervisor_person_id
                              ,supervisor_name
                              ,level_num)
                               VALUES (per_wpm_plan_hierarchy_s.nextval
                                      ,p_plan_id
                                      ,i.person_id
                                      ,i.full_name
                                      ,l_sc_hrchy(j).supervisor_id
                                      ,l_sc_hrchy(j).supervisor_name
                                      ,l_sc_hrchy(j).level);
             END IF;
            END LOOP;
          END IF; ---count > 0
         END LOOP;
     ELSE
         FOR i IN csr_all_scs(p_plan_id)
         LOOP
           l_sc_hrchy.DELETE;
           OPEN csr_sc_hrchy(p_plan_id,i.assignment_id);
           FETCH csr_sc_hrchy BULK COLLECT INTO l_sc_hrchy;
           CLOSE csr_sc_hrchy;
           IF l_sc_hrchy.count > 0 THEN
            FOR j IN l_sc_hrchy.FIRST .. l_sc_hrchy.LAST
            LOOP
             IF (l_sc_hrchy(j).person_id = l_pl_rec.supervisor_id OR
                 l_sc_hrchy(j).assignment_id = l_pl_rec.supervisor_assignment_id
OR
                 l_sc_hrchy(j).organization_id = l_pl_rec.top_organization_id OR
                 l_sc_hrchy(j).position_id = l_pl_rec.top_position_id ) THEN
                 -- No need to insert anything as this is the top most record in the hierarchy
                 NULL;
             ELSE
               INSERT INTO per_wpm_plan_hierarchy
                              (wpm_plan_hierarchy_id
                              ,plan_id
                              ,employee_person_id
                              ,employee_name
                              ,supervisor_person_id
                              ,supervisor_name
                              ,level_num)
                               VALUES (per_wpm_plan_hierarchy_s.nextval
                                      ,p_plan_id
                                      ,i.person_id
                                      ,i.full_name
                                      ,l_sc_hrchy(j).supervisor_id
                                      ,l_sc_hrchy(j).supervisor_name
                                      ,l_sc_hrchy(j).level);
             END IF;
            END LOOP;
           END IF; -- count > 0
         END LOOP;
     END IF;
  END build_hierarchy_for_sc;
  --
  --
  PROCEDURE populate_plan_hierarchy(p_plan_id IN NUMBER
                                   ,p_effective_date IN DATE) IS
    --
    CURSOR csr_plan_sup_directs(p_plan_id NUMBER, p_effective_date DATE) IS
         SELECT ppf.full_name employee_name
               ,ppf.person_id employee_id
               ,ppf2.full_name supervisor_name
               ,ppf2.person_id supervisor_id
               ,pmp.plan_id    PLAN_ID
         FROM   per_perf_mgmt_plans pmp
               ,per_assignments_f paf
               ,per_people_f ppf
               ,per_people_f ppf2
         WHERE  pmp.plan_id = p_plan_id
         AND    pmp.supervisor_id = paf.supervisor_id
         AND    paf.primary_flag = 'Y'
         AND    p_effective_date  between paf.effective_start_date AND paf.effective_end_date
         AND    paf.person_id = ppf.person_id
         AND    p_effective_date  between ppf.effective_start_date AND ppf.effective_end_date
         AND    paf.supervisor_id = ppf2.person_id
         AND    p_effective_date  between ppf2.effective_start_date AND ppf2.effective_end_date
         AND    paf.person_id IN (select person_id FROM per_personal_scorecards WHERE plan_id = p_plan_id);
    l_effective_date DATE;
    l_sup_level  t_sup_level;
    l_proc VARCHAR2(80) := g_package||'populate_plan_hierarchy';
  BEGIN
     --
     hr_utility.set_location('Entering:'||l_proc,10);
     DELETE per_wpm_plan_hierarchy
       WHERE  plan_id = p_plan_id;
     l_effective_date := NVL(p_effective_date,TRUNC(SYSDATE));
/* changed the logic using build_hierarchy_for_sc
 *   FOR i IN csr_plan_sup_directs(p_plan_id,l_effective_date)
     LOOP
         l_sup_level(1).supervisor_id := i.supervisor_id;
         l_sup_level(1).supervisor_name := i.supervisor_name;
         l_sup_level(1).level_num :=1;
         INSERT INTO per_wpm_plan_hierarchy
                              (wpm_plan_hierarchy_id
                              ,plan_id
                              ,employee_person_id
                              ,employee_name
                              ,supervisor_person_id
                              ,supervisor_name
                              ,level_num)
                               VALUES (per_wpm_plan_hierarchy_s.nextval
                                      ,i.plan_id
                                      ,i.employee_id
                                      ,i.employee_name
                                      ,i.supervisor_id
                                      ,i.supervisor_name
                                      ,1);
         insert_next_levels(p_plan_id, i.employee_id,l_sup_level,1);
     END LOOP;
*/
     build_hierarchy_for_sc(p_plan_id => p_plan_id);
     COMMIT;
     hr_utility.set_location('Leaving:'||l_proc,100);
     --
     --
  END populate_plan_hierarchy;
  --
  --



procedure submit_refreshApprSummary_cp
   (p_plan_id               in     number
   ,p_appraisal_period_id   in     number
   ,p_request_id           out NOCOPY   number
   )
is
  --

    l_request_id               number ;
    l_effective_date           varchar2(30) := fnd_date.date_to_canonical(trunc(sysdate));

  --
begin
  -- Submit the request
  l_request_id := fnd_request.submit_request(
                           application => 'PER'
                          ,program     => 'PERAPPRSUM'
                          ,sub_request => FALSE
--                          ,start_time  => l_effective_date
                          ,argument1   => p_plan_id
                          ,argument2   => p_appraisal_period_id
                          ,argument3   => l_effective_date
                          );
    --

    if l_request_id > 0 then
       null;
    end if;

    p_request_id := l_request_id;
    commit;
  --
end submit_refreshApprSummary_cp;



  PROCEDURE populate_appraisal_summary_cp(errbuf  OUT NOCOPY VARCHAR2
                                         ,retcode OUT NOCOPY NUMBER
                                         ,p_plan_id IN NUMBER
                                         ,p_appraisal_period_id IN NUMBER
                                         ,p_effective_date IN VARCHAR2) IS
    l_proc VARCHAR2(80) := g_package||'populate_appraisal_summary_cp';
    l_effective_date DATE;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,10);
    l_effective_date := NVL(fnd_date.canonical_to_date(p_effective_date),TRUNC(SYSDATE));
    populate_appraisal_summary(p_plan_id => p_plan_id
                              ,p_appraisal_period_id  => p_appraisal_period_id
                              ,p_effective_date => l_effective_date);
    hr_utility.set_location('Leaving:'||l_proc,100);
  EXCEPTION
     WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,Sqlerrm);
        retcode := 2;
        errbuf := SQLERRM;
        hr_utility.set_location('Leaving:'||l_proc,110);
        RAISE;
  END populate_appraisal_summary_cp;
  --
  --
  PROCEDURE compute_summary_for_supervisor(p_plan_id         IN NUMBER
                                          ,p_effective_date  IN DATE
                                          ,p_supervisor_id   IN NUMBER
                                          ,p_supervisor_name IN VARCHAR2) IS
   --
   l_proc VARCHAR2(80) := g_package||'populate_appraisal_summary';
   --
   CURSOR csr_direct_summary(p_plan_id   NUMBER
                            ,p_supervisor_id NUMBER
                            ,p_effective_date DATE
                            ,p_rating_level_id NUMBER) IS
        SELECT COUNT(*)
        FROM   per_appraisals pa
              ,per_wpm_plan_hierarchy wph
              ,per_people_f ppf
        WHERE  wph.plan_id = p_plan_id
        AND    wph.supervisor_person_id = p_supervisor_id
        AND    wph.level_num = 1
        AND    wph.employee_person_id = ppf.person_id
        AND    p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
        AND    pa.plan_id = p_plan_id
        AND    wph.employee_person_id = pa.appraisee_person_id
        AND    pa.appraisal_period_end_date = g_appr_period_rec.end_date
        AND    (pa.appraisal_period_start_date = g_appr_period_rec.start_date OR pa.appraisal_period_start_date = ppf.start_date)
        AND    pa.overall_performance_level_id = p_rating_level_id;
   --
   --
   CURSOR csr_total_summary(p_plan_id   NUMBER
                            ,p_supervisor_id NUMBER
                            ,p_effective_date DATE
                            ,p_rating_level_id NUMBER) IS
        SELECT COUNT(*)
        FROM   per_appraisals pa
              ,per_wpm_plan_hierarchy wph
              ,per_people_f ppf
        WHERE  wph.plan_id = p_plan_id
        AND    wph.supervisor_person_id = p_supervisor_id
        AND    wph.employee_person_id = ppf.person_id
        AND    p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
        AND    pa.plan_id = p_plan_id
        AND    wph.employee_person_id = pa.appraisee_person_id
        AND    pa.appraisal_period_end_date = g_appr_period_rec.end_date
        AND    (pa.appraisal_period_start_date = g_appr_period_rec.start_date OR pa.appraisal_period_start_date = ppf.start_date)
        AND    pa.overall_performance_level_id = p_rating_level_id;
   --
   --
   CURSOR csr_directs_unrated(p_plan_id   NUMBER
                            ,p_supervisor_id NUMBER
                            ,p_effective_date DATE) IS
        SELECT COUNT(*)
        FROM   per_appraisals pa
              ,per_wpm_plan_hierarchy wph
              ,per_people_f ppf
        WHERE  wph.plan_id = p_plan_id
        AND    wph.level_num = 1
        AND    wph.supervisor_person_id = p_supervisor_id
        AND    wph.employee_person_id = ppf.person_id
        AND    p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
        AND    pa.plan_id = p_plan_id
        AND    wph.employee_person_id = pa.appraisee_person_id
        AND    pa.appraisal_period_end_date = g_appr_period_rec.end_date
        AND    (pa.appraisal_period_start_date = g_appr_period_rec.start_date OR pa.appraisal_period_start_date = ppf.start_date)
        AND    pa.overall_performance_level_id IS NULL;
   CURSOR csr_total_unrated(p_plan_id   NUMBER
                            ,p_supervisor_id NUMBER
                            ,p_effective_date DATE) IS
        SELECT COUNT(*)
        FROM   per_appraisals pa
              ,per_wpm_plan_hierarchy wph
              ,per_people_f ppf
        WHERE  wph.plan_id = p_plan_id
        AND    wph.supervisor_person_id = p_supervisor_id
        AND    wph.employee_person_id = ppf.person_id
        AND    p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
        AND    pa.plan_id = p_plan_id
        AND    wph.employee_person_id = pa.appraisee_person_id
        AND    pa.appraisal_period_end_date = g_appr_period_rec.end_date
        AND    (pa.appraisal_period_start_date = g_appr_period_rec.start_date OR pa.appraisal_period_start_date = ppf.start_date)
        AND    pa.overall_performance_level_id IS NULL;
   --
   --
   TYPE r_rating_summary IS RECORD (rating_level_id   NUMBER(15),
                                    rating_level_name VARCHAR2(100),
                                    direct_count      NUMBER(15),
                                    total_count       NUMBER(15) );
   TYPE t_rating_summary IS TABLE OF r_rating_summary INDEX BY BINARY_INTEGER;
   l_rating_summary t_rating_summary;
   l_direct_count NUMBER(15);
   l_tot_count    NUMBER(15);
   l_total_unrated_count NUMBER(15);
   l_direct_unrated_count NUMBER(15);
   --
  BEGIN
  --
     hr_utility.set_location('Entering:'||l_proc,10);
     FOR i IN g_rating_levels.FIRST .. LEAST(g_rating_levels.LAST,20)-- only upto 20 levels
     LOOP
        l_rating_summary(i).rating_level_id  :=  g_rating_levels(i).rating_level_id;
        l_rating_summary(i).rating_level_name :=  g_rating_levels(i).level_name;
        OPEN  csr_direct_summary(p_plan_id
                                ,p_supervisor_id
                                ,p_effective_date
                                 ,g_rating_levels(i).rating_level_id);
        FETCH csr_direct_summary INTO l_direct_count;
        CLOSE csr_direct_summary;
        OPEN  csr_total_summary(p_plan_id
                                ,p_supervisor_id
                                ,p_effective_date
                                 ,g_rating_levels(i).rating_level_id);
        FETCH csr_total_summary INTO l_tot_count;
        CLOSE csr_total_summary;
        l_rating_summary(i).direct_count := NVL(l_direct_count,0);
        l_rating_summary(i).total_count  := NVL(l_tot_count,0);
     END LOOP;
     FOR i IN (l_rating_summary.COUNT+1) .. 20
     LOOP
       l_rating_summary(i).rating_level_id  := NULL;
       l_rating_summary(i).rating_level_name:= NULL;
       l_rating_summary(i).direct_count     := 0;
       l_rating_summary(i).total_count      := 0;
     END LOOP;
     OPEN  csr_total_unrated(p_plan_id
                             ,p_supervisor_id
                             ,p_effective_date);
     FETCH csr_total_unrated INTO l_total_unrated_count;
     CLOSE csr_total_unrated;
     OPEN  csr_directs_unrated(p_plan_id
                             ,p_supervisor_id
                             ,p_effective_date);
     FETCH csr_directs_unrated INTO l_direct_unrated_count;
     CLOSE csr_directs_unrated;

     --
     INSERT INTO PER_WPM_APPRAISAL_SUMMARY
      (
 wpm_appraisal_summary_id ,
 plan_id                  ,
 appraisal_period_id      ,
 supervisor_person_id     ,
 supervisor_name          ,
 level_1_id               ,
 level_1_name             ,
 level_1_direct_count     ,
 level_1_total_count      ,
 level_2_id               ,
 level_2_name             ,
 level_2_direct_count     ,
 level_2_total_count      ,
 level_3_id               ,
 level_3_name             ,
 level_3_direct_count     ,
 level_3_total_count      ,
 level_4_id               ,
 level_4_name             ,
 level_4_direct_count     ,
 level_4_total_count      ,
 level_5_id               ,
 level_5_name             ,
 level_5_direct_count     ,
 level_5_total_count      ,
 level_6_id               ,
 level_6_name             ,
 level_6_direct_count     ,
 level_6_total_count      ,
 level_7_id               ,
 level_7_name             ,
 level_7_direct_count     ,
 level_7_total_count      ,
 level_8_id               ,
 level_8_name             ,
 level_8_direct_count     ,
 level_8_total_count      ,
 level_9_id               ,
 level_9_name             ,
 level_9_direct_count     ,
 level_9_total_count      ,
 level_10_id              ,
 level_10_name            ,
 level_10_direct_count    ,
 level_10_total_count     ,
 level_11_id              ,
 level_11_name            ,
 level_11_direct_count    ,
 level_11_total_count     ,
 level_12_id              ,
 level_12_name            ,
 level_12_direct_count    ,
 level_12_total_count     ,
 level_13_id              ,
 level_13_name            ,
 level_13_direct_count    ,
 level_13_total_count     ,
 level_14_id              ,
 level_14_name            ,
 level_14_direct_count    ,
 level_14_total_count     ,
 level_15_id              ,
 level_15_name            ,
 level_15_direct_count    ,
 level_15_total_count     ,
 level_16_id              ,
 level_16_name            ,
 level_16_direct_count    ,
 level_16_total_count     ,
 level_17_id              ,
 level_17_name            ,
 level_17_direct_count    ,
 level_17_total_count     ,
 level_18_id              ,
 level_18_name            ,
 level_18_direct_count    ,
 level_18_total_count     ,
 level_19_id              ,
 level_19_name            ,
 level_19_direct_count    ,
 level_19_total_count     ,
 level_20_id              ,
 level_20_name            ,
 level_20_direct_count    ,
 level_20_total_count     ,
 norating_direct_count    ,
 norating_total_count     )
 VALUES
 (
  PER_WPM_APPRAISAL_SUMMARY_S.nextval
 ,p_plan_id
 ,g_appr_period_rec.appraisal_period_id
 ,p_supervisor_id
 ,p_supervisor_name
 ,l_rating_summary(1).rating_level_id
 ,l_rating_summary(1).rating_level_name
 ,l_rating_summary(1).direct_count
 ,l_rating_summary(1).total_count
 ,l_rating_summary(2).rating_level_id
 ,l_rating_summary(2).rating_level_name
 ,l_rating_summary(2).direct_count
 ,l_rating_summary(2).total_count
 ,l_rating_summary(3).rating_level_id
 ,l_rating_summary(3).rating_level_name
 ,l_rating_summary(3).direct_count
 ,l_rating_summary(3).total_count
 ,l_rating_summary(4).rating_level_id
 ,l_rating_summary(4).rating_level_name
 ,l_rating_summary(4).direct_count
 ,l_rating_summary(4).total_count
 ,l_rating_summary(5).rating_level_id
 ,l_rating_summary(5).rating_level_name
 ,l_rating_summary(5).direct_count
 ,l_rating_summary(5).total_count
 ,l_rating_summary(6).rating_level_id
 ,l_rating_summary(6).rating_level_name
 ,l_rating_summary(6).direct_count
 ,l_rating_summary(6).total_count
 ,l_rating_summary(7).rating_level_id
 ,l_rating_summary(7).rating_level_name
 ,l_rating_summary(7).direct_count
 ,l_rating_summary(7).total_count
 ,l_rating_summary(8).rating_level_id
 ,l_rating_summary(8).rating_level_name
 ,l_rating_summary(8).direct_count
 ,l_rating_summary(8).total_count
 ,l_rating_summary(9).rating_level_id
 ,l_rating_summary(9).rating_level_name
 ,l_rating_summary(9).direct_count
 ,l_rating_summary(9).total_count
 ,l_rating_summary(10).rating_level_id
 ,l_rating_summary(10).rating_level_name
 ,l_rating_summary(10).direct_count
 ,l_rating_summary(10).total_count
 ,l_rating_summary(11).rating_level_id
 ,l_rating_summary(11).rating_level_name
 ,l_rating_summary(11).direct_count
 ,l_rating_summary(11).total_count
 ,l_rating_summary(12).rating_level_id
 ,l_rating_summary(12).rating_level_name
 ,l_rating_summary(12).direct_count
 ,l_rating_summary(12).total_count
 ,l_rating_summary(13).rating_level_id
 ,l_rating_summary(13).rating_level_name
 ,l_rating_summary(13).direct_count
 ,l_rating_summary(13).total_count
 ,l_rating_summary(14).rating_level_id
 ,l_rating_summary(14).rating_level_name
 ,l_rating_summary(14).direct_count
 ,l_rating_summary(14).total_count
 ,l_rating_summary(15).rating_level_id
 ,l_rating_summary(15).rating_level_name
 ,l_rating_summary(15).direct_count
 ,l_rating_summary(15).total_count
 ,l_rating_summary(16).rating_level_id
 ,l_rating_summary(16).rating_level_name
 ,l_rating_summary(16).direct_count
 ,l_rating_summary(16).total_count
 ,l_rating_summary(17).rating_level_id
 ,l_rating_summary(17).rating_level_name
 ,l_rating_summary(17).direct_count
 ,l_rating_summary(17).total_count
 ,l_rating_summary(18).rating_level_id
 ,l_rating_summary(18).rating_level_name
 ,l_rating_summary(18).direct_count
 ,l_rating_summary(18).total_count
 ,l_rating_summary(19).rating_level_id
 ,l_rating_summary(19).rating_level_name
 ,l_rating_summary(19).direct_count
 ,l_rating_summary(19).total_count
 ,l_rating_summary(20).rating_level_id
 ,l_rating_summary(20).rating_level_name
 ,l_rating_summary(20).direct_count
 ,l_rating_summary(20).total_count
 ,l_direct_unrated_count
 ,l_total_unrated_count);
     --
     hr_utility.set_location('Leaving:'||l_proc,100);
  --
  END compute_summary_for_supervisor;
  --
  --
  PROCEDURE populate_appraisal_summary(p_plan_id IN NUMBER
                                      ,p_appraisal_period_id IN NUMBER
                                      ,p_effective_date IN DATE) IS
   l_proc VARCHAR2(80) := g_package||'populate_appraisal_summary';
   --
   CURSOR csr_appr_period_dtls(p_appraisal_period_id IN NUMBER) IS
     SELECT  pap.appraisal_period_id
            ,pap.start_date
            ,pap.end_date
            ,pat.rating_scale_id
     FROM    per_appraisal_periods pap
            ,per_appraisal_templates pat
     WHERE   pap.appraisal_period_id = p_appraisal_period_id
     AND     pap.appraisal_template_id = pat.appraisal_template_id;
   --
   --
   CURSOR csr_appr_levels (p_rating_scale_id IN NUMBER) IS
     SELECT  rating_level_id
            ,step_value||'-'||name "LEVEL_NAME"
      FROM  per_rating_levels
      WHERE rating_scale_id = p_rating_scale_id
      ORDER BY step_value;
   --
   --
   CURSOR csr_plan_managers(p_plan_id IN NUMBER) IS
     SELECT distinct supervisor_person_id
                   , supervisor_name
     FROM   per_wpm_plan_hierarchy
     WHERE  plan_id = p_plan_id;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,10);
    OPEN csr_appr_period_dtls(p_appraisal_period_id);
    FETCH csr_appr_period_dtls INTO g_appr_period_rec;
    IF csr_appr_period_dtls%NOTFOUND THEN
       fnd_file.put_line(fnd_file.LOG,'Invalid Appraisal Period selected. Cannot Proceed.');
       g_errmsg := 'Invalid Appraisal Period selected. Cannot Proceed.';--- New message to be created.
       CLOSE csr_appr_period_dtls;
       RETURN;
     END IF;
    CLOSE csr_appr_period_dtls;
    DELETE PER_WPM_APPRAISAL_SUMMARY
    WHERE  plan_id = p_plan_id
    AND    appraisal_period_id = g_appr_period_rec.appraisal_period_id;
    COMMIT;
    g_rating_levels.DELETE;
    OPEN csr_appr_levels(g_appr_period_rec.rating_scale_id);
    FETCH csr_appr_levels BULK COLLECT INTO g_rating_levels;
    CLOSE csr_appr_levels;
    FOR i IN csr_plan_managers(p_plan_id)
    LOOP
       hr_utility.trace('Computing totals for : '||i.supervisor_name);
       compute_summary_for_supervisor(p_plan_id => p_plan_id
                                     ,p_effective_date => p_effective_date
                                     ,p_supervisor_id => i.supervisor_person_id
                                     ,p_supervisor_name => i.supervisor_name);
    END LOOP;
    /*
     create a row with supervisor_person_id as -1 to store the run_date into the
     supervisor_name column in canonical format. level_1_id will store the request Id.
    */
    INSERT INTO PER_WPM_APPRAISAL_SUMMARY
      (
       wpm_appraisal_summary_id ,
       plan_id                  ,
       appraisal_period_id      ,
       supervisor_person_id     ,
       supervisor_name          ,
       level_1_id    )
     VALUES
      (PER_WPM_APPRAISAL_SUMMARY_S.nextval
      ,p_plan_id
      ,g_appr_period_rec.appraisal_period_id
      ,-1
      ,fnd_date.date_to_canonical(sysdate)
      ,fnd_global.conc_request_id);
    --
    COMMIT;
    --
    hr_utility.set_location('Leaving:'||l_proc,100);
  END populate_appraisal_summary;
 --
 --
 FUNCTION get_summary_date(p_plan_id IN NUMBER
                          ,p_appraisal_period_id IN NUMBER) RETURN DATE IS
 CURSOR csr_get_date(p_plan_id NUMBER
                    ,p_period_id NUMBER) IS
      SELECT NVL(fnd_date.canonical_to_date(supervisor_name),SYSDATE)  -- supervisor_name is used to store the run date with id as -1.
      FROM   per_wpm_appraisal_summary
      WHERE  plan_id = p_plan_id
      AND    appraisal_period_id = p_period_id
      AND    supervisor_person_id = -1;
 l_summary_date DATE;
 BEGIN
  OPEN csr_get_date(p_plan_id,p_appraisal_period_id);
  FETCH csr_get_date INTO l_summary_date;
  CLOSE csr_get_date;

  RETURN l_summary_date;
 END get_summary_date;
END PER_WPM_SUMMARY_PKG;

/
