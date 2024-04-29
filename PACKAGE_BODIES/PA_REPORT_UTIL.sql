--------------------------------------------------------
--  DDL for Package Body PA_REPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REPORT_UTIL" AS
        /* $Header: PARFRULB.pls 120.1 2005/07/04 06:57:50 appldev ship $   */

------------------------------------------------------------------------------------------------------------------
-- This procedure will populate the values for screen U1 ,and U2
-- Input parameters
-- Parameters                   Type           Required  Description
--
-- Out parameters
-- x_org_id                     NUMBER            YES       It store the org id
-- x_def_period_typ             VARCHAR2          YES       It store the default period type
-- x_def_period_yr              VARCHAR2          YES       It store the default period year
-- x_def_period_name            VARCHAR2          YES       It store the default period name
-- x_def_period_per             VARCHAR2          YES       It store the default period percentage
-- x_billing_installed          VARCHAR2          YES       It store billing installed check
-- x_prm_installed              VARCHAR2          YES       It store prm installed check
--
--------------------------------------------------------------------------------------------------------------------
PROCEDURE get_default_val(
                          p_calling_screen  		IN      VARCHAR2,
                          x_org_id             		OUT NOCOPY     NUMBER,
                          x_org_name           		OUT NOCOPY     VARCHAR2,
                          x_def_period_typ     		OUT NOCOPY     VARCHAR2,
                          x_def_period_typ_desc 	OUT NOCOPY     VARCHAR2,
                          x_def_period_yr      		OUT NOCOPY     VARCHAR2,
                          x_def_period_name    		OUT NOCOPY     VARCHAR2,
                          x_def_period_name_desc    	OUT NOCOPY     VARCHAR2,
                          x_def_show_percentages_by     OUT NOCOPY     VARCHAR2,
                          x_billing_installed  		OUT NOCOPY     VARCHAR2,
                          x_prm_installed      		OUT NOCOPY     VARCHAR2,
                          x_login_person_name  		OUT NOCOPY     VARCHAR2,
                          x_login_person_id  		OUT NOCOPY     NUMBER,
                          x_return_status      		OUT NOCOPY     VARCHAR2,
                          x_msg_count          		OUT NOCOPY     NUMBER,
                          x_msg_data           		OUT NOCOPY     VARCHAR2)

 IS
   l_prd_name        	gl_periods.period_name%TYPE;
   l_quarter_num      	gl_periods.quarter_num%TYPE;
   l_prd_yr          	gl_periods.period_year%TYPE;
   l_meaning            gl_lookups.meaning%TYPE;
   l_name_desc          VARCHAR2(120);

  l_period_type      	gl_periods.period_type%TYPE;
  l_week_ending_date 	DATE;
  l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;
  l_msg_index_out       INTEGER:=1;
  l_forecast_thru_date	DATE;
  l_default_date	      DATE			  := trunc(SYSDATE);
  l_date_format        VARCHAR2(100); -- Added for Bug 2387429  and 2091182
  /* NPE Changes Begin*/
  l_def_show_percentages_by    varchar2(240);
  l_global_week_start_day      varchar2(240);
  l_user_profile_option_name1  varchar2(1000);
  l_user_profile_option_name2  varchar2(1000);
  l_user_profile_option_name3  varchar2(1000);
  l_user_profile_option_name4  varchar2(1000);
  l_msg_count       NUMBER := 0;
  l_data            VARCHAR2(2000);
  l_msg_data        VARCHAR2(2000);
  l_return_status   VARCHAR2(2000);
  l_err_msg         VARCHAR2(3000);
 /* NPE Changes End */

  dummy char ; -- Added for bug2440313


 BEGIN
  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

 /* Bug2440313 Begin */
  BEGIN
    select 'x' into dummy
    from pa_implementations;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_INCORRECT_MO_OPERATING_UNIT');

         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 then
            IF l_msg_count = 1 then
               PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

                  x_msg_data := l_data;
                  x_msg_count := l_msg_count;
             ELSE
                  x_msg_count := l_msg_count;
             END IF;
         pa_debug.reset_err_stack;
         return;
         END IF;
  END;
 /* Bug2440313 End */

 IF (p_calling_screen = 'U1') THEN
  -- Populate org id
  BEGIN
     SELECT parent_organization_id,parent_org_name
     INTO x_org_id,x_org_name
     FROM ( SELECT DISTINCT parent_organization_id,parent_org_name
            FROM pa_rep_org_util_v
            ORDER BY parent_org_name )
     WHERE ROWNUM = 1;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     /* NPE Suggestion - Ideally here we should give message that the user does not have
        the organization authorities on any organizations for the current Operatin Unit.
        Note that no need to "return" here after populating the message, as further other
        profile options are being checked that whether they have been populated or not*/

      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_ORG_NAME');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_ORG_NAME';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
  END;
 END IF;


  -- Populating Billing product is installed
   x_billing_installed := PA_INSTALL.is_costing_licensed;

  -- Populating Prm product is installed
   x_prm_installed := PA_INSTALL.is_prm_licensed;

 IF FND_GLOBAL.USER_ID IS NOT NULL THEN
  -- Populating person id person name
   BEGIN
    SELECT rsd.resource_name,rsd.person_id
    INTO x_login_person_name,x_login_person_id
    FROM pa_resources_denorm rsd, fnd_user usr
    WHERE rsd.person_id = usr.employee_id
    AND usr.user_id = fnd_global.user_id
    AND rsd.resource_effective_end_date >= sysdate
    AND rownum < 2
    ;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
   NULL;
   WHEN OTHERS THEN
   NULL;
  END;
 END IF;


  -- Populating default period type using profile options
   l_period_type    := FND_PROFILE.VALUE('PA_ORG_UTIL_DEF_PERIOD_TYPE');

   /* NPE Changes Begin */
    -- Populating default period percentage using profile options
    l_def_show_percentages_by := FND_PROFILE.VALUE('PA_ORG_UTIL_DEF_CALC_METHOD');

    l_global_week_start_day :=  FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY');

     SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name1
     FROM fnd_profile_options_tl
     WHERE profile_option_name='PA_ORG_UTIL_DEF_CALC_METHOD'
     AND language=userenv('LANG');

     SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name2
     FROM fnd_profile_options_tl
     WHERE profile_option_name='PA_ORG_UTIL_DEF_PERIOD_TYPE'
     AND language=userenv('LANG');

     SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name3
     FROM fnd_profile_options_tl
     WHERE profile_option_name='PA_GLOBAL_WEEK_START_DAY'
     AND language=userenv('LANG');


     IF l_period_type is NULL AND l_def_show_percentages_by is NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_err_msg := l_user_profile_option_name1;
         l_err_msg:=l_err_msg||', '||l_user_profile_option_name2;
     ELSIF l_period_type is NULL AND  l_def_show_percentages_by is NOT NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_err_msg:=l_user_profile_option_name2;
     ELSIF l_period_type is NOT NULL AND  l_def_show_percentages_by is NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_err_msg:=l_user_profile_option_name1;
         IF l_period_type = 'GE' AND l_global_week_start_day IS NULL THEN
             l_err_msg:=l_err_msg||', '||l_user_profile_option_name3;
         END IF;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_ERROR and l_err_msg is not null THEN
           PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    =>  'PROFILES',
                            p_value1    =>  l_err_msg);

           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count > 0 then
              IF l_msg_count = 1 then
                 PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);

                    x_msg_data := l_data;
                    x_msg_count := l_msg_count;
              ELSE
                    x_msg_count := l_msg_count;
              END IF;
           END IF;
     END IF;

     /*NPE changes ends */

   -- Fetching the default forecast thru date information from utilization options
   BEGIN
     select forecast_thru_date
     into l_forecast_thru_date
     from pa_utilization_options  ut ;

    /*Bug2440313 -- Commented this, the check for pa_implementaions is being done
                above in the code
     ,pa_implementations  imp  --NPE changes
     where  nvl(ut.org_id, -99) = nvl(imp.org_id,-99);   --NPE changes
    */

     IF (l_forecast_thru_date > sysdate
         OR l_forecast_thru_date is NULL) then
        l_default_date := sysdate;
     ELSE
  	    l_default_date := l_forecast_thru_date;
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN

	/* NPE Changes Begins */
        /* l_default_date := sysdate;  -- Commented this code */
        /* Bug2440313 Begin -- Undone the check for MO: Operating Unit here. The  Operating Unit check
	   is now done above in this code. Here we do check for utilization options defined or not */

	 x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_UNDEFINED_UTIL_OPTIONS');

         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 then
            IF l_msg_count = 1 then
               PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

                  x_msg_data := l_data;
                  x_msg_count := l_msg_count;
             ELSE
                  x_msg_count := l_msg_count;
             END IF;
         END IF;
        /* Bug2440313 End */
   END;

   -- Collectively check for x_return_status, if error then return
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           pa_debug.reset_err_stack;
           return;
   END IF;

   l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);
   x_def_show_percentages_by := l_def_show_percentages_by;

   /*NPE changes ends */

   PA_REP_UTIL_GLOB.SETU1SHOWPRCTGBY (x_def_show_percentages_by);

   l_default_date := trunc(l_default_date);

   --  Populating default period year taking from forecast thru date or sysdate
   x_def_period_yr := TO_CHAR(l_default_date,'YYYY');

   x_def_period_typ := l_period_type;

   -- Populating period desc
   SELECT meaning
   INTO x_def_period_typ_desc
   FROM pa_lookups
   WHERE lookup_type = 'PA_REP_PERIOD_TYPES'
   AND   lookup_code = l_period_type;


   -- Populating default period name
   IF ( l_period_type = 'PA') THEN
      BEGIN  -- NPE Changes
	    SELECT paperiod.period_name,
	    paperiod.period_year,
	    paperiod.status_meaning
	    INTO l_prd_name,l_prd_yr,l_meaning
	    FROM   pa_periods_v paperiod,
		   pa_implementations imp,
		   gl_period_statuses glpersts
	    WHERE  glpersts.period_type       = imp.pa_period_type
	    AND  imp.set_of_books_id        = paperiod.set_of_books_id
	    AND  glpersts.set_of_books_id   = imp.set_of_books_id
	    AND  glpersts.period_name       = paperiod.period_name
	    AND  glpersts.period_year       = paperiod.period_year
	    AND  glpersts.application_id    = 275
	    AND l_default_date BETWEEN paperiod.pa_start_date AND paperiod.pa_end_date
   	    AND ROWNUM=1
           ORDER BY paperiod.period_year;

         -- Populating default period name,period desc, and default period year
         x_def_period_name         :=  l_prd_name;
         x_def_period_yr           :=  l_prd_yr;
         x_def_period_name_desc    :=  l_prd_name||'  '||l_meaning;

     /*NPE changes Begins */
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_PRD_NOT_DEFINED_FOR_DATE',
                            p_token1    => 'PA_DATE',
                            p_value1    =>  to_char(l_default_date,l_date_format));
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 then
               IF l_msg_count = 1 then
                  PA_INTERFACE_UTILS_PUB.get_messages
                      (p_encoded        => FND_API.G_TRUE,
                       p_msg_index      => 1,
                       p_msg_count      => l_msg_count,
		       p_msg_data       => l_msg_data,
                       p_data           => l_data,
                       p_msg_index_out  => l_msg_index_out);

                       x_msg_data := l_data;
                       x_msg_count := l_msg_count;
               ELSE
                       x_msg_count := l_msg_count;
               END IF;
               pa_debug.reset_err_stack;
               return;
            END IF;
      END;
     /*NPE changes Ends */
   ELSIF( l_period_type = 'GL') THEN
      BEGIN -- NPE Changes

	     SELECT glper.period_name,glper.period_year,gllkups.meaning
	     INTO l_prd_name,l_prd_yr,l_meaning
	     FROM pa_implementations imp,
	     gl_sets_of_books gl,
	     gl_periods glper,
	     gl_period_statuses glst,
	     gl_lookups gllkups
	     WHERE  imp.set_of_books_id    = gl.set_of_books_id
	     AND gl.period_set_name        = glper.period_set_name
	     AND gl.accounted_period_type  = glper.period_type
	     AND glper.period_name   = glst.period_name
	     AND glper.period_type   = glst.period_type
	     AND glst.set_of_books_id=imp.set_of_books_id
	     AND glst.application_id = PA_Period_Process_PKG.Application_ID
	     AND gllkups.lookup_code = glst.closing_status
	     AND gllkups.lookup_type = 'CLOSING_STATUS'
	     /* Bug 2288460 - Start        */
	     /* Added the following clause */
	     AND glper.adjustment_period_flag = 'N'
	     /* Bug 2288460 - End          */
	     AND l_default_date BETWEEN glper.start_date AND glper.end_date
	     AND ROWNUM=1
	     ORDER BY glper.period_year;

	     -- Populating default period name,period desc, and default period year
	     x_def_period_name         :=  l_prd_name;
	     x_def_period_yr           :=  l_prd_yr;
	     x_def_period_name_desc    :=  l_prd_name||'  '||l_meaning;

      /*NPE changes starts */
      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
		 PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_GL_PRD_NOT_DEFINED_FOR_DATE',
                            p_token1    => 'GL_DATE',
                            p_value1    =>  to_char(l_default_date,l_date_format));
                l_msg_count := FND_MSG_PUB.count_msg;
                IF l_msg_count > 0 then
                    IF l_msg_count = 1 then
                         PA_INTERFACE_UTILS_PUB.get_messages
				  (p_encoded        => FND_API.G_TRUE,
			           p_msg_index      => 1,
				   p_msg_count      => l_msg_count,
		 		   p_msg_data       => l_msg_data,
		                   p_data           => l_data,
		                   p_msg_index_out  => l_msg_index_out);

			  x_msg_data := l_data;
                          x_msg_count := l_msg_count;
                    ELSE
                          x_msg_count := l_msg_count;
                    END IF;
                    pa_debug.reset_err_stack;
                    return;
                END IF;
       END;
      /*NPE changes Ends */
   ELSIF ( l_period_type = 'GE') THEN
     /* NPE Changes Begins */
     IF l_global_week_start_day IS NULL THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
   	   PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    =>  'PROFILES',
                            p_value1    =>  l_user_profile_option_name3);

            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 then
                 IF l_msg_count = 1 then
                       PA_INTERFACE_UTILS_PUB.get_messages
		         (p_encoded        => FND_API.G_TRUE,
			  p_msg_index      => 1,
	                  p_msg_count      => l_msg_count,
	                  p_msg_data       => l_msg_data,
	                  p_data           => l_data,
	                  p_msg_index_out  => l_msg_index_out);

		          x_msg_data := l_data;
			  x_msg_count := l_msg_count;
	         ELSE
                          x_msg_count := l_msg_count;
                 END IF;
                 pa_debug.reset_err_stack;
                 return;
            END IF;
       END IF;
    /*  NPE Changes Ends */

     -- Populating period name
/** Fix for bug 2387429  and 2091182 starts here **/
     /* -- NPE Changes, it is shifted to above in the code  l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT); */

     SELECT
     TO_CHAR(NEXT_DAY(l_default_date, NVL(TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY')),0))  -1,l_date_format)
     INTO x_def_period_name
     FROM sys.dual;
/*
SELECT
	TO_CHAR( NEXT_DAY(l_default_date, NVL( TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY')),0)) -1,        'DD-MON-YYYY')
	INTO x_def_period_name
	FROM sys.dual;
*/
/** Bug 2387429  and 2091182 Code Fix Ends **/
    x_def_period_name_desc := NULL;
   ELSIF ( l_period_type = 'YR') THEN
     --  Populating default period year taking from sysdate

     x_def_period_yr        := TO_CHAR(SYSDATE,'YYYY');
     x_def_period_name      := NULL;
     x_def_period_name_desc := NULL;
   ELSIF ( l_period_type = 'QR') THEN
     SELECT glper.quarter_num
     INTO l_quarter_num
     FROM pa_implementations imp,
     gl_sets_of_books gl,
     gl_periods glper,
     gl_period_statuses glst
     WHERE  imp.set_of_books_id    = gl.set_of_books_id
     AND gl.period_set_name        = glper.period_set_name
     AND gl.accounted_period_type  = glper.period_type
     AND glper.period_name   = glst.period_name
     AND glper.period_type   = glst.period_type
     AND glst.set_of_books_id=imp.set_of_books_id
     AND glst.application_id = PA_Period_Process_PKG.Application_ID
     /* Bug 2288460 - Start        */
     /* Added the following clause */
     AND glper.adjustment_period_flag = 'N'
     /* Bug 2288460 - End          */
     AND l_default_date BETWEEN glper.start_date AND glper.end_date
	 AND ROWNUM=1
     ORDER BY glper.period_year;
     -- Populating default period name and default period year
     l_prd_name             :=  TO_CHAR(l_quarter_num);
     x_def_period_name      :=  l_prd_name;
     x_def_period_name_desc :=  x_def_period_typ_desc||'  '||l_prd_name;
   END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      -- dbms_output.put_line(SQLERRM);
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REPORT_UTIL',
                               p_procedure_name   => 'get_default_val');
 END get_default_val;


------------------------------------------------------------------------------------------------------------------
-- This procedure will validate the passed values for screen U1
-- Input parameters
-- Parameters                   Type           Required    Description
-- p_org_mgr_id                 NUMBER            YES       It is having the manager org id
-- p_period_typ                 VARCHAR2          YES       It store the period type
-- p_select_yr                  VARCHAR2          YES       It store the period year
-- p_period_name                VARCHAR2          YES       It store the period name
-- Out parameters
--
--------------------------------------------------------------------------------------------------------------------

PROCEDURE validate_u1    (p_org_name           IN      VARCHAR2,
                          p_period_type_desc   IN      VARCHAR2,
                          p_select_yr          IN      NUMBER,
                          p_period_name        IN      VARCHAR2,
                          p_calling_mode       IN      VARCHAR2,
                          p_showprctgby        IN      VARCHAR2,
                          x_org_id             OUT NOCOPY     NUMBER,
                          x_period_type        OUT NOCOPY     VARCHAR2,
                          x_period_name        OUT NOCOPY     VARCHAR2,
                          x_return_status      OUT NOCOPY     VARCHAR2,
                          x_msg_count          OUT NOCOPY     NUMBER,
                          x_msg_data           OUT NOCOPY     VARCHAR2)

 IS
  l_invalid_value       EXCEPTION;
  l_exist               VARCHAR2(1) := 'N';
  l_period_type         pa_rep_period_types_v.period_type%TYPE;
  l_period_year         pa_rep_periods_v.period_year%TYPE;
  l_msg_index_out       INTEGER:=1;
  l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;
 BEGIN
  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  PA_REP_UTIL_GLOB.update_util_cache; -- Bug 2447797 added this call
  -- Validate org name
  BEGIN
   x_org_id  := NULL;
   IF (p_calling_mode = 'ORG') THEN
     SELECT distinct parent_organization_id
     INTO x_org_id
     FROM pa_rep_org_util_v
     WHERE parent_org_name = p_org_name;
   END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_ORG_NAME');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_ORG_NAME';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
   END;


   -- Validating  period type
   BEGIN
     SELECT period_type
     INTO l_period_type
     FROM pa_rep_period_types_v
     WHERE period_type_desc = p_period_type_desc;

     x_period_type := l_period_type;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_TYPE';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
   END;

 IF (l_period_type = 'YR') THEN
   -- Validating  select year
   BEGIN
       SELECT period_year
       INTO l_period_year
       FROM pa_rep_period_years_v
       WHERE period_type = l_period_type
       AND   period_year = p_select_yr
       AND   ROWNUM      = 1;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_YEAR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_YEAR';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
     END;
  ELSE
   -- Validating  select year
   BEGIN
       SELECT period_year
       INTO l_period_year
       FROM pa_rep_periods_v
       WHERE period_type = l_period_type
       AND   period_year = p_select_yr
       AND   ROWNUM      = 1;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_YEAR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_YEAR';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
   END;
  END IF;


   -- Validating  period name
   BEGIN
     IF (l_period_type = 'PA' OR l_period_type = 'GL' OR l_period_type = 'GE') THEN
       SELECT period_name
       INTO x_period_name
       FROM pa_rep_periods_v
       WHERE period_type = l_period_type
       AND ( period_name      = p_period_name
       OR    period_name||'  '||period_status = p_period_name)
       AND   period_year      = p_select_yr;
     ELSIF (l_period_type = 'QR') THEN
       SELECT TO_CHAR(mon_or_qtr)
       INTO x_period_name
       FROM pa_rep_periods_v
       WHERE period_type = l_period_type
       AND ( period_name      = p_period_name
       OR    period_name||'  '||period_status = p_period_name)
       AND   period_year      = p_select_yr;
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_NAME');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_NAME';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;

   END;

   --Calling set u1 show percentage API
    PA_REP_UTIL_GLOB.setu1showprctgby(p_showprctgby);

  EXCEPTION
    WHEN l_invalid_value THEN
      NULL;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REPORT_UTIL',
                               p_procedure_name   => 'validate_u1');
 END validate_u1;


------------------------------------------------------------------------------------------------------------------
-- This procedure will validate the passed values for screen U2
-- Input parameters
-- Parameters                   Type           Required    Description
-- p_mgr_name                   VARCHAR2          YES       It is having the manager name
-- p_org_id                     NUMBER            YES       It is having the org id
-- p_assignment_sts             VARCHAR2          YES       It store the assignment status
-- p_period_yr                  VARCHAR2          YES       It store the period year
-- p_period_typ                 VARCHAR2          YES       It store the period type
-- p_util_category              VARCHAR2          YES       It store the util category
-- Out parameters
--
--------------------------------------------------------------------------------------------------------------------
PROCEDURE validate_u2    (p_mgr_name           IN      VARCHAR ,
                          p_org_name           IN      VARCHAR2,
                          p_org_id             IN      NUMBER,
                          p_mgr_id             IN      NUMBER,
                          p_assignment_sts     IN      VARCHAR2,
                          p_period_year        IN      NUMBER,
                          p_period_type_desc   IN      VARCHAR2,
                          p_period_name        IN      VARCHAR2,
                          p_util_category      IN      NUMBER,
                          p_Show_Percentage_By IN      VARCHAR2,
                          p_Utilization_Method IN      VARCHAR2,
                          p_calling_mode       IN      VARCHAR2,
                          x_return_status      OUT NOCOPY     VARCHAR2,
                          x_msg_count          OUT NOCOPY     NUMBER,
                          x_msg_data           OUT NOCOPY     VARCHAR2)
 IS
  l_invalid_value       EXCEPTION;
  l_exist               VARCHAR2(1) := 'N';
  l_period_type         pa_rep_period_types_v.period_type_desc%type;
  l_period_name         pa_rep_periods_v.period_name%TYPE;
  l_org_id              pa_rep_util_res_orgs_v.organization_id%TYPE;
  l_mgr_id              pa_rep_util_mgr_org_v.manager_id%TYPE;
  l_orgz_id             pa_rep_util_res_orgs_v.organization_id%TYPE;
  l_mgnr_id             pa_rep_util_res_orgs_v.organization_id%TYPE;
  l_prd_quarter         pa_rep_periods_v.mon_or_qtr%type;
  l_glb_wek_dt          pa_rep_periods_v.ge_week_dt%type;
  l_period_year         pa_rep_periods_v.period_year%TYPE;
  l_msg_index_out       INTEGER:=1;
  l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;
  l_calling_mode        VARCHAR2(15);

 BEGIN
  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  PA_REP_UTIL_GLOB.update_util_cache; -- Bug 2447797 added this call

  -- Check mgr name or org name is valid or not
/*  BEGIN
    IF (p_calling_mode = 'RESMGR') THEN
       SELECT organization_id
       INTO l_org_id
       FROM pa_rep_util_res_orgs_v
       WHERE organization_name = p_org_name;
       l_orgz_id   := l_org_id;
       l_mgnr_id   := p_mgr_id;
    ELSIF (p_calling_mode = 'ORGMGR') THEN
       SELECT manager_id
       INTO l_mgr_id
       FROM pa_rep_util_mgr_org_v
       WHERE manager_name = p_mgr_name;
       l_orgz_id   := p_org_id;
       l_mgnr_id   := l_mgr_id;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    l_text := 'ORGNIZATION';
    RAISE l_invalid_value;
  END;   */

       l_orgz_id   := p_org_id;
       l_mgnr_id   := p_mgr_id;
  -- Validating  period type
  BEGIN
      SELECT PERIOD_TYPE
      INTO l_period_type
      FROM pa_rep_period_types_v
      WHERE period_type_desc = p_period_type_desc;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_TYPE';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
  END;

--  dbms_output.put_line('prd yer '||p_period_year);
--  dbms_output.put_line('prd typ '||l_period_type);
--  dbms_output.put_line('prd nam '||p_period_name);

 IF ( l_period_type = 'YR' ) THEN
  -- Validating  period year
  BEGIN
     SELECT period_year
     INTO l_period_year
     FROM pa_rep_period_years_v
     WHERE period_type = l_period_type
     AND   period_year = p_period_year
     AND   ROWNUM      =1;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_YEAR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_YEAR';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
  END;
 ELSE
  -- Validating  period year
  BEGIN
     SELECT period_year
     INTO l_period_year
     FROM pa_rep_periods_v
     WHERE period_type = l_period_type
     AND   period_year = p_period_year
     AND   ROWNUM      =1;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_YEAR');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_YEAR';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
  END;
 END IF;

 IF ( l_period_type <> 'YR') THEN
  -- Validating  period name
  BEGIN
     SELECT period_name
     INTO l_period_name
     FROM pa_rep_periods_v
     WHERE period_type = l_period_type
     AND ( period_name = p_period_name
     OR    period_name||'  '||period_status = p_period_name)
     AND   period_year = p_period_year;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
      PA_UTILS.Add_Message( 'PA', 'PA_UTIL_INVALID_PRD_NAME');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_UTIL_INVALID_PRD_NAME';
      x_msg_count     := 1;
      IF x_msg_count = 1 THEN
       PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => x_msg_data,
          p_msg_index_out  => l_msg_index_out );
      END IF;
      RAISE l_invalid_value;
  END;
 END IF;

  -- Calling Temporary table population API

   IF (l_period_type = 'QR') THEN
     SELECT MON_OR_QTR
     INTO l_prd_quarter
     FROM pa_rep_periods_v
     WHERE period_type = l_period_type
     AND ( period_name = p_period_name
     OR    period_name||'  '||period_status = p_period_name)
     AND   period_year = p_period_year;
  ELSE
    l_prd_quarter := 0;
  END IF;

  IF (l_period_type = 'GE') THEN
    SELECT ge_week_dt
    INTO l_glb_wek_dt
    FROM  pa_rep_periods_v
    WHERE period_type = l_period_type
    AND ( period_name = p_period_name
    OR    period_name||'  '||period_status = p_period_name)
    AND   period_year = p_period_year;
 ELSE
   l_glb_wek_dt := TO_DATE('10/09/1492','MM/DD/YYYY');
 END IF;


l_calling_mode     := p_calling_mode;

/*  */PA_REP_UTIL_SCREEN.poplt_screen_tmp_table(
            p_Organization_ID           => l_orgz_id
            , p_Manager_ID              => l_mgnr_id
            , p_Period_Type             => l_period_type
            , p_Period_Year             => p_period_year
            , p_Period_Quarter          => l_prd_quarter
            , p_Period_Name             => l_period_name
            , p_Global_Week_End_Date    => l_glb_wek_dt
            , p_Assignment_Status       => NVL(p_assignment_sts,'ALL')
            , p_Show_Percentage_By      => p_Show_Percentage_By
            , p_Utilization_Method      => p_Utilization_Method
            , p_Utilization_Category_Id => NVL(p_util_category,0)
            , p_calling_mode            => l_calling_mode);



  EXCEPTION
    WHEN l_invalid_value THEN
      NULL;
   --    dbms_output.put_line(' Invalid value '||l_text||' '||l_text1);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SUBSTR(SQLERRM,1,240);
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REPORT_UTIL',
                               p_procedure_name   => 'validate_u2');
 END validate_u2;


------------------------------------------------------------------------------------------------------------------
-- This procedure will populate U3 screen
-- Input parameters
-- Parameters                   Type           Required    Description
-- Out parameters
--
----------------------------------------------------------------------------------------------------------
PROCEDURE get_default_period_val(
			  x_def_period	       OUT NOCOPY     VARCHAR2,
                          x_def_period_typ     IN OUT NOCOPY     VARCHAR2,
                          x_def_period_yr      IN OUT NOCOPY     VARCHAR2,
                          x_def_period_name    IN OUT NOCOPY     VARCHAR2,
			  x_def_period_sts_code OUT NOCOPY    VARCHAR2,
			  x_def_period_sts     OUT NOCOPY     VARCHAR2,
			  x_def_mon_or_qtr     OUT NOCOPY     VARCHAR2,
			  x_def_period_num     OUT NOCOPY     VARCHAR2,
                          x_return_status      OUT NOCOPY     VARCHAR2,
                          x_msg_count          OUT NOCOPY     NUMBER,
                          x_msg_data           OUT NOCOPY     VARCHAR2) IS

/*  CURSOR C1 IS SELECT glper.period_name,glper.period_year,glst.closing_status,glper.quarter_num,glst.effective_period_num
               FROM pa_implementations imp,
                    gl_sets_of_books gl,
                    gl_periods glper,
                    gl_period_statuses glst
               WHERE  imp.set_of_books_id     = gl.set_of_books_id
               AND gl.period_set_name  = glper.period_set_name
               AND imp.pa_period_type  = glper.period_type
               AND glper.period_name   = glst.period_name
               AND glper.period_type   = glst.period_type
               AND glst.set_of_books_id=imp.set_of_books_id
               AND glst.closing_status ='O'
               AND glst.application_id = 275
               ORDER BY glper.period_year;*/

    CURSOR C1 IS SELECT
                paperiod.period_name,
		paperiod.period_year,
		paperiod.status,
                paperiod.quarter_num,
                glpersts.effective_period_num,
                paperiod.status_meaning
         FROM   pa_periods_v paperiod,
                pa_implementations imp,
                gl_period_statuses glpersts
        WHERE  glpersts.period_type       = imp.pa_period_type
          AND  imp.set_of_books_id        = paperiod.set_of_books_id
          AND  glpersts.set_of_books_id   = imp.set_of_books_id
          AND  glpersts.period_name       = paperiod.period_name
          AND  glpersts.period_year       = paperiod.period_year
          AND  glpersts.application_id    = 275
	  AND  paperiod.status            = 'O'
     ORDER BY  paperiod.period_year;


  CURSOR C2 IS SELECT glper.period_name
                      ,glper.period_year
                      ,glst.closing_status
                      ,glper.quarter_num
                      ,glst.effective_period_num
                      ,gllkups.meaning
               FROM pa_implementations imp,
                    gl_sets_of_books gl,
                    gl_periods glper,
                    gl_period_statuses glst,
                    gl_lookups gllkups
               WHERE  imp.set_of_books_id    = gl.set_of_books_id
               AND gl.period_set_name        = glper.period_set_name
               AND gl.accounted_period_type  = glper.period_type
               AND glper.period_name   = glst.period_name
               AND glper.period_type   = glst.period_type
               AND glst.set_of_books_id=imp.set_of_books_id
               AND glst.closing_status ='O'
               AND glst.application_id = PA_Period_Process_PKG.Application_ID
               AND gllkups.lookup_code = glst.closing_status
               AND gllkups.lookup_type = 'CLOSING_STATUS'
               ORDER BY glper.period_year;

/*  CURSOR C4(p_sts in varchar2) IS
	       SELECT meaning, lookup_code
	       FROM   gl_lookups
	       WHERE  lookup_type = 'CLOSING_STATUS'
	       ANd    lookup_code = p_sts;*/

   l_default_date		DATE			  := SYSDATE;
   l_forecast_thru_date DATE;

   l_prd_name        	gl_periods.period_name%TYPE;
   l_prd_yr          	gl_periods.period_year%TYPE;
   l_sts             	gl_period_statuses.closing_status%TYPE;
   l_mon_qtr		gl_periods.quarter_num%TYPE;

   l_mon		NUMBER;

   l_period_type      	gl_periods.period_type%TYPE;
   l_week_ending_date 	DATE;

   l_period_num 	gl_period_statuses.effective_period_num%TYPE;
   l_sts_meaning        gl_lookups.meaning%TYPE;
   l_use_default_logic  VARCHAR2(1) := 'Y';
   l_date_format        VARCHAR2(100); -- Added for Bug 2091182 and 2387429
  /* NPE Changes Begin*/
  l_def_show_percentages_by    varchar2(240);
  l_global_week_start_day      varchar2(240);
  l_user_profile_option_name1  varchar2(1000);
  l_user_profile_option_name2  varchar2(1000);
  l_user_profile_option_name3  varchar2(1000);
  l_msg_count       NUMBER := 0;
  l_data            VARCHAR2(2000);
  l_msg_data        VARCHAR2(2000);
  l_msg_index_out   NUMBER;
  l_return_status   VARCHAR2(2000);
  l_init_msg_list       VARCHAR2(20)        := FND_API.G_TRUE;
  l_err_msg         VARCHAR2(3000);
 /* NPE Changes End */

  dummy char ; -- Added for bug2440313
 BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  /* NPE Changes Begins - The following initialize is added,
     otherwise it will show same message again and give misleading information */

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  /* NPE Changes Ends */

 /* Bug2440313 Begin */
  BEGIN
    select 'x' into dummy
    from pa_implementations;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_INCORRECT_MO_OPERATING_UNIT');

         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 then
            IF l_msg_count = 1 then
               PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

                  x_msg_data := l_data;
                  x_msg_count := l_msg_count;
             ELSE
                  x_msg_count := l_msg_count;
             END IF;
         pa_debug.reset_err_stack;
         return;
         END IF;
  END;
 /* Bug2440313 End */

   -- Populating default period type using profile options
   l_period_type    := FND_PROFILE.VALUE_SPECIFIC('PA_RES_UTIL_DEF_PERIOD_TYPE');

   /* NPE Changes Begins */

     l_def_show_percentages_by := FND_PROFILE.VALUE('PA_RES_UTIL_DEF_CALC_METHOD');
     l_global_week_start_day :=  FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY');

     SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name1
     FROM fnd_profile_options_tl
     WHERE profile_option_name='PA_RES_UTIL_DEF_CALC_METHOD'
     AND language=userenv('LANG');

     SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name2
     FROM fnd_profile_options_tl
     WHERE profile_option_name='PA_RES_UTIL_DEF_PERIOD_TYPE'
     AND language=userenv('LANG');

     SELECT USER_PROFILE_OPTION_NAME INTO l_user_profile_option_name3
     FROM fnd_profile_options_tl
     WHERE profile_option_name='PA_GLOBAL_WEEK_START_DAY'
     AND language=userenv('LANG');


     IF l_period_type is NULL AND  l_def_show_percentages_by is NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_err_msg:=l_user_profile_option_name1;
         l_err_msg:=l_err_msg||', '||l_user_profile_option_name2;
     ELSIF l_period_type is NULL AND  l_def_show_percentages_by is NOT NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_err_msg:=l_user_profile_option_name2;
     ELSIF l_period_type is NOT NULL AND  l_def_show_percentages_by is NULL THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_err_msg:=l_user_profile_option_name1;
         IF l_period_type = 'GE' and l_global_week_start_day IS NULL THEN
               l_err_msg:=l_err_msg||', '||l_user_profile_option_name3;
         END IF;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_ERROR and l_err_msg is not null THEN
           PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    =>  'PROFILES',
                            p_value1    =>  l_err_msg);

           l_msg_count := FND_MSG_PUB.count_msg;
           IF l_msg_count > 0 then
              IF l_msg_count = 1 then
                 PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded        => FND_API.G_TRUE,
                    p_msg_index      => 1,
                    p_msg_count      => l_msg_count,
                    p_msg_data       => l_msg_data,
                    p_data           => l_data,
                    p_msg_index_out  => l_msg_index_out);

                    x_msg_data := l_data;
                    x_msg_count := l_msg_count;
              ELSE
                    x_msg_count := l_msg_count;
              END IF;
           END IF;
     END IF;

     /*NPE changes ends */

   -- Shifted the following code of selecting forecast_thru_date to
   -- here, Also added message if NO_data_found occurs

   -- Fetching the default forecast thru date information from utilization options
   BEGIN

     select forecast_thru_date
     into l_forecast_thru_date
     from pa_utilization_options ut;

    /*Bug2440313 -- Commented this, the check for pa_implementaions is being done
                above in the code
     ,pa_implementations  imp  --NPE changes
     where  nvl(ut.org_id, -99) = nvl(imp.org_id,-99);   --NPE changes
    */

     IF (l_forecast_thru_date > sysdate
	 OR l_forecast_thru_date is NULL) then
        l_default_date := sysdate;
	 ELSE
        l_default_date := l_forecast_thru_date;
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        /* NPE Changes Begins */
        /* l_default_date := sysdate;  -- Commented this code */

        /* Bug2440313 Begin -- Undone the check for MO: Operating Unit here. The  Operating Unit check
	   is now done above in this code. Here we do check for utilization options defined or not */

	 x_return_status := FND_API.G_RET_STS_ERROR;
         PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_UNDEFINED_UTIL_OPTIONS');

         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count > 0 then
            IF l_msg_count = 1 then
               PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);

                  x_msg_data := l_data;
                  x_msg_count := l_msg_count;
             ELSE
                  x_msg_count := l_msg_count;
             END IF;
         END IF;
        /* Bug2440313 End */
   END;

     -- Collectively check for x_return_status, if error then return
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           pa_debug.reset_err_stack;
           return;
    END IF;

   l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);

   /*NPE changes ends */

   l_default_date := trunc(l_default_date);

   IF nvl(x_def_period_typ,'NA') <> l_period_type THEN
          x_def_period_typ := l_period_type;
	  l_use_default_logic := 'Y';
   ELSE
   	  l_use_default_logic := 'N';
   END IF;

  IF l_use_default_logic = 'Y' THEN
        -- Populating default period name
	IF ( l_period_type = 'PA') THEN
	     BEGIN -- NPE Changes
		   SELECT
		   paperiod.period_name,
		   paperiod.period_year,
		   paperiod.status,
		   paperiod.quarter_num,
		   glpersts.effective_period_num,
		   paperiod.status_meaning
		   INTO  l_prd_name,l_prd_yr,l_sts,l_mon_qtr,l_period_num,l_sts_meaning
		   FROM  pa_periods_v paperiod,
		   pa_implementations imp,
		   gl_period_statuses glpersts
		   WHERE  glpersts.period_type       = imp.pa_period_type
		   AND  imp.set_of_books_id        = paperiod.set_of_books_id
		   AND  glpersts.set_of_books_id   = imp.set_of_books_id
		   AND  glpersts.period_name       = paperiod.period_name
		   AND  glpersts.period_year       = paperiod.period_year
		   AND  glpersts.application_id    = 275
		   --      AND  paperiod.status            = 'O'
		   AND  l_default_date BETWEEN PA_START_DATE and PA_END_DATE
		   ORDER BY  paperiod.period_year;
		   --DBMS_OUTPUT.PUT_LINE('VALUES  '||l_prd_name||' '||l_prd_yr||' '||l_sts);
		   -- Populating default period name and default period year

		   x_def_period_name   :=  l_prd_name;
	           x_def_period_yr     :=  l_prd_yr;
	           x_def_mon_or_qtr    :=  l_mon_qtr;
                   x_def_period_num    :=  l_period_num;
	           x_def_period_sts    :=  l_sts_meaning;
                   x_def_period_sts_code := l_sts;
              /*NPE changes Begins */
              EXCEPTION
		 WHEN NO_DATA_FOUND THEN
	            x_return_status := FND_API.G_RET_STS_ERROR;
		    PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_PRD_NOT_DEFINED_FOR_DATE',
                            p_token1    => 'PA_DATE',
                            p_value1    =>  to_char(l_default_date,l_date_format));
	            l_msg_count := FND_MSG_PUB.count_msg;
		    IF l_msg_count > 0 then
	               IF l_msg_count = 1 then
		          PA_INTERFACE_UTILS_PUB.get_messages
			      (p_encoded        => FND_API.G_TRUE,
	                       p_msg_index      => 1,
		               p_msg_count      => l_msg_count,
			       p_msg_data       => l_msg_data,
	                       p_data           => l_data,
	                       p_msg_index_out  => l_msg_index_out);

		               x_msg_data := l_data;
			       x_msg_count := l_msg_count;
	               ELSE
		               x_msg_count := l_msg_count;
	               END IF;
		       pa_debug.reset_err_stack;
	               return;
		    END IF;
	      END;
	     /*NPE changes Ends */
	ELSIF( l_period_type = 'GL') THEN
	   BEGIN -- NPE Changes
	       SELECT glper.period_name
	      ,glper.period_year
	      ,glst.closing_status
	      ,glper.quarter_num
	      ,glst.effective_period_num
	      ,gllkups.meaning
	      INTO l_prd_name,l_prd_yr,l_sts,l_mon_qtr,l_period_num,l_sts_meaning
	      FROM pa_implementations imp,
	      gl_sets_of_books gl,
	      gl_periods glper,
	      gl_period_statuses glst,
	      gl_lookups gllkups
	      WHERE  imp.set_of_books_id    = gl.set_of_books_id
	      AND gl.period_set_name        = glper.period_set_name
	      AND gl.accounted_period_type  = glper.period_type
	      AND glper.period_name   = glst.period_name
	      AND glper.period_type   = glst.period_type
	      AND glst.set_of_books_id=imp.set_of_books_id
	      AND glst.application_id = PA_Period_Process_PKG.Application_ID
	      AND gllkups.lookup_code = glst.closing_status
	      AND gllkups.lookup_type = 'CLOSING_STATUS'
	      AND l_default_date BETWEEN glper.start_date AND glper.end_date
	     /* Bug 2288460 - Start        */
	     /* Added the following clause */
	     AND glper.adjustment_period_flag = 'N'
	     /* Bug 2288460 - End          */
	      ORDER BY glper.period_year;
	       --DBMS_OUTPUT.PUT_LINE('VALUES  '||l_prd_name||' '||l_prd_yr||' '||l_sts);

	       -- Populating default period name and default period year
	      x_def_period_name   :=  l_prd_name;
	      x_def_period_yr     :=  l_prd_yr;
	      x_def_mon_or_qtr    :=  l_mon_qtr;
	      x_def_period_num    :=  l_period_num;
	      x_def_period_sts    :=  l_sts_meaning;
	      x_def_period_sts_code := l_sts;
           /*NPE changes starts */
           EXCEPTION
		 WHEN NO_DATA_FOUND THEN
			 x_return_status := FND_API.G_RET_STS_ERROR;
			 PA_UTILS.Add_Message( p_app_short_name =>'PA',
		                    p_msg_name  => 'PA_GL_PRD_NOT_DEFINED_FOR_DATE',
			            p_token1    => 'GL_DATE',
				    p_value1    =>  to_char(l_default_date,l_date_format));
	                l_msg_count := FND_MSG_PUB.count_msg;
		        IF l_msg_count > 0 then
			    IF l_msg_count = 1 then
				 PA_INTERFACE_UTILS_PUB.get_messages
					  (p_encoded        => FND_API.G_TRUE,
				           p_msg_index      => 1,
					   p_msg_count      => l_msg_count,
			 		   p_msg_data       => l_msg_data,
			                   p_data           => l_data,
			                   p_msg_index_out  => l_msg_index_out);

				  x_msg_data := l_data;
		                  x_msg_count := l_msg_count;
			    ELSE
				  x_msg_count := l_msg_count;
	                    END IF;
		            pa_debug.reset_err_stack;
			    return;
	                END IF;
	       END;
	      /*NPE changes Ends */
	ELSIF ( l_period_type = 'GE') THEN
	     /* NPE Changes Begins */
	     IF l_global_week_start_day IS NULL THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
	   	   PA_UTILS.Add_Message( p_app_short_name =>'PA',
                            p_msg_name  => 'PA_UNDEFINED_PROFILES',
                            p_token1    =>  'PROFILES',
                            p_value1    =>  l_user_profile_option_name3);

		    l_msg_count := FND_MSG_PUB.count_msg;
	            IF l_msg_count > 0 then
		         IF l_msg_count = 1 then
			       PA_INTERFACE_UTILS_PUB.get_messages
				 (p_encoded        => FND_API.G_TRUE,
				  p_msg_index      => 1,
			          p_msg_count      => l_msg_count,
		                  p_msg_data       => l_msg_data,
		                  p_data           => l_data,
			          p_msg_index_out  => l_msg_index_out);

				  x_msg_data := l_data;
				  x_msg_count := l_msg_count;
		         ELSE
			          x_msg_count := l_msg_count;
	                 END IF;
		         pa_debug.reset_err_stack;
			 return;
	            END IF;
	       END IF;
	    /*  NPE Changes Ends */

	      -- Populating period name
	/** Bug 2387429  and 2091182 Code Fix Starts **/
	/*
	     SELECT
	     TO_CHAR(NEXT_DAY(l_default_date, NVL(TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY')),0))  -1,'DD-MON-YYYY')
	     INTO x_def_period_name
	     FROM sys.dual;
	*/

	  /* NPE Changes -- Shifted this code to the above in this code    l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);*/

	     SELECT
	     TO_CHAR(NEXT_DAY(l_default_date, NVL(TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY')),0))  -1,l_date_format)
	     INTO x_def_period_name
	     FROM sys.dual;

	/** Bug 2387429  and 2091182 Code Fix Ends **/

	--  Populating default period year taking from sysdate
	x_def_period_yr := TO_CHAR(l_default_date,'YYYY');
	-- Populating Mon or Qtr
	l_mon := TO_CHAR(l_default_date,'MM');

        x_def_mon_or_qtr    :=  l_mon;
        x_def_period_num    :=  0;
	x_def_period_sts := ' ';
	x_def_period_sts_code := ' ';
     END IF;
  ELSE --l_use_default_logic <> 'Y'
     /* Note that no need to do the NPE changes here as the value of the period are coming
        from other windows and would have been already validated */
     IF ( l_period_type = 'PA') THEN
	    SELECT
	      paperiod.period_name,
	      paperiod.period_year,
	      paperiod.status,
	      paperiod.quarter_num,
	      glpersts.effective_period_num,
	      paperiod.status_meaning
	      INTO  l_prd_name,l_prd_yr,l_sts,l_mon_qtr,l_period_num,l_sts_meaning
	      FROM  pa_periods_v paperiod,
	      pa_implementations imp,
	      gl_period_statuses glpersts
	      WHERE  glpersts.period_type       = imp.pa_period_type
	      AND  imp.set_of_books_id        = paperiod.set_of_books_id
	      AND  glpersts.set_of_books_id   = imp.set_of_books_id
	      AND  glpersts.period_name       = paperiod.period_name
	      AND  glpersts.period_year       = paperiod.period_year
	      AND  glpersts.period_name       = x_def_period_name
	      AND  glpersts.period_year       = x_def_period_yr
	      AND  glpersts.application_id    = 275
	--      AND  paperiod.status            = 'O'
	--      AND  l_default_date BETWEEN PA_START_DATE and PA_END_DATE
	      ORDER BY  paperiod.period_year;
	       --DBMS_OUTPUT.PUT_LINE('VALUES  '||l_prd_name||' '||l_prd_yr||' '||l_sts);
	       -- Populating default period name and default period year
	      x_def_period_name   :=  l_prd_name;
	      x_def_period_yr     :=  l_prd_yr;
	      x_def_mon_or_qtr    :=  l_mon_qtr;
	      x_def_period_num    :=  l_period_num;
	      x_def_period_sts    :=  l_sts_meaning;
	      x_def_period_sts_code := l_sts;
     ELSIF( l_period_type = 'GL') THEN
	  SELECT glper.period_name
	      ,glper.period_year
	      ,glst.closing_status
	      ,glper.quarter_num
	      ,glst.effective_period_num
	      ,gllkups.meaning
	      INTO l_prd_name,l_prd_yr,l_sts,l_mon_qtr,l_period_num,l_sts_meaning
	      FROM pa_implementations imp,
	      gl_sets_of_books gl,
	      gl_periods glper,
	      gl_period_statuses glst,
	      gl_lookups gllkups
	      WHERE  imp.set_of_books_id    = gl.set_of_books_id
	      AND gl.period_set_name        = glper.period_set_name
	      AND gl.accounted_period_type  = glper.period_type
	      AND glper.period_name   = glst.period_name
	      AND glper.period_name   = x_def_period_name
	      AND glper.period_type   = glst.period_type
	      AND glst.set_of_books_id=imp.set_of_books_id
	      AND glst.application_id = PA_Period_Process_PKG.Application_ID
	      AND gllkups.lookup_code = glst.closing_status
	      AND gllkups.lookup_type = 'CLOSING_STATUS'
	     /* Bug 2288460 - Start        */
	     /* Added the following clause */
	     AND glper.adjustment_period_flag = 'N'
	     /* Bug 2288460 - End          */
	--      AND l_default_date BETWEEN glper.start_date AND glper.end_date
	      ORDER BY glper.period_year;
	       --DBMS_OUTPUT.PUT_LINE('VALUES  '||l_prd_name||' '||l_prd_yr||' '||l_sts);

	       -- Populating default period name and default period year
	      x_def_period_name   :=  l_prd_name;
	      x_def_period_yr     :=  l_prd_yr;
	      x_def_mon_or_qtr    :=  l_mon_qtr;
	      x_def_period_num    :=  l_period_num;
	      x_def_period_sts    :=  l_sts_meaning;
	      x_def_period_sts_code := l_sts;

     ELSIF ( l_period_type = 'GE') THEN

	-- Populating Mon or Qtr
	      l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);
	      l_mon := TO_CHAR(to_date(x_def_period_name, l_date_format),'MM');

	      x_def_mon_or_qtr    :=  l_mon;
	      x_def_period_num    :=  0;
	      x_def_period_sts    := ' ';
   	      x_def_period_sts_code := ' ';
     END IF;
  END IF;
   --Added the below cos for GE status = NULL
   --Select from pa_rep_periods_v gives ' ' but this was giving NULL
   x_def_period := x_def_period_typ||'#'||x_def_period_name||'#'||x_def_period_sts_code||'#'||x_def_period_sts||'#'||x_def_mon_or_qtr||'#'||x_def_period_yr||'#'||x_def_period_num;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_REGENRATE_ORGNIZATION_FORECAST',
                               p_procedure_name   => 'get_default_period_val');
      RAISE;

END get_default_period_val;

------------------------------------------------------------------------------------------------------------------
-- This procedure will get the GE flag
-- Input parameters
-- Parameters                   Type           Required    Description
-- p_periodname                 VARCHAR2        YES        Period name
-- Out parameters
-- x_flag                       VARCHAR2        YES        It stores flag value
--
----------------------------------------------------------------------------------------------------------
PROCEDURE Get_GE_Flag(
	p_periodname IN  VARCHAR2,
	x_flag	     OUT NOCOPY VARCHAR2) IS

	l_gedate 	DATE ;
	l_date_format	varchar2(100);
	l_ge_end_date           DATE;

	x_def_period            VARCHAR2(100);
        x_def_period_typ        VARCHAR2(2);
        x_def_period_yr         VARCHAR2(10);
        x_def_period_name       VARCHAR2(30);
        x_def_period_sts_code   VARCHAR2(1);
        x_def_period_sts        VARCHAR2(30);
        x_def_mon_or_qtr        VARCHAR2(10);
	x_def_period_num	VARCHAR2(20);
        x_return_status         VARCHAR2(1);
        x_msg_count             NUMBER;
        x_msg_data              VARCHAR2(100);
BEGIN

        PA_REP_UTIL_GLOB.update_util_cache; -- Bug 2447797 added this call

	l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);
	--dbms_output.put_line('Date Format ---- ' || l_date_format);

	l_gedate := to_date(p_periodname, l_date_format);

	 pa_report_util.get_default_period_val(
                          x_def_period,
                          x_def_period_typ,
                          x_def_period_yr ,
                          x_def_period_name,
                          x_def_period_sts_code,
                          x_def_period_sts,
                          x_def_mon_or_qtr,
			  x_def_period_num,
                          x_return_status,
                          x_msg_count,
                          x_msg_data);

        l_ge_end_date := to_date(x_def_period_name, l_date_format);
        -- dbms_output.put_line('GE End Date : '|| to_char(l_ge_end_date));

        IF l_gedate < l_ge_end_date THEN
                x_flag := 'A';
        ELSIF  l_gedate > l_ge_end_date THEN
                x_flag := 'F';
        ELSIF l_gedate = l_ge_end_date THEN
                 x_flag := 'B';
        END IF;

EXCEPTION
	WHEN OTHERS THEN
	   RAISE;
END Get_GE_Flag;
END PA_REPORT_UTIL;

/
