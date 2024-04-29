--------------------------------------------------------
--  DDL for Package Body PA_FCST_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FCST_GLOBAL" as
/* $Header: PARFSGLB.pls 120.2 2006/01/11 17:48:18 ramurthy noship $ */

PROCEDURE GetDefaultValue(x_start_period    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_show_amount     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_project_type    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_project_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_view_type       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_apply_prob_flag OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_class_display   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_prj_owner_display OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_return_status   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count       OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         )
IS


l_start_period        VARCHAR2(30);
l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;
l_start_date          DATE;
l_end_date            DATE;
l_csr_end_date        DATE;
l_period_type         VARCHAR2(30);

l_class_display       VARCHAR2(60);
l_prj_owner_display   NUMBER;

/* NPE Changes Begin*/
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
l_user_profile_option_name1  varchar2(1000);
l_user_profile_option_name2  varchar2(1000);
org_count        NUMBER;
l_default_calendar  VARCHAR2(240);
/* NPE Changes End */


CURSOR C1(l_start_date DATE) IS
      SELECT end_date
      FROM pa_fcst_periods_tmp
     WHERE start_date  >= l_start_date
       order by start_date;



BEGIN

   Populate_Fcst_Periods;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table

  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  /* Initializing Global variable */

    pa_fcst_global.Global_proj_fcst_show_amt          := 'REVENUE';
    pa_fcst_global.Global_view_type                   := 'PERIODIC';
    pa_fcst_global.Global_ProbabilityPerFlag          := 'N';
    pa_fcst_global.Global_Period_Set_Name             := NULL;


/*  Assigning Global variable to Out variables. */

   x_show_amount    :=  pa_fcst_global.Global_proj_fcst_show_amt;
   x_project_type   :=  null;
   x_project_status :=  null;
   x_view_type      :=  pa_fcst_global.Global_view_type;
   x_apply_prob_flag :=  pa_fcst_global.Global_ProbabilityPerFlag;


   l_period_type  := pa_fcst_global.Global_period_type;


  /* Added the logic to display the classification and Project owner colum
     display in the screen  */

  BEGIN
   /* NPE Changes - The MO: Operating Unit should be checked here .
      If we can put a join with pa_implementations then
      in NO_data_found, we can raise message for missing Mo: operating Unit.
      Since I am not very sure, so keeping the logic to check for Mo operating unit
      later in the code*/

       SELECT KEY_MEMBER_ROLE_ID,
              FORECAST_CLASS_CATEGORY
         INTO l_prj_owner_display,
              l_class_display
         FROM pa_forecasting_options;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        null;

  END;


   pa_fcst_global.Global_Class_category  := l_class_display;
   pa_fcst_global.Global_key_member_id   := l_prj_owner_display;


    If l_class_display IS NULL THEN
       x_class_display := 'N';
    else
       x_class_display := 'Y';
    End If;


    If l_prj_owner_display IS NULL THEN
       x_prj_owner_display := 'N';
    else
       x_prj_owner_display := 'Y';
    End If;

/* NPE Changes Begin - Added displaying error messages for missing period type profile*/

    -- Not needed as the value is alreday coming from pa_fcst_global.Global_period_type
   /* select fnd_profile.value('PA_FORECASTING_PERIOD_TYPE')
      into l_period_type
      from dual; */


   If l_period_type is null THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

       SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name1
       FROM fnd_profile_options_tl
       WHERE profile_option_name='PA_FORECASTING_PERIOD_TYPE'
       AND language=userenv('LANG');

       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    => 'PROFILES',
                            p_value1    =>  l_user_profile_option_name1);

       l_msg_count := FND_MSG_PUB.count_msg;
       if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
            else
             x_msg_count := l_msg_count;
        end if;
            pa_debug.reset_err_stack;
            return;
    end if;

  end if;
/* NPE Changes End */


  BEGIN

   --Calling procedure to initialize Global_Period_Set_Name;
   pa_fcst_global.SetPeriodSetName;

   SELECT period_name, start_date, end_date
     INTO l_start_period, l_start_date, l_end_date
     FROM pa_fcst_periods_tmp_v
    WHERE period_type = pa_fcst_global.Global_period_type
      AND trunc(sysdate) between start_date and end_date
      AND to_char(period_year) = to_char(sysdate,'YYYY');


  x_start_period := l_start_period;


  EXCEPTION
       WHEN NO_DATA_FOUND THEN

   begin

    SELECT period_name, start_date, end_date
      INTO l_start_period, l_start_date, l_end_date
      FROM pa_fcst_periods_tmp_v
     WHERE period_type = pa_fcst_global.Global_period_type
       and start_date =
           ( SELECT max(start_date) from pa_fcst_periods_tmp_v
              WHERE period_type = pa_fcst_global.Global_period_type
                AND start_date < sysdate
           );

    x_start_period := l_start_period;

   /* NPE Changes Begin - Added displaying error messages for missing calendar */
    EXCEPTION

       WHEN NO_DATA_FOUND THEN

       x_return_status := FND_API.G_RET_STS_ERROR;
       l_default_calendar := FND_PROFILE.VALUE('PA_PRM_DEFAULT_CALENDAR');
       select count(*) into org_count from pa_implementations;

       IF l_default_calendar is null THEN
	       SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name2
	       FROM fnd_profile_options_tl
               WHERE profile_option_name='PA_PRM_DEFAULT_CALENDAR'
	       AND language=userenv('LANG');

	       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    => 'PROFILES',
                            p_value1    =>  l_user_profile_option_name2);

        END IF;
        IF org_count=0 THEN
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name  => 'PA_INCORRECT_MO_OPERATING_UNIT');

        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;
        if l_msg_count > 0 then
         if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
            else
             x_msg_count := l_msg_count;
        end if;
            pa_debug.reset_err_stack;
            return;
    end if;
  end;
    /* NPE Changes End */
  END;




     OPEN C1(l_start_date);

     LOOP

         FETCH C1
          INTO l_csr_end_date;

          EXIT WHEN C1%NOTFOUND;

          EXIT WHEN l_period_type = 'PA' and C1%ROWCOUNT = 13;

          EXIT WHEN l_period_type = 'GL' and C1%ROWCOUNT = 6;



     END LOOP;

     CLOSE C1;


   pa_fcst_global.Global_proj_fcst_start_date    := l_start_date;
   pa_fcst_global.Global_proj_fcst_end_date      := l_csr_end_date;


  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FCST_GLOBAL',
                               p_procedure_name   => 'GetDefaultValue');

END GetDefaultValue;

procedure pa_fcst_proj_get_default(p_project_id          IN   NUMBER,
                                   x_show_amount_type    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_start_period_name   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_apply_prob_per_flag OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_msg_data            OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

l_start_date    DATE;
l_end_date      DATE;
l_period_type   VARCHAR2(30);
l_project_type_class   VARCHAR2(30);
l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;
/* NPE Changes Begin*/
l_msg_count       NUMBER := 0;
l_data            VARCHAR2(2000);
l_msg_data        VARCHAR2(2000);
l_msg_index_out   NUMBER;
l_return_status   VARCHAR2(2000);
l_user_profile_option_name1  varchar2(1000);
l_user_profile_option_name2  varchar2(1000);
org_count        NUMBER;
l_default_calendar  VARCHAR2(240);
/* NPE Changes End */

BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;


  --Clear the global PL/SQL message table

  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

BEGIN
   /* NPE Changes - The MO: Operating Unit should be checked here .
      I am not sure that why we are taking _all tables
      here. If we can put a join with pa_implementations then
      in NO_data_found, we can raise message for missing Mo: operating Unit.
      Since we are not sure, so keeping the logic to check for Mo operating unit
      later in the code*/

   SELECT  pr2.project_type_class_code
    INTO    l_project_type_class
        FROM    pa_projects_all pr1,
                pa_project_types_all pr2
        WHERE   pr1.project_id = p_project_id
         AND    pr2.project_type = pr1.project_type
         AND    nvl(pr1.org_id,-99)=nvl(pr2.org_id,-99);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;

END;

pa_fcst_global.Global_project_type_class := l_project_type_class;

/* Set the Global variable for Project Id */

  pa_fcst_global.Global_ProjectId     := p_project_id;

 /* Initializing Global variables */
   IF pa_fcst_global.Global_project_type_class = 'CONTRACT' THEN
       Global_proj_fcst_show_amt          := 'REVENUE';
   ELSE
       Global_proj_fcst_show_amt          := 'COST';
   END IF;

    Global_ProbabilityPerFlag          := 'N';

 /* Assigning Global value into output variables */

  x_show_amount_type     := pa_fcst_global.Global_proj_fcst_show_amt;
  x_apply_prob_per_flag  := pa_fcst_global.Global_ProbabilityPerFlag;
  l_period_type          := pa_fcst_global.global_period_type;

/* NPE Changes Begin - Added displaying error messages for missing period type profile*/
/*
   select fnd_profile.value('PA_FORECASTING_PERIOD_TYPE')
     into l_period_type
     from dual;
*/
   If l_period_type is null THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

       SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name1
       FROM fnd_profile_options_tl
       WHERE profile_option_name='PA_FORECASTING_PERIOD_TYPE'
       AND language=userenv('LANG');

       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    => 'PROFILES',
                            p_value1    =>  l_user_profile_option_name1);

       l_msg_count := FND_MSG_PUB.count_msg;
       if l_msg_count > 0 then
         if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
            else
             x_msg_count := l_msg_count;
        end if;
            pa_debug.reset_err_stack;
            return;
    end if;

  end if;
 /* NPE Changes End */

  BEGIN


    SELECT  period_name
      INTO  x_start_period_name
      FROM  pa_fcst_periods_tmp_v
     WHERE  period_type = l_period_type
       AND  trunc(sysdate) between start_date and end_date
       AND  to_char(period_year) = to_char(sysdate,'YYYY');

    EXCEPTION
       WHEN NO_DATA_FOUND THEN

    begin

    SELECT period_name
      INTO x_start_period_name
      FROM pa_fcst_periods_tmp_v
     WHERE period_type = pa_fcst_global.Global_period_type
       and start_date =
           ( SELECT max(start_date) from pa_fcst_periods_tmp_v
              WHERE period_type = pa_fcst_global.Global_period_type
                AND start_date < sysdate
           );
       /* NPE Changes Begin - Added displaying error messages for missing calendar */
     EXCEPTION

       WHEN NO_DATA_FOUND THEN

       x_return_status := FND_API.G_RET_STS_ERROR;
       l_default_calendar := FND_PROFILE.VALUE('PA_PRM_DEFAULT_CALENDAR');
       select count(*) into org_count from pa_implementations;

       IF l_default_calendar is null THEN
	       SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name2
	       FROM fnd_profile_options_tl
               WHERE profile_option_name='PA_PRM_DEFAULT_CALENDAR'
	       AND language=userenv('LANG');

	       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    => 'PROFILES',
                            p_value1    =>  l_user_profile_option_name2);
       END IF;
       IF org_count=0 THEN
               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                            p_msg_name  => 'PA_INCORRECT_MO_OPERATING_UNIT');

       END IF;

       l_msg_count := FND_MSG_PUB.count_msg;
       if l_msg_count > 0 then
         if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
            else
             x_msg_count := l_msg_count;
        end if;
            pa_debug.reset_err_stack;
            return;
      end if;

    end;
     /* NPE Changes End */
  END;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FCST_GLOBAL',
                               p_procedure_name   => 'pa_fcst_proj_get_default');

END pa_fcst_proj_get_default;

PROCEDURE Set_CrossProject_GlobalValue(p_start_period    	IN  VARCHAR2,
                                       p_Show_amount     	IN  VARCHAR2,
                                       p_apply_prob_flag 	IN  VARCHAR2,
                                       p_page_first_flag        IN  VARCHAR2,
                                       p_project_number  	IN  VARCHAR2,
                                       p_project_name    	IN  VARCHAR2,
                                       p_project_type    	IN  VARCHAR2,
                                       p_organization_name 	IN  VARCHAR2,
                                       p_project_status  	IN  VARCHAR2,
                                       p_project_manager_name 	IN  VARCHAR2,
                                       p_project_customer_name  IN  VARCHAR2,
                                       x_return_status   	OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count       	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data        	OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                      )

IS

l_period_name          VARCHAR2(30);
l_start_date           DATE;
l_end_date             DATE;
l_period_type          VARCHAR2(30);
l_org_id               NUMBER(15);

l_csr_end_date         DATE;

CURSOR C1(l_period_type VARCHAR2,l_start_date DATE) IS
      -- Bug 4874283 - perf changes - remove trunc so index U2 is used
      SELECT end_date
      FROM pa_fcst_periods_tmp_v
     WHERE period_type = l_period_type
       -- AND trunc(start_date)  >= trunc(l_start_date) -- 4874283
       AND start_date  >= trunc(l_start_date) -- 4874283
       order by start_date;


l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;

BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table

  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
/* Populate the Period Temp Table */
Populate_Fcst_Periods;

pa_fcst_global.Global_Page_First_Flag		  := p_page_first_flag;

IF p_show_amount <> 'X' THEN
pa_fcst_global.Global_proj_fcst_show_amt          := p_show_amount;
END IF;

IF p_apply_prob_flag <> 'X' THEN
pa_fcst_global.Global_ProbabilityPerFlag          := p_apply_prob_flag;
END IF;

IF p_project_number <> 'X' THEN
pa_fcst_global.Global_Project_Number		  := p_project_number;
ELSE pa_fcst_global.Global_Project_Number         :='ALL';
END IF;

IF p_project_name <> 'X' THEN
pa_fcst_global.Global_Project_Name                := p_project_name;
ELSE pa_fcst_global.Global_Project_Name           :='XXXXXXXXXXXXXXX';
END IF;

IF p_project_type <> 'X' THEN
pa_fcst_global.Global_project_type                := p_project_type;
ELSE pa_fcst_global.Global_project_type           := 'ALL';
END IF;

IF p_organization_name <> 'X' THEN
pa_fcst_global.Global_Orgnization_Name            := p_organization_name;

select organization_id
into  l_org_id
from hr_all_organization_units_tl
where name = p_organization_name
AND   language = userenv('LANG');
pa_fcst_global.Global_Orgnization_Id              :=l_org_id;

ELSE pa_fcst_global.Global_Orgnization_Name       :='ALL';
END IF;

IF p_project_status <> 'X' THEN
pa_fcst_global.Global_project_status              := p_project_status;
ELSE pa_fcst_global.Global_project_status         := 'ALL';
END IF;

IF p_project_manager_name <> 'X' THEN
pa_fcst_global.GLobal_Project_Manager_Name        := p_project_manager_name;
ELSE pa_fcst_global.GLobal_Project_Manager_Name   := 'XXXXXXXXXXXXXXX';
END IF;

IF p_project_customer_name <> 'X' THEN
pa_fcst_global.GLobal_Project_Customer_Name        := p_project_customer_name;
ELSE pa_fcst_global.GLobal_Project_Customer_Name   := 'XXXXXXXXXXXXXXX';
END IF;

 l_period_type  := pa_fcst_global.Global_period_type;

  BEGIN

   SELECT
          Start_Date,
          End_Date
     INTO
          l_start_date,
          l_end_date
     FROM pa_fcst_periods_tmp_v
    WHERE period_name = p_start_period
      AND period_type = l_period_type;


  EXCEPTION
       WHEN NO_DATA_FOUND THEN
         null;

  END;

     OPEN C1(l_period_type, l_start_date);

     LOOP

         FETCH C1
          INTO l_csr_end_date;

          EXIT WHEN C1%NOTFOUND;

          EXIT WHEN l_period_type = 'PA' and C1%ROWCOUNT = 13;

          EXIT WHEN l_period_type = 'GL' and C1%ROWCOUNT = 6;

     END LOOP;

     CLOSE C1;


     pa_fcst_global.Global_proj_fcst_start_date    := l_start_date;
     pa_fcst_global.Global_proj_fcst_end_date      := l_csr_end_date;


EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FCST_GLOBAL',
                               p_procedure_name   => 'Set_CrossProject_GlobalValue');

END Set_CrossProject_GlobalValue;

PROCEDURE Set_Project_GlobalValue(p_project_id      IN  NUMBER,
                                  p_start_period    IN  VARCHAR2,
                                  p_show_amount     IN  VARCHAR2,
                                  p_apply_prob_flag IN  VARCHAR2,
                                  p_apply_prob_per  IN  NUMBER,
                                  x_project_type_class OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_project_TM_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                )
IS

l_period_name          VARCHAR2(30);
l_start_date           DATE;
l_end_date             DATE;
l_period_type          VARCHAR2(30);
l_csr_end_date         DATE;
ll_start_date          DATE;   -- Added for bug# 3620818
ll_end_date            DATE;
l_pl_start_date        DATE;
l_pl_end_date          DATE;
l_project_type_class   VARCHAR2(30);
x_rev_gen_method       VARCHAR2(1);
x_error_msg            VARCHAR2(1);

CURSOR C1(l_period_type VARCHAR2,l_start_date DATE) IS
      -- Bug 4874283 - perf changes - remove trunc so index U2 is used
      SELECT end_date
      FROM pa_fcst_periods_tmp_v
     WHERE period_type = l_period_type
       -- AND trunc(start_date)  >= trunc(l_start_date) -- 4874283
       AND start_date  >= trunc(l_start_date) -- 4874283
       order by start_date;

l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;

BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table

  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


pa_fcst_global.Global_ProjectId                  := p_project_id;
pa_fcst_global.Global_proj_fcst_show_amt         := p_show_amount;
pa_fcst_global.Global_ProbabilityPerFlag          := p_apply_prob_flag;
pa_fcst_global.Global_ProbabilityPer              := p_apply_prob_per;
l_period_type  := pa_fcst_global.global_period_type;


 SELECT  min(start_date),    -- Added for bug# 3620818
         max(end_date)
    INTO  ll_start_date,     -- Added for bug# 3620818
          ll_end_date
    FROM  pa_project_assignments
   WHERE  project_id = p_project_id;

IF l_period_type = 'GL' THEN

	SELECT     min(p1.start_date),
                   max(p1.end_date)
        INTO       l_pl_start_date,
                   l_pl_end_date
        FROM       pa_fcst_periods_tmp_v p1,
                   pa_projects_all p2
        WHERE      p1.period_type = 'GL'
	/* Commented the AND condition and modified for bug #3620818
	AND        p1.start_date between p2.start_date and
                   NVL(p2.completion_date, ll_end_date) */
        AND        ( p1.start_date between nvl(p2.start_date, ll_start_date) and
                     NVL(p2.completion_date, ll_end_date)
                    OR
		     nvl(p2.start_date, ll_start_date) between p1.start_date and p1.end_date )
        AND        p2.project_id = p_project_id;

  ELSIF  l_period_type = 'PA' THEN

        SELECT    min(start_date),
                  max(end_date)
        INTO      l_pl_start_date,
                  l_pl_end_date
        FROM      pa_fcst_periods_tmp_v
        WHERE     period_type = 'PA'
        AND      (to_char(period_year) = to_char(sysdate,'YYYY')
                    OR  start_date between add_months(sysdate,-3) and
                                   add_months(sysdate,6));

  END IF;

pa_fcst_global.Global_pl_start_date := l_pl_start_date;
pa_fcst_global.Global_pl_end_date  := l_pl_end_date;

  	SELECT 	pr2.project_type_class_code
  	INTO   	l_project_type_class
  	FROM   	pa_projects_all pr1,
   	      	pa_project_types_all pr2
 	WHERE   pr1.project_id = p_project_id
  	 AND   	pr2.project_type = pr1.project_type
         AND    nvl(pr1.org_id,-99)=nvl(pr2.org_id,-99);

pa_fcst_global.Global_project_type_class := l_project_type_class;
x_project_type_class := l_project_type_class;

         BEGIN
                PA_RATE_PVT_PKG.get_revenue_generation_method(p_project_id=>p_project_id ,
                                        x_rev_gen_method =>x_rev_gen_method,
                                        x_error_msg      =>x_error_msg);



                IF x_rev_gen_method = 'T'  THEN
                        x_project_TM_flag :='Y';
                ELSE
                        x_project_TM_flag :='N';
                END IF;


        EXCEPTION
        WHEN OTHERS THEN
                x_project_TM_flag := 'N';
        END;

  SELECT
          Start_Date,
          End_Date
     INTO
          l_start_date,
          l_end_date
     FROM pa_fcst_periods_tmp_v
    WHERE period_name = p_start_period
      AND period_type = l_period_type;

     OPEN C1(l_period_type, l_start_date);

     LOOP

         FETCH C1
          INTO l_csr_end_date;

          EXIT WHEN C1%NOTFOUND;


          EXIT WHEN l_period_type= 'PA' and C1%ROWCOUNT = 13;


          EXIT WHEN l_period_type= 'GL' and C1%ROWCOUNT = 6;


     END LOOP;

     CLOSE C1;

     pa_fcst_global.Global_proj_fcst_start_date    := l_start_date;
     pa_fcst_global.Global_proj_fcst_end_date      := l_csr_end_date;


EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FCST_GLOBAL',
                               p_procedure_name   => 'Set_Project_GlobalValue');

END Set_Project_GlobalValue;

PROCEDURE SetPeriodSetName
IS

   -- R12 MOAC changes and bug 4874283 perf fix.
   -- See previous version for old cursor definition - I have deleted
   -- it so that it doesn't show up in grep for impact.

   CURSOR cur_period_set_name
   IS
     SELECT sob.period_set_name
       FROM gl_sets_of_books sob,
            pa_implementations_all pia
      WHERE pia.set_of_books_id = sob.set_of_books_id
        AND ((mo_global.get_current_org_id is NULL AND      -- 4874283
              mo_global.check_access(pia.org_id) = 'Y')     -- 4874283
             OR                                             -- 4874283
             (mo_global.get_current_org_id is NOT NULL AND  -- 4874283
              pia.org_id = mo_global.get_current_org_id));  -- 4874283


BEGIN
  OPEN cur_period_set_name;
  FETCH cur_period_set_name INTO pa_fcst_global.Global_Period_Set_Name;
  CLOSE cur_period_set_name;
END SetPeriodSetName;


PROCEDURE Set_Global_Project_Id(p_project_id      IN NUMBER,
                                x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data        OUT NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
                                )
IS

BEGIN

pa_fcst_global.Global_ProjectId                  := p_project_id;

END Set_Global_Project_Id;



PROCEDURE Get_Project_Info(p_project_id      IN  NUMBER,
                           x_project_name    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_project_number  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_FI_Date         OUT NOCOPY Date, --File.Sql.39 bug 4440895
                           x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                )
IS

BEGIN

 x_return_status    := FND_API.G_RET_STS_SUCCESS;

select name, segment1
into   x_project_name, x_project_number
from   pa_projects_all
where  project_id = p_project_id;

select plan_run_date
into   x_FI_Date
from   pa_budget_versions
where  project_id = p_project_id
and    budget_type_code = 'FORECASTING_BUDGET_TYPE';

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FCST_GLOBAL',
                               p_procedure_name   => 'Get_Project_Info');

END Get_Project_Info;

FUNCTION GetPeriodSetName RETURN VARCHAR2 IS
BEGIN
  RETURN( pa_fcst_global.Global_Period_Set_Name );
END GetPeriodSetName;


FUNCTION GetProjFcstShowAmount RETURN VARCHAR2 IS
BEGIN
RETURN (pa_fcst_global.global_proj_fcst_show_amt);
END GetProjFcstShowAmount;


FUNCTION GetProjectId  RETURN NUMBER IS
BEGIN
RETURN (pa_fcst_global.Global_ProjectId);
END GetProjectId;

FUNCTION GetProjFcstStartDate  RETURN DATE IS
BEGIN
RETURN (global_proj_fcst_start_date);
END GetProjFcstStartDate;

FUNCTION GetProjFcstEndDate RETURN DATE IS
BEGIN
RETURN (global_proj_fcst_end_date);
END GetProjFcstEndDate;

FUNCTION GetProbabilityPerFlag RETURN VARCHAR2 IS
BEGIN
RETURN (Global_ProbabilityPerFlag);
END GetProbabilityPerFlag;

FUNCTION GetProbabilityPer RETURN NUMBER IS
BEGIN
RETURN (Global_ProbabilityPer);
END GetProbabilityPer;

FUNCTION GetPeriodType RETURN VARCHAR2 IS
BEGIN
RETURN Global_period_type;
END GetPeriodType;


FUNCTION GetProjType            RETURN VARCHAR2
IS

BEGIN

  RETURN pa_fcst_global.Global_project_type;

END GetProjType;



FUNCTION GetProjStatusCode  RETURN VARCHAR2
IS

BEGIN

RETURN pa_fcst_global.Global_project_status;

END GetProjStatusCode;

FUNCTION GetPageFirstFlag       RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.Global_Page_First_Flag;
END GetPageFirstFlag;

FUNCTION GetProjectNumber       RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.Global_Project_Number;
END GetProjectNumber;

FUNCTION GetProjectName         RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.Global_Project_Name;
END GetProjectName;

FUNCTION GetProjectOrgId        RETURN NUMBER
IS
BEGIN
RETURN pa_fcst_global.Global_Orgnization_Id;
END GetProjectOrgId;

FUNCTION GetProjectOrgName      RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.Global_Orgnization_Name;
END GetProjectOrgName;

FUNCTION GetProjectStartDate    RETURN DATE
IS
BEGIN
RETURN pa_fcst_global.Global_Project_Start_Date;
END GetProjectStartDate;


FUNCTION GetProjectStartDateOpt RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.Global_Project_Start_Date_Opt;
END GetProjectStartDateOpt;

FUNCTION GetProjectCompDate     RETURN DATE
IS
BEGIN
RETURN pa_fcst_global.Global_Project_Comp_Date;
END GetProjectCompDate;

FUNCTION GetProjectCompDateOpt  RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.Global_Project_Comp_Date_Opt;
END GetProjectCompDateOpt;

FUNCTION GetProjectMangerName   RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.GLobal_Project_Manager_Name;
END GetProjectMangerName;

FUNCTION GetProjectMangerId     RETURN NUMBER
IS
BEGIN
RETURN pa_fcst_global.GLobal_Project_Manager_Id;
END GetProjectMangerId;

FUNCTION GetProjectCustomerName RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.GLobal_Project_Customer_Name;
END GetProjectCustomerName;

FUNCTION GetClassCatgory  RETURN VARCHAR2
IS

BEGIN

RETURN  pa_fcst_global.Global_Class_category;

END GetClassCatgory;


FUNCTION GetKeyMemberId  RETURN VARCHAR2
IS

BEGIN

RETURN  pa_fcst_global.Global_key_member_id;

END GetKeyMemberId;

FUNCTION GetPlStartDate  RETURN DATE
IS
BEGIN
RETURN pa_fcst_global.Global_pl_start_date;
END GetPlStartDate;

FUNCTION GetPlEndDate  RETURN DATE
IS
BEGIN
RETURN pa_fcst_global.Global_pl_end_date;
END GetPlEndDate;

FUNCTION GetProjectTypeClass  RETURN VARCHAR2
IS
BEGIN
RETURN pa_fcst_global.Global_project_type_class;
END GetProjectTypeClass;

FUNCTION find_project_owner(
                            p_project_id        IN NUMBER,
                            p_proj_start_date   IN  DATE,
                            p_proj_end_date     IN  DATE
                           )
RETURN VARCHAR2
IS

CURSOR csr_prj_owner IS
     SELECT resd.resource_name
       FROM pa_resources_denorm resd,
            pa_project_parties prjp
      WHERE resd.person_id = prjp.resource_source_id
        AND prjp.project_id = p_project_id
        AND prjp.project_role_id  = pa_fcst_global.GetKeyMemberId
        AND (sysdate between resd.RESOURCE_EFFECTIVE_START_DATE and resd.RESOURCE_EFFECTIVE_END_DATE
        OR  (p_proj_start_date between resd.RESOURCE_EFFECTIVE_START_DATE and resd.RESOURCE_EFFECTIVE_END_DATE
            OR p_proj_end_date between resd.RESOURCE_EFFECTIVE_START_DATE and resd.RESOURCE_EFFECTIVE_END_DATE))
        order by resd.resource_name;


l_project_owner   pa_resources_denorm.resource_name%TYPE;


BEGIN

      OPEN csr_prj_owner;

      LOOP

         FETCH csr_prj_owner
          INTO l_project_owner;

           EXIT;


      END LOOP;


     CLOSE csr_prj_owner;


   RETURN l_project_owner;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RETURN NULL;

END find_project_owner;

FUNCTION find_project_fixed_price(p_project_id IN NUMBER)  RETURN VARCHAR2 IS
   fixed_price_flag   VARCHAR2(1);
   x_rev_gen_method   VARCHAR2(1);
   x_error_msg        VARCHAR2(1);

BEGIN
	BEGIN
		PA_RATE_PVT_PKG.get_revenue_generation_method(p_project_id=>p_project_id ,
                                        x_rev_gen_method =>x_rev_gen_method,
                                        x_error_msg      =>x_error_msg);

		IF (x_rev_gen_method = 'E' OR x_rev_gen_method = 'C') THEN
			fixed_price_flag :='Y';
		ELSE
			fixed_price_flag :='N';
		END IF;

	EXCEPTION
	WHEN OTHERS THEN
		fixed_price_flag := 'N';
	END;

       RETURN (fixed_price_flag);

END find_project_fixed_price;

FUNCTION SetCrossProjectViewUser RETURN VARCHAR2 IS
        l_cross_view_user       VARCHAR2(1) :='N';
        l_resp_id               NUMBER;
        l_resp_appl_id          NUMBER;
        l_user_id               NUMBER;
        l_person_id             NUMBER;
  BEGIN

    l_user_id   := FND_GLOBAL.USER_ID;
    l_person_id := pa_utils.GetEmpIdFromUser( l_user_id );
    l_resp_id   := fnd_global.resp_id;
    l_resp_appl_id := fnd_global.resp_appl_id;

        IF fnd_profile.value_specific('PA_SUPER_PROJECT',l_user_id,
					 l_resp_id, l_resp_appl_id) = 'Y' THEN
                l_cross_view_user := 'Y';
        ELSE
                l_cross_view_user := 'N';
        END IF;

	IF l_cross_view_user = 'N' THEN

		IF fnd_profile.value_specific('PA_SUPER_PROJECT_VIEW',l_user_id,
						 l_resp_id, l_resp_appl_id) = 'Y' THEN
                	l_cross_view_user := 'Y';
		END IF;
	END IF;

      RETURN l_cross_view_user;

END SetCrossProjectViewUser;

FUNCTION IsCrossProjectViewUser RETURN VARCHAR2 IS
   BEGIN
   RETURN (Global_CrossProjectViewUser);
END IsCrossProjectViewUser;

Procedure Populate_Fcst_Periods IS

	l_period_type  VARCHAR2(2):= FND_PROFILE.VALUE('PA_FORECASTING_PERIOD_TYPE');

 BEGIN
	BEGIN
		DELETE pa_fcst_periods_tmp;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			raise;

	END;

    IF  l_period_type ='GL' THEN
	INSERT INTO pa_fcst_periods_tmp
           (PERIOD_NAME,
	    START_DATE,
	     END_DATE)
        SELECT distinct
          glper.period_name,
          glper.start_date,
          glper.end_date
         FROM  pa_implementations imp,
               gl_sets_of_books gl,
               gl_periods glper,
               gl_period_statuses glpersts,
               gl_lookups prsts,
               gl_date_period_map glmaps
        WHERE imp.set_of_books_id         = gl.set_of_books_id
          AND  gl.period_set_name          = glper.period_set_name
          AND  gl.accounted_period_type    = glper.period_type
          AND  glpersts.set_of_books_id    = gl.set_of_books_id
          AND  glpersts.period_type        = glper.period_type
          AND  glpersts.period_name        = glper.period_name
          AND  glpersts.period_year        = glper.period_year
          AND  glpersts.closing_status     = prsts.lookup_code
          AND  glmaps.period_type          = glper.period_type
          AND  glmaps.period_name          = glper.period_name
          AND  glmaps.period_set_name      = glper.period_set_name
          AND  glpersts.application_id     = Pa_Period_Process_Pkg.Application_Id
          AND  prsts.lookup_code IN('C','F','N','O','P')
          AND  prsts.lookup_type ='CLOSING_STATUS';
    ELSIF l_period_type ='PA' THEN
        -- R12 MOAC changes and bug 4874283 perf fix.
        -- See previous version for old insert statement - I have deleted
        -- it so that it doesn't show up in grep for impact.

        INSERT INTO pa_fcst_periods_tmp
              (PERIOD_NAME,
               START_DATE,
               END_DATE)
        SELECT PER.PERIOD_NAME,
               PER.START_DATE,
               PER.END_DATE
          FROM PA_PERIODS_ALL PER
         WHERE ((mo_global.get_current_org_id is NULL AND       -- 4874283
                 mo_global.check_access(per.org_id) = 'Y')      -- 4874283
                OR                                              -- 4874283
                (mo_global.get_current_org_id is NOT NULL AND   -- 4874283
                 per.org_id = mo_global.get_current_org_id));   -- 4874283
    END IF;
  END Populate_Fcst_Periods;
 BEGIN
	Global_CrossProjectViewUser := SetCrossProjectViewUser;
END pa_fcst_global;

/
