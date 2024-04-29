--------------------------------------------------------
--  DDL for Package Body GMS_OIE_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_OIE_INT_PKG" AS
-- $Header: gmsoieib.pls 120.1 2005/07/26 14:38:11 appldev noship $

PROCEDURE RaiseException(
	p_calling_sequence 	IN VARCHAR2,
	p_debug_info		IN VARCHAR2,
	p_set_name		IN VARCHAR2,
	p_params		IN VARCHAR2
) IS
-------------------------------------------------------------------
BEGIN
  FND_MESSAGE.SET_NAME('SQLAP', nvl(p_set_name,'AP_DEBUG'));
  FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
  FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', p_calling_sequence);
  FND_MESSAGE.SET_TOKEN('DEBUG_INFO', p_debug_info);
  FND_MESSAGE.SET_TOKEN('PARAMETERS', p_params);

END RaiseException;
-------------------------------------------------------

FUNCTION GetAwardNumber(
	p_award_id		IN	gms_awardId,
	p_award_number  	OUT NOCOPY	gms_awardNum
) RETURN BOOLEAN IS

BEGIN
   select Award_Number
   into   p_award_number
   from   gms_ssa_awards_v
   where  award_id = p_award_id;

   RETURN TRUE;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		GMS_OIE_INT_PKG.RaiseException( 'GetAwardNumber' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetAwardNumber;

-------------------------------------------------------------------
FUNCTION GetAwardInfo(
	p_award_number	IN	gms_awardNum,
	p_award_id 	OUT NOCOPY	gms_awardId,
	p_award_name  	OUT NOCOPY	gms_awardName
) RETURN BOOLEAN IS

BEGIN
  select AWARD_ID, AWARD_SHORT_NAME
  into   p_award_id, p_award_name
  from   gms_ssa_awards_v
  where  AWARD_NUMBER = p_award_number;

  RETURN TRUE;
EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		GMS_OIE_INT_PKG.RaiseException( 'GetAwardInfo' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetAwardInfo;

--------------------------------------------------------------------------------
FUNCTION GetAwardID(
	p_award_number	IN	gms_awardNum,
	p_award_id 	OUT NOCOPY	gms_awardId
) RETURN BOOLEAN IS

BEGIN
  select award_id
  into   p_award_id
  from   gms_ssa_awards_v
  where  award_number = p_award_number;

  RETURN TRUE;
EXCEPTION

	WHEN NO_DATA_FOUND THEN
    		RETURN FALSE;

	WHEN OTHERS THEN
		GMS_OIE_INT_PKG.RaiseException( 'GetAwardID' );
    		APP_EXCEPTION.RAISE_EXCEPTION;
        	return FALSE;

END GetAwardID;

--------------------------------------------------------------------------------
FUNCTION  IsSponsoredProject(
 		p_project_num 	 	IN  varchar2,
		p_sponsored_flag 	OUT NOCOPY varchar2
) RETURN BOOLEAN IS

BEGIN

	select nvl(pt.sponsored_flag, 'N')
	  into p_sponsored_flag
	  from pa_projects_all b,
	       gms_project_types pt
	 where b.segment1     = p_project_num
	   and b.project_type   = pt.project_type
	   and pt.sponsored_flag = 'Y';

	RETURN TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		GMS_OIE_INT_PKG.RaiseException( 'IsSponsoredProject' );
                APP_EXCEPTION.RAISE_EXCEPTION;
                return FALSE;

END IsSponsoredProject ;

--------------------------------------------------------------------------------
FUNCTION  IsGrantsEnabled RETURN BOOLEAN IS

BEGIN
	if gms_install.enabled then
	  return TRUE;
	else
	  return FALSE;
	end if;
END IsGrantsEnabled;
--------------------------------------------------------------------------------
FUNCTION IsAwardValid(
		p_award_number	IN	gms_awardNum
)RETURN BOOLEAN IS

l_award_valid	varchar2(1);
BEGIN
	select 'Y'
	  into l_award_valid
	  from dual
	 where exists (
			select '1'
	  		  from gms_awards_all
	 		 where award_number = p_award_number
			   and award_template_flag = 'DEFERRED'
			   and status in ('ACTIVE', 'AT_RISK'));
	RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
	RETURN FALSE;

  WHEN OTHERS THEN
	GMS_OIE_INT_PKG.RaiseException( 'IsAwardValid' );
	APP_EXCEPTION.RAISE_EXCEPTION;
	return FALSE;

END IsAwardValid;
--------------------------------------------------------------------------------
FUNCTION AwardFundingProject (
		p_award_id	IN	NUMBER,
		p_project_id	IN	NUMBER,
		p_task_id	IN	NUMBER
) RETURN BOOLEAN IS

l_award_funds	varchar2(1);
BEGIN
	select 'Y'
	  into l_award_funds
	  from gms_ssa_awards_v
	 where award_id = p_award_id
	   and project_id = p_project_id
	   and task_id = p_task_id;

	RETURN TRUE;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   RETURN FALSE;

	WHEN OTHERS THEN
	  GMS_OIE_INT_PKG.RaiseException( 'AwardFundingProject' );
	  APP_EXCEPTION.RAISE_EXCEPTION;
	  return FALSE;

END AwardFundingProject;
--------------------------------------------------------------------------------
FUNCTION DoGrantsValidation(p_project_id         IN NUMBER,
                            p_task_id            IN NUMBER,
                            p_award_id           IN NUMBER,
                            p_award_number       IN VARCHAR2,
                            p_expenditure_type   IN VARCHAR2,
                            p_expenditure_item_date IN DATE,
                            p_calling_module     IN VARCHAR2,
			    p_err_msg	        OUT NOCOPY VARCHAR2
			 ) RETURN BOOLEAN IS

l_status	varchar2(20);

BEGIN

-- This function is called from Internet Expenses when the report is submitted.
-- Award data entered on the screen is validated and returns a TRUE or FALSE along
-- with the error message, if any.

	gms_transactions_pub.validate_award(X_project_id		=> p_project_id
					  , X_task_id    		=> p_task_id
					  , X_award_id   		=> p_award_id
					  , X_award_number		=> p_award_number
					  , X_expenditure_type		=> p_expenditure_type
					  , X_expenditure_item_date	=> p_expenditure_item_date
					  , X_calling_module		=> 'GMS-OIE'
					  , X_status			=> l_status
					  , X_err_msg			=> p_err_msg);

	if l_status = 'E' then
	   return FALSE;
	else
	   return TRUE;
	end if;

EXCEPTION
WHEN OTHERS THEN
	GMS_OIE_INT_PKG.RaiseException( 'ValidateAward' );
        APP_EXCEPTION.RAISE_EXCEPTION;
        return FALSE;
END DoGrantsValidation;
--------------------------------------------------------------------------------
-- This function creates an award distribution line for each award related expense report line
-- This function returns the award_set_id and this is passed onto the Account generator.
FUNCTION CreateACGenADL(p_award_id	IN	NUMBER,
			p_project_id	IN	NUMBER,
			p_task_id	IN	NUMBER)
  RETURN NUMBER IS
    v_adl_rec		gms_award_distributions%ROWTYPE;
  BEGIN
    v_adl_rec.award_set_id := GMS_AWARDS_DIST_PKG.get_award_set_id;
    v_adl_rec.award_id := p_award_id;
    v_adl_rec.project_id := p_project_id;
    v_adl_rec.task_id := p_task_id;
    v_adl_rec.document_type := 'OIE';
    v_adl_rec.adl_line_num := 1;
    v_adl_rec.distribution_value := 100;
    v_adl_rec.request_id := null;
    v_adl_rec.adl_status := 'A';
    v_adl_rec.line_type := 'R';

    GMS_AWARDS_DIST_PKG.create_adls(v_adl_rec);
    return v_adl_rec.award_set_id;

  EXCEPTION
	WHEN OTHERS THEN
	  GMS_OIE_INT_PKG.RaiseException( 'CreateACGenADL' );
          APP_EXCEPTION.RAISE_EXCEPTION;
END CreateACGenADL;
----------------------------------------------------------------------------------
-- This function deletes the award distribution line created for Accounting purpose.
FUNCTION DeleteACGenADL(p_award_set_id	IN	NUMBER)
  RETURN BOOLEAN IS

  BEGIN

    delete from gms_award_distributions
     where award_set_id = p_award_set_id;

    return TRUE;

  EXCEPTION
	WHEN OTHERS THEN
          return FALSE;
END DeleteACGenADL;
----------------------------------------------------------------------------------
-- This procedure creates award distribution lines for award related expense reports
-- that are interfaced to Payables from AP Expense Report interface tables.
-- * This procedure accepts a PL/SQL table of Invoice IDs passed from Expense Report Import
--   process.
-- * Processing is done for expense report source of 'Oracle Project Accounting' and 'SelfService'
--   (OIE) only.
-- * For source of 'Oracle Project Accounting' update the expense report lines records with the
--   award_id and award_number for sponsored projects. Award information is obtained from ADL table.
-- * Common processing for both the above sources is to create ADLs with document_type = 'AP'
--   and update the award_id column on AP_INVOICE_DISTRIBUTIONS_ALL table with award_set_id of the
--   new ADLs.
--
procedure create_award_distributions(p_invoice_id  IN   gms_oie_int_pkg.invoice_id_tab) is

TYPE pt_award_set_id is table of number index by binary_integer;
TYPE pt_date is table of date index by binary_integer;
TYPE pt_varchar25 is table of varchar2(25) index by binary_integer;

t_award_set_id                  pt_award_set_id;
t_distribution_line_number      pt_award_set_id;
t_invoice_distribution_id       pt_award_set_id;
t_project_id                    pt_award_set_id;
cur_project_id                  pt_award_set_id;
cur_report_header_id            pt_award_set_id;
t_task_id                       pt_award_set_id;
t_award_id                      pt_award_set_id;
t_amount                        pt_award_set_id;
t_request_id                    pt_award_set_id;
t_created_by                    pt_award_set_id;
t_reference_1			pt_award_set_id;
t_reference_2			pt_award_set_id;
t_date                          pt_date;
t_ind_compiled_set_id		pt_award_set_id;
t_rlmi_id                       pt_award_set_id;
t_bud_task_id                   pt_award_set_id;
t_burdenable_cost               pt_award_set_id;

v_source			varchar2(25);

cursor get_inv_dist_lines(v_invoice_id number) is
  select aid.invoice_distribution_id,
         aid.distribution_line_number,
         aerl.project_id,
         aerl.task_id,
         aerl.award_id,
         aid.amount,
         aid.request_id,
         aid.creation_date,
         aid.created_by,
	 to_number(aerl.reference_1), -- Expenditure_item_id
	 to_number(aerl.reference_2),  -- CDL Line number
         null, -- ind_compiled_set_id
         null, -- burdenable_raw_cost
         null, -- rlmi_id
         null  -- bud_task_id
    from ap_invoice_distributions_all aid,
         ap_expense_report_headers_all aerh,
         ap_expense_report_lines_all aerl,
	 gms_project_types gpt,
	 pa_projects_all pp
   where aerh.vouchno = aid.invoice_id
     and aerh.report_header_id = aerl.report_header_id
     and aid.invoice_id = v_invoice_id
     and aid.distribution_line_number = aerl.distribution_line_number
     and aid.project_id = pp.project_id
     and pp.project_type = gpt.project_type
     and gpt.sponsored_flag = 'Y'
     and aerl.award_id is not null
   order by aid.distribution_line_number;

cursor get_source(v_invoice_id number) is
  select source
    from ap_expense_report_headers_all
   where vouchno = v_invoice_id;

begin

   open get_source(p_invoice_id(1));
   fetch get_source into v_source;
   close get_source;

   if v_source not in ('Oracle Project Accounting', 'SelfService') then
      return;
   end if;

   if v_source = 'Oracle Project Accounting' then

	for i in p_invoice_id.FIRST..p_invoice_id.LAST loop

	  select aeh.report_header_id, aerl.project_id bulk collect
	    into cur_report_header_id, cur_project_id
	    from ap_expense_report_headers_all aeh,
		 ap_expense_report_lines_all aerl,
		 pa_projects_all pp, gms_project_types gpt
	   where aeh.report_header_id = aerl.report_header_id
	     and aeh.vouchno = p_invoice_id(i)
	     and aerl.project_id = pp.project_id
	     and pp.project_type = gpt.project_type
	     and gpt.sponsored_flag = 'Y';

	end loop;

	if cur_project_id.COUNT > 0 then

	   forall i in cur_project_id.FIRST..cur_project_id.LAST

	     update ap_expense_report_lines_all aerl
	        set (award_id, award_number) =  (select aw.award_id, aw.award_number
						   from gms_awards_all aw, gms_award_distributions adl
					          where aw.award_id = adl.award_id
						    and adl.expenditure_item_id = aerl.reference_1
						    and adl.document_type = 'EXP'
						    and adl.adl_status = 'A'
						    and adl.adl_line_num = 1
						    and rownum = 1
						    and adl.project_id = aerl.project_id
						    and adl.task_id = aerl.task_id)
	      where aerl.report_header_id = cur_report_header_id(i)
	        and aerl.project_id = cur_project_id(i);
	end if;

   end if;


   for inv_index in p_invoice_id.FIRST..p_invoice_id.LAST loop

     t_award_set_id.delete;
     t_distribution_line_number.delete;
     t_invoice_distribution_id.delete;
     t_project_id.delete;
     t_task_id.delete;
     t_award_id.delete;
     t_amount.delete;
     t_request_id.delete;
     t_created_by.delete;
     t_date.delete;
     t_reference_1.delete;
     t_reference_2.delete;
     t_ind_compiled_set_id.delete;
     t_rlmi_id.delete;
     t_bud_task_id.delete;
     t_burdenable_cost.delete;
     cur_project_id.delete;
     cur_report_header_id.delete;

     open get_inv_dist_lines(p_invoice_id(inv_index));

     fetch get_inv_dist_lines bulk collect into t_invoice_distribution_id, t_distribution_line_number,
                                                t_project_id, t_task_id, t_award_id, t_amount,
                                                t_request_id, t_date, t_created_by,
					        t_reference_1, t_reference_2, t_ind_compiled_set_id,
                                                t_rlmi_id, t_burdenable_cost, t_bud_task_id;
     close get_inv_dist_lines;

     if t_distribution_line_number.count = 0 then
        goto no_lines; -- If there are no lines, skip the processing.
     end if;

     if v_source = 'Oracle Project Accounting' then
     -- populate values from EXP line for PA Expense Reports interfaced to AP.
        for i in t_reference_1.FIRST..t_reference_1.LAST loop
          select ind_compiled_set_id, burdenable_raw_cost,
                 resource_list_member_id, bud_task_id
            into t_ind_compiled_set_id(i), t_burdenable_cost(i),
                 t_rlmi_id(i), t_bud_task_id(i)
            from gms_award_distributions
           where expenditure_item_id = t_reference_1(i)
             and cdl_line_num = t_reference_2(i)
             and adl_status = 'A'
             and document_type = 'EXP'
             and fc_status = 'A';
        end loop;
     end if;

     forall i in t_distribution_line_number.first..t_distribution_line_number.last
        insert into gms_award_distributions (
           AWARD_SET_ID,
           ADL_LINE_NUM,
           FUNDING_PATTERN_ID,
           DISTRIBUTION_VALUE,
           RAW_COST,
           DOCUMENT_TYPE,
           PROJECT_ID,
           TASK_ID,
           AWARD_ID,
           EXPENDITURE_ITEM_ID,
           CDL_LINE_NUM,
           IND_COMPILED_SET_ID,
           GL_DATE,
           REQUEST_ID,
           LINE_NUM_REVERSED,
           RESOURCE_LIST_MEMBER_ID,
           OUTPUT_VAT_TAX_ID,
           OUTPUT_TAX_EXEMPT_FLAG,
           OUTPUT_TAX_EXEMPT_REASON_CODE,
           OUTPUT_TAX_EXEMPT_NUMBER,
           ADL_STATUS,
           FC_STATUS,
           LINE_TYPE,
           CAPITALIZED_FLAG,
           CAPITALIZABLE_FLAG,
           REVERSED_FLAG,
           REVENUE_DISTRIBUTED_FLAG,
           BILLED_FLAG,
           BILL_HOLD_FLAG,
           DISTRIBUTION_ID,
           PO_DISTRIBUTION_ID,
           INVOICE_DISTRIBUTION_ID,
           PARENT_AWARD_SET_ID,
           INVOICE_ID,
           PARENT_ADL_LINE_NUM,
           DISTRIBUTION_LINE_NUMBER,
           BURDENABLE_RAW_COST,
           COST_DISTRIBUTED_FLAG,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           BUD_TASK_ID,
           BILLABLE_FLAG,
           ACCUMULATED_FLAG)
      values (
           gms_adls_award_set_id_s.nextval,        -- award_set_id
           1,                                      -- adl_line_num
           null,                                   -- funding_pattern_id
           100,                                    -- distribution_rule
           null,                                   -- raw_cost
           'AP',                                   -- document_type
           t_project_id(i),                        -- project_id
           t_task_id(i),                           -- task_id
           t_award_id(i),                          -- award_id
           null,                                   -- expenditure_item_id
           null,                                   -- cdl_line_num
           t_ind_compiled_set_id(i),               -- ind_compiled_set_id
           null,                                   -- gl_date
           t_request_id(i),                        -- request_id
           null,                                   -- line_num_reversed
           t_rlmi_id(i),                           -- resource_list_member_id
           null,                                   -- output_vat_tax_id
           null,                                   -- output_tax_exempt_flag
           null,                                   -- output_tax_exempt_reason_code
           null,                                   -- output_tax_exempt_number
           'A',                                    -- adl_status
           decode(v_source,
                  'Oracle Project Accounting', 'A',
                  'N'),                            -- fc_status
           'R',                                    -- line_type
           null,                                   -- capitalized_flag
           null,                                   -- capitalizable_flag
           null,                                   -- reversed_flag
           'N',                                    -- revenue_distributed_flag
           'N',                                    -- billed_flag
           null,                                   -- bill_hold_flag
           null,                                   -- distribution_id
           null,                                   -- po_distribution_id
           t_invoice_distribution_id(i),           -- invoice_distribution_id
           null,                                   -- parent_award_set_id
           p_invoice_id(inv_index),                -- invoice_id
           null,                                   -- parent_adl_line_num
           t_distribution_line_number(i),          -- distribution_line_number
           t_burdenable_cost(i),                   -- burdenable_raw_cost
           null,                                   -- cost_distributed_flag
           t_date(i),                              -- last_update_date
           t_created_by(i),                        -- last_updated_by
           t_created_by(i),                        -- created_by
           t_date(i),                              -- creation_date
           t_created_by(i),                        -- last_update_login
           t_bud_task_id(i),                       -- bud_task_id
           'N',                                    -- billable_flag
           'N')                                    -- accumulated_flag
           returning award_set_id bulk collect
                           into t_award_set_id;

    forall asi in t_award_set_id.first..t_award_set_id.last
       update ap_invoice_distributions_all
          set award_id = t_award_set_id(asi)
        where invoice_id = p_invoice_id(inv_index)
          and distribution_line_number = t_distribution_line_number(asi);

   <<no_lines>>
      null;

 end loop;

exception
  when others then
    -- dbms_output.put_line('Exception ' || sqlerrm);
    app_exception.raise_exception;
end create_award_distributions;
----------------------------------------------------------------------------------

PROCEDURE GMS_ENABLED(p_gms_enabled	 out NOCOPY 	number) IS

BEGIN

  if gms_install.enabled then
     p_gms_enabled := 1;
  else
     p_gms_enabled := 0;
  end if;

END GMS_ENABLED;
-----------------------------------------------------------------------------------
END GMS_OIE_INT_PKG;

/
