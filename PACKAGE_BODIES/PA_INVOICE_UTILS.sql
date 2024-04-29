--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_UTILS" as
-- $Header: PAINUTLB.pls 120.0.12010000.5 2008/10/30 11:32:03 nkapling noship $
--
--  FUNCTION
--              Check_draft_invoice_exists
--
--
Function check_draft_invoice_exists (x_project_id     IN number,
                                     x_customer_id	   IN number)
return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                WHERE exists (SELECT NULL
                        FROM   pa_draft_invoices a, pa_agreements b
                        WHERE  a.project_id   = x_project_id
                        AND    a.agreement_id = b.agreement_id
                        AND    b.customer_id  = x_customer_id );
/*                      AND    a.transfer_status_code = 'A');  commented for bug 6636321*/
        c1_rec c1%rowtype;
begin

   if (x_project_id is null and x_customer_id is null) then
      return(null);
   end if;

   open c1;
   fetch c1 into c1_rec;
   if c1%notfound then
      close c1;
      return(0);
   else
      close c1;
      return(1);
   end if;

exception
   when others then
      return(SQLCODE);
end check_draft_invoice_exists;

-------------------------------------------------------------

END PA_INVOICE_UTILS;

/
