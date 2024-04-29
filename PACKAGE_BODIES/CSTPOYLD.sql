--------------------------------------------------------
--  DDL for Package Body CSTPOYLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPOYLD" AS
/* $Header: CSTOYLDB.pls 120.10 2006/08/28 05:49:29 rajagraw noship $ */

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   process_op_yield                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to calculate operation yield for lot based jobs.  --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_entity_id    : Wip entity id of lot based job             --
--            i_run_option   : 1 if it is called from standard cost       --
--                             processor and split merge cost processor   --
--                             for txn type Split or Merge                --
--                             2 if is called from standard cost update   --
--                             3 if it is called from split merge cost    --
--                             processor with txn type bonus and update   --
--                             quanitty.                                  --
--            i_txn_op_seq_num :Operation sequence number for bonus and   --
--                              update quantity txn number.               --
--            i_range_option : 1 if it is to run for an organization      --
--                             2 if it is to run for a WIP entity         --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE  process_op_yield(ERRBUF             OUT NOCOPY VARCHAR2,
                            RETCODE            OUT NOCOPY VARCHAR2,
                            i_range_option         NUMBER,
                            i_entity_id            NUMBER,
                            i_run_option           NUMBER,
                            i_txn_op_seq_num       NUMBER,
                            i_organization_id      NUMBER,
                            i_sm_txn_id            NUMBER) IS


x_err_num                        NUMBER;
x_err_msg                        VARCHAR2(200);
x_statement                      NUMBER := 0;
x_status                         boolean;
x_organization_id                NUMBER := 0;
x_acct_period_id                 NUMBER := 0;
x_starting_opseq                 NUMBER := 0;
x_first_operation                BOOLEAN;
x_op_unit_cost		         NUMBER	:= 0;
x_unit_cost                      NUMBER := 0;
x_est_scrap_per_unit		 NUMBER	:= 0;
x_net_absorption                 NUMBER := 0;
x_cum_pr_est_scp_per_unit	 NUMBER	:= 0;
x_abs_account                    NUMBER;
x_net_reversal                   NUMBER := 0;
x_transaction_id                 NUMBER := 0;
x_tl_scrap_in		         NUMBER	:= 0;
x_tl_scrap_out		         NUMBER	:= 0;
x_currency_code                  VARCHAR2(15);
x_precision                      NUMBER := 0;
x_ext_precision                  NUMBER := 0;
x_min_acct_unit		         NUMBER	:= 0;
x_last_updated_by                NUMBER(15);
x_last_update_login              NUMBER(15);
x_request_id                     NUMBER(15);
x_program_application_id         NUMBER(15);
x_program_id                     NUMBER(15);
x_sysdate                        DATE;
x_save_point                     VARCHAR2(30);
x_count                          NUMBER;
x_last_opseq_num		 NUMBER;
x_wsm_enabled_flag               VARCHAR2(1);
ACCOUNTS_NOT_DEFINED		 EXCEPTION;
l_debug				 VARCHAR2(80);
l_scrap_acct			 NUMBER;
l_scrap_rev_acct		 NUMBER;
l_est_scrap_abs_acct		 NUMBER;
temp_wip_entity_id		 NUMBER := 0;
l_uom                            VARCHAR2(3);
l_legal_entity_date              DATE;
l_operating_unit                 NUMBER;
l_transaction_date               DATE; /* Bug 4757384 */

/* SLA Event Seeding */
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_trx_info           CST_XLA_PVT.t_xla_wip_trx_info;
l_inv_trx_info       CST_XLA_PVT.t_xla_inv_trx_info;

/* Changes for Optional Scrap */
x_est_scrap_acct_flag		NUMBER := 0;
WSM_ESA_PKG_ERROR      		EXCEPTION;
EST_ACCT_NOT_FOUND		EXCEPTION;

CURSOR c_wip_entity IS
       SELECT woy.wip_entity_id          wip_entity_id,
              woy.organization_id        organization_id,
              MIN(woy.operation_seq_num) starting_op_seq,
              WDJ.EST_SCRAP_ACCOUNT      est_scrap_account,
              WDJ.EST_SCRAP_VAR_ACCOUNT  est_scrap_var_account,
              WDJ.PRIMARY_ITEM_ID        primary_item_id
       FROM   wip_operation_yields woy, wip_discrete_jobs wdj
       WHERE  woy.status IN (1, 3)
       AND    woy.wip_entity_id   = DECODE(NVL(i_entity_id, 0), 0, woy.wip_entity_id, i_entity_id)
       AND    woy.organization_id = DECODE(NVL(i_organization_id, 0), 0, woy.organization_id, i_organization_id)
       AND    WDJ.WIP_ENTITY_ID   = WOY.WIP_ENTITY_ID
       AND    WDJ.ORGANIZATION_ID = WOY.ORGANIZATION_ID
       AND    WDJ.STATUS_TYPE     IN ( 3,4,5,6,7,15  )
       GROUP BY woy.wip_entity_id, woy.organization_id,
                wdj.est_scrap_account, wdj.est_scrap_var_account,
                wdj.primary_item_id
       ORDER BY woy.wip_entity_id;


/* Bug #1554288, the check for wo.quantity_completed > 0 has been commented,
   so that Operation Yield processor is able to reverse scrap absorption for
   undo transactions. This fix however, causes a cumulative value to be
   inserted against the last operation_seq_num in wip_operation_yields table.
   Please note that it does not cause any valuation mismatch, and is not
   a cause for concern, until now */

CURSOR c_opseq(p_entity_id NUMBER, p_starting_opseq NUMBER, p_organization_id NUMBER) IS
       SELECT WOY.OPERATION_SEQ_NUM,
              NVL(WOY.OPERATION_COST, 0)          OPERATION_COST,
              NVL(WOY.OPERATION_UNIT_COST, 0)     OPERATION_UNIT_COST,
              NVL(WOY.CUM_OPERATION_UNIT_COST, 0) CUM_OPERATION_UNIT_COST ,
              NVL(WOY.EST_SCRAP_UNIT_COST, 0)     EST_SCRAP_UNIT_COST,
              NVL(WOY.CUM_EST_PRIOR_UNIT_COST, 0) CUM_EST_PRIOR_UNIT_COST,
              NVL(WOY.EST_SCRAP_QTY_COMPLETED, 0) EST_SCRAP_QTY_COMPLETED,
              NVL(WOY.EST_SCRAP_QTY_SCRAPED, 0)   EST_SCRAP_QTY_SCRAPED,
              WOY.SCRAP_ACCOUNT,
              WOY.EST_SCRAP_ABSORB_ACCOUNT,
              WOY.STATUS,
              NVL(WO.WSM_COSTED_QUANTITY_COMPLETED, NVL(WO.QUANTITY_COMPLETED, 0)) QUANTITY_COMPLETED,
              NVL(WO.QUANTITY_SCRAPPED, 0) QUANTITY_SCRAPPED,
              DECODE (WO.OPERATION_YIELD_ENABLED, 1, NVL(WO.OPERATION_YIELD, 1),
              1) OPERATION_YIELD,
              NVL(WO.DEPARTMENT_ID, 0) DEPARTMENT_ID,
	      WO.DISABLE_DATE DISABLE_DATE
        FROM  WIP_OPERATION_YIELDS WOY,
              WIP_OPERATIONS WO
        WHERE WOY.WIP_ENTITY_ID      = p_entity_id
          AND WOY.OPERATION_SEQ_NUM >= p_starting_opseq
          AND WO.WIP_ENTITY_ID       = WOY.WIP_ENTITY_ID
          AND WO.OPERATION_SEQ_NUM   = WOY.OPERATION_SEQ_NUM
          AND WO.ORGANIZATION_ID     = WOY.ORGANIZATION_ID
          AND WOY.ORGANIZATION_ID    = p_organization_id
     ORDER BY WOY.OPERATION_SEQ_NUM

     FOR UPDATE OF woy.status;


BEGIN
             ---------------------------------------------------------
             --       Get profile value for debug                   --
             ---------------------------------------------------------
    x_statement := 05;
    l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

             ---------------------------------------------------------
             -- Get Values of WHO Columns                           --
             ---------------------------------------------------------
    x_statement := 10;

    x_last_updated_by := fnd_global.user_id;
    x_last_update_login := fnd_global.login_id;
    x_request_id := fnd_global.conc_request_id;
    x_program_application_id := fnd_global.prog_appl_id;
    x_program_id  := fnd_global.conc_program_id;
    x_sysdate     := SYSDATE;

    IF(l_debug = 'Y') THEN
      FND_FILE.put_line(fnd_file.log, 'PROCESS_OP_YIELD <<< ');
      FND_FILE.put_line(FND_FILE.LOG,'P_ENTITY_ID : '||to_char(i_entity_id));
      FND_FILE.put_line(FND_FILE.LOG,'P_ORGANIZATION_ID: '|| to_char(i_organization_id));
    END IF;

             ---------------------------------------------------------
             -- Open wip_entity_id Cursor                          --
             ---------------------------------------------------------
   <<wip_entity>>

    FOR rec_wip_entity IN c_wip_entity LOOP
      IF(l_debug = 'Y') THEN
        FND_FILE.put_line(FND_FILE.LOG, 'REC_WIP_ENTITY.WIP_ENTITY_ID: '|| to_char(rec_wip_entity.wip_entity_id));
      END IF;

      /* Initialize Absorptions */
      x_tl_scrap_in  := 0;
      x_tl_scrap_out := 0;

      /* Changes for Optional Scrap */
      x_statement := 15;
      temp_wip_entity_id := rec_wip_entity.wip_entity_id;
      x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(rec_wip_entity.wip_entity_id, x_err_num, x_err_msg);
      IF (x_est_scrap_acct_flag = 0) THEN
	RAISE WSM_ESA_PKG_ERROR;
      END IF;

      /* Do Operation Yield Accounting only if ESA is enabled */
      IF x_est_scrap_acct_flag = 1 THEN
        if (l_debug = 'Y') then
          fnd_file.put_line(fnd_file.log, 'WIP ENTITY ID : '||to_char(rec_wip_entity.wip_entity_id));
          fnd_file.put_line(fnd_file.log, 'ORG ID : '||to_char(rec_wip_entity.organization_id));
        end if;

             ---------------------------------------------------------
             -- Get Currency Information                            --
             ---------------------------------------------------------
        IF (x_organization_id <> rec_wip_entity.organization_id) THEN
          x_organization_id := rec_wip_entity.organization_id;


             ---------------------------------------------------------
             -- Get Currency Code for Organization                  --
             ---------------------------------------------------------
          x_statement := 20;

          SELECT COD.CURRENCY_CODE, COD.OPERATING_UNIT
          INTO x_currency_code, l_operating_unit
          FROM CST_ORGANIZATION_DEFINITIONS COD
          WHERE COD.ORGANIZATION_ID = rec_wip_entity.organization_id;


          x_statement := 30;

          fnd_currency.get_info( x_currency_code,
                              x_precision,
                              x_ext_precision,
                              x_min_acct_unit);


             ---------------------------------------------------------
             -- Get Accounting Period Information                   --
             ---------------------------------------------------------
          x_statement := 38;
          l_legal_entity_date := INV_LE_TIMEZONE_PUB.GET_LE_SYSDATE_FOR_OU(l_operating_unit);

          x_statement := 40;
          BEGIN
       		SELECT acct_period_id
         	INTO x_acct_period_id
         	FROM org_acct_periods
        	WHERE organization_id = x_organization_id
          	AND l_legal_entity_date BETWEEN period_start_date AND schedule_close_date;
          EXCEPTION
            when NO_DATA_FOUND then
              fnd_file.put_line(fnd_file.log,'Accounting period is not open for the organization: ' || to_char(x_organization_id));
          END;

          if (l_debug = 'Y') then
      	    fnd_file.put_line(fnd_file.log, 'ACCT PERIOD ID : '||to_char( x_acct_period_id ));
          end if;

        END IF;  /* (x_organization_id <> rec_wip_entity.organization_id) */

             ---------------------------------------------------------
             -- Get Starting Operation Sequence Number              --
             ---------------------------------------------------------

        x_statement := 50;
        x_starting_opseq := rec_wip_entity.starting_op_seq;

        x_first_operation := TRUE;


             ---------------------------------------------------------
             -- Open Operation Sequence Cursor                      --
             ---------------------------------------------------------

        x_save_point := 'sv'||to_char(rec_wip_entity.wip_entity_id);
        SAVEPOINT x_save_point;
 <<opseq>>

        FOR rec_opseq IN c_opseq (rec_wip_entity.wip_entity_id, x_starting_opseq, x_organization_id) LOOP

	BEGIN


          /* Changes for Optional Scrap. To take care of case when the
           ESA flag is toggled between when the job is created and
           Released or between when the job is closed and unclosed. */

          IF(rec_opseq.SCRAP_ACCOUNT IS NULL OR
	     rec_opseq.EST_SCRAP_ABSORB_ACCOUNT IS NULL) THEN

	    x_statement := 55;
	    SELECT bd.scrap_account,bd.est_absorption_account
            INTO l_scrap_acct, l_est_scrap_abs_acct
            FROM bom_departments bd, wip_operations wo
            WHERE wo.operation_seq_num = rec_opseq.operation_seq_num
            AND wo.wip_entity_id = rec_wip_entity.wip_entity_id
	    AND wo.organization_id = rec_wip_entity.organization_id
            AND bd.department_id = wo.department_id
	    AND bd.organization_id = wo.organization_id;


	    IF l_scrap_acct IS NULL OR l_est_scrap_abs_acct IS NULL THEN
	      RAISE EST_ACCT_NOT_FOUND;
	    END IF;

	    x_statement := 60;
	    UPDATE wip_operation_yields woy
	    SET SCRAP_ACCOUNT = l_scrap_acct,
		EST_SCRAP_ABSORB_ACCOUNT = l_est_scrap_abs_acct
            WHERE woy.operation_seq_num  = rec_opseq.operation_seq_num
	    AND woy.wip_entity_id = rec_wip_entity.wip_entity_id
	    AND woy.organization_id = rec_wip_entity.organization_id;
	  ELSE
	    l_scrap_acct := rec_opseq.SCRAP_ACCOUNT;
	    l_est_scrap_abs_acct := rec_opseq.EST_SCRAP_ABSORB_ACCOUNT;

	  END IF;

	  /* Bug #4045115. Call client extension to override the scrap account. */
	  l_scrap_rev_acct := CSTPSCHK.std_get_est_scrap_rev_acct_id(
					i_org_id 	=> rec_wip_entity.organization_id,
					i_wip_entity_id	=> rec_wip_entity.wip_entity_id,
					i_operation_seq_num => rec_opseq.operation_seq_num);

	  if(l_scrap_rev_acct = -1) then
		l_scrap_rev_acct := l_scrap_acct;
	  end if;

          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log, 'EST_SCRAP_ACCOUNT : '||to_char(REC_WIP_ENTITY.EST_SCRAP_ACCOUNT ));
            fnd_file.put_line(fnd_file.log, 'EST_SCRAP_VAR_ACCOUNT : '||to_char(REC_WIP_ENTITY.EST_SCRAP_VAR_ACCOUNT ));
            fnd_file.put_line(fnd_file.log, 'OPERATION_SEQ_NUM : '||to_char(REC_OPSEQ.OPERATION_SEQ_NUM ));
            fnd_file.put_line(fnd_file.log, 'OPERATION_COST : '||to_char(REC_OPSEQ.OPERATION_COST ));
            fnd_file.put_line(fnd_file.log, 'OPERATION_UNIT_COST : '||to_char(REC_OPSEQ.OPERATION_UNIT_COST ));
            fnd_file.put_line(fnd_file.log, 'CUM_OPERATION_UNIT_COST : '||to_char(REC_OPSEQ.CUM_OPERATION_UNIT_COST ));
            fnd_file.put_line(fnd_file.log, 'EST_SCRAP_UNIT_COST : '||to_char(REC_OPSEQ.EST_SCRAP_UNIT_COST ));
            fnd_file.put_line(fnd_file.log, 'CUM_EST_PRIOR_UNIT_COST : '||to_char(REC_OPSEQ.CUM_EST_PRIOR_UNIT_COST ));
            fnd_file.put_line(fnd_file.log, 'EST_SCRAP_QTY_COMPLETED : '||to_char(REC_OPSEQ.EST_SCRAP_QTY_COMPLETED ));
            fnd_file.put_line(fnd_file.log, 'EST_SCRAP_QTY_SCRAPED : '||to_char(REC_OPSEQ.EST_SCRAP_QTY_SCRAPED ));
            fnd_file.put_line(fnd_file.log, 'SCRAP_ACCOUNT : '||to_char(l_scrap_acct ));
            fnd_file.put_line(fnd_file.log, 'NET_REV_ACCT : '||to_char(l_scrap_rev_acct ));

            fnd_file.put_line(fnd_file.log, 'EST_SCRAP_ABSORB_ACCOUNT : '||to_char(l_est_scrap_abs_acct ));
            fnd_file.put_line(fnd_file.log, 'STATUS : '||to_char(REC_OPSEQ.STATUS ));
            fnd_file.put_line(fnd_file.log, 'QUANTITY_COMPLETED : '||to_char(REC_OPSEQ.QUANTITY_COMPLETED ));
            fnd_file.put_line(fnd_file.log, 'QUANTITY_SCRAPPED : '||to_char(REC_OPSEQ.QUANTITY_SCRAPPED ));
            fnd_file.put_line(fnd_file.log, 'OPERATION_YIELD : '||to_char(REC_OPSEQ.OPERATION_YIELD ));
            fnd_file.put_line(fnd_file.log, 'DEPARTMENT_ID : '||to_char(REC_OPSEQ.DEPARTMENT_ID ));
          end if;
             ---------------------------------------------------------
             -- Initialize Parameters if first operation of job     --
             ---------------------------------------------------------
          If x_first_operation THEN

            /* Bug 4599116 - Added the join with WIP_OPERATIONS table to avoid the
                 operations that are obsoleted due to undo move or
                 update assembly transactions. The obsoleted operation is determined
                by a valid disable date */

            x_statement := 200;
            SELECT count(*)
            INTO x_count
            FROM WIP_OPERATION_YIELDS woy,
                 WIP_OPERATIONS wo
            WHERE woy.wip_entity_id = rec_wip_entity.wip_entity_id
            and wo.wip_entity_id =  woy.wip_entity_id
            and woy.organization_id = x_organization_id
            and wo.organization_id = x_organization_id
            and woy.operation_seq_num = wo.operation_seq_num
            and woy.operation_seq_num < rec_opseq.operation_seq_num
            and wo.disable_date is null;

            x_statement := 210;

            IF (x_count = 0) THEN
              x_unit_cost := 0;
              x_cum_pr_est_scp_per_unit := 0;
            ELSE
              x_statement := 220;

              SELECT  NVL(CUM_OPERATION_UNIT_COST, 0)
              INTO x_unit_cost
              FROM WIP_OPERATION_YIELDS
              WHERE wip_entity_id = rec_wip_entity.wip_entity_id
              and organization_id = x_organization_id
              and operation_seq_num = (select max(woy.operation_seq_num)
                                       from wip_operation_yields woy,
                                            wip_operations wo
                                       where woy.wip_entity_id = rec_wip_entity.wip_entity_id
                                       and woy.organization_id = x_organization_id
                                       and woy.operation_seq_num < rec_opseq.operation_seq_num
				       and woy.operation_seq_num = wo.operation_seq_num
                                       and woy.wip_entity_id   = wo.wip_entity_id
                                       and woy.organization_id = wo.organization_id
                                       and wo.disable_date is null);

              x_statement := 230;
              SELECT SUM( NVL(EST_SCRAP_UNIT_COST, 0))
              INTO x_cum_pr_est_scp_per_unit
              FROM WIP_OPERATION_YIELDS WOY,
	           WIP_OPERATIONS WO
              WHERE woy.wip_entity_id = rec_wip_entity.wip_entity_id
              and woy.organization_id = x_organization_id
              and woy.operation_seq_num < rec_opseq.operation_seq_num
	      and woy.operation_seq_num = wo.operation_seq_num
	      and woy.wip_entity_id   = wo.wip_entity_id
	      and woy.organization_id = wo.organization_id
	      and wo.disable_date is null;

            END IF;  /* IF x_count = 0 */

            x_tl_scrap_in := 0;
            x_tl_scrap_out := 0;
            x_first_operation := FALSE;

            ELSE
	      ---------------------------------------------------------------
   	      -- Compute the Cumulative Prior Estimated Scrap for other cases
	      ---------------------------------------------------------------
              SELECT SUM( NVL(EST_SCRAP_UNIT_COST, 0))
              INTO x_cum_pr_est_scp_per_unit
              FROM WIP_OPERATION_YIELDS WOY,
                   WIP_OPERATIONS WO
              WHERE woy.wip_entity_id = rec_wip_entity.wip_entity_id
              and woy.organization_id = x_organization_id
              and woy.operation_seq_num < rec_opseq.operation_seq_num
	      and woy.operation_seq_num = wo.operation_seq_num
              and woy.wip_entity_id   = wo.wip_entity_id
              and woy.organization_id = wo.organization_id
              and wo.disable_date is null;
          END IF; /* IF x_first_operation */


             ---------------------------------------------------------
             -- Calculate Net Absorption                           --
             ---------------------------------------------------------
          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'Disable_date : '||rec_opseq.disable_date);
	    fnd_file.put_line(fnd_file.log,'Cumulative Est Prior Scrap: '||x_cum_pr_est_scp_per_unit);
	  end if;

          IF (rec_opseq.quantity_completed <> 0 and rec_opseq.disable_date IS NULL) THEN
            x_op_unit_cost := rec_opseq.operation_cost / rec_opseq.quantity_completed ;
          ELSE
            x_op_unit_cost := 0;
          END IF;
          x_unit_cost := x_unit_cost + x_op_unit_cost;

          /* Backward Moves : when an operation is obsoleted in a
             backward move, then it should not be considered
             while calculating operation yield cost.  This check is very
             specific to WSM organizations */
          select wsm_enabled_flag
          into x_wsm_enabled_flag
          from mtl_parameters
          where organization_id = rec_wip_entity.organization_id;

          if (x_wsm_enabled_flag = 'Y') then
       	    select NVL(last_operation_seq_num,9999)
            into x_last_opseq_num
            from wsm_parameters
            where organization_id = rec_wip_entity.organization_id;

            if (rec_opseq.quantity_completed = 0 OR rec_opseq.disable_date is not null) then
               x_est_scrap_per_unit := 0;
            else
               x_est_scrap_per_unit := x_unit_cost * ((1 - rec_opseq.operation_yield) / rec_opseq.operation_yield);
            end if;
          end if; /* x_wsm_enabled_flag = 'Y' */

          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'Est scrap per unit cost : ' || to_char(x_est_scrap_per_unit));
          end if;

          x_unit_cost := x_unit_cost + x_est_scrap_per_unit;

          IF (i_run_option = 2) THEN

             x_net_absorption := (x_est_scrap_per_unit - rec_opseq.est_scrap_unit_cost) * (rec_opseq.est_scrap_qty_completed - rec_opseq.est_scrap_qty_scraped);
          ELSE

             x_net_absorption := (x_est_scrap_per_unit *
                             (rec_opseq.quantity_completed - rec_opseq.quantity_scrapped) - rec_opseq.est_scrap_unit_cost *
                              (rec_opseq.est_scrap_qty_completed - rec_opseq.est_scrap_qty_scraped));

          END If; /* i_run_option = 2 */

          if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'x_net_absorption : ' || to_char(x_net_absorption));
          end if;

             ---------------------------------------------------------
             -- Perform Accounting for Net Absorption:              --
             --                                      DR       CR    --
             -- EST_SCRAP_ACCOUNT                    X              --
             -- EST_SCRAP_ABSORPTION_ACCOUNT                  X     --
             -- TRANSACTION_TYPE = 15 (Estimated Scrap_transaction) --
             -- Acounting Line Type :                               --
             -- 29 (Estimated Scrap Absorption)                     --
             -- 7 ( WIP valauation)                                 --
             --  from mfg_lookups
             ---------------------------------------------------------


          IF (x_net_absorption <> 0 ) THEN

            IF (i_run_option = 3 and rec_opseq.operation_seq_num <= i_txn_op_seq_num ) THEN
              SELECT BONUS_ACCT_ID
              INTO x_abs_account
              FROM WSM_SM_RESULTING_JOBS
              WHERE TRANSACTION_ID = i_sm_txn_id
              AND WIP_ENTITY_ID = i_entity_id;
            ELSE
              x_abs_account := l_est_scrap_abs_acct;
            END IF;

            x_statement := 60;

            SELECT wip_transactions_s.nextval
            INTO x_transaction_id
            FROM dual;

            if (l_debug = 'Y') then
              fnd_file.put_line(fnd_file.log,'Inserting into WT transaction : '||to_char(x_transaction_id));
            end if;

            l_transaction_date := sysdate; /* Bug 4757384 */

            INSERT INTO WIP_TRANSACTIONS(transaction_id,
                                    organization_id,
                                    wip_entity_id,
		                    acct_period_id,
		                    department_id,
		                    transaction_type,
		                    transaction_date,
		                    operation_seq_num,
		                    primary_item_id,
		                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    last_update_login,
                                    request_id,
		                    program_application_id,
		                    program_id,
		                    program_update_date )

		            VALUES(x_transaction_id,
		                   x_organization_id,
		                   rec_wip_entity.wip_entity_id,
		                   x_acct_period_id,
		                   rec_opseq.department_id,
		                   15,
		                   l_transaction_date,
		                   rec_opseq.operation_seq_num,
			           rec_wip_entity.primary_item_id,
			           x_sysdate,
			           x_last_updated_by,
			           x_sysdate,
			           x_last_updated_by,
			           x_last_update_login,
			           x_request_id,
		                   x_program_application_id,
		                   x_program_id,
		                   x_sysdate);

             ---------------------------------------------------------
             -- Debit EST_SCRAP_ACCOUNT                             --
             ---------------------------------------------------------

            if (l_debug = 'Y') then
              fnd_file.put_line(fnd_file.log,'Inserting into WTA transaction : '||to_char(x_transaction_id));
            end if;

	    x_statement := 70;

            INSERT INTO
		WIP_TRANSACTION_ACCOUNTS
		(
                wip_sub_ledger_id, /* R12 - SLA Distribution Link */
		transaction_id,
		reference_account,
		organization_id,
		transaction_date,
		wip_entity_id,
		accounting_line_type,
		base_transaction_value,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date )
		VALUES
		(
		CST_WIP_SUB_LEDGER_ID_S.NEXTVAL,
		x_transaction_id,
		rec_wip_entity.est_scrap_account,
		x_organization_id,
		l_transaction_date,
		rec_wip_entity.wip_entity_id,
		7,
		decode(NVL(x_min_acct_unit, 0), 0, ROUND(x_net_absorption, x_precision),
		                        ROUND (x_net_absorption / x_min_acct_unit) * x_min_acct_unit),
		x_sysdate,
	        x_last_updated_by,
		x_sysdate,
		x_last_updated_by,
		x_last_update_login,
		x_request_id,
		x_program_application_id,
		x_program_id,
		x_sysdate);

             ---------------------------------------------------------
             -- Credit EST_SCRAP_ABOORPTION_ACCOUNT                 --
             ---------------------------------------------------------
            x_statement := 80;
            INSERT INTO
		WIP_TRANSACTION_ACCOUNTS
		(
                wip_sub_ledger_id, /* R12 - SLA Distribution Link */
		transaction_id,
		reference_account,
		organization_id,
		transaction_date,
		wip_entity_id,
		accounting_line_type,
		base_transaction_value,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date )
		VALUES
		(
                CST_WIP_SUB_LEDGER_ID_S.NEXTVAL,
		x_transaction_id,
		x_abs_account,
		x_organization_id,
		l_transaction_date,
		rec_wip_entity.wip_entity_id,
		29,
		decode(NVL(x_min_acct_unit, 0), 0, ROUND(-1 *(x_net_absorption), x_precision),
		                        ROUND (-1 *(x_net_absorption) / x_min_acct_unit) * x_min_acct_unit),
		x_sysdate,
	        x_last_updated_by,
		x_sysdate,
		x_last_updated_by,
		x_last_update_login,
		x_request_id,
		x_program_application_id,
		x_program_id,
		x_sysdate);

              /* SLA Event Seeding */
              l_trx_info.TRANSACTION_ID      := x_transaction_id;
              l_trx_info.WIP_RESOURCE_ID     := -1;
              l_trx_info.WIP_BASIS_TYPE_ID   := -1;
              l_trx_info.TXN_TYPE_ID         := 15;
              l_trx_info.INV_ORGANIZATION_ID := x_organization_id;
              l_trx_info.TRANSACTION_DATE    := x_sysdate;
              x_statement := 85;

              CST_XLA_PVT.Create_WIPXLAEvent(
                p_api_version      => 1.0,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                p_trx_info         => l_trx_info);

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                FND_FILE.put_line(FND_FILE.log, 'Event Creation Failed: '||l_msg_data );
                RAISE FND_API.g_exc_unexpected_error;
              END IF;

            END IF;  /* x_net_absorption <> 0 */


             ---------------------------------------------------------
             -- Calculate Net Reversal                              --
             ---------------------------------------------------------

            IF (i_run_option = 2) THEN

              x_net_reversal := (x_cum_pr_est_scp_per_unit - rec_opseq.cum_est_prior_unit_cost) *
                            rec_opseq.est_scrap_qty_scraped;
            ELSE

              x_net_reversal := x_cum_pr_est_scp_per_unit * rec_opseq.quantity_scrapped -
                             rec_opseq.cum_est_prior_unit_cost * rec_opseq.est_scrap_qty_scraped;
            END If;

            if (l_debug = 'Y') then
              fnd_file.put_line(fnd_file.log,'x_net_reversal : '||to_char(x_net_reversal));
            end if;

             ---------------------------------------------------------
             -- Perform Accounting for Net Reversal:                --
             --                                      DR       CR    --
             -- SCRAP_ACCOUNT                        X              --
             -- EST_SCRAP__ACCOUNT                             X    --
             -- TRANSACTION_TYPE = 90 (Scrap_transaction)           --
             -- Acounting Line Type :                               --
             -- 2 (Account)                                         --
             -- 7 ( WIP valauation)                                 --
             --  from mfg_lookups
             ---------------------------------------------------------


            IF (x_net_reversal <> 0 ) THEN

              x_statement := 90;

              SELECT mtl_material_transactions_s.nextval
              INTO x_transaction_id
              FROM dual;

              /* Bug #2840690. Get primary UOM of assembly */
              SELECT muom.uom_code
              INTO l_uom
              FROM
                mtl_system_items msi, mtl_units_of_measure muom
              WHERE  msi.inventory_item_id  = rec_wip_entity.primary_item_id
              AND    msi.organization_id    = x_organization_id
              AND    msi.primary_unit_of_measure = muom.unit_of_measure;


              if (l_debug = 'Y') then
                fnd_file.put_line(fnd_file.log,'Inserting into MMT transaction : '||to_char(x_transaction_id));
              end if;

              l_transaction_date := sysdate; /* Bug 4757384 */

	      INSERT into
		MTL_MATERIAL_TRANSACTIONS(
		transaction_id,
		inventory_item_id,
		organization_id,
		transaction_type_id,
		transaction_action_id,
		transaction_source_type_id,
		transaction_quantity,
		transaction_uom,
		primary_quantity,
		transaction_date,
		acct_period_id,
		department_id,
		operation_seq_num,
		transaction_source_id,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date)
		VALUES
		(x_transaction_id,
		rec_wip_entity.primary_item_id,
		x_organization_id,
		92, /* Est Scrap Txn in MMT  (new type) */
		30,
		5,
		(rec_opseq.quantity_scrapped
		- rec_opseq.est_scrap_qty_scraped),
		l_uom,
		(rec_opseq.quantity_scrapped
		- rec_opseq.est_scrap_qty_scraped),
		l_transaction_date,
		x_acct_period_id,
		rec_opseq.department_id,
		rec_opseq.operation_seq_num,
		rec_wip_entity.wip_entity_id,
		x_sysdate,
	        x_last_updated_by,
		x_sysdate,
		x_last_updated_by,
		x_last_update_login,
		x_request_id,
		x_program_application_id,
		x_program_id,
		x_sysdate);

             ---------------------------------------------------------
             -- Debit SCRAP_ACCOUNT                             --
             ---------------------------------------------------------

	      x_statement := 100;
              INSERT into MTL_TRANSACTION_ACCOUNTS
		(
                inv_sub_ledger_id, /* R12 - SLA Distribution Link */
		transaction_id,
		reference_account,
		inventory_item_id,
		organization_id,
		transaction_date,
		transaction_source_id,
		transaction_source_type_id,
		primary_quantity,
		accounting_line_type,
		base_transaction_value,
		contra_set_id,
		rate_or_amount,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date)
		VALUES(
                CST_INV_SUB_LEDGER_ID_S.NEXTVAL,
		x_transaction_id,
		l_scrap_rev_acct,
		rec_wip_entity.primary_item_id,
		x_organization_id,
		l_transaction_date,
		rec_wip_entity.wip_entity_id,
		5,
		(rec_opseq.quantity_scrapped - rec_opseq.est_scrap_qty_scraped),
		2,
		decode(NVL(x_min_acct_unit, 0), 0, ROUND(x_net_reversal, x_precision),
		                        ROUND (x_net_reversal / x_min_acct_unit) * x_min_acct_unit),
		1,
		x_cum_pr_est_scp_per_unit,
		x_sysdate,
	        x_last_updated_by,
		x_sysdate,
		x_last_updated_by,
		x_last_update_login,
		x_request_id,
		x_program_application_id,
		x_program_id,
		x_sysdate);

             ---------------------------------------------------------
             -- Credit EST_SCRAP_ACCOUNT                             --
             ---------------------------------------------------------
	      x_statement := 110;
	      INSERT into MTL_TRANSACTION_ACCOUNTS
		(
                inv_sub_ledger_id, /* R12 - SLA Distribution Link */
		transaction_id,
		reference_account,
		inventory_item_id,
		organization_id,
		transaction_date,
		transaction_source_id,
		transaction_source_type_id,
		primary_quantity,
		accounting_line_type,
		base_transaction_value,
		contra_set_id,
		rate_or_amount,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date)
		VALUES(
                CST_INV_SUB_LEDGER_ID_S.NEXTVAL,
		x_transaction_id,
		rec_wip_entity.est_scrap_account,
		rec_wip_entity.primary_item_id,
		x_organization_id,
		l_transaction_date,
		rec_wip_entity.wip_entity_id,
		5,
		(rec_opseq.quantity_scrapped - rec_opseq.est_scrap_qty_scraped),
		7,
		decode(NVL(x_min_acct_unit, 0), 0, ROUND(-1 *(x_net_reversal), x_precision),
		                        ROUND (-1 *(x_net_reversal) / x_min_acct_unit) * x_min_acct_unit),
		1,
		x_cum_pr_est_scp_per_unit,
		x_sysdate,
	        x_last_updated_by,
		x_sysdate,
		x_last_updated_by,
		x_last_update_login,
		x_request_id,
		x_program_application_id,
		x_program_id,
		x_sysdate);

              l_inv_trx_info.TRANSACTION_ID       := x_transaction_id;
              l_inv_trx_info.TXN_ACTION_ID        := 30;
              l_inv_trx_info.TXN_ORGANIZATION_ID  := x_organization_id;
              l_inv_trx_info.TXN_SRC_TYPE_ID      := 5;
              l_inv_trx_info.TXN_TYPE_ID          := 92;
              l_inv_trx_info.TRANSACTION_DATE     := l_transaction_date;

              x_statement := 115;
              /* Create the SLA event for the Estimated Scrap Reversal */
              CST_XLA_PVT.Create_INVXLAEvent (
                p_api_version       => 1.0,
                p_init_msg_list     => FND_API.G_FALSE,
                p_commit            => FND_API.G_FALSE,
                p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data,
                p_trx_info          => l_inv_trx_info
              );
              IF l_return_status <> 'S' THEN
                FND_FILE.put_line(FND_FILE.log, 'Event creation failed: CSTPOYLD.process_op_yield('||x_statement||')');
                RAISE FND_API.g_exc_unexpected_error;
              END IF;

            END IF; /* x_net_reversal <> 0 */

            if (l_debug = 'Y') then
              fnd_file.put_line(fnd_file.log,'Updating WOY ');
            end if;


           ---------------------------------------------------------
           -- Update WIP_OPERATION_YIELDS                         --
           ---------------------------------------------------------

            x_statement := 120;
            UPDATE WIP_OPERATION_YIELDS
            SET operation_unit_cost = x_op_unit_cost,
                cum_operation_unit_cost = x_unit_cost,
                est_scrap_unit_cost = x_est_scrap_per_unit,
                cum_est_prior_unit_cost = x_cum_pr_est_scp_per_unit,
                est_scrap_qty_completed = rec_opseq.quantity_completed,
                est_scrap_qty_scraped = rec_opseq.quantity_scrapped,
                status = 2,
                last_update_date = x_sysdate,
                last_updated_by = x_last_updated_by,
                request_id = x_request_id,
	        program_application_id = x_program_application_id,
	        program_id = x_program_id,
	        program_update_date = x_sysdate
            WHERE organization_id = x_organization_id
            AND wip_entity_id = rec_wip_entity.wip_entity_id
            AND operation_seq_num = rec_opseq.operation_seq_num;

             ---------------------------------------------------------
             -- Update variables                                    --
             ---------------------------------------------------------

            x_statement := 125;
            SELECT  x_tl_scrap_in + decode(NVL(x_min_acct_unit, 0), 0, ROUND(x_net_absorption, x_precision),
                                        ROUND (x_net_absorption / x_min_acct_unit) * x_min_acct_unit),
                    x_tl_scrap_out + decode(NVL(x_min_acct_unit, 0), 0, ROUND(x_net_reversal, x_precision),
                                        ROUND (x_net_reversal / x_min_acct_unit) * x_min_acct_unit)
            INTO    x_tl_scrap_in,
                    x_tl_scrap_out
            FROM    dual;

        EXCEPTION
	  WHEN EST_ACCT_NOT_FOUND THEN
           x_tl_scrap_in  := 0;
           x_tl_scrap_out := 0;
           ROLLBACK  TO x_save_point;

           UPDATE WIP_OPERATION_YIELDS
           SET status = 3,
               last_update_date = x_sysdate,
               last_updated_by = x_last_updated_by,
               request_id = x_request_id,
               program_application_id = x_program_application_id,
               program_id = x_program_id,
               program_update_date = x_sysdate
           WHERE organization_id = x_organization_id
           AND wip_entity_id = rec_wip_entity.wip_entity_id
           AND operation_seq_num = rec_opseq.operation_seq_num;

	   fnd_file.put_line(FND_FILE.LOG,'BOM department does not have scrap account '||
				'or estimated scrap absortion account defined');
           fnd_message.set_name('BOM', 'CST_OP_YLD_NOT_PROCESSED');
           fnd_message.set_token('ENTITY_ID', to_char(rec_wip_entity.wip_entity_id));
           fnd_file.put_line(fnd_file.log, fnd_message.get);

           fnd_message.set_name('BOM', 'CST_OP_YLD_GENERAL_ERROR');
           fnd_message.set_token('NUMBER', to_char(x_statement));
           fnd_file.put_line(fnd_file.log, fnd_message.get);


           x_err_num := SQLCODE;
           x_err_msg := substr(SQLERRM, 1, 200);
           ERRBUF := x_err_msg;
           fnd_file.put_line(fnd_file.log, 'x_err_num' || ' : ' || x_err_msg);
           x_status := fnd_concurrent.set_completion_status( status => 'WARNING',
                                          message => '');

           EXIT opseq;

          WHEN OTHERS THEN
            x_tl_scrap_in  := 0;
            x_tl_scrap_out := 0;
            ROLLBACK  TO x_save_point;

            UPDATE WIP_OPERATION_YIELDS
            SET status = 3,
                last_update_date = x_sysdate,
                last_updated_by = x_last_updated_by,
                request_id = x_request_id,
	        program_application_id = x_program_application_id,
	        program_id = x_program_id,
	        program_update_date = x_sysdate
            WHERE organization_id = x_organization_id
            AND wip_entity_id = rec_wip_entity.wip_entity_id
            AND operation_seq_num = rec_opseq.operation_seq_num;


            fnd_message.set_name('BOM', 'CST_OP_YLD_NOT_PROCESSED');
            fnd_message.set_token('ENTITY_ID', to_char(rec_wip_entity.wip_entity_id));
            fnd_file.put_line(fnd_file.log, fnd_message.get);

            fnd_message.set_name('BOM', 'CST_OP_YLD_GENERAL_ERROR');
            fnd_message.set_token('NUMBER', to_char(x_statement));
            fnd_file.put_line(fnd_file.log, fnd_message.get);


            x_err_num := SQLCODE;
            x_err_msg := substr(SQLERRM, 1, 200);
            ERRBUF := x_err_msg;
            fnd_file.put_line(fnd_file.log, 'x_err_num' || ' : ' || x_err_msg);
            x_status := fnd_concurrent.set_completion_status( status => 'WARNING',
                                          message => '');

            EXIT opseq;

        END;

        END LOOP opseq;
             ---------------------------------------------------------
             -- Update WIP_PERIOD_BALANCEs                          --
             ---------------------------------------------------------


        /* Update WOY if x_tl_scrap_in or x_tl_scrap_out <> 0 */
        IF (x_tl_scrap_in <> 0 OR x_tl_scrap_out <> 0) THEN
          x_statement := 130;
          UPDATE WIP_PERIOD_BALANCES
          SET tl_scrap_in  = NVL(tl_scrap_in, 0) + x_tl_scrap_in,
              tl_scrap_out = NVL(tl_scrap_out, 0) + x_tl_scrap_out,
              last_update_date = x_sysdate,
              last_updated_by = x_last_updated_by,
              request_id = x_request_id,
	      program_application_id = x_program_application_id,
	      program_id = x_program_id,
	      program_update_date = x_sysdate
          WHERE organization_id = x_organization_id
          AND wip_entity_id = rec_wip_entity.wip_entity_id
          AND acct_period_id =  x_acct_period_id;
        END IF;

        IF (i_run_option <> 3) THEN
          COMMIT;
        END IF;

      END IF; /* If ESA is enabled */

    END LOOP wip_entity;
    IF(l_debug = 'Y') THEN
      fnd_file.put_line(fnd_file.log, 'PROCESS_OP_YIELD >>>');
    END IF;

EXCEPTION
WHEN WSM_ESA_PKG_ERROR THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in WSM_ESA_ENABLED : '||
					 ' wip_entity_id '|| to_char(temp_wip_entity_id) ||
                                         x_err_num ||' : '|| x_err_msg);
	ERRBUF := 'CSTPOYLD.process_op_yield:' || x_statement || ':' ||
		  substr(x_err_msg,1,200);
        RAISE_APPLICATION_ERROR( -20001, x_err_msg);
WHEN OTHERS THEN
        fnd_message.set_name('BOM', 'CST_OP_YLD_GENERAL_ERROR');
        fnd_message.set_token('NUMBER', 'x_statement');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        x_err_num := SQLCODE;
        x_err_msg := 'CSTPOYLD.process_op_yield:' || x_statement || ':' ||
                     substr(SQLERRM, 1, 200);
        fnd_file.put_line(fnd_file.log,x_err_msg);
        ERRBUF := x_err_msg;
        RAISE_APPLICATION_ERROR( -20001, x_err_msg);

END process_op_yield;


 ---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  transact_op_yield_var                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate op yield reallocation and op yield    --
--   variance. This function is to be called from discrete job close      --
--   variance program cmlwjv()                                            --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_group_id     : Wip entity id of lot based job             --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    03/02/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
FUNCTION  transact_op_yield_var( i_group_id    IN   NUMBER,
                                 i_user_id     IN   NUMBER,
                                 i_login_id    IN   NUMBER,
                                 i_prg_appl_id IN   NUMBER,
                                 i_prg_id      IN   NUMBER,
                                 i_req_id      IN   NUMBER,
                                 o_err_num     OUT NOCOPY NUMBER,
                                 o_err_code  OUT NOCOPY VARCHAR2,
                                 o_err_msg   OUT NOCOPY VARCHAR2)
return NUMBER IS
x_scrap_variance                 NUMBER := 0;
x_tl_scrap_in                    NUMBER := 0;
x_tl_scrap_out                   NUMBER := 0;
x_tl_scrap_var                   NUMBER := 0;
x_organization_id                NUMBER := 0;
x_currency_code                  VARCHAR2(15);
x_precision                      NUMBER := 0;
x_ext_precision                  NUMBER := 0;
x_min_acct_unit		         NUMBER	:= 0;
l_debug                          VARCHAR2(80);

/* Changes for Optional Scrap */
x_est_scrap_acct_flag		NUMBER :=0;
x_err_num			NUMBER := 0;
x_err_msg			VARCHAR2(240) ;
WSM_ESA_PKG_ERROR      		EXCEPTION;

/* Bug 2469879*/
x_history_count			NUMBER;

CURSOR c_wip_entity IS
 SELECT distinct wcti.transaction_id,
	wcti.wip_entity_id,
        wcti.acct_period_id,
        wcti.organization_id,
        wcti.transaction_date, /* Bug 4757384 */
        wdj.est_scrap_account,
        wdj.est_scrap_var_account,
        wdj.primary_item_id
   FROM WIP_COST_TXN_INTERFACE wcti,
        WIP_DISCRETE_JOBS      wdj,
        WIP_ENTITIES we
  WHERE wcti.group_id = i_group_id
    AND we.entity_type = 5
    and we.wip_entity_id = wcti.wip_entity_id
    and we.organization_id = wcti.organization_id
    AND wcti.wip_entity_id = wdj.wip_entity_id;

BEGIN

 x_err_msg := '';
 o_err_code := '';
 o_err_num := 0;
 o_err_msg := '';

       l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

	     ---------------------------------------------------------
              -- Open wip_entity Cursor                          --
             ---------------------------------------------------------
   <<wip_entity>>

    FOR rec_wip_entity IN c_wip_entity LOOP

	/* Changes for Optional Scrap */
	x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(rec_wip_entity.wip_entity_id,
             						  x_err_num,x_err_msg);

        IF (x_est_scrap_acct_flag = 0) THEN
	  RAISE WSM_ESA_PKG_ERROR;
        END IF;
        IF (l_debug = 'Y') THEN
          FND_FILE.put_line(FND_FILE.log,'transact_op:x_est_scrap_acct_flag : '|| to_char(x_est_scrap_acct_flag));
        END IF;

	/* Do Operation Yield Accounting only if ESA is enabled */
	IF x_est_scrap_acct_flag = 1 THEN

	  IF (x_organization_id <> rec_wip_entity.organization_id) THEN
             x_organization_id := rec_wip_entity.organization_id;

             ---------------------------------------------------------
             -- Get Currency Code for Organization                  --
             ---------------------------------------------------------

/* The following lines in the select clause has been replaced with
   the reference to"CST_ORGANIZATION_DEFINITIONS" as an impact of the
   HR-PROFILE option" */


         SELECT COD.CURRENCY_CODE
         INTO x_currency_code
            FROM CST_ORGANIZATION_DEFINITIONS COD
         WHERE COD.ORGANIZATION_ID = rec_wip_entity.organization_id;



       	fnd_currency.get_info( x_currency_code,
                              x_precision,
                              x_ext_precision,
                              x_min_acct_unit);

    	END IF;
             ---------------------------------------------------------
              -- Calculate Op YLD Variance                          --
             ---------------------------------------------------------

     	SELECT
		NVL(SUM(NVL(tl_scrap_in,0)), 0),
		NVL(SUM(NVL(TL_SCRAP_OUT,0)), 0),
		NVL(SUM(NVL(TL_SCRAP_VAR,0)), 0)
	INTO
		x_tl_scrap_in,
		x_tl_scrap_out,
		x_tl_scrap_var
	FROM
		WIP_PERIOD_BALANCES
	WHERE
		wip_entity_id=rec_wip_entity.wip_entity_id
	AND 	organization_id=rec_wip_entity.organization_id
	AND	acct_period_id <= rec_wip_entity.acct_period_id;

	x_scrap_variance := NVL(x_tl_scrap_in, 0) - (NVL(x_tl_scrap_out, 0)
	                                          + NVL(x_tl_scrap_var, 0));

             ---------------------------------------------------------
             -- Perform Accounting for Scrap Variance:              --
             --                                      DR       CR    --
             -- EST_SCRAP_VAR_ACCOUNT                X              --
             -- EST_SCRAP_ACCOUNT                             X     --
             -- TRANSACTION_TYPE = 6 (Job Close variance)           --
             -- Acounting Line Type :                               --
             -- 8 (WIP variance)                                    --
             -- 7 ( WIP valauation)                                 --
             --  from mfg_lookups
             ---------------------------------------------------------


       IF (x_scrap_variance <> 0 ) THEN

       /* Bug #2325980. No need to enter another transaction of type 6 in WT.
          Just use the original transaction_id from WCTI. Otherwise there will
          be 2 Job Close Variance transactions in WT and hence two lines in the
 	  output of the Job Close Variance report. */


             ---------------------------------------------------------
             -- Debit EST_SCRAP_VAR_ACCOUNT                             --
             ---------------------------------------------------------


          INSERT INTO
		WIP_TRANSACTION_ACCOUNTS
		(
                wip_sub_ledger_id, /* R12 - SLA Distribution Link */
		transaction_id,
		reference_account,
		organization_id,
		transaction_date,
		wip_entity_id,
		accounting_line_type,
		base_transaction_value,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date )
		VALUES
		(
                CST_WIP_SUB_LEDGER_ID_S.NEXTVAL,
		rec_wip_entity.transaction_id,
		rec_wip_entity.est_scrap_var_account,
		x_organization_id,
		rec_wip_entity.transaction_date,
		rec_wip_entity.wip_entity_id,
		8,
		decode(NVL(x_min_acct_unit, 0), 0, ROUND(x_scrap_variance, x_precision),
		                        ROUND (x_scrap_variance / x_min_acct_unit) * x_min_acct_unit),
		sysdate,
		i_user_id,
		sysdate,
		i_user_id,
		i_login_id ,
		i_req_id  ,
		i_prg_appl_id,
		i_prg_id,
		sysdate);
             ---------------------------------------------------------
             -- Credit EST_SCRAP_ACCOUNT                 --
             ---------------------------------------------------------

          INSERT INTO
		WIP_TRANSACTION_ACCOUNTS
		(
                wip_sub_ledger_id, /* R12 - SLA Distribution Link */
		transaction_id,
		reference_account,
		organization_id,
		transaction_date,
		wip_entity_id,
		accounting_line_type,
		base_transaction_value,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date )
		VALUES
		(
                CST_WIP_SUB_LEDGER_ID_S.NEXTVAL,
		rec_wip_entity.transaction_id,
		rec_wip_entity.est_scrap_account,
		x_organization_id,
		rec_wip_entity.transaction_date,
		rec_wip_entity.wip_entity_id,
		7,
		decode(NVL(x_min_acct_unit, 0), 0, ROUND(-1 *(x_scrap_variance), x_precision),
		                        ROUND (-1 * (x_scrap_variance) / x_min_acct_unit) * x_min_acct_unit),
		sysdate,
		i_user_id,
		sysdate,
		i_user_id,
		i_login_id ,
		i_req_id  ,
		i_prg_appl_id,
		i_prg_id,
		sysdate);

        END IF;

             ---------------------------------------------------------
              -- Update WIP_PERIOD_BALANCES                         --
             ---------------------------------------------------------


		UPDATE WIP_PERIOD_BALANCES wpb
			SET
				TL_SCRAP_VAR =
                                                (SELECT SUM(  NVL(TL_SCRAP_IN,0)
                                                              - NVL(TL_SCRAP_OUT,0)
                                                              - decode(wpb2.acct_period_id,wpb.acct_period_id,0,
                                                                        NVL(TL_SCRAP_VAR,0)))
                                                 FROM WIP_PERIOD_BALANCES wpb2
                                                 WHERE wpb2.wip_entity_id = wpb.wip_entity_id
                                                 AND   wpb2.acct_period_id <= wpb.acct_period_id),
				last_update_date = sysdate,
				last_updated_by = i_user_id,
				last_update_login = i_login_id,
				request_id = i_req_id ,
		                program_application_id = i_prg_appl_id,
		                program_id = i_prg_id,
		                program_update_date = sysdate


			WHERE
			 	organization_id = x_organization_id
			AND	acct_period_id = rec_wip_entity.acct_period_id
			AND	wip_entity_id= rec_wip_entity.wip_entity_id;


	/* Bug# 2469879. Check if row already exists. There may be a row
	   in the history table if the job had been closed earlier and then
	   unclosed. */

	SELECT count(*)
	INTO x_history_count
	FROM WIP_OP_YIELD_HISTORY
	WHERE wip_entity_id = rec_wip_entity.wip_entity_id
	AND organization_id = x_organization_id
	AND acct_period_id = rec_wip_entity.acct_period_id;

	IF (x_history_count = 0) THEN

             ---------------------------------------------------------
              -- INSERT INTO  WIP_OP_YIELD_HISTORY                  --
             ---------------------------------------------------------

   	   INSERT INTO WIP_OP_YIELD_HISTORY
		(wip_entity_id,
		organization_id,
		acct_period_id,
		est_scrap_absorb_amt,
		est_scrap_reverse_amt,
		est_scrap_var_amt,
		last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
		program_application_id,
		program_id,
		program_update_date)
	   VALUES
		(rec_wip_entity.wip_entity_id,
		x_organization_id,
		rec_wip_entity.acct_period_id,
		x_tl_scrap_in,
		x_tl_scrap_out,
		(x_scrap_variance + x_tl_scrap_var),
		sysdate,
		i_user_id,
		sysdate,
		i_user_id,
		i_login_id ,
		i_req_id  ,
		i_prg_appl_id,
		i_prg_id,
		sysdate);
	ELSE /* Row exists */

             ---------------------------------------------------------
              -- UPDATE  WIP_OP_YIELD_HISTORY                  --
             ---------------------------------------------------------

	   UPDATE WIP_OP_YIELD_HISTORY
	   SET
                est_scrap_absorb_amt = x_tl_scrap_in,
                est_scrap_reverse_amt = x_tl_scrap_out,
                est_scrap_var_amt = (x_scrap_variance + x_tl_scrap_var),
                last_update_date = sysdate,
                last_updated_by = i_user_id,
                last_update_login = i_login_id,
                request_id = i_req_id,
                program_application_id = i_prg_appl_id,
                program_id = i_prg_id,
                program_update_date = sysdate
           WHERE wip_entity_id = rec_wip_entity.wip_entity_id
           AND organization_id = x_organization_id
           AND acct_period_id = rec_wip_entity.acct_period_id;

	END IF; /* IF x_history_count = 0 */

    END IF; /* If ESA is enabled */

  END LOOP wip_entity;

  return 1;

EXCEPTION
   WHEN WSM_ESA_PKG_ERROR THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in WSM_ESA_ENABLED : '||
                                         x_err_num ||' : '|| x_err_msg);
	o_err_num := x_err_num;
        o_err_msg := 'CSTPOYLD.transact_op_yield_var:' || substr(x_err_msg,1,150);
	return 0;
  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPOYLD.transact_op_yield_var:' || substrb(SQLERRM,1,150);
    return 0;
END transact_op_yield_var;
 ---------------------------------------------------------------------------
-- FUNCTION                                                               --
--  process_sm_op_yld                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to calculate op yield for jobs involved in split   --
--   merge transaction.                                                   --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.1                                        --
--                                                                        --
-- PARAMETERS:                                                            --
--            i_txn_id     :Split Merge Txn Id                            --
-- RETURNS                                                                --
--     1 : Success                                                        --
--     0 : Failure                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    02/12/00     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
FUNCTION  process_sm_op_yld    ( i_txn_id      IN   NUMBER,
                                 i_user_id     IN   NUMBER,
                                 i_login_id    IN   NUMBER,
                                 i_prg_appl_id IN   NUMBER,
                                 i_prg_id      IN   NUMBER,
                                 i_req_id      IN   NUMBER,
                                 o_err_num     OUT NOCOPY NUMBER,
                                 o_err_code  OUT NOCOPY VARCHAR2,
                                 o_err_msg   OUT NOCOPY VARCHAR2)

 return NUMBER IS


x_op_seq_num                     Number;
x_pl_cost                        Number;
x_tl_res_cost                    Number;
x_tl_osp_cost                    Number;
x_tl_res_val_ovhd_cost           Number;
x_tl_res_unit_ovhd_cost          Number;
x_item_lot_ovhd_cost             Number;
x_ovhd_cost             	 Number;
x_operation_cost                 Number;
l_debug				 VARCHAR2(80);
l_stmt_num                       NUMBER := 0;

/* Changes for Optional Scrap */
x_est_scrap_acct_flag		NUMBER := 0;
x_err_num                       NUMBER := 0;
x_err_msg                      VARCHAR2(240) ;
WSM_ESA_PKG_ERROR               EXCEPTION;

CURSOR c_wip_entity IS
       SELECT sj.wip_entity_id        wip_entity_id,
              sj.operation_seq_num    op_seq_num,
              sj.intraoperation_step  intra_op_step,
              smt.organization_id     organization_id,
              sj.routing_seq_id routing_seq_id,
              smt.transaction_type_id txn_type_id
        FROM wsm_sm_starting_jobs sj,
             wsm_split_merge_transactions smt
       WHERE smt.transaction_id = i_txn_id
         AND smt.transaction_type_id In (1, 2, 6)
         AND smt.transaction_id = sj.transaction_id
       UNION
         select rj.wip_entity_id wip_entity_id,
         nvl(rj.starting_operation_seq_num,sj.operation_seq_num) op_seq_num,
         rj.starting_intraoperation_step intra_op_step,
         smt.organization_id organization_id,
	 rj.common_routing_sequence_id routing_seq_id,
	 smt.transaction_type_id txn_type_id
         from wsm_sm_resulting_jobs rj,
         wsm_split_merge_transactions smt,
         wsm_sm_starting_jobs sj
         where smt.transaction_id = i_txn_id
         and smt.transaction_type_id in (1,2,6)
         and smt.transaction_id = rj.transaction_id
         and smt.transaction_id = sj.transaction_id
         and sj.representative_flag = 'Y'
       UNION
        Select rj.wip_entity_id wip_entity_id,
               rj.job_operation_seq_num op_seq_num,
            nvl(rj.starting_intraoperation_step, WIP_CONSTANTS.QUEUE) intra_op_step,
            smt.organization_id organization_id,
            rj.common_routing_sequence_id routing_seq_id,
            smt.transaction_type_id txn_type_id
         from wsm_sm_resulting_jobs rj,
              wsm_split_merge_transactions smt
        where smt.transaction_id = i_txn_id
          and smt.transaction_type_id = 4
          and smt.transaction_id = rj.transaction_id
          and rj.job_operation_seq_num is not NULL
      /* Jobs prior to 11i.8 would not have JOB_OPERATION_SEQ_NUM
         populated. Not modifying the above since this will not
         happen in most cases and also is much cleaner performance
         wise */
        UNION
         Select rj.wip_entity_id wip_entity_id,
                wo.operation_seq_num op_seq_num,
                nvl(rj.starting_intraoperation_step, WIP_CONSTANTS.QUEUE) intra_op_step,
                smt.organization_id organization_id,
                rj.common_routing_sequence_id routing_seq_id,
                 smt.transaction_type_id txn_type_id
         from   wsm_sm_resulting_jobs rj,
                wsm_split_merge_transactions smt,
                wip_operations wo,
                bom_operation_sequences bos
        where smt.transaction_id             = i_txn_id
          and smt.transaction_type_id        = 4
          and smt.transaction_id             = rj.transaction_id
          and rj.starting_operation_seq_num  = bos.operation_seq_num
          and rj.common_routing_sequence_id  = bos.routing_sequence_id
          and bos.operation_sequence_id      = wo.operation_sequence_id
          AND bos.EFFECTIVITY_DATE          <= smt.transaction_date
          AND NVL( bos.DISABLE_DATE, smt.transaction_date + 1) > smt.transaction_date
          and wo.wip_entity_id               = rj.wip_entity_id
          and wo.organization_id             = smt.organization_id
          and rj.job_operation_seq_num is NULL
	order by wip_entity_id;

CURSOR c_operation (p_wip_entity_id   Number,
                    p_op_seq_num      Number,
                    p_organization_id Number) IS
       SELECT wo.operation_seq_num,
              wdj.start_quantity
         FROM wip_operations wo,
              wip_discrete_jobs wdj
        WHERE wo.wip_entity_id = p_wip_entity_id
          AND wo.operation_seq_num <= p_op_seq_num
          AND wo.organization_id = p_organization_id
          AND wo.wip_entity_id = wdj.wip_entity_id
          AND wo.organization_id = wdj.organization_id
      ORDER BY wo.operation_seq_num;

BEGIN

 x_err_msg := '';
 o_err_code := '';
 o_err_num := 0;
 o_err_msg := '';

      l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

  IF(l_debug = 'Y') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESS_SM_OP_YIELD <<< ');
  END IF;


             ---------------------------------------------------------
              -- Open wip_entity Cursor                          --
             ---------------------------------------------------------
   <<wip_entity>>

  FOR rec_wip_entity IN c_wip_entity LOOP
    /* Changes for Optional Scrap */
    l_stmt_num := 10;
    x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(rec_wip_entity.wip_entity_id,
                                             x_err_num, x_err_msg);

    IF (x_est_scrap_acct_flag = 0) THEN
       RAISE WSM_ESA_PKG_ERROR;
    END IF;

    IF x_est_scrap_acct_flag = 1 THEN
     x_op_seq_num := rec_wip_entity.op_seq_num;

 <<opseq>>
    if (l_debug = 'Y') then
         fnd_file.put_line(fnd_file.log,'WIP_ENTITY_ID : ' || to_char(rec_wip_entity.wip_entity_id));
         fnd_file.put_line(fnd_file.log,'X_OP_SEQ_NUM: ' || to_char(x_op_seq_num));
    end if;

     FOR rec_opseq IN c_operation (rec_wip_entity.wip_entity_id,
                                   x_op_seq_num,
                                   rec_wip_entity.organization_id) LOOP

      if (l_debug = 'Y') then
       fnd_file.put_line(fnd_file.log,'OP_SEQ: ' || to_char(rec_opseq.operation_seq_num));
      end if;
      l_stmt_num := 20;

             ---------------------------------------------------------
              -- Get privious level cost                           --
             ---------------------------------------------------------
       SELECT
             NVL(SUM ((NVL(CIC.MATERIAL_COST,0) +
                       NVL(CIC.MATERIAL_OVERHEAD_COST,0) +
                       NVL(CIC.RESOURCE_COST,0) +
                       NVL(CIC.OUTSIDE_PROCESSING_COST,0) +
                       NVL(CIC.OVERHEAD_COST,0)) * NVL(WRO.COSTED_QUANTITY_ISSUED, 0)), 0)

        INTO
	    x_pl_cost

         FROM
	    wip_requirement_operations WRO,
	    cst_item_costs CIC
        WHERE
	        CIC.INVENTORY_ITEM_ID	= WRO.INVENTORY_ITEM_ID
         AND	CIC.ORGANIZATION_ID	= WRO.ORGANIZATION_ID
         AND	CIC.COST_TYPE_ID	= 1
         AND	WRO.WIP_ENTITY_ID	= rec_wip_entity.wip_entity_id
         AND	WRO.OPERATION_SEQ_NUM 	= rec_opseq.operation_seq_num
         AND    WRO.ORGANIZATION_ID     = rec_wip_entity.organization_id;

             ---------------------------------------------------------
              -- Get this level Resource and OSP cost               --
             ---------------------------------------------------------
        l_stmt_num := 30;
        SELECT
	     NVL(SUM(DECODE(BR.COST_ELEMENT_ID,
		        3, DECODE(BR.STANDARD_RATE_FLAG,
			     1, decode(BR.functional_currency_flag,
				1,nvl(WOR.APPLIED_RESOURCE_UNITS,0),
				nvl(CRC.RESOURCE_RATE*WOR.APPLIED_RESOURCE_UNITS,0)),
			     2, nvl(WOR.APPLIED_RESOURCE_VALUE,0)),
		0)),0),
	    NVL(SUM(DECODE(BR.COST_ELEMENT_ID,
		     4, DECODE(BR.STANDARD_RATE_FLAG,
			    1, decode(BR.functional_currency_flag,
				    1,nvl(WOR.APPLIED_RESOURCE_UNITS,0),
				    nvl(CRC.RESOURCE_RATE*WOR.APPLIED_RESOURCE_UNITS,0)),
			    2, nvl(WOR.APPLIED_RESOURCE_VALUE,0)),
		        0)),0)
        INTO
	    x_tl_res_cost,
	    x_tl_osp_cost
        FROM 	cst_resource_costs CRC,
	        wip_operation_resources WOR,
	        bom_resources BR
       WHERE
	      CRC.COST_TYPE_ID(+)	= 1
         AND  CRC.RESOURCE_ID(+)	= WOR.RESOURCE_ID
         AND  WOR.OPERATION_SEQ_NUM	= rec_opseq.operation_seq_num
         AND  BR.RESOURCE_ID		= WOR.RESOURCE_ID
         AND  WOR.WIP_ENTITY_ID 	= rec_wip_entity.wip_entity_id
         AND  WOR.ORGANIZATION_ID	= rec_wip_entity.organization_id;

             ---------------------------------------------------------
              -- Calculate overhead cost                            --
             ---------------------------------------------------------
         l_stmt_num := 40;

           SELECT  nvl(sum(WOO.applied_ovhd_value),0)
            INTO	x_ovhd_cost
            FROM	wip_operation_overheads		WOO
           WHERE
	        	WOO.wip_entity_id       = rec_wip_entity.wip_entity_id
             and	WOO.operation_seq_num   = rec_opseq.operation_seq_num
             and	WOO.organization_id     = rec_wip_entity.organization_id;

             ---------------------------------------------------------
              -- Calculate operation_cost and                       --
              -- Update Wip_operation_yields                        --
             ---------------------------------------------------------

        x_operation_cost :=  x_pl_cost +
                             x_tl_res_cost +
                             x_tl_osp_cost +
                             x_ovhd_cost;
      if (l_debug = 'Y') then
        fnd_file.put_line(fnd_file.log,'PL cost : ' || to_char(x_pl_cost));
      	fnd_file.put_line(fnd_file.log,'TL res cost: ' || to_char(x_tl_res_cost));
      	fnd_file.put_line(fnd_file.log,'TL osp cost: ' || to_char(x_tl_osp_cost));
      	fnd_file.put_line(fnd_file.log,'TL ovh cost: ' || to_char(x_ovhd_cost));
       end if;

        l_stmt_num := 50;

        UPDATE wip_operation_yields
          SET operation_cost = x_operation_cost,
              status = 1,
              last_update_date = sysdate,
	      last_updated_by = i_user_id,
	      last_update_login = i_login_id,
	      request_id = i_req_id ,
	      program_application_id = i_prg_appl_id,
	      program_id = i_prg_id,
	      program_update_date = sysdate
        WHERE wip_entity_id        = rec_wip_entity.wip_entity_id
          AND operation_seq_num    = rec_opseq.operation_seq_num
          AND organization_id      = rec_wip_entity.organization_id;

        if (l_debug = 'Y') then
            fnd_file.put_line(fnd_file.log,'TOTAL OPN COST: ' || to_char(x_operation_cost));
        end if;

    END LOOP opseq;

   END IF; /* If ESA is enabled */
  END LOOP wip_entity;
  IF(l_debug = 'Y') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESS_SM_OP_YIELD >>> ');
  END IF;


  RETURN 1;
EXCEPTION
   WHEN WSM_ESA_PKG_ERROR THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in WSM_ESA_ENABLED : '||
                                         x_err_num ||' : '|| x_err_msg);
        o_err_num := x_err_num;
        o_err_msg := 'CSTPOYLD.transact_op_yield_var:' ||substr(x_err_msg,1,150);
        return 0;

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPOYLD.process_sm_op_yld:(' || to_char(l_stmt_num) || ')'||substrb(SQLERRM,1,150);
    return 0;
END process_sm_op_yld;

---------------------------------------------------------------------------
Function cost_update_adjustment (i_org_id         IN   NUMBER,
                                 i_update_id      IN   NUMBER,
                                 i_user_id        IN   NUMBER,
                                 i_login_id       IN   NUMBER,
                                 i_prg_appl_id    IN   NUMBER,
                                 i_prg_id         IN   NUMBER,
                                 i_req_id         IN   NUMBER,
                                 o_err_num        OUT NOCOPY  NUMBER,
                                 o_err_code       OUT NOCOPY  VARCHAR2,
                                 o_err_msg        OUT NOCOPY  VARCHAR2)
return NUMBER IS
   l_adj_value  NUMBER;
   l_stmt_num NUMBER;
   l_err_num NUMBER;
   l_err_code VARCHAR2(240);
   l_err_msg VARCHAR2(240);
   process_error EXCEPTION;

   /* Changes for Optional Scrap */
   x_est_scrap_acct_flag           NUMBER := 0;


   /* Add for bug 4171498 */
   CURSOR opseq_cur IS
      SELECT  cscav.WIP_ENTITY,
              cscav.OP_SEQ_NUM,
              cscav.ADJ_VALUE
        FROM ( SELECT  wip_entity_id WIP_ENTITY,
                       operation_seq_num OP_SEQ_NUM,
                       SUM((NVL(new_unit_cost,0) - NVL(old_unit_cost,0)) * adjustment_quantity) adj_value
                  FROM cst_std_cost_adj_values
                 WHERE organization_id = i_org_id
                   AND cost_update_id = i_update_id
                   AND transaction_type NOT IN (1, 2, 4, 5)
              GROUP BY wip_entity_id, operation_seq_num
                HAVING SUM((NVL(new_unit_cost,0) - NVL(old_unit_cost,0)) * adjustment_quantity) <> 0
             ) cscav,
               wip_entities we
        WHERE  cscav.wip_entity = we.wip_entity_id
          AND  we.organization_id = i_org_id
          AND  we.entity_type = 5
     ORDER BY  wip_entity, op_seq_num;

BEGIN
   l_stmt_num := 0;
   l_err_code := '';
   l_err_num := 0;
   l_err_msg := '';
   l_adj_value := 0;

   l_stmt_num := 10;

   For opseq_rec IN opseq_cur
      LOOP

        l_stmt_num := 15;
        x_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(opseq_rec.WIP_ENTITY,
                                               l_err_num, l_err_msg);

        /* Update operation cost in WOY only if ESA is enabled */
        IF x_est_scrap_acct_flag = 1 THEN

           l_stmt_num := 20;

           l_stmt_num := 30;

              update wip_operation_yields
              set last_update_date = sysdate,
                  last_updated_by = i_user_id,
                  last_update_login = i_login_id,
                  request_id = i_req_id,
                  program_application_id = i_prg_appl_id,
                  program_id = i_prg_id,
                  program_update_date = sysdate,
                  operation_cost = nvl(operation_cost,0) + nvl(opseq_rec.ADJ_VALUE,0),
                  status = 1
              where organization_id = i_org_id
              and wip_entity_id = opseq_rec.WIP_ENTITY
              and operation_seq_num = opseq_rec.OP_SEQ_NUM;
	end if;

    END LOOP;

    return 1;

EXCEPTION
   when process_error then
      o_err_num := l_err_num;
      o_err_code := l_err_code;
      o_err_msg := l_err_msg;
      return 0;

   when others then
      rollback;
      o_err_num := SQLCODE;
      o_err_msg := 'CSTPOYLD.cost_update_adjustment: (' || to_char(l_stmt_num) || '):' || substrb(SQLERRM,1,200);
      return 0;
END cost_update_adjustment;
-------------------------------------------------------------------------------
end CSTPOYLD;

/
