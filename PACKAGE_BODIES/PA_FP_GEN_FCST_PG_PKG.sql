--------------------------------------------------------
--  DDL for Package Body PA_FP_GEN_FCST_PG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_GEN_FCST_PG_PKG" as
/* $Header: PAFPGFPB.pls 120.10.12010000.3 2010/01/07 09:56:41 racheruv ship $ */

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

FUNCTION   GET_REV_GEN_METHOD( P_PROJECT_ID IN PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE)
RETURN     VARCHAR2 IS

x_rev_gen_method         VARCHAR2(3);
l_error_msg              VARCHAR2(30);
l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.GET_REV_GEN_METHOD';

  BEGIN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'GET_REV_GEN_METHOD',
                                      p_debug_mode   =>  p_pa_debug_mode);
      END IF;

      -- Bug 4711164: Previously, distribution_rule was selected from
      -- pa_projects_all and passed to Get_Revenue_Generation_Method.
      -- However, it turns out that the lower level API ignores this
      -- parameter value and derives the value on its own. Code to get
      -- the distribution_rule has been removed to improve performance.

      --Calling the get rev gen method to get the value for l_rev_gen_method
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                               PA_RATE_PVT_PKG.Get_Revenue_Generation_Method',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
     PA_RATE_PVT_PKG.Get_Revenue_Generation_Method
       (P_PROJECT_ID         => p_project_id,
        P_DISTRIBUTION_RULE  => null, -- Modified for Bug 4711164
        X_REV_GEN_METHOD     => x_rev_gen_method,
        X_ERROR_MSG          => l_error_msg );
     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'After calling
                              PA_RATE_PVT_PKG.Get_Revenue_Generation_Method',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
     IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
     END IF;
  RETURN x_rev_gen_method;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN NULL;
    WHEN OTHERS THEN
         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN NULL;
  END;

FUNCTION   GET_ACTUALS_THRU_PERIOD_DTLS(P_BUDGET_VERSION_ID IN  PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
                                   P_CONTEXT           IN  VARCHAR2)
 RETURN     VARCHAR2 IS

    x_period_name     PA_PERIODS_ALL.PERIOD_NAME%TYPE;
    l_end_date        PA_PERIODS_ALL.END_DATE%TYPE;
    l_end_date1       PA_PERIODS_ALL.END_DATE%TYPE;
    l_end_date2       PA_PERIODS_ALL.END_DATE%TYPE;
    l_fp_cols_rec     PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
    l_ret_status      VARCHAR2(100);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.GET_ACTUALS_THRU_PERIOD_DTLS';

  BEGIN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'GET_ACTUALS_THRU_PERIOD_DTLS',
                                      p_debug_mode   =>  p_pa_debug_mode);
      END IF;
      --Calling the Util API
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
      PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
               (P_BUDGET_VERSION_ID          => P_BUDGET_VERSION_ID,
                X_FP_COLS_REC                => l_fp_cols_rec,
                X_RETURN_STATUS              => L_RET_STATUS,
                X_MSG_COUNT                  => L_MSG_COUNT,
                X_MSG_DATA               => L_MSG_DATA);
       IF L_RET_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls: '
                              ||L_RET_STATUS,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
       --dbms_output.put_line('Status of get plan version dtls api: '||L_RETURN_STATUS);
       --Last period means Last Closed Period
       IF    l_fp_cols_rec.x_gen_actual_amts_thru_code = 'LAST_PERIOD' AND
             l_fp_cols_rec.x_time_phased_code = 'P'   THEN

             SELECT   PERIOD_NAME, END_DATE
             INTO     x_period_name,l_end_date
             FROM     PA_PERIODS_ALL
             WHERE    ORG_ID = l_fp_cols_rec.x_org_id
             AND      STATUS = 'C'
             AND      END_DATE = (SELECT  MAX(END_DATE)
                                  FROM     PA_PERIODS_ALL
                                  WHERE    ORG_ID = l_fp_cols_rec.x_org_id
                                  AND      END_DATE < TRUNC(SYSDATE)
                                  AND      STATUS = 'C');

       ELSIF  l_fp_cols_rec.x_gen_actual_amts_thru_code = 'LAST_PERIOD' AND
              l_fp_cols_rec.x_time_phased_code = 'G'   THEN

              SELECT   PERIOD_NAME, END_DATE
              INTO     x_period_name,l_end_date
              FROM     GL_PERIOD_STATUSES
              WHERE    APPLICATION_ID         = PA_PERIOD_PROCESS_PKG.Application_id
              AND      SET_OF_BOOKS_ID        = l_fp_cols_rec.x_set_of_books_id
              AND      ADJUSTMENT_PERIOD_FLAG = 'N'
              AND      CLOSING_STATUS         = 'C'
              AND      END_DATE = (SELECT  MAX(END_DATE)
                                   FROM     GL_PERIOD_STATUSES
                                   WHERE    APPLICATION_ID         = PA_PERIOD_PROCESS_PKG.Application_id
                                   AND      SET_OF_BOOKS_ID        = l_fp_cols_rec.x_set_of_books_id
                                   AND      ADJUSTMENT_PERIOD_FLAG = 'N'
                                   AND      END_DATE < TRUNC(SYSDATE)
                                   AND      CLOSING_STATUS         = 'C');

       ELSIF  l_fp_cols_rec.x_gen_actual_amts_thru_code = 'PRIOR_PERIOD' AND
              l_fp_cols_rec.x_time_phased_code = 'P'   THEN

              SELECT period_name, end_date
              INTO   x_period_name,l_end_date
              FROM   pa_periods_all
              WHERE  end_date =
                   (SELECT max(end_date)
                    FROM   pa_periods_all
                    WHERE  org_id = l_fp_cols_rec.x_org_id
                    AND    end_date <
                            (SELECT end_date
                             FROM   pa_periods_all
                             WHERE  trunc(sysdate) between start_date and end_date
                             AND    org_id = l_fp_cols_rec.x_org_id) )
              AND    org_id = l_fp_cols_rec.x_org_id;

       ELSIF  l_fp_cols_rec.x_gen_actual_amts_thru_code = 'PRIOR_PERIOD' AND
              l_fp_cols_rec.x_time_phased_code = 'G'   THEN

              SELECT period_name, end_date
              INTO   x_period_name, l_end_date
              FROM   gl_period_statuses
              WHERE  end_date =
                   (SELECT max(end_date)
                    FROM   gl_period_statuses
                    WHERE  application_id  = PA_PERIOD_PROCESS_PKG.Application_id
                AND    set_of_books_id = l_fp_cols_rec.x_set_of_books_id
                    AND    adjustment_period_flag = 'N'
                    AND    end_date <
                             (SELECT end_date
                              FROM   gl_period_statuses
                              WHERE  trunc(sysdate) between start_date and end_date
                              AND  APPLICATION_ID  = PA_PERIOD_PROCESS_PKG.Application_id
                              AND  SET_OF_BOOKS_ID = l_fp_cols_rec.x_set_of_books_id
                              AND  ADJUSTMENT_PERIOD_FLAG = 'N'))
          AND  APPLICATION_ID  = PA_PERIOD_PROCESS_PKG.Application_id
          AND  SET_OF_BOOKS_ID = l_fp_cols_rec.x_set_of_books_id
              AND  ADJUSTMENT_PERIOD_FLAG = 'N';
              /* CURRENT_PERIOD - last summarization run date */
       ELSIF  l_fp_cols_rec.x_gen_actual_amts_thru_code = 'CURRENT_PERIOD' THEN
              l_end_date := PJI_PJP_EXTRACTION_UTILS.LAST_PJP_EXTR_DATE;

          /* Get period_name based on the l_end_date calculated for CURRENT_PERIOD bug4034021 */
          IF l_fp_cols_rec.x_time_phased_code = 'P' THEN
              SELECT period_name, end_date
              INTO   x_period_name, l_end_date2
              FROM   pa_periods_all
              WHERE  org_id = l_fp_cols_rec.x_org_id
                AND  l_end_date between start_date and end_date;

          ELSIF  ltrim(rtrim(l_fp_cols_rec.x_time_phased_code)) = 'G' THEN
              SELECT period_name, end_date
              INTO   x_period_name, l_end_date2
              FROM   gl_period_statuses
              WHERE  APPLICATION_ID  = PA_PERIOD_PROCESS_PKG.Application_id
               AND  set_of_books_id = l_fp_cols_rec.x_set_of_books_id
               AND   adjustment_period_flag = 'N'
               AND   l_end_date  between start_date and end_date;
         END IF;
         l_end_date := l_end_date2;
       END IF;

       IF P_CONTEXT = 'PERIOD' THEN
             IF p_pa_debug_mode = 'Y' THEN
                 PA_DEBUG.Reset_Curr_Function;
             END IF;
             RETURN x_period_name;
       ELSIF P_CONTEXT = 'END_DATE' THEN
             IF l_end_date IS NULL THEN
                l_end_date := trunc(sysdate);
             END IF;
             l_end_date1 := l_end_date;
            IF l_fp_cols_rec.x_time_phased_code = 'G' THEN
               SELECT end_date into l_end_date1
                              FROM   gl_period_statuses
                              WHERE  l_end_date between start_date and end_date
                              AND  APPLICATION_ID  = PA_PERIOD_PROCESS_PKG.Application_id
                              AND  SET_OF_BOOKS_ID = l_fp_cols_rec.x_set_of_books_id
                              AND  ADJUSTMENT_PERIOD_FLAG = 'N';
             ELSIF l_fp_cols_rec.x_time_phased_code = 'P' THEN
                   SELECT end_date into l_end_date1
                             FROM   pa_periods_all
                             WHERE  l_end_date between start_date and end_date
                             AND    org_id = l_fp_cols_rec.x_org_id;
             END IF;
             IF p_pa_debug_mode = 'Y' THEN
                 PA_DEBUG.Reset_Curr_Function;
             END IF;
             RETURN  to_char(nvl(l_end_date1,trunc(sysdate)),'RRRRMMDD');
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
           PA_DEBUG.Reset_Curr_Function;
       END IF;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF P_CONTEXT = 'PERIOD' THEN
          IF p_pa_debug_mode = 'Y' THEN
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RETURN NULL;
       ELSIF P_CONTEXT = 'END_DATE' THEN
          /*To address bug 4233703: when specified period doesn't exist,
            NUll becomes actuals_thru_period; end date of the current period
            where sysdate falls into becomes actuals_thru_date.*/
          BEGIN
              IF l_fp_cols_rec.x_time_phased_code = 'P' THEN
                  SELECT end_date
                  INTO   l_end_date
                  FROM   pa_periods_all
                  WHERE  org_id = l_fp_cols_rec.x_org_id
                    AND  trunc(sysdate) between start_date and end_date;
              ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN
                  SELECT end_date
                  INTO   l_end_date
                  FROM   gl_period_statuses
                  WHERE  APPLICATION_ID  = PA_PERIOD_PROCESS_PKG.Application_id
                   AND   set_of_books_id = l_fp_cols_rec.x_set_of_books_id
                   AND   adjustment_period_flag = 'N'
                   AND   trunc(sysdate) between start_date and end_date;
              ELSE
                  l_end_date := trunc(sysdate);
              END IF;
          EXCEPTION
              WHEN OTHERS THEN
                  l_end_date := trunc(sysdate);
          END ;
          IF p_pa_debug_mode = 'Y' THEN
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RETURN to_char(NVL(l_end_date, trunc(sysdate)),'RRRRMMDD');
       END IF;
    WHEN OTHERS THEN
       IF P_CONTEXT = 'PERIOD' THEN
          IF p_pa_debug_mode = 'Y' THEN
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RETURN NULL;
       ELSIF P_CONTEXT = 'END_DATE' THEN
          IF p_pa_debug_mode = 'Y' THEN
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RETURN to_char(trunc(sysdate),'RRRRMMDD');
       END IF;
 END;

FUNCTION   GET_ACT_FRM_PERIOD(P_BUDGET_VERSION_ID  IN PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN     VARCHAR2  IS
l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.GET_ACT_FRM_PERIOD';


     l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
     l_return_status              VARCHAR2(10);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_data                       VARCHAR2(2000);

     l_period_name                PA_PERIODS_ALL.PERIOD_NAME%TYPE;

BEGIN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'GET_ACT_FRM_PERIOD',
                                      p_debug_mode   =>  p_pa_debug_mode);
      END IF;
      --Calling the Util API
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
      PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                        (P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
                         X_FP_COLS_REC             => l_fp_cols_rec,
                         X_RETURN_STATUS           => l_RETURN_STATUS,
                         X_MSG_COUNT               => l_MSG_COUNT,
                         X_MSG_DATA            => l_MSG_DATA);
       IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;
       IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls: '
                              ||l_RETURN_STATUS,
              p_module_name => l_module_name,
              p_log_level   => 5);
       END IF;

      IF l_fp_cols_rec.x_time_phased_code = 'P' THEN

         SELECT p.period_name
         INTO   l_period_name
         FROM   pa_periods_all p, pa_projects_all  proj
         WHERE  p.org_id = l_fp_cols_rec.x_org_id
         AND    proj.project_id = l_fp_cols_rec.x_project_id
         AND   proj.start_date  between p.start_date and p.end_date;

         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN l_period_name;

      ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN

         SELECT g.period_name
         INTO   l_period_name
         FROM   gl_period_statuses g, pa_projects_all proj
         WHERE   g.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
         AND    g.set_of_books_id = l_fp_cols_rec.x_set_of_books_id
         AND    g.adjustment_period_flag = 'N'
         AND    proj.project_id = l_fp_cols_rec.x_project_id
         AND    proj.start_date between g.start_date and g.end_date;

         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN l_period_name;

      ELSE
         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN null;

      END IF;
      IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
 EXCEPTION
   WHEN OTHERS THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN null;
END;

FUNCTION   GET_ACT_TO_PERIOD(P_BUDGET_VERSION_ID  IN PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN     VARCHAR2 IS
l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.GET_ACT_TO_PERIOD';
     l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
     l_return_status              VARCHAR2(10);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_data                       VARCHAR2(2000);

l_act_to_period_date  DATE;
l_act_to_period_name  PA_PERIODS_ALL.PERIOD_NAME%TYPE;
l_act_from_period_name  varchar2(1000);  -- bug 6142328 added for comparing act_from_period with act_to_period

BEGIN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'GET_ACT_TO_PERIOD',
                                      p_debug_mode   =>  p_pa_debug_mode);
      END IF;
      --Calling the Util API
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
      PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                        (P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
                         X_FP_COLS_REC             => l_fp_cols_rec,
                         X_RETURN_STATUS           => l_RETURN_STATUS,
                         X_MSG_COUNT               => l_MSG_COUNT,
                         X_MSG_DATA                => l_MSG_DATA);
       IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls: '
                              ||l_RETURN_STATUS,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
     l_act_to_period_date :=  to_date(GET_ACTUALS_THRU_PERIOD_DTLS(P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID,
                                                      P_CONTEXT => 'END_DATE'),'RRRRMMDD');
--bug6120919 retrieving the act_from_period_name by calling GET_ACT_FRM_PERIOD()
     l_act_from_period_name := GET_ACT_FRM_PERIOD(P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID);

     IF l_fp_cols_rec.x_time_phased_code = 'P' THEN
       BEGIN
         SELECT period_name
         INTO   l_act_to_period_name
         FROM   pa_periods_all
         WHERE  org_id = l_fp_cols_rec.x_org_id
         AND    l_act_to_period_date BETWEEN start_date AND end_date
         AND   start_date >= (SELECT start_date    -- bug6142328 added one more select query for comparing the start date of act_to_period with act_from_period
 	 FROM pa_periods_all
	 WHERE period_name = l_act_from_period_name
	 AND org_id = l_fp_cols_rec.x_org_id);
         EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	         l_act_to_period_name := l_act_from_period_name;
     END;
         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN l_act_to_period_name;
      ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN
      BEGIN
         SELECT period_name
         INTO   l_act_to_period_name
         FROM   gl_period_statuses
         WHERE    application_id  = PA_PERIOD_PROCESS_PKG.Application_id
         AND    set_of_books_id = l_fp_cols_rec.x_set_of_books_id
         AND    adjustment_period_flag = 'N'
         AND    l_act_to_period_date BETWEEN start_date AND end_date
         AND   start_date >= (SELECT start_date FROM gl_period_statuses -- bug6142328 added one more select query for comparing the start date of act_to_period with act_from_period
	 WHERE  application_id  = PA_PERIOD_PROCESS_PKG.Application_id
	 AND  set_of_books_id = l_fp_cols_rec.x_set_of_books_id
	 AND period_name = l_act_from_period_name);

	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	         l_act_to_period_name := l_act_from_period_name;
	 END;

         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
	 -- bug 6142328; adding the below if condition for validating the l_act_to_period
      --bug6142328	l_act_from_period_name := GET_ACT_FRM_PERIOD(P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID);

/*	IF(l_act_from_period_name > l_act_to_period_name)
	THEN
		l_act_to_period_name := l_act_from_period_name;
	END IF;  */
         RETURN l_act_to_period_name;

      ELSE
         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN null;

      END IF;
      IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
 EXCEPTION
   WHEN OTHERS THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN null;
END;

FUNCTION   GET_ETC_FRM_PERIOD(P_BUDGET_VERSION_ID  IN PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN     VARCHAR2  IS
l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.GET_ETC_FRM_PERIOD';
     l_fp_cols_rec     PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
     l_return_status              VARCHAR2(10);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_data                       VARCHAR2(2000);
     l_msg_index_out              NUMBER:=0;

l_etc_from_period_date  DATE;
l_etc_from_period_name  PA_PERIODS_ALL.PERIOD_NAME%TYPE;

BEGIN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'GET_ETC_FRM_PERIOD',
                                      p_debug_mode   =>  p_pa_debug_mode);
      END IF;
      --Calling the Util API
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
      PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                        (P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
                         X_FP_COLS_REC             => l_fp_cols_rec,
                         X_RETURN_STATUS           => l_RETURN_STATUS,
                         X_MSG_COUNT               => l_MSG_COUNT,
                         X_MSG_DATA                => l_MSG_DATA);
       IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       END IF;

     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls: '
                              ||l_RETURN_STATUS,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;

     l_etc_from_period_date :=  to_date(GET_ACTUALS_THRU_PERIOD_DTLS(P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID,
                                                      P_CONTEXT => 'END_DATE'),'RRRRMMDD')+1;

     IF l_fp_cols_rec.x_time_phased_code = 'P' THEN

         SELECT period_name
         INTO   l_etc_from_period_name
         FROM   pa_periods_all
         WHERE  org_id = l_fp_cols_rec.x_org_id
         AND    l_etc_from_period_date between start_date and end_date;

         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN l_etc_from_period_name;
      ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN

         SELECT period_name
         INTO   l_etc_from_period_name
         FROM   gl_period_statuses
         WHERE    application_id  = PA_PERIOD_PROCESS_PKG.Application_id
         AND    set_of_books_id = l_fp_cols_rec.x_set_of_books_id
         AND    adjustment_period_flag = 'N'
         AND    l_etc_from_period_date between start_date and end_date;

         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN l_etc_from_period_name;

      ELSE
         IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RETURN null;

      END IF;
      IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
   -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded         => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
            --x_msg_data := l_data;
                        l_msg_data := l_data;
            --x_msg_count := l_msg_count;
      /*ELSE
         x_msg_count := l_msg_count; */
      END IF;
      ROLLBACK;

      l_return_status := FND_API.G_RET_STS_ERROR;

      IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;

   WHEN OTHERS THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN null;
END;

FUNCTION   GET_ETC_TO_PERIOD(P_BUDGET_VERSION_ID  IN PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN     VARCHAR2  IS
l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.GET_ETC_TO_PERIOD';

     l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
     l_return_status              VARCHAR2(10);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_data                       VARCHAR2(2000);
     l_proj_comp_date             DATE;
     l_etc_to_period              PA_PERIODS_ALL.PERIOD_NAME%TYPE;
     l_actual_thru_date              DATE;

BEGIN
      IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'GET_ETC_TO_PERIOD',
                                      p_debug_mode   =>  p_pa_debug_mode);
      END IF;
      --Calling the Util API
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_amount_utils.get_plan_version_dtls',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
      PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                        (P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
                         X_FP_COLS_REC             => l_fp_cols_rec,
                         X_RETURN_STATUS           => l_RETURN_STATUS,
                         X_MSG_COUNT               => l_MSG_COUNT,
                         X_MSG_DATA            => l_MSG_DATA);
     IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
     END IF;
     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_amount_utils.get_plan_version_dtls: '
                              ||l_RETURN_STATUS,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;

        l_actual_thru_date :=  to_date(GET_ACTUALS_THRU_PERIOD_DTLS(P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID,
                                                      P_CONTEXT => 'END_DATE'),'RRRRMMDD');

      IF l_fp_cols_rec.x_time_phased_code = 'P' THEN

         SELECT p.period_name, NVL(proj.completion_date, trunc(SYSDATE))
         INTO   l_etc_to_period, l_proj_comp_date
         FROM   pa_periods_all p, pa_projects_all proj
         WHERE  NVL(proj.completion_date, trunc(SYSDATE)) between p.start_date and p.end_date
         AND    p.org_id = l_fp_cols_rec.x_org_id
         AND    proj.project_id = l_fp_cols_rec.x_project_id;

        IF l_actual_thru_date+1 >= l_proj_comp_date THEN
           l_etc_to_period := GET_ETC_FRM_PERIOD(P_BUDGET_VERSION_ID);
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN l_etc_to_period;

      ELSIF l_fp_cols_rec.x_time_phased_code = 'G' THEN

         SELECT g.period_name,  NVL(proj.completion_date, trunc(SYSDATE))
         INTO   l_etc_to_period, l_proj_comp_date
         FROM   gl_period_statuses g, pa_projects_all proj
         WHERE    g.application_id  = PA_PERIOD_PROCESS_PKG.Application_id
         AND    g.set_of_books_id = l_fp_cols_rec.x_set_of_books_id
         AND    g.adjustment_period_flag = 'N'
         AND    proj.project_id = l_fp_cols_rec.x_project_id
         AND    NVL(proj.completion_date, trunc(SYSDATE)) between g.start_date and g.end_date;

        IF l_actual_thru_date+1 >= l_proj_comp_date THEN
           l_etc_to_period := GET_ETC_FRM_PERIOD(P_BUDGET_VERSION_ID);
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN l_etc_to_period;

      ELSE
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN null;

      END IF;
      IF p_pa_debug_mode = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
      END IF;
 EXCEPTION
   WHEN OTHERS THEN
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN null;
END;



FUNCTION   GET_UNSPENT_AMT_PERIOD(P_BUDGET_VERSION_ID  IN PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE)
RETURN     VARCHAR2  IS
l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.GET_UNSPENT_AMT_PERIOD';
    x_period_name     PA_PERIODS_ALL.PERIOD_NAME%TYPE;
BEGIN
   x_period_name := GET_ETC_FRM_PERIOD(P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID);
   RETURN x_period_name;
END;


PROCEDURE GET_VERSION_DETAILS
          (P_BUDGET_VERSION_ID   IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           X_VERSION_TYPE        OUT NOCOPY  PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE,
           X_RETURN_STATUS       OUT NOCOPY  VARCHAR2,
           X_MSG_COUNT           OUT NOCOPY  NUMBER,
           X_MSG_DATA            OUT NOCOPY  VARCHAR2) IS

l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.get_version_details';
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER:=0;

BEGIN
    --Setting initial values
    X_MSG_COUNT := 0;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF p_pa_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function     => 'GET_VERSION_DETAILS'
                                     ,p_debug_mode   =>  p_pa_debug_mode);
    END IF;

     SELECT   VERSION_TYPE
     INTO     X_VERSION_TYPE
     FROM     PA_BUDGET_VERSIONS
     WHERE    BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;
     --dbms_output.put_line('Version type from get_version_dtls api:'||X_VERSION_TYPE);

     IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;

     END IF;

EXCEPTION
     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
                 x_msg_data := l_data;
                 x_msg_count := l_msg_count;
          ELSE
                x_msg_count := l_msg_count;
          END IF;
          ROLLBACK;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Invalid Arguments Passed',
                p_module_name => l_module_name,
                p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_PG_PKG'
              ,p_procedure_name => 'GET_VERSION_DETAILS');
       IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||SUBSTR(SQLERRM,1,240),
                p_module_name => l_module_name,
                p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_VERSION_DETAILS;

   -- gboomina added for AAI requirement 8318932 - start
   /**
   * This method is used to validate Time Phase and ETC Source of
   * source plan
   */
   PROCEDURE VALIDATION_FOR_COPY_ETC_FLAG
             (P_PROJECT_ID          IN  PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
              P_WP_VERSION_ID       IN  PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
              P_ETC_PLAN_VERSION_ID IN  PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
              X_RETURN_STATUS       OUT NOCOPY  VARCHAR2,
              X_MSG_COUNT           OUT NOCOPY  NUMBER,
              X_MSG_DATA              OUT NOCOPY  VARCHAR2) IS

     l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.validation_for_copy_etc_flag';
     l_plan_version_id            PA_BUDGET_VERSIONS.VERSION_NAME%TYPE;
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2(2000);
     l_data                       VARCHAR2(2000);
     l_msg_index_out              NUMBER:=0;
     l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;

     CURSOR get_etc_source_code_csr
     IS
      SELECT  GEN_ETC_SOURCE_CODE,TASK_NAME
      FROM    PA_TASKS T
      WHERE   PROJECT_ID = P_PROJECT_ID;

     l_gen_etc_source_code get_etc_source_code_csr%ROWTYPE;

     BEGIN
       X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

       IF p_pa_debug_mode = 'Y' THEN
             pa_debug.set_curr_function( p_function     => 'VALIDATE_PLAN_TYPE_OR_VERSION'
                                        ,p_debug_mode   =>  p_pa_debug_mode);
       END IF;

       -- Get the work plan details by calling the following method
       -- with work plan version id
       IF P_WP_VERSION_ID IS NOT NULL THEN
         IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Before calling
                 pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id)',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
         END IF;
         PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                           (P_BUDGET_VERSION_ID       => P_WP_VERSION_ID,
                            X_FP_COLS_REC             => l_fp_cols_rec,
                            X_RETURN_STATUS           => X_RETURN_STATUS,
                            X_MSG_COUNT               => X_MSG_COUNT,
                            X_MSG_DATA                => X_MSG_DATA);
         IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Status after calling
                 pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id): '
                                 ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
         END IF;

         -- Check whether work plan is non time phased. if so, throw an error
         -- Only time phased plan is supported for Copy ETC From plan AAI requirement
         IF l_fp_cols_rec.x_time_phased_code = 'N' THEN
            x_return_status        := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_NON_TIME_PHASE_NOT_SUPP',
                                  p_token1         => 'PLAN_TYPE',
                                  p_value1         => 'Work Plan');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
       END IF;

        -- Get the financial plan details by calling the following
        -- method with financial paln id
        IF P_ETC_PLAN_VERSION_ID IS NOT NULL THEN
          IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Before calling
                  pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id)',
                  p_module_name => l_module_name,
                  p_log_level   => 5);
          END IF;
          PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                            (P_BUDGET_VERSION_ID       => P_ETC_PLAN_VERSION_ID,
                             X_FP_COLS_REC             => l_fp_cols_rec,
                             X_RETURN_STATUS           => X_RETURN_STATUS,
                             X_MSG_COUNT               => X_MSG_COUNT,
                             X_MSG_DATA                => X_MSG_DATA);
          IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
          IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                 (p_msg         => 'Status after calling
                  pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id): '
                                  ||x_return_status,
                  p_module_name => l_module_name,
                  p_log_level   => 5);
          END IF;

          -- Check whether work plan is non time phased. if so, throw an error.
          -- Only time phased plan is supported for Copy ETC From plan AAI requirement
          IF l_fp_cols_rec.x_time_phased_code = 'N' THEN
             x_return_status        := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_NON_TIME_PHASE_NOT_SUPP',
                                                        p_token1         => 'PLAN_TYPE',
                                                 p_value1         => 'Source Financial Plan');

             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;

        END IF;

        -- Validation for ETC source
        -- Either Financial plan or Work plan are only supported for
        -- Copy ETC From plan AAI requirement
        FOR l_gen_etc_source_code IN get_etc_source_code_csr
        LOOP
         IF l_gen_etc_source_code.gen_etc_source_code NOT IN ('FINANCIAL_PLAN', 'WORKPLAN_RESOURCES') THEN
            PA_UTILS.ADD_MESSAGE
                ( p_app_short_name  => 'PA',
                  p_msg_name        => 'PA_FP_ETC_SRC_NOT_SUPPORTED',
                         p_token1          => 'TASK_NAME',
                         p_value1          => l_gen_etc_source_code.task_name);
            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
          END IF;
        END LOOP;

        IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
        END IF;

     EXCEPTION
       WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
         l_msg_count := FND_MSG_PUB.count_msg;
         IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                (p_encoded        => FND_API.G_TRUE
                 ,p_msg_index      => 1
                 ,p_msg_count      => l_msg_count
                 ,p_msg_data       => l_msg_data
                 ,p_data           => l_data
                 ,p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
                x_msg_count := l_msg_count;
         ELSE
               x_msg_count := l_msg_count;
         END IF;
         ROLLBACK;

         x_return_status := FND_API.G_RET_STS_ERROR;
         IF P_PA_DEBUG_MODE = 'Y' THEN
           pa_fp_gen_amount_utils.fp_debug
            (p_msg         => 'Validation failed',
             p_module_name => l_module_name,
             p_log_level   => 5);
             PA_DEBUG.Reset_Curr_Function;
         END IF;
         RAISE;
       WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data      := SUBSTR(SQLERRM,1,240);
         FND_MSG_PUB.add_exc_msg
           ( p_pkg_name       => 'PA_FP_GEN_FCST_PG_PKG'
            ,p_procedure_name => 'VALIDATE_PLAN_TYPE_OR_VERSION');
         IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END VALIDATION_FOR_COPY_ETC_FLAG;
   -- gboomina added for AAI requirement 8318932 - end

/**
 * 23-MAY-05 dkuo Added parameters P_CHECK_SRC_ERRORS, X_WARNING_MESSAGE.
 *                Please check body of VALIDATE_SUPPORT_CASES in PAFPGAUB.pls
 *                for list of valid parameter values.
 **/
PROCEDURE UPD_VER_DTLS_AND_GEN_AMT
          (P_BUDGET_VERSION_ID       IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_VERSION_TYPE            IN          PA_BUDGET_VERSIONS.VERSION_TYPE%TYPE,
           P_UNSPENT_AMT_FLAG        IN          PA_PROJ_FP_OPTIONS.GEN_COST_INCL_UNSPENT_AMT_FLAG%TYPE,
           P_UNSPENT_AMT_PERIOD      IN          VARCHAR2,
           P_INCL_CHG_DOC_FLAG       IN          PA_PROJ_FP_OPTIONS.GEN_COST_INCL_CHANGE_DOC_FLAG%TYPE,
           P_INCL_OPEN_CMT_FLAG      IN          PA_PROJ_FP_OPTIONS.GEN_COST_INCL_OPEN_COMM_FLAG%TYPE,
           P_INCL_BILL_EVT_FLAG      IN          PA_PROJ_FP_OPTIONS.GEN_REV_INCL_BILL_EVENT_FLAG%TYPE,
           P_RET_MANUAL_LNS_FLAG     IN          PA_PROJ_FP_OPTIONS.GEN_COST_RET_MANUAL_LINE_FLAG%TYPE,
           P_PLAN_TYPE_ID            IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
           P_PLAN_VERSION_ID         IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
           P_PLAN_VERSION_NAME       IN          PA_BUDGET_VERSIONS.VERSION_NAME%TYPE,
           P_ETC_PLAN_TYPE_ID        IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
           P_ETC_PLAN_VERSION_ID     IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
           P_ETC_PLAN_VERSION_NAME   IN          PA_BUDGET_VERSIONS.VERSION_NAME%TYPE,
           P_ACTUALS_FROM_PERIOD     IN          VARCHAR2,
           P_ACTUALS_TO_PERIOD       IN          VARCHAR2,
           P_ETC_FROM_PERIOD         IN          VARCHAR2,
           P_ETC_TO_PERIOD           IN          VARCHAR2,
           P_ACTUALS_THRU_PERIOD     IN          PA_BUDGET_VERSIONS.ACTUAL_AMTS_THRU_PERIOD%TYPE,
           P_ACTUALS_THRU_DATE       IN          PA_PERIODS_ALL.END_DATE%TYPE,
           P_WP_STRUCTURE_VERSION_ID IN          PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
           P_CHECK_SRC_ERRORS_FLAG   IN          VARCHAR2,
           X_WARNING_MESSAGE         OUT NOCOPY  VARCHAR2,
           X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
           X_MSG_COUNT               OUT NOCOPY  NUMBER,
           X_MSG_DATA                OUT NOCOPY  VARCHAR2) IS

l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.upd_ver_dtls_and_gen_amt';
l_fp_cols_rec                PA_FP_GEN_AMOUNT_UTILS.FP_COLS;
l_PLAN_VERSION_ID            PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE;
l_ETC_PLAN_VERSION_ID        PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE;
l_return_status              VARCHAR2(10);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER:=0;

l_last_updated_by            PA_RESOURCE_ASSIGNMENTS.LAST_UPDATED_BY%TYPE;
l_last_update_login          PA_RESOURCE_ASSIGNMENTS.LAST_UPDATE_LOGIN%TYPE;
l_sysdate                    DATE;

l_record_version_number      PA_BUDGET_VERSIONS.RECORD_VERSION_NUMBER%TYPE;
l_wp_version_id number;
l_res_asg_id_del_tab         PA_PLSQL_DATATYPES.IdTabTyp;

-- gboomina added for AAI requirement 8318932 - start
-- Cursor to get 'Copy ETC from Plan' flag
CURSOR get_copy_etc_from_plan_csr
IS
SELECT COPY_ETC_FROM_PLAN_FLAG
FROM PA_PROJ_FP_OPTIONS
WHERE FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID;

l_copy_etc_from_plan_flag PA_PROJ_FP_OPTIONS.COPY_ETC_FROM_PLAN_FLAG%TYPE;
-- gboomina added for AAI requirement 8318932 - end

BEGIN
      --Setting initial values
  --hr_utility.trace_on(null,'mftest');
  --hr_utility.trace('bv id :'|| P_BUDGET_VERSION_ID);
  --hr_utility.trace('ver type: '|| P_VERSION_TYPE);
  --hr_utility.trace('unspent : '|| P_UNSPENT_AMT_FLAG);
  --hr_utility.trace('unspent pd : '|| P_UNSPENT_AMT_PERIOD);
  --hr_utility.trace('inc chg doc : '|| P_INCL_CHG_DOC_FLAG);
  --hr_utility.trace('inc cmt flag: '|| P_INCL_OPEN_CMT_FLAG);
  --hr_utility.trace('inc bil flag: '|| P_INCL_BILL_EVT_FLAG);
  --hr_utility.trace('ret man flag: '|| P_RET_MANUAL_LNS_FLAG);
  --hr_utility.trace('plan type id: '|| P_PLAN_TYPE_ID);
  --hr_utility.trace('plan vers id: '|| P_PLAN_VERSION_ID);
  --hr_utility.trace('plan vers name: '|| P_PLAN_VERSION_NAME);
  --hr_utility.trace('etc plan type : '|| P_ETC_PLAN_TYPE_ID);
  --hr_utility.trace('etc plan ver  : '|| P_ETC_PLAN_VERSION_ID);
  --hr_utility.trace('etc plan ver name  : '|| P_ETC_PLAN_VERSION_NAME);
  --hr_utility.trace('actu from pd name  : '|| P_ACTUALS_FROM_PERIOD);
  --hr_utility.trace('actu to  pd name  : '|| P_ACTUALS_TO_PERIOD);
  --hr_utility.trace('etc from pd name  : '|| P_ETC_FROM_PERIOD);
  --hr_utility.trace('etc to   pd name  : '|| P_ETC_TO_PERIOD);
  --hr_utility.trace('act thru pd name  : '|| P_ACTUALS_THRU_PERIOD);
  --hr_utility.trace('act thru date     : '|| to_char(P_ACTUALS_THRU_DATE));
  --hr_utility.trace('wp str ver id     : '|| P_WP_STRUCTURE_VERSION_ID);

      FND_MSG_PUB.initialize;
      X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
      l_return_status :=  FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'UPD_VER_DTLS_AND_GEN_AMT'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

    /*Bug fix:3818180 for locking*/
    --acquire version lock

    SELECT record_version_number
       INTO l_record_version_number
    FROM pa_budget_versions
    WHERE budget_version_id = p_budget_version_id;
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling pa_fin_plan_pvt.lock_unlock_version',
              p_module_name => l_module_name);
    END IF;
    pa_fin_plan_pvt.lock_unlock_version
    (p_budget_version_id    => P_BUDGET_VERSION_ID,
        p_record_version_number => l_record_version_number,
        p_action                => 'L',
        p_user_id               => FND_GLOBAL.USER_ID,
        p_person_id             => NULL,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data);
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling pa_fin_plan_pvt.lock_unlock_version:'
                              ||x_return_status,
              p_module_name => l_module_name);
    END IF;

    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    COMMIT;

    /* we need to commit the changes so that the locked by person info
       will be available for other sessions. */

    --acquire lock for copy_actual
    IF p_pa_debug_mode = 'Y' THEN
        PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG               => 'Before calling PA_FP_COPY_FROM_PKG.'
                                    ||'ACQUIRE_LOCKS_FOR_COPY_ACTUAL',
            P_MODULE_NAME       => l_module_name);
    END IF;

      PA_FP_COPY_FROM_PKG.ACQUIRE_LOCKS_FOR_COPY_ACTUAL
            (P_PLAN_VERSION_ID   => P_BUDGET_VERSION_ID,
                 X_RETURN_STATUS     => X_RETURN_STATUS,
                 X_MSG_COUNT         => X_MSG_COUNT,
                 X_MSG_DATA          => X_MSG_DATA);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    --If can't acquire lock, customized message is thrown from within
    -- the API, so we should suppress exception error
        IF p_pa_debug_mode = 'Y' THEN
            PA_DEBUG.Reset_Curr_Function;
        END IF;
        RETURN;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
    PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG(
            P_MSG               => 'After calling PA_FP_COPY_FROM_PKG.'
                                   ||'ACQUIRE_LOCKS_FOR_COPY_ACTUAL: '
                   ||x_return_status,
            P_MODULE_NAME       => l_module_name);
    END IF;
    /*End Bug fix:3818180 for locking*/


    l_PLAN_VERSION_ID := P_PLAN_VERSION_ID;
    l_ETC_PLAN_VERSION_ID := P_ETC_PLAN_VERSION_ID;

    --Calling the Util API
    IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
           (p_msg         => 'Before calling
            pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id)',
            p_module_name => l_module_name,
            p_log_level   => 5);
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
                      (P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
                       X_FP_COLS_REC             => l_fp_cols_rec,
                       X_RETURN_STATUS           => X_RETURN_STATUS,
                       X_MSG_COUNT               => X_MSG_COUNT,
                       X_MSG_DATA                => X_MSG_DATA);
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
          pa_fp_gen_amount_utils.fp_debug
           (p_msg         => 'Status after calling
            pa_fp_gen_amount_utils.get_plan_version_dtls(p_budget_version_id): '
                            ||x_return_status,
            p_module_name => l_module_name,
            p_log_level   => 5);
    END IF;
    --dbms_output.put_line('Status of get plan version dtls api: '||X_RETURN_STATUS);

      IF P_WP_STRUCTURE_VERSION_ID IS NOT NULL THEN
         l_wp_version_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id
            ( p_project_id                    => l_fp_cols_rec.x_project_id,
              p_plan_type_id                  => -1,
              p_proj_str_ver_id               => P_WP_STRUCTURE_VERSION_ID );
      END IF;

     -- gboomina added for AAI requirement 8318932 - start
     OPEN get_copy_etc_from_plan_csr;
     FETCH get_copy_etc_from_plan_csr INTO l_copy_etc_from_plan_flag;
     CLOSE get_copy_etc_from_plan_csr;

     IF l_copy_etc_from_plan_flag = 'Y' THEN
         -- Check whether the target version type is 'COST' and
         -- ETC Source is 'Task Level Selection'. Only this combo is supported for
         -- Copy ETC from plan flow.
         IF ( P_VERSION_TYPE <> 'COST' )  THEN
             x_return_status        := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_COST_PLAN_TYPE_ONLY_SUPP');
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
         IF ( L_FP_COLS_REC.X_GEN_ETC_SRC_CODE <> 'TASK_LEVEL_SEL' ) THEN
             x_return_status        := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_TASK_LEVEL_SEL_ONLY');
             RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;
         -- Check whether destination financial plan is non time phased.
         -- if so, throw an error.
         -- Only time phased plan is supported for Copy ETC From plan AAI requirement
         IF L_FP_COLS_REC.X_TIME_PHASED_CODE = 'N' THEN
            x_return_status        := FND_API.G_RET_STS_ERROR;
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_NON_TIME_PHASE_NOT_SUPP',
                                  p_token1         => 'PLAN_TYPE',
                                  p_value1         => 'Financial Plan');

            RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
         END IF;

         IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Before calling
                                pa_fp_gen_fcst_pg_pkg.validation_for_copy_etc_flag',
                 p_module_name => l_module_name,
                 p_log_level   => 5);
         END IF;
         -- Calling the following method to validate time phase and ETC source of
         -- source plan
         VALIDATION_FOR_COPY_ETC_FLAG
             (P_PROJECT_ID          => L_FP_COLS_REC.X_PROJECT_ID,
              P_WP_VERSION_ID       => L_WP_VERSION_ID,
              P_ETC_PLAN_VERSION_ID => L_ETC_PLAN_VERSION_ID,
              X_RETURN_STATUS       => X_RETURN_STATUS,
              X_MSG_COUNT           => X_MSG_COUNT,
              X_MSG_DATA              => X_MSG_DATA);
         IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := X_RETURN_STATUS;
         END IF;
         IF p_pa_debug_mode = 'Y' THEN
               pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Status after calling
                 pa_fp_gen_fcst_pg_pkg.validation_for_copy_etc_flag: '
                                 ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
         END IF;
     END IF;
     -- gboomina added for AAI requirement 8318932 - end

      --Calling the validation for the periods
      --dbms_output.put_line('before validate_periods');
  /* the validation should not happen when the forecast gen source is
     RESOURCE SCHEDULE. */

  IF L_FP_COLS_REC.X_GEN_ETC_SRC_CODE <> 'RESOURCE_SCHEDULE' THEN
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_fcst_pg_pkg.validate_periods',
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
      PA_FP_GEN_FCST_PG_PKG.VALIDATE_PERIODS
          (P_BUDGET_VERSION_ID   => P_BUDGET_VERSION_ID,
           P_FP_COLS_REC         => l_fp_cols_rec,
           P_UNSPENT_AMT_FLAG    => P_UNSPENT_AMT_FLAG,
           P_UNSPENT_AMT_PERIOD  => P_UNSPENT_AMT_PERIOD,
           P_ACTUALS_FROM_PERIOD => P_ACTUALS_FROM_PERIOD,
           P_ACTUALS_TO_PERIOD   => P_ACTUALS_TO_PERIOD,
           P_ETC_FROM_PERIOD     => P_ETC_FROM_PERIOD,
           P_ETC_TO_PERIOD       => P_ETC_TO_PERIOD,
           X_RETURN_STATUS       => X_RETURN_STATUS,
           X_MSG_COUNT           => X_MSG_COUNT,
           X_MSG_DATA            => X_MSG_DATA);
      IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := X_RETURN_STATUS;
           --RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_fcst_pg_pkg.validate_periods: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;


   /* Calling Validate plan type or version api -> etc_generation_source'*/
     IF P_ETC_PLAN_TYPE_ID IS NOT NULL AND
        P_ETC_PLAN_VERSION_NAME IS NOT NULL AND
        l_ETC_PLAN_VERSION_ID IS NULL THEN
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_fcst_pg_pkg.validate_plan_type_or_version',
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
      PA_FP_GEN_FCST_PG_PKG.VALIDATE_PLAN_TYPE_OR_VERSION
          (P_PROJECT_ID          => l_fp_cols_rec.X_PROJECT_ID,
           P_PLAN_TYPE_ID        => P_ETC_PLAN_TYPE_ID,
           PX_PLAN_VERSION_ID    => l_ETC_PLAN_VERSION_ID,
           P_PLAN_VERSION_NAME   => P_ETC_PLAN_VERSION_NAME,
           P_CALLING_CONTEXT     => 'ETC_GENERATION_SOURCE',
           X_RETURN_STATUS       => X_RETURN_STATUS,
           X_MSG_COUNT           => X_MSG_COUNT,
           X_MSG_DATA            => X_MSG_DATA);
      IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          l_return_status := X_RETURN_STATUS;
          --RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             ( p_msg         => 'Status after calling
               pa_fp_gen_fcst_pg_pkg.validate_plan_type_or_version for etc_generation_source: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
      --dbms_output.put_line('Status of validate plan type or version(for etc gen src) api: '||X_RETURN_STATUS);

  END IF;

 END IF;
 /* end if for chking gen src code not equal to resource schedule  */

    IF p_ret_manual_lns_flag = 'N' THEN
        DELETE FROM pa_budget_lines
        WHERE  budget_version_id = P_BUDGET_VERSION_ID;

        DELETE FROM pa_resource_assignments
        WHERE  budget_version_id = P_BUDGET_VERSION_ID;

        -- IPM: New Entity ER ------------------------------------------
        -- Call the maintenance api in DELETE mode
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG               => 'Before calling PA_RES_ASG_CURRENCY_PUB.'
                                         || 'MAINTAIN_DATA',
                --P_CALLED_MODE       => p_called_mode,
                  P_MODULE_NAME       => l_module_name,
                  P_LOG_LEVEL         => 5 );
        END IF;
        PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
            ( P_FP_COLS_REC           => l_fp_cols_rec,
              P_CALLING_MODULE        => 'FORECAST_GENERATION',
              P_DELETE_FLAG           => 'Y',
              P_VERSION_LEVEL_FLAG    => 'Y',
            --P_CALLED_MODE           => p_called_mode,
              X_RETURN_STATUS         => x_return_status,
              X_MSG_COUNT             => x_msg_count,
              X_MSG_DATA              => x_msg_data );
        IF p_pa_debug_mode = 'Y' THEN
            PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                ( P_MSG               => 'After calling PA_RES_ASG_CURRENCY_PUB.'
                                         || 'MAINTAIN_DATA: ' || x_return_status,
                --P_CALLED_MODE       => p_called_mode,
                  P_MODULE_NAME       => l_module_name,
                  P_LOG_LEVEL         => 5 );
        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;
        -- END OF IPM: New Entity ER ------------------------------------------

    -- Bug 4136545: Delete actuals budget lines when target timephasing is PA
    -- or GL. Subtract and NULL out actual amounts when timephasing is None.
    ELSIF p_ret_manual_lns_flag = 'Y' THEN

        -- 8947560: As per functional requirement, we need to retain the user
        -- entered etc values for the generated lines with etc source of None
        -- i.e. these lines should be treated similar to manually added lines
        UPDATE pa_resource_assignments
        SET transaction_source_code = NULL
        WHERE budget_version_id = p_budget_version_id AND
              transaction_source_code = 'NONE';

        -- Bug 4344111: We should delete budget lines for all resources with
        -- non-null transaction source code and then null-out the transaction
        -- source code for these resources. Moved the logic for Bug 4227963
        -- up before the logic for cleaning up actuals budget line data and
        -- modified the SELECT statement's WHERE clause to check that the
        -- transaction_source_code IS NOT NULL (which includes the previous
        -- check that transaction_source_code was either Open Commitments,
        -- Billing Events, or Change Documents).

        /* Bug 4227963: Clean up additional options' budget line data. */
        SELECT resource_assignment_id
        BULK COLLECT INTO
        l_res_asg_id_del_tab
        FROM PA_RESOURCE_ASSIGNMENTS
        WHERE budget_version_id = p_budget_version_id AND
              transaction_source_code IS NOT NULL;

        IF (l_res_asg_id_del_tab.count > 0) THEN
           FORALL i IN 1 .. l_res_asg_id_del_tab.count
              DELETE FROM PA_BUDGET_LINES
              WHERE resource_assignment_id = l_res_asg_id_del_tab(i);

           FORALL j IN 1 .. l_res_asg_id_del_tab.count
              UPDATE PA_RESOURCE_ASSIGNMENTS
              SET transaction_source_code = null
              WHERE resource_assignment_id = l_res_asg_id_del_tab(j);

            -- IPM: New Entity ER ------------------------------------------
            DELETE pa_resource_asgn_curr_tmp;

            FORALL k IN 1..l_res_asg_id_del_tab.count
                INSERT INTO pa_resource_asgn_curr_tmp (
                    RESOURCE_ASSIGNMENT_ID,
                    DELETE_FLAG )
                VALUES (
                    l_res_asg_id_del_tab(k),
                    'Y' );

            -- Call the maintenance api in DELETE mode
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG               => 'Before calling PA_RES_ASG_CURRENCY_PUB.'
                                             || 'MAINTAIN_DATA',
                    --P_CALLED_MODE       => p_called_mode,
                      P_MODULE_NAME       => l_module_name,
                      P_LOG_LEVEL         => 5 );
            END IF;
            PA_RES_ASG_CURRENCY_PUB.MAINTAIN_DATA
                ( P_FP_COLS_REC           => l_fp_cols_rec,
                  P_CALLING_MODULE        => 'FORECAST_GENERATION',
                  P_DELETE_FLAG           => 'Y',
                  P_VERSION_LEVEL_FLAG    => 'N',
                --P_CALLED_MODE           => p_called_mode,
                  X_RETURN_STATUS         => x_return_status,
                  X_MSG_COUNT             => x_msg_count,
                  X_MSG_DATA              => x_msg_data );
            IF p_pa_debug_mode = 'Y' THEN
                PA_FP_GEN_AMOUNT_UTILS.FP_DEBUG
                    ( P_MSG               => 'After calling PA_RES_ASG_CURRENCY_PUB.'
                                             || 'MAINTAIN_DATA: ' || x_return_status,
                    --P_CALLED_MODE       => p_called_mode,
                      P_MODULE_NAME       => l_module_name,
                      P_LOG_LEVEL         => 5 );
            END IF;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
            END IF;
            -- END OF IPM: New Entity ER ------------------------------------------

        END IF; --IF (l_res_asg_id_del_tab.count > 0) THEN

        /* Clean up actuals budget line data. */
        IF l_fp_cols_rec.x_time_phased_code IN ('P','G') THEN
            DELETE FROM pa_budget_lines
            WHERE  budget_version_id = p_budget_version_id
            AND    start_date <= p_actuals_thru_date;
        ELSIF l_fp_cols_rec.x_time_phased_code = 'N' THEN
            UPDATE pa_budget_lines
            SET    quantity = quantity - NVL(init_quantity,0),
                   raw_cost = raw_cost - NVL(init_raw_cost,0),
                   burdened_cost = burdened_cost - NVL(init_burdened_cost,0),
                   revenue = revenue - NVL(init_revenue,0),
                   project_raw_cost = project_raw_cost - NVL(project_init_raw_cost,0),
                   project_burdened_cost = project_burdened_cost - NVL(project_init_burdened_cost,0),
                   project_revenue = project_revenue - NVL(project_init_revenue,0),
                   txn_raw_cost = txn_raw_cost - NVL(txn_init_raw_cost,0),
                   txn_burdened_cost = txn_burdened_cost - NVL(txn_init_burdened_cost,0),
                   txn_revenue = txn_revenue - NVL(txn_init_revenue,0)
            WHERE  budget_version_id = p_budget_version_id;

            l_last_updated_by := FND_GLOBAL.USER_ID;
            l_last_update_login := FND_GLOBAL.LOGIN_ID;
            l_sysdate := SYSDATE;

            UPDATE pa_budget_lines
            SET    init_quantity = null,
                   init_raw_cost = null,
                   init_burdened_cost = null,
                   init_revenue = null,
                   project_init_raw_cost = null,
                   project_init_burdened_cost = null,
                   project_init_revenue = null,
                   txn_init_raw_cost = null,
                   txn_init_burdened_cost = null,
                   txn_init_revenue = null,
                   last_update_date = l_sysdate,
                   last_updated_by = l_last_updated_by,
                   last_update_login = l_last_update_login
            WHERE  budget_version_id = p_budget_version_id;
        END IF;
    END IF;

     IF P_VERSION_TYPE = 'COST' THEN
        --Updating the pa_proj_fp_options table for cost version type
          UPDATE PA_PROJ_FP_OPTIONS
          SET    GEN_COST_INCL_UNSPENT_AMT_FLAG = P_UNSPENT_AMT_FLAG,
                 GEN_COST_INCL_CHANGE_DOC_FLAG  = P_INCL_CHG_DOC_FLAG,
                 GEN_COST_INCL_OPEN_COMM_FLAG   = P_INCL_OPEN_CMT_FLAG,
                 GEN_COST_RET_MANUAL_LINE_FLAG  = P_RET_MANUAL_LNS_FLAG,
                 GEN_SRC_COST_PLAN_TYPE_ID      = P_ETC_PLAN_TYPE_ID,
                 GEN_SRC_COST_PLAN_VERSION_ID   = l_ETC_PLAN_VERSION_ID,
                 GEN_SRC_COST_WP_VERSION_ID     = l_wp_version_id
         WHERE   FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID;
         --dbms_output.put_line('No. of rows updated in pa_proj_fp_options for cost:'||sql%rowcount);

    ELSIF P_VERSION_TYPE = 'REVENUE' THEN
        --Updating the pa_proj_fp_options table for revenue version type
          UPDATE PA_PROJ_FP_OPTIONS
          SET
                 GEN_REV_INCL_CHANGE_DOC_FLAG  = P_INCL_CHG_DOC_FLAG,
                 GEN_REV_INCL_BILL_EVENT_FLAG  = P_INCL_BILL_EVT_FLAG,
                 GEN_REV_RET_MANUAL_LINE_FLAG  = P_RET_MANUAL_LNS_FLAG,
                 GEN_SRC_REV_PLAN_TYPE_ID      = P_ETC_PLAN_TYPE_ID,
                 GEN_SRC_REV_PLAN_VERSION_ID   = l_ETC_PLAN_VERSION_ID,
                 GEN_SRC_REV_WP_VERSION_ID     = l_wp_version_id
          WHERE  FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID;
         --dbms_output.put_line('No. of rows updated in pa_proj_fp_options for revenue:'||sql%rowcount);

    ELSIF P_VERSION_TYPE = 'ALL' THEN
        --Updating the pa_proj_fp_options table for all version type
          UPDATE PA_PROJ_FP_OPTIONS
          SET    GEN_ALL_INCL_UNSPENT_AMT_FLAG = P_UNSPENT_AMT_FLAG,
                 GEN_ALL_INCL_CHANGE_DOC_FLAG  = P_INCL_CHG_DOC_FLAG,
                 GEN_ALL_INCL_OPEN_COMM_FLAG   = P_INCL_OPEN_CMT_FLAG,
                 GEN_ALL_INCL_BILL_EVENT_FLAG  = P_INCL_BILL_EVT_FLAG,
                 GEN_ALL_RET_MANUAL_LINE_FLAG  = P_RET_MANUAL_LNS_FLAG,
                 GEN_SRC_ALL_PLAN_TYPE_ID      = P_ETC_PLAN_TYPE_ID,
                 GEN_SRC_ALL_PLAN_VERSION_ID   = l_ETC_PLAN_VERSION_ID,
                 GEN_SRC_ALL_WP_VERSION_ID     = l_wp_version_id
          WHERE  FIN_PLAN_VERSION_ID = P_BUDGET_VERSION_ID;
         --dbms_output.put_line('No. of rows updated in pa_proj_fp_options for all:'||sql%rowcount);
    END IF;

    UPDATE  PA_BUDGET_VERSIONS
    SET     ACTUAL_AMTS_THRU_PERIOD = P_ACTUALS_THRU_PERIOD
    WHERE   BUDGET_VERSION_ID       = P_BUDGET_VERSION_ID;

    /* We need to get version details again after validation logic and
     * updates to the budget version so that we pass the most current
     * information to lower level APIs via the l_fp_cols_rec parameter. */
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           ( p_msg         => 'Before calling
                               pa_fp_gen_amount_utils.get_plan_version_dtls',
             p_module_name => l_module_name,
             p_log_level   => 5 );
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.GET_PLAN_VERSION_DTLS
        ( P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
          X_FP_COLS_REC             => l_fp_cols_rec,
          X_RETURN_STATUS           => X_RETURN_STATUS,
          X_MSG_COUNT               => X_MSG_COUNT,
          X_MSG_DATA                => X_MSG_DATA );

    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           ( p_msg         => 'Status after calling
                              pa_fp_gen_amount_utils.get_plan_version_dtls: '
                              ||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5 );
    END IF;

    /* This API validates that the current generation is supported.
     * For a list of unsupported cases, please see comments at the
     * beginning of the VALIDATE_SUPPORT_CASES API (PAFPGAUB.pls) */

    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           ( p_msg         => 'Before calling
                               pa_fp_gen_amount_utils.validate_support_cases',
             p_module_name => l_module_name,
             p_log_level   => 5 );
    END IF;
    PA_FP_GEN_AMOUNT_UTILS.VALIDATE_SUPPORT_CASES (
        P_FP_COLS_REC_TGT       => l_fp_cols_rec,
        P_CHECK_SRC_ERRORS_FLAG => P_CHECK_SRC_ERRORS_FLAG,
        X_WARNING_MESSAGE       => X_WARNING_MESSAGE,
        X_RETURN_STATUS         => X_RETURN_STATUS,
        X_MSG_COUNT             => X_MSG_COUNT,
        X_MSG_DATA              => X_MSG_DATA );
    IF p_pa_debug_mode = 'Y' THEN
        pa_fp_gen_amount_utils.fp_debug
           ( p_msg         => 'Status after calling
                              pa_fp_gen_amount_utils.validate_support_cases: '
                              ||x_return_status,
             p_module_name => l_module_name,
             p_log_level   => 5 );
    END IF;
    IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    /* When VALIDATE_SUPPORT_CASES returns a non-null warning message,
     * we need to Return control to the page/front-end so that a warning
     * can be displayed asking the user whether or not to proceed.
     */
     /* Bug 4901256 : If P_CHECK_SRC_ERRORS_FLAG is passed as 'Y' always
        Return irrespective of X_WARNING_MESSAGE. */
    IF P_CHECK_SRC_ERRORS_FLAG = 'Y' THEN
        -- Added the above IF and Commented below if condition bug 4901256
        --    IF X_WARNING_MESSAGE IS NOT NULL THEN
        -- Before returning, we always have the following check.
        IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
        END IF;

        RETURN;
    END IF;

    --Calling Gen FCST Amt Wrapper API
     IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_fcst_amt_pub.generate_fcst_amt_wrp',
              p_module_name => l_module_name,
              p_log_level   => 5);
     END IF;
    PA_FP_GEN_FCST_AMT_PUB.GENERATE_FCST_AMT_WRP
       (   P_PROJECT_ID              => l_fp_cols_rec.X_PROJECT_ID,
           P_BUDGET_VERSION_ID       => P_BUDGET_VERSION_ID,
           P_FP_COLS_REC             => l_fp_cols_rec,
           P_VERSION_TYPE            => P_VERSION_TYPE,
           P_UNSPENT_AMT_FLAG        => P_UNSPENT_AMT_FLAG,
           P_UNSPENT_AMT_PERIOD      => P_UNSPENT_AMT_PERIOD,
           P_INCL_CHG_DOC_FLAG       => P_INCL_CHG_DOC_FLAG,
           P_INCL_OPEN_CMT_FLAG      => P_INCL_OPEN_CMT_FLAG,
           P_INCL_BILL_EVT_FLAG      => P_INCL_BILL_EVT_FLAG,
           P_RET_MANUAL_LNS_FLAG     => P_RET_MANUAL_LNS_FLAG,
           P_PLAN_TYPE_ID            => P_PLAN_TYPE_ID,
           P_PLAN_VERSION_ID         => P_PLAN_VERSION_ID,
           P_PLAN_VERSION_NAME       => P_PLAN_VERSION_NAME,
           P_ETC_PLAN_TYPE_ID        => P_ETC_PLAN_TYPE_ID,
           P_ETC_PLAN_VERSION_ID     => l_ETC_PLAN_VERSION_ID,
           P_ETC_PLAN_VERSION_NAME   => P_ETC_PLAN_VERSION_NAME,
           P_ACTUALS_FROM_PERIOD     => P_ACTUALS_FROM_PERIOD,
           P_ACTUALS_TO_PERIOD       => P_ACTUALS_TO_PERIOD,
           P_ETC_FROM_PERIOD         => P_ETC_FROM_PERIOD,
           P_ETC_TO_PERIOD           => P_ETC_TO_PERIOD,
           P_ACTUALS_THRU_PERIOD     => P_ACTUALS_THRU_PERIOD,
           P_ACTUALS_THRU_DATE       => P_ACTUALS_THRU_DATE,
           P_WP_STRUCTURE_VERSION_ID => P_WP_STRUCTURE_VERSION_ID,
           X_RETURN_STATUS           => X_RETURN_STATUS,
           X_MSG_COUNT               => X_MSG_COUNT,
           X_MSG_DATA                => X_MSG_DATA);
      IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
          l_return_status := X_RETURN_STATUS;
          --RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
      END IF;
      IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_fcst_amt_pub.generate_fcst_amt_wrp: '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
      END IF;
      --dbms_output.put_line('Status of gen_fcst_amt_wrp api: '||X_RETURN_STATUS);

    x_return_status := l_return_status;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
    END IF;

    IF p_pa_debug_mode = 'Y' THEN
         PA_DEBUG.Reset_Curr_Function;
    END IF;

 EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
      -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded         => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
      ROLLBACK;

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5);
      PA_DEBUG.Reset_Curr_Function;
      END IF;
      RAISE;

    WHEN OTHERS THEN
     --dbms_output.put_line('inside excep');
     --dbms_output.put_line(SUBSTR(SQLERRM,1,240));
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);

     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_PG_PKG'
              ,p_procedure_name => 'UPD_VER_DTLS_AND_GEN_AMT');
     IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5);
           PA_DEBUG.Reset_Curr_Function;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPD_VER_DTLS_AND_GEN_AMT;


PROCEDURE VALIDATE_PERIODS
          (P_BUDGET_VERSION_ID   IN          PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
           P_FP_COLS_REC         IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_UNSPENT_AMT_FLAG    IN          PA_PROJ_FP_OPTIONS.GEN_COST_INCL_UNSPENT_AMT_FLAG%TYPE,
           P_UNSPENT_AMT_PERIOD  IN          VARCHAR2,
           P_ACTUALS_FROM_PERIOD IN          VARCHAR2,
           P_ACTUALS_TO_PERIOD   IN          VARCHAR2,
           P_ETC_FROM_PERIOD     IN          VARCHAR2,
           P_ETC_TO_PERIOD       IN          VARCHAR2,
           X_RETURN_STATUS       OUT NOCOPY  VARCHAR2,
           X_MSG_COUNT           OUT NOCOPY  NUMBER,
           X_MSG_DATA            OUT NOCOPY  VARCHAR2) IS

l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.validate_periods';
l_return_status              VARCHAR2(30);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER:=0;

l_unspent_date          DATE;
l_act_frm_date          DATE;
l_act_to_date           DATE;
l_etc_frm_date          DATE;
l_etc_to_date           DATE;
l_act_thru_date         DATE;
l_valid_act_frm_flag    VARCHAR2(1) := 'N';
l_valid_act_to_flag     VARCHAR2(1) := 'N';
l_valid_etc_frm_flag    VARCHAR2(1) := 'N';
l_valid_etc_to_flag     VARCHAR2(1) := 'N';

BEGIN
     --Setting initial values
     --FND_MSG_PUB.initialize;
     --X_MSG_COUNT := 0;
     X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
     l_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'VALIDATE_PERIODS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

    --Validating unspent amount period
     IF P_FP_COLS_REC.X_TIME_PHASED_CODE <> 'N'
        AND P_UNSPENT_AMT_FLAG = 'Y'
        AND P_UNSPENT_AMT_PERIOD IS NULL THEN
           l_return_status        := FND_API.G_RET_STS_ERROR;
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_NO_UNSPENT_PERIOD');
     END IF;

     IF P_UNSPENT_AMT_FLAG = 'Y' AND P_UNSPENT_AMT_PERIOD IS NOT NULL THEN
         --Calling pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(unspent date) api
          IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(unspent date)',
              p_module_name => l_module_name,
              p_log_level   => 5);
         END IF;
         PA_FP_GEN_FCST_PG_PKG.VALIDATE_PA_GL_PERIODS
            (P_PERIOD_NAME     => P_UNSPENT_AMT_PERIOD,
             P_FP_COLS_REC     => P_FP_COLS_REC,
             P_CONTEXT         => 'UNSPENT_PERIOD',
             X_END_DATE        => l_unspent_date ,
             X_RETURN_STATUS   => X_RETURN_STATUS,
             X_MSG_COUNT       => X_MSG_COUNT,
             X_MSG_DATA        => X_MSG_DATA);
             l_return_status      := X_RETURN_STATUS;
         IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(unspent date): '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
         END IF;
         --dbms_output.put_line('Status of validate_pa_gl_period api(unspent date): '||X_RETURN_STATUS);
     END IF;
/*       --Validating actuals from period
        IF P_ACTUALS_FROM_PERIOD IS NULL THEN
             x_return_status        := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_NO_ACTUALS_FROM_PERIOD');
        ELSE*/

     IF P_ACTUALS_FROM_PERIOD IS NOT NULL THEN
         --Calling pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(actuals from) api
           IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(actuals from)',
              p_module_name => l_module_name,
              p_log_level   => 5);
           END IF;
           PA_FP_GEN_FCST_PG_PKG.VALIDATE_PA_GL_PERIODS
              (P_PERIOD_NAME         => P_ACTUALS_FROM_PERIOD,
               P_FP_COLS_REC         => P_FP_COLS_REC,
               P_CONTEXT             => 'ACTUALS_FROM_PERIOD',
               X_END_DATE            => l_act_frm_date,
               X_RETURN_STATUS       => X_RETURN_STATUS,
               X_MSG_COUNT           => X_MSG_COUNT,
               X_MSG_DATA        => X_MSG_DATA);
           IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Status after calling
              pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(actuals from): '
                              ||x_return_status,
              p_module_name => l_module_name,
              p_log_level   => 5);
           END IF;
           --dbms_output.put_line('Status of validate_pa_gl_period api(actuals from): '||X_RETURN_STATUS);

           IF  X_RETURN_STATUS = 'S' THEN
            l_valid_act_frm_flag := 'Y';
           ELSE
             l_return_status      := X_RETURN_STATUS;
           END IF;
     END IF;
/*        --Validating actuals to period
        IF P_ACTUALS_TO_PERIOD IS NULL THEN
             x_return_status        := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_NO_ACTUALS_TO_PERIOD');
        ELSE */

    IF P_ACTUALS_TO_PERIOD IS NOT NULL THEN
         --Calling pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(actuals to) api
           IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(actuals to)',
              p_module_name => l_module_name,
              p_log_level   => 5);
           END IF;
           PA_FP_GEN_FCST_PG_PKG.VALIDATE_PA_GL_PERIODS
               (P_PERIOD_NAME         => P_ACTUALS_TO_PERIOD,
                P_FP_COLS_REC         => P_FP_COLS_REC,
                P_CONTEXT             => 'ACTUALS_TO_PERIOD',
                X_END_DATE            => l_act_to_date,
                X_RETURN_STATUS       => X_RETURN_STATUS,
                X_MSG_COUNT           => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA);
           IF p_pa_debug_mode = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
               ( p_msg         => 'Status after calling
                 pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(actuals to): '
                                 ||x_return_status,
                 p_module_name => l_module_name,
                 p_log_level   => 5);
           END IF;
       --dbms_output.put_line('Status of validate_pa_gl_period api(actuals to): '||X_RETURN_STATUS);

           IF  X_RETURN_STATUS = 'S' THEN
              l_valid_act_to_flag := 'Y';
           ELSE
              l_return_status      := X_RETURN_STATUS;
           END IF;
     END IF;
/*        --Validating ETC from period
        IF P_ETC_FROM_PERIOD IS NULL THEN
             x_return_status        := FND_API.G_RET_STS_ERROR;
             PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_NO_ETC_FROM_PERIOD');
        ELSE*/
   IF P_ETC_FROM_PERIOD IS NOT NULL THEN
         --Calling pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(etc from) api
           IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'Before calling
                              pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(etc from)',
               p_module_name => l_module_name,
               p_log_level   => 5);
           END IF;
           PA_FP_GEN_FCST_PG_PKG.VALIDATE_PA_GL_PERIODS
               (P_PERIOD_NAME         => P_ETC_FROM_PERIOD,
                P_FP_COLS_REC         => P_FP_COLS_REC,
                P_CONTEXT             => 'ETC_FROM_PERIOD',
                X_END_DATE            => l_etc_frm_date,
                X_RETURN_STATUS       => X_RETURN_STATUS,
                X_MSG_COUNT           => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA);
           IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
              (p_msg         => 'Status after calling
               pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(etc from): '
                                ||x_return_status,
               p_module_name => l_module_name,
               p_log_level   => 5);
           END IF;
        --dbms_output.put_line('Status of validate_pa_gl_period api(etc from): '||X_RETURN_STATUS);

          IF X_RETURN_STATUS = 'S' THEN
                  l_valid_etc_frm_flag := 'Y';
          ELSE
                  l_return_status      := X_RETURN_STATUS;
          END IF;
    END IF;

/*       --Validating ETC to period
        IF P_ETC_TO_PERIOD IS NULL THEN
           x_return_status        := FND_API.G_RET_STS_ERROR;
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_NO_ETC_TO_PERIOD');
        ELSE */
         --Calling pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(etc to) api
    IF P_ETC_TO_PERIOD IS NOT NULL THEN
           IF p_pa_debug_mode = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Before calling
                             pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(etc to)',
              p_module_name => l_module_name,
              p_log_level   => 5);
           END IF;
            PA_FP_GEN_FCST_PG_PKG.VALIDATE_PA_GL_PERIODS
              (P_PERIOD_NAME         => P_ETC_TO_PERIOD,
               P_FP_COLS_REC         => P_FP_COLS_REC,
               P_CONTEXT             => 'ETC_TO_PERIOD',
               X_END_DATE            => l_etc_to_date,
               X_RETURN_STATUS       => X_RETURN_STATUS,
               X_MSG_COUNT           => X_MSG_COUNT,
               X_MSG_DATA        => X_MSG_DATA);
           IF p_pa_debug_mode = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Status after calling
                pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods(etc to): '
                                ||x_return_status,
                p_module_name => l_module_name,
                p_log_level   => 5);
           END IF;
           --dbms_output.put_line('Status of validate_pa_gl_period api(etc to): '||X_RETURN_STATUS);

             IF X_RETURN_STATUS = 'S' THEN
              l_valid_etc_to_flag := 'Y';
             ELSE
              l_return_status      := X_RETURN_STATUS;
             END IF;
        END IF;

        --dbms_output.put_line('Value of valid act frm flag: '||l_valid_act_frm_flag);
        --dbms_output.put_line('Value of valid act to flag: '||l_valid_act_to_flag);

        IF  l_valid_act_frm_flag = 'Y' AND l_valid_act_to_flag = 'Y' THEN
          --dbms_output.put_line('all flags are Y');
              --dbms_output.put_line('act_to_date:'||l_act_to_date);
              --dbms_output.put_line('act_frm_date:'||l_act_frm_date);
              IF   l_act_to_date < l_act_frm_date THEN
                   l_return_status        := FND_API.G_RET_STS_ERROR;
                   --dbms_output.put_line(l_return_status);
                   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_FP_INV_ACT_PD_RANGE');
              END IF;
        END IF;

        --dbms_output.put_line('Value of valid etc frm flag: '||l_valid_etc_frm_flag);
        --dbms_output.put_line('Value of valid etc to flag: '||l_valid_etc_to_flag);

        IF  l_valid_etc_frm_flag = 'Y' AND l_valid_etc_to_flag = 'Y' THEN
              IF l_etc_to_date < l_etc_frm_date THEN
                   l_return_status        := FND_API.G_RET_STS_ERROR;
                   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_FP_INV_ETC_PD_RANGE');
              END IF;
        END IF;

        l_act_thru_date := to_date(GET_ACTUALS_THRU_PERIOD_DTLS(
               P_BUDGET_VERSION_ID => P_BUDGET_VERSION_ID,
               P_CONTEXT => 'END_DATE'),'RRRRMMDD');

        --dbms_output.put_line('Value of act_thru_date: '||l_act_thru_date);

        IF l_act_frm_date > l_act_thru_date THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_ACT_FP_NOT_IN_ATP');
        ELSIF l_act_to_date > l_act_thru_date THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_ACT_TP_NOT_IN_ATP');
        ELSIF l_etc_frm_date < l_act_thru_date THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_ETC_FP_NOT_IN_ATP');
        ELSIF l_etc_to_date < l_act_thru_date THEN
            PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_FP_ETC_TP_NOT_IN_ATP');
        END IF;

        x_return_status := l_return_status;

    IF (x_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
           RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF p_pa_debug_mode = 'Y' THEN
             PA_DEBUG.Reset_Curr_Function;
        END IF;

EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
      -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded         => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
      ROLLBACK;

      x_return_status := FND_API.G_RET_STS_ERROR;
      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5);
      PA_DEBUG.Reset_Curr_Function;
      END IF;
      RAISE;

 WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_PG_PKG'
              ,p_procedure_name => 'VALIDATE_PERIODS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
                pa_fp_gen_amount_utils.fp_debug
                (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                 p_module_name => l_module_name,
                 p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END VALIDATE_PERIODS;


PROCEDURE VALIDATE_PA_GL_PERIODS
          (P_PERIOD_NAME         IN          PA_PERIODS_ALL.PERIOD_NAME%TYPE,
           P_FP_COLS_REC         IN          PA_FP_GEN_AMOUNT_UTILS.FP_COLS,
           P_CONTEXT             IN          VARCHAR2,
           P_ERROR_MSG_CODE      IN          FND_NEW_MESSAGES.MESSAGE_NAME%TYPE,
           X_END_DATE            OUT NOCOPY  DATE,
           X_RETURN_STATUS       OUT NOCOPY  VARCHAR2,
           X_MSG_COUNT           OUT NOCOPY  NUMBER,
           X_MSG_DATA            OUT NOCOPY  VARCHAR2) IS

l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.validate_pa_gl_periods';
l_return_status              VARCHAR2(30);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER:=0;

BEGIN
      --Setting initial values
      --FND_MSG_PUB.initialize;
      --X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'VALIDATE_PA_GL_PERIODS'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

      IF  P_FP_COLS_REC.X_TIME_PHASED_CODE = 'P' THEN
             SELECT   END_DATE
             INTO     X_END_DATE
             FROM     PA_PERIODS_ALL
             WHERE    ORG_ID      = p_fp_cols_rec.x_org_id
             AND      PERIOD_NAME = p_period_name;
             --dbms_output.put_line('End date from validate_pa_gl_periods(P) api:'||X_END_DATE);

      ELSIF P_FP_COLS_REC.X_TIME_PHASED_CODE = 'G' THEN
            SELECT   END_DATE
            INTO     X_END_DATE
            FROM     GL_PERIOD_STATUSES
            WHERE    APPLICATION_ID         = PA_PERIOD_PROCESS_PKG.Application_id
            AND      SET_OF_BOOKS_ID        = p_fp_cols_rec.x_set_of_books_id
            AND      ADJUSTMENT_PERIOD_FLAG = 'N'
            AND      PERIOD_NAME            = p_period_name;
            --dbms_output.put_line('End date from validate_pa_gl_periods(G) api:'||X_END_DATE);

      END IF;

     IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;
     END IF;

            --dbms_output.put_line('return status from pa_gl_periods api before exception: '||x_return_status);
EXCEPTION
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;

          IF    P_CONTEXT = 'UNSPENT_PERIOD'     THEN
                      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_INV_UNSPENT_PERIOD');
          ELSIF P_CONTEXT = 'ACTUALS_FROM_PERIOD' THEN
                      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_INV_ACT_FP');
          ELSIF P_CONTEXT = 'ACTUALS_TO_PERIOD' THEN
                      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_INV_ACT_TP');
          ELSIF P_CONTEXT =  'ETC_FROM_PERIOD' THEN
                      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_INV_ETC_FP');
          ELSIF P_CONTEXT = 'ETC_TO_PERIOD' THEN
                      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_INV_ETC_TP');
          END IF;
          --dbms_output.put_line('return status from pa_gl_periods api inside exception(NDF): '||x_return_status);
      -- Bug Fix: 4569365. Removed MRC code.
      -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded         => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
      ROLLBACK;

      x_return_status := FND_API.G_RET_STS_ERROR;
      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Invalid periods',
              p_module_name => l_module_name,
              p_log_level   => 5);
      PA_DEBUG.Reset_Curr_Function;
      END IF;
      RAISE;


   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
   --   PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded         => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
            x_msg_data := l_data;
            x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
      ROLLBACK;

      x_return_status := FND_API.G_RET_STS_ERROR;
      IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5);
      PA_DEBUG.Reset_Curr_Function;
      END IF;
      RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_PG_PKG'
              ,p_procedure_name => 'VALIDATE_PA_GL_PERIODS');
           IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
              p_module_name => l_module_name,
              p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         --dbms_output.put_line('return status from pa_gl_periods api inside exception(O): '||x_return_status);

END VALIDATE_PA_GL_PERIODS;

PROCEDURE VALIDATE_PLAN_TYPE_OR_VERSION
          (P_PROJECT_ID          IN          PA_PROJ_FP_OPTIONS.PROJECT_ID%TYPE,
           P_PLAN_TYPE_ID        IN          PA_PROJ_FP_OPTIONS.FIN_PLAN_TYPE_ID%TYPE,
           PX_PLAN_VERSION_ID    IN OUT NOCOPY PA_PROJ_FP_OPTIONS.FIN_PLAN_VERSION_ID%TYPE,
           P_PLAN_VERSION_NAME   IN          PA_BUDGET_VERSIONS.VERSION_NAME%TYPE,
           P_CALLING_CONTEXT     IN          VARCHAR2,
           X_RETURN_STATUS       OUT NOCOPY  VARCHAR2,
           X_MSG_COUNT           OUT NOCOPY  NUMBER,
           X_MSG_DATA            OUT NOCOPY  VARCHAR2) IS

l_module_name                VARCHAR2(200) := 'pa.plsql.pa_fp_gen_fcst_pg_pkg.validate_plan_type_or_version';
l_plan_version_id            PA_BUDGET_VERSIONS.VERSION_NAME%TYPE;
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(2000);
l_data                       VARCHAR2(2000);
l_msg_index_out              NUMBER:=0;

BEGIN
      --Setting initial values
      --FND_MSG_PUB.initialize;
      --X_MSG_COUNT := 0;
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'VALIDATE_PLAN_TYPE_OR_VERSION'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
      END IF;

     IF p_plan_type_id IS NULL THEN
        IF p_calling_context = 'GENERATION_SOURCE' THEN
           x_return_status        := FND_API.G_RET_STS_ERROR;
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_NO_PLAN_TYPE_ID_SRC');
        ELSIF p_calling_context = 'ETC_GENERATION_SOURCE' THEN
           x_return_status        := FND_API.G_RET_STS_ERROR;
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_NO_PLAN_TYPE_ID_ETC_SRC');
        END IF;
     END IF;

     IF  px_plan_version_id IS NOT NULL THEN
         IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.RESET_CURR_FUNCTION;
         END IF;
         RETURN;
     END IF;

     IF p_plan_version_name IS NULL THEN
           x_return_status        := FND_API.G_RET_STS_ERROR;
           PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_FP_NO_PLAN_VERSION_NAME');
     END IF;

     SELECT  bv.budget_version_id
     INTO    l_plan_version_id
     FROM    pa_budget_versions bv
     WHERE   bv.project_id          = p_project_id
     AND     bv.fin_plan_type_id    = p_plan_type_id
     AND     bv.version_name        = p_plan_version_name
     AND     bv.version_type        in ('COST','ALL');

     px_plan_version_id := l_plan_version_id;

     IF P_PA_DEBUG_MODE = 'Y' THEN
          PA_DEBUG.Reset_Curr_Function;

     END IF;


EXCEPTION
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF p_calling_context =  'GENERATION_SOURCE' THEN
                      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_INV_GEN_BV');
          ELSIF p_calling_context = 'ETC_GENERATION_SOURCE' THEN
                      PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                            p_msg_name       => 'PA_FP_INV_ETC_BV');
          END IF;
          IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Invalid source',
              p_module_name => l_module_name,
              p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

     WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count = 1 THEN
              PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
                 x_msg_data := l_data;
                 x_msg_count := l_msg_count;
          ELSE
                x_msg_count := l_msg_count;
          END IF;
          ROLLBACK;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF P_PA_DEBUG_MODE = 'Y' THEN
            pa_fp_gen_amount_utils.fp_debug
             (p_msg         => 'Invalid Arguments Passed',
              p_module_name => l_module_name,
              p_log_level   => 5);
              PA_DEBUG.Reset_Curr_Function;
          END IF;
          RAISE;

      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_data      := SUBSTR(SQLERRM,1,240);
           FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_GEN_FCST_PG_PKG'
              ,p_procedure_name => 'VALIDATE_PLAN_TYPE_OR_VERSION');
           IF P_PA_DEBUG_MODE = 'Y' THEN
              pa_fp_gen_amount_utils.fp_debug
               (p_msg         => 'Unexpected Error'||substr(sqlerrm, 1, 240),
                p_module_name => l_module_name,
                p_log_level   => 5);
                PA_DEBUG.Reset_Curr_Function;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END VALIDATE_PLAN_TYPE_OR_VERSION;

END PA_FP_GEN_FCST_PG_PKG;

/
