--------------------------------------------------------
--  DDL for Package Body OPI_EDW_INV_DAILY_STAT_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_INV_DAILY_STAT_F_SZ" AS
/* $Header: OPIOINZB.pls 120.1 2005/06/07 02:07:01 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS


      CURSOR mmt_cnt_rows IS
	 SELECT count(*)
           FROM mtl_material_transactions mmt
	  WHERE transaction_date >= p_from_date
	    AND transaction_date <= p_to_Date
       GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
		  mmt.COST_GROUP_ID,mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.locator_id;

 CURSOR wt_cnt_rows IS
 select count(*) from (
    SELECT wdj.primary_item_id,wdj.bom_revision
      FROM wip_transactions wt,
           wip_discrete_jobs wdj
     WHERE wt.transaction_date between p_from_date
                            and p_to_Date
       AND wt.wip_entity_id = wdj.wip_entity_id
  GROUP BY wdj.primary_item_id,
            wdj.bom_revision
 UNION ALL
    SELECT we.primary_item_id,wrs.bom_revision
      FROM wip_transactions wt,
           wip_repetitive_schedules wrs,
           wip_entities we
     WHERE wt.transaction_date between p_from_date
                             and p_to_Date
       AND wt.wip_entity_id = wrs.wip_entity_id
       AND wt.wip_entity_id = we.wip_entity_id
  GROUP BY we.primary_item_id,
           wrs.bom_revision
 UNION ALL
    SELECT  wfs.primary_item_id,wfs.bom_revision
      FROM wip_transactions wt,
           wip_flow_schedules wfs
     WHERE wt.transaction_date between p_from_date
                             and p_to_Date
       AND wt.wip_entity_id = wfs.wip_entity_id
  GROUP BY wfs.primary_item_id,
            wfs.bom_revision );

     p_mmt_num_rows number:=0;
     p_wt_num_rows number:=0;

BEGIN


/*  Called it in loop rather than defining an INLINE SQL as cursor performance was much better with the number of records in mmt*/

  OPEN mmt_cnt_rows;
  loop
       FETCH mmt_cnt_rows INTO p_mmt_num_rows;
       if(mmt_cnt_rows%NOTFOUND) then
	  CLOSE mmt_cnt_rows;
	  EXIT;
       end if;
       p_num_rows := nvl(p_num_rows,0)+1;
  end loop;


  OPEN wt_cnt_rows;
  FETCH wt_cnt_rows INTO p_wt_num_rows;
  CLOSE wt_cnt_rows;

   p_num_rows := nvl(p_num_rows,0)+nvl(p_wt_num_rows,0);

END;  -- procedure cnt_rows.



PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER) IS
 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;

x_AVG_INT_QTY                              NUMBER;
x_AVG_INT_VAL_B                            NUMBER;
x_AVG_INT_VAL_G                            NUMBER;
x_AVG_ONH_QTY                              NUMBER;
x_AVG_ONH_VAL_B                            NUMBER;
x_AVG_ONH_VAL_G                            NUMBER;
x_AVG_WIP_QTY                              NUMBER;
x_AVG_WIP_VAL_B                            NUMBER;
x_AVG_WIP_VAL_G                            NUMBER;
x_BASE_CURRENCY_FK                         NUMBER;
x_BASE_UOM_FK                              NUMBER;
x_BEG_INT_QTY                              NUMBER;
x_BEG_INT_VAL_B                            NUMBER;
x_BEG_INT_VAL_G                            NUMBER;
x_BEG_ONH_QTY                              NUMBER;
x_BEG_ONH_VAL_B                            NUMBER;
x_BEG_ONH_VAL_G                            NUMBER;
x_BEG_WIP_QTY                              NUMBER;
x_BEG_WIP_VAL_B                            NUMBER;
x_BEG_WIP_VAL_G                            NUMBER;
x_COMMODITY_CODE                           VARCHAR2(40);
x_COST_GROUP                               NUMBER;
x_CREATION_DATE                            DATE;
x_END_INT_QTY                              NUMBER;
x_END_INT_VAL_B                            NUMBER;
x_END_INT_VAL_G                            NUMBER;
x_END_ONH_QTY                              NUMBER;
x_END_ONH_VAL_B                            NUMBER;
x_END_ONH_VAL_G                            NUMBER;
x_END_WIP_QTY                              NUMBER;
x_END_WIP_VAL_B                            NUMBER;
x_END_WIP_VAL_G                            NUMBER;
x_FROM_ORG_QTY                             NUMBER;
x_FROM_ORG_VAL_B                           NUMBER;
x_FROM_ORG_VAL_G                           NUMBER;
x_INSTANCE_FK                              NUMBER;
x_INV_ADJ_QTY                              NUMBER;
x_INV_ADJ_VAL_B                            NUMBER;
x_INV_ADJ_VAL_G                            NUMBER;
x_INV_DAILY_STATUS_PK                      NUMBER;
x_INV_ORG_FK                               NUMBER;
x_ITEM_ORG_FK                              NUMBER;
x_ITEM_STATUS                              VARCHAR2(40);
x_ITEM_TYPE                                VARCHAR2(40);
x_LAST_UPDATE_DATE                         DATE;
x_LOCATOR_FK                               NUMBER;
x_LOT_FK                                   NUMBER;
x_NETTABLE_FLAG                            VARCHAR2(15);
x_PO_DEL_QTY                               NUMBER;
x_PO_DEL_VAL_B                             NUMBER;
x_PO_DEL_VAL_G                             NUMBER;
x_PRD_DATE_FK                              NUMBER;
x_TOTAL_REC_QTY                            NUMBER;
x_TOTAL_REC_VAL_B                          NUMBER;
x_TOTAL_REC_VAL_G                          NUMBER;
x_TOT_CUST_SHIP_QTY                        NUMBER;
x_TOT_CUST_SHIP_VAL_B                      NUMBER;
x_TOT_CUST_SHIP_VAL_G                      NUMBER;
x_TOT_ISSUES_QTY                           NUMBER;
x_TOT_ISSUES_VAL_B                         NUMBER;
x_TOT_ISSUES_VAL_G                         NUMBER;
x_TO_ORG_QTY                               NUMBER;
x_TO_ORG_VAL_B                             NUMBER;
x_TO_ORG_VAL_G                             NUMBER;
x_TRX_DATE_FK                              NUMBER;
x_USER_ATTRIBUTE1                          VARCHAR2(240);
x_USER_ATTRIBUTE10                         VARCHAR2(240);
x_USER_ATTRIBUTE11                         VARCHAR2(240);
x_USER_ATTRIBUTE12                         VARCHAR2(240);
x_USER_ATTRIBUTE13                         VARCHAR2(240);
x_USER_ATTRIBUTE14                         VARCHAR2(240);
x_USER_ATTRIBUTE15                         VARCHAR2(240);
x_USER_ATTRIBUTE2                          VARCHAR2(240);
x_USER_ATTRIBUTE3                          VARCHAR2(240);
x_USER_ATTRIBUTE4                          VARCHAR2(240);
x_USER_ATTRIBUTE5                          VARCHAR2(240);
x_USER_ATTRIBUTE6                          VARCHAR2(240);
x_USER_ATTRIBUTE7                          VARCHAR2(240);
x_USER_ATTRIBUTE8                          VARCHAR2(240);
x_USER_ATTRIBUTE9                          VARCHAR2(240);
x_USER_FK1_KEY                             NUMBER;
x_USER_FK2_KEY                             NUMBER;
x_USER_FK3_KEY                             NUMBER;
x_USER_FK4_KEY                             NUMBER;
x_USER_FK5_KEY                             NUMBER;
x_USER_MEASURE1                            NUMBER;
x_USER_MEASURE2                            NUMBER;
x_USER_MEASURE3                            NUMBER;
x_USER_MEASURE4                            NUMBER;
x_USER_MEASURE5                            NUMBER;
x_WIP_ASSY_QTY                             NUMBER;
x_WIP_ASSY_VAL_B                           NUMBER;
x_WIP_ASSY_VAL_G                           NUMBER;
x_WIP_COMP_QTY                             NUMBER;
x_WIP_COMP_VAL_B                           NUMBER;
x_WIP_COMP_VAL_G                           NUMBER;
x_WIP_ISSUE_QTY                            NUMBER;
x_WIP_ISSUE_VAL_B                          NUMBER;
x_WIP_ISSUE_VAL_G                          NUMBER;
x_TRX_DATE                                 DATE;
x_PERIOD_FLAG                              NUMBER;

--------

cursor c_1 is
  select
        avg(nvl(vsize(trunc(mmt.TRANSACTION_DATE)||mmt.ORGANIZATION_ID||mmt.INVENTORY_ITEM_ID||mmt.COST_GROUP_ID||mmt.REVISION||mmt.SUBINVENTORY_CODE||mmt.LOCATOR_ID),0)),
	avg(nvl(vsize(cost_group_id),0)),
	avg(nvl(vsize(mmt.INVENTORY_ITEM_ID||mmt.ORGANIZATION_ID),0)),
	avg(nvl(vsize(mmt.ORGANIZATION_ID),0)),
	avg(nvl(vsize(mmt.LOCATOR_ID||mmt.SUBINVENTORY_CODE||mmt.ORGANIZATION_ID),0)),
	avg(nvl(vsize(sum(primary_quantity)),0))
    from mtl_material_transactions mmt
   where transaction_date between p_from_date and p_to_date
GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,
		  mmt.COST_GROUP_ID,mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.locator_id;


 cursor c_2 is
     SELECT
          avg(nvl(vsize(sum(mta.BASE_TRANSACTION_VALUE)),0))
     FROM MTL_MATERIAL_TRANSACTIONS mmt,
          MTL_TRANSACTION_ACCOUNTS mta
    WHERE mmt.transaction_id = mta.transaction_id
      AND mta.accounting_line_type = 1
      AND ((mmt.transaction_action_id in (2,3,12)
           AND mmt.primary_quantity >0 )
          OR (mmt.transaction_action_id in (31,32)
              AND mmt.transaction_source_type_id=5))
      AND mmt.transaction_date >= p_from_date
      AND mmt.transaction_date <= p_to_date
 GROUP BY trunc(mmt.TRANSACTION_DATE),mmt.ORGANIZATION_ID,mmt.INVENTORY_ITEM_ID,mmt.COST_GROUP_ID,
          mmt.REVISION,mmt.SUBINVENTORY_CODE,mmt.LOCATOR_ID;


  CURSOR c_3 IS
	SELECT
		avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;

  CURSOR c_4 is
	SELECT  avg(nvl(vsize(gsob.currency_code), 0))
        FROM    hr_all_organization_units hou,
                hr_organization_information hoi,
                gl_sets_of_books gsob
        WHERE   hou.organization_id  = hoi.organization_id
          AND ( hoi.org_information_context || '') ='Accounting Information'
          AND hoi.org_information1    = to_char(gsob.set_of_books_id)  ;


  BEGIN

  OPEN c_1;
  FETCH c_1 INTO
       x_INV_DAILY_STATUS_PK,
       x_COST_GROUP,
       x_ITEM_ORG_FK,
       x_INV_ORG_FK,
       x_LOCATOR_FK,
       x_END_ONH_QTY;

  CLOSE c_1;

/*------------------------------------------------------------------------------------------------
The above value for Ending Onhand quantity should be almost the same
for BEG/END/AVG onhand, wip and intransit as well as total receipt and issue qty

x_AVG_INT_QTY
x_AVG_ONH_QTY
x_AVG_WIP_QTY
x_BEG_INT_QTY
x_BEG_ONH_QTY
x_BEG_WIP_QTY
x_END_INT_QTY
x_END_ONH_QTY
x_END_WIP_QTY
x_TOTAL_REC_QTY
x_TOT_ISSUES_QTY
                   QTYsize = 10*x_END_ONH_QTY;

    For other QTY columns we are taking the average of the columns that will be populated.

x_FROM_ORG_QTY
x_INV_ADJ_QTY
x_PO_DEL_QTY
x_TOT_CUST_SHIP_QTY
x_TO_ORG_QTY
x_WIP_ASSY_QTY
x_WIP_COMP_QTY
x_WIP_ISSUE_QTY
                  QTYsize = (10+4)*x_END_ONH_QTY
---------------------------------------------------------------------------------------------------*/

   x_END_ONH_QTY := 14*x_END_ONH_QTY;



  OPEN c_2;
  FETCH c_2 INTO
     x_END_ONH_VAL_B;

 CLOSE c_2;

/*-------------------------------------------------------------------------------------------------
THe above average value for the ending_onhand_value should be the same for

x_AVG_INT_VAL_B
x_AVG_INT_VAL_G
x_AVG_ONH_VAL_B
x_AVG_ONH_VAL_G
x_AVG_WIP_VAL_B
x_AVG_WIP_VAL_G
x_BEG_INT_VAL_B
x_BEG_INT_VAL_G
x_BEG_ONH_VAL_B
x_BEG_ONH_VAL_G
x_BEG_WIP_VAL_B
x_BEG_WIP_VAL_G
x_END_INT_VAL_B
x_END_INT_VAL_G
x_END_ONH_VAL_B
x_END_ONH_VAL_G
x_END_WIP_VAL_B
x_END_WIP_VAL_G
x_TOTAL_REC_VAL_B
x_TOTAL_REC_VAL_G
x_TOT_ISSUES_VAL_B
x_TOT_ISSUES_VAL_G

       avg size for value columns = 2*11*x_END_ONH_VAL_B;  (2 is for VAL_G and VAL_B)

For other value columns we will take an average
x_FROM_ORG_VAL_B
x_FROM_ORG_VAL_G
x_INV_ADJ_VAL_B
x_INV_ADJ_VAL_G
x_PO_DEL_VAL_B
x_PO_DEL_VAL_G
x_TOT_CUST_SHIP_VAL_B
x_TOT_CUST_SHIP_VAL_G
x_TO_ORG_VAL_B
x_TO_ORG_VAL_G
x_WIP_ASSY_VAL_B
x_WIP_ASSY_VAL_G
x_WIP_COMP_VAL_B
x_WIP_COMP_VAL_G
x_WIP_ISSUE_VAL_B
x_WIP_ISSUE_VAL_G
    avg size for value columns =  2*(11+4)*x_END_ONH_VAL_B

--------------------------------------------------------------------------------------------------*/


    x_END_ONH_VAL_B:= 2*14*x_END_ONH_VAL_B;



    x_PRD_DATE_FK := x_date;
    x_TRX_DATE_FK := x_date;

    x_total := 3 +
	    x_total +
            ceil(x_INV_DAILY_STATUS_PK + 1) +
		ceil(x_COST_GROUP + 1) +
		ceil(x_ITEM_ORG_FK + 1) +
		ceil(x_INV_ORG_FK + 1) +
		ceil(x_LOCATOR_FK + 1) +
		ceil(x_END_ONH_QTY + 14) +         ---  Add 14 becuase there are 30 diff columns.
		ceil(x_END_ONH_VAL_B + 30) +       ---  Add 30 because there are 30 different columns.
		ceil(x_PRD_DATE_FK + 1) +
		ceil(x_TRX_DATE_FK + 1);

    OPEN c_3;
      FETCH c_3 INTO x_INSTANCE_FK;
    CLOSE c_3;

    x_total := x_total + ceil(x_INSTANCE_FK + 1);

    OPEN c_4 ;
      FETCH c_4 INTO x_BASE_CURRENCY_FK;
    CLOSE c_4 ;

    x_total := x_total + ceil(x_BASE_CURRENCY_FK + 1);


    -- Miscellaneous
    x_total := x_total + 4 * ceil(x_INSTANCE_FK + 1);

    p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body OPI_EDW_INV_DAILY_STAT_F_SZ

/
