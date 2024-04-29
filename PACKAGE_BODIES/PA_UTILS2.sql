--------------------------------------------------------
--  DDL for Package Body PA_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UTILS2" AS
/* $Header: PAXGUT2B.pls 120.15.12010000.8 2010/01/31 06:41:32 svivaram ship $ */

-- FUNCTION get_period_name /*2835063*/
    FUNCTION get_period_name RETURN  pa_cost_distribution_lines_all.pa_period_name%TYPE is
    BEGIN
         /* Please note that this function should be used only after ensuring that
            get_pa_date() is called for the returned variable's value to be set to
            a non-NULL value */
      return  g_prvdr_pa_period_name;
    end get_period_name;


-- ==========================================================================
-- = FUNCTION  CheckExpOrg
-- ==========================================================================

  FUNCTION CheckExpOrg (x_org_id IN NUMBER,
                       x_txn_date in date ) RETURN VARCHAR2 IS

       -- This function returns 'Y'  if a given org is a Exp organization ,
       -- otherwise , it returns 'N'

       CURSOR l_exp_org_csr IS
       SELECT 'x'
         FROM pa_organizations_expend_v
        WHERE organization_id = x_org_id
          and active_flag = 'Y'
          and trunc(x_txn_date) between date_from and nvl(date_to,trunc(x_txn_date));

       l_dummy  VARCHAR2(1);

  BEGIN

     IF (x_org_id          = G_PREV_ORG_ID AND
         trunc(x_txn_date) = G_PREV_TXN_DATE) THEN

         RETURN(G_PREV_EXP_ORG);

     ELSE

        G_PREV_ORG_ID    := x_org_id;
        G_PREV_TXN_DATE  := trunc(x_txn_date);

        OPEN l_exp_org_csr;
        FETCH l_exp_org_csr INTO l_dummy;

        IF l_exp_org_csr%NOTFOUND THEN

           close l_exp_org_csr; -- bug 5347506
           G_PREV_EXP_ORG := 'N';
           RETURN 'N';

        ELSE

           close l_exp_org_csr; -- bug 5347506
           G_PREV_EXP_ORG := 'Y';
           RETURN 'Y';

        END IF;

        -- CLOSE l_exp_org_csr; -- bug 5347506

      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      G_PREV_ORG_ID    := x_org_id;
      G_PREV_TXN_DATE  := trunc(x_txn_date);
      G_PREV_EXP_ORG   := 'N';
      RETURN 'N';

  END CheckExpOrg;

        FUNCTION CheckSysLinkFuncActive(x_exp_type IN VARCHAR2,
                                        x_ei_date IN DATE,
                                        x_sys_link_func IN VARCHAR2) RETURN BOOLEAN
        IS

                x_dummy NUMBER DEFAULT 0;

        BEGIN

                select count(*)
                into x_dummy
                from pa_expenditure_types_expend_v
                where x_ei_date between expnd_typ_start_date_active
                                    and nvl(expnd_typ_end_date_active,x_ei_date)
                and   x_ei_date between SYS_LINK_START_DATE_ACTIVE
                                    and nvl(sys_link_end_date_active,x_ei_date)
                and   system_linkage_function = x_sys_link_func
                and   expenditure_type = x_exp_type;

                IF ( x_dummy = 0 ) THEN
                        RETURN ( FALSE );
                ELSE
                        RETURN ( TRUE );
                END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN ( FALSE );
                WHEN OTHERS THEN
                        RAISE;

        END CheckSysLinkFuncActive;

        FUNCTION CheckAdjFlag (x_exp_item_id In Number) RETURN VARCHAR2 IS

        x_return_flag VARCHAR2(1);

        BEGIN

              SELECT NVL(NET_ZERO_ADJUSTMENT_FLAG,'N')
              INTO x_return_flag
              FROM PA_EXPENDITURE_ITEMS
              WHERE EXPENDITURE_ITEM_ID = x_exp_item_id;

              RETURN ( x_return_flag ) ;

        EXCEPTION
              WHEN OTHERS THEN
                      RAISE;

        END CheckAdjFlag;

---------------------------------------------------------------
--=================================================================================
-- These are the new procedures and functions added for Archive / Purge
--=================================================================================

-- ==========================================================================
-- =  FUNCTION  IsSourcePurged
-- ==========================================================================

  FUNCTION  IsSourcePurged ( X_exp_id  IN NUMBER ) RETURN VARCHAR2
  IS
      l_dummy   VARCHAR2(1) := 'N';
  BEGIN
    SELECT
            'Y'
      INTO
            l_dummy
      FROM
            pa_expend_item_adj_activities eia
     WHERE
            eia.expenditure_item_id = X_exp_id
       AND  eia.exception_activity_code = 'SOURCE ITEM PURGED';

    RETURN (  'N' );

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
       RETURN ( 'N' );

    WHEN  OTHERS  THEN
      RAISE ;

  END  IsSourcePurged;

-- ==========================================================================
-- =  FUNCTION  IsDestPurged
-- ==========================================================================

   FUNCTION  IsDestPurged ( X_exp_id  IN NUMBER ) RETURN VARCHAR2
   IS
      l_dummy   VARCHAR2(1) := 'N';
   BEGIN
     SELECT
            'Y'
      INTO
            l_dummy
      FROM
            pa_expend_item_adj_activities eia
     WHERE
            eia.expenditure_item_id = X_exp_id
       AND  eia.exception_activity_code = 'DESTINATION ITEM PURGED';

     RETURN ( l_dummy );

   EXCEPTION
     WHEN  NO_DATA_FOUND  THEN
       RETURN ( 'N' );

     WHEN  OTHERS  THEN
       RAISE ;

   END  IsDestPurged;

-- ==========================================================================
-- =  FUNCTION  IsProjectClosed
-- ==========================================================================

  FUNCTION  IsProjectClosed ( X_project_system_status_code  IN VARCHAR2 ) RETURN VARCHAR2
  IS
      l_dummy   VARCHAR2(1);
  BEGIN
      if X_project_system_status_code in ( 'CLOSED',
                                           'PENDING_PURGE',
                                           'PARTIALLY_PURGED',
                                           'PURGED')  then

           RETURN ( 'Y');
      else
           RETURN ( 'N');
      end if;

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( 'N' );

  END  IsProjectClosed;

-- ==========================================================================
-- =  FUNCTION  IsProjectInPurgeStatus
-- ==========================================================================

  FUNCTION  IsProjectInPurgeStatus ( X_project_system_status_code  IN VARCHAR2 )
                                                              RETURN VARCHAR2
  IS
      l_dummy   VARCHAR2(1);
  BEGIN
      if X_project_system_status_code in ( 'PENDING_PURGE',
                                           'PARTIALLY_PURGED',
                                           'PURGED')  then

           RETURN ( 'Y');
      else
           RETURN ( 'N');
      end if;

  EXCEPTION
    WHEN  OTHERS  THEN
      RETURN ( 'N' );

  END  IsProjectInPurgeStatus;

-- ==========================================================================
-- =  PROCEDURE  IsActivePrjTxnsPurged
-- ==========================================================================

 PROCEDURE IsActivePrjTxnsPurged(p_project_id          IN NUMBER,
                              x_message_code    IN OUT NOCOPY VARCHAR2,
                              x_token           IN OUT NOCOPY DATE)

 is

--    cursor C1 is
--       select pp.txn_to_date
--         from pa_purge_projects pp, pa_purge_batches pb
--        where pp.project_id = p_project_id
--          and pp.purge_batch_id = pb.purge_batch_id
--          and pb.active_closed_flag = 'A' ;
--

    l_txn_to_date      DATE ;

 begin
--    open C1;
--    fetch C1 into l_txn_to_date ;
--    if C1%FOUND then
--       x_message_code := 'PA_TR_APE_PRIOR_TXNS_PURGED' ;
--       x_token        := l_txn_to_date ;
--    end if;
--    close C1;
    NULL ;
 exception
    WHEN others then
        RAISE ;
 end IsActivePrjTxnsPurged ;

-- ==========================================================================
-- =  FUNCTION  IsProjectTxnsPurged
-- ==========================================================================

 function IsProjectTxnsPurged(p_project_id  IN NUMBER) RETURN BOOLEAN

 is

--    cursor C1 is
--       select 'X'
--         from pa_purge_projects pp, pa_purge_batches pb
--        where pp.project_id = p_project_id
--          and pp.purge_batch_id = pb.purge_batch_id
--          and pp.purge_actuals_flag = 'Y'
--          and pb.batch_status_code in ('C','P') ;
--

    l_dummy      VARCHAR2(1);

 begin
--    open C1;
--    fetch C1 into l_dummy ;
--    if C1%FOUND then
--       close C1 ;
--       return TRUE ;
--    end if;
--    close C1;
      return FALSE ;
    NULL ;
 exception
    WHEN others then
        RAISE ;
 end IsProjectTxnsPurged ;

-- ==========================================================================
-- =  FUNCTION  IsProjectCapitalPurged
-- ==========================================================================

 function IsProjectCapitalPurged(p_project_id  IN NUMBER) RETURN BOOLEAN

 is

--    cursor C1 is
--       select 'X'
--         from pa_purge_projects pp, pa_purge_batches pb
--        where pp.project_id = p_project_id
--          and pp.purge_batch_id = pb.purge_batch_id
--          and pp.purge_capital_flag = 'Y'
--          and pb.batch_status_code in ('C','P') ;
--

    l_dummy      VARCHAR2(1);

 begin
--    open C1;
--    fetch C1 into l_dummy ;
--    if C1%FOUND then
--       close C1 ;
--       return TRUE ;
--    end if;
--    close C1;
      return FALSE ;
    NULL ;
 exception
    WHEN others then
        RAISE ;
 end IsProjectCapitalPurged ;

-- ==========================================================================
-- =  FUNCTION  IsProjectBudgetsPurged
-- ==========================================================================

 function IsProjectBudgetsPurged(p_project_id  IN NUMBER) RETURN BOOLEAN

 is

--    cursor C1 is
--       select 'X'
--         from pa_purge_projects pp, pa_purge_batches pb
--        where pp.project_id = p_project_id
--          and pp.purge_batch_id = pb.purge_batch_id
--          and pp.purge_budgets_flag = 'Y'
--          and pb.batch_status_code in ('C','P') ;
--

    l_dummy      VARCHAR2(1);

 begin
--    open C1;
--    fetch C1 into l_dummy ;
--    if C1%FOUND then
--       close C1 ;
--       return TRUE ;
--    end if;
--    close C1;
      return FALSE ;
    NULL ;
 exception
    WHEN others then
        RAISE ;
 end IsProjectBudgetsPurged ;

-- ==========================================================================
-- =  PROCEDURE  IsProjectSummaryPurged
-- ==========================================================================

 function IsProjectSummaryPurged(p_project_id  IN NUMBER) RETURN BOOLEAN

 is

--    cursor C1 is
--       select 'X'
--         from pa_purge_projects pp, pa_purge_batches pb
--        where pp.project_id = p_project_id
--          and pp.purge_batch_id = pb.purge_batch_id
--          and pp.purge_summary_flag = 'Y'
--          and pb.batch_status_code in ('C','P') ;
--

    l_dummy      VARCHAR2(1);

 begin
--    open C1;
--    fetch C1 into l_dummy ;
--    if C1%FOUND then
--       close C1 ;
--       return TRUE ;
--    end if;
--    close C1;
      return FALSE ;
    NULL ;
 exception
    WHEN others then
        RAISE ;
 end IsProjectSummaryPurged ;

 FUNCTION  GetProductRelease  RETURN VARCHAR2 is

   cursor GetRelease is
      select release_name
        from fnd_product_groups ;

  l_dummy    varchar2(50);
 Begin

    open GetRelease ;
    fetch GetRelease into l_dummy ;
    close GetRelease;
    return l_dummy ;
 exception
   when others then
      raise ;
 end GetProductRelease ;

-- ==========================================================================
-- =  FUNCTION  GetLaborCostMultiplier
-- ==========================================================================

 function GetLaborCostMultiplier (x_task_id In Number) RETURN VARCHAR2 IS

        l_lcm_name VARCHAR2(20);

 BEGIN

   IF (x_task_id  = G_PREV_TASK_ID) THEN

      RETURN G_PREV_LCM_NAME;

   ELSE

      G_PREV_TASK_ID := x_task_id;

        SELECT T.labor_cost_multiplier_name
        INTO l_lcm_name
        FROM PA_TASKS T
        WHERE T.task_id  = x_task_id;

       G_PREV_LCM_NAME := l_lcm_name;

        RETURN ( l_lcm_name ) ;

   END IF;

 EXCEPTION
    WHEN OTHERS THEN
      G_PREV_TASK_ID  := x_task_id;
      G_PREV_LCM_NAME := NULL;
      RAISE;

 END GetLaborCostMultiplier;

--=================================================================================


FUNCTION  GetPrjOrgId(p_project_id  NUMBER,
                      p_task_id     NUMBER )
RETURN NUMBER IS

l_org_id    NUMBER ;
BEGIN

  IF (p_project_id = G_PREV_PROJ_ID AND
      p_task_id    = G_PREV_TASK_ID2) THEN

     RETURN (G_PREV_ORG_ID2);

  ELSE

     IF p_project_id IS NOT NULL THEN

        G_PREV_PROJ_ID  := p_project_id;
        G_PREV_TASK_ID2 := p_task_id;

        -- This section of IF is executed if project id is
        -- passed to the function
        SELECT org_id
          INTO l_org_id
          FROM pa_projects_all
         WHERE project_id = p_project_id ;

        G_PREV_ORG_ID2 := l_org_id;

     ELSE

        G_PREV_PROJ_ID  := p_project_id;
        G_PREV_TASK_ID2 := p_task_id;

        -- This section of IF is executed if task_id id is
        -- passed without a project id.

        SELECT p.org_id
          INTO l_org_id
          FROM pa_projects_all p,
               pa_tasks t
         WHERE p.project_id = t.project_id
           AND t.task_id = p_task_id ;

         G_PREV_ORG_ID2 := l_org_id;

     END IF;

     RETURN (l_org_id ) ;

   END IF;

EXCEPTION
  WHEN OTHERS THEN
    G_PREV_PROJ_ID  := p_project_id;
    G_PREV_TASK_ID2 := p_task_id;
    G_PREV_ORG_ID2   := NULL;
    RAISE ;
END GetPrjOrgId ;

--------------------------------------------------------------
/*
 * This procedure will be called from both get_pa_date and get_recvr_pa_date -
 * does caching - accesses the database and populate the global variables.
 * This procedure will hit the database for a given org_id and ei_date and then populates
 * the global variables of either receiver or provider based on the flag ( 'R' or 'P' ).
 */


PROCEDURE refresh_pa_cache (p_org_id IN number , p_ei_date IN date , p_caller_flag IN varchar2 )
IS
-- local variables
  l_earliest_start_date  date ;
  l_earliest_end_date    date ;
  l_earliest_period_name  varchar2(15) ;
  l_pa_date        date ;
  l_start_date     date ;               -- start date for the l_pa_date.
  l_end_date       date ;
  l_period_name    varchar2(15);

  l_stage NUMBER;

BEGIN

  l_stage := 10;
/*
 * SQL to select the earliest open PA_DATE
 * Select the earliest open date only if the global earliest date is not yet populated.
 * Because , earliest pa_date will remain the same for a run.
 */

 IF ( p_caller_flag = 'R' AND g_r_earliest_pa_start_date IS NULL ) OR
    ( p_caller_flag = 'P' AND g_p_earliest_pa_start_date IS NULL ) THEN

  l_stage := 20;
    /*
     * EPP.
     * This sql is modified to get both the start and end dates.
     */
    SELECT pap1.start_date
          ,pap1.end_date
          ,pap1.period_name
      INTO l_earliest_start_date
          ,l_earliest_end_date
          ,l_earliest_period_name
      FROM pa_periods_all pap1
     WHERE pap1.status in ('O','F')
         AND pap1.org_id =  p_org_id /*  Bug#9048873  */
       AND pap1.start_date = ( SELECT MIN (pap.start_date)
                                 FROM pa_periods_all pap
                                WHERE pap.status in ('O','F')
                                  AND pap.org_id =  p_org_id /*  Bug#9048873  */
                             );
  l_stage := 25;
 END IF ;

IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'Y' )    /*For Bug 5391468*/
THEN
  l_stage := 30;
  /*
   * If the profile option is set,
   * -- the pa date should equal the ei date (if the ei date falls in a open
   *    pa period.)
   * -- the pa date should equal the start date of the immediate next open
   *    period (if the ei date doesnt fall in a open period.)
   */

-- SQL to select the PA_DATE of the current EI.

   l_pa_date := NULL;
   l_start_date := NULL;
   l_end_date := NULL;
   l_period_name := NULL;
   /*
    * EPP.
    * This sql has been changed.
    * If the txn falls in an open period, store the start,end dates
    * and period_name for caching purposes.
    */
   BEGIN
  l_stage := 40;
     SELECT p_ei_date
           ,pap.start_date
           ,pap.end_date
           ,pap.period_name
       INTO l_pa_date
           ,l_start_date
           ,l_end_date
           ,l_period_name
      FROM pa_periods_all pap
     WHERE pap.status in ('O','F')
       AND trunc(p_ei_date) between pap.start_date and pap.end_date
       AND pap.org_id = p_org_id ;   --removed nvl for the bug#6343739
   EXCEPTION
     WHEN NO_DATA_FOUND
       THEN
         /*
          * The txn does not fall in a open period.
          * Select the immediate available open or future period.
          */
         SELECT pap1.start_date
               ,pap1.start_date
               ,pap1.end_date
               ,pap1.period_name
           INTO l_pa_date
               ,l_start_date
               ,l_end_date
               ,l_period_name
           FROM pa_periods_all pap1
          WHERE pap1.status in ('O','F')
            AND nvl( pap1.org_id, -99 ) = nvl( p_org_id, -99 )
            AND pap1.start_date = ( SELECT MIN (pap.start_date)
                                      FROM pa_periods_all pap
                                     WHERE pap.status in ('O','F')
                                       AND  pap.org_id = p_org_id --removed nvl for the bug#6343739
                                       AND trunc(p_ei_date) <= pap.start_date
                                  );
   END; -- local block

      if ( p_caller_flag = 'R' ) then
         -- Populate receiver cache.
         g_r_earliest_pa_start_date  := l_earliest_start_date ;
         g_r_earliest_pa_end_date    := l_earliest_end_date ;
         g_r_earliest_pa_period_name := l_earliest_period_name ;

         g_recvr_pa_start_date  := l_start_date ;
         g_recvr_pa_end_date    := l_end_date ;
         g_recvr_pa_period_name := l_period_name;

         g_recvr_pa_date  := l_pa_date;
         g_recvr_org_id   := p_org_id ;
      else
        if ( p_caller_flag = 'P' ) then
            -- Populate provider cache
            g_p_earliest_pa_start_date  := l_earliest_start_date ;
            g_p_earliest_pa_end_date    := l_earliest_end_date ;
            g_p_earliest_pa_period_name := l_earliest_period_name ;

            g_prvdr_pa_start_date  := l_start_date ;
            g_prvdr_pa_end_date    := l_end_date ;
            g_prvdr_pa_period_name := l_period_name ;

            g_prvdr_pa_date  := l_pa_date ;
            g_prvdr_org_id   := p_org_id ;
        end if ;
      end if;

ELSE -- profile is NOT set.
  l_stage := 26;

  /*
   * If the profile option NOT set,
   * -- the pa dates should equal the end date of the period (if the ei date
   *    falls in the respective open periods.)
   * -- the pa date should equal the end date of the immediate next open
   *    period (if the ei date doesnt fall in a open period.)
   */

-- SQL to select the PA_DATE of the current EI.

   l_pa_date := NULL;
   l_start_date := NULL;
   l_end_date := NULL;
   l_period_name := NULL;
   /*
    * pa_gl period related changes:
    * This sql has been changed.
    * If the txn falls in an open period, store the start and end dates
    * of that period for caching purposes.
    */
   BEGIN
  l_stage := 27;
     SELECT pap.end_date
           ,pap.start_date
           ,pap.end_date
           ,pap.period_name
       INTO l_pa_date
           ,l_start_date
           ,l_end_date
           ,l_period_name
      FROM pa_periods_all pap
     WHERE pap.status in ('O','F')
       AND trunc(p_ei_date) between pap.start_date and pap.end_date
       AND pap.org_id = p_org_id; /*removed nvl for bug 9284457  */
  l_stage := 28;
   EXCEPTION
     WHEN NO_DATA_FOUND
       THEN
         /*
          * The txn does not fall in a open period.
          * Select the immediate available open or future period.
          */
         SELECT pap1.end_date
               ,pap1.start_date
               ,pap1.end_date
               ,pap1.period_name
           INTO l_pa_date
               ,l_start_date
               ,l_end_date
               ,l_period_name
           FROM pa_periods_all pap1
          WHERE pap1.status in ('O','F')
           AND  pap1.org_id =  p_org_id /*  Bug#9048873 */
            AND pap1.start_date = ( SELECT MIN (pap.start_date)
                                      FROM pa_periods_all pap
                                     WHERE pap.status in ('O','F')
                                       AND pap.org_id =  p_org_id /*  Bug#9048873 */
                                       AND trunc(p_ei_date) <= pap.start_date
                                  );
  l_stage := 29;
   END; -- local block
  l_stage := 31;

      if ( p_caller_flag = 'R' ) then
  l_stage := 32;
         -- Populate receiver cache.
         g_r_earliest_pa_start_date  := l_earliest_start_date ;
  l_stage := 321;
         g_r_earliest_pa_end_date    := l_earliest_end_date ;
  l_stage := 322;
         g_r_earliest_pa_period_name := l_earliest_period_name ;
  l_stage := 323;

         g_recvr_pa_start_date  := l_start_date ;
  l_stage := 324;
         g_recvr_pa_end_date    := l_end_date ;
  l_stage := 325;
         g_recvr_pa_period_name := l_period_name;
  l_stage := 326;

         g_recvr_pa_date := l_pa_date;
  l_stage := 327;
         g_recvr_org_id  := p_org_id ;
  l_stage := 356;
      else
  l_stage := 33;
        if ( p_caller_flag = 'P' ) then
  l_stage := 34;
            -- Populate provider cache
            g_p_earliest_pa_start_date  := l_earliest_start_date ;
            g_p_earliest_pa_end_date    := l_earliest_end_date ;
            g_p_earliest_pa_period_name := l_earliest_period_name ;

            g_prvdr_pa_start_date  := l_start_date ;
            g_prvdr_pa_end_date    := l_end_date ;
            g_prvdr_pa_period_name := l_period_name ;

            g_prvdr_pa_date    := l_pa_date ;
            g_prvdr_org_id     := p_org_id ;
        end if ;
      end if;

END IF ; -- profile option check.

EXCEPTION
  WHEN no_data_found THEN
    if ( p_caller_flag = 'P' ) then
      g_prvdr_pa_date := NULL ;
      g_prvdr_pa_period_name := NULL ;
/** Added for 2810747 **/
      g_prvdr_pa_start_date := NULL;
      g_prvdr_pa_end_date := NULL;
/** End Added for 2810747 **/
    /*elsif ( p_caller_flag = 'P' ) then    Bug2724294*/
    elsif ( p_caller_flag = 'R' ) then
      g_recvr_pa_date := NULL ;
      g_recvr_pa_period_name := NULL ;
/** Added for 2810747 **/
      g_recvr_pa_start_date := NULL;
      g_recvr_pa_end_date   := NULL;
/** End Added for 2810747 **/
    end if;
  WHEN others THEN
    RAISE ;

END refresh_pa_cache ;
--=================================================================================
-- Function  : get_pa_date
--      Derive PA date from GL date and ei date .
-- This function accepts the expenditure item date and the GL date
-- and derives the period name based on this.  This is mainly used
-- for AP invoices and transactions imported from other systems
-- where the GL date is known in advance and the PA date has to
-- be determined. In the current logic, the PA date is derived solely
-- based on the EI date. The GL date which is passed as a parameter is
-- ignored. However, it is still retained as a parameter in case the
-- logic for the derivation of the PA date is changed on a later date.
-----------------------------------------------------------------------

/**This function was previously part-of pa_utils.
 **It was moved here and changed for CBGA and caching.
 **/

FUNCTION get_pa_date( p_ei_date IN date, p_gl_date IN date, p_org_id IN number) return date
IS
BEGIN

/**
Global variables for the Provider Cache.
    g_prvdr_org_id, g_prvdr_earliest_pa_date, g_prvdr_pa_start_date, g_prvdr_pa_end_date,
    g_prvdr_pa_date

Logic :-
~~~~~
If the Cache is NOT already populated,
         access DB, populate cache and return g_pa_date.
If it is already populated, check if the p_ei_date falls between start and end dates of the
  cache. If yes, return g_pa_date from the cache.
  If the p_ei_date doesnt' fall between the start and end dates, chek if its lesser
  than the earliest available pa_date. If YES, return g_earliest_pa_date.
If NO, access the DB and refresh the cache and return new g_pa_date.
**/

-- Coding Starts
  /*
   * Validate the input parameters.
   * If the essential input parameters have NULL values, set the global variables
   * appropriately and return NULL value.
   */
  IF ( p_ei_date IS NULL )
  THEN
    return NULL;
  END IF;

  IF ( g_p_earliest_pa_start_date IS NOT NULL
       and nvl(p_org_id,-99) = nvl(g_prvdr_org_id,-99) ) /* 1982225. check the orgs before accessing cache */
  THEN
    -- values are already available in the provider_cache.
    -- so, check the provider_cache and return pa_date accordingly.

    IF  ( p_ei_date BETWEEN g_prvdr_pa_start_date AND g_prvdr_pa_end_date )
    THEN
      IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'Y' )     /*For Bug 5391468 */
      THEN
        return ( p_ei_date ) ;
      ELSE
        return ( g_prvdr_pa_end_date ) ;
      END IF; -- profile
    ELSE
      IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'Y' )     /*For Bug 5391468*/
      THEN
        IF ( p_ei_date <= g_p_earliest_pa_start_date )
        THEN
          g_prvdr_pa_start_date  := g_p_earliest_pa_start_date;
          g_prvdr_pa_end_date    := g_p_earliest_pa_end_date;
          g_prvdr_pa_period_name := g_p_earliest_pa_period_name;
          return (g_prvdr_pa_start_date) ;
        ELSIF ( p_ei_date <= g_p_earliest_pa_end_date )
        THEN
          g_prvdr_pa_start_date  := g_p_earliest_pa_start_date;
          g_prvdr_pa_end_date    := g_p_earliest_pa_end_date;
          g_prvdr_pa_period_name := g_p_earliest_pa_period_name;
          return ( g_prvdr_pa_end_date ) ;
        END IF; -- p_ei_date
      END IF; -- profile
    END IF ; -- p_ei_date
  END IF ; -- g_prvdr_earliest_pa_date

     -- If control comes here, it means that either the cache is empty or
     -- the provider Cache is not reusable.
     -- Access the DB and refresh cache and return pa_date.

     pa_utils2.refresh_pa_cache( p_org_id , p_ei_date, 'P' );
     /*
      * Here we can return g_prvdr_pa_date - because the profile option
      * is taken care during the refresh_pa_cache.
      */
     return ( g_prvdr_pa_date ) ;
EXCEPTION
    WHEN OTHERS THEN
      RAISE ;
END get_pa_date ;


/* Functions derive pa_date_profile() and pa_period_name_profile() added as as part of BUG# 3384892 */
/* caching the value of the profile PA_EN_NEW_GLDATE_DERIVATION */

FUNCTION pa_date_profile(exp_item_date IN DATE, accounting_date IN DATE, org_id IN NUMBER)
RETURN DATE  IS
l_return_date DATE;
BEGIN
        IF g_profile_cache_first_time = 'Y'  THEN
           g_profile_value := fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION');  /*For Bug 5391468*/
           g_profile_cache_first_time :='N' ;
        END IF;

        SELECT decode(nvl(g_profile_value,'N'),
           'Y', pa_utils2.get_pa_date( exp_item_date,accounting_date,org_id),
           'N', pa_integration.get_raw_cdl_pa_date(exp_item_date,accounting_date,org_id))
        INTO  l_return_date
        FROM  DUAL;
        RETURN l_return_date;
END pa_date_profile;

FUNCTION pa_period_name_profile
RETURN VARCHAR2 IS
l_return_name varchar2(25);
BEGIN
        IF g_profile_cache_first_time = 'Y'  THEN
            g_profile_value := fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION');/*For Bug 5391468*/
            g_profile_cache_first_time :='N' ;
        END IF;

        SELECT decode(nvl(g_profile_value,'N'),
           'Y', pa_utils2.get_period_name(),
           'N', pa_integration.get_period_name())
        INTO  l_return_name
        FROM  DUAL;
        RETURN l_return_name;
END  pa_period_name_profile;

--------------------------------------------------------------
-- Function  : get_recvr_pa_date
-- Included during CBGA changes.
--      Derive PA date from GL date and ei date .
-- This function accepts the expenditure item date and the GL date
-- and derives the period name based on this.  This is mainly used
-- for AP invoices and transactions imported from other systems
-- where the GL date is known in advance and the PA date has to
-- be determined. In the current logic, the PA date is derived solely
-- based on the EI date. The GL date which is passed as a parameter is
-- ignored. However, it is still retained as a parameter in case the
-- logic for the derivation of the PA date is changed on a later date.
-----------------------------------------------------------------------

-- Global variables for receiver cache.
--     g_recvr_org_id, g_recvr_earliest_pa_date, g_recvr_start_date, g_recvr_end_date,
--     g_recvr_pa_date

/**
Logic :-
~~~~~
 If the receiver cache is already populated,
   Try using the receiver cache.
   If its not reusable,
   Try using the provider cache.
 If either receiver cache is EMPTY or  both provider and receiver are reusable,
 hit the DB and populate/refresh receiver cache.
**/

FUNCTION get_recvr_pa_date( p_ei_date  IN date, p_gl_date IN date , p_org_id IN number ) return date
IS
  l_stage NUMBER ;
BEGIN
 l_stage := 100;

  /*
   * Validate the input parameters.
   * If the essential input parameters have NULL values, set the global variables
   * appropriately and return NULL value.
   */
  IF ( p_ei_date IS NULL )
  THEN
    l_stage := 200;
    return NULL;
  END IF;

IF ( g_r_earliest_pa_start_date IS NOT NULL
     and nvl(p_org_id,-99) = nvl(g_recvr_org_id,-99) ) /* 1982225. check the orgs before accessing cache */
THEN
    l_stage := 300;
     -- receiver cache is available.
     -- should try to re-use the receiver cache.

      IF ( p_ei_date BETWEEN g_recvr_pa_start_date AND g_recvr_pa_end_date )
      THEN
    l_stage := 400;
        IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'Y' )    /* For Bug 5391468 */
        THEN
    l_stage := 500;
          return ( p_ei_date ) ;
        ELSE
    l_stage := 600;
          return ( g_recvr_pa_end_date ) ;
        END IF ; -- profile
      ELSE
    l_stage := 700;
        IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'Y' )    /*For Bug 5391468 */
        THEN
    l_stage := 800;
          IF ( p_ei_date <= g_r_earliest_pa_start_date )
          THEN
    l_stage := 900;
            g_recvr_pa_start_date  := g_r_earliest_pa_start_date ;
            g_recvr_pa_end_date    := g_r_earliest_pa_end_date ;
            g_recvr_pa_period_name := g_r_earliest_pa_period_name ;
            return ( g_r_earliest_pa_start_date ) ;
          END IF; -- p_ei_date
        ELSIF (p_ei_date <= g_r_earliest_pa_end_date )
        THEN
    l_stage := 1000;
          g_recvr_pa_start_date  := g_r_earliest_pa_start_date ;
          g_recvr_pa_end_date    := g_r_earliest_pa_end_date ;
          g_recvr_pa_period_name := g_r_earliest_pa_period_name ;
          return ( g_r_earliest_pa_end_date ) ;
        END IF; -- profile
      END IF ; -- p_ei_date
ELSE
        l_stage := 110;
    -- receiver cache is empty.
    -- should try to use the provider cache.

  IF ( nvl( g_prvdr_org_id, -99 ) = nvl( p_org_id, -99 )
       and g_p_earliest_pa_start_date IS NOT NULL )  /* 1982225. check if prvdr cache is available or not */
  THEN
    l_stage := 1100;
      IF ( p_ei_date BETWEEN g_prvdr_pa_start_date AND g_prvdr_pa_end_date )
      THEN
    l_stage := 1200;

         -- copy provider cache to receiver cache.
         g_recvr_org_id               := g_prvdr_org_id ;
         g_recvr_pa_date              := g_prvdr_pa_date ;
         g_r_earliest_pa_start_date   := g_p_earliest_pa_start_date  ;
         g_r_earliest_pa_end_date     := g_p_earliest_pa_end_date  ;
         g_r_earliest_pa_period_name  := g_p_earliest_pa_period_name ;
         g_recvr_pa_start_date        := g_prvdr_pa_start_date ;
         g_recvr_pa_end_date          := g_prvdr_pa_end_date ;
         g_recvr_pa_period_name       := g_prvdr_pa_period_name ;

         IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'Y' )   /*For Bug 5391468*/
         THEN
    l_stage := 1300;
           return ( p_ei_date ) ;
         ELSE
    l_stage := 1400;
           return ( g_recvr_pa_end_date ) ;
         END IF ; -- profile
      ELSE
    l_stage := 1500;
        IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'Y' )    /*For Bug 5391468*/
        THEN
    l_stage := 1600;
          IF (p_ei_date <= g_p_earliest_pa_start_date )
          THEN
    l_stage := 1700;
            -- copy provider cache to receiver cache.
            g_recvr_org_id               := g_prvdr_org_id ;
            g_r_earliest_pa_start_date   := g_p_earliest_pa_start_date  ;
            g_r_earliest_pa_end_date     := g_p_earliest_pa_end_date  ;
            g_r_earliest_pa_period_name  := g_p_earliest_pa_period_name  ;
            g_recvr_pa_start_date        := g_p_earliest_pa_start_date ;
            g_recvr_pa_end_date          := g_p_earliest_pa_end_date ;
            g_recvr_pa_period_name       := g_p_earliest_pa_period_name ;

            g_recvr_pa_date              := g_r_earliest_pa_start_date ;
            return ( g_r_earliest_pa_start_date ) ;
          END IF; -- p_ei_date
        ELSE
          IF ( p_ei_date <= g_p_earliest_pa_end_date )
          THEN
            -- copy provider cache to receiver cache.
            g_recvr_org_id               := g_prvdr_org_id ;
            g_r_earliest_pa_start_date   := g_p_earliest_pa_start_date  ;
            g_r_earliest_pa_end_date     := g_p_earliest_pa_end_date  ;
            g_r_earliest_pa_period_name  := g_p_earliest_pa_period_name  ;
            g_recvr_pa_start_date        := g_p_earliest_pa_start_date ;
            g_recvr_pa_end_date          := g_p_earliest_pa_end_date ;
            g_recvr_pa_period_name       := g_p_earliest_pa_period_name ;

            g_recvr_pa_date              := g_r_earliest_pa_end_date ;
            return ( g_r_earliest_pa_end_date ) ;
          END IF; -- p_ei_date
        END IF ; -- profile
      END IF ; -- p_ei_date
  END IF ; -- org_id
END IF ;  -- g_r_earliest_pa_start_date
/**
 **If control comes here,
 **either receiver cache is EMPTY or ( Both provider AND receiver caches are not reusable )
 **hence hit the DB and populate/refresh receiver cache.
 **then return g_recvr_pa_date.
**/

    pa_utils2.refresh_pa_cache ( p_org_id , p_ei_date , 'R' );
    return ( g_recvr_pa_date ) ;
EXCEPTION
    WHEN OTHERS THEN
      RAISE ;
END get_recvr_pa_date ;
-----------------------------------------------------------------------
PROCEDURE populate_gl_dates( p_local_set_size           IN NUMBER,
                             p_application_id            IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_request_id                IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_cdl_rowid                 IN PA_PLSQL_DATATYPES.Char30TabTyp ,
                             p_prvdr_sob_id              IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_recvr_sob_id              IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_expnd_id                  IN PA_PLSQL_DATATYPES.IDTabTyp ,
                             p_sys_linkage_type          IN VARCHAR2
                            )

IS
l_prvdr_gl_date_tab    PA_PLSQL_DATATYPES.DateTabTyp ;
l_recvr_gl_date_tab    PA_PLSQL_DATATYPES.DateTabTyp ;
l_pa_date              PA_PLSQL_DATATYPES.DateTabTyp ;
l_recvr_pa_date        PA_PLSQL_DATATYPES.DateTabTyp ;
l_reject_meaning       VARCHAR2(81);

l_gl_date_old          PA_PLSQL_DATATYPES.DateTabTyp ;
l_gl_period_old        PA_PLSQL_DATATYPES.Char15TabTyp ;
l_recvr_org_id         PA_PLSQL_DATATYPES.IDTabTyp ;

/** Bug 3668005 Begins **/
l_gl_date_new          PA_PLSQL_DATATYPES.DateTabTyp ;
l_gl_period_new        PA_PLSQL_DATATYPES.Char15TabTyp ;
l_recvr_gl_date_new    PA_PLSQL_DATATYPES.DateTabTyp ;
l_recvr_gl_period_new  PA_PLSQL_DATATYPES.Char15TabTyp ;
p_USER_ID               CONSTANT NUMBER := FND_GLOBAL.user_id;
l_err_code              NUMBER ;
l_err_stage             VARCHAR2(2000);
l_err_stack             VARCHAR2(255) ;
l_cwk_lab_to_gl         pa_implementations_all.XFACE_CWK_LABOR_TO_GL_FLAG%type;
l_labor_to_gl           pa_implementations_all.interface_labor_to_gl_flag%type;
l_usage_to_gl           pa_implementations_all.interface_usage_to_gl_flag%type;
l_interface_to_gl       PA_PLSQL_DATATYPES.Char1TabTyp;

-- Bug 4374769 : The following variables are introduced as part of this bug.
v_gl_per_end_dt		DATE;
l_adj_exp_item_id       pa_expenditure_items_all.adjusted_expenditure_item_id%type;
l_exp_item_id           pa_expenditure_items_all.expenditure_item_id%type;
l_gl_date               DATE;
l_pji_summarized_flag   VARCHAR2(1);
l_prvdr_accr_date       DATE;
l_billable_flag         pa_cost_distribution_lines_all.billable_flag%type;
l_line_type             VARCHAR2(1);
l_line_num              NUMBER ;
l_denom_currency_code   pa_expenditure_items_all.denom_currency_code%type;
l_acct_currency_code    pa_expenditure_items_all.acct_currency_code%type;
l_acct_rate_date        pa_expenditure_items_all.acct_rate_date%type;
l_acct_rate_type        pa_expenditure_items_all.acct_rate_type%type;
l_acct_exchange_rate    pa_expenditure_items_all.acct_exchange_rate%type;
l_project_currency_code pa_expenditure_items_all.project_currency_code%type;
l_project_rate_date     pa_expenditure_items_all.project_rate_date%type;
l_project_rate_type     pa_expenditure_items_all.project_rate_type%type;
l_project_exchange_rate          pa_expenditure_items_all.project_exchange_rate%type;
l_projfunc_currency_code         pa_expenditure_items_all.projfunc_currency_code%type;
l_projfunc_cost_rate_date        pa_expenditure_items_all.projfunc_cost_rate_date%type;
l_projfunc_cost_rate_type        pa_expenditure_items_all.projfunc_cost_rate_type%type;
l_projfunc_cost_exchange_rate    pa_expenditure_items_all.projfunc_cost_exchange_rate%type;
l_work_type_id                   pa_expenditure_items_all.work_type_id%type;
l_sob_id                         pa_implementations.set_of_books_id%type;


-- Cursor to pick up all CDLs with intermediate status 'Y' for creation of
-- reversing and new CDLs .

/* Bug 4374769     : The cursor c_sel_cdl is modified to also select the line_num for a cdl with transfer_status_code as 'Y'.
		     This line_num is passed to Pa_Costing.ReverseCdl when it is being called from the
		     populate_gl_dates procedure to create reversing and new lines for the line_num that is being passed. */

Cursor c_sel_cdl Is
        SELECT
                ei.expenditure_item_id,
                cdl.billable_flag,
                cdl.line_type,
		cdl.line_num,          -- Added as part of Bug 4374769
                ei.transaction_source,
                tr.gl_accounted_flag,
                ei.denom_currency_code,
                ei.acct_currency_code,
                ei.acct_rate_date,
                ei.acct_rate_type,
                ei.acct_exchange_rate,
                ei.project_currency_code,
                ei.project_rate_date,
                ei.project_rate_type,
                ei.project_exchange_rate,
                tr.system_linkage_function,
                ei.projfunc_currency_code,
                ei.projfunc_cost_rate_date,
                ei.projfunc_cost_rate_type,
                ei.projfunc_cost_exchange_rate,
                ei.work_type_id
        FROM  pa_expenditure_items_all ei,
              pa_cost_distribution_lines cdl,
              pa_transaction_sources tr
        WHERE tr.transaction_source(+) = ei.transaction_source
        AND   ei.expenditure_item_id = cdl.expenditure_item_id
        AND   CDL.Transfer_Status_Code = 'Y';

/** Bug 3668005 ends **/

BEGIN



  select interface_labor_to_gl_flag , interface_usage_to_gl_flag , XFACE_CWK_LABOR_TO_GL_FLAG , set_of_books_id
  Into   l_labor_to_gl , l_usage_to_gl , l_cwk_lab_to_gl , l_sob_id
  from   pa_implementations;

/* Bug 4374769    : If the populate_gl_dates procedure is called for miscellaneous transactions for which the "Reverse Expenditure in a future period"
                    is checked then the "PRC: Interface Usage and Miscellaneous costs to General Ledger" calls this procedure with the
		    p_sys_linkage_type parameter as 'PJ' for the CDLs of reversing EI.  */

IF (p_sys_linkage_type = 'PJ') THEN

	SELECT
	        ei.expenditure_item_id,
		ei.adjusted_expenditure_item_id,
		cdl.gl_date,
		cdl.pji_summarized_flag,
                cdl.billable_flag,
                cdl.line_type,
		cdl.line_num,
                ei.denom_currency_code,
                ei.acct_currency_code,
                ei.acct_rate_date,
                ei.acct_rate_type,
                ei.acct_exchange_rate,
                ei.project_currency_code,
                ei.project_rate_date,
                ei.project_rate_type,
                ei.project_exchange_rate,
                ei.projfunc_currency_code,
                ei.projfunc_cost_rate_date,
                ei.projfunc_cost_rate_type,
                ei.projfunc_cost_exchange_rate,
                ei.work_type_id
	   INTO l_exp_item_id,
	        l_adj_exp_item_id,
		l_gl_date,
		l_pji_summarized_flag,
		l_billable_flag,
                l_line_type,
		l_line_num,
                l_denom_currency_code,
                l_acct_currency_code,
                l_acct_rate_date,
                l_acct_rate_type,
                l_acct_exchange_rate,
                l_project_currency_code,
                l_project_rate_date,
                l_project_rate_type,
                l_project_exchange_rate,
                l_projfunc_currency_code,
                l_projfunc_cost_rate_date,
                l_projfunc_cost_rate_type,
                l_projfunc_cost_exchange_rate,
                l_work_type_id
	   FROM PA_COST_DISTRIBUTION_LINES_ALL CDL,
	        PA_EXPENDITURE_ITEMS_ALL EI
          WHERE CDL.EXPENDITURE_ITEM_ID = EI.EXPENDITURE_ITEM_ID
	    AND CDL.ROWID = chartorowid( p_cdl_rowid(1));

/* Bug 4374769     : The code in the "PRC: Interface and Usage Transactions to General Ledger" process that updated the CDLs of reversing EI with
                     next GL period of CDL of original EI, is shifted to populate_gl_dates as below */

/* Bug 4374769 :  The following query selects the end_date of the GL period stamped on the 'R' line of the original expenditure item. */

	 SELECT  GPS.end_date
           INTO  v_gl_per_end_dt
           FROM  pa_cost_distribution_lines CDL,
                 gl_period_statuses         GPS
          WHERE  GPS.application_id = 101
            AND  GPS.set_of_books_id = l_sob_id
            AND  GPS.adjustment_period_flag = 'N'
            AND  CDL.expenditure_item_id = l_adj_exp_item_id
            AND  CDL.gl_date BETWEEN GPS.start_date AND  GPS.end_date
	    AND  CDL.LINE_TYPE = 'R';

/* Bug 4374769 :  	If the date selected in the above query is greater than or equal to the GL date on the cdl of the reversing EI and
                             a) If the PJI_Summarized_flag on the cdl is 'N' then we directly update the GL_Date of the cdl with the start date
			        of a GL Period that is next to that of the cdl of the original EI.
                             b) If the the PJI_Summarized_flag on the cdl is NULL then the ReverseCdl procedure is called to create the reversing
			        and new 'I' lines. Finally we update the GL_Date of the 'R' and the new 'I' line with the start date of a GL Period
				that is next to that of the cdl of the original EI. */

	 IF (l_gl_date <= v_gl_per_end_dt) THEN

		SELECT GPS.start_date
                        INTO   l_prvdr_accr_date
                        FROM   gl_period_statuses GPS
                        WHERE  GPS.application_id = 101
                        AND    GPS.set_of_books_id = l_sob_id
                        AND    GPS.adjustment_period_flag = 'N'
                        AND    GPS.start_date = (SELECT min(GPS1.start_date)
                                                 FROM   gl_period_statuses GPS1
                                                 WHERE  GPS1.application_id = 101
                                                 AND    GPS1.set_of_books_id = l_sob_id
                                                 AND    GPS1.adjustment_period_flag = 'N'
                                                 AND    GPS1.start_date > v_gl_per_end_dt);


		IF (l_pji_summarized_flag  = 'N') THEN

		   UPDATE PA_Cost_Distribution_lines CDL
	              SET CDL.gl_date = l_prvdr_accr_date
		    WHERE CDL.ROWID = chartorowid( p_cdl_rowid(1))
                    AND CDL.TRANSFER_STATUS_CODE in ('P','R');

		ELSE

		            Pa_Costing.ReverseCdl
                                (  X_expenditure_item_id            =>  l_exp_item_id
                                 , X_billable_flag                  =>  l_billable_flag
                                 , X_amount                         =>  NULL
                                 , X_quantity                       =>  NULL
                                 , X_burdened_cost                  =>  NULL
                                 , X_dr_ccid                        =>  NULL
                                 , X_cr_ccid                        =>  NULL
                                 , X_tr_source_accounted            =>  'Y'
                                 , X_line_type                      =>  l_line_type
                                 , X_user                           =>  p_user_id
                                 , X_denom_currency_code            =>  l_denom_currency_code
                                 , X_denom_raw_cost                 =>  NULL
                                 , X_denom_burden_cost              =>  NULL
                                 , X_acct_currency_code             =>  l_acct_currency_code
                                 , X_acct_rate_date                 =>  l_acct_rate_date
                                 , X_acct_rate_type                 =>  l_acct_rate_type
                                 , X_acct_exchange_rate             =>  l_acct_exchange_rate
                                 , X_acct_raw_cost                  =>  NULL
                                 , X_acct_burdened_cost             =>  NULL
                                 , X_project_currency_code          =>  l_project_currency_code
                                 , X_project_rate_date              =>  l_project_rate_date
                                 , X_project_rate_type              =>  l_project_rate_type
                                 , X_project_exchange_rate          =>  l_project_exchange_rate
                                 , X_err_code                       =>  l_err_code
                                 , X_err_stage                      =>  l_err_stage
                                 , X_err_stack                      =>  l_err_stack
                                 , P_Projfunc_currency_code         =>  l_projfunc_currency_code
                                 , P_Projfunc_cost_rate_date        =>  l_projfunc_cost_rate_date
                                 , P_Projfunc_cost_rate_type        =>  l_projfunc_cost_rate_type
                                 , P_Projfunc_cost_exchange_rate    =>  l_projfunc_cost_exchange_rate
                                 , P_project_raw_cost               =>  null
                                 , P_project_burdened_cost          =>  null
                                 , P_Work_Type_Id                   =>  l_work_type_id
                                 , P_mode                           =>  'INTERFACE'
				 , X_line_num                       =>  l_line_num
                                 );

			UPDATE PA_Cost_Distribution_lines CDL
			 SET CDL.GL_DATE = l_prvdr_accr_date,
			     CDL.GL_PERIOD_NAME = pa_utils2.get_gl_period_name (l_prvdr_accr_date,CDL.org_id)
			 WHERE CDL.EXPENDITURE_ITEM_ID = l_exp_item_id
			  AND CDL.LINE_NUM_REVERSED IS NULL
                          AND CDL.TRANSFER_STATUS_CODE in ('P','R','G');


		END IF;


	 END IF;


End If;

/*
 *The calculation of pa_date used to arrive at the gl_date varies between
 *Expense reports ( sys_link 'ER' ) and non Expense reports.
 *The pa_date to be passed to the functions get_prvdr_gl_date/get_recvr_gl_date
 *is calculated accordingly based on the sys_linkage value passed.
 */

IF (p_sys_linkage_type = 'ER') THEN
  -- Decide the rejection reason.
  /*
   * The SQL can be moved within the FORALL.
   * But, since the SELECT is kind-of static i.e., its enough
   * that it be executed only once per call, i'm  retaining it here.
   * In-fact because of its staticness, it can be even moved out of this
   * package and retained in patmv.lpc and the reject_reason can be passed
   * as parameter.
   */
  SELECT  Meaning
    INTO  l_reject_meaning
    FROM  PA_Lookups LOOK
   WHERE  LOOK.Lookup_Type = 'TRANSFER REJECTION CODE'
     AND  LOOK.Lookup_Code = 'TRANS_INV_DATA';

  FORALL i IN 1..p_local_set_size
    UPDATE   PA_Cost_Distribution_lines CDL
           SET   CDL.request_id = p_request_id(i)
                ,CDL.transfer_rejection_reason = l_reject_meaning
                ,CDL.transfer_status_code = 'X'
                ,CDL.Transferred_Date = SYSDATE
/*
 * Bug#2085814
 * -- Since gl period information is getting populated during costing, it is no
 * -- longer needed to populate GL info during transfer to AP.
 * -- Ideally this procedure itself need not be called from patmv.lpc. The updates
 * -- to other columns like request_id can be done in patmv.lpc itself.
 * -- Calling this procedure from pro*C requires some array related processing which
 * -- can be avoided if this procedure is not called from pro*C. This change has to
 * -- be done - at some point of time.
 *
 *              ,CDL.GL_Date       = ( SELECT pa_utils2.get_prvdr_gl_date(
 *                                                 MAX(CDL.pa_date)
 *                                                ,p_application_id(i)
 *                                                ,p_prvdr_sob_id(i))
 *                                       FROM   pa_cost_distribution_lines CDL,
 *                                              pa_expenditure_items ITEM
 *                                      WHERE   ITEM.expenditure_item_id = CDL.expenditure_item_id
 *                                        AND   CDL.line_type = 'R'
 *                                        AND   ITEM.expenditure_id = p_expnd_id(i)
 *                                    )
 *              ,CDL.Recvr_Gl_Date = ( SELECT pa_utils2.get_recvr_gl_date(
 *                                                 MAX(CDL.recvr_pa_date)
 *                                                ,p_application_id(i)
 *                                                ,p_recvr_sob_id(i))
 *                                       FROM   pa_cost_distribution_lines CDL,
 *                                              pa_expenditure_items ITEM
 *                                      WHERE   ITEM.expenditure_item_id = CDL.expenditure_item_id
 *                                        AND   CDL.line_type = 'R'
 *                                        AND   ITEM.expenditure_id = p_expnd_id(i)
 *                                    )
 */
        WHERE    CDL.Transfer_Status_Code || '' IN ('P','R')
        AND      CDL.line_type = 'R'
        AND      CDL.Batch_name IS NOT NULL
        AND      CDL.Expenditure_Item_ID IN
                 (
                 SELECT  ITEM.Expenditure_Item_ID
                 FROM    PA_Expenditure_Items ITEM
                 WHERE   ITEM.Cost_Distributed_Flag||'' = 'S'
                   AND   ITEM.expenditure_id = p_expnd_id(i)
                 );
ELSE
  -- If the sys_linkage received is NOT Expense-report.

/* Enhanced Period Processing : Commenting the code the gl_date Recvr_gl_date updation, This will
   Populated during Distributing the cost */

/****************** Bug 3668005 : GL Derivation Changes for M .************************
 Now in interface process the GL date will be derived for those CDLs
 whose GL dates fall in closed GL periods.
   (1)If these CDLs have not been summarized the CDLs would be updated.
   (2)If these CDLs have been summarized then the CDL would be reversed and a new line
      created with the rederived GL date while all other attribute would remain same
      including the PA Dates.
****************************************************************************************/

IF gms_pa_api2.is_grants_enabled = 'N' THEN

-- Commented for Bug 4374769
 /* select interface_labor_to_gl_flag , interface_usage_to_gl_flag , XFACE_CWK_LABOR_TO_GL_FLAG
  Into   l_labor_to_gl , l_usage_to_gl , l_cwk_lab_to_gl
  from   pa_implementations; */

  --Get the GL Info into PLSQL table for all the CDL_row_Ids passed to this procedure .
  FOR i IN 1..p_local_set_size
  LOOP
/* 4130583 - The following SELECT raises "no data found" exception if the interface flag
   corresponding to the CDL is unchecked. The exception block will set the date and
   period values in the local PL/SQL table to NULL and set l_interface_to_gl(i) to 'N' */


      BEGIN
        Select
                pa_utils2.get_prvdr_gl_date(
                                        CDL.gl_date
                                       ,p_application_id(i)
                                       ,p_prvdr_sob_id(i))  gl_date,
                pa_utils2.get_gl_period_name (
                                        pa_utils2.get_prvdr_gl_date(
                                           CDL.gl_date
                                          ,p_application_id(i)
                                          ,p_prvdr_sob_id(i))
                                          ,CDL.org_id) gl_period_name,
                pa_utils2.get_recvr_gl_date(
                                        CDL.recvr_gl_date
                                       ,p_application_id(i)
                                       ,p_recvr_sob_id(i)) recvr_gl_date,
                pa_utils2.get_gl_period_name (
                                        pa_utils2.get_recvr_gl_date(
                                                CDL.recvr_gl_date
                                               ,p_application_id(i)
                                               ,p_recvr_sob_id(i))
                                        ,nvl(EI.recvr_org_id,CDL.org_id)) recvr_gl_period_name,
                'Y'     -- Interface to GL
        Into l_gl_date_new(i) , l_gl_period_new(i) , l_recvr_gl_date_new(i) , l_recvr_gl_period_new(i) , l_interface_to_gl(i)
        From PA_Cost_Distribution_lines CDL,PA_Expenditure_items_all EI,PA_Expenditures EXP
        Where CDL.Rowid = chartorowid( p_cdl_rowid(i) )
        AND   CDL.Transfer_Status_Code in ('P','R')
        AND   CDL.expenditure_item_id = EI.expenditure_item_id
        AND   EXP.expenditure_id = EI.Expenditure_Id
        AND   decode(EI.system_linkage_function                 /* If the interface to GL is not ticked we donot rederive the GL Dates */
                        ,'ST',nvl(Decode(nvl(EXP.person_type, 'EMP')
                                                ,'EMP',l_labor_to_gl
                                                ,l_cwk_lab_to_gl),'N')
                        ,'OT',nvl(Decode(nvl(EXP.person_type, 'EMP')
                                                ,'EMP',l_labor_to_gl
                                                ,l_cwk_lab_to_gl),'N')
                        ,'VI','Y'
                        ,'ER','Y'
                        ,nvl(l_usage_to_gl,'N')) = 'Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_gl_date_new(i) := NULL;
          l_gl_period_new(i) := NULL;
          l_recvr_gl_date_new(i) := NULL;
          l_recvr_gl_period_new(i) := NULL;
          l_interface_to_gl(i) := 'N';
      END;
 End Loop;

  /* When the CDL is not summarized then update the CDLs with the rederived GL dates. */
  /* Bug 3669746 : Modified the update to check if the derived gl date/receiver gl date is null
     i.e. no future open periods exist then update the transfer_status_code to 'R' and reason with appropriate value.
     In case of rejection the date and period info is not nulled out.
   */
/* 4130583 - l_interface_to_gl(i),CDL GL Date/Period and Receiver GL Date/Period  will never be NULL.
             Modified update stmt accordingly */

/* Bug 4374769  : Both PJI Summarized and Non Summarized cdls are handled in a single update statement. The logic is as follows :
                     a) When the CDL is not summarized then update the CDLs with the rederived GL dates.
		     b) When the CDL to be transferred is already summarized the transfer_status_code
                        is updated to 'X' if the Gl_date on the CDL is still in open period.
                        If the GL period is closed then we mark the transfer_status_code to intermediate status 'Y'.
                        For all CDL's stamped with 'Y' reversing line and new line with proper GL info will be created subsequently.
                             (1)The reversing CDL would be created with line_type as 'I',transfer_status_code as 'G' and the same GL Date/Period as
			        that of the original 'R' cdl.
                             (2)The new CDL would be created with line_type as 'I', transfer_status_code as 'G' and GL Date/Period as those of the
			        next open GL Period .
			     (3)The Original CDL would be updated with transfer_status_code as 'X' and GL Date/Period as those of the next open
			        GL Period. The reversed_flag will be NULL for the original 'R' cdl. */


  FORALL i IN 1..p_local_set_size
    UPDATE   PA_Cost_Distribution_lines CDL
       SET   CDL.request_id = p_request_id(i)
            ,CDL.transfer_status_code = Decode(l_interface_to_gl(i),
	                                       'Y',  DECODE(l_gl_date_new(i),
					                     NULL,'R',
							          DECODE(l_recvr_gl_date_new(i)
								         ,NULL,'R',
									       DECODE (CDL.PJI_SUMMARIZED_FLAG,
									                'N', 'X',
											   DECODE (CDL.gl_date ,
												   l_gl_date_new(i), 'X',
                                                                						     'Y'
											          )

									              )
									 )
						            ),
					             'X'
					       )
            ,CDL.Transfer_Rejection_Reason =
                                     (
                                     SELECT Meaning
                                     FROM   PA_Lookups LOOK
                                     WHERE  LOOK.Lookup_Type = 'TRANSFER REJECTION CODE'
                                     AND    LOOK.Lookup_Code = Decode(l_interface_to_gl(i),'Y'
                                                                     ,DECODE(l_gl_date_new(i),NULL,'NO_GL_DATE'
                                                                            ,DECODE(l_recvr_gl_date_new(i),NULL,'NO_RECVR_GL_DATE',NULL)),NULL)
                                     )
            ,CDL.Transferred_Date = SYSDATE
            ,CDL.gl_date        = Decode(l_interface_to_gl(i),
	                                  'N',CDL.gl_date,
					      DECODE ( CDL.PJI_SUMMARIZED_FLAG,
					               'N', nvl(l_gl_date_new(i),CDL.gl_date) ,
						            CDL.GL_DATE
						     )

					)
            ,CDL.gl_period_name = Decode(l_interface_to_gl(i),
	                                  'N',CDL.gl_period_name,
					      DECODE ( CDL.PJI_SUMMARIZED_FLAG,
					               'N', nvl(l_gl_period_new(i),CDL.gl_period_name),
						            CDL.gl_period_name
						     )

					 )
            ,CDL.recvr_gl_date  = Decode(l_interface_to_gl(i),
	                                  'N',CDL.recvr_gl_date,
					      DECODE ( CDL.PJI_SUMMARIZED_FLAG,
					               'N', nvl(l_recvr_gl_date_new(i),CDL.recvr_gl_date),
						            CDL.recvr_gl_date
						     )

					)
            ,CDL.recvr_gl_period_name = Decode(l_interface_to_gl(i),
	                                        'N', CDL.recvr_gl_period_name ,
						 DECODE ( CDL.PJI_SUMMARIZED_FLAG,
					                  'N', nvl(l_recvr_gl_period_new(i),CDL.recvr_gl_period_name),
						               CDL.recvr_gl_period_name
							)
					       )
    WHERE  CDL.Rowid = chartorowid( p_cdl_rowid(i) )
    AND    CDL.Transfer_Status_Code in ('P','R')  ;  /* Bug#3114404 */
    -- Commented for Bug 4374769
    /*AND    ((CDL.pji_summarized_flag = 'N' AND l_interface_to_gl(i) = 'Y')
             OR l_interface_to_gl(i) = 'N')    ; */


  -- When the CDL to be transferred is already summarized the transfer_status_code
  -- is updated to 'X' if the Gl_date on the CDL is still in open period.
  -- If the GL period is closed then we mark the transfer_status_code to intermediate status 'Y'.
  -- For all CDL's stamped with 'Y' reversing line and new line with proper GL info will be created subsequently.
  --(1)The Original CDL would be stamped with 'G' .
  --(2)The reversing CDL would have the same GL info as the original line with status 'G' .
  --(3)The new CDL would have the proper GL info with stutus 'X' for further processing.

-- The following code is commented for Bug 4374769
 /* FORALL i IN 1..p_local_set_size
    UPDATE   PA_Cost_Distribution_lines CDL
       SET   CDL.request_id = p_request_id(i)
            ,CDL.transfer_status_code = DECODE(l_gl_date_new(i)                 -- Bug 3669746
                                                , NULL ,'R'
                                                ,DECODE(l_recvr_gl_date_new(i)
                                                        ,NULL,'R'
                                                        ,Decode(CDL.gl_date
                                                                ,l_gl_date_new(i),'X'
                                                                ,'Y')))
            ,CDL.Transfer_Rejection_Reason =                                    -- Bug 3669746
                                     (
                                     SELECT Meaning
                                     FROM   PA_Lookups LOOK
                                     WHERE  LOOK.Lookup_Type = 'TRANSFER REJECTION CODE'
                                     AND    LOOK.Lookup_Code = DECODE(l_gl_date_new(i)
                                                                        , NULL,'NO_GL_DATE'
                                                                        ,DECODE(l_recvr_gl_date_new(i)
                                                                                ,NULL,'NO_RECVR_GL_DATE'
                                                                                ,NULL))
                                     )
            ,CDL.Transferred_Date = decode (CDL.gl_date
                                                ,l_gl_date_new(i),SYSDATE
                                                ,NULL)
    WHERE  CDL.Rowid = chartorowid( p_cdl_rowid(i) )
    AND    CDL.Transfer_Status_Code in ('P','R')
    AND    CDL.pji_summarized_flag is NULL ; */


    -- Creating REVERSING and NEW CDLs .

    /* Bug 4374769 : The line_num is passed to Pa_Costing.ReverseCdl to create reversing and new lines for the line_num that is being passed. */

          For cdlsel in c_sel_cdl Loop
                        Pa_Costing.ReverseCdl
                                (  X_expenditure_item_id            =>  cdlsel.expenditure_item_id
                                 , X_billable_flag                  =>  cdlsel.billable_flag
                                 , X_amount                         =>  NULL
                                 , X_quantity                       =>  NULL
                                 , X_burdened_cost                  =>  NULL
                                 , X_dr_ccid                        =>  NULL
                                 , X_cr_ccid                        =>  NULL
                                 , X_tr_source_accounted            =>  'Y'
                                 , X_line_type                      =>  cdlsel.line_type
                                 , X_user                           =>  p_user_id
                                 , X_denom_currency_code            =>  cdlsel.denom_currency_code
                                 , X_denom_raw_cost                 =>  NULL
                                 , X_denom_burden_cost              =>  NULL
                                 , X_acct_currency_code             =>  cdlsel.acct_currency_code
                                 , X_acct_rate_date                 =>  cdlsel.acct_rate_date
                                 , X_acct_rate_type                 =>  cdlsel.acct_rate_type
                                 , X_acct_exchange_rate             =>  cdlsel.acct_exchange_rate
                                 , X_acct_raw_cost                  =>  NULL
                                 , X_acct_burdened_cost             =>  NULL
                                 , X_project_currency_code          =>  cdlsel.project_currency_code
                                 , X_project_rate_date              =>  cdlsel.project_rate_date
                                 , X_project_rate_type              =>  cdlsel.project_rate_type
                                 , X_project_exchange_rate          =>  cdlsel.project_exchange_rate
                                 , X_err_code                       =>  l_err_code
                                 , X_err_stage                      =>  l_err_stage
                                 , X_err_stack                      =>  l_err_stack
                                 , P_Projfunc_currency_code         =>  cdlsel.projfunc_currency_code
                                 , P_Projfunc_cost_rate_date        =>  cdlsel.projfunc_cost_rate_date
                                 , P_Projfunc_cost_rate_type        =>  cdlsel.projfunc_cost_rate_type
                                 , P_Projfunc_cost_exchange_rate    =>  cdlsel.projfunc_cost_exchange_rate
                                 , P_project_raw_cost               =>  null
                                 , P_project_burdened_cost          =>  null
                                 , P_Work_Type_Id                   =>  cdlsel.work_type_id
                                 , P_mode                           =>  'INTERFACE'
				 , X_line_num                       =>  cdlsel.line_num
                                 );
          End Loop;


 --Marking the ORIGINAL and REVERSING CDLs with transfer_status_code 'G'.

 -- Commented for Bug 4374769
 /* FORALL i IN 1..p_local_set_size
    UPDATE   PA_Cost_Distribution_lines CDL
       SET   CDL.request_id = p_request_id(i)
            ,CDL.transfer_status_code = 'G'
            ,CDL.Transferred_Date = SYSDATE
    WHERE  CDL.Transfer_Status_Code in ('Y')
    AND    (CDL.line_num_reversed is NOT NULL
            OR CDL.reversed_flag = 'Y'); */

  --Marking the NEWLY created CDLs with transfer_status_code 'X' for further processing.
  /* Bug 4374769     : The following code is modified to set the TRANSFER_STATUS_CODE to 'X' and rederive the GL_DATE, GL_PERIOD_NAME, RECVR_GL_DATE and
                       RECVR_GL_PERIOD_NAME for the reversing and new cdls of line_type 'R' to further process and transfer them to GL. */

  FORALL i IN 1..p_local_set_size
    UPDATE   PA_Cost_Distribution_lines CDL
       SET   CDL.request_id = p_request_id(i)
            ,CDL.transfer_status_code = 'X'
            ,CDL.Transferred_Date = SYSDATE
	    ,CDL.gl_date        = Decode(l_interface_to_gl(i),'N',CDL.gl_date,nvl(l_gl_date_new(i),CDL.gl_date))
            ,CDL.gl_period_name = Decode(l_interface_to_gl(i),'N',CDL.gl_period_name,nvl(l_gl_period_new(i),CDL.gl_period_name))
            ,CDL.recvr_gl_date  = Decode(l_interface_to_gl(i),'N',CDL.recvr_gl_date,nvl(l_recvr_gl_date_new(i),CDL.recvr_gl_date))
            ,CDL.recvr_gl_period_name = Decode(l_interface_to_gl(i),'N',CDL.recvr_gl_period_name
                                                                       ,nvl(l_recvr_gl_period_new(i),CDL.recvr_gl_period_name))
    WHERE  CDL.Transfer_Status_Code in ('Y')
    AND    CDL.reversed_flag is NULL;
    -- Commented for Bug 4374769
    /* AND    CDL.line_num_reversed is NULL ; */


/*************************** Bug 3668005 Ends ****************************/

  ELSE
     FORALL i IN 1..p_local_set_size
       UPDATE   PA_Cost_Distribution_lines CDL
          SET   CDL.request_id = p_request_id(i)
               ,CDL.transfer_status_code = 'X'
               ,CDL.Transferred_Date = SYSDATE
       WHERE  CDL.Rowid = chartorowid( p_cdl_rowid(i) )
       AND    CDL.Transfer_Status_Code in ('P','R');   /* Bug#3114404 */

  END IF;
END IF;
END populate_gl_dates;
-----------------------------------------------------------------------
PROCEDURE refresh_gl_cache ( p_reference_date            IN DATE,
                             p_application_id     IN NUMBER,
                             p_set_of_books_id    IN NUMBER,
                             p_caller_flag        IN VARCHAR2
                           )
IS
  l_earliest_start_date    gl_period_statuses.start_date%TYPE;
  l_earliest_end_date      gl_period_statuses.end_date%TYPE;
  l_earliest_period_name   gl_period_statuses.period_name%TYPE;
  l_gl_date                gl_period_statuses.start_date%TYPE;
  l_period_name            gl_period_statuses.period_name%TYPE;
  l_start_date             gl_period_statuses.start_date%TYPE;         -- start date for the l_gl_date.
  l_end_date               gl_period_statuses.start_date%TYPE;         -- end date for the l_gl_date.

  CURSOR c_get_gl_date (c_reference_date DATE) IS
      SELECT  PERIOD.start_date,
              PERIOD.end_date,
              PERIOD.period_name
        FROM  GL_PERIOD_STATUSES PERIOD
       WHERE  PERIOD.application_id   = p_application_id
         AND  PERIOD.set_of_books_id  = p_set_of_books_id
         AND  PERIOD.closing_status||''  IN ('O','F')
         AND  PERIOD.adjustment_period_flag = 'N'
         AND  trunc(c_reference_date) BETWEEN PERIOD.start_date and PERIOD.end_date;

BEGIN

     G_Application_Id := p_application_id; /*Added this line for bug 7638790 */
      IF ( p_caller_flag = 'R' AND g_r_earliest_gl_start_date IS NULL ) OR
         ( p_caller_flag = 'P' AND g_p_earliest_gl_start_date IS NULL ) THEN
          SELECT PERIOD.start_date
                ,PERIOD.end_date
                ,PERIOD.period_name
            INTO l_earliest_start_date
                ,l_earliest_end_date
                ,l_earliest_period_name
            FROM GL_PERIOD_STATUSES PERIOD
           WHERE PERIOD.set_of_books_id = p_set_of_books_id
             AND PERIOD.application_id = p_application_id
             AND PERIOD.adjustment_period_flag = 'N'
             AND PERIOD.end_date = (
          SELECT   MIN (PERIOD1.end_date)
            FROM   GL_PERIOD_STATUSES PERIOD1
           WHERE   PERIOD1.closing_status in ('O','F')
             AND   PERIOD1.application_id = p_application_id         /* Bug# 1899771 */
             AND   PERIOD1.adjustment_period_flag = 'N' /* Bug# 1899771 */
             AND   PERIOD1.set_of_books_id = p_set_of_books_id)  ;

        -- the earliest global variables will be populated ONLY ONCE.

        IF ( p_caller_flag = 'P' )
        THEN
          g_p_earliest_gl_start_date  := l_earliest_start_date ;
          g_p_earliest_gl_end_date    := l_earliest_end_date ;
          g_p_earliest_gl_period_name := l_earliest_period_name ;
        ELSIF ( p_caller_flag = 'R' )
        THEN
          g_r_earliest_gl_start_date  := l_earliest_start_date ;
          g_r_earliest_gl_end_date    := l_earliest_end_date ;
          g_r_earliest_gl_period_name := l_earliest_period_name ;
        END IF;
      END IF ;

  IF ( fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') = 'N' )         /*For Bug 5391468*/
  THEN
    /*
     * The profile option is NOT set,(Gldate is based on the pa_date)
     * -- the gl date should equal the end date (if the pa date falls in a open
     *    gl period.)
     * -- the gl date should equal the end date of the immediate next open
     *    period (if the pa date doesnt fall in a open period.)
     */

      SELECT  PERIOD.start_date,
              PERIOD.end_date,
              PERIOD.end_date,
              PERIOD.period_name
        INTO  l_start_date,
              l_end_date,
              l_gl_date,
              l_period_name
        FROM  GL_PERIOD_STATUSES PERIOD
       WHERE  PERIOD.application_id   = p_application_id
         AND  PERIOD.set_of_books_id  = p_set_of_books_id
         AND  PERIOD.effective_period_num =
          ( SELECT  min(PERIOD1.effective_period_num)
            FROM    GL_PERIOD_STATUSES PERIOD1
            WHERE   PERIOD1.application_id  = p_application_id
              AND   PERIOD1.set_of_books_id = p_set_of_books_id
              AND   PERIOD1.closing_status||''  IN ('O','F')
              AND   PERIOD1.adjustment_period_flag = 'N'
              AND   PERIOD1.effective_period_num  >=
             ( SELECT PERIOD2.effective_period_num
               FROM   GL_PERIOD_STATUSES PERIOD2,
                      GL_DATE_PERIOD_MAP DPM,
                      GL_SETS_OF_BOOKS SOB
               WHERE  SOB.set_of_books_id = p_set_of_books_id
                 AND  DPM.period_set_name = SOB.period_set_name
                 AND  DPM.period_type = SOB.accounted_period_type
                 AND  trunc(DPM.accounting_date) = trunc(p_reference_date)
                 AND  DPM.period_name = PERIOD2.period_name
                 AND  PERIOD2.application_id = p_application_id
                 AND  PERIOD2.set_of_books_id = p_set_of_books_id ))
         AND  PERIOD.End_Date >= TRUNC(p_reference_date)
         AND  PERIOD.set_of_books_id = p_set_of_books_id ;

      -- Populating cache.
      if ( p_caller_flag = 'R' ) then
         g_recvr_set_of_books_id  := p_set_of_books_id ;
         g_recvr_gl_start_date    := l_start_date ;
         g_recvr_gl_end_date      := l_end_date ;
         g_recvr_gl_date          := l_gl_date ;
         g_recvr_gl_period_name   := l_period_name ;
      elsif ( p_caller_flag = 'P' ) then
         g_prvdr_set_of_books_id  := p_set_of_books_id ;
         g_prvdr_gl_start_date    := l_start_date ;
         g_prvdr_gl_end_date      := l_end_date ;
         g_prvdr_gl_date          := l_gl_date ;
         g_prvdr_gl_period_name   := l_period_name ;
      end if;

  ELSE -- profile option is SET.
      /*
       * Check whether the reference_date falls in an Open or Future Period.
       */

      OPEN c_get_gl_date (p_reference_date);

      FETCH c_get_gl_date
       INTO l_start_date
           ,l_end_date
           ,l_period_name;

      IF (c_get_gl_date%NOTFOUND)
      THEN
        /*
         * Get the earliest available date.
         */
            SELECT  PERIOD.start_date
                   ,PERIOD.start_date
                   ,PERIOD.end_date
                   ,PERIOD.period_name
              INTO  l_gl_date
                   ,l_start_date
                   ,l_end_date
                   ,l_period_name
              FROM  GL_PERIOD_STATUSES PERIOD
             WHERE  PERIOD.application_id   = p_application_id
               AND  PERIOD.set_of_books_id  = p_set_of_books_id
               AND  PERIOD.effective_period_num =
                ( SELECT  min(PERIOD1.effective_period_num)
                  FROM    GL_PERIOD_STATUSES PERIOD1
                  WHERE   PERIOD1.application_id  = p_application_id
                    AND   PERIOD1.set_of_books_id = p_set_of_books_id
                    AND   PERIOD1.closing_status||''  IN ('O','F')
                    AND   PERIOD1.adjustment_period_flag = 'N'
                    AND   PERIOD1.effective_period_num  >=
                   ( SELECT PERIOD2.effective_period_num
                     FROM   GL_PERIOD_STATUSES PERIOD2,
                            GL_DATE_PERIOD_MAP DPM,
                            GL_SETS_OF_BOOKS SOB
                     WHERE  SOB.set_of_books_id = p_set_of_books_id
                       AND  DPM.period_set_name = SOB.period_set_name
                       AND  DPM.period_type = SOB.accounted_period_type
                       AND  trunc(DPM.accounting_date) = trunc(p_reference_date)
                       AND  DPM.period_name = PERIOD2.period_name
                       AND  PERIOD2.application_id = p_application_id
                       AND  PERIOD2.set_of_books_id = p_set_of_books_id ))
               AND  PERIOD.Start_Date > TRUNC(p_reference_date);
      ELSE
          l_gl_date  := p_reference_date ;
      END IF;

      CLOSE c_get_gl_date;

      -- Populating cache.
      if ( p_caller_flag = 'R' ) then
         g_recvr_set_of_books_id  := p_set_of_books_id ;
         g_recvr_gl_start_date := l_start_date ;
         g_recvr_gl_end_date   := l_end_date ;
         g_recvr_gl_date    := l_gl_date ;
         g_recvr_gl_period_name := l_period_name ;
      elsif ( p_caller_flag = 'P' ) then
         g_prvdr_set_of_books_id  := p_set_of_books_id ;
         g_prvdr_gl_start_date    := l_start_date ;
         g_prvdr_gl_end_date      := l_end_date ;
         g_prvdr_gl_date          := l_gl_date ;
         g_prvdr_gl_period_name   := l_period_name ;
      end if;
  END IF;
EXCEPTION
  WHEN no_data_found THEN
    if ( p_caller_flag = 'R' ) then
/** Added for 2810747 **/
      g_recvr_gl_start_date := NULL;
      g_recvr_gl_end_date := NULL;
/** End Added for 2810747 **/

      g_recvr_gl_date := NULL ;
      g_recvr_gl_period_name := NULL ;
    elsif ( p_caller_flag = 'P' ) then

/** Added for 2810747 **/
      g_prvdr_gl_start_date := NULL;
      g_prvdr_gl_end_date := NULL;
/** End Added for 2810747 **/

      g_prvdr_gl_date := NULL ;
      g_prvdr_gl_period_name := NULL ;
    end if;
  WHEN others THEN
     RAISE ;

END refresh_gl_cache ;
-----------------------------------------------------------------------
/*
 * EPP.
 * Modified the name of the first parameter.
 */
FUNCTION get_prvdr_gl_date( p_reference_date  IN DATE,
                            p_application_id  IN NUMBER ,
                            p_set_of_books_id IN gl_sets_of_books.set_of_books_id%TYPE
                          )
return date
IS
  l_prof_new_gldate_derivation varchar2(1);
BEGIN
  l_prof_new_gldate_derivation := fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') ; /*For Bug 5391468*/

  /*
   * Validate the input parameters.
   * If the essential input parameters have NULL values, set the global variables
   * appropriately and return NULL value.
   */
  IF ( p_reference_date IS NULL OR p_application_id IS NULL OR p_set_of_books_id IS NULL )
  THEN
    return NULL;
  END IF;

  IF ( p_set_of_books_id = g_prvdr_set_of_books_id and G_Application_Id = p_application_id) --Added one more condition for bug 7638790
  THEN
    -- if sob is not the same, we HAVE to hit the DB.
    IF ( g_p_earliest_gl_start_date IS NOT NULL )
    THEN
      -- the cache is NOT empty.
      -- check whether provider_cache is re-usable..
      IF p_reference_date BETWEEN g_prvdr_gl_start_date AND g_prvdr_gl_end_date THEN

        /*Added for bug 4277525 -Start */
        IF  g_prvdr_gl_date IS NULL OR g_prvdr_gl_period_name IS null
          then
            pa_utils2.refresh_gl_cache( p_reference_date,
                               p_application_id,
                               p_set_of_books_id,
                               'P'
                              );
           END IF ;
        /*Added for bug 4277525 -End */

        IF ( l_prof_new_gldate_derivation = 'Y' )
        THEN
          return ( p_reference_date ) ;
        ELSE
          return ( g_prvdr_gl_end_date ) ;
        END IF ; -- profile
      ELSE  -- p_reference_date
        IF ( l_prof_new_gldate_derivation = 'Y' )
        THEN
          IF ( p_reference_date <= g_p_earliest_gl_start_date )
          THEN
            g_prvdr_gl_start_date  := g_p_earliest_gl_start_date ;
            g_prvdr_gl_end_date    := g_p_earliest_gl_end_date ;
            g_prvdr_gl_period_name := g_p_earliest_gl_period_name ;
            return ( g_p_earliest_gl_start_date ) ;
          END IF; -- p_reference_date
        ELSIF ( p_reference_date <= g_p_earliest_gl_end_date )
        THEN
          g_prvdr_gl_start_date  := g_p_earliest_gl_start_date ;
          g_prvdr_gl_end_date    := g_p_earliest_gl_end_date ;
          g_prvdr_gl_period_name := g_p_earliest_gl_period_name ;
          return ( g_p_earliest_gl_end_date ) ;
        END IF ; -- profile
      END IF ; -- p_reference_date
    END IF ; -- g_p_earliest_gl_start_date
  END IF ; -- sob

     -- If control comes here, it means that
     --  1. sob doesnt match   or
     --  2. cache is empty     or
     --  3. the Cache is not reusable.
     -- Access the DB and refresh cache and return gl_date.

     pa_utils2.refresh_gl_cache( p_reference_date,
                              p_application_id,
                              p_set_of_books_id,
                              'P'
                             );
     return ( g_prvdr_gl_date ) ;
EXCEPTION
    WHEN OTHERS THEN
      RAISE ;
END get_prvdr_gl_date ;
-----------------------------------------------------------------------
/*
 * EPP.
 * Modified the name of the first parameter.
 */

FUNCTION get_recvr_gl_date( p_reference_date   IN DATE,
                            p_application_id   IN NUMBER ,
                            p_set_of_books_id  IN gl_sets_of_books.set_of_books_id%TYPE
                          )
return date
IS
  l_prof_new_gldate_derivation VARCHAR2(1) := 'N';
BEGIN
  l_prof_new_gldate_derivation := fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') ; /*For Bug 5391468*/

  /*
   * Validate the input parameters.
   * If the essential input parameters have NULL values,
   * return NULL value.
   */
  IF ( p_reference_date IS NULL OR p_application_id IS NULL OR p_set_of_books_id IS NULL )
  THEN
    return NULL;
  END IF;

  IF ( p_set_of_books_id = g_recvr_set_of_books_id )
  THEN
    IF ( g_r_earliest_gl_start_date IS NOT NULL )
    THEN
      -- receiver cache is NOT empty.
      -- try to re-use the receiver cache.
      IF p_reference_date BETWEEN g_recvr_gl_start_date AND g_recvr_gl_end_date
      THEN
        IF ( l_prof_new_gldate_derivation = 'Y' )
        THEN
          return ( p_reference_date ) ;
        ELSE
          return ( g_recvr_gl_end_date ) ;
        END IF;
      ELSE
        IF ( l_prof_new_gldate_derivation = 'Y' )
        THEN
          IF ( p_reference_date <= g_r_earliest_gl_start_date )
          THEN
            g_recvr_gl_start_date := g_r_earliest_gl_start_date;
            g_recvr_gl_end_date := g_r_earliest_gl_end_date;
            g_recvr_gl_period_name := g_r_earliest_gl_period_name;

            g_recvr_gl_date := g_r_earliest_gl_start_date ;
            return ( g_r_earliest_gl_start_date ) ;
          END IF; -- profile
        ELSIF ( p_reference_date <= g_r_earliest_gl_end_date )
        THEN
          g_recvr_gl_start_date := g_r_earliest_gl_start_date;
          g_recvr_gl_end_date := g_r_earliest_gl_end_date;
          g_recvr_gl_period_name := g_r_earliest_gl_period_name;
          return ( g_r_earliest_gl_end_date ) ;
        END IF; -- profile
      END IF ; -- p_reference_date
    ELSE -- g_r_earliest_gl_start_date
      -- receiver cache is empty.
      -- should try to use the provider cache.

      IF ( p_set_of_books_id = g_prvdr_set_of_books_id ) THEN
        IF p_reference_date BETWEEN g_prvdr_gl_start_date AND g_prvdr_gl_end_date THEN

          -- copy provider cache to receiver cache.
          g_recvr_gl_date              := g_prvdr_gl_date ;
          g_r_earliest_gl_start_date   := g_p_earliest_gl_start_date  ;
          g_r_earliest_gl_end_date     := g_p_earliest_gl_end_date  ;
          g_r_earliest_gl_period_name  := g_p_earliest_gl_period_name ;
          g_recvr_gl_start_date        := g_prvdr_gl_start_date ;
          g_recvr_gl_end_date          := g_prvdr_gl_end_date ;
          g_recvr_gl_period_name       := g_prvdr_gl_period_name ;
          g_recvr_set_of_books_id      := g_prvdr_set_of_books_id ;
          IF ( l_prof_new_gldate_derivation = 'Y' )
          THEN
            return ( p_reference_date ) ;
          ELSE
            return ( g_prvdr_gl_end_date ) ;
          END IF;
        ELSIF ( l_prof_new_gldate_derivation = 'Y' )
        THEN
          IF ( p_reference_date <= g_p_earliest_gl_start_date )
          THEN
            -- copy provider cache to receiver cache.
            g_r_earliest_gl_start_date   := g_p_earliest_gl_start_date  ;
            g_r_earliest_gl_end_date     := g_p_earliest_gl_end_date  ;
            g_r_earliest_gl_period_name  := g_p_earliest_gl_period_name ;
            g_recvr_gl_start_date        := g_p_earliest_gl_start_date ;
            g_recvr_gl_end_date          := g_p_earliest_gl_end_date ;
            g_recvr_gl_period_name       := g_p_earliest_gl_period_name ;
            g_recvr_set_of_books_id      := g_prvdr_set_of_books_id ;

            g_recvr_gl_date              := g_prvdr_gl_date ;
            return ( g_p_earliest_gl_start_date ) ;
          ELSIF ( p_reference_date <= g_p_earliest_gl_end_date )
          THEN
            g_r_earliest_gl_start_date   := g_p_earliest_gl_start_date  ;
            g_r_earliest_gl_end_date     := g_p_earliest_gl_end_date  ;
            g_r_earliest_gl_period_name  := g_p_earliest_gl_period_name ;
            g_recvr_gl_start_date        := g_p_earliest_gl_start_date ;
            g_recvr_gl_end_date          := g_p_earliest_gl_end_date ;
            g_recvr_gl_period_name       := g_p_earliest_gl_period_name ;
            g_recvr_set_of_books_id      := g_prvdr_set_of_books_id ;

            g_recvr_gl_date              := g_p_earliest_gl_end_date ;
            return ( g_p_earliest_gl_end_date ) ;
          END IF; -- p_reference_date
        END IF ; -- p_reference_date
      END IF ; -- sob
    END IF; -- g_r_earliest_gl_start_date
  END IF ; -- p_set_of_books_id

    pa_utils2.refresh_gl_cache ( p_reference_date,
                              p_application_id,
                              p_set_of_books_id,
                              'R');
    return ( g_recvr_gl_date ) ;
EXCEPTION
    WHEN OTHERS THEN
      RAISE ;
END get_recvr_gl_date ;
-----------------------------------------------------------------------
-- ==========================================================================
-- = PROCEDURE GetProjInfo
-- ==========================================================================

  FUNCTION  GetBusinessGroupId ( P_Business_Group_Name  IN VARCHAR2 ) RETURN NUMBER
  IS

    x_business_group_id      NUMBER;
  BEGIN

    IF (P_Business_Group_Name = G_PREV_BUS_GRP_NAME) THEN

        RETURN G_PREV_BUS_GRP_ID;

    ELSE

       G_PREV_BUS_GRP_NAME := P_Business_Group_Name;

       SELECT
            ho.organization_id
         INTO
            x_business_group_id
         FROM
            hr_all_organization_units ho
        WHERE
            ho.name = P_Business_Group_Name
          AND
            ho.organization_id = ho.business_group_id; /* Added this clause for bug 1649495 */

       G_PREV_BUS_GRP_ID := x_business_group_id;
       RETURN ( x_business_group_id );

     END IF;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
          G_PREV_BUS_GRP_NAME := P_Business_Group_Name;
          G_PREV_BUS_GRP_ID   := NULL;
          return NULL ;
    WHEN  OTHERS  THEN
          G_PREV_BUS_GRP_NAME := P_Business_Group_Name;
          G_PREV_BUS_GRP_ID   := NULL;

          RAISE  ;

  END  GetBusinessGroupId;

-- ==========================================================================
-- = FUNCTION  GetEmpId
-- ==========================================================================
-- Fixed Bug 1534973, 1581184
-- Added P_EiDate parameter and performing date check in the query
-- If adding new parameters please add before P_EiDate parameter

-- cwk changes: added new parameter P_Person_Type and modified procedure to return the person id for
--contingent workers as well as employees based on the P_Person_Type parameter

  PROCEDURE  GetEmpId ( P_Business_Group_Id     IN NUMBER
                      , P_Employee_Number       IN VARCHAR2
                      , X_Employee_Id          OUT NOCOPY VARCHAR2
                      , P_Person_Type   IN VARCHAR2
                      , P_EiDate                IN DATE )
  IS
    X_person_id         NUMBER;
  BEGIN

    IF (p_business_group_id        = G_PREV_BUSGRP_ID   AND
        p_employee_number          = G_PREV_EMP_NUM     AND
        p_eidate                   = G_PREV_EI_DATE     AND
        nvl(p_person_type,'EMP')   = NVL(G_PREV_PERSON_TYPE,'EMP') AND /* Bug 3972641*/
        G_Return_Status      IS NULL) THEN

        x_employee_id := G_PREV_EMP_ID;

    ELSE

       G_PREV_BUSGRP_ID:= P_Business_Group_Id;
       G_PREV_EMP_NUM  := P_Employee_Number;
       G_PREV_EI_DATE  := trunc(P_EiDate);
       G_PREV_PERSON_TYPE := P_Person_Type;

       IF nvl(P_Person_Type,'EMP') NOT IN ('EMP','CWK') THEN
       G_PREV_EMP_ID   := NULL;
       G_Return_Status :=  'INVALID_PERSON_TYPE' ;
       ELSE

       /* Bug 3972641/
       SELECT
            person_id
         INTO
            X_person_id
         FROM
            per_people_f
        WHERE
            decode(p_person_type,'CWK', npw_number,employee_number) = P_Employee_Number
       AND (business_group_id = P_Business_Group_Id
        OR  P_Business_Group_Id is NULL)
       AND  trunc(P_EiDate) between trunc(effective_start_date) and trunc(effective_end_date);

         Bug 3972641 */
       /* Bug 3972641 */

	 IF NVL(P_Person_Type,'EMP') = 'EMP' THEN

            SELECT
            person_id
            INTO
            X_person_id
            FROM
            per_people_f
            WHERE
            employee_number = P_Employee_Number
            AND (business_group_id = P_Business_Group_Id
            OR  P_Business_Group_Id is NULL)
            AND  trunc(P_EiDate) between trunc(effective_start_date) and trunc(effective_end_date);

        ELSE

            SELECT
            person_id
            INTO
            X_person_id
            FROM
            per_people_f
            WHERE
            npw_number = P_Employee_Number
            AND (business_group_id = P_Business_Group_Id
            OR  P_Business_Group_Id is NULL)
            AND  trunc(P_EiDate) between trunc(effective_start_date) and trunc(effective_end_date);

        END IF;
       /* Bug 3972641 */

       G_PREV_EMP_ID   := x_person_id;
       X_Employee_Id   := X_person_id;
       G_Return_Status := NULL;

       END IF; /* person type */

    END IF;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
       G_PREV_BUSGRP_ID:= P_Business_Group_Id;
       G_PREV_EMP_NUM  := P_Employee_Number;
       G_PREV_EI_DATE  := trunc(P_EiDate);
       G_PREV_EMP_ID   := NULL;
       G_PREV_PERSON_TYPE := P_Person_Type;
       G_Return_Status :=  'PA_INVALID_EMPLOYEE' ;

    WHEN  TOO_MANY_ROWS  THEN
       G_PREV_BUSGRP_ID:= P_Business_Group_Id;
       G_PREV_EMP_NUM  := P_Employee_Number;
       G_PREV_EI_DATE  := trunc(P_EiDate);
       G_PREV_EMP_ID   := NULL;
       G_PREV_PERSON_TYPE := P_Person_Type;
      G_Return_Status := 'PA_TOO_MANY_EMPLOYEES' ;

    WHEN  OTHERS  THEN
       G_PREV_BUSGRP_ID:= P_Business_Group_Id;
       G_PREV_EMP_NUM  := P_Employee_Number;
       G_PREV_EI_DATE  := trunc(P_EiDate);
       G_PREV_EMP_ID   := NULL;
       G_PREV_PERSON_TYPE := P_Person_Type;
      RAISE ;

  END  GetEmpId;

----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Function : GetGlPeriodName
-- This function is called by Transaction Import to get the gl period name.
----------------------------------------------------------------------------
PROCEDURE GetGlPeriodNameDate( p_pa_date   IN DATE,
                              p_application_id  IN NUMBER ,
                              p_set_of_books_id IN gl_sets_of_books.set_of_books_id%TYPE,
                              x_gl_date    OUT NOCOPY DATE,
                              x_period_name  OUT NOCOPY VARCHAR2
                            )
IS
  l_prof_new_gldate_derivation VARCHAR2(1) := 'N';
BEGIN

  l_prof_new_gldate_derivation := fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') ; /*For Bug 5391468*/

  IF ( p_set_of_books_id = g_prvdr_set_of_books_id )
  THEN
    -- if sob is not the same, we HAVE to hit the DB.
    IF ( g_p_earliest_gl_start_date IS NOT NULL )
    THEN
      -- the cache is NOT empty.
      -- check whether provider_cache is re-usable..
      IF ( p_pa_date BETWEEN g_prvdr_gl_start_date AND g_prvdr_gl_end_date )
      THEN
        IF ( l_prof_new_gldate_derivation = 'Y' )
        THEN
          x_gl_date  := p_pa_date ;
          x_period_name := g_prvdr_gl_period_name ;
        ELSE
          x_gl_date  := g_prvdr_gl_end_date ;
          x_period_name := g_prvdr_gl_period_name ;
        END IF; -- profile
      ELSE
        IF ( l_prof_new_gldate_derivation = 'Y' )
        THEN
          IF ( p_pa_date <= g_p_earliest_gl_start_date )
          THEN
            x_gl_date  := g_p_earliest_gl_start_date ;
            x_period_name := g_p_earliest_gl_period_name ;
          END IF;
        ELSE
          IF (p_pa_date <= g_p_earliest_gl_end_date )
          THEN
            x_gl_date  := g_p_earliest_gl_end_date ;
            x_period_name := g_p_earliest_gl_period_name ;
          END IF; -- p_pa_date
        END IF ; -- profile
      END IF ; -- p_pa_date
    END IF ; -- g_p_earliest_gl_start_date
  END IF ; -- p_set_of_books_id

     -- If control comes here, it means that
     --  1. sob doesnt match   or
     --  2. cache is empty     or
     --  3. the Cache is not reusable.
     -- Access the DB and refresh cache and return gl_date.

     pa_utils2.refresh_gl_cache( p_pa_date,
                              p_application_id,
                              p_set_of_books_id,
                              'P'
                             );
     x_gl_date  := g_prvdr_gl_date ;
     x_period_name := g_prvdr_gl_period_name ;
EXCEPTION
    WHEN OTHERS THEN
      RAISE ;
END GetGlPeriodNameDate;

-----------------------------------------------------------------------
/*============================================================================*
 * This procedure,                                                            *
 * -- ensures that all cdls of an Expense-Report expenditure                  *
 *    gets the same gl_date.                                                  *
 * -- ensures that the pa_date for a burden VI cdl is based on                *
 *    the pa_date on the raw_cdl.                                             *
 * Bug#2103722                                                                *
 * -- To derive the recvr PA information, implementations option of the exp.  *
 *    OU was being used. The code was changed to use the respective imp.      *
 *    options.                                                                *
 * Bug#2150196                                                                                  *
 * -- When this procedure is called from Generate Draft invoice process, the calling module be  *
 *    either AR_INSTALLED_INVOICE or AR_NOT_INSTALLED_INVOICE.                                  *
 *    If AR_INSTALLED_INVOICE, to derive GL information, use AR's application id. ( 222 ).      *
 *    Also, if this procedure is called from the Generate Draft invoice process, PA and GL      *
 *    periods should not be made the same - even if implementation option Use_Same_PA_GL_Period *
 *    is set.                                                                                   *
 * -- Shouldnt derive receiver side dates when call is from get_ou_period_information (ou       *
 *    context). In which case, no info about the receiver is available. Also when call is for   *
 *    CCDL, receiver side dates are not required.                                               *
 * Capital Interest - PA.L                                                                      *
 *  o For transactions with transaction source 'Capitalized Interest', GL period is always      *
 *    derived based on application id 101 irrespective of the EPP profile option.               *
 *==============================================================================================*/

PROCEDURE get_period_information ( p_expenditure_item_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                  ,p_expenditure_id IN pa_expenditure_items_all.expenditure_id%TYPE
                                  ,p_system_linkage_function IN pa_expenditure_items_all.system_linkage_function%TYPE
                                  ,p_line_type IN pa_cost_distribution_lines_all.line_type%TYPE
                                  ,p_prvdr_raw_pa_date IN pa_cost_distribution_lines_all.pa_date%TYPE
                                  ,p_recvr_raw_pa_date IN pa_cost_distribution_lines_all.pa_date%TYPE
                                  ,p_prvdr_raw_gl_date IN pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,p_recvr_raw_gl_date IN pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,p_prvdr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_recvr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_prvdr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,p_recvr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,p_calling_module IN VARCHAR2
                                  ,p_ou_context IN VARCHAR2
                                  ,x_prvdr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                  ,x_prvdr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                  ,x_prvdr_gl_date OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,x_prvdr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                  ,x_recvr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_date%TYPE
                                  ,x_recvr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE
                                  ,x_recvr_gl_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_date%TYPE
                                  ,x_recvr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE
                                  ,x_return_status  OUT NOCOPY NUMBER
                                  ,x_error_code OUT NOCOPY VARCHAR2
                                  ,x_error_stage OUT NOCOPY NUMBER
                                 )
IS
    l_prvdr_pa_date        pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
    l_prvdr_pa_period_name pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
    l_prvdr_gl_date        pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
    l_prvdr_gl_period_name pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;

    l_recvr_pa_date        pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
    l_recvr_pa_period_name pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
    l_recvr_gl_date        pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_recvr_gl_period_name pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;

       /*Starts-Changes for 7535550 */
 	p_prvdr_raw_pa_date_l  pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
 	p_recvr_raw_pa_date_l  pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
 	p_prvdr_raw_gl_date_l        pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
 	p_recvr_raw_gl_date_l        pa_cost_distribution_lines_all.pa_date%TYPE := NULL;

       /*End-Changes for 7535550 */
    l_pa_gl_app_id NUMBER := 8721 ;
    l_gl_app_id NUMBER := 101;
    l_ar_app_id NUMBER := 222;
    l_app_id NUMBER := NULL ;

    TYPE DeriveType IS RECORD (receiver      VARCHAR2(1) := 'Y'
                              );
    derive DeriveType;



  /*
   * Processing related variables.
   */
  l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  l_error_code                 VARCHAR2(30);
  l_error_stage                VARCHAR2(30);
  l_debug_mode                 VARCHAR2(1);
  l_stage                      NUMBER ;

  l_prof_new_gldate_derivation VARCHAR2(1) := 'N';
  l_use_same_pa_gl_period_prvdr VARCHAR2(1) := 'N' ;
  l_use_same_pa_gl_period_recvr VARCHAR2(1) := 'N' ;
BEGIN
	 p_prvdr_raw_pa_date_l := trunc(p_prvdr_raw_pa_date);
         p_recvr_raw_pa_date_l := trunc(p_recvr_raw_pa_date);
         p_prvdr_raw_gl_date_l := trunc(p_prvdr_raw_gl_date);
         p_recvr_raw_gl_date_l := trunc(p_recvr_raw_gl_date);

/*Changes for 7535550  end. Also, please note that all occurances of p_prvdr_raw_pa_date,p_recvr_raw_pa_date,p_prvdr_raw_gl_date,p_recvr_raw_gl_date have been replaced by their local variables.*/
  x_return_status := -1 ;
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'N');
  l_stage := 100;
  IF (l_debug_mode = 'Y') THEN
	pa_debug.init_err_stack('pa_utils2.get_period_information');
	pa_debug.set_process('PLSQL','LOG',l_debug_mode);
	pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From get_period_information';
	pa_debug.write_file(pa_debug.g_err_stage);
  END IF;

  if g_prof_new_gldate_derivation IS NULL then
   l_prof_new_gldate_derivation := nvl(fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION'),'N') ; /*For Bug 5391468*/
   g_prof_new_gldate_derivation := l_prof_new_gldate_derivation;
  else
   l_prof_new_gldate_derivation := g_prof_new_gldate_derivation;
  end if;
  l_use_same_pa_gl_period_prvdr := NVL(PA_PERIOD_PROCESS_PKG.Use_Same_PA_GL_Period(p_prvdr_org_id), 'N') ;
  l_use_same_pa_gl_period_recvr := NVL(PA_PERIOD_PROCESS_PKG.Use_Same_PA_GL_Period(p_recvr_org_id), 'N') ;

  IF ( l_debug_mode = 'Y' )   THEN
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Profile option is [' || l_prof_new_gldate_derivation || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Same PA and GL for Prvdr [' || to_char(p_prvdr_org_id) || '] is ['
                                               || l_use_same_pa_gl_period_prvdr || ']' ;
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Same PA and GL for Recvr [' || to_char(p_recvr_org_id) || '] is ['
                                               || l_use_same_pa_gl_period_recvr || ']' ;
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_expenditure_item_date is [' || to_char(p_expenditure_item_date) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_expenditure_id is [' || to_char(p_expenditure_id) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_system_linkage_function is [' || p_system_linkage_function || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_line_type is [' || p_line_type || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_prvdr_raw_pa_date_l is [' || to_char(p_prvdr_raw_pa_date_l) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_recvr_raw_pa_date_l is [' || to_char(p_recvr_raw_pa_date_l) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_prvdr_raw_gl_date_l is [' || to_char(p_prvdr_raw_gl_date_l) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_recvr_raw_gl_date_l   is [' || to_char(p_recvr_raw_gl_date_l  ) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_prvdr_org_id is [' || to_char(p_prvdr_org_id) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_recvr_org_id is [' || to_char(p_recvr_org_id) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_prvdr_sob_id is [' || to_char(p_prvdr_sob_id) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_recvr_sob_id is [' || to_char(p_recvr_sob_id) || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
      pa_debug.g_err_stage := TO_CHAR(l_stage) || ': p_calling_module is [' || p_calling_module || ']';
      pa_debug.write_file(pa_debug.g_err_stage);
  END IF;

  /*
   * Decide whether to derive the receiver part.
   */
  IF ( p_ou_context = 'Y' OR p_calling_module = 'CCDL' )
  THEN
      derive.receiver := 'N' ;
  END IF;


    IF ( l_prof_new_gldate_derivation ='Y' )
    THEN
      /*
       * Get Gl periods based on ei date.
       */
        IF (p_system_linkage_function = 'ER' AND p_expenditure_id = g_prev_expenditure_id
            AND g_prev_expenditure_id IS NOT NULL AND p_calling_module = 'CDL')
        THEN
            l_stage := 200;
            IF ( l_debug_mode = 'Y' )
            THEN
                pa_debug.g_err_stage := TO_CHAR(l_stage) || ': ER - Same Expenditure GL Cache used.' ;
                pa_debug.write_file(pa_debug.g_err_stage);
            END IF;
            l_prvdr_gl_date := g_prev_prvdr_gl_date;
            l_prvdr_gl_period_name := g_prev_prvdr_gl_period_name;
            l_recvr_gl_date := g_prev_recvr_gl_date;
            l_recvr_gl_period_name := g_prev_recvr_gl_period_name;
        ELSIF ( p_line_type <> 'R' AND p_system_linkage_function = 'VI' )
        THEN
            l_stage := 300;
            IF ( l_debug_mode = 'Y' )
            THEN
                pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Burden VI.' ;
                pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Deriving GL Info.';
                pa_debug.write_file(pa_debug.g_err_stage);
            END IF; -- debug
            /*
             * The gl_date for the burden CDL is derived based on the gl_date in the
             * Raw CDL.(if the Profile option is SET.) If the profile option is NOT set
             * gl_date for the burden CDL is derived based on the pa_date in the Raw CDL.
             */
            IF ( p_calling_module = 'CDL' AND p_prvdr_raw_gl_date_l IS NOT NULL )
            THEN
                l_prvdr_gl_date := pa_utils2.get_prvdr_gl_date( p_reference_date => p_prvdr_raw_gl_date_l
                                                               ,p_application_id => l_pa_gl_app_id
                                                               ,p_set_of_books_id => p_prvdr_sob_id
                                                              );
                l_prvdr_gl_period_name := g_prvdr_gl_period_name;
            END IF; -- p_calling_module

            IF ( p_calling_module = 'CDL' AND p_recvr_raw_gl_date_l   IS NOT NULL )
            THEN
              l_recvr_gl_date := pa_utils2.get_recvr_gl_date( p_reference_date => p_recvr_raw_gl_date_l
                                                             ,p_application_id => l_pa_gl_app_id
                                                             ,p_set_of_books_id => p_recvr_sob_id
                                                            );
              l_recvr_gl_period_name := g_recvr_gl_period_name;
            END IF;
        ELSE
            l_stage := 400;
            IF ( l_debug_mode = 'Y' )
            THEN
                pa_debug.g_err_stage := TO_CHAR(l_stage) || ': New ER expenditure/ Raw VI/ Other.' ;
                pa_debug.write_file(pa_debug.g_err_stage);
                pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Deriving GL Info.';
                pa_debug.write_file(pa_debug.g_err_stage);
            END IF; -- debug
            IF ( p_calling_module = 'AR_INSTALLED_INVOICE' )
            THEN
                l_app_id := l_ar_app_id ;
            ELSIF ( p_calling_module =  'AR_NOT_INSTALLED_INVOICE' ) -- Bug 3710905
            THEN
                l_app_id := l_gl_app_id ;
            ELSE
                l_app_id := l_pa_gl_app_id ;
            END IF;

            IF ( p_calling_module = 'CAP_INT' )
            THEN
               l_app_id := l_pa_gl_app_id;		/* Modified l_gl_app_id for Bug 6904977 */
            END IF;

            l_prvdr_gl_date := pa_utils2.get_prvdr_gl_date( p_reference_date => p_expenditure_item_date
                                                           ,p_application_id => l_app_id
                                                           ,p_set_of_books_id => p_prvdr_sob_id
                                                          );
            l_prvdr_gl_period_name := g_prvdr_gl_period_name;

            IF ( derive.receiver <> 'N' AND p_expenditure_item_date IS NOT NULL )
            THEN
                l_recvr_gl_date := pa_utils2.get_recvr_gl_date( p_reference_date => p_expenditure_item_date
                                                               ,p_application_id => l_app_id
                                                               ,p_set_of_books_id => p_recvr_sob_id
                                                              );
                l_recvr_gl_period_name := g_recvr_gl_period_name;
            END IF;
        END IF; -- expense report check
      /*
       * Deriving PA periods for Provider.
       */
      IF ( l_use_same_pa_gl_period_prvdr = 'Y' AND
           ( p_calling_module <> 'AR_INSTALLED_INVOICE' OR p_calling_module <> 'AR_NOT_INSTALLED_INVOICE')
         )
      THEN
          l_stage := 500;
          IF ( l_debug_mode = 'Y' )
          THEN
              pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Copying Provider GL info to Provider PA';
              pa_debug.write_file(pa_debug.g_err_stage);
          END IF; -- debug
        /*
         * Copy Provider Gl period information to Provider Pa periods.
         */
        /*l_prvdr_pa_date := l_prvdr_gl_date;
        l_prvdr_pa_period_name := l_prvdr_gl_period_name;*/
	/*Commented the above code and added the below code for bug 7638790*/
	l_prvdr_pa_date := pa_utils2.get_prvdr_gl_date( p_reference_date => p_expenditure_item_date
                                                           ,p_application_id => l_pa_gl_app_id
                                                           ,p_set_of_books_id => p_prvdr_sob_id
                                                          );
        l_prvdr_pa_period_name := g_prvdr_gl_period_name;

      ELSE
        /*
         * Get Provider Pa periods based on ei date.
         */
        l_stage := 500;
        IF ( l_debug_mode = 'Y' )
        THEN
            pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Deriving Provider PA Info.';
            pa_debug.write_file(pa_debug.g_err_stage);
        END IF; -- debug
        IF (p_line_type <> 'R' AND p_system_linkage_function = 'VI')
        THEN
          IF ( p_prvdr_raw_pa_date_l IS NOT NULL )
          THEN
            l_prvdr_pa_date := pa_utils2.get_pa_date( p_ei_date => p_prvdr_raw_pa_date_l
                                                     ,p_gl_date => SYSDATE
                                                     ,p_org_id  => p_prvdr_org_id
                                                    );
            l_prvdr_pa_period_name := g_prvdr_pa_period_name;
          END IF;
        ELSE
          IF ( p_expenditure_item_date IS NOT NULL )
          THEN
            l_prvdr_pa_date := pa_utils2.get_pa_date( p_ei_date => p_expenditure_item_date
                                                     ,p_gl_date => SYSDATE
                                                     ,p_org_id  => p_prvdr_org_id
                                                    );
            l_prvdr_pa_period_name := g_prvdr_pa_period_name;
          END IF;
        END IF; -- burden VI cdl check.
      END IF; -- implementations option
      /*
       * Deriving PA periods for Receiver.
       * Receiver information need not be derived if calling module is CCDL.
       */
      IF ( p_calling_module <> 'CCDL' )
      THEN
          IF ( l_use_same_pa_gl_period_recvr = 'Y' AND p_calling_module <> 'AR_INSTALLED_INVOICE' )
          THEN
            /*
             * Copy Receiver Gl period information to Receiver Pa periods.
             */
            l_stage := 600;
            IF ( l_debug_mode = 'Y' )
            THEN
                pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Copying Receiver GenLedg Info to Receiver ProjAacc';
                pa_debug.write_file(pa_debug.g_err_stage);
            END IF; -- debug
            l_recvr_pa_date := l_recvr_gl_date;
            l_recvr_pa_period_name := l_recvr_gl_period_name;
          ELSE
            /*
             * Get Receiver Pa periods based on ei date.
             */
            l_stage := 700;
            IF ( l_debug_mode = 'Y' )
            THEN
                pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Deriving Receiver PA Info.';
                pa_debug.write_file(pa_debug.g_err_stage);
            END IF; -- debug
            IF (p_line_type <> 'R' AND p_system_linkage_function = 'VI')
            THEN
              IF ( derive.receiver <> 'N' AND p_recvr_raw_pa_date_l IS NOT NULL )
              THEN
                l_recvr_pa_date := pa_utils2.get_recvr_pa_date( p_ei_date => p_recvr_raw_pa_date_l
                                                               ,p_gl_date => SYSDATE
                                                               ,p_org_id  => p_recvr_org_id
                                                              );
                l_recvr_pa_period_name := g_recvr_pa_period_name;
              END IF;
            ELSE
              IF ( derive.receiver <> 'N' AND p_expenditure_item_date IS NOT NULL )
              THEN
                l_recvr_pa_date := pa_utils2.get_recvr_pa_date( p_ei_date => p_expenditure_item_date
                                                               ,p_gl_date => SYSDATE
                                                               ,p_org_id  => p_recvr_org_id
                                                              );
                l_recvr_pa_period_name := g_recvr_pa_period_name;
              END IF;
            END IF; -- burden VI cdl check.
          END IF; -- implementations option
      END IF ; -- CCDL Check
    ELSE
      /*
       * Profile Option is NOT SET.
       */
      /*
       * Get Pa periods based on ei date.
       * Get Gl periods based on above derived Pa date.
       */
      IF (p_line_type <> 'R' AND p_system_linkage_function = 'VI')
      THEN
        -- this area has to be revisited.
         IF ( p_prvdr_raw_pa_date_l IS NOT NULL )
         THEN
           l_prvdr_pa_date := pa_utils2.get_pa_date( p_ei_date => p_prvdr_raw_pa_date_l
                                                    ,p_gl_date => SYSDATE
                                                    ,p_org_id  => p_prvdr_org_id
                                                   );
           l_prvdr_pa_period_name := g_prvdr_pa_period_name;
         END IF;
         IF ( derive.receiver <> 'N' AND p_recvr_raw_pa_date_l IS NOT NULL )
         THEN
           l_recvr_pa_date := pa_utils2.get_recvr_pa_date( p_ei_date => p_recvr_raw_pa_date_l
                                                          ,p_gl_date => SYSDATE
                                                          ,p_org_id  => p_recvr_org_id
                                                         );
           l_recvr_pa_period_name := g_recvr_pa_period_name;
         END IF; -- p_calling_module
      ELSE
         IF ( p_expenditure_item_date IS NOT NULL )
         THEN
           l_prvdr_pa_date := pa_utils2.get_pa_date( p_ei_date => p_expenditure_item_date
                                                    ,p_gl_date => SYSDATE
                                                    ,p_org_id  => p_prvdr_org_id
                                                   );
           l_prvdr_pa_period_name := g_prvdr_pa_period_name;
         END IF;

         IF ( derive.receiver <> 'N' AND p_expenditure_item_date IS NOT NULL )
         THEN
           l_recvr_pa_date := pa_utils2.get_recvr_pa_date( p_ei_date => p_expenditure_item_date
                                                          ,p_gl_date => SYSDATE
                                                          ,p_org_id  => p_recvr_org_id
                                                         );
           l_recvr_pa_period_name := g_recvr_pa_period_name;
         END IF; -- p_calling_module
       END IF; -- burden VI cdl check.
       IF (p_system_linkage_function = 'ER' AND p_expenditure_id = g_prev_expenditure_id
           AND g_prev_expenditure_id IS NOT NULL AND p_calling_module = 'CDL')
       THEN
           IF ( l_debug_mode = 'Y' )
           THEN
               pa_debug.g_err_stage := TO_CHAR(l_stage) || ': ER - Same Expenditure Populating GL from Cache';
               pa_debug.write_file(pa_debug.g_err_stage);
           END IF; -- debug
           l_prvdr_gl_date := g_prev_prvdr_gl_date;
           l_prvdr_gl_period_name := g_prev_prvdr_gl_period_name;
           l_recvr_gl_date := g_prev_recvr_gl_date;
           l_recvr_gl_period_name := g_prev_recvr_gl_period_name;
       ELSE -- Either system_linkage is NOT 'ER' or expenditure_id has changed.
           IF ( l_debug_mode = 'Y' )
           THEN
               pa_debug.g_err_stage := TO_CHAR(l_stage) || ': NOT ER/exp_id has changed.' ;
               pa_debug.write_file(pa_debug.g_err_stage);
               pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Deriving GL Info.';
               pa_debug.write_file(pa_debug.g_err_stage);
           END IF; -- debug

           IF ( p_calling_module = 'AR_INSTALLED_INVOICE' )
           THEN
               l_app_id := l_ar_app_id ;
           ELSE
               l_app_id := l_gl_app_id ;
           END IF;

           /* Bug 8964378 - Commented following code as this is applicable
                            for enhanced period processing only
           IF ( p_calling_module = 'CAP_INT' )
           THEN
               l_app_id := l_pa_gl_app_id;		/* Modified l_gl_app_id for Bug 6904977 */
           /* END IF; */ -- Bug 8964378

        /* Bug 2965043: Passing expenditure item date instead of pa dates */
        /*Bug# 3617395 :Modified fix of 2965043 */
        IF (p_calling_module = 'AR_INSTALLED_INVOICE' OR p_calling_module = 'AR_NOT_INSTALLED_INVOICE')
         THEN
           IF ( p_expenditure_item_date IS NOT NULL )
           THEN
             l_prvdr_gl_date := pa_utils2.get_prvdr_gl_date( p_reference_date => p_expenditure_item_date
                                                            ,p_application_id => l_app_id
                                                            ,p_set_of_books_id => p_prvdr_sob_id
                                                           );
             l_prvdr_gl_period_name := g_prvdr_gl_period_name;
           END IF;

           IF ( derive.receiver <> 'N' AND p_expenditure_item_date IS NOT NULL )
           THEN
             l_recvr_gl_date := pa_utils2.get_recvr_gl_date( p_reference_date => p_expenditure_item_date
                                                            ,p_application_id => l_app_id
                                                            ,p_set_of_books_id => p_recvr_sob_id
                                                           );
        /* Code changes end for bug 2965043 */
             l_recvr_gl_period_name := g_recvr_gl_period_name;
           END IF;
        ELSE  /*Bug# 3617395*/
          IF ( l_prvdr_pa_date IS NOT NULL )
           THEN
             l_prvdr_gl_date := pa_utils2.get_prvdr_gl_date( p_reference_date => l_prvdr_pa_date
                                                            ,p_application_id => l_app_id
                                                            ,p_set_of_books_id => p_prvdr_sob_id
                                                           );
             l_prvdr_gl_period_name := g_prvdr_gl_period_name;
           END IF;

           IF ( derive.receiver <> 'N' AND l_recvr_pa_date IS NOT NULL )
           THEN
             l_recvr_gl_date := pa_utils2.get_recvr_gl_date( p_reference_date => l_recvr_pa_date
                                                            ,p_application_id => l_app_id
                                                            ,p_set_of_books_id => p_recvr_sob_id
                                                           );
             l_recvr_gl_period_name := g_recvr_gl_period_name;
           END IF;
        END IF; -- p_calling_module   /*Bug# 3617395*/
       END IF; -- expense report check
    END IF; -- profile option
    /*
     * Caching.
     * Caching not required for ccdl.
     */
    IF (p_system_linkage_function = 'ER' AND p_calling_module  = 'CCDL' )
    THEN
      IF (g_prev_expenditure_id <> p_expenditure_id OR g_prev_expenditure_id IS NULL )
      THEN
          IF ( l_debug_mode = 'Y' )
          THEN
              pa_debug.g_err_stage := TO_CHAR(l_stage) || ': ER - New Expenditure - Populating Cache.';
              pa_debug.write_file(pa_debug.g_err_stage);
          END IF; -- debug

        /*
         * Indicates new expenditure batch.
         */
        g_prev_expenditure_id := p_expenditure_id;
        g_prev_prvdr_gl_date := l_prvdr_gl_date;
        g_prev_prvdr_gl_period_name := l_prvdr_gl_period_name;
        g_prev_recvr_gl_date := l_recvr_gl_date;
        g_prev_recvr_gl_period_name := l_recvr_gl_period_name;

          IF ( l_debug_mode = 'Y' )
          THEN
              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                      ': g_prev_expenditure_id is [' || to_char(g_prev_expenditure_id) ||
                                      '] g_prev_prvdr_gl_date [' || to_char(g_prev_prvdr_gl_date) ||
                                      '] g_prev_prvdr_gl_period_name [' || g_prev_prvdr_gl_period_name ||']';
              pa_debug.write_file(pa_debug.g_err_stage);
              pa_debug.g_err_stage := TO_CHAR(l_stage) ||
                                      ': g_prev_recvr_gl_date is [' || to_char(g_prev_recvr_gl_date) ||
                                      '] g_prev_recvr_gl_period_name [' || g_prev_recvr_gl_period_name ||']';
              pa_debug.write_file(pa_debug.g_err_stage);
          END IF; -- debug
      ELSE
        /*
         * Leave the cache as it is.
         */
        NULL;
      END IF;
    ELSE -- system link is NOT 'ER'
        IF ( l_debug_mode = 'Y' )
        THEN
            pa_debug.g_err_stage := TO_CHAR(l_stage) || ': Not an ER. Wiping the Cache.';
            pa_debug.write_file(pa_debug.g_err_stage);
        END IF; -- debug

        /*
         * Wipe-off the cache.
         */
        g_prev_prvdr_gl_date := NULL;
        g_prev_prvdr_gl_period_name := NULL;
        g_prev_recvr_gl_date := NULL;
        g_prev_recvr_gl_period_name := NULL;
        g_prev_expenditure_id := NULL;
    END IF; -- system link check.

    /*
     * Populate the out variables.
     */
    /*
     * Check the availability of periods and set the error_code.
     */
    IF (l_prvdr_pa_date IS NULL OR l_prvdr_pa_period_name IS NULL)
    THEN
      x_error_code := 'NO_PA_DATE';
    ELSIF (l_prvdr_gl_date IS NULL OR l_prvdr_gl_period_name IS NULL)
    THEN
      x_error_code := 'NO_PRVDR_GL_DATE';
    ELSIF ( derive.receiver <> 'N' AND ( l_recvr_pa_date IS NULL OR l_recvr_pa_period_name IS NULL) )
    THEN
      x_error_code := 'NO_RECVR_PA_DATE';
    ELSIF ( derive.receiver <> 'N' AND ( l_recvr_gl_date IS NULL OR l_recvr_gl_period_name IS NULL) )
    THEN
      x_error_code := 'NO_RECVR_GL_DATE';
    END IF;

    x_prvdr_pa_date := l_prvdr_pa_date;
    x_prvdr_pa_period_name := l_prvdr_pa_period_name;
    x_prvdr_gl_date := l_prvdr_gl_date;
    x_prvdr_gl_period_name := l_prvdr_gl_period_name;
    x_recvr_pa_date := l_recvr_pa_date;
    x_recvr_pa_period_name := l_recvr_pa_period_name;
    x_recvr_gl_date := l_recvr_gl_date;
    x_recvr_gl_period_name := l_recvr_gl_period_name;

    IF ( l_debug_mode = 'Y' )
    THEN
        pa_debug.g_err_stage := TO_CHAR(l_stage) || ': x_prvdr_pa_date is [' || to_char(x_prvdr_pa_date) ||
                                                    '] x_prvdr_pa_period_name is ['|| x_prvdr_pa_period_name || ']';
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := TO_CHAR(l_stage) || ': x_prvdr_gl_date is [' || to_char(x_prvdr_gl_date) ||
                                                    '] x_prvdr_gl_period_name is ['|| x_prvdr_gl_period_name || ']';
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := TO_CHAR(l_stage) || ': x_recvr_pa_date is [' || to_char(x_recvr_pa_date) ||
                                                    '] x_recvr_pa_period_name is ['|| x_recvr_pa_period_name || ']';
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := TO_CHAR(l_stage) || ': x_recvr_gl_date is [' || to_char(x_recvr_gl_date) ||
                                                    '] x_recvr_gl_period_name is ['|| x_recvr_gl_period_name || ']';
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := TO_CHAR(l_stage) || ': x_error_code is [' || x_error_code || ']';
        pa_debug.write_file(pa_debug.g_err_stage);
    END IF;

  x_return_status := 0;
  pa_debug.reset_err_stack;

EXCEPTION
  WHEN others THEN
     x_error_stage := l_stage ;
     RAISE ;

END get_period_information ;
-----------------------------------------------------------------------
PROCEDURE get_OU_period_information ( p_reference_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                     ,p_calling_module IN VARCHAR2
                                     ,x_pa_date OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                     ,x_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                     ,x_gl_date OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                     ,x_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                     ,x_return_status  OUT NOCOPY NUMBER
                                     ,x_error_code OUT NOCOPY VARCHAR2
                                     ,x_error_stage OUT NOCOPY NUMBER
                                    )
IS
    l_org_id               pa_implementations_all.org_id%TYPE;
    l_sob_id               pa_implementations_all.set_of_books_id%TYPE;

    l_pa_date        pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
    l_pa_period_name pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
    l_gl_date        pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
    l_gl_period_name pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;

    l_return_status NUMBER ;
    l_stage         NUMBER ;
    l_error_code    VARCHAR2(30);
    l_debug_mode    VARCHAR2(1);

    l_date_dummy DATE;
    l_name_dummy VARCHAR2(30);
    l_calling_module VARCHAR2(30) := NULL ;
BEGIN
    pa_debug.init_err_stack('pa_utils2.get_ou_period_information');

    fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
    l_debug_mode := NVL(l_debug_mode, 'N');

    pa_debug.set_process('PLSQL','LOG',l_debug_mode);

    l_stage := 100;
    IF ( l_debug_mode = 'Y' )
    THEN
        pa_debug.g_err_stage := TO_CHAR(l_stage) || ':From get_ou_period_information';
        pa_debug.write_file(pa_debug.g_err_stage);
    END IF; -- debug

    x_return_status := -1 ;
    l_calling_module := p_calling_module ;

    SELECT NVL(imp.org_id, -99)
          ,imp.set_of_books_id
      INTO l_org_id
          ,l_sob_id
      FROM pa_implementations imp;

      l_stage := 200 ;
      IF ( l_debug_mode = 'Y' )
      THEN
          pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Calling pa_utils2.get_period_information';
          pa_debug.write_file(pa_debug.g_err_stage);
      END IF; -- debug

      pa_utils2.get_period_information
                            ( p_expenditure_item_date => p_reference_date
                             ,p_prvdr_org_id => l_org_id
                             ,p_prvdr_sob_id => l_sob_id
                             ,p_calling_module => l_calling_module
                             ,p_ou_context => 'Y'
                             ,x_prvdr_pa_date => l_pa_date
                             ,x_prvdr_pa_period_name => l_pa_period_name
                             ,x_prvdr_gl_date => l_gl_date
                             ,x_prvdr_gl_period_name => l_gl_period_name
                             ,x_recvr_pa_date => l_date_dummy
                             ,x_recvr_pa_period_name => l_name_dummy
                             ,x_recvr_gl_date => l_date_dummy
                             ,x_recvr_gl_period_name => l_name_dummy
                             ,x_return_status  => l_return_status
                             ,x_error_code => l_error_code
                             ,x_error_stage => l_stage
                            );

      l_stage := 300 ;
      IF ( l_debug_mode = 'Y' )
      THEN
          pa_debug.g_err_stage := TO_CHAR(l_stage) || ':After call to pa_utils2.get_period_information';
          pa_debug.write_file(pa_debug.g_err_stage);
          pa_debug.g_err_stage := TO_CHAR(l_stage) || ':PA date [' || to_char(l_pa_date) || '] name [' || l_pa_period_name || ']';
          pa_debug.write_file(pa_debug.g_err_stage);
          pa_debug.g_err_stage := TO_CHAR(l_stage) || ':GL date [' || to_char(l_gl_date) || '] name [' || l_gl_period_name || ']';
          pa_debug.write_file(pa_debug.g_err_stage);
          pa_debug.g_err_stage := TO_CHAR(l_stage) || ':Error Code [' || l_error_code || ']';
          pa_debug.write_file(pa_debug.g_err_stage);
      END IF; -- debug

    /*
     * Populate the out variables.
     */
    x_pa_date := l_pa_date;
    x_pa_period_name := l_pa_period_name;
    x_gl_date := l_gl_date;
    x_gl_period_name := l_gl_period_name;
    x_error_code := l_error_code;

  x_return_status := 0;
  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    x_error_stage := l_stage ;
    RAISE;
END get_OU_period_information;

-----------------------------------------------------------------------
  FUNCTION  get_gl_period_name ( p_gl_date  IN pa_cost_distribution_lines_all.gl_date%TYPE
                                ,p_org_id   IN pa_cost_distribution_lines_all.org_id%TYPE
                               )
  RETURN pa_cost_distribution_lines_all.gl_period_name%TYPE
  IS
       l_gl_period_name pa_cost_distribution_lines_all.gl_period_name%TYPE ;
       l_gl_period_start_date pa_cost_distribution_lines_all.gl_date%TYPE ;
       l_gl_period_end_date pa_cost_distribution_lines_all.gl_date%TYPE ;

  BEGIN
    /*
     * Try to reuse the global cache.
     * Otherwise, hit the database.
     */
    IF ( NVL(p_org_id, -99) = NVL(g_org_id, -99) AND
         TRUNC(p_gl_date) BETWEEN TRUNC(g_gl_period_start_date) AND TRUNC(g_gl_period_end_date))
    THEN
          RETURN g_gl_period_name ;
    ELSE
         SELECT glp.period_name
               ,glp.start_date
               ,glp.end_date
           INTO l_gl_period_name
               ,l_gl_period_start_date
               ,l_gl_period_end_date
           FROM gl_periods glp
               ,gl_sets_of_books glsob
               ,pa_implementations_all imp
          WHERE glsob.period_set_name = glp.period_set_name
            AND glp.period_type = glsob.accounted_period_type
            AND glp.adjustment_period_flag <> 'Y'
            AND glsob.set_of_books_id = imp.set_of_books_id
            AND TRUNC(p_gl_date) BETWEEN TRUNC(glp.start_date) AND TRUNC(glp.end_date)
            AND imp.org_id = p_org_id; --removed nvl for bug#6343739
         /*
          * Refresh the global variables.
          */
         g_org_id := p_org_id ;
         g_gl_period_start_date := l_gl_period_start_date ;
         g_gl_period_end_date := l_gl_period_end_date ;
         g_gl_period_name := l_gl_period_name ;

         RETURN l_gl_period_name ;
    END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
        l_gl_period_name := NULL ;
        RAISE;
  END get_gl_period_name ;
---------------------------------------------------------------
   FUNCTION get_set_of_books_id (p_org_id IN pa_implementations_all.org_id%TYPE)
   RETURN NUMBER IS
    l_set_of_books_id pa_implementations_all.set_of_books_id%TYPE;
   BEGIN

      SELECT imp.set_of_books_id
        INTO l_set_of_books_id
        FROM pa_implementations_all imp
       WHERE NVL(imp.org_id,-99) = NVL(p_org_id, -99);

      RETURN l_set_of_books_id;
   EXCEPTION
    WHEN  OTHERS THEN
      RETURN NULL;
   END get_set_of_books_id;

---------------------------------------------------------------
 /*
  * This function returns the end_date of the PA period in which the input date falls.
  */
 FUNCTION get_pa_period_end_date_OU ( p_date IN pa_periods_all.end_date%TYPE)
           RETURN pa_periods_all.end_date%TYPE
 IS
     l_end_date pa_periods_all.end_date%TYPE ;
 BEGIN

     SELECT pap.end_date
       INTO l_end_date
       FROM pa_periods pap
      WHERE trunc(p_date) between pap.start_date AND pap.end_date ;

     RETURN l_end_date ;
 EXCEPTION
   WHEN  OTHERS THEN
     RAISE;

 END get_pa_period_end_date_OU;
---------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-- API          : get_accrual_pa_dt_period
-- Description  : This procedure returns the pa_date and period_name based  on the reversing EI gl period Name
--                and EI Date for Reversing and original transactions respectively.
-- Parameters   :
--           IN :p_gl_period       - GL period of the reversing EI.
--               p_ei_date         - EI Date of the Trx.(Used for Org EI PA Date Derivation).
--               p_org_id          - Organization Id.
--               p_prvdr_recvr_flg - Provider/Receiver Flag.
--               p_epp_flag        - EPP Enabled Flag.
--               p_org_rev_fl      - Orginal/Reversing Transaction Flag.
--         OUT  :x_pa_date         - PA Date of the Trx.
--               x_pa_period_name  - PA Period Name for above date.
--               x_return_status   - Return status.
--               x_error_code      - Return Error Code.
----------------------------------------------------------------------------------------------------------------
PROCEDURE get_accrual_pa_dt_period( p_gl_period       IN  VARCHAR2
                                   ,p_ei_date         IN  DATE
                                   ,p_org_id          IN  pa_expenditure_items_all.org_id%TYPE
                                   ,p_prvdr_recvr_flg IN  VARCHAR2
                                   ,p_epp_flag        IN  VARCHAR2
                                   ,p_org_rev_flg     IN  VARCHAR2
                                   ,x_pa_date         OUT NOCOPY DATE
                                   ,x_pa_period_name  OUT NOCOPY VARCHAR2
                                   ,x_return_status   OUT NOCOPY VARCHAR2
                                   ,x_error_code      OUT NOCOPY VARCHAR2
                          )
IS
l_org_pa_date         pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
l_org_pa_start_date   pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
l_org_pa_end_date     pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
l_org_pa_period_name  pa_cost_distribution_lines_all.pa_period_name%TYPE;
l_rev_pa_date         pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
l_rev_pa_period_name  pa_cost_distribution_lines_all.pa_period_name%TYPE;
l_org_gl_period_name  pa_cost_distribution_lines_all.gl_period_name%TYPE;
l_pa_overlaps_gl      VARCHAR2(1) := 'N';
l_debug_mode                 VARCHAR2(1);
BEGIN

      ---Initialize the out var.

               x_pa_date        := NULL;
               x_pa_period_name := NULL;
               x_return_status  := FND_API.G_RET_STS_SUCCESS;
               x_error_code     := NULL;

     fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'N');

	IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.g_err_stage := 'get_accrual_pa_dt_per dt - '||to_char(p_ei_date);
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := 'get_accrual_pa_dt_per org - '||p_org_id;
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := 'get_accrual_pa_dt_per Org_Rev_Flg - '||p_org_rev_flg;
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := 'get_accrual_pa_dt_per prvdr_recvr_flg - '||p_prvdr_recvr_flg;
        pa_debug.write_file(pa_debug.g_err_stage);
     END IF;

     IF p_org_rev_flg = 'O' THEN -- This is for Original Transaction-----------------------------{

        IF p_prvdr_recvr_flg = 'P' THEN ------------------------{
          IF ((trunc(p_ei_date) BETWEEN g_prv_accr_prvdr_pa_start_date AND g_prv_accr_prvdr_pa_end_date)
                  AND g_prv_accr_prvdr_pa_start_date IS NOT NULL
                  AND g_prv_accr_prvdr_gl_period=p_gl_period)     THEN

                  IF p_epp_flag = 'Y' THEN
                     l_org_pa_date := p_ei_date;
                  ELSE
                     l_org_pa_date := g_prv_accr_prvdr_pa_end_date;
                  END IF;
		IF ( l_debug_mode = 'Y' )   THEN
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Org P Cache PA dt- '||to_char(l_org_pa_date);
                  pa_debug.write_file(pa_debug.g_err_stage);
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Org P Cache PA Per-'||g_prv_accr_prvdr_pa_period;
                  pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

                  x_pa_date        := l_org_pa_date;
                  x_pa_period_name := g_prv_accr_prvdr_pa_period;
                  return;
          END IF;
        ELSE ---- p_prvdr_recvr_flg = 'R'
          IF ((trunc(p_ei_date) BETWEEN g_prv_accr_recvr_pa_start_date AND g_prv_accr_recvr_pa_end_date)
                  AND g_prv_accr_recvr_pa_start_date IS NOT NULL
                  AND g_prv_accr_recvr_gl_period=p_gl_period)     THEN

                  IF p_epp_flag = 'Y' THEN
                     l_org_pa_date := p_ei_date;
                  ELSE
                     l_org_pa_date := g_prv_accr_recvr_pa_end_date;
                  END IF;
		IF ( l_debug_mode = 'Y' )   THEN
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Org R Cache PA dt- '||to_char(l_org_pa_date);
                  pa_debug.write_file(pa_debug.g_err_stage);
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Org R Cache PA Per-'||g_prv_accr_recvr_pa_period;
                  pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

              x_pa_date        := l_org_pa_date;
              x_pa_period_name := g_prv_accr_recvr_pa_period;
              return;
           END IF;
      END IF; -------p_prvdr_recvr_flg = P-----------}

        -- Either the Cache is empty / date is not in the range
        BEGIN
          SELECT papl.end_date,papl.start_date,papl.period_name,papl.gl_period_name
          INTO   l_org_pa_end_date,l_org_pa_start_date,l_org_pa_period_name,l_org_gl_period_name
          FROM   pa_periods_all papl
          WHERE  nvl(papl.org_id, -99 ) = nvl( p_org_id, -99 )
          AND trunc(p_ei_date) between papl.start_date  and papl.end_date;

          IF ( l_org_gl_period_name <> p_gl_period )
          THEN
            /* Bug#2476554
             * If PA Period derived above overlaps GL periods, PA date will be the end_date
             * of the last period in the earlier GL period. (In this case pa_date will
             * will usually end-up lesser than ei_date. This is OK.) The end_date will be
             * used for both EPP and non-EPP.
             */
		IF ( l_debug_mode = 'Y' )   THEN
            pa_debug.g_err_stage := 'DEBUG: gl periods are different ' || l_org_gl_period_name || p_gl_period;
            pa_debug.write_file(pa_debug.g_err_stage);
          END IF;

            l_pa_overlaps_gl := 'Y';
            SELECT papl.end_date,papl.start_date,papl.period_name
              INTO l_org_pa_end_date,l_org_pa_start_date,l_org_pa_period_name
              FROM pa_periods_all papl
             WHERE nvl(papl.org_id, -99 ) = nvl( p_org_id, -99 )
               AND papl.gl_period_name=p_gl_period
               AND papl.start_date= ( SELECT MAX(papl1.start_date)
                                        FROM pa_periods_all papl1
                                       WHERE nvl(papl1.org_id, -99 ) = nvl( p_org_id, -99 )
                                         AND papl1.gl_period_name=p_gl_period
                                    );
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
		IF ( l_debug_mode = 'Y' )   THEN
             pa_debug.g_err_stage := 'NDF - get_accrual_pa_dt_per Org PA dt ';
             pa_debug.write_file(pa_debug.g_err_stage);
		END IF;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             IF p_prvdr_recvr_flg = 'P' THEN
                x_error_code := 'NO_PA_DATE';
             ELSE
                x_error_code := 'NO_RECVR_PA_DATE';
             END IF;
             return;
         WHEN OTHERS THEN
	    IF ( l_debug_mode = 'Y' )   THEN
             pa_debug.g_err_stage := 'WO Excep - get_accrual_pa_dt_per Org PA Date';
             pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             raise;
        END;
             --- Assign the global variables
          IF p_prvdr_recvr_flg = 'P' THEN
             g_prv_accr_prvdr_pa_start_date := l_org_pa_start_date;
             g_prv_accr_prvdr_pa_end_date   := l_org_pa_end_date;
             g_prv_accr_prvdr_pa_period     := l_org_pa_period_name;
             g_prv_accr_prvdr_gl_period     := l_org_gl_period_name;
           ELSE
             g_prv_accr_recvr_pa_start_date := l_org_pa_start_date;
             g_prv_accr_recvr_pa_end_date   := l_org_pa_end_date;
             g_prv_accr_recvr_pa_period     := l_org_pa_period_name;
             g_prv_accr_recvr_gl_period     := l_org_gl_period_name;
           END IF;

                  IF ( p_epp_flag = 'N' or l_pa_overlaps_gl = 'Y' )
                  THEN
                     l_org_pa_date := l_org_pa_end_date;
                  ELSE
                     l_org_pa_date := p_ei_date;
                  END IF;
		IF ( l_debug_mode = 'Y' )   THEN
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Org SEL PA dt- '||to_char(l_org_pa_date);
                  pa_debug.write_file(pa_debug.g_err_stage);
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Org SEL PA Per-'||l_org_pa_period_name;
                  pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

              x_pa_date        := l_org_pa_date;
              x_pa_period_name := l_org_pa_period_name;
              return;

    ELSE ---- REV Transaction---p_org_rev_flg = 'R'--------------------------

        IF p_prvdr_recvr_flg = 'P' THEN

            IF p_gl_period = g_p_gl_period THEN

                     l_rev_pa_date := g_p_accr_rev_pa_date;
		  IF ( l_debug_mode = 'Y' )   THEN
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev P Cache PA dt- '||to_char(l_rev_pa_date);
                  pa_debug.write_file(pa_debug.g_err_stage);
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev P Cache PA Per-'||g_p_accr_rev_pa_period;
                  pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;

                  x_pa_date         :=  l_rev_pa_date;
             /*2476554*/
             if (p_epp_flag = 'Y' and p_ei_date >= l_rev_pa_date) then
                    x_pa_date := p_ei_date;
               end if;
                  x_pa_period_name  :=  g_p_accr_rev_pa_period;
                  return;

            END IF;
        ELSE --- Recvr

            IF p_gl_period = g_r_gl_period THEN
                     l_rev_pa_date := g_r_accr_rev_pa_date;
		  IF ( l_debug_mode = 'Y' )   THEN
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev R Cache PA dt- '||to_char(l_rev_pa_date);
                  pa_debug.write_file(pa_debug.g_err_stage);
                  pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev R Cache PA Per-'||g_r_accr_rev_pa_period;
                  pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;

                  x_pa_date         :=  l_rev_pa_date;
             /*2476554*/
             if (p_epp_flag = 'Y' and p_ei_date >= l_rev_pa_date) then
                    x_pa_date := p_ei_date;
               end if;
                  x_pa_period_name  :=  g_r_accr_rev_pa_period;
                  return;
            END IF;
        END IF;


       ---- Either the Cache is empty/ Date is not in the range.
       ----Rev EI GL date is used to get the pa date. EPP flag is checked in the select itself.
         BEGIN
          SELECT min(decode(p_epp_flag,'Y',papl.start_date,papl.end_date))
          INTO   l_rev_pa_date
          FROM   pa_periods_all papl
          WHERE  nvl(papl.org_id, -99 ) = nvl(p_org_id, -99 )
          AND    papl.gl_period_name = p_gl_period ;
         END;
	    IF ( l_debug_mode = 'Y' )   THEN
          pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev SEL min(Date) For GL per '||to_char(l_rev_pa_date);
          pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;

    IF l_rev_pa_date IS NOT NULL THEN

    -- Get the Period Name
        BEGIN
          SELECT period_name
          INTO   l_rev_pa_period_name
          FROM   pa_periods_all papl
          WHERE  nvl(papl.org_id, -99 ) = nvl(p_org_id, -99 )
          AND    trunc(l_rev_pa_date) between papl.start_date  and papl.end_date;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
		IF ( l_debug_mode = 'Y' )   THEN
             pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev NDF';
             pa_debug.write_file(pa_debug.g_err_stage);
		END IF;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             IF p_prvdr_recvr_flg = 'P' THEN
                x_error_code := 'PA_NO_REV_PRVDR_ACCR_PA_DATE';
             ELSE
                x_error_code := 'PA_NO_REV_RECVR_ACCR_PA_DATE';
             END IF;
             return;
         WHEN OTHERS THEN
	    IF ( l_debug_mode = 'Y' )   THEN
            pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev WO';
            pa_debug.write_file(pa_debug.g_err_stage);
		END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            raise;
        END;

        IF p_prvdr_recvr_flg = 'P' THEN
           g_p_gl_period  := p_gl_period;
           g_p_accr_rev_pa_period := l_rev_pa_period_name;
           g_p_accr_rev_pa_date   := l_rev_pa_date;
         ELSE
           g_r_gl_period  := p_gl_period;
           g_r_accr_rev_pa_period := l_rev_pa_period_name;
           g_r_accr_rev_pa_date   := l_rev_pa_date;
          END IF;

           x_pa_date         :=  l_rev_pa_date;
/*2476554*/
             if (p_epp_flag = 'Y' and p_ei_date >= l_rev_pa_date) then
                    x_pa_date := p_ei_date;
               end if;
           x_pa_period_name  :=  l_rev_pa_period_name;
     ELSE
     ---- Handle the error. PA_DATE_PERIOD NOT DEFINED for Reverse trx.
		IF ( l_debug_mode = 'Y' )   THEN
           pa_debug.g_err_stage := 'get_accrual_pa_dt_per Rev PA Period not defined';
           pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

           x_return_status := FND_API.G_RET_STS_ERROR ;

        IF p_prvdr_recvr_flg = 'P' THEN
           x_error_code := 'PA_NO_REV_PRVDR_ACCR_PA_DATE';
        ELSE
           x_error_code := 'PA_NO_REV_RECVR_ACCR_PA_DATE';
        END IF;
           return;

    END IF;
	IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.g_err_stage := 'Aft get_accrual_pa_dt_per sel  pa dt - '||to_char(x_pa_date);
        pa_debug.write_file(pa_debug.g_err_stage);
        pa_debug.g_err_stage := 'Aft get_accrual_pa_dt_per sel  pa period - '||x_pa_period_name;
        pa_debug.write_file(pa_debug.g_err_stage);
	 END IF;

  END IF; -------------------------------------------------------------------------------------------}

END;
----------------------------------------------------------------------------------------------------------------
-- API          : get_rev_accrual_date
-- Description  : This function returns the reversing accrual_dates.
-- Parameters   :
--           IN :p_calling_module  - Calling Module(CDL,PAXTREPE,TRXIMPORT)
--               p_reference_date  - Most of the time it is accrual Date of the Org Trx.
--               p_application_id  - Application Id (101).
--               p_set_of_books_id - Set of Books for that Org.
--               p_prvdr_recvr_flg - Provider/Receiver Flag.
--               p_epp_flag        - EPP Enabled Flag.
--         OUT  :x_gl_period_name  - GL Period Name  for that corresponding accr/gl date.
--               x_return_status   - Return status.
--               x_error_code      - Return Error Code.
--               x_error_stage     - Var to Capture the error messages.
----------------------------------------------------------------------------------------------------------------
FUNCTION get_rev_accrual_date( p_calling_module  IN  VARCHAR2,
                               p_reference_date  IN  DATE,
                               p_application_id  IN  NUMBER ,
                               p_set_of_books_id IN  gl_sets_of_books.set_of_books_id%TYPE,
                               p_prvdr_recvr_flg IN  VARCHAR2,
                               p_epp_flag        IN  VARCHAR2,
                               x_gl_period_name  OUT NOCOPY VARCHAR2,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_error_code      OUT NOCOPY VARCHAR2,
                               x_error_stage     OUT NOCOPY VARCHAR2
                          )
return date
IS
    l_org_accr_start_date            pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_org_accr_end_date              pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_rev_accr_nxt_st_dt             pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_rev_accr_nxt_end_dt            pa_cost_distribution_lines_all.gl_date%TYPE := NULL;

    l_rev_accr_dt                    pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_period_status                  gl_period_statuses.closing_status%TYPE := NULL;
    l_period_name                    gl_period_statuses.period_name%TYPE := NULL;
    l_debug_mode                     VARCHAR2(1);

BEGIN
        ---Initialize the out variables.
           x_gl_period_name := NULL;
           x_return_status  := FND_API.G_RET_STS_SUCCESS;
           x_error_code     := NULL;
	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'N');


        pa_debug.g_err_stage := 'get_rev_accrual_date() for ref dt- ['||to_char(p_reference_date)||']';
	   IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_rev_accrual_date() sob - ['||p_set_of_books_id||']';
	   IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_rev_accrual_date() prvdr_recvr_flg - ['||p_prvdr_recvr_flg||']';
	   IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;


     IF p_prvdr_recvr_flg  = 'P' THEN ------------------------------------{

         IF ((trunc(p_reference_date) BETWEEN g_p_org_accr_start_date AND g_p_org_accr_end_date )
                                          AND g_p_org_accr_end_date IS NOT NULL) THEN
		pa_debug.g_err_stage := 'Returning the accrual date from cache - get_rev_accrual_date()';
		IF ( l_debug_mode = 'Y' )   THEN
             pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

                  IF p_epp_flag = 'Y' THEN
                     l_rev_accr_dt := g_p_rev_accr_nxt_st_dt;
                  ELSE
                     l_rev_accr_dt := g_p_rev_accr_nxt_end_dt;
                  END IF;
                     x_gl_period_name := g_p_rev_gl_period_name;
                     return(l_rev_accr_dt);
        END IF;
     ELSIF p_prvdr_recvr_flg = 'R' THEN

         IF ((trunc(p_reference_date) BETWEEN g_r_org_accr_start_date AND g_r_org_accr_end_date )
                                          AND g_r_org_accr_end_date IS NOT NULL) THEN

             pa_debug.g_err_stage := 'Returning the accrual date from cache - get_rev_accrual_date()';
          IF ( l_debug_mode = 'Y' ) THEN
             pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

                  IF p_epp_flag = 'Y' THEN
                     l_rev_accr_dt := g_r_rev_accr_nxt_st_dt;
                  ELSE
                     l_rev_accr_dt := g_r_rev_accr_nxt_end_dt;
                  END IF;
                     x_gl_period_name := g_r_rev_gl_period_name;
                     return(l_rev_accr_dt);

        END IF;

     END IF; ------------------p_prvdr_recvr_flg = 'P'--------------------}

        ---Either the Cache is empty or the date is not in the range.

        pa_debug.g_err_stage := 'Before select get_rev_accrual_date() for ref dt-'||to_char(p_reference_date);
	   IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;

               BEGIN
                SELECT  PERIOD.start_date,PERIOD.end_date
                INTO    l_org_accr_start_date,l_org_accr_end_date
                FROM    GL_PERIOD_STATUSES PERIOD
                WHERE   PERIOD.application_id   = p_application_id
                AND     PERIOD.set_of_books_id  = p_set_of_books_id
                AND     PERIOD.adjustment_period_flag = 'N'
                AND     trunc(p_reference_date) BETWEEN PERIOD.start_date and PERIOD.end_date;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     x_return_status := FND_API.G_RET_STS_ERROR ;
                    IF p_prvdr_recvr_flg = 'P' THEN
                     x_error_code := 'PA_GL_REV_PRVDR_ACCR_NDEF';
                    ELSE
                     x_error_code := 'PA_GL_REV_RECVR_ACCR_NDEF';
                    END IF;
				pa_debug.g_err_stage :='NDF - Prvdr GL Period SELECT';
				IF ( l_debug_mode = 'Y' )   THEN
					pa_debug.write_file(pa_debug.g_err_stage);
				END IF;
                   return(NULL);
                  WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                   x_error_stage := 'Procedure: Pa_Utils2.Get_Accrual_Period_Information() ::: ' || pa_debug.g_err_stage ||':: '|| SQLERRM;
                   raise;
               END;


              BEGIN
                SELECT  PERIOD.start_date,PERIOD.end_date,PERIOD.closing_status,PERIOD.period_name
                INTO    l_rev_accr_nxt_st_dt,l_rev_accr_nxt_end_dt,l_period_status,l_period_name
                FROM    GL_PERIOD_STATUSES PERIOD
                WHERE   PERIOD.application_id   = p_application_id
                AND     PERIOD.set_of_books_id  = p_set_of_books_id
                AND     PERIOD.adjustment_period_flag = 'N'
                AND     PERIOD.start_date = ( SELECT  min(PERIOD.start_date)
                                              FROM    GL_PERIOD_STATUSES PERIOD
                                              WHERE   PERIOD.application_id   = p_application_id
                                              AND     PERIOD.set_of_books_id  = p_set_of_books_id
                                              AND     PERIOD.adjustment_period_flag = 'N'
                                              AND     PERIOD.start_date > l_org_accr_end_date);
              END;

              --Check the status here.
              IF l_period_status IN ('O','F') THEN -------------------------{
                 IF p_prvdr_recvr_flg = 'P' THEN
                     g_p_rev_accr_nxt_st_dt  := l_rev_accr_nxt_st_dt;
                     g_p_rev_accr_nxt_end_dt := l_rev_accr_nxt_end_dt;
                     g_p_org_accr_start_date := l_org_accr_start_date ;
                     g_p_org_accr_end_date   := l_org_accr_end_date ;
                     g_p_rev_gl_period_name  := l_period_name ;
                 ELSIF p_prvdr_recvr_flg = 'R' THEN
                     g_r_rev_accr_nxt_st_dt  := l_rev_accr_nxt_st_dt;
                     g_r_rev_accr_nxt_end_dt := l_rev_accr_nxt_end_dt;
                     g_r_org_accr_start_date := l_org_accr_start_date ;
                     g_r_org_accr_end_date   := l_org_accr_end_date ;
                     g_r_rev_gl_period_name  := l_period_name;
                END IF;
              ELSE -- Period is closed.
                     x_return_status :=  FND_API.G_RET_STS_ERROR;
                   IF p_prvdr_recvr_flg = 'P' THEN
                     x_error_code    := 'PA_GL_REV_PRVDR_ACCR_CLOSED';
                   ELSE
                     x_error_code    := 'PA_GL_REV_RECVR_ACCR_CLOSED';
                   END IF;
                   return(NULL);
              END IF; -----------------l_period_status IN ('O','F')----------}
        pa_debug.g_err_stage := 'get_rev_accrual_date st date is '||to_char(l_rev_accr_nxt_st_dt);
        IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_rev_accrual_date end date is '||to_char(l_rev_accr_nxt_end_dt);
    	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;

                  IF p_epp_flag = 'Y' THEN
                     l_rev_accr_dt := l_rev_accr_nxt_st_dt;
                  ELSE
                     l_rev_accr_dt := l_rev_accr_nxt_end_dt;
                  END IF;
                     x_gl_period_name := l_period_name;
                     return(l_rev_accr_dt);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_error_stage := 'Procedure: Pa_Utils2.Get_Accrual_Period_Information() ::: ' || pa_debug.g_err_stage ||':: '|| SQLERRM;
    RAISE;
END;
----------------------------------------------------------------------------------------------------------------
-- API          : get_accrual_gl_dt_period
-- Description  : This procedure is used to check if the gl/accrual date passed falls in a 'O'/'F' period.
--                If Yes then return the period name. In case of accrual dates check though we don't need
--                the period name, it is just used to check if the Dates are still in an O/F Period.
-- Parameters   :
--           IN :p_calling_module      - Calling Module(CDL,PAXTREPE,TRXIMPORT)
--               p_reference_date      - Accrual Date/GL Date of the Trx.
--               p_application_id      - Application Id (101).
--               p_set_of_books_id     - Set of Books for that Org.
--               p_prvdr_recvr_flg     - Provider/Receiver Flag.
--               p_epp_flag            - EPP Enabled Flag.
--         OUT  :x_gl_accr_period_name - GL Period Name  for that corresponding accr/gl date.
--               x_gl_accr_dt          - GL Date.
--               x_return_status       - Return status.
--               x_error_code          - Return Error Code.
--               x_error_stage         - Var to Capture the error messages.
----------------------------------------------------------------------------------------------------------------
PROCEDURE get_accrual_gl_dt_period(p_calling_module   IN  VARCHAR2,
                                p_reference_date      IN  DATE,
                                p_application_id      IN  NUMBER ,
                                p_set_of_books_id     IN  gl_sets_of_books.set_of_books_id%TYPE,
                                p_prvdr_recvr_flg     IN  VARCHAR2,
                                p_epp_flag            IN  VARCHAR2,
                                x_gl_accr_period_name OUT NOCOPY VARCHAR2,
                                x_gl_accr_dt          OUT NOCOPY DATE,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_error_code          OUT NOCOPY VARCHAR2,
                                x_error_stage         OUT NOCOPY VARCHAR2
                              )
IS
    l_accr_gl_period_name          pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
    l_accr_gl_dt                   pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_accr_gl_period_st_dt         pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_accr_gl_period_end_dt        pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_period_status                gl_period_statuses.closing_status%TYPE :=NULL;
    l_debug_mode				VARCHAR2(1);
BEGIN

        ---Initialize the out variables.
           x_gl_accr_period_name := NULL;
           x_gl_accr_dt          := NULL;
           x_return_status       := FND_API.G_RET_STS_SUCCESS;
           x_error_code          := NULL;
	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
     l_debug_mode := NVL(l_debug_mode, 'N');

        pa_debug.g_err_stage := 'get_accrual_gl_dt_period() for ref dt- ['||to_char(p_reference_date)||']';
	   IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period() sob - ['||p_set_of_books_id||']';
	   IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period() prvdr_recvr_flg - ['||p_prvdr_recvr_flg||']';
	   IF ( l_debug_mode = 'Y' ) THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;

     IF p_prvdr_recvr_flg  = 'P' THEN -------------------------------------------------{

        IF ((trunc(p_reference_date) BETWEEN g_p_accr_gl_per_st_dt AND g_p_accr_gl_per_end_dt )
                  AND g_p_accr_gl_per_st_dt IS NOT NULL) THEN ----------------------------P Cache------{

                 ---From Cache
                  IF p_epp_flag = 'Y' THEN
                     l_accr_gl_dt := p_reference_date;
                  ELSE
                     l_accr_gl_dt := g_p_accr_gl_per_end_dt;
                  END IF;

              pa_debug.g_err_stage := 'get_accrual_gl_dt_period() P Cache dt- ['||to_char(l_accr_gl_dt)||']';
		    IF ( l_debug_mode = 'Y' )   THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		    END IF;
              pa_debug.g_err_stage := 'get_accrual_gl_dt_period() P Cache Per- ['||g_p_accr_gl_per_name||']';
		    IF ( l_debug_mode = 'Y' )   THEN
              pa_debug.write_file(pa_debug.g_err_stage);
	    	    END IF;
                  --Assign the out variables.
                  x_gl_accr_dt := l_accr_gl_dt ;
                  x_gl_accr_period_name := g_p_accr_gl_per_name;
                  return;
         END IF; ------------------------------------------------------------------------P Cache------}

     ELSIF p_prvdr_recvr_flg = 'R' THEN

        IF ((trunc(p_reference_date) BETWEEN g_r_accr_gl_per_st_dt AND g_r_accr_gl_per_end_dt )
                  AND g_r_accr_gl_per_st_dt IS NOT NULL) THEN ----------------------------R Cache------{

                 ---From Cache
                  IF p_epp_flag = 'Y' THEN
                     l_accr_gl_dt := p_reference_date;
                  ELSE
                     l_accr_gl_dt := g_r_accr_gl_per_end_dt;
                  END IF;
              pa_debug.g_err_stage := 'get_accrual_gl_dt_period() R Cache dt- ['||to_char(l_accr_gl_dt)||']';
		    IF ( l_debug_mode = 'Y' )   THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		    END IF;
              pa_debug.g_err_stage := 'get_accrual_gl_dt_period() R Cache Per- ['||g_r_accr_gl_per_name||']';
		    IF ( l_debug_mode = 'Y' )   THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		    END IF;
                  --Assign the out variables.
                  x_gl_accr_dt := l_accr_gl_dt ;
                  x_gl_accr_period_name := g_r_accr_gl_per_name;
                  return;
         END IF;

     END IF;---------------p_prvdr_recvr_flg  = 'P'-----------------------------}
     --- Either the cache is empty or the reference date is not in the range.
                 BEGIN
                  SELECT PERIOD.period_name,PERIOD.start_date,PERIOD.end_date,PERIOD.closing_status
                  INTO   l_accr_gl_period_name, l_accr_gl_period_st_dt,l_accr_gl_period_end_dt,l_period_status
                  FROM   GL_PERIOD_STATUSES PERIOD
                  WHERE  PERIOD.application_id   = p_application_id
                  AND    PERIOD.set_of_books_id  = p_set_of_books_id
                  AND    PERIOD.adjustment_period_flag = 'N'
                  AND    trunc(p_reference_date) BETWEEN PERIOD.start_date and PERIOD.end_date;
                 EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     x_return_status := FND_API.G_RET_STS_ERROR ;
                    IF p_prvdr_recvr_flg = 'P' THEN
                     x_error_code := 'PA_GL_PER_PRVDR_ACCR_NOT_DEF';
                    ELSE
                     x_error_code := 'PA_GL_PER_RECVR_ACCR_NOT_DEF';
                    END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-NDF for ref dt- ['||to_char(p_reference_date)||']';
        IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-NDF sob - ['||p_set_of_books_id||']';
        IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-NDF prvdr_recvr_flg - ['||p_prvdr_recvr_flg||']';
        IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
                  return;
                  WHEN OTHERS THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-WO sob - ['||p_set_of_books_id||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-WO prvdr_recvr_flg - ['||p_prvdr_recvr_flg||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-WO for ref dt- ['||to_char(p_reference_date)||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
	   x_error_stage := 'Procedure: Pa_Utils2.Get_Accrual_Period_Information() ::: ' || pa_debug.g_err_stage ||':: '|| SQLERRM;
                   raise;
                 END;
                  -- EPP Derivation.
                  IF p_epp_flag = 'Y' THEN
                     l_accr_gl_dt := p_reference_date;
                  ELSE
                     l_accr_gl_dt := l_accr_gl_period_end_dt;
                  END IF;

              --Check the status here.
              IF l_period_status in ('O','F') THEN --------------------------{
                 IF p_prvdr_recvr_flg = 'P' THEN
                   g_p_accr_gl_per_name   := l_accr_gl_period_name;
                   g_p_accr_gl_per_st_dt  := l_accr_gl_period_st_dt ;
                   g_p_accr_gl_per_end_dt := l_accr_gl_period_end_dt;
                 ELSIF p_prvdr_recvr_flg = 'R' THEN
                   g_r_accr_gl_per_name   := l_accr_gl_period_name;
                   g_r_accr_gl_per_st_dt  := l_accr_gl_period_st_dt ;
                   g_r_accr_gl_per_end_dt := l_accr_gl_period_end_dt;
                  END IF;

        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-SEL for accr/gl dt- ['||to_char(l_accr_gl_dt)||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-SEL sob - ['||p_set_of_books_id||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-SEL prvdr_recvr_flg - ['||p_prvdr_recvr_flg||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()-SEL gl period name - ['||l_accr_gl_period_name||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
                   x_gl_accr_dt           := l_accr_gl_dt ;
                   x_gl_accr_period_name  := l_accr_gl_period_name ;

               ELSE -- Period is closed.
                     x_return_status :=  FND_API.G_RET_STS_ERROR;
                     x_gl_accr_period_name  := l_accr_gl_period_name ; -- We need this for accounted TRX.
                   IF p_prvdr_recvr_flg = 'P' THEN
                     x_error_code    := 'PA_GL_PER_PRVDR_ACCR_CLOSED';
                   ELSE
                     x_error_code    := 'PA_GL_PER_RECVR_ACCR_CLOSED';
                   END IF;

        pa_debug.g_err_stage := 'get_accrual_gl_dt_period() Period Clsd ref dt- ['||to_char(p_reference_date)||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := ' get_accrual_gl_dt_period()Period Clsd sob - ['||p_set_of_books_id||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'get_accrual_gl_dt_period()Period Clsd prvdr_recvr_flg - ['||p_prvdr_recvr_flg||']';
	   IF ( l_debug_mode = 'Y' )   THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
      END IF;---------------------l_period_status in ('O','F')------------}

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     x_error_stage := 'Procedure: Pa_Utils2.Get_Accrual_Period_Information() ::: ' || pa_debug.g_err_stage ||':: '|| SQLERRM;
     raise;
END;
----------------------------------------------------------------------------------------------------------------
-- API          : get_accrual_period_information
-- Description  : This is main procedure to derive the accrual dates, gl dates, GL Periods, PA Dates
--                and the Corresponding PA Periods.If any of them are null/not in a O/F period, then
--                an appropriate error code is returned to the calling program.
-- Parameters   :
--           IN :p_expenditure_item_date - EI Date of the Trx.
--               p_reference_date      - Accrual Date/GL Date of the Trx.
--               p_application_id      - Application Id (101).
--               p_prvdr_org_id        - Provider Organization Id.
--               p_recvr_org_id        - Receiver Organization Id.
--               p_prvdr_sob_id        - Provider Set of Books for that Org.
--               p_recvr_sob_id        - Receiver Set of Books for that Org.
--               p_calling_module      - Calling Module(CDL,PAXTREPE,TRXIMPORT)
--               p_adj_ei_id           - Adjusted item id. We check if it is not null or not.
--               p_acct_flag           - Flag to indicate an accounted Transaction.
--         OUT  :x_prvdr_pa_date       - Provider PA Date.
--               x_prvdr_gl_period_name- Provider GL Period Name  for that corresponding gl date.
--               x_prvdr_pa_period_name- Provider PA Period Name  for that corresponding ei date.
--               x_recvr_pa_date       - Receiver PA Date.
--               x_recvr_gl_period_name- Receiver GL Period Name  for that corresponding gl date.
--               x_recvr_pa_period_name- Receiver PA Period Name  for that corresponding ei date.
--               x_return_status       - Return status.
--               x_error_code          - Return Error Code.
--               x_error_stage         - Var to Capture the error messages.
--      IN OUT  :x_prvdr_accrual_date  - Provider Accrual Date. Values is passed in the same var for Rev Trx.
--               x_recvr_accrual_date  - Receiver Accrual Date. Values is passed in the same var for Rev Trx.
--               x_prvdr_gl_date       - Provider GL Date.IN (TRXIMPORT) OUT(CDL)
/*=====================================================================================================*
 * This procedure is called from Costing prog/Trx import/PAXTREPE (Pre-Approved Batches)               *
 * Before each call, the accrual data/accrual flag,accounted_flag, and                                 *
 * system_linkage_function = 'PJ'(misc) is checked.                                                    *
 * Process Logic :                                                                                     *
 * 1.Accrual Dates -                                                                                   *
 * If the Call is from the Costing program then the accrual dates will be not null, where as           *
 * for Transaction import, and the exp entry form, we need to derive the accrual dates.                *
  _____________________________________________________________________________________________________
  |Description : Derive Accrual Dates                                                                  |
  |___________________________________________________________________________________________________ |
  | EI Date  |REV EI | EPP  | Accrual Date |  GL Date  | PA Date  |         Logic                      |
  |__________|_______|______|______________|___________|__________|____________________________________|
  |27-JAN-02 |  NO   | YES  | 27-JAN-02    |    -      |   -      |  Accrual date is same as EI Date   |
  |__________|_______|______|______________|___________|__________|____________________________________|
  |27-JAN-02 |  NO   | NO   | 31-JAN-02    |    -      |   -      |  Last day of the current GL Period |
  |          |       |      |              |           |          |  GL Period 01-JAN-02 to 31-JAN-02  |
  |----------|-----------------------------------------------------------------------------------------|
  |27-JAN-02 |  YES  | YES  | 01-FEB-02    |    -      |   -      | First Day of the Next O,F GL Period|
  |__________|_______|______|______________|___________|__________|____________________________________|
  |27-JAN-02 |  YES  |  NO  | 28-FEB-02    |    -      |   -      | Last Day of the Next O,F GL Period |
  |__________|_______|______|______________|___________|__________|____________________________________|
  |                                                                                                    |
  |Description : Derive GL Dates. GL Date is same as accrual Date, but it has to be in an open period. |
  |___________________________________________________________________________________________________ |
  |27-JAN-02 |  NO   | YES  | 27-JAN-02    |27-JAN-02  |   -      | GL Date is same as the Accrual Dt. |
  |__________|_______|______|______________|___________|__________|____________________________________|
  |27-JAN-02 |  NO   | NO   | 31-JAN-02    |31-JAN-02  |   -      | GL Date is same as the Accrual Dt. |
  |          |       |      |              |           |          |                                    |
  |----------|-----------------------------------------------------------------------------------------|
  |27-JAN-02 |  YES  | YES  | 01-FEB-02    | 01-FEB-02 |   -      | GL Date is same as the Accrual Dt. |
  |__________|_______|______|______________|___________|__________|____________________________________|
  |27-JAN-02 |  YES  |  NO  | 28-FEB-02    | 28-FEB-02 |   -      | GL Date is same as the Accrual Dt. |
  |__________|_______|______|______________|___________|__________|____________________________________|
  |                                                                                                    |
  |Description : Derive PA Dates.                                                                      |
  |___________________________________________________________________________________________________ |
  |27-JAN-02 |  NO   | YES  | 27-JAN-02    |27-JAN-02  |27-JAN-02 | Same as the EI Date.               |
  |__________|_______|______|______________|___________|__________|____________________________________|
  |27-JAN-02 |  NO   | NO   | 31-JAN-02    |31-JAN-02  |31-JAN-02 | End date of the PA Period where    |
  |          |       |      |              |           |          | the EI falls bt. start and End Dt. |
  |----------|-----------------------------------------------------------------------------------------|
  |27-JAN-02 |  YES  | YES  | 01-FEB-02    | 01-FEB-02 |01-FEB-02 | First PA Period Date where the Rev |
  |          |       |      |              |           |          | GL Per.is bt.the start and end dt. |
  |          |       |      |              |           |          | Its the min(start_date).           |
  |----------|-----------------------------------------------------------------------------------------|
  |27-JAN-02 |  YES  |  NO  | 28-FEB-02    | 28-FEB-02 |28-FEB-02 | Last PA Period Date where the Rev  |
  |          |       |      |              |           |          | GL Per. is bt.the start and end dt.|
  |          |       |      |              |           |          | Its the min(end_date).             |
  ------------------------------------------------------------------------------------------------------
 *======================================================================================================*/
----------------------------------------------------------------------------------------------------------------
PROCEDURE get_accrual_period_information(p_expenditure_item_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                   ,x_prvdr_accrual_date IN OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                   ,x_recvr_accrual_date   IN  OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                   ,p_prvdr_org_id         IN  pa_expenditure_items_all.org_id%TYPE
                                   ,p_recvr_org_id         IN  pa_expenditure_items_all.org_id%TYPE
                                   ,p_prvdr_sob_id         IN  pa_implementations_all.set_of_books_id%TYPE
                                   ,p_recvr_sob_id         IN  pa_implementations_all.set_of_books_id%TYPE
                                   ,p_calling_module       IN  VARCHAR2
                                   ,x_prvdr_pa_date        OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                   ,x_prvdr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                   ,x_prvdr_gl_date        IN  OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                   ,x_prvdr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                   ,x_recvr_pa_date        OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_date%TYPE
                                   ,x_recvr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE
                                   ,x_recvr_gl_date        OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_date%TYPE
                                   ,x_recvr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE
                                   ,p_adj_ei_id            IN  pa_expenditure_items_all.expenditure_item_id%type
                                   ,p_acct_flag            IN  VARCHAR2
                                   ,x_return_status        OUT NOCOPY VARCHAR2
                                   ,x_error_code           OUT NOCOPY VARCHAR2
                                   ,x_error_stage          OUT NOCOPY VARCHAR2
                                 )
IS
    l_prvdr_pa_date           pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
    l_prvdr_pa_period_name    pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
    l_prvdr_gl_period_name    pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;
    l_recvr_pa_date           pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
    l_recvr_pa_period_name    pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
    l_recvr_gl_period_name    pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;
    l_prvdr_accrual_date      pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_prvdr_gl_date           pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_recvr_gl_date           pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
    l_recvr_accrual_date      pa_cost_distribution_lines_all.gl_date%TYPE := NULL;

    l_pa_gl_app_id NUMBER := 101; -- We always go against the GL Period.
    l_gl_app_id NUMBER := 101;
    l_app_id NUMBER := NULL ;

  /*
   * Processing related variables.
   */
  l_error_stage                VARCHAR2(2000);
  l_debug_mode                 VARCHAR2(1);

  l_prof_new_gldate_derivation VARCHAR2(1) := 'N';

BEGIN



  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  l_debug_mode := NVL(l_debug_mode, 'N');
  pa_debug.g_err_stage :='From get_accrual_period_information';
  IF(l_debug_mode = 'Y') THEN
	  pa_debug.init_err_stack('pa_utils2.get_accrual_period_information');
	  pa_debug.set_process('PLSQL','LOG',l_debug_mode);

	  pa_debug.write_file(pa_debug.g_err_stage);
  END IF;

  if g_prof_new_gldate_derivation IS NULL then
   l_prof_new_gldate_derivation := nvl(fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION'),'N') ; /*For Bug 5391468*/
   g_prof_new_gldate_derivation := l_prof_new_gldate_derivation;
  else
   l_prof_new_gldate_derivation := g_prof_new_gldate_derivation;
  end if;
  pa_debug.g_err_stage :='EPP Flag is :['||l_prof_new_gldate_derivation||']';
 IF(l_debug_mode = 'Y') THEN
  pa_debug.write_file(pa_debug.g_err_stage);
 END IF;

  ---Initialize the error var.
     x_error_code    := NULL;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

         pa_debug.g_err_stage :=' Profile option is [' || l_prof_new_gldate_derivation || ']';
         IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='x_prvdr_accrual_date is [' || to_char(x_prvdr_accrual_date) || ']';
         IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='x_recvr_accrual_date is [' || to_char(x_recvr_accrual_date) || ']';
         IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='p_expenditure_item_date is [' || to_char(p_expenditure_item_date) || ']';
         IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='x_prvdr_gl_date is [' || to_char(x_prvdr_gl_date) || ']';
         IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='x_recvr_gl_date is [' || to_char(x_recvr_gl_date) || ']';
         IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='p_prvdr_org_id is [' || to_char(p_prvdr_org_id) || ']';
         IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='p_recvr_org_id is [' || to_char(p_recvr_org_id) || ']';
	    IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='p_prvdr_sob_id is [' || to_char(p_prvdr_sob_id) || ']';
	    IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='p_recvr_sob_id is [' || to_char(p_recvr_sob_id) || ']';
	    IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;
         pa_debug.g_err_stage :='p_calling_module is [' || p_calling_module || ']';
	    IF(l_debug_mode = 'Y') THEN
         pa_debug.write_file(pa_debug.g_err_stage);
	    END IF;

    --- We derive the accrual dates for TRXIMPORT(Unaccounted)/Pre-Approved Batch(PAXTREPE).

    IF p_calling_module in ( 'TRXIMPORT','PAXTREPE') AND NVL(p_acct_flag,'N') = 'N' THEN  ------------------------{
       pa_debug.g_err_stage :='Getting the accrual Dates for TRX/PAX';
	  IF(l_debug_mode = 'Y') THEN
		pa_debug.write_file(pa_debug.g_err_stage);
	  END IF;
   		x_error_stage := pa_debug.g_err_stage;
     IF p_adj_ei_id IS NULL THEN  -------------ORG EI--------------------{
	  pa_debug.g_err_stage :='Getting the accrual Dates for TRX/PAX ORG EI';
	  IF(l_debug_mode = 'Y') THEN
		pa_debug.write_file(pa_debug.g_err_stage);
	  END IF;
	     x_error_stage := pa_debug.g_err_stage;

            --- Though this api returns the period name also, we don't make use of it at this stage.
              BEGIN
               pa_utils2.get_accrual_gl_dt_period( p_calling_module => p_calling_module
                                               ,p_reference_date      => p_expenditure_item_date
                                               ,p_application_id      => l_pa_gl_app_id
                                               ,p_set_of_books_id     => p_prvdr_sob_id
                                               ,p_prvdr_recvr_flg     => 'P'
                                               ,p_epp_flag            => l_prof_new_gldate_derivation
                                               ,x_gl_accr_period_name => l_prvdr_gl_period_name
                                               ,x_gl_accr_dt          => l_prvdr_accrual_date
                                               ,x_return_status       => x_return_status
                                               ,x_error_code          => x_error_code
                                               ,x_error_stage         => x_error_stage
                                               );
              END;
                      -- Error encountered!!!
                     IF x_error_code is NOT NULL THEN
                       return;
                     END IF;
	 pa_debug.g_err_stage := 'Prvdr accrual Date for ORG EI TRX/PAX -'||to_char(l_prvdr_accrual_date);
	 IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	 END IF;
	 x_error_stage := pa_debug.g_err_stage;
          --- If provider and receiver are of same org, then don't derive the accrual date for RECVR
           IF p_prvdr_org_id = p_recvr_org_id THEN ---------------------------------{

             l_recvr_accrual_date := l_prvdr_accrual_date;
		   pa_debug.g_err_stage := 'Recvr accrual Date is Same as Prvdr for ORG EI TRX/PAX';
		  IF(l_debug_mode = 'Y') THEN
			pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;
		   x_error_stage := pa_debug.g_err_stage;

           ELSE  ----Do the check for O/F status.

            -- Though we are not deriving the gl_period_name , this api is multi-function.
            -- It checks if the ei date is in an O/F period. This check is for RECVR.
              BEGIN
               pa_utils2.get_accrual_gl_dt_period( p_calling_module => p_calling_module
                                               ,p_reference_date      => p_expenditure_item_date
                                               ,p_application_id      => l_pa_gl_app_id
                                               ,p_set_of_books_id     => p_recvr_sob_id
                                               ,p_prvdr_recvr_flg     => 'R'
                                               ,p_epp_flag            => l_prof_new_gldate_derivation
                                               ,x_gl_accr_period_name => l_recvr_gl_period_name
                                               ,x_gl_accr_dt          => l_recvr_accrual_date
                                               ,x_return_status       => x_return_status
                                               ,x_error_code          => x_error_code
                                               ,x_error_stage         => x_error_stage
                                               );
              END;
                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     END IF;
		  pa_debug.g_err_stage := 'Recvr accrual Date for ORG EI TRX/PAX -'||to_char(l_recvr_accrual_date);
		  IF(l_debug_mode = 'Y') THEN
               pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;
		  x_error_stage := pa_debug.g_err_stage;

            END IF; ----------------------p_prvdr_org_id = p_recvr_org_id------------------}

     ELSE -----------------------For Reversing EI

      --- For REV EI, the accrual dates of the
      --- ORG EI are passed. Since its an IN OUT parameter, we read and write to the same parameter.
      --- For REV EI, the accrual date is the first/last day of the next O,F GL Period depending on EPP.

             l_prvdr_accrual_date := pa_utils2.get_rev_accrual_date(p_calling_module => p_calling_module
                                                               ,p_reference_date =>x_prvdr_accrual_date
                                                               ,p_application_id  => l_pa_gl_app_id
                                                               ,p_set_of_books_id => p_prvdr_sob_id
                                                               ,p_prvdr_recvr_flg => 'P'
                                                               ,p_epp_flag        => l_prof_new_gldate_derivation
                                                               ,x_gl_period_name  => l_prvdr_gl_period_name
                                                               ,x_return_status   => x_return_status
                                                               ,x_error_code      => x_error_code
                                                               ,x_error_stage     => x_error_stage);
                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     END IF;
	pa_debug.g_err_stage := 'Prvdr accrual Date for Rev EI TRX/PAX -'||to_char(l_prvdr_accrual_date);
	IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	END IF;
	x_error_stage := pa_debug.g_err_stage;

           IF p_prvdr_org_id = p_recvr_org_id THEN -------------------------{

             l_recvr_accrual_date := l_prvdr_accrual_date;
		  pa_debug.g_err_stage := 'Recvr accrual Date= Prvdr Accrual Date for Rev EI TRX/PAX';
		  IF(l_debug_mode = 'Y') THEN
             pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;
		  x_error_stage := pa_debug.g_err_stage;

           ELSE
             l_recvr_accrual_date := pa_utils2.get_rev_accrual_date( p_calling_module => p_calling_module
                                                               ,p_reference_date =>x_recvr_accrual_date
                                                               ,p_application_id => l_pa_gl_app_id
                                                               ,p_set_of_books_id => p_recvr_sob_id
                                                               ,p_prvdr_recvr_flg => 'R'
                                                               ,p_epp_flag        => l_prof_new_gldate_derivation
                                                               ,x_gl_period_name  => l_recvr_gl_period_name
                                                               ,x_return_status   => x_return_status
                                                               ,x_error_code      => x_error_code
                                                               ,x_error_stage     => x_error_stage);

                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     END IF;
            pa_debug.g_err_stage := 'Recvr accrual Date for Rev EI Trx/Pax -'||to_char(l_recvr_accrual_date);
		  IF(l_debug_mode = 'Y') THEN
             pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;
		  x_error_stage := pa_debug.g_err_stage;
           END IF; ---------------p_prvdr_org_id = p_recvr_org_id-------------}

     END IF; ---------------------ORG EI---------------------------------------------------}


           x_prvdr_accrual_date := l_prvdr_accrual_date;
           x_recvr_accrual_date := l_recvr_accrual_date;

           pa_debug.g_err_stage := ' x_prvdr accr Dt for  EI TRX/PAX -'||to_char(x_prvdr_accrual_date);
		 IF(l_debug_mode = 'Y') THEN
           pa_debug.write_file(pa_debug.g_err_stage);
		 END IF;
           pa_debug.g_err_stage := 'x_recvr accr Dt for  EI TRX/PAX -'||to_char(x_recvr_accrual_date);
		 IF(l_debug_mode = 'Y') THEN
           pa_debug.write_file(pa_debug.g_err_stage);
 		 END IF;
           return; -- We don't need anything after this point for Unaccounted TRXIMPORT and PAXTREPE Transactions.

    END IF; ------( 'TRXIMPORT','PAXTREPE') AND NVL(p_acct_flag,'N') = 'N' --------------------------------}

         ---- Call is for CDL/Accounted Transaction Import(TRXIMPRT)

    IF p_calling_module = 'CDL' OR  NVL(p_acct_flag,'N') = 'Y' THEN  ------------------------{

        IF p_calling_module = 'CDL'  THEN-------------------------{

           pa_debug.g_err_stage :='Call is from Costing program';
		 IF(l_debug_mode = 'Y') THEN
           pa_debug.write_file(pa_debug.g_err_stage);
		 END IF;
           pa_debug.g_err_stage := 'Prvdr accr Dt from CDL call -'||to_char(x_prvdr_accrual_date);
		 IF(l_debug_mode = 'Y') THEN
           pa_debug.write_file(pa_debug.g_err_stage);
		 END IF;
           pa_debug.g_err_stage := ' Recvr accr Dt from CDL call -'||to_char(x_recvr_accrual_date);
		 IF(l_debug_mode = 'Y') THEN
           pa_debug.write_file(pa_debug.g_err_stage);
		 END IF;

            --- We make use of the GL period name.
            --- This is just to check if the accrual date is still in an open period.
              BEGIN
               pa_utils2.get_accrual_gl_dt_period( p_calling_module => p_calling_module
                                               ,p_reference_date   => x_prvdr_accrual_date
                                               ,p_application_id      => l_pa_gl_app_id
                                               ,p_set_of_books_id     => p_prvdr_sob_id
                                               ,p_prvdr_recvr_flg     => 'P'
                                               ,p_epp_flag            => l_prof_new_gldate_derivation
                                               ,x_gl_accr_period_name => l_prvdr_gl_period_name
                                               ,x_gl_accr_dt          => l_prvdr_accrual_date
                                               ,x_return_status       => x_return_status
                                               ,x_error_code          => x_error_code
                                               ,x_error_stage         => x_error_stage
                                               );
              END;
                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     ELSE --- Assign the passed accrual date to gl Date.
                       l_prvdr_accrual_date :=  x_prvdr_accrual_date;
                       l_prvdr_gl_date      :=  l_prvdr_accrual_date;
                     END IF;

              pa_debug.g_err_stage :='Prvdr GL Date is -'||to_char(l_prvdr_gl_date);
		    IF(l_debug_mode = 'Y') THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		    END IF;
              pa_debug.g_err_stage :='Prvdr GL Period is -'||l_prvdr_gl_period_name;
    	        IF(l_debug_mode = 'Y') THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		   END IF;
          --- If provider and receiver are of same org, then don't check the RECVR accrual date
           IF p_prvdr_org_id = p_recvr_org_id THEN ---------------------------------{

             l_recvr_accrual_date   := nvl(x_recvr_accrual_date,l_prvdr_accrual_date);
             l_recvr_gl_period_name := l_prvdr_gl_period_name ;
             l_recvr_gl_date        := l_recvr_accrual_date;

              pa_debug.g_err_stage :='Prvdr GL Date is = Recvr GL Date';
		  IF(l_debug_mode = 'Y') THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;
           ELSE  ----Do the check for O/F status.

            -- It checks if the accrual date is in an O/F period. This check is for RECVR.
              BEGIN
               pa_utils2.get_accrual_gl_dt_period( p_calling_module => p_calling_module
                                               ,p_reference_date      => x_recvr_accrual_date
                                               ,p_application_id      => l_pa_gl_app_id
                                               ,p_set_of_books_id     => p_recvr_sob_id
                                               ,p_prvdr_recvr_flg     => 'R'
                                               ,p_epp_flag            => l_prof_new_gldate_derivation
                                               ,x_gl_accr_period_name => l_recvr_gl_period_name
                                               ,x_gl_accr_dt          => l_recvr_accrual_date
                                               ,x_return_status       => x_return_status
                                               ,x_error_code          => x_error_code
                                               ,x_error_stage         => x_error_stage
                                               );
              END;
                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     ELSE --- Assign the passed accrual date.
                       l_recvr_accrual_date := x_recvr_accrual_date;
                       l_recvr_gl_date      := x_recvr_accrual_date;
                     END IF;

              pa_debug.g_err_stage :='Recvr GL Date is -'||to_char(l_recvr_gl_date);
		    IF(l_debug_mode = 'Y') THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		    END IF;
              pa_debug.g_err_stage :='Recvr GL Period is -'||l_recvr_gl_period_name;
		    IF(l_debug_mode = 'Y') THEN
              pa_debug.write_file(pa_debug.g_err_stage);
		    END IF;

            END IF; ----------------------p_prvdr_org_id = p_recvr_org_id------------------}

     END IF;  ---------p_calling_module = 'CDL' ---------------------}

     --- The transaction is accounted, so assign the gl date to accrual date.

     IF nvl(p_acct_flag,'N') = 'Y' THEN-------Accounted Transaction---------------------------{

         IF p_adj_ei_id IS NULL THEN  -------------ORG EI----------------------------------{

               l_prvdr_accrual_date := x_prvdr_gl_date;
               l_prvdr_gl_date      := x_prvdr_gl_date;

        pa_debug.g_err_stage := 'Prvdr accrual Date for ORG EI Acct TRX -'||to_char(l_prvdr_accrual_date);
        IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'Prvdr GL Date for ORG EI Acct TRX -'||to_char(l_prvdr_gl_date);
   	   IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
                 -- We need the Period name.
                  BEGIN
                   pa_utils2.get_accrual_gl_dt_period( p_calling_module => p_calling_module
                                               ,p_reference_date   => l_prvdr_accrual_date
                                               ,p_application_id      => l_pa_gl_app_id
                                               ,p_set_of_books_id     => p_prvdr_sob_id
                                               ,p_prvdr_recvr_flg     => 'P'
                                               ,p_epp_flag            => l_prof_new_gldate_derivation
                                               ,x_gl_accr_period_name => l_prvdr_gl_period_name
                                               ,x_gl_accr_dt          => l_prvdr_gl_date
                                               ,x_return_status       => x_return_status
                                               ,x_error_code          => x_error_code
                                               ,x_error_stage         => x_error_stage
                                               );
                  END;
                   --- GL Date may be in a closed period , we just need the period name.
                     IF  l_prvdr_gl_period_name IS NOT NULL AND x_error_code is NOT NULL  THEN

        pa_debug.g_err_stage := 'Prvdr GL Period for ORG EI Acct TRX -'||l_prvdr_gl_period_name;
	IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	END IF;
                         x_return_status := NULL;
                         x_error_code    := NULL;
                     ELSIF x_error_code IS NOT NULL THEN

        pa_debug.g_err_stage := 'Prvdr GL Period Not Found for ORG EI Acct TRX -';
	  IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	  END IF;
                         x_return_status := FND_API.G_RET_STS_ERROR;
                         x_error_code    := 'PA_GL_PER_PRVDR_ACCR_CLOSED';
                         return; -- Could not find the Period Name.
                     END IF;

           -- If Provider and Receiver are of same ORG, then assign the same prvdr gl date to recvrs' accr date.
               IF p_prvdr_org_id = p_recvr_org_id THEN -----------------------------------{
                 l_recvr_accrual_date   := x_prvdr_gl_date;
                 l_recvr_gl_period_name := l_prvdr_gl_period_name;
                 l_recvr_gl_date        := l_recvr_accrual_date;
               ELSE --- derive the recvr_accrual_date based on the ei date.
                  BEGIN
                   pa_utils2.get_accrual_gl_dt_period( p_calling_module => p_calling_module
                                               ,p_reference_date   => p_expenditure_item_date
                                               ,p_application_id      => l_pa_gl_app_id
                                               ,p_set_of_books_id     => p_recvr_sob_id
                                               ,p_prvdr_recvr_flg     => 'R'
                                               ,p_epp_flag            => l_prof_new_gldate_derivation
                                               ,x_gl_accr_period_name => l_recvr_gl_period_name
                                               ,x_gl_accr_dt          => l_recvr_accrual_date
                                               ,x_return_status       => x_return_status
                                               ,x_error_code          => x_error_code
                                               ,x_error_stage         => x_error_stage
                                               );
                  END;
                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     ELSE --- Assign the recvr GL Date
                       l_recvr_gl_date      := l_recvr_accrual_date;
                     END IF;
               END IF; -----------------------p_prvdr_org_id = p_recvr_org_id-------------}
          ELSE   ----------------------------REV EI-----------------------------------------------
                --- For REV EI, the accrual dates of the
                --- ORG EI are passed. Since its an IN OUT parameter, we read and write to the same parameter.
                --- For REV EI, the accrual date is the first/last day of the next O,F GL Period depending on EPP.

             l_prvdr_accrual_date := pa_utils2.get_rev_accrual_date(p_calling_module => p_calling_module
                                                               ,p_reference_date =>x_prvdr_accrual_date
                                                               ,p_application_id  => l_pa_gl_app_id
                                                               ,p_set_of_books_id => p_prvdr_sob_id
                                                               ,p_prvdr_recvr_flg => 'P'
                                                               ,p_epp_flag        => l_prof_new_gldate_derivation
                                                               ,x_gl_period_name  => l_prvdr_gl_period_name
                                                               ,x_return_status   => x_return_status
                                                               ,x_error_code      => x_error_code
                                                               ,x_error_stage     => x_error_stage);
                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     END IF;

                     l_prvdr_gl_date := l_prvdr_accrual_date; --- Accounted Rev Trx.

        pa_debug.g_err_stage := 'Prvdr GL/accrual Date for Rev EI Acct TRX -'||to_char(l_prvdr_accrual_date);
        IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage := 'Prvdr GL Period for Rev EI Acct TRX -'||l_prvdr_gl_period_name;
	  IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
 	  END IF;
           IF p_prvdr_org_id = p_recvr_org_id THEN -------------------------{

             l_recvr_accrual_date   := l_prvdr_accrual_date;
             l_recvr_gl_date        := l_recvr_accrual_date;
             l_recvr_gl_period_name := l_prvdr_gl_period_name;

             pa_debug.g_err_stage := 'Recvr is same as Prvdr GL/accrual Date for Rev EI Acct TRX ';
  	   	  IF(l_debug_mode = 'Y') THEN
             pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;

           ELSE
             l_recvr_accrual_date := pa_utils2.get_rev_accrual_date( p_calling_module => p_calling_module
                                                               ,p_reference_date =>x_recvr_accrual_date
                                                               ,p_application_id => l_pa_gl_app_id
                                                               ,p_set_of_books_id => p_recvr_sob_id
                                                               ,p_prvdr_recvr_flg => 'R'
                                                               ,p_epp_flag        => l_prof_new_gldate_derivation
                                                               ,x_gl_period_name  => l_recvr_gl_period_name
                                                               ,x_return_status   => x_return_status
                                                               ,x_error_code      => x_error_code
                                                               ,x_error_stage     => x_error_stage);
                      -- Error encountered!!!
                     IF x_error_code IS NOT NULL THEN
                       return;
                     END IF;
             l_recvr_gl_date        := l_recvr_accrual_date;

             pa_debug.g_err_stage := ':Recvr accrual Date for Rev EI Acct TRX -'||to_char(l_recvr_accrual_date);
  	       IF(l_debug_mode = 'Y') THEN
             pa_debug.write_file(pa_debug.g_err_stage);
		  END IF;

           END IF; ---------------p_prvdr_org_id = p_recvr_org_id-------------}
        END IF; ------------------p_adj_ei_id IS NULL---------------------------------------}
  END IF; ------------------------Accounted Transaction----------------------------------------------}


               --Assign the out parameters
                 x_prvdr_accrual_date := l_prvdr_accrual_date;
                 x_recvr_accrual_date := l_recvr_accrual_date;
                 x_prvdr_gl_date := nvl(x_prvdr_gl_date,l_prvdr_gl_date); --Don't overwrite the gl date from TRXIMPORT
                 x_recvr_gl_date := l_recvr_gl_date ;
                 x_prvdr_gl_period_name := l_prvdr_gl_period_name;
                 x_recvr_gl_period_name := l_recvr_gl_period_name;

      -- Deriving PA periods

	        pa_debug.g_err_stage := 'Deriving the PA Dates';
	   IF(l_debug_mode = 'Y') THEN
		   pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;

    IF  p_adj_ei_id IS NULL THEN ------------ORG EI-------------------------{

        BEGIN
           --- Derive the org prvdr pa date and pa period.
           pa_utils2.get_accrual_pa_dt_period( p_gl_period=>l_prvdr_gl_period_name
                                             ,p_ei_date     => p_expenditure_item_date
                                             ,p_org_id =>p_prvdr_org_id
                                             ,p_prvdr_recvr_flg => 'P'
                                             ,p_epp_flag  => l_prof_new_gldate_derivation
                                             ,p_org_rev_flg => 'O'
                                             ,x_pa_date   => l_prvdr_pa_date
                                             ,x_pa_period_name => l_prvdr_pa_period_name
                                             ,x_return_status  =>x_return_status
                                             ,x_error_code   =>x_error_code);
        END;
                      --Error
                      IF x_error_code IS NOT NULL THEN
                        return;
                      END IF;

        pa_debug.g_err_stage := 'Prvdr PA Date -'||to_char(l_prvdr_pa_date);
	IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	END IF;
        pa_debug.g_err_stage :='Prvdr PA Period Name -'||l_prvdr_pa_period_name;
	IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	END IF;
      IF p_prvdr_org_id = p_recvr_org_id THEN
           l_recvr_pa_date := l_prvdr_pa_date;
           l_recvr_pa_period_name := l_prvdr_pa_period_name;

        pa_debug.g_err_stage :='Prvdr PA Derivation = Recvr PA Derivation ORG EI ';
	  IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
       END IF;
      ELSE
           --- Derive the org recvr pa date and pa period.
           BEGIN
           pa_utils2.get_accrual_pa_dt_period( p_gl_period=>l_recvr_gl_period_name
                                             ,p_ei_date     => p_expenditure_item_date
                                             ,p_org_id =>p_recvr_org_id
                                             ,p_prvdr_recvr_flg => 'R'
                                             ,p_epp_flag  => l_prof_new_gldate_derivation
                                             ,p_org_rev_flg => 'O'
                                             ,x_pa_date   => l_recvr_pa_date
                                             ,x_pa_period_name => l_recvr_pa_period_name
                                             ,x_return_status  =>x_return_status
                                             ,x_error_code   =>x_error_code);
             END;
                      --Error
                      IF x_error_code IS NOT NULL THEN
                        return;
                      END IF;

        pa_debug.g_err_stage := 'Recvr PA Date -'||to_char(l_recvr_pa_date);
  	  IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
       END IF;
        pa_debug.g_err_stage := 'Recvr PA Period Name -'||l_recvr_pa_period_name;
	  IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	  END IF;
	END IF;

    ELSE -------------------------REV ITEM-----------------------

		pa_debug.g_err_stage := 'Deriving the PA Dates for REV EI';
  	   IF(l_debug_mode = 'Y') THEN
		pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
       ----For Prvdr
        BEGIN
           --- Derive the org prvdr pa date and pa period.
           pa_utils2.get_accrual_pa_dt_period( p_gl_period=>l_prvdr_gl_period_name
                                             ,p_ei_date     => p_expenditure_item_date
                                             ,p_org_id =>p_prvdr_org_id
                                             ,p_prvdr_recvr_flg => 'P'
                                             ,p_epp_flag  => l_prof_new_gldate_derivation
                                             ,p_org_rev_flg => 'R'
                                             ,x_pa_date   => l_prvdr_pa_date
                                             ,x_pa_period_name => l_prvdr_pa_period_name
                                             ,x_return_status  =>x_return_status
                                             ,x_error_code   =>x_error_code);
        END;
                      --Error
                      IF x_error_code IS NOT NULL THEN
                        return;
                      END IF;

        pa_debug.g_err_stage := 'Prvdr PA Date -'||to_char(l_prvdr_pa_date);
	   IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage :='Prvdr PA Period Name -'||l_prvdr_pa_period_name;
	   IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	  END IF;

       ----For Recvr
          IF p_prvdr_org_id = p_recvr_org_id THEN
            l_recvr_pa_date := l_prvdr_pa_date;
            l_recvr_pa_period_name :=l_prvdr_pa_period_name ;

        pa_debug.g_err_stage :='Prvdr PA Derivation = Recvr PA Derivation REV EI ';
    	  IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	  END IF;
          ELSE
           --- Derive the org recvr pa date and pa period.
           BEGIN
           pa_utils2.get_accrual_pa_dt_period( p_gl_period=>l_recvr_gl_period_name
                                             ,p_ei_date     => p_expenditure_item_date
                                             ,p_org_id =>p_recvr_org_id
                                             ,p_prvdr_recvr_flg => 'R'
                                             ,p_epp_flag  => l_prof_new_gldate_derivation
                                             ,p_org_rev_flg => 'R'
                                             ,x_pa_date   => l_recvr_pa_date
                                             ,x_pa_period_name => l_recvr_pa_period_name
                                             ,x_return_status  =>x_return_status
                                             ,x_error_code   =>x_error_code);
           END;
                      --Error
                      IF x_error_code IS NOT NULL THEN
                        return;
                      END IF;

         END IF;

        pa_debug.g_err_stage := 'Recvr PA Date -'||to_char(l_recvr_pa_date);
	   IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	   END IF;
        pa_debug.g_err_stage :='Recvr PA Period Name -'||l_recvr_pa_period_name;
	  IF(l_debug_mode = 'Y') THEN
        pa_debug.write_file(pa_debug.g_err_stage);
	  END IF;

    END IF; ---------------ORG EI--------------------------------------------}
             ---Assign the out parameters.
              x_prvdr_pa_date := l_prvdr_pa_date;
              x_prvdr_pa_period_name := l_prvdr_pa_period_name;
              x_recvr_pa_date := l_recvr_pa_date;
              x_recvr_pa_period_name := l_recvr_pa_period_name;
  END IF; -----------p_calling_module = 'CDL' AND  NVL(p_acct_flag,'N') = 'Y'------------------------}

          pa_debug.g_err_stage :='x_prvdr_accr_date is [' || to_char(x_prvdr_accrual_date) ||
                                                    '] x_recvr_accr_date is ['|| to_char(x_recvr_accrual_date) || ']';
		IF(l_debug_mode = 'Y') THEN
          pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

          pa_debug.g_err_stage :='x_prvdr_pa_date is [' || to_char(x_prvdr_pa_date) ||
                                                    '] x_prvdr_pa_period_name is ['|| x_prvdr_pa_period_name || ']';
		IF(l_debug_mode = 'Y') THEN
          pa_debug.write_file(pa_debug.g_err_stage);
		END IF;
          pa_debug.g_err_stage :='x_prvdr_gl_date is [' || to_char(x_prvdr_gl_date) ||
                                                    '] x_prvdr_gl_period_name is ['|| x_prvdr_gl_period_name || ']';
		IF(l_debug_mode = 'Y') THEN
          pa_debug.write_file(pa_debug.g_err_stage);
		END IF;
          pa_debug.g_err_stage :='x_recvr_pa_date is [' || to_char(x_recvr_pa_date) ||
                                                    '] x_recvr_pa_period_name is ['|| x_recvr_pa_period_name || ']';
		IF(l_debug_mode = 'Y') THEN
          pa_debug.write_file(pa_debug.g_err_stage);
		END IF;
          pa_debug.g_err_stage :='x_recvr_gl_date is [' || to_char(x_recvr_gl_date) ||
                                                    '] x_recvr_gl_period_name is ['|| x_recvr_gl_period_name || ']';
	     IF(l_debug_mode = 'Y') THEN
          pa_debug.write_file(pa_debug.g_err_stage);
		END IF;
          pa_debug.g_err_stage :=' x_error_code is [' || x_error_code || ']';
		IF(l_debug_mode = 'Y') THEN
          pa_debug.write_file(pa_debug.g_err_stage);
		END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  pa_debug.reset_err_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RAISE;
  WHEN OTHERS THEN
     RAISE ;
END get_accrual_period_information ;
-----------------------------------------------------------------------
FUNCTION get_pa_period_name( p_txn_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                            ,p_org_id   IN pa_implementations_all.org_id%TYPE
                           )
RETURN pa_periods.period_name%TYPE
IS
         l_pa_period_name pa_periods.period_name%TYPE;
         l_pa_date        date;
BEGIN

         IF ( p_txn_date IS NOT NULL )
         THEN
             l_pa_date := pa_utils2.get_pa_date( p_ei_date => p_txn_date
                                                ,p_gl_date => SYSDATE
                                                ,p_org_id  => p_org_id
                                               );
             l_pa_period_name := g_prvdr_pa_period_name;
         END IF;
         RETURN l_pa_period_name ;
EXCEPTION
    WHEN OTHERS
    THEN
          RAISE;
END get_pa_period_name ;

-----------------------------------------------------------------------
--Start Bug 3069632
FUNCTION get_ts_allow_burden_flag( p_transaction_source IN pa_expenditure_items_all.transaction_source%TYPE)
RETURN pa_transaction_sources.allow_burden_flag%TYPE
IS
         l_allow_burden_flag pa_transaction_sources.allow_burden_flag%TYPE := 'N';
BEGIN
         IF ( p_transaction_source IS NOT NULL )
         THEN
            If p_transaction_source = pa_utils2.g_transaction_source Then
               Return g_ts_allow_burden_flag;

            Else

             select ts.allow_burden_flag
               into l_allow_burden_flag
               from pa_transaction_sources ts
              where ts.transaction_source = p_transaction_source;

             pa_utils2.g_ts_allow_burden_flag := l_allow_burden_flag;
             pa_utils2.g_transaction_source := p_transaction_source;
             RETURN l_allow_burden_flag;
            End If;
         ELSE
            RETURN 'N';
         END IF;
EXCEPTION
    WHEN OTHERS
    THEN
          RAISE;
END get_ts_allow_burden_flag ;

-----------------------------------------------------------------------

--Start Bug 3059344
Function Get_Burden_Amt_Display_Method(P_Project_Id in Number) Return Varchar2
Is
        l_Found         BOOLEAN         := FALSE;
        x_burden_method VARCHAR2(1);
  Begin
        -- Check if there are any records in the pl/sql table.
        If G_BdMethodProjID_Tab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');
            Begin
                X_Burden_Method := G_BdMethodProjID_Tab(P_Project_Id);
                l_Found := TRUE;
                --Dbms_Output.Put_Line('l_found TRUE');
            Exception
                When No_Data_Found Then
                        l_Found := FALSE;
                When Others Then
                        Raise;
            End;

        End If;

        If Not l_Found Then
                --Dbms_Output.Put_Line('l_found FALSE');

                If G_BdMethodProjID_Tab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_BdMethodProjID_Tab.Delete;
                End If;
              Begin
                --Dbms_Output.Put_Line('select');
                SELECT DECODE(pt.burden_amt_display_method, 'D', 'D'
                                     , DECODE(pt.BURDEN_SUM_DEST_PROJECT_ID, NULL
                                         , DECODE(pt.BURDEN_SUM_DEST_TASK_ID, NULL, 'S', 'D'), 'D'))
                  INTO x_burden_method
                  FROM pa_project_types_all pt
                      ,pa_projects_all      p
                 WHERE p.project_id = P_Project_Id
                   AND p.project_type = pt.project_type
                   AND pt.org_id = p.org_id
                   AND pt.burden_cost_flag = 'Y';

                G_BdMethodProjID_Tab(P_Project_Id) := x_burden_method;
                --Dbms_Output.Put_Line('after select');
              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     x_burden_method := 'N';
                     G_BdMethodProjID_Tab(P_Project_Id) := 'N';
              End;

        End If;

        Return x_burden_method;

Exception
  When Others Then
       RETURN 'N';

End Get_Burden_Amt_Display_Method;


/* S.N. Bug4746949 */
Function Proj_Type_Burden_Disp_Method(P_Project_Id in Number) Return Varchar2
Is
        l_Found         BOOLEAN         := FALSE;
        x_burden_method VARCHAR2(1);
  Begin
        -- Check if there are any records in the pl/sql table.
        If G_Bd_MethodProjID_Tab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');
            Begin
                X_Burden_Method := G_Bd_MethodProjID_Tab(P_Project_Id);
                l_Found := TRUE;
                --Dbms_Output.Put_Line('l_found TRUE');
            Exception
                When No_Data_Found Then
                        l_Found := FALSE;
                When Others Then
                        Raise;
            End;

        End If;

        If Not l_Found Then
                --Dbms_Output.Put_Line('l_found FALSE');

                If G_Bd_MethodProjID_Tab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_Bd_MethodProjID_Tab.Delete;
                End If;
              Begin
                --Dbms_Output.Put_Line('select');
                SELECT pt.burden_amt_display_method
                  INTO x_burden_method
                  FROM pa_project_types_all pt
                      ,pa_projects_all      p
                 WHERE p.project_id = P_Project_Id
                   AND p.project_type = pt.project_type
                   -- begin bug 5614790
                   -- AND NVL(pt.org_id,-99) = nvl(p.org_id,-99)
                   AND pt.org_id = p.org_id
                   -- end bug 5614790
                   AND pt.burden_cost_flag = 'Y';

                G_Bd_MethodProjID_Tab(P_Project_Id) := x_burden_method;
                --Dbms_Output.Put_Line('after select');
              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     x_burden_method := 'N';
                     G_Bd_MethodProjID_Tab(P_Project_Id) := 'N';
              End;

        End If;

        Return x_burden_method;

Exception
  When Others Then
       RETURN 'N';

End Proj_Type_Burden_Disp_Method;

/* E.N. Bug4746949 */

Function get_capital_cost_type_code( p_project_id IN pa_projects_all.project_id%TYPE)
RETURN pa_project_types_all.CAPITAL_COST_TYPE_CODE%TYPE
Is
        l_Found         BOOLEAN         := FALSE;
        x_capital_cost_type VARCHAR2(1);
  Begin
        -- Check if there are any records in the pl/sql table.
        If G_CapCostTypProjID_Tab.COUNT > 0 Then
            --Dbms_Output.Put_Line('count > 0');
            Begin
                x_capital_cost_type := G_CapCostTypProjID_Tab(P_Project_Id);
                l_Found := TRUE;
                --Dbms_Output.Put_Line('l_found TRUE');
            Exception
                When No_Data_Found Then
                        l_Found := FALSE;
                When Others Then
                        Raise;
            End;

        End If;

        If Not l_Found Then
                --Dbms_Output.Put_Line('l_found FALSE');

                If G_CapCostTypProjID_Tab.COUNT > 999 Then
                        --Dbms_Output.Put_Line('count > 199');
                        G_CapCostTypProjID_Tab.Delete;
                End If;
              Begin
                --Dbms_Output.Put_Line('select');
                SELECT pt.capital_cost_type_code
                  INTO x_capital_cost_type
                  FROM pa_project_types_all pt
                      ,pa_projects_all      p
                 WHERE p.project_id = P_Project_Id
                   AND p.project_type = pt.project_type
                   -- begin bug 5614790
                   -- AND NVL(pt.org_id,-99) = nvl(p.org_id,-99)
                   AND pt.org_id = p.org_id
                   -- end bug 5614790
                   AND pt.project_type_class_code = 'CAPITAL';

                G_CapCostTypProjID_Tab(P_Project_Id) := x_capital_cost_type;
                --Dbms_Output.Put_Line('after select');

              Exception
                When No_Data_Found Then
                     --Dbms_Output.Put_Line('wndf ');
                     x_capital_cost_type := 'N';
                     G_CapCostTypProjID_Tab(P_Project_Id) := 'N';
              End;

        End If;

        Return x_capital_cost_type;

Exception
  When Others Then
       RETURN 'N';

End get_capital_cost_type_code;
--End Bug 3059344

FUNCTION IsEnhancedBurdeningEnabled
RETURN VARCHAR2
IS
BEGIN

        IF ( NVL(fnd_profile.value('PA_ENHANCED_BURDENING'),'N') = 'Y' )
        THEN
             IF (PA_GMS_API.vert_install)
             THEN
                   RETURN 'N';
             ELSE
                   RETURN 'Y';
             END IF;
        ELSE
             RETURN 'N';
        END IF;

EXCEPTION
  WHEN OTHERS
  THEN
          RETURN 'N';
End IsEnhancedBurdeningEnabled;

/* Bug 5374282 */
PROCEDURE get_gl_dt_period  (p_reference_date IN  DATE,
                             x_gl_period_name OUT NOCOPY pa_draft_revenues_all.gl_period_name%TYPE,
                             x_gl_dt          OUT NOCOPY pa_draft_revenues_all.gl_date%TYPE,
                             x_return_status  OUT NOCOPY NUMBER,
                             x_error_code     OUT NOCOPY VARCHAR2,
                             x_error_stage    OUT NOCOPY VARCHAR2
                            )
IS
    l_gl_period_name          pa_draft_revenues_all.gl_period_name%TYPE := NULL;
    l_gl_dt                   pa_draft_revenues_all.gl_date%TYPE        := NULL;
    l_gl_period_st_dt         pa_draft_revenues_all.gl_date%TYPE        := NULL;
    l_gl_period_end_dt        pa_draft_revenues_all.gl_date%TYPE        := NULL;
    l_period_status           gl_period_statuses.closing_status%TYPE    := NULL;

    l_set_of_books_id       pa_implementations_all.set_of_books_id%TYPE;

    l_gl_app_id      NUMBER      := 101;
    l_epp_flag       VARCHAR2(1) := 'N';
    l_application_id NUMBER      := NULL ;

BEGIN

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Entering procedure');

    /* Changed from value_specific to value for bug 5472333 */
    l_epp_flag       := fnd_profile.value('PA_EN_NEW_GLDATE_DERIVATION') ;

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: EPP Flag status: ' || l_epp_flag);

    l_application_id := l_gl_app_id ;

    SELECT imp.set_of_books_id
      INTO l_set_of_books_id
      FROM pa_implementations imp;

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Using (appl_id, sob_id): (' || to_char(l_application_id) || ', ' || to_char(l_set_of_books_id) || ')' );

---Initialize the out variables.
    x_gl_period_name := NULL;
    x_gl_dt          := NULL;
  x_return_status  := 0;
    x_error_code     := NULL;

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Trying reference_date with cached start and end date values' );

    IF ((trunc(p_reference_date) BETWEEN g_gl_dt_period_str_dt AND g_gl_dt_period_end_dt )
       AND g_gl_dt_period_str_dt IS NOT NULL) THEN

       pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Using cached values' );

       ---From Cache
       IF l_epp_flag = 'Y' THEN
          l_gl_dt := p_reference_date;
       ELSE
          l_gl_dt := g_gl_dt_period_end_dt;
       END IF;

       --Assign the out variables.
       x_gl_dt          := l_gl_dt ;
       x_gl_period_name := g_gl_dt_period_name;

       pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Leaving procedure');

       return;

    END IF;

--- Either the cache is empty or the reference date is not in the range.

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Cache values empty/reference date not between cached start and end date values' );

    BEGIN

      SELECT PERIOD.period_name,PERIOD.start_date,PERIOD.end_date,PERIOD.closing_status
        INTO l_gl_period_name, l_gl_period_st_dt,l_gl_period_end_dt,l_period_status
        FROM GL_PERIOD_STATUSES PERIOD
       WHERE PERIOD.application_id   = l_application_id
         AND PERIOD.set_of_books_id  = l_set_of_books_id
         AND PERIOD.adjustment_period_flag = 'N'
         AND trunc(p_reference_date) BETWEEN PERIOD.start_date and PERIOD.end_date;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
        x_return_status := -1;
        x_error_code    := 'PA_GL_PER_PRVDR_ACCR_NOT_DEF';

        return;
      WHEN OTHERS THEN
        x_return_status := -1;
        x_error_stage   := 'PA_UTILS2.GET_GL_PERIOD:: ' || pa_debug.g_err_stage ||':: '|| SQLERRM;

        raise;
    END;

    -- EPP Derivation.
    IF l_epp_flag = 'Y' THEN
       l_gl_dt := p_reference_date;
    ELSE
       l_gl_dt := l_gl_period_end_dt;
    END IF;

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Checking for period status' );

    --Checking for period status.
    IF l_period_status NOT IN ('O','F') THEN

       pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Period is closed' );

       IF l_epp_flag = 'N' THEN

         pa_debug.g_err_stage := 'EPP = N, Querying next open period';  /* Added Code for Bug 6139975 */

          SELECT  PERIOD.start_date,
                  PERIOD.end_date,
                  PERIOD.end_date,
                  PERIOD.period_name
            INTO  l_gl_period_st_dt,
                  l_gl_period_end_dt,
                  l_gl_dt,
                  l_gl_period_name
            FROM  GL_PERIOD_STATUSES PERIOD
           WHERE  PERIOD.application_id   = l_application_id
             AND  PERIOD.set_of_books_id  = l_set_of_books_id
             AND  PERIOD.effective_period_num =
                  (SELECT  min(PERIOD1.effective_period_num)
                   FROM  GL_PERIOD_STATUSES PERIOD1
                    WHERE  PERIOD1.application_id  = l_application_id
                      AND  PERIOD1.set_of_books_id = l_set_of_books_id
                      AND  PERIOD1.closing_status||''  IN ('O','F')
                      AND  PERIOD1.adjustment_period_flag = 'N'
                      AND  PERIOD1.effective_period_num  >=
                           (SELECT  PERIOD2.effective_period_num
                              FROM  GL_PERIOD_STATUSES PERIOD2,
                                    GL_DATE_PERIOD_MAP DPM,
                                    GL_SETS_OF_BOOKS SOB
                             WHERE  SOB.set_of_books_id = l_set_of_books_id
                               AND  DPM.period_set_name = SOB.period_set_name
                               AND  DPM.period_type = SOB.accounted_period_type
                               AND  trunc(DPM.accounting_date) = trunc(p_reference_date)
                               AND  DPM.period_name = PERIOD2.period_name
                               AND  PERIOD2.application_id = l_application_id
                               AND  PERIOD2.set_of_books_id = l_set_of_books_id ))
             AND  PERIOD.End_Date >= TRUNC(p_reference_date)
             AND  PERIOD.set_of_books_id = l_set_of_books_id ;

         pa_debug.g_err_stage := 'EPP = N, Fetched next open period';   /* Added Code for Bug 6139975 */

       ELSE

         pa_debug.g_err_stage := 'EPP = Y, Querying next open period';  /* Added Code for Bug 6139975 */

          SELECT  PERIOD.start_date,
                  PERIOD.start_date,
                  PERIOD.end_date,
                  PERIOD.period_name
            INTO  l_gl_dt,
                  l_gl_period_st_dt,
                  l_gl_period_end_dt,
                  l_gl_period_name
            FROM  GL_PERIOD_STATUSES PERIOD
           WHERE  PERIOD.application_id   = l_application_id
             AND  PERIOD.set_of_books_id  = l_set_of_books_id
             AND  PERIOD.effective_period_num =
                  (SELECT  min(PERIOD1.effective_period_num)
                     FROM  GL_PERIOD_STATUSES PERIOD1
                    WHERE  PERIOD1.application_id  = l_application_id
                      AND  PERIOD1.set_of_books_id = l_set_of_books_id
                      AND  PERIOD1.closing_status||''  IN ('O','F')
                      AND  PERIOD1.adjustment_period_flag = 'N'
                      AND  PERIOD1.effective_period_num  >=
                           (SELECT  PERIOD2.effective_period_num
                              FROM  GL_PERIOD_STATUSES PERIOD2,
                                 GL_DATE_PERIOD_MAP DPM,
                                    GL_SETS_OF_BOOKS SOB
                             WHERE  SOB.set_of_books_id = l_set_of_books_id
                               AND  DPM.period_set_name = SOB.period_set_name
                               AND  DPM.period_type = SOB.accounted_period_type
                               AND  trunc(DPM.accounting_date) = trunc(p_reference_date)
                               AND  DPM.period_name = PERIOD2.period_name
                               AND  PERIOD2.application_id = l_application_id
                               AND  PERIOD2.set_of_books_id = l_set_of_books_id ))
             AND  PERIOD.Start_Date > TRUNC(p_reference_date);

         pa_debug.g_err_stage := 'EPP = Y, Fetched next open period';   /* Added Code for Bug 6139975 */

       END IF;

    END IF;

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Caching dates' );

    g_gl_dt_period_name    := l_gl_period_name;
    g_gl_dt_period_str_dt  := l_gl_period_st_dt ;
    g_gl_dt_period_end_dt  := l_gl_period_end_dt;

    x_gl_dt           := l_gl_dt ;
    x_gl_period_name  := l_gl_period_name ;

    pa_debug.write_file('PA_UTILS2.GET_GL_PERIOD: Leaving procedure');

EXCEPTION

/* Start of code added for Bug 6139975 */

  WHEN NO_DATA_FOUND THEN
     x_return_status := -1;
     x_error_code    := 'NO_GL_DATE';
     x_error_stage   := 'PA_UTILS2.GET_GL_PERIOD:: ' || pa_debug.g_err_stage ||':: '|| SQLERRM;

     return;

/* End of code added for Bug 6139975 */

  WHEN OTHERS THEN
     x_return_status := -1;
     x_error_stage   := 'PA_UTILS2.GET_GL_PERIOD:: ' || pa_debug.g_err_stage ||':: '|| SQLERRM;

     raise;
END get_gl_dt_period ;

/*  5374282 ends */


END pa_utils2;

/
