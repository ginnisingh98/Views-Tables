--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_TIEBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_TIEBACK" as
/* $Header: PAXVINTB.pls 120.0.12000000.3 2007/10/18 06:18:47 srathi ship $ */

PROCEDURE Validate_inv_acct_amt
                      ( P_project_id         IN   num_arr,
                        P_draft_inv_num      IN   num_arr,
                        P_project_num        IN   var_arr_25,
                        P_cust_trx_id        IN   num_arr,
                        P_user_id            IN   NUMBER,
                        P_request_id         IN   NUMBER,
                        P_num_of_rec         IN   NUMBER,
                        P_out_error         OUT  NOCOPY   var_arr_01 )
AS
  Cursor cur_get_line_amt ( l_draft_inv_num  number,
                            l_project_id       number)
  Is
     SELECT dii.acct_amount acct_amt,
            dii.line_num line_num
     FROM   pa_draft_invoice_items dii
     WHERE  dii.project_id    = l_project_id
     AND    dii.draft_invoice_num = l_draft_inv_num;

  Cursor cur_get_ar_amt ( l_project_num        VARCHAR2,
                          l_cust_trx_id        NUMBER,
                          l_draft_invoice_num  NUMBER,
                          l_line_num           NUMBER )
  Is
   /* Commented the code change done for bug 4022244 and modified the previous
      query as below for this bug 6443623 */
  Select  sum(tgl.acctd_amount)
     from   ra_cust_trx_line_gl_dist_all tgl,
            ra_customer_trx_lines trx
     where  trx.customer_trx_id = l_cust_trx_id
     and    trim(trx.interface_line_attribute6)
                  = to_char(l_line_num)
     and    rtrim(ltrim(trx.interface_line_attribute1)) = l_project_num
     and    tgl.customer_trx_line_id = trx.customer_trx_line_id
     and    tgl.account_class = 'REV';

/* Bug 4022244. Modified the cursor query to add a new join for interface_line_context */
/* Commenting the code for Bug 6443623
        Select sum(tgl.acctd_amount)
    from  ra_cust_trx_line_gl_dist_all tgl,
            ra_customer_trx_lines trx_lines,
            ra_customer_trx trx, ra_batch_sources source
    where  trx_lines.customer_trx_id = trx.customer_trx_id
    and    trx.batch_source_id = source.batch_source_id
    and    trx_lines.interface_line_context = source.name
    and    trx_lines.customer_trx_id = l_cust_trx_id
    and    to_number(trunc(trx_lines.interface_line_attribute6))
            = l_line_num
    and    rtrim(ltrim(trx_lines.interface_line_attribute1)) = l_project_num
    and    tgl.customer_trx_line_id = trx_lines.customer_trx_line_id
    and    tgl.account_class = 'REV';
*/
/* Commenting the following for bug 4022244.
    Select sum(tgl.acctd_amount)
    from   ra_cust_trx_line_gl_dist_all tgl,
           ra_customer_trx_lines trx
    where  trx.customer_trx_id = l_cust_trx_id
    and    to_number(trunc(trx.interface_line_attribute6))
                 = l_line_num
    and    rtrim(ltrim(trx.interface_line_attribute1)) = l_project_num
    and    tgl.customer_trx_line_id = trx.customer_trx_line_id
    and    tgl.account_class = 'REV';
*/

  l_error_message    VARCHAR2(80);
  l_error_flag       VARCHAR2(1);
  l_acct_amount      NUMBER;

BEGIN

  /*** First fetch the error message ***/
  begin
   SELECT Meaning
   INTO l_error_message
   FROM PA_Lookups
   WHERE Lookup_Type = 'TRANSFER REJECTION CODE'
   AND Lookup_Code = 'EXCHANGE_RATE_CHANGE';

  exception
   when NO_DATA_FOUND then
   l_error_message := 'EXCHANGE_RATE_CHANGE';
  end;
  /*** End fetching the error message ***/

  For i in 1..P_num_of_rec
  Loop
   P_out_error(i) := NULL;
   l_error_flag   := 'N';

   for cur_get_line_amt_rec in cur_get_line_amt ( P_draft_inv_num(i),
                                                  P_project_id(i))
   loop
       open cur_get_ar_amt ( P_project_num(i),
                             P_cust_trx_id(i),
                             P_draft_inv_num(i),
                             cur_get_line_amt_rec.line_num);
       fetch cur_get_ar_amt into l_acct_amount;
       close cur_get_ar_amt;

       if  l_acct_amount <> cur_get_line_amt_rec.acct_amt
       then
           l_error_flag := 'Y';
           exit;
       end if;

   end loop;

   if  l_error_flag = 'Y'
   then
       P_out_error(i) := 'Y';

       insert into pa_distribution_warnings
       (
       PROJECT_ID, DRAFT_INVOICE_NUM, LAST_UPDATE_DATE, LAST_UPDATED_BY,
       CREATION_DATE, CREATED_BY, REQUEST_ID, WARNING_MESSAGE
       )
       VALUES
       (
       P_project_id(i), P_draft_inv_num(i), sysdate, P_user_id,
       sysdate, P_user_id, P_request_id, l_error_message
       );
   End if;
  End Loop;
EXCEPTION
  When Others
  Then
       Raise;
END Validate_inv_acct_amt;

END PA_INVOICE_TIEBACK;

/
