--------------------------------------------------------
--  DDL for Package Body INV_TXN_PURGE_WORKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TXN_PURGE_WORKER" AS
/* $Header: INVTPGWB.pls 120.1.12000000.2 2007/02/21 23:11:53 yssingh ship $ */

--Procedure to purge the transaction tables


  PROCEDURE Txn_Purge_Worker(
			    x_errbuf            OUT NOCOPY VARCHAR2
			   ,x_retcode           OUT NOCOPY NUMBER
                      	   ,p_organization_id   IN  NUMBER
                     	   ,p_min_date 		IN  VARCHAR2
 		     	   ,p_max_date          IN  VARCHAR2
                          )
     IS

    l_debug          NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);


    l_min_date       DATE := fnd_date.displaydate_to_date(p_min_date);
    l_max_date       DATE := fnd_date.displaydate_to_date(p_max_date);

    l_bulk_limit     NUMBER := 2000;

    TYPE rowidtab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    rowid_list       rowidtab;

    TYPE tranidtab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    tranid_list      tranidtab;

    l_ret boolean;
    l_tempvar number;

    l_count number;
    l_total_count number;
    l_total_count1 number;
    l_total_count2 number;
    l_total_count3 number;
    l_total_count4 number;

--Bug3681437:Used the trunc cmd for transaction_date validation for all 5 cursors below

    -- bug 4951747 : removed trunc to leverage MTL_MATERIAL_TRANSACTIONS_N5 index

    -- Bug 5894075 : removed trunc from all the queries and added - (1/(24*3600)) to max date
    CURSOR c_mmt IS
       SELECT ROWID, TRANSACTION_ID
       FROM     MTL_MATERIAL_TRANSACTIONS
       WHERE    transaction_date >= l_min_date and transaction_date <= l_max_date + 1-(1/(24*3600))
                AND organization_id = p_organization_id;

    CURSOR c_mmta IS
       SELECT ROWID
       FROM     MTL_MATERIAL_TXN_ALLOCATIONS
       WHERE    transaction_date >= l_min_date and transaction_date <= l_max_date + 1-(1/(24*3600))
                AND organization_id = p_organization_id;

    CURSOR c_mtlt IS
       SELECT ROWID
       FROM     MTL_TRANSACTION_LOT_NUMBERS
       WHERE    transaction_date >= l_min_date and transaction_date <= l_max_date + 1-(1/(24*3600))
                AND organization_id = p_organization_id;

    CURSOR c_mut IS
       SELECT ROWID
       FROM     MTL_UNIT_TRANSACTIONS
       WHERE    transaction_date >= l_min_date and transaction_date <= l_max_date + 1-(1/(24*3600))
                AND organization_id = p_organization_id;

    -- bug 4951747 : removed trunc to leverage MTL_TRANSACTION_ACCOUNTS_N5 index
    CURSOR c_mta IS
       SELECT ROWID
       FROM     MTL_TRANSACTION_ACCOUNTS
       WHERE    transaction_date >= l_min_date and transaction_date <= l_max_date + 1-(1/(24*3600))
                AND organization_id = p_organization_id;

BEGIN

    SAVEPOINT PURGE_SAVEPOINT;

    IF (l_debug = 1) THEN
    	 inv_log_util.trace('Purge Worker : OrgId='||p_organization_id||',Min_Date='||l_min_date||',Max_Date='||l_max_date,'TXN_PURGE_WORKER', 9);
    END IF;

    --Check if max_date is less than min_date, if yes error out.
    IF  l_max_date < l_min_date THEN
	    IF (l_debug = 1) THEN
	    	 inv_log_util.trace('Max_date cannot be less than min_date', 'TXN_PURGE_WORKER', 9);
	    END IF;
            RAISE fnd_api.g_exc_error;
    END IF;

    -- Validate the Organization passed to ensure that it has no OPEN
    -- accounting periods for the Max_date specified
    begin
          SELECT 1
              into l_tempvar
            FROM ORG_ACCT_PERIODS
           WHERE ORGANIZATION_ID = p_organization_id
             AND SCHEDULE_CLOSE_DATE >= l_max_date
             AND OPEN_FLAG = 'N' AND ROWNUM < 2;
    exception
       WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          inv_log_util.trace('Purge Worker : Accounting Period is not closed for the Max_date','TXN_PURGE_WORKER', 9);
        END IF;
        l_ret := fnd_concurrent.set_completion_status('ERROR', 'Error');

        x_retcode  := 2;
        x_errbuf   := 'Error';
	return;
    end ;

    -- *************** Purge from MTL_MATERIAL_TXN_ALLOCATIONS ****************
    l_total_count := 0;
    OPEN c_mmta;
    LOOP
	l_count := 0;

        FETCH c_mmta bulk collect INTO rowid_list limit l_bulk_limit;

	IF rowid_list.first IS NULL THEN
	    IF (l_debug = 1) THEN
    		 inv_log_util.trace('Purge Worker : No more Records to delete from MMTA','TXN_PURGE_WORKER', 9);
	    END IF;
	    EXIT;
        END IF;

	FORALL i IN rowid_list.first .. rowid_list.last
		DELETE FROM MTL_MATERIAL_TXN_ALLOCATIONS
		WHERE ROWID = rowid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count := l_total_count + l_count;
	EXIT WHEN c_mmta%notfound;
    END LOOP;
    CLOSE c_mmta;

    IF (l_debug = 1) THEN
       inv_log_util.trace('Deleted :'||l_total_count||' rows from MMTA', 'TXN_PURGE_WORKER', 9);
    END IF;

    -- *************** Purge from MTL_TRANSACTION_LOT_NUMBERS ******************
    l_total_count := 0;
    OPEN c_mtlt;
    LOOP
	l_count := 0;

        FETCH c_mtlt bulk collect INTO rowid_list limit l_bulk_limit;

	IF rowid_list.first IS NULL THEN
	    IF (l_debug = 1) THEN
    		 inv_log_util.trace('Purge Worker : No more Records to delete from MTLN','TXN_PURGE_WORKER', 9);
	    END IF;
	    EXIT;
        END IF;

	FORALL i IN rowid_list.first .. rowid_list.last
		DELETE FROM MTL_TRANSACTION_LOT_NUMBERS
		WHERE ROWID = rowid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count := l_total_count + l_count;
	EXIT WHEN c_mtlt%notfound;
    END LOOP;
    CLOSE c_mtlt;

    IF (l_debug = 1) THEN
       inv_log_util.trace('Deleted :'||l_total_count||' rows from MTLN', 'TXN_PURGE_WORKER', 9);
    END IF;

    -- *************** Purge from MTL_UNIT_TRANSACTIONS ******************
    l_total_count := 0;
    OPEN c_mut;
    LOOP
	l_count := 0;

        FETCH c_mut bulk collect INTO rowid_list limit l_bulk_limit;

	IF rowid_list.first IS NULL THEN
	    IF (l_debug = 1) THEN
    		 inv_log_util.trace('Purge Worker : No more Records to delete from MUT','TXN_PURGE_WORKER', 9);
	    END IF;
	    EXIT;
        END IF;

	FORALL i IN rowid_list.first .. rowid_list.last
		DELETE FROM MTL_UNIT_TRANSACTIONS
		WHERE ROWID = rowid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count := l_total_count + l_count;
	EXIT WHEN c_mut%notfound;
    END LOOP;
    CLOSE c_mut;

    IF (l_debug = 1) THEN
       inv_log_util.trace('Deleted :'||l_total_count||' rows from MUT', 'TXN_PURGE_WORKER', 9);
    END IF;

    -- *************** Purge from MTL_TRANSACTION_ACCOUNTS ******************
    l_total_count := 0;
    OPEN c_mta;
    LOOP
	l_count := 0;

        FETCH c_mta bulk collect INTO rowid_list limit l_bulk_limit;

	IF rowid_list.first IS NULL THEN
	    IF (l_debug = 1) THEN
    		 inv_log_util.trace('Purge Worker : No more Records to delete from MTA','TXN_PURGE_WORKER', 9);
	    END IF;
	    EXIT;
        END IF;

	FORALL i IN rowid_list.first .. rowid_list.last
		DELETE FROM MTL_TRANSACTION_ACCOUNTS
		WHERE ROWID = rowid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count := l_total_count + l_count;
	EXIT WHEN c_mta%notfound;
    END LOOP;
    CLOSE c_mta;

    IF (l_debug = 1) THEN
       inv_log_util.trace('Deleted :'||l_total_count||' rows from MTA', 'TXN_PURGE_WORKER', 9);
    END IF;


    -- *************** Purge from MMT and dependent tables ********************
    l_total_count1 := 0;
    l_total_count2 := 0;
    l_total_count3 := 0;
    l_total_count4 := 0;
    l_total_count  := 0;

    OPEN c_mmt;
    LOOP

        FETCH c_mmt bulk collect INTO rowid_list,tranid_list limit l_bulk_limit;

	IF tranid_list.first IS NULL THEN
	    IF (l_debug = 1) THEN
    		 inv_log_util.trace('Purge Worker : No more Records to delete from MMT for dependant tables','TXN_PURGE_WORKER', 9);
	    END IF;
	    EXIT;
        END IF;

        -- *************** Purge from WIP_SCRAP_VALUES ************************
	l_count := 0;

	FORALL i IN tranid_list.first .. tranid_list.last
		DELETE FROM WIP_SCRAP_VALUES
		WHERE TRANSACTION_ID = tranid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count1 := l_total_count1 + l_count;

        -- *************** Purge from MTL_CST_ACTUAL_COST_DETAILS ********************
        l_count := 0;

	FORALL i IN tranid_list.first .. tranid_list.last
		DELETE FROM MTL_CST_ACTUAL_COST_DETAILS
		WHERE TRANSACTION_ID = tranid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count2 := l_total_count2 + l_count;

        -- *************** Purge from MTL_CST_TXN_COST_DETAILS ********************
        l_count := 0;

	FORALL i IN tranid_list.first .. tranid_list.last
		DELETE FROM MTL_CST_TXN_COST_DETAILS
		WHERE TRANSACTION_ID = tranid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count3 := l_total_count3 + l_count;

        -- *************** Purge from MTL_ACTUAL_COST_SUBELEMENT ********************
        l_count := 0;

	FORALL i IN tranid_list.first .. tranid_list.last
		DELETE FROM MTL_ACTUAL_COST_SUBELEMENT
		WHERE TRANSACTION_ID = tranid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count4 := l_total_count4 + l_count;

        -- *************** Purge from MTL_MATERIAL_TRANSACTIONS ********************
        l_count := 0;

	FORALL i IN rowid_list.first .. rowid_list.last
		DELETE FROM MTL_MATERIAL_TRANSACTIONS
		WHERE ROWID = rowid_list(i);

	l_count := SQL%ROWCOUNT;
	COMMIT;
	l_total_count := l_total_count + l_count;

        EXIT WHEN c_mmt%notfound;
    END LOOP;
    CLOSE c_mmt;

    IF (l_debug = 1) THEN
	inv_log_util.trace('Deleted :'||l_total_count1||' rows from WSV', 'TXN_PURGE_WORKER', 9);
	inv_log_util.trace('Deleted :'||l_total_count2||' rows from MCACD', 'TXN_PURGE_WORKER', 9);
	inv_log_util.trace('Deleted :'||l_total_count3||' rows from MCTCD', 'TXN_PURGE_WORKER', 9);
	inv_log_util.trace('Deleted :'||l_total_count4||' rows from MACS', 'TXN_PURGE_WORKER', 9);
	inv_log_util.trace('Deleted :'||l_total_count ||' rows from MMT', 'TXN_PURGE_WORKER', 9);
    END IF;

    l_ret := fnd_concurrent.set_completion_status('NORMAL', 'Success');

    x_retcode  := 0;
    x_errbuf   := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    IF (l_debug = 1) THEN
       inv_log_util.trace('Error :'||substr(sqlerrm, 1, 100), 'TXN_PURGE_WORKER', 1);
    END IF;

      IF c_mmt%ISOPEN THEN
         CLOSE c_mmt;
      END IF;

      IF c_mmta%ISOPEN THEN
         CLOSE c_mmta;
      END IF;

      IF c_mtlt%ISOPEN THEN
         CLOSE c_mtlt;
      END IF;

      IF c_mut%ISOPEN THEN
         CLOSE c_mut;
      END IF;

      IF c_mta%ISOPEN THEN
         CLOSE c_mta;
      END IF;

    ROLLBACK TO PURGE_SAVEPOINT;

    l_ret := fnd_concurrent.set_completion_status('ERROR', 'Error');

    x_retcode  := 2;
    x_errbuf   := 'Error';

 END Txn_Purge_Worker;

END INV_TXN_PURGE_WORKER;

/
