--------------------------------------------------------
--  DDL for Package Body PA_AP_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AP_VAL_PKG" AS
-- /* $Header: PAAPVALB.pls 120.0.12010000.5 2010/03/31 13:24:59 sesingh noship $ */

 P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
 g_api_name      VARCHAR2(30) :='Validate_unprocessed_ded';

 -- This procedure is for logging debug messages
  Procedure log_message (p_log_msg IN VARCHAR2,p_proc_name VARCHAR2)  ;

  PROCEDURE log_message (p_log_msg IN VARCHAR2,p_proc_name VARCHAR2) IS
  BEGIN
      pa_debug.write('log_message: ' || p_proc_name, 'log: ' || p_log_msg, 3);
  END log_message;

/*---------------------------------------------------------------------------------------------------------
    --  This procedure is to validate a Retainage Release invoice in payables. This is called from Payables
    -- Input parameters
    --  Parameters                Type           Required  Description
    --  invoice_id              NUMBER            YES      invoice_id being validated
    -- cmt_exist_flag           VARCHAR                     returns whether unprocessed dedns exist
	----------------------------------------------------------------------------------------------------------*/
	Procedure validate_unprocessed_ded ( invoice_id IN ap_invoices_all.invoice_id%type,
				       	     cmt_exist_flag OUT NOCOPY VARCHAR2)
IS

--Cursor check_cmt_exist will check the number of deductions that have not yet
--resulted in a debit memo in payables. It will include the deductions
--in working,submitted statuses as well.


cursor check_cmt_exist(p_invoice_id ap_invoices_all.invoice_id%type) is
select 1 from pa_deductions_all
where not exists
(select 1 from ap_invoices_all
 where source = 'Oracle Project Accounting'
  AND    invoice_type_lookup_code = 'DEBIT'
  AND    product_table='PA_DEDUCTIONS_ALL'
  and deduction_req_id = to_number(reference_key1))
  and (vendor_id, project_id) in (select inv.vendor_id, apd.project_id
  from ap_invoices_all inv, ap_invoice_distributions_all apd
  where inv.invoice_id =p_invoice_id
  and inv.invoice_id=apd.invoice_id);


l_invoice_id 	ap_invoices_all.invoice_id%type;
l_count NUMBER;

BEGIN

l_invoice_id := invoice_id;
IF P_DEBUG_MODE = 'Y' THEN
      log_message ('Entered validate_unprocessed_ded with invoice_id = '||l_invoice_id,g_api_name);
     END IF;

open check_cmt_exist(l_invoice_id);
fetch check_cmt_exist into l_count;
close check_cmt_exist;

IF P_DEBUG_MODE = 'Y' THEN
      log_message ('Value of l_count in validate_unprocessed_ded = '||l_count,g_api_name);
     END IF;

if l_count > 0 then
cmt_exist_flag := 'Y'; -- return Y, because unprocessed deductions exist
else
cmt_exist_flag := 'N'; -- return N, no unprocessed deductions exist
end if;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

end validate_unprocessed_ded;

END PA_AP_VAL_PKG ;

/
