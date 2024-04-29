--------------------------------------------------------
--  DDL for Package Body PA_CC_AR_AP_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_AR_AP_TRANSFER" AS
/* $Header: PAXARAPB.pls 120.8.12010000.2 2008/08/22 14:08:33 nkapling ship $ */

----------------------------------------------------------------
--Procedure Transfer_ar_ap_invoices is a  wrapper to convert the
--data types for input parameters
----------------------------------------------------------------
Procedure Transfer_ar_ap_invoices(
                     p_internal_billing_type in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_project_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_draft_invoice_number in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_ra_invoice_number in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_prvdr_org_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_recvr_org_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_customer_trx_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_project_customer_id in PA_PLSQL_DATATYPES.Char30TabTyp,
                     p_invoice_date in PA_PLSQL_DATATYPES.Char15TabTyp,
                     p_invoice_comment in PA_PLSQL_DATATYPES.Char240TabTyp,
                     p_inv_currency_code in PA_PLSQL_DATATYPES.Char15TabTyp,
                     p_compute_flag in PA_PLSQL_DATATYPES.Char1TabTyp,
                     p_array_size  in number,
                     x_transfer_status_code out NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,/*file.sql.39*/
                     x_transfer_error_code out NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,/*file.sql.39*/
                     x_status_code   out NOCOPY varchar2 /*file.sql.39*/) IS

--v_project_id PA_PLSQL_DATATYPES.NumTabTyp;
--v_draft_invoice_number PA_PLSQL_DATATYPES.NumTabTyp;
v_prvdr_org_id PA_PLSQL_DATATYPES.NumTabTyp;
v_recvr_org_id  PA_PLSQL_DATATYPES.NumTabTyp;
v_customer_trx_id  PA_PLSQL_DATATYPES.NumTabTyp;
v_project_customer_id  PA_PLSQL_DATATYPES.NumTabTyp;
v_invoice_date PA_PLSQL_DATATYPES.DateTabTyp;
--v_array_size number;
v_debug_mode varchar2(2);
v_process_mode varchar2(10);


begin
--v_array_size:=to_number(p_array_size);
for i in 1..p_array_size LOOP
--  v_project_id(i):=to_number(p_project_id(i));
 -- v_draft_invoice_number(i):=to_number(p_draft_invoice_number(i));
  v_prvdr_org_id(i):=to_number(p_prvdr_org_id(i));
  v_recvr_org_id(i):=to_number(p_recvr_org_id(i));
  v_customer_trx_id(i):=to_number(p_customer_trx_id(i));
  v_project_customer_id(i):=to_number(p_project_customer_id(i));
  v_invoice_date(i):=fnd_date.canonical_to_date(p_invoice_date(i));
end loop;

Transfer_ar_ap_invoices_01(
                     v_debug_mode ,
                     v_process_mode ,
                     p_internal_billing_type ,
                     p_project_id ,
                     p_draft_invoice_number ,
                     p_ra_invoice_number ,
                     v_prvdr_org_id ,
                     v_recvr_org_id ,
                     v_customer_trx_id ,
                     v_project_customer_id ,
                     v_invoice_date ,
                     p_invoice_comment ,
                     p_inv_currency_code ,
                     p_compute_flag ,
                     p_array_size  ,
                     x_transfer_status_code,
                     x_transfer_error_code ,
                     x_status_code   );

end Transfer_ar_ap_invoices;

--------------------------------------------------------
--Procedure Transfer_ar_ap_invoices_01 is the main procedure
--in which sub procedures are called
-----------------------------------------------------------
Procedure Transfer_ar_ap_invoices_01(
                     p_debug_mode   in varchar2,
                     p_process_mode in varchar2,
                     p_internal_billing_type in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_project_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_draft_invoice_number in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_ra_invoice_number in PA_PLSQL_DATATYPES.Char20TabTyp,
                     p_prvdr_org_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_recvr_org_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_customer_trx_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_project_customer_id in PA_PLSQL_DATATYPES.NumTabTyp,
                     p_invoice_date in PA_PLSQL_DATATYPES.DateTabTyp,
                     p_invoice_comment in PA_PLSQL_DATATYPES.Char240TabTyp,
                     p_inv_currency_code in PA_PLSQL_DATATYPES.Char15TabTyp,
                     p_compute_flag in PA_PLSQL_DATATYPES.Char1TabTyp,
                     p_array_size  in Number,
                     x_transfer_status_code out NOCOPY PA_PLSQL_DATATYPES.Char1TabTyp,/*file.sql.39*/
                     x_transfer_error_code out NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,/*file.sql.39*/
                     x_status_code   out NOCOPY varchar2 /*file.sql.39*/) IS

Cursor  c_setup_info(p_prvdr_org_id in number, p_recvr_org_id in number) is
 select a.vendor_site_id vendor_site_id ,
         a.ap_inv_exp_type expenditure_type,
         a.ap_inv_exp_organization_id  expenditure_organization_id,
         b.vendor_id vendor_id
from pa_cc_org_relationships a,
         po_vendor_sites_all b
where  a.prvdr_org_id= p_prvdr_org_id
  and       a.recvr_org_id= p_recvr_org_id
and   a.vendor_site_id =b.vendor_site_id;

Cursor c_invoice_amount (p_customer_trx_id in number) is
 select sum(extended_amount) amount
  from  ra_customer_trx_lines_all
  where  customer_trx_id = p_customer_trx_id;


Cursor c_receiver_project_task (p_project_customer_id  in number,p_project_id in number) is
 select ppc.receiver_task_id task_id,
          pt.project_id project_id
 from pa_project_customers ppc,
         pa_tasks  pt
 where pt.task_id=ppc.receiver_task_id
 and    ppc.customer_id=p_project_customer_id
 and    ppc.project_id=p_project_id;

Cursor c_invoice_lines_counter(p_project_id in number,p_draft_invoice_number in number)IS
       select count(*) lines_counter from pa_draft_invoice_items
       where project_id=p_project_id
       and  draft_invoice_num=p_draft_invoice_number
       and  invoice_line_type <> 'NET ZERO ADJUSTMENT';/* added as fix for Bug 1580854 */

Cursor c_invoice_lines(p_project_id in number,
                       p_draft_invoice_number in number,
                       p_recvr_org_id in number,
                       p_customer_trx_id in number)IS
                  SELECT       pdii.line_num line_number,
                               pdii.inv_amount amount,
                               nvl(pdii.translated_text, pdii.text) description,
                               pdii.output_tax_classification_code tax_code,
                               --aptax.name tax_code,
                               --pdii.output_vat_tax_id tax_id,
                               pdii.cc_project_id project_id,
                               pdii.cc_tax_task_id task_id,
                               pdii.inv_amount pa_quantity,
                               arinv.line_number pa_cc_ar_invoice_line_num,
                               arinv.customer_trx_line_id cust_trx_line_id -- added for bug 5045406
                    FROM       pa_draft_invoice_items pdii,
                               ra_customer_trx_lines_all arinv
--                               ap_tax_codes_all aptax,
--                               ar_vat_tax_all artax
                    where      arinv.interface_line_attribute6= pdii.line_num
                    and         arinv.customer_trx_id = p_customer_trx_id
                    and         pdii.project_id=p_project_id
                    and         pdii.draft_invoice_num=p_draft_invoice_number
                    and        pdii.output_tax_classification_code IS NOT NULL
                    and        pdii.invoice_line_type <> 'NET ZERO ADJUSTMENT' /* added as fix for Bug 2397907 */
--                    and        pdii.output_vat_tax_id =  artax.vat_tax_id
--                    and        artax.tax_code= aptax.name
--                    and        pdii.output_vat_tax_id is not null
--                    and          aptax.org_id= p_recvr_org_id
          UNION
SELECT       pdii.line_num line_number,
                               pdii.inv_amount amount,
                               nvl(pdii.translated_text, pdii.text) description,
                               null tax_code,
--                               pdii.output_vat_tax_id tax_id,
                               pdii.cc_project_id project_id,
                               pdii.cc_tax_task_id task_id,
                               pdii.inv_amount pa_quantity,
                               arinv.line_number pa_cc_ar_invoice_line_num,
                               arinv.customer_trx_line_id cust_trx_line_id -- added for bug 5045406
                    FROM       pa_draft_invoice_items pdii,
                               ra_customer_trx_lines_all arinv
                    where      arinv.interface_line_attribute6= pdii.line_num
                    and        pdii.project_id=p_project_id
                    and        pdii.draft_invoice_num=p_draft_invoice_number
                    and        arinv.customer_trx_id =p_customer_trx_id
                    and        pdii.invoice_line_type <> 'NET ZERO ADJUSTMENT' /* added as fix for Bug 2397907 */
                    and        pdii.output_Tax_classificatioN_code IS NULL;
--                    and        pdii.output_vat_tax_id is null;

v_invoice_id number;
v_request_id number :=fnd_global.conc_request_id;
v_receiver_project_id number;
v_receiver_task_id number;
v_expenditure_type  varchar2(30);
v_expenditure_organization_id number;
v_error_code number;
v_receiver_project_task c_receiver_project_task%ROWTYPE;
v_setup_info c_setup_info%ROWTYPE;
v_invoice_amount c_invoice_amount%ROWTYPE;
x_error_stage varchar2(250);
v_debug_mode varchar2(2);
v_process_mode varchar2(10);
v_old_stack VARCHAR2(630);
v_invoice_type varchar2(30); -- added for etax changes
v_invoice_lines_rec c_invoice_lines%ROWTYPE;
v_invoice_line_num PA_PLSQL_DATATYPES.NumTabTyp;
v_inv_amount PA_PLSQL_DATATYPES.NumTabTyp;
v_description PA_PLSQL_DATATYPES.Char240TabTyp;
v_tax_code PA_PLSQL_DATATYPES.Char50TabTyp;
--v_tax_id  PA_PLSQL_DATATYPES.NumTabTyp;
v_project_id  PA_PLSQL_DATATYPES.NumTabTyp;
v_task_id PA_PLSQL_DATATYPES.NumTabTyp;
v_pa_quantity PA_PLSQL_DATATYPES.NumTabTyp;
v_pa_cc_ar_inv_line_num PA_PLSQL_DATATYPES.NumTabTyp;
v_cust_trx_line_id  PA_PLSQL_DATATYPES.NumTabTyp; -- bug 5045406
v_lines_counter_rec c_invoice_lines_counter%ROWTYPE;
v_lines_counter number;
v_counter number :=0;

-- DevDrop2 Changes Starts

l_status       number;
l_error_stage  varchar2(250);
l_error_code number;
dummy_x      varchar2(1);
l_expenditure_type varchar2(50);
l_expenditure_organization_id number;

l_receiver_project_id  number;
l_receiver_task_id     number;

v_arr_exp_type  PA_PLSQL_DATATYPES.Char50TabTyp;
v_arr_exp_organization_id  PA_PLSQL_DATATYPES.NumTabTyp;

-- DevDrop2 Changes End

Begin

pa_debug.Init_err_stack ( 'Transfer_ar_ap_invoices');
v_debug_mode := NVL(p_debug_mode, 'Y');
v_process_mode := NVL(p_process_mode, 'SQL');
pa_debug.set_process(v_process_mode, 'LOG', v_debug_mode) ;
x_status_code :=null;
pa_debug.G_err_code:='0';

--- Is it necessary to validate p_array_size here? how about if it is null or 0?

pa_debug.G_err_stage := 'Beginning LOOP';
pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
For I in 1..p_array_size LOOP
      x_transfer_status_code(I):='P';
      x_transfer_error_code(I):=null;
      x_status_code:=null;

      pa_debug.G_err_stage := 'Check if any mandatory input parameter is null';
      pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
      if p_internal_billing_type(I) is null or
         p_project_id(I) is null or
         p_draft_invoice_number(I) is null or
         p_ra_invoice_number(I) is null or
         p_prvdr_org_id(I) is null or
         p_recvr_org_id(I) is null or
         p_customer_trx_id(I) is null or
         p_invoice_date(I) is null or
       /*  p_invoice_comment(I) is null or */
         p_inv_currency_code(I) is null   then
              x_transfer_status_code(I):='X';
              x_transfer_error_code(I):='PA_CC_AR_AP_NULL_PARAMETER';
              x_status_code:='-1';
      end if;
      if nvl(p_compute_flag(I),'Y')='Y' then
             pa_debug.G_err_stage := 'Check if vendor and expenditure information is valid';
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
             open  c_setup_info(p_prvdr_org_id(I), p_recvr_org_id(I));
             LOOP
              fetch c_setup_info into v_setup_info;
              if c_setup_info%ROWCOUNT =1 then
                  v_expenditure_type:=v_setup_info.expenditure_type;
                  v_expenditure_organization_id:=v_setup_info.expenditure_organization_id;
                  exit;
              elsif  c_setup_info%ROWCOUNT=0 then
                  x_transfer_status_code(I):='X';
                  x_transfer_error_code(I):='PA_CC_AR_AP_NO_SETUP_INFO';
                  x_status_code:='-1';
                  exit;
              elsif c_setup_info%ROWCOUNT>1 then
                  x_transfer_status_code(I):='X';
                 x_transfer_error_code(I):='PA_CC_AR_AP_NO_UNQ_SETUP';
                  x_status_code:='-1';
                  exit;
              end if;
             END LOOP;
             close c_setup_info;

             pa_debug.G_err_stage := 'Check if invoice amount is valid';
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
             open  c_invoice_amount (p_customer_trx_id(I));
             fetch c_invoice_amount into v_invoice_amount;
             if c_invoice_amount%NOTFOUND then
                x_transfer_status_code(I):='X';
                x_transfer_error_code(I):='PA_CC_AR_AP_NO_INV_AMOUNT';
                x_status_code:='-1';
             end if;
             close c_invoice_amount;

             pa_debug.G_err_stage := 'Check if receiver project and task is valid';
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
             if p_internal_billing_type(I) ='PA_IP_INVOICES' then
                 open c_receiver_project_task(p_project_customer_id(I),p_project_id(I));
                 LOOP
                    fetch c_receiver_project_task into v_receiver_project_task;
                    if c_receiver_project_task%ROWCOUNT =1 then
                         v_receiver_project_id:=v_receiver_project_task.project_id;
                         v_receiver_task_id:=v_receiver_project_task.task_id;
                         exit;
                    elsif  c_receiver_project_task%ROWCOUNT =0 then
                        x_transfer_status_code(I):='X';
                        x_transfer_error_code(I):='PA_CC_AR_AP_NO_REC_PROJ_TASK';
                        x_status_code:='-1';
                        exit;
                   elsif c_receiver_project_task%ROWCOUNT>1 then
                        x_transfer_status_code(I):='X';
                        x_transfer_error_code(I):='PA_CC_AR_AP_MUL_REC_PROJ_TSK';
                        x_status_code:='-1';
                        exit;
                   end if;
                 END LOOP;
                 close c_receiver_project_task;
            end if;

            select ap_invoices_interface_s.nextval into v_invoice_id from sys.dual;

            pa_debug.G_err_stage := 'Check if tax code is null';
            pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
            open  c_invoice_lines_counter(p_project_id(I),p_draft_invoice_number(I));
            fetch c_invoice_lines_counter into v_lines_counter;
            close c_invoice_lines_counter;

	    v_counter := 0;  /* for bug 6594692 */


             -- The following sql added for etax changes
            select decode(draft_invoice_num_credited, NULL, 'INVOICE', 'CREDIT_MEMO')
            into v_invoice_type
            from pa_draft_invoices_all
            where project_id = p_project_id(I)
            and draft_invoice_num = p_draft_invoice_number(I);

            FOR v_invoice_lines_rec IN  c_invoice_lines(p_project_id(I) ,p_draft_invoice_number(I) ,p_recvr_org_id(I), p_customer_trx_id(I)) LOOP
              v_counter:=c_invoice_lines%ROWCOUNT;
              v_invoice_line_num(v_counter):=v_invoice_lines_rec.line_number;
              v_inv_amount(v_counter):=v_invoice_lines_rec.amount;
              v_description(v_counter):=v_invoice_lines_rec.description;
              v_tax_code(v_counter):=v_invoice_lines_rec.tax_code;
--              v_tax_id(v_counter):=v_invoice_lines_rec.tax_id;
              v_project_id(v_counter):=v_invoice_lines_rec.project_id;
              v_task_id(v_counter):=v_invoice_lines_rec.task_id;
              v_pa_quantity(v_counter):=v_invoice_lines_rec.pa_quantity;
              v_pa_cc_ar_inv_line_num(v_counter):=v_invoice_lines_rec.pa_cc_ar_invoice_line_num;
              v_cust_trx_line_id(v_counter) := v_invoice_lines_rec.cust_trx_line_id ; -- bug 5045406
            END LOOP;
            if v_lines_counter <> v_counter then
                x_transfer_status_code(I):='X';
                x_transfer_error_code(I):='PA_CC_AR_AP_NO_TAX_CODE';
                x_status_code:='-1';
            end if;


-- DevDrop2 Changes Start */
-- Calling the client extension to override the expenditure type and
-- expenditure organization id for each ap invoice line

if  x_status_code is null then

   pa_debug.G_err_stage := 'Calling Client Extension override_exp_type_exp_org';
   pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

   FOR K in 1..v_counter LOOP

-- Call Client Extension to override expenditure type and
-- expenditure organization of the ap inovice lines.

-- driver receiver project and task id

   if ( p_internal_billing_type(I) = 'PA_IC_INVOICES' ) then

    l_receiver_project_id := v_project_id(K);
    l_receiver_task_id    := v_task_id(K);
   else
    l_receiver_project_id := v_receiver_project_id;
    l_receiver_task_id    := v_receiver_task_id;
   end if;


   pa_cc_ap_inv_client_extn.override_exp_type_exp_org (
              p_internal_billing_type      =>  p_internal_billing_type(I),
          p_project_id                     =>  p_project_id(I),
          p_receiver_project_id            =>  l_receiver_project_id,
          p_receiver_task_id               =>  l_receiver_task_id,
          p_draft_invoice_number           =>  p_draft_invoice_number(I),
          p_draft_invoice_line_num         =>  v_invoice_line_num(K),
          p_invoice_date                   =>  p_invoice_date(I),
          p_ra_invoice_number              =>  p_ra_invoice_number(I),
          p_provider_org_id                =>  p_prvdr_org_id(I),
          p_receiver_org_id                =>  p_recvr_org_id(I),
          p_cc_ar_invoice_id               =>  p_customer_trx_id(I),
          p_cc_ar_invoice_line_num         =>  v_pa_cc_ar_inv_line_num(K),
          p_project_customer_id            =>  p_project_customer_id(I),
          p_vendor_id                      =>  v_setup_info.vendor_id,
          p_vendor_site_id                 =>  v_setup_info.vendor_site_id,
          p_expenditure_type               =>  v_expenditure_type,
          p_expenditure_organization_id    =>  v_expenditure_organization_id,
          x_expenditure_type               =>  l_expenditure_type,
          x_expenditure_organization_id    =>  l_expenditure_organization_id,
          x_status                         =>  l_status,
          x_Error_Stage                    =>  l_error_stage,
          X_Error_Code                     =>  l_error_code) ;

          if ( l_status <> 0 ) then

             pa_debug.G_err_stage := 'Error Client Extension(Call) : draft_inv_num :'||p_draft_invoice_number(I)||
                                     ' draft_inv_line_num :'||v_invoice_line_num(K);
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

                x_transfer_status_code(I):='X';
                x_transfer_error_code(I):='PA_CC_AR_AP_ERR_CLIENT_EXTN';
                x_status_code:= '-1';
          end if;

          if ( l_status = 0 ) then

-- Check Expenditure Type

           if ( l_expenditure_type <> v_expenditure_type ) then

--  Validate the expenditure type.
--  l_expenditure_type should be valid one for expenditure class supplier invoice.

              begin
                    select 'x'
                    into   dummy_x
                    from  dual
                    where EXISTS
                       ( select 'x' from
                         pa_expend_typ_sys_links
                         where system_linkage_function = 'VI'
                         and expenditure_type = l_expenditure_type);

               v_arr_exp_type(K) := l_expenditure_type;
              exception
               when no_data_found then
             pa_debug.G_err_stage := 'Error Client Extension(Exp_type): draft_inv_num :'||
                                     p_draft_invoice_number(I)||' draft_inv_line_num :'||
                                     v_invoice_line_num(K);
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

             pa_debug.G_err_stage := 'override exp_type : '||l_expenditure_type;
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

                 x_transfer_status_code(I):='X';
                 x_transfer_error_code(I):='PA_CC_AR_AP_INVLD_EXP_TYP';
                 x_status_code:= '-1';
              end;

           else
              v_arr_exp_type(K) := v_expenditure_type;
           end if;


-- Check Expenditure Organization

           if ( l_expenditure_organization_id <> v_expenditure_organization_id ) then

--  Validate the l_expenditure_organization_id.
--  l_expenditure_organization_id should be valid expenditure organization for
--  receiver operating unit.

              begin
                    select 'x'
                    into   dummy_x
                    from  dual
                    where EXISTS
                       ( select 'x' from
                         pa_all_organizations
                         where org_id = p_recvr_org_id(I)
                         and organization_id = l_expenditure_organization_id
                         and PA_ORG_USE_TYPE = 'EXPENDITURES');

               v_arr_exp_organization_id(K) := l_expenditure_organization_id;
              exception
               when no_data_found then
             pa_debug.G_err_stage := 'Error Client Extension(Exp_org): draft_inv_num :'||p_draft_invoice_number(I)||
                                     ' draft_inv_line_num :'||v_invoice_line_num(K);
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

             pa_debug.G_err_stage := 'override exp_orgz_id'||l_expenditure_organization_id;
             pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

                 x_transfer_status_code(I):='X';
                 x_transfer_error_code(I):='PA_CC_AR_AP_INVLD_EXP_ORG';
                 x_status_code:= '-1';
              end;

           else
              v_arr_exp_organization_id(K) := v_expenditure_organization_id;
           end if;

          end if;

   END LOOP;
end if;

-- DevDrop2 Changes End

            if x_status_code is null then
                pa_debug.G_err_stage := 'Insert into AP_invoices_interface table';
                pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
                populate_ap_invoices_interface (
                      p_internal_billing_type(I),
                      v_invoice_id,
                      p_ra_invoice_number(I),
                      p_invoice_date(I),
                      v_setup_info.vendor_id,
                      v_setup_info.vendor_site_id,
                      v_invoice_amount.amount,
                      p_inv_currency_code(I),
                      p_invoice_comment(I),
                      to_char(v_request_id),
                      NULL,                /*1994696*:Changed workflow_flag from 'Y' to NULL*/
                      p_recvr_org_id(I));
                pa_debug.G_err_stage := 'Insert into AP_invoice_lines_interface table';
                pa_debug.write_file( 'LOG', pa_debug.G_err_stage);

--DevDrop2 Changes
--Changed expenditure type , expenditure organization id to
--v_arr_exp_type , v_arr_exp_organization_id respectively

                Populate_ap_inv_line_interface(
                   v_invoice_id,
                   p_internal_billing_type(I) ,
                   v_receiver_project_id,
                   v_receiver_task_id ,
                   v_arr_exp_type ,
                   p_invoice_date(I)  ,
                   v_arr_exp_organization_id ,
                   p_recvr_org_id(I) ,
                   p_customer_trx_id(I),
                   p_project_customer_id(I),
                   v_invoice_line_num ,
                   v_inv_amount  ,
                   v_description ,
                   v_tax_code  ,
                   v_project_id  ,
                   v_task_id   ,
                   v_pa_quantity  ,
                   v_pa_cc_ar_inv_line_num  ,
                   v_counter,
                   v_invoice_type, -- added for etax changes
                   v_cust_trx_line_id ); -- added for bug 5045406
                x_transfer_status_code(I) :='A';
         end if;
   end if;
END LOOP;

If x_status_code is null then
  x_status_code:='0';
end if;

pa_debug.reset_err_stack;

Exception
 when others then
 pa_debug.G_err_code := SQLCODE;
 pa_debug.G_err_stage:=pa_debug.G_err_stage|| ': '||sqlerrm;
 pa_debug.write_file( 'LOG', pa_debug.G_err_stage);
 x_status_code:=-1;
 RAISE;
end transfer_ar_ap_invoices_01;


----------------------------------------------------
--procedure Populate_ap_invoices_interface
--transfer invoices to ap_invoices_interface table
-------------------------------------------------
procedure  Populate_ap_invoices_interface(
                     p_internal_billing_type in varchar2,
                     p_invoice_id in number,
                     p_invoice_number in varchar2,
                     p_invoice_date in date,
                     p_vendor_id in number,
                     p_vendor_site_id in number,
                     p_invoice_amount number,
                     p_invoice_currency_code in varchar2,
                     p_description in varchar2,
                     p_group_id in varchar2,
                     p_workflow_flag in varchar2,
                     p_org_id in number)
IS
             begin
                  pa_debug.set_err_stack('populate_ap_invoices_interface');
                  Insert into ap_invoices_interface (
                    invoice_id,
                    invoice_num,
                    invoice_date,
                    vendor_id,
                    vendor_site_id,
                    invoice_amount,
                    invoice_currency_code,
                    description,
                    source,
                    group_id,
                    workflow_flag,
                    calc_tax_during_import_flag, -- added for bug 5045406
                    org_id,
                    created_by ,
                    last_update_login ,
                    last_updated_by,
                    creation_date ,
                    last_update_date,
                    invoice_received_date) /* Added for bug 3658825*/
              values (p_invoice_id,
                     p_invoice_number,
                     p_invoice_date,
                     p_vendor_id,
                     p_vendor_site_id,
                     p_invoice_amount,
                     p_invoice_currency_code,
                     p_description,
                     decode(p_internal_billing_type,'PA_IC_INVOICES','PA_IC_INVOICES','PA_IP_INVOICES'),
                     p_group_id,
                     p_workflow_flag,
                     'Y', -- added for bug 5045406
                     p_org_id,
                    G_created_by,
                    G_last_update_login,
                    G_last_updated_by  ,
                    G_creation_date   ,
                    G_last_update_date,
                    sysdate); /* Added for bug 3658825*/
               pa_debug.reset_err_stack;
             exception
                    when others then
                        pa_debug.G_err_code :=SQLCODE;
                        pa_debug.G_err_stage:= pa_debug.G_err_stage||':'||sqlerrm;
                    Raise;
             End populate_ap_invoices_interface;


----------------------------------------------------------------------------------
---procedure Populate_ap_inv_line_interface
----populates ap_invoice_lines_interface table
-------------------------------------------------------------------------------

--DevDrop2 Changes
--Changed datatype of p_expenditure_type
--Changed datatype of p_expenditure_organization_id

procedure      Populate_ap_inv_line_interface(
                   p_invoice_id in number,
                   p_internal_billing_type in varchar2,
                   p_receiver_project_id in number,
                   p_receiver_task_id in number,
                   p_expenditure_type in PA_PLSQL_DATATYPES.Char50TabTyp,
                   p_invoice_date in date ,
                   p_expenditure_organization_id in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_recvr_org_id  in number,
                   p_customer_trx_id in number,
                   p_project_customer_id in number,
                   p_invoice_line_number in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_inv_amount  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_description  in PA_PLSQL_DATATYPES.Char240TabTyp,
                   p_tax_code in  PA_PLSQL_DATATYPES.Char50TabTyp,
                   p_project_id  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_task_id in  PA_PLSQL_DATATYPES.NumTabTyp,
                   p_pa_quantity  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_pa_cc_ar_inv_line_num  in PA_PLSQL_DATATYPES.NumTabTyp,
                   p_sub_array_size in number,
                   p_invoice_type in VARCHAR2, -- added for etax changtes
                   p_cust_trx_line_id in PA_PLSQL_DATATYPES.NumTabTyp -- added for bug 5045406
                   )
       IS

         -- the following var declarations added for etax changes

           l_application_id number;
           l_entity_code varchar2(30);
           l_event_class_code varchar2(30);
           l_trx_id number;
           l_trx_level_type varchar2(30);

       begin
/*Bug# 2042840:Modified the value of pa_addition_flag from hardcoded 'N' to
decode(p_internal_billing_type,'PA_IC_INVOICES','T','N').*/
                pa_debug.set_err_stack('Populate_ap_inv_line_interface');

                     -- the following block added for etax changes
                    begin
                       SELECT APPLICATION_ID, ENTITY_CODE,
                             EVENT_CLASS_CODE, TRX_ID, TRX_LEVEL_TYPE
                        into l_application_id, l_entity_code, l_event_class_code, l_trx_id, l_trx_level_type
                       FROM ZX_LINES_DET_FACTORS
                       WHERE trx_id = p_customer_trx_id
                       AND   application_id =  222
                       AND   entity_Code = 'TRANSACTIONS'
                       AND    event_class_code = p_invoice_type
                        AND   rownum = 1;
                    exception
                        when others then
                         l_application_id := 222;
                         l_entity_code := 'TRANSACTIONS';
                         l_event_class_code := p_invoice_type;
                         l_trx_id := p_customer_trx_id;
                         l_trx_level_type := 'NO DATA ERR';

                    end;

                FORALL i in 1..p_sub_array_size
                INSERT INTO   ap_invoice_lines_interface(
                               invoice_id,
                               line_number,
                               line_type_lookup_code,
                               amount,
                               description,
                               amount_includes_tax_flag,
                               prorate_across_flag,
                               tax_classification_code,/*Changed for bug 4882123 */
                               final_match_flag,
                               last_updated_by,
                               last_update_date,
                               last_update_login,
                               created_by,
                               creation_date,
                               project_id,
                               task_id,
                               expenditure_type,
                               expenditure_item_date,
                               expenditure_organization_id,
                               project_accounting_context,
                               pa_addition_flag,
                               pa_quantity,
                               org_id,
                               pa_cc_ar_invoice_id,
                               pa_cc_ar_invoice_line_num,
                               TAX_CODE_OVERRIDE_FLAG,
                               SOURCE_APPLICATION_ID,
                               SOURCE_ENTITY_CODE,
                               SOURCE_EVENT_CLASS_CODE,
                               SOURCE_TRX_ID,
                               SOURCE_TRX_LEVEL_TYPE,
                               SOURCE_LINE_ID -- added for bug 5045406
                            )
                    VALUES(    p_invoice_id,
                               p_invoice_line_number(i),
                               'ITEM',
                               p_inv_amount(i),
                               p_description(i),
                               'N',
                               'N',
                               p_tax_code(i),
                               'N',
                               G_last_updated_by,
                               G_last_update_date,
                               G_last_update_login,
                               G_created_by,
                               G_creation_date,
                               decode(p_internal_billing_type, 'PA_IC_INVOICES', p_project_id(i), p_receiver_project_id),
                               decode(p_internal_billing_type,'PA_IC_INVOICES',p_task_id(i), p_receiver_task_id),
                               p_expenditure_type(i),
                               (select least(NVL(completion_date,p_invoice_date),p_invoice_date) from pa_tasks pt where pt.task_id =decode(p_internal_billing_type,'PA_IC_INVOICES',p_task_id(i), p_receiver_task_id)), /* Modified this for bug 7234925*/
                               p_expenditure_organization_id(i),
                               'Yes',
                               decode(p_internal_billing_type,'PA_IC_INVOICES','T','N'),/*Bug# 2042840*/
                               p_pa_quantity(i),
                               p_recvr_org_id,
                               p_customer_trx_id,
                               p_pa_cc_ar_inv_line_num(i),
                               'Y',
                               l_application_id, -- added for etax changes
                               l_entity_code,  -- added for etax changes
                               'INTERCOMPANY_TRX',  -- l_event_class_code,  -- added for etax changes
                               l_trx_id,  -- added for etax changes
                               'LINE' ,    -- l_trx_level_type -- added for etax changes
                               p_cust_trx_line_id(i) -- added for bug 5045406
                               );

       pa_debug.reset_err_stack;
       exception
           when others then
              pa_debug.G_err_code:=SQLCODE;
              pa_debug.G_err_stage:=pa_debug.G_err_stage||':'||sqlerrm;
              raise;
         END populate_ap_inv_line_interface;

end PA_CC_AR_AP_TRANSFER;

/
