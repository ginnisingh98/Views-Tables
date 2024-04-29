--------------------------------------------------------
--  DDL for Package Body PA_WORK_TYPE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WORK_TYPE_UPGRADE" AS
/* $Header: PAWKUPGB.pls 120.9.12010000.4 2010/01/29 12:25:11 svivaram ship $ */

/* Procedure: Upgrade_WT_Main

              Updates Work Type Id on
                 pa_projects_all,
                 pa_tasks,
                 pa_expenditure_items_all,
                 pa_cost_distribution_lines_all

              Simultaneously, it also updates Tp Amt Type Code on
                 pa_expenditure_items_all,
                 pa_cc_dist_lines_all
                 pa_draft_invoice_details_all

	      In FP.M, it has been modified to support update
		 inventory_item_id, wip_resource_id, unit_of_measure
	      on pa_expenditure_items_all

   Parameters: IN
                 P_Num_Of_Processes : User given number, that many processes will be spawned
                 P_Worker_Id        : Holds the worker id
                 P_Org_Id           : Holds the operating unit
                 P_Txn_Date         : Holds the transaction start date
                 P_Txn_Type         : Can be 'PJM' or 'WORK TYPE'.
					if PJM, will update Project Manufacturing Attributes on EI table
                 P_Txn_Src          : If given will update EI for the specified Transaction Source only.
                 --Added for R12 AP Lines uptake
                 P_Min_Project_Id   : Holds the minimum of the project id range, internally used
                 P_Max_Project_Id   : Holds the maximum of the project id range, internally used

               OUT
                 X_Return_Status : Currently not used
                 X_Error_Message_Code : Currently not used

*/


   Procedure Upgrade_WT_Main(
                              X_RETURN_STATUS      OUT NOCOPY VARCHAR2
                             ,X_ERROR_MESSAGE_CODE OUT NOCOPY VARCHAR2
   			     ,P_TXN_TYPE           IN VARCHAR2
                             ,P_TXN_SRC            IN VARCHAR2
                             ,P_NUM_OF_PROCESSES   IN NUMBER
                             ,P_WORKER_ID          IN NUMBER
                             ,P_ORG_ID             IN NUMBER DEFAULT NULL
                             ,P_TXN_DATE           IN VARCHAR2
                             ,P_Min_Project_Id     IN NUMBER DEFAULT NULL
                             ,P_Max_Project_Id     IN NUMBER DEFAULT NULL
			     )

   Is

      l_child_req_id  number;
      l_Txn_Date      Date;
      l_get_uom       varchar2(2000); /* Bug 3817950 */
   Begin

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Time = '|| to_char(sysdate,'HH:MI:SS'));
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Validated parameters are as follows:');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_Num_Of_Processes = ' || p_num_of_processes);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_worker_id = ' || p_worker_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_org_id = ' || p_org_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_Txn_Date = ' || P_Txn_Date);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_Txn_Type = ' || P_Txn_Type);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_TXN_SRC  = ' || P_TXN_SRC);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_Min_Project_Id  = ' || P_Min_Project_Id);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_Max_Project_Id  = ' || P_Max_Project_Id);

     l_Txn_Date := fnd_date.canonical_to_date(P_Txn_Date);

     -- Update only projects and tasks for the given project type in the given OU
     -- Submit requests to update EI, CDL, CCDL and DID
     If (p_worker_id = 0) Then

      Declare

        Cursor C_Projects Is
          Select P.Project_Id,
                 Pt.Work_Type_Id
          From  Pa_Projects_All P,
                Pa_Project_Types_All Pt
          Where P.Project_Type = Pt.Project_Type
          And   nvl(P.Org_Id, -99) = nvl(Pt.Org_Id, -99)
          And   Pt.Work_Type_Id is not NULL;

          l_PrjIdTab      PA_PLSQL_DATATYPES.IdTabTyp;
          l_WorkTypeTab   PA_PLSQL_DATATYPES.IdTabTyp;

          l_ReqStsTab     PA_WORK_TYPE_UPGRADE.ResStsTabType;

        Rows number := 1000;

        l_phase                    varchar2(255);
        l_status                   varchar2(255);
        l_dev_phase                varchar2(255);
        l_dev_status               varchar2(255);
        l_message                  varchar2(255);

        l_ins_rowcount             number;

        NOTCOMPLETE                BOOLEAN := TRUE;

        --Code Changes for Bug No.2984871 start
        l_rowcount number :=0;
        --Code Changes for Bug No.2984871 end

        l_inssts            VARCHAR2(30);
        l_industry          VARCHAR2(30);
        l_pa_schema         VARCHAR2(30);

        MIN_Project_Id NUMBER;
        MAX_Project_Id NUMBER;

        l_Min INTEGER := 0;
        l_Max INTEGER := 0;
        l_remainder      integer:=0;

      Begin

      IF P_Txn_Type = 'WORK TYPE' THEN -- PJM Changes

        OPEN C_Projects;

        LOOP

          l_WorkTypeTab.delete;
          l_PrjIdTab.delete;

          FETCH C_Projects BULK COLLECT INTO
               l_PrjIdTab,
               l_WorkTypeTab
          LIMIT Rows;

          If l_PrjIdtab.count = 0 Then
            Exit;
          End If;

          FORALL i in l_PrjIdTab.first .. l_PrjIdTab.last
            update   pa_projects_all
            set      work_type_id = l_WorkTypeTab(i)
            where    project_id = l_PrjIdTab(i)
            and      work_type_id is null;

  	  --Code Changes for Bug No.2984871 start
	  l_rowcount:=sql%rowcount;
	  --Code Changes for Bug No.2984871 end

	  FND_FILE.PUT_LINE(FND_FILE.LOG,'....................');

	  -- Commented for Bug 2984871
	  --	  FND_FILE.PUT_LINE(FND_FILE.LOG,'No of Project Records updated = '||SQL%ROWCOUNT);

	  --Code Changes for Bug No.2984871 start
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'No of Project Records updated = '||l_rowcount);
		  --dbms_output.PUT_LINE('No of Project Records updated = '||l_rowcount);
	  --Code Changes for Bug No.2984871 end

          FORALL i in l_PrjIdTab.first .. l_PrjIdTab.last
            update   pa_tasks
            set      work_type_id = l_WorkTypeTab(i)
            where    project_id = l_PrjIdTab(i)
            and      work_type_id is null;

	  l_rowcount:=sql%rowcount;

          FND_FILE.PUT_LINE(FND_FILE.LOG,'No of Task Records updated = '||l_rowcount);
          --dbms_output.PUT_LINE('No of Task Records updated = '||l_rowcount);

          commit;

          EXIT WHEN C_Projects%NOTFOUND;

       END LOOP ;

       CLOSE C_Projects;

      END IF; -- P_TXN_TYPE = 'WORK TYPE'  -- PJM Changes

      IF P_Txn_Type = 'SUPPLIER TYPE' THEN -- R12 changes

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start EI Upgrade Process'|| to_char(sysdate, 'HH:MI:SS'));

        -- Get the project range if not supplied
/*   bug 9132581 changes start: break the statement into two, as P_Max_Project_Id may be null even when P_Min_Project_Id is not null  */
         IF P_Min_Project_Id IS NULL THEN
          SELECT Min(P.Project_Id)  --, Max(P.Project_Id)
          INTO   Min_Project_Id   --,Max_Project_Id
          FROM   Pa_Projects_All P
          WHERE  p.org_id = nvl(p_org_id,p.org_id);
         ELSE
           Min_Project_Id := P_Min_Project_Id;
--           Max_Project_Id := P_Max_Project_Id;
         END IF;

         IF P_Max_Project_Id IS NULL THEN
          SELECT Max(P.Project_Id)
          INTO   Max_Project_Id
          FROM   Pa_Projects_All P
          WHERE  p.org_id = nvl(p_org_id,p.org_id);
         ELSE
           Max_Project_Id := P_Max_Project_Id;
         END IF;
/*   bug 9132581 changes end */

         l_remainder := MOD((Max_Project_Id-Min_Project_Id),p_num_of_processes);

         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Min_Project_Id  = ' || Min_Project_Id);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Max_Project_Id  = ' || Max_Project_Id);

       l_Max := MIN_Project_Id ;

     IF Min_Project_Id = Max_Project_Id THEN

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '.....................');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Project_Id  = ' || Min_Project_Id);

         -- Call FND API to submit the same request for the EI update
         l_child_req_id := FND_REQUEST.SUBMIT_REQUEST('PA',
                                                      'PAWKTPUP',
                                                      '',
                                                      '',
                                                      FALSE,
                                                      p_txn_type,
                                                      p_txn_src,
                                                      1,
                                                      1,
                                                      p_org_id,
                                                      fnd_date.date_to_canonical(l_TXN_DATE),
                                                      Min_Project_Id,
                                                      Max_Project_Id);
     ELSE

       For i in 1..P_Num_Of_Processes Loop

         l_Min := l_Max;
         l_Max := (l_Min + FLOOR((Max_Project_Id-Min_Project_Id)/p_num_of_processes));

         IF i = P_Num_Of_Processes THEN
	  l_max := l_max + l_remainder;
	 END IF;

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '.....................');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Min Project_Id  = ' || l_Min);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Max Project_Id  = ' || l_Max);

         -- Call FND API to submit the same request for the EI update
         l_child_req_id := FND_REQUEST.SUBMIT_REQUEST('PA',
                                                      'PAWKTPUP',
                                                      '',
                                                      '',
                                                      FALSE,
                                                      p_txn_type,
                                                      p_txn_src,
                                                      p_num_of_processes,
                                                      i,
                                                      p_org_id,
                                                      fnd_date.date_to_canonical(l_TXN_DATE),
                                                      l_min,
                                                      l_max);
         IF (l_child_req_id = 0) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            '...An attempt to submit the upgrade request has failed.');
          FND_FILE.PUT_LINE(FND_FILE.LOG,
			    '...An attempt to submit the upgrade request has failed.');
	 ELSE
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            'The process to upgrade the records has been submitted.
                             Please check Request ID: '|| to_char(l_child_req_id));
          FND_FILE.PUT_LINE(FND_FILE.LOG,
                            'The process to upgrade the records has been submitted.
                             Please check Request ID: '|| to_char(l_child_req_id));
         END IF;

       End Loop;
      END IF;

      END IF; -- P_TXN_TYPE = 'SUPPLIER TYPE'  -- R12 changes


       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Insert into Temp Table '|| to_char(sysdate, 'HH:MI:SS'));

      IF P_TXN_TYPE <> 'SUPPLIER TYPE' THEN -- R12 changes
       execute immediate 'alter session enable parallel dml';
      END IF;

     IF P_Txn_Type = 'WORK TYPE' THEN

       INSERT /*+ APPEND parallel(t) */
         INTO   pa_txn_upgrade_temp t
                (row_id,
                 pk1_id,
                 worker_id,
                 pk2_id)
              select /*+ parallel(ei) */ ei.rowid, ei.expenditure_item_id id, null , ei.task_id
              from   pa_expenditure_items_all ei
              where  trunc(ei.expenditure_item_date) >= trunc(l_Txn_Date)
              and    nvl(ei.org_id, -99) = nvl(p_org_id,nvl(ei.org_id,-99)) /* Changed for Bug #6129449 by anuragar */
              and    work_type_id is null;

       l_ins_rowcount := SQL%ROWCOUNT;

   FND_FILE.PUT_LINE(FND_FILE.LOG, l_ins_rowcount||' Records inserted for WORK TYPE '|| to_char(sysdate, 'HH:MI:SS'));

     ELSIF  P_Txn_Type = 'PJM' THEN

/* 3968368: Added two unions to handle the PJM invoice charges upgrade. For such txns,
	   PJM has been populating the relevant columns in the pa_transaction_interface table
	   in the following manner:

  Column                   Populated value
  ---------------------    ------------------------
  cdl_system_reference1    PO_Distribution_Id
  cdl_system_reference2    RCV_Transaction_Id
  cdl_system_reference3    l_receipt_num
  orig_exp_txn_reference1  Invoice_Id
  orig_exp_txn_reference2  NULL
  orig_exp_txn_reference3  NULL

From 11.5.7 to now

  Column                   Populated value
  ---------------------    --------------------------
  orig_exp_txn_reference1  PO_Distribution_Id
  orig_exp_txn_reference2  InvRec.RCV_Transaction_Id
  orig_exp_txn_reference3  l_receipt_num

*/

      INSERT /*+ APPEND parallel(t) */
        INTO pa_txn_upgrade_temp t
             (row_id
	     ,pk1_id
	     ,worker_id
	     ,pk2_id
	     ,txn_src
	     ,reference1
	     )
             SELECT /*+ parallel(ei) */ EI.ROWID, EI.expenditure_item_id, null
	            , EI.orig_transaction_reference, EI.transaction_source, 'CCO'
             FROM   pa_expenditure_items_all EI, pa_expenditures_all EXP
             WHERE  EI.transaction_source = NVL(P_Txn_Src, EI.transaction_source)
             AND    EI.transaction_source IN ('Inventory Misc', 'Inventory', 'PJM_CSTBP_INV_ACCOUNTS'
	                                     ,'PJM_CSTBP_INV_NO_ACCOUNTS', 'Work In Process'
					     ,'PJM_CSTBP_ST_ACCOUNTS', 'PJM_CSTBP_ST_NO_ACCOUNTS'
					     ,'PJM_CSTBP_WIP_ACCOUNTS', 'PJM_CSTBP_WIP_NO_ACCOUNTS'
					     ,'PJM_NON_CSTBP_ST_ACCOUNTS')
             AND    EI.unit_of_measure IS NULL
	     AND    TRUNC(ei.expenditure_item_date) >= TRUNC(l_TXN_DATE)
             AND    EI.expenditure_id = EXP.expenditure_id
             AND    EXP.orig_exp_txn_reference1 is null
            UNION ALL
             SELECT /*+ parallel(ei) */ EI.ROWID, EI.expenditure_item_id, null
	            , EXP.orig_exp_txn_reference1, EI.transaction_source, 'PODIST'
             FROM   pa_expenditure_items_all EI, pa_expenditures_all EXP
             WHERE  EI.transaction_source IN ('Inventory Misc', 'Inventory', 'PJM_CSTBP_INV_ACCOUNTS'
	                                     ,'PJM_CSTBP_INV_NO_ACCOUNTS', 'Work In Process'
					     ,'PJM_CSTBP_ST_ACCOUNTS', 'PJM_CSTBP_ST_NO_ACCOUNTS'
					     ,'PJM_CSTBP_WIP_ACCOUNTS', 'PJM_CSTBP_WIP_NO_ACCOUNTS'
					     ,'PJM_NON_CSTBP_ST_ACCOUNTS')
             AND    EI.unit_of_measure IS NULL
	     AND    TRUNC(ei.expenditure_item_date) >= TRUNC(l_TXN_DATE)
             AND    EI.expenditure_id = EXP.expenditure_id
             AND    EXP.orig_exp_txn_reference1 is not null
             AND    EXP.orig_exp_txn_reference2 is not null
            UNION ALL
             SELECT /*+ parallel(ei) */ EI.ROWID, EI.expenditure_item_id, null
	            , CDL.system_reference1, EI.transaction_source, 'PODIST'
             FROM   pa_expenditure_items_all  EI, pa_expenditures_all EXP, pa_cost_distribution_lines_all CDL
             WHERE  EI.transaction_source IN ('Inventory Misc', 'Inventory', 'PJM_CSTBP_INV_ACCOUNTS'
	                                     ,'PJM_CSTBP_INV_NO_ACCOUNTS', 'Work In Process'
					     ,'PJM_CSTBP_ST_ACCOUNTS', 'PJM_CSTBP_ST_NO_ACCOUNTS'
					     ,'PJM_CSTBP_WIP_ACCOUNTS', 'PJM_CSTBP_WIP_NO_ACCOUNTS'
					     ,'PJM_NON_CSTBP_ST_ACCOUNTS')
             AND    EI.unit_of_measure IS NULL
	     AND    TRUNC(ei.expenditure_item_date) >= TRUNC(l_TXN_DATE)
             AND    EI.expenditure_id = EXP.expenditure_id
             AND    EXP.orig_exp_txn_reference1 is not null
             AND    EXP.orig_exp_txn_reference2 is null
             AND    EI.expenditure_item_id = CDL.expenditure_item_id
             AND    CDL.line_num = 1;

       l_ins_rowcount := SQL%ROWCOUNT;

       FND_FILE.PUT_LINE(FND_FILE.LOG, l_ins_rowcount || ' Records inserted for PJM '|| to_char(sysdate, 'HH:MI:SS'));

      END IF;

       commit;

     IF  P_Txn_Type <> 'SUPPLIER TYPE' THEN

       UPDATE /*+ parallel(t) */ pa_txn_upgrade_temp t
          SET worker_id = (ceil(rownum / ceil(l_ins_rowcount / p_num_of_processes )));

       commit;

       l_ReqStsTab.delete; -- PJM Changes

       For i in 1..P_Num_Of_Processes Loop

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '.....................');

         -- Call FND API to submit the same request for the EI update
         l_child_req_id := FND_REQUEST.SUBMIT_REQUEST('PA',
                                                      'PAWKTPUP',
                                                      '',
                                                      '',
                                                      FALSE,
                                                      p_txn_type,
                                                      p_txn_src,
                                                      p_num_of_processes,
                                                      i,
                                                      p_org_id,
                                                      fnd_date.date_to_canonical(l_TXN_DATE) );

         IF (l_child_req_id = 0) THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            '...An attempt to submit the upgrade request has failed.');
          FND_FILE.PUT_LINE(FND_FILE.LOG,
			    '...An attempt to submit the upgrade request has failed.');
	 ELSE
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            'The process to upgrade the records has been submitted.
                             Please check Request ID: '|| to_char(l_child_req_id));
          FND_FILE.PUT_LINE(FND_FILE.LOG,
                            'The process to upgrade the records has been submitted.
                             Please check Request ID: '|| to_char(l_child_req_id));
         END IF;

         l_ReqStsTab(i).Request_Id := l_child_req_id;

            if (FND_CONCURRENT.GET_REQUEST_STATUS
                (
                  l_child_req_id,
                  null,  --  pa_schema_name
                  null,  --  request_name
                  l_phase,
                  l_status,
                  l_dev_phase,
                  l_dev_status,
                  l_message
                )) then
              null;
            end if;

         l_ReqStsTab(i).Status := l_dev_phase;

         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Req = ' || l_ReqStsTab(i).Request_Id || ' Sts = ' || l_ReqStsTab(i).Status);

       End Loop;

       commit;

       While NOTCOMPLETE Loop

          dbms_lock.sleep(60);  /* changed sleep seconds from 300 to 60 for 4130368 */

          FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside Loop forever '|| to_char(sysdate,'HH:MI:SS') );

          NOTCOMPLETE := FALSE;

          FOR j in l_ReqStsTab.first..l_ReqStsTab.LAST LOOP

            if (FND_CONCURRENT.GET_REQUEST_STATUS
                (
                  l_ReqStsTab(j).request_id,
                  null,  --  pa_schema_name
                  null,  --  request_name
                  l_phase,
                  l_status,
                  l_dev_phase,
                  l_dev_status,
                  l_message
                )) then
              null;
            end if;

            l_ReqStsTab(j).Status := l_dev_phase;

            If l_dev_phase <> 'COMPLETE'  Then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Loop Again'|| to_char(sysdate,'HH:MI:SS'));
               NOTCOMPLETE := TRUE;
               exit;
            End If;

          END LOOP;

       End Loop;

          IF (NOT FND_INSTALLATION.GET_APP_INFO('PA', l_inssts, l_industry, l_pa_schema)) THEN
             raise_application_error(-20001,SQLERRM);
          END IF;

	  FND_FILE.PUT_LINE(FND_FILE.LOG,'Truncating Table '|| l_pa_schema || '.pa_txn_upgrade_temp '||
					 to_char(sysdate,'HH:MI:SS') );

	  execute immediate ('Truncate table ' || l_pa_schema || '.pa_txn_upgrade_temp');

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling pa_uom.get_uom for updating UOM Meaning '|| to_char(sysdate,'HH:MI:SS') );

	  l_get_uom := 'F';

          l_get_uom := pa_uom.get_uom(fnd_global.USER_ID);

          IF (l_get_uom = 'S') THEN

             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Successfully Updated UOM Meanings in PA '|| to_char(sysdate,'HH:MI:SS'));

          ELSE

             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error While Updating UOM Meanings in PA '||l_get_uom);
             raise_application_error(-20001,SQLERRM);

          END IF;

          commit;
       END IF; -- P_Txn_Type <> 'SUPPLIER TYPE'

      End;

     End If;  -- p_worker_id

     If (p_worker_id <> 0) Then

        FND_FILE.PUT_LINE(FND_FILE.LOG, p_worker_id|| ' is the worker_id '|| to_char(sysdate,'HH:MI:SS'));

        Declare

           Cursor C_Ei Is
           Select Temp.Pk1_Id,
                  Tsk.Work_Type_Id,
                  Wt.Tp_Amt_Type_Code
             From pa_txn_upgrade_temp Temp,
                  Pa_Tasks Tsk,
                  Pa_Work_Types_B Wt
            Where Worker_Id = p_worker_id
              And Temp.Pk2_id = Tsk.Task_Id
              And Tsk.Work_Type_Id = Wt.Work_Type_Id;

          CURSOR   Cur_PJM_Attr IS
          SELECT   MMT.Inventory_Item_Id Inventory_Item_ID
                  ,to_number(NULL)  Wip_Resource_Id
                  ,MSI.Primary_UOM_Code UOM
                  ,Temp.Pk1_Id
          FROM     MTL_MATERIAL_TRANSACTIONS MMT
                  ,MTL_SYSTEM_ITEMS MSI
                  ,Pa_Txn_Upgrade_Temp Temp
          WHERE    Temp.Worker_Id = p_worker_id
          And      Temp.Pk2_id = MMT.Transaction_Id
          AND      MMT.Inventory_Item_Id = MSI.Inventory_Item_Id
          AND      MMT.Organization_Id =MSI.Organization_Id
          AND      Temp.Txn_Src IN ('Inventory Misc', 'Inventory'
                  ,'PJM_CSTBP_INV_ACCOUNTS', 'PJM_CSTBP_INV_NO_ACCOUNTS')
          AND      Temp.Reference1 = 'CCO'
          UNION ALL
          SELECT  to_number(NULL) Inventory_Item_ID
                  ,WT.Resource_Id Wip_Resource_ID
                  ,WT.Primary_UOM UOM
                  ,Temp.Pk1_ID
          FROM     WIP_TRANSACTIONS WT
                  ,Pa_Txn_Upgrade_Temp Temp
          WHERE    Temp.Worker_Id = p_worker_id
          And      Temp.Pk2_ID = WT.Transaction_ID
          AND      Temp.Txn_Src IN ('Work In Process'
                  ,'PJM_CSTBP_ST_ACCOUNTS', 'PJM_CSTBP_ST_NO_ACCOUNTS'
                  ,'PJM_CSTBP_WIP_ACCOUNTS', 'PJM_CSTBP_WIP_NO_ACCOUNTS'
                  ,'PJM_NON_CSTBP_ST_ACCOUNTS')
          AND      Temp.Reference1 = 'CCO'
          UNION ALL
          SELECT    decode(PoDist.destination_type_code, 'INVENTORY' , PoLine.Item_Id, null) Inventory_Item_ID ,
                    decode(PoDist.destination_type_code, 'SHOP FLOOR', PoDist.Bom_Resource_Id, null) Wip_Resource_ID ,
                    'DOLLARS' UOM ,
                    Temp.Pk1_Id
          FROM	    Pa_Txn_Upgrade_Temp Temp,
                    Po_Distributions_All PoDist,
                    Po_Lines_All PoLine
          WHERE     Temp.Worker_Id = p_worker_id
          AND       Temp.Pk2_Id = PoDist.po_distribution_id
          AND       PoDist.Po_Line_Id = PoLine.Po_Line_Id
          AND 	    Temp.Txn_Src in ('Inventory Misc', 'Inventory', 'PJM_CSTBP_INV_ACCOUNTS', 'PJM_CSTBP_INV_NO_ACCOUNTS',
                                     'Work In Process','PJM_CSTBP_ST_ACCOUNTS', 'PJM_CSTBP_ST_NO_ACCOUNTS',
                                     'PJM_CSTBP_WIP_ACCOUNTS', 'PJM_CSTBP_WIP_NO_ACCOUNTS','PJM_NON_CSTBP_ST_ACCOUNTS')
          AND 	    Temp.Reference1 = 'PODIST';


	   l_InvItmIdTab  PA_PLSQL_DATATYPES.IdTabTyp;
	   l_WIPIdTab     PA_PLSQL_DATATYPES.IdTabTyp;
           l_UOMTab       PA_PLSQL_DATATYPES.Char30TabTyp;

	   l_EIIdTab    PA_PLSQL_DATATYPES.IdTabTyp;
           l_WtIdTab    PA_PLSQL_DATATYPES.IdTabTyp;
           l_WtTpAmtTab PA_PLSQL_DATATYPES.Char30TabTyp;

           Rows number := 1000;
           l_rowcount number :=0;

TYPE rowid_typ                IS TABLE OF varchar2(30) ;
TYPE exp_item_id_typ          IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.expenditure_item_id%TYPE;
TYPE vendor_id_typ            IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.vendor_id%TYPE;
TYPE doc_header_id_typ        IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.document_header_id%TYPE;
TYPE doc_dist_id_typ          IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.document_distribution_id%TYPE;
TYPE doc_line_num_typ         IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.document_line_number%TYPE;
TYPE doc_payment_id_typ       IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.document_payment_id%TYPE;
TYPE document_typ             IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.document_type%TYPE;
TYPE document_dist_typ        IS TABLE OF  PA_EXPENDITURE_ITEMS_ALL.document_distribution_type%TYPE;

l_ei_rowid_tbl           rowid_typ ;
l_exp_item_id_tbl      exp_item_id_typ;
l_vendor_id_tbl        vendor_id_typ;
l_doc_header_id_tbl    doc_header_id_typ;
l_doc_dist_id_tbl      doc_dist_id_typ;
l_doc_line_num_tbl     doc_line_num_typ;
l_doc_payment_id_tbl   doc_payment_id_typ;
l_document_tbl         document_typ;
l_document_dist_tbl    document_dist_typ;
l_plsql_max_array_size number := 200;

-- Get all the VI related transactions to be upgraded.
CURSOR cur_ap_po_ei(p_project_id in number) IS
 SELECT /*+ leading(ei) index(ei,pa_expenditure_items_n8) use_nl(cdl,inv,dist) */
         ei.rowid,
         cdl.expenditure_item_id,
         to_number(cdl.system_reference1) vendor_id,
         inv.invoice_id doc_header_id,
         dist.invoice_distribution_id doc_dist_id,
         dist.invoice_line_number doc_line_num,
         NVL2(LTRIM(cdl.system_reference4, '0123456789'), NULL, cdl.system_reference4) doc_payment_id,
         inv.invoice_type_lookup_code doc_type,
         dist.line_type_lookup_code dist_type
  FROM   pa_cost_distribution_lines_all cdl,
         pa_expenditure_items_all ei,
         ap_invoice_distributions_all dist,
         ap_invoices_all inv
  WHERE  cdl.expenditure_item_id = ei.expenditure_item_id
  AND    inv.invoice_id = to_number(cdl.system_reference2)
  AND    dist.invoice_id = to_number(cdl.system_reference2)
  AND    dist.invoice_id = inv.invoice_id
  AND    dist.project_id > 0
  AND    dist.old_dist_line_number = to_number(cdl.system_reference3)
  AND    ((dist.line_type_lookup_code = decode(ei.transaction_source,'AP VARIANCE',cdl.system_reference4,
                                                                     'AP INVOICE','ITEM',
                                                                     'AP NRTAX','NONREC_TAX',dist.line_type_lookup_code)
          AND ei.transaction_source <> 'AP DISCOUNTS'
          OR dist.line_type_lookup_code = DECODE(ei.transaction_source,'AP VARIANCE','T'||cdl.system_reference4))
         OR dist.line_type_lookup_code = DECODE(ei.transaction_source,'AP INVOICE','PREPAY')
         OR dist.line_type_lookup_code = DECODE(ei.transaction_source,'AP INVOICE','FREIGHT')         /* 8547295 : Added clause */
         OR dist.line_type_lookup_code = DECODE(ei.transaction_source,'AP INVOICE','MISCELLANEOUS')   /* 8547295 : Added clause */
         OR ei.transaction_source = 'AP DISCOUNTS' and dist.line_type_lookup_code NOT IN ('TERV','TRV','ERV','IPV','TIPV'))
  AND    cdl.system_reference2 IS NOT NULL
  AND    cdl.system_reference3 IS NOT NULL
  AND    cdl.line_type ='R'
  AND    cdl.reversed_flag IS NULL
  AND    cdl.line_num_reversed IS NULL
  AND    ei.document_header_id IS NULL
  AND    nvl(ei.historical_flag,'Y') = 'Y'
  AND    ei.expenditure_item_date between nvl(l_Txn_Date,ei.expenditure_item_date) AND sysdate
  AND    ei.project_id = p_project_id
  AND    ei.transaction_source in ('AP EXPENSE', 'AP INVOICE', 'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES', 'AP NRTAX',
         'AP VARIANCE', 'AP DISCOUNTS' ,'AP ERV') /* changed for bug 9320194 */
 UNION ALL
 SELECT /*+ leading(ei) index(ei,pa_expenditure_items_n8) use_nl(cdl,inv,dist) */
         ei.rowid,
         cdl.expenditure_item_id,
         to_number(cdl.system_reference1) vendor_id,
         to_number(cdl.system_reference2) doc_header_id,
         to_number(NVL2(LTRIM(cdl.system_reference4, '0123456789'), NULL, cdl.system_reference4)) doc_dist_id,
         to_number(cdl.system_reference3) doc_line_num,
         null doc_payment_id,
         rcv.destination_type_code doc_type,
         rcv.transaction_type dist_type
  FROM   pa_cost_distribution_lines_all cdl,
         pa_expenditure_items_all ei,
         rcv_transactions rcv
  WHERE  cdl.expenditure_item_id = ei.expenditure_item_id
  AND    rcv.transaction_id = to_number(NVL2(LTRIM(cdl.system_reference4, '0123456789'), NULL, cdl.system_reference4))
  AND    rcv.po_distribution_id = to_number(cdl.system_reference3)
  AND    cdl.system_reference2 IS NOT NULL
  AND    cdl.system_reference3 IS NOT NULL
  AND    cdl.line_type ='R'
  AND    cdl.reversed_flag IS NULL
  AND    cdl.line_num_reversed IS NULL
  AND    ei.document_header_id IS NULL
  AND    nvl(ei.historical_flag,'Y') = 'Y'
  AND    ei.expenditure_item_date between nvl(l_Txn_Date,ei.expenditure_item_date) AND sysdate
  AND    ei.project_id = p_project_id
  AND    ei.transaction_source like 'PO %';

-- Get all the uncosted VI related transactions to be upgraded.
CURSOR cur_uncosted_ei(p_project_id in number) IS
 SELECT  ei.rowid,
         ei.expenditure_item_id
 FROM    pa_expenditure_items_all ei
 WHERE   ei.cost_distributed_flag = 'N'
 ANd     ei.document_header_id IS NULL
 AND     nvl(ei.historical_flag,'Y') = 'Y'
 AND     ei.expenditure_item_date between nvl(l_Txn_Date,ei.expenditure_item_date) AND sysdate
 AND     ei.project_id = p_project_id
 AND     (ei.transaction_source in ('AP EXPENSE', 'AP INVOICE', 'INTERCOMPANY_AP_INVOICES', 'INTERPROJECT_AP_INVOICES', 'AP NRTAX',
         'AP VARIANCE', 'AP DISCOUNTS' ,'AP ERV') OR  ei.transaction_source like 'PO %') /* changed for bug 9320194 */
 AND NOT EXISTS ( SELECT NULL
                  FROM   pa_cost_distribution_lines_all cdl
                  WHERE  cdl.expenditure_item_id = ei.expenditure_item_id);


Cursor cur_upg_project is
  SELECT project_id
  FROM   pa_projects_all
  WHERE  project_id between P_Min_Project_Id and P_Max_Project_Id;

        Begin

        IF P_Txn_Type = 'WORK TYPE' THEN

           Open C_Ei;

           Loop

	       l_EIIdTab.delete;
               l_WtIdTab.delete;
               l_WtTpAmtTab.delete;
               l_InvItmIdTab.delete;
               l_WIPIdTab.delete;
               l_UOMTab.delete;

               FETCH C_EI BULK COLLECT INTO
                     l_EIIdTab,
                     l_WtIdTab,
                     l_WtTpAmtTab
                LIMIT Rows;

               If l_EIIdTab.count = 0 Then
                  Exit;
               End If;

               FORALL i in l_EIIdTab.first .. l_EIIdTab.last
                 update   pa_expenditure_items_all
                    set   work_type_id = l_WtIdTab(i),
                          tp_amt_type_code = l_WtTpAmtTab(i)
                  where   Expenditure_Item_Id = l_EIIdTab(i);

	       l_rowcount:=sql%rowcount;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'No of EI Records updated = '||l_rowcount);
               commit;

               FORALL j in l_EIIdTab.first .. l_EIIdTab.last
                 update   pa_cost_distribution_lines_all
                    set   work_type_id = l_WtIdTab(j)
                  where   Expenditure_Item_Id = l_EIIdTab(j)
                    and   line_type = 'R';

               l_rowcount:=sql%rowcount;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'No of CDL Records updated = '||l_rowcount);
               commit;

               FORALL k in l_EIIdTab.first .. l_EIIdTab.last
                 update   pa_cc_dist_lines_all
                    set   tp_amt_type_code = l_WtTpAmtTab(k)
                  where   Expenditure_Item_Id = l_EIIdTab(k)
                    and   tp_amt_type_code is null;

	       l_rowcount:=sql%rowcount;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'No of CCDL Records updated = '||l_rowcount);
               commit;

               FORALL l in l_EIIdTab.first .. l_EIIdTab.last
                 update   pa_draft_invoice_details_all
                    set   tp_amt_type_code = l_WtTpAmtTab(l)
                  where   Expenditure_Item_Id = l_EIIdTab(l)
                    and   tp_amt_type_code is null;

     	       l_rowcount:=sql%rowcount;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'No of DID Records updated = '||l_rowcount);
               commit;

           End Loop;

           Close c_Ei;


	ELSIF  P_Txn_Type = 'PJM' THEN

           OPEN Cur_PJM_Attr;

           Loop

	       l_EIIdTab.delete;
               l_WtIdTab.delete;
               l_WtTpAmtTab.delete;
               l_InvItmIdTab.delete;
               l_WIPIdTab.delete;
               l_UOMTab.delete;

               FETCH Cur_PJM_Attr BULK COLLECT INTO
                     l_InvItmIdTab
		    ,l_WIPIdTab
		    ,l_UOMTab
		    ,l_EIIdTab
                LIMIT Rows;

               If l_EIIdTab.count = 0 Then
                  Exit;
               End If;

	       FORALL i in l_EIIdTab.first .. l_EIIdTab.last
                 update   pa_expenditure_items_all
                    set   inventory_item_id  = l_InvItmIdTab(i)
                         ,wip_resource_id    = l_WIPIdTab(i)
			 ,unit_of_measure    = l_UOMTab(i)
                  where  Expenditure_Item_Id = l_EIIdTab(i);

	       l_rowcount:=sql%rowcount;

               FND_FILE.PUT_LINE(FND_FILE.LOG, l_rowcount || ' EI Records updated '||to_char(sysdate,'HH:MI:SS'));
               commit;

           End Loop;

           Close Cur_PJM_Attr;

	  ELSIF  P_Txn_Type = 'SUPPLIER TYPE' THEN   --R12 changes

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Initializing variables for cur_ap_po_ei');

               l_ei_rowid_tbl          := rowid_typ(null);
               l_exp_item_id_tbl       := exp_item_id_typ(null);
               l_vendor_id_tbl         := vendor_id_typ(null);
               l_doc_header_id_tbl     := doc_header_id_typ(null);
               l_doc_dist_id_tbl       := doc_dist_id_typ(null);
               l_doc_line_num_tbl      := doc_line_num_typ(null);
               l_doc_payment_id_tbl    := doc_payment_id_typ(null);
               l_document_tbl          := document_typ(null);
               l_document_dist_tbl     := document_dist_typ(null);

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Opening cursor cur_upg_proj');

           FOR upg_proj in cur_upg_project LOOP

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Opening cursor cur_ap_po_ei');

            OPEN  cur_ap_po_ei(upg_proj.project_id);
             LOOP


               l_ei_rowid_tbl.delete;
               l_exp_item_id_tbl.delete;
               l_vendor_id_tbl.delete;
               l_doc_header_id_tbl.delete;
               l_doc_dist_id_tbl.delete;
               l_doc_line_num_tbl.delete;
               l_doc_payment_id_tbl.delete;
               l_document_tbl.delete;
               l_document_dist_tbl.delete;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Fetching Cusor cur_ap_po_ei');

             FETCH cur_ap_po_ei BULK COLLECT INTO
               l_ei_rowid_tbl,
               l_exp_item_id_tbl,
               l_vendor_id_tbl,
               l_doc_header_id_tbl,
               l_doc_dist_id_tbl,
               l_doc_line_num_tbl,
               l_doc_payment_id_tbl,
               l_document_tbl,
               l_document_dist_tbl
             limit l_plsql_max_array_size;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'After Bulk Collecting Cusor cur_ap_po_ei');

              If l_ei_rowid_tbl.count = 0 Then
                 Exit;
              End If;

              FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating EI columns -R12 ');

       FORALL i in l_ei_rowid_tbl.first..l_ei_rowid_tbl.last
            UPDATE pa_expenditure_items_all ei
            SET    ei.vendor_id = l_vendor_id_tbl(i),
                   ei.last_update_date = sysdate,
                   ei.document_header_id = l_doc_header_id_tbl(i),
                   ei.document_distribution_id = l_doc_dist_id_tbl(i),
                   ei.document_line_number = l_doc_line_num_tbl(i),
                   ei.document_payment_id = l_doc_payment_id_tbl(i),
                   ei.document_type = l_document_tbl(i),
                   ei.document_distribution_type = l_document_dist_tbl(i),
                   ei.historical_flag = decode(l_doc_header_id_tbl(i),NULL,NULL,nvl(ei.historical_flag,'Y'))
           WHERE   ei.rowid = l_ei_rowid_tbl(i);

           l_rowcount := nvl(l_rowcount, 0) + SQL%ROWCOUNT;

            -- commit transaction here
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Commit in Loop');
            commit;

 END LOOP;
 CLOSE cur_ap_po_ei;

              FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating uncosted EI columns ');
           -- Update the adjusted and uncosted expenditures. Bug#5381198.
        FOR uncosted_ei in cur_uncosted_ei(upg_proj.project_id) LOOP

             UPDATE pa_expenditure_items_all ei
             SET      (ei.vendor_id,
                       ei.document_header_id,
                       ei.document_distribution_id,
                       ei.document_line_number,
                       ei.document_payment_id,
                       ei.document_type,
                       ei.document_distribution_type) = (
		                                  SELECT uei.vendor_id,
                                                         uei.document_header_id,
                                                         uei.document_distribution_id,
                                                         uei.document_line_number,
                                                         uei.document_payment_id,
                                                         uei.document_type,
                                                         uei.document_distribution_type
		                                   FROM  pa_expenditure_items_all uei
		                                   WHERE uei.document_header_id >0
                                                   START WITH uei.expenditure_item_id = uncosted_ei.expenditure_item_id
                                                   CONNECT BY PRIOR NVL(uei.adjusted_expenditure_item_id,uei.transferred_from_exp_item_id)
                                                              =  uei.expenditure_item_id
                                                   AND   rownum = 1
                                                          ),
		        ei.historical_flag  = NVL(ei.historical_flag,'Y')
               WHERE ei.rowid = uncosted_ei.rowid;

          END LOOP;

            -- commit transaction here
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Commit in Loop - Uncosted Expenditures ');
            commit;
END LOOP;

          END IF;

        Exception
           When Others Then
           Raise;
        End;

     End If;

   Exception

      When Others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_error_message_code := (SQLCODE||' '||SQLERRM);
         raise_application_error(-20001,SQLERRM);

   End Upgrade_WT_Main;

END PA_WORK_TYPE_UPGRADE;

/
