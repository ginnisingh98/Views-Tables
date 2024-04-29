--------------------------------------------------------
--  DDL for Package Body OPI_PMI_IDS_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_PMI_IDS_SUMMARY" AS
/*$Header: OPIMINDB.pls 115.19 2004/01/02 19:05:32 bthammin ship $ */
PROCEDURE post_perd_bal_recs(p_last_run_date date) IS
/*===================================================================================+
 |     post_perd_bal_recs;                                                           |
 |          This procedure is to create period marker rows at location, lot          |
 |          level for all periods defined in GL Periods from last run date to current|
 |          date. There will be one row at the beginning of the period(period flag=0)|
 |          and one at end of the period(period flag = 1 ).                          |
 |          These rows are created for collection hook program to get period         |
 |          beginning and ending inventory balances.                                 |
 +===================================================================================*/
/*===================================================================================+
 |   Following Cursor identifies whethear new period marker rows need to be created  |
 |   or not.                                                                         |
 +===================================================================================*/
CURSOR check_cldr_for_perd_bal IS
select c.co_code co_code,
       c.start_date start_date,
       c.end_date end_date,
       d.last_start_date last_start_date,
       d.last_end_date last_end_date
FROM
(   select a.co_code co_code,
          a.period_num period_num,
          a.start_date cur_start_date,
          a.end_Date cur_end_Date,
          b.start_date last_start_date,
          b.end_Date last_end_date
  from OPI_OPM_GL_CALENDAR_V a,OPI_OPM_GL_CALENDAR_V b
  where a.co_code = b.co_code and
  sysdate between a.start_date and a.end_Date AND
  p_last_run_date between b.start_date and b.end_Date and
  a.start_date <> b.start_date ) d,
  OPI_OPM_GL_CALENDAR_V c
where c.co_code = d.co_code
and  c.start_date > d.last_end_date
and  c.start_date <= sysdate
order by c.co_code,c.start_date;
cldr_rec check_cldr_for_perd_bal%ROWTYPE;
BEGIN
   OPEN check_cldr_for_perd_bal;
   LOOP
     FETCH check_cldr_for_perd_bal INTO cldr_rec;
     EXIT WHEN check_cldr_for_perd_bal%NOTFOUND;

  /* Insert new period marker rows using last period ending period marker rows.
     If there are no rows in summary table for last period then creates period
     marker rows using IC_LOCT_INV
     */
     edw_log.put_line ('Before creating New Period begin marker row for Company  :'||cldr_rec.co_code);

     INSERT INTO   opi_pmi_inv_daily_stat_sum (CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,TRX_DATE
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
	,period_flag)
     (SELECT CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,0 FROM_ORG_QTY
	,0 INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,0 PO_DEL_QTY
	,0 TOTAL_REC_QTY
	,0 TOT_CUST_SHIP_QTY
	,0 TOT_ISSUES_QTY
	,0 TO_ORG_QTY
	,cldr_rec.start_date TRX_DATE
	,0 WIP_COMP_QTY
	,0 WIP_ISSUE_QTY
	,0
      FROM opi_pmi_inv_daily_stat_sum
      WHERE co_code  = cldr_rec.co_code
        AND trx_date = cldr_rec.last_end_Date);

      IF sql%rowcount = 0 THEN
       INSERT INTO   opi_pmi_inv_daily_stat_sum (CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,TRX_DATE
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
	,period_flag)
     (SELECT org.CO_CODE
	,org.ORGN_CODE
	,loct.WHSE_CODE
	,loct.LOCATION
	,0 AVG_ONH_QTY
	,0 BEG_ONH_QTY
	,sysdate CREATION_DATE
	,0 END_ONH_QTY
	,0 FROM_ORG_QTY
	,0 INV_ADJ_QTY
	,ITEM_ID
	,sysdate LAST_UPDATE_DATE
	,LOT_ID
	,0 PO_DEL_QTY
	,0 TOTAL_REC_QTY
	,0 TOT_CUST_SHIP_QTY
	,0 TOT_ISSUES_QTY
	,0 TO_ORG_QTY
	,cldr_rec.start_date TRX_DATE
	,0 WIP_COMP_QTY
	,0 WIP_ISSUE_QTY
	,0
      FROM IC_LOCT_INV loct,
           IC_WHSE_MST whs,
           SY_ORGN_MST org
      WHERE co_code        = cldr_rec.co_code
        AND loct.whse_code = whs.whse_code
        AND whs.orgn_code  = org.orgn_code);

     edw_log.put_line ('After creating New Period begin marker row for Company  :'||cldr_rec.co_code );
     edw_log.put_line ('Before creating New Period end marker row for Company  :'||cldr_rec.co_code );



       INSERT INTO   opi_pmi_inv_daily_stat_sum (CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,TRX_DATE
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
	,period_flag)
     (SELECT org.CO_CODE
	,org.ORGN_CODE
	,loct.WHSE_CODE
	,loct.LOCATION
	,0 AVG_ONH_QTY
	,0 BEG_ONH_QTY
	,sysdate CREATION_DATE
	,0 END_ONH_QTY
	,0 FROM_ORG_QTY
	,0 INV_ADJ_QTY
	,ITEM_ID
	,sysdate LAST_UPDATE_DATE
	,LOT_ID
	,0 PO_DEL_QTY
	,0 TOTAL_REC_QTY
	,0 TOT_CUST_SHIP_QTY
	,0 TOT_ISSUES_QTY
	,0 TO_ORG_QTY
	,cldr_rec.end_date TRX_DATE
	,0 WIP_COMP_QTY
	,0 WIP_ISSUE_QTY
	,1
      FROM IC_LOCT_INV loct,
           IC_WHSE_MST whs,
           SY_ORGN_MST org
      WHERE co_code        = cldr_rec.co_code
        AND loct.whse_code = whs.whse_code
        AND whs.orgn_code  = org.orgn_code);
   ELSE
     INSERT INTO   opi_pmi_inv_daily_stat_sum (CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,TRX_DATE
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
	,period_flag)
     (SELECT CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,0 FROM_ORG_QTY
	,0 INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,0 PO_DEL_QTY
	,0 TOTAL_REC_QTY
	,0 TOT_CUST_SHIP_QTY
	,0 TOT_ISSUES_QTY
	,0 TO_ORG_QTY
	,cldr_rec.end_date TRX_DATE
	,0 WIP_COMP_QTY
	,0 WIP_ISSUE_QTY
	,1
      FROM opi_pmi_inv_daily_stat_sum
      WHERE co_code  = cldr_rec.co_code
        AND trx_date = cldr_rec.last_end_Date);
    END IF;

  edw_log.put_line ('Before creating New Period end marker row for Company  :'||cldr_rec.co_code );
  END LOOP;
  CLOSE check_cldr_for_perd_bal;
  commit;
END post_perd_bal_recs;
PROCEDURE populate_net_change (p_last_run_date date) IS
/*=================================================================================+
 |     populate_net_change;                                                        |
 |          It moves transaction data created after last summarization date upto   |
 |          current date into work table from ic_tran_pnd and ic_tran_cmp.         |
 +=================================================================================*/
   l_stmt varchar2(2000);
   l_last_run_date  date:= p_last_run_date;
BEGIN
    -- get all new trasactions from ic_tran_cmp and ic_tran_pnd and insert into net change table

  edw_log.put_line ('Before Indentifying Delta change  :');

               INSERT INTO opi_pmi_trans_inc (co_code,orgn_code,whse_code,item_id,
                      line_id,lot_id,location,doc_type,DOC_ID,DOC_LINE,TRANS_DATE,
                      TRANS_QTY,TRANS_QTY2,QC_GRADE,LOT_STATUS,CURR_BAL
                      ,TRANS_UM,TRANS_UM2,REASON_CODE,LINE_TYPE,CREATION_DATE,LAST_UPDATE_DATE) (
                   SELECT
                    org.CO_CODE,org.ORGN_CODE,cmp.WHSE_CODE,cmp.ITEM_ID,cmp.LINE_ID,cmp.LOT_ID,
                    nvl(cmp.LOCATION,'NONE'),cmp.DOC_TYPE,cmp.DOC_ID,cmp.DOC_LINE,cmp.TRANS_DATE,
                    cmp.TRANS_QTY,cmp.TRANS_QTY2,cmp.QC_GRADE,cmp.LOT_STATUS,loct.LOCT_ONHAND
                    ,cmp.TRANS_UM,cmp.TRANS_UM2,cmp.REASON_CODE,cmp.LINE_TYPE,cmp.CREATION_DATE,cmp.LAST_UPDATE_DATE
                  from ic_tran_cmp cmp,ic_loct_inv loct, sy_orgn_mst org,ic_whse_mst whse
                  where trunc(cmp.last_update_date) >= trunc(l_last_run_date)
                    AND loct.item_id  = cmp.item_id   AND loct.lot_id   = cmp.lot_id
                    AND loct.whse_code = cmp.whse_code AND loct.location = cmp.location
                    AND cmp.whse_code is not null
                    AND whse.whse_code = loct.whse_code
                    AND whse.orgn_code = org.orgn_code
                    and cmp.whse_code  = whse.whse_code
                    AND cmp.location is not null)
                  UNION ALL ( SELECT
                    org.CO_CODE,org.ORGN_CODE,pnd.WHSE_CODE,pnd.ITEM_ID,pnd.LINE_ID,pnd.LOT_ID,
                    nvl(pnd.LOCATION,'NONE'),pnd.DOC_TYPE,pnd.DOC_ID,pnd.DOC_LINE,pnd.TRANS_DATE,pnd.TRANS_QTY,
                    pnd.TRANS_QTY2,pnd.QC_GRADE,pnd.LOT_STATUS,loct.LOCT_ONHAND
                    ,pnd.TRANS_UM,pnd.TRANS_UM2,pnd.REASON_CODE,pnd.LINE_TYPE,pnd.CREATION_DATE,pnd.LAST_UPDATE_DATE
                    from ic_tran_pnd pnd ,ic_loct_inv loct , sy_orgn_mst org,ic_whse_mst whse
                  where trunc(pnd.last_update_date) >= trunc(l_last_run_date)  AND pnd.COMPLETED_IND = 1
                    AND loct.item_id  = pnd.item_id   AND loct.lot_id   = pnd.lot_id
                    AND loct.whse_code = pnd.whse_code AND loct.location = pnd.location
                    AND whse.whse_code = loct.whse_code
                    AND whse.orgn_code = org.orgn_code
                    and pnd.whse_code  = whse.whse_code
                    AND pnd.delete_mark = 0);

  edw_log.put_line ('After Indentifying Delta change  :');

  commit;
END;

PROCEDURE populate_day_sum_temp IS
/*===================================================================================+
 |     populate_day_sum_temp;                                                        |
 |          Summarize net change records at day level and transform rows             |
 |          from horizantal (row) structutre to vertical (column) structure          |
 |          In transaction table transaction are stored in multiple rows             |
 |          we need to summarize data into multiple columns based on doc_type.       |
 |          All transactions are summarized at day level grouped by Transaction Type |
 +===================================================================================*/

   l_stmt varchar2(2000);
BEGIN

   /*  summarize new transactions at day level and convert from
       horizontal (row structure) to vertical (column) structure
       We use trunc(trans_date) to summarize all transaction at day level
       All Summarizations are Lot, Location,day Level
       All OPM(Oracle Process Manufacturing) Transactions are grouped as follows

       TOTAL_ISSUES_QTY  This is sum of all transaction which reduces inventory
           OPSO   Sales Orders
           OPBO   Blanket Sales Order
           OMSO   Sales Orders Created through Order Management
           PROD and LINE_TYPE = -1 Ingredients consumed in Production
           TRNI and LINE_TYPE = -1 (Transfer Immediate) Transferred out Quantity
           TRNR and LINE_TYPE = -1 (Transfer Journal) Transferred out Quantity
           XFER If trans_qty < 0    Transfer Transaction
       WIP_COMP_QTY   This is sum of product/by product Quantity Produced on a given day
           PROD Production Transaction
             LINE_TYPE = 1   Product
             LINE_TYPE = 2   By Product
       WIP_ISSUE_QTY   This is sum of Ingredient Quantity  on a given day
           PROD Production Transaction
             LINE_TYPE = -1   Ingredient
       TOTAL_REC_QTY  Total quantity received
           RECV    Purchase Order Receiving
           POSR    Purchase Order Quick Receipt
           CREI    Create Immediate
           CRER    Create Journal
           PROD    Production Transactions (LINE_TYPE 1-Product 2-Byproduct)
           TRNI and LINE_TYPE = 1 (Transfer Immediate) Transferred in Quantity
           TRNR and LINE_TYPE = 1 (Transfer Journal) Transferred in Quantity
           XFER If trans_qty > 0   Transfer Transaction
       TOT_CUST_SHIP_QTY  Total Quantity Shipped to Customer
           OPSO   Sales Orders
           OPBO   Blanket Sales Order
           OMSO   Sales Orders Created through Order Management
       INV_ADJ_QTY   Total Inventory Adjustments
           ADJI   Adjust Immediate
           ADJR   Adjust Journal
           PICY   Physical Inventory - Cycle No
           PIPH   Physical Inventory - Physical
           REPI   Replace Quantity/Status - Immediate
           REPR   Replace Quantity/Status - Journaled
        PO_DEL_QTY   Purchase Order Delivered Quantity
           RECV    Purchase Order Receiving
           POSR    Purchase Order Quick Receipt
           RTRN    Purchase Order Returns
        TO_ORG_QTY  Quantity Transferred in
           TRNI and LINE_TYPE = 1 (Transfer Immediate) Transferred in Quantity
           TRNR and LINE_TYPE = 1 (Transfer Journal) Transferred in Quantity
           XFER If trans_qty > 0   Transfer Transaction
        FROM_ORG_QTY  Quantiry Transferred Out
           TRNI and LINE_TYPE = -1 (Transfer Immediate) Transferred out Quantity
           TRNR and LINE_TYPE = -1 (Transfer Journal) Transferred out Quantity
           XFER If trans_qty < 0    Transfer Transaction   */


    edw_log.put_line ('After Indentifying Delta change  :');

          INSERT INTO  opi_pmi_day_sum_temp
              (co_code,orgn_code,whse_code,item_id,lot_id,location,trans_date,TOT_ISSUES_QTY,
               WIP_COMP_QTY,WIP_ISSUE_QTY,TOTAL_REC_QTY,TOT_CUST_SHIP_QTY, INV_ADJ_QTY,
               PO_DEL_QTY,TO_ORG_QTY,FROM_ORG_QTY,
               Period_start_date,Period_end_date,cost_mthd,curr_bal)
        (select inc.co_code,Orgn_code,whse_code,item_id,lot_id,LOCATION,trunc(trans_date) Trans_date,
          sum(decode(doc_type,'OPSO',trans_qty,'OPBO',trans_qty,'OMSO',trans_qty,
                     'PROD',decode(line_type,-1,trans_qty),
                     'TRNI',decode(line_type,-1,trans_qty),
                     'TRNR',decode(line_type,-1,trans_qty),
                     'XFER',decode(SIGN(trans_qty),-1,trans_qty),0)) TOTAL_ISSUES_QTY,
          sum(decode(doc_type,'PROD',decode(line_type,1,trans_qty,2,trans_qty),0)) WIP_COMP_QTY,
          sum(decode(doc_type,'PROD',decode(line_type,-1,trans_qty),0)) WIP_ISSUE_QTY,
          sum(decode(doc_type,'RECV',trans_qty,'POSR',trans_qty,'RTRN',trans_qty,
                     'CREI',trans_qty,'CRER',trans_qty,'PROD',decode(line_type,1,trans_qty,2,trans_qty),
                     'TRNI',decode(line_type,1,trans_qty),'TRNR',decode(line_type,1,trans_qty),
                     'XFER',decode(SIGN(trans_qty),1,trans_qty),0)) TOTAL_REC_QTY,
          sum(decode(doc_type,'OPSO',trans_qty,'OPBO',trans_qty,'OMSO',trans_qty,0)) TOT_CUST_SHIP_QTY,
          sum(decode(doc_type,'ADJI',trans_qty,'ADJR',trans_qty,'PICY',trans_qty,'PIPH',trans_qty,
            'REPI',trans_qty,'REPR',trans_qty,0 )) INV_ADJ_QTY,
          sum(decode(doc_type,'RECV',trans_qty,'POSR',trans_qty,
                     'PORD',trans_qty,'RTRN',trans_qty,0)) PO_DEL_QTY,
          sum(decode(doc_type,'TRNI',decode(line_type,1,trans_qty),
                     'TRNR',decode(line_type,1,trans_qty),
                     'XFER',decode(SIGN(trans_qty),1,trans_qty,0),0)) TO_ORG_qty,
          sum(decode(doc_type,'TRNI',decode(line_type,-1,trans_qty),
                     'TRNR',decode(line_type,-1,trans_qty),
                     'XFER',decode(SIGN(trans_qty),-1,trans_qty,0),0)) FROM_ORG_QTY,
          glcldr.Start_date Period_start_date,
          glcldr.end_Date  Period_end_date,
          glcldr.gl_cost_mthd  cost_mthd,
          inc.curr_bal  curr_bal
          from opi_pmi_trans_inc inc,OPI_OPM_GL_CALENDAR_V glcldr
          where trunc(trans_date) between glcldr.start_date and glcldr.end_date
             AND inc.co_code = glcldr.co_code
            group by inc.co_code,Orgn_code,whse_code,item_id,lot_id,Location,trunc(trans_date),
           glcldr.Start_date, glcldr.end_Date,inc.curr_bal,glcldr.gl_cost_mthd);
       commit;

    edw_log.put_line ('After Summarizing data at day level  :');

END;


PROCEDURE  identify_summary_recs_to_chng  IS
/*===================================================================================+
 |     identify_summary_recs_to_chng;                                                |
 |          Identifies Rows to be re-summarized becasue of new transaction.  This    |
 |          procedure moves rows identified from Summary table to work table         |
 +===================================================================================*/
   l_stmt varchar2(4000);
BEGIN
/*  Following insert statement identifies from which date we need to re-summarize summary table
    for each lot,warehouse,location */


    edw_log.put_line ('Before idenfying rows to be re-summaeized  :');

         INSERT INTO opi_pmi_ids_idnt (co_code,orgn_code,whse_code,location,item_id,lot_id, trans_date ,
                  start_date  ,end_date) (
           SELECT co_code,orgn_code,whse_code,location,item_id,lot_id,min(trans_date) trans_date ,
                 min(period_start_date) start_date  ,min(period_end_date) end_date
           FROM  opi_pmi_day_sum_temp inc
           group by co_code,orgn_code,whse_code,location,item_id,lot_id );


    edw_log.put_line ('After idenfying rows to be re-summarized  :');

        -- dbms_output.put_line (' Before Insert ');

/*  following insert moves data to be re-summarized from summary table to work table identified
    in above step  and marks these row with operation_code = 'UPDATE' */


    edw_log.put_line ('Before moving rows to be re-summaeized to temp table :');

       INSERT INTO  opi_pmi_ids_temp   (CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,TRX_DATE
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
      ,period_flag
      ,OPERATION_CODE )  (
      SELECT sm.CO_CODE
	,sm.ORGN_CODE
	,sm.WHSE_CODE
	,sm.LOCATION
	,sm.AVG_ONH_QTY
	,sm.BEG_ONH_QTY
	,sm.CREATION_DATE
	,sm.END_ONH_QTY
	,sm.FROM_ORG_QTY
	,sm.INV_ADJ_QTY
	,sm.ITEM_ID
	,sm.LAST_UPDATE_DATE
	,sm.LOT_ID
	,sm.PO_DEL_QTY
	,sm.TOTAL_REC_QTY
	,sm.TOT_CUST_SHIP_QTY
	,sm.TOT_ISSUES_QTY
	,sm.TO_ORG_QTY
	,sm.TRX_DATE
	,sm.WIP_COMP_QTY
	,sm.WIP_ISSUE_QTY
      ,sm.period_flag
      ,'UPDATE' OPERATION_CODE
      from opi_pmi_inv_daily_stat_sum  sm, opi_pmi_ids_idnt idnt
      where          idnt.co_code        =  sm.co_code        AND
                     idnt.orgn_code      =  sm.orgn_code      AND
                     idnt.whse_code      =  sm.whse_code      AND
                     idnt.location       =  sm.location       AND
                     idnt.item_id        =  sm.item_id        AND
                     idnt.lot_id         =  sm.lot_id         AND
                     sm.trx_date        >= idnt.start_date     ) ;
    commit;

    edw_log.put_line ('rows to be re-summaeized are moved to temp table :');

END  identify_summary_recs_to_chng;



PROCEDURE summarize_temp_summary IS
/*===================================================================================+
 |   This Procedure Summarizes and calculates day beginning and Ending Balances      |
 |   and Moves data from day summary table to temporary summary table                |
 +===================================================================================*/

    CURSOR summerize_temp_sum IS
       select * from opi_pmi_day_sum_temp
       order by trans_date ASC;
    rec_summary summerize_temp_sum%ROWTYPE;
    CURSOR  get_records_to_change IS
      select *
      from opi_pmi_ids_temp
      where co_code          = rec_summary.co_code
        AND  whse_code       = rec_summary.whse_code
        AND  orgn_code       = rec_summary.orgn_code
        AND  Location        = rec_summary.location
        AND  item_id         = rec_summary.item_id
        AND  lot_id          = rec_summary.lot_id
        AND  trx_Date        >= rec_summary.trans_date
      order by trx_date ASC;
    CURSOR  get_balance_row IS
      select trx_Date,end_onh_qty,beg_onh_qty
      from opi_pmi_inv_daily_stat_sum
      where co_code          = rec_summary.co_code
        AND  whse_code       = rec_summary.whse_code
        AND  orgn_code       = rec_summary.orgn_code
        AND  Location        = rec_summary.location
        AND  item_id         = rec_summary.item_id
        AND  lot_id          = rec_summary.lot_id
        AND  trx_Date < rec_summary.trans_date
        order by trx_date desc;
    ids_bal_rec     get_balance_row%ROWTYPE;
    ids_temp_rec    get_records_to_change%ROWTYPE;
    l_cost_mthd     cm_cmpt_dtl.cost_mthd_code%TYPE;
    l_cmpntcls_id   cm_cmpt_dtl.cost_cmpntcls_id%TYPE := null;
    l_analysis_code cm_cmpt_dtl.cost_analysis_code%TYPE := null;
    L_perd_st_date  DATE;
    l_perd_end_date DATE;
    l_retreive_ind  number := 1;
    l_total_cost    number;
    l_no_of_rows    number;
    rc              number;
    l_end_qty       NUMBER := 0;
    l_beg_qty       number := 0;
    l_day_tr        number := 0;
    l_n_tr_qty      number := 0;
    l_n_beg_qty     number := 0;
    l_n_end_qty     number := 0;
    l_prev_end_qty  number := null;
BEGIN

    edw_log.put_line ('at start of  Summarize and calculate day beginning and Ending Balances :');

      OPEN summerize_temp_sum;
      LOOP
        FETCH summerize_temp_sum INTO rec_summary;
        EXIT when summerize_temp_sum%NOTFOUND;
      BEGIN
       /*   update row if already a row exists for company,organization,warehouse,location
            item,lot and transaction date                                                  */
               UPDATE   opi_pmi_ids_temp
                 SET         wip_comp_qty           = rec_summary.wip_comp_qty,
                             wip_issue_qty          = rec_summary.wip_issue_qty,
                             po_del_qty             = rec_summary.po_del_qty,
                             total_rec_qty          = rec_summary.total_rec_qty,
                             from_org_qty           = rec_summary.from_org_qty,
                             to_org_qty             = rec_summary.to_org_qty,
                             tot_cust_ship_qty      = rec_summary.tot_cust_ship_qty,
                             inv_adj_qty            = rec_summary.inv_adj_qty,
                             tot_issues_qty         = rec_summary.tot_issues_qty,
                             creation_date          = sysdate,
                             last_update_date       = sysdate
                WHERE  co_code         = rec_summary.co_code
                  AND  whse_code       = rec_summary.whse_code
                  AND  orgn_code       = rec_summary.orgn_code
                  AND  Location        = rec_summary.location
                  AND  item_id         = rec_summary.item_id
                  AND  lot_id          = rec_summary.lot_id
                  AND  trunc(trx_Date) = trunc(rec_summary.trans_date);
       /*   if above update fails to find a matching row for company,organization,warehouse,location
            item,lot and transaction date combination then insert the row with operation code = 'INSERT'
                           */

       if sql%rowcount = 0 THEN
           INSERT into   opi_pmi_ids_temp ( co_code,
                             orgn_code,
                             whse_code,
                             location,
                             item_id,
                             lot_id,
                             trx_date,
                             wip_comp_qty,
                             wip_issue_qty,
                             po_del_qty,
                             total_rec_qty,
                             from_org_qty,
                             to_org_qty,
                             tot_cust_ship_qty,
                             inv_adj_qty,
                             tot_issues_qty,
                             creation_date,
                             last_update_date,
                             operation_code)
                   VALUES
                         (rec_summary.co_code,
                          rec_summary.orgn_code,
                          rec_summary.whse_code,
                          rec_summary.location,
                          rec_summary.item_id,
                          rec_summary.lot_id,
                          rec_summary.trans_date,
                          rec_summary.wip_comp_qty,
                          rec_summary.wip_issue_qty,
                          rec_summary.po_del_qty,
                          rec_summary.total_rec_qty,
                          rec_summary.from_org_qty,
                          rec_summary.to_org_qty,
                          rec_summary.tot_cust_ship_qty,
                          rec_summary.inv_adj_qty,
                          rec_summary.tot_issues_qty,
                          sysdate,
                          sysdate,
                          'INSERT');
              END IF;
            END;
        END LOOP;
        CLOSE summerize_temp_sum;
        commit;


    edw_log.put_line ('at end of  Summarize and calculate day beginning and Ending Balances :');
    edw_log.put_line ('at start of  Calculate day beginning and Ending Balances :');


--   Calculate On Hand Balances
      OPEN summerize_temp_sum;
      LOOP
        FETCH summerize_temp_sum INTO rec_summary;
        EXIT when summerize_temp_sum%NOTFOUND;
        OPEN get_balance_row;
        FETCH get_balance_row into ids_bal_rec;

/*
   if we can't find the balance row for company,organization,warehouse,location,item,lot and transaction date
   combination then we need to create the period marker rows for this combination since this combination is
   first occrence */
        IF get_balance_row%NOTFOUND THEN
           ids_bal_rec.end_onh_qty := NULL;
           ids_bal_rec.beg_onh_qty := NULL;
           ids_bal_rec.trx_date    := NULL;
           BEGIN
             UPDATE opi_pmi_ids_temp
             SET period_flag = 0
             where co_code          = rec_summary.co_code
               AND  whse_code       = rec_summary.whse_code
               AND  orgn_code       = rec_summary.orgn_code
               AND  Location        = rec_summary.location
               AND  item_id         = rec_summary.item_id
               AND  lot_id          = rec_summary.lot_id
               AND  trx_Date        = rec_summary.period_start_date;
            IF sql%rowCOUNT = 0 THEN
             INSERT into   opi_pmi_ids_temp ( co_code,
                             orgn_code,
                             whse_code,
                             location,
                             item_id,
                             lot_id,
                             trx_date,
                             wip_comp_qty,
                             wip_issue_qty,
                             po_del_qty,
                             total_rec_qty,
                             from_org_qty,
                             to_org_qty,
                             tot_cust_ship_qty,
                             inv_adj_qty,
                             tot_issues_qty,
                             beg_onh_qty,
                             end_onh_qty,
                             avg_onh_qty,
                             period_flag,
                             creation_date,
                             last_update_date,
                             operation_code)
                   VALUES
                         (rec_summary.co_code,
                          rec_summary.orgn_code,
                          rec_summary.whse_code,
                          rec_summary.location,
                          rec_summary.item_id,
                          rec_summary.lot_id,
                          rec_summary.period_start_date,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          sysdate,
                          sysdate,
                          'INSERT');
             END IF;
             UPDATE opi_pmi_ids_temp
             SET period_flag = 1
             where co_code          = rec_summary.co_code
               AND  whse_code       = rec_summary.whse_code
               AND  orgn_code       = rec_summary.orgn_code
               AND  Location        = rec_summary.location
               AND  item_id         = rec_summary.item_id
               AND  lot_id          = rec_summary.lot_id
               AND  trx_Date        = rec_summary.period_end_date;
             IF SQL%ROWCOUNT = 0 THEN
              INSERT into  opi_pmi_ids_temp ( co_code,
                             orgn_code,
                             whse_code,
                             location,
                             item_id,
                             lot_id,
                             trx_date,
                             wip_comp_qty,
                             wip_issue_qty,
                             po_del_qty,
                             total_rec_qty,
                             from_org_qty,
                             to_org_qty,
                             tot_cust_ship_qty,
                             inv_adj_qty,
                             tot_issues_qty,
                             beg_onh_qty,
                             end_onh_qty,
                             avg_onh_qty,
                             period_flag,
                             creation_date,
                             last_update_date,
                             operation_code)
                   VALUES
                         (rec_summary.co_code,
                          rec_summary.orgn_code,
                          rec_summary.whse_code,
                          rec_summary.location,
                          rec_summary.item_id,
                          rec_summary.lot_id,
                          rec_summary.period_end_date,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          sysdate,
                          sysdate,
                          'INSERT');
              END IF;
          END;
             UPDATE opi_pmi_ids_temp
             SET period_flag = 0
             where co_code          = rec_summary.co_code
               AND  whse_code       = rec_summary.whse_code
               AND  orgn_code       = rec_summary.orgn_code
               AND  Location        = rec_summary.location
               AND  item_id         = rec_summary.item_id
               AND  lot_id          = rec_summary.lot_id
               AND  trx_Date        = rec_summary.period_start_date;
             UPDATE opi_pmi_ids_temp
             SET period_flag = 1
             where co_code          = rec_summary.co_code
               AND  whse_code       = rec_summary.whse_code
               AND  orgn_code       = rec_summary.orgn_code
               AND  Location        = rec_summary.location
               AND  item_id         = rec_summary.item_id
               AND  lot_id          = rec_summary.lot_id
               AND  trx_Date        = rec_summary.period_end_date;


  /* following code is added to fix bug #1700563

  /********************************************************************************************************************
  ***    Above Insert statement creates period marker rows for current rows period. we need to insert marker        ***
  ***    rows for all the periods from current process period to either sysdate or till the period row which        ***
  ***    already summarized. i.e. take period1 .. period4.  we have data for period4 and now we are getting         ***
  ***    a backposted transaction in period1 then we need to create period marker rows for period1 though period 3. ***
  ***    above insert statements ensures we get period marker rows for period1.  following is to populate period    ***
  ***    marker rows for period2 and period3. at the same time if this is the first transaction for company,        ***
  ***    organization,warehouse,location,item,lot and transaction date combination then we need to create period    ***
  ***    marker rows till current period.                                                                           ***
  *********************************************************************************************************************/

              INSERT into  opi_pmi_ids_temp ( co_code,
                             orgn_code,
                             whse_code,
                             location,
                             item_id,
                             lot_id,
                             trx_date,
                             wip_comp_qty,
                             wip_issue_qty,
                             po_del_qty,
                             total_rec_qty,
                             from_org_qty,
                             to_org_qty,
                             tot_cust_ship_qty,
                             inv_adj_qty,
                             tot_issues_qty,
                             beg_onh_qty,
                             end_onh_qty,
                             avg_onh_qty,
                             period_flag,
                             creation_date,
                             last_update_date,
                             operation_code)
                       (SELECT p_marker_rows.co_code,
                          p_marker_rows.orgn_code,
                          p_marker_rows.whse_code,
                          p_marker_rows.location,
                          p_marker_rows.item_id,
                          p_marker_rows.lot_id,
                          p_marker_rows.start_date,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          sysdate,
                          sysdate,
                          'INSERT'
                       FROM
                         ((SELECT summ.co_code co_code,
                             summ.orgn_code orgn_code,
                             summ.whse_code whse_code,
                             summ.location  location,
                             summ.item_id   item_id,
                             summ.lot_id    lot_id,
                             glcldr.start_date start_date
                          FROM opi_pmi_ids_temp summ,
                               opi_opm_gl_calendar_v glcldr
                          WHERE summ.period_flag = 1
                             and trunc(summ.trx_date) = trunc(rec_summary.period_end_date)
                             and summ.co_code = glcldr.co_code
                             and glcldr.start_date > summ.trx_date
                             and glcldr.start_date <= SYSDATE
                             and summ.co_code = rec_summary.co_code
                             and summ.orgn_code = rec_summary.orgn_code
                             and summ.whse_code = rec_summary.whse_code
                             and summ.location = rec_summary.location
                             and summ.item_id  = rec_summary.item_id
                             and summ.lot_id   = rec_summary.lot_id)
                      MINUS
                         (SELECT summ.co_code co_code,
                             summ.orgn_code orgn_code,
                             summ.whse_code whse_code,
                             summ.location  location,
                             summ.item_id   item_id,
                             summ.lot_id    lot_id,
                             summ.trx_date start_date
                          FROM opi_pmi_ids_temp summ,
                               opi_opm_gl_calendar_v glcldr
                          WHERE trunc(summ.trx_date) >= trunc(rec_summary.period_end_date)
                             and summ.co_code = glcldr.co_code
                             and glcldr.start_date = summ.trx_date
                             and glcldr.start_date <= SYSDATE
                             and summ.co_code = rec_summary.co_code
                             and summ.orgn_code = rec_summary.orgn_code
                             and summ.whse_code = rec_summary.whse_code
                             and summ.location = rec_summary.location
                             and summ.item_id  = rec_summary.item_id
                             and summ.lot_id   = rec_summary.lot_id))  p_marker_rows);

              INSERT into  opi_pmi_ids_temp ( co_code,
                             orgn_code,
                             whse_code,
                             location,
                             item_id,
                             lot_id,
                             trx_date,
                             wip_comp_qty,
                             wip_issue_qty,
                             po_del_qty,
                             total_rec_qty,
                             from_org_qty,
                             to_org_qty,
                             tot_cust_ship_qty,
                             inv_adj_qty,
                             tot_issues_qty,
                             beg_onh_qty,
                             end_onh_qty,
                             avg_onh_qty,
                             period_flag,
                             creation_date,
                             last_update_date,
                             operation_code)
                       (SELECT p_marker_rows.co_code,
                          p_marker_rows.orgn_code,
                          p_marker_rows.whse_code,
                          p_marker_rows.location,
                          p_marker_rows.item_id,
                          p_marker_rows.lot_id,
                          p_marker_rows.end_date,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          sysdate,
                          sysdate,
                          'INSERT'
                       FROM
                         ((SELECT summ.co_code co_code,
                             summ.orgn_code orgn_code,
                             summ.whse_code whse_code,
                             summ.location  location,
                             summ.item_id   item_id,
                             summ.lot_id    lot_id,
                             glcldr.end_date end_date
                          FROM opi_pmi_ids_temp summ,
                               opi_opm_gl_calendar_v glcldr
                          WHERE summ.period_flag = 1
                             and trunc(summ.trx_date) = trunc(rec_summary.period_end_date)
                             and summ.co_code = glcldr.co_code
                             and glcldr.start_date > summ.trx_date
                             and glcldr.start_date <= SYSDATE
                             and summ.co_code = rec_summary.co_code
                             and summ.orgn_code = rec_summary.orgn_code
                             and summ.whse_code = rec_summary.whse_code
                             and summ.location = rec_summary.location
                             and summ.item_id  = rec_summary.item_id
                             and summ.lot_id   = rec_summary.lot_id)
                      MINUS
                         (SELECT summ.co_code co_code,
                             summ.orgn_code orgn_code,
                             summ.whse_code whse_code,
                             summ.location  location,
                             summ.item_id   item_id,
                             summ.lot_id    lot_id,
                             summ.trx_date end_date
                          FROM opi_pmi_ids_temp summ,
                               opi_opm_gl_calendar_v glcldr
                          WHERE trunc(summ.trx_date) >= trunc(rec_summary.period_end_date)
                             and summ.co_code = glcldr.co_code
                             and glcldr.end_date = summ.trx_date
                             and glcldr.start_date <= SYSDATE
                             and summ.co_code = rec_summary.co_code
                             and summ.orgn_code = rec_summary.orgn_code
                             and summ.whse_code = rec_summary.whse_code
                             and summ.location = rec_summary.location
                             and summ.item_id  = rec_summary.item_id
                             and summ.lot_id   = rec_summary.lot_id))  p_marker_rows);
        END IF;
        CLOSE get_balance_row;
          l_prev_end_qty := nvl(ids_bal_rec.end_onh_qty,0);
          l_n_tr_qty     := nvl(rec_summary.tot_issues_qty,0)+nvl(rec_summary.total_rec_qty,0)+
                            nvl(rec_summary.inv_adj_qty,0);
             OPEN get_records_to_change;
             LOOP
               FETCH get_records_to_change into ids_temp_rec;
               EXIT WHEN get_records_to_change%NOTFOUND;
               l_beg_qty := ids_temp_rec.BEG_ONH_QTY;
               l_end_qty := ids_temp_rec.END_ONH_QTY;
               l_day_tr  := nvl(ids_temp_rec.END_ONH_QTY,0)  -  nvl(ids_temp_rec.BEG_ONH_QTY,0);
               l_n_tr_qty:= nvl(ids_temp_rec.tot_issues_qty,0)+nvl(ids_temp_rec.total_rec_qty,0)+
                            nvl(ids_temp_rec.inv_adj_qty,0);

               IF ids_bal_rec.trx_date   =  ids_temp_rec.trx_date THEN
                     l_n_beg_qty          :=  nvl(ids_bal_rec.beg_onh_qty,0);
                     l_n_end_qty          :=  nvl(ids_bal_rec.end_onh_qty,0) + l_n_tr_qty;
               ELSE
                    l_n_beg_qty           :=  l_prev_end_qty;
                    l_n_end_qty           :=  l_n_beg_qty + l_n_tr_qty;
               END IF;
                    l_prev_end_qty     := l_n_end_qty;
               update opi_pmi_ids_temp
               set
                     AVG_ONH_QTY        = (l_n_beg_qty+l_n_end_qty)/2,
                     BEG_ONH_QTY        = l_n_beg_qty,
                     END_ONH_QTY        = l_n_end_qty,
                     creation_date      = sysdate,
                     last_update_date   = sysdate
                WHERE  co_code         = ids_temp_rec.co_code
                  AND  whse_code       = ids_temp_rec.whse_code
                  AND  orgn_code       = ids_temp_rec.orgn_code
                  AND  Location        = ids_temp_rec.location
                  AND  item_id         = ids_temp_rec.item_id
                  AND  lot_id          = ids_temp_rec.lot_id
                  AND  trx_Date        = ids_temp_rec.trx_date;
             END LOOP;
             CLOSE  get_records_to_change;
        END LOOP;
        CLOSE summerize_temp_sum;
    edw_log.put_line ('at End of  Calculate day beginning and Ending Balances :');

        commit;
END  summarize_temp_summary;


PROCEDURE apply_to_summary_tab  IS
/*===================================================================================+
 |     apply_to_summary_tab;                                                         |
 |          This procedure moves data from work table to Actual summary table.       |
 +===================================================================================*/
l_update_row_cnt number;
l_insert_row_cnt number;
BEGIN
/*  Insert all new rows from work table into summary table using operation code = 'INSERT'*/

   insert into opi_pmi_inv_daily_stat_sum (CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,TRX_DATE
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
	,period_flag)
   (SELECT CO_CODE
	,ORGN_CODE
	,WHSE_CODE
	,LOCATION
	,AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,ITEM_ID
	,LAST_UPDATE_DATE
	,LOT_ID
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,TRX_DATE
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
	,period_flag
      FROM opi_pmi_ids_temp
      WHERE OPERATION_CODE = 'INSERT');

      l_insert_row_cnt := sql%rowcount;

      -- dbms_output.put_line('Rows inserted '||l_insert_row_cnt);
      commit;
/*  update summary table using rows marked with operation code = 'UPDATE' in work table */

      UPDATE opi_pmi_inv_daily_stat_sum sm
      SET 	(
	AVG_ONH_QTY
	,BEG_ONH_QTY
	,CREATION_DATE
	,END_ONH_QTY
	,FROM_ORG_QTY
	,INV_ADJ_QTY
	,LAST_UPDATE_DATE
	,PO_DEL_QTY
	,TOTAL_REC_QTY
	,TOT_CUST_SHIP_QTY
	,TOT_ISSUES_QTY
	,TO_ORG_QTY
	,WIP_COMP_QTY
	,WIP_ISSUE_QTY
	,period_flag)  =
      (SELECT
	 tmp.AVG_ONH_QTY
	,tmp.BEG_ONH_QTY
	,tmp.CREATION_DATE
	,tmp.END_ONH_QTY
	,tmp.FROM_ORG_QTY
	,tmp.INV_ADJ_QTY
	,tmp.LAST_UPDATE_DATE
	,tmp.PO_DEL_QTY
	,tmp.TOTAL_REC_QTY
	,tmp.TOT_CUST_SHIP_QTY
	,tmp.TOT_ISSUES_QTY
	,tmp.TO_ORG_QTY
	,tmp.WIP_COMP_QTY
	,tmp.WIP_ISSUE_QTY
	,tmp.period_flag
      FROM opi_pmi_ids_temp tmp
      WHERE sm.CO_CODE         = tmp.CO_CODE
	  AND sm.ORGN_CODE       = tmp.ORGN_CODE
	  AND sm.WHSE_CODE       = tmp.WHSE_CODE
	  AND sm.LOCATION        = tmp.LOCATION
	  AND sm.LOT_ID          = tmp.LOT_ID
	  AND sm.ITEM_ID         = tmp.ITEM_ID
	  AND sm.TRX_DATE        = tmp.TRX_DATE
        AND tmp.OPERATION_CODE = 'UPDATE')
    where exists (select 1
      FROM opi_pmi_ids_temp tmp
      WHERE sm.CO_CODE         = tmp.CO_CODE
   AND sm.ORGN_CODE       = tmp.ORGN_CODE
   AND sm.WHSE_CODE       = tmp.WHSE_CODE
   AND sm.LOCATION        = tmp.LOCATION
   AND sm.LOT_ID          = tmp.LOT_ID
   AND sm.ITEM_ID         = tmp.ITEM_ID
   AND sm.TRX_DATE        = tmp.TRX_DATE
   AND tmp.OPERATION_CODE = 'UPDATE');

      l_update_row_cnt := sql%rowcount;
      -- dbms_output.put_line('Rows updated '||l_insert_row_cnt);
commit;
END apply_to_summary_tab;

PROCEDURE cost_summary_tab IS
/*===================================================================================+
 |     Cost_summary_tab;                                                             |
 |          This procedure to cost the summary table rows.                           |
 +===================================================================================*/
BEGIN
/* following insert statement moves all open periods data into work table for costing */
        INSERT INTO OPI_PMI_INV_DAILY_STAT_TEMP (CO_CODE
                                               ,ORGN_CODE
                                               ,WHSE_CODE
                                               ,LOCATION
                                               ,ITEM_ID
                                               ,LOT_ID
                                               ,TRX_DATE
                                               ,AVG_ONH_QTY
                                               ,BEG_ONH_QTY
                                               ,CREATION_DATE
                                               ,END_ONH_QTY
                                               ,FROM_ORG_QTY
                                               ,INV_ADJ_QTY
                                               ,LAST_UPDATE_DATE
                                               ,PO_DEL_QTY
                                               ,TOTAL_REC_QTY
                                               ,TOT_CUST_SHIP_QTY
                                               ,TOT_ISSUES_QTY
                                               ,TO_ORG_QTY
                                               ,WIP_COMP_QTY
                                               ,WIP_ISSUE_QTY
                                               ,PERIOD_FLAG
                                               ,AVG_ONH_VAL_B
                                               ,BEG_ONH_VAL_B
                                               ,END_ONH_VAL_B
                                               ,FROM_ORG_VAL_B
                                               ,INV_ADJ_VAL_B
                                               ,PO_DEL_VAL_B
                                               ,TOTAL_REC_VAL_B
                                               ,TOT_CUST_SHIP_VAL_B
                                               ,TOT_ISSUES_VAL_B
                                               ,TO_ORG_VAL_B
                                               ,WIP_COMP_VAL_B
                                               ,WIP_ISSUE_VAL_B
                                               ,PERIOD_STATUS
                                               ,DATA_PUSHED_IND)

                                     (SELECT    sm.CO_CODE
                                               ,sm.ORGN_CODE
                                               ,sm.WHSE_CODE
                                               ,sm.LOCATION
                                               ,sm.ITEM_ID
                                               ,sm.LOT_ID
                                               ,sm.TRX_DATE
                                               ,sm.AVG_ONH_QTY
                                               ,sm.BEG_ONH_QTY
                                               ,sm.CREATION_DATE
                                               ,sm.END_ONH_QTY
                                               ,sm.FROM_ORG_QTY
                                               ,sm.INV_ADJ_QTY
                                               ,sysdate
                                               ,sm.PO_DEL_QTY
                                               ,sm.TOTAL_REC_QTY
                                               ,sm.TOT_CUST_SHIP_QTY
                                               ,sm.TOT_ISSUES_QTY
                                               ,sm.TO_ORG_QTY
                                               ,sm.WIP_COMP_QTY
                                               ,sm.WIP_ISSUE_QTY
                                               ,sm.PERIOD_FLAG
                                               ,sm.AVG_ONH_QTY
                                               ,sm.BEG_ONH_QTY
                                               ,sm.END_ONH_QTY
                                               ,sm.FROM_ORG_QTY
                                               ,sm.INV_ADJ_QTY
                                               ,sm.PO_DEL_QTY
                                               ,sm.TOTAL_REC_QTY
                                               ,sm.TOT_CUST_SHIP_QTY
                                               ,sm.TOT_ISSUES_QTY
                                               ,sm.TO_ORG_QTY
                                               ,sm.WIP_COMP_QTY
                                               ,sm.WIP_ISSUE_QTY
                                               ,sm.PERIOD_STATUS
                                               ,sm.DATA_PUSHED_IND
                                  FROM OPI_PMI_INV_DAILY_STAT_SUM sm
                                  WHERE NVL(PERIOD_STATUS,0) <> 2 );
          /*  Delete rows from summary table which are moved to work table for costing.
              later we can insert these rows from work table back to summary table since
              delete and insert of mass transactions are faster than update */
                   delete OPI_PMI_INV_DAILY_STAT_SUM
                   WHERE NVL(PERIOD_STATUS,0) <> 2 ;

/* Insert parameter to costing procedure in opi_pmi_cost_param_gtmp.
   Parameter are Organization code, warehouse code, item id, transaction date
   after insertion call costing procedure                                   */

      insert into opi_pmi_cost_param_gtmp (orgn_code,
                              whse_code,
                              item_id,
                              trans_date)
                (SELECT distinct orgn_code,
                                 whse_code,
                                 item_id,
                                 trx_date
                 FROM OPI_PMI_INV_DAILY_STAT_TEMP);
        opi_pmi_cost.get_cost;

/*  Move data from temporary summary table to actual summary table and calculate the values
using cost data inserted into opi_pmi_cost_result_gtmp table by costing procedure           */

        INSERT INTO OPI_PMI_INV_DAILY_STAT_SUM (CO_CODE
                                               ,ORGN_CODE
                                               ,WHSE_CODE
                                               ,LOCATION
                                               ,ITEM_ID
                                               ,LOT_ID
                                               ,TRX_DATE
                                               ,AVG_ONH_QTY
                                               ,BEG_ONH_QTY
                                               ,CREATION_DATE
                                               ,END_ONH_QTY
                                               ,FROM_ORG_QTY
                                               ,INV_ADJ_QTY
                                               ,LAST_UPDATE_DATE
                                               ,PO_DEL_QTY
                                               ,TOTAL_REC_QTY
                                               ,TOT_CUST_SHIP_QTY
                                               ,TOT_ISSUES_QTY
                                               ,TO_ORG_QTY
                                               ,WIP_COMP_QTY
                                               ,WIP_ISSUE_QTY
                                               ,PERIOD_FLAG
                                               ,AVG_ONH_VAL_B
                                               ,BEG_ONH_VAL_B
                                               ,END_ONH_VAL_B
                                               ,FROM_ORG_VAL_B
                                               ,INV_ADJ_VAL_B
                                               ,PO_DEL_VAL_B
                                               ,TOTAL_REC_VAL_B
                                               ,TOT_CUST_SHIP_VAL_B
                                               ,TOT_ISSUES_VAL_B
                                               ,TO_ORG_VAL_B
                                               ,WIP_COMP_VAL_B
                                               ,WIP_ISSUE_VAL_B
                                               ,PERIOD_STATUS
                                               ,DATA_PUSHED_IND)

                                     (SELECT    sm.CO_CODE
                                               ,sm.ORGN_CODE
                                               ,sm.WHSE_CODE
                                               ,sm.LOCATION
                                               ,sm.ITEM_ID
                                               ,sm.LOT_ID
                                               ,sm.TRX_DATE
                                               ,sm.AVG_ONH_QTY
                                               ,sm.BEG_ONH_QTY
                                               ,sm.CREATION_DATE
                                               ,sm.END_ONH_QTY
                                               ,sm.FROM_ORG_QTY
                                               ,sm.INV_ADJ_QTY
                                               ,sysdate
                                               ,sm.PO_DEL_QTY
                                               ,sm.TOTAL_REC_QTY
                                               ,sm.TOT_CUST_SHIP_QTY
                                               ,sm.TOT_ISSUES_QTY
                                               ,sm.TO_ORG_QTY
                                               ,sm.WIP_COMP_QTY
                                               ,sm.WIP_ISSUE_QTY
                                               ,sm.PERIOD_FLAG
                                               ,sm.AVG_ONH_QTY        *  rslt.total_cost
                                               ,sm.BEG_ONH_QTY        *  rslt.total_cost
                                               ,sm.END_ONH_QTY        *  rslt.total_cost
                                               ,sm.FROM_ORG_QTY       *  rslt.total_cost
                                               ,sm.INV_ADJ_QTY        *  rslt.total_cost
                                               ,sm.PO_DEL_QTY         *  rslt.total_cost
                                               ,sm.TOTAL_REC_QTY      *  rslt.total_cost
                                               ,sm.TOT_CUST_SHIP_QTY  *  rslt.total_cost
                                               ,sm.TOT_ISSUES_QTY     *  rslt.total_cost
                                               ,sm.TO_ORG_QTY         *  rslt.total_cost
                                               ,sm.WIP_COMP_QTY       *  rslt.total_cost
                                               ,sm.WIP_ISSUE_QTY      *  rslt.total_cost
                                               ,NVL(rslt.PERIOD_STATUS,0)
                                               ,NVL(sm.DATA_PUSHED_IND,0)
                                  FROM OPI_PMI_INV_DAILY_STAT_TEMP sm,
                                       opi_pmi_cost_result_gtmp rslt
                                  WHERE  rslt.orgn_code  = sm.orgn_code  AND
                                         rslt.whse_code  = sm.whse_code  AND
                                         rslt.item_id    = sm.item_id    AND
                                         rslt.trans_date = sm.trx_date);

END cost_summary_tab;



PROCEDURE  CLEANUP is
/*===================================================================================+
 |          This Procedure is to truncate all work tables used by the program.       |
 |          This call is issued at the beginning of the process once (since previous |
 |          run may be abnormally terminated) and again at the end.                  |
 |          In this procedure we fisrt get the table owner and then using table owner|
 |          truncate the work table.  This process is repeted for all work tables    |
 +===================================================================================*/

   l_stmt varchar2(2000);
   l_owner VARCHAR2(240);
BEGIN
     select TABLE_OWNER    INTO l_owner
     from user_synonyms
     where table_name= 'OPI_PMI_DAY_SUM_TEMP';
     IF l_owner IS NOT NULL THEN
       l_stmt := 'truncate table '||l_owner||'.opi_pmi_day_sum_temp  ';
       BEGIN
         execute immediate l_stmt;
       EXCEPTION WHEN  OTHERS THEN
         NULL;
       END;
     END IF;
     select TABLE_OWNER    INTO l_owner
     from user_synonyms
     where table_name= 'OPI_PMI_TRANS_INC';
     IF l_owner IS NOT NULL THEN
       l_stmt := 'truncate table '||l_owner||'.opi_pmi_trans_inc ';
       BEGIN
         execute immediate l_stmt;
       EXCEPTION WHEN  OTHERS THEN
         NULL;
       END;
     END IF;
     select TABLE_OWNER    INTO l_owner
     from user_synonyms
     where table_name= 'OPI_PMI_IDS_IDNT';
     IF l_owner IS NOT NULL THEN
       l_stmt := 'truncate table '||l_owner||'.opi_pmi_ids_idnt  ';
       BEGIN
         execute immediate l_stmt;
       EXCEPTION WHEN  OTHERS THEN
         NULL;
       END;
     END IF;
     select TABLE_OWNER    INTO l_owner
     from user_synonyms
     where table_name= 'OPI_PMI_IDS_TEMP';
     IF l_owner IS NOT NULL THEN
       l_stmt := 'truncate table '||l_owner||'.opi_pmi_ids_temp ';
       BEGIN
         execute immediate l_stmt;
       EXCEPTION WHEN  OTHERS THEN
         NULL;
       END;
     END IF;
     select TABLE_OWNER    INTO l_owner
     from user_synonyms
     where table_name= 'OPI_PMI_INV_DAILY_STAT_TEMP';
     IF l_owner IS NOT NULL THEN
       l_stmt := 'truncate table '||l_owner||'.OPI_PMI_INV_DAILY_STAT_TEMP';
       BEGIN
         execute immediate l_stmt;
       EXCEPTION WHEN  OTHERS THEN
         NULL;
       END;
     END IF;

END cleanup;

PROCEDURE start_summary(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2)  IS
/*===================================================================================*
 |       start_summary(errbuf OUT varchar2,retcode OUT VARCHAR2)                     |
 |          This procedure is a driver procedure for the Net Change summary          |
 |          process. It checks summary log table empty or not.  If Summary log Table |
 |          is empty then it errors out with summary table is  baseline is not set.  |
 *===================================================================================*/
  l_summary_start_date  DATE;
  l_last_run_Date date;
  CURSOR cur_last_run IS
    SELECT LAST_RUN_DATE
    FROM OPI_PMI_IDS_SUM_LOG
    ORDER BY LAST_RUN_DATE DESC;

BEGIN
  OPEN cur_last_run;
  FETCH cur_last_run INTO l_last_run_date;
  CLOSE cur_last_run;
  IF l_last_run_date is not null THEN

    -- Cleanup temporary tables

           cleanup;

    --   Check period Balance Records

        post_perd_bal_recs(l_last_run_date);

    -- Clock Summary Start Time
        l_summary_start_date  := sysdate;

    -- Get Net change from transaction tables.

          populate_net_change(l_last_run_date);

    --   Summarize net change records at day level and transform rows  from horizantal (row) structutre
    --   to vertical (column) structure

          populate_day_sum_temp;

    --  Identify summary records need to be changed

          identify_summary_recs_to_chng;

   --    summarize data in temp summary table

           summarize_temp_summary;

   --   apply changes to actual summay table

          apply_to_summary_tab;


   --  Cost Changed Rows

        cost_summary_tab;

    --   log summary completed
         UPDATE OPI_PMI_IDS_SUM_LOG
         SET LAST_RUN_DATE = l_summary_start_date;
        commit;
   --     cleanup temporary tables

             cleanup;
    ELSE
      edw_log.put_line (FND_MESSAGE.get_string('OPI','OPI_PMI_SUMMARY_ERROR'));
      retcode:= '2';
    END IF;
END start_summary;

END  OPI_PMI_IDS_SUMMARY;

/
