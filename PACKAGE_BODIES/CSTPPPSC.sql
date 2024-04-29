--------------------------------------------------------
--  DDL for Package Body CSTPPPSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPPSC" AS
/* $Header: CSTPPSCB.pls 120.8.12010000.7 2009/08/28 19:20:28 hyu ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSTPPPSC';
G_LOG_LEVEL CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/* **************************************************************************** */
/* This procedure is called from PAC Periods form to open a fiscal accounting   */
/* period. The explanation of the various IN and OUT params are as follows      */
/* IN Params:   1. l_entity_id: Legal Entity ID of the pac Period               */
/*              2. l_cost_type_id: Cost Type ID of the pac Period               */
/*              3. l_user_id : user id                                          */
/*              4. l_login_id: login id                                         */
/*              5. open_period_name: Name of the period beging opened           */
/*              6. open_period_num : Opening period number                      */
/*              7. open_period_year: Opening period year                        */
/*              8. open_period_set_name: Set of Books name for the LE-CT        */
/*              9. l_period_end_date : Period end date to be opened             */
/* IN OUT Params:                                                               */
/*              1. last_scheduled_close_date: It is a user defined param which  */
/*                 holds the value of the max(end_date) of all the periods in   */
/*                 in cst_pac_periods table for a particular LE-CT              */
/* OUT Params:  1. prior_open_period: TRUE if this is the duplicate period to   */
/*                 be opened for an LE-CT combination                           */
/*              2. improper_order: TRUE if the period being opened is not the   */
/*                 subsequent period accounding to the Calender                 */
/*              3. new_pac_period_id: New ID of the currently opened PAC Period */
/*              4. duplicate_open_period: TRUE if another user is simultaneously */
/*                 opening this period                                          */
/*              5. undefined_cost_groups: TRUE if no cost groups are defined for */
/*                 the LE                                                       */
/*              6. commit_complete: TRUE if the periods has been opened         */
/*                 successfully.                                                */
/* **************************************************************************** */

PROCEDURE check_rev_info_run
(p_closing_date        IN DATE
,p_ledger_id           IN NUMBER
,x_current_upto_date   OUT NOCOPY DATE
,x_exist               OUT NOCOPY VARCHAR2
,x_required            OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT last_process_upto_date
    FROM cst_revenue_cogs_control
   WHERE control_id  = p_ledger_id;
  l_last_upto_date   DATE;
BEGIN
  OPEN c;
  FETCH c INTO l_last_upto_date;
  IF c%NOTFOUND THEN
   x_exist := 'N';
  ELSE
   x_exist := 'Y';
  END IF;
  CLOSE c;
  x_current_upto_date := l_last_upto_date;
  IF x_exist = 'N' THEN
    x_required := 'Y';
  ELSIF l_last_upto_date < p_closing_date  THEN
    x_required := 'Y';
  ELSE
    x_required := 'N';
  END IF;
END;


PROCEDURE validate_open_period(
                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,
                                open_period_name                IN      VARCHAR2,
                                open_period_num                 IN      NUMBER,
                                open_period_year                IN      NUMBER,
                                open_period_set_name            IN      VARCHAR2,
                                open_period_type                IN      VARCHAR2,
                                last_scheduled_close_date       IN OUT NOCOPY  DATE,
                                l_period_end_date               IN      DATE,

                                prior_open_period               OUT NOCOPY     BOOLEAN,
                                improper_order                  OUT NOCOPY      BOOLEAN,
                                new_pac_period_id               OUT NOCOPY     NUMBER,
                                duplicate_open_period           OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
                                user_defined_error              OUT NOCOPY      BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN

 )  IS


/* **************************************************************************** */
/* This section  defines the local variables for the open procedure             */
/* **************************************************************************** */

        low_period_id                   NUMBER;
        period_count                    NUMBER;
        first_period_to_be_opened       BOOLEAN;
        dummy_id                        NUMBER;
        current_cost_group_id           NUMBER;
        no_cost_groups                  NUMBER;
        phase_count                     NUMBER;
        no_available_cost_group         BOOLEAN;
        proper_period_name              VARCHAR2(15);
        proper_period_num               NUMBER;
        proper_period_year              NUMBER;
        dummy_date                      DATE;
        distributions_flag              VARCHAR2(1);


/* **************************************************************************** */
/* Cursor to check whether this is the first period beging opened for a         */
/* particular legal entity and cost type combination                            */
/* **************************************************************************** */

        CURSOR first_period_cur IS
                select
                        count(1)
                from    cst_pac_periods
                where   legal_entity = l_entity_id
                and     cost_type_id = l_cost_type_id
                AND     rownum < 2;


/* **************************************************************************** */
/* Cursor to check whether there are any current open periods for the legal     */
/* entity and cost type combination                                             */
/* **************************************************************************** */

        CURSOR prior_period_open_cur IS
                select  pac_period_id
                from    cst_pac_periods
                where
                        legal_entity = l_entity_id
                and     cost_type_id = l_cost_type_id
                and     pac_period_id NOT in
                                (select pac_period_id
                                 from   cst_pac_periods
                                 where  legal_entity = l_entity_id
                                 and    cost_type_id = l_cost_type_id
                                 and    open_flag = 'N'
                                 and    period_close_date IS NOT NULL);


/* **************************************************************************** */
/* Cursor to check this is the next period that should be opened as per         */
/* the calender defined in the set of books                                     */
/* **************************************************************************** */


        CURSOR proper_period_to_open_cur IS
                select end_date, period_name, period_year, period_num
                from gl_periods gp
                WHERE   gp.ADJUSTMENT_PERIOD_FLAG = 'N'
                and     gp.period_set_name = open_period_set_name
                and     gp.end_date > last_scheduled_close_date
                and     gp.period_type = open_period_type
                and     gp.end_date = (
                                    select      min(gp1.end_date)
                                    from        gl_periods gp1
                                    where       gp1.ADJUSTMENT_PERIOD_FLAG = 'N'
                                    and         gp1.period_set_name = open_period_set_name
                                    and         gp1.period_type = open_period_type
                                    and         gp1.end_date > last_scheduled_close_date );


l_stmt_num              NUMBER;
l_api_name            CONSTANT VARCHAR2(30) := 'validate_open_period';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN


 IF (l_pLog) THEN
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       l_module || '.begin',
                       l_api_name || ' <<< Parameters:
                       l_entity_id  = ' || l_entity_id || '
                       l_cost_type_id = ' || l_cost_type_id || '
                       open_period_name = ' || open_period_name || '
                       open_period_num = ' || open_period_num || '
                       open_period_year = ' || open_period_year || '
                       open_period_set_name = ' || open_period_set_name || '
                       open_period_type = ' || open_period_type || '
                       l_period_end_date = ' || l_period_end_date || '
                       last_scheduled_close_date = ' || last_scheduled_close_date);

 END IF;

/* **************************************************************************** */
/* Initialize all local and OUT params of the open procedure                    */
/* **************************************************************************** */
        l_stmt_num                      := 0;
        low_period_id                   := 0;
        period_count                    := 0;
        first_period_to_be_opened       := false;
        commit_complete                 := false;
        duplicate_open_period           := false;
        prior_open_period               := false;
        current_cost_group_id           := 0;
        no_cost_groups                  := 0;
        phase_count                     := 0;
        undefined_cost_groups           := false;
        new_pac_period_id               := 0;
        dummy_id                        := 0;
        improper_order                  := false;
        proper_period_name              := NULL;
        dummy_date                      := NULL;
        proper_period_num               := 0;
        proper_period_year              := 0;
        distributions_flag              := 'N';
        user_defined_error              := false;

/* **************************************************************************** */
/* Section below checks whether this is the first period being opened for this  */
/* LE-CT combination.   If YES => first_period_to_be_opened = TRUE              */
/*                      If NO  => first_period_to_be_opened = FALSE             */
/* **************************************************************************** */


        open first_period_cur;
        fetch first_period_cur into period_count;

        if (period_count = 0) then
                first_period_to_be_opened := true;
        else
                first_period_to_be_opened := false;
        end if;
        close first_period_cur;

/* **************************************************************************** */
/* If this is not the first periods being opened for the LE-CT combination...   */
/* Check whether there are any open periods for this LE-CT                      */
/*      If YES  => prior_open_period = TRUE                                     */
/*      If NO   => prior_open_period = FALSE                                    */
/* **************************************************************************** */

        l_stmt_num := 10;
        if ( NOT first_period_to_be_opened ) then
                open prior_period_open_cur;
                fetch prior_period_open_cur into dummy_id;
                if (prior_period_open_cur%FOUND) then
                        prior_open_period       := true;
                        commit_complete         := false;
                        goto procedure_end_label;
                else
                        prior_open_period        := false;
                end if;
                close prior_period_open_cur;


                /* **************************************************************************** */
                /* Check if this is the proper period tp open accourding to the calender        */
                /* defined in the set of books for the LE-CT combination                        */
                /* **************************************************************************** */

                open proper_period_to_open_cur;
                fetch proper_period_to_open_cur into dummy_date, proper_period_name, proper_period_year, proper_period_num;
                if(     proper_period_name = open_period_name ) AND
                  (     proper_period_year = open_period_year ) AND
                  (     proper_period_num  = open_period_num  )  then
                        improper_order  := false;
                 else
                        improper_order  := true;
                        commit_complete := false;
                        goto procedure_end_label;
                 end if;


        end if;



        <<error_label>>
                rollback;

                /* **************************************************************************** */
                /* In case of an error, rollback will take care of the unwanted rows in         */
                /* the cst_pac_process_phases table. However the row inserted into              */
                /* cst_pac_periods have already been commited, hence need to be explicitly      */
                /* deleted. The section below does that...                                      */
                /* **************************************************************************** */
                l_stmt_num := 20;
                delete from cst_pac_periods
                where pac_period_id = new_pac_period_id;

                commit_complete := false;


                goto procedure_end_label;


        <<procedure_end_label>>
        NULL;

         IF (l_pLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                  l_module || '.end',
                  l_api_name || ' >>>');
         END IF;

        EXCEPTION
                WHEN OTHERS THEN
                     IF (l_uLog) THEN
                           FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                           l_module || '.' || l_stmt_num,
                                           SQLERRM);
                     END IF;
                     rollback;
                     user_defined_error := true;
                     commit_complete := false;

END     validate_open_period;


PROCEDURE open_period(

                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,
                                open_period_name                IN      VARCHAR2,
                                open_period_num                 IN      NUMBER,
                                open_period_year                IN      NUMBER,
                                open_period_set_name            IN      VARCHAR2,
                                open_period_type                IN      VARCHAR2,
                                last_scheduled_close_date       IN OUT NOCOPY  DATE,
                                l_period_end_date               IN      DATE,

                                prior_open_period               OUT NOCOPY     BOOLEAN,
                                improper_order                  OUT NOCOPY     BOOLEAN,
                                new_pac_period_id               OUT NOCOPY     NUMBER,
                                duplicate_open_period           OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
                                user_defined_error              OUT NOCOPY     BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN

 )  IS

/* **************************************************************************** */
/* This section  defines the local variables for the open procedure             */
/* **************************************************************************** */

        low_period_id                   NUMBER;
        period_count                    NUMBER;
        first_period_to_be_opened       BOOLEAN;
        dummy_id                        NUMBER;
        current_cost_group_id           NUMBER;
        no_cost_groups                  NUMBER;
        phase_count                     NUMBER;
        no_available_cost_group         BOOLEAN;
        proper_period_name              VARCHAR2(15);
        proper_period_num               NUMBER;
        proper_period_year              NUMBER;
        dummy_date                      DATE;
        distributions_flag              VARCHAR2(1);
        transfer_cost_flag              VARCHAR2(1);

/* **************************************************************************** */
/* Cursor to obtain the new pac period id from cst_pac_periods_s sequence       */
/* **************************************************************************** */

        CURSOR get_new_period_id_cur IS
                select  cst_pac_periods_s.nextval
                from    dual;


/* **************************************************************************** */
/* Cursor whether another user is opening this period simultaneously            */
/* **************************************************************************** */

        CURSOR check_if_duplicating_cur IS
                select  new_pac_period_id
                from    cst_pac_periods
                where   legal_entity = l_entity_id
                and     cost_type_id = l_cost_type_id
                and     period_name = open_period_name
                and     period_year = open_period_year
                and     period_num = open_period_num
                and     pac_period_id <> new_pac_period_id;

/* **************************************************************************** */
/* Cursor for all cost groups defined for this legal entity                     */
/* **************************************************************************** */


        CURSOR all_cost_groups_cur IS
                select  cost_group_id
                from    cst_cost_groups ccg
                where   ccg.legal_entity = l_entity_id
                and     ccg.cost_group_type = 2
                and     NVL(ccg.disable_date, sysdate) >= sysdate;

l_stmt_num              NUMBER;
l_api_name            CONSTANT VARCHAR2(30) := 'open_period';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

 IF (l_pLog) THEN
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       l_module || '.begin',
                       l_api_name || ' <<< Parameters:
                       l_entity_id  = ' || l_entity_id || '
                       l_cost_type_id = ' || l_cost_type_id || '
                       open_period_name = ' || open_period_name || '
                       open_period_num = ' || open_period_num || '
                       open_period_year = ' || open_period_year || '
                       open_period_set_name = ' || open_period_set_name || '
                       open_period_type = ' || open_period_type || '
                       l_period_end_date = ' || l_period_end_date || '
                       last_scheduled_close_date = ' || last_scheduled_close_date);
 END IF;


/* **************************************************************************** */
/* Initialize all local and OUT params of the open procedure                    */
/* **************************************************************************** */
        l_stmt_num                      := 0;
        low_period_id                   := 0;
        period_count                    := 0;
        first_period_to_be_opened       := false;
        commit_complete                 := false;
        duplicate_open_period           := false;
        prior_open_period               := false;
        current_cost_group_id           := 0;
        no_cost_groups                  := 0;
        phase_count                     := 0;
        undefined_cost_groups           := false;
        new_pac_period_id               := 0;
        dummy_id                        := 0;
        improper_order                  := false;
        proper_period_name              := NULL;
        dummy_date                      := NULL;
        proper_period_num               := 0;
        proper_period_year              := 0;
        distributions_flag              := 'N';
        user_defined_error              := false;

/* **************************************************************************** */
/* Validate period to be opened                                                 */
/* **************************************************************************** */

  CSTPPPSC.validate_open_period(
        l_entity_id,
        l_cost_type_id,
        l_user_id,
        l_login_id,
        open_period_name,
        open_period_num,
        open_period_year,
        open_period_set_name,
        open_period_type,
        last_scheduled_close_date,
        l_period_end_date,
        prior_open_period,
        improper_order,
        new_pac_period_id,
        duplicate_open_period,
        undefined_cost_groups,
        user_defined_error,
        commit_complete
        );

   IF ( (prior_open_period = true)      OR
        (improper_order = true)         OR
        (duplicate_open_period = true)  OR
        (user_defined_error = true)     OR
        (undefined_cost_groups = true)) THEN

                commit_complete := false;
                goto procedure_end_label;
   END IF;


/* **************************************************************************** */
/* To obtain the new pac period id for the period being opened from             */
/* a sequence                                                                   */
/* **************************************************************************** */
        l_stmt_num := 10;
        open get_new_period_id_cur;
        fetch get_new_period_id_cur into new_pac_period_id;
        if (get_new_period_id_cur%NOTFOUND) then
                new_pac_period_id       := 0;
                commit_complete         := false;
                goto procedure_end_label;
        end if;
        close get_new_period_id_cur;

/* **************************************************************************** */
/* To obtain the Distributions Flag for the LE-CT                               */
/* **************************************************************************** */

        distributions_flag := 'N';
        transfer_cost_flag := 'N';

        l_stmt_num := 20;
        SELECT  NVL(CREATE_ACCT_ENTRIES,'N')
             ,  nvl(transfer_cost_flag,'N')
        INTO    distributions_flag
              , transfer_cost_flag
        FROM    CST_LE_COST_TYPES
        WHERE   LEGAL_ENTITY    = l_entity_id
        AND     COST_TYPE_ID    = l_cost_type_id
        AND     PRIMARY_COST_METHOD > 2;

/* **************************************************************************** */
/* START OPENING THE PERIOD. The steps are...                                   */
/*      1. Insert into cst_pac_periods form gl_periods table                    */
/*      2. For each an every cost group defined in the legal entity             */
/*              Insert five rows for five process statuses  into                */
/*              cst_pac_process_phases                                          */
/* **************************************************************************** */



/* **************************************************************************** */
/* Insert a single row for the pac period being opened into cst_pac_periods     */
/* Insert the rows with 'P' (Pending) status and period close date = sysdate    */
/* **************************************************************************** */

                l_stmt_num := 30;
                INSERT INTO cst_pac_periods (
                        pac_period_id,
                        legal_entity,
                        cost_type_id,
                        period_start_date,
                        period_end_date,
                        open_flag,
                        period_year,
                        period_num,
                        period_name,
                        period_set_name,
                        period_close_date,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login )
                        SELECT  new_pac_period_id,
                                l_entity_id,
                                l_cost_type_id,
                                gp.start_date,
                                gp.end_date,
                                'P',
                                gp.period_year,
                                gp.period_num,
                                gp.period_name,
                                gp.period_set_name,
                                SYSDATE,
                                SYSDATE,
                                l_user_id,
                                SYSDATE,
                                l_user_id,
                                -1
                        FROM    gl_periods gp
                        WHERE   gp.period_name          = open_period_name
                        AND     gp.period_num           = open_period_num
                        AND     gp.period_year          = open_period_year
                        AND     gp.period_set_name =       (select gsob.period_set_name
                                                 from   gl_sets_of_books gsob, cst_le_cost_types clct
                                                 where  gsob.set_of_books_id = clct.set_of_books_id
                                                 and    clct.legal_entity = l_entity_id
                                                 and    clct.cost_type_id = l_cost_type_id
                                                 and    clct.primary_cost_method > 2)
                        AND     (gp.period_name, gp.period_num, gp.period_year) NOT IN
                                        (select period_name, period_num, period_year
                                         from   cst_pac_periods
                                         where  legal_entity = l_entity_id
                                         and    cost_type_id = l_cost_type_id);

        IF(SQL%ROWCOUNT = 0) THEN
                goto procedure_end_label;
        END IF;


        COMMIT;
        SAVEPOINT before_process_phases_table;

/* **************************************************************************** */
/* Open cursor for all cost groups defined in the legal entity                  */
/* **************************************************************************** */


                no_available_cost_group := true;
                no_cost_groups          := 0;

                l_stmt_num := 40;
                open  all_cost_groups_cur;
                LOOP
                        current_cost_group_id := 0;
                        fetch all_cost_groups_cur into current_cost_group_id;
                        if (all_cost_groups_cur%NOTFOUND) then
                                if(no_available_cost_group) then
                                        /* No cost groups defined */
                                        undefined_cost_groups   := true;
                                        commit_complete         := false;
                                        goto error_label;
                                else
                                        /* All cost group processing done */
                                        undefined_cost_groups   := false;
                                        goto check_duplicate_label;
                                end if;
                        end if;


                        /* Start Phase Count =1 and loop for all five phases */
                        no_available_cost_group         := false;
                        phase_count     := 0;


                /* **************************************************************************** */
                /* Loop for five process phases                                                 */
                /* **************************************************************************** */

                        LOOP

                        /* Increment Phase_count by 1 */
                        phase_count     := phase_count +1;
                        no_cost_groups  := phase_count;


                /* **************************************************************************** */
                /* Insert a row for each and every cost group and phases into                   */
                /* cst_pac_process_phases table                                                 */
                /* **************************************************************************** */

                        l_stmt_num := 50;
                        INSERT INTO cst_pac_process_phases (
                                pac_period_id,
                                cost_group_id,
                                process_phase,
                                process_status,
                                process_date,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                last_update_login )
                                SELECT
                                        new_pac_period_id,
                                        current_cost_group_id,
                                        phase_count,
                                        DECODE(phase_count,6,DECODE(distributions_flag,'Y',1,0), 7,DECODE(transfer_cost_flag,'Y',1,0),8,DECODE(transfer_cost_flag,'Y',1,0),1),
                                        NULL,
                                        SYSDATE,
                                        l_user_id,
                                        SYSDATE,
                                        l_user_id,
                                        -1
                                FROM    dual;

                        if (phase_count = 8) then
                                goto cppp_insert_done_label;
                        end if;

                        END LOOP;



        <<cppp_insert_done_label>>
                        NULL;

                END LOOP;
                close all_cost_groups_cur;



        <<check_duplicate_label>>

/* **************************************************************************** */
/* This section is to check whether another is simultaneously trying to open    */
/* this period. This section catches such a condition                           */
/*      If YES => duplicate_open_period = TRUE                                  */
/*      If NO =>  duplicate_open_period = FALSE                                 */
/* **************************************************************************** */
                l_stmt_num := 60;
                open check_if_duplicating_cur;
                fetch check_if_duplicating_cur into dummy_id;
                if (check_if_duplicating_cur%FOUND) then
                        /* Duplicate open period found */
                        duplicate_open_period   := true;
                        commit_complete         := false;
                        rollback to before_process_phases_table;
                        delete from cst_pac_process_phases where pac_period_id = dummy_id;
                        goto error_label;
                else
                        /* No Duplicating rows found */
                        duplicate_open_period   := false;
                end if;
                close check_if_duplicating_cur;


/* **************************************************************************** */
/* Update the the new pac period row in cst_pac_periods with open_flag = 'Y'    */
/* and  the period close date = NULL, this declaring the period as open         */
/* **************************************************************************** */
        l_stmt_num := 70;
        UPDATE  cst_pac_periods
        SET       open_flag             = 'Y',
                period_close_date       = NULL,
                last_update_date        = trunc(sysdate),
                last_updated_by         = l_user_id,
                last_update_login       = l_login_id
        WHERE   pac_period_id           = new_pac_period_id;


        <<sucess_label>>
                commit;

                /* **************************************************************************** */
                /* Reset the last_scheduled_close_date OUT param with the period_end_date       */
                /* of the newly opened period                                                   */
                /* **************************************************************************** */
                l_stmt_num := 80;
                SELECT  NVL(MAX(period_end_date),sysdate)
                INTO    last_scheduled_close_date
                FROM    cst_pac_periods
                WHERE   legal_entity = l_entity_id
                AND     cost_type_id = l_cost_type_id;

                commit_complete := true;

                goto procedure_end_label;


        <<error_label>>
                rollback;

                /* **************************************************************************** */
                /* In case of an error, rollback will take care of the unwanted rows in         */
                /* the cst_pac_process_phases table. However the row inserted into              */
                /* cst_pac_periods have already been commited, hence need to be explicitly      */
                /* deleted. The section below does that...                                      */
                /* **************************************************************************** */

                delete from cst_pac_periods
                where pac_period_id = new_pac_period_id;

                commit_complete := false;


                goto procedure_end_label;


        <<procedure_end_label>>
        NULL;

         IF (l_pLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                  l_module || '.end',
                  l_api_name || ' >>>');
         END IF;

        EXCEPTION
            WHEN OTHERS THEN
                     IF (l_uLog) THEN
                           FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                           l_module || '.' || l_stmt_num,
                                           SQLERRM);
                     END IF;
                     rollback;
                     user_defined_error := true;
                     commit_complete := false;

END     open_period;




/* **************************************************************************** */
/* **************************************************************************** */
/* **************************************************************************** */



/* **************************************************************************** */
/* This procedure is called from PAC Period form to close a period with proper  */
/* validations. Below are a description of the various IN and OUT params        */
/*                                                                              */
/* IN Params:   1. l_entity_id: legal entity id                                 */
/*              2. l_cost_type_id; Cost type ID                                 */
/*              3. closing_pac_period_id : PAC period id of the period being    */
/*                 closed                                                       */
/*              4. closing_end_date: Period end date of  the PAC Period being   */
/*                 closed                                                       */
/*              5. l_user_id: User ID                                           */
/*              6. l_login_id : Login ID                                        */
/* IN OUT Params:                                                               */
/*              1. last_scheduled_close_date: It is a user defined param which  */
/*                 holds the value of the max(end_date) of all the periods in   */
/*                 in cst_pac_periods table for a particular LE-CT              */
/* OUT Params:                                                                  */
/*              1. end_date_is_passed: TRUE of the user is trying to close      */
/*                 whose period end date is in future                           */
/*              2. incomplete_processing: TRUE if the process status of all the */
/*                 cost groups for the period are not completely processes      */
/*              3. rerun_processor: TRUE if the processor has been in an        */
/*                 intermediate date and should be rerun to process txn after   */
/*                 that date till the period end date                           */
/*              4. prompt_to_reclose: TRUE id another is trying to close this   */
/*                 period simultaneously                                        */
/*              5. undefined_cost_groups: TRUE if no cost groups are defined    */
/*                 for the legal entity                                         */
/*              6. commit_complete: TRUE is the period has been sucessfully     */
/*                 closed                                                       */
/* **************************************************************************** */



PROCEDURE validate_close_period (
                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                closing_pac_period_id           IN      NUMBER,
                                closing_period_type             IN      VARCHAR2,
                                closing_end_date                IN      DATE,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,

                                last_scheduled_close_date       IN OUT NOCOPY   DATE,
                                end_date_is_passed              OUT NOCOPY     BOOLEAN,
                                incomplete_processing           OUT NOCOPY     BOOLEAN,
                                pending_transactions            OUT NOCOPY      BOOLEAN,
                                rerun_processor                 OUT NOCOPY      BOOLEAN,
                                prompt_to_reclose               OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
                                backdated_transactions          OUT NOCOPY     BOOLEAN,
                                perpetual_periods_open          OUT NOCOPY     BOOLEAN,
                                ap_period_open                  OUT NOCOPY      BOOLEAN,
                                ar_period_open                  OUT NOCOPY      BOOLEAN,
                cogsgen_phase2_notrun   OUT NOCOPY  BOOLEAN,
                cogsgen_phase3_notrun   OUT NOCOPY  BOOLEAN,
                                user_defined_error              OUT NOCOPY     BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN
                        ) IS


/* **************************************************************************** */
/* This section declares all the local variable for the close procedure         */
/* **************************************************************************** */

        dummy_id                NUMBER;
        no_cost_groups          NUMBER;
        current_cost_group_id   NUMBER;
        no_cost_groups_available BOOLEAN;
        count_rows              NUMBER;
        rerun_process_date      DATE;

    -- Variables for Revenue / COGS Matching checks
    l_effective_period_num  NUMBER;
    l_ledger_id             NUMBER;
    l_create_acct_entries   VARCHAR2(1);
    l_ar_period_status      VARCHAR2(1);
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(1000);
    l_phase2_required       NUMBER;
    l_phase3_required       NUMBER;
    l_so_txn_flag           VARCHAR2(1);

    x_current_upto_date     DATE;
    x_exist                 VARCHAR2(1);
    x_required              VARCHAR2(1);


/* **************************************************************************** */
/* Cursor for checking open AP periods                                   */
/* **************************************************************************** */
        CURSOR ap_period_open_cur(      p_entity_id             NUMBER,
                                        p_cost_type_id          NUMBER,
                                        p_closing_end_date      DATE)    IS
                SELECT count(1)
                FROM gl_period_statuses gps
                WHERE gps.application_id = 200
                AND gps.closing_status <> 'C'
                AND trunc(gps.end_date) = trunc(p_closing_end_date)
                AND gps.set_of_books_id = (     SELECT  distinct clct.set_of_books_id
                                                FROM    cst_le_cost_types clct
                                                WHERE   clct.cost_type_id = p_cost_type_id
                                                AND     clct.legal_entity = p_entity_id
                                          )
                AND rownum < 2;


/* **************************************************************************** */
/* Cursor for checking open perpetual periods                                   */
/* **************************************************************************** */
        CURSOR perpetual_periods_cur(l_current_cost_group_id NUMBER,
                                     l_closing_pac_period_id NUMBER) IS
                SELECT  count(1)
                FROM    org_acct_periods
                WHERE   open_flag IN ('Y','P')
                AND     trunc(schedule_close_date) <=
                                  (select trunc(period_end_date)
                                  from   cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     organization_id IN (    SELECT  ccga.organization_id
                                                FROM    cst_cost_group_assignments ccga
                                                WHERE   ccga.cost_group_id = l_current_cost_group_id
                                            )
                AND      rownum < 2;


/* **************************************************************************** */
/* Cursor for checking backdated txns in MMT                                    */
/* **************************************************************************** */
        CURSOR back_dated_mmt_cur(      l_current_cost_group_id NUMBER,
                                        l_closing_pac_period_id NUMBER,
                                        l_entity_id             NUMBER,
                                        l_cost_type_id          NUMBER) IS
                SELECT  count(1)
                FROM    mtl_material_transactions mmt
                WHERE   mmt.creation_date > ( SELECT MIN(cppp.process_date)
                                              FROM   cst_pac_process_phases cppp
                                              WHERE
                                                ((   cppp.process_phase <= 5
                                                AND cppp.process_upto_date IS NOT NULL)
                                                OR
                                                (   cppp.process_phase = 6
                                                AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                        FROM    CST_LE_COST_TYPES
                                                        WHERE   LEGAL_ENTITY    = l_entity_id
                                                        AND     COST_TYPE_ID    = l_cost_type_id
                                                        AND     PRIMARY_COST_METHOD > 2
                                                        AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                                AND cppp.process_upto_date IS NOT NULL
                                                ))
                                                AND cppp.pac_period_id = l_closing_pac_period_id
                                            /* bug 2658552  */
                                                AND cppp.cost_group_id = l_current_cost_group_id
                                             )
                AND     mmt.organization_id IN
                                (select ccga.organization_id
                                from cst_cost_group_assignments ccga
                                where ccga.cost_group_id = l_current_cost_group_id)
                AND     mmt.transaction_date >=
                                 (select trunc(period_start_date)
                                  from    cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     mmt.transaction_date <=
                                 (select (trunc(period_end_date) + 0.99999)
                                  from   cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     rownum < 2;

/* **************************************************************************** */
/* Cursor for checking backdated txns in WT                                     */
/* **************************************************************************** */
        CURSOR back_dated_wt_cur(       l_current_cost_group_id NUMBER,
                                        l_closing_pac_period_id NUMBER,
                                        l_entity_id             NUMBER,
                                        l_cost_type_id          NUMBER) IS
                SELECT  count(1)
                FROM    wip_transactions wt
                WHERE   wt.creation_date > ( SELECT MIN(cppp.process_date)
                                              FROM   cst_pac_process_phases cppp
                                              WHERE
                                                ((   cppp.process_phase <= 5
                                                AND cppp.process_upto_date IS NOT NULL)
                                                OR
                                                (   cppp.process_phase = 6
                                                AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                        FROM    CST_LE_COST_TYPES
                                                        WHERE   LEGAL_ENTITY    = l_entity_id
                                                        AND     COST_TYPE_ID    = l_cost_type_id
                                                        AND     PRIMARY_COST_METHOD > 2
                                                        AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                                AND cppp.process_upto_date IS NOT NULL
                                                ))
                                                AND cppp.pac_period_id = l_closing_pac_period_id
                                            /* bug 2658552  */
                                                AND cppp.cost_group_id = l_current_cost_group_id
                                             )
                AND     wt.organization_id IN
                                (select ccga.organization_id
                                from cst_cost_group_assignments ccga
                                where ccga.cost_group_id = l_current_cost_group_id)
                AND     wt.transaction_date >=
                                 (select trunc(period_start_date)
                                  from    cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     wt.transaction_date <=
                                 (select (trunc(period_end_date) + 0.99999)
                                  from   cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     rownum < 2;


/* **************************************************************************** */
/* Cursor for checking backdated txns in RT                                     */
/* **************************************************************************** */
        CURSOR back_dated_rt_cur(      l_current_cost_group_id NUMBER,
                                        l_closing_pac_period_id NUMBER,
                                        l_entity_id             NUMBER,
                                        l_cost_type_id          NUMBER) IS
                SELECT  count(1)
                FROM    rcv_transactions rt
                WHERE   rt.creation_date > ( SELECT MIN(cppp.process_date)
                                              FROM   cst_pac_process_phases cppp
                                              WHERE
                                                ((   cppp.process_phase <= 5
                                                AND cppp.process_upto_date IS NOT NULL)
                                                OR
                                                (   cppp.process_phase = 6
                                                AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                        FROM    CST_LE_COST_TYPES
                                                        WHERE   LEGAL_ENTITY    = l_entity_id
                                                        AND     COST_TYPE_ID    = l_cost_type_id
                                                        AND     PRIMARY_COST_METHOD > 2
                                                        AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                                AND cppp.process_upto_date IS NOT NULL
                                                ))
                                                AND cppp.pac_period_id = l_closing_pac_period_id
                                            /* bug 2658552  */
                                                AND cppp.cost_group_id = l_current_cost_group_id
                                             )
                AND     rt.organization_id IN
                                (select ccga.organization_id
                                from cst_cost_group_assignments ccga
                                where ccga.cost_group_id = l_current_cost_group_id)
                AND     rt.transaction_date >=
                                 (select trunc(period_start_date)
                                  from    cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     rt.transaction_date <=
                                 (select (trunc(period_end_date) + 0.99999)
                                  from   cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     rownum < 2;

/* **************************************************************************** */
/* Cursor for checking backdated txns in RAE                                    */
/* **************************************************************************** */
        CURSOR back_dated_rae_cur(      l_current_cost_group_id NUMBER,
                                        l_closing_pac_period_id NUMBER,
                                        l_entity_id             NUMBER,
                                        l_cost_type_id          NUMBER) IS
                SELECT  count(1)
                FROM    rcv_accounting_events rae
                WHERE   rae.creation_date > ( SELECT MIN(cppp.process_date)
                                              FROM   cst_pac_process_phases cppp
                                              WHERE
                                                ((   cppp.process_phase <= 5
                                                AND cppp.process_upto_date IS NOT NULL)
                                                OR
                                                (   cppp.process_phase = 6
                                                AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                        FROM    CST_LE_COST_TYPES
                                                        WHERE   LEGAL_ENTITY    = l_entity_id
                                                        AND     COST_TYPE_ID    = l_cost_type_id
                                                        AND     PRIMARY_COST_METHOD > 2
                                                        AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                                AND cppp.process_upto_date IS NOT NULL
                                                ))
                                                AND cppp.pac_period_id = l_closing_pac_period_id
                                                AND cppp.cost_group_id = l_current_cost_group_id
                                             )
                AND     rae.organization_id IN
                                (select ccga.organization_id
                                from cst_cost_group_assignments ccga
                                where ccga.cost_group_id = l_current_cost_group_id)
                AND     rae.transaction_date >=
                                 (select trunc(period_start_date)
                                  from    cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     rae.transaction_date <=
                                 (select (trunc(period_end_date) + 0.99999)
                                  from   cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     rae.event_type_id IN (7,8, 9, 10)
                AND     rownum < 2;


/* **************************************************************************** */
/* Cursor for checking backdated txns in LCM ADJ TXN                            */
/* **************************************************************************** */
        CURSOR back_dated_lcadj_cur(    l_current_cost_group_id NUMBER,
                                        l_closing_pac_period_id NUMBER,
                                        l_entity_id             NUMBER,
                                        l_cost_type_id          NUMBER) IS
                SELECT  count(1)
                FROM    cst_lc_adj_transactions clat
                WHERE   clat.creation_date > ( SELECT MIN(cppp.process_date)
                                              FROM  cst_pac_process_phases cppp
                                              WHERE
                                                ((   cppp.process_phase <= 5
                                                AND cppp.process_upto_date IS NOT NULL)
                                                OR
                                                (   cppp.process_phase = 6
                                                AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                        FROM    CST_LE_COST_TYPES
                                                        WHERE   LEGAL_ENTITY    = l_entity_id
                                                        AND     COST_TYPE_ID    = l_cost_type_id
                                                        AND     PRIMARY_COST_METHOD > 2
                                                        AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                                AND cppp.process_upto_date IS NOT NULL
                                                ))
                                                AND cppp.pac_period_id = l_closing_pac_period_id
                                                AND cppp.cost_group_id = l_current_cost_group_id
                                             )
                AND     clat.organization_id IN
                                (select ccga.organization_id
                                from cst_cost_group_assignments ccga
                                where ccga.cost_group_id = l_current_cost_group_id)
                AND     clat.transaction_date >=
                                 (select trunc(period_start_date)
                                  from    cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     clat.transaction_date <=
                                 (select (trunc(period_end_date) + 0.99999)
                                  from   cst_pac_periods
                                  where  pac_period_id = l_closing_pac_period_id )
                AND     rownum < 2;


/* **************************************************************************** */
/* Cursor for all cost groups defined in the legal entity                       */
/* **************************************************************************** */

        CURSOR all_cost_groups_cur IS
                select  cost_group_id
                from    cst_cost_groups ccg
                where   ccg.legal_entity = l_entity_id
                and     ccg.cost_group_type = 2
                and     NVL(ccg.disable_date, sysdate) >= sysdate
                and     ccg.cost_group_id IN    (
                                SELECT  distinct cost_group_id
                                FROM    cst_cost_group_assignments
                                WHERE   legal_entity = l_entity_id );

/* **************************************************************************** */
/* Cursor to check for pending txn in MMTT                                      */
/* **************************************************************************** */

CURSOR cur_mmtt(l_current_cost_group_id NUMBER,l_closing_pac_period_id NUMBER) IS
        SELECT  count(1)
        FROM    mtl_material_transactions_temp mmtt
        WHERE   NVL(mmtt.transaction_status,0) <> 2
        AND     mmtt.organization_id IN
                        (select ccga.organization_id
                        from cst_cost_group_assignments ccga
                        where ccga.cost_group_id = l_current_cost_group_id)
        AND     mmtt.transaction_date >=
                        (select trunc(period_start_date)
                         from    cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     mmtt.transaction_date <=
                        (select (trunc(period_end_date)+0.99999)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     rownum < 2;

/* **************************************************************************** */
/* Cursor to check for pending txn in MTI                                       */
/* **************************************************************************** */

CURSOR cur_mti(l_current_cost_group_id NUMBER,l_closing_pac_period_id NUMBER) IS
        SELECT  count(1)
        FROM    mtl_transactions_interface mti
        WHERE   mti.organization_id  IN
                        (select ccga.organization_id
                        from cst_cost_group_assignments ccga
                        where ccga.cost_group_id = l_current_cost_group_id)
        AND     mti.transaction_date >=
                        (select trunc(period_start_date)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     mti.transaction_date <=
                        (select (trunc(period_end_date)+0.99999)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     rownum < 2;

/* **************************************************************************** */
/* Cursor to check for pending txn in WCTI                                      */
/* **************************************************************************** */

CURSOR cur_wcti(l_current_cost_group_id NUMBER,l_closing_pac_period_id NUMBER) IS
        SELECT  count(1)
        FROM    wip_cost_txn_interface wcti
        WHERE   wcti.organization_id  IN
                        (select ccga.organization_id
                        from cst_cost_group_assignments ccga
                        where ccga.cost_group_id = l_current_cost_group_id)
        AND     wcti.transaction_date >=
                        (select trunc(period_start_date)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     wcti.transaction_date <=
                        (select (trunc(period_end_date)+0.99999)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     rownum < 2;

/* **************************************************************************** */
/* Cursor to check for pending txn in RTI                                       */
/* **************************************************************************** */

CURSOR cur_rti(l_current_cost_group_id NUMBER,l_closing_pac_period_id NUMBER) IS
        SELECT  count(1)
        FROM    rcv_transactions_interface rti
        WHERE   rti.to_organization_code  IN
                        (select mp.organization_code
                        from cst_cost_group_assignments ccga,
                             mtl_parameters  mp
                        where ccga.cost_group_id = l_current_cost_group_id
                        and   ccga.organization_id = mp.organization_id)
        AND     rti.transaction_date >=
                        (select trunc(period_start_date)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     rti.transaction_date <=
                        (select (trunc(period_end_date)+0.99999)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     rownum < 2;

/* **************************************************************************** */
/* Cursor to check for pending txn in LCM INTERFACE                             */
/* **************************************************************************** */
CURSOR cur_lci(l_current_cost_group_id NUMBER,l_closing_pac_period_id NUMBER) IS
        SELECT  count(1)
        FROM    cst_lc_adj_interface lci
        WHERE   lci.organization_id  IN
                        (select ccga.organization_id
                        from cst_cost_group_assignments ccga
                        where ccga.cost_group_id = l_current_cost_group_id)
        AND     lci.transaction_date >=
                        (select trunc(period_start_date)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     lci.transaction_date <=
                        (select (trunc(period_end_date)+0.99999)
                         from   cst_pac_periods
                         where  pac_period_id = l_closing_pac_period_id )
        AND     rownum < 2;


-- ===================================================================
-- FP BUG 8563354:AR Period validation only if
-- there is atleast one SO issue or RMA txn for the valid
-- inventory organizations of the cost group in any
-- period.
-- ====================================================================
CURSOR cur_so_txn(c_legal_entity_id NUMBER) IS
SELECT 'Y'
  FROM MTL_MATERIAL_TRANSACTIONS
 WHERE transaction_source_type_id IN (2,12)
   AND organization_id IN (Select ccga.organization_id
                             from cst_cost_group_assignments ccga,
                                  cst_cost_groups ccg
                            where ccga.cost_group_id = ccg.cost_group_id
                              and ccg.legal_entity = c_legal_entity_id
                              and ccg.cost_group_type = 2
                              and NVL(ccg.disable_date, sysdate) >= sysdate)
   AND rownum = 1;


l_err_msg VARCHAR2(255);
l_stmt_num              NUMBER;

l_api_name            CONSTANT VARCHAR2(30) := 'validate_close_period';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);


BEGIN

 IF (l_pLog) THEN
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       l_module || '.begin',
                       l_api_name || ' <<< Parameters:
                       l_entity_id  = ' || l_entity_id || '
                       l_cost_type_id = ' || l_cost_type_id || '
                       closing_pac_period_id = ' || closing_pac_period_id || '
                       closing_period_type = ' || closing_period_type || '
                       closing_end_date = ' || closing_end_date );
 END IF;

/* **************************************************************************** */
/* This section initializes all local and OUT Params of the close procedure     */
/* **************************************************************************** */

        dummy_id                := 0;
        end_date_is_passed      := false;
        prompt_to_reclose       := false;
        incomplete_processing   := false;
        pending_transactions    := false;
        current_cost_group_id   := 0;
        no_cost_groups          := 0;
        undefined_cost_groups   := false;
        rerun_processor         := false;
        commit_complete         := false;
        no_cost_groups_available:= false;
        backdated_transactions  := false;
        perpetual_periods_open  := false;
        ap_period_open          := false;
        ar_period_open          := false;
    cogsgen_phase2_notrun  := false;
    cogsgen_phase3_notrun  := false;


        user_defined_error      := false;
        count_rows              := 0;
        rerun_process_date      := trunc(closing_end_date) +1;
        l_stmt_num := 0;

/* **************************************************************************** */
/* This section checks whether the period end date lies in future               */
/*      if YES => end_date_is_passed = TRUE                                     */
/*      if No =>  end_date_is_passed = FALSE                                    */
/* **************************************************************************** */

        if (trunc(closing_end_date)+1 > SYSDATE ) then
                end_date_is_passed      := true;
                commit_complete         := false;
                goto procedure_end_label;
        else
                end_date_is_passed      := false;
        end if;


        no_cost_groups := 0;
        no_cost_groups_available := true;



/* **************************************************************************** */
/* Start LOOP to check whether process status  = 4 (Complete) for all cost      */
/* in the PAC Period (check Phase 6 only if clct.CREATE_ACCT_ENTRIES='Y'        */
/* Logic is as follows...                                                       */
/*      IF process_status <> 4  => incomplete_processing = TRUE                 */
/*      IF process_status = 4  and process_date < period_end_date               */
/*                              => rerun_processor = TRUE                       */
/*      ELSE    go ahead with closing this period                               */
/* **************************************************************************** */

        l_stmt_num := 10;
        open all_cost_groups_cur;

        LOOP
                current_cost_group_id := 0;
                fetch all_cost_groups_cur into current_cost_group_id;
                if ( all_cost_groups_cur%NOTFOUND) then
                        if ( no_cost_groups_available ) then
                                /* No cost groups associated */
                                undefined_cost_groups   := true;
                                rerun_processor         := false;
                                commit_complete         := false;
                                goto procedure_end_label;
                        else
                                /* All cost group processing done */
                                undefined_cost_groups   := false;
                                rerun_processor         := false;
                                incomplete_processing   := false;
                                goto check_ar_label;
                        end if;
                end if;

                no_cost_groups_available := false;
                no_cost_groups := no_cost_groups + 1;


                count_rows := 0;
                dummy_id := 0;

             /* Bug 3591905. The following Select statement was checking for process_phase < 5 instead of process_phase <= 5 */
                l_stmt_num := 20;
                SELECT  count(1)
                INTO    count_rows
                FROM    cst_pac_process_phases
                WHERE   pac_period_id   = closing_pac_period_id
                AND     cost_group_id   = current_cost_group_id
                AND     ((      process_status  <> 4
                                AND process_phase <= 5
                         )
                         OR
                         (      process_status <> 4
                                AND process_phase = 6
                                AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                FROM    CST_LE_COST_TYPES
                                                WHERE   LEGAL_ENTITY    = l_entity_id
                                                AND     COST_TYPE_ID    = l_cost_type_id
                                                AND     PRIMARY_COST_METHOD > 2
                                                AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                        ))
                  AND rownum < 2;


              /* Bug 3591905. The following Select statement was checking for process_phase < 5 instead of process_phase <= 5 */
                l_stmt_num := 30;
                if ( count_rows <> 0) then

                        SELECT  distinct NVL(pac_period_id,0)
                        INTO    dummy_id
                        FROM    cst_pac_process_phases
                        WHERE   pac_period_id   = closing_pac_period_id
                        AND     cost_group_id   = current_cost_group_id
                        AND     ((      process_status  <> 4
                                        AND process_phase <= 5
                                 )
                                 OR
                                 (      process_status <> 4
                                        AND process_phase = 6
                                        AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                        FROM    CST_LE_COST_TYPES
                                                        WHERE   LEGAL_ENTITY    = l_entity_id
                                                        AND     COST_TYPE_ID    = l_cost_type_id
                                                        AND     PRIMARY_COST_METHOD > 2
                                                        AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                 ));


                end if;


                if ( dummy_id <> 0 ) then
                        incomplete_processing := true;
                        rerun_processor := false;
                        commit_complete := false;
                        goto procedure_end_label;
                else

                /* Bug 3591905. The following Select statement was checking for process_phase < 5 instead of process_phase <= 5 */
                        l_stmt_num := 40;
                        count_rows := 0;
                        rerun_process_date := trunc(closing_end_date)+1;

                        SELECT  count(1)
                        INTO    count_rows
                        FROM    cst_pac_process_phases
                        WHERE   pac_period_id   = closing_pac_period_id
                        AND     cost_group_id   = current_cost_group_id
                        AND     (
                                ((      process_date    < trunc(closing_end_date)+1
                                        AND process_phase <= 5
                                 )
                                OR
                                (       process_date    < trunc(closing_end_date)+1
                                        AND process_phase = 6
                                        AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                 FROM    CST_LE_COST_TYPES
                                                WHERE   LEGAL_ENTITY    = l_entity_id
                                                AND     COST_TYPE_ID    = l_cost_type_id
                                                AND     PRIMARY_COST_METHOD > 2
                                                AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                ))
                        OR
                                ((      trunc(NVL(process_upto_date,closing_end_date-1))  < trunc(closing_end_date)
                                        AND process_phase <= 5
                                 )
                                 OR
                                (       trunc(NVL(process_upto_date,closing_end_date-1))  < trunc(closing_end_date)
                                        AND process_phase = 6
                                        AND EXISTS (    SELECT  CREATE_ACCT_ENTRIES
                                                 FROM    CST_LE_COST_TYPES
                                                WHERE   LEGAL_ENTITY    = l_entity_id
                                                AND     COST_TYPE_ID    = l_cost_type_id
                                                AND     PRIMARY_COST_METHOD > 2
                                                AND     NVL(CREATE_ACCT_ENTRIES,'N') = 'Y')
                                ))
                                )
                          AND   rownum < 2;


                        if ( count_rows <> 0 ) then
                                incomplete_processing := false;
                                rerun_processor := true;
                                commit_complete := false;
                                goto procedure_end_label;
                        else

                                /* **********section to check perpetual periods **************** */

                                count_rows := 0;
                                open perpetual_periods_cur(current_cost_group_id,
                                                           closing_pac_period_id);
                                fetch perpetual_periods_cur into count_rows;
                                if(count_rows <> 0 ) then
                                        perpetual_periods_open := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close perpetual_periods_cur;

                                /* **********section to check pending txns **************** */

                                /* check for pending rows in MMTT */
                                count_rows := 0;
                                open cur_mmtt(current_cost_group_id,closing_pac_period_id);
                                fetch cur_mmtt into count_rows;
                                if(count_rows <> 0 ) then
                                        pending_transactions := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close cur_mmtt;

                                /* check for pending rows in MTI */
                                count_rows := 0;
                                open cur_mti(current_cost_group_id,closing_pac_period_id);
                                fetch cur_mti into count_rows;
                                if(count_rows <> 0 ) then
                                        pending_transactions := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close cur_mti;

                                /* check for pending rows in WCTI */
                                count_rows := 0;
                                open cur_wcti(current_cost_group_id,closing_pac_period_id);
                                fetch cur_wcti into count_rows;
                                if(count_rows <> 0 ) then
                                        pending_transactions := true;
                                        goto procedure_end_label;
                                end if;
                                close cur_wcti;

                                /* check for pending rows in RTI */
                                count_rows := 0;
                                open cur_rti(current_cost_group_id,closing_pac_period_id);
                                fetch cur_rti into count_rows;
                                if(count_rows <> 0 ) then
                                        pending_transactions := true;
                                        goto procedure_end_label;
                                end if;
                                close cur_rti;

                                /* check for pending rows in LCI */
                                count_rows := 0;
                                open cur_lci(current_cost_group_id,closing_pac_period_id);
                                fetch cur_lci into count_rows;
                                if(count_rows <> 0 ) then
                                        pending_transactions := true;
                                        goto procedure_end_label;
                                end if;
                                close cur_lci;

                                /* **********section to check backdated txns **************** */
                                /* check for backdated txns in MMT */
                                count_rows := 0;
                                open back_dated_mmt_cur(current_cost_group_id,
                                                        closing_pac_period_id,
                                                        l_entity_id,
                                                        l_cost_type_id);
                                fetch back_dated_mmt_cur into count_rows;
                                if(count_rows <> 0 ) then
                                        backdated_transactions := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close back_dated_mmt_cur;

                                /* check for backdated txns in WT */
                                count_rows := 0;
                                open back_dated_wt_cur(current_cost_group_id,
                                                        closing_pac_period_id,
                                                        l_entity_id,
                                                        l_cost_type_id);
                                fetch back_dated_wt_cur into count_rows;
                                if(count_rows <> 0 ) then
                                        backdated_transactions := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close back_dated_wt_cur;

                                /* check for backdated txns in RT */
                                count_rows := 0;
                                open back_dated_rt_cur(current_cost_group_id,
                                                        closing_pac_period_id,
                                                        l_entity_id,
                                                        l_cost_type_id);
                                fetch back_dated_rt_cur into count_rows;
                                if(count_rows <> 0 ) then
                                        backdated_transactions := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close back_dated_rt_cur;


                                /* check for backdated txns in RAE */
                                count_rows := 0;
                                open back_dated_rae_cur(current_cost_group_id,
                                                        closing_pac_period_id,
                                                        l_entity_id,
                                                        l_cost_type_id);
                                fetch back_dated_rae_cur into count_rows;
                                if(count_rows <> 0 ) then
                                        backdated_transactions := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close back_dated_rae_cur;

                                /* check for backdated txns in LCM ADJ */
                                count_rows := 0;
                                open back_dated_lcadj_cur(current_cost_group_id,
                                                        closing_pac_period_id,
                                                        l_entity_id,
                                                        l_cost_type_id);
                                fetch back_dated_lcadj_cur into count_rows;
                                if(count_rows <> 0 ) then
                                        backdated_transactions := true;
                                        commit_complete := false;
                                        goto procedure_end_label;
                                end if;
                                close back_dated_lcadj_cur;



                        end if;

                end if;

        END LOOP;

        close all_cost_groups_cur;

        /* **********section to check AP periods **************** */
        l_stmt_num := 50;
        count_rows := 0;
        open ap_period_open_cur( l_entity_id, l_cost_type_id, closing_end_date);
        fetch ap_period_open_cur into count_rows;
        if(count_rows <> 0 ) then
                l_err_msg := l_err_msg || 'I am Here';
               ap_period_open := true;
               commit_complete := false;
               goto procedure_end_label;
        end if;
        close ap_period_open_cur;

<<check_ar_label>>
    /* ********** Perform validations for Revenue / COGS Matching *********** */
    l_stmt_num := 60;
    -- First get the ledger ID for this legal entity
    SELECT distinct clct.set_of_books_id,
           nvl(clct.create_acct_entries,'N')
    INTO   l_ledger_id,
           l_create_acct_entries
    FROM   cst_le_cost_types clct
    WHERE  clct.cost_type_id = l_cost_type_id
    AND    clct.legal_entity = l_entity_id;

    -- If the create_acct_entries field is not YES for this LE/CT, there is
    -- no need to perform any of the Revenue / COGS validations.

    IF (l_create_acct_entries = 'N') THEN
       goto procedure_end_label;
    END IF;


/* ********** check the AR period **************** */
    -- FP Bug 8563354 fix: Perform AR period validation only
    -- if there is atleast 1 SO txn or 1 RMA txn in any of the
    -- inventory organizations across cost groups belongs to
    -- PAC legal entity
    -- Because, it is possible to have deferred COGS/deferred revenue
    -- for the past pac periods

    l_stmt_num := 62;
    OPEN cur_so_txn(l_entity_id);

    FETCH cur_so_txn
     INTO l_so_txn_flag;

     IF cur_so_txn%FOUND THEN
       l_so_txn_flag := 'Y';
     ELSE
       l_so_txn_flag := 'N';
     END IF;

    CLOSE cur_so_txn;

    IF (l_sLog) THEN
        FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                       l_module || '.sotxn',
                       'SO Transaction Flag:' || l_so_txn_flag
                       );
    END IF;

    l_stmt_num := 65;
    -- Sales Order txn or RMA txn exists
    IF l_so_txn_flag = 'Y' then
      -- AR Period must be Closed (C) or permanently closed (P)
      -- since SO or RMA txn exists

      -- Get the effective period number to pass to the AR procedure
      -- FP Bug 8563354 fix: application_id is 222 for AR
      -- changed application_id from 101 (GL) to 222 (AR)
      SELECT gps.effective_period_num
        INTO l_effective_period_num
        FROM gl_period_statuses gps
       WHERE gps.ledger_id = l_ledger_id
         AND gps.application_id = 222
         AND gps.adjustment_period_flag = 'N' -- Added for bug#4634513
         AND trunc(closing_end_date) BETWEEN gps.start_date AND gps.end_date;


    l_stmt_num := 80;
    -- Call AR's API to find out if the period is closed
    ar_match_rev_cogs_grp.period_status(
                 p_api_version => 1.0,
                 p_eff_period_num => l_effective_period_num,
                 p_sob_id => l_ledger_id,
                 x_status => l_ar_period_status,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data
                 );

    l_stmt_num := 85;
       IF (l_sLog) THEN
          FND_LOG.STRING (FND_LOG.LEVEL_STATEMENT,
                         l_module || '.revcg',
                         'AR Period Status:' || l_ar_period_status ||
		         ' Effective period Num:' || l_effective_period_num
                         );
       END IF;


    -- AR Period is closed(C) OR permanently closed(P),
      -- then perform validations for Load revenue recognition events
      -- and generate COGS concurrent request
      IF (l_ar_period_status = 'C' OR l_ar_period_status = 'P') THEN
        /* check whether phase 2 of the Generate COGS concurrent request has been run for this period */
        -- Phases 2 and 3 of the concurrent request to generate COGS recognition events must be run before
        -- closing the PAC period because those phases may generate events that need to be processed in
        -- this PAC period.  The check for phase 1 is not necessary since the perpetual cost processor
        -- would have taken care of that phase for this period, and we already have a check that the
        -- perpetual period is closed.

        -- If the last process date of phase 2 is less than the period close date, then it still needs
        -- to be run for this period to load revenue recognition events into CRRL.
        l_stmt_num := 90;

--{ BUG#8678956
         check_rev_info_run
          (p_closing_date        => closing_end_date
          ,p_ledger_id           => l_ledger_id
          ,x_current_upto_date   => x_current_upto_date
          ,x_exist               => x_exist
          ,x_required            => x_required);

           IF (l_pLog) THEN
                FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                    'check_rev_info_run',
                    'p_ledger_id:'||l_ledger_id||',closing_end_date:'||closing_end_date||
                    ',x_current_upto_date:'||x_current_upto_date||',x_exist:'||x_exist||
		            ',x_required:'||x_required);
           END IF;
--        SELECT count(1)
--          INTO l_phase2_required
--          FROM cst_revenue_cogs_control
--         WHERE
--            control_id = 1
--           AND   last_process_upto_date < closing_end_date
--           AND   rownum < 2;
--        IF (l_phase2_required > 0) THEN
--          cogsgen_phase2_notrun := true;
--          commit_complete := false;
--          goto procedure_end_label;
--        END IF;
--
        IF (x_required = 'Y') THEN
          cogsgen_phase2_notrun := true;
          commit_complete := false;
          goto procedure_end_label;
        END IF;
--}
        -- If there are any rows in CRRL that may lead to a potential mismatch between revenue and
        -- COGS for all organizations in this cost group, then we cannot close the period until
        -- those unmatched rows in CRRL get matching events created in CCE via phase 3 of the
        -- Generate COGS Recognition Events concurrent request.
        l_stmt_num := 100;
        SELECT min(crrl.acct_period_num)
          INTO l_phase3_required
          FROM cst_revenue_recognition_lines crrl,
               cst_revenue_cogs_match_lines crcml,
               cst_cost_group_assignments ccga,
               cst_cost_groups ccg
         WHERE crrl.ledger_id = l_ledger_id
           AND crrl.potentially_unmatched_flag = 'Y'
           AND crrl.revenue_om_line_id = crcml.revenue_om_line_id
           AND crcml.organization_id = ccga.organization_id
           AND ccga.cost_group_id = ccg.cost_group_id
           AND ccg.legal_entity = l_entity_id
           AND ccg.cost_group_type = 2
           AND NVL(ccg.disable_date, sysdate) >= sysdate;

        IF (l_phase3_required IS NOT NULL) THEN
          cogsgen_phase3_notrun := true;
          commit_complete := false;
          goto procedure_end_label;
        END IF;

      ELSE
        ar_period_open := true;
        commit_complete := false;
      END IF; -- AR period status check

    END IF; -- SO or RMA txn check

    <<procedure_end_label>>
    NULL;

  IF (l_pLog) THEN
   FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                   l_module || '.end',
                   l_api_name || ' >>>');
  END IF;

  EXCEPTION
        when OTHERS then
             IF (l_uLog) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                   l_module || '.' || l_stmt_num,
                                   SQLERRM);
             END IF;
             rollback;
             user_defined_error := true;
             commit_complete    := false;

END validate_close_period;


PROCEDURE close_period (
                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                closing_pac_period_id           IN      NUMBER,
                                closing_period_type             IN      VARCHAR2,
                                closing_end_date                IN      DATE,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,

                                last_scheduled_close_date       IN OUT NOCOPY   DATE,
                                end_date_is_passed              OUT NOCOPY     BOOLEAN,
                                incomplete_processing           OUT NOCOPY     BOOLEAN,
                                pending_transactions            OUT NOCOPY      BOOLEAN,
                                rerun_processor                 OUT NOCOPY      BOOLEAN,
                                prompt_to_reclose               OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
                                backdated_transactions          OUT NOCOPY     BOOLEAN,
                                perpetual_periods_open          OUT NOCOPY     BOOLEAN,
                                ap_period_open                  OUT NOCOPY      BOOLEAN,
                                ar_period_open                  OUT NOCOPY      BOOLEAN,
				cogsgen_phase2_notrun		OUT NOCOPY	BOOLEAN,
				cogsgen_phase3_notrun		OUT NOCOPY	BOOLEAN,
                                user_defined_error              OUT NOCOPY     BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN,
                                req_id                          OUT NOCOPY      NUMBER
                        ) IS


/* **************************************************************************** */
/* This section declares all the local variable for the close procedure         */
/* **************************************************************************** */

        dummy_id                NUMBER;
        no_cost_groups          NUMBER;
        current_cost_group_id   NUMBER;
        no_cost_groups_available BOOLEAN;
        count_rows              NUMBER;
        rerun_process_date      DATE;
        l_err_num               NUMBER;
        l_err_code              VARCHAR2(240);
        l_err_msg               VARCHAR2(240);
        l_open_flag             VARCHAR2(1);

        l_stmt_num              NUMBER;

        l_api_name            CONSTANT VARCHAR2(30) := 'close_period';
        l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
        l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

        l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
        l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
        l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
        l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
        l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
        l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

 IF (l_pLog) THEN
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       l_module || '.begin',
                       l_api_name || ' <<< Parameters:
                       l_entity_id  = ' || l_entity_id || '
                       l_cost_type_id = ' || l_cost_type_id || '
                       closing_pac_period_id = ' || closing_pac_period_id || '
                       closing_period_type = ' || closing_period_type || '
                       closing_end_date = ' || closing_end_date ||'
                       last_scheduled_close_date = ' || last_scheduled_close_date);
 END IF;

/* **************************************************************************** */
/* This section initializes all local and OUT Params of the close procedure     */
/* **************************************************************************** */
        l_stmt_num := 0;
        dummy_id                := 0;
        end_date_is_passed      := false;
        prompt_to_reclose       := false;
        incomplete_processing   := false;
        pending_transactions    := false;
        current_cost_group_id   := 0;
        no_cost_groups          := 0;
        undefined_cost_groups   := false;
        backdated_transactions  := false;
        perpetual_periods_open  := false;
        ap_period_open          := false;
        ar_period_open          := false;
        cogsgen_phase2_notrun := false;
        cogsgen_phase3_notrun := false;
        user_defined_error      := false;
        rerun_processor         := false;
        commit_complete         := false;
        no_cost_groups_available:= false;
        count_rows              := 0;
        rerun_process_date      := trunc(closing_end_date) +1;
        l_err_num               := 0;
        l_err_code              := NULL;
        l_err_msg               := NULL;



        CSTPPPSC.validate_close_period
                        (       l_entity_id,
                                l_cost_type_id,
                                closing_pac_period_id,
                                closing_period_type,
                                closing_end_date,
                                l_user_id,
                                l_login_id,
                                last_scheduled_close_date,
                                end_date_is_passed,
                                incomplete_processing,
                                pending_transactions,
                                rerun_processor,
                                prompt_to_reclose,
                                undefined_cost_groups,
                                backdated_transactions,
                                perpetual_periods_open,
                                ap_period_open,
                                ar_period_open,
                cogsgen_phase2_notrun,
                cogsgen_phase3_notrun,
                                user_defined_error,
                                commit_complete
                        );

        l_stmt_num := 10;
        IF( (end_date_is_passed  )      OR
            (incomplete_processing)     OR
            (pending_transactions )     OR
            (rerun_processor )          OR
            (prompt_to_reclose)         OR
            (undefined_cost_groups )    OR
            (backdated_transactions)    OR
            (perpetual_periods_open)    OR
            (ap_period_open )           OR
            (ar_period_open )           OR
        (cogsgen_phase2_notrun) OR
        (cogsgen_phase3_notrun) OR
            (user_defined_error )    )  THEN

                commit_complete := false;
                goto procedure_end_label;
        END IF;

        l_stmt_num := 20;
        req_id := FND_REQUEST.submit_request('BOM',
                                        'CSTPPPSC',
                                        NULL,
                                        NULL,
                                        FALSE,
                                        l_entity_id,
                                        l_cost_type_id,
                                        closing_pac_period_id,
                                        closing_period_type,
                                        fnd_date.date_to_canonical(closing_end_date),
                                        l_user_id,
                                        l_login_id,
                                        fnd_date.date_to_canonical(last_scheduled_close_date)
                                        );

        if (req_id =  0) then
                commit_complete := false;
                goto error_label;
        else
        /* Change the period status to pending by changing the open_flag = 'P' */

                COMMIT;
                l_stmt_num := 30;
                l_open_flag := 'P';
                UPDATE  cst_pac_periods
                SET     open_flag               = l_open_flag,
                        period_close_date       = trunc(sysdate),
                        last_update_date        = trunc(sysdate),
                        last_updated_by         = l_user_id,
                        last_update_login       = l_login_id
                WHERE   pac_period_id = closing_pac_period_id;

                COMMIT;
                goto procedure_end_label;
        end if;

        <<error_label>>
        commit_complete := false;


        <<procedure_end_label>>
        NULL;

        IF (l_pLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                            l_module || '.end',
                            l_api_name || ' >>>');
        END IF;

        EXCEPTION
                when OTHERS then
                     IF (l_uLog) THEN
                        FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                       l_module || '.' || l_stmt_num,
                                       SQLERRM);
                     END IF;
                     rollback;
                     user_defined_error := true;
                     commit_complete := false;


END close_period;


PROCEDURE api_close_period(
                                errbuf                          OUT NOCOPY     VARCHAR2,
                                retcode                         OUT NOCOPY     NUMBER,
                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                closing_pac_period_id           IN      NUMBER,
                                closing_period_type             IN      VARCHAR2,
                                l_closing_end_date              IN      VARCHAR2,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,
                                l_last_scheduled_close_date     IN      VARCHAR2
                                ) IS

/* **************************************************************************** */
/* Cursor for all cost groups defined in the legal entity                       */
/* **************************************************************************** */
        CURSOR all_cost_groups_cur IS
                select  cost_group_id
                from    cst_cost_groups ccg
                where   ccg.legal_entity = l_entity_id
                and     ccg.cost_group_type = 2
                and     NVL(ccg.disable_date, sysdate) >= sysdate
                and     ccg.cost_group_id IN    (
                                SELECT  distinct cost_group_id
                                FROM    cst_cost_group_assignments
                                WHERE   legal_entity = l_entity_id );

/* **************************************************************************** */
/* Cursor to check whether the period is still open to be closed                */
/* **************************************************************************** */

        CURSOR check_still_open_to_close_cur IS
                SELECT  pac_period_id
                FROM    cst_pac_periods
                WHERE   legal_entity            = l_entity_id
                AND     cost_type_id            = l_cost_type_id
                AND     pac_period_id           = closing_pac_period_id
                AND     open_flag               = 'P';



        no_cost_groups                  NUMBER;
        no_cost_groups_available        BOOLEAN;
        current_cost_group_id           NUMBER;
        l_err_num                       NUMBER;
        l_err_code                      VARCHAR2(2000);
        l_err_msg                       VARCHAR2(2000);
        prompt_to_reclose               BOOLEAN;
        dummy_id                        NUMBER;
        last_scheduled_close_date       DATE;
        closing_end_date                DATE;
        conc_status                     BOOLEAN;
        distributions_flag              VARCHAR2(1);
        l_open_flag                     VARCHAR2(1);


l_stmt_num            NUMBER;

l_api_name            CONSTANT VARCHAR2(30) := 'api_close_period';
l_full_name           CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_module              CONSTANT VARCHAR2(60) := 'cst.plsql.' || l_full_name;

l_uLog  CONSTANT BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL AND FND_LOG.TEST (FND_LOG.LEVEL_UNEXPECTED, l_module);
l_errorLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
l_eventLog CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
l_pLog CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
l_sLog CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

 IF (l_pLog) THEN
    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                       l_module || '.begin',
                       l_api_name || ' <<< Parameters:
                       l_entity_id  = ' || l_entity_id || '
                       l_cost_type_id = ' || l_cost_type_id || '
                       closing_pac_period_id = ' || closing_pac_period_id || '
                       closing_period_type = ' || closing_period_type || '
                       l_closing_end_date = ' || l_closing_end_date || '
                       l_last_scheduled_close_date = ' || l_last_scheduled_close_date);
 END IF;


/* **************************************************************************** */
/* This section is to create distribution entries while period close            */
/* **************************************************************************** */
        l_stmt_num  := 0;
        no_cost_groups := 0;
        no_cost_groups_available := true;
        current_cost_group_id   := 0;
        l_err_num               := 0;
        l_err_code              := NULL;
        l_err_msg               := NULL;
        prompt_to_reclose       := false;
        dummy_id                := 0;
        last_scheduled_close_date := fnd_date.canonical_to_date(l_last_scheduled_close_date);
        closing_end_date := fnd_date.canonical_to_date(l_closing_end_date);

        FND_MESSAGE.set_name('BOM', 'CST_BEGIN_PERIOD_END');
        l_err_msg := FND_MESSAGE.Get;
        fnd_file.put_line(fnd_file.log,l_err_msg);

        l_stmt_num  := 10;
        open all_cost_groups_cur;

        LOOP
                current_cost_group_id := 0;
                fetch all_cost_groups_cur into current_cost_group_id;
                if ( all_cost_groups_cur%NOTFOUND) then
                                goto check_duplicating_label;
                end if;

                no_cost_groups_available := false;
                no_cost_groups := no_cost_groups + 1;

        l_stmt_num  := 20;
        SELECT  NVL(CREATE_ACCT_ENTRIES,'N')
        INTO    distributions_flag
        FROM    CST_LE_COST_TYPES
        WHERE   LEGAL_ENTITY    = l_entity_id
        AND     COST_TYPE_ID    = l_cost_type_id
        AND     PRIMARY_COST_METHOD > 2;

        if (distributions_flag = 'Y') then

          /* Call the period end process only if accounting is turned on */
          l_stmt_num  := 30;
          CSTPDPPC.dist_processor_main(
          errbuf => l_err_code,
          retcode => l_err_num,
          i_mode => 1,
          i_period_id => closing_pac_period_id,
          i_cost_type_id => l_cost_type_id,
          i_cost_group_id => current_cost_group_id,
          i_legal_entity => l_entity_id);

          fnd_file.put_line(fnd_file.log,' ');

          if (l_err_num <> 0) then
                  goto error_label;
          end if;

        end if;

    END LOOP;

    close  all_cost_groups_cur;


/* **************************************************************************** */
/* This section check whether another user is trying to close the same period   */
/* simultaneously.                                                              */
/*      IF yes => prompt_to_reclose = TRUE                                      */
/*      IF no  => prompt_to_reclose = FALSE                                     */
/* **************************************************************************** */


        <<check_duplicating_label>>


        l_stmt_num  := 40;
        open check_still_open_to_close_cur;
        fetch  check_still_open_to_close_cur into dummy_id;
        if (  check_still_open_to_close_cur%FOUND ) then
                prompt_to_reclose       := false;
        else
                prompt_to_reclose       := true;
                goto error_label;
        end if;
        close  check_still_open_to_close_cur;


/* **************************************************************************** */
/* Declare the period closed by updating the following...                       */
/*              open_flag = 'N' and period_close_date = SYSDATE                 */
/* **************************************************************************** */

        /* Close the period by updating the open flag to 'N' */
        l_stmt_num  := 50;
        l_open_flag  := 'N';
        UPDATE  cst_pac_periods
        SET     open_flag               = l_open_flag,
                period_close_date       = trunc(sysdate),
                last_update_date        = trunc(sysdate),
                last_updated_by         = l_user_id,
                last_update_login       = l_login_id
        WHERE   pac_period_id = closing_pac_period_id;

        <<sucess_label>>
        commit;
        FND_MESSAGE.set_name('BOM', 'CST_PERIOD_END_SUCCESS');
        l_err_msg := FND_MESSAGE.Get;
        fnd_file.put_line(fnd_file.log,l_err_msg);

        goto procedure_end_label;

        <<error_label>>
        ROLLBACK;
        l_stmt_num  := 60;
        UPDATE  cst_pac_periods
        SET     open_flag               = 'Y',
                period_close_date       = trunc(sysdate),
                last_update_date        = trunc(sysdate),
                last_updated_by         = l_user_id,
                last_update_login       = l_login_id
        WHERE   pac_period_id = closing_pac_period_id;

        COMMIT;
        conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);

        FND_MESSAGE.set_name('BOM', 'CST_PERIOD_END_FAILURE');
        l_err_msg := FND_MESSAGE.Get;
        fnd_file.put_line(fnd_file.log,l_err_msg);


        <<procedure_end_label>>
        NULL;

        IF (l_pLog) THEN
            FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE,
                            l_module || '.end',
                            l_api_name || ' >>>');
        END IF;


        EXCEPTION
                when OTHERS then
                IF (l_uLog) THEN
                   FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED,
                                  l_module || '.' || l_stmt_num,
                                  SQLERRM);
                END IF;

                ROLLBACK;
                UPDATE  cst_pac_periods
                SET     open_flag               = 'Y',
                        period_close_date       = trunc(sysdate),
                        last_update_date        = trunc(sysdate),
                        last_updated_by         = l_user_id,
                        last_update_login       = l_login_id
                WHERE   pac_period_id = closing_pac_period_id;

                COMMIT;

                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
                FND_MESSAGE.set_name('BOM', 'CST_PERIOD_END_SUCCESS');
                l_err_msg := FND_MESSAGE.Get;
                fnd_file.put_line(fnd_file.log,l_err_msg);


END api_close_period;



END CSTPPPSC;

/
