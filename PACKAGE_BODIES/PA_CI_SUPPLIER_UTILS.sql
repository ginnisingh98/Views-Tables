--------------------------------------------------------
--  DDL for Package Body PA_CI_SUPPLIER_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_SUPPLIER_UTILS" as
-- $Header: PASIUTLB.pls 120.1.12010000.22 2010/06/02 10:41:40 gboomina ship $

PROCEDURE print_msg(p_msg  varchar2) IS
BEGIN
      --dbms_output.put_line('Log:'||p_msg);
      --r_debug.r_msg('Log:'||p_msg);
        PA_DEBUG.g_err_stage := p_msg;
        PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
      NULL;

END print_msg;

/** This API checks whether the record exists or not in pa_ci_supplier_details **/
FUNCTION check_trx_exists(p_ci_transaction_id in NUMBER)
    RETURN VARCHAR2 IS
        l_return_status  varchar2(1) := 'N';
BEGIN

      IF p_ci_transaction_id is NOT NULL then

        SELECT 'Y'
        INTO l_return_status
        FROM pa_ci_supplier_details
        WHERE ci_transaction_id = p_ci_transaction_id;

      ELSE
        l_return_status := 'N';
      END IF;

        return l_return_status;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return 'N';
        WHEN OTHERS THEN
                RAISE;

END check_trx_exists;

-- gboomina added for supplier cost 12.1.3 requirement - start
-- This method is used to check whether the record is unique in supplier cost
procedure is_record_unique(p_api_version            in number,
			                        p_init_msg_list          in varchar2 default fnd_api.g_false,
                    			    x_return_status          in out nocopy varchar2 ,
                      	    x_msg_data               in out nocopy varchar2,
                    			    x_msg_count              in out nocopy number,
                           p_ci_id                  in number,
                           p_task_id                in number,
	                          p_resource_list_mem_id   in number,
                           p_expenditure_type       in varchar2,
			                        p_currency_code          in varchar2,
                           p_vendor_id              in number,
                           p_expenditure_org_id     in number,
                           p_need_by_date           in date,
                           p_po_line_id             in number,
                           p_record_status          in varchar2,
                           p_ci_transaction_id      in number)
    IS
    l_return_status  varchar2(1) := 'Y';
    l_error_msg_code   varchar2(100):= null;
   	l_msg_count  number := 0;

    -- Cursor to check whether supplier record is unique if
    -- Change type is 'Create New', during SC Line create
    cursor is_supp_cost_rec_exist_cre_1 is
            select 'Y'
                from pa_ci_supplier_details
                where ci_id = p_ci_id
                and task_id = p_task_id
                and resource_list_member_id = p_resource_list_mem_id
                and expenditure_type = p_expenditure_type
                and currency_code = p_currency_code
                and change_type = 'CREATE'
                and vendor_id = p_vendor_id
                and expenditure_org_id = p_expenditure_org_id
                and need_by_date = p_need_by_date;

    -- Cursor to check whether supplier record is unique if
    -- Change type is 'Update Existing', during SC Line create
    cursor is_supp_cost_rec_exist_cre_2 is
            select 'Y'
                from pa_ci_supplier_details
                where ci_id = p_ci_id
                and task_id = p_task_id
                and resource_list_member_id = p_resource_list_mem_id
                and expenditure_type = p_expenditure_type
                and currency_code = p_currency_code
                and change_type = 'UPDATE'
                and po_line_id = p_po_line_id;

    cursor is_direct_cost_rec_exist is
            select 'Y'
                from pa_ci_direct_cost_details
                where ci_id = p_ci_id
                and task_id = p_task_id
                and resource_list_member_id = p_resource_list_mem_id
                and expenditure_type = p_expenditure_type
                and currency_code = p_currency_code;

    l_exist varchar2(1) := 'N';

    -- Cursor to check whether supplier record is unique if
    -- Change type is 'Create New' during Update SC Line
    cursor is_supp_cost_rec_exist_upd_1 is
            select 'Y'
                from pa_ci_supplier_details
                where ci_id = p_ci_id
                and task_id = p_task_id
                and resource_list_member_id = p_resource_list_mem_id
                and expenditure_type = p_expenditure_type
                and currency_code = p_currency_code
                and change_type = 'CREATE'
                and vendor_id = p_vendor_id
                and expenditure_org_id = p_expenditure_org_id
                and need_by_date = p_need_by_date
                and ci_transaction_id <> p_ci_transaction_id;

    -- Cursor to check whether supplier record is unique if
    -- Change type is 'Update Existing' during Update SC Line
    cursor is_supp_cost_rec_exist_upd_2 is
            select 'Y'
                from pa_ci_supplier_details
                where ci_id = p_ci_id
                and task_id = p_task_id
                and resource_list_member_id = p_resource_list_mem_id
                and expenditure_type = p_expenditure_type
                and currency_code = p_currency_code
                and change_type = 'UPDATE'
                and po_line_id = p_po_line_id
                and ci_transaction_id <> p_ci_transaction_id;

BEGIN

      IF p_ci_id is NOT NULL then

        if (p_record_status = 'NEW') then
          -- If the change type is 'Create New' then
          -- we need to check whether the same combination of Task,
          -- Expenditure Type, Resource, Supplier, Expenditure Org and Need by date
          -- is present in Supplier Cost
          open is_supp_cost_rec_exist_cre_1;
          fetch is_supp_cost_rec_exist_cre_1 into l_exist;
          close is_supp_cost_rec_exist_cre_1;

          if ( l_exist = 'Y') then
            l_error_msg_code := 'PA_CI_SC_REC_NOT_UNIQUE_CRE';
            raise PA_API.G_EXCEPTION_ERROR;
          else
            -- If the change type is 'Update Existing' then
            -- we need to check whether the same combination of Task,
            -- Expenditure Type, Resource, Supplier, PO number and
            -- PO Line Number is present in Supplier Cost
            open is_supp_cost_rec_exist_cre_2;
            fetch is_supp_cost_rec_exist_cre_2 into l_exist;
            close is_supp_cost_rec_exist_cre_2;
            if ( l_exist = 'Y') then
              l_error_msg_code := 'PA_CI_SC_REC_NOT_UNIQUE_UPD';
              raise PA_API.G_EXCEPTION_ERROR;
            else
              -- we need to check whether the same combination of Task,
              -- Expenditure Type and Resource is present between Supplier
              -- Cost end Direct Cost
              open is_direct_cost_rec_exist;
              fetch is_direct_cost_rec_exist into l_exist;
              close is_direct_cost_rec_exist;
              if ( l_exist = 'Y') then
                l_error_msg_code := 'PA_FIN_SAME_PLANNING_ELEMENT';
                raise PA_API.G_EXCEPTION_ERROR;
              end if;
            end if;
          end if;
        else if (p_record_status = 'CHANGED') then
          -- If the change type is 'Create New' then
          -- we need to check whether the same combination of Task,
          -- Expenditure Type, Resource, Supplier, Expenditure Org and Need by date
          -- is present in Supplier Cost
          open is_supp_cost_rec_exist_upd_1;
          fetch is_supp_cost_rec_exist_upd_1 into l_exist;
          close is_supp_cost_rec_exist_upd_1;

          if ( l_exist = 'Y') then
            l_error_msg_code := 'PA_CI_SC_REC_NOT_UNIQUE_CRE';
            raise PA_API.G_EXCEPTION_ERROR;
          else
            -- If the change type is 'Update Existing' then
            -- we need to check whether the same combination of Task,
            -- Expenditure Type, Resource, Supplier, PO number and
            -- PO Line Number is present in Supplier Cost
            open is_supp_cost_rec_exist_upd_2;
            fetch is_supp_cost_rec_exist_upd_2 into l_exist;
            close is_supp_cost_rec_exist_upd_2;
            if ( l_exist = 'Y') then
              l_error_msg_code := 'PA_CI_SC_REC_NOT_UNIQUE_UPD';
              raise PA_API.G_EXCEPTION_ERROR;
            end if;
          end if;
        end if;
        end if;

      END IF;
x_return_status := PA_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      x_msg_count := l_msg_count+1;
      x_msg_data := l_error_msg_code;
      x_return_status := PA_API.G_RET_STS_ERROR;
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_msg_count := l_msg_count+1;
      x_msg_data := l_error_msg_code;
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_msg_count := l_msg_count+1;
      x_msg_data := l_error_msg_code||sqlerrm;
      x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;

END is_record_unique;
-- gboomina added for supplier cost 12.1.3 requirement - end

/** This api validates the supplier impact records and populates id for name **/
PROCEDURE validate_SI_record(
	 p_RECORD_STATUS               IN  VARCHAR2
        ,p_CI_ID                       IN  NUMBER
        ,P_CALLING_MODE                IN  VARCHAR2
        ,P_CI_STATUS                   IN  VARCHAR2
        ,P_ORG_ID                      IN  VARCHAR2
        ,x_VENDOR_ID                   IN  OUT NOCOPY  NUMBER
        ,p_VENDOR_NAME                 IN   VARCHAR2
        ,x_PO_HEADER_ID                IN  OUT NOCOPY NUMBER
        ,p_PO_NUMBER                   IN  VARCHAR2
        ,x_PO_LINE_ID                  IN  OUT NOCOPY  NUMBER
        ,p_PO_LINE_NUM                 IN  NUMBER
        ,p_ADJUSTED_TRANSACTION_ID     IN   NUMBER
        ,p_CURRENCY_CODE               IN   VARCHAR2
        ,p_CHANGE_AMOUNT               IN   NUMBER
        ,p_CHANGE_TYPE                 IN   VARCHAR2
        ,p_CHANGE_DESCRIPTION          IN   VARCHAR2
		,p_Task_Id                   IN VARCHAR2
					 ,p_Resource_List_Mem_Id      IN VARCHAR2
					 ,p_From_Date                 IN VARCHAR2
					 ,p_To_Date                   IN VARCHAR2
					 ,p_Estimated_Cost            IN VARCHAR2
					 ,p_Quoted_Cost               IN VARCHAR2
					 ,p_Negotiated_Cost           IN VARCHAR2
					 ,p_Burdened_cost             IN VARCHAR2
					 ,p_revenue_override_rate      IN varchar2
        ,p_audit_history_number      in number
        ,p_current_audit_flag        in varchar2
        ,p_Original_supp_trans_id       in number
        ,p_Source_supp_trans_id         in number
		,p_Sup_ref_no                in number
		,p_version_type                in varchar2 default 'ALL'
	      ,p_ci_transaction_id         IN   NUMBER
        ,x_return_status             OUT NOCOPY  VARCHAR2
        ,x_error_msg_code            OUT NOCOPY  VARCHAR2 ) IS

	return_error  EXCEPTION;
	l_error_msg  varchar2(1000) := NULL;
	l_return_status VARCHAR2(10) := 'S';
	l_vendor_id   NUMBER;
	l_po_header_id NUMBER;
	l_po_line_id   NUMBER;
	l_change_type  VARCHAR2(100);
	l_currency_code VARCHAR2(100);
	l_debug_mode    varchar2(1) := 'N';
  l_task_id    number;

	PROCEDURE validate_supplier(l_error_msg OUT NOCOPY varchar2) IS
		cursor cur_ven is
		SELECT vendor_id
		FROM po_vendors
		WHERE vendor_name = p_vendor_name;
	BEGIN
		If p_record_status in ('NEW','CHANGED') Then
			If l_debug_mode = 'Y' Then
				print_msg('inside validate_supplier api');
			End If;
			If p_vendor_name is NULL then
				l_error_msg := 'PA_CISI_SUPPLIER_NULL';
			Else
				OPEN cur_ven;
				FETCH cur_ven INTO l_vendor_id;
				IF cur_ven%NOTFOUND then

					l_error_msg := 'PA_CISI_SUPPLIER_INVALID';
			        END IF;
				CLOSE cur_ven;
				x_vendor_id := l_vendor_id;
			End If;
		End If;
	EXCEPTION
		WHEN OTHERS THEN
			l_error_msg := sqlcode||sqlerrm;
			Raise;

	END validate_supplier;

	PROCEDURE validate_PO(c_vendor_id   number,l_error_msg  OUT NOCOPY varchar2) IS
		cursor cur_po is
		SELECT po.po_header_id
		FROM po_headers_all po
		WHERE po.segment1 = p_po_number
		AND   po.vendor_id = c_vendor_id
		/* added this condition to cehck Po status is OPEN or APPRVOED */
                AND   NVL(po.closed_code,'XX') NOT in ('FINALLY CLOSED','CLOSED')
                AND   (( po.org_id = p_org_id
                         AND p_org_id is NOT NULL )
                       OR p_org_id is NULL
                      );
	BEGIN
		If l_debug_mode = 'Y' Then
			print_msg('insdie validate_PO api c_vendor_id['||c_vendor_id||']');
		End If;
		If p_change_type is NOT NULL and p_change_type = 'CREATE'
		   and p_po_number is NOT NULL then
		       l_error_msg := 'PA_CISI_INVALID_PO_CHANGE';
		Elsif p_change_type = 'UPDATE' and p_po_number is NOT NULL and p_org_id is NOT NULL then
		   OPEN cur_po;
		   FETCH cur_po INTO l_po_header_id;
		   IF cur_po%NOTFOUND THEN
			l_error_msg := 'PA_CISI_INVALID_PO';
		   Else
			x_po_header_id := l_po_header_id;
		   End If;
		   CLOSE cur_po;
                Elsif p_change_type = 'UPDATE' and p_po_number is NOT NULL and p_org_id is NULL then
                   OPEN cur_po;
                   FETCH cur_po INTO l_po_header_id;
                   IF cur_po%NOTFOUND THEN
                        l_error_msg := 'PA_CISI_INVALID_PO';
                   Else
			if cur_po%Rowcount > 1 then
                           l_error_msg := 'PA_CISI_PO_EXISTS';
                        Else
                           x_po_header_id := l_po_header_id;
			End If;
                   End If;
		   CLOSE cur_po;
		End If;

	EXCEPTION
		WHEN OTHERS THEN
			l_error_msg := sqlcode||sqlerrm;
			Raise;

	END validate_PO;

	PROCEDURE validate_PO_line(c_po_header_id number,c_po_line_num number
				  ,l_error_msg OUT NOCOPY varchar2) IS
		cursor cur_po_line is
		SELECT pol.po_line_id
		FROM po_lines_all pol
		    ,po_headers_all poh
		WHERE pol.po_header_id = poh.po_header_id
		AND   poh.po_header_id = c_po_header_id
		AND   pol.line_num = c_po_line_num
		/* added this condition to cehck Po status is OPEN or APPRVOED */
		AND   NVL(poh.closed_code,'XX') NOT in ('FINALLY CLOSED','CLOSED');

	BEGIN
		If l_debug_mode = 'Y' Then
		     print_msg('inside validate_PO_line api HeaderId['||c_po_header_id||
                          ']c_po_line_num['||c_po_line_num||']');
		End If;
		IF c_po_header_id is NOT NULL then
		     If c_po_line_num is NULL then
			l_error_msg := 'PA_CISI_POLINE_NULL';
		     Else
			OPEN cur_po_line;
			FETCH cur_po_line INTO l_po_line_id;
			IF cur_po_line%NOTFOUND then
				l_error_msg := 'PA_CISI_INVALID_POLINE'; /*Bug fix : 2634057 */
			Else
				x_po_line_id := l_po_line_id;
			End If;
			CLOSE cur_po_line;
		     End if;
		End If;
	EXCEPTION
		WHEN OTHERS THEN
			l_error_msg := SQLCODE||SQLERRM;
			raise;

	END validate_PO_line;

	PROCEDURE Validate_change_type(l_error_msg OUT NOCOPY varchar2) IS
	BEGIN
		If l_debug_mode = 'Y' Then
			print_msg('inside Validate_change_type api');
		End If;
		If p_change_type is NULL then
		   --Changes for new supplier region
			l_error_msg := 'PA_CISI_CHANGE_TYPE_NULL';

            /*    ElsIf p_po_number is null and p_PO_LINE_NUM is null AND p_change_type = 'UPDATE' then
                        l_error_msg := 'PA_CISI_INVALID_CHANGE_TYPE';
                Elsif p_po_number is null and p_PO_LINE_NUM is NOT Null AND p_change_type = 'UPDATE' then
                        l_error_msg := 'PA_CISI_INVALID_PO';
                Elsif p_po_number is NOT Null and p_PO_LINE_NUM is Null AND p_change_type = 'UPDATE' then
                        l_error_msg := 'PA_CISI_POLINE_NULL';
                Elsif (p_po_number is NOT Null OR  p_PO_LINE_NUM is NOT Null)  AND p_change_type = 'CREATE' then
                        l_error_msg := 'PA_CISI_INVALID_CHANGE_TYPE'; */
                End if;

	END Validate_change_type;

	PROCEDURE Validate_Currency(c_po_header_id  number,l_error_msg OUT NOCOPY varchar2) IS
		cursor cur_po_currency IS
		SELECT po.currency_code
		FROM po_headers_all po
		WHERE po.po_header_id = c_po_header_id
		AND   po.currency_code = p_currency_code;

		cursor cur_currency is
		SELECT currency_code
		FROM fnd_currencies -- Modified for Bug 4403203.
		WHERE enabled_flag = 'Y'
		AND  trunc(sysdate) between nvl(start_date_active,trunc(sysdate))
		and nvl(end_date_active,trunc(sysdate))
                AND currency_code = p_currency_code;
	BEGIN
		If l_debug_mode = 'Y' Then
			print_msg('inside Validate_Currency api['||c_po_header_id||']');
		End If;
		If p_currency_code is NULL and p_vendor_name is NOT NULL then
			l_error_msg := 'PA_CISI_CURRENCY_NULL';

		ElsIf c_po_header_id is NOT NULL then
		  	OPEN cur_po_currency;
			FETCH cur_po_currency INTO l_currency_code;
			IF cur_po_currency%NOTFOUND THEN
				l_error_msg := 'PA_CISI_INVALID_CURRENCY';
			End If;
			CLOSE cur_po_currency;
		Else
			OPEN cur_currency;
			FETCH cur_currency INTO l_currency_code;
			IF cur_currency%NOTFOUND THEN
				l_error_msg := 'PA_CISI_INVALID_CURRENCY';
			End if;
			CLOSE cur_currency;
		End if;
	EXCEPTION
		WHEN OTHERS THEN
			l_error_msg := sqlcode||sqlerrm;

	END Validate_Currency;

        PROCEDURE Validate_changeamt Is

	BEGIN
		If l_debug_mode = 'Y' Then
			print_msg('inside Validate_changeamt');
		End If;
		/** this condition is commented out as -ve amt should be allowed for SI impact
		if p_change_amount < 0 then
			l_error_msg := 'PA_CISI_NEG_AMT';
		Els  **/
                if p_change_amount is NULL then
			l_error_msg := 'PA_CISI_CHANGEAMT_NULL';
		End if;


	END Validate_changeamt ;


BEGIN
   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');
--x_PO_HEADER_ID := 44878;
   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

	/** reset the return status and error msg code **/
	x_return_status := 'S';
	x_error_msg_code := NULL;
	l_error_msg := null;


	/** VALIDATE SUPPLIER NAME **/
	validate_supplier(l_error_msg);
	If l_error_msg is NOT NULL then
		Raise return_error;
	End If;

       validate_change_type(l_error_msg);
        If l_error_msg is NOT NULL then
                Raise return_error;
        End If;

	validate_PO(x_vendor_id,l_error_msg);
        If l_error_msg is NOT NULL then
                Raise return_error;
        End If;

	if 	(p_po_line_num is not null) then
	validate_PO_line(x_po_header_id,p_po_line_num,l_error_msg);
        If l_error_msg is NOT NULL then
                Raise return_error;
        End If;
	end if;

	validate_currency(x_po_header_id,l_error_msg);
        If l_error_msg is NOT NULL then
                Raise return_error;
        End If;

	Validate_changeamt;
        If l_error_msg is NOT NULL then
                Raise return_error;
        End If;

EXCEPTION
	WHEN return_error then
		x_return_status := 'E';
		x_error_msg_code := l_error_msg;
		If l_debug_mode = 'Y' Then
			print_msg('errmsg='||l_error_msg);
		End If;
		Return;
        when others then
                x_return_status := 'U';
                x_error_msg_code := sqlcode||sqlerrm;
                Raise;

END validate_SI_record;


/** This is called from Supplier Impact UI scrren this is a wrapper api which in turn
 ** calls validate SI record for each single record
 **/
PROCEDURE validate_insert_SI (
         p_ROWID                       IN  OUT NOCOPY PA_VC_1000_150
        ,p_RECORD_STATUS               IN  PA_VC_1000_150
        ,p_CI_ID                       IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_CI_TYPE_ID                  IN  PA_VC_1000_150
        ,p_CI_IMPACT_ID                IN  PA_VC_1000_150
        ,P_CALLING_MODE                IN  VARCHAR2
        ,P_CI_STATUS                   IN  PA_VC_1000_150
        ,P_ORG_ID                      IN  PA_VC_1000_150
        ,x_VENDOR_ID                   IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_VENDOR_NAME                 IN  PA_VC_1000_150
        ,x_PO_HEADER_ID                IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_PO_NUMBER                   IN  PA_VC_1000_150
        ,x_PO_LINE_ID                  IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_PO_LINE_NUM                 IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_ADJUSTED_TRANSACTION_ID     IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_CURRENCY_CODE               IN  PA_VC_1000_150
        ,p_CHANGE_AMOUNT               IN  PA_VC_1000_150  --PA_VC_1000_NUM
        ,p_CHANGE_TYPE                 IN  PA_VC_1000_150
        ,p_CHANGE_DESCRIPTION          IN  PA_VC_1000_150
		,p_Task_Id                   IN PA_VC_1000_150
        ,p_Resource_List_Mem_Id      IN PA_VC_1000_150
		,p_From_Date                 IN PA_VC_1000_150
		,p_To_Date                   IN PA_VC_1000_150
		,p_Estimated_Cost            IN PA_VC_1000_150
		,p_Quoted_Cost               IN PA_VC_1000_150
		,p_Negotiated_Cost           IN PA_VC_1000_150
        ,p_Burdened_cost             IN PA_VC_1000_150
        ,p_revenue_override_rate      IN PA_VC_1000_150
        ,p_audit_history_number        in number
        ,p_current_audit_flag          in varchar2
        ,p_Original_supp_trans_id              in number
        ,p_Source_supp_trans_id                in number
		,p_Sup_ref_no                in number
		,p_version_type                in varchar2 default 'ALL'
        -- gboomina modified for supplier cost 12.1.3 requirement - start
        ,p_expenditure_type            in varchar2
        ,p_expenditure_org_id          in number
        ,p_change_reason_code          in varchar2
        ,p_quote_negotiation_reference in varchar2
        ,p_need_by_date                in varchar2
        -- gboomina modified for supplier cost 12.1.3 requirement - end
        ,p_ci_transaction_id           IN  OUT NOCOPY PA_VC_1000_150
        ,p_RECORD_ID                   IN  OUT NOCOPY PA_VC_1000_150
        ,p_REC_RETURN_STATUS           IN  OUT NOCOPY PA_VC_1000_150
        ,x_return_status               IN  OUT NOCOPY VARCHAR2
        ,x_msg_data                    IN  OUT NOCOPY VARCHAR2
        ,x_msg_count                   IN  OUT NOCOPY NUMBER
           ) IS

	l_error_msg_code   varchar2(100):= null;
	l_rec_count        number := 0;
	l_counter number := 0;
	l_msg_count  number := 0;

	l_vendor_id    		pa_plsql_datatypes.IdTabTyp;
	l_po_header_id 		pa_plsql_datatypes.IdTabTyp;
	l_po_line_id		pa_plsql_datatypes.IdTabTyp;
	l_return_status         pa_plsql_datatypes.char50TabTyp;
	l_rowid			pa_plsql_datatypes.char150TabTyp;
        l_ci_transaction_id   pa_plsql_datatypes.IdTabTyp;

	l_debug_mode           varchar2(1) := 'N';



BEGIN
   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       -- initialize the error stack
       PA_DEBUG.init_err_stack('PA_CI_SUPPLIER_UTILS.validate_insert_SI');

        /** clear the message stack **/
        fnd_msg_pub.INITIALIZE;

	l_rec_count := p_RECORD_STATUS.count();

	/** Initialize plsql tables **/
	l_vendor_id.delete;
        l_po_header_id.delete;
	l_po_line_id.delete;
	l_return_status.delete;
	l_rowid.delete;
        l_ci_transaction_id.delete;


	IF (p_calling_mode = 'VALIDATEANDINSERT') then

	    FOR i in 1 .. l_rec_count LOOP

		/** print the inpput params **/
		If l_debug_mode = 'Y' THEN
		print_msg('p_RECORD_STATUS['||p_RECORD_STATUS(i)||']p_CI_ID['||p_CI_ID(i)||
			 ']P_CI_STATUS['||P_CI_STATUS(i)||']p_VENDOR_NAME['||p_VENDOR_NAME(i)||
			 ']p_PO_NUMBER['||p_PO_NUMBER(i)||']p_PO_LINE_NUM['||p_PO_LINE_NUM(i)||']p_CURRENCY_CODE['||
			 p_CURRENCY_CODE(i)||']p_CHANGE_AMOUNT['||p_CHANGE_AMOUNT(i)||']p_CHANGE_TYPE['||p_CHANGE_TYPE(i)||
			']p_CHANGE_DESCRIPTION['||p_CHANGE_DESCRIPTION(i)||']p_rowid['||p_rowid(i)||
			']p_ci_transaction_id['||p_ci_transaction_id(i)||']'  );
		End If;


		l_error_msg_code :=  NULL;
		l_vendor_id(i) := null;
		l_po_header_id(i) := null;
		l_po_line_id(i) := null;
		l_return_status(i) := 'S';
		l_rowid(i) := p_rowid(i);
                l_ci_transaction_id(i) := p_ci_transaction_id(i);
		p_REC_RETURN_STATUS(i) := 'S';
		If l_debug_mode = 'Y' THEN
			print_msg('calling validate_SI_record');
		End If;

		validate_SI_record(
         		p_RECORD_STATUS                => p_RECORD_STATUS(i)
        		,p_CI_ID                	=> p_CI_ID(i)
        		,P_CALLING_MODE                => 'VALIDATE'
        		,P_CI_STATUS            	=> P_CI_STATUS(i)
        		,P_ORG_ID                      => p_org_id(i)  /* Bug fix fnd_profile.value('ORG_ID') */
        		,x_VENDOR_ID                   => l_vendor_id(i)
        		,p_VENDOR_NAME                 => p_VENDOR_NAME(i)
        		,x_PO_HEADER_ID                => l_po_header_id(i)
        		,p_PO_NUMBER                   => p_PO_NUMBER(i)
        		,x_PO_LINE_ID                  => l_po_line_id(i)
        		,p_PO_LINE_NUM                 => p_PO_LINE_NUM(i)
        		,p_ADJUSTED_TRANSACTION_ID     => p_ADJUSTED_TRANSACTION_ID(i)
        		,p_CURRENCY_CODE               => p_CURRENCY_CODE(i)
        		,p_CHANGE_AMOUNT               => p_CHANGE_AMOUNT(i)
        		,p_CHANGE_TYPE                 => p_CHANGE_TYPE(i)
        		,p_CHANGE_DESCRIPTION          => p_CHANGE_DESCRIPTION(i)
				,p_Task_Id                     => p_Task_Id(i)
                ,p_Resource_List_Mem_Id        => p_Resource_List_Mem_Id(i)
		        ,p_From_Date                   => p_From_Date(i)
		        ,p_To_Date                     => p_To_Date(i)
		        ,p_Estimated_Cost              => p_Estimated_Cost(i)
		        ,p_Quoted_Cost                 => p_Quoted_Cost(i)
		        ,p_Negotiated_Cost             => p_Negotiated_Cost(i)
				,p_Burdened_cost               => p_Burdened_cost(i)
				,p_revenue_override_rate        => p_revenue_override_rate(i)
           		,p_audit_history_number        => p_audit_history_number
                ,p_current_audit_flag          => p_current_audit_flag
                ,p_Original_supp_trans_id      => p_Original_supp_trans_id
                ,p_Source_supp_trans_id        => p_Source_supp_trans_id
				,p_Sup_ref_no                  => p_Sup_ref_no
			    ,p_ci_transaction_id           => l_ci_transaction_id(i)
        		,x_return_status               => l_return_status(i)
        		,x_error_msg_code              => l_error_msg_code );

		/** depending on return status and record status call the appropriate table handler api **/

		If l_return_status(i) = 'S' and nvl(l_error_msg_code,'X') = 'X' then

			If p_RECORD_STATUS(i) = 'NEW' then
				If l_debug_mode = 'Y' THEN
					print_msg('calling insert_row api');
				End If;
				PA_CI_SUPPLIER_PKG.insert_row (
        				x_rowid                   => l_rowid(i)
        				,x_ci_transaction_id      => l_ci_transaction_id(i)
        				,p_CI_TYPE_ID             => p_ci_type_id(i)
        				,p_CI_ID           	  => p_CI_ID(i)
        				,p_CI_IMPACT_ID           => p_ci_impact_id(i)
        				,p_VENDOR_ID              => l_vendor_id(i)
        				,p_PO_HEADER_ID           => l_po_header_id(i)
        				,p_PO_LINE_ID             => l_po_line_id(i)
        				,p_ADJUSTED_TRANSACTION_ID => p_ADJUSTED_TRANSACTION_ID(i)
        				,p_CURRENCY_CODE           => p_CURRENCY_CODE(i)
        				,p_CHANGE_AMOUNT           => p_CHANGE_AMOUNT(i)
        				,p_CHANGE_TYPE             => p_CHANGE_TYPE(i)
        				,p_CHANGE_DESCRIPTION      => p_CHANGE_DESCRIPTION(i)
        				,p_CREATED_BY              => FND_GLOBAL.login_id
        				,p_CREATION_DATE           => trunc(sysdate)
        				,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
        				,p_LAST_UPDATE_DATE        => trunc(sysdate)
        				,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
						,p_Task_Id                 => p_Task_Id(i)
		                ,p_Resource_List_Mem_Id    => p_Resource_List_Mem_Id(i)
		                ,p_From_Date               => p_From_Date(i)
		                ,p_To_Date                 => p_To_Date(i)
		                ,p_Estimated_Cost          => p_Estimated_Cost(i)
		                ,p_Quoted_Cost             => p_Quoted_Cost(i)
		                ,p_Negotiated_Cost         => p_Negotiated_Cost(i)
						,p_Burdened_cost           => p_Burdened_cost(i)
						,p_Revenue                 => null
						,p_revenue_override_rate    => p_revenue_override_rate(i)
                        ,p_audit_history_number    => p_audit_history_number
                        ,p_current_audit_flag      => 'Y'
                        ,p_Original_supp_trans_id        => p_Original_supp_trans_id
                        ,p_Source_supp_trans_id          => p_Source_supp_trans_id
					    ,p_Sup_ref_no               => p_Sup_ref_no
						,p_version_type            => p_version_type
            -- gboomina modified for supplier cost 12.1.3 requirement - start
            ,p_expenditure_type            => p_expenditure_type
            ,p_expenditure_org_id          => p_expenditure_org_id
            ,p_change_reason_code          => p_change_reason_code
            ,p_quote_negotiation_reference => p_quote_negotiation_reference
            ,p_need_by_date                => p_need_by_date
            -- gboomina modified for supplier cost 12.1.3 requirement - end
        				,x_return_status           => l_return_status(i)
        				,x_error_msg_code          => l_error_msg_code  );

				If l_return_status(i) = 'S' then
					p_ci_transaction_id(i) := l_ci_transaction_id(i);
					p_rowid(i) := l_rowid(i);
					If l_debug_mode = 'Y' THEN
						print_msg('Assigning citransactionid ='||p_ci_transaction_id(i));
					End If;
				End if;
				If l_debug_mode = 'Y' THEN
					print_msg('end of insert row api');
				End If;


			Elsif p_RECORD_STATUS(i) = 'CHANGED' then
				If l_debug_mode = 'Y' THEN
					print_msg('calling update row api');
				End If;
                                PA_CI_SUPPLIER_PKG.update_row (
                                        p_rowid                   => l_rowid(i)
                                        ,p_ci_transaction_id      => l_ci_transaction_id(i)
                                        ,p_CI_TYPE_ID             => p_ci_type_id(i)
                                        ,p_CI_ID           	  => p_CI_ID(i)
                                        ,p_CI_IMPACT_ID           => p_ci_impact_id(i)
                                        ,p_VENDOR_ID              => l_vendor_id(i)
                                        ,p_PO_HEADER_ID           => l_po_header_id(i)
                                        ,p_PO_LINE_ID             => l_po_line_id(i)
                                        ,p_ADJUSTED_TRANSACTION_ID => p_ADJUSTED_TRANSACTION_ID(i)
                                        ,p_CURRENCY_CODE           => p_CURRENCY_CODE(i)
                                        ,p_CHANGE_AMOUNT           => p_CHANGE_AMOUNT(i)
                                        ,p_CHANGE_TYPE             => p_CHANGE_TYPE(i)
                                        ,p_CHANGE_DESCRIPTION      => p_CHANGE_DESCRIPTION(i)
                                        ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
                                        ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                                        ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
										,p_Task_Id                 => p_Task_Id(i)
		                ,p_Resource_List_Mem_Id    => p_Resource_List_Mem_Id(i)
		                ,p_From_Date               => p_From_Date(i)
		                ,p_To_Date                 => p_To_Date(i)
		                ,p_Estimated_Cost          => p_Estimated_Cost(i)
		                ,p_Quoted_Cost             => p_Quoted_Cost(i)
		                ,p_Negotiated_Cost         => p_Negotiated_Cost(i)
						,p_Burdened_cost           => p_Burdened_cost(i)
						,p_Revenue                 => null
						,p_revenue_override_rate    => p_revenue_override_rate(i)
                                        ,p_audit_history_number  => p_audit_history_number
                    ,p_current_audit_flag    => p_current_audit_flag
                    ,p_Original_supp_trans_id        => p_Original_supp_trans_id
                    ,p_Source_supp_trans_id          => p_Source_supp_trans_id
					                              ,p_ci_status               => p_Sup_ref_no
                                        -- gboomina modified for supplier cost 12.1.3 requirement - start
                                        ,p_expenditure_type            => p_expenditure_type
                                        ,p_expenditure_org_id          => p_expenditure_org_id
                                        ,p_change_reason_code          => p_change_reason_code
                                        ,p_quote_negotiation_reference => p_quote_negotiation_reference
                                        ,p_need_by_date                => p_need_by_date
                                        -- gboomina modified for supplier cost 12.1.3 requirement - end
                                        ,x_return_status           => l_return_status(i)
                                        ,x_error_msg_code          => l_error_msg_code );
				If l_debug_mode = 'Y' THEN
					print_msg('end of update row api');
				End If;

			End if;

		End if;

		If l_return_status(i) <> 'S' and nvl(l_error_msg_code,'X') <> 'X' then
			If l_debug_mode = 'Y' THEN
				print_msg('adding error msg to stack'||l_error_msg_code);
			End If;

		       p_REC_RETURN_STATUS(i) := 'E';
		       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                             ,p_msg_name  =>l_error_msg_code
					   );
			l_msg_count := l_msg_count +1;

		End if;


	    END LOOP;

	   If l_msg_count = 1 then
		x_return_status := 'E';
		x_msg_count := l_msg_count;
		x_msg_data := l_error_msg_code;
	   Elsif l_msg_count > 1 then
                x_return_status := 'E';
                x_msg_count := l_msg_count;
                x_msg_data := null;
	   End if;


	END IF;

        pa_debug.reset_err_stack;
EXCEPTION
     when others then
		x_return_status := 'U';
		x_msg_count := 1;
		x_msg_data := SQLCODE||SQLERRM;
        	pa_debug.reset_err_stack;
		RAISE;

END validate_insert_SI;

PROCEDURE validateSI(p_ROWID                      IN OUT NOCOPY VARCHAR2
                     ,p_RECORD_STATUS             IN VARCHAR2
                     ,p_CI_ID                     IN VARCHAR2
                     ,p_CI_TYPE_ID                IN VARCHAR2
                     ,p_CI_IMPACT_ID              IN VARCHAR2
                     ,P_CALLING_MODE              IN VARCHAR2
                     ,P_ORG_ID                    IN VARCHAR2
                     ,p_VENDOR_NAME               IN VARCHAR2
                     ,p_PO_NUMBER                 IN VARCHAR2
                     ,p_PO_LINE_NUM               IN VARCHAR2
                     ,p_ADJUSTED_TRANSACTION_ID   IN VARCHAR2
                     ,p_CURRENCY_CODE             IN VARCHAR2
                     ,p_CHANGE_AMOUNT             IN VARCHAR2
                     ,p_CHANGE_TYPE               IN VARCHAR2
                     ,p_CHANGE_DESCRIPTION        IN VARCHAR2
                     ,p_Task_Id                   IN VARCHAR2
					 ,p_Resource_List_Mem_Id      IN VARCHAR2
					 ,p_From_Date                 IN VARCHAR2
					 ,p_To_Date                   IN VARCHAR2
					 ,p_Estimated_Cost            IN VARCHAR2
					 ,p_Quoted_Cost               IN VARCHAR2
					 ,p_Negotiated_Cost           IN VARCHAR2
					 ,p_Burdened_cost             IN VARCHAR2
					 ,p_Revenue                   IN VARCHAR2 default NULL
					 ,p_revenue_override_rate     IN varchar2
					 ,p_audit_history_number      in number
                     ,p_current_audit_flag        in varchar2
                     ,p_Original_supp_trans_id    in number
                     ,p_Source_supp_trans_id      in number
					 ,p_Sup_ref_no                in number default null
					 ,p_version_type              in varchar2 default 'ALL'
                     -- gboomina modified for supplier cost 12.1.3 requirement - start
                     ,p_expenditure_type            in varchar2
                     ,p_expenditure_org_id          in number
                     ,p_change_reason_code          in varchar2
                     ,p_quote_negotiation_reference in varchar2
                     ,p_need_by_date                in varchar2
                     -- gboomina modified for supplier cost 12.1.3 requirement - end
                     ,p_CI_TRANSACTION_ID         IN OUT NOCOPY VARCHAR2
                     ,x_return_status             IN OUT NOCOPY VARCHAR2
                     ,x_msg_data                  IN OUT NOCOPY VARCHAR2
                     ,x_msg_count                 IN OUT NOCOPY NUMBER
		    ) IS

		l_CI_STATUS  varchar2(10);
                l_error_msg_code     varchar2(1000);
                l_vendor_id          number ;
                l_po_header_id       number;
                l_po_line_id         number;
                l_return_status      varchar2(1) :=  'S';
                l_rowid              varchar2(100) := p_rowid;
                l_ci_transaction_id  number :=  p_ci_transaction_id;
		l_msg_count  number := 0;
		l_msg_index_out number := 0;
		l_ci_impact_id       number;
		l_debug_mode           varchar2(1) := 'N';
		cursor cur_impact_id IS
		SELECT ci_impact_id
		FROM pa_ci_impacts pci
		WHERE pci.ci_id = p_ci_id
		AND   pci.IMPACT_TYPE_CODE = 'SUPPLIER';



BEGIN
   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       -- initialize the error stack
       PA_DEBUG.init_err_stack('PA_CI_SUPPLIER_UTILS.validateSI');

        /** clear the message stack **/
        fnd_msg_pub.INITIALIZE;

        IF (p_calling_mode = 'VALIDATEANDINSERT') then

                /** print the inpput params **/
		IF l_debug_mode = 'Y' THEN
                print_msg('p_RECORD_STATUS['||p_RECORD_STATUS||']p_CI_ID['||p_CI_ID||
                         ']p_VENDOR_NAME['||p_VENDOR_NAME||
                          -- gboomina addded for 12.1.3 supplier cost requirement
                          ']EXPENDITURE_TYPE['||p_expenditure_type||
                         ']p_PO_NUMBER['||p_PO_NUMBER||']p_PO_LINE_NUM['||p_PO_LINE_NUM||']p_CURRENCY_CODE['||
                         p_CURRENCY_CODE||']p_CHANGE_AMOUNT['||p_CHANGE_AMOUNT||']p_CHANGE_TYPE['||p_CHANGE_TYPE||
                        ']p_CHANGE_DESCRIPTION['||p_CHANGE_DESCRIPTION||']p_rowid['||p_rowid||
                        ']p_ci_transaction_id['||p_ci_transaction_id||']p_org_id['||p_org_id||']'  );
		End If;


                l_error_msg_code :=  NULL;
                l_vendor_id := null;
                l_po_header_id := null;
                l_po_line_id := null;
                l_return_status := 'S';
                l_rowid := p_rowid;
                l_ci_transaction_id := p_ci_transaction_id;
		l_CI_STATUS := null;
		IF l_debug_mode = 'Y' THEN
                	print_msg('calling validate_SI_record');
		End If;

		validate_SI_record(
         		p_RECORD_STATUS                => p_RECORD_STATUS
        		,p_CI_ID                	=> p_CI_ID
        		,P_CALLING_MODE                => 'VALIDATE'
        		,P_CI_STATUS            	=> l_CI_STATUS
        		,P_ORG_ID                      => p_org_id  /*Bug fix fnd_profile.value('ORG_ID')*/
        		,x_VENDOR_ID                   => l_vendor_id
        		,p_VENDOR_NAME                 => p_VENDOR_NAME
        		,x_PO_HEADER_ID                => l_po_header_id
        		,p_PO_NUMBER                   => p_PO_NUMBER
        		,x_PO_LINE_ID                  => l_po_line_id
        		,p_PO_LINE_NUM                 => p_PO_LINE_NUM
        		,p_ADJUSTED_TRANSACTION_ID     => p_ADJUSTED_TRANSACTION_ID
        		,p_CURRENCY_CODE               => p_CURRENCY_CODE
        		,p_CHANGE_AMOUNT               => p_CHANGE_AMOUNT
        		,p_CHANGE_TYPE                 => p_CHANGE_TYPE
        		,p_CHANGE_DESCRIPTION          => p_CHANGE_DESCRIPTION
				,p_Task_Id                     => p_Task_Id
				,p_Resource_List_Mem_Id        => p_Resource_List_Mem_Id
				,p_From_Date                   => p_From_Date
				,p_To_Date                     => p_To_Date
				,p_Estimated_Cost              => p_Estimated_Cost
				,p_Quoted_Cost                 => p_Quoted_Cost
				,p_Negotiated_Cost             => p_Negotiated_Cost
				,p_Burdened_cost               => p_Burdened_cost
				,p_revenue_override_rate       => p_revenue_override_rate
        		,p_audit_history_number        => p_audit_history_number
                ,p_current_audit_flag          => p_current_audit_flag
                ,p_Original_supp_trans_id      => p_Original_supp_trans_id
                ,p_Source_supp_trans_id        => p_Source_supp_trans_id
				,p_Sup_ref_no                  => p_Sup_ref_no
			    ,p_ci_transaction_id           => l_ci_transaction_id
        		,x_return_status               => l_return_status
        		,x_error_msg_code              => l_error_msg_code );

		/** depending on return status and record status call the appropriate table handler api **/

		If l_return_status = 'S' and nvl(l_error_msg_code,'X') = 'X' then

			If p_RECORD_STATUS = 'NEW' then

				/* Bug fix: 2634102  create impact line if not exists*/
				    IF ( NOT pa_ci_impacts_util.is_impact_exist
						(p_ci_id => p_ci_id,
                                                  p_impact_type_code => 'SUPPLIER') ) THEN

					    IF l_debug_mode = 'Y' THEN
					    	print_msg('Calling PA_CI_IMPACTS_pub.create_ci_impact Api');
					    End If;

        				PA_CI_IMPACTS_pub.create_ci_impact(
                      				p_ci_id => p_ci_id,
                      			        p_impact_type_code => 'SUPPLIER',
                      				p_status_code => 'CI_IMPACT_PENDING',
                      				p_commit => 'F',
                      				p_validate_only => 'F',
                      				p_description => NULL,
                      				p_implementation_comment => NULL,
                      				x_ci_impact_id  => l_ci_impact_id,
                      				x_return_status  => l_return_status,
                      				x_msg_count  => l_msg_count,
                      				x_msg_data  =>l_error_msg_code
                                                  );

    				ELSE
                        OPEN cur_impact_id;
			            FETCH cur_impact_id INTO l_ci_impact_id;
						CLOSE cur_impact_id;
				   End If;
				   /* End of bug fix : 2634102 */

				IF l_debug_mode = 'Y' THEN
					print_msg('calling insert_row api');
				End If;

				PA_CI_SUPPLIER_PKG.insert_row (
        				x_rowid                    => l_rowid
        				,x_ci_transaction_id       => l_ci_transaction_id
        				,p_CI_TYPE_ID              => p_ci_type_id
        				,p_CI_ID           	       => p_CI_ID
        				,p_CI_IMPACT_ID            => l_ci_impact_id
        				,p_VENDOR_ID               => l_vendor_id
        				,p_PO_HEADER_ID            => l_po_header_id
        				,p_PO_LINE_ID              => l_po_line_id
        				,p_ADJUSTED_TRANSACTION_ID => p_ADJUSTED_TRANSACTION_ID
        				,p_CURRENCY_CODE           => p_CURRENCY_CODE
        				,p_CHANGE_AMOUNT           => p_CHANGE_AMOUNT
        				,p_CHANGE_TYPE             => p_CHANGE_TYPE
        				,p_CHANGE_DESCRIPTION      => p_CHANGE_DESCRIPTION
        				,p_CREATED_BY              => FND_GLOBAL.login_id
        				,p_CREATION_DATE           => trunc(sysdate)
        				,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
        				,p_LAST_UPDATE_DATE        => trunc(sysdate)
        				,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
						,p_Task_Id                 => p_Task_Id
		                ,p_Resource_List_Mem_Id    => p_Resource_List_Mem_Id
		                ,p_From_Date               => p_From_Date
		                ,p_To_Date                 => p_To_Date
		                ,p_Estimated_Cost          => p_Estimated_Cost
		                ,p_Quoted_Cost             => p_Quoted_Cost
		                ,p_Negotiated_Cost         => p_Negotiated_Cost
						,p_Burdened_cost           => p_Burdened_cost
						,p_Revenue                 => p_Revenue
						,p_revenue_override_rate   => p_revenue_override_rate
                        ,p_audit_history_number    => p_audit_history_number
                        ,p_current_audit_flag      => p_current_audit_flag
                        ,p_Original_supp_trans_id  => p_Original_supp_trans_id
                        ,p_Source_supp_trans_id    => p_Source_supp_trans_id
					    ,p_Sup_ref_no               => p_Sup_ref_no
						,p_version_type            => p_version_type
            -- gboomina modified for supplier cost 12.1.3 requirement - start
            ,p_expenditure_type            => p_expenditure_type
            ,p_expenditure_org_id          => p_expenditure_org_id
            ,p_change_reason_code          => p_change_reason_code
            ,p_quote_negotiation_reference => p_quote_negotiation_reference
            ,p_need_by_date                => p_need_by_date
            -- gboomina modified for supplier cost 12.1.3 requirement - end
        				,x_return_status           => l_return_status
        				,x_error_msg_code          => l_error_msg_code  );

				If l_return_status = 'S' then
					p_ci_transaction_id := l_ci_transaction_id;
					p_rowid := l_rowid;
					IF l_debug_mode = 'Y' THEN
						print_msg('Assigning citransactionid ='||p_ci_transaction_id);
					End If;

				End if;
				IF l_debug_mode = 'Y' THEN
					print_msg('end of insert row api');
				End If;


			Elsif p_RECORD_STATUS = 'CHANGED' then
				/** Check if the ci_transaction_id is already populated then update the row else
				 ** insert the row with same ci_transaction_id. so that populating unnecessary sequence
				 ** number can be avoided.
                                 **/

			        If check_trx_exists(l_ci_transaction_id) = 'Y' then
				     IF l_debug_mode = 'Y' THEN
				     	print_msg('calling update row api');
				     End If;

                                     PA_CI_SUPPLIER_PKG.update_row (
                                        p_rowid                   => l_rowid
                                        ,p_ci_transaction_id      => l_ci_transaction_id
                                        ,p_CI_TYPE_ID             => p_ci_type_id
                                        ,p_CI_ID           	  => p_CI_ID
                                        ,p_CI_IMPACT_ID           => p_ci_impact_id
                                        ,p_VENDOR_ID              => l_vendor_id
                                        ,p_PO_HEADER_ID           => l_po_header_id
                                        ,p_PO_LINE_ID             => l_po_line_id
                                        ,p_ADJUSTED_TRANSACTION_ID => p_ADJUSTED_TRANSACTION_ID
                                        ,p_CURRENCY_CODE           => p_CURRENCY_CODE
                                        ,p_CHANGE_AMOUNT           => p_CHANGE_AMOUNT
                                        ,p_CHANGE_TYPE             => p_CHANGE_TYPE
                                        ,p_CHANGE_DESCRIPTION      => p_CHANGE_DESCRIPTION
                                        ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
                                        ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                                        ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
										,p_Task_Id                 => p_Task_Id
		                ,p_Resource_List_Mem_Id    => p_Resource_List_Mem_Id
		                ,p_From_Date               => p_From_Date
		                ,p_To_Date                 => p_To_Date
		                ,p_Estimated_Cost          => p_Estimated_Cost
		                ,p_Quoted_Cost             => p_Quoted_Cost
		                ,p_Negotiated_Cost         => p_Negotiated_Cost
						,p_Burdened_cost               => p_Burdened_cost
						,p_Revenue                 => p_Revenue
						,p_revenue_override_rate      =>p_revenue_override_rate
                                         ,p_audit_history_number  => p_audit_history_number
                    ,p_current_audit_flag    => p_current_audit_flag
                    ,p_Original_supp_trans_id        => p_Original_supp_trans_id
                    ,p_Source_supp_trans_id          => p_Source_supp_trans_id
					,p_ci_status               => p_Sup_ref_no
                                        -- gboomina modified for supplier cost 12.1.3 requirement - start
                                        ,p_expenditure_type            => p_expenditure_type
                                        ,p_expenditure_org_id          => p_expenditure_org_id
                                        ,p_change_reason_code          => p_change_reason_code
                                        ,p_quote_negotiation_reference => p_quote_negotiation_reference
                                        ,p_need_by_date                => p_need_by_date
                                        -- gboomina modified for supplier cost 12.1.3 requirement - end
                                        ,x_return_status           => l_return_status
                                        ,x_error_msg_code          => l_error_msg_code );

				      IF l_debug_mode = 'Y' THEN
				      	    print_msg('end of update row api');
				      End If;
				Else
				      IF l_debug_mode = 'Y' THEN
                                      	    print_msg('calling insert_row api for record status CHANGED');
				      End If;

                                      PA_CI_SUPPLIER_PKG.insert_row (
                                        x_rowid                   => l_rowid
                                        ,x_ci_transaction_id      => l_ci_transaction_id
                                        ,p_CI_TYPE_ID             => p_ci_type_id
                                        ,p_CI_ID                  => p_CI_ID
                                        ,p_CI_IMPACT_ID           => p_ci_impact_id
                                        ,p_VENDOR_ID              => l_vendor_id
                                        ,p_PO_HEADER_ID           => l_po_header_id
                                        ,p_PO_LINE_ID             => l_po_line_id
                                        ,p_ADJUSTED_TRANSACTION_ID => p_ADJUSTED_TRANSACTION_ID
                                        ,p_CURRENCY_CODE           => p_CURRENCY_CODE
                                        ,p_CHANGE_AMOUNT           => p_CHANGE_AMOUNT
                                        ,p_CHANGE_TYPE             => p_CHANGE_TYPE
                                        ,p_CHANGE_DESCRIPTION      => p_CHANGE_DESCRIPTION
                                        ,p_CREATED_BY              => FND_GLOBAL.login_id
                                        ,p_CREATION_DATE           => trunc(sysdate)
                                        ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
                                        ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                                        ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
										,p_Task_Id                 => p_Task_Id
		                ,p_Resource_List_Mem_Id    => p_Resource_List_Mem_Id
		                ,p_From_Date               => p_From_Date
		                ,p_To_Date                 => p_To_Date
		                ,p_Estimated_Cost          => p_Estimated_Cost
		                ,p_Quoted_Cost             => p_Quoted_Cost
		                ,p_Negotiated_Cost         => p_Negotiated_Cost
						,p_Burdened_cost               => p_Burdened_cost
						,p_Revenue                => p_Revenue
						,p_revenue_override_rate     =>p_revenue_override_rate
                                         ,p_audit_history_number  => p_audit_history_number
                    ,p_current_audit_flag    => p_current_audit_flag
                    ,p_Original_supp_trans_id        => p_Original_supp_trans_id
                    ,p_Source_supp_trans_id          => p_Source_supp_trans_id
                                        ,p_Sup_ref_no               => p_Sup_ref_no
										,p_version_type            => p_version_type
                                        -- gboomina modified for supplier cost 12.1.3 requirement - start
                                        ,p_expenditure_type            => p_expenditure_type
                                        ,p_expenditure_org_id          => p_expenditure_org_id
                                        ,p_change_reason_code          => p_change_reason_code
                                        ,p_quote_negotiation_reference => p_quote_negotiation_reference
                                        ,p_need_by_date                => p_need_by_date
                                        -- gboomina modified for supplier cost 12.1.3 requirement - end
                                        ,x_return_status           => l_return_status
                                        ,x_error_msg_code          => l_error_msg_code  );

                                        If l_return_status = 'S' then
                                             p_ci_transaction_id := l_ci_transaction_id;
                                             p_rowid := l_rowid;
					     IF l_debug_mode = 'Y' THEN
                                             		print_msg('Assigning citransactionid ='||p_ci_transaction_id);
					     End If;
                                            /* Bug fix: 2634102  create impact line if not exists*/
                                            IF ( NOT pa_ci_impacts_util.is_impact_exist
                                                (p_ci_id => p_ci_id,
                                                  p_impact_type_code => 'SUPPLIER') ) THEN
						IF l_debug_mode = 'Y' THEN
							print_msg('Calling PA_CI_IMPACTS_pub.create_ci_impact in Update');
						End If;

                                                PA_CI_IMPACTS_pub.create_ci_impact(
                                                p_ci_id => p_ci_id,
                                                p_impact_type_code => 'SUPPLIER',
                                                p_status_code => 'CI_IMPACT_PENDING',
                                                p_commit => 'F',
                                                p_validate_only => 'F',
                                                p_description => NULL,
                                                p_implementation_comment => NULL,
                                                x_ci_impact_id  => l_ci_impact_id,
                                                x_return_status  => l_return_status,
                                                x_msg_count  => l_msg_count,
                                                x_msg_data  =>l_error_msg_code
                                                  );
                                            End If;
                                           /* End of bug fix : 2634102 */

                                        End if;
					IF l_debug_mode = 'Y' THEN
                                        	print_msg('end of insert row api');
					End if;


				End If; -- End of check_trx_exists
			End if;

		End if;
		If l_return_status <> 'S' and nvl(l_error_msg_code,'X') <> 'X' then

			IF l_debug_mode = 'Y' THEN
				print_msg('adding error msg to stack'||l_error_msg_code);
			End If;

		       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                             ,p_msg_name  =>l_error_msg_code
					   );
			l_msg_count := l_msg_count +1;

		End if;

           If l_msg_count = 1 then
    		pa_interface_utils_pub.get_messages
			      ( p_encoded       => FND_API.G_TRUE
                               ,p_msg_index     => 1
                               ,p_data          => x_msg_data
                               ,p_msg_index_out => l_msg_index_out
                               );

                x_return_status := 'E';
                --x_msg_count := l_msg_count;
                --x_msg_data := l_error_msg_code;
           Elsif l_msg_count > 1 then
                x_return_status := 'E';
                x_msg_count := l_msg_count;
                x_msg_data := null;
           End if;
	END IF; -- end of p_callingModule
        pa_debug.reset_err_stack;
EXCEPTION
     when others then
                x_return_status := 'U';
                x_msg_count := 1;
                x_msg_data := SQLCODE||SQLERRM;
                pa_debug.reset_err_stack;
                RAISE;
END validateSI;

PROCEDURE deleteSIrecord(P_CALLING_MODE  IN varchar2
                       ,p_ROWID          IN varchar2
                       ,P_CI_TRANSACTION_ID  IN number
                       ,X_RETURN_STATUS    IN OUT NOCOPY varchar2
                       ,x_MSG_DATA   IN OUT NOCOPY varchar2
                       ,X_MSG_COUNT  IN OUT NOCOPY number ) IS

	l_debug_mode           varchar2(1) := 'N';
BEGIN
   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       -- initialize the error stack
       PA_DEBUG.init_err_stack('PA_CI_SUPPLIER_UTILS.deleteSIrecord');
	IF l_debug_mode = 'Y' THEN
	      print_msg('inside deleteSIrecord api P_CALLING_MODE['||P_CALLING_MODE||']p_ROWID['||p_ROWID||
                      '] P_CI_TRANSACTION_ID['||P_CI_TRANSACTION_ID||']');
	End If;

       X_RETURN_STATUS := 'S';
       x_MSG_DATA := null;
       X_MSG_COUNT := 0;

	If nvl(P_CI_TRANSACTION_ID ,0) <> 0 then

	   PA_CI_SUPPLIER_PKG.delete_row (p_ci_transaction_id => P_CI_TRANSACTION_ID);
	   /** issuing commit to prevent rollack issued by checkErrors method from java calls**/
	   commit;

	End if;


        pa_debug.reset_err_stack;
EXCEPTION
     when others then
		IF l_debug_mode = 'Y' THEN
                	print_msg('deleteSIrecord Error:'||sqlcode||sqlerrm);
		End If;
                x_return_status := 'U';
                x_msg_count := 1;
                x_msg_data := SQLCODE||SQLERRM;
                RAISE;


END deleteSIrecord;


/** This API copies the supplier Impact details from one
 ** project control item to another project control item
 **/
PROCEDURE Merge_suppliers
                   ( p_from_ci_item_id          IN NUMBER
                    ,p_to_ci_item_id            IN NUMBER
                    ,x_return_status              OUT NOCOPY VARCHAR2
                    ,x_error_msg                  OUT NOCOPY VARCHAR2
                   ) IS

	l_debug_mode           varchar2(1) := 'N';

BEGIN
   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

	IF l_debug_mode = 'Y' THEN
		print_msg('Inside Merge_suppliers Api params p_from_ci_item_id['||p_from_ci_item_id||
			  ']p_to_ci_item_id['||p_to_ci_item_id||']' );
	End If;

	x_return_status := 'S';
	x_error_msg := NULL;

	IF p_from_ci_item_id is NOT NULL and
	   p_to_ci_item_id  is NOT NULL  Then

		INSERT INTO PA_CI_SUPPLIER_DETAILS
		(
                CI_TRANSACTION_ID
                ,CI_TYPE_ID
                ,CI_ID
                ,CI_IMPACT_ID
                ,VENDOR_ID
                ,PO_HEADER_ID
                ,PO_LINE_ID
                ,ADJUSTED_CI_TRANSACTION_ID
                ,CURRENCY_CODE
                ,CHANGE_AMOUNT
                ,CHANGE_TYPE
                ,CHANGE_DESCRIPTION
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATE_LOGIN
		)
		SELECT
 		PA_CI_SUPPLIER_DETAILS_S.nextval
 		,ci.CI_TYPE_ID
 		,p_to_ci_item_id
 		,si.CI_IMPACT_ID
 		,si.VENDOR_ID
 		,si.PO_HEADER_ID
 		,si.PO_LINE_ID
 		,si.CI_TRANSACTION_ID
 		,si.CURRENCY_CODE
 		,si.CHANGE_AMOUNT
 		,si.CHANGE_TYPE
 		,si.CHANGE_DESCRIPTION
 		,NVL(FND_GLOBAL.login_id,-99)
 		,sysdate
 		,NVL(FND_GLOBAL.login_id,-99)
 		,sysdate
 		,NVL(FND_GLOBAL.login_id,-99)
		FROM PA_CI_SUPPLIER_DETAILS si
		    ,PA_CONTROL_ITEMS ci
		WHERE si.CI_ID = p_from_ci_item_id
		AND  ci.ci_id = p_to_ci_item_id;

		IF l_debug_mode = 'Y' THEN
			print_msg('Num of rows merged['||sql%rowcount||']');
		End If;

	End If;
EXCEPTION
     when others then
		IF l_debug_mode = 'Y' THEN
                	print_msg('sqlerror:'||sqlcode||sqlerrm);
		End If;
                x_return_status := 'U';
                x_error_msg := SQLCODE||SQLERRM;
                RAISE;

END Merge_suppliers;

PROCEDURE DELETE_IMPACT(p_ci_id               IN  NUMBER
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_data           OUT NOCOPY VARCHAR2
			,x_msg_count          OUT NOCOPY NUMBER
                        )IS

	l_debug_mode           varchar2(1) := 'N';

BEGIN
	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       -- initialize the error stack
       PA_DEBUG.init_err_stack('PA_CI_SUPPLIER_UTILS.delete_impact');
	IF l_debug_mode = 'Y' THEN
        	print_msg('Inside DELETE_IMPACT  api p_ci_id['||p_ci_id||']' );
	End If;

       X_RETURN_STATUS := 'S';
       x_MSG_DATA := null;
       X_MSG_COUNT := 0;

        If nvl(p_ci_id ,0) <> 0 then
	   DELETE FROM PA_CI_SUPPLIER_DETAILS
	   WHERE ci_id = p_ci_id;
           commit;

        End if;

        pa_debug.reset_err_stack;
EXCEPTION
     when others then
		IF l_debug_mode = 'Y' THEN
                	print_msg('sqlerror:'||sqlcode||sqlerrm);
		End If;
                x_return_status := 'U';
                x_msg_count := 1;
                x_msg_data := SQLCODE||SQLERRM;
		pa_debug.reset_err_stack;
                RAISE;

END DELETE_IMPACT;

/** This Api checks transactions exists in supplier impact details
 ** and returns success 'S' if there are no transactions exists
 ** returns Error if transactions exists. This api is called before
 ** deleting records from pa_ci_impacts
 **/

PROCEDURE IS_SI_DELETE_OK(p_ci_id               IN  NUMBER
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_data           OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER
                        ) IS

	cursor c1 is
	SELECT CI_TRANSACTION_ID
	FROM pa_ci_supplier_details
	WHERE ci_id = p_ci_id;

	l_ci_transaction_id   Number;
	l_msg_index_out       Number;
	l_debug_mode           varchar2(1) := 'N';

BEGIN
   	fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   	l_debug_mode := NVL(l_debug_mode, 'N');

   	pa_debug.set_process('PLSQL','LOG',l_debug_mode);

       -- initialize the error stack
       PA_DEBUG.init_err_stack('PA_CI_SUPPLIER_UTILS.delete_impact');

        /** clear the message stack **/
        fnd_msg_pub.INITIALIZE;

	IF l_debug_mode = 'Y' THEN
        	print_msg('Inside IS_SI_DELETE_OK  api p_ci_id['||p_ci_id||']' );
	End If;
	x_return_status := 'S';
	x_msg_data := Null;
	x_msg_count := 0;

	OPEN c1;
	FETCH c1 INTO l_ci_transaction_id;
	IF c1%FOUND then
	   IF l_debug_mode = 'Y' THEN
	   	print_msg('Transaction Exists For Supplier Impacts');
	   End If;
	   x_msg_count:= 1;
	   x_return_status := 'E';
	   x_msg_data := 'PA_CISI_TRANS_EXISTS';
        End If;
	CLOSE C1;

        If x_return_status <> 'S' then
		 IF l_debug_mode = 'Y' THEN
                 	print_msg('Adding error msg to stack'||x_msg_data);
		 End If;
                 PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                      ,p_msg_name  =>x_msg_data
                                      );
        End if;

        If x_msg_count = 1 then
                pa_interface_utils_pub.get_messages
                              ( p_encoded       => FND_API.G_TRUE
                               ,p_msg_index     => 1
                               ,p_data          => x_msg_data
                               ,p_msg_index_out => l_msg_index_out
                               );

        End if;
	-- Reset the error stack
	pa_debug.reset_err_stack;

EXCEPTION

	WHEN OTHERS THEN
		IF l_debug_mode = 'Y' THEN
                	print_msg('Error From IS_SI_DELETE_OK :sqlerror:'||sqlcode||sqlerrm);
		End If;
                x_return_status := 'U';
                x_msg_count := 1;
                x_msg_data := SQLCODE||SQLERRM;
		pa_debug.reset_err_stack;
                RAISE;

END IS_SI_DELETE_OK;

/** This is a overloaded function which makes calls to IS_SI_DELETE_OK plsql API
 ** and returns 'Y' to delete the records from supplier impact details
 **/

FUNCTION IS_SI_DELETE_OK(p_ci_id   IN  NUMBER) return varchar2 IS

	l_return_status   varchar2(10);
	l_err_msg_data    varchar2(1000);
	l_msg_count       Number;
	l_return_flag     varchar2(1);

BEGIN
	l_return_flag := 'N';

	PA_CI_SUPPLIER_UTILS.IS_SI_DELETE_OK
		       (p_ci_id              =>p_ci_id
                        ,x_return_status     =>l_return_status
                        ,x_msg_data    =>l_err_msg_data
                        ,x_msg_count   =>l_msg_count
		       );

	If l_return_status <> 'S' then
		-- Indicates records exists in SI table so donot delete header lines (pa_ci_impacts)
		l_return_flag := 'N';
	Else
		-- No records exists in SI table so delete header lines (pa_ci_impacts)
		l_return_flag := 'Y';
	End If;

	RETURN l_return_flag;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;
		l_return_flag := 'N';
		RETURN l_return_flag;

END IS_SI_DELETE_OK;
/** This API removes the negative format mask such as if the
 *  if the number <200,000.00> or {20,000.00} or [2,000.00]
 *  this api returns with out brackets as -200,000.00/-20,000.00/-2,000.00
 *  This api is begin used in Supplier impact java screen as a workaround
 *  method of entereing negative amounts in supplier impact region
 *  OA Framework is still working on this issue to fix the prolbem
 *  refer to bug 2747172 and 2748904 for details
 **/
FUNCTION get_formated_amount(p_currency_code  varchar2
                            ,p_amount number ) return varchar2
	IS
        l_string  varchar2(100);
        s1  varchar2(100);
        s2  varchar2(100);
        l_return_string  varchar2(200);

begin
        l_string := p_amount;
        if p_amount is not null and p_currency_code is not null then
                select to_char(p_amount, fnd_currency.get_format_mask(p_currency_code,30))
                into l_string
                from dual;

                s1 := substr(l_string,0,1);
                s2 := substr(l_string,length(l_string),1);
                if((s1 ='<' and s2='>')OR (s1='(' and s2=')')OR(s1='[' and s2=']')) then
                        l_return_string := ( '-'||substr(l_string,2,length(l_string)-2));
                elsif(s2='-') then
                        l_return_string := ( '-'||substr(l_string,1,length(l_string)-1));
                elsif(s2='+') then
                        l_return_string :=( substr(l_string,1,length(l_string)-1));
                else
                        l_return_string:= l_string;
                End If;

        end if;
        return l_return_string;

END get_formated_amount;

PROCEDURE GET_Original_Ci_ID(p_ci_id IN NUMBER
                             ,x_original_ci_id     OUT NOCOPY number
                             ,x_return_status      OUT NOCOPY VARCHAR2
                             ,x_msg_data           OUT NOCOPY VARCHAR2
                             ,x_msg_count          OUT NOCOPY NUMBER) IS

    CURSOR cur(p_ci_id number) is
    SELECT
     decode (NVL(original_ci_id,0),0,ci_id, original_ci_id)
    FROM pa_control_items
    WHERE ci_id = p_ci_id;

    l_ci_id number;
    original_ci_id number;
    l_no_of_app_plan_types number;

BEGIN
    l_ci_id  := p_ci_id;

    if l_ci_id is not null then
      open cur(l_ci_id);
      fetch cur into original_ci_id;
      close cur;
    else
      print_msg('Ci Id cannot be null');
    end if;
  x_original_ci_id := original_ci_id;
  EXCEPTION

	WHEN OTHERS THEN

                x_return_status := 'U';
                x_msg_count := 1;
                x_msg_data := SQLCODE||SQLERRM;
		            pa_debug.reset_err_stack;
                RAISE;

end GET_Original_Ci_ID;

--knk procedure for getting the resource list id
PROCEDURE GET_RESOURCE_LIST_ID(p_project_id IN NUMBER
                               ,x_res_list_id OUT NOCOPY number
                               ,x_return_status      OUT NOCOPY VARCHAR2
                               ,x_msg_data           OUT NOCOPY VARCHAR2
                               ,x_msg_count          OUT NOCOPY NUMBER) IS

    CURSOR cur(p_project_id number) is
    SELECT
     decode (NVL(all_resource_list_id,0),0,cost_resource_list_id , all_resource_list_id)
    FROM pa_proj_fp_options pfo, pa_budget_versions pbv
    WHERE pbv.project_id = p_project_id AND
          pbv.current_working_flag = 'Y' AND
          pbv.budget_status_code = 'W' AND
          Nvl(pbv.approved_cost_plan_type_flag,'N') = 'Y' AND
          pfo.fin_plan_version_id = pbv.budget_version_id;



    l_project_id number;
    res_list_id number := 1000;
    l_no_of_app_plan_types number;

BEGIN
  l_project_id  := p_project_id;

  if l_project_id is not null then
     SELECT COUNT(*) INTO l_no_of_app_plan_types FROM Pa_Proj_Fp_Options
     WHERE
     Project_Id = l_project_id AND
     Fin_Plan_Option_Level_Code = 'PLAN_TYPE' AND
     ( NVL(Approved_Cost_Plan_Type_Flag ,'N') = 'Y' ) ;

     if l_no_of_app_plan_types <> 0 then
       open cur(l_project_id);
       fetch cur into res_list_id;
       close cur;
     else
      null;
     end if;

  else
     print_msg('Project Id cannot be null');
  end if;
  x_res_list_id := res_list_id;
  EXCEPTION

	WHEN OTHERS THEN

                x_return_status := 'U';
                x_msg_count := 1;
                x_msg_data := SQLCODE||SQLERRM;
		pa_debug.reset_err_stack;
                RAISE;

end GET_RESOURCE_LIST_ID;

--knk proc for getting the total cost of the corresponding Change Document
PROCEDURE GET_TOTAL_COST(p_ci_id IN NUMBER
                        ,x_total_cost         OUT NOCOPY NUMBER
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_data           OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER) IS

    l_ci_id number;
    total_cost number := 1000;

BEGIN
  l_ci_id  := p_ci_id;

  if l_ci_id is not null then
     SELECT sum(change_amount) INTO total_cost
     FROM pa_ci_supplier_details_v
     WHERE
     ci_id = l_ci_id;
  else
     print_msg('Project Id cannot be null');
  end if;
  x_total_cost := total_cost;
  EXCEPTION
	WHEN OTHERS THEN
	       x_return_status := 'U';
         x_msg_count := 1;
         x_msg_data := SQLCODE||SQLERRM;
	       pa_debug.reset_err_stack;
         RAISE;

end GET_TOTAL_COST;

-- gboomina added for 12.1.3 supplier cost requirement - start
PROCEDURE delete_supplier_costs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ci_transaction_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE ,
    p_ci_id                        IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_resource_assignment_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE
    ) IS

 l_api_version	     number := 1;
 l_api_name          CONSTANT VARCHAR2(30) := 'delete_supplier_costs';
 l_return_status     VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
 l_msg_count	     number := 0;
 l_msg_data          varchar2(2000);
 l_error_msg_code   varchar2(100):= null;


  cursor get_project_id is
    select project_id
    from pa_control_items
    where ci_id = p_ci_id;

  l_project_id              number;

  cursor get_budget_cost_version_id is
    SELECT budget_version_id FROM pa_budget_versions
    WHERE ci_id = p_ci_id;

  l_budget_version_id       number;

begin

    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              NULL,
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

   if (p_ci_transaction_id_tbl.count > 0) then
     for i in p_ci_transaction_id_tbl.first..p_ci_transaction_id_tbl.last loop
	      PA_CI_SUPPLIER_PKG.delete_row (p_ci_transaction_id => p_ci_transaction_id_tbl(i));
      end loop;

      open get_project_id;
      fetch get_project_id into l_project_id;
      close get_project_id;

      open get_budget_cost_version_id;
      fetch get_budget_cost_version_id into l_budget_version_id;
      close get_budget_cost_version_id;

     pa_process_ci_lines_pkg.process_planning_lines(
	                   p_api_version        => l_api_version,
                           p_init_msg_list      => FND_API.G_FALSE,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_error_msg_code,
                           p_calling_context    => 'SUPPLIER_COST',
                           p_action_type        => 'DELETE',
                           p_bvid               => l_budget_version_id,
                           p_ci_id              => p_ci_id,
                           p_line_id_tbl        => p_ci_transaction_id_tbl,
                           p_project_id         => l_project_id,
                           p_task_id_tbl        => p_task_id_tbl,
                           p_currency_code_tbl  => p_currency_code_tbl,
                           p_rlmi_id_tbl        => p_rlmi_id_tbl,
                           p_res_assgn_id_tbl   => p_resource_assignment_id_tbl
                           );

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

    end if;

    x_return_status := l_return_status;
    PA_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      pa_api.set_message('PA',l_error_msg_code);
      x_msg_count := l_msg_count+1;
      x_msg_data := l_error_msg_code;
      FND_MSG_PUB.Count_And_Get
        (
          p_count	=>	x_msg_count,
          p_data	=>	x_msg_data
        );
        x_return_status := PA_API.G_RET_STS_ERROR;
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      pa_api.set_message('PA',l_error_msg_code);
      x_msg_count := l_msg_count+1;
      x_msg_data := l_error_msg_code;
      FND_MSG_PUB.Count_And_Get
        (
          p_count	=>	x_msg_count,
          p_data	=>	x_msg_data
        );
        x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_msg_count := l_msg_count+1;
      x_msg_data := l_error_msg_code||sqlerrm;
      FND_MSG_PUB.Count_And_Get
        (
          p_count	=>	x_msg_count,
          p_data	=>	x_msg_data
        );
        x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;

end delete_supplier_costs;


procedure save_supplier_costs(
     p_api_version                     IN NUMBER
    ,p_init_msg_list                   IN VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                   IN OUT NOCOPY VARCHAR2
    ,x_msg_data                        IN OUT NOCOPY VARCHAR2
    ,x_msg_count                       IN OUT NOCOPY NUMBER
    ,p_rowid_tbl                       IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_ci_transaction_id_tbl           IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_ci_id                           IN NUMBER
    ,p_ci_type_id                      IN NUMBER
    ,p_ci_impact_id                    IN NUMBER DEFAULT NULL
    ,p_calling_mode                    IN VARCHAR2
    ,p_org_id                          IN NUMBER
    ,p_version_type                    IN VARCHAR2 DEFAULT 'ALL'
    ,p_record_status_tbl               IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_vendor_name_tbl                 IN SYSTEM.PA_VARCHAR2_150_TBL_TYPE
    ,p_vendor_id_tbl                   IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_po_number_tbl                   IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_po_header_id_tbl                IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_po_line_num_tbl                 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_po_line_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_currency_code_tbl               IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_change_amount_tbl               IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_change_type_tbl                 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_change_description_tbl          IN SYSTEM.PA_VARCHAR2_150_TBL_TYPE
    ,p_task_id_tbl                     IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_resource_list_mem_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_adjusted_transaction_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_from_date_tbl                   IN SYSTEM.PA_DATE_TBL_TYPE
    ,p_to_date_tbl                     IN SYSTEM.PA_DATE_TBL_TYPE
    ,p_need_by_date_tbl                IN SYSTEM.PA_DATE_TBL_TYPE
    ,p_estimated_cost_tbl              IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_quoted_cost_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_negotiated_cost_tbl             IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_burdened_cost_tbl               IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_revenue_tbl                     IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
    ,p_revenue_override_rate_tbl       IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_audit_history_number_tbl        IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_current_audit_flag_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_original_supp_trans_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_source_supp_trans_id_tbl        IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_sup_ref_no_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
    ,p_expenditure_type_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_expenditure_org_id_tbl          IN SYSTEM.PA_NUM_TBL_TYPE
    ,p_change_reason_code_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
    ,p_quote_negotiation_ref_tbl       IN SYSTEM.PA_VARCHAR2_150_TBL_TYPE
    ,p_resource_assignment_id_tbl      IN SYSTEM.PA_NUM_TBL_TYPE
)
IS
  l_api_version	   number := 1;
  l_api_name       CONSTANT VARCHAR2(30) := 'save_supplier_costs';
  l_return_status  VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
  l_msg_count	     number := 0;
  l_msg_data       varchar2(2000);
  l_error_msg_code   varchar2(100):= null;

  l_rowid                        varchar2(100);
  l_ci_transaction_id            number(15);
  l_ci_id                        number(15);
  l_ci_type_id                   number(15);
  l_ci_impact_id                 number(15);
  l_vendor_id                    number(15);
  l_po_header_id                 number(15);
  l_po_line_id                   number(15);
  l_change_amount                number;
  l_currency_code                varchar2(15);
  l_adjusted_ci_transaction_id   number(15);
  l_change_description           varchar2(2000);
  l_change_type                  varchar2(100);
  l_created_by                   number;
  l_creation_date                date;
  l_last_updated_by              number;
  l_last_update_date             date;
  l_last_update_login            number;
  l_change_approver              varchar2(50);
  l_audit_history_number         number;
  l_current_audit_flag           varchar2(1);
  l_original_supp_trans_id       number;
  l_source_supp_trans_id         number;
  l_from_change_date             date;
  l_to_change_date               date;
  l_raw_cost                     number;
  l_burdened_cost                number;
  l_revenue_rate                 number;
  l_revenue_override_rate        number;
  l_revenue                      number;
  l_total_revenue                number;
  l_sup_quote_ref_no             number;
  l_task_id                      number(15);
  l_resource_list_member_id      number(15);
  l_estimated_cost               number;
  l_quoted_cost                  number;
  l_negotiated_cost              number;
--  l_final_cost                   number;
  l_markup_cost                  number;
  l_status                       varchar2(15);
  l_expenditure_org_id           number(15);
  l_change_reason_code           varchar2(30);
  l_quote_negotiation_ref        varchar2(150);
  l_need_by_date                 date;
  l_expenditure_type             varchar2(30);
  l_resource_assignment_id       number;

  l_ci_transaction_id_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  l_quantity_tbl                 SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

  cursor get_project_id is
    select project_id
    from pa_control_items
    where ci_id = p_ci_id;

  l_project_id              number;

  cursor get_budget_cost_version_id is
    SELECT budget_version_id FROM pa_budget_versions
    WHERE ci_id = p_ci_id and version_type IN ('ALL', 'COST');

  l_budget_version_id       number;

  cursor get_budget_update_method is
    Select typ.impact_budget_type_code
    from pa_ci_types_b typ, pa_control_items items
    where items.ci_type_id=typ.ci_type_id and ci_id = p_ci_id;

  l_budget_update_method  varchar2(30);

  cursor get_po_dates(c_po_header_id NUMBER) is
  select start_date, end_date from po_headers_all
  where po_header_id = c_po_header_id;

  l_po_start_date date;
  l_po_end_date date;

  -- budget impact tables for inserted record
  l_ins_count             number := 0;
  b_ins_task_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_ins_sc_line_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_ins_quantity_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_ins_raw_cost_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_ins_res_assgn_id_tbl  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_ins_rlmi_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_ins_currency_code_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

  -- budget impact tables for updated record
  l_upd_count             number := 0;
  b_upd_task_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_upd_sc_line_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_upd_quantity_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_upd_raw_cost_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_upd_res_assgn_id_tbl  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_upd_rlmi_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  b_upd_currency_code_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

 cursor get_sc_line(c_sc_line_id number) is
   select nvl(raw_cost, 0) raw_cost,
                  from_change_date, to_change_date
     from pa_ci_supplier_details
    where ci_id = p_ci_id
      and ci_transaction_id = c_sc_line_id;

   sc_line_row         get_sc_line%ROWTYPE;

begin
    l_return_status := PA_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              NULL,
                                              x_return_status);
    IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
      RAISE PA_API.G_EXCEPTION_ERROR;
    END IF;

   -- Get the budget update method of the control item
   open get_budget_update_method;
   fetch get_budget_update_method into l_budget_update_method;
   close get_budget_update_method;

   if (p_ci_transaction_id_tbl.count > 0) then
     for i in p_ci_transaction_id_tbl.first..p_ci_transaction_id_tbl.last loop

       l_rowid                        := p_rowid_tbl(i);
       l_ci_transaction_id            := p_ci_transaction_id_tbl(i);
       l_ci_id                        := p_ci_id;
       l_ci_type_id                   := p_ci_type_id;
       l_ci_impact_id                 := p_ci_impact_id;
       l_vendor_id                    := p_vendor_id_tbl(i);
       l_po_header_id                 := p_po_header_id_tbl(i);
       l_po_line_id                   := p_po_line_id_tbl(i);
       l_change_amount                := p_change_amount_tbl(i);
       l_currency_code                := p_currency_code_tbl(i);
       l_adjusted_ci_transaction_id   := p_adjusted_transaction_id_tbl(i);
       l_change_description           := p_change_description_tbl(i);
       l_change_type                  := p_change_type_tbl(i);
       l_audit_history_number         := p_audit_history_number_tbl(i);
       l_task_id                      := p_task_id_tbl(i);
       l_current_audit_flag           := p_current_audit_flag_tbl(i);
       l_original_supp_trans_id       := p_original_supp_trans_id_tbl(i);
       l_source_supp_trans_id         := p_source_supp_trans_id_tbl(i);
       l_from_change_date             := p_from_date_tbl(i);
       l_to_change_date               := p_to_date_tbl(i);
       l_raw_cost                     := p_change_amount_tbl(i);
       l_burdened_cost                := p_burdened_cost_tbl(i);
       l_revenue_override_rate        := p_revenue_override_rate_tbl(i);
       l_revenue                      := p_revenue_tbl(i);
       l_sup_quote_ref_no             := p_sup_ref_no_tbl(i);
       l_resource_list_member_id      := p_resource_list_mem_id_tbl(i);
       l_estimated_cost               := p_estimated_cost_tbl(i);
       l_quoted_cost                  := p_quoted_cost_tbl(i);
       l_negotiated_cost              := p_negotiated_cost_tbl(i);
       l_expenditure_org_id           := p_expenditure_org_id_tbl(i);
       l_change_reason_code           := p_change_reason_code_tbl(i);
       l_quote_negotiation_ref        := p_quote_negotiation_ref_tbl(i);
       l_need_by_date                 := p_need_by_date_tbl(i);
       l_expenditure_type             := p_expenditure_type_tbl(i);
       l_resource_assignment_id       := p_resource_assignment_id_tbl(i);


       if (p_record_status_tbl(i) = 'NEW') then

         -- if Budget Update Method is 'Cost and Revenue planning' then only
         -- validate uniqueness.
         if (l_budget_update_method = 'DIRECT_COST_ENTRY') then
         -- check for uniqueness of the record
           is_record_unique(p_api_version            => p_api_version
			                        ,p_init_msg_list          => p_init_msg_list
                    			    ,x_return_status          => l_return_status
                      	    ,x_msg_data               => x_msg_data
                    			    ,x_msg_count              => x_msg_count
                           ,p_ci_id                  => p_ci_id
                           ,p_task_id                => l_task_id
	                          ,p_resource_list_mem_id   => l_resource_list_member_id
                           ,p_expenditure_type       => l_expenditure_type
			                        ,p_currency_code          => l_currency_code
                           ,p_vendor_id              => l_vendor_id
                           ,p_expenditure_org_id     => l_expenditure_org_id
                           ,p_need_by_date           => l_need_by_date
                           ,p_po_line_id             => l_po_line_id
                           ,p_record_status          => p_record_status_tbl(i)
                           ,p_ci_transaction_id      => l_ci_transaction_id );

                  IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
                    RAISE PA_API.G_EXCEPTION_ERROR;
                  END IF;
            end if;

          PA_CI_SUPPLIER_PKG.insert_row (
                  x_rowid                    => l_rowid
                  ,x_ci_transaction_id       => l_ci_transaction_id
                  ,p_CI_TYPE_ID              => l_ci_type_id
                  ,p_CI_ID           	     => l_ci_id
                  ,p_CI_IMPACT_ID            => l_ci_impact_id
                  ,p_VENDOR_ID               => l_vendor_id
                  ,p_PO_HEADER_ID            => l_po_header_id
                  ,p_PO_LINE_ID              => l_po_line_id
                  ,p_ADJUSTED_TRANSACTION_ID => l_adjusted_ci_transaction_id
                  ,p_CURRENCY_CODE           => l_currency_code
                  ,p_CHANGE_AMOUNT           => l_change_amount
                  ,p_CHANGE_TYPE             => l_change_type
                  ,p_CHANGE_DESCRIPTION      => l_change_description
                  ,p_CREATED_BY              => FND_GLOBAL.login_id
                  ,p_CREATION_DATE           => trunc(sysdate)
                  ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
                  ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                  ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
                  ,p_Task_Id                 => l_task_id
                  ,p_Resource_List_Mem_Id    => l_resource_list_member_id
                  ,p_From_Date               => l_from_change_date
                  ,p_To_Date                 => l_to_change_date
                  ,p_Estimated_Cost          => l_estimated_cost
                  ,p_Quoted_Cost             => l_quoted_cost
                  ,p_Negotiated_Cost         => l_negotiated_cost
                  ,p_Burdened_cost           => l_burdened_cost
                  ,p_Revenue                 => l_revenue
                  ,p_revenue_override_rate   => l_revenue_override_rate
                  ,p_audit_history_number    => l_audit_history_number
                  ,p_current_audit_flag      => l_current_audit_flag
                  ,p_Original_supp_trans_id  => l_original_supp_trans_id
                  ,p_Source_supp_trans_id    => l_source_supp_trans_id
                  ,p_Sup_ref_no               => l_sup_quote_ref_no
                  ,p_version_type            => p_version_type
                  ,p_expenditure_type            => l_expenditure_type
                  ,p_expenditure_org_id          => l_expenditure_org_id
                  ,p_change_reason_code          => l_change_reason_code
                  ,p_quote_negotiation_reference => l_quote_negotiation_ref
                  ,p_need_by_date                => l_need_by_date
                  ,x_return_status           => l_return_status
                  ,x_error_msg_code          => l_error_msg_code  );

                  IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
                    RAISE PA_API.G_EXCEPTION_ERROR;
                  END IF;

          -- populate the budget impact tables

          b_ins_sc_line_id_tbl.extend(1);
          b_ins_task_id_tbl.extend(1);
          b_ins_currency_code_tbl.extend(1);
          b_ins_rlmi_id_tbl.extend(1);
          b_ins_res_assgn_id_tbl.extend(1);
          b_ins_quantity_tbl.extend(1);
          b_ins_raw_cost_tbl.extend(1);

          l_ins_count := l_ins_count + 1 ;
          b_ins_task_id_tbl(l_ins_count)        := l_task_id;
          b_ins_sc_line_id_tbl(l_ins_count)     := l_ci_transaction_id;
          b_ins_quantity_tbl(l_ins_count)       := NULL; -- Quantity is null for Supplier cost
          b_ins_raw_cost_tbl(l_ins_count)       := l_change_amount;
          b_ins_res_assgn_id_tbl(l_ins_count)   := l_resource_assignment_id;
          b_ins_rlmi_id_tbl(l_ins_count)        := l_resource_list_member_id;
          b_ins_currency_code_tbl(l_ins_count)  := l_currency_code;

       elsif (p_record_status_tbl(i) = 'CHANGED') then

         -- if Budget Update Method is 'Cost and Revenue planning' then only
         -- validate uniqueness.
         if (l_budget_update_method = 'DIRECT_COST_ENTRY') then
         -- check for uniqueness of the record
           is_record_unique(p_api_version            => p_api_version
			                        ,p_init_msg_list          => p_init_msg_list
                    			    ,x_return_status          => l_return_status
                      	    ,x_msg_data               => x_msg_data
                    			    ,x_msg_count              => x_msg_count
                           ,p_ci_id                  => p_ci_id
                           ,p_task_id                => l_task_id
	                          ,p_resource_list_mem_id   => l_resource_list_member_id
                           ,p_expenditure_type       => l_expenditure_type
			                        ,p_currency_code          => l_currency_code
                           ,p_vendor_id              => l_vendor_id
                           ,p_expenditure_org_id     => l_expenditure_org_id
                           ,p_need_by_date           => l_need_by_date
                           ,p_po_line_id             => l_po_line_id
                           ,p_record_status          => p_record_status_tbl(i)
                           ,p_ci_transaction_id      => l_ci_transaction_id );

                  IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
                    RAISE PA_API.G_EXCEPTION_ERROR;
                  END IF;
            end if;

          -- populate the budget impact tables
          open get_sc_line(l_ci_transaction_id);
          fetch get_sc_line into sc_line_row;
          close get_sc_line;

          if (sc_line_row.from_change_date <> l_from_change_date or
              sc_line_row.to_change_date <> l_to_change_date or
              sc_line_row.raw_cost <> l_change_amount ) then

            b_upd_sc_line_id_tbl.extend(1);
            b_upd_task_id_tbl.extend(1);
            b_upd_currency_code_tbl.extend(1);
            b_upd_rlmi_id_tbl.extend(1);
            b_upd_res_assgn_id_tbl.extend(1);
            b_upd_quantity_tbl.extend(1);
            b_upd_raw_cost_tbl.extend(1);

            l_upd_count := l_upd_count + 1 ;
            b_upd_task_id_tbl(l_upd_count)        := l_task_id;
            b_upd_sc_line_id_tbl(l_upd_count)     := l_ci_transaction_id;
            b_upd_quantity_tbl(l_upd_count)       := NULL; -- Quantity is null for Supplier cost
            b_upd_raw_cost_tbl(l_upd_count)       := l_change_amount;
            b_upd_res_assgn_id_tbl(l_upd_count)   := l_resource_assignment_id;
            b_upd_rlmi_id_tbl(l_upd_count)        := l_resource_list_member_id;
            b_upd_currency_code_tbl(l_upd_count)  := l_currency_code;

          end if;

         PA_CI_SUPPLIER_PKG.update_row (
                  p_rowid                    => l_rowid
                  ,p_ci_transaction_id       => l_ci_transaction_id
                  ,p_CI_TYPE_ID              => l_ci_type_id
                  ,p_CI_ID           	     => l_ci_id
                  ,p_CI_IMPACT_ID            => l_ci_impact_id
                  ,p_VENDOR_ID               => l_vendor_id
                  ,p_PO_HEADER_ID            => l_po_header_id
                  ,p_PO_LINE_ID              => l_po_line_id
                  ,p_ADJUSTED_TRANSACTION_ID => l_adjusted_ci_transaction_id
                  ,p_CURRENCY_CODE           => l_currency_code
                  ,p_CHANGE_AMOUNT           => l_change_amount
                  ,p_CHANGE_TYPE             => l_change_type
                  ,p_CHANGE_DESCRIPTION      => l_change_description
                  ,p_LAST_UPDATED_BY         => FND_GLOBAL.login_id
                  ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                  ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
                  ,p_Task_Id                 => l_task_id
                  ,p_Resource_List_Mem_Id    => l_resource_list_member_id
                  ,p_From_Date               => l_from_change_date
                  ,p_To_Date                 => l_to_change_date
                  ,p_Estimated_Cost          => l_estimated_cost
                  ,p_Quoted_Cost             => l_quoted_cost
                  ,p_Negotiated_Cost         => l_negotiated_cost
                  ,p_Burdened_cost           => l_burdened_cost
                  ,p_Revenue                 => l_revenue
                  ,p_revenue_override_rate   => l_revenue_override_rate
                  ,p_audit_history_number    => l_audit_history_number
                  ,p_current_audit_flag      => l_current_audit_flag
                  ,p_Original_supp_trans_id  => l_original_supp_trans_id
                  ,p_Source_supp_trans_id    => l_source_supp_trans_id
                  ,p_Sup_ref_no              => l_sup_quote_ref_no
                  ,p_version_type            => p_version_type
                  ,p_expenditure_type        => l_expenditure_type
                  ,p_expenditure_org_id      => l_expenditure_org_id
                  ,p_change_reason_code      => l_change_reason_code
                  ,p_quote_negotiation_reference => l_quote_negotiation_ref
                  ,p_need_by_date            => l_need_by_date
                  ,x_return_status           => l_return_status
                  ,x_error_msg_code          => l_error_msg_code );

                 IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
                   RAISE PA_API.G_EXCEPTION_ERROR;
                 END IF;

         end if;
         l_ci_transaction_id_tbl.extend(1);
         l_ci_transaction_id_tbl(i) := l_ci_transaction_id;
         -- l_quantity_tbl.extend(1);
         -- l_quantity_tbl(i) := NULL; --Quantity will be null for supplier cost
       end loop;
     end if;

     -- Get the budget update method of the control item
      open get_budget_update_method;
      fetch get_budget_update_method into l_budget_update_method;
      close get_budget_update_method;

      -- if Budget Update Method is 'Cost and Revenue planning' then only
      -- Create budget impacts.
      if (l_budget_update_method = 'DIRECT_COST_ENTRY') then
          --if (l_ci_transaction_id_tbl.count > 0) then
             open get_project_id;
             fetch get_project_id into l_project_id;
             close get_project_id;

             open get_budget_cost_version_id;
             fetch get_budget_cost_version_id into l_budget_version_id;
             close get_budget_cost_version_id;


           if (l_ins_count > 0 ) then
             pa_process_ci_lines_pkg.process_planning_lines(
                 p_api_version        => l_api_version,
                 p_init_msg_list      => FND_API.G_FALSE,
                 x_return_status      => l_return_status,
                 x_msg_count          => l_msg_count,
                 x_msg_data           => l_msg_data,
                 p_calling_context    => 'SUPPLIER_COST',
                 p_action_type        => 'INSERT',
                 p_bvid               => l_budget_version_id,
                 p_ci_id              => p_ci_id,
                 p_line_id_tbl        => b_ins_sc_line_id_tbl,
                 p_project_id         => l_project_id,
                 p_task_id_tbl        => b_ins_task_id_tbl,
                 p_currency_code_tbl  => b_ins_currency_code_tbl,
                 p_rlmi_id_tbl        => b_ins_rlmi_id_tbl,
                 p_res_assgn_id_tbl   => b_ins_res_assgn_id_tbl,
                 p_quantity_tbl       => b_ins_quantity_tbl, -- this will be null for supplier cost
                 p_raw_cost_tbl       => b_ins_raw_cost_tbl
                 );

             IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
               RAISE PA_API.G_EXCEPTION_ERROR;
             END IF;

           -- update resource assignment id, effective dates and
           -- burdened cost in supplier details table after
           -- processing the supplier records and createing/updating
           -- resource assignments
           forall i in b_ins_task_id_tbl.first..b_ins_task_id_tbl.last
            update pa_ci_supplier_details pcsc
               set (resource_assignment_id, FROM_CHANGE_DATE,
                    TO_CHANGE_DATE, burdened_cost) =
                       (select prac.resource_assignment_id,
                               decode(pcsc.FROM_CHANGE_DATE,
                                  null,pra.planning_start_date, pcsc.FROM_CHANGE_DATE),
                           decode(pcsc.TO_CHANGE_DATE,
                                  null, pra.planning_end_date, pcsc.TO_CHANGE_DATE),
                               pcsc.raw_cost * prac.txn_average_burden_cost_rate
                          from pa_resource_assignments pra, pa_resource_asgn_curr prac
                         where pra.budget_version_id = l_budget_version_id
                           and pra.task_id = pcsc.task_id
                           and pra.resource_list_member_id = pcsc.resource_list_member_id
                           and prac.txn_currency_code = pcsc.currency_code
                           and prac.resource_assignment_id = pra.resource_assignment_id)
             where ci_id = p_ci_id
             and source_supp_trans_id = b_ins_sc_line_id_tbl(i);
           end if;

           if (l_upd_count > 0 ) then
             pa_process_ci_lines_pkg.process_planning_lines(
                 p_api_version        => l_api_version,
                 p_init_msg_list      => FND_API.G_FALSE,
                 x_return_status      => l_return_status,
                 x_msg_count          => l_msg_count,
                 x_msg_data           => l_msg_data,
                 p_calling_context    => 'SUPPLIER_COST',
                 p_action_type        => 'UPDATE',
                 p_bvid               => l_budget_version_id,
                 p_ci_id              => p_ci_id,
                 p_line_id_tbl        => b_upd_sc_line_id_tbl,
                 p_project_id         => l_project_id,
                 p_task_id_tbl        => b_upd_task_id_tbl,
                 p_currency_code_tbl  => b_upd_currency_code_tbl,
                 p_rlmi_id_tbl        => b_upd_rlmi_id_tbl,
                 p_res_assgn_id_tbl   => b_upd_res_assgn_id_tbl,
                 p_quantity_tbl       => b_upd_quantity_tbl, -- this will be null for supplier cost
                 p_raw_cost_tbl       => b_upd_raw_cost_tbl
                 );

             IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
               RAISE PA_API.G_EXCEPTION_ERROR;
             END IF;

           -- update resource assignment id, effective dates and
           -- burdened cost in supplier details table after
           -- processing the supplier records and createing/updating
           -- resource assignments
           forall i in b_upd_task_id_tbl.first..b_upd_task_id_tbl.last
            update pa_ci_supplier_details pcsc
               set (resource_assignment_id, FROM_CHANGE_DATE,
                    TO_CHANGE_DATE, burdened_cost) =
                       (select prac.resource_assignment_id,
                           decode(pcsc.FROM_CHANGE_DATE,
                              null,pra.planning_start_date, pcsc.FROM_CHANGE_DATE),
                           decode(pcsc.TO_CHANGE_DATE,
                              null, pra.planning_end_date, pcsc.TO_CHANGE_DATE),
                               pcsc.raw_cost * prac.txn_average_burden_cost_rate
                          from pa_resource_assignments pra, pa_resource_asgn_curr prac
                         where pra.budget_version_id = l_budget_version_id
                           and pra.task_id = pcsc.task_id
                           and pra.resource_list_member_id = pcsc.resource_list_member_id
                           and prac.txn_currency_code = pcsc.currency_code
                           and prac.resource_assignment_id = pra.resource_assignment_id)
             where ci_id = p_ci_id
             and source_supp_trans_id = b_upd_sc_line_id_tbl(i);

           end if;

         --end if;
     end if;

   PA_API.END_ACTIVITY(x_msg_count,x_msg_data);

  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN
      pa_api.set_message('PA',x_msg_data);
      x_msg_count := l_msg_count+1;
      x_msg_data := x_msg_data;
      FND_MSG_PUB.Count_And_Get
        (
          p_count	=>	x_msg_count,
          p_data	=>	x_msg_data
        );
        x_return_status := PA_API.G_RET_STS_ERROR;
    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      pa_api.set_message('PA',x_msg_data);
      x_msg_count := l_msg_count+1;
      x_msg_data := x_msg_data;
      FND_MSG_PUB.Count_And_Get
        (
          p_count	=>	x_msg_count,
          p_data	=>	x_msg_data
        );
        x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_msg_count := l_msg_count+1;
      x_msg_data := x_msg_data||sqlerrm;
      FND_MSG_PUB.Count_And_Get
        (
          p_count	=>	x_msg_count,
          p_data	=>	x_msg_data
        );
        x_return_status := PA_API.G_RET_STS_UNEXP_ERROR;

end save_supplier_costs;

-- gboomina added for 12.1.3 supplier cost requirement - end

END PA_CI_SUPPLIER_UTILS;

/
