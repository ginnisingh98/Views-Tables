--------------------------------------------------------
--  DDL for Package Body BEN_TCS_STMT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TCS_STMT_PROCESS" as
/* $Header: bentcssg.pkb 120.18.12010000.4 2009/04/15 13:39:29 vkodedal ship $ */
g_package                VARCHAR2 (80)           := 'BEN_TCS_STMT_PROCESS';
   g_proc                   VARCHAR2 (80);
   g_actn                   VARCHAR2 (2000);
   g_run_type               VARCHAR2(30);
   g_validate              VARCHAR2(1);
   l_rep_rec               g_rep_rec_tab ;

   item_hrchy_values BEN_TCS_STMT_VALID_HRCHY.cat_item_hrchy_table ;
   subcat_hrchy_values BEN_TCS_STMT_VALID_HRCHY.cat_subcat_hrchy_table ;

   TYPE g_number_type IS VARRAY (200) OF NUMBER;
   TYPE g_exceution_params_rec IS RECORD (
       Number_Of_BGs       NUMBER (15),
       stmt_errors         NUMBER (15),
       persons_selected    NUMBER (15),                            -- PER_SLCTD
       persons_proc_succ   NUMBER (15),                            -- PER_PROC_SUCC
       persons_errored     NUMBER (15),                            -- PER_ERR
       business_group_id   NUMBER (15),
       benefit_action_id   NUMBER (15),
       start_date          DATE,
       end_date            DATE,
       start_time          VARCHAR (90),
       end_time            VARCHAR (90)
     );

  g_exec_param_rec         g_exceution_params_rec;

  CURSOR suc_ppl ( v_benefit_action_id IN NUMBER) IS
      SELECT
            COUNT(UNIQUE(person_id)) cnt_ppl
                FROM  ben_tcs_report_details
                WHERE  benefit_action_id = v_benefit_action_id
                AND stmt_created ='Y' ;

   CURSOR err_ppl ( v_benefit_action_id IN NUMBER) IS
      SELECT
            COUNT(UNIQUE(person_id)) cnt_ppl
                FROM  ben_tcs_report_details
                WHERE  benefit_action_id = v_benefit_action_id
                AND stmt_created ='E' ;

--
--
-- ============================================================================
--                            <<WRITE>>
-- ============================================================================
--
   PROCEDURE WRITE (p_string IN VARCHAR2)
   IS
   BEGIN
      ben_batch_utils.WRITE (p_string);
   END WRITE ;


--
--
-- ============================================================================
--                            <<check_multiple_stmt>>
-- ============================================================================
--
    FUNCTION check_multiple_stmt (
          p_person_id           IN              NUMBER DEFAULT NULL,
          p_period_start_date   IN              DATE,
          p_period_end_date     IN              DATE,
          p_stmt_id             IN              NUMBER
     )RETURN BOOLEAN
   IS

     CURSOR c_person_stmt(  p_person_id            IN              NUMBER DEFAULT NULL,
                            p_period_start_date    IN              DATE,
                            p_period_end_date      IN              DATE,
                            p_stmt_id              IN              NUMBER)
     IS
     SELECT per_perd.stmt_id
         FROM ben_tcs_per_stmt_perd per_perd, ben_tcs_stmt_perd perd
         WHERE per_perd.stmt_id <> p_stmt_id
         AND   per_perd.person_id  = p_person_id
         AND   per_perd.end_date = p_period_end_date
         AND   perd.stmt_perd_id  = per_perd.stmt_perd_id
         AND   perd.start_date = p_period_start_date ;

     BEGIN
     g_proc := 'check_multiple_stmt';
     hr_utility.set_location('Entering '||g_proc,10);
     g_actn := 'check_multiple_stmt: ' ||p_person_id||'statement id : '|| p_stmt_id
        || 'period start date :' ||p_period_start_date || 'period end date : ' || p_period_end_date ;
     WRITE (g_actn );
     WRITE('In procedure :' || g_proc);

     OPEN c_person_stmt (p_person_id , p_period_start_date ,p_period_end_date ,p_stmt_id);
     IF c_person_stmt%FOUND THEN
        hr_utility.set_location('return True From '||g_proc,10.1);
        return TRUE;
     ELSE
        hr_utility.set_location('return False From '||g_proc,10.2);
        return false;
     END IF;

     hr_utility.set_location('Leaving  '||g_proc,11);
     WRITE('Leaving check_multiple_stmt');
   END check_multiple_stmt;

--
--
-- ============================================================================
--                            <<get_name>>
-- ============================================================================
--

    PROCEDURE get_name(
            p_bg_id IN NUMBER ,
            v_ee_id IN NUMBER DEFAULT NULL ,
            v_period_end_date IN DATE,
            p_bg_name OUT NOCOPY VARCHAR2 ,
            p_ee_name OUT NOCOPY VARCHAR2  )
    IS
    BEGIN
      g_proc := 'get_name';
      WRITE('In procedure :' || g_proc);
      hr_utility.set_location('Entering '||g_proc,20);

      SELECT bg.name bg_name
      INTO p_bg_name
      FROM per_business_groups_perf bg
      WHERE
        bg.business_group_id = p_bg_id
        AND v_period_end_date >= bg.date_from
        AND (   bg.date_to IS NULL OR bg.date_to >= v_period_end_date);

      IF (v_ee_id is not null ) THEN
        SELECT eligy.name
        INTO  p_ee_name
        FROM BEN_ELIGY_PRFL_F eligy
        WHERE
             eligy.ELIGY_PRFL_ID(+) = v_ee_id
             AND v_period_end_date  >= eligy.effective_start_date(+)
             AND  (eligy.effective_end_date IS NULL  OR eligy.effective_end_date >= v_period_end_date) ;
      END IF;

      hr_utility.set_location('Leaving '||g_proc,21);
      WRITE('Leaving get_name');
    END get_name;

--
--
-- ============================================================================
--                            <<get_emp_detail>>
-- ============================================================================
--

    PROCEDURE get_emp_detail(
            p_assignment_id  IN NUMBER  DEFAULT NULL ,
            p_person_id IN NUMBER DEFAULT NULL ,
            p_period_end_date IN DATE,
            p_job OUT NOCOPY VARCHAR2 ,
            p_emp_name OUT NOCOPY VARCHAR2,
            p_emp_num OUT NOCOPY VARCHAR2,
            p_bg OUT NOCOPY VARCHAR2 )
    IS
    BEGIN
       g_proc := 'get_emp_detail';
       WRITE('In procedure :' || g_proc);
       hr_utility.set_location('Entering '||g_proc,30);

     IF ( p_assignment_id IS NOT NULL) THEN
       SELECT jobs.name
       INTO p_job
       FROM  per_jobs_tl jobs , per_all_assignments_f assign,
        ( SELECT assignment.assignment_id , max(assignment.effective_end_date)end_date
          FROM per_all_assignments_f assignment
          WHERE  assignment.assignment_id = p_assignment_id GROUP  BY assignment_id) b
       WHERE
              assign.effective_end_date = b.end_date
              AND assign.assignment_id = b.assignment_id
              AND assign.job_id=jobs.job_id(+)
              AND jobs.language (+) = userenv('lang')
              ORDER BY jobs.name;
        END IF;

          SELECT employee_number ,full_name ,bg.name
        INTO p_emp_num , p_emp_name , p_bg
        FROM per_all_people_f ppl ,per_business_groups_perf bg
        WHERE
                ppl.person_id = p_person_id
                AND trunc(sysdate) between ppl.effective_start_date and ppl.effective_end_date
                AND  bg.business_group_id = ppl.business_group_id
                AND p_period_end_date >= bg.date_from
			    AND (   bg.date_to IS NULL OR bg.date_to >= p_period_end_date);

        WRITE('Leaving get_emp_detail');
        hr_utility.set_location('Leaving '||g_proc,31);
    END get_emp_detail;

    --
-- ============================================================================
--                            <<print_cache>>
-- ============================================================================
--


  PROCEDURE print_cache
  IS
    l_evaluated    NUMBER (9) := 0;
    l_successful   NUMBER (9) := 0;
    l_error        NUMBER (9) := 0;
    l_closed_le    NUMBER (9) := 0;
    l_open_le      NUMBER (9) := 0;
    l_previous     NUMBER     := -1;
  BEGIN
    g_proc := 'print_cache';
    WRITE ('Time before printing cache '||to_char(sysdate,'yyyy/mm/dd:hh:mi:ssam'));
    WRITE ('In Procedure' ||g_proc);
    hr_utility.set_location('Entering '||g_proc,40);

    FOR i IN 1 .. l_rep_rec.COUNT
    LOOP
        IF (l_rep_rec(i).P_TYPE = -1) THEN
            INSERT INTO BEN_TCS_REPORT_DETAILS(
                BENEFIT_ACTION_ID,
                BUSINESS_GROUP_ID,
                BUSINESS_GROUP_NAME,
                ELIGY_ID,
                ELIGY_PROF_NAME,
                STMT_ID,
                STMT_NAME,
                SETUP_VALID,
                TOTAL_PERSONS,
                BEN_TCS_RPT_DET_ID)
           VALUES
            (
                l_rep_rec(i).BENEFIT_ACTION_ID,
                l_rep_rec(i).BUSINESS_GROUP_ID,
                l_rep_rec(i).BUSINESS_GROUP_NAME,
                l_rep_rec(i).ELIGY_ID,
                l_rep_rec(i).ELIGY_PROF_NAME,
                l_rep_rec(i).STMT_ID,
                l_rep_rec(i).STMT_NAME,
                l_rep_rec(i).SETUP_VALID,
                l_rep_rec(i).TOTAL_PERSONS,
                BEN_TCS_REPORT_DETAILS_S.NEXTVAL
            );
      ELSE
            INSERT INTO BEN_TCS_REPORT_DETAILS(
                BENEFIT_ACTION_ID,
                BUSINESS_GROUP_ID ,
                BUSINESS_GROUP_NAME,
                ASSIGNMENT_NUMBER,
                STMT_CREATED,
                ASSIGNMENT_ID ,
                PERSON_ID,
                STMT_ID,
                STMT_NAME,
                FULL_NAME,
                EMPLOYEE_NUMBER,
                JOB_NAME,
                BEN_TCS_RPT_DET_ID,
                ERROR
            )
            VALUES
            (
                 l_rep_rec(i).BENEFIT_ACTION_ID,
                 l_rep_rec(i).BUSINESS_GROUP_ID,
                 l_rep_rec(i).BUSINESS_GROUP_NAME,
                 l_rep_rec(i).ASSIGNMENT_NUMBER,
                 l_rep_rec(i).STMT_CREATED,
                 l_rep_rec(i).ASSIGNMENT_ID,
                 l_rep_rec(i).PERSON_ID,
                 l_rep_rec(i).STMT_ID,
                 l_rep_rec(i).STMT_NAME,
                 l_rep_rec(i).FULL_NAME,
                 l_rep_rec(i).EMPLOYEE_NUMBER,
                 l_rep_rec(i).JOB_NAME,
                 BEN_TCS_REPORT_DETAILS_S.NEXTVAL,
                 l_rep_rec(i).ERROR
            );
    END IF;
    END LOOP;
    hr_utility.set_location('Leaving '||g_proc,41);
    WRITE('Leaving print_cache');
  END print_cache;


--
-- ============================================================================
--                            <<hrchy_set>>
-- ============================================================================
--
  PROCEDURE hrchy_set(p_benefit_action_id IN NUMBER)
  IS

    TYPE num_table  IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;


    item_id_found             NUMBER;
    item_entry_found          NUMBER;
    processed_cat             num_table;
    row_in_cat                num_table;
    all_obj_cat               num_table;
    cat_id_found              VARCHAR2(1);
    cat_entry_found           NUMBER;
    l_stmt_id                 NUMBER;
    l_perd_id                 NUMBER;
    cat_cnt                   NUMBER:= 1;
    row_cnt                   NUMBER :=1;
    obj_cnt                   NUMBER := 1;
    l_row_id                  NUMBER;
    l_obj_id                    NUMBER;
    cat_type                 VARCHAR2(30);

    CURSOR c_get_item (v_item_id IN NUMBER , v_period_id IN NUMBER)
     IS
        SELECT DISTINCT item_id
            FROM ben_tcs_per_item
            WHERE item_id = v_item_id
            AND stmt_perd_id = v_period_id ;

    CURSOR c_stmt_period (v_stmt_id IN NUMBER , v_perd_id IN NUMBER )
    IS
            SELECT  stmt_id ,stmt_perd_id
              FROM ben_tcs_per_stmt_perd
              WHERE stmt_id = v_stmt_id
              AND stmt_perd_id  = v_perd_id;
   stmt_perd_rec c_stmt_period%ROWTYPE;

   CURSOR c_per_stmt_period (v_perd_id IN NUMBER)
   IS
            SELECT stmt_perd_id
              FROM ben_tcs_per_stmt_perd
              WHERE stmt_perd_id = v_perd_id ;

  CURSOR c_per_stmt (v_stmt_id IN NUMBER)
   IS
            SELECT stmt_id
              FROM ben_tcs_per_stmt_perd
              WHERE stmt_id = v_stmt_id ;

   CURSOR c_item_hrchy_val(v_period_id IN NUMBER)
   IS
            SELECT row_in_cat_id , all_objects_in_cat_id
              FROM ben_tcs_cat_item_hrchy
              WHERE stmt_perd_id = v_period_id
              AND lvl_num = 1;

   item_hrchy_val_rec  c_item_hrchy_val%ROWTYPE;

   CURSOR c_cat_hrchy_val(v_period_id IN NUMBER)
   IS
            SELECT row_in_cat_id row_cat_id
              FROM ben_tcs_cat_subcat_hrchy
              WHERE stmt_perd_id = v_period_id
              AND lvl_num = 1;

   cat_hrchy_val_rec  c_cat_hrchy_val%ROWTYPE;

   CURSOR c_row_cat_id( row_id IN NUMBER , v_period_id IN NUMBER)
   IS
        SELECT  distinct nvl(item.stmt_perd_id,cat.stmt_perd_id )row_cat_id
            FROM ben_tcs_cat_item_hrchy item ,ben_tcs_cat_subcat_hrchy cat
            WHERE (item.row_in_cat_id  =row_id
            AND item.lvl_num =1
            AND item.stmt_perd_id <> v_period_id )
            OR( cat.row_in_cat_id  =row_id
            AND cat.lvl_num =1 AND cat.stmt_perd_id <> v_period_id);


   CURSOR c_obj_cat_id( obj_id IN NUMBER , v_period_id IN NUMBER)
   IS
        SELECT all_objects_in_cat_id
            FROM ben_tcs_cat_item_hrchy item
            WHERE item.all_objects_in_cat_id  =obj_id
            AND item.lvl_num =1
            AND item.stmt_perd_id <> v_period_id;


  BEGIN
     g_proc := 'Hierarchy set - hrchy_set';
     WRITE('In procedure :' || g_proc);
     hr_utility.set_location('Entering '||g_proc,50);

    OPEN suc_ppl(p_benefit_action_id ) ;
    FETCH suc_ppl INTO g_exec_param_rec.persons_proc_succ ;
    CLOSE suc_ppl;

    OPEN err_ppl(p_benefit_action_id ) ;
    FETCH err_ppl INTO g_exec_param_rec.persons_errored ;
    CLOSE err_ppl;

    SAVEPOINT HRCHY_GEN;
    IF (g_run_type = 'GEN') THEN
        IF ( g_exec_param_rec.persons_proc_succ > 0) THEN
        processed_cat.DELETE;
        hr_utility.set_location('Inside Hierarchy Generation ',51);
        FOR i IN 1 .. l_rep_rec.COUNT
        LOOP
            l_stmt_id := null;
            IF (l_rep_rec(i).P_TYPE = -1) THEN
            OPEN c_stmt_period (l_rep_rec(i).STMT_ID, l_rep_rec(i).PERIOD_ID );
            FETCH c_stmt_period
                INTO stmt_perd_rec ;
            IF (c_stmt_period%FOUND) THEN
                IF (stmt_perd_rec.stmt_id IS NOT NULL ) THEN
               -- WRITE('Updating the statement generated flag .Stmt Id :'|| stmt_perd_rec.stmt_id );
                hr_utility.set_location('Updating the statement generated flag .Stmt Id : ',52);
                             UPDATE  BEN_TCS_STMT
                                SET stmt_generated_flag = 'Y'
                                WHERE stmt_id  = stmt_perd_rec.stmt_id ;
                  END IF;
                  IF (stmt_perd_rec.stmt_perd_id IS NOT NULL ) THEN
                  --WRITE('Updating the statement generated flag .Stmt Period Id :'|| stmt_perd_rec.stmt_perd_id );
                  hr_utility.set_location('Updating the statement generated flag .Stmt Period Id : ',53);
                             UPDATE BEN_TCS_STMT_PERD
                                SET stmt_generated_flag = 'STMTGEN'
                                WHERE stmt_perd_id  = stmt_perd_rec.stmt_perd_id ;
                 END IF;
             END IF;
          CLOSE c_stmt_period ;

            END IF;
        END LOOP;
   hr_utility.set_location('before deleting  from cat_item_hrchy: ',54);
        FOR i IN 1.. item_hrchy_values.COUNT
  	    LOOP
          OPEN c_get_item (item_hrchy_values(i).item_id, item_hrchy_values(i).perd_id );
            FETCH c_get_item
            INTO item_id_found ;
           IF ( c_get_item%FOUND) THEN
             DELETE
                FROM ben_tcs_cat_item_hrchy
                WHERE item_id = item_hrchy_values(i).item_id
                AND stmt_perd_id = item_hrchy_values(i).perd_id ;
           END IF;
           CLOSE c_get_item ;
        END LOOP;
       hr_utility.set_location('before inserting into cat_item_hrchy: ',55);
  	   FOR i IN 1.. item_hrchy_values.COUNT
  	    LOOP
  	      item_id_found := null;
          OPEN c_get_item (item_hrchy_values(i).item_id, item_hrchy_values(i).perd_id );
            FETCH c_get_item
            INTO item_id_found ;
           IF ( c_get_item%FOUND) THEN
	         INSERT INTO ben_tcs_cat_item_hrchy
		                                 (stmt_id, cat_id,
		                                  item_id,
		                                  lvl_num ,cntr_cd, row_in_cat_id , all_objects_in_cat_id, stmt_perd_id
		                                 )
		                          VALUES (item_hrchy_values(i).stmt_id,
		                                  item_hrchy_values(i).cat_id,
		                                  item_hrchy_values(i).item_id,
		                                  item_hrchy_values(i).lvl_num,
		                                  item_hrchy_values(i).cntr_cd ,
		                                  item_hrchy_values(i).row_cat_id,
		                                  item_hrchy_values(i).all_objects_id,
		                                  item_hrchy_values(i).perd_id
                                 );

               processed_cat(cat_cnt) :=item_hrchy_values(i).cat_id;
               cat_cnt := cat_cnt +1;

                IF (item_hrchy_values(i).lvl_num = 1) THEN

                hr_utility.set_location('Updating the statement generated flag .all_objects_in_cat_id:'|| item_hrchy_values(i).all_objects_id ,56);
                UPDATE BEN_TCS_ALL_OBJECTS_IN_CAT
                        SET stmt_generated_flag = 'Y'
                        WHERE all_objects_in_cat_id = item_hrchy_values(i).all_objects_id;

                hr_utility.set_location('Updating the statement generated flag .row_in_cat_id:'|| item_hrchy_values(i).row_cat_id,57);
                UPDATE BEN_TCS_ROW_IN_CAT
                        SET stmt_generated = 'Y'
                        WHERE row_in_cat_id =item_hrchy_values(i).row_cat_id;
                END IF;
           END IF;
           CLOSE c_get_item ;

  	 END LOOP;
    hr_utility.set_location('after inserting into cat_item_hrchy: ',58);
  	 FOR i IN 1.. subcat_hrchy_values.COUNT
  	 LOOP

        SELECT cat_type_cd into cat_type
  	             FROM BEN_TCS_CAT
  	             WHERE CAT_ID = subcat_hrchy_values(i).subcat_id;
  	     IF (cat_type = 'STKOPTEXT') THEN
               processed_cat(cat_cnt) :=subcat_hrchy_values(i).subcat_id ;
                cat_cnt := cat_cnt +1;
  	     END IF;

  	 END LOOP;
    hr_utility.set_location('before deleting  from cat_subcat_hrchy: ',59);
  	 FOR i IN 1.. subcat_hrchy_values.COUNT
  	    LOOP
          cat_id_found := null;
  	      FOR j IN 1.. processed_cat.COUNT
  	      LOOP
  	         IF ( processed_cat(j) = subcat_hrchy_values(i).subcat_id ) THEN
  	                cat_id_found := 'Y';
                    EXIT;
             END IF;
  	      END LOOP;

  	      IF( cat_id_found ='Y')THEN

  	            DELETE
                FROM ben_tcs_cat_subcat_hrchy
                WHERE  sub_cat_id =subcat_hrchy_values(i).subcat_id
                AND stmt_perd_id = subcat_hrchy_values(i).perd_id ;
           END IF;
     END LOOP;
       hr_utility.set_location('before inserting  into cat_subcat_hrchy: ',60);
  	 FOR i IN 1.. subcat_hrchy_values.COUNT
  	    LOOP
          cat_id_found := null;
  	      cat_entry_found := null;
         FOR j IN 1.. processed_cat.COUNT
  	      LOOP
  	         IF ( processed_cat(j) = subcat_hrchy_values(i).subcat_id ) THEN
  	                cat_id_found := 'Y';
                    EXIT;
             END IF;
  	      END LOOP;

  	      IF( cat_id_found ='Y')THEN
  		         INSERT INTO ben_tcs_cat_subcat_hrchy
		                                 (stmt_id, cat_id,
		                                  sub_cat_id,
		                                  lvl_num,row_in_cat_id ,stmt_perd_id
		                                 )
		                          VALUES (subcat_hrchy_values(i).stmt_id,
		                                  subcat_hrchy_values(i).cat_id,
		                                  subcat_hrchy_values(i).subcat_id,
		                                  subcat_hrchy_values(i).lvl_num,
		                                  subcat_hrchy_values(i).row_cat_id,
                                         subcat_hrchy_values(i).perd_id  );
               IF ( subcat_hrchy_values(i).lvl_num =1) THEN
               hr_utility.set_location('Updating the statement generated flag :sub_cat .row_in_cat_id:'|| subcat_hrchy_values(i).row_cat_id, 61);
                 UPDATE BEN_TCS_ROW_IN_CAT
                      SET stmt_generated = 'Y'
                     WHERE row_in_cat_id = subcat_hrchy_values(i).row_cat_id;
               END IF;
         END IF;
      END LOOP;
      END IF;
     IF (g_validate = 'Y')  THEN
          ROLLBACK to HRCHY_GEN;
     END IF;
   END IF;
     IF (g_run_type = 'PURGE') THEN
          IF ( g_exec_param_rec.persons_proc_succ > 0) THEN
           FOR i IN 1 .. l_rep_rec.COUNT
           LOOP
               l_perd_id := null;
               l_stmt_id  := null;
               row_in_cat.DELETE ;
               all_obj_cat.DELETE ;
               row_cnt := 1;
               obj_cnt := 1;
                IF (l_rep_rec(i).P_TYPE = -1) THEN
                    OPEN c_per_stmt_period (l_rep_rec(i).PERIOD_ID );
                     FETCH c_per_stmt_period
                      INTO l_perd_id ;
                      IF (c_per_stmt_period%NOTFOUND) THEN
                        hr_utility.set_location('Statement Generated Flag reset for period' || l_rep_rec(i).PERIOD_ID ,62);
                        UPDATE BEN_TCS_STMT_PERD
                           SET stmt_generated_flag = 'STMTNGEN'
                           WHERE stmt_perd_id  = l_rep_rec(i).PERIOD_ID ;

                       OPEN c_item_hrchy_val ( l_rep_rec(i).PERIOD_ID);
                       LOOP
                            FETCH c_item_hrchy_val
                                INTO item_hrchy_val_rec;
                            EXIT WHEN c_item_hrchy_val%NOTFOUND;
                                row_in_cat(row_cnt) :=item_hrchy_val_rec.row_in_cat_id;
                                row_cnt := row_cnt +1;
                                all_obj_cat(obj_cnt) := item_hrchy_val_rec.all_objects_in_cat_id;
                                obj_cnt := obj_cnt +1;
                       END LOOP;
                       CLOSE c_item_hrchy_val;

                       OPEN c_cat_hrchy_val ( l_rep_rec(i).PERIOD_ID);
                       LOOP
                            FETCH c_cat_hrchy_val
                                INTO cat_hrchy_val_rec;
                            EXIT WHEN c_cat_hrchy_val%NOTFOUND;
                                row_in_cat(row_cnt) :=cat_hrchy_val_rec.row_cat_id;
                                row_cnt := row_cnt +1;
                            END LOOP;
                       CLOSE c_cat_hrchy_val;

                        hr_utility.set_location('Deleting Item Hrchy for period' || l_rep_rec(i).PERIOD_ID ,63);
                       DELETE
                            FROM  ben_tcs_cat_item_hrchy
                            WHERE stmt_perd_id = l_rep_rec(i).PERIOD_ID;

                        hr_utility.set_location('Deleting Subcat Hrchy for period' || l_rep_rec(i).PERIOD_ID ,64);
                       DELETE
                            FROM  ben_tcs_cat_subcat_hrchy
                            WHERE stmt_perd_id = l_rep_rec(i).PERIOD_ID;

                       FOR j IN 1..row_in_cat.COUNT
                       LOOP
                          OPEN c_row_cat_id(row_in_cat(j) ,l_rep_rec(i).PERIOD_ID);
                          FETCH c_row_cat_id INTO l_row_id;
                          IF (c_row_cat_id % NOTFOUND) THEN
                          hr_utility.set_location('Stmt Generated flag reset for row' ||  row_in_cat(j),65);
                                UPDATE ben_tcs_row_in_cat
                                        SET stmt_generated = null
                                        WHERE row_in_cat_id = row_in_cat(j);
                          END IF;
                           CLOSE c_row_cat_id;
                       END LOOP;
                       FOR j IN 1..all_obj_cat.COUNT
                       LOOP
                          OPEN c_obj_cat_id(all_obj_cat(j),l_rep_rec(i).PERIOD_ID);
                          FETCH c_obj_cat_id INTO l_obj_id;
                          IF (c_obj_cat_id % NOTFOUND) THEN
                          hr_utility.set_location('Stmt Generated flag reset for obj' ||  all_obj_cat(j),66);
                                UPDATE ben_tcs_all_objects_in_cat
                                        SET stmt_generated_flag = null
                                        WHERE all_objects_in_cat_id = all_obj_cat(j);
                          END IF;
                          CLOSE c_obj_cat_id ;
                       END LOOP;

                     END IF;

                CLOSE c_per_stmt_period ;
                OPEN c_per_stmt(l_rep_rec(i).STMT_ID );
                FETCH c_per_stmt
                   INTO l_stmt_id ;
                IF (c_per_stmt%NOTFOUND) THEN
                   hr_utility.set_location('Stmt Generated flag reset for stmt' || l_rep_rec(i).STMT_ID,67);
                      UPDATE BEN_TCS_STMT
                           SET stmt_generated_flag = 'N'
                           WHERE stmt_id  = l_rep_rec(i).STMT_ID;
                END IF;
                CLOSE c_per_stmt;
                END IF;
          END LOOP;
        END IF;
        IF (g_validate = 'Y')  THEN
            ROLLBACK to HRCHY_GEN;
        END IF;
     END IF;
         hr_utility.set_location('Leaving '||g_proc,68);
    WRITE('Leaving hrchy_set');
  END hrchy_set;

  PROCEDURE delete_hrchy
  IS
  BEGIN
        DELETE FROM ben_tcs_cat_item_hrchy
          WHERE cat_id = -999 and lvl_num = -1;

  END delete_hrchy;

--
-- ============================================================================
--                            <<End_process>>
-- ============================================================================
--
  PROCEDURE end_process (
    p_benefit_action_id   IN   NUMBER,
    p_person_selected     IN   NUMBER,
    p_business_group_id   IN   NUMBER DEFAULT NULL
  )
  IS
    l_batch_proc_id           NUMBER;
    l_object_version_number   NUMBER;

    BEGIN
    g_proc  := 'end_process';
     hr_utility.set_location('Leaving '||g_proc,69);
    --
    -- Get totals for unprocessed, processed successfully and errored
    --

    OPEN suc_ppl(p_benefit_action_id ) ;
    FETCH suc_ppl INTO g_exec_param_rec.persons_proc_succ ;
    CLOSE suc_ppl;

    OPEN err_ppl(p_benefit_action_id ) ;
    FETCH err_ppl INTO g_exec_param_rec.persons_errored ;
    CLOSE err_ppl;
    WRITE('benefit action Id : ' || p_benefit_action_id);

    ben_batch_proc_info_api.create_batch_proc_info
                                            (p_validate                  => FALSE
                                           , p_batch_proc_id             => l_batch_proc_id
                                           , p_benefit_action_id         => p_benefit_action_id
                                           , p_strt_dt                   => TRUNC
                                                                              (g_exec_param_rec.start_date
                                                                              )
                                           , p_end_dt                    => TRUNC (SYSDATE)
                                           , p_strt_tm                   => TO_CHAR
                                                                              (g_exec_param_rec.start_date
                                                                             , 'HH24:MI:SS'
                                                                              )
                                           , p_end_tm                    => TO_CHAR (SYSDATE
                                                                                   , 'HH24:MI:SS'
                                                                                    )
                                           , p_elpsd_tm                  => fnd_number.number_to_canonical
                                                                              ((DBMS_UTILITY.get_time
                                                                                - g_exec_param_rec.start_time
                                                                               )
                                               / 100
                                                                              )

                                           , p_per_slctd                 => p_person_selected
                                           , p_per_proc                  => g_exec_param_rec.Number_Of_BGs
                                           , p_per_unproc                => g_exec_param_rec.stmt_errors
                                           , p_per_proc_succ             => g_exec_param_rec.persons_proc_succ
                                           , p_per_err                   => g_exec_param_rec.persons_errored
                                           , p_business_group_id         => nvl(p_business_group_id,HR_GENERAL.GET_BUSINESS_GROUP_ID)
                                           , p_object_version_number     => l_object_version_number);

   -- print_cache;
   delete_hrchy;
    COMMIT;

    hr_utility.set_location('Leaving '||g_proc,70);
    WRITE('Leaving end_process');
  END end_process;




--
-- ============================================================================
--                            <<purge_person_stmt>>
-- ============================================================================
--

   PROCEDURE purge_person_stmt (
          p_validate           IN              VARCHAR2,
          p_person_id          IN              NUMBER DEFAULT NULL,
          p_stmt_id            IN              NUMBER DEFAULT NULL,
          p_stmt_perd_id       IN              NUMBER DEFAULT NULL,
          p_person_action_id   IN              NUMBER DEFAULT NULL,
          p_benefit_action_id  IN              NUMBER DEFAULT NULL ,
          p_business_group     IN              NUMBER DEFAULT NULL,
          p_period_end_date    IN              DATE DEFAULT NULL,
          p_run_type           IN              VARCHAR2
     )
   IS
        l_per_stmt_perd NUMBER;
        l_per_item NUMBER;
        p_job VARCHAR2(700);
        p_emp_name VARCHAR2(240);
        p_emp_num VARCHAR2(240) ;
        p_bg VARCHAR2(240);
        rep_count NUMBER;

       CURSOR c_asg_stmt ( v_per_stmt_perd_id IN NUMBER)
       IS
        SELECT ASG_STMT_ID ,assignment_number, assignment_id
        FROM ben_tcs_asg_stmt
        WHERE per_stmt_perd_id = v_per_stmt_perd_id;

      CURSOR c_per_item(v_asg_stmt_id IN NUMBER)
      IS
        SELECT per_item_id
        FROM ben_tcs_per_item
        WHERE ASG_STMT_ID = v_asg_stmt_id;

      asg_rec c_asg_stmt%ROWTYPE;
   BEGIN
        g_proc := 'purge_person_stmt';
        WRITE ('In Procedure' ||g_proc);
        hr_utility.set_location('Entering '||g_proc,71);

        WRITE ('===========purge statement for the person============');
        WRITE ('||Person Id             ' || p_person_id);
        WRITE ('||Statement id          ' || p_stmt_id);
        WRITE ('||Period    id          ' || p_stmt_perd_id);
        WRITE ('||Person Action id      ' || p_person_action_id);
        WRITE ('=======================================================');

        SAVEPOINT Purge ;

        SELECT per_stmt_perd_id
            INTO l_per_stmt_perd
            FROM ben_tcs_per_stmt_perd
            WHERE
                stmt_id = p_stmt_id
                AND stmt_perd_id = p_stmt_perd_id
                AND  person_id = p_person_id ;

        hr_utility.set_location ( 'delete per_stmt_perd_id  entry for per_stmt_perd_id :' || l_per_stmt_perd,72);

        DELETE
            FROM ben_tcs_per_stmt_perd
            WHERE per_stmt_perd_id = l_per_stmt_perd;

        OPEN c_asg_stmt( l_per_stmt_perd);
        LOOP

          FETCH c_asg_stmt
            INTO asg_rec;
          EXIT WHEN c_asg_stmt%NOTFOUND;

          OPEN c_per_item (asg_rec.asg_stmt_id)  ;
          LOOP
               FETCH c_per_item
                INTO l_per_item ;
               EXIT WHEN c_per_item%NOTFOUND;

               hr_utility.set_location ( 'delete ben_tcs_per_item_value  and ben_tcs_per_item entry for per_item_id :' || l_per_item,73);
               DELETE FROM ben_tcs_per_item_value
                    WHERE per_item_id = l_per_item;

               DELETE FROM ben_tcs_per_item
                    WHERE per_item_id = l_per_item;
          END LOOP;

          hr_utility.set_location ( 'delete ben_tcs_asg_stmt entry for ASG_STMT_ID :' || asg_rec.asg_stmt_id,74);
          DELETE FROM
            ben_tcs_asg_stmt
            WHERE ASG_STMT_ID = asg_rec.asg_stmt_id;

          IF (p_run_type = 'PURGE') THEN

            get_emp_detail(
                    asg_rec.assignment_id ,
                    p_person_id ,
                    p_period_end_date,
                    p_job ,
                    p_emp_name ,
                    p_emp_num ,
                    p_bg ) ;

            rep_count := l_rep_rec.COUNT +1;
            l_rep_rec(rep_count  ).p_TYPE := 0;
            l_rep_rec(rep_count ).BENEFIT_ACTION_ID :=p_benefit_action_id ;
            l_rep_rec(rep_count  ).ASSIGNMENT_NUMBER :=asg_rec.assignment_number;
            l_rep_rec(rep_count  ).ASSIGNMENT_ID := asg_rec.assignment_id;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := p_business_group;
            l_rep_rec(rep_count  ).PERSON_ID := p_person_id;
            l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg;
            l_rep_rec(rep_count  ).EMPLOYEE_NUMBER := p_emp_num;
            l_rep_rec(rep_count  ).FULL_NAME := p_emp_name;
            l_rep_rec(rep_count  ).JOB_NAME := substr(p_job, 1, 35);
            l_rep_rec(rep_count  ).STMT_CREATED := 'Y';

          END IF;
          CLOSE c_per_item;
        END LOOP;
        CLOSE c_asg_stmt;

      IF (p_validate = 'Y')
      THEN
         g_actn := 'Running in rollback mode, person rolled back...';
         WRITE (g_actn);

         ROLLBACK TO Purge;
      END IF;

      WRITE('leaving purge ...');
      hr_utility.set_location('Leaving '||g_proc,75);
      EXCEPTION
        WHEN no_data_found THEN
         WRITE('No stmt yet generated');
         WRITE ('Leaving purge_person_stmt');
END purge_person_stmt;

--
-- ============================================================================
--                            <<stmt_generation>>
-- ============================================================================
--

PROCEDURE stmt_generation (
          p_validate           IN             VARCHAR2,
          p_person_id          IN             NUMBER DEFAULT NULL,
          p_person_action_id   IN             NUMBER DEFAULT NULL,
          p_stmt_id            IN             NUMBER DEFAULT NULL,
          p_stmt_perd_id       IN             NUMBER DEFAULT NULL,
          p_period_end_date    IN             DATE,
          p_benefit_action_id  IN             NUMBER ,
          p_business_group     IN             NUMBER DEFAULT NULL,
          p_run_type           IN             VARCHAR2,
          p_start_date         IN             DATE
   )
   IS

   CURSOR c_assignment_selection ( v_person_id IN   NUMBER,
      v_period_start_date   IN   DATE,
      v_period_end_date   IN   DATE)
   IS
      SELECT DISTINCT(assignment_id) , assignment_number FROM
        per_all_assignments_f assign ,
        PER_ASSIGNMENT_STATUS_TYPES status
        WHERE assignment_type IN ('B','C','E')
        AND  assign.person_id = v_person_id
        AND  nvl(status.business_group_id,assign.business_group_id)  = assign.business_group_id
        AND  status.active_flag = 'Y'
        AND  assign.ASSIGNMENT_STATUS_TYPE_ID = status.ASSIGNMENT_STATUS_TYPE_ID
        AND  status.per_system_status IN ('ACTIVE_ASSIGN' , 'ACTIVE_CWK')
        AND  assign.effective_end_date > v_period_start_date
        AND  assign.effective_start_date < v_period_end_date;

   CURSOR c_stk_opts (v_person_id IN NUMBER ,
                      v_stmt_perd_id  IN NUMBER,
                      v_period_end_date IN DATE,
                      v_business_group IN NUMBER,
                      p_emp_num IN VARCHAR2 )
    IS
       SELECT  sum(current_shares_outstanding) total
       FROM
             ben_cwb_stock_optn_dtls
       WHERE   ( person_id = v_person_id
            OR  (business_group_id = v_business_group
            AND   employee_number = p_emp_num) )
            AND (  grant_date BETWEEN  ( SELECT START_DATE FROM ben_tcs_stmt_perd
                                        WHERE stmt_perd_id = v_stmt_perd_id )
                             AND v_period_end_date  );

   stk_opts_rec c_stk_opts%ROWTYPE ;

   l_assign c_assignment_selection%ROWTYPE;
   TYPE item_ids is TABLE  of NUMBER;
   l_per_stmt_perd_id NUMBER;
   l_asg_stmt_id NUMBER;
   l_item_cnt NUMBER := 1;
   l_source_cd VARCHAR2(30);
   l_source_key NUMBER;
   l_uom  VARCHAR2(30);
   l_comp_type_cd  VARCHAR2(30);
   l_nnmntry_uom VARCHAR(30);
   l_status  VARCHAR2(3);
   l_result BEN_TCS_COMPENSATION.period_table;
   l_count number := 0;
   item_u_cnt NUMBER :=0;
   item item_ids := null;
   item_cnt NUMBER :=0;
   gen Number :=0;
   p_job VARCHAR2(700);
   p_emp_name VARCHAR2(240);
   p_emp_num VARCHAR2(240) ;
   p_bg VARCHAR2(240);
   msg VARCHAR2(240);
   item_name VARCHAR2(240);
   UMBRELLA_API_ERR Exception;
   l_person_inc NUMBER := 0;
   l_initial_count NUMBER := l_rep_rec.COUNT+1;
   Rollback_Person VARCHAR(1) := 'N';
   Record_Created  VARCHAR(1) := 'N';
   cntr_item   VARCHAR(1) := 'N';
   rep_count NUMBER ;

   person_created_now   VARCHAR(1) := 'N';

    CURSOR c_item (v_stmt_id IN NUMBER) IS
        SELECT item_id,cntr_cd
                FROM ben_tcs_cat_item_hrchy
                WHERE cat_id  = -999
                AND  stmt_id = v_stmt_id;

    item_id_process  c_item%ROWTYPE;
   BEGIN

     g_proc := 'stmt_generation';
     WRITE ('In Procedure' ||g_proc);
     hr_utility.set_location('Entering '||g_proc,76);

     WRITE ('===========statement generation for the person============');
     WRITE ('||Person Id             ' || p_person_id);
     WRITE ('||Statement id          ' || p_stmt_id);
     WRITE ('||Period    id          ' || p_stmt_perd_id);
     WRITE ('||Person Action id      ' || p_person_action_id);
     WRITE ('=======================================================');

     SAVEPOINT generation;

     hr_utility.set_location( 'calling  purge ...',77 );
     purge_person_stmt(
       p_validate => p_validate ,
       p_person_id  => p_person_id,
       p_stmt_id => p_stmt_id,
       p_stmt_perd_id => p_stmt_perd_id,
       p_person_action_id => p_person_action_id ,
       p_benefit_action_id =>  p_benefit_action_id,
       p_business_group =>p_business_group,
       p_period_end_date => p_period_end_date,
       p_run_type     =>p_run_type);

    hr_utility.set_location('Calling check_multiple_stmt ',78);
    IF (check_multiple_stmt (
       p_person_id  => p_person_id,
       p_stmt_id    => p_stmt_id ,
       p_period_start_date => p_start_date,
       p_period_end_date => p_period_end_date) = true )
    THEN
       WRITE('Statement already exists for this period date');
    ELSE
      hr_utility.set_location('Before assignment cursor',79);
      OPEN c_assignment_selection(p_person_id,p_start_date,p_period_end_date);
      hr_utility.set_location('After assignment cursor',80 );
      LOOP
          person_created_now := 'N';
          Record_Created := 'N';
          cntr_item  := 'N';
          FETCH c_assignment_selection
                INTO l_assign;
          EXIT WHEN c_assignment_selection%NOTFOUND;
          SAVEPOINT assign_details;
          hr_utility.set_location('Processing assignment_number id '|| l_assign.assignment_id,81);
           gen := 0;
          OPEN c_item (p_stmt_id ) ;
          LOOP
            FETCH c_item INTO item_id_process ;
            EXIT WHEN c_item%NOTFOUND;
               IF ( item_id_process.item_id <> -1 ) THEN
                hr_utility.set_location('Processing item_id ' ||item_id_process.item_id,82);
                SELECT source_cd , source_key ,uom ,nnmntry_uom,comp_type_cd,name
                  INTO l_source_cd , l_source_key ,l_uom ,l_nnmntry_uom,l_comp_type_cd ,item_name
                  FROM  ben_tcs_item
                  WHERE item_id = item_id_process.item_id;

                hr_utility.set_location('Before BEN_TCS_COMPENSATION.get_value_for_item call',83);
                hr_utility.set_location('Assignment Id'|| l_assign.assignment_id ,84) ;
                hr_utility.set_location('Person Id' || p_person_id,85);
              -- hr_utility.trace_on(null,'tcs');
                 BEN_TCS_COMPENSATION.get_value_for_item(p_source_cd     =>  l_source_cd,
                             p_source_key               => l_source_key,
                             p_perd_st_dt               => p_start_date,
                             p_perd_en_dt               => p_period_end_date,
                             p_person_id                => p_person_id,
                             p_assignment_id            => l_assign.assignment_id ,
                             p_comp_typ_cd              => l_comp_type_cd,
                             p_currency_cd              => l_uom  ,
                             p_uom                      => l_nnmntry_uom ,
                             p_effective_date           => p_period_end_date ,
                             p_result                   => l_result,
                             p_status                   => l_status);

                hr_utility.set_location('After BEN_TCS_COMPENSATION.get_value_for_item call',86);
              --   hr_utility.trace_off;
                IF ( l_status = '0') THEN
                  IF (l_result.count > 0) THEN
                    IF (item_id_process.cntr_cd = 'ER' OR item_id_process.cntr_cd = 'EE' ) THEN
                        cntr_item  := 'Y';
                    END IF;
                  END IF;

                  SAVEPOINT insertion;
                  FOR i IN 1..l_result.count
                  LOOP
                     IF (i =1 ) THEN
                        IF l_count = 0  AND gen = 0 THEN
                            hr_utility.set_location('inserting INTO  ben_tcs_per_stmt_perd  person id , period id , stmt id '||
                            p_person_id||  p_stmt_perd_id||p_stmt_id,87);

                            l_person_inc := 1;
                            l_count := l_count + 1;

                            INSERT INTO ben_tcs_per_stmt_perd
                             ( per_stmt_perd_id ,
                               stmt_id ,
                               stmt_perd_id,
                               person_id,
                               show_wlcm_pg_flag,
                               end_date )
                            VALUES
                             ( ben_tcs_per_stmt_perd_s.NEXTVAL ,
                               p_stmt_id,
                               p_stmt_perd_id,
                               p_person_id,
                               null,
                               p_period_end_date);

                            person_created_now := 'Y';

                           hr_utility.set_location('After inserting INTO  ben_tcs_per_stmt_perd  ',88);

                        END IF;

                        IF gen = 0 THEN

                           hr_utility.set_location('Inserting INTO  ben_tcs_asg_stmt  assignment_id '||l_assign.assignment_id,89);
                           INSERT INTO ben_tcs_asg_stmt(
                                 asg_stmt_id ,
                                 stmt_id ,
                                 assignment_id,
                                 per_stmt_perd_id,
                                 assignment_number )
                           VALUES
                              ( ben_tcs_asg_stmt_s.NEXTVAL ,
                                p_stmt_id,
                                l_assign.assignment_id,
                                ben_tcs_per_stmt_perd_s.CURRVAL,
                                l_assign.assignment_number);

                           hr_utility.set_location('After inserting INTO  ben_tcs_asg_stmt  ',90);
                           IF (Record_Created ='N') THEN
                              get_emp_detail(
                                l_assign.assignment_id ,
                                p_person_id ,
                                p_period_end_date,
                                p_job ,
                                p_emp_name ,
                                p_emp_num ,
                                p_bg ) ;

                              rep_count := l_rep_rec.COUNT +1;
                              l_rep_rec(rep_count  ).p_TYPE := 0;
                              l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=p_benefit_action_id ;
                              l_rep_rec(rep_count  ).ASSIGNMENT_NUMBER :=l_assign.assignment_number;
                              l_rep_rec(rep_count  ).ASSIGNMENT_ID := l_assign.assignment_id;
                              l_rep_rec(rep_count ).BUSINESS_GROUP_ID := p_business_group;
                              l_rep_rec(rep_count  ).PERSON_ID := p_person_id;
                              l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
                              l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg;
                              l_rep_rec(rep_count  ).EMPLOYEE_NUMBER := p_emp_num;
                              l_rep_rec(rep_count  ).FULL_NAME := p_emp_name;
                              l_rep_rec(rep_count  ).JOB_NAME := substr(p_job, 1, 35);
                              l_rep_rec(rep_count  ).STMT_CREATED := 'Y';
                              Record_Created := 'Y';

                           END IF;
                           gen := 1;
                        END IF ;

                        l_uom := l_result(i).currency_cd;
                        l_nnmntry_uom := l_result(i).uom;

                        hr_utility.set_location('Inserting INTO  ben_tcs_per_item  item_id '||item_id_process.item_id,91);

                        INSERT INTO ben_tcs_per_item
                         ( per_item_id,
                           asg_stmt_id ,
                           stmt_id ,
                           item_id,
                           person_id,
                           stmt_perd_id ,
                           assignment_id,
                           uom ,
                           nnmntry_uom )
                        VALUES
                         ( ben_tcs_per_item_s.NEXTVAL ,
                           ben_tcs_asg_stmt_s.CURRVAL ,
                           p_stmt_id,
                           item_id_process.item_id,
                           p_person_id,
                           p_stmt_perd_id,
                           l_assign.assignment_id ,
                           l_uom ,
                           l_nnmntry_uom  );

                        hr_utility.set_location(' After inserting INTO  ben_tcs_per_item ',92);
                     END IF;
                     IF (l_source_cd = 'BB' OR l_source_cd = 'RULE'  OR  l_source_cd = 'PAYCOSTG' ) THEN
                      hr_utility.set_location('  Inserting INTO  ben_tcs_per_item_value  ' ,92.1);
                       IF (l_comp_type_cd = 'DATE') THEN
                         IF( l_source_cd = 'PAYCOSTG' OR l_source_cd = 'BB' ) THEN
                           WRITE('Data Type Mismatch for the item :' || item_name ||
                            'Expected Type : ' || l_comp_type_cd|| ' Actual type :' || l_result(i).actual_uom);
                           fnd_message.set_name('BEN','BEN_94667_TCS_CON_ERR_DATA_M');
                           fnd_message.set_token('ITEM_NAME', item_name );
                            msg := fnd_message.get ;
                           l_rep_rec(rep_count  ).STMT_CREATED := 'E';
                           IF (l_rep_rec(rep_count  ).ERROR IS NULL)THEN
                                l_rep_rec(rep_count  ).ERROR :=  msg;
                           ELSE
                                l_rep_rec(rep_count  ).ERROR := l_rep_rec(rep_count  ).ERROR||'; ' ||  msg;
                           END IF;
                           Rollback_Person := 'Y' ;
                           EXIT ;
                        ELSE
                        BEGIN
                        INSERT INTO ben_tcs_per_item_value
                           (   per_item_value_id,
                               per_item_id ,
                               source_from_date ,
                               source_to_date,
                               seq_num,
                               date_value,
                               source_key ,
                               source_cd,
                               display_date)
                       VALUES
                            ( ben_tcs_per_item_value_s.NEXTVAL ,
                              ben_tcs_per_item_s.CURRVAL ,
                              l_result(i).start_date,
                              l_result(i).end_date ,
                              i,
                              to_date(l_result(i).value,'yyyy/mm/dd'),
                              l_result(i).output_key,
                               l_source_cd ,l_result(i).start_date);

                        EXCEPTION
                        WHEN OTHERS THEN
                             WRITE('Data Type Mismatch for the item :' || item_name ||
                            'Expected Type : ' || l_comp_type_cd|| ' Actual type :' || l_result(i).actual_uom);
                           fnd_message.set_name('BEN','BEN_94667_TCS_CON_ERR_DATA_M');
                           fnd_message.set_token('ITEM_NAME', item_name );
                            msg := fnd_message.get ;
                           l_rep_rec(rep_count  ).STMT_CREATED := 'E';
                           IF (l_rep_rec(rep_count  ).ERROR IS NULL)THEN
                                l_rep_rec(rep_count  ).ERROR :=  msg;
                           ELSE
                                l_rep_rec(rep_count  ).ERROR := l_rep_rec(rep_count  ).ERROR||'; ' ||  msg;
                           END IF;
                           Rollback_Person := 'Y' ;
                           EXIT ;
                        END;
                        END IF ;
                       ELSIF (l_comp_type_cd = 'TEXT') THEN

                           INSERT INTO ben_tcs_per_item_value
                              ( per_item_value_id,
                                per_item_id ,
                                source_from_date ,
                                source_to_date,
                                seq_num,
                                text_value,
                                source_key ,
                                source_cd,
                                display_date)
                           VALUES
                            ( ben_tcs_per_item_value_s.NEXTVAL ,
                              ben_tcs_per_item_s.CURRVAL ,
                              l_result(i).start_date,
                              l_result(i).end_date ,
                              i,
                              l_result(i).value,
                              l_result(i).output_key,
                              l_source_cd ,
                              l_result(i).start_date);
                       ELSE


                        BEGIN
                         INSERT INTO ben_tcs_per_item_value
                           ( per_item_value_id,
                             per_item_id ,
                             source_from_date ,
                             source_to_date,
                             seq_num,
                             num_value,
                             source_key ,
                             source_cd,
                             display_date)
                         VALUES
                           ( ben_tcs_per_item_value_s.NEXTVAL ,
                             ben_tcs_per_item_s.CURRVAL ,
                             l_result(i).start_date,
                             l_result(i).end_date ,
                             i,
                             fnd_number.canonical_to_number(l_result(i).value),
                             l_result(i).output_key,
                             l_source_cd ,
                             l_result(i).start_date);
                              EXCEPTION
                             WHEN OTHERS THEN
                             WRITE('Data Type Mismatch for the item :' || item_name ||
                            'Expected Type : ' || l_comp_type_cd|| ' Actual type :' || l_result(i).actual_uom);
                           fnd_message.set_name('BEN','BEN_94667_TCS_CON_ERR_DATA_M');
                           fnd_message.set_token('ITEM_NAME', item_name );
                            msg := fnd_message.get ;
                           l_rep_rec(rep_count  ).STMT_CREATED := 'E';
                           IF (l_rep_rec(rep_count  ).ERROR IS NULL)THEN
                                l_rep_rec(rep_count  ).ERROR :=  msg;
                           ELSE
                                l_rep_rec(rep_count  ).ERROR := l_rep_rec(rep_count  ).ERROR||'; ' ||  msg;
                           END IF;
                           Rollback_Person := 'Y' ;
                           EXIT ;
                        END;
                       END IF;

                       hr_utility.set_location(' After inserting INTO  ben_tcs_per_item_value ',93 );
                     --vkodedal 7012521 Run Result ER
                     ELSIF (l_source_cd = 'THRDPTYPAY' OR l_source_cd = 'EE' or l_source_cd = 'RR') THEN

                       hr_utility.set_location('Inserting INTO  ben_tcs_per_item_value ',94.1);
                       hr_utility.set_location('l_comp_type_cd'||l_comp_type_cd,95.1);
                       hr_utility.set_location('l_result(i).value'||l_result(i).value,96.1);
                       hr_utility.set_location('actual'||l_result(i).actual_uom,97.1);
                       IF (l_comp_type_cd = 'DATE') THEN
                         IF (l_result(i).actual_uom IS NOT NULL AND l_result(i).actual_uom <>'D') THEN

                           WRITE('Data Type Mismatch for the item :' || item_name ||
                            'Expected Type : ' || l_comp_type_cd|| ' Actual type :' || l_result(i).actual_uom);
                           fnd_message.set_name('BEN','BEN_94667_TCS_CON_ERR_DATA_M');
                           fnd_message.set_token('ITEM_NAME', item_name );
                           msg := fnd_message.get ;
                           l_rep_rec(rep_count  ).STMT_CREATED := 'E';
                           IF (l_rep_rec(rep_count  ).ERROR IS NULL)THEN
                                l_rep_rec(rep_count  ).ERROR :=  msg;
                           ELSE
                                l_rep_rec(rep_count  ).ERROR := l_rep_rec(rep_count  ).ERROR||'; ' ||  msg;
                           END IF;
                           Rollback_Person := 'Y' ;
                           EXIT;
                         ELSE

                         INSERT INTO ben_tcs_per_item_value
                          ( per_item_value_id,
                            per_item_id ,
                            source_from_date ,
                            source_to_date,
                            seq_num,
                            date_value,
                            source_key ,
                            source_cd,
                            display_date)
                         VALUES
                         (  ben_tcs_per_item_value_s.NEXTVAL ,
                            ben_tcs_per_item_s.CURRVAL ,
                            l_result(i).start_date,
                            l_result(i).end_date ,
                            i,
                            fnd_date.canonical_to_date(l_result(i).value),
                            l_result(i).output_key,
                            l_source_cd ,
                            l_result(i).end_date);
                        END IF ;

                       ELSIF (l_comp_type_cd = 'TEXT') THEN

                          INSERT INTO ben_tcs_per_item_value
                             ( per_item_value_id,
                               per_item_id ,
                               source_from_date ,
                               source_to_date,
                               seq_num,
                               text_value,
                               source_key ,
                               source_cd,
                               display_date)
                          VALUES
                             ( ben_tcs_per_item_value_s.NEXTVAL ,
                               ben_tcs_per_item_s.CURRVAL ,
                               l_result(i).start_date,
                               l_result(i).end_date ,
                               i,
                               l_result(i).value,
                               l_result(i).output_key,
                               l_source_cd ,
                               l_result(i).end_date);
                       ELSE
                         IF (l_result(i).actual_uom IS NOT NULL AND
                           (l_result(i).actual_uom  NOT IN('I','M','N','ND','H_HH','H_DECIMAL1','H_DECIMAL2','H_DECIMAL3'))) THEN

                           WRITE('Data Type Mismatch for the item :' || item_name ||
                           'Expected Type : ' || l_comp_type_cd|| ' Actual Unit :' || l_result(i).actual_uom);

                           fnd_message.set_name('BEN','BEN_94667_TCS_CON_ERR_DATA_M');
                           fnd_message.set_token('ITEM_NAME', item_name );
                           msg := fnd_message.get ;
                           l_rep_rec(rep_count  ).STMT_CREATED := 'E';
                           IF (l_rep_rec(rep_count  ).ERROR IS NULL)THEN
                                l_rep_rec(rep_count  ).ERROR :=  msg;
                           ELSE
                                l_rep_rec(rep_count  ).ERROR := l_rep_rec(rep_count  ).ERROR||'; ' ||  msg;
                           END IF;
                           Rollback_Person := 'Y' ;
                           EXIT;
                           ELSE

                             INSERT INTO ben_tcs_per_item_value
                               ( per_item_value_id,
                                 per_item_id ,
                                 source_from_date ,
                                 source_to_date,
                                 seq_num,num_value,
                                 source_key ,
                                 source_cd,
                                 display_date)
                             VALUES
                               ( ben_tcs_per_item_value_s.NEXTVAL ,
                               ben_tcs_per_item_s.CURRVAL ,
                               l_result(i).start_date,
                               l_result(i).end_date ,
                               i,
                               fnd_number.canonical_to_number(l_result(i).value),
                               l_result(i).output_key,
                               l_source_cd ,
                               l_result(i).end_date);
                           END  IF;
                        END IF ;
                     END IF ;
                  END LOOP;
                ELSE
                  IF (Record_Created ='N') THEN
                           get_emp_detail(
                             l_assign.assignment_id ,
                             p_person_id ,
                             p_period_end_date,
                             p_job ,
                             p_emp_name ,
                             p_emp_num ,
                             p_bg ) ;

                            rep_count := l_rep_rec.COUNT +1;
                            l_rep_rec(rep_count  ).p_TYPE := 0;
                            l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=p_benefit_action_id ;
                            l_rep_rec(rep_count  ).ASSIGNMENT_NUMBER :=l_assign.assignment_number;
                            l_rep_rec(rep_count  ).ASSIGNMENT_ID := l_assign.assignment_id;
                            l_rep_rec(rep_count ). BUSINESS_GROUP_ID := p_business_group;
                            l_rep_rec(rep_count  ).PERSON_ID := p_person_id;
                            l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
                            l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg;
                            l_rep_rec(rep_count  ).EMPLOYEE_NUMBER := p_emp_num;
                            l_rep_rec(rep_count  ).FULL_NAME := p_emp_name;
                            l_rep_rec(rep_count  ).JOB_NAME := substr(p_job, 1, 35);
                            Record_Created := 'Y';
                  END IF;

                  l_rep_rec(rep_count  ).STMT_CREATED := 'E';
                  IF( l_status = '1B' ) THEN
                        fnd_message.set_name('BEN','BEN_94669_TCS_CON_ERR_SB_NF');
                  ELSIF( l_status = '1C' ) THEN
                        fnd_message.set_name('BEN','BEN_94670_TCS_CON_ERR_PAY_NF');
                  ELSIF( l_status = '6' ) THEN
                          msg := item_name || ' : ' || 'Invalid Source code ';
                   ELSIF( l_status = '5' ) THEN
                          fnd_message.set_name('BEN','BEN_94671_TCS_RULE_DT_FORMAT');
                  END IF ;
                  fnd_message.set_token('ITEM_NAME', item_name );
                  msg := fnd_message.get ;
                  IF (l_rep_rec(rep_count  ).ERROR IS NULL)THEN
                     l_rep_rec(rep_count  ).ERROR :=  msg;
                  ELSE
                     l_rep_rec(rep_count  ).ERROR := l_rep_rec(rep_count  ).ERROR||'; ' ||  msg;
                  END IF;
                  Rollback_Person := 'Y' ;
                END IF;
            ELSE
                hr_utility.set_location('stock options extended subcategory',94);
                get_emp_detail(
                                l_assign.assignment_id ,
                                p_person_id ,
                                p_period_end_date,
                                p_job ,
                                p_emp_name ,
                                p_emp_num ,
                                p_bg ) ;
                OPEN c_stk_opts (p_person_id , p_stmt_perd_id , p_period_end_date , p_business_group,p_emp_num );
                 FETCH c_stk_opts INTO stk_opts_rec ;
                  IF ( stk_opts_rec.total IS NOT NULL  ) THEN
                   hr_utility.set_location('Person has value for stock options extended subcategory',95);
                   cntr_item  := 'Y';
                    IF l_count = 0  AND gen = 0 THEN
                            hr_utility.set_location('inserting INTO  ben_tcs_per_stmt_perd  person id , period id , stmt id '||
                            p_person_id||  p_stmt_perd_id||p_stmt_id ||' subcategory part' ,96);

                            l_person_inc := 1;
                            l_count := l_count + 1;

                            INSERT INTO ben_tcs_per_stmt_perd
                             ( per_stmt_perd_id ,
                               stmt_id ,
                               stmt_perd_id,
                               person_id,
                               show_wlcm_pg_flag,
                               end_date )
                            VALUES
                             ( ben_tcs_per_stmt_perd_s.NEXTVAL ,
                               p_stmt_id,
                               p_stmt_perd_id,
                               p_person_id,
                               null,
                               p_period_end_date);

                           hr_utility.set_location('After inserting INTO  ben_tcs_per_stmt_perd  ',97);
                        END IF;

                        IF gen = 0 THEN

                           hr_utility.set_location('inserting INTO  ben_tcs_asg_stmt  assignment_id '||l_assign.assignment_id||' subcategory',98);
                           INSERT INTO ben_tcs_asg_stmt(
                                 asg_stmt_id ,
                                 stmt_id ,
                                 assignment_id,
                                 per_stmt_perd_id,
                                 assignment_number )
                           VALUES
                              ( ben_tcs_asg_stmt_s.NEXTVAL ,
                                p_stmt_id,
                                l_assign.assignment_id,
                                ben_tcs_per_stmt_perd_s.CURRVAL,
                                l_assign.assignment_number);

                           hr_utility.set_location('After inserting INTO  ben_tcs_asg_stmt  ',99);
                           IF (Record_Created ='N') THEN
                              rep_count := l_rep_rec.COUNT +1;
                              l_rep_rec(rep_count  ).p_TYPE := 0;
                              l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=p_benefit_action_id ;
                              l_rep_rec(rep_count  ).ASSIGNMENT_NUMBER :=l_assign.assignment_number;
                              l_rep_rec(rep_count  ).ASSIGNMENT_ID := l_assign.assignment_id;
                              l_rep_rec(rep_count ).BUSINESS_GROUP_ID := p_business_group;
                              l_rep_rec(rep_count  ).PERSON_ID := p_person_id;
                              l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
                              l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg;
                              l_rep_rec(rep_count  ).EMPLOYEE_NUMBER := p_emp_num;
                              l_rep_rec(rep_count  ).FULL_NAME := p_emp_name;
                              l_rep_rec(rep_count  ).JOB_NAME := substr(p_job, 1, 35);
                              l_rep_rec(rep_count  ).STMT_CREATED := 'Y';
                              Record_Created := 'Y';

                           END IF;
                           gen := 1;
                        END IF ;
                END IF;
                CLOSE c_stk_opts ;
            END IF;
          END LOOP;

          IF (Record_Created ='N') THEN

            hr_utility.set_location(' no report',100);
            get_emp_detail(
              l_assign.assignment_id ,
              p_person_id ,
              p_period_end_date,
              p_job ,
              p_emp_name ,
              p_emp_num ,
              p_bg ) ;

              rep_count := l_rep_rec.COUNT +1;
              l_rep_rec(rep_count  ).p_TYPE := 0;
              l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=p_benefit_action_id ;
              l_rep_rec(rep_count  ).ASSIGNMENT_NUMBER :=l_assign.assignment_number;
              l_rep_rec(rep_count  ).ASSIGNMENT_ID := l_assign.assignment_id;
              l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := p_business_group;
              l_rep_rec(rep_count  ).PERSON_ID := p_person_id;
              l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
              l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg;
              l_rep_rec(rep_count  ).EMPLOYEE_NUMBER := p_emp_num;
              l_rep_rec(rep_count  ).FULL_NAME := p_emp_name;
              l_rep_rec(rep_count  ).JOB_NAME := substr(p_job, 1, 35);
              l_rep_rec(rep_count  ).STMT_CREATED := 'N';
          ELSE
              IF (  cntr_item  = 'N'  AND l_rep_rec(rep_count  ).STMT_CREATED = 'Y') THEN
                    l_rep_rec(rep_count  ).STMT_CREATED := 'N';
                    WRITE('No Compensation For Employer Contribution and Employee  Contribution');
                    IF (person_created_now = 'Y') THEN
                      l_count := 0;
                    END IF;
                    ROLLBACK TO assign_details ;
               END IF;
          END IF;

          CLOSE c_item;

      END LOOP;
      END IF ;
      CLOSE c_assignment_selection;


     IF (p_validate = 'Y')
     THEN
       g_actn := 'Running in rollback mode, person rolled back...';
       WRITE (g_actn);
       ROLLBACK TO generation;
     END IF;

     IF ( Rollback_Person = 'Y') THEN
        ROLLBACK TO generation;

        hr_utility.set_location('initial cnt' || l_initial_count,101);
        hr_utility.set_location(' cnt' || l_rep_rec.COUNT,102);

        FOR i in l_initial_count .. l_rep_rec.COUNT
        LOOP
            IF ( l_rep_rec(i).STMT_CREATED = 'Y' OR  l_rep_rec(i).STMT_CREATED = 'N' ) THEN
                l_rep_rec(i).STMT_CREATED := 'H';
            END IF;
        END LOOP;

        WRITE('person rolled back due to error  ');
     END If;

     WRITE ('Leaving stmt_generation');
     --hr_utility.trace_off;
     hr_utility.set_location('Leaving '||g_proc,103);

     EXCEPTION

       WHEN OTHERS
       THEN
     -- hr_utility.trace_off;
        IF (Record_Created ='N') THEN
                            get_emp_detail(
                              l_assign.assignment_id ,
                              p_person_id ,
                              p_period_end_date,
                              p_job ,
                              p_emp_name ,
                              p_emp_num ,
                              p_bg ) ;

                            rep_count := l_rep_rec.COUNT +1;
                            l_rep_rec(rep_count  ).p_TYPE := 0;
                            l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=p_benefit_action_id ;
                            l_rep_rec(rep_count  ).ASSIGNMENT_NUMBER :=l_assign.assignment_number;
                            l_rep_rec(rep_count  ).ASSIGNMENT_ID := l_assign.assignment_id;
                            l_rep_rec(rep_count ).BUSINESS_GROUP_ID := p_business_group;
                            l_rep_rec(rep_count  ).PERSON_ID := p_person_id;
                            l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
                            l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg;
                            l_rep_rec(rep_count  ).EMPLOYEE_NUMBER := p_emp_num;
                            l_rep_rec(rep_count  ).FULL_NAME := p_emp_name;
                            l_rep_rec(rep_count  ).JOB_NAME := substr(p_job, 1, 35);
                            Record_Created := 'Y';
        END IF;
        l_rep_rec(rep_count  ).STMT_CREATED := 'E';

       ROLLBACK TO generation;

       hr_utility.set_location('initial cnt' || l_initial_count,104);
       hr_utility.set_location(' cnt' || l_rep_rec.COUNT,105);

       FOR i IN l_initial_count .. l_rep_rec.COUNT
       LOOP
           IF ( l_rep_rec(i).STMT_CREATED = 'N' OR l_rep_rec(i).STMT_CREATED = 'Y' ) THEN
                l_rep_rec(i).STMT_CREATED := 'H';
           END IF;
       END LOOP;

       WRITE('person rolled back due to some error in the generation ');
       WRITE (SQLERRM);

   END stmt_generation;

--
-- ============================================================================
--                            <<set_wlcm_flag>>
-- ============================================================================
--

    PROCEDURE set_wlcm_flag (
          p_validate           IN              VARCHAR2,
          p_person_id          IN              NUMBER DEFAULT NULL,
          p_stmt_id            IN              NUMBER DEFAULT NULL,
          p_stmt_perd_id       IN              NUMBER DEFAULT NULL,
          p_person_action_id   IN               NUMBER DEFAULT NULL,
          p_benefit_action_id  IN              NUMBER DEFAULT NULL ,
          p_business_group     IN              NUMBER DEFAULT NULL,
          p_period_end_date    IN              DATE DEFAULT NULL,
          p_run_type           IN              VARCHAR2
    )
   IS
     wlcm_flag           VARCHAR2(10)  ;
     rep_count           NUMBER;
     p_job VARCHAR2(700);
     p_emp_name VARCHAR2(240);
     p_emp_num VARCHAR2(240) ;
     p_bg VARCHAR2(240);

   BEGIN

     g_proc := 'set_wlcm_flag';
     hr_utility.set_location('Entering '||g_proc,106);
     g_actn := 'updating ben_tcs_per_stmt_perd' ;

     WRITE ('In Procedure' ||g_proc);
     WRITE ('===========Reset welcome flag for the person============');
     WRITE ('||Person Id             ' || p_person_id);
     WRITE ('||Statement id          ' || p_stmt_id);
     WRITE ('||Period    id          ' || p_stmt_perd_id);
     WRITE ('||Person Action id      ' || p_person_action_id);
     WRITE ('=======================================================');

    SAVEPOINT setFlag;

    hr_utility.set_location('statement id : '||p_stmt_id || ' statement period id :' ||p_stmt_perd_id
     || 'person id :' ||p_person_id,107);

    SELECT show_wlcm_pg_flag
      INTO wlcm_flag
      FROM ben_tcs_per_stmt_perd
      WHERE  stmt_id = p_stmt_id
                AND stmt_perd_id = p_stmt_perd_id
                AND person_id = p_person_id ;

     IF (wlcm_flag = 'N') THEN
     hr_utility.set_location('Updating the welcome flag for person id  : ' || p_person_id || ' : ' ||p_period_end_date ,108);

         get_emp_detail(
                    null ,
                    p_person_id ,
                    p_period_end_date,
                    p_job ,
                    p_emp_name ,
                    p_emp_num ,
                    p_bg ) ;

            rep_count := l_rep_rec.COUNT +1;
            l_rep_rec(rep_count  ).p_TYPE := 0;
            l_rep_rec(rep_count  ).BENEFIT_ACTION_ID := p_benefit_action_id ;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := p_business_group;
            l_rep_rec(rep_count  ).PERSON_ID := p_person_id;
            l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg;
            l_rep_rec(rep_count  ).EMPLOYEE_NUMBER := p_emp_num;
            l_rep_rec(rep_count  ).FULL_NAME := p_emp_name;
            l_rep_rec(rep_count  ).STMT_CREATED := 'Y';

    UPDATE ben_tcs_per_stmt_perd
        SET show_wlcm_pg_flag = null
        WHERE stmt_id = p_stmt_id
                AND stmt_perd_id = p_stmt_perd_id
                AND person_id = p_person_id ;
       WRITE ('Reopened  Welcome Page');
    END IF;

    IF (p_validate = 'Y')
    THEN
      g_actn := 'Running in rollback mode, person rolled back...';
      WRITE (g_actn);
      ROLLBACK TO setFlag;
    END IF;

   WRITE ('Leaving set_wlcm_flag');
   hr_utility.set_location('Leaving '||g_proc,109);
   EXCEPTION
      WHEN OTHERS
      THEN
      l_rep_rec(rep_count  ).STMT_CREATED := 'E';
           WRITE (SQLERRM);

   END set_wlcm_flag;

-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--    this is a main procedure to invoke the Total Compensation Statement
--    process.
-- ============================================================================
   PROCEDURE do_multithread (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      NUMBER,
      p_validate            IN              VARCHAR2 DEFAULT 'N',
      p_benefit_action_id   IN              NUMBER,
      p_thread_id           IN              NUMBER,
      p_effective_date      IN              VARCHAR2,
      p_audit_log           IN              VARCHAR2 DEFAULT 'N',
      p_run_type            IN               VARCHAR2,
      p_start_date          IN              DATE,
      p_end_date            IN              DATE

   )
   IS

     CURSOR c_range_for_thread (v_benefit_action_id IN NUMBER)
     IS
      SELECT  ran.range_id, ran.starting_person_action_id,
                    ran.ending_person_action_id
      FROM ben_batch_ranges ran
      WHERE ran.range_status_cd = 'U'
      AND ran.benefit_action_id = v_benefit_action_id
      AND ROWNUM < 2
      FOR UPDATE OF ran.range_status_cd;

     CURSOR c_person_for_thread (
         v_benefit_action_id        IN   NUMBER,
         v_start_person_action_id   IN   NUMBER,
         v_end_person_action_id     IN   NUMBER
     )
     IS
      SELECT   ben.person_id, ben.person_action_id, ben.object_version_number,
      ben.chunk_number ,ben.ler_id , ben.non_person_cd
      FROM ben_person_actions ben
      WHERE ben.benefit_action_id = v_benefit_action_id
      AND ben.action_status_cd <> 'P'
      AND ben.person_action_id BETWEEN v_start_person_action_id
                               AND v_end_person_action_id
      ORDER BY ben.person_action_id;

    CURSOR c_parameter (v_benefit_action_id IN NUMBER)
    IS
      SELECT ben.*
      FROM ben_benefit_actions ben
      WHERE ben.benefit_action_id = v_benefit_action_id;

      l_parm                     c_parameter%ROWTYPE;
      l_commit                   NUMBER;
      l_range_id                 NUMBER;
      l_record_number            NUMBER                := 0;
      l_start_person_action_id   NUMBER                := 0;
      l_end_person_action_id     NUMBER                := 0;
      l_effective_date           DATE;
      l_loop_cnt                 NUMBER                :=1;

    TYPE g_cache_person_process_object IS RECORD (
      person_id               ben_person_actions.person_id%TYPE,
      person_action_id        ben_person_actions.person_action_id%TYPE,
      object_version_number   ben_person_actions.object_version_number%TYPE,
      perd_id                  ben_person_actions.ler_id%TYPE ,
      stmt_id                 ben_person_actions.chunk_number%TYPE,
      bg_id                   ben_person_actions.non_person_cd%TYPE


     );

    TYPE g_cache_person_process_rec IS TABLE OF g_cache_person_process_object
      INDEX BY BINARY_INTEGER;

    g_cache_person_process   g_cache_person_process_rec;

   BEGIN

      g_actn := 'Started do_multithread for the thread ' || p_thread_id;
      g_proc := 'do_multithread';
      hr_utility.set_location('Entering '||g_proc,110);

      benutils.g_benefit_action_id := p_benefit_action_id;

      WRITE ('procedure :' ||g_proc );
      hr_utility.set_location (g_actn,111);
      WRITE ('=====================do_multithread=============');
      WRITE ('||Parameter              Description            ');
      WRITE ('||p_effective_dates -    ' || p_effective_date);
      WRITE ('||p_validate -           ' || p_validate);
      WRITE ('||p_benefit_action_id -  ' || p_benefit_action_id);
      WRITE ('||p_thread_id -          ' || p_thread_id);
      WRITE ('||p_audit_log -          ' || p_audit_log);
      WRITE ('================================================');

      l_effective_date :=
                  TRUNC (TO_DATE (p_effective_date, 'yyyy/mm/dd'));
      hr_utility.set_location ('l_effective_date is ' || l_effective_date,112);
      g_actn := 'Put row in fnd_sessions...';
      hr_utility.set_location (g_actn,113);
      hr_utility.set_location ('dt_fndate.change_ses_date with ' || l_effective_date,114);
      dt_fndate.change_ses_date (p_ses_date      => l_effective_date,
                                 p_commit        => l_commit
                                );
      -- need to check .
      IF (l_commit = 1)
      THEN
         WRITE ('The session date is committed...');
         COMMIT;
      END IF;

      OPEN c_parameter (p_benefit_action_id);
        FETCH c_parameter
         INTO l_parm;
      CLOSE c_parameter;


      WRITE (   'Time before processing the ranges '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
              );

      LOOP
        OPEN c_range_for_thread (p_benefit_action_id);
         FETCH c_range_for_thread
          INTO l_range_id, l_start_person_action_id, l_end_person_action_id;
         EXIT WHEN c_range_for_thread%NOTFOUND;
        CLOSE c_range_for_thread;


        IF (l_range_id IS NOT NULL)
        THEN
            WRITE (   'Range with range_id '
                     || l_range_id
                     || ' with Starting person action id '
                     || l_start_person_action_id
                    );
            WRITE (   ' and Ending Person Action id '
                     || l_end_person_action_id
                     || ' is selected'
                    );
            g_actn :=
                  'Marking ben_batch_ranges for range_id '
               || l_range_id
               || ' as processed...';
            WRITE (g_actn);

            UPDATE ben_batch_ranges ran
               SET ran.range_status_cd = 'P'
             WHERE ran.range_id = l_range_id;

            COMMIT;
        END IF;

         --g_cache_person_process.DELETE;
        g_actn := 'Loading person data into g_cache_person_process cache...';
        hr_utility.set_location (g_actn,114);
        hr_utility.set_location ('Time' || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'),115);

        OPEN c_person_for_thread (p_benefit_action_id,
                                   l_start_person_action_id,
                                   l_end_person_action_id
                                 );
        l_record_number := 0;
        LOOP
          FETCH c_person_for_thread
            INTO g_cache_person_process (l_record_number + 1).person_id,
                  g_cache_person_process (l_record_number + 1).person_action_id,
                  g_cache_person_process (l_record_number + 1).object_version_number,
                  g_cache_person_process (l_record_number + 1).stmt_id,
                  g_cache_person_process (l_record_number + 1).perd_id,
                  g_cache_person_process (l_record_number + 1).bg_id;
          EXIT WHEN c_person_for_thread%NOTFOUND;
          l_record_number := l_record_number + 1;
        END LOOP;
        CLOSE c_person_for_thread;

        WRITE ('Time ' || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));
        WRITE (   'Number of Persons selected in this range '
                || g_cache_person_process.COUNT
               );
        WRITE ('======Parameters required for processing this person ====');
        WRITE ('||l_parm.business_group_id   ' || l_parm.business_group_id);
        WRITE ('||l_parm.debug_messages_flag '
                  || l_parm.debug_messages_flag
                 );
        WRITE ('||l_parm.bft_attribute1      ' || l_parm.bft_attribute1);
        WRITE ('=======================================================');
        WRITE ('Time ' || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));

        IF l_record_number > 0
        THEN
          FOR l_cnt IN 1 .. l_record_number
          LOOP
              BEGIN
              g_actn := 'Calling the process for the person id  ...'||g_cache_person_process (l_cnt).person_id ;
              hr_utility.set_location(g_actn,116);
              IF ( p_run_type = 'GEN') THEN
                hr_utility.set_location (' calling stmt_generation..',117);
                stmt_generation (
                  p_validate                  =>  p_validate,
                  p_person_id                 =>  g_cache_person_process (l_cnt).person_id ,
                  p_person_action_id          =>  g_cache_person_process (l_cnt).person_action_id ,
                  p_stmt_id                   =>  g_cache_person_process (l_cnt).stmt_id  ,
                  p_stmt_perd_id              =>  g_cache_person_process (l_cnt).perd_id ,
                  p_period_end_date           =>  p_end_date ,
                  p_benefit_action_id         =>  p_benefit_action_id,
                  p_business_group            =>  g_cache_person_process (l_cnt).bg_id,
                  p_run_type                  =>  p_run_type,
                  p_start_date                =>  p_start_date   );

                  hr_utility.set_location('After  the statement generation  for the person id '|| g_cache_person_process (l_cnt).person_id,118);

              ELSIF (p_run_type = 'WLCM_SET') THEN
                    g_actn := 'calling set_wlcm_flag..';
                    hr_utility.set_location(g_actn,119);

                    set_wlcm_flag ( p_validate      =>  p_validate,
                        p_person_id                 =>  g_cache_person_process (l_cnt).person_id ,
                        p_stmt_id                   =>  g_cache_person_process (l_cnt).stmt_id ,
                        p_stmt_perd_id              =>  g_cache_person_process (l_cnt).perd_id,
                        p_person_action_id          =>  g_cache_person_process (l_cnt).person_action_id,
                        p_benefit_action_id         =>  p_benefit_action_id ,
                        p_business_group             => g_cache_person_process (l_cnt).bg_id ,
                        p_period_end_date           =>  p_end_date,
                        p_run_type                    =>p_run_type
                         ) ;

                     hr_utility.set_location('After  the set welcome flag  for the person id '|| g_cache_person_process (l_cnt).person_id,120);

              ELSIF (p_run_type = 'PURGE') THEN

                    g_actn := 'calling  purge_person_stmt..';
                    hr_utility.set_location(g_actn,121);

                    purge_person_stmt(p_validate    =>  p_validate,
                        p_person_id                 =>  g_cache_person_process (l_cnt).person_id ,
                        p_stmt_id                   =>  g_cache_person_process (l_cnt).stmt_id ,
                        p_stmt_perd_id              =>  g_cache_person_process (l_cnt).perd_id ,
                        p_person_action_id          =>  g_cache_person_process (l_cnt).person_action_id ,
                        p_benefit_action_id         =>  p_benefit_action_id ,
                        p_business_group             => g_cache_person_process (l_cnt).bg_id ,
                        p_period_end_date           =>  p_end_date,
                        p_run_type                    =>p_run_type);

                    hr_utility.set_location('After  the purge for the person id '|| g_cache_person_process (l_cnt).person_id,122);
              END IF;
          EXCEPTION
               WHEN OTHERS
                THEN
                     WRITE (   SQLERRM || ' in multithread, caught in process_person call');
                  END;
        END LOOP;

        g_actn := 'Time after processing the ranges..';
        WRITE (   'Time after processing the ranges '
                     || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));
        ELSE

            g_actn := 'Erroring out since no person is found in range...';
            fnd_message.set_name ('BEN', 'BEN_91709_PER_NOT_FND_IN_RNG');
            fnd_message.set_token ('PROCEDURE', g_proc);
            fnd_message.raise_error;
        END IF;

        g_actn := 'before commit';
        WRITE (g_actn);

        COMMIT;

        g_actn := 'after commit';
        WRITE (g_actn);

      END LOOP;
      print_cache;
      WRITE ('Leaving do_multithread');
      hr_utility.set_location('Leaving '||g_proc,130);
   EXCEPTION
      WHEN OTHERS
      THEN
         WRITE (SQLERRM);
         g_actn := g_actn || SQLERRM;
         print_cache;
         COMMIT;
         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', g_proc);
         fnd_message.set_token ('STEP', g_actn);
         fnd_message.raise_error;

     END do_multithread;

--
-- ============================================================================
--                            <<insert_person_actions>>
-- ============================================================================
--

   PROCEDURE insert_person_actions (
      p_per_actn_id_array   IN   g_number_type,
      p_per_id              IN   g_number_type,
      p_benefit_action_id   IN   NUMBER,
      p_perd_id             IN   g_number_type,
      p_stmt_id             IN   g_number_type,
      p_bg_id               IN   g_number_type
   )
   IS
      l_num_rows   NUMBER := p_per_actn_id_array.COUNT;
   BEGIN
      g_proc := 'insert_person_actions';
      WRITE ('In Procedure' ||g_proc);
      hr_utility.set_location('Entering '||g_proc,131);
      WRITE (   'Time before inserting person actions '
             || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));

      FORALL l_count IN 1 .. p_per_actn_id_array.COUNT

         INSERT INTO ben_person_actions
                     (person_action_id,
                      person_id,
                      benefit_action_id,
                      action_status_cd,
                      chunk_number,
                      LER_ID,
                      non_person_cd ,
                      object_version_number)
         VALUES (
                      p_per_actn_id_array (l_count),
                      p_per_id (l_count),
                      p_benefit_action_id,
                      'U',
                      p_stmt_id (l_count),
                      p_perd_id (l_count),
                      p_bg_id (l_count),
                      1);

         WRITE (   'Time before inserting ben batch ranges '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));

        INSERT INTO ben_batch_ranges
                  (range_id,
                   benefit_action_id,
                   range_status_cd,
                   starting_person_action_id,
                   ending_person_action_id,
                   object_version_number)
        VALUES   (
                   ben_batch_ranges_s.NEXTVAL,
                   p_benefit_action_id,
                   'U',
                   p_per_actn_id_array (1),
                   p_per_actn_id_array (l_num_rows),
                   1);

        WRITE (   'Time at end of insert person actions '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));

     WRITE ('Leaving insert_person_actions');
     hr_utility.set_location('Leaving '||g_proc,132);

   END insert_person_actions;

--
-- ============================================================================
--                            <<process>>
-- ============================================================================
--

   PROCEDURE process (
      errbuf             OUT NOCOPY      VARCHAR2,
      retcode            OUT NOCOPY      NUMBER,
      p_validate         IN              VARCHAR2 DEFAULT 'N',
      p_run_type         IN              VARCHAR2,
      p_stmt_name        IN              VARCHAR2,
      p_stmt_id          IN              VARCHAR2 ,
      p_person_id        IN              VARCHAR2 DEFAULT NULL,
      p_period_id        IN              VARCHAR2,
      p_partial_end      IN              VARCHAR2 DEFAULT NULL,
      p_audit_log        IN              VARCHAR2 DEFAULT 'Y',
      p_business_group_id IN             NUMBER DEFAULT NULL,
      p_org_id          IN              NUMBER DEFAULT NULL,
      p_location_id          IN              NUMBER DEFAULT NULL,
      p_ben_grp_id          IN              NUMBER DEFAULT NULL,
      p_payroll_id          IN              NUMBER DEFAULT NULL,
      p_job_id          IN              NUMBER DEFAULT NULL,
      p_position_id          IN              NUMBER DEFAULT NULL,
      p_supervisor_id          IN              NUMBER DEFAULT NULL
   )
   IS
      --
      -- local variable declaration.
      --
      l_max_errors_allowed     NUMBER (9)              := 200;
      l_elig_return_status      BOOLEAN;
      l_loop_cnt                NUMBER                              := 1;
      l_count                   NUMBER                              := 0;
      l_chunk_size              NUMBER;
      l_request_id              NUMBER;
      l_threads                 NUMBER;
      l_benefit_action_id       NUMBER;
      l_object_version_number   NUMBER;
      l_business_group_id       NUMBER                              := NULL;
      l_num_ranges              NUMBER                              := 0;
      l_num_persons             NUMBER                              := 0;
      l_silent_error            EXCEPTION;
      l_num_rows                NUMBER                              := 0;
      l_period_start_date       DATE;
      l_period_end_date         DATE;
      l_effective_date          DATE := sysdate;
      temp_count                NUMBER :=1 ;
      temp_ee_id                NUMBER ;
      l_stmt_name               VARCHAR2(240);
      l_actual_end_date         DATE;


    CURSOR c_person_selection (
        v_stmt_id        IN   NUMBER,
        v_period_start_date   IN   DATE,
        v_period_end_date   IN   DATE,
        v_bg_id            IN   NUMBER,
        --vkodedal added args 14-sep-2007 ER
        v_ben_grp_id       IN   NUMBER,
        v_position_id      IN   NUMBER,
        v_job_id           IN   NUMBER,
        v_payroll_id       IN   NUMBER,
        v_location_id      IN   NUMBER,
        v_supervisor_id    IN   NUMBER,
        v_org_id           IN   NUMBER
      )
      IS

 SELECT DISTINCT papf.person_id,
		papf.full_name name
           FROM per_all_people_f papf,
                per_all_assignments_f paaf
          WHERE papf.business_group_id = v_bg_id
     AND EXISTS (
            SELECT 'x'
              FROM per_person_type_usages_f ptu, per_person_types ppt
             WHERE ptu.person_id = papf.person_id
               AND ptu.effective_start_date <= v_period_end_date           --period end date
               AND ptu.effective_end_date >= v_period_start_date            --period start date
               AND ptu.person_type_id = ppt.person_type_id
               AND (   ppt.system_person_type IN ('EMP', 'CWK')
                    OR (    ppt.system_person_type = 'EX_EMP'
                        AND EXISTS (
                               SELECT NULL
                                 FROM per_periods_of_service pps
                                WHERE papf.person_id = pps.person_id
                                  AND pps.date_start <= v_period_end_date   --period end date
                                  AND pps.final_process_date >=
                                                         v_period_start_date
                                                           --period start date
                                                           )
                       )
                    OR (    ppt.system_person_type = 'EX_CWK'
                        AND EXISTS (
                               SELECT NULL
                                 FROM per_periods_of_placement pps
                                WHERE papf.person_id = pps.person_id
                                  AND pps.date_start <= v_period_end_date   --period end date
                                  AND pps.final_process_date >=
                                                         v_period_start_date
                                                           --period start date
                                                           )
                       )
                   ))
            AND paaf.person_id = papf.person_id
            AND paaf.primary_flag = 'Y'
            AND paaf.assignment_type IN ('E', 'C')
            AND paaf.effective_end_date >= v_period_start_date
            AND paaf.effective_start_date <= v_period_end_date
            AND papf.effective_start_date <= v_period_end_date
            AND papf.effective_end_date >= v_period_start_date
            AND (v_ben_grp_id IS NULL OR papf.benefit_group_id=v_ben_grp_id)
			AND (v_position_id IS NULL OR paaf.position_id=v_position_id)
			AND (v_job_id IS NULL OR paaf.job_id=v_job_id)
			AND (v_payroll_id IS NULL OR paaf.payroll_id=v_payroll_id)
			AND (v_location_id IS NULL OR paaf.location_id=v_location_id)
			AND (v_supervisor_id IS NULL OR paaf.supervisor_id=v_supervisor_id)
			AND (v_org_id IS NULL OR paaf.organization_id=v_org_id);


   CURSOR c_stmt_id (v_stmt_id NUMBER,v_period_id NUMBER )
     IS
      SELECT stmt.stmt_id stmt_id, v_period_id period_id ,stmt.ee_profile_id ee_id,'Y' valid_flag,
             stmt.business_group_id bg_id
      FROM ben_tcs_stmt stmt
      WHERE stmt.stmt_id = v_stmt_id ;


       stmt_rec                  c_stmt_id%ROWTYPE;

     CURSOR c_stmt_id_bg_id (v_stmt_name VARCHAR2, v_period_start_date IN DATE,v_period_end_date IN DATE)
     IS
      SELECT stmt.stmt_id stmt_id, period.stmt_perd_id period_id ,stmt.ee_profile_id ee_id,'Y' valid_flag,
             stmt.business_group_id bg_id
      FROM ben_tcs_stmt stmt , ben_tcs_stmt_perd period
      WHERE stmt.NAME = v_stmt_name
      AND period.start_date = v_period_start_date
      AND period.end_date = v_period_end_date
      AND period.stmt_id = stmt.stmt_id
      AND stmt.stat_cd = 'CO';

     stmt_rec2                 c_stmt_id_bg_id%ROWTYPE;

      CURSOR c_stmt_id_bg_id1 (v_stmt_name VARCHAR2, v_period_start_date IN DATE,v_period_end_date IN DATE)
     IS
      SELECT stmt.stmt_id stmt_id, period.stmt_perd_id period_id ,stmt.business_group_id bg_id
      FROM ben_tcs_stmt stmt , ben_tcs_stmt_perd period
      WHERE stmt.NAME = v_stmt_name
      AND period.start_date = v_period_start_date
      AND period.end_date = v_period_end_date
      AND period.stmt_id = stmt.stmt_id;

     stmt_rec1                 c_stmt_id_bg_id1%ROWTYPE;

     CURSOR c_person_valid_emp ( v_person_id IN NUMBER ,
                                    v_period_st_dt IN DATE,
                                      v_period_end_dt IN DATE
     )
     IS
    SELECT DISTINCT papf.person_id, papf.full_name NAME
           FROM per_all_people_f papf,
                per_all_assignments_f paaf
          WHERE papf.person_id = v_person_id
            AND EXISTS (
	              SELECT 'x'
	                FROM per_person_type_usages_f ptu, per_person_types ppt
	               WHERE ptu.person_id = papf.person_id
	                 AND ptu.effective_start_date <= v_period_end_dt           --period end date
	                 AND ptu.effective_end_date >= v_period_st_dt            --period start date
	                 AND ptu.person_type_id = ppt.person_type_id
	                 AND (   ppt.system_person_type IN ('EMP', 'CWK')
	                      OR (    ppt.system_person_type = 'EX_EMP'
	                          AND EXISTS (
	                                 SELECT NULL
	                                   FROM per_periods_of_service pps
	                                  WHERE papf.person_id = pps.person_id
	                                    AND pps.date_start <= v_period_end_dt   --period end date
	                                    AND pps.final_process_date >=
	                                                           v_period_st_dt
	                                                             --period start date
	                                                             )
	                         )
	                      OR (    ppt.system_person_type = 'EX_CWK'
	                          AND EXISTS (
	                                 SELECT NULL
	                                   FROM per_periods_of_placement pps
	                                  WHERE papf.person_id = pps.person_id
	                                    AND pps.date_start <= v_period_end_dt   --period end date
	                                    AND pps.final_process_date >=
	                                                           v_period_st_dt
	                                                             --period start date
	                                                             )
	                         )
	                     ))
	              AND paaf.person_id = papf.person_id
	              AND paaf.primary_flag = 'Y'
	              AND paaf.assignment_type IN ('E', 'C')
	              AND paaf.effective_end_date >= v_period_st_dt
	              AND paaf.effective_start_date <= v_period_end_dt
	              AND papf.effective_start_date <= v_period_end_dt
            	      AND papf.effective_end_date >= v_period_st_dt;



      TYPE stmt_record IS RECORD (
         statement_rec   c_stmt_id_bg_id%ROWTYPE
        );

      TYPE stmt_record_tab IS TABLE OF stmt_record
         INDEX BY BINARY_INTEGER;
      stmt_record_rec           stmt_record_tab;

      TYPE stmt_record1 IS RECORD (
         statement_rec1   c_stmt_id_bg_id1%ROWTYPE
        );

      TYPE stmt_record_tab1 IS TABLE OF stmt_record1
         INDEX BY BINARY_INTEGER;
      stmt_record_rec1           stmt_record_tab1;

     CURSOR c_bus_grp_id (v_stmt_id IN NUMBER)
     IS
        SELECT business_group_id
        FROM ben_tcs_stmt stmt
        WHERE stmt.stmt_id = v_stmt_id;

     CURSOR c_check_stmt_person(v_person_id IN NUMBER ,v_stmt_id IN NUMBER ,v_perd_id IN NUMBER)
     IS
          SELECT  stmt.person_id ,per.full_name name
          FROM BEN_TCS_PER_STMT_PERD  stmt,per_all_people_f per
          WHERE  stmt.stmt_id =  v_stmt_id
          AND stmt.stmt_perd_id   = v_perd_id
          AND stmt.person_id = v_person_id
          and per.person_id  = stmt.person_id
          AND trunc(sysdate) between per.effective_start_date and per.effective_end_date;

      stmt_per_rec               c_check_stmt_person%ROWTYPE;

     CURSOR c_check_stmt_avail(v_stmt_id IN NUMBER ,v_perd_id IN NUMBER)
     IS
          SELECT  stmt.person_id, per.full_name name
          FROM BEN_TCS_PER_STMT_PERD  stmt,per_all_people_f per
          WHERE  stmt.stmt_id =  v_stmt_id
          AND stmt.stmt_perd_id  = v_perd_id
          AND per.person_id = stmt.person_id
          AND trunc(sysdate) between per.effective_start_date and per.effective_end_date;

      per_rec                   c_person_selection%ROWTYPE;

      l_person_action_ids       g_number_type             := g_number_type();
      l_person_ids              g_number_type             := g_number_type();
      l_stmt_ids                g_number_type             := g_number_type();
      l_perd_ids                g_number_type             := g_number_type();
      l_bg_ids                  g_number_type             := g_number_type();
      l_score_tab               ben_evaluate_elig_profiles.scoretab;
      l_item_cnt                NUMBER                                :=1;
      t_prof_tbl                ben_evaluate_elig_profiles.proftab;
      l_status                  BOOLEAN;
      All_Bg                    VARCHAR(10) := 'N';
      l_person_temp             NUMBER := 0 ;
      p_bg_name                 VARCHAR(240);
      p_ee_name                 VARCHAR(240);
      rep_count                 NUMBER;
      hrchy_cnt                 NUMBER;
      extend_cnt                NUMBER;



   BEGIN
      g_actn := 'Stating the Total Compensation Statement process : ' ;
     --  hr_utility.trace_on(null,'tcs');
      hr_utility.set_location('Entering '||g_actn,150);

      IF (p_run_type = 'GEN') THEN
        g_actn := g_actn || ' Statement Generation.' ;
      ELSIF (p_run_type = 'PURGE') THEN
        g_actn := g_actn || ' Statement Purge.' ;
      ELSE
        g_actn := g_actn || ' Reopen welcome Page .' ;
      END  IF ;
      WRITE (g_actn);

      l_business_group_id  := p_business_group_id;
      IF (l_business_group_id is null ) THEN
        All_Bg := 'Y';
      ELSE
        All_Bg := 'N';
      END IF;

      g_proc := g_package || '.process';

      SELECT start_date , end_date
        INTO l_period_start_date,
             l_actual_end_date
        FROM ben_tcs_stmt_perd
        WHERE stmt_perd_id = p_period_id ;

      WRITE ('=====================process====================');
      WRITE ('||Parameter  Description     ');
      WRITE ('||Validate              -   ' || p_validate);
      WRITE ('||Run Type              -   ' || p_run_type);
      WRITE ('||statement Name        -   ' || p_stmt_name);
      WRITE ('||statement Id          -   ' || p_stmt_id);
      WRITE ('||Statement Period Id   -   ' || p_period_id);
      WRITE ('||Period Start Date     -   ' || l_period_start_date);
      WRITE ('||Period End Date       -   ' || l_actual_end_date);
      WRITE ('||Interim End Date      -   ' || p_partial_end);
      WRITE ('||Person Id             -   ' || p_person_id);
	  WRITE ('||Organization Id       -   ' || p_org_id);
      WRITE ('||Location Id           -   ' || p_location_id);
      WRITE ('||Benefits Group Id     -   ' || p_ben_grp_id);
      WRITE ('||Payroll Id            -   ' || p_payroll_id);
      WRITE ('||Job Id                -   ' || p_job_id);
      WRITE ('||Position Id           -   ' || p_position_id);
      WRITE ('||Supervisor Id         -   ' || p_supervisor_id);
      WRITE ('||Audit Log             -   ' || p_audit_log);
      WRITE ('||Business Group Id     -   ' || p_business_group_id);
      WRITE ('||All Business Groups   -   ' || All_Bg );
      WRITE ('================================================');

      IF  ( p_partial_end IS NOT NULL) THEN
          l_period_end_date   := to_date(p_partial_end,'DD/MM/YYYY')   ;
      ELSE
          l_period_end_date   := l_actual_end_date  ;
      END IF;

      g_run_type := p_run_type;

      WRITE ('================== process Mode  ====================');

      IF (p_person_id IS NOT NULL) THEN
            g_actn := 'Processing single person ..';
      ELSIF(l_business_group_id IS NOT NULL) THEN
           g_actn := 'Processing single Business group  ..';
      else
           g_actn := 'Processing all Business groups  ..';
      END  IF;

      WRITE(g_actn);
      WRITE ('=====================================================');

      g_actn := 'initializing the process parameters';
      WRITE (g_actn);

      g_exec_param_rec.persons_selected := 0;
      g_exec_param_rec.stmt_errors := 0;
      g_exec_param_rec.persons_proc_succ := 0;
      g_exec_param_rec.persons_errored  := 0;
      g_exec_param_rec.business_group_id := p_business_group_id;
      g_exec_param_rec.start_date := SYSDATE;
      g_exec_param_rec.start_time := DBMS_UTILITY.get_time;
      g_validate                  :=     p_validate ;

      g_actn := 'Calling ben_batch_utils.ini...';
      hr_utility.set_location (g_actn,151);
      hr_utility.set_location ('ben_batch_utils.ini with PROC_INFO',152);
      ben_batch_utils.ini (p_actn_cd => 'PROC_INFO');

      g_actn := 'Calling benutils.get_parameter...';
      WRITE (g_actn);
      hr_utility.set_location(g_actn,153);
      WRITE (   'benutils.get_parameter with '
               || p_business_group_id
               || ' '
               || 'BENTCSSP'
               || ' '
               || l_max_errors_allowed
              );

      benutils.get_parameter (p_business_group_id      => nvl(l_business_group_id,HR_GENERAL.GET_BUSINESS_GROUP_ID),
                              p_batch_exe_cd           => 'BENTCSSP',
                              p_threads                => l_threads,
                              p_chunk_size             => l_chunk_size,
                              p_max_errors             => l_max_errors_allowed
                             );

      WRITE ( 'Values of l_threads is '
               || l_threads
               || ' and l_chunk_size is '
               || l_chunk_size
              );

      benutils.g_thread_id := 99;    -- need to investigate why this is needed

      g_actn := 'Creating benefit actions...';
      WRITE (g_actn);
      WRITE ('Time' || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));
      WRITE ('=====================Benefit Actions=======================');
      WRITE ('||Parameter                  value                         ');
      WRITE ('||p_request_id-             ' || fnd_global.conc_request_id);
      WRITE ('||p_program_application_id- ' || fnd_global.prog_appl_id);
      WRITE ('||p_program_id-             ' || fnd_global.conc_program_id);
      WRITE ('==========================================================');

      ben_benefit_actions_api.create_perf_benefit_actions
                         (p_benefit_action_id           => l_benefit_action_id,
                          p_process_date                => l_effective_date,
                          p_mode_cd                     => 'W',
                          p_derivable_factors_flag      => 'NONE',
                          p_validate_flag               => nvl(p_validate,'N'),
                          p_debug_messages_flag         => 'N' ,
                          p_business_group_id           => nvl(l_business_group_id,HR_GENERAL.GET_BUSINESS_GROUP_ID),
                          p_no_programs_flag            => 'N',
                          p_no_plans_flag               => 'N',
                          p_audit_log_flag              => nvl(p_audit_log,'N'),
                          p_pgm_id                     => -100,
                          p_person_id                   => p_person_id,
                          p_object_version_number       => l_object_version_number,
                          p_effective_date              => l_effective_date,
                          p_request_id                  => fnd_global.conc_request_id,
                          p_program_application_id      => fnd_global.prog_appl_id,
                          p_program_id                  => fnd_global.conc_program_id,
                          p_program_update_date         => SYSDATE,
                          p_bft_attribute1              => p_run_type,
                          p_uneai_effective_date        => to_date(p_partial_end,'DD/MM/YYYY'),
                          p_bft_attribute3              => p_stmt_name,
                          p_bft_attribute4              => p_period_id,
                          p_bft_attribute7              => All_Bg,
                          p_per_sel_dt_from             => l_period_start_date,
                          p_per_sel_dt_to               => l_actual_end_date
     );

      WRITE('Benefit Action Id is ' || l_benefit_action_id);
      benutils.g_benefit_action_id := l_benefit_action_id;
      g_actn := 'Inserting Person Actions...';
      WRITE (g_actn);
      WRITE (   'Time before processing the person selections '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
              );

      g_actn := 'Before Processing statement id and Eligibility Id .';
      WRITE (g_actn);

      IF (p_run_type ='GEN') THEN
             IF ( p_person_id IS NOT NULL ) THEN
                 OPEN c_stmt_id (p_stmt_id,
                          p_period_id);
                 FETCH c_stmt_id
                  INTO stmt_rec;
                 CLOSE c_stmt_id;

                g_exec_param_rec.Number_Of_BGs :=1;

            ELSIF (l_business_group_id IS NULL) THEN
              --IF( FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP')='Y' ) THEN
                SELECT name
                INTO l_stmt_name
                FROM BEN_TCS_STMT
                WHERE stmt_id = p_stmt_id
                AND name = p_stmt_name;
                IF ( l_stmt_name IS NULL ) THEN
                        WRITE('The statement Name has been changed ');
                        fnd_message.set_name ('BEN', 'BEN_TCS_STMT_NAME_CHG');
                        fnd_message.raise_error;
                END IF;
                OPEN c_stmt_id_bg_id (p_stmt_name , l_period_start_date ,l_actual_end_date);
                 LOOP
                    FETCH c_stmt_id_bg_id
                        INTO stmt_rec2;
                    EXIT WHEN c_stmt_id_bg_id%NOTFOUND;

                    l_count := l_count + 1;
                    stmt_record_rec (l_count).statement_rec := stmt_rec2;
                  END LOOP;

                    hr_utility.set_location( 'Number of statement ids to be processed '||l_count,154);
                    g_exec_param_rec.Number_Of_BGs  :=l_count;
                CLOSE c_stmt_id_bg_id;
           /* ELSE
               l_business_group_id := HR_GENERAL.GET_BUSINESS_GROUP_ID ;
               g_exec_param_rec.Number_Of_BGs  :=1;
               OPEN c_stmt_id (p_stmt_id, p_period_id);
                FETCH c_stmt_id
                    INTO stmt_rec;
               CLOSE c_stmt_id;
            END IF;*/

      ELSE

        g_exec_param_rec.Number_Of_BGs  :=1;
        OPEN c_stmt_id (p_stmt_id, p_period_id);
           FETCH c_stmt_id
             INTO stmt_rec;
        CLOSE c_stmt_id;

      END IF;
     g_actn := 'After Processing statement id and Eligibility Id .';
     hr_utility.set_location( g_actn,155);

        IF (l_business_group_id IS NOT NULL OR p_person_id IS NOT NULL ) THEN
          WRITE ('****************statement validation ************');
          g_actn := 'Before statement validation ...' ;
          hr_utility.set_location(g_actn,157);
          g_actn := 'Statement id to be validated :' || stmt_rec.stmt_id;
          hr_utility.set_location (g_actn,158);
          WRITE (   'Time before validating the stataement '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
              );
          hr_utility.set_location (g_actn,159);


          ben_tcs_stmt_valid_hrchy.stmt_gen_valid_process (
                            stmt_rec.stmt_id,
                            stmt_rec.bg_id ,
                            p_period_id ,
                            item_hrchy_values,
                            subcat_hrchy_values,
                            l_status) ;

            g_actn := 'After statement validation ...' ;
            hr_utility.set_location (g_actn,160);
            WRITE (   'Time after validating the stataement '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
              );
            WRITE (g_actn);

            IF (l_status = true )THEN
                WRITE ('valid statement setup...');
                stmt_rec.valid_flag := 'Y';
            ELSE
                g_exec_param_rec.stmt_errors := g_exec_param_rec.stmt_errors +1;
                stmt_rec.valid_flag := 'N';
                get_name(
                    l_business_group_id ,
                    stmt_rec.ee_id  ,
                    l_period_end_date ,
                    p_bg_name ,
                    p_ee_name);

                rep_count := l_rep_rec.COUNT +1;
                l_rep_rec(rep_count  ).p_TYPE := -1;
                l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
                l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
                l_rep_rec(rep_count  ).ELIGY_ID := stmt_rec.ee_id;
                l_rep_rec(rep_count  ).STMT_ID := stmt_rec.stmt_id ;
                l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
                l_rep_rec(rep_count  ).ELIGY_PROF_NAME := p_ee_name;
                l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
                l_rep_rec(rep_count  ).SETUP_VALID := 'N';

                WRITE ('invalid statement setup ...');
                fnd_message.set_name ('BEN', 'BEN_TCS_CON_INVALID_STMT');
                fnd_message.raise_error;

            END IF;
            WRITE ('********************************************');


        ELSE

          WRITE('Total number of statements to be processed : '||l_count);
          IF l_count = 0 THEN
             WRITE( 'No statement exist ' );
             fnd_message.set_name ('BEN', 'BEN_TCS_CON_NO_STMT');
             fnd_message.raise_error;
          END IF;
          WHILE (l_loop_cnt <= l_count)
          LOOP
             g_actn := 'Processing  the statement :'|| stmt_record_rec (l_loop_cnt).statement_rec.stmt_id;
             hr_utility.set_location (g_actn,161);
             WRITE ('****************statement validation ************');
             g_actn := 'Before statement validation ...' ;
             hr_utility.set_location (g_actn,162);
             g_actn := 'Statement id to be validated :' || stmt_rec.stmt_id;
             WRITE (g_actn);
             WRITE (   'Time before validating the stataement '
                            || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
                              );

             ben_tcs_stmt_valid_hrchy.stmt_gen_valid_process(
                     stmt_record_rec (l_loop_cnt).statement_rec.stmt_id,
                     stmt_record_rec (l_loop_cnt).statement_rec.bg_id ,
                     stmt_record_rec (l_loop_cnt).statement_rec.period_id ,
                     item_hrchy_values, subcat_hrchy_values,
                     l_status);

              g_actn := 'After statement validation ...' ;
              hr_utility.set_location (g_actn,163);
              WRITE (   'Time after validating the stataement '
                       || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
                      );
              WRITE (g_actn);
              IF (l_status = true) THEN

                WRITE ('valid statement setup...');
                   stmt_record_rec (l_loop_cnt).statement_rec.valid_flag := 'Y';
                 IF (stmt_record_rec (l_loop_cnt).statement_rec.ee_id IS NOT NULL ) THEN
                   SELECT ELIGY_PRFL_ID INTO stmt_record_rec (l_loop_cnt).statement_rec.ee_id
                    FROM BEN_ELIGY_PRFL_F
                    WHERE STAT_CD='A'
                      AND ELIGY_PRFL_ID = stmt_record_rec (l_loop_cnt).statement_rec.ee_id
                      AND l_period_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

               END IF;


              ELSE
                 BEGIN
                     WRITE ('Invalid statement setup...');

                     g_exec_param_rec.stmt_errors := g_exec_param_rec.stmt_errors +1;
                     stmt_record_rec (l_loop_cnt).statement_rec.valid_flag := 'N';
                     get_name(stmt_record_rec (l_loop_cnt).statement_rec.bg_id ,
                              stmt_record_rec (l_loop_cnt).statement_rec.ee_id   ,
                              l_period_end_date ,
                              p_bg_name ,
                              p_ee_name);
                     rep_count := l_rep_rec.COUNT +1;
                     l_rep_rec(rep_count ).p_TYPE := -1;
                     l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
                     l_rep_rec(rep_count  ).BUSINESS_GROUP_ID :=  stmt_record_rec (l_loop_cnt).statement_rec.bg_id;
                     l_rep_rec(rep_count  ).ELIGY_ID :=stmt_record_rec (l_loop_cnt).statement_rec.ee_id ;
                     l_rep_rec(rep_count  ).STMT_ID := stmt_record_rec (l_loop_cnt).statement_rec.stmt_id ;
                     l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
                     l_rep_rec(rep_count  ).ELIGY_PROF_NAME := p_ee_name;
                     l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
                     l_rep_rec(rep_count  ).SETUP_VALID := 'N';

                     EXCEPTION
                     WHEN others THEN
                        WRITE ( 'The statement id:'|| stmt_record_rec (l_loop_cnt).statement_rec.stmt_id
                          ||':'|| stmt_record_rec (l_loop_cnt).statement_rec.bg_id || 'is not valid');
                 END;
                 END IF;
                 WRITE ('********************************************');
             l_loop_cnt := l_loop_cnt + 1;
          END LOOP;
        END IF;

        WRITE ('****************processing the person ************');
        g_actn := 'before processing person ids..' ;
        hr_utility.set_location (g_actn,164);
        WRITE (   'Time before processing person ids .. '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
              );
        WRITE (g_actn);

        IF ( p_person_id IS NOT NULL  AND  stmt_rec.valid_flag = 'Y') THEN
          OPEN c_person_valid_emp ( p_person_id ,l_period_start_date,l_period_end_date);
          hr_utility.set_location( 'processing the person id  ' ||p_person_id,165);
          FETCH c_person_valid_emp into per_rec;
          IF c_person_valid_emp%NOTFOUND THEN

             get_name(l_business_group_id ,
                    stmt_rec.ee_id  ,
                    l_period_end_date ,
                    p_bg_name ,
                    p_ee_name);

             rep_count := l_rep_rec.COUNT +1;
             l_rep_rec(rep_count  ).p_TYPE := -1;
             l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
             l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
             l_rep_rec(rep_count  ).ELIGY_ID :=temp_ee_id ;
             l_rep_rec(rep_count  ).STMT_ID := stmt_rec.stmt_id;
             l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
             l_rep_rec(rep_count  ).ELIGY_PROF_NAME := p_ee_name;
             l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
             l_rep_rec(rep_count  ).SETUP_VALID := 'Y';
             l_rep_rec(rep_count  ).TOTAL_PERSONS := 0 ;

             hr_utility.set_location('The person id :'||p_person_id || 'is not valid for this period' ||stmt_rec.stmt_id,165);
             fnd_message.set_name ('BEN', 'BEN_TCS_CON_NO_VALID_PERSON');
             fnd_message.raise_error;

          ELSE
            t_prof_tbl (1).mndtry_flag := 'N';
            t_prof_tbl (1).compute_score_flag := 'N';
            t_prof_tbl (1).trk_scr_for_inelg_flag := 'N';

            IF ( stmt_rec.ee_id  IS NOT NULL ) THEN
              hr_utility.set_location('checking the eligibity of the person_id id :'|| p_person_id ||'.Eligibility profile id  is
                 '||stmt_rec.ee_id ,166 );

               SELECT ELIGY_PRFL_ID INTO temp_ee_id
                    FROM BEN_ELIGY_PRFL_F
                    WHERE STAT_CD='A'
                      AND ELIGY_PRFL_ID =  stmt_rec.ee_id
                      AND l_period_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

               t_prof_tbl (1).eligy_prfl_id := stmt_rec.ee_id ;
               hr_utility.set_location( 'valid eligy id'|| temp_ee_id ,166) ;
               BEGIN
               IF (temp_ee_id is not null ) THEN
               hr_utility.set_location('before calling  ben_evaluate_elig_profiles.eligible...',167);

                 ben_env_object.init(
                             p_business_group_id=>l_business_group_id,
                             p_effective_date   =>l_period_end_date,
                             p_thread_id         => 99 ,
                             p_chunk_size       => l_chunk_size ,
                             p_threads          => l_threads ,
                             p_max_errors       => l_max_errors_allowed,
                             p_benefit_action_id => l_benefit_action_id
                    );

                 l_elig_return_status :=
                   ben_evaluate_elig_profiles.eligible
                                    (p_person_id              => p_person_id,
                                     p_business_group_id      => l_business_group_id,
                                     p_effective_date         => l_period_end_date,
                                     p_eligprof_tab           => t_prof_tbl,
                                     p_comp_obj_mode          => FALSE,
                                     p_score_tab              => l_score_tab
                                    );

                hr_utility.set_location('After  ben_evaluate_elig_profiles.eligible...',168);
               ELSE
                  l_elig_return_status := TRUE ;
               END IF;
               EXCEPTION
                    WHEN OTHERS THEN
                 hr_utility.set_location('Exception : '||SQLERRM,10);
                 l_elig_return_status := FALSE ;
               END;
            ELSE
              hr_utility.set_location('No eligibility profile attached to the statement' ||stmt_rec.stmt_id ||
               'The person id  '||p_person_id|| 'is eligible for processing .',169 );

               l_elig_return_status := TRUE ;
          END IF;

          IF l_elig_return_status   THEN

            l_num_rows := l_num_rows + 1;
            l_num_persons := l_num_persons + 1;
            l_person_action_ids.EXTEND (1);
            l_person_ids.EXTEND (1);
            l_stmt_ids.EXTEND (1);
            l_perd_ids.EXTEND (1);
            l_bg_ids.EXTEND (1);
            get_name(   l_business_group_id ,
                        temp_ee_id ,
                        l_period_end_date ,
                        p_bg_name ,
                        p_ee_name);
            rep_count := l_rep_rec.COUNT+1 ;
            l_rep_rec(rep_count  ).p_TYPE := -1;
            l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
            l_rep_rec(rep_count  ).ELIGY_ID :=temp_ee_id;
            l_rep_rec(rep_count  ).STMT_ID := stmt_rec.stmt_id;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
            l_rep_rec(rep_count  ).ELIGY_PROF_NAME := p_ee_name;
            l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
            l_rep_rec(rep_count  ).SETUP_VALID := 'Y';
            l_rep_rec(rep_count  ).TOTAL_PERSONS := 1 ;
            l_rep_rec(rep_count  ).PERIOD_ID := stmt_rec.period_id;

            SELECT ben_person_actions_s.NEXTVAL
              INTO l_person_action_ids (l_num_rows)
              FROM DUAL;

            l_person_ids (l_num_rows) := p_person_id;
            l_stmt_ids (l_num_rows) := stmt_rec.stmt_id;
            l_perd_ids(l_num_rows) := stmt_rec.period_id;
            l_bg_ids(l_num_rows) := l_business_group_id;

            WRITE ('=====================Person Header====================');
            WRITE ('||Person Name       -' || per_rec.name);
            WRITE ('||Business Group    -' || p_bg_name   ) ;
            WRITE ('||Person Id         -' || p_person_id);
            WRITE ('||Business Group Id -' || l_business_group_id   ) ;
            WRITE ('||stmt_id           -' || stmt_rec.stmt_id);
            WRITE ('||Person Action id  -' || l_person_action_ids (l_num_rows));
            WRITE ('=======================================================');

            IF l_num_rows = l_chunk_size THEN
               l_num_ranges := l_num_ranges + 1;
                hr_utility.set_location('inserting INTO person actions :..',170);
                g_actn := 'inserting INTO person actions : person id  ' || p_person_id ;
                hr_utility.set_location(g_actn,171);

               insert_person_actions
                                 (p_per_actn_id_array      => l_person_action_ids,
                                  p_per_id                 => l_person_ids,
                                  p_benefit_action_id      => l_benefit_action_id,
                                  p_stmt_id                =>l_stmt_ids,
                                  p_perd_id                =>l_perd_ids,
                                  p_bg_id                 =>l_bg_ids
                                 );
               l_num_rows := 0;
               l_person_action_ids.DELETE;
               l_person_ids.DELETE;
               l_stmt_ids.DELETE;
               l_bg_ids.DELETE;
               l_perd_ids.DELETE;
            END IF;
          ELSE
                hr_utility.set_location('The person id :'||p_person_id || 'is not eligible  for the statement' ||stmt_rec.stmt_id ,171);
                --fnd_message.set_name ('BEN', 'BEN_TCS_CON_NO_ELIG_PERSON');
                --fnd_message.raise_error;
                get_name(l_business_group_id ,
                         temp_ee_id ,
                         l_period_end_date ,
                         p_bg_name ,
                         p_ee_name);
                 rep_count := l_rep_rec.COUNT +1;
                 l_rep_rec(rep_count  ).p_TYPE := -1;
                 l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
                 l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
                 l_rep_rec(rep_count  ).ELIGY_ID :=temp_ee_id ;
                 l_rep_rec(rep_count  ).STMT_ID := stmt_rec.stmt_id;
                 l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
                 l_rep_rec(rep_count  ).ELIGY_PROF_NAME := p_ee_name;
                 l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
                 l_rep_rec(rep_count  ).SETUP_VALID := 'Y';
                 l_rep_rec(rep_count  ).TOTAL_PERSONS := 0 ;

          END IF;
        END IF;

        ELSIF (l_business_group_id IS NOT NULL  AND  stmt_rec.valid_flag = 'Y' ) THEN

          g_actn := 'processing  person ids for the business group id  ' || l_business_group_id ;
          hr_utility.set_location(g_actn,172);
          temp_ee_id :=null;
          IF (stmt_rec.ee_id IS NOT NULL ) THEN
                SELECT ELIGY_PRFL_ID INTO temp_ee_id
                    FROM BEN_ELIGY_PRFL_F
                    WHERE STAT_CD='A'
                    AND ELIGY_PRFL_ID = stmt_rec.ee_id
                    AND l_period_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;
          END IF;
          OPEN c_person_selection (stmt_rec.stmt_id,
                                  l_period_start_date,
                                  l_period_end_date ,
                                  l_business_group_id,
                                  p_ben_grp_id,
                                  p_position_id,
                                  p_job_id,
                                  p_payroll_id,
                                  p_location_id,
                                  p_supervisor_id,
                                  p_org_id
                                 );

          t_prof_tbl (1).mndtry_flag := 'N';
          t_prof_tbl (1).compute_score_flag := 'N';
          t_prof_tbl (1).trk_scr_for_inelg_flag := 'N';
          get_name(l_business_group_id ,
                   temp_ee_id ,
                   l_period_end_date ,
                   p_bg_name ,
                   p_ee_name);
          LOOP
            FETCH c_person_selection
                  INTO per_rec;
            EXIT WHEN c_person_selection%NOTFOUND;

            g_actn := 'processing the person id  ' || per_rec.person_id ;
            hr_utility.set_location(g_actn,173);
            BEGIN
            IF (stmt_rec.ee_id IS NOT NULL ) THEN
               t_prof_tbl (1).eligy_prfl_id := stmt_rec.ee_id;
               IF (temp_ee_id is not null ) THEN

                  ben_env_object.init(
                             p_business_group_id  => stmt_rec.bg_id,
                             p_effective_date     => l_period_end_date,
                             p_thread_id          => 99 ,
                             p_chunk_size         => l_chunk_size ,
                             p_threads            => l_threads ,
                             p_max_errors         => l_max_errors_allowed,
                             p_benefit_action_id  => l_benefit_action_id
                  );

                  hr_utility.set_location('before calling  ben_evaluate_elig_profiles.eligible...'  ,174);
                        l_elig_return_status :=
                        ben_evaluate_elig_profiles.eligible
                                    (p_person_id              => per_rec.person_id,
                                     p_business_group_id      => stmt_rec.bg_id ,
                                     p_effective_date         => l_period_end_date,
                                     p_eligprof_tab           => t_prof_tbl,
                                     p_comp_obj_mode          => FALSE,
                                     p_score_tab              => l_score_tab
                                    );
                   hr_utility.set_location('after ben_evaluate_elig_profiles.eligible...',175);
               ELSE
                      l_elig_return_status := TRUE ;
               END IF;

            ELSE
                 l_elig_return_status := TRUE ;
            END IF;
              EXCEPTION
                 WHEN OTHERS THEN
                 hr_utility.set_location('Exception : '||SQLERRM,10);
                 l_elig_return_status := FALSE ;
               END;
            IF l_elig_return_status THEN

              hr_utility.set_location( 'The person id ' || per_rec.person_id || ' is  eligible for the statement ' ||
              stmt_rec.stmt_id,176);

              l_num_rows := l_num_rows + 1;
              l_num_persons := l_num_persons + 1;
              l_person_action_ids.EXTEND (1);
              l_person_ids.EXTEND (1);
              l_stmt_ids.EXTEND (1);
              l_perd_ids.EXTEND (1);
              l_bg_ids.EXTEND (1);

              hr_utility.set_location ('Adding  the person id :' ||per_rec.person_id ,177);

              SELECT ben_person_actions_s.NEXTVAL
                 INTO l_person_action_ids (l_num_rows)
                FROM DUAL;

              l_person_ids (l_num_rows) := per_rec.person_id;
              l_stmt_ids (l_num_rows) := stmt_rec.stmt_id;
              l_perd_ids(l_num_rows) := stmt_rec.period_id;
              l_bg_ids(l_num_rows) := stmt_rec.bg_id;


              WRITE ('=====================Person Header====================');
              WRITE ('||Person Name       -' || per_rec.name);
              WRITE ('||Business Group    -' || p_bg_name   ) ;
              WRITE ('||Person Id         -' || per_rec.person_id);
              WRITE ('||Business Group Id -' || stmt_rec.bg_id   ) ;
              WRITE ('||stmt_id           -' || stmt_rec.stmt_id);
              WRITE ('||Person Action id  -' || l_person_action_ids (l_num_rows));
              WRITE ('=======================================================');

              IF l_num_rows = l_chunk_size
              THEN
                g_actn := 'inserting INTO person actions   ';
                hr_utility.set_location(g_actn,178);

                l_num_ranges := l_num_ranges + 1;
                insert_person_actions
                                 (p_per_actn_id_array      => l_person_action_ids,
                                  p_per_id                 => l_person_ids,
                                  p_benefit_action_id      => l_benefit_action_id,
                                  p_stmt_id                =>l_stmt_ids,
                                  p_perd_id                =>l_perd_ids,
                                  p_bg_id                 =>l_bg_ids
                                 );
                 l_num_rows := 0;
                 l_person_action_ids.DELETE;
                 l_person_ids.DELETE;
                 l_stmt_ids.DELETE;
                 l_perd_ids.DELETE;
                 l_bg_ids.DELETE;
              END IF;
            ELSE
                hr_utility.set_location( 'The person id ' || per_rec.person_id || ' is not eligible for the statement ' ||
                stmt_rec.stmt_id,179);
            END IF;
          END LOOP;

          rep_count := l_rep_rec.COUNT +1;
          l_rep_rec(rep_count  ).p_TYPE := -1;
          l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
          l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
          l_rep_rec(rep_count  ).ELIGY_ID :=temp_ee_id ;
          l_rep_rec(rep_count  ).STMT_ID := stmt_rec.stmt_id;
          l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
          l_rep_rec(rep_count  ).ELIGY_PROF_NAME := p_ee_name;
          l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
          l_rep_rec(rep_count  ).SETUP_VALID := 'Y';
          l_rep_rec(rep_count  ).TOTAL_PERSONS := l_num_persons ;
          l_rep_rec(rep_count  ).PERIOD_ID := stmt_rec.period_id;

          CLOSE c_person_selection;

        ELSIF (l_business_group_id IS  NULL ) THEN

          l_loop_cnt := 1;
          t_prof_tbl (1).mndtry_flag := 'N';
          t_prof_tbl (1).compute_score_flag := 'N';
          t_prof_tbl (1).trk_scr_for_inelg_flag := 'N';

          WHILE (l_loop_cnt <= l_count)
          LOOP
            l_person_temp := 0;

            g_actn := 'processing the stmt id  ' || stmt_record_rec (l_loop_cnt).statement_rec.stmt_id ;
            hr_utility.set_location(g_actn,180);

            IF (stmt_record_rec (l_loop_cnt).statement_rec.valid_flag = 'Y' ) THEN
               OPEN c_person_selection (stmt_record_rec (l_loop_cnt).statement_rec.stmt_id,
                                        l_period_start_date,
                                        l_period_end_date ,
                                        stmt_record_rec (l_loop_cnt).statement_rec.bg_id,
										p_ben_grp_id,
                                  		p_position_id,
                                  		p_job_id,
                                  		p_payroll_id,
                                  		p_location_id,
                                  		p_supervisor_id,
                                  		p_org_id);
                get_name(stmt_record_rec (l_loop_cnt).statement_rec.bg_id ,
                        stmt_record_rec (l_loop_cnt).statement_rec.ee_id   ,
                        l_period_end_date ,
                        p_bg_name ,
                        p_ee_name);
               LOOP
                  FETCH c_person_selection
                     INTO per_rec;
                  EXIT WHEN c_person_selection%NOTFOUND;

                  g_actn := 'processing the person id  ' || per_rec.person_id  ;
                  hr_utility.set_location(g_actn,181);
                 BEGIN
                  IF (stmt_record_rec (l_loop_cnt).statement_rec.ee_id IS NOT NULL ) THEN

                    hr_utility.set_location ('checking the eligibility of the person id ' ||per_rec.person_id,182 );

                    t_prof_tbl (1).eligy_prfl_id := stmt_record_rec (l_loop_cnt).statement_rec.ee_id;

                       ben_env_object.init(
                             p_business_group_id  => stmt_record_rec (l_loop_cnt).statement_rec.bg_id ,
                             p_effective_date     => l_period_end_date,
                             p_thread_id          => 99 ,
                             p_chunk_size         => l_chunk_size ,
                             p_threads            => l_threads ,
                             p_max_errors         => l_max_errors_allowed,
                             p_benefit_action_id  => l_benefit_action_id
                       );
                       hr_utility.set_location('Before calling  ben_evaluate_elig_profiles.eligible...',183);
                         l_elig_return_status :=
                             ben_evaluate_elig_profiles.eligible
                                    (p_person_id              => per_rec.person_id,
                                     p_business_group_id      => stmt_record_rec (l_loop_cnt).statement_rec.bg_id ,
                                     p_effective_date         => l_period_end_date,
                                     p_eligprof_tab           => t_prof_tbl,
                                     p_comp_obj_mode          => FALSE,
                                     p_score_tab              => l_score_tab
                                    );
                  ELSE
                       l_elig_return_status := TRUE ;
                  END IF;
                    EXCEPTION
                    WHEN OTHERS THEN
                    hr_utility.set_location('Exception : '||SQLERRM,10);
                    l_elig_return_status := FALSE ;
               END;
                  IF l_elig_return_status THEN

                     l_num_rows := l_num_rows + 1;
                     l_num_persons := l_num_persons + 1;
                     l_person_temp := l_person_temp + 1;
                     l_person_action_ids.EXTEND (1);
                     l_person_ids.EXTEND (1);
                     l_stmt_ids.EXTEND (1);
                     l_perd_ids.EXTEND (1);
                     l_bg_ids.EXTEND (1);

                     hr_utility.set_location ('Adding  the person id :' ||per_rec.person_id ,184);

                     SELECT ben_person_actions_s.NEXTVAL
                        INTO l_person_action_ids (l_num_rows)
                        FROM DUAL;

                     l_person_ids (l_num_rows) := per_rec.person_id;
                     l_stmt_ids (l_num_rows) := stmt_record_rec (l_loop_cnt).statement_rec.stmt_id;
                     l_perd_ids(l_num_rows) :=  stmt_record_rec (l_loop_cnt).statement_rec.period_id;
                     l_bg_ids(l_num_rows) :=stmt_record_rec (l_loop_cnt).statement_rec.bg_id;

                     WRITE ('=====================Person Header====================');
                     WRITE ('||Person Name       -' || per_rec.name);
                     WRITE ('||Business Group    -' || p_bg_name   ) ;
                     WRITE ('||Person Id         -' || per_rec.person_id);
                     WRITE ('||Business Group Id -' || stmt_record_rec (l_loop_cnt).statement_rec.bg_id  ) ;
                     WRITE ('||stmt_id           -' || stmt_record_rec (l_loop_cnt).statement_rec.stmt_id);
                     WRITE ('||Person Action id  -' || l_person_action_ids (l_num_rows));
                     WRITE ('=======================================================');


                     IF l_num_rows = l_chunk_size THEN
                            g_actn := 'inserting INTO person actions   ';
                            hr_utility.set_location(g_actn,185);
                            l_num_ranges := l_num_ranges + 1;
                            insert_person_actions
                                 (p_per_actn_id_array      => l_person_action_ids,
                                  p_per_id                 => l_person_ids,
                                  p_benefit_action_id      => l_benefit_action_id,
                                  p_stmt_id                =>l_stmt_ids,
                                  p_perd_id                =>l_perd_ids,
                                  p_bg_id                 =>l_bg_ids
                                 );
                            l_num_rows := 0;
                            l_person_action_ids.DELETE;
                            l_person_ids.DELETE;
                            l_stmt_ids.DELETE;
                            l_bg_ids.DELETE;
                            l_perd_ids.DELETE;
                     END IF;
                  ELSE
                    hr_utility.set_location ('The person : ' ||per_rec.person_id || 'is not eligible',186);
                  END IF;
               END LOOP;


               rep_count := l_rep_rec.COUNT+1 ;
               l_rep_rec(rep_count  ).p_TYPE := -1;
               l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
               l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := stmt_record_rec (l_loop_cnt).statement_rec.bg_id;
               l_rep_rec(rep_count  ).ELIGY_ID :=stmt_record_rec (l_loop_cnt).statement_rec.ee_id ;
               l_rep_rec(rep_count  ).STMT_ID :=stmt_record_rec (l_loop_cnt).statement_rec.stmt_id ;
               l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
               l_rep_rec(rep_count  ).ELIGY_PROF_NAME := p_ee_name;
               l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
               l_rep_rec(rep_count  ).SETUP_VALID := 'Y';
               l_rep_rec(rep_count  ).TOTAL_PERSONS := l_person_temp ;
               l_rep_rec(rep_count  ).PERIOD_ID := stmt_record_rec (l_loop_cnt).statement_rec.period_id;

            END IF;
            l_loop_cnt := l_loop_cnt + 1;
            CLOSE c_person_selection;
          END LOOP;
        END IF;

      ELSE
        IF (l_business_group_id IS NULL) THEN
             -- IF( FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP')='Y' ) THEN
                SELECT name
                INTO l_stmt_name
                FROM BEN_TCS_STMT
                WHERE stmt_id = p_stmt_id
                AND name = p_stmt_name;
                IF ( l_stmt_name IS NULL ) THEN
                        WRITE('The statement Name has been changed ');
                        fnd_message.set_name ('BEN', 'BEN_TCS_STMT_NAME_CHG');
                        fnd_message.raise_error;
                END IF;
                OPEN c_stmt_id_bg_id1 (p_stmt_name , l_period_start_date ,l_actual_end_date);
                 LOOP
                    FETCH c_stmt_id_bg_id1
                        INTO stmt_rec1;
                    EXIT WHEN c_stmt_id_bg_id1%NOTFOUND;

                    l_count := l_count + 1;
                    stmt_record_rec1 (l_count).statement_rec1 := stmt_rec1;
                  END LOOP;

                    hr_utility.set_location ('Number of statement ids to be processed '||l_count,187);
                    g_exec_param_rec.Number_Of_BGs  :=l_count;
                CLOSE c_stmt_id_bg_id1;
           /* ELSE
               l_business_group_id := HR_GENERAL.GET_BUSINESS_GROUP_ID ;
               g_exec_param_rec.Number_Of_BGs  :=1;
               END IF;*/
            END IF;

        IF ( p_person_id IS NOT NULL)THEN

          hr_utility.set_location('checking for the person_id id ... '||p_person_id,188);
          g_exec_param_rec.Number_Of_BGs :=1;
          OPEN c_check_stmt_person(p_person_id ,p_stmt_id, p_period_id ) ;

          FETCH c_check_stmt_person into stmt_per_rec;

          IF c_check_stmt_person%NOTFOUND THEN
               get_name( p_bg_id=> l_business_group_id ,
                         v_period_end_date  => l_period_end_date ,
                        p_bg_name =>p_bg_name ,
                        p_ee_name =>  p_ee_name);
               rep_count := l_rep_rec.COUNT +1;
               l_rep_rec(rep_count  ).p_TYPE := -1;
               l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
               l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
               l_rep_rec(rep_count  ).STMT_ID := p_stmt_id;
               l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
               l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
               l_rep_rec(rep_count  ).TOTAL_PERSONS := 0;
               l_rep_rec(rep_count  ).PERIOD_ID := p_period_id ;

               WRITE('The person id :'||p_person_id || 'doesnt have the statement' ||stmt_rec.stmt_id );
               fnd_message.set_name ('BEN', 'BEN_TCS_STMT_DOESNT_EXIST');
               fnd_message.raise_error;
          ELSE

            t_prof_tbl (1).mndtry_flag := 'N';
            t_prof_tbl (1).compute_score_flag := 'N';
            t_prof_tbl (1).trk_scr_for_inelg_flag := 'N';
            l_num_rows := l_num_rows + 1;
            l_num_persons := l_num_persons + 1;
            l_person_action_ids.EXTEND (1);
            l_person_ids.EXTEND (1);
            l_stmt_ids.EXTEND (1);
            l_perd_ids.EXTEND (1);
            l_bg_ids.EXTEND (1);

            SELECT ben_person_actions_s.NEXTVAL
              INTO l_person_action_ids (l_num_rows)
              FROM DUAL;

            l_person_ids (l_num_rows) := p_person_id;
             l_perd_ids(l_num_rows) := p_period_id;
            l_bg_ids(l_num_rows) := l_business_group_id;
            l_stmt_ids(l_num_rows) := p_stmt_id;

              WRITE ('=====================Person Header====================');
              WRITE ('||Person Name       -' || stmt_per_rec.name);
              WRITE ('||Business Group    -' || p_bg_name   ) ;
              WRITE ('||Person Id         -' || p_person_id);
              WRITE ('||Business Group Id -' || l_business_group_id   ) ;
              WRITE ('||stmt_id           -' || p_stmt_id);
              WRITE ('||Person Action id  -' || l_person_action_ids (l_num_rows));
              WRITE ('=======================================================');

            IF l_num_rows = l_chunk_size THEN
               l_num_ranges := l_num_ranges + 1;
                g_actn := 'inserting INTO person actions : person id  ' || p_person_id;
                hr_utility.set_location(g_actn,189);
                  insert_person_actions
                                 (p_per_actn_id_array      => l_person_action_ids,
                                  p_per_id                 => l_person_ids,
                                  p_benefit_action_id      => l_benefit_action_id,
                                  p_stmt_id                =>l_stmt_ids,
                                  p_perd_id                =>l_perd_ids,
                                  p_bg_id                 =>l_bg_ids
                                 );
               l_num_rows := 0;
               l_person_action_ids.DELETE;
               l_person_ids.DELETE;
               l_stmt_ids.DELETE;
               l_perd_ids.DELETE;
               l_bg_ids.DELETE;
            END IF;
            get_name(p_bg_id=> l_business_group_id ,
                      v_period_end_date  => l_period_end_date ,
                      p_bg_name =>p_bg_name ,
                      p_ee_name =>  p_ee_name);
                      rep_count := l_rep_rec.COUNT+1 ;

            l_rep_rec(rep_count  ).p_TYPE := -1;
            l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
            l_rep_rec(rep_count  ).STMT_ID := p_stmt_id ;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
            l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
            l_rep_rec(rep_count  ).TOTAL_PERSONS := 1;
            l_rep_rec(rep_count  ).PERIOD_ID := p_period_id ;
        END IF;
        CLOSE c_check_stmt_person ;
        ELSIF(l_business_group_id IS NOT NULL) THEN
            g_actn := 'processing the business group id  ' || l_business_group_id ;
            hr_utility.set_location(g_actn,190);
             g_exec_param_rec.Number_Of_BGs :=1;
            OPEN c_check_stmt_avail(p_stmt_id , p_period_id ) ;

            t_prof_tbl (1).mndtry_flag := 'N';
            t_prof_tbl (1).compute_score_flag := 'N';
            t_prof_tbl (1).trk_scr_for_inelg_flag := 'N';
            get_name(p_bg_id=> l_business_group_id ,
                        v_period_end_date  => l_period_end_date ,
                        p_bg_name =>p_bg_name ,
                        p_ee_name =>  p_ee_name);
            LOOP
              FETCH c_check_stmt_avail
                 INTO per_rec;
              EXIT WHEN c_check_stmt_avail%NOTFOUND;
              g_actn := 'processing the person id  ' || per_rec.person_id ;
              hr_utility.set_location(g_actn,191);

              l_num_rows := l_num_rows + 1;
              l_num_persons := l_num_persons + 1;
              l_person_action_ids.EXTEND (1);
              l_person_ids.EXTEND (1);
              l_stmt_ids.EXTEND (1);
              l_perd_ids.EXTEND (1);
              l_bg_ids.EXTEND (1);


              SELECT ben_person_actions_s.NEXTVAL
                INTO l_person_action_ids (l_num_rows)
                FROM DUAL;

              l_person_ids (l_num_rows) := per_rec.person_id;
              l_stmt_ids (l_num_rows) := p_stmt_id;
              l_perd_ids(l_num_rows) := p_period_id;
	          l_bg_ids(l_num_rows) := l_business_group_id;

              WRITE ('=====================Person Header====================');
              WRITE ('||Person Name       -' || per_rec.name);
              WRITE ('||Business Group    -' || p_bg_name   ) ;
              WRITE ('||Person Id         -' || per_rec.person_id);
              WRITE ('||Business Group Id -' || l_business_group_id   ) ;
              WRITE ('||stmt_id           -' || p_stmt_id);
              WRITE ('||Person Action id  -' || l_person_action_ids (l_num_rows));
              WRITE ('=======================================================');

              IF l_num_rows = l_chunk_size
              THEN
                g_actn := 'inserting INTO person actions   ';
                hr_utility.set_location(g_actn,192);
                l_num_ranges := l_num_ranges + 1;
                 insert_person_actions
	                                        (p_per_actn_id_array      => l_person_action_ids,
	                                         p_per_id                 => l_person_ids,
	                                         p_benefit_action_id      => l_benefit_action_id,
	                                         p_stmt_id                =>l_stmt_ids,
	                                         p_perd_id                =>l_perd_ids,
	                                         p_bg_id                 =>l_bg_ids
                                 );

                 l_num_rows := 0;
                 l_person_action_ids.DELETE;
                 l_person_ids.DELETE;
                 l_stmt_ids.DELETE;
                 l_perd_ids.DELETE;
                 l_bg_ids.DELETE;
              END IF;
            END LOOP;
            CLOSE c_check_stmt_avail;

               rep_count := l_rep_rec.COUNT +1;
               l_rep_rec(rep_count  ).p_TYPE := -1;
               l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
               l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := l_business_group_id;
               l_rep_rec(rep_count  ).STMT_ID := p_stmt_id ;
               l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
               l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
               l_rep_rec(rep_count  ).TOTAL_PERSONS := l_num_persons;
               l_rep_rec(rep_count  ).PERIOD_ID := p_period_id ;

        ELSIF (l_business_group_id is  null ) THEN

          l_loop_cnt := 1;
          t_prof_tbl (1).mndtry_flag := 'N';
          t_prof_tbl (1).compute_score_flag := 'N';
          t_prof_tbl (1).trk_scr_for_inelg_flag := 'N';
          WHILE (l_loop_cnt <= l_count)
          LOOP
            l_person_temp := 0;
            g_actn := 'processing the stmt id  ' || stmt_record_rec1 (l_loop_cnt).statement_rec1.stmt_id
              || 'period id :'||stmt_record_rec1 (l_loop_cnt).statement_rec1.period_id;
             hr_utility.set_location(g_actn,193);
            OPEN c_check_stmt_avail(stmt_record_rec1 (l_loop_cnt).statement_rec1.stmt_id ,stmt_record_rec1 (l_loop_cnt).statement_rec1.period_id ) ;
            get_name(p_bg_id=> stmt_record_rec1 (l_loop_cnt).statement_rec1.bg_id ,
                     v_period_end_date  => l_period_end_date ,
                     p_bg_name =>p_bg_name ,
                     p_ee_name =>  p_ee_name);
            LOOP
              WRITE ( 'getting person ids for the stmt id '||stmt_record_rec1 (l_loop_cnt).statement_rec1.stmt_id );
              FETCH c_check_stmt_avail
               INTO per_rec;
              EXIT WHEN c_check_stmt_avail%NOTFOUND;

              l_num_rows := l_num_rows + 1;
              l_num_persons := l_num_persons + 1;
              l_person_temp := l_person_temp +1;
              l_person_action_ids.EXTEND (1);
              l_person_ids.EXTEND (1);
              l_stmt_ids.EXTEND (1);
              l_perd_ids.EXTEND (1);
              l_bg_ids.EXTEND (1);

              hr_utility.set_location ('Adding  the person id :' ||per_rec.person_id ,193);


              SELECT ben_person_actions_s.NEXTVAL
              INTO l_person_action_ids (l_num_rows)
              FROM DUAL;

              l_person_ids (l_num_rows) := per_rec.person_id;
              l_stmt_ids (l_num_rows) := stmt_record_rec1 (l_loop_cnt).statement_rec1.stmt_id;
              l_perd_ids(l_num_rows) := stmt_record_rec1 (l_loop_cnt).statement_rec1.period_id;
	          l_bg_ids(l_num_rows) := stmt_record_rec1 (l_loop_cnt).statement_rec1.bg_id;

              WRITE ('=====================Person Header====================');
              WRITE ('||Person Name       -' || per_rec.name);
              WRITE ('||Business Group    -' || p_bg_name   ) ;
              WRITE ('||Person Id         -' || per_rec.person_id);
              WRITE ('||Business Group Id -' || stmt_record_rec1 (l_loop_cnt).statement_rec1.bg_id  ) ;
              WRITE ('||stmt_id           -' || stmt_record_rec1 (l_loop_cnt).statement_rec1.stmt_id);
              WRITE ('||Person Action id  -' || l_person_action_ids (l_num_rows));
              WRITE ('=======================================================');


              IF l_num_rows = l_chunk_size THEN
                g_actn := 'inserting INTO person actions   ';
                hr_utility.set_location(g_actn,194);
                l_num_ranges := l_num_ranges + 1;
                insert_person_actions
	                                        (p_per_actn_id_array      => l_person_action_ids,
	                                         p_per_id                 => l_person_ids,
	                                         p_benefit_action_id      => l_benefit_action_id,
	                                         p_stmt_id                =>l_stmt_ids,
	                                         p_perd_id                =>l_perd_ids,
	                                         p_bg_id                 =>l_bg_ids
                                 );

                l_num_rows := 0;
                l_person_action_ids.DELETE;
                l_person_ids.DELETE;
                l_stmt_ids.DELETE;
                l_perd_ids.DELETE;
               l_bg_ids.DELETE;
              END IF;

            END LOOP;


            rep_count := l_rep_rec.COUNT +1;
            l_rep_rec(rep_count  ).p_TYPE := -1;
            l_rep_rec(rep_count  ).BENEFIT_ACTION_ID :=l_benefit_action_id ;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_ID := stmt_record_rec1 (l_loop_cnt).statement_rec1.bg_id;
            l_rep_rec(rep_count  ).STMT_ID := stmt_record_rec1 (l_loop_cnt).statement_rec1.stmt_id;
            l_rep_rec(rep_count  ).BUSINESS_GROUP_NAME := p_bg_name;
            l_rep_rec(rep_count  ).STMT_NAME := p_stmt_name;
            l_rep_rec(rep_count  ).TOTAL_PERSONS := l_person_temp;
            l_rep_rec(rep_count  ).PERIOD_ID := stmt_record_rec1 (l_loop_cnt).statement_rec1.period_id ;
            l_loop_cnt := l_loop_cnt + 1;
            CLOSE c_check_stmt_avail;
          END LOOP;
        END IF;
      END IF;


      WRITE ('Total no of person selected - ' || l_num_persons);
      g_actn := 'Inserting the last range of persons IF exists...';
      WRITE (g_actn);
      WRITE (   'Time after processing the person selections '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));

      IF l_num_rows <> 0 THEN
        l_num_ranges := l_num_ranges + 1;
        hr_utility.set_location('l_num_ranges '||l_num_ranges,500);
        insert_person_actions
	                                        (p_per_actn_id_array      => l_person_action_ids,
	                                         p_per_id                 => l_person_ids,
	                                         p_benefit_action_id      => l_benefit_action_id,
	                                         p_stmt_id                =>l_stmt_ids,
	                                         p_perd_id                =>l_perd_ids,
	                                         p_bg_id                 =>l_bg_ids
                                 );
        l_num_rows := 0;
        l_person_action_ids.DELETE;
        l_person_ids.DELETE;
        l_stmt_ids.DELETE;
        l_perd_ids.DELETE;
        l_bg_ids.DELETE;
      END IF;
      COMMIT;

      g_actn := 'Submitting job to con-current manager...';
      WRITE (g_actn);
      g_actn := 'Preparing for launching concurrent requests';
      WRITE (g_actn);

      ben_batch_utils.g_num_processes := 0;
      ben_batch_utils.g_processes_tbl.DELETE;
      WRITE (   'Time before launching the threads '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam'));

      IF l_num_ranges > 1
      THEN
         hr_utility.set_location('L threads '||l_threads, 29);
         WRITE('l_threads'||l_threads );
         WRITE('l_num_ranges'||l_num_ranges );
         FOR loop_count IN 1 .. LEAST (l_threads, l_num_ranges) - 1
         LOOP

            WRITE
                ('=====================Request Parameters===================');
            WRITE
                ('||Parameter               value                           ');
            WRITE ('||argument2-              ' || l_benefit_action_id);
            WRITE ('||argument3-              ' || loop_count);
            WRITE
                ('==========================================================');
            l_request_id :=
               fnd_request.submit_request (application      => 'BEN',
                                           program          => 'BENTCSMT',
                                           description      => NULL,
                                           sub_request      => FALSE,
                                           argument1        => p_validate,
                                           argument2        => l_benefit_action_id,
                                           argument3        => loop_count,
                                           argument4        => to_char(sysdate,'yyyy/mm/dd'),
                                           argument5        => p_audit_log,
                                           argument6        => p_run_type,
                                           argument7        => l_period_start_date ,
                                           argument8        => l_period_end_date
                                          );
            ben_batch_utils.g_num_processes :=
                                           ben_batch_utils.g_num_processes + 1;
            ben_batch_utils.g_processes_tbl (ben_batch_utils.g_num_processes) :=
                                                                  l_request_id;
            hr_utility.set_location ('request id for this thread ' || l_request_id,160);
            COMMIT;
         END LOOP;
      ELSIF l_num_ranges = 0
      THEN
         WRITE ('<< No Person to process>>');
         RAISE l_silent_error;
      END IF;

      WRITE (   'Time after launching the threads '
               || TO_CHAR (SYSDATE, 'yyyy/mm/dd:hh:mi:ssam')
              );
      WRITE ('=====================do_multithread in Process============');
      WRITE ('||Parameter               value                           ');
      WRITE ('||p_benefit_action_id-    ' || l_benefit_action_id);
      WRITE ('||p_thread_id-            ' || (l_threads + 1));
      WRITE ('==========================================================');
      hr_utility.set_location('L threads before calling do_mutithread'||l_threads, 29);

      do_multithread (errbuf                   => errbuf,
                      retcode                  => retcode,
                      p_validate               => p_validate,
                      p_benefit_action_id      => l_benefit_action_id,
                      p_thread_id              => l_threads + 1,
                      p_effective_date         => to_char(sysdate,'yyyy/mm/dd'),
                      p_audit_log              => p_audit_log,
                      p_run_type               => p_run_type,
                      p_start_date             => l_period_start_date,
                      p_end_date                => l_period_end_date
                     );

      g_actn := 'Calling ben_batch_utils.check_all_slaves_finished...';
      WRITE (g_actn);
      ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);

      WRITE ('=====================End Process==========');
      WRITE ('||Parameter               value                           ');
      WRITE ('||p_benefit_action_id-    ' || l_benefit_action_id);
      WRITE ('||p_person_selected-      ' || l_num_persons);
      WRITE ('==========================================================');
      WRITE ('=====================Summary==========');
      WRITE ('||Parameter               value                           ');
      WRITE ('||Number of business groups processed -    ' || g_exec_param_rec.Number_Of_BGs );
      WRITE ('||Number of persons processed       -      ' || l_num_persons);
      WRITE ('==========================================================');

      g_actn := 'Calling delete hrchy ...';
      hr_utility.set_location (g_actn,161);
      delete_hrchy;
      g_actn := 'Calling Hierarchy Set...';
      hr_utility.set_location (g_actn,162);
      hrchy_set(l_benefit_action_id);
      g_actn := 'Calling end_process...';
      hr_utility.set_location (g_actn,163);
      end_process (p_benefit_action_id     => l_benefit_action_id
               , p_person_selected         => l_num_persons
               , p_business_group_id       => l_business_group_id
                );
      g_actn := 'Finished Process Procedure...';
      hr_utility.set_location (g_actn,164);

      IF (p_run_type ='GEN') THEN
    	IF (g_validate = 'N') THEN
		IF (l_business_group_id IS NOT NULL OR p_person_id IS NOT NULL ) THEN
			IF (stmt_rec.stmt_id IS NOT NULL AND stmt_rec.period_id IS NOT NULL) THEN
         			IF (  fnd_request.submit_request ( application => 'BEN',
				                                    program     => 'BENTCSTP',
				                                    description => NULL,
				                                    start_time  => SYSDATE,
				                                    sub_request => FALSE,
				                                    argument1   => p_stmt_id,
				                                    argument2   => p_period_id,
				                                    argument3   => p_stmt_name,
								    argument4   => p_person_id) = 0)
				 	THEN
				          WRITE(' Printable page Process Errored ');
 				 END IF ;
              END IF;
      		 ELSE
      		    temp_count := 1;
      		    WHILE (temp_count <= l_count)
        	    LOOP
        	      	IF (stmt_record_rec (temp_count).statement_rec.valid_flag = 'Y') THEN
        	    	 IF (  fnd_request.submit_request ( application => 'BEN',
								      program     => 'BENTCSTP',
								      description => NULL,
								      start_time  => SYSDATE,
								      sub_request => FALSE,
								      argument1   => stmt_record_rec (temp_count).statement_rec.stmt_id ,
								      argument2   => stmt_record_rec (temp_count).statement_rec.period_id,
								      argument3   => p_stmt_name) = 0)
			        THEN
			        	WRITE(' Printable page Process Errored ');
                    END IF ;
                   END IF;
        	    	temp_count := temp_count+1;
        	    END LOOP;
		END IF;
	END IF;
END IF;
-- hr_utility.trace_off;
EXCEPTION
      --
      WHEN l_silent_error
      THEN
            ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
            delete_hrchy;
            end_process (p_benefit_action_id     => l_benefit_action_id
               , p_person_selected         => l_num_persons
               , p_business_group_id       => l_business_group_id
                );
                print_cache;
      WHEN OTHERS
      THEN
         WRITE (fnd_message.get);
         WRITE (SQLERRM);
         WRITE ('Error Occurred');

            ben_batch_utils.check_all_slaves_finished (p_rpt_flag => TRUE);
            end_process (p_benefit_action_id     => l_benefit_action_id
               , p_person_selected         => l_num_persons
               , p_business_group_id       => l_business_group_id
                );

         fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token ('PROCEDURE', g_proc);
         fnd_message.set_token ('STEP', g_actn);
         fnd_message.raise_error;
   END;




end BEN_TCS_STMT_PROCESS;

/
