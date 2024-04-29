--------------------------------------------------------
--  DDL for Package Body OPIMPXIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPIMPXIN" AS
/*$Header: OPIMXINB.pls 120.1 2005/06/08 18:27:52 appldev  $ */


/*{----------------------------------------------
PROCEDURE    CALC_WIP_COMPLETION
----------------------------------------------*/


   Procedure calc_wip_completion(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
                  Org_id        IN  Number) IS

   CURSOR wip_completion_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id=31
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR wip_completion_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mtln.LOT_NUMBER,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mtln.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
          MTL_TRANSACTION_LOT_NUMBERS mtln
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND mmt.transaction_id = mtln.transaction_id
      AND msi.LOT_CONTROL_CODE = 2
      AND mmt.transaction_action_id=31
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID, mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR wip_completion_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
          MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id=31
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


    CURSOR wip_completion_with_lot_val IS
    SELECT   trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mtln.LOT_NUMBER,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
          MTL_TRANSACTION_LOT_NUMBERS mtln,
          MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND mmt.transaction_id = mtln.transaction_id
      AND msi.LOT_CONTROL_CODE = 2
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id=31
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;

 BEGIN

    OPEN wip_completion_no_lot_qty;


edw_log.put_line('CALCWIPCOMP p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCWIPCOMP p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));


    LOOP

      initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);

      FETCH wip_completion_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(wip_completion_no_lot_qty%NOTFOUND) then

edw_log.put_line('NOT FOUND');
         CLOSE wip_completion_no_lot_qty;
         exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_comp_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

/*  edw_log.put_line('Insert_update_push_log');  */
      if (status > 0) then
edw_log.put_line('ERROR');

        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN wip_completion_with_lot_qty;

    LOOP

      initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);
/*  edw_log.put_line('2');  */
      FETCH wip_completion_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;



        if(wip_completion_with_lot_qty%NOTFOUND) then
	edw_log.put_line('NOT FOUND');
          CLOSE wip_completion_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_comp_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
      edw_log.put_line('error');
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN wip_completion_no_lot_val;

    LOOP

      initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);
 /*  edw_log.put_line('3');  */
      FETCH wip_completion_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

 /*  edw_log.put_line('3 after fetch');  */
      if(wip_completion_no_lot_val%NOTFOUND) then
      edw_log.put_line('NOT FOUND');
        CLOSE wip_completion_no_lot_val;
        exit;
      end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_comp_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
      edw_log.put_line('error');
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN wip_completion_with_lot_val;

    LOOP

      initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);
/*  edw_log.put_line('4');  */
      FETCH wip_completion_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(wip_completion_with_lot_val%NOTFOUND) then
          CLOSE wip_completion_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_comp_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
      edw_log.put_line('error');
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('EXCEPTIOn OTHERS');
   edw_log.put_line('Error in calc_wip_completion');
   Retcode := '2';

end calc_wip_completion;


/*}{---------------------------------------------
PROCEDURE    CALC_WIP_ISSUE
----------------------------------------------*/


   Procedure calc_wip_issue(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS

   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;


   CURSOR wip_issue_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id in (1,27,33,34)
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR wip_issue_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.transaction_id = mtln.transaction_id
     AND mmt.ORGANIZATION_ID=Org_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_action_id in (1,27,33,34)
     AND mmt.transaction_source_type_id=5
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR wip_issue_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id in (1,27,33,34)
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR wip_issue_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND mta.accounting_line_type = 1
     AND mmt.transaction_action_id in (1,27,33,34)
     AND mmt.transaction_source_type_id=5
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
  BEGIN


edw_log.put_line('CALCWIPISS p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCWIPISS p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));


    OPEN wip_issue_no_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);

      FETCH wip_issue_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(wip_issue_no_lot_qty%NOTFOUND) then
        CLOSE wip_issue_no_lot_qty;
        exit;
      end if;

         Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_issue_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN wip_issue_with_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);

      FETCH wip_issue_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;



        if(wip_issue_with_lot_qty%NOTFOUND) then
          CLOSE wip_issue_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_issue_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN wip_issue_no_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);

      FETCH wip_issue_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(wip_issue_no_lot_val%NOTFOUND) then
        CLOSE wip_issue_no_lot_val;
        exit;
      end if;

         Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_issue_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN wip_issue_with_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
		 l_lot_number,l_subinventory,l_locator,total_qty,total_value);

      FETCH wip_issue_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(wip_issue_with_lot_val%NOTFOUND) then
          CLOSE wip_issue_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_issue_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_wip_issue');
   Retcode := '2';

end calc_wip_issue;



/*}{----------------------------------------------
PROCEDURE    CALC_ASSEMBLY_RETURN
----------------------------------------------*/

   Procedure calc_assembly_return(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS

   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;

   CURSOR assembly_return_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id=32
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR assembly_return_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_action_id=32
     AND mmt.transaction_source_type_id=5
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR assembly_return_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id=32
      AND mmt.transaction_source_type_id=5
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR assembly_return_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.transaction_id = mtln.transaction_id
     AND mmt.ORGANIZATION_ID=Org_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND mta.accounting_line_type = 1
     AND mmt.transaction_action_id=32
     AND mmt.transaction_source_type_id=5
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
  BEGIN

edw_log.put_line('CALCWIPRET p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCWIPRET p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));
    OPEN assembly_return_no_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH assembly_return_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(assembly_return_no_lot_qty%NOTFOUND) then
        CLOSE assembly_return_no_lot_qty;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_assy_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN assembly_return_with_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH assembly_return_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(assembly_return_with_lot_qty%NOTFOUND) then
          CLOSE assembly_return_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_assy_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN assembly_return_no_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH assembly_return_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(assembly_return_no_lot_val%NOTFOUND) then
        CLOSE assembly_return_no_lot_val;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_assy_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN assembly_return_with_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH assembly_return_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(assembly_return_with_lot_val%NOTFOUND) then
          CLOSE assembly_return_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'wip_assy_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);


      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_assembly_return');
   Retcode := '2';

end calc_assembly_return;




/*}{----------------------------------------------
PROCEDURE    CALC_PO_DELIVERIES
----------------------------------------------*/

   Procedure calc_po_deliveries(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS

   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR po_deliveries_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id in (1,27,29)
      AND mmt.transaction_source_type_id=1
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
      AND MMT.organization_id =  NVL(MMT.owning_organization_id, MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR po_deliveries_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_action_id in (1,27,29)
     AND mmt.transaction_source_type_id=1
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
     AND MMT.organization_id =  NVL(MMT.owning_organization_id, MMT.organization_id)
     AND NVL(MMT.OWNING_TP_TYPE,2) = 2
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR po_deliveries_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id in (1,27,29)
      AND mmt.transaction_source_type_id=1
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
      AND MMT.organization_id =  NVL(MMT.owning_organization_id, MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR po_deliveries_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.transaction_id = mtln.transaction_id
     AND mmt.ORGANIZATION_ID=Org_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND mta.accounting_line_type = 1
     AND mmt.transaction_action_id in (1,27,29)
     AND mmt.transaction_source_type_id=1
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
     AND MMT.organization_id =  NVL(MMT.owning_organization_id, MMT.organization_id)
     AND NVL(MMT.OWNING_TP_TYPE,2) = 2
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
  BEGIN

edw_log.put_line('CALCPODEL p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCPODEL p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));

    OPEN po_deliveries_no_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH po_deliveries_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(po_deliveries_no_lot_qty%NOTFOUND) then
        CLOSE po_deliveries_no_lot_qty;
        exit;
      end if;

         Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'po_del_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN po_deliveries_with_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);



      FETCH po_deliveries_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(po_deliveries_with_lot_qty%NOTFOUND) then
          CLOSE po_deliveries_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'po_del_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN po_deliveries_no_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);

      FETCH po_deliveries_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(po_deliveries_no_lot_val%NOTFOUND) then
        CLOSE po_deliveries_no_lot_val;
        exit;
      end if;

         Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'po_del_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN po_deliveries_with_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH po_deliveries_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(po_deliveries_with_lot_val%NOTFOUND) then
          CLOSE po_deliveries_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'po_del_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_po_deliveries');
   Retcode := '2';

end calc_po_deliveries;


/*}{----------------------------------------------
PROCEDURE    CALC_VALUE_FROM_ORGS
----------------------------------------------*/

   Procedure calc_value_from_orgs(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS
   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;

   CURSOR value_from_orgs_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id in (3,12)
      AND mmt.primary_quantity > 0
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR value_from_orgs_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_action_id in (3,12)
     AND mmt.primary_quantity > 0
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR value_from_orgs_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id in (3,12)
      AND mmt.primary_quantity > 0
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR value_from_orgs_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND mta.accounting_line_type = 1
     AND mmt.transaction_action_id in (3,12)
     AND mmt.primary_quantity > 0
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
  BEGIN

edw_log.put_line('CALCFROMORG p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCFROMORG p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));

    OPEN value_from_orgs_no_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_from_orgs_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(value_from_orgs_no_lot_qty%NOTFOUND) then
        CLOSE value_from_orgs_no_lot_qty;
        exit;
      end if;

         Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'from_org_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN value_from_orgs_with_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_from_orgs_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(value_from_orgs_with_lot_qty%NOTFOUND) then
          CLOSE value_from_orgs_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'from_org_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN value_from_orgs_no_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_from_orgs_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(value_from_orgs_no_lot_val%NOTFOUND) then
        CLOSE value_from_orgs_no_lot_val;
        exit;
      end if;

         Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'from_org_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN value_from_orgs_with_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_from_orgs_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(value_from_orgs_with_lot_val%NOTFOUND) then
          CLOSE value_from_orgs_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'from_org_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_value_from_orgs');
   Retcode := '2';

end calc_value_from_orgs;



/*}{----------------------------------------------
PROCEDURE    CALC_VALUE_TO_ORGS
----------------------------------------------*/

   Procedure calc_value_to_orgs(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS
   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;


   CURSOR value_to_orgs_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id in (3,21)
      AND mmt.primary_quantity < 0
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR value_to_orgs_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_action_id in (3,21)
     AND mmt.primary_quantity < 0
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR value_to_orgs_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mmt.organization_id=mta.organization_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id in (3,21)
      AND mmt.primary_quantity < 0
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR value_to_orgs_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND mmt.organization_id=mta.organization_id
     AND mta.accounting_line_type = 1
     AND mmt.transaction_action_id in (3,21)
     AND mmt.primary_quantity < 0
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
  BEGIN

edw_log.put_line('CALCTOORG p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCTOORG p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));

    OPEN value_to_orgs_no_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_to_orgs_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(value_to_orgs_no_lot_qty%NOTFOUND) then
        CLOSE value_to_orgs_no_lot_qty;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'to_org_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN value_to_orgs_with_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_to_orgs_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(value_to_orgs_with_lot_qty%NOTFOUND) then
          CLOSE value_to_orgs_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'to_org_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN value_to_orgs_no_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_to_orgs_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(value_to_orgs_no_lot_val%NOTFOUND) then
        CLOSE value_to_orgs_no_lot_val;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'to_org_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN value_to_orgs_with_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH value_to_orgs_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(value_to_orgs_with_lot_val%NOTFOUND) then
          CLOSE value_to_orgs_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'to_org_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_value_to_orgs');
   Retcode := '2';

end calc_value_to_orgs;




/*}{----------------------------------------------
PROCEDURE    CALC_CUSTOMER_SHIPMENT
----------------------------------------------*/




   Procedure calc_customer_shipment(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS
   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;

   CURSOR customer_shipment_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id in (1,27)
      AND mmt.transaction_source_type_id in (2,8,12)
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR customer_shipment_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.transaction_id = mtln.transaction_id
     AND mmt.ORGANIZATION_ID=Org_id
     AND msi.LOT_CONTROL_CODE = 2
      AND mmt.transaction_action_id in (1,27)
      AND mmt.transaction_source_type_id in (2,8,12)
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
   -------------------------------------------------------
   -- begin 11.5.10 changes
   -- Replace old Cursors for item value with new cursors
   -------------------------------------------------------
   /*
   CURSOR customer_shipment_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id in (1,27)
      AND mmt.transaction_source_type_id in (2,8,12)
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR customer_shipment_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
      AND mmt.transaction_action_id in (1,27)
      AND mmt.transaction_source_type_id in (2,8,12)
     AND mta.accounting_line_type = 1
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
*/
  CURSOR customer_shipment_no_lot_val IS
  SELECT  TRANSACTION_DATE,
          ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          COST_GROUP_ID,
          REVISION,
          SUBINVENTORY_CODE,
          LOCATOR_ID,
          sum(BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
  FROM
  (
  /* Regular Sales Transactions (no logical flow)*/
     SELECT  trunc(mmt.TRANSACTION_DATE)TRANSACTION_DATE,
             mmt.ORGANIZATION_ID,
             mmt.INVENTORY_ITEM_ID,
             mmt.COST_GROUP_ID,
             mmt.REVISION,
             mmt.SUBINVENTORY_CODE,
             mmt.LOCATOR_ID,
             sum(mta.BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
     FROM    MTL_MATERIAL_TRANSACTIONS mmt,
             MTL_SYSTEM_ITEMS  msi,
             MTL_TRANSACTION_ACCOUNTS mta
     WHERE   mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND   mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND   mmt.ORGANIZATION_ID=Org_id
       AND   msi.LOT_CONTROL_CODE = 1
       AND   mmt.TRANSACTION_ID = mta.TRANSACTION_ID
       AND   mta.ACCOUNTING_LINE_TYPE = 1
       AND   mmt.TRANSACTION_ACTION_ID IN (1,27)
       AND   mmt.TRANSACTION_SOURCE_TYPE_ID IN (2,8,12)
       AND   mmt.TRANSACTION_DATE >= p_from_date
       AND   mmt.TRANSACTION_DATE <= p_to_date
     GROUP BY trunc(mmt.TRANSACTION_DATE), mmt.ORGANIZATION_ID, mmt.INVENTORY_ITEM_ID,
             mmt.COST_GROUP_ID, mmt.REVISION, mmt.SUBINVENTORY_CODE, mmt.LOCATOR_ID
     UNION
     /* Sales Orders and  RMA Receipts in Internal Drop Ship to Customer*/
     SELECT  trunc(mmt1.TRANSACTION_DATE)TRANSACTION_DATE,
             mmt1.ORGANIZATION_ID,
             mmt1.INVENTORY_ITEM_ID,
             mmt1.COST_GROUP_ID,
             mmt1.REVISION,
             mmt1.SUBINVENTORY_CODE,
             mmt1.LOCATOR_ID,
             sum(mta.BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
     FROM    MTL_MATERIAL_TRANSACTIONS mmt1,        --Parent Physical Txns
             MTL_MATERIAL_TRANSACTIONS mmt2,        --Logical (Child) Txns
             MTL_SYSTEM_ITEMS msi,
	     MTL_TRANSACTION_ACCOUNTS mta
     WHERE   mmt1.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND   mmt1.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND   mmt1.ORGANIZATION_ID=Org_id
       AND   msi.LOT_CONTROL_CODE = 1
       AND   mmt1.TRANSACTION_ACTION_ID IN (1, 27)
       AND   mmt1.TRANSACTION_SOURCE_TYPE_ID IN (2, 12)
       AND   mmt1.TRANSACTION_DATE >= p_from_date
       AND   mmt1.TRANSACTION_DATE <= p_to_date
       AND   mmt2.TRANSACTION_ID = mta.TRANSACTION_ID
       AND   mta.ACCOUNTING_LINE_TYPE = 1
       /* logical txn triggered by this parent txn*/
       AND   mmt2.PARENT_TRANSACTION_ID = mmt1.TRANSACTION_ID
       AND   mmt2.TRANSACTION_TYPE_ID IN (11, 14)
       AND   mmt2.ORGANIZATION_ID = Org_id
     GROUP BY trunc(mmt1.TRANSACTION_DATE), mmt1.ORGANIZATION_ID, mmt1.INVENTORY_ITEM_ID,
             mmt1.COST_GROUP_ID, mmt1.REVISION, mmt1.SUBINVENTORY_CODE, mmt1.LOCATOR_ID
  )
  GROUP BY TRANSACTION_DATE, ORGANIZATION_ID, INVENTORY_ITEM_ID, COST_GROUP_ID, REVISION, SUBINVENTORY_CODE, LOCATOR_ID;

  CURSOR customer_shipment_with_lot_val IS
  SELECT   TRANSACTION_DATE,
	   ORGANIZATION_ID,
	   INVENTORY_ITEM_ID,
	   COST_GROUP_ID,
	   REVISION,
	   LOT_NUMBER,
	   SUBINVENTORY_CODE,
	   LOCATOR_ID,
	   sum(BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
  FROM
  (
           /* Regular Sales Transactions (no logical flow)*/
     SELECT   trunc(mmt.TRANSACTION_DATE)TRANSACTION_DATE,
              mmt.ORGANIZATION_ID,
              mmt.INVENTORY_ITEM_ID,
              mmt.COST_GROUP_ID,
              mmt.REVISION,
              mtln.LOT_NUMBER,
              mmt.SUBINVENTORY_CODE,
              mmt.LOCATOR_ID,
              sum(mta.BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
     FROM     MTL_MATERIAL_TRANSACTIONS mmt,
              MTL_SYSTEM_ITEMS  msi,
              MTL_TRANSACTION_LOT_NUMBERS mtln,
              MTL_TRANSACTION_ACCOUNTS mta
     WHERE    mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND    mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND    mmt.ORGANIZATION_ID=Org_id
       AND    mmt.TRANSACTION_ID = mtln.TRANSACTION_ID
       AND    msi.LOT_CONTROL_CODE = 2
       AND    mmt.TRANSACTION_ID = mta.TRANSACTION_ID
       AND    mmt.TRANSACTION_ACTION_ID IN (1,27)
       AND    mmt.TRANSACTION_SOURCE_TYPE_ID in (2,8,12)
       AND    mta.ACCOUNTING_LINE_TYPE = 1
       AND    mmt.TRANSACTION_DATE >= p_from_date
       AND    mmt.TRANSACTION_DATE <= p_to_date
     GROUP BY trunc(mmt.TRANSACTION_DATE), mmt.ORGANIZATION_ID, mmt.INVENTORY_ITEM_ID, mmt.COST_GROUP_ID,
              mmt.REVISION, mtln.LOT_NUMBER, mmt.SUBINVENTORY_CODE, mmt.LOCATOR_ID
  UNION
     /* Sales Orders and RMA Receipts in Internal Drop Ship to Customer*/
     SELECT   trunc(mmt1.TRANSACTION_DATE)TRANSACTION_DATE,
              mmt1.ORGANIZATION_ID,
              mmt1.INVENTORY_ITEM_ID,
              mmt1.COST_GROUP_ID,
              mmt1.REVISION,
	      mtln.LOT_NUMBER,
              mmt1.SUBINVENTORY_CODE,
              mmt1.LOCATOR_ID,
	      sum(mta.BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
     FROM     MTL_MATERIAL_TRANSACTIONS mmt1,   --Parent Physical Txns
              MTL_MATERIAL_TRANSACTIONS mmt2,   --Logical (Child) Txns
              MTL_SYSTEM_ITEMS  msi,
              MTL_TRANSACTION_LOT_NUMBERS mtln,
              MTL_TRANSACTION_ACCOUNTS mta
     WHERE    mmt1.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND    mmt1.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND    mmt1.ORGANIZATION_ID=Org_id
       AND    mmt1.TRANSACTION_ID = mtln.TRANSACTION_ID
       AND    msi.LOT_CONTROL_CODE = 2
       AND    mmt1.TRANSACTION_ACTION_ID IN (1,27)
       AND    mmt1.TRANSACTION_SOURCE_TYPE_ID IN (2,12)
       AND    mmt1.TRANSACTION_DATE >= p_from_date
       AND    mmt1.TRANSACTION_DATE <= p_to_date
       AND    mmt2.TRANSACTION_ID = mta.TRANSACTION_ID
       AND    mta.ACCOUNTING_LINE_TYPE = 1
       /* logical txn triggered by this parent txn*/
       AND    mmt2.PARENT_TRANSACTION_ID = mmt1.TRANSACTION_ID
       AND    mmt2.ORGANIZATION_ID=Org_id
       AND    mmt2.TRANSACTION_TYPE_ID IN (11,14)
     GROUP BY trunc(mmt1.TRANSACTION_DATE), mmt1.ORGANIZATION_ID, mmt1.INVENTORY_ITEM_ID, mmt1.COST_GROUP_ID,
              mmt1.REVISION, mtln.LOT_NUMBER, mmt1.SUBINVENTORY_CODE, mmt1.LOCATOR_ID
  )
  GROUP BY TRANSACTION_DATE, ORGANIZATION_ID, INVENTORY_ITEM_ID, COST_GROUP_ID,
           REVISION, LOT_NUMBER, SUBINVENTORY_CODE, LOCATOR_ID;
  -------------------------------------------------------------------------------
  -- End 11.5.10 changes*/
  ------------------------------------------------------------------------------
  BEGIN

edw_log.put_line('CALCcstship p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCcstship p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));

    OPEN customer_shipment_no_lot_qty;


    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH customer_shipment_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(customer_shipment_no_lot_qty%NOTFOUND) then
        CLOSE customer_shipment_no_lot_qty;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_cust_ship_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN customer_shipment_with_lot_qty;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH customer_shipment_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(customer_shipment_with_lot_qty%NOTFOUND) then
          CLOSE customer_shipment_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_cust_ship_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN customer_shipment_no_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH customer_shipment_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(customer_shipment_no_lot_val%NOTFOUND) then
        CLOSE customer_shipment_no_lot_val;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_cust_ship_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN customer_shipment_with_lot_val;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH customer_shipment_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(customer_shipment_with_lot_val%NOTFOUND) then
          CLOSE customer_shipment_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_cust_ship_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_customer_shipment');
   Retcode := '2';

end calc_customer_shipment;


/*}{----------------------------------------------
PROCEDURE    CALC_INV_ADJUSTMENT
----------------------------------------------*/

   Procedure calc_inv_adjustment(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS
   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;


   CURSOR inv_adj_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_action_id in (4,8)
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR inv_adj_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.transaction_id = mtln.transaction_id
     AND mmt.ORGANIZATION_ID=Org_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_action_id in (4,8)
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR inv_adj_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND mmt.transaction_action_id in (4,8)
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   CURSOR inv_adj_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND mmt.transaction_action_id in (4,8)
     AND mta.accounting_line_type = 1
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
  BEGIN

edw_log.put_line('CALCadj p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCadj p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));

    OPEN inv_adj_no_lot_qty;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH inv_adj_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(inv_adj_no_lot_qty%NOTFOUND) then
        CLOSE inv_adj_no_lot_qty;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'inv_adj_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN inv_adj_with_lot_qty;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH inv_adj_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(inv_adj_with_lot_qty%NOTFOUND) then
          CLOSE inv_adj_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'inv_adj_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN inv_adj_no_lot_val;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH inv_adj_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(inv_adj_no_lot_val%NOTFOUND) then
        CLOSE inv_adj_no_lot_val;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'inv_adj_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN inv_adj_with_lot_val;

    LOOP

      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH inv_adj_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(inv_adj_with_lot_val%NOTFOUND) then
          CLOSE inv_adj_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'inv_adj_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_inv_adjustment');
   Retcode := '2';

end calc_inv_adjustment;



/*}{----------------------------------------------
PROCEDURE    CALC_TOTAL_ISSUE
----------------------------------------------*/

   Procedure calc_total_issue(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS
   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_issue_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND (  (mmt.transaction_action_id in (1,2,3,21)
	      AND mmt.primary_quantity < 0
	      AND mmt.transaction_source_type_id <> 1)
          OR (mmt.transaction_action_id = 27
	      AND mmt.transaction_source_type_id in (5,12))  )
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
      AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_issue_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.transaction_id = mtln.transaction_id
     AND mmt.ORGANIZATION_ID=Org_id
     AND msi.LOT_CONTROL_CODE = 2
      AND (  (mmt.transaction_action_id in (1,2,3,21)
	      AND mmt.primary_quantity < 0
	      AND mmt.transaction_source_type_id <> 1)
          OR (mmt.transaction_action_id = 27
	      AND mmt.transaction_source_type_id in (5,12))  )
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
     AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
     AND NVL(MMT.OWNING_TP_TYPE,2) = 2
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

  -------------------------------------------------------------------------------
  -- Begin 11.5.10 changes
  -- Replace old Cursors for Item value with new cusors
  -------------------------------------------------------------------------------
  /*
   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_issue_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND (  (mmt.transaction_action_id in (1,2,3,21)
	      AND mmt.primary_quantity < 0
	      AND mmt.transaction_source_type_id <> 1)
          OR (mmt.transaction_action_id = 27
	      AND mmt.transaction_source_type_id in (5,12))  )
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
      AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_issue_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND (  (mmt.transaction_action_id in (1,2,3,21)
	      AND mmt.primary_quantity < 0
	      AND mmt.transaction_source_type_id <> 1)
          OR (mmt.transaction_action_id = 27
	      AND mmt.transaction_source_type_id in (5,12))  )
     AND mta.accounting_line_type = 1
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
     AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
     AND NVL(MMT.OWNING_TP_TYPE,2) = 2
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
*/

  CURSOR total_issue_no_lot_val IS
  SELECT   TRANSACTION_DATE,
           ORGANIZATION_ID,
           INVENTORY_ITEM_ID,
           COST_GROUP_ID,
           REVISION,
           SUBINVENTORY_CODE,
           LOCATOR_ID,
           sum(BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
  FROM
  (
     /* Regular Sales Transactions (no logical flow)*/
     SELECT   trunc(mmt.TRANSACTION_DATE) TRANSACTION_DATE,
              mmt.ORGANIZATION_ID,
              mmt.INVENTORY_ITEM_ID,
              mmt.COST_GROUP_ID,
              mmt.REVISION,
              mmt.SUBINVENTORY_CODE,
              mmt.LOCATOR_ID,
              sum(mta.BASE_TRANSACTION_VALUE) BASE_TRANSACTION_VALUE
     FROM     MTL_MATERIAL_TRANSACTIONS mmt,
              MTL_SYSTEM_ITEMS  msi,
              MTL_TRANSACTION_ACCOUNTS mta
     WHERE    mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND    mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND    mmt.ORGANIZATION_ID=Org_id
       AND    msi.LOT_CONTROL_CODE = 1
       AND    mmt.TRANSACTION_ID = mta.TRANSACTION_ID
       AND    mta.ACCOUNTING_LINE_TYPE = 1
       AND    ((mmt.TRANSACTION_ACTION_ID IN (1,2,3,21)
                AND mmt.PRIMARY_QUANTITY < 0
                AND mmt.TRANSACTION_SOURCE_TYPE_ID <> 1)
              OR (mmt.TRANSACTION_ACTION_ID = 27
                 AND mmt.TRANSACTION_SOURCE_TYPE_ID IN (5,12)))
       AND    mmt.TRANSACTION_DATE >= p_from_date
       AND    mmt.TRANSACTION_DATE <= p_to_date
       AND    mmt.ORGANIZATION_ID = NVL(mmt.OWNING_ORGANIZATION_ID, mmt.ORGANIZATION_ID)
       AND    NVL(mmt.OWNING_TP_TYPE,2) = 2
     GROUP BY trunc(mmt.TRANSACTION_DATE), mmt.ORGANIZATION_ID, mmt.INVENTORY_ITEM_ID, mmt.COST_GROUP_ID,
              mmt.REVISION, mmt.SUBINVENTORY_CODE, mmt.LOCATOR_ID
  UNION
     /* Sales Orders and RMA Receipts in Internal Drop Ship to Customer*/
     SELECT   trunc(mmt1.TRANSACTION_DATE)TRANSACTION_DATE,
              mmt1.ORGANIZATION_ID,
              mmt1.INVENTORY_ITEM_ID,
              mmt1.COST_GROUP_ID,
              mmt1.REVISION,
              mmt1.SUBINVENTORY_CODE,
              mmt1.LOCATOR_ID,
              sum(mta.BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
     FROM     MTL_MATERIAL_TRANSACTIONS mmt1,  -- Parent Physical Txns
              MTL_MATERIAL_TRANSACTIONS mmt2,  -- Logical (Child) Txns
	      MTL_SYSTEM_ITEMS msi,
	      MTL_TRANSACTION_ACCOUNTS mta
     WHERE    mmt1.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND    mmt1.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND    mmt1.ORGANIZATION_ID=Org_id
       AND    msi.LOT_CONTROL_CODE = 1
       AND    mmt1.TRANSACTION_ACTION_ID IN (1, 27)
       AND    mmt1.TRANSACTION_SOURCE_TYPE_ID IN (2, 12)
       AND    mmt1.TRANSACTION_DATE >= p_from_date
       AND    mmt1.TRANSACTION_DATE <= p_to_date
       AND    mmt2.TRANSACTION_ID = mta.TRANSACTION_ID
       AND    mta.ACCOUNTING_LINE_TYPE = 1
       /* logical txn triggered by this parent txn*/
       AND    mmt2.PARENT_TRANSACTION_ID = mmt1.TRANSACTION_ID
       AND    mmt2.TRANSACTION_TYPE_ID IN (11, 14)
       AND    mmt2.ORGANIZATION_ID = Org_id
       GROUP BY trunc(mmt1.TRANSACTION_DATE), mmt1.ORGANIZATION_ID, mmt1.INVENTORY_ITEM_ID, mmt1.COST_GROUP_ID,
              mmt1.REVISION, mmt1.SUBINVENTORY_CODE, mmt1.LOCATOR_ID
  )
  GROUP BY TRANSACTION_DATE, ORGANIZATION_ID, INVENTORY_ITEM_ID, COST_GROUP_ID, REVISION, SUBINVENTORY_CODE, LOCATOR_ID;

  CURSOR total_issue_with_lot_val IS
  SELECT   TRANSACTION_DATE,
           ORGANIZATION_ID,
           INVENTORY_ITEM_ID,
           COST_GROUP_ID,
           REVISION,
           LOT_NUMBER,
           SUBINVENTORY_CODE,
           LOCATOR_ID,
           sum(BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
  FROM
  (
     /* Regular Sales Transactions (no logical flow)*/
     SELECT   trunc(mmt.TRANSACTION_DATE)TRANSACTION_DATE,
              mmt.ORGANIZATION_ID,
              mmt.INVENTORY_ITEM_ID,
              mmt.COST_GROUP_ID,
              mmt.REVISION,
              mtln.LOT_NUMBER,
              mmt.SUBINVENTORY_CODE,
              mmt.LOCATOR_ID,
              sum(mta.BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
     FROM     MTL_MATERIAL_TRANSACTIONS mmt,
              MTL_SYSTEM_ITEMS  msi,
              MTL_TRANSACTION_LOT_NUMBERS mtln,
              MTL_TRANSACTION_ACCOUNTS mta
     WHERE    mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND    mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND    mmt.ORGANIZATION_ID=Org_id
       AND    mmt.TRANSACTION_ID = mtln.TRANSACTION_ID
       AND    msi.LOT_CONTROL_CODE = 2
       AND    mmt.TRANSACTION_ID = mta.TRANSACTION_ID
       AND    ((mmt.TRANSACTION_ACTION_ID IN (1,2,3,21)
                AND mmt.PRIMARY_QUANTITY < 0
                AND mmt.TRANSACTION_SOURCE_TYPE_ID <> 1)
              OR (mmt.TRANSACTION_ACTION_ID = 27
                  AND mmt.TRANSACTION_SOURCE_TYPE_ID IN (5,12)))
       AND    mta.ACCOUNTING_LINE_TYPE = 1
       AND    mmt.TRANSACTION_DATE >= p_from_date
       AND    mmt.TRANSACTION_DATE <= p_to_date
       AND    mmt.ORGANIZATION_ID =  NVL(mmt.OWNING_ORGANIZATION_ID,mmt.ORGANIZATION_ID)
       AND    NVL(mmt.OWNING_TP_TYPE,2) = 2
     GROUP BY trunc(mmt.TRANSACTION_DATE), mmt.ORGANIZATION_ID, mmt.INVENTORY_ITEM_ID, mmt.COST_GROUP_ID,
              mmt.REVISION, mtln.lot_number, mmt.SUBINVENTORY_CODE, mmt.LOCATOR_ID
  UNION
     /* Sales Orders and RMA Receipts in Internal Drop Ship to Customer*/
     SELECT   trunc(mmt1.TRANSACTION_DATE)TRANSACTION_DATE,
              mmt1.ORGANIZATION_ID,
              Mmt1.INVENTORY_ITEM_ID,
              Mmt1.COST_GROUP_ID,
              Mmt1.REVISION,
              mtln.LOT_NUMBER,
              Mmt1.SUBINVENTORY_CODE,
              Mmt1.LOCATOR_ID,
              sum(mta.BASE_TRANSACTION_VALUE)BASE_TRANSACTION_VALUE
     FROM     MTL_MATERIAL_TRANSACTIONS mmt1,   --Parent Physical Txns
              MTL_MATERIAL_TRANSACTIONS mmt2,   --Logical (Child) Txns
              MTL_SYSTEM_ITEMS  msi,
              MTL_TRANSACTION_LOT_NUMBERS mtln,
              MTL_TRANSACTION_ACCOUNTS mta
     WHERE    mmt1.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
       AND    mmt1.ORGANIZATION_ID=msi.ORGANIZATION_ID
       AND    mmt1.ORGANIZATION_ID=Org_id
       AND    mmt1.TRANSACTION_ID = mtln.TRANSACTION_ID
       AND    msi.LOT_CONTROL_CODE = 2
       AND    mmt1.TRANSACTION_ACTION_ID IN (1,27)
       AND    mmt1.TRANSACTION_SOURCE_TYPE_ID IN (2,12)
       AND    mmt1.TRANSACTION_DATE >= p_from_date
       AND    mmt1.TRANSACTION_DATE <= p_to_date
       AND    mmt2.TRANSACTION_ID = mta.TRANSACTION_ID
       AND    mta.ACCOUNTING_LINE_TYPE = 1
       /* logical txn triggered by this parent txn*/
       AND    mmt2.PARENT_TRANSACTION_ID = mmt1.TRANSACTION_ID
       AND    mmt2.TRANSACTION_TYPE_ID IN (11,14)
       AND    mmt2.ORGANIZATION_ID=org_id
     GROUP BY trunc(mmt1.TRANSACTION_DATE), mmt1.ORGANIZATION_ID, mmt1.INVENTORY_ITEM_ID, mmt1.COST_GROUP_ID,
              mmt1.REVISION,  mtln.LOT_NUMBER, mmt1.SUBINVENTORY_CODE, mmt1.LOCATOR_ID
  )
  GROUP BY TRANSACTION_DATE, ORGANIZATION_ID, INVENTORY_ITEM_ID, COST_GROUP_ID,
           LOT_NUMBER, REVISION, SUBINVENTORY_CODE, LOCATOR_ID;

  BEGIN

edw_log.put_line('CALCTOTISS p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCTOTISS p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));

    OPEN total_issue_no_lot_qty;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_issue_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(total_issue_no_lot_qty%NOTFOUND) then
        CLOSE total_issue_no_lot_qty;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_issues_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN total_issue_with_lot_qty;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_issue_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(total_issue_with_lot_qty%NOTFOUND) then
          CLOSE total_issue_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_issues_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);


      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN total_issue_no_lot_val;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_issue_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(total_issue_no_lot_val%NOTFOUND) then
        CLOSE total_issue_no_lot_val;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_issues_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN total_issue_with_lot_val;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_issue_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(total_issue_with_lot_val%NOTFOUND) then
          CLOSE total_issue_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'tot_issues_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_total_issue');
   Retcode := '2';

end calc_total_issue;


/*}{----------------------------------------------
PROCEDURE    CALC_TOTAL_RECEIPT
----------------------------------------------*/


   Procedure calc_total_receipt(Errbuf out nocopy Varchar2,
                  Retcode       out nocopy Varchar2,
                  p_from_date   IN  Date,
                  p_to_date     IN  Date,
		  Org_id        IN  Number) IS
   l_trx_date         DATE;
   l_organization_id  NUMBER;
   l_item_id          NUMBER;
   l_cost_group_id    NUMBER;
   l_revision         VARCHAR2(3);
   l_lot_number       VARCHAR2(30);
   l_subinventory     VARCHAR2(10);
   l_locator          NUMBER;
   total_value        NUMBER;
   total_qty          NUMBER;
   trx_type           NUMBER;
   status             NUMBER;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_receipt_no_lot_qty IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mmt.PRIMARY_QUANTITY)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND (  (mmt.transaction_action_id in (2,3,12)
	      AND mmt.primary_quantity >0 )
          OR ( mmt.transaction_action_id in (4,8))
          OR (mmt.transaction_action_id in (27,29)
	      AND mmt.transaction_source_type_id in (3,6,13,1))
          OR (mmt.transaction_action_id in (31,32)
	      AND mmt.transaction_source_type_id=5)
	  OR  (mmt.transaction_action_id =1 and mmt.transaction_source_type_id =1))
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
      AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;

   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_receipt_with_lot_qty IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mtln.PRIMARY_QUANTITY)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.transaction_id = mtln.transaction_id
     AND mmt.ORGANIZATION_ID=Org_id
     AND msi.LOT_CONTROL_CODE = 2
     AND (  (mmt.transaction_action_id in (2,3,12)
	      AND mmt.primary_quantity >0 )
          OR ( mmt.transaction_action_id in (4,8))
          OR (mmt.transaction_action_id in (27,29)
	      AND mmt.transaction_source_type_id in (3,6,13,1))
          OR (mmt.transaction_action_id in (31,32)
	      AND mmt.transaction_source_type_id=5)
	  OR  (mmt.transaction_action_id =1 and mmt.transaction_source_type_id =1))
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
     AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
     AND NVL(MMT.OWNING_TP_TYPE,2) = 2
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_receipt_no_lot_val IS
   SELECT trunc(mmt.TRANSACTION_DATE),
          mmt.ORGANIZATION_ID,
          mmt.INVENTORY_ITEM_ID,
          mmt.COST_GROUP_ID,
          mmt.REVISION,
          mmt.SUBINVENTORY_CODE,
          mmt.LOCATOR_ID,
          sum(mta.BASE_TRANSACTION_VALUE)
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_SYSTEM_ITEMS  msi,
	  MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
      AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
      AND mmt.ORGANIZATION_ID=Org_id
      AND msi.LOT_CONTROL_CODE = 1
      AND mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND (  (mmt.transaction_action_id in (2,3,12)
	      AND mmt.primary_quantity >0 )
          OR ( mmt.transaction_action_id in (4,8))
          OR (mmt.transaction_action_id in (27,29)
	      AND mmt.transaction_source_type_id in (3,6,13,1))
          OR (mmt.transaction_action_id in (31,32)
	      AND mmt.transaction_source_type_id=5)
	  OR  (mmt.transaction_action_id =1 and mmt.transaction_source_type_id =1))
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
      AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
      AND NVL(MMT.OWNING_TP_TYPE,2) = 2
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


   -- ltong 01/20/2003. Filtered out consigned inventory.
   CURSOR total_receipt_with_lot_val IS
   SELECT   trunc(mmt.TRANSACTION_DATE),
         mmt.ORGANIZATION_ID,
         mmt.INVENTORY_ITEM_ID,
         mmt.COST_GROUP_ID,
         mmt.REVISION,
         mtln.LOT_NUMBER,
         mmt.SUBINVENTORY_CODE,
         mmt.LOCATOR_ID,
         sum(mta.BASE_TRANSACTION_VALUE)
    FROM MTL_MATERIAL_TRANSACTIONS mmt,
         MTL_SYSTEM_ITEMS  msi,
         MTL_TRANSACTION_LOT_NUMBERS mtln,
	 MTL_TRANSACTION_ACCOUNTS mta
   WHERE mmt.INVENTORY_ITEM_ID=msi.INVENTORY_ITEM_ID
     AND mmt.ORGANIZATION_ID=msi.ORGANIZATION_ID
     AND mmt.ORGANIZATION_ID=Org_id
     AND mmt.transaction_id = mtln.transaction_id
     AND msi.LOT_CONTROL_CODE = 2
     AND mmt.transaction_id = mta.transaction_id
     AND (  (mmt.transaction_action_id in (2,3,12)
	      AND mmt.primary_quantity >0 )
          OR ( mmt.transaction_action_id in (4,8))
          OR (mmt.transaction_action_id in (27,29)
	      AND mmt.transaction_source_type_id in (3,6,13,1))
          OR (mmt.transaction_action_id in (31,32)
	      AND mmt.transaction_source_type_id=5)
	  OR  (mmt.transaction_action_id =1 and mmt.transaction_source_type_id =1))
     AND mta.accounting_line_type = 1
     AND mmt.transaction_date >= p_from_date
     AND mmt.transaction_date <= p_to_date
     AND MMT.organization_id =  NVL(MMT.owning_organization_id,MMT.organization_id)
     AND NVL(MMT.OWNING_TP_TYPE,2) = 2
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
         mmt.REVISION,mtln.lot_number,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;
  BEGIN

edw_log.put_line('CALCTOTRCT p_from_Date '||to_char(p_from_date,'dd-mon-yyyy hh24:mi:ss'));
edw_log.put_line('CALCTOTRCT p_to_Date '||to_char(p_to_date,'dd-mon-yyyy hh24:mi:ss'));
    OPEN total_receipt_no_lot_qty;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_receipt_no_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
	    total_qty;


      if(total_receipt_no_lot_qty%NOTFOUND) then
        CLOSE total_receipt_no_lot_qty;
        exit;
      end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'total_rec_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN total_receipt_with_lot_qty;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_receipt_with_lot_qty
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
	    total_qty;


        if(total_receipt_with_lot_qty%NOTFOUND) then
          CLOSE total_receipt_with_lot_qty;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'total_rec_qty',
            p_total1          => total_qty,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN total_receipt_no_lot_val;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_receipt_no_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_subinventory,
            l_locator,
            total_value;

      if(total_receipt_no_lot_val%NOTFOUND) then
        CLOSE total_receipt_no_lot_val;
        exit;
      end if;

      Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'total_rec_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;


    OPEN total_receipt_with_lot_val;

    LOOP
      Initialize(l_trx_date,l_organization_id,l_item_id,l_cost_group_id,l_revision,
                 l_lot_number,l_subinventory,l_locator,total_qty,total_value);


      FETCH total_receipt_with_lot_val
       INTO l_trx_date,
            l_organization_id,
            l_item_id,
            l_cost_group_id,
            l_revision,
            l_lot_number,
            l_subinventory,
            l_locator,
            total_value;

        if(total_receipt_with_lot_val%NOTFOUND) then
          CLOSE total_receipt_with_lot_val;
          exit;
        end if;

        Insert_update_push_log(
            p_trx_date => l_trx_date ,
            p_organization_id => l_organization_id,
            p_item_id         => l_item_id,
            p_cost_group_id   => l_cost_group_id,
            p_revision        => l_revision,
            p_lot_number      => l_lot_number,
            p_subinventory    => l_subinventory,
            p_locator         => l_locator,
            p_col_name1       => 'total_rec_val_b',
            p_total1          => total_value,
            selector          => 1,
            success           => status);

      if (status > 0) then
        Retcode := '2';
        return;
      end if;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
   edw_log.put_line('Error in calc_total_receipt');
   Retcode := '2';

end calc_total_receipt;


/*}----------------------------------------------
PROCEDURE    Insert_update_push_log
----------------------------------------------*/

  PROCEDURE Insert_update_push_log(
            p_trx_date IN Date,
            p_organization_id IN Number,
            p_item_id         IN Number default NULL,
            p_cost_group_id   IN Number default NULL,
            p_revision        IN Varchar2 default NULL,
            p_lot_number      IN Varchar2 default NULL,
            p_subinventory    IN Varchar2 default NULL,
            p_locator         IN Number default NULL,
            p_item_status     IN Varchar2 default NULL,
            p_item_type       IN Varchar2 default NULL,
            p_base_uom        IN Varchar2 default NULL,
            p_col_name1       IN Varchar2 default NULL,
            p_total1          IN Number default NULL,
            p_col_name2       IN Varchar2 default NULL,
            p_total2          IN Number default NULL,
            p_col_name3       IN Varchar2 default NULL,
            p_total3          IN Number default NULL,
            p_col_name4       IN Varchar2 default NULL,
            p_total4          IN Number default NULL,
            p_col_name5       IN Varchar2 default NULL,
            p_total5          IN Number default NULL,
            p_col_name6       IN Varchar2 default NULL,
            p_total6          IN Number default NULL,
            selector          IN Number default NULL,
            success           OUT nocopy Number)
IS

  l_pk varchar2(100):=null;
  l_query varchar2(2000):=null;
  l_row_exists number:=0;
  l_physical_location number:= 0;
  l_locator number;
  pjm_org number:= 2;



  CURSOR row_exists IS
     SELECT 1
       FROM opi_ids_push_log
      WHERE IDS_KEY=l_pk;

  CURSOR change_location IS
        SELECT physical_location_id
          FROM mtl_item_locations
         WHERE organization_id = p_organization_id
           AND inventory_location_id <> physical_location_id
           AND inventory_location_id = p_locator;

BEGIN

       l_locator := p_locator;

/* ---------------------------------------------------------------------------------------------------
Fixes bug 1675273.  For PJM controlled orgs, MMT/MOQ stores the inv_location_id for the project
Mtl_item_locations
  inventory_location_id  physical_location_id  Projectid
           1                     2                P1
	   2                     2
	   3                     2                P2
	   4                     2                P2 Task 2

But Inv Locator dimension only stores the Real physical locators and so it only gets inventory_location_id=
physical_location_id = 2  and doesn't have 1,3 and 4.  So while collecting IDS, mmt/moq are grouped by
inventory_location_id (1,2,3,4)  but 1,3,4 should be converted into 2.  THis is due to the fact that IDS
doesn't support (nor is it required) Project info. To track keeping the original locator_id as in
  mmt/moq in the ids_key but changing the locator_fk column to point to physical locator

  --rjin
  we store the p_locator (the physical locator info for non-pjm controlled org or the project
  locator info for pjm-controlled org ) in project_locator_id column in push_log.
  Because later in calc_prd_start_end, we need to recover the project locator id info to
  construct the ids_key.
-----------------------------------------------------------------------------------------------------*/

  SELECT nvl(PROJECT_REFERENCE_ENABLED,2) into pjm_org
    FROM mtl_parameters
   WHERE organization_id = p_organization_id;


    if ( pjm_org = 1 AND  p_locator > 0 ) then
        OPEN change_location;
        FETCH change_location INTO l_physical_location;

        if (change_location%FOUND) then
           l_locator := l_physical_location;
        end if;
           CLOSE change_location;
    end if;

  l_pk := p_trx_date||'-'||p_item_id||'-'||p_organization_id||'-'||p_cost_group_id||'-'
    ||p_revision||'-'||p_lot_number||'-'||p_subinventory||'-'||p_locator;

  --dbms_output.put_line('l_pk is ' || l_pk);

/*  edw_log.put_line('IU_push_log: IDSKEY= '||l_pk);  */


  OPEN row_exists ;

  FETCH row_exists
   INTO l_row_exists;

  IF row_exists%rowcount > 0 THEN
     --dbms_output.put_line(' > 0');
     IF(selector = 1) then
	l_query := 'UPDATE opi_ids_push_log SET push_flag = 1,' || p_col_name1
	  || ' = ' || 'nvl(:p_total1,0) WHERE IDS_KEY = :l_pk ';

	execute immediate l_query using p_total1, l_pk;
      ELSE
	l_query := 'UPDATE opi_ids_push_log SET  push_flag = 1, '
	  || p_col_name1 || ' = nvl(:p_total1,0),' || p_col_name2 ||
	  ' =  nvl(:p_total2,0), ' || p_col_name3 || ' = nvl( :p_total3,0), '
	  || p_col_name4 || ' = nvl(:p_total4,0), '|| p_col_name5 ||
	  ' = nvl(:p_total5,0), '|| p_col_name6 || ' = nvl(:p_total6,0) '
	  || ' WHERE IDS_KEY = :l_pk ';

	execute immediate l_query using p_total1, p_total2, p_total3, p_total4, p_total5, p_total6, l_pk;
     END IF;
   ELSE
     --dbms_output.put_line('<0, not exist');

     l_query := 'INSERT INTO opi_ids_push_log(IDS_KEY,trx_date,organization_id,Push_flag';

     l_query := l_query || ', cost_group_id , inventory_item_id, revision, lot_number';
     l_query := l_query||', subinventory_code, locator_id, project_locator_id, item_status';
     l_query := l_query||', item_type, base_uom';

     IF(selector = 1) then
	l_query := l_query || ' ,' || p_col_name1;
      ELSE
	l_query := l_query || ' ,' || p_col_name1 || ' ,' || p_col_name2 || ' ,'||
	  p_col_name3 || ' ,' || p_col_name4 || ' ,' || p_col_name5 || ' ,' || p_col_name6;
     END IF;

     l_query :=  l_query || ') VALUES ( :l_pk ,:p_trx_date, :p_organization_id, 1';
     l_query := l_query||', :p_cost_group_id, :p_item_id, :p_revision,:p_lot_number';
     l_query := l_query||', :p_subinventory, :l_locator, :p_locator, :p_item_status';
     l_query := l_query||', :p_item_type, :p_base_uom ';


     IF(selector = 1) then
	l_query := l_query || ', Nvl(:p_total1,0) )';

	execute immediate l_query using l_pk ,p_trx_date, p_organization_id, p_cost_group_id, p_item_id, p_revision,p_lot_number , p_subinventory, l_locator, p_locator, p_item_status, p_item_type, p_base_uom, p_total1;

      ELSE
	l_query := l_query || ', Nvl(:p_total1,0), Nvl(:p_total2,0), Nvl(:p_total3,0),';
	l_query := l_query || 'Nvl(:p_total4,0), Nvl(:p_total5,0), Nvl(:p_total6,0) ) ';

	execute immediate l_query using l_pk ,p_trx_date, p_organization_id, p_cost_group_id,
	  p_item_id, p_revision,p_lot_number , p_subinventory, l_locator, p_locator, p_item_status,
	  p_item_type, p_base_uom, p_total1, p_total2, p_total3, p_total4, p_total5, p_total6;

     END IF;
 END IF;

 success:=0;
 CLOSE row_exists ;

EXCEPTION
 WHEN OTHERS THEN
    edw_log.put_line('Error in Insert_update_push_log prodedure ');
    edw_log.put_line('query errored '||l_query);
    success:=1;
END Insert_update_push_log;

/*}----------------------------------------------
PROCEDURE    Initialize
----------------------------------------------*/

PROCEDURE Initialize(
            p_trx_date        OUT nocopy Date,
            p_organization_id OUT nocopy Number,
            p_item_id         OUT nocopy Number,
            p_cost_group_id   OUT nocopy Number,
            p_revision        OUT nocopy Varchar2,
            p_lot_number      OUT nocopy Varchar2,
            p_subinventory    OUT nocopy Varchar2,
            p_locator         OUT nocopy Number,
            total_qty         OUT nocopy Number,
            total_value       OUT nocopy Number) IS
BEGIN
   p_trx_date := NULL;
   p_organization_id := 0;
   p_item_id         := 0;
   p_cost_group_id   := NULL;
   p_revision        := NULL;
   p_lot_number      := NULL;
   p_subinventory    := NULL;
   p_locator         := 0;
   total_qty         := 0;
   total_value       := 0;

EXCEPTION
 WHEN OTHERS THEN
    edw_log.put_line('Error in Initialize');

end Initialize;

End OPIMPXIN;

/
