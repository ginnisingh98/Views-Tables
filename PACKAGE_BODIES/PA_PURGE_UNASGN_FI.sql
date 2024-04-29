--------------------------------------------------------
--  DDL for Package Body PA_PURGE_UNASGN_FI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_UNASGN_FI" AS
/* $Header: PAXUSGNB.pls 120.1.12000000.2 2007/03/06 14:02:34 rthumma ship $ */

-- Start of comments
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Procedure for Purging records related to unassigned time forecast_items for resources
-- Parameters       :
--                     p_archive_flag    -> This flag will indicate if the
--                                          records need to be archived
--                                          before they are purged.
--                     p_txn_to_date     -> Date through which the transactions
--                                          need to be purged. This value will
--                                          be NULL if the purge batch is for
--                                          active projects.
-- End of comments

Procedure  PA_FORECASTITEM (
			    errbuf                       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode                      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			    p_txn_to_date                in  VARCHAR2,
                            p_archive_flag               in  varchar2) IS


    l_forecast_item_id_tab               PA_PLSQL_DATATYPES.IdTabTyp;
    l_project_id_tab                     PA_PLSQL_DATATYPES.IdTabTyp; --Added for bug 5870223
    I                                    PLS_INTEGER;
    l_last_fetch                         VARCHAR2(1):='N';
    l_this_fetch                         NUMBER:=0;
    l_totally_fetched                    NUMBER:=0;
    p_commit_size                        NUMBER:=1000;
    l_purge_batch_id                     NUMBER;
    x_err_stack                          VARCHAR2(5000);
    x_err_stage                          VARCHAR2(5000);
    x_err_code                           NUMBER;

/*The below cursor will select  unassigned time forecast_items whose item date <=purge till date. */

     CURSOR Cur_forecast_items IS
     SELECT forecast_item_id ,project_id --Added for bug 5870223
     FROM pa_forecast_items
     WHERE forecast_item_type='U'
     AND item_date <= fnd_date.canonical_to_date(p_txn_to_date)  /* Bug#2510609 */
     ORDER BY project_id; -- Added for bug 5870223

Begin
   arpr_log('p_txn_to_date: '||p_txn_to_date);
   arpr_log('p_archive_flag: '||p_archive_flag);
  x_err_stack := x_err_stack || ' ->Before call to purge unassigned forecast items ';

   arpr_log(' About to purge unassigned time forecast items ') ;
   x_err_stage := 'About to start purge  unassigned time forecast items' ;

   select pa_purge_batches_s.nextval into l_purge_batch_id from dual;

   arpr_log(' l_purge_batch_id: '||l_purge_batch_id);

    OPEN CUR_forecast_items;
    LOOP

        /*Clear PL/SQL table before start */
        l_forecast_item_id_tab.DELETE;
	l_project_id_tab.DELETE; --Added for bug 5870223

        FETCH cur_forecast_items BULK COLLECT
        INTO  l_forecast_item_id_tab , l_project_id_tab LIMIT p_commit_size;  --Added for bug 5870223

        /*  To check the rows fetched in this fetch */

        l_this_fetch :=  cur_forecast_items%ROWCOUNT - l_totally_fetched;
        l_totally_fetched :=  cur_forecast_items%ROWCOUNT;

	arpr_log(' l_this_fetch: '||l_this_fetch);
	arpr_log(' l_totally_fetched: '||l_totally_fetched);

        /*
         *  Check if this fetch has 0 rows returned (ie last fetch was even p_commit_size)
         *  This could happen in 2 cases
         *      1) this fetch is the very first fetch with 0 rows returned
         *   OR 2) the last fetch returned an even p_commit_size  rows
         *  If either then EXIT without any processing
         */
          IF  l_this_fetch = 0 then
	    arpr_log(' Exiting from the program as l_this_fetch = 0');
              EXIT;
          END IF;

        /*
         *  Check if this fetch is the last fetch
         *  If so then set the flag l_last_fetch so as to exit after processing
         */
          IF  l_this_fetch < p_commit_size  then
              l_last_fetch := 'Y';
          ELSE
              l_last_fetch := 'N';
          END IF;

          /* arpr_log(' Before call to PA_PURGE_UNASGN_FI.Delete_fi'); */

           PA_PURGE_UNASGN_FI.Delete_fi(p_forecast_item_id_tab =>l_forecast_item_id_tab,
                                        p_project_id_tab  =>  l_project_id_tab, --Added for bug 5870223
					p_archive_flag         =>p_archive_flag,
					p_purge_batch_id       =>l_purge_batch_id,
                                        x_err_stack            =>x_err_stack,
                                        x_err_stage            =>x_err_stage,
                                        x_err_code             =>x_err_code);

     /*  Check if this loop is the last set of p_commit_size  If so then EXIT; */

          IF l_last_fetch='Y' THEN
               EXIT;
          END IF;

   END LOOP;


   CLOSE cur_forecast_items;

/* Bug#2510609 */
   arpr_out( p_txn_to_date,
             p_archive_flag,
             l_purge_batch_id);

EXCEPTION
/* Bug#2510609 */
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error THEN
        errbuf := PA_PROJECT_UTILS2.g_sqlerrm ;
        retcode := -1 ;
  WHEN OTHERS THEN
    errbuf := SQLERRM ;
    retcode := -1 ;
    arpr_log('errbuf in exception: '||errbuf);

/* Bug#2510609
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    arpr_log('Error Procedure Name  := PA_PURGE_UNASGN_FI.PA_FORECASTITEMS' );
    arpr_log('Error stage is '||x_err_stage );
    arpr_log('Error stack is '||x_err_stack );
    arpr_log(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;
*/

End PA_FORECASTITEM;

-- Start of comments
-- API name         : DELETE_FI
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Archive/purge records for pa_forecast_items, pa_forecast_items_details and pa_fi_amount_details table.
-- Parameters       :
--                                              records need to be archived
--                     p_forecast_item_id_id_tab   -> forecast items tab
-- End of comments

Procedure Delete_FI (p_forecast_item_id_tab           in PA_PLSQL_DATATYPES.IdTabTyp,
                     p_project_id_tab                      in PA_PLSQL_DATATYPES.IdTabTyp, --Added for bug 5870223
		     p_archive_flag                   in VARCHAR2,
		     p_purge_batch_id                 in NUMBER,
                     x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_err_code                       in OUT NOCOPY NUMBER ) IS --File.Sql.39 bug 4440895

    l_forecast_item_id                   Pa_forecast_items.forecast_item_id%TYPE;
    I                                    PLS_INTEGER;
    l_nos_fi_inserted                    NUMBER ;
    l_nos_fid_inserted                   NUMBER ;
    l_nos_fi_deleted                     NUMBER ;
    l_nos_fid_deleted                    NUMBER ;
    l_nos_fi_amt_inserted                NUMBER;
    l_nos_fi_amt_deleted                 NUMBER;
    l_purge_release                      VARCHAR2(50) := '11.5';
    l_project_id                         pa_projects_all.project_id%TYPE;

    --Added for bug 5870223
     l_max_count                            NUMBER;
     l_first_index                          NUMBER;
     l_last_index                           NUMBER;
     l_call_commit                         VARCHAR2(1) := 'N';

     l_forecast_item_id_tab                 PA_PLSQL_DATATYPES.IdTabTyp;
     J                                      PLS_INTEGER := 0;

     --End for bug 5870223


Begin

/*  x_err_stack := x_err_stack || ' ->Before call to purge unassigned time Forecast Item records ';  */

/*Initialize the no of record variables for each call */

  /*  arpr_log(' Inside Procedure to purge unassigned time Forecast Items,Forecast Item Details and fi_amount details ') ;  */
  x_err_stage := 'Start  purging forecast items for id ';

   l_nos_fi_inserted  :=0;
   l_nos_fid_inserted :=0;
   l_nos_fi_deleted   :=0;
   l_nos_fid_deleted  :=0;
   l_nos_fi_amt_deleted :=0;
   l_nos_fi_amt_inserted :=0;

   --Added for bug 5870223
    l_max_count := p_forecast_item_id_tab.count;
    l_first_index :=  p_forecast_item_id_tab.FIRST;
    l_last_index :=  p_forecast_item_id_tab.LAST;
    J := l_first_index;
  --End for bug 5870223

   FOR I in p_forecast_item_id_tab.FIRST .. p_forecast_item_id_tab.LAST LOOP
     l_forecast_item_id :=p_forecast_item_id_tab(I);
     l_forecast_item_id_tab(J) := p_forecast_item_id_tab(I); --Added for bug 5870223

      --Added for bug 5870223
      IF I = l_last_index OR l_max_count = 1 THEN
         l_call_commit := 'Y';
      ELSE
         IF p_project_id_tab(I) <> p_project_id_tab(I + 1) THEN
                 l_call_commit := 'Y';
         END IF;
      END IF;
      --End for bug 5870223

         /*Commented for bug 5870223
       SELECT project_id into l_project_id
       from pa_forecast_items
       where forecast_item_id=l_forecast_item_id;*/

     l_project_id := p_project_id_tab(I); --Added for bug 5870223

     /* If archive flag is YES, archiving of data needs to be done. Insert data into correspodning AR tables */

       IF l_call_commit = 'Y' THEN -- Bug 5870223

	IF p_archive_flag='Y' THEN

       /*  arpr_log('Inserting Records into pa_forecast_items_AR table  ') ;  */
       x_err_stage := 'Inserting Records into pa_forecast_items_AR table for forecast item '||to_char(l_forecast_item_id) ;

       FORALL K IN l_forecast_item_id_tab.FIRST..l_forecast_item_id_tab.LAST        -- Bug 5870223
	    INSERT INTO pa_frcst_items_AR
              (PURGE_BATCH_ID,
               PURGE_RELEASE,
               PURGE_PROJECT_ID,
               FORECAST_ITEM_ID,
               FORECAST_ITEM_TYPE,
               PROJECT_ORG_ID,
               EXPENDITURE_ORG_ID,
               EXPENDITURE_ORGANIZATION_ID,
               PROJECT_ORGANIZATION_ID,
               PROJECT_ID,
               PROJECT_TYPE_CLASS,
               PERSON_ID,
               RESOURCE_ID,
               BORROWED_FLAG,
               ASSIGNMENT_ID,
               ITEM_DATE,
               ITEM_UOM,
               ITEM_QUANTITY,
               PVDR_PERIOD_SET_NAME,
               PVDR_PA_PERIOD_NAME,
               PVDR_GL_PERIOD_NAME,
               RCVR_PERIOD_SET_NAME,
               RCVR_PA_PERIOD_NAME,
               RCVR_GL_PERIOD_NAME,
               GLOBAL_EXP_PERIOD_END_DATE,
               EXPENDITURE_TYPE,
               EXPENDITURE_TYPE_CLASS,
               COST_REJECTION_CODE,
               REV_REJECTION_CODE,
               TP_REJECTION_CODE,
               BURDEN_REJECTION_CODE,
               OTHER_REJECTION_CODE,
               DELETE_FLAG,
               ERROR_FLAG,
               PROVISIONAL_FLAG,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN,
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE,
               ASGMT_SYS_STATUS_CODE,
               CAPACITY_QUANTITY,
               OVERCOMMITMENT_QUANTITY,
               AVAILABILITY_QUANTITY,
               OVERCOMMITMENT_FLAG,
               AVAILABILITY_FLAG,
               TP_AMOUNT_TYPE,
               FORECAST_AMT_CALC_FLAG,
               COST_TXN_CURRENCY_CODE,
               TXN_RAW_COST,
               TXN_BURDENED_COST,
               REVENUE_TXN_CURRENCY_CODE,
               TXN_REVENUE,
               TP_TXN_CURRENCY_CODE,
               TXN_TRANSFER_PRICE,
               PROJECT_CURRENCY_CODE,
               PROJECT_RAW_COST,
               PROJECT_BURDENED_COST,
               PROJECT_REVENUE,
               PROJECT_TRANSFER_PRICE,
               PROJFUNC_CURRENCY_CODE,
               PROJFUNC_RAW_COST,
               PROJFUNC_BURDENED_COST,
               PROJFUNC_REVENUE,
               PROJFUNC_TRANSFER_PRICE,
               EXPFUNC_CURRENCY_CODE,
               EXPFUNC_RAW_COST,
               EXPFUNC_BURDENED_COST,
               EXPFUNC_TRANSFER_PRICE,
               OVERPROVISIONAL_QTY,
               OVER_PROV_CONF_QTY,
               CONFIRMED_QTY,
               PROVISIONAL_QTY,
               JOB_ID)

          SELECT  p_purge_batch_id,
                  l_purge_release,
                  project_id,
                  Forecast_Item_Id,
                  Forecast_Item_Type,
                  Project_Org_Id,
                  Expenditure_Org_Id,
                  Expenditure_Organization_Id,
                  Project_Organization_Id,
                  Project_Id,
                  Project_Type_Class,
                  Person_Id,
                  Resource_Id,
                  Borrowed_Flag,
                  Assignment_Id,
                  Item_Date,
                  Item_Uom,
                  Item_Quantity,
                  Pvdr_Period_Set_Name,
                  Pvdr_Pa_Period_Name,
                  Pvdr_Gl_Period_Name,
                  Rcvr_Period_Set_Name,
                  Rcvr_Pa_Period_Name,
                  Rcvr_Gl_Period_Name,
                  Global_Exp_Period_End_Date,
                  Expenditure_Type,
                  Expenditure_Type_Class,
                  Cost_Rejection_Code,
                  Rev_Rejection_Code,
                  Tp_Rejection_Code,
                  Burden_Rejection_Code,
                  Other_Rejection_Code,
                  Delete_Flag,
                  Error_Flag,
                  Provisional_Flag,
                  Creation_Date,
                  Created_By,
                  Last_Update_Date,
                  Last_Updated_By,
                  Last_Update_Login,
                  Request_Id,
                  Program_Application_Id,
                  Program_Id,
                  Program_Update_Date,
                  Asgmt_Sys_Status_Code,
                  Capacity_Quantity,
                  Overcommitment_Quantity,
                  Availability_Quantity,
                  Overcommitment_Flag,
                  Availability_Flag,
                  Tp_Amount_Type,
                  Forecast_Amt_Calc_Flag,
                  Cost_Txn_Currency_Code,
                  Txn_Raw_Cost,
                  Txn_Burdened_Cost,
                  Revenue_Txn_Currency_Code,
                  Txn_Revenue,
                  Tp_Txn_Currency_Code,
                  Txn_Transfer_Price,
                  Project_Currency_Code,
                  Project_Raw_Cost,
                  Project_Burdened_Cost,
                  Project_Revenue,
                  Project_Transfer_Price,
                  Projfunc_Currency_Code,
                  projfunc_Raw_Cost,
                  Projfunc_Burdened_Cost,
                  Projfunc_Revenue,
                  Projfunc_Transfer_Price,
                  Expfunc_Currency_Code,
                  Expfunc_Raw_Cost,
                  Expfunc_Burdened_Cost,
                  Expfunc_Transfer_Price,
                  Overprovisional_Qty,
                  Over_Prov_Conf_Qty,
                  Confirmed_Qty,
                  Provisional_Qty,
                  Job_Id
              FROM pa_forecast_items
              WHERE forecast_item_id = l_forecast_item_id_tab(K);--l_forecast_item_id; 5870223

 /*Increase the value of l_nos_fi_inserted to indicate number of records inserted in forecast_items table.
  The value will increase for each loop(forecast item id*/
            l_nos_fi_inserted :=  SQL%ROWCOUNT;  /* Bug#2510609 */

       /*  arpr_log('Inserting Records into pa_forecast_item_DETAILS_AR table  ') ;  */
       x_err_stage := 'Inserting Records into forecast_item_detail table for forecast item '||to_char(l_forecast_item_id) ;

        FORALL K IN l_forecast_item_id_tab.FIRST..l_forecast_item_id_tab.LAST        -- Bug 5870223
	INSERT INTO PA_FRCST_ITEM_DTLS_AR
                  (PURGE_BATCH_ID,
                   PURGE_RELEASE,
                   PURGE_PROJECT_ID,
                   FORECAST_ITEM_ID,
                   AMOUNT_TYPE_ID,
                   LINE_NUM,
                   RESOURCE_TYPE_CODE,
                   PERSON_BILLABLE_FLAG,
                   ITEM_DATE,
                   ITEM_UOM,
                   ITEM_QUANTITY,
                   EXPENDITURE_ORG_ID,
                   PROJECT_ORG_ID,
                   PVDR_ACCT_CURR_CODE,
                   PVDR_ACCT_AMOUNT,
                   RCVR_ACCT_CURR_CODE,
                   RCVR_ACCT_AMOUNT,
                   PROJ_CURRENCY_CODE,
                   PROJ_AMOUNT,
                   DENOM_CURRENCY_CODE,
                   DENOM_AMOUNT,
                   TP_AMOUNT_TYPE,
                   BILLABLE_FLAG,
                   FORECAST_SUMMARIZED_CODE,
                   UTIL_SUMMARIZED_CODE,
                   WORK_TYPE_ID,
                   RESOURCE_UTIL_CATEGORY_ID,
                   ORG_UTIL_CATEGORY_ID,
                   RESOURCE_UTIL_WEIGHTED,
                   ORG_UTIL_WEIGHTED,
                   PROVISIONAL_FLAG,
                   REVERSED_FLAG,
                   NET_ZERO_FLAG,
                   REDUCE_CAPACITY_FLAG,
                   LINE_NUM_REVERSED,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_LOGIN,
                   REQUEST_ID,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_ID,
                   PROGRAM_UPDATE_DATE,
                   CAPACITY_QUANTITY,
                   OVERCOMMITMENT_QTY,
                   OVERPROVISIONAL_QTY,
                   OVER_PROV_CONF_QTY,
                   CONFIRMED_QTY,
                   PROVISIONAL_QTY,
                   JOB_ID,
                   PROJECT_ID,
                   RESOURCE_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   PJI_SUMMARIZED_FLAG)

           SELECT  p_purge_batch_id,
                   l_Purge_Release,
                   l_Project_Id,
                   Forecast_Item_Id,
                   Amount_Type_Id,
                   Line_Num,
                   Resource_Type_Code,
                   Person_Billable_Flag,
                   Item_Date,
                   Item_Uom,
                   Item_Quantity,
                   Expenditure_Org_Id,
                   Project_Org_Id,
                   Pvdr_Acct_Curr_Code,
                   Pvdr_Acct_Amount,
                   Rcvr_Acct_Curr_Code,
                   Rcvr_Acct_Amount,
                   Proj_Currency_Code,
                   Proj_Amount,
                   Denom_Currency_Code,
                   Denom_Amount,
                   Tp_Amount_Type,
                   Billable_Flag,
                   Forecast_Summarized_Code,
                   Util_Summarized_Code,
                   Work_Type_Id,
                   Resource_Util_Category_Id,
                   Org_Util_Category_Id,
                   Resource_Util_Weighted,
                   Org_Util_Weighted,
                   Provisional_Flag,
                   Reversed_Flag,
                   Net_Zero_Flag,
                   Reduce_Capacity_Flag,
                   Line_Num_Reversed,
                   Creation_Date,
                   Created_By,
                   Last_Update_Date,
                   Last_Updated_By,
                   Last_Update_Login,
                   Request_Id,
                   Program_Application_Id,
                   Program_Id,
                   Program_Update_Date,
                   CAPACITY_QUANTITY,
                   OVERCOMMITMENT_QTY,
                   OVERPROVISIONAL_QTY,
                   OVER_PROV_CONF_QTY,
                   CONFIRMED_QTY,
                   PROVISIONAL_QTY,
                   JOB_ID,
                   PROJECT_ID,
                   RESOURCE_ID,
                   EXPENDITURE_ORGANIZATION_ID,
                   PJI_SUMMARIZED_FLAG
           FROM PA_forecast_item_details
           WHERE forecast_item_id=l_forecast_item_id_tab(K);--l_forecast_item_id; bug 5870223

  /*Increase the value of l_nos_fis_inserted to indicate number of records inserted in forecast_items detail table.
  The value will increase for each loop(forecast item id*/
          l_nos_fid_inserted :=  SQL%ROWCOUNT;  /* Bug#2510609 */

            FORALL K IN l_forecast_item_id_tab.FIRST..l_forecast_item_id_tab.LAST        -- Bug 5870223
	    INSERT INTO PA_FI_AMOUNT_DETAILS_AR
                       (PURGE_BATCH_ID,
			PURGE_RELEASE,
			PURGE_PROJECT_ID,
			FORECAST_ITEM_ID,
			LINE_NUM,
			ITEM_DATE,
			ITEM_UOM,
			ITEM_QUANTITY,
			REVERSED_FLAG,
			NET_ZERO_FLAG,
			LINE_NUM_REVERSED,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			REQUEST_ID,
			PROGRAM_APPLICATION_ID,
			PROGRAM_ID,
			PROGRAM_UPDATE_DATE,
			COST_TXN_CURRENCY_CODE,
			TXN_RAW_COST,
			TXN_BURDENED_COST,
			REVENUE_TXN_CURRENCY_CODE,
			TXN_REVENUE,
			TP_TXN_CURRENCY_CODE,
			TXN_TRANSFER_PRICE,
			PROJECT_CURRENCY_CODE,
			PROJECT_COST_RATE_DATE,
			PROJECT_COST_RATE_TYPE,
			PROJECT_COST_EXCHANGE_RATE,
			PROJECT_RAW_COST,
			PROJECT_BURDENED_COST,
			PROJECT_REVENUE_RATE_DATE,
			PROJECT_REVENUE_RATE_TYPE,
			PROJECT_REVENUE_EXCHANGE_RATE,
			PROJECT_REVENUE,
			PROJECT_TP_RATE_DATE,
			PROJECT_TP_RATE_TYPE,
			PROJECT_TP_EXCHANGE_RATE,
			PROJECT_TRANSFER_PRICE,
			PROJFUNC_CURRENCY_CODE,
			PROJFUNC_COST_RATE_DATE,
			PROJFUNC_COST_RATE_TYPE,
			PROJFUNC_COST_EXCHANGE_RATE,
			PROJFUNC_RAW_COST,
			PROJFUNC_BURDENED_COST,
			PROJFUNC_REVENUE,
			PROJFUNC_TRANSFER_PRICE,
			--PROJFUNC_RATE_DATE,
			--PROJFUNC_RATE_TYPE,
			--PROJFUNC_EXCHANGE_RATE,
			EXPFUNC_CURRENCY_CODE,
			EXPFUNC_COST_RATE_DATE,
			EXPFUNC_COST_RATE_TYPE,
			EXPFUNC_COST_EXCHANGE_RATE,
			EXPFUNC_RAW_COST,
			EXPFUNC_BURDENED_COST,
			EXPFUNC_TP_RATE_DATE,
			EXPFUNC_TP_RATE_TYPE,
			EXPFUNC_TP_EXCHANGE_RATE,
			EXPFUNC_TRANSFER_PRICE)

                SELECT  p_purge_batch_id,
                        l_purge_release,
                        l_project_id,
                        Forecast_Item_Id,
			Line_Num,
			Item_Date,
			Item_Uom,
			Item_Quantity,
			Reversed_Flag,
			Net_Zero_Flag,
			Line_Num_Reversed,
			Creation_Date,
			Created_By,
			Last_Update_Date,
			Last_Updated_By,
			Last_Update_Login,
			Request_Id,
			Program_Application_Id,
			Program_Id,
			Program_Update_Date,
			Cost_Txn_Currency_Code,
			Txn_Raw_Cost,
			Txn_Burdened_Cost,
			Revenue_Txn_Currency_Code,
			Txn_Revenue,
			Tp_Txn_Currency_Code,
			Txn_Transfer_Price,
			Project_Currency_Code,
			Project_Cost_Rate_Date,
			Project_Cost_Rate_Type,
			Project_Cost_Exchange_Rate,
			Project_Raw_Cost,
			Project_Burdened_Cost,
			Project_Revenue_Rate_Date,
			Project_Revenue_Rate_Type,
			Project_Revenue_Exchange_Rate,
			Project_Revenue,
			Project_Tp_Rate_Date,
			Project_Tp_Rate_Type,
			Project_Tp_Exchange_Rate,
			Project_Transfer_Price,
			Projfunc_Currency_Code,
			Projfunc_Cost_Rate_Date,
			Projfunc_Cost_Rate_Type,
			Projfunc_Cost_Exchange_Rate,
			Projfunc_Raw_Cost,
			Projfunc_Burdened_Cost,
			Projfunc_Revenue,
			Projfunc_Transfer_Price,
			--Projfunc_Rate_Date,
			--Projfunc_Rate_Type,
			--Projfunc_Exchange_Rate,
			Expfunc_Currency_Code,
			Expfunc_Cost_Rate_Date,
			Expfunc_Cost_Rate_Type,
			Expfunc_Cost_Exchange_Rate,
			Expfunc_Raw_Cost,
			Expfunc_Burdened_Cost,
			Expfunc_Tp_Rate_Date,
			Expfunc_Tp_Rate_Type,
			Expfunc_Tp_Exchange_Rate,
			Expfunc_Transfer_Price
           FROM PA_FI_AMOUNT_DETAILS Where forecast_item_id=l_forecast_item_id_tab(K); --l_forecast_item_id; Bug 5870223

       /*Increase the value of l_nos_fi_amt_inserted to reflct the number of records inserted */

                 l_nos_fi_amt_inserted := SQL%ROWCOUNT;                /* Bug#2510609 */

     END IF;

   /*To keep the count of no os records deleted from pa_forecast_items and pa_forecast_item_details, manipulate the
  count of l_nos_of fi_deleted and l_nos_fis_deleted. */

       /*  arpr_log('Deleting Records from  pa_fi_amount_details table  ') ;  */
       x_err_stage := 'Deleting Records from  pa_fi_amount_details table for id '||to_char(l_forecast_item_id) ;

            FORALL K IN l_forecast_item_id_tab.FIRST..l_forecast_item_id_tab.LAST -- Bug 5870223

	    DELETE PA_FI_AMOUNT_DETAILS
            WHERE forecast_item_id = l_forecast_item_id_tab(K);--l_forecast_item_id;  Bug 5870223

           l_nos_fi_amt_deleted := SQL%ROWCOUNT;               /* Bug#2510609 */

       /*  arpr_log('Deleting Records from  pa_forecast_item_details table  ') ;  */
       x_err_stage := 'Deleting Records from  pa_forecast_item_details table for id '||to_char(l_forecast_item_id) ;

            FORALL K IN l_forecast_item_id_tab.FIRST..l_forecast_item_id_tab.LAST -- Bug 5870223

	    DELETE PA_FORECAST_ITEM_DETAILS
            WHERE forecast_item_id =l_forecast_item_id_tab(K);--l_forecast_item_id;  Bug 5870223

            l_nos_fid_deleted :=SQL%ROWCOUNT;   /* Bug#2510609 */

            /*  arpr_log('Deleting Records from  pa_forecast_items table  ') ;  */
            x_err_stage := 'Deleting Records from  pa_forecast_items table for id '||to_char(l_forecast_item_id) ;

            FORALL K IN l_forecast_item_id_tab.FIRST..l_forecast_item_id_tab.LAST -- Bug 5870223

	    DELETE PA_FORECAST_ITEMS
            WHERE forecast_item_id=l_forecast_item_id_tab(K);--l_forecast_item_id;  Bug 5870223

           l_nos_fi_deleted :=SQL%ROWCOUNT;   /* Bug#2510609 */

--  END LOOP;   /* Bug#2510609 */

/*After "deleting" or "deleting and inserting" a set of records the transaction is commited. This also creates a record in the Pa_Purge_Project_details, which will show the no. of records that are purged from each table.
 The procedure is called once for pa_forecast_items and once for pa_forecast_item_details */


       pa_purge.CommitProcess (p_purge_batch_id,
	                       l_project_id,
	                       'PA_FORECAST_ITEMS',
	                       l_nos_fi_inserted,
	                       l_nos_fi_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;
       	pa_purge.CommitProcess(p_purge_batch_id,
	                       l_project_id,
	                       'PA_FORECAST_ITEM_DETAILS',
	                       l_nos_fid_inserted,
	                       l_nos_fid_deleted,
	                       x_err_code,
	                       x_err_stack,
	                       x_err_stage
	                       ) ;

         pa_purge.CommitProcess(p_purge_batch_id,
                                l_project_id,
                                'PA_FI_AMOUNT_DETAILS',
                                l_nos_fi_amt_inserted,
                                l_nos_fi_amt_deleted,
                                x_err_code,
                                x_err_stack,
                                x_err_stage
                               ) ;

	 l_call_commit := 'N';

         l_forecast_item_id_tab.DELETE;
         J := 0;

    END IF; --end for l_call_commit = 'Y'

    J:= J + 1;  --Added for bug 5870223

END LOOP;  /* Bug#2510609  */


EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    arpr_log('Error Procedure Name  := PA_PURGE_UNASGN_FI.DELETE_FI' );
    arpr_log('Error stage is '||x_err_stage );
    arpr_log('Error stack is '||x_err_stack );
    arpr_log(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

End  delete_fi;


PROCEDURE arpr_log (p_message      IN VARCHAR2) IS

begin

  --  IF ( G_DEBUG_MODE = 'Y') THEN

 	     FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(sysdate,'HH:MI:SS:   ')|| p_message);

  --  END IF;

EXCEPTION

   WHEN OTHERS THEN
      raise;

END arpr_log;


PROCEDURE arpr_out ( p_txn_to_date                    in VARCHAR2,
                     p_archive_flag                   in varchar2,
                     p_purge_batch_id                 in number) IS

  cursor c_arpr_details is
    select table_name,
	   sum(nvl(num_recs_archived,0)) num_recs_archived,
	   sum(nvl(num_recs_purged,0)) num_recs_purged
      from PA_PURGE_PRJ_DETAILS
     where purge_batch_id = p_purge_batch_id
     group by table_name
    order by table_name;

  l_sob_id   NUMBER;
  l_sob_name VARCHAR2(30);
  l_tblock   VARCHAR2(132);
  l_tmp_str  VARCHAR2(132);
  l_tmp_str2  VARCHAR2(132);
  l_tmp_str3  VARCHAR2(132);

begin

    SELECT IMP.Set_Of_Books_ID
    INTO   l_sob_id
    FROM   PA_Implementations IMP;

    SELECT SUBSTRB(GL.Name, 1, 30)
    INTO   l_sob_name
    FROM   GL_Sets_Of_Books GL
    WHERE  GL.Set_Of_Books_ID = l_sob_id;

    SELECT meaning
    INTO   l_tmp_str
    FROM   PA_LOOKUPS
    WHERE  lookup_type = 'UNASSIGNED_PURGE_REPORT'
    AND    lookup_code = 'PA_R_UNASS_TIME_01';

    SELECT  rpad(l_sob_name,30,' ')||lpad(l_tmp_str,75,' ')||sysdate
    INTO    l_tblock
    FROM    DUAL;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_tblock);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 2);

    SELECT meaning
    INTO   l_tmp_str
    FROM   PA_LOOKUPS
    WHERE  lookup_type = 'UNASSIGNED_PURGE_REPORT'
    AND    lookup_code = 'PA_R_UNASS_TIME_02';

    SELECT lpad(l_tmp_str,66+length(l_tmp_str)/2,' ')
    INTO l_tblock
    FROM DUAL;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_tblock);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 3);

    SELECT lpad(meaning,32,' ')
    INTO   l_tmp_str
    FROM   PA_LOOKUPS
    WHERE  lookup_type = 'UNASSIGNED_PURGE_REPORT'
    AND    lookup_code = 'PA_R_UNASS_TIME_03';

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_tmp_str||p_archive_flag);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);

    SELECT lpad(meaning,32,' ')
    INTO   l_tmp_str
    FROM   PA_LOOKUPS
    WHERE  lookup_type = 'UNASSIGNED_PURGE_REPORT'
    AND    lookup_code = 'PA_R_UNASS_TIME_04';

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_tmp_str||p_txn_to_date);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 3);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------------------------------------------------------------------------------------------------');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);

    SELECT '  '||rpad(meaning,20,' ')
    INTO   l_tmp_str
    FROM   PA_LOOKUPS
    WHERE  lookup_type = 'UNASSIGNED_PURGE_REPORT'
    AND    lookup_code = 'PA_R_UNASS_TIME_05';

    SELECT rpad(meaning,52,' ')
    INTO   l_tmp_str2
    FROM   PA_LOOKUPS
    WHERE  lookup_type = 'UNASSIGNED_PURGE_REPORT'
    AND    lookup_code = 'PA_R_UNASS_TIME_06';

    SELECT rpad(meaning,48,' ')
    INTO   l_tmp_str3
    FROM   PA_LOOKUPS
    WHERE  lookup_type = 'UNASSIGNED_PURGE_REPORT'
    AND    lookup_code = 'PA_R_UNASS_TIME_07';

    SELECT l_tmp_str||'          '||l_tmp_str2||l_tmp_str3
    INTO   l_tblock
    FROM   DUAL;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_tblock);

    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------------------------------------------------------------------------------------------------');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
    For i in c_arpr_details LOOP

      SELECT '  '||rpad(i.table_name,30,' ')||lpad(i.num_recs_archived,26,' ')||'                          '||lpad(i.num_recs_purged,24,' ')
      INTO
      l_tmp_str
      FROM DUAL;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_tmp_str);

      FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);

    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------------------------------------------------------------------------------------------------');

EXCEPTION

   WHEN OTHERS THEN
      raise;

END arpr_out;


END ;

/
