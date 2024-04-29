--------------------------------------------------------
--  DDL for Package Body MSC_CL_MISCELLANEOUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_MISCELLANEOUS" AS -- body
/* $Header: MSCCLGAB.pls 120.0 2005/05/25 17:59:40 appldev noship $ */
TYPE number_arr IS TABLE OF NUMBER;
TYPE date_arr IS TABLE OF DATE;


              t_inv_item_id          number_arr;
              t_sr_inv_item_id       number_arr;
	      t_org_id               number_arr;
              t_sr_org_id            number_arr;
              t_supplier_id          number_arr;
              t_sr_supplier_id       number_arr;
	      t_supp_site_id         number_arr;
	      t_sr_supp_site_id      number_arr;
	      t_sr_rule_id           number_arr;
	      t_sr_level             number_arr;
	      t_assignment_set_id    number_arr;

	      t_start_date           date_arr;

	      t_ins_inv_item_id       number_arr;
	      t_ins_org_id            number_arr;
	      t_ins_trx_date          date_arr;
	      t_trx_qty               number_arr;
	      t_trx_type              number_arr;
              t_ins_sr_org_id         number_arr;
	      t_ins_supp_id           number_arr;
	      t_ins_supp_site_id      number_arr;

  lv_pbs number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);
  c_count number := 0;
  G_START_SH  number := nvl(TO_NUMBER(FND_PROFILE.VALUE('MSC_START_SOURCING_HISTORY')),-1);

   PROCEDURE load_sourcing_history
             ( arg_instance_id       IN NUMBER,
               arg_refresh_number    IN NUMBER,
               arg_current_date      IN DATE,
               arg_current_user      IN NUMBER,
               arg_request_id        IN NUMBER )
IS

   lv_assignment_set_id     NUMBER;
   lv_task_start_time       DATE;

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   cur_c1              CurTyp;
   LV_SQL_STMT_NEW     varchar2(4000);


  lv_sql_stmt        varchar2(2000);
  lv_sql_stmt_app       varchar2(200);
  lv_starting_date   date;
BEGIN

    v_instance_id    := arg_instance_id;
    v_refresh_number := arg_refresh_number;
    v_current_date   := arg_current_date;
    v_current_user   := arg_current_user;
    v_request_id     := arg_request_id;

    SELECT DECODE( M2A_DBLINK,
                   NULL, ' ',
                   '@'||M2A_DBLINK)
      INTO v_dblink
      FROM MSC_APPS_INSTANCES
     WHERE INSTANCE_ID= arg_instance_id;

   lv_task_start_time:= SYSDATE;

   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SOURCING_HISTORY');
   LOG_MESSAGE(FND_MESSAGE.GET);

   if (G_START_SH >= 0) then
      --lv_starting_date := sysdate - G_START_SH;
      lv_sql_stmt_app := '  and trunc(x.transaction_date) >= trunc(add_months(sysdate,-('||G_START_SH||')))';
   else
       lv_sql_stmt_app := '   ';
   end if;

   lv_sql_stmt_new := ' insert into MSC_SOURCING_TRANSACTIONS(  '
                      ||' INVENTORY_ITEM_ID,  '
			 ||' ORGANIZATION_ID,  '
			 ||' TRANSACTION_DATE, '
			 ||' TRANSACTION_QTY,  '
			 ||' TRANSACTION_TYPE) '
                ||' SELECT inventory_item_id, organization_id, '
                ||'        transaction_date, transaction_qty , 1 '
                ||'   FROM MRP_AP_INNER_ORG_TRXS_V'||v_dblink||' x'
		||'   where x.inventory_item_id is not null  '
		|| lv_sql_stmt_app ;

  execute immediate lv_sql_stmt_new;
  commit;

   lv_sql_stmt_new := ' insert into MSC_SOURCING_TRANSACTIONS(  '
                      ||' INVENTORY_ITEM_ID,  '
			 ||' ORGANIZATION_ID,  '
			 ||' SOURCE_ORG_ID,  '
			 ||' TRANSACTION_DATE, '
			 ||' TRANSACTION_QTY,  '
			 ||' TRANSACTION_TYPE) '
                ||' SELECT inventory_item_id, organization_id, '
                ||'        source_org_id, transaction_date, transaction_qty ,2 '
                ||'   FROM MRP_AP_INTER_ORG_TRXS_V'||v_dblink||' x'
		||'   where x.inventory_item_id is not null  '
		|| lv_sql_stmt_app ;

  execute immediate lv_sql_stmt_new;
  commit;

   lv_sql_stmt_new := ' insert into MSC_SOURCING_TRANSACTIONS(  '
                      ||' INVENTORY_ITEM_ID,  '
			 ||' SUPPLIER_ID,  '
			 ||' SUPPLIER_SITE_ID,  '
			 ||' TRANSACTION_DATE, '
			 ||' TRANSACTION_QTY,  '
			 ||' TRANSACTION_TYPE) '
                ||' SELECT inventory_item_id, SUPPLIER_ID,nvl(SUPPLIER_SITE_ID,-1), '
                ||'        transaction_date, transaction_qty ,3 '
                ||'   FROM MRP_AP_PO_SUPPLIER_TRXS_V'||v_dblink||' x'
		||'   where x.inventory_item_id is not null  '
		|| lv_sql_stmt_app ;

  execute immediate lv_sql_stmt_new;
  commit;

     load_sourcing_history_sub1( lv_assignment_set_id);

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                     TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     LOG_MESSAGE(FND_MESSAGE.GET);

    EXCEPTION
       WHEN OTHERS THEN
          RAISE;

 END load_sourcing_history;

 PROCEDURE load_po_receipts
             ( arg_instance_id       IN NUMBER,
               arg_org_sub_str       IN VARCHAR2:= NULL,
               arg_refresh_number    IN NUMBER,
               arg_current_date      IN DATE,
               arg_current_user      IN NUMBER,
               arg_request_id        IN NUMBER )
IS

   lv_assignment_set_id     NUMBER;
   lv_task_start_time       DATE;

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type
   cur_c1              CurTyp;
   LV_SQL_STMT_NEW     varchar2(4000);


  lv_sql_stmt        varchar2(2000);
  lv_sql_stmt_app       varchar2(200);
  lv_starting_date   date;
BEGIN

    v_instance_id    := arg_instance_id;
    v_refresh_number := arg_refresh_number;
    v_current_date   := arg_current_date;
    v_current_user   := arg_current_user;
    v_request_id     := arg_request_id;

    SELECT DECODE( M2A_DBLINK,
                   NULL, ' ',
                   '@'||M2A_DBLINK)
      INTO v_dblink
      FROM MSC_APPS_INSTANCES
     WHERE INSTANCE_ID= arg_instance_id;

   lv_task_start_time:= SYSDATE;

   FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_TASK_START');
   FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_PO_RECEIPTS');
   LOG_MESSAGE(FND_MESSAGE.GET);

   if (G_START_SH >= 0) then
      --lv_starting_date := sysdate - G_START_SH;
      lv_sql_stmt_app := '  and trunc(x.transaction_date) >= trunc(add_months(sysdate,-('||G_START_SH||')))';
   else
       lv_sql_stmt_app := '   ';
   end if;
log_message(lv_sql_stmt_app);
   lv_sql_stmt_new := ' insert into MSC_PO_RECEIPTS(  '
                         ||' RECEIPT_ID,  '
                         ||' SR_INSTANCE_ID,  '
                         ||' INVENTORY_ITEM_ID,  '
                         ||' ORGANIZATION_ID,  '
			 ||' SUPPLIER_ID,  '
			 ||' SUPPLIER_SITE_ID,  '
			 ||' TRANSACTION_DATE, '
			 ||' TRANSACTION_QTY,  '
			 ||' LAST_UPDATE_DATE,  '
			 ||' LAST_UPDATED_BY,  '
			 ||' CREATION_DATE,  '
			 ||' CREATED_BY)     '
                ||' SELECT x.receipt_id,:v_instance_id,item.inventory_item_id,x.organization_id, TP.TP_ID,nvl(TPS.TP_SITE_ID,-1), '
                ||'        x.transaction_date, x.transaction_qty ,:v_current_date, :v_current_user, '
                ||' :v_current_date, :v_current_user'
                ||'   FROM MRP_AP_PO_SUPPLIER_TRXS_V'||v_dblink||' x, MSC_TP_ID_LID tp, MSC_ITEM_ID_LID item, '
                ||'   MSC_TP_SITE_ID_LID tps     '
		||'   where x.inventory_item_id is not null and  '
		||'   x.inventory_item_id = item.sr_inventory_item_id and  '
		||'   item.sr_instance_id= :v_instance_id and '
		||'   x.supplier_id = tp.sr_tp_id and  '
		||'   tp.sr_instance_id= :v_instance_id and '
		||'   x.supplier_site_id(+) = tps.sr_tp_site_id  and '
		||'   tps.partner_type = 1 and '
		||'   tp.partner_type = 1 and '
		||'   tps.sr_instance_id= :v_instance_id and '
		||'    x.organization_id '|| arg_org_sub_str
		|| lv_sql_stmt_app ;
log_message(lv_sql_stmt_new);
  EXECUTE IMMEDIATE lv_sql_stmt_new
  USING v_instance_id, v_current_date, v_current_user,v_current_date, v_current_user, v_instance_id, v_instance_id, v_instance_id;

  commit;

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                     TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     LOG_MESSAGE(FND_MESSAGE.GET);

    EXCEPTION
       WHEN OTHERS THEN
          RAISE;

 END Load_PO_Receipts;

   PROCEDURE load_sourcing_history_sub1
             ( arg_assignment_set_id IN NUMBER )
IS
   lv_source_type               NUMBER;
   lv_sr_inventory_item_id      NUMBER;
   lv_inventory_item_id         NUMBER;
   lv_organization_id           NUMBER;
   lv_source_org_id             NUMBER;
   lv_sr_supplier_id            NUMBER;
   lv_supplier_id               NUMBER;
   lv_sr_supplier_site_id       NUMBER;
   lv_supplier_site_id          NUMBER;
   lv_start_date                DATE;
   lv_end_date                  DATE;
   lv_historical_allocation     NUMBER;
   lv_sourcing_rule_id          NUMBER;
   lv_sourcing_level            NUMBER;

   lv_assignment_set_id            number;
   lv_p_assignment_set_id          number;

   lv_p_source_type             NUMBER;
   lv_p_inventory_item_id       NUMBER;
   lv_p_organization_id         NUMBER;
   lv_p_source_org_id           NUMBER;
   lv_p_supplier_id             NUMBER;
   lv_p_supplier_site_id        NUMBER;
   lv_p_start_date              DATE;
   lv_p_sourcing_level          NUMBER;

   lv_total_alloc_qty           NUMBER;

   start_date_new		DATE;
   start_date_offset		NUMBER;

   CURSOR cur_item_sourcing_history  IS
   SELECT
          iil.sr_inventory_item_id,
          iil.inventory_item_id,
          sr_view.organization_id,
          sr_view.source_org_id,
          til.sr_tp_id,
          til.tp_id,
          nvl(tsil.sr_tp_site_id,-1) sr_tp_site_id,
          tsil.tp_site_id,
          sr_view.effective_date,
          sr_view.sourcing_rule_id,
          sr_view.sourcing_level,
	  msa.assignment_set_id
     FROM msc_assignment_sets   msa,
          MSC_BOD_SOURCING_RULES_V sr_view,
          MSC_ITEM_ID_LID iil,
          MSC_TP_ID_LID til,
          MSC_TP_SITE_ID_LID tsil
    WHERE iil.inventory_item_id= sr_view.inventory_item_id
      AND iil.sr_instance_id= sr_view.sr_instance_id
      AND til.tp_id(+)= sr_view.supplier_id
      AND til.sr_instance_id(+)= sr_view.sr_instance_id
      AND til.partner_type(+)= 1
      AND tsil.tp_site_id(+)= sr_view.supplier_site_id
      AND tsil.sr_instance_id(+)= sr_view.sr_instance_id
      AND tsil.partner_type(+)= 1
      AND sr_view.effective_date <= v_current_date
      AND NVL(sr_view.disable_date, TRUNC(v_current_date) + 1)
                  > TRUNC(v_current_date)
      AND sr_view.assignment_set_id= msa.assignment_set_id
      and msa.sr_instance_id = v_instance_id
    ORDER BY
          msa.assignment_set_id,
          sr_view.organization_id,
          sr_view.inventory_item_id,
          sr_view.sourcing_level ASC;

BEGIN

    lv_end_date := v_current_date;

	/* Added this new Profile opt MSC_SH_START_DATE_OFFSET(in months)
          For enfore sourcing splits
	This profile will control the start date of Sourcing History calculation
	for those transactions that are not calculated anytime before in the Destination*/

    SELECT TO_NUMBER(FND_PROFILE.VALUE('MSC_START_SOURCING_HISTORY'))
    into start_date_offset
    from dual;

    IF (start_date_offset IS NOT NULL) THEN
        start_date_new := add_months(v_current_date,-start_date_offset);
    END IF;

    BEGIN
     OPEN cur_item_sourcing_history;
      fetch cur_item_sourcing_history
       bulk collect into
              t_sr_inv_item_id,
	      t_inv_item_id,
	      t_org_id,
              t_sr_org_id,
	      t_sr_supplier_id,
              t_supplier_id,
	      t_sr_supp_site_id,
	      t_supp_site_id,
	      t_start_date,
	      t_sr_rule_id,
	      t_sr_level,
	      t_assignment_set_id;

  IF t_inv_item_id.COUNT > 0  then

     FOR i in 1..t_inv_item_id.COUNT LOOP

       IF t_inv_item_id(i)       = lv_p_inventory_item_id AND
          t_org_id(i)            = lv_p_organization_id   AND
	  t_assignment_set_id(i) = lv_p_assignment_set_id AND
          t_sr_level(i)    > lv_p_sourcing_level    THEN
	   null;
          ---GOTO fetch_item_sourcing_history;
       ELSE

       lv_p_sourcing_level   := t_sr_level(i);
       lv_p_inventory_item_id:= t_inv_item_id(i);
       lv_p_organization_id  := t_org_id(i);
       lv_p_assignment_set_id := t_assignment_set_id(i);
       lv_start_date :=  t_start_date(i);

	/* if the profile option is set and the effectivity date of the Sourcing rule is
           greater than the new start date (based on offset days as calculated above) ,
           then the start date will be the effectivity date.If the parameter Purge SH has been set in ODS
           then the table msc_sourcing_history would have been deleted and relcalculation will be
          done from this new date */

       IF (start_date_offset IS NOT NULL) THEN
          IF start_date_new > lv_start_date THEN
                lv_start_date := start_date_new - 1;
          ELSE
                lv_start_date := lv_start_date - 1;
                       /* added this code since the transactions on effectivity date of Sourcing rule
                          were not getting calculated for Bug: 2069633 */
          END IF;
       END IF;

       get_sourcing_history(
              t_sr_org_id(i),
              t_sr_supplier_id(i),
              t_supplier_id(i),
	      t_sr_supp_site_id(i),
	      t_supp_site_id(i),
              t_sr_inv_item_id(i),
	      t_inv_item_id(i),
	      t_org_id(i),
	      t_sr_rule_id(i),
              lv_start_date,
              v_current_date);

       END IF;
     END LOOP;

END IF;


    EXCEPTION
       WHEN OTHERS THEN
	  log_message('Error within load_sourcing_history_sub1: '||SQLERRM);
          IF cur_item_sourcing_history%ISOPEN THEN
             CLOSE cur_item_sourcing_history;
          END IF;
          RAISE;
    END;
EXCEPTION
   when others then
       log_message('Error in  load_sourcing_history_sub1: '||SQLERRM);

END load_sourcing_history_sub1;



   PROCEDURE get_sourcing_history
             ( arg_source_org           IN NUMBER,
               arg_sr_supplier_id       IN NUMBER,
               arg_supplier_id          IN NUMBER,
               arg_sr_supplier_site_id  IN NUMBER,
               arg_supplier_site_id     IN NUMBER,
               arg_sr_item_id           IN NUMBER,
               arg_item_id           IN NUMBER,
               arg_org_id            IN NUMBER,
               arg_sourcing_rule_id  IN NUMBER,
               arg_start_date        IN DATE,
               arg_end_date          IN DATE )
   IS

   --PRAGMA AUTONOMOUS_TRANSACTION;

   L_ST_INNER_ORG      CONSTANT NUMBER:= 1;
   L_ST_INTER_ORG      CONSTANT NUMBER:= 2;
   L_ST_PO_SUPPLIER    CONSTANT NUMBER:= 3;

   lv_rowid                     UROWID;
   lv_start_date                DATE;
   lv_historical_allocation     NUMBER;
   lv_record_exists             NUMBER;
   lv_total_alloc_qty           NUMBER;
   lv_source_type               NUMBER;

   BEGIN

   BEGIN
     SELECT msh.ROWID,
            msh.last_calculated_date,
            msh.historical_allocation,
            SYS_YES
       INTO lv_rowid,
            lv_start_date,
            lv_historical_allocation,
            lv_record_exists
       FROM MSC_SOURCING_HISTORY msh
      WHERE msh.inventory_item_id= arg_item_id
        AND msh.organization_id=   arg_org_id
        AND msh.sr_instance_id=    v_instance_id
        AND msh.sourcing_rule_id=  arg_sourcing_rule_id
        AND NVL( msh.source_org_id,-1)= NVL( arg_source_org,-1)
        AND NVL( msh.supplier_id,-1)= NVL ( arg_supplier_id,-1)
        AND NVL( msh.supplier_site_id,-1)= NVL( arg_supplier_site_id,-1);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        lv_start_date           := arg_start_date;
	/* subtracting by minus 1, is added since the transactions done on the same day as the
           effectivity date were not getting calculated */
                    --lv_start_date := lv_start_date - 1;
                   /* commented this code since the transactions on effectivity date of Sourcing rule were not getting
                      calculated for Bug: 2069633 */
        lv_historical_allocation:= 0;
        lv_record_exists        := SYS_NO;
   END;

   IF lv_start_date = v_current_date THEN
      RETURN;
   END IF;

   IF lv_start_date< arg_start_date THEN
      lv_historical_allocation:= 0;
      lv_start_date:= arg_start_date;
   END IF;

  /*  These are the Debug messages
   FND_MESSAGE.SET_NAME('MSC', 'MSC_SH_TASK_START');
   FND_MESSAGE.SET_TOKEN('ITEM_ID:',arg_item_id);
   LOG_MESSAGE(FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('MSC', 'MSC_SH_TASK_START');
   FND_MESSAGE.SET_TOKEN('START_DATE:',lv_start_date);
   LOG_MESSAGE(FND_MESSAGE.GET);
*/

   IF arg_source_org IS NULL THEN
         lv_source_type := L_ST_PO_SUPPLIER;
   ELSIF arg_source_org= arg_org_id THEN
         lv_source_type := L_ST_INNER_ORG;
   ELSE  lv_source_type := L_ST_INTER_ORG;
   END IF;

       IF lv_source_type= L_ST_INNER_ORG THEN

            select GREATEST(NVL(SUM(transaction_qty),0),0)
	       into lv_total_alloc_qty
	       from MSC_SOURCING_TRANSACTIONS
	      where inventory_item_id = arg_sr_item_id
	        and organization_id = arg_org_id
		and transaction_date > lv_start_date
		and trunc(transaction_date) <= trunc(arg_end_date)
		and transaction_type = 1;

       ELSIF lv_source_type= L_ST_INTER_ORG THEN

            select GREATEST(NVL(SUM(transaction_qty),0),0)
	       into lv_total_alloc_qty
	       from MSC_SOURCING_TRANSACTIONS
	      where inventory_item_id = arg_sr_item_id
	        and organization_id = arg_org_id
		and SOURCE_ORG_ID = arg_source_org
		and transaction_date > lv_start_date
		and trunc(transaction_date) <= trunc(arg_end_date)
		and transaction_type = 2;

       ELSIF lv_source_type= L_ST_PO_SUPPLIER THEN

            select GREATEST(NVL(SUM(transaction_qty),0),0)
	       into lv_total_alloc_qty
	       from MSC_SOURCING_TRANSACTIONS
	      where inventory_item_id = arg_sr_item_id
	        and SUPPLIER_ID = arg_sr_supplier_id
		and SUPPLIER_SITE_ID = arg_sr_supplier_site_id
		and transaction_date > lv_start_date
		and trunc(transaction_date) <= trunc(arg_end_date)
		and transaction_type = 3;

       END IF;

       lv_total_alloc_qty:= lv_total_alloc_qty +
                            NVL( lv_historical_allocation,0);

       IF lv_record_exists= SYS_YES THEN

       UPDATE MSC_SOURCING_HISTORY
          SET historical_allocation= lv_total_alloc_qty,
              last_calculated_date = v_current_date,
              LAST_UPDATED_BY = v_current_user,
              LAST_UPDATE_DATE = v_current_date
        WHERE rowid= lv_rowid;
	  c_count:= c_count+1;

       ELSE

       INSERT INTO MSC_SOURCING_HISTORY
            ( inventory_item_id,
              organization_id,
              sourcing_rule_id,
              source_org_id,
              source_sr_instance_id,
              supplier_id,
              supplier_site_id,
              historical_allocation,
              refresh_number,
              last_calculated_date,
              sr_instance_id,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              CREATION_DATE,
              CREATED_BY)
        VALUES
            ( arg_item_id,
              arg_org_id,
              arg_sourcing_rule_id,
              arg_source_org,
              v_instance_id,
              arg_supplier_id,
              arg_supplier_site_id,
              lv_total_alloc_qty,
              v_refresh_number,
              v_current_date,
              v_instance_id,
              v_current_user,
              v_current_date,
              v_current_date,
              v_current_user);

	  c_count:= c_count+1;
       END IF;


  IF c_count>lv_pbs  THEN
   COMMIT;
  END IF;

   END get_sourcing_history;


  FUNCTION inner_org_trx_qty
                 ( arg_inventory_item_id IN NUMBER,
                   arg_organization_id   IN NUMBER,
                   arg_start_date        IN DATE,
                   arg_end_date          IN DATE)
  RETURN NUMBER
  IS
     lv_sql_stmt         VARCHAR2(2000);
     lv_total_alloc_qty  NUMBER;
  BEGIN

    lv_sql_stmt:=
       'SELECT GREATEST(NVL(SUM(transaction_qty),0),0)'
    ||'   FROM MRP_AP_INNER_ORG_TRXS_V'||v_dblink||' x'
    ||'  WHERE trunc(x.transaction_date) >  trunc(:arg_start_date)'
    ||'    AND trunc(x.transaction_date) <= trunc(:arg_end_date)'
    ||'    AND x.inventory_item_id = :arg_inventory_item_id'
    ||'    AND x.organization_id   = :arg_organization_id';

    EXECUTE IMMEDIATE lv_sql_stmt
                 INTO lv_total_alloc_qty
                USING arg_start_date,
                      arg_end_date,
                      arg_inventory_item_id,
                      arg_organization_id;

    RETURN lv_total_alloc_qty;

  END inner_org_trx_qty;


  FUNCTION inter_org_trx_qty
                 ( arg_inventory_item_id IN NUMBER,
                   arg_organization_id   IN NUMBER,
                   arg_source_org_id     IN NUMBER,
                   arg_start_date        IN DATE,
                   arg_end_date          IN DATE)
  RETURN NUMBER
  IS
     lv_sql_stmt         VARCHAR2(2000);
     lv_total_alloc_qty  NUMBER;
  BEGIN

    lv_sql_stmt:=
      ' SELECT GREATEST(NVL(SUM(transaction_qty),0),0)'
    ||'   FROM MRP_AP_INTER_ORG_TRXS_V'||v_dblink||' x'
    ||'  WHERE trunc(x.transaction_date) >  trunc(:arg_start_date)'
    ||'    AND trunc(x.transaction_date) <= trunc(:arg_end_date)'
    ||'    AND x.inventory_item_id = :arg_inventory_item_id'
    ||'    AND x.organization_id   = :arg_organization_id'
    ||'    AND x.source_org_id     = :arg_source_org_id';

    EXECUTE IMMEDIATE lv_sql_stmt
                 INTO lv_total_alloc_qty
                USING arg_start_date,
                      arg_end_date,
                      arg_inventory_item_id,
                      arg_organization_id,
                      arg_source_org_id;

    RETURN lv_total_alloc_qty;

  END inter_org_trx_qty;

  FUNCTION po_supplier_trx_qty
                 ( arg_inventory_item_id IN NUMBER,
                   arg_organization_id   IN NUMBER,
                   arg_supplier_id       IN NUMBER,
                   arg_supplier_site_id  IN NUMBER,
                   arg_start_date        IN DATE,
                   arg_end_date          IN DATE)
  RETURN NUMBER
  IS
     lv_sql_stmt         VARCHAR2(2000);
     lv_total_alloc_qty  NUMBER;
  BEGIN

    lv_sql_stmt:=
      ' SELECT GREATEST(NVL(SUM(transaction_qty),0),0)'
    ||'   FROM MRP_AP_PO_SUPPLIER_TRXS_V'||v_dblink||' x'
    ||'  WHERE trunc(x.transaction_date) > trunc(:arg_start_date)'
    ||'    AND trunc(x.transaction_date) <= trunc(:arg_end_date)'
    ||'    AND x.inventory_item_id   = :arg_inventory_item_id'
    ||'    AND x.supplier_id         = :arg_supplier_id'
    ||'    AND NVL(x.supplier_site_id, -1)'
                                 ||' = NVL(:arg_supplier_site_id,-1)';

    EXECUTE IMMEDIATE lv_sql_stmt
                 INTO lv_total_alloc_qty
                USING arg_start_date,
                      arg_end_date,
                      arg_inventory_item_id,
                      arg_supplier_id,
                      arg_supplier_site_id;

    RETURN lv_total_alloc_qty;

  END po_supplier_trx_qty;


   PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN
     IF FND_GLOBAL.CONC_REQUEST_ID > 0 THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
	       null;
     ELSE
         NULL;
     END IF;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
   END LOG_MESSAGE;

END MSC_CL_MISCELLANEOUS;

/
