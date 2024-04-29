--------------------------------------------------------
--  DDL for Package Body PJI_REP_DFLT_DRILLDOWN_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_REP_DFLT_DRILLDOWN_TXN" AS
/* $Header: PJIRX13B.pls 120.2 2007/10/24 04:07:10 paljain ship $ */


/*
** This stored procedure derives all the possible parameters
** (ex.: event_type, GL_date, pa_date, org_id, etc)
** that will be added dynamically to the VO SQL statement.
** To do this we will start from the available input parameters:
** input params (always not null)   : p_time_id, p_calendar_id, p_calendar_type,
**                                    project_id
** input params (wbs OR rbs OR both): rbs_element_id, wbs_element_id (task_id)
**
** History
**   04-FEB-2004    EPASQUIN   Created
**   28-APR-2004    EPASQUIN   Updated the pkg to use PA_RBS_ELEMENTS table
**                             instead of PA_PROJ_ELEM_VER_RBS.
*/
PROCEDURE derive_parameters(
   p_project_id       NUMBER
  ,p_calendar_type    VARCHAR2
  ,p_calendar_id      NUMBER
  ,p_time_id          NUMBER
  ,p_wbs_element_id   NUMBER
  ,p_rbs_element_id   NUMBER
  ,p_commitment_flag              VARCHAR2
  ,p_time_flag                    VARCHAR2
  ,x_start_date                   OUT NOCOPY DATE
  ,x_end_date                     OUT NOCOPY DATE
  ,x_task_id                      OUT NOCOPY NUMBER
  ,x_rev_categ_code               OUT NOCOPY VARCHAR2
  ,x_event_type_id                OUT NOCOPY NUMBER
  ,x_event_type                   OUT NOCOPY VARCHAR2
  ,x_inventory_item_ids           OUT NOCOPY VARCHAR2
  ,x_org_id                       OUT NOCOPY NUMBER
  ,x_expenditure_category_id      OUT NOCOPY NUMBER
  ,x_expenditure_type_id          OUT NOCOPY NUMBER
  ,x_item_category_id             OUT NOCOPY NUMBER
  ,x_job_id                       OUT NOCOPY NUMBER
  ,x_person_type_id               OUT NOCOPY NUMBER
  ,x_person_id                    OUT NOCOPY NUMBER
  ,x_non_labor_resource_id        OUT NOCOPY NUMBER
  ,x_bom_equipment_resource_id    OUT NOCOPY NUMBER
  ,x_bom_labor_resource_id        OUT NOCOPY NUMBER
  ,x_vendor_id                    OUT NOCOPY NUMBER
  ,x_resource_class_id            OUT NOCOPY NUMBER
  ,x_resource_class_code          OUT NOCOPY VARCHAR2
  ,x_person_type                  OUT NOCOPY VARCHAR2
  ,x_expenditure_type             OUT NOCOPY VARCHAR2
  ,x_prg_project_id               OUT NOCOPY NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
) AS

inv_item_id_list  number_nestedtb;
inv_item_id       NUMBER;
A NUMBER;
i NUMBER;
l_object_type VARCHAR2(255);

 l_start_date    DATE;
 l_end_date      DATE;

BEGIN

  NULL;

  -- variables initialization
  l_start_date := NULL;
  l_end_date   := NULL;
  x_start_date := NULL;
  x_end_date := NULL;
  x_task_id := NULL;
  x_event_type_id := NULL;
  x_event_type := NULL;
  x_org_id := NULL;
  x_expenditure_category_id := NULL;
  x_expenditure_type_id := NULL;
  x_expenditure_type := NULL;
  x_item_category_id := NULL;
  x_job_id := NULL;
  x_person_type_id := NULL;
  x_person_id := NULL;
  x_non_labor_resource_id := NULL;
  x_bom_equipment_resource_id := NULL;
  x_bom_labor_resource_id := NULL;
  x_vendor_id := NULL;
  x_rev_categ_code := NULL;
  x_resource_class_id := NULL;
  x_inventory_item_ids := '';
  inv_item_id := NULL;
  A           := NULL;
  i           := NULL;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;



  BEGIN
    x_return_status :=  FND_API.G_RET_STS_SUCCESS; -- Added for bug 3848087

    -- NULL;


  /* Bug4161726, 4159404 - The ITD date was retrieving wrongly, Fixing the ITD issue and also pass the correct
     start and end date to the transaction page

     If commitment Transaction
             if PTD then all the transaction which are before the end reporting period.
             if ITD then all commitment transaction should select.

     If Non Commitment Transaction
             if PTD then all transaction within the the start and end reporting period.
             if ITD then all the transaction which are before end reporting period.  */


       x_start_date := TO_DATE('01-01-1950','DD/MM/YYYY');
       x_end_date   := TO_DATE('31-12-2050','DD/MM/YYYY');


     /* Program Changes - Get the project id based on the wbs element id */

           SELECT project_id
             INTO x_prg_project_id
             FROM pa_proj_elements
            WHERE proj_element_id = p_wbs_element_id ;


       /* The following SQL will get the reporting period which is based on the calandar type and Time Id */


         SELECT start_date, end_date
            INTO l_start_date, l_end_date
            FROM
             (
                SELECT start_date, end_date
                 FROM   pji_time_ent_period_v  per
                       ,pji_time_rpt_struct  rpt
                WHERE  1=1
                  AND 'E' = p_calendar_type
                  AND per.ent_period_id = rpt.time_id
                  AND rpt.report_date = TO_DATE(p_time_id,'j')
                  AND rpt.record_type_id = 256
                UNION ALL
                 SELECT start_date, end_date
                   FROM pji_time_cal_period_V      per
                       ,pji_time_cal_rpt_struct  rpt
                  WHERE 1=1
                    AND per.calendar_id   =  p_calendar_id
                    AND 'E' <> p_calendar_type
                    AND per.cal_period_id = rpt.time_id
                    AND rpt.report_date = TO_DATE(p_time_id,'j')
                    AND rpt.record_type_id = 256
                    AND rpt.calendar_id = p_calendar_id
              );


    IF (p_commitment_flag  = 'N')  THEN

         x_end_date     := l_end_date;       /* Period end date for ITD and PTD */

        IF (p_time_flag = 'PTD') THEN

           x_start_date   := l_start_date;

	ELSIF (p_time_flag = 'QTD') THEN

	 SELECT start_date, end_date
           INTO l_start_date, l_end_date
           FROM
            (
               SELECT start_date, end_date
                FROM   pji_time_ent_QTR_v  per
                      ,pji_time_rpt_struct  rpt
               WHERE  1=1
                 AND 'E' = p_calendar_type
                 AND per.ent_qtr_id = rpt.time_id
                 AND rpt.report_date = TO_DATE(p_time_id,'j')
                 AND rpt.record_type_id = 512
               UNION ALL
                SELECT start_date, end_date
                  FROM pji_time_cal_qtr_V      per
                      ,pji_time_cal_rpt_struct  rpt
                 WHERE 1=1
                   AND per.calendar_id   =  p_calendar_id
                   AND 'E' <> p_calendar_type
                   AND per.cal_qtr_id = rpt.time_id
                   AND rpt.report_date = TO_DATE(p_time_id,'j')
                   AND rpt.record_type_id = 512
                   AND rpt.calendar_id = p_calendar_id
             );


            x_start_date   := l_start_date;

	   ELSIF (p_time_flag = 'YTD') THEN

	   SELECT start_date, end_date
           INTO l_start_date, l_end_date
           FROM
            (
               SELECT start_date, end_date
                FROM   pji_time_ent_year_v  per
                      ,pji_time_rpt_struct  rpt
               WHERE  1=1
                 AND 'E' = p_calendar_type
                 AND per.ent_year_id = rpt.time_id
                 AND rpt.report_date = TO_DATE(p_time_id,'j')
                 AND rpt.record_type_id = 128
               UNION ALL
                SELECT start_date, end_date
                  FROM pji_time_cal_year_V      per
                      ,pji_time_cal_rpt_struct  rpt
                 WHERE 1=1
                   AND per.calendar_id   =  p_calendar_id
                   AND 'E' <> p_calendar_type
                   AND per.cal_year_id = rpt.time_id
                   AND rpt.report_date = TO_DATE(p_time_id,'j')
                   AND rpt.record_type_id = 512
                   AND rpt.calendar_id = p_calendar_id
             );

             x_start_date   := l_start_date;


         END IF;


    ELSE   /* Commitment_flag = 'Y' */


        IF (p_time_flag = 'PTD') THEN   /* for PTD set the reporting end date for ITD open dates */

           x_end_date     := l_end_date;

        END IF;


    END IF;




  /*  Bug4161726, 4159404,  Commmenting the old logic */


  /*  IF (p_time_id = -1) THEN

      -- if -1 is received, it means it was requested a drilldown for an ITD value;
      -- in this case we derive start_date, end_date from pa_projects_all
      SELECT start_date, closed_date --ACTUAL_FINISH_DATE, ACTUAL_START_DATE,
      INTO x_start_date, x_end_date
      FROM pa_projects_all
      WHERE project_id = p_project_id;

      IF x_end_date IS NULL OR x_end_Date > SYSDATE THEN
        x_end_date := SYSDATE;
      END IF;

    ELSE

      -- in all other cases, it is requested a drilldown for a PTD value:
      -- p_time_id actually contains reporting_date_julian
      -- (prfPeriodDateJulian) from the Prj perf pages.
      SELECT start_date, end_date
      INTO x_start_date, x_end_date
      FROM
      (
        SELECT start_date, end_date
        FROM
        pji_time_ent_period_v  per
        , pji_time_rpt_struct  rpt
        WHERE 1=1
        AND 'E' = p_calendar_type
        AND per.ent_period_id = rpt.time_id
        AND rpt.report_date = TO_DATE(p_time_id,'j')
        AND rpt.record_type_id = 256
        UNION ALL
        SELECT start_date, end_date
        FROM
        pji_time_cal_period_V      per
        , pji_time_cal_rpt_struct  rpt
        WHERE 1=1
        AND per.calendar_id   =  p_calendar_id
        AND 'E' <> p_calendar_type
        AND per.cal_period_id = rpt.time_id
        AND rpt.report_date = TO_DATE(p_time_id,'j')
        AND rpt.record_type_id = 256
        AND rpt.calendar_id = p_calendar_id
      );

    END IF;   */




    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
           pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');
        WHEN TOO_MANY_ROWS THEN
            x_return_status := FND_API.G_RET_STS_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
           pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');

  END;

  BEGIN
    SELECT object_type
    INTO   l_object_type
    FROM   pa_proj_elements
    WHERE  proj_element_id = p_wbs_element_id;
  EXCEPTION WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
           pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG', p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');
  END;

  IF l_object_type = 'PA_STRUCTURES' THEN
    -- in this case the selected proj_element_id is a structure
    x_task_id := NULL;
  ELSIF l_object_type = 'PA_TASKS' THEN
    -- in this case the selected proj_element_id is a task
    x_task_id := p_wbs_element_id;
  END IF;

  IF (p_rbs_element_id IS NOT NULL) THEN
    BEGIN

      BEGIN

        SELECT
           rbs.event_type_id
          ,et.event_type
          ,rbs.organization_id
          ,rbs.inventory_item_id
          ,rbs.expenditure_category_id
          ,rbs.expenditure_type_id
          ,expt.expenditure_type
          ,rbs.item_category_id
          ,rbs.job_id
          ,rbs.person_type_id
          ,rbs.person_id
          ,rbs.non_labor_resource_id
          ,rbs.bom_equipment_id
          ,rbs.bom_labor_id
          ,rbs.supplier_id
          ,rbs.resource_class_id
          ,rc.resource_class_code
          --,rbsn.resourcetype
          ,et.revenue_category_code
        INTO
           x_event_type_id
          ,x_event_type
          ,x_org_id
          ,inv_item_id
          ,x_expenditure_category_id
          ,x_expenditure_type_id
          ,x_expenditure_type
          ,x_item_category_id
          ,x_job_id
          ,x_person_type_id
          ,x_person_id
          ,x_non_labor_resource_id
          ,x_bom_equipment_resource_id
          ,x_bom_labor_resource_id
          ,x_vendor_id
          ,x_resource_class_id
          ,x_resource_class_code
          --,x_resourcetype
          ,x_rev_categ_code
        FROM
           PA_RBS_ELEMENTS             rbs
          ,pa_event_types              et
          ,pa_resource_classes_b       rc
          ,pa_expenditure_types        expt
          --,PA_RBS_ELEMENT_NAMES_B      rbsn
        WHERE 1=1
          AND rbs.rbs_element_id = p_rbs_element_id
          AND rbs.resource_class_id  = rc.resource_class_id (+) -- Added outer joing for bug 3848087
          -- we want to obtain the rbs records regardless of event_type_id or expenditure_type_id
          AND rbs.event_type_id = et.event_type_id (+)
          AND rbs.expenditure_type_id = expt.expenditure_type_id (+)
          --AND rbs.element_version_id = rbsn.rbs_element_id
        ;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
           pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');

          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
            Pji_Rep_Util.add_message(p_app_short_name=>'PJI',
              p_msg_name=>'PJI_REP_GENERIC_MSG',
              p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,
              p_token1=>'PROC_NAME',
              p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');

      END;

      BEGIN

        SELECT system_person_type
        INTO x_person_type
        FROM per_person_types
        WHERE person_type_id = x_person_type_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
           pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');

          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
            Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
              p_msg_name=>'PJI_REP_GENERIC_MSG',
              p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
              p_token1=>'PROC_NAME',
              p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');

      END;


      IF inv_item_id IS NOT NULL THEN
        x_inventory_item_ids := TO_CHAR(inv_item_id);
      ELSE
        --collect all inv_item_id that match the retrieved item_category_id
        SELECT cat.inventory_item_id
        BULK COLLECT INTO inv_item_id_list
        FROM
        pa_resource_classes_b cls
        , pa_plan_res_defaults def
        , mtl_item_categories cat
        WHERE 1=1
        AND cls.resource_class_id = def.object_id
        AND cls.resource_class_code = 'MATERIAL_ITEMS'
        AND def.object_type = 'CLASS'
        AND cat.organization_id = def.item_master_id
        AND cat.category_set_id = def.item_category_set_id
        AND category_id = x_item_category_id
        ;

        -- copy the nested table in a comma separated list of values string
        IF inv_item_id_list.COUNT > 0 THEN
          -- take care of 1st element so don't need to worry about the last comma
          x_inventory_item_ids := TO_CHAR(inv_item_id_list(inv_item_id_list.FIRST));
          A :=  inv_item_id_list.NEXT(inv_item_id_list.FIRST);

          -- copy the remaining elements
          FOR i IN A..inv_item_id_list.LAST LOOP
            IF inv_item_id_list(i) IS NOT NULL THEN
                x_inventory_item_ids := x_inventory_item_ids || ', ' ||
                                        TO_CHAR(inv_item_id_list(i));
            END IF;
          END LOOP;

        END IF;

      END IF;
      --dbms_output.put_line('x_inventory_item_ids='||x_inventory_item_ids);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
           pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');
          NULL;
        WHEN TOO_MANY_ROWS THEN
            x_return_status := FND_API.G_RET_STS_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
           pji_rep_util.add_message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');
          NULL;
        WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; -- Added for bug 3848087
            x_msg_count := x_msg_count + 1;
          Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
            p_msg_name=>'PJI_REP_GENERIC_MSG',
            p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,
            p_token1=>'PROC_NAME',
            p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.derive_parameters');

    END;

  END IF;

  COMMIT;

END derive_parameters;


/*
**
** History
**   13-JUL-2004    EPASQUIN   Created
*/
PROCEDURE determine_events_costs_display(
   p_wbs_element_id               NUMBER
  ,x_task_id                      OUT NOCOPY NUMBER
  ,x_show_costs_flag              OUT NOCOPY VARCHAR2
  ,x_show_events_flag             OUT NOCOPY VARCHAR2
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
) AS

l_object_type      VARCHAR2(255);
l_chargeable_flag  VARCHAR2(255);
l_top_task_id      VARCHAR2(255);

BEGIN

  x_show_events_flag := 'N';
  x_show_costs_flag   := 'Y';
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;

  BEGIN
    SELECT object_type
    INTO   l_object_type
    FROM   pa_proj_elements
    WHERE  proj_element_id = p_wbs_element_id;
  EXCEPTION WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := x_msg_count + 1;
          Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
            p_msg_name=>'PJI_REP_GENERIC_MSG',
            p_msg_type=>FND_API.G_RET_STS_UNEXP_ERROR,
            p_token1=>'PROC_NAME',
            p_token1_value=>'PJI_REP_DFLT_DRILLDOWN_TXN.determine_events_costs_display');
  END;

  IF l_object_type = 'PA_STRUCTURES' THEN

    -- in this case the selected proj_element_id is a structure
    x_task_id := NULL;
    x_show_events_flag := 'Y';

  ELSIF l_object_type = 'PA_TASKS' THEN

    -- in this case the selected proj_element_id is a task
    x_task_id := p_wbs_element_id;

    BEGIN
      SELECT chargeable_flag, top_task_id
      INTO l_chargeable_flag, l_top_task_id
      FROM pa_tasks
      WHERE task_id = p_wbs_element_id;
    EXCEPTION WHEN OTHERS THEN
      l_top_task_id := NULL;
      l_chargeable_flag := NULL;
    END;

    IF l_top_task_id = p_wbs_element_id THEN
      x_show_events_flag := 'Y';
    END IF;

    IF l_chargeable_flag = 'Y' THEN
      x_show_costs_flag := 'Y';
    END IF;

  END IF;

END determine_events_costs_display;


END Pji_Rep_Dflt_Drilldown_Txn;

/
