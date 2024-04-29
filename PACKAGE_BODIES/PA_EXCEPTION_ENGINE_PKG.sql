--------------------------------------------------------
--  DDL for Package Body PA_EXCEPTION_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXCEPTION_ENGINE_PKG" AS
/* $Header: PAPEXENB.pls 120.5.12010000.3 2009/07/02 08:45:06 rthumma ship $ */

   P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

-- Procedure    PAPFEXCP
-- Purpose      This procedure will be called from Concurrent Program to call
--               logic to generate exception transaction, KPA Scoring or
--               Notification based on the input parameters.

PROCEDURE PAPFEXCP      (    x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_retcode               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             p_project_ou            IN      NUMBER   DEFAULT NULL,
                             p_project_org           IN      NUMBER   DEFAULT NULL,
                             p_project_type          IN      VARCHAR2 DEFAULT NULL,
                             p_project_manager       IN      NUMBER   DEFAULT NULL,
                             p_project_from          IN      NUMBER   DEFAULT NULL,
                             p_project_to            IN      NUMBER   DEFAULT NULL,
                             p_generate_exceptions   IN      VARCHAR2 DEFAULT 'N',
                             p_generate_scoring      IN      VARCHAR2 DEFAULT 'N',
                             p_generate_notification IN      VARCHAR2 DEFAULT 'N',
                             p_purge                 IN      VARCHAR2 DEFAULT 'N',
                             p_daysold               IN      NUMBER   DEFAULT NULL,
                             p_bz_event_code         IN      VARCHAR2 DEFAULT 'N',
                             p_perf_txn_set_id       IN      VARCHAR2 DEFAULT 'N') IS

   l_project_list        PA_PLSQL_DATATYPES.IdTabTyp;
   l_bz_event_code       pa_perf_bz_measures.bz_event_code%TYPE;
   l_perf_txn_set_id     pa_perf_transactions.perf_txn_id%TYPE;
   l_proj                NUMBER;
   l_no_params_err_msg   VARCHAR2(2000);

   /* This cursor is for perf_txn_set_id is not null
       Get the project_id from interface table based on business event and request_id */
   CURSOR get_project_id(l_perf_txn_set_id IN VARCHAR2, l_proj_from  IN NUMBER,
                         l_proj_to IN NUMBER, l_proj IN NUMBER) IS
          SELECT DISTINCT object_id
            FROM pa_perf_bz_object ppbo, pa_projects_all ppa
           WHERE ppbo.object_type = 'PA_PROJECTS'
             AND ppbo.perf_txn_set_id = l_perf_txn_set_id
             AND ppa.segment1 between nvl((select segment1 from pa_projects_all where project_id = l_proj_from),' ') and
	          nvl((select segment1 from pa_projects_all where project_id = l_proj_to),ppa.segment1)
             AND ppa.project_id = ppbo.object_id
           ORDER BY object_id;

   /* This cursor is for p_project_manager not null */
   CURSOR get_project_id_p (l_project_manager IN NUMBER,
                            l_project_ou IN NUMBER,
                            l_project_org IN NUMBER,
                            l_proj_type VARCHAR2,
                            l_proj_from IN NUMBER,
                            l_proj_to IN NUMBER,
                            l_proj IN NUMBER) IS
          SELECT DISTINCT ppa.project_id
            FROM pa_projects_all ppa,
                 pa_project_parties ppp,
                 pa_project_types_all ppt,
		 pa_project_statuses pps  -- Added for Bug 4338924
           WHERE ppa.project_id = ppp.project_id
             AND ppp.object_type = 'PA_PROJECTS'
	     AND ppa.project_status_code = pps.project_status_code  -- Added for Bug 4338924
	     AND pps.status_type = 'PROJECT'  -- Added for Bug 4338924
	     AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED')  -- Added for Bug 4338924
             AND ppa.segment1 BETWEEN NVL((select segment1 from pa_projects_all where project_id = l_proj_from),' ') AND
	         NVL((select segment1 from pa_projects_all where project_id = l_proj_to), ppa.segment1)
             AND ppa.project_id = ppp.project_id
             AND ppp.resource_source_id = nvl(l_project_manager,ppp.resource_source_id)
             AND ppa.carrying_out_organization_id = nvl(l_project_org, ppa.carrying_out_organization_id) -- Corrected passing parameters for Bug 8652142
             AND ppa.org_id = nvl(l_project_ou, ppa.org_id) -- Corrected passing parameters for Bug 8652142
	     AND ppa.project_type = nvl(l_proj_type, ppt.project_type)
	     AND ppt.org_id = ppa.org_id
	     AND ppp.project_role_id = 1  -- Added for Bug 4338924
	     AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ppp.start_date_active, SYSDATE)) AND TRUNC(NVL(ppp.end_date_active, SYSDATE))  -- Added for Bug 4338924
           ORDER BY ppa.project_id;

   /* This cursor is for p_project_manager null */
   CURSOR get_project_id_pp (l_project_ou IN NUMBER,
                             l_project_org   IN NUMBER,
                             l_proj_type  IN VARCHAR2,
                             l_proj_from  IN NUMBER,
                             l_proj_to    IN NUMBER,
                             l_proj       IN NUMBER) IS
          SELECT distinct ppa.project_id
            FROM pa_projects_all ppa,
                 pa_project_types_all ppt,
		 pa_project_statuses pps  -- Added for Bug 4338924
           WHERE ppa.carrying_out_organization_id = nvl(l_project_org, ppa.carrying_out_organization_id) -- Corrected passing parameters for Bug 8652142
             AND ppa.org_id = nvl(l_project_ou, ppa.org_id) -- Corrected passing parameters for Bug 8652142
	     AND ppa.project_status_code = pps.project_status_code  -- Added for Bug 4338924
	     AND pps.status_type = 'PROJECT'  -- Added for Bug 4338924
	     AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED')  -- Added for Bug 4338924
             AND ppa.segment1 between nvl((select segment1 from pa_projects_all where project_id = l_proj_from),' ') and
	          nvl((select segment1 from pa_projects_all where project_id = l_proj_to), ppa.segment1)
	    AND ppa.project_type = nvl(l_proj_type, ppt.project_type)
	    and ppt.org_id = ppa.org_id
           ORDER BY ppa.project_id;

   l_errbuf	VARCHAR2(500);
   l_retcode	VARCHAR2(100);

BEGIN

   x_retcode := '1';
   x_errbuf := null;

   pa_debug.init_err_stack('PAPFEXCP');
   pa_debug.set_process('PLSQL','LOG','Y');
   pa_debug.G_err_stage := 'Entering PAPFEXCP ()';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.g_err_stage := '   Current system time is '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS');
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;

   /* Write the Parameters passed in */
   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Parameters passed ');
     PA_DEBUG.write_file('LOG', 'Project OU        => '||p_project_ou);
     PA_DEBUG.write_file('LOG', 'Project Org       => '||p_project_org);
     PA_DEBUG.write_file('LOG', 'Project Type      => '||p_project_type);
     PA_DEBUG.write_file('LOG', 'Project Manager   => '||p_project_manager);
     PA_DEBUG.write_file('LOG', 'Project From      => '||p_project_from);
     PA_DEBUG.write_file('LOG', 'Project To        => '||p_project_to);
     PA_DEBUG.write_file('LOG', 'Exception Flag    => '||p_generate_exceptions);
     PA_DEBUG.write_file('LOG', 'KPA Scoring Flag  => '||p_generate_scoring);
     PA_DEBUG.write_file('LOG', 'Notification Flag => '||p_generate_notification);
     PA_DEBUG.write_file('LOG', 'Purge Flag        => '||p_purge);
   END IF;

   /* Check the parameters.  If none of the parameters are passed in then do not
       proceed on processing else continue */
   IF ( p_project_ou is NULL AND
        p_project_org is NULL AND
        p_project_type is NULL AND
        p_project_manager is NULL AND
        p_project_from is NULL AND
        p_project_to is NULL ) THEN

      IF P_PA_DEBUG_MODE = 'Y' THEN -- Added for Bug 4324724
        PA_DEBUG.write_file('LOG', 'No parameters passed in () Exception Engine will not continue');
      END IF;

	RAISE FND_API.G_EXC_ERROR; -- For Bug 4324724

   ELSE
   /*** Begin business logic to get the list of Projects ***/

   IF p_perf_txn_set_id <> 'N' THEN
      OPEN get_project_id (p_perf_txn_set_id,p_project_from, p_project_to, l_proj);
      FETCH get_project_id bulk collect INTO l_project_list;
      CLOSE get_project_id;

      SELECT bz_ent_code
        INTO l_bz_event_code
        FROM pa_perf_bz_object
       WHERE perf_txn_set_id = p_perf_txn_set_id
         and rownum = 1;

   ELSE
      IF p_project_manager is NOT NULL THEN

      OPEN get_project_id_p (p_project_manager, p_project_ou,p_project_org, p_project_type,
                             p_project_from, p_project_to, l_proj);
      FETCH get_project_id_p bulk collect INTO l_project_list;
      CLOSE get_project_id_p;

      ELSE

        OPEN get_project_id_pp (p_project_ou, p_project_org, p_project_type,p_project_from, p_project_to, l_proj);
        FETCH get_project_id_pp bulk collect INTO l_project_list;
        CLOSE get_project_id_pp;
      END IF;

      l_bz_event_code := 'N';

   END IF;

   -- Do not proceed if there are no projects selected
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', 'Project count selected : '||l_project_list.COUNT);
   END IF;

   IF l_project_list.COUNT <> 0 THEN
   /*** End business logic to get the list of Projects ***/
       IF ( NVL(p_generate_exceptions,'N') = 'Y' )  THEN

       -- CALL EXCEPTION GENERATION LOGIC --
          PA_EXCEPTION_ENGINE_PKG.generate_exception(
                         p_project_list                   => l_project_list,
                         p_business_event_code            => l_bz_event_code,
			 x_errbuf			  => l_errbuf,
			 x_retcode			  => l_retcode
                        );
          IF l_retcode = '0' THEN
             IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'After calling Generate Exceptions API . . returns error: '||l_errbuf;
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                RETURN;
             END IF;
          END IF;
       END IF;

       IF (NVL(p_generate_scoring,'N') = 'Y' ) THEN

       -- CALL KPA SCORING LOGIC --
          PA_EXCEPTION_ENGINE_PKG.get_kpa_score(
                         p_project_list                   => l_project_list,
                         x_errbuf                         => l_errbuf,
                         x_retcode                        => l_retcode
                        );

          IF l_retcode = '0' THEN
             IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'After calling Generate KPA Scoring API . . returns error: '||l_errbuf;
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                RETURN;
             END IF;
          END IF;
       END IF;

       IF ( NVL(p_generate_notification,'N') = 'Y' ) THEN

       -- CALL GENERATE NOTIFICATION LOGIC --
          PA_EXCEPTION_ENGINE_PKG.generate_notification(
                         p_project_list                   => l_project_list,
                         x_errbuf                         => l_errbuf,
                         x_retcode                        => l_retcode
                        );

          IF l_retcode = '0' THEN
             IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'After calling Generate Notification Logic API . . returns error: '||l_errbuf;
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             END IF;
          END IF;

       END IF;

       IF ( NVL(p_purge,'N') = 'Y' ) THEN
         IF p_daysold is NULL THEN
            pa_debug.write_file('LOG', 'Days Old not passed in () Purge Logic API will not continue');
         ELSE

       -- CALL PURGE TRANSACTION LOGIC --
          PA_EXCEPTION_ENGINE_PKG.purge_transaction(
		    	p_project_list                   => l_project_list,
		    	p_days_old                       => p_daysold,
                        x_errbuf                         => l_errbuf,
                        x_retcode                        => l_retcode
                        );

          IF l_retcode = '0' THEN
             IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'After calling Purge Transaction Logic API . . returns error: '||l_errbuf;
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
             END IF;
          END IF;
         END IF;
       END IF;
   ELSE
       pa_debug.write_file('LOG', 'No valid project to be processed.');
   END IF; --end if for Project count 0

   END IF; --end if for No parameters passed in

   x_retcode := '0';

   pa_debug.G_err_stage := 'Leaving PAPFEXCP () with success';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.reset_err_stack;


EXCEPTION

   WHEN NO_DATA_FOUND THEN

    pa_debug.write_file('LOG', 'PAPFEXCP () exception: No data found');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

   WHEN FND_API.G_EXC_ERROR THEN -- Added for Bug 4324724

     FND_MESSAGE.SET_NAME ('PA', 'PA_EXCP_NO_PARAMS_PASSED'); -- Set the translatable message name.
     l_no_params_err_msg := FND_MESSAGE.GET; -- Get the error message.
     x_errbuf := x_errbuf || 'errbuf: ' || l_no_params_err_msg; -- Set it in errbuf.
     PA_DEBUG.write_file('LOG', l_no_params_err_msg); -- Write the error message to the log file.
     RAISE; -- Pass on the exception to the calling API.

   WHEN OTHERS THEN

    x_errbuf := x_errbuf||'errbuf: '||sqlerrm;
    pa_debug.write_file('LOG', 'PAPFEXCP () exception: Others');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

END PAPFEXCP;

-- Procedure	generate_exception
-- Purpose      This procedure will be called by concurrent program.
--               Once running, it will generate the performance transactions

PROCEDURE generate_exception(p_project_list	   IN	PA_PLSQL_DATATYPES.IdTabTyp,
		             p_business_event_code IN	VARCHAR2,
	  	             x_errbuf		   OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_retcode             OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   l_measure_id       pa_perf_rules.measure_id%TYPE;
   l_rule_id          pa_perf_object_rules.rule_id%TYPE;
   l_object_type      pa_perf_object_rules.object_type%TYPE;
   l_period_type      pa_perf_rules.period_type%TYPE;
   l_currency_type    pa_perf_rules.currency_type%TYPE;
   l_period_name      pa_perf_transactions.period_name%TYPE;

   l_object_list      PA_PLSQL_DATATYPES.IdTabTyp;
   l_rule_list        PA_PLSQL_DATATYPES.IdTabTyp;
   l_measure_list     PA_PLSQL_DATATYPES.IdTabTyp;
   l_bz_code_list     PA_PLSQL_DATATYPES.Char30TabTyp;
   l_program_name     VARCHAR2(100);

   l_object_rule_id   pa_perf_object_rules.object_rule_id%TYPE;
   l_kpa_code         pa_perf_rules.kpa_code%TYPE;
   l_precision        pa_perf_rules.precision%TYPE;
   l_measure_format   pa_perf_rules.measure_format%TYPE;
   l_rule_type        pa_perf_rules.rule_type%TYPE;
   l_thres_from       pa_perf_thresholds.from_value%TYPE;
   l_thres_to         pa_perf_thresholds.to_value%TYPE;
   l_threshold_id     pa_perf_thresholds.threshold_id%TYPE;
   l_indicator_code   pa_perf_thresholds.indicator_code%TYPE;
   l_weighting        pa_perf_thresholds.weighting%TYPE;
   l_exception_flag   pa_perf_thresholds.exception_flag%TYPE;

   l_measure_value    NUMBER;



   l_bz_ent_code      pa_perf_bz_measures.bz_event_code%TYPE;
   l_count            NUMBER;

   l_cursor         INTEGER;
   l_rows           INTEGER;
   l_stmt           VARCHAR2(2000);

   l_return_status  VARCHAR2(30) := 'S';
   l_msg_count      NUMBER       := NULL;
   l_msg_data       VARCHAR2(4000) := 'SUCCESS';

   l_errbuf         VARCHAR2(500);
   l_retcode        VARCHAR2(100);

   /* Get all the project_id with rule_id and store it in PLSQL table */
   CURSOR get_proj_rule_id (l_proj_id IN NUMBER) IS
          SELECT distinct(ppor.object_id)
            FROM pa_perf_object_rules ppor, pa_perf_rules ppr, pa_lookups pl  -- Bug 4275320: Added pa_lookups
           WHERE ppor.object_id = l_proj_id
             AND ppor.rule_id is not null
	       AND ppor.object_type = 'PA_PROJECTS'
	       AND ppor.rule_id = ppr.rule_id
	       AND ppr.rule_type = 'PERF_RULE'
	       AND pl.lookup_code (+) = ppr.kpa_code  -- For Bug 4275320
 	       AND pl.lookup_type (+) = 'PA_PERF_KEY_AREAS'  --Bug 4958325. Added look up type outer join, See the Bug for more details.
	       AND trunc(sysdate) between trunc(nvl(pl.start_date_active,sysdate)) and trunc(nvl(pl.end_date_active,sysdate));  -- For Bug 4275320

   /* Get all the rule_id associated with the project_id */
   CURSOR get_rule_id (l_proj_id IN NUMBER) IS
          SELECT ppor.rule_id
            FROM pa_perf_object_rules ppor, pa_perf_rules ppr, pa_lookups pl  -- Bug 4275320: Added pa_lookups
           WHERE ppor.object_id = l_proj_id
	    AND ppor.object_type = 'PA_PROJECTS'
	    AND ppor.rule_id = ppr.rule_id
	    AND ppr.rule_type = 'PERF_RULE'
	    AND pl.lookup_code (+) = ppr.kpa_code  -- For Bug 4275320
            AND pl.lookup_type (+) = 'PA_PERF_KEY_AREAS'   --Bug 4958325. Added look up type outer join, See the Bug for more details.
	    AND trunc(sysdate) between trunc(nvl(pl.start_date_active,sysdate)) and trunc(nvl(pl.end_date_active,sysdate));  -- For Bug 4275320

   /* Get the measure_id for a given project_id and rule_id */
   CURSOR get_measures (l_proj_id IN NUMBER, l_rule_id IN NUMBER) IS
          SELECT ppr.measure_id, ppr.period_type,
                 ppr.currency_type, ppor.object_type
            FROM pa_perf_object_rules ppor,
                 pa_perf_rules  ppr
           WHERE ppor.object_type = 'PA_PROJECTS'
             AND ppor.object_id = l_proj_id
             AND ppor.rule_id = l_rule_id
	    AND ppr.rule_id = ppor.rule_id
	    AND ppr.rule_type = 'PERF_RULE';

   /* Get the rule id from global temporary table for a given object_id */
   CURSOR get_rule_id_tmp (l_proj_id IN NUMBER,
                           l_measure_id IN NUMBER) IS
          SELECT rule_id
            FROM pa_perf_temp_obj_measure
           WHERE object_id = l_proj_id
             AND object_type = 'PA_PROJECTS'
             AND measure_id = l_measure_id;

   /* Get the measure id from global temporary table for a given object_id */
   CURSOR get_measure_id (l_object_id IN NUMBER) IS
          SELECT DISTINCT measure_id
            FROM pa_perf_temp_obj_measure
           WHERE object_type = 'PA_PROJECTS'
             AND object_id = l_object_id;

   /* Get the object id from global temporary table */
   CURSOR get_object_id IS
          SELECT DISTINCT object_id
            FROM pa_perf_temp_obj_measure
           WHERE object_type = 'PA_PROJECTS'
            ;

   /* Get the list of Business Event code from temporary table */
   CURSOR bz_ent_code IS
          SELECT distinct bz_ent_code
            FROM pa_perf_temp_obj_measure
           WHERE object_type = 'PA_PROJECTS'
             AND bz_ent_code is not null;

BEGIN
   x_retcode := '0';

   pa_debug.G_err_stage := 'Entering GENERATE_EXCEPTION ()';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.g_err_stage := '   Current system time is '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS');
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;

   -- Remove the data in temp table
   EXECUTE IMMEDIATE ('delete from  pa_perf_temp_obj_measure') ;


   /*** Begin business logic to generate the Performance Transaction ***/

   -- Step 1:  Populate the temp table and prepare to get the measure value
   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Number of Projects to be processed is : '||p_project_list.COUNT);
   END IF;
   FOR i IN p_project_list.FIRST .. p_project_list.LAST LOOP
      -- Step 1: Populate PA_PERF_TEMP_OBJ_MEASURE (temp table)
      -- get all the rules attached to the project

    OPEN get_rule_id (p_project_list(i));
    FETCH get_rule_id bulk collect INTO l_rule_list;
    CLOSE get_rule_id;

    IF l_rule_list.COUNT <> 0 THEN

      IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.write_file('LOG', 'Inserting into PA_PERF_TEMP_OBJ_MEASURE temp table for Project: '||p_project_list(i));
        PA_DEBUG.write_file('LOG', 'Number of Rule IDs : '||l_rule_list.COUNT);
      END IF;

      FOR j IN l_rule_list.FIRST .. l_rule_list.LAST LOOP

      -- Process only those projects with rule id

         OPEN get_measures (p_project_list(i), l_rule_list(j));
         FETCH get_measures INTO l_measure_id, l_period_type,
               l_currency_type, l_object_type;
         CLOSE get_measures;

         IF l_measure_id is NULL THEN
            PA_DEBUG.write_file('LOG', 'Rule ID '||l_rule_list(j)||' has no associated measure id');
         ELSE
	    ---  If bz_ent_code is not passed in, get one bz_ent_code
	    ---  from pa_perf_bz_measures for the given measure id
	    IF (p_business_event_code = 'N') THEN
               SELECT count(*) INTO l_count FROM dual where EXISTS
                    (SELECT bz_event_code
                       FROM pa_perf_bz_measures
                      WHERE measure_id = l_measure_id);
               IF l_count = 0 THEN
                  --NULL;
		  l_bz_ent_code := null;
               ELSE
                  SELECT bz_event_code
                    INTO l_bz_ent_code
                    FROM pa_perf_bz_measures
                   WHERE measure_id = l_measure_id
                     AND rownum = 1;
               END IF;

               INSERT INTO pa_perf_temp_obj_measure
		 ( object_type
                   ,object_id
                   ,measure_id
                   ,measure_value
                   ,rule_id
                   ,calendar_type
                   ,currency_type
                   ,period_name
                   ,bz_ent_code
		   )
	       VALUES
                  ('PA_PROJECTS'
                   ,p_project_list(i)
                   ,l_measure_id
                   ,null
                   ,l_rule_list(j)
                   ,l_period_type
                   ,l_currency_type
                   ,null
                   ,l_bz_ent_code
                  );
	     ELSE

               l_bz_ent_code := p_business_event_code;

               INSERT INTO pa_perf_temp_obj_measure
		 ( object_type
                   ,object_id
                   ,measure_id
                   ,measure_value
                   ,rule_id
                   ,calendar_type
                   ,currency_type
                   ,period_name
                   ,bz_ent_code
		   )
	       VALUES
		 ('PA_PROJECTS'
                  ,p_project_list(i)
		  ,l_measure_id
		  ,null
		  ,l_rule_list(j)
		  ,l_period_type
		  ,l_currency_type
		  ,null
		  ,l_bz_ent_code
                  );
            END IF;

            -- End of Step 1
         END IF; -- end if for l_measure id null
      END LOOP; -- end loop for l_rule_list
    ELSE
      --NULL;
      --Added for bug# 3918182
      IF P_PA_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.write_file('LOG', 'No performance rules are associated to the project ');
      END IF;
      -- Since there are no performance rules associated to the project there should not be
      -- any current transaction record for the project. So marking all the transaction for the
      -- project as History
      UPDATE pa_perf_transactions
      SET current_flag = 'N'
      WHERE perf_txn_obj_type = 'PA_PROJECTS'
      AND perf_txn_obj_id = p_project_list(i)
      AND current_flag = 'Y';

    END IF;  --end of l_rule_list.COUNT
   END LOOP; --end loop for l_project_list

   commit;  --Save the work after inserting all the projects into temp table

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'End of Step 1 .. Inserting into PA_PERF_TEMP_OBJ_MEASURE temp table');
   END IF;

       --- Step 2: Call Business Event API to get the value of measure_id
       ---         for a given project_id.  This API will do the update on the temp
       ---         table to set the measure value in bulk.

       --- get the API for a given business event--
       OPEN bz_ent_code;
       FETCH bz_ent_code bulk collect INTO l_bz_code_list;
       CLOSE bz_ent_code;

       IF l_bz_code_list.COUNT <> 0 THEN

         FOR i IN l_bz_code_list.FIRST .. l_bz_code_list.LAST LOOP
            SELECT attribute1
              INTO l_program_name
              FROM pa_lookups
              WHERE lookup_type = 'PA_PERF_BZ_EVENTS'
              AND lookup_code = l_bz_code_list(i)
              AND enabled_flag = 'Y';

            IF ( l_program_name IS NOT NULL ) THEN
            -- Construct the dynamic SQL that will call the API from PA_LOOKUPS
            --     for PA_PERF_BZ_EVENTS lookup_type --
            -- l_program_name is the name of the extension API.
            -- For instance 'SUMMARIZATION.EXCEPTION'

               IF P_PA_DEBUG_MODE = 'Y' THEN
                  PA_DEBUG.g_err_stage := 'Executing Dynamic SQL to call API that will set the measure value.';
                  PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
               END IF;

               BEGIN

                 l_return_status := 'S';

                 -- Get cursor handle
                 l_cursor  := dbms_sql.open_cursor;

                 -- Associate a sql statement with the cursor.

                 l_stmt := 'BEGIN '||l_program_name ||
                                '(p_commit_flag   => :Y,'||
                                ' x_msg_count     => :msg_count,'||
                                ' x_msg_data      => :msg_data,'||
                                ' x_return_status => :return_status);'||
                           ' END;';

                 -- parse the sql statemnt to check for any syntax or symantic errors

                 dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

                 -- before executing the sql statement bind the variables

                 dbms_sql.bind_variable(l_cursor,':Y',
                                                 'Y');
                 dbms_sql.bind_variable(l_cursor,':msg_count',
                                                 l_msg_count);
                 dbms_sql.bind_variable(l_cursor,':msg_data',
                                                 l_msg_data);
                 dbms_sql.bind_variable(l_cursor,':return_status',
                                                 l_return_status);
                 -- execute the statement
                 l_rows := dbms_sql.execute(l_cursor);

                 -- retrieve the values for the output variables
                 dbms_sql.variable_value(l_cursor, ':msg_count', l_msg_count);
                 dbms_sql.variable_value(l_cursor, ':msg_data', l_msg_data);
                 dbms_sql.variable_value(l_cursor, ':return_status', l_return_status);

               IF ( l_return_status <> 'S') THEN
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     PA_DEBUG.g_err_stage := 'After executing Dynamic SQL () with error';
                     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                  END IF;
               ELSE
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     PA_DEBUG.g_err_stage := 'After executing Dynamic SQL () with success';
                     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                  END IF;
                  dbms_sql.close_cursor(l_cursor);
               END IF;

               EXCEPTION
                    WHEN others THEN
                      dbms_sql.close_cursor(l_cursor);
                      pa_debug.write_file('LOG', 'Error executing Dynamic SQL () exception: Others '||sqlerrm);
               END;
	       IF P_PA_DEBUG_MODE = 'Y' THEN
                 PA_DEBUG.write_file('LOG', 'End of Step 2 . . Called Business Event API to get the measure value');
	       END IF;
            -- till here for dynamic SQL
            END IF;

         END LOOP; --end loop for l_bz_code_list
       ELSE
         IF P_PA_DEBUG_MODE = 'Y' THEN  -- Added for Bug 4324824
	   PA_DEBUG.write_file('LOG', 'No Business Event code selected from PA_PERF_TEMP_OBJ_MEASURE temp table.');
	 END IF;
       END IF;
       -- End of Step 2

   -- Step 3: Generate the Performance Transaction --

   OPEN get_object_id ;
   FETCH get_object_id bulk collect INTO l_object_list;
   CLOSE get_object_id;

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Number of Object IDs to be inserted into transaction table : '||l_object_list.COUNT);
   END IF;
   IF l_object_list.COUNT <> 0 THEN
   FOR i IN l_object_list.FIRST .. l_object_list.LAST LOOP

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Project ID    : '||l_object_list(i));
   END IF;
      OPEN get_measure_id (l_object_list(i));
      FETCH get_measure_id bulk collect INTO l_measure_list;
      CLOSE get_measure_id;
          /* Marking the transaction to be not current */
	      -- IF business event is not passed in, mark to be not current all
              --  the transaction for a given project
              IF p_business_event_code = 'N' THEN
                 UPDATE pa_perf_transactions
		   SET current_flag = 'N'
		  -- WHERE project_id = l_object_list(i) --Modified for Bug 3639490
                  WHERE perf_txn_obj_type = 'PA_PROJECTS'
                    AND perf_txn_obj_id = l_object_list(i)
                    AND current_flag = 'Y';

              -- ELSE if business event is passed in, mark to be not current only the transactions with
	      -- measure_id associated with the business event
	      ELSE
                 --Check if there are records to be updated
                 SELECT count(*) INTO l_count FROM dual where EXISTS
                  (SELECT project_id
                     FROM pa_perf_transactions
                    --WHERE project_id = l_object_list(i) --Modified for Bug3639490
                    WHERE perf_txn_obj_type = 'PA_PROJECTS'
                      AND perf_txn_obj_id = l_object_list(i)
                      AND measure_id in (SELECT measure_id
                                      FROM pa_perf_bz_measures
                                      WHERE bz_event_code = p_business_event_code)
                      AND current_flag = 'Y');
                 IF l_count = 0 THEN
                   null;
                 ELSE
                   UPDATE pa_perf_transactions
		   SET current_flag = 'N'
		   --WHERE project_id = l_object_list(i) --Modified for bug 3639490
                   WHERE perf_txn_obj_type = 'PA_PROJECTS'
                   AND perf_txn_obj_id = l_object_list(i)
		   AND measure_id in (SELECT measure_id
				      FROM pa_perf_bz_measures
				      WHERE bz_event_code = p_business_event_code)
                   AND current_flag = 'Y';
                 END IF;

              END IF;
        /* till here for marking the transaction to be not current */

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Number of Measure ID  : '||l_measure_list.COUNT);
   END IF;
      FOR j IN l_measure_list.FIRST .. l_measure_list.LAST LOOP
          -- Get all the rule_id associated with the given measure_id
          IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.write_file('LOG', 'Measure ID : '||l_measure_list(j));
	  END IF;
          OPEN get_rule_id_tmp (l_object_list(i), l_measure_list(j));
          FETCH get_rule_id_tmp bulk collect INTO l_rule_list;
          CLOSE get_rule_id_tmp;

          FOR k IN l_rule_list.FIRST .. l_rule_list.LAST LOOP

            IF P_PA_DEBUG_MODE = 'Y' THEN
	      PA_DEBUG.write_file('LOG', 'Rule ID       : '||l_rule_list(k));
	    END IF;
          -- Get the calendar_type associated with the rule_id and measure_id
             SELECT calendar_type
               INTO l_period_type
               FROM pa_perf_temp_obj_measure
              WHERE object_id = l_object_list(i)
                AND object_type = 'PA_PROJECTS'
                AND measure_id = l_measure_list(j)
                AND rule_id = l_rule_list(k);

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Period Type   : '||l_period_type);
   END IF;

          -- Get the measure_value, period_type, period_name and rule_id
          --    for a given project_id and measure_id

	    SELECT nvl(pptom.measure_value, null), nvl(pptom.period_name,null),
                   pptom.rule_id, pptom.object_type, ppor.object_rule_id,
                   ppr.kpa_code, ppr.precision, ppr.currency_type, ppr.measure_format,
                   ppr.rule_type
	      INTO l_measure_value, l_period_name,
                   l_rule_id, l_object_type, l_object_rule_id,
                   l_kpa_code, l_precision, l_currency_type, l_measure_format,
                   l_rule_type
	      FROM pa_perf_rules ppr,
                   pa_perf_object_rules ppor,
                   pa_perf_temp_obj_measure pptom
             WHERE pptom.object_id = l_object_list(i)
               AND pptom.object_id = ppor.object_id
               AND ppor.object_type = 'PA_PROJECTS'
	       AND pptom.measure_id = l_measure_list(j)
               AND pptom.object_type = 'PA_PROJECTS'
               AND ppor.rule_id = l_rule_list(k)
               AND ppor.rule_id = ppr.rule_id
               AND ppor.rule_id = pptom.rule_id
               AND rownum = 1;

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'After selecting values from PA_PERF_TEMP_OBJ_MEASURE temp table' );
   END IF;

	  -- If measure value is null for a given measure_id and there is associated API
	  --     then call the API to get the measure value
	    IF l_measure_value is NOT NULL THEN
	       NULL;
	    ELSE
	       SELECT pl_sql_api
		 INTO l_program_name
		 FROM pji_mt_measures_v
		 WHERE measure_id = l_measure_list(j)
                 AND rownum = 1 ;

               IF ( l_program_name IS NOT NULL ) THEN
                 -- Construct the dynamic SQL that will call the API from PJI_MT_MEASURES_V
                    -- l_program_name is the name of the extension API.
                    -- For instance 'SUMMARIZATION.EXCEPTION'
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                     PA_DEBUG.g_err_stage := 'Executing Dynamic SQL to call Measure Value API '||l_program_name;
                     PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                  END IF;
                    BEGIN

                       l_return_status := 'S';

                       -- Get cursor handle
                       l_cursor  := dbms_sql.open_cursor;

                       -- Associate a sql statement with the cursor.

                       l_stmt := 'BEGIN '||l_program_name ||
                                  '( p_object_type  => :object_type,'||
                                  ' p_object_id     => :object_list,'||
                                  ' p_measure_id    => :measure_list,'||
                                  ' p_period_type   => :period_type,'||
                                  ' x_measure_value => :measure_value,'||
                                  ' x_period_name   => :period_name,'||
                                  ' x_return_status => :return_status,'||
                                  ' x_msg_count     => :msg_count,'||
                                  ' x_msg_data      => :msg_data);'||
                                 ' END;';

                       -- parse the sql statemnt to check for any syntax or symantic errors

                       dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

                       -- before executing the sql statement bind the variables

                       dbms_sql.bind_variable(l_cursor,':object_type',
                                                       'PA_PROJECTS');
                       dbms_sql.bind_variable(l_cursor,':object_list',
                                                       l_object_list(i));
                       dbms_sql.bind_variable(l_cursor,':measure_list',
                                                       l_measure_list(j));
                       dbms_sql.bind_variable(l_cursor,':period_type',
                                                       l_period_type);
                       dbms_sql.bind_variable(l_cursor,':measure_value',
                                                       l_measure_value);
                       dbms_sql.bind_variable(l_cursor,':period_name',
                                                       l_period_name);
                       dbms_sql.bind_variable(l_cursor,':return_status',
                                                       l_return_status);
                       dbms_sql.bind_variable(l_cursor,':msg_count',
                                                       l_msg_count);
                       dbms_sql.bind_variable(l_cursor,':msg_data',
                                                       l_msg_data);

                       -- execute the statement
                       l_rows := dbms_sql.execute(l_cursor);

                       -- retrieve the values for the output variables
                       dbms_sql.variable_value(l_cursor, ':measure_value', l_measure_value);
                       dbms_sql.variable_value(l_cursor, ':period_name', l_period_name);
                       dbms_sql.variable_value(l_cursor, ':return_status', l_return_status);
                       dbms_sql.variable_value(l_cursor, ':msg_count', l_msg_count);
                       dbms_sql.variable_value(l_cursor, ':msg_data', l_msg_data);

                       -- Check if the call to Get Measure Value API is successful
                       IF ( l_return_status <> 'S' ) THEN
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             PA_DEBUG.g_err_stage := 'After executing Dynamic SQL () with error';
                             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                          END IF;
                       ELSE
                          IF P_PA_DEBUG_MODE = 'Y' THEN
                             PA_DEBUG.g_err_stage := 'After executing Dynamic SQL () with success';
                             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                          END IF;

                          IF P_PA_DEBUG_MODE = 'Y' THEN
			    pa_debug.write_file('LOG','Period Name   : '||l_period_name);
			  END IF;

                          IF l_measure_value is NOT NULL THEN
                          -- Update the measure value on pa_perf_temp_obj_measure table
                             UPDATE pa_perf_temp_obj_measure
                                SET measure_value = l_measure_value,
                                      period_name = l_period_name
                              WHERE object_id = l_object_list(i)
                                AND measure_id = l_measure_list(j)
                                AND rule_id = l_rule_list(k)
                                AND object_type = 'PA_PROJECTS';
                            IF P_PA_DEBUG_MODE = 'Y' THEN
			      pa_debug.write_file('LOG','Updating PA_PERF_TEMP_OBJ_MEASURE () with success');
			    END IF;
                          END IF;
                          dbms_sql.close_cursor(l_cursor);
                       END IF;

                    EXCEPTION
                       WHEN others THEN
                         dbms_sql.close_cursor(l_cursor);
                         pa_debug.write_file('LOG','Error executing Dynamic SQL () exception: Others '||sqlerrm);
                    END;
                 -- till here for dynamic SQL --
               ELSE
                   PA_DEBUG.write_file('LOG', 'No Measure Value API for measure id '||l_measure_list(j));
               END IF; --end if for program name is not null
	    END IF;    --end if for measure values is not null

	    SELECT measure_value
	      INTO l_measure_value
	      FROM pa_perf_temp_obj_measure
	     WHERE object_id = l_object_list(i)
	       AND measure_id = l_measure_list(j)
               AND object_type = 'PA_PROJECTS'
	      AND rule_id = l_rule_list(k)
	      AND ROWNUM = 1;

	   IF P_PA_DEBUG_MODE = 'Y' THEN
	     pa_debug.write_file('LOG','Get Threshold for Measure Value : '||l_measure_value);
	   END IF;
           -- Check whether the measure value is between the threshold from
           --   and threshold to. If l_retcode = 1 then there is a match . . hence
	   --   inserting the record into pa_perf_transactions table ELSE do nothing
	    PA_EXCEPTION_ENGINE_PKG.GET_THRESHOLD(
                                 l_rule_list(k)
                                ,l_rule_type
                                ,l_measure_value
                                ,l_threshold_id
                                ,l_indicator_code
                                ,l_exception_flag
                                ,l_weighting
                                ,l_thres_from
                                ,l_thres_to
                                ,l_errbuf
                                ,l_retcode);

            IF l_retcode = '0' THEN
	       pa_debug.write_file('LOG','No matching threshold');
            ELSE
              -- Insert new record into PA_PERF_TRANSACTIONS table
	       IF P_PA_DEBUG_MODE = 'Y' THEN
	         pa_debug.write_file('LOG','Inserting record into PA_PERF_TRANSACTIONS');
	       END IF;
	        INSERT INTO pa_perf_transactions
		       ( perf_txn_id
		        ,perf_txn_obj_type
		        ,perf_txn_obj_id
		        ,object_rule_id
                        ,related_obj_type
		        ,related_obj_id
		        ,rule_id
		        ,project_id
		        ,kpa_code
		        ,measure_id
		        ,measure_value
		        ,period_name
		        ,indicator_code
		        ,threshold_from
		        ,threshold_to
		        ,weighting
		        ,precision
		        ,period_type
		        ,currency_type
		        ,measure_format
		        ,program_id
		        ,date_checked
		        ,exception_flag
		        ,current_flag
                        ,included_in_scoring
		        ,record_version_number
		        ,creation_date
		        ,created_by
		        ,last_update_date
		        ,last_updated_by
		        ,last_update_login
		       )
		VALUES ( pa_perf_transactions_s1.nextval
	                ,'PA_PROJECTS'
		        ,l_object_list(i)
		        ,l_object_rule_id
			,null
			,null
			,l_rule_list(k)
			,l_object_list(i)
			,l_kpa_code
			,l_measure_list(j)
			,l_measure_value
			,l_period_name
			,l_indicator_code
			,l_thres_from
			,l_thres_to
			,l_weighting
			,l_precision
			,l_period_type
			,l_currency_type
			,l_measure_format
			,fnd_global.CONC_REQUEST_ID
			,sysdate
			,l_exception_flag
			,'Y'
			,'N'
			,1
			,sysdate
			,fnd_global.user_id
			,sysdate
			,fnd_global.user_id
			,fnd_global.login_id
		       );
            END IF; --end if of l_retcode = 0
          END LOOP; --end loop for l_rule_list from temp table
      END LOOP; --end loop for l_measure_list

      COMMIT; --Do the commit after each project

   END LOOP; --end loop for l_object_list
   END IF;  --end if for l_object_list.count is 0

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'End of Step 3 . . Inserting into PA_PERF_TRANSACTIONS table');
   END IF;
   -- End of Step 3 --

   -- Remove the data in temp table
   -- EXECUTE IMMEDIATE ('delete from pa_perf_temp_obj_measure') ;
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG','Deleting records from PA_PERF_TEMP_OBJ_MEASURE () with success');
   END IF;

   -- Clean the Interface Table PA_PER_BZ_OBJECT --

   IF p_business_event_code = 'N' THEN
      IF P_PA_DEBUG_MODE = 'Y' THEN  -- Added for Bug 4324824
        pa_debug.write_file('LOG','No records will be deleted from PA_PERF_BZ_OBJECT since Business Event code is not passed in.');
      END IF;
   ELSE
      DELETE from pa_perf_bz_object
       WHERE bz_ent_code = p_business_event_code;
      IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('LOG','Deleting records from PA_PERF_BZ_OBJECT () with success');
      END IF;
   END IF;


   x_retcode := '1';

   pa_debug.G_err_stage := 'Leaving GENERATE_EXCEPTION () with success';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.reset_err_stack;

   commit;


EXCEPTION

   WHEN NO_DATA_FOUND THEN

    pa_debug.write_file('LOG', 'GENERATE_EXCEPTION () exception: No data found');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

   WHEN OTHERS THEN

    x_errbuf := x_errbuf||'errbuf: '||sqlerrm;
    pa_debug.write_file('LOG', 'GENERATE_EXCEPTION () exception: Others '||x_errbuf);
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

END generate_exception;

-- Procedure	generate_notification
-- Purpose      This procedure will be called by concurrent program.
--               Once running, it will generate the workflow notification for each.

PROCEDURE generate_notification(
                   p_project_list          IN      PA_PLSQL_DATATYPES.IdTabTyp,
                   x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   x_retcode               OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   CURSOR get_page( c_object_id  NUMBER)
   IS
   SELECT object_page_layout_id
   FROM pa_progress_report_setup_v
   WHERE object_id = c_object_id
   AND object_type = 'PA_PROJECTS'
   AND page_type_code='PPR'
   AND generation_method='AUTOMATIC';

   l_project_list PA_PLSQL_DATATYPES.IdTabTyp;
   l_msg_count                NUMBER := 0;
   l_data                     VARCHAR2(2000);
   l_msg_data                 VARCHAR2(2000);
   l_msg_index_out            NUMBER;
   l_item_key                 VARCHAR2(2000);
   l_return_status            VARCHAR2(1);
   l_number                   NUMBER;


BEGIN

   x_retcode := '0';

   l_project_list := p_project_list;

   pa_debug.G_err_stage := 'Entering GENERATE_NOTIFICATION ()';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END If;
   pa_debug.g_err_stage := '   Current system time is '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS');
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;


   /*** Begin Notification logic ***/

   FOR i IN l_project_list.FIRST .. l_project_list.LAST LOOP
      -- Call workflow API to generate Workflow Notification for the given project.
      /* Check if any Page Layout is aatched to this project for Exception Reporting. If it is attached then
         Workflow will be started to send e-mail notification to all the member in the access list otherwise
	 error message is logged in the concurrent request log and continue with next project.*/
      OPEN get_page( l_project_list(i));
      FETCH get_page INTO l_number;
      IF get_page%FOUND THEN
        PA_PERF_NOTIFICATION_PKG.START_PERF_NOTIFICATION_WF(
              p_item_type => 'PAEXNOWF'
             ,p_process_name => 'PERFORMANCE_NOTIFICATION_PROCE'
             ,p_project_id   => l_project_list(i)
             ,x_item_key     => l_item_key
             ,x_return_status  => l_return_status
             ,x_msg_count  => l_msg_count
             ,x_msg_data  => l_msg_data);

        IF (l_return_status <>  'S') THEN
           pa_debug.g_err_stage:= 'Error calling START_PERF_NOTIFICATION_WF';
           IF P_PA_DEBUG_MODE = 'Y' THEN
	     pa_debug.write_file('LOG',pa_debug.g_err_stage);
             pa_debug.write_file('LOG','l_msg_data : '||l_msg_data);
	   END IF;

           PA_INTERFACE_UTILS_PUB.get_messages
           (p_encoded        => FND_API.G_TRUE
           ,p_msg_index      => 1
           ,p_msg_count      => l_msg_count
           ,p_msg_data       => l_msg_data
           ,p_data           => l_data
           ,p_msg_index_out  => l_msg_index_out);

           IF P_PA_DEBUG_MODE = 'Y' THEN
	     pa_debug.write_file('LOG','l_data : '||l_data);
	   END IF;

        END IF;
      ELSE
        pa_debug.write_file('LOG', ' There is no report type associated to the project( Project Id: '||l_project_list(i)||') to send the performance status notification ');
      END IF;
      CLOSE get_page;
   END LOOP;

   x_retcode := '1';

   pa_debug.G_err_stage := 'Leaving GENERATE_NOTIFICATION () with success';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.reset_err_stack;

   commit;


EXCEPTION

   WHEN NO_DATA_FOUND THEN

    pa_debug.write_file('LOG', 'GENERATE_NOTIFICATION () exception: No data found');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

   WHEN OTHERS THEN

    x_errbuf := x_errbuf||'errbuf: '||sqlerrm;
    pa_debug.write_file('LOG', 'GENERATE_NOTIFICATION () exception: Others');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

END generate_notification;

-- Procedure	purge_transaction
-- Purpose      This procedure will call logic to cleanup data in the
--               PA_PERF_TRANSACTIONS table.

PROCEDURE purge_transaction( p_project_list	   IN	   PA_PLSQL_DATATYPES.IdTabTyp,
			     p_days_old            IN      NUMBER,
			     x_errbuf              OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			     x_retcode             OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

BEGIN

   x_retcode := '0';


   pa_debug.init_err_stack('PURGE_TRANSACTION ');
   pa_debug.set_process('PLSQL','LOG','Y');
   pa_debug.G_err_stage := 'Entering PURGE_TRANSACTION ()';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.g_err_stage := '   Current system time is '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS');
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;

     FOR i IN p_project_list.FIRST .. p_project_list.LAST LOOP

      IF P_PA_DEBUG_MODE = 'Y' THEN
        pa_debug.write_file('LOG', 'Purging Project : ' || p_project_list(i));
      END IF;

      /*** clean up the comments transaction table based on project_id and purge_date ***/
      DELETE from pa_perf_comments
       WHERE perf_txn_id in (SELECT perf_txn_id
                               FROM pa_perf_transactions
                              WHERE perf_txn_obj_type = 'PA_PROJECTS'
                                AND perf_txn_obj_id = p_project_list(i)
                                AND trunc(creation_date) < trunc(sysdate - p_days_old)
                                AND current_flag = 'N');

      /*** clean up the the KPA Scoring Summary ***/
      DELETE from pa_perf_kpa_trans
       WHERE perf_txn_id in (SELECT perf_txn_id
                               FROM pa_perf_transactions
                              WHERE perf_txn_obj_type = 'PA_PROJECTS'
                                AND perf_txn_obj_id = p_project_list(i)
                                AND trunc(creation_date) < trunc(sysdate - p_days_old)
                                AND current_flag = 'N');

      DELETE from pa_perf_kpa_summary_det
       WHERE object_type = 'PA_PROJECTS'
         AND object_id = p_project_list(i)
         AND trunc(creation_date) < trunc(sysdate - p_days_old)
         AND kpa_summary_id in (SELECT kpa_summary_id
                                  FROM pa_perf_kpa_summary
                                 WHERE object_type = 'PA_PROJECTS'
                                   AND object_id = p_project_list(i)
                                   AND trunc(creation_date) < trunc(sysdate - p_days_old)
                                   AND current_flag = 'N');

      DELETE from pa_perf_kpa_summary
       WHERE object_type = 'PA_PROJECTS'
         AND object_id = p_project_list(i)
         AND trunc(creation_date) < trunc(sysdate - p_days_old)
         AND current_flag = 'N';

      /*** clean up the transaction table based on project_id and purge_date ***/
      DELETE from pa_perf_transactions
       WHERE perf_txn_obj_type = 'PA_PROJECTS'
         AND perf_txn_obj_id = p_project_list(i)
         AND trunc(creation_date) < trunc(sysdate - p_days_old)
         AND current_flag = 'N';

     END LOOP;

   x_retcode := '1';

   pa_debug.G_err_stage := 'Leaving PURGE_TRANSACTION () with success';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.reset_err_stack;

   commit;


EXCEPTION

   WHEN NO_DATA_FOUND THEN

    pa_debug.write_file('LOG', 'PURGE_TRANSACTION () exception: No data found');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

   WHEN OTHERS THEN

    x_errbuf := x_errbuf||'errbuf: '||sqlerrm;
    pa_debug.write_file('LOG', 'PURGE_TRANSACTION () exception: Others');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

END purge_transaction;

-- Procedure	get_threshold
-- Purpose      This procedure will return information from
--               PA_PERF_THRESHOLDS table.

PROCEDURE get_threshold (
                        p_rule_id		IN	NUMBER,
    			p_rule_type             IN      VARCHAR2,
    			p_cur_value		IN	NUMBER,
    			x_threshold_id          out     NOCOPY NUMBER, --File.Sql.39 bug 4440895
    			x_indicator_code	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    			x_exception_flag	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    			x_weighting		OUT 	NOCOPY NUMBER, --File.Sql.39 bug 4440895
    			x_from_value		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
    			x_to_value		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
    			x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    			x_retcode               OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   l_count number;

BEGIN

   x_retcode := '0';

   pa_debug.G_err_stage := 'Entering GET_THRESHOLD ()';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.g_err_stage := '   Current system time is '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS');
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;

   SELECT COUNT(*) INTO l_count FROM dual WHERE EXISTS
      (
    SELECT pt.threshold_Id, pt.indicator_code, pt.exception_flag,
           pt.weighting, pt.from_value, pt.to_value
      FROM pa_perf_thresholds pt, pa_perf_rules pr
     WHERE pr.rule_id = NVL(p_rule_id, -99)
       AND pr.rule_id = pt.thres_obj_id
       AND pt.rule_type = p_rule_type
       AND pr.rule_type = pt.rule_type
       AND NVL(round(p_cur_value, DECODE(pr.precision,0.1,1,0.01,2,0.001,3,0)),
               -99999999999) between pt.from_value and pt.to_value
      );
   IF l_count = 0 THEN
      x_retcode := 0;
      x_exception_flag := 'N';
   ELSE
    SELECT pt.threshold_Id, pt.indicator_code, pt.exception_flag,
           pt.weighting, pt.from_value, pt.to_value
      INTO x_threshold_id, x_indicator_code, x_exception_flag,
           x_weighting, x_from_value, x_to_value
      FROM pa_perf_thresholds pt, pa_perf_rules pr
     WHERE pr.rule_id = NVL(p_rule_id, -99)
       AND pr.rule_id = pt.thres_obj_id
       AND pt.rule_type = p_rule_type
       AND pr.rule_type = pt.rule_type
       AND NVL(round(p_cur_value, DECODE(pr.precision,0.1,1,0.01,2,0.001,3,0)),
               -99999999999) between pt.from_value and pt.to_value
       AND rownum = 1;
   END IF;

   x_retcode := '1';

   pa_debug.G_err_stage := 'Leaving GET_THRESHOLD () with success';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.reset_err_stack;



EXCEPTION

   WHEN NO_DATA_FOUND THEN

    pa_debug.write_file('LOG', 'GET_THRESHOLD () exception: No data found');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

   WHEN OTHERS THEN

    x_errbuf := x_errbuf||'errbuf: '||sqlerrm;
    pa_debug.write_file('LOG', 'GET_THRESHOLD () exception: Others');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

END get_threshold;

-- Procedure	get_kpa_score
-- Purpose      This procedure will be called by concurrent program.
--               Once running, it will generate the Project KPA Summary.
PROCEDURE get_kpa_score(p_project_list          IN      PA_PLSQL_DATATYPES.IdTabTyp,
                   x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   x_retcode               OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895


                      l_summary_table pa_exception_engine_pkg.summary_table;
  		      l_summary_seq NUMBER;
		      l_summary_det_seq NUMBER;
		      l_kpas PA_PLSQL_DATATYPES.Char30TabTyp ;
		      l_score NUMBER;
		      l_count NUMBER;
		      l_kpa_rule_id NUMBER;
		      l_weighting NUMBER;
		      l_indicator_code VARCHAR2(30);
		      l_excp_flag VARCHAR2(1);
		      l_thres_from NUMBER;
		      l_thres_to NUMBER;
		      l_status VARCHAR2(30);
		      l_threshold_id NUMBER;
		      l_rule_id NUMBER;

		      l_counter NUMBER;

		      l_score_list pa_plsql_datatypes.NumTabTyp ;
		      l_count_list PA_PLSQL_DATATYPES.NumTabTyp ;

		      CURSOR get_kpas IS
			 SELECT lookup_code
			   FROM pa_lookups
			   WHERE lookup_type = 'PA_PERF_KEY_AREAS'
			   AND lookup_code <> 'ALL'
			   ORDER BY To_number(predefined_flag) ASC ;

		      CURSOR get_score_rule (l_proj_id IN NUMBER, l_kpa_code IN VARCHAR2)
			IS
			   select
			     ppor.rule_id
			     from
			     pa_perf_rules ppr, pa_perf_object_rules ppor
			     where
			     ppor.object_type = 'PA_PROJECTS'
			     AND ppor.object_id = l_proj_id
			     and ppr.kpa_code = l_kpa_code
			     AND ppor.rule_id = ppr.rule_id
			     AND ppr.rule_type = 'SCORE_RULE'
			     AND ppr.score_method = 'SUM'
			     AND Trunc(Sysdate) BETWEEN ppr.start_date_active
			     AND Nvl(ppr.end_date_active, Trunc(Sysdate +1));


		      CURSOR get_kpa_score_rule (l_proj_id IN number, l_kpa_code IN varchar2)
			IS
			   select Nvl(sum(ppem.weighting), 0),
			     MIN (ppor.rule_id), COUNT(ppem.perf_txn_id)
			     from pa_perf_transactions ppem  ,
			     pa_perf_rules ppr, pa_perf_object_rules ppor
			     where ppem.current_flag = 'Y'
			     and ppem.perf_txn_obj_type = 'PA_PROJECTS'
			     and ppem.perf_txn_obj_id = l_proj_id
			     AND ppor.object_type = 'PA_PROJECTS'
			     AND ppor.object_id = l_proj_id
			     AND ppor.rule_id = ppr.rule_id
			     AND ppr.rule_type = 'SCORE_RULE'
			     AND ppr.score_method = 'SUM'
			     AND ppr.kpa_code = ppem.kpa_code
			     AND ppem.kpa_code = l_kpa_code
			     AND Nvl(ppem.exception_flag, 'Y') = 'Y'
			     AND Trunc(Sysdate) BETWEEN ppr.start_date_active
			     AND Nvl(ppr.end_date_active, Trunc(Sysdate +1))
			     group by ppem.kpa_code;


		       CURSOR get_kpa_score_breakdown (l_proj_id IN number, l_kpa_code IN VARCHAR2, l_ind IN varchar2)
			IS
			   select
			     COUNT(ppem.perf_txn_id),
			     Nvl(sum(ppem.weighting), 0)
			     from pa_perf_transactions ppem  ,
			     pa_perf_rules ppr, pa_perf_object_rules ppor
			     where ppem.current_flag = 'Y'
			     and ppem.perf_txn_obj_type = 'PA_PROJECTS'
			     and ppem.perf_txn_obj_id = l_proj_id
			     AND ppor.object_type = 'PA_PROJECTS'
			     AND ppor.object_id = l_proj_id
			     AND ppor.rule_id = ppr.rule_id
			     AND ppr.rule_type = 'SCORE_RULE'
			     AND ppr.score_method = 'SUM'
			     AND ppr.kpa_code = ppem.kpa_code
			     AND ppem.kpa_code = l_kpa_code
			     AND Nvl(ppem.exception_flag, 'Y') = 'Y'
			     AND Trunc(Sysdate) BETWEEN ppr.start_date_active
			     AND Nvl(ppr.end_date_active, Trunc(Sysdate +1))
			     AND ppem.indicator_code = l_ind
			     group by ppem.kpa_code;


		       CURSOR get_indicator
			 IS
			    SELECT lookup_code
			      FROM pa_lookups
			      WHERE lookup_type = 'PA_PERF_INDICATORS'
			      ORDER BY predefined_flag ASC;

		       l_errbuf	VARCHAR2(500);
		       l_retcode	VARCHAR2(100);
		       l_excep_flag VARCHAR2(1);

BEGIN

   x_retcode := '0';

   pa_debug.G_err_stage := 'Entering PAPFSCRE ()';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.g_err_stage := '   Current system time is '||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS');
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;


   /*** Begin business logic to generate the KPA Summary Info ***/

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Begin business logic to generate the KPA Summary Info ');
     PA_DEBUG.write_file('LOG', 'Get all KPA codes');
   END IF;

   -- get all kpa codes
   OPEN get_kpas;
   FETCH get_kpas bulk collect INTO l_kpas;
   CLOSE get_kpas;

   -- mass update the current_flag in PA_PERF_KPA_SUMMARY table

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Mass update the KPA Summary table');
   END IF;

   FORALL i IN p_project_list.first..p_project_list.last
     UPDATE pa_perf_kpa_summary
     SET current_flag = 'N'
     WHERE object_type = 'PA_PROJECTS'
     AND object_id = p_project_list(i);

   /* write the Scoring Logic Here  */

   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Process scoring logic for each project');
   END IF;


   FOR i IN p_project_list.first..p_project_list.last LOOP

     IF P_PA_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_file('LOG', 'Project ID : '||p_project_list(i));
     END IF;

       SELECT pa_perf_kpa_summary_s1.nextval
	 INTO   l_summary_seq
	 FROM   DUAL;


      l_summary_table.DELETE();


      --- for each KPA
      FOR j IN l_kpas.first..l_kpas.last LOOP

	 --- get the overall KPA Score
	 OPEN get_kpa_score_rule(p_project_list(i), l_kpas(j));
	 FETCH get_kpa_score_rule INTO l_score, l_kpa_rule_id, l_count;


	 if (get_kpa_score_rule%notfound) then
	    l_score := null;
	    l_kpa_rule_id := null;
	    l_count := null;
	 end if;
	 CLOSE get_kpa_score_rule;

	 IF (l_kpa_rule_id IS NULL) THEN
	    --- there is no exception transactions for this KPA Code
	    --- , we still need to create a
	    --- record in PA_PERF_KPA_SUMMARY later on


	    l_summary_table(j).kpa_code := l_kpas(j);
	    l_summary_table(j).indicator_code := null;
	    l_summary_table(j).score := 0;
	    l_summary_table(j).thres_from := NULL;
	    l_summary_table(j).thres_to := NULL;

	    --- only for the kpa which the project has a scoring rule
	    --  associated
	    --- we need to save the summary detatil information.


	    OPEN get_score_rule(p_project_list(i), l_kpas(j));
	    FETCH get_score_rule INTO l_rule_id;
	    IF (get_score_rule%notfound) THEN
	       l_rule_id := NULL;
	    END IF;

	    CLOSE get_score_rule;

	    IF (l_rule_id IS NOT NULL) THEN

	       SELECT pa_perf_kpa_summary_det_s1.NEXTVAL
		 INTO l_summary_det_seq
		 FROM dual;

               IF P_PA_DEBUG_MODE = 'Y' THEN
	         PA_DEBUG.write_file('LOG', 'Inserting into PA_PERF_KPA_SUMMARY_DET');
                 PA_DEBUG.write_file('LOG', 'KPA code : '||l_kpas(j));
                 PA_DEBUG.write_file('LOG', 'Rule ID  : '||l_rule_id);
	       END IF;

	       INSERT INTO pa_perf_kpa_summary_det
		 (
		  kpa_summary_det_id,
		  kpa_summary_id,
		  object_type,
		  object_id,
		  kpa_code,
		  indicator_code,
		  COUNT,
		  score,
		  rule_id,
		  ind1_count,
		  ind1_score,
		  ind2_count,
		  ind2_score,
		  ind3_count,
		  ind3_score,
		  ind4_count,
		  ind4_score,
		  ind5_count,
		  ind5_score,
		  creation_date,
		   created_by       ,
		  last_update_date,
		  last_updated_by       ,
		  last_update_login
		  )
		 VALUES
		 (
		  l_summary_det_seq,
		  l_summary_seq,
		  'PA_PROJECTS',
		  p_project_list(i),
		  l_kpas(j),
		  null,
		  0,
		  0,
		  l_rule_id,
		  0,
		  0,
		  0,
		  0,
		  0,
		  0,
		  0,
		  0,
		  0,
		  0,
		  Sysdate,
		  fnd_global.user_id,
		  Sysdate,
		  fnd_global.user_id,
		  fnd_global.login_id
		  );
	    END IF;


	  ELSE
	    -- if we find some transactions for the given KPA
	    -- ge the KPA Scroing Rule Threshold

	    l_retcode := 0;
	    -- call api TO get the threshold
	     pa_exception_engine_pkg.get_threshold     (
				   l_kpa_rule_id,
				   'SCORE_RULE',
				   l_score,
				   l_threshold_id,
				   l_indicator_code	,
				   l_excep_flag,
				   l_weighting,
				   l_thres_from,
				   l_thres_to,
				   l_errbuf,
				   l_retcode);

	     IF (l_retcode = 1 ) THEN
		--- if we find a matching threshold
		--- save the result into PA_PERF_KPA_SUMMARY_DET table

		l_score_list.DELETE;
		l_count_list.DELETE;

		l_counter := 1;
		FOR ind_code IN get_indicator  LOOP
		   OPEN get_kpa_score_breakdown(p_project_list(i), l_kpas(j), ind_code.lookup_code);
		   FETCH get_kpa_score_breakdown INTO l_count_list(l_counter), l_score_list(l_counter);
		   IF (get_kpa_score_breakdown%NOTfound) THEN
		      l_count_list(l_counter) := 0;
		      l_score_list(l_counter) := 0;
		   END IF;
		   CLOSE get_kpa_score_breakdown;

		   l_counter := l_counter+1;

		END LOOP;


		SELECT pa_perf_kpa_summary_det_s1.NEXTVAL
		  INTO l_summary_det_seq
		  FROM dual;

               IF P_PA_DEBUG_MODE = 'Y' THEN
	         PA_DEBUG.write_file('LOG', 'Inserting into PA_PERF_KPA_SUMMARY_DET');
		 PA_DEBUG.write_file('LOG', 'KPA code : '||l_kpas(j));
                 PA_DEBUG.write_file('LOG', 'Rule ID  : '||l_kpa_rule_id);
	       END IF;

		INSERT INTO pa_perf_kpa_summary_det
		  (
		   kpa_summary_det_id,
		   kpa_summary_id,
		   object_type,
		   object_id,
		   kpa_code,
		   indicator_code,
		   COUNT,
		   score,
		   rule_id,
		   ind1_count,
		   ind1_score,
		   ind2_count,
		   ind2_score,
		   ind3_count,
		   ind3_score,
		   ind4_count,
		   ind4_score,
		   ind5_count,
		   ind5_score,
		   creation_date,
		   created_by       ,
		   last_update_date,
		   last_updated_by       ,
		   last_update_login
		   )
		  VALUES
		  (
		   l_summary_det_seq,
		   l_summary_seq,
		   'PA_PROJECTS',
		   p_project_list(i),
		   l_kpas(j),
		   l_indicator_code,
		   l_count,
		   l_score,
		   l_kpa_rule_id,
		   l_count_list(1),
		   l_score_list(1),
		   l_count_list(2),
		   l_score_list(2),
		   l_count_list(3),
		   l_score_list(3),
		   l_count_list(4),
		   l_score_list(4),
		   l_count_list(5),
		   l_score_list(5),
		   Sysdate,
		   fnd_global.user_id,
		   Sysdate,
		   fnd_global.user_id,
		   fnd_global.login_id

		   );

	      --- save the result to PA_PERF_KPA_TRANS table
               IF P_PA_DEBUG_MODE = 'Y' THEN
	         PA_DEBUG.write_file('LOG', 'Inserting into PA_PERF_KPA_TRANS');
	       END IF;

		INSERT INTO pa_perf_kpa_trans
		  (kpa_summary_det_id,
		   perf_txn_id,
		   creation_date,
		   created_by       ,
		   last_update_date,
		   last_updated_by       ,
		   last_update_login)
		  SELECT l_summary_det_seq,perf_txn_id,  Sysdate,
		   fnd_global.user_id,
		   Sysdate,
		   fnd_global.user_id,
		   fnd_global.login_id
		  FROM pa_perf_transactions
		  WHERE perf_txn_obj_type = 'PA_PROJECTS'
		  AND perf_txn_obj_id = p_project_list(i)
		  AND kpa_code = l_kpas(j)
		  AND current_flag = 'Y'
		  AND Nvl(exception_flag, 'Y') = 'Y'
		  ;

		--- update the transaction to be as included in the last scoring

		UPDATE pa_perf_transactions
		  SET included_in_scoring = 'Y'
		  WHERE perf_txn_obj_type =  'PA_PROJECTS'
		  AND perf_txn_obj_id = p_project_list(i)
		  AND kpa_code = l_kpas(j)
		  AND current_flag = 'Y'
		  AND Nvl(exception_flag, 'Y') = 'Y'
		  ;

		--- save the KPA summary info

		l_summary_table(j).kpa_code := l_kpas(j);
		l_summary_table(j).indicator_code := l_indicator_code;
		l_summary_table(j).score := l_score;
		l_summary_table(j).thres_from := l_thres_from;
		l_summary_table(j).thres_to := l_thres_to;

	      ELSE
		--- if we do not find a matching threshold
		--- we still need to save to the details table.

		l_score_list.DELETE;
		l_count_list.DELETE;

		l_counter := 1;
		FOR ind_code IN get_indicator  LOOP
		   OPEN get_kpa_score_breakdown(p_project_list(i), l_kpas(j), ind_code.lookup_code);
		   FETCH get_kpa_score_breakdown INTO l_count_list(l_counter), l_score_list(l_counter);
		   IF (get_kpa_score_breakdown%NOTfound) THEN
		      l_count_list(l_counter) := 0;
		      l_score_list(l_counter) := 0;
		   END IF;
		   CLOSE get_kpa_score_breakdown;

		   l_counter := l_counter+1;

		END LOOP;


		SELECT pa_perf_kpa_summary_det_s1.NEXTVAL
		  INTO l_summary_det_seq
		  FROM dual;

               IF P_PA_DEBUG_MODE = 'Y' THEN
	         PA_DEBUG.write_file('LOG', 'Inserting into PA_PERF_KPA_SUMMARY_DET');
                 PA_DEBUG.write_file('LOG', 'KPA code : '||l_kpas(j));
                 PA_DEBUG.write_file('LOG', 'Rule ID  : '||l_kpa_rule_id);
	       END IF;

		INSERT INTO pa_perf_kpa_summary_det
		  (
		   kpa_summary_det_id,
		   kpa_summary_id,
		   object_type,
		   object_id,
		   kpa_code,
		   indicator_code,
		   COUNT,
		   score,
		   rule_id,
		   ind1_count,
		   ind1_score,
		   ind2_count,
		   ind2_score,
		   ind3_count,
		   ind3_score,
		   ind4_count,
		   ind4_score,
		   ind5_count,
		   ind5_score,
		   creation_date,
		   created_by       ,
		   last_update_date,
		   last_updated_by       ,
		   last_update_login
		   )
		  VALUES
		  (
		   l_summary_det_seq,
		   l_summary_seq,
		   'PA_PROJECTS',
		   p_project_list(i),
		   l_kpas(j),
		   null,
		   l_count,
		   l_score,
		   l_kpa_rule_id,
		   l_count_list(1),
		   l_score_list(1),
		   l_count_list(2),
		   l_score_list(2),
		   l_count_list(3),
		   l_score_list(3),
		   l_count_list(4),
		   l_score_list(4),
		   l_count_list(5),
		   l_score_list(5),
		    Sysdate,
		   fnd_global.user_id,
		   Sysdate,
		   fnd_global.user_id,
		   fnd_global.login_id
		   );

	      --- save the result to PA_PERF_KPA_TRANS table
		INSERT INTO pa_perf_kpa_trans
		  (kpa_summary_det_id,
		   perf_txn_id,
		   creation_date,
		   created_by       ,
		   last_update_date,
		   last_updated_by       ,
		   last_update_login)
		  SELECT l_summary_det_seq,perf_txn_id, Sysdate,
		   fnd_global.user_id,
		   Sysdate,
		   fnd_global.user_id,
		   fnd_global.login_id
		  FROM pa_perf_transactions
		  WHERE perf_txn_obj_type = 'PA_PROJECTS'
		  AND perf_txn_obj_id = p_project_list(i)
		  AND kpa_code = l_kpas(j)
		  AND current_flag = 'Y'
		  AND Nvl(exception_flag, 'Y') = 'Y'
		  ;

		--- update the transaction to be as included in the last scoring

		UPDATE pa_perf_transactions
		  SET included_in_scoring = 'Y'
		  WHERE perf_txn_obj_type =  'PA_PROJECTS'
		  AND perf_txn_obj_id = p_project_list(i)
		  AND kpa_code = l_kpas(j)
		  AND current_flag = 'Y'
		  AND Nvl(exception_flag, 'Y') = 'Y'
		  ;

		--- save the KPA summary info

		l_summary_table(j).kpa_code := l_kpas(j);
		l_summary_table(j).indicator_code := NULL;
		l_summary_table(j).score := l_score;
		l_summary_table(j).thres_from := NULL;
		l_summary_table(j).thres_to := null;

	     END IF;


	 END IF;




      END LOOP;

      --- calculate the overall score
      l_status := pa_perf_status_client_extn.get_performance_status(
							       'PA_PROJECTS',
							       p_project_list(i),
							       l_summary_table
							       );

   --Bug8253959: If l_summary_table length is less than 5, fill the rest with null
  IF l_summary_table.count<5 THEN
     FOR i IN (l_summary_table.Count+1)..5 LOOP
      l_summary_table(i).kpa_code := null;
	    l_summary_table(i).indicator_code := null;
	    l_summary_table(i).score := null;
	    l_summary_table(i).thres_from := NULL;
	    l_summary_table(i).thres_to := NULL;
  		END LOOP;

  END IF;
  -- create the record in PA_PERF_KPA_SUMMARY
      INSERT INTO pa_perf_kpa_summary
	(
	 kpa_summary_id,
	 object_type,
	 object_id,
	 date_checked,
	 current_flag,
	 perf_status_code,
	 kpa1_code,
	 kpa1_indicator,
	 kpa1_score,
	 kpa1_thres_from,
	 kpa1_thres_to,
	 kpa2_code,
	 kpa2_indicator,
	 kpa2_score,
	 kpa2_thres_from,
	 kpa2_thres_to,
	 kpa3_code,
	 kpa3_indicator,
	 kpa3_score,
	 kpa3_thres_from,
	 kpa3_thres_to,
	 kpa4_code,
	 kpa4_indicator,
	 kpa4_score,
	 kpa4_thres_from,
	 kpa4_thres_to,
	 kpa5_code,
	 kpa5_indicator,
	 kpa5_score,
	 kpa5_thres_from,
	 kpa5_thres_to,
	 creation_date,
		   created_by       ,
		   last_update_date,
		   last_updated_by       ,
		   last_update_login
	 )
	VALUES
	(
	 l_summary_seq,
	 'PA_PROJECTS',
	 p_project_list(i),
	 Sysdate,
	 'Y',
	 l_status,
	 l_summary_table(1).kpa_code,
	 l_summary_table(1).indicator_code,
	 l_summary_table(1).score,
	 l_summary_table(1).thres_from,
	 l_summary_table(1).thres_to,
	 l_summary_table(2).kpa_code,
	 l_summary_table(2).indicator_code,
	 l_summary_table(2).score,
	 l_summary_table(2).thres_from,
	 l_summary_table(2).thres_to,

	 l_summary_table(3).kpa_code,
	 l_summary_table(3).indicator_code,
	 l_summary_table(3).score,
	 l_summary_table(3).thres_from,
	 l_summary_table(3).thres_to,

	 l_summary_table(4).kpa_code,
	 l_summary_table(4).indicator_code,
	 l_summary_table(4).score,
	 l_summary_table(4).thres_from,
	 l_summary_table(4).thres_to,

	 l_summary_table(5).kpa_code,
	 l_summary_table(5).indicator_code,
	 l_summary_table(5).score,
	 l_summary_table(5).thres_from,
	 l_summary_table(5).thres_to,
	  Sysdate,
		   fnd_global.user_id,
		   Sysdate,
		   fnd_global.user_id,
		   fnd_global.login_id

	 );

      	 --- update the included in scoring flag for all other transactions
	 UPDATE pa_perf_transactions
	      SET included_in_scoring = 'N'
	      WHERE perf_txn_obj_type =  'PA_PROJECTS'
	      AND perf_txn_obj_id = p_project_list(i)
	      AND Nvl(exception_flag, 'Y') = 'Y'
	   AND included_in_scoring = 'Y'
	   AND perf_txn_id NOT IN
	   (
	    select ppkt.perf_txn_id
	    from pa_perf_kpa_summary ppks, pa_perf_kpa_summary_det ppkd,
	    pa_perf_kpa_trans ppkt
	    where ppks.object_type = 'PA_PROJECTS' and
	    ppks.object_id = p_project_list(i)
	    and ppks.current_flag = 'Y'
	    and ppks.kpa_summary_id = ppkd.kpa_summary_id
	    and ppkd.kpa_summary_det_id = ppkt.kpa_summary_det_id
	    )
	      ;

   commit;

   END LOOP;


   IF P_PA_DEBUG_MODE = 'Y' THEN
     PA_DEBUG.write_file('LOG', 'Sucessfully processed scoring logic for each project');
   END IF;

   x_retcode := '1';

   pa_debug.G_err_stage := 'Leaving PAPFSCRE () with success';
   IF P_PA_DEBUG_MODE = 'Y' THEN
     pa_debug.write_file('LOG', pa_debug.g_err_stage);
   END IF;
   pa_debug.reset_err_stack;

   commit;

EXCEPTION

   WHEN NO_DATA_FOUND THEN

    pa_debug.write_file('LOG', 'PAPFSCRE () exception: No data found');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

   WHEN OTHERS THEN
    x_errbuf := x_errbuf||'errbuf: '||sqlerrm;
    pa_debug.write_file('LOG', 'PAPFSCRE () exception: Others');
    pa_debug.write_file('LOG', pa_debug.g_err_stack);
    pa_debug.write_file('LOG', pa_debug.g_err_stage);

END get_kpa_score;

END pa_exception_engine_pkg;

/
