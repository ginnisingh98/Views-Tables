--------------------------------------------------------
--  DDL for Package Body GMS_LD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_LD_PKG" AS
-- $Header: gmsenxfb.pls 120.5 2007/02/06 09:49:54 rshaik ship $

   -- Bug :3265300, 3345880
   -- PSP: encumbrance summarize and transfer gives 'GMS_UNEXPECTED_ERROR'
   -- Procedure created to log unexpected errors in the log file.
   -- irrespective of the debug enabled flag.
   PROCEDURE write_to_log( p_message varchar2 ) IS
   BEGIN
       if p_message is NULL then
          return ;
       end if ;

       fnd_file.put(fnd_file.log, substr(p_message,1,255)) ;

       if substr(p_message,256) is not null then
          fnd_file.put(fnd_file.log, substr(p_message,256)) ;
       end if ;
   END write_to_log ;

   PROCEDURE PRE_PROCESS (P_TRANSACTION_SOURCE    IN  VARCHAR2,
                         P_BATCH                 IN  VARCHAR2,
                         P_XFACE_ID              IN  NUMBER,
                         P_USER_ID               IN  NUMBER) IS

    CURSOR TrxBatches IS
    SELECT
	        xc.transaction_source
    ,       xc.batch_name
    ,       xc.system_linkage_function
    --,       xc.batch_name ||xc.system_linkage_function|| to_char(P_xface_id) exp_group_name name  --Bug 3035863 : commented as its not used anywhere
      FROM
            pa_transaction_xface_control xc
     WHERE
            xc.transaction_source = P_transaction_source
       AND  xc.batch_name         = nvl(P_batch, xc.batch_name)
       AND  xc.status             = 'PENDING';

    -- PA.L Changes
    CURSOR c_trans_source is
    SELECT allow_emp_org_override_flag ,
           purgeable_flag              ,   -- Added following columns for Bug 3035863
           allow_duplicate_reference_flag,
	   gl_accounted_flag ,
           allow_reversal_flag     ,
           costed_flag             ,
           allow_burden_flag
      from pa_transaction_sources
     where transaction_source = P_TRANSACTION_SOURCE ;
    -- PA.L Changes.

    CURSOR TrxRecs ( X_transaction_source  VARCHAR2
                   , current_batch         VARCHAR2
                   , curr_etype_class_code VARCHAR2  ) IS
    SELECT
            to_char(trunc(expenditure_ending_date), 'J')||':'||
            nvl(employee_number, '-DUMMY EMP-')||':'||
            nvl(organization_name, '-DUMMY ORG-')||':'||
            nvl(orig_exp_txn_reference1, '-DUMMY EXP_TXN_REF1-') || ':' ||
            nvl(orig_user_exp_txn_reference, '-DUMMY USER_EXP_TXN_REF-') || ':' ||
            nvl(vendor_number, '-DUMMY VENDOR_NUMBER-') || ':' ||
            nvl(orig_exp_txn_reference2, '-DUMMY EXP_TXN_REF2-') || ':' ||
            nvl(orig_exp_txn_reference3, '-DUMMY EXP_TXN_REF3-') expend
    ,       decode(system_linkage,'OT','ST',system_linkage) || ':' ||
            decode(system_linkage,'ER', nvl(denom_currency_code,'-DUMMY CODE-'),
                                  'VI', nvl(denom_currency_code,'-DUMMY CODE-'),
                                  '-DUMMY CODE-')||':'||
            decode(system_linkage,'ER', nvl(to_char(acct_rate_date,'MMDDYYYY'),'-DUMMY DATE-'),
                                  'VI', nvl(to_char(acct_rate_date,'MMDDYYYY'),'-DUMMY DATE-'),
                                  '-DUMMY DATE-')||':'||
            decode(system_linkage,'ER', nvl(acct_rate_type,'-DUMMY TYPE-'),
                                  'VI', nvl(acct_rate_type,'-DUMMY TYPE-'),
                                  '-DUMMY TYPE-')||':'||
            decode(system_linkage,'ER', nvl(to_char(acct_exchange_rate),'-DUMMY RATE-'),
                                  'VI', nvl(to_char(acct_exchange_rate),'-DUMMY RATE-'),
                                  '-DUMMY RATE-') expend2
    ,       system_linkage
    ,       trunc(expenditure_ending_date) expenditure_ending_date
    ,       employee_number
    ,       organization_name
    ,       trunc(expenditure_item_date) expenditure_item_date
    ,       project_number
    ,       task_number
    ,       expenditure_type
    ,       non_labor_resource
    ,       non_labor_resource_org_name
    ,       quantity
    ,       raw_cost
    ,       raw_cost_rate
    ,       orig_transaction_reference
    ,       attribute_category
    ,       attribute1
    ,       attribute2
    ,       attribute3
    ,       attribute4
    ,       attribute5
    ,       attribute6
    ,       attribute7
    ,       attribute8
    ,       attribute9
    ,       attribute10
    ,       expenditure_comment
    ,       interface_id
    ,       expenditure_id
    ,       nvl(unmatched_negative_txn_flag, 'N') unmatched_negative_txn_flag
    ,       to_number( NULL )  expenditure_item_id
    ,       to_number( NULL )  job_id
    ,       org_id             org_id
    ,       dr_code_combination_id
    ,       cr_code_combination_id
    ,       cdl_system_reference1
    ,       cdl_system_reference2
    ,       cdl_system_reference3
    ,       gl_date
    ,       burdened_cost
    ,       burdened_cost_rate
    ,       receipt_currency_amount
    ,       receipt_currency_code
    ,	      receipt_exchange_rate
    ,       denom_currency_code
    ,	      denom_raw_cost
    ,	      denom_burdened_cost
    ,	      acct_rate_date
    ,	      acct_rate_type
    ,       acct_exchange_rate
    ,       pa_currency.round_currency_amt(acct_raw_cost) acct_raw_cost
    ,       acct_burdened_cost
    ,       acct_exchange_rounding_limit
    ,       project_currency_code
    ,       project_rate_date
    ,       project_rate_type
    ,       project_exchange_rate
    ,       orig_exp_txn_reference1
    ,       orig_user_exp_txn_reference
    ,       vendor_number
    ,       orig_exp_txn_reference2
    ,       orig_exp_txn_reference3
    ,       override_to_organization_name
    ,       reversed_orig_txn_reference
    ,       billable_flag
    ,       txn_interface_id
    ,       person_business_group_name
	-- Bug 2464841 : Added parameters for 11.5 PA-J certification.
    ,	    projfunc_currency_code
    ,	    projfunc_cost_rate_type
    ,	    projfunc_cost_rate_date
    ,	    projfunc_cost_exchange_rate
    ,	    project_raw_cost
    ,	    project_burdened_cost
    ,	    assignment_name
    ,	    work_type_name
    ,	    accrual_flag
    ,       project_id -- PA.L Changes
    ,       task_id
    ,       person_id
    ,       organization_id
    ,       non_labor_resource_org_id
    ,       vendor_id
    ,       override_to_organization_id
    ,       assignment_id
    ,       work_type_id
    ,       person_business_group_id   -- PA.L Changes end.
    ,       po_number  /* cwk */
    ,       po_header_id
    ,       po_line_num
    ,       po_line_id
    ,       person_type
    ,       po_price_type
    ,       wip_resource_id
    ,       inventory_item_id
    ,       unit_of_measure
      FROM pa_transaction_interface_all
     WHERE transaction_source = X_transaction_source
       AND batch_name = current_batch
       AND transaction_status_code = 'P'
       AND decode(system_linkage,'OT','ST',system_linkage) =
                                                      curr_etype_class_code
    ORDER BY
            decode(system_linkage,'OT','ST',system_linkage)
    ,       expenditure_ending_date DESC
    ,       employee_number
    ,       organization_name
    ,       orig_exp_txn_reference1
    ,       orig_user_exp_txn_reference
    ,       vendor_number
    ,       orig_exp_txn_reference2
    ,       orig_exp_txn_reference3
    ,       denom_currency_code
    ,	      acct_rate_date
    ,	      acct_rate_type
    ,	      acct_exchange_rate
    ,       expenditure_item_date
    ,       project_number
    ,       task_number
    FOR UPDATE OF transaction_status_code;

    -- Bug 3465939: Defined cursor to fetch the information associated with Liquidated Encumbrance item.
    -- This cursor returns 'Y' as Net_zero_adjustment_flag if the Encumbrance item being imported is
    -- a liquidated Encumbrance Item.

    CURSOR c_get_org_enc_item_id(p_txn_interface_id NUMBER) IS
    SELECT original_encumbrance_item_id ,
           DECODE(original_encumbrance_item_id,NULL,NULL,'Y')  net_zero_adjustment_flag
      FROM gms_transaction_interface_all
     WHERE txn_interface_id = p_txn_interface_id ;

    TrxRec		TrxRecs%ROWTYPE;
    X_status		varchar2(100);
    X_success       varchar2(1)  ;
    X_bill_flag		varchar2(100);
     l_encumbrance_grp          GMS_ENCUMBRANCE_GROUPS_ALL.ENCUMBRANCE_GROUP%TYPE; -- Bug 3035863 : Modified to reflect size change
     l_org_id                   NUMBER ;
     l_exp_ending_date          DATE;
     l_enc_id                   NUMBER ; -- Bug 3220756 : Removed intialization to zero
     l_system_linkage_fn        VARCHAR2(100);
     l_task_id                  VARCHAR2(30);
     l_override_organization_id NUMBER; -- bug# 2111317
     l_organization_id          NUMBER; -- not initializing this just in case
     x_dummy		        NUMBER  ;
     l_gen_seq                  VARCHAR2(1) ;
     --l_organization_name        VARCHAR2(60);
      -- The width of the variable is changed for UTF8 changes for HRMS schema. refer bug 2302839.
     l_organization_name        HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
     l_employee_number          VARCHAR2(30);
     dummy                      NUMBER;
     FIRST_RECORD       BOOLEAN ;
     ORG_FIRST          BOOLEAN ;
     GROUP_FIRST        BOOLEAN ;
     TASK_FIRST         BOOLEAN ;
     PROJ_FIRST         BOOLEAN ;

     -- S.N. Introduced for the bug# 4138033
     TASK_FAIL          BOOLEAN ;
     PROJ_FAIL          BOOLEAN ;
     -- E.N. Introduced for the bug# 4138033

     l_rowid                    VARCHAR2(40);
     l_person_id                NUMBER(15);
     l_task_number              VARCHAR2(40);
     l_project_id               NUMBER(15);
     l_award_id                 gms_awards_all.award_id%TYPE; /*Bug# 4138033*/
     l_enc_item_id              NUMBER(15);
     l_project_number           VARCHAR2(25);
     x_calling_module		varchar2(50)  ;
     x_acct_currency_code	VARCHAR2(15); -- Added for Bug:1331903
     l_emp_org_oride            varchar2(1) ;
     l_emporg_id                NUMBER ;
     l_empJob_id                NUMBER ;
     -- Bug 3465939 and 3035863 :  Defined following variables
     l_orig_enc_item_id         NUMBER ;
     l_net_zero_adj_flag        VARCHAR2(1);
     l_purgeable_flag           VARCHAR2(1);
     l_allow_dup_ref_flag       VARCHAR2(1);
     l_gl_accted_flag	        VARCHAR2(1) ;
     l_allow_reversal_flag      VARCHAR2(1) ;
     l_costed_flag              VARCHAR2(1) ;
     l_allow_burden_flag        VARCHAR2(1) ;
     x_status_code              VARCHAR2(100) ;


  RESOURCE_BUSY     EXCEPTION;
  PRAGMA EXCEPTION_INIT( RESOURCE_BUSY, -0054 );

  FUNCTION lockCntrlRec     ( trx_source   VARCHAR2
                          , batch        VARCHAR2
                          , etypeclasscode VARCHAR2 ) RETURN NUMBER
    IS
    -- Bug 3035863 : Moved the select statement to cursor for locking more than one
    -- record when batch name is NULL

    CURSOR C_lock_records IS
       SELECT 1
        FROM
              pa_transaction_xface_control
       WHERE
              transaction_source = trx_source
         AND  batch_name = NVL(batch,batch_name) -- Bug 3035863 : Introduced NVL as batch can be NULL
         AND  system_linkage_function = NVL(etypeclasscode,system_linkage_function) -- Bug 3035863 : Introduced NVL as etypeclasscode can be NULL
         AND  status = 'PENDING'
      FOR UPDATE OF status NOWAIT;

    BEGIN

      pa_cc_utils.set_curr_function('lockCntrlRec');

      pa_cc_utils.log_message('Trying to get lock for record in xface ctrl:'||
                                ' transaction source ='||trx_source||
                                ' batch = '||batch||
                                ' sys link = '||etypeclasscode, 1);

      -- Bug 3035863 : Moved the select logic to cursor for handling locking of multiple rows
      FOR i in C_lock_records LOOP
        NULL;
      END LOOP;

       pa_cc_utils.log_message('Got lock for record',1);

       /* Bug 3035863:  Explanation on below code modification

          Oracle projects Transaction import process picks the PENDING status records
	  from control table pa_transaction_xface_control and updates them to 'IN_PROGRESS'
	  during processing .At the end of process updates them to 'PROCESSED' if successful
	  else in case of failure updates them back to 'PENDING' status.

          But in Grants the records are marked and left in 'IN_PROGRESS' status. We don't
	  mark the records to 'PROCESSED'  as the Projects code deletes 'PROCESSED' records
	  when purgeable_flag is set to 'Yes'.And to prevent user from updating/deleting
	  the Encumbrance transaction source details through 'Transaction Sources' form
	  i.e. PAXTRTXS.fmb  we need record in control table ,hence Grants code leaves records
	  in control table with 'IN_PROGRESS' status.

          Scenario Fixed : When transaction which is rejected is marked for re-processing
	  then grants code was failing with unique constraint violation on above control table.

          Code issue : After processing records are left in 'In_PROGRESS' status and when the
	  transaction is marked for re-processing projects code checks for PENDING status
	  record in control table and as it fails to find one it creates a new record with
	  PENDING status. Grants code tries to mark even this new record to In_PROGRESS and
	  fails with UNIQUE constraint violation, as both records are similar.

          Solution:  Delete the 'IN_PROGRESS' record created during the previous unsuccessful
	  run before updating the current run record to same status. */

      pa_cc_utils.log_message('GMS_LD_PKG.LOCKCNTRLREC : Deleting interface control record in IN_PROGRESS status which is created during last run' ,1);

      DELETE  pa_transaction_xface_control
       WHERE  transaction_source = trx_source
         AND  batch_name = NVL(batch,batch_name) -- Bug 3035863
         AND  system_linkage_function = NVL(etypeclasscode,system_linkage_function) -- Bug 3035863
         AND  status = 'IN_PROGRESS' ;

      pa_cc_utils.log_message('GMS_LD_PKG.LOCKCNTRLREC : Number of records deleted from pa_transaction_xface_control : '||SQl%ROWCOUNT);

      UPDATE  pa_transaction_xface_control
         SET
              interface_id = P_xface_id
      ,       status = 'IN_PROGRESS'
       WHERE
              transaction_source = trx_source
         AND  batch_name = NVL(batch,batch_name) -- Bug 3035863
         AND  system_linkage_function = NVL(etypeclasscode,system_linkage_function) -- Bug 3035863
         AND  status = 'PENDING';

      pa_cc_utils.log_message('Updated interface id/status on pa_transaction_xface_control',1);

      pa_cc_utils.reset_curr_function;
      RETURN 0;

    EXCEPTION
      WHEN  RESOURCE_BUSY  THEN
      pa_cc_utils.log_message('Cannot get lock',1);
      pa_cc_utils.reset_curr_function;
      write_to_log('GMS :lockCntrlRec RESOURCE_BUSY exception raised '||SQLCODE) ;
      write_to_log('GMS :SQLERRM '||SQLERRM) ;
      write_to_log('GMS :Parameter trx_source :'||trx_source||' system_linkage_function :'||etypeclasscode) ;
      raise_application_error(SQLCODE,SQLERRM) ;
      RETURN -1;
  END lockCntrlRec;

  FUNCTION GET_award_id return NUMBER is

    X_award_id  NUMBER ;

    -- Bug 31221039 : Modified the below cursor to fetch award_id based on award_number/award_id.

    CURSOR C1 IS
    SELECT ga.award_id
      FROM gms_transaction_interface_all gtxn,
           gms_awards_all ga
     WHERE ((gtxn.award_number IS NULL AND ga.award_id = NVL(gtxn.award_id,0)  ) OR
            (ga.award_number = gtxn.award_number) )
       AND gtxn.txn_interface_id = Trxrec.txn_interface_id ;

  begin
    open c1 ;
    fetch C1 into x_award_id ;
    IF c1%notfound then
        x_award_id := 0 ;
    end if ;
    close C1 ;
    return x_award_id ;
  exception
    when others then
        IF c1%isopen then
            close c1 ;
        end if ;
    	pa_cc_utils.log_message('Unexpected error : get_award_id: '||SQLERRM,1);
        write_to_log('GMS :get_award_id When OTHERS exception raised '||SQLCODE) ;
        write_to_log('GMS :SQLERRM '||SQLERRM) ;
        write_to_log('GMS :Parameter txn_interface_id :'||Trxrec.txn_interface_id||' award id :'||NVL(x_award_id,0)) ;
        return 0 ;
  end get_award_id ;
/* **************************************************************

  PROCEDURE PROC_FUNDS_CHECK_ENC IS
		x_err_buf			varchar2(2000) ;
		x_ret_code			varchar2(1) ;
		x_encumbrance_grp 	varchar2(15) ;
		x_packet_id			NUMBER ;

	CURSOR C_enc is
    select distinct encumbrance_id
      from gms_encumbrances
     where encumbrance_group = x_encumbrance_grp ;
  begin
  END	 PROC_FUNDS_CHECK_ENC ;
 **************************************************************/

  PROCEDURE PROC_CREATE_GROUP (p_batch_name pa_transaction_xface_control.batch_name%TYPE ) is
  l_req_id   NUMBER;    /*bug 5689213*/
  BEGIN

    if (X_status is null) then -- Record is accepted by the ValidateItem Proc.
        -- --------------------------
        -- Group Creation
        -- --------------------------
	l_req_id := FND_GLOBAL.CONC_REQUEST_ID ;  /*bug 5689213*/
        IF (FIRST_RECORD) then

                select gms_encumbrance_groups_s.nextval
                  into l_encumbrance_grp
                 from dual;

                l_org_id := TrxRec.org_id;
                l_exp_ending_date := TrxRec.expenditure_ending_date;
                l_system_linkage_fn := TrxRec.system_linkage;
		--
		-- bug : 3265300,3425124
		-- encumbrance summarize and transfer process gives 'gms_unexpected_error'
		--
		l_encumbrance_grp := SUBSTR(p_batch_name||' '||l_encumbrance_grp,1,240) ;

                gms_encumbrance_groups_pkg.insert_row (x_rowid	    => l_rowid,
                       x_encumbrance_group		    => l_encumbrance_grp,
                       x_last_update_date		    => sysdate,
                       x_last_updated_by		    => to_number(fnd_profile.value('USER_ID')),
                       x_creation_date			    => sysdate,
                       x_created_by			        => to_number(fnd_profile.value('USER_ID')),
                       x_encumbrance_group_status	=> 'RELEASED',
                       x_encumbrance_ending_date	=> TrxRec.expenditure_ending_date,
                       x_system_linkage_function	=> TrxRec.system_linkage,
                       x_control_count			    =>  NULL,
                       x_control_total_amount	    =>  NULL,
                       x_description			    =>  NULL,
                       x_last_update_login		    =>  to_number(fnd_profile.value('LOGIN_ID')),
                       x_transaction_source		    =>  P_TRANSACTION_SOURCE ,
                       x_org_id                             =>  l_org_id,
		       x_request_id                         =>  l_req_id  /*bug 5689213*/
		                                               ); -- bug : 2376730

                       FIRST_RECORD := FALSE;
                       l_gen_seq := 'Y';

        ELSIF (l_org_id <> TrxRec.org_id OR l_exp_ending_date <> TrxRec.expenditure_ending_date
                        OR  l_system_linkage_fn <> TrxRec.system_linkage ) then

			-- ---------------------------------------------------------------------
			-- CALL GMS_funds_check Routine and reject items if FUNDS_CHECK_Failed.
			-- ---------------------------------------------------------------------
			--PROC_FUNDS_CHECK_ENC ;

                        select gms_encumbrance_groups_s.nextval
                          into l_encumbrance_grp
                          from dual;

                        l_org_id := TrxRec.org_id;
                        l_exp_ending_date := TrxRec.expenditure_ending_date;
                        l_system_linkage_fn := TrxRec.system_linkage;
			--
			-- bug : 3265300,3425124
			-- encumbrance summarize and transfer process gives 'gms_unexpected_error'
			--

		        l_encumbrance_grp := SUBSTR(p_batch_name||' '||l_encumbrance_grp,1,240) ;

                        gms_encumbrance_groups_pkg.insert_row (x_rowid	    => l_rowid,
                            x_encumbrance_group		    => l_encumbrance_grp,
                            x_last_update_date		    => sysdate,
                            x_last_updated_by		    => to_number(fnd_profile.value('USER_ID')),
                            x_creation_date			    => sysdate,
                            x_created_by			        => to_number(fnd_profile.value('USER_ID')),
                            x_encumbrance_group_status	=> 'RELEASED',
                            x_encumbrance_ending_date	=> TrxRec.expenditure_ending_date,
                            x_system_linkage_function	=> TrxRec.system_linkage,
                            x_control_count			    =>  NULL,
                            x_control_total_amount	    =>  NULL,
                            x_description			    =>  NULL,
                            x_last_update_login		    =>  to_number(fnd_profile.value('LOGIN_ID')),
                            x_transaction_source		    =>  P_TRANSACTION_SOURCE ,
                            x_org_id                             =>  l_org_id,
			    x_request_id                         =>  l_req_id  /*bug 5689213*/
			                                           ); -- bug : 2376730

                       l_gen_seq := 'Y';

        END IF  ;
    END IF ;
  EXCEPTION
    WHEN OTHERS THEN
        X_SUCCESS := 'F' ;
    	pa_cc_utils.log_message('Unexpected error : PROC_CREATE_GROUP: '||SQLERRM,1);
        write_to_log('GMS :proc_create_group When OTHERS exception raised '||SQLCODE) ;
        write_to_log('GMS :SQLERRM '||SQLERRM) ;
        write_to_log('GMS :Parameter x_encumbrance_group :'||l_encumbrance_grp) ;
  END PROC_CREATE_GROUP ;

PROCEDURE PROC_VALIDATE_LOCAL (  p_raw_cost    IN NUMBER,    -- Bug 3465936
                                 p_status_code OUT NOCOPY VARCHAR2) IS
   l_bg_id       NUMBER ;
   l_temp_org_id NUMBER ;
   -- Bug 3465939  : Added following variables
   l_net_zero_adjustment_flag   VARCHAR2(1) ;
   l_orig_raw_cost                   NUMBER ;

   --Bug 3465939 : Cursor to fetch original Labor distribution
   --              encumbrance Item details.

   CURSOR  c_original_enc_exists IS
   SELECT  net_zero_adjustment_flag,amount
     FROM  gms_encumbrance_items_all gei
    WHERE  gei.transaction_source =  P_transaction_source
      AND  gei.encumbrance_item_id = l_orig_enc_item_id ;

BEGIN

   pa_cc_utils.log_message('GMS_LD_PKG.PROC_VALIDATE_LOCAL :  Start');

    -- Bug 3465936 : Added following code to validate the original_encumbrance_item_id  and
    -- to check whether liquidation of encumbrance item id is allowed

    IF l_orig_enc_item_id IS NOT NULL THEN

       pa_cc_utils.log_message('GMS_LD_PKG.PROC_VALIDATE_LOCAL :  Before vaildating the liquidated Encumbrance');

       IF l_allow_reversal_flag = 'N'  THEN
            p_status_code := 'GMS_IMP_ENC_NO_REVERSAL';
       ELSE

         OPEN  c_original_enc_exists;
         FETCH c_original_enc_exists INTO l_net_zero_adjustment_flag,l_orig_raw_cost;
         IF c_original_enc_exists%NOTFOUND THEN
            p_status_code := 'GMS_IMP_ORIG_ENC_NOT_EXISTS';
         ELSIF NVL(l_net_zero_adjustment_flag,'N') = 'Y' THEN
            p_status_code := 'GMS_IMP_ORIG_ENC_REVERSED';
         ELSIF (NVL(p_raw_cost,0)+ NVL(l_orig_raw_cost,0)) <> 0 THEN
            p_status_code := 'GMS_IMP_ORIG_AMT_MISMATCH';
         END IF;
         CLOSE c_original_enc_exists ;

       END IF;

       pa_cc_utils.log_message('GMS_LD_PKG.PROC_VALIDATE_LOCAL :  After vaildating the liquidated Encumbrance ,p_status_code : '||p_status_code);

       IF p_status_code IS NOT NULL THEN
        X_success := 'F' ;
        RETURN;
       END IF;

    END IF;

    l_bg_id  := PA_TRX_IMPORT.G_Business_Group_Id ;

    IF ((GROUP_FIRST) OR (l_employee_number <> TrxRec.employee_number)) then

            -- BUG : 3226607
	    -- Bug : 3601539 : Added parameter alias as expenditure_ending_date was getting passed
	    --                 for p_person_type parameter.
            pa_utils2.GetEmpId( P_Business_Group_Id => l_bg_id,
                                P_Employee_Number   => TrxRec.employee_number,
                                X_Employee_Id       => l_person_id,
                                P_EiDate            => TrxRec.expenditure_ending_date );
            IF ( pa_utils2.G_return_status IS NOT NULL and TrxRec.system_linkage not in ('PJ', 'USG')) THEN --Bug: 4594620
              X_status := pa_utils2.G_return_status ;
              pa_cc_utils.log_message('EXECPTION :Person  ' || TrxRec.employee_number, 1);
              pa_cc_utils.log_message('EXECPTION :Expenditure Item date ' || TrxRec.expenditure_ending_date, 1);
              pa_cc_utils.log_message('EXECPTION : Person ID validation ' || x_status);

              X_success := 'F' ;
              return ;
            END IF ;

            l_gen_seq         := 'Y';
            l_employee_number := TrxRec.employee_number;
            GROUP_FIRST       := FALSE;
    end if;

    if (    (ORG_FIRST) OR
            (l_organization_name <> nvl(TrxRec.override_to_organization_name, TrxRec.organization_name))) then

	    l_override_organization_id := NULL;
	    l_organization_id := NULL;
            l_organization_name := nvl(TrxRec.override_to_organization_name, TrxRec.organization_name);

            If (l_organization_name is NULL) then /* Bug 4901079 */
              X_success := 'F';
              p_status_code := 'PA_EXP_ORG_NOT_SPECIFIED' ;
              RETURN;
            End If;

            pa_utils.GetOrgnId(X_org_name => l_organization_name,
			       X_bg_id    => l_bg_id,
			       X_Orgn_Id  => l_temp_org_id,
			       X_Return_Status => x_status);

            If x_status is Not Null OR l_temp_org_id is NULL Then
	       X_success := 'F';
               pa_cc_utils.log_message('EXECPTION : organization_name validation ' || x_status);
	       RETURN;
	    End If;


            IF (TrxRec.override_to_organization_name is not null) then
                    l_override_organization_id := l_temp_org_id ;
            ELSE
	 	    l_organization_id          := l_temp_org_id ;
            END IF ;

            pa_cc_utils.log_message('Organization  ' || l_organization_id, 1);
            l_gen_seq := 'Y';
            ORG_FIRST := FALSE;

            select organization_id
              into l_temp_org_id
              from pa_organizations_expend_v
                   --hr_all_organization_units
             WHERE organization_id = l_temp_org_id
               and active_flag = 'Y'
               and trunc(TrxRec.expenditure_ending_date) between date_from
                   and nvl(date_to,trunc(TrxRec.expenditure_ending_date));

            X_success := 'S' ;
 end if;

 pa_cc_utils.log_message('GMS_LD_PKG.PROC_VALIDATE_LOCAL :  End');
EXCEPTION
    WHEN no_data_found THEN
         pa_cc_utils.log_message('EXECPTION :Person  ' || TrxRec.employee_number, 1);
         pa_cc_utils.log_message('EXECPTION :Override Organization  ' || TrxRec.override_to_organization_name, 1);
         pa_cc_utils.log_message('EXECPTION :Expenditure Item date ' || TrxRec.expenditure_ending_date, 1);
         pa_cc_utils.log_message('EXECPTION :Organization  ' || TrxRec.organization_name, 1);

        X_success := 'F' ;
        write_to_log('GMS :proc_validate_local When no_data_found exception raised '||SQLCODE) ;
        write_to_log('GMS :SQLERRM '||SQLERRM) ;
        write_to_log('GMS :Parameter person :'||TrxRec.employee_number) ;
        write_to_log('GMS :Parameter Override Organization :'||TrxRec.override_to_organization_name) ;
        write_to_log('GMS :Parameter Expenditure Item date :'|| TrxRec.expenditure_ending_date) ;
        write_to_log('GMS :Organization  ' || TrxRec.organization_name);

    When others then
        X_success := 'F' ;
    	pa_cc_utils.log_message('Unexpected error: PROC_VALIDATE_LOCAL: '||SQLERRM,1);
        write_to_log('GMS :proc_validate_local When OTHERS exception raised '||SQLCODE) ;
        write_to_log('GMS :SQLERRM '||SQLERRM) ;
        write_to_log('GMS :Parameter person :'||TrxRec.employee_number) ;
        write_to_log('GMS :Parameter Override Organization :'||TrxRec.override_to_organization_name) ;
        write_to_log('GMS :Parameter Expenditure Item date :'|| TrxRec.expenditure_ending_date) ;
        write_to_log('GMS :Organization  ' || TrxRec.organization_name);

END PROC_VALIDATE_LOCAL ;

  FUNCTION F_create_adls return boolean is
    x_adl_rec           gms_award_distributions%ROWTYPE ;
    x_award_id          NUMBER ;
    x_award_set_id      NUMBER ;
    X_request_id        NUMBER ;
    x_raw_cost          NUMBER;
    x_ei_id             NUMBER;
    x_project_id        NUMBER;
    X_task_id           NUMBER;
  begin
        X_raw_cost        :=  TrxRec.raw_cost ;
        X_ei_id           :=  l_enc_item_id ;
        X_project_id      :=  l_project_id;
        X_task_id         :=  l_task_id;
		x_award_id        := get_award_id ;
        X_request_id := FND_GLOBAL.CONC_REQUEST_ID ;

        IF x_award_id = 0 then
            return false ;
        end if ;
        x_award_set_id                      := GMS_AWARDS_DIST_PKG.get_award_set_id  ;
        x_adl_rec.award_set_id              := x_award_set_id ;
        X_adl_rec.adl_line_num              := 1 ;
		-- -----------------------------------------------------------
		-- BUG: 1363695 - CDL line num is missing into ADLS.
		-- -----------------------------------------------------------
		X_adl_rec.cdl_line_num				:= 1   ;

        X_adl_rec.project_id                := X_project_id ;
		X_adl_rec.document_type				:= 'ENC' ;
        X_adl_rec.task_id                   := X_task_id ;
        X_adl_rec.award_id                  := X_award_id ;
        x_adl_rec.expenditure_item_id       := x_ei_id ;
        x_adl_rec.raw_cost                  := X_raw_cost ;
        x_adl_rec.request_id                := X_request_id ;
        x_adl_rec.billed_flag               := 'N' ;
        X_adl_rec.adl_status                := 'A' ;
		X_adl_rec.line_type					:= 'R' ;
		X_adl_rec.cost_distributed_flag		:= 'N' ;
        GMS_AWARDS_DIST_PKG.create_adls(x_adl_rec) ;

        return TRUE ;
  exception
    when others then
    	pa_cc_utils.log_message('Unexpected error: F_create_adls: '||SQLERRM,1);
        write_to_log('GMS :f_create_adls When OTHERS exception raised '||SQLCODE) ;
        write_to_log('GMS :SQLERRM '||SQLERRM) ;
        write_to_log('GMS :Parameter X_ei_id :'|| l_enc_item_id) ;
        write_to_log('GMS :Parameter project_id, task_id :'||l_project_id||' , '||l_task_id) ;
        write_to_log('GMS :Parameter award_id :'|| x_award_id) ;

        return false   ;
  END F_create_adls ;

   PROCEDURE PROC_PROJECT_TASK IS
   BEGIN

       if ((PROJ_FIRST) OR (l_project_number <> TrxRec.project_number)) then
                    select project_id
                    into l_project_id
                    from pa_projects_all
                    where segment1 = TrxRec.project_number;

                    PROJ_FIRST := FALSE;
      end if;
      pa_cc_utils.log_message('Task : ' || TrxRec.task_number ||' , project id : ' || l_project_id, 1);
      PROJ_FAIL := FALSE;

      ----------------------------------------------------------------------------
      -- BUG:2389535 - Encumbrances have Identical Task Ids
      ----------------------------------------------------------------------------
      if ((TASK_FIRST) OR (l_project_number <> TrxRec.project_number) OR (l_task_number <> TrxRec.task_number)) then
                select task_id
                     into l_task_id
                    from pa_tasks
                    where task_number = TrxRec.task_number
                    and project_id = l_project_id;

                    TASK_FIRST := FALSE;
      end if;
      TASK_FAIL := FALSE;

      ----------------------------------------------------------------------------
      -- BUG:2389535 - Encumbrances have Identical Task Ids
      ----------------------------------------------------------------------------
      l_project_number := TrxRec.project_number;
      l_task_number := TrxRec.task_number;

   EXCEPTION
        when no_data_found then
	     pa_cc_utils.log_message('EXCEPTION:Project  : ' || TrxRec.project_number, 1);
             pa_cc_utils.log_message('EXCEPTION:Task  : ' || TrxRec.task_number, 1);
             x_success := 'F' ;
             write_to_log('GMS :proc_project_task When no_data_found exception raised '||SQLCODE) ;
             write_to_log('GMS :SQLERRM '||SQLERRM) ;
             write_to_log('GMS :Parameter project_number, task_number :'|| TrxRec.project_number||','||TrxRec.task_number) ;
        When others then
             x_success := 'F' ;
    	     pa_cc_utils.log_message('Unexpected error: PROC_PROJECT_TASK: '||SQLERRM,1);
             write_to_log('GMS :proc_project_task when others exception raised '||SQLCODE) ;
             write_to_log('GMS :SQLERRM '||SQLERRM) ;
             write_to_log('GMS :Parameter project_number, task_number :'|| TrxRec.project_number||','||TrxRec.task_number) ;
   END PROC_PROJECT_TASK ;

   -- Bug 3035863 : Added following procedure to validate the encumbrance transaction source.

   PROCEDURE VALIDATE_TRANSACTION_SOURCE IS
   BEGIN
     	-- Bug 3035863: The following code is added to stop further processing of
        -- encumbrance if flags not properly set .

        pa_cc_utils.log_message('GMS_LD_PKG.VALIDATE_TRANSACTION_SOURCE :  Start');
	x_status := NULL;

        pa_cc_utils.log_message('GMS_LD_PKG.VALIDATE_TRANSACTION_SOURCE : Validating transaction source '||p_transaction_source );

        IF NVL(l_gl_accted_flag ,'N') = 'Y' THEN
           x_status := 'GMS_IMP_ENC_GLACCT_FLAG';
        ELSIF NVL(l_costed_flag,'N') = 'N' THEN
           x_status := 'GMS_IMP_ENC_COSTED_FLAG';
        ELSIF NVL(l_allow_burden_flag,'N') = 'Y' THEN
           x_status := 'GMS_IMP_ENC_BURDEN_FLAG';
        END IF;

        pa_cc_utils.log_message('GMS_LD_PKG.VALIDATE_TRANSACTION_SOURCE : After validating transaction source ,Value of x_status : '||x_status );

        pa_cc_utils.log_message('GMS_LD_PKG.VALIDATE_TRANSACTION_SOURCE :  End ');

   EXCEPTION
     When others then
     	 pa_cc_utils.log_message('GMS_LD_PKG.VALIDATE_TRANSACTION_SOURCE : Unexpected error : '||SQLERRM,1);
         x_status := 'GMS_UNEXPECTED_ERROR';
   END;

   BEGIN

    -- --------------------------------------------
    -- Pre processing extension is exclusively for
    -- GOLDE transaction source
    -- --------------------------------------------
    -- Bug 3035863 : Included check to allow processing for transaction sources starting with 'GMSE'
    l_org_id    := 0;
    l_gen_seq   := 'N' ;
     FIRST_RECORD       := TRUE;
     ORG_FIRST          := TRUE;
     GROUP_FIRST        := TRUE;
     TASK_FIRST         := TRUE;
     PROJ_FIRST         := TRUE;
     x_calling_module	:= 'GMS_LD_PKG.PRE_PROCESS' ;

    IF (P_TRANSACTION_SOURCE = 'GOLDE' OR (SUBSTR(P_TRANSACTION_SOURCE,1,4) = 'GMSE')) THEN
        NULL;
     ELSE
        return ;
     END IF ;

    write_to_log('GMS :begin gms_ld_pkg.pre_process :'||P_TRANSACTION_SOURCE) ;
    write_to_log('GMS :start time gms_ld_pkg.pre_process :'||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')) ;

    open  c_trans_source ;
    fetch c_trans_source into l_emp_org_oride,l_purgeable_flag,l_allow_dup_ref_flag ,
          l_gl_accted_flag,l_allow_reversal_flag,l_costed_flag,l_allow_burden_flag; -- Bug 3035863
    close c_trans_source ;

    pa_cc_utils.log_message('GMS_LD_PKG.PRE_PROCESS : Before calling VALIDATE_TRANSACTION_SOURCE ');

    -- Bug 3035863 : Call to validate encumbrance transaction source.

    IF SUBSTR(p_transaction_source,1,4) ='GMSE'  THEN

       VALIDATE_TRANSACTION_SOURCE;

       IF  X_STATUS IS NOT NULL THEN

         UPDATE pa_transaction_interface_all
            SET transaction_rejection_code = X_status,
                interface_id = P_xface_id,
                transaction_status_code = 'R'
          WHERE transaction_status_code ='P'
            AND (transaction_source,batch_name,decode(system_linkage,'OT','ST',system_linkage)) IN
  	          (SELECT xc.transaction_source,xc.batch_name,xc.system_linkage_function
		     FROM pa_transaction_xface_control xc
                    WHERE xc.transaction_source = P_transaction_source
                      AND  xc.batch_name         = nvl(P_batch, xc.batch_name)
                      AND  xc.status             = 'PENDING');

         pa_cc_utils.log_message('GMS_LD_PKG.PRE_PROCESS : Number of records marked for failure after VALIDATE_TRANSACTION_SOURCE'||SQL%ROWCOUNT);

         dummy := lockCntrlRec( p_transaction_source,
                                p_batch ,
                                NULL );

         IF ( dummy <> 0 ) THEN
	   rollback;
           RETURN;
         END IF ;

         COMMIT;
	 RETURN;
       END IF;   --  IF  X_STATUS IS NOT NULL THEN
     END IF; -- IF SUBSTR(p_transaction_source,1,4) ='GMSE'  THEN

    /*=============================================================================================================================*/
    /* The following FND_STATS.GATHER_TABLE_STATS procedure call has been modified by VBANDARU for bug 2465932*/
    /*=============================================================================================================================*/

    /*FND_STATS.Gather_Table_Stats(ownname=>'PA',
                                  tabname =>'PA_TRANSACTION_INTERFACE_ALL',
                                  percent =>10,
                                  tmode => 'TEMPORARY');*/

      --FND_STATS.Gather_Table_Stats(ownname=>'PA',
       --                           tabname =>'PA_TRANSACTION_INTERFACE_ALL');

    x_success := 'S' ;
    FOR  eachGroup  IN  TrxBatches  LOOP

      pa_debug.G_err_Stage := 'Locking xface ctrl record';
      pa_cc_utils.log_message(pa_debug.G_err_stage||
                         'Transaction source = '||eachGroup.transaction_source
                         ||' batch= '||eachGroup.batch_name||' sys link= '||
                         eachGroup.system_linkage_function,1);


      dummy := lockCntrlRec( eachGroup.transaction_source
                           , eachGroup.batch_name
                           , eachGroup.system_linkage_function );

      IF ( dummy <> 0 ) THEN
          GOTO NEXTREC ;
      END IF ;

     pa_debug.G_err_Stage := 'Open cursor trxrecs';
     pa_cc_utils.log_message( pa_debug.G_err_Stage,1);

     IF TrxRecs%ISOPEN THEN
        CLOSE TrxRecs ;
     END IF ;

     OPEN TrxRecs( eachGroup.transaction_source
               , eachGroup.batch_name
               , eachGroup.system_linkage_function  );

     FIRST_RECORD := TRUE;
     GROUP_FIRST  := TRUE;
     ORG_FIRST    := TRUE;
     PROJ_FIRST   := TRUE;
     TASK_FIRST   := TRUE;

     x_success := 'S' ;
     l_orig_enc_item_id := NULL;
     l_net_zero_adj_flag := NULL;
     l_enc_id := NULL ; -- Bug 3220756 :Intializing the variable to NULL for every new batch processed.
                        -- As for every new batch processed a new encumbrance Id will be generated.

     <<expenditures>>
     LOOP
        BEGIN

            PROJ_FAIL := TRUE;
            TASK_FAIL := TRUE;

	    FETCH TrxRecs into TrxRec;

            SAVEPOINT SAVE_TrxREC ;

            IF ( TrxRecs%ROWCOUNT = 0 ) THEN
                pa_cc_utils.log_message('Zero Records Fetched',1);
                EXIT expenditures ;

            elsif TrxRecs%NOTFOUND then
                exit expenditures;
            end if;

           -- Bug# 4138033 Moved this code

           -- Bug 3465939 :Code to fetch liquidated encumbrance item id information
	   -- from grants transaction_interface table

           pa_cc_utils.log_message('GMS_LD_PKG.PRE_PROCESS : Fetching liquidated Encumbrance for txn interface id : '||TrxRec.txn_interface_id);

           OPEN  c_get_org_enc_item_id(TrxRec.txn_interface_id);
           FETCH c_get_org_enc_item_id INTO l_orig_enc_item_id,l_net_zero_adj_flag ;
           CLOSE c_get_org_enc_item_id;

           pa_cc_utils.log_message('GMS_LD_PKG.PRE_PROCESS : Value of l_orig_enc_item_id'||l_orig_enc_item_id);
           pa_cc_utils.log_message('GMS_LD_PKG.PRE_PROCESS : Value of l_net_zero_adj_flag'||l_net_zero_adj_flag);

           -- Bug 3465939 :Shifted the call to PROC_VALIDATE_LOCAL before encumbrance group creation

	   PROC_PROJECT_TASK ;
           IF x_success = 'F' THEN
                 write_to_log('GMS :PROC_PROJECT_TASK returned x_success False') ;
                -- --------------------
                -- ERROR
                -- --------------------

		 ROLLBACK TO SAVE_TrxREC; -- Bug 3035863 : Introduced rollback in case of failure

                 IF PROJ_FAIL THEN

		 UPDATE pa_transaction_interface_all
                    SET  transaction_rejection_code = 'INVALID_PROJECT'
                        ,       interface_id = P_xface_id
                        ,       expenditure_id = l_enc_id
                        ,       transaction_status_code = 'R'
                 WHERE current of TrxRecs ;

		 ELSIF TASK_FAIL THEN

		 UPDATE pa_transaction_interface_all
                    SET  transaction_rejection_code = 'INVALID_TASK'
                        ,       interface_id = P_xface_id
                        ,       expenditure_id = l_enc_id
                        ,       transaction_status_code = 'R'
                 WHERE current of TrxRecs ;

		 ELSE

		 UPDATE pa_transaction_interface_all
                    SET  transaction_rejection_code = 'GMS_UNEXPECTED_ERROR'
                        ,       interface_id = P_xface_id
                        ,       expenditure_id = l_enc_id
                        ,       transaction_status_code = 'R'
                 WHERE current of TrxRecs ;

                 END IF;

		-- Bug 3221039 : Commented the following update statement as gms_transaction_
		-- interface_all.transaction_status_code column is obsolete

		 /*UPDATE gms_transaction_interface_all
		    SET transaction_status_code = 'R'
		  WHERE orig_transaction_reference = TrxRec.orig_transaction_reference;*/

                 X_success := 'S' ;
                 GOTO MOVETONEXT ;
            END IF ;

           -- Bug# 4138033 End

           l_award_id := get_award_id;

           /* Bug# 4138033 */
           Validate_Dates_YN(l_award_id,
	                     l_project_id,
			     l_task_id,
			     l_orig_enc_item_id);

	    pa_cc_utils.log_message('Trying to call the validate item proc', 1);
	    l_emporg_id := NULL ;
	    l_empjob_id := NULL ;

	    IF NVL(l_emp_org_oride, 'N') = 'N' AND
	       TrxRec.person_id is NOT NULL    THEN

	       pa_utils.GetEmpOrgJobID( trxRec.person_id,
	                                trxRec.expenditure_item_date,
					l_emporg_id ,
					l_empJob_id ) ;
	    END IF ;

            PA_TRX_IMPORT.ValidateItem(      p_transaction_source
                      ,  TrxRec.employee_number
                      ,  TrxRec.organization_name
                      ,  TrxRec.expenditure_ending_date
                      ,  TrxRec.expenditure_item_date
                      ,  TrxRec.expenditure_type
                      ,  TrxRec.project_number
                      ,  TrxRec.task_number
                      ,  TrxRec.non_labor_resource
                      ,  TrxRec.non_labor_resource_org_name
                      ,  TrxRec.quantity
                      ,  TrxRec.denom_raw_cost
                      ,  x_calling_module         -- 'GMS_LD_PKG.PRE_PROCESS' calling_module is hardcoded to this.
                      ,  TrxRec.orig_transaction_reference
                      ,  TrxRec.unmatched_negative_txn_flag
                      ,  p_user_id
                      ,  TrxRec.attribute_category
                      ,  TrxRec.attribute1
                      ,  TrxRec.attribute2
                      ,  TrxRec.attribute3
                      ,  TrxRec.attribute4
                      ,  TrxRec.attribute5
                      ,  TrxRec.attribute6
                      ,  TrxRec.attribute7
                      ,  TrxRec.attribute8
                      ,  TrxRec.attribute9
                      ,  TrxRec.attribute10
                      ,  TrxRec.dr_code_combination_id
                      ,  TrxRec.cr_code_combination_id
                      ,  TrxRec.gl_date
                      ,  TrxRec.denom_burdened_cost
                      ,  TrxRec.system_linkage
                      ,  X_status
                      ,  X_bill_flag
	   	      ,  TrxRec.receipt_currency_amount
	   	      ,  TrxRec.receipt_currency_code
	   	      ,  TrxRec.receipt_exchange_rate
	   	      ,  TrxRec.denom_currency_code
	   	      ,  TrxRec.acct_rate_date
	   	      ,  TrxRec.acct_rate_type
	   	      ,  TrxRec.acct_exchange_rate
	   	      ,  TrxRec.acct_raw_cost
	   	      ,  TrxRec.acct_burdened_cost
	   	      ,  TrxRec.acct_exchange_rounding_limit
	   	      ,  TrxRec.project_currency_code
	   	      ,  TrxRec.project_rate_date
	   	      ,  TrxRec.project_rate_type
	   	      ,  TrxRec.project_exchange_rate
		      ,  TrxRec.raw_cost
		      ,  TrxRec.burdened_cost
                      ,  TrxRec.override_to_organization_name
                      ,  TrxRec.vendor_number
		      -- ---------------------------------------------
                      -- Adding 2 new parameters to the ValidateItem
                      -- Commented due to PA Patch dependency
                      -- Need to uncomment when PA patch released
		      -- BUG:1359088 - PA CBG changes.
		      -- ---------------------------------------------
		      ,  TrxRec.org_id
		      ,  TrxRec.person_business_group_name  -- Removed Null for BUSINESS_GROUP_NAME
			-- Bug 2464841 : Added parameters for 11.5 PA-J certification.
 		      ,  TrxRec.projfunc_currency_code
		      ,  TrxRec.projfunc_cost_rate_type
		      ,  TrxRec.projfunc_cost_rate_date
		      ,  TrxRec.projfunc_cost_exchange_rate
		      ,  TrxRec.project_raw_cost
		      ,  TrxRec.project_burdened_cost
		      ,  TrxRec.assignment_name
		      ,  TrxRec.work_type_name
		      ,  TrxRec.accrual_flag
		      ,  TrxRec.project_id
		      ,  TrxRec.Task_id
		      ,  TrxRec.person_id
		      ,  TrxRec.Organization_id
		      ,  TrxRec.non_labor_resource_org_id
		      ,  TrxRec.vendor_id
		      ,  TrxRec.override_to_organization_id
		      ,  TrxRec.person_business_group_id
		      ,  TrxRec.assignment_id
		      ,  TrxRec.work_type_id
		      ,  l_emporg_id
		      ,  l_empjob_id
		      ,  TrxRec.txn_interface_id
                      ,  TrxRec.po_number /* CWK */
                      ,  TrxRec.po_header_id
                      ,  TrxRec.po_line_num
                      ,  TrxRec.po_line_id
                      ,  TrxRec.person_type
                      ,  TrxRec.po_price_type    );
                        pa_cc_utils.log_message('Done calling ValidateItem....from pre-process ', 1);
			-- --------------------------------------------------
			-- INFORMATION :
			-- We do this because validate item pkg calls
			-- GetTrxSrcInfo is called for external each time
			-- we want it to be called only the 1st time.
			-- -------------------------------------------------
			x_calling_module := 'PAXTRTRX' ;

			pa_cc_utils.reset_curr_function ;
            -- gms validations for Bug:2431943
            gms_pa_api.vert_app_validate(eachGroup.transaction_source,
                                         eachGroup.batch_name,
                                         TrxRec.txn_interface_id,
                                         TrxRec.org_id,
                                         x_status);

            IF  X_STATUS IS NOT NULL THEN

	         ROLLBACK TO SAVE_TrxREC; -- Bug 3035863 : Introduced rollback in case of failure

                 UPDATE pa_transaction_interface_all
                    SET  transaction_rejection_code = X_status
                 ,       interface_id = P_xface_id
                 ,       expenditure_id = l_enc_id
                 ,       transaction_status_code = 'R'
                 WHERE CURRENT OF TrxRecs;

		-- Bug 3221039 : Commented the following update statement as gms_transaction_
		-- interface_all.transaction_status_code column is obsolete

		/* UPDATE gms_transaction_interface_all
		    SET transaction_status_code = 'R'
		  WHERE orig_transaction_reference = TrxRec.orig_transaction_reference; */

                pa_cc_utils.log_message('This  record is rejected Stage: Pre-Process ' || X_status, 1);

                GOTO MOVETONEXT ;

           end if;  -- For the accepted records

           if x_acct_currency_code is NULL then
              pa_multi_currency.init;
              x_acct_currency_code := pa_multi_currency.G_accounting_currency_code;
           end if;

           pa_cc_utils.log_message('GMS_LD_PKG.PRE_PROCESS : Before calling PROC_VALIDATE_LOCAL');

	   PROC_VALIDATE_LOCAL(TrxRec.raw_cost,x_status_code) ;

            IF x_success = 'F' THEN
                 write_to_log('GMS :PROC_VALIDATE_LOCAL returned x_success False') ;

	         ROLLBACK TO SAVE_TrxREC; -- Bug 3035863 : Introduced rollback in case of failure

                 UPDATE pa_transaction_interface_all
                    SET  transaction_rejection_code = DECODE(x_status_code ,NULL,'GMS_UNEXPECTED_ERROR',x_status_code) -- Bug 3465939
                        ,       interface_id = P_xface_id
                        ,       expenditure_id = l_enc_id
                        ,       transaction_status_code = 'R'
                 WHERE current of TrxRecs ;

		-- Bug 3221039 : Commented the following update statement as gms_transaction_
		-- interface_all.transaction_status_code column is obsolete

		 /* UPDATE gms_transaction_interface_all
		    SET transaction_status_code = 'R'
		  WHERE orig_transaction_reference = TrxRec.orig_transaction_reference; */

                 X_success := 'S' ;
                 GOTO MOVETONEXT ;
            END IF ;

           --
	   -- bug : 3265300,3425124
	   -- encumbrance summarize and transfer process gives 'gms_unexpected_error'
	   --
           PROC_CREATE_GROUP( eachGroup.batch_name ) ;

           IF x_success = 'F' THEN
                 write_to_log('GMS :PROC_CREATE_GROUP returned x_success False') ;

	         ROLLBACK TO SAVE_TrxREC; -- Bug 3035863 : Introduced rollback in case of failure

                --*******************************
                --*** ERROR
                --*** DO Something for failure ;
                --*** ****************************
                 UPDATE pa_transaction_interface_all
                    SET  transaction_rejection_code = 'GMS_UNEXPECTED_ERROR'
                        ,       interface_id = P_xface_id
                        ,       expenditure_id = l_enc_id
                        ,       transaction_status_code = 'R'
                 WHERE batch_name = P_batch ;

		-- Bug 3221039 : Commented the following update statement as gms_transaction_
		-- interface_all.transaction_status_code column is obsolete

		 /*UPDATE gms_transaction_interface_all
		    SET transaction_status_code = 'R'
		  WHERE batch_name = P_batch ; */


                 X_success := 'S' ;
                 EXIT ;
           END IF ;
            -- --------------------------
            -- Group Creation  END..
            -- --------------------------

	    -- Bug 3465939 :Shifted the call to PROC_VALIDATE_LOCAL before encumbrance group creation

	    if l_gen_seq = 'Y' then

                select gms_encumbrances_s.nextval
                into l_enc_id
                from dual;

                gms_encumbrances_pkg.insert_row (x_rowid	=> l_rowid,
                       x_encumbrance_id			     => l_enc_id,
                       x_last_update_date		     => sysdate,
                       x_last_updated_by		     => to_number(fnd_profile.value('USER_ID')),
                       x_creation_date			     => sysdate,
                       x_created_by			         => to_number(fnd_profile.value('USER_ID')),
                       x_encumbrance_status_code	 => 'APPROVED',
                       x_encumbrance_ending_date	 => TrxRec.expenditure_ending_date,
                       x_encumbrance_class_code		 => TrxRec.system_linkage, /* changed to TrxRec.system_linkage from 'ST' for bug 5035700 --'ST',*/
                       x_incurred_by_person_id		 => l_person_id,
                       x_incurred_by_organization_id => l_organization_id,
                       x_encumbrance_group		     => l_encumbrance_grp,
                       x_control_total_amount		 => NULL,
                       x_entered_by_person_id		 => NULL,
                       x_description			     => NULL,
                       x_initial_submission_date	 => sysdate,
                       x_last_update_login		     => to_number(fnd_profile.value('LOGIN_ID')),
                       x_attribute_category		     => NULL,
                       x_attribute1			         => NULL,
                       x_attribute2			         => NULL,
                       x_attribute3			         => NULL,
                       x_attribute4			         => NULL,
                       x_attribute5			         => NULL,
                       x_attribute6			         => NULL,
                       x_attribute7			         => NULL,
                       x_attribute8			         => NULL,
                       x_attribute9			         => NULL,
                       x_attribute10		         => NULL,
	                   x_denom_currency_code	     => 'USD',  -- Currency code hard coded
-- The following fix is for Bug: 1331903
--		               x_acct_currency_code	         => 'USD',  -- Currency code hard coded
		               x_acct_currency_code	         => x_acct_currency_code,
		               x_acct_rate_type	             => NULL,
		               x_acct_rate_date	             => NULL,
		               x_acct_exchange_rate	         => NULL,
                       x_orig_enc_txn_reference1 	 => NULL,
                       x_orig_enc_txn_reference2 	 => NULL,
                       x_orig_enc_txn_reference3 	 => NULL,
                       x_orig_user_enc_txn_reference => NULL,
                       x_vendor_id 			         => NULL,
                       x_org_id                      => TrxRec.org_id ); -- fix for bug : 2376730

                l_gen_seq := 'N';

            end if;

            pa_cc_utils.log_message('Project : ' || TrxRec.project_number, 1);

             -- Bug 3035863 : Added below if condition to check for duplicate flags based on
	     -- Allow_duplicate_flag value.

	     IF NVL(l_allow_dup_ref_flag,'Y') = 'N' THEN

			--CHECK for duplicates ...
			begin
				x_dummy := 0 ;
				select count(*)
				  into x_dummy
				  from gms_encumbrance_items_all gei
				 where orig_transaction_reference = trxRec.orig_transaction_reference
				   and transaction_source	  = P_TRANSACTION_SOURCE ;

		if x_dummy > 0 then

	           ROLLBACK TO SAVE_TrxREC; -- Bug 3035863 : Introduced rollback in case of failure

                   UPDATE pa_transaction_interface_all
                      SET  transaction_rejection_code = 'DUPLICATE_ITEM'
                           ,       interface_id = P_xface_id
                           ,       expenditure_id = l_enc_id
                           ,       transaction_status_code = 'R'
                   WHERE CURRENT OF TrxRecs;

		-- Bug 3221039 : Commented the following update statement as gms_transaction_
		-- interface_all.transaction_status_code column is obsolete

		 /*UPDATE gms_transaction_interface_all
		    SET transaction_status_code = 'R'
		  WHERE orig_transaction_reference = TrxRec.orig_transaction_reference
		    AND transaction_source = P_TRANSACTION_SOURCE;*/

		end if;

			exception
				when no_data_found then
					NULL ;
				WHEN others THEN
					RAISE ;
			end ;

			IF x_dummy > 0 THEN
				goto MOVETONEXT ;
			END IF ;
	    END IF;	-- Bug 3035863

            select gms_encumbrance_items_s.nextval
              into l_enc_item_id
              from dual;

            savepoint SAVE_ENC_ADL_REC ;

            /* Modified the following insert call by passing attributes instead of NULL for bug 3646187*/
            gms_encumbrance_items_pkg.insert_row (x_rowid         => l_rowid,
                       x_encumbrance_item_id          => l_enc_item_id,
                       x_last_update_date             => sysdate,
                       x_last_updated_by              => to_number(fnd_profile.value('USER_ID')),
                       x_creation_date                => sysdate,
                       x_created_by                   => to_number(fnd_profile.value('USER_ID')),
                       x_encumbrance_id               => l_enc_id,
                       x_task_id                      => l_task_id,
                       x_encumbrance_item_date        => TrxRec.expenditure_item_date,
                       x_encumbrance_type             => TrxRec.expenditure_type,
                       x_enc_distributed_flag         => 'N', -- default
                       x_amount                       => TrxRec.raw_cost,
                       x_override_to_organization_id  => l_override_organization_id,
                       x_adjusted_encumbrance_item_id => l_orig_enc_item_id, -- Bug 3465939
                       x_net_zero_adjustment_flag     => l_net_zero_adj_flag, -- Bug 3465939
                       x_transferred_from_enc_item_id => NULL,
                       x_last_update_login            => to_number(fnd_profile.value('LOGIN_ID')),
                       x_request_id                   => NULL,
                       x_attribute_category           => TrxRec.attribute_category,
                       x_attribute1                   => TrxRec.attribute1,
                       x_attribute2                   => TrxRec.attribute2,
                       x_attribute3                   => TrxRec.attribute3,
                       x_attribute4                   => TrxRec.attribute4,
                       x_attribute5                   => TrxRec.attribute5,
                       x_attribute6                   => TrxRec.attribute6,
                       x_attribute7                   => TrxRec.attribute7,
                       x_attribute8                   => TrxRec.attribute8,
                       x_attribute9                   => TrxRec.attribute9,
                       x_attribute10                  => TrxRec.attribute10,
                       x_orig_transaction_reference   => TrxRec.orig_transaction_reference,
                       x_transaction_source           => P_TRANSACTION_SOURCE,
                       x_project_id                   => l_project_id,
                       x_source_encumbrance_item_id   => NULL,
                       x_job_id                       => NULL,
                       x_system_linkage_function      => TrxRec.system_linkage,
                       x_denom_currency_code          => TrxRec.denom_currency_code,
                       x_denom_raw_amount             => TrxRec.acct_raw_cost,
                       x_acct_exchange_rounding_limit => TrxRec.acct_exchange_rounding_limit,
-- The following fix is for Bug:1331903
--                       x_acct_currency_code           => NULL,
                       x_acct_currency_code           => x_acct_currency_code,
                       x_acct_rate_date               => TrxRec.acct_rate_date,
                       x_acct_rate_type               => TrxRec.acct_rate_type,
                       x_acct_exchange_rate           => TrxRec.acct_exchange_rate,
                       x_acct_raw_cost                => TrxRec.acct_raw_cost,
                       x_project_currency_code        => TrxRec.project_currency_code,
                       x_project_rate_date            => TrxRec.project_rate_date,
                       x_project_rate_type            => TrxRec.project_rate_type,
                       x_project_exchange_rate        => TrxRec.project_exchange_rate,
                       x_denom_tp_currency_code       => NULL,
                       x_denom_transfer_price         => NULL,
                       x_encumbrance_comment          => TrxRec.expenditure_comment, --Bug#3755610
                       x_person_id                    => NULL,
                       x_incurred_by_person_id        => l_person_id,
                       x_ind_compiled_set_id          =>  NULL,
                       x_pa_date                      => NULL,
                       x_gl_date                      => NULL ,
                       x_line_num                     => 1,
                       x_burden_sum_dest_run_id       => NULL,
                       x_burden_sum_source_run_id     => NULL,
                       x_org_id                       => TrxRec.org_id ); -- fix for bug : 2376730

            pa_cc_utils.log_message('This  record validated ' || X_status, 1);

            IF f_create_adls THEN
                          UPDATE pa_transaction_interface_all
                            SET transaction_rejection_code = NULL,
                                interface_id = P_xface_id,
                                expenditure_id = l_enc_id,
                                transaction_status_code = 'A',
                                expenditure_item_id = l_enc_item_id
                          WHERE CURRENT OF TrxRecs;

		-- Bug 3221039 : Commented the following update statement as gms_transaction_
		-- interface_all.transaction_status_code column is obsolete

		 /*UPDATE gms_transaction_interface_all
		    SET transaction_status_code = 'A'
		  WHERE orig_transaction_reference = TrxRec.orig_transaction_reference
		    AND transaction_source = P_TRANSACTION_SOURCE;*/

                  -- Bug  3465939 : Updating the original encumbrance Item to Net zero.

                  UPDATE gms_encumbrance_items_all
                     SET net_zero_adjustment_flag = 'Y'
                   WHERE encumbrance_item_id = l_orig_enc_item_id;

           ELSE
                        rollback to save_enc_adl_rec ;
                        UPDATE pa_transaction_interface_all
                            SET  transaction_rejection_code = 'GMS_CREATE_ADL_FAILED'
                            ,       interface_id = P_xface_id
                            ,       expenditure_id = l_enc_id
                            ,       transaction_status_code = 'R'
                        WHERE CURRENT OF TrxRecs;

     		       -- Bug 3221039 : Commented the following update statement as gms_transaction_
       		       -- interface_all.transaction_status_code column is obsolete

		       /* UPDATE gms_transaction_interface_all
		          SET transaction_status_code = 'R'
		        WHERE orig_transaction_reference = TrxRec.orig_transaction_reference
		    	  AND transaction_source = P_TRANSACTION_SOURCE; */

           END IF ;

        <<MOVETONEXT>>
        NULL ;
    EXCEPTION
        WHEN  RESOURCE_BUSY  THEN
          pa_cc_utils.log_message('Cannot get lock',1);
          pa_cc_utils.reset_curr_function;
          write_to_log('GMS :RESOURCE_BUSY exception stage 20 ') ;
          write_to_log('GMS :SQLCODE '||SQLCODE) ;
          write_to_log('GMS :SQLERRM '||SQLERRM) ;
          raise_application_error(SQLCODE,SQLERRM) ;
        WHEN OTHERS THEN
            write_to_log('GMS :OTHERS exception stage 20 ') ;
            write_to_log('GMS :SQLCODE '||SQLCODE) ;
            write_to_log('GMS :SQLERRM '||SQLERRM) ;
            --*******************************
            --*** ERROR
            --***REJECT ITEM and continue.....
            --*** ******************************
	    ROLLBACK TO SAVE_TrxREC; -- Bug 3035863 : Introduced rollback in case of failure
            UPDATE pa_transaction_interface_all
              SET  transaction_rejection_code = 'GMS_UNEXPECTED_ERROR'
                   ,       interface_id = P_xface_id
                   ,       expenditure_id = l_enc_id
                   ,       transaction_status_code = 'R'
             WHERE CURRENT OF TrxRecs;

	    -- Bug 3221039 : Commented the following update statement as gms_transaction_
	    -- interface_all.transaction_status_code column is obsolete

	    /* UPDATE gms_transaction_interface_all
	       SET transaction_status_code = 'R'
	     WHERE orig_transaction_reference = TrxRec.orig_transaction_reference; */

          	 pa_cc_utils.log_message('Unexpected error :TrxRecs LOOP: '||SQLERRM,1);
    END ;
    end loop;  -- TrxRecs
    --end if;
    <<NEXTREC>>
    NULL ;
end loop;

--PROC_FUNDS_CHECK_ENC ;

-- Bug  3035863 : Deleting the records from Grants Transactions tables
-- based on purgeable flag.

IF NVL(l_purgeable_flag,'N')  = 'Y' THEN

     DELETE gms_transaction_interface_all
      WHERE txn_interface_id IN (SELECT txn_interface_id
                                   FROM pa_transaction_interface_all
                                  WHERE interface_id = P_XFACE_ID
                                    AND transaction_status_code ='A' );
     pa_cc_utils.log_message('GMS_LD_PKG.PRE_PROCESS : Number of success records deleted from Grants interface table :'||SQL%ROWCOUNT);

END IF ;

write_to_log('GMS :end time gms_ld_pkg.pre_process :'||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS')) ;


commit;

EXCEPTION
 WHEN  RESOURCE_BUSY  THEN
       pa_cc_utils.log_message('Cannot get lock',1);
       pa_cc_utils.reset_curr_function;
       write_to_log('GMS :RESOURCE_BUSY exception stage30 ') ;
       write_to_log('GMS :SQLCODE '||SQLCODE) ;
       write_to_log('GMS :SQLERRM '||SQLERRM) ;
       raise_application_error(SQLCODE,SQLERRM) ;
 when no_data_found then
      pa_cc_utils.log_message('No data found for some item..', 1);
      write_to_log('GMS :NO_DATA_FOUND exception stage30 ') ;
      write_to_log('GMS :SQLCODE '||SQLCODE) ;
      write_to_log('GMS :SQLERRM '||SQLERRM) ;
      raise_application_error(SQLCODE, SQLERRM) ;
      rollback ;
 when others then
      pa_cc_utils.log_message('Unexpected error: '||SQLERRM,1);
      write_to_log('GMS :OTHERS exception stage30 ') ;
      write_to_log('GMS :SQLCODE '||SQLCODE) ;
      write_to_log('GMS :SQLERRM '||SQLERRM) ;
      raise_application_error(SQLCODE, SQLERRM) ;
      rollback ;
END;

/* Bug# 4138033 */
PROCEDURE Validate_Dates_YN
             ( l_award_id1           IN gms_awards_all.award_id%TYPE,  -- Original Encumbrance Award Id
	       l_project_id1         IN pa_projects_all.project_id%TYPE, -- Original Encumbrance Project Id
	       l_task_id1            IN pa_tasks.task_id%TYPE, -- Original Encumbrance Task Id
	       l_orig_enc_item_id1   IN gms_encumbrance_items_all.encumbrance_item_id%TYPE -- Original Encumbrance Item Id
	       )  IS

    -- The following cursor is to get the maximum start date and minimum completion date
    -- out of award, project and task's start and end dates.
    CURSOR Cur_MaxMin_StartEnd_Dates IS
        SELECT max(start_date), min(completion_date)
	FROM   (   select start_date, completion_date
                   from   pa_tasks tsk1
                   where  task_id = l_task_id1
                   union all
                   select start_date, completion_date
                   from   pa_projects_all
                   where  project_id = l_project_id1
                   union all
                   select start_date_active start_date, end_date_active completion_date
                   from   gms_awards_all
                   where  award_id = l_award_id1
	        );

   l_max_start_date DATE;
   l_min_end_date   DATE;

   -- To verify if the original encumbrance item date is behind the max start date
   -- or min end date fetched in the above cursor.
   -- If this cursor returs a row, it means that the original encumbrance item is falling out of
   -- the start and end dates of any of the task/project/award.
   -- Now, we can skip the dates validation for the reversal encumbrance item which happens
   -- in the procedure PATC.Get_Status, as the original encumbrance itself falls out of the
   -- dates there is no need to do the date validation for the reversal encumbrance item.

   CURSOR Cur_Check_EncItemDate IS
       SELECT 1
       FROM   gms_encumbrance_items_all
       WHERE  encumbrance_item_id = l_orig_enc_item_id1
       AND    (encumbrance_item_date < l_max_start_date OR encumbrance_item_date > l_min_end_date);

   l_Check_EncItemDate NUMBER := 0;

BEGIN

       OPEN Cur_MaxMin_StartEnd_Dates;
       FETCH Cur_MaxMin_StartEnd_Dates INTO l_max_start_date, l_min_end_date;
       CLOSE Cur_MaxMin_StartEnd_Dates;

       OPEN Cur_Check_EncItemDate;
       FETCH Cur_Check_EncItemDate INTO l_Check_EncItemDate;
       CLOSE Cur_Check_EncItemDate;

       IF l_Check_EncItemDate = 1 THEN
         -- set the global variable so as to skip validating the dates in PATC.get_status.
          PA_TRX_IMPORT.Set_GVal_ProjTskEi_Date('N');
       ELSE
          PA_TRX_IMPORT.Set_GVal_ProjTskEi_Date('Y');
       END IF;

END Validate_Dates_YN;

END GMS_LD_PKG;

/
