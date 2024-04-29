--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_PWP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_PWP" AS
--  $Header: PAPWPEXTB.pls 120.0.12010000.4 2009/01/12 04:49:35 jjgeorge noship $

PROCEDURE     RELEASE_INV (
		             P_REQUEST_ID  IN NUMBER
		             , P_PROJECT_TYPE    IN  VARCHAR2
                 , P_FROM_PROJ_NUM   IN  VARCHAR2
                 , P_TO_PROJ_NUM     IN  VARCHAR2
                 , P_CUSTOMER_NAME   IN  VARCHAR2
                 , P_CUSTOMER_NUMBER IN  NUMBER
                 , P_REC_DATE_FROM   IN  VARCHAR2
                 , P_REC_DATE_TO     IN  VARCHAR2
                 ,x_return_status        OUT NOCOPY VARCHAR2
			           ,x_error_message_code   OUT NOCOPY VARCHAR2)
IS

l_user_id     number(15);
l_date date ;
l_request_id number(15);
l_org_id  number(15);

/*Cursor to select the records inserted by Oracle seeded code during concurrent program processing for a run i.e request_id*/

CURSOR  C_REPORTED_REC   IS
SELECT  REQUEST_ID,PROJECT_ID,DRAFT_INVOICE_NUM,RA_INVOICE_NUM,AP_INVOICE_ID,LINK_TYPE  FROM
PA_PWP_RELEASE_REPORT_ALL WHERE  REQUEST_ID  =  P_REQUEST_ID  ;



/*Sample cursor :As an example :To pick up  all invoices rejected  by Oracle code where invoice amount < 5000*/

CURSOR  C_OVERRIDE    IS
SELECT  AP_INVOICE_ID
FROM
PA_PWP_RELEASE_REPORT  PWP
,AP_INVOICES     APINV
WHERE
     PWP.AP_INVOICE_ID =  APINV.INVOICE_ID
AND  PWP.REQUEST_ID  =  P_REQUEST_ID
AND  PWP.RELEASE_FLAG =  'N'
AND APINV.INVOICE_AMOUNT < 5000 ;


/* To pick up all unlinked  draft invoices */

CURSOR  C_UNLINKED  IS
SELECT  REQUEST_ID,PROJECT_ID,DRAFT_INVOICE_NUM  FROM
PA_PWP_RELEASE_REPORT_ALL
WHERE  REQUEST_ID  = P_REQUEST_ID
AND  link_type = 'UNLINKED'
AND  release_flag = 'X';



BEGIN
/*
 For Link type    'AUTOMATIC' or   'MANUAL',
 The client extension can update the CUSTOM_RELEASE_FLAG
 to prevent or allow release of  payment holds for a  supplier invoice.
 This will override the RELEASE_FLAG set by Oracle code.

FOR  rec    IN  c_reported_rec  LOOP

Update  PA_PWP_RELEASE_REPORT_ALL
set  CUSTOM_RELEASE_FLAG = 'Y'
where  request_id =  p_request_id
AND  ........

End Loop;
*/




/*
Oracle code will not release the supplier invoices unless they are fully paid.
If you want to release the hold on all supplier invoices that are below a threshold amount, you can add  customer code  here  to  override the results of the standard logic used.
The CUSTOM_RELEASE_FLAG column value updated by this package will always take precedence over the RELEASE_FLAG value updated by the standard Oracle code.

FOR  rec    IN  C_OVERRIDE  LOOP

Update  PA_PWP_RELEASE_REPORT_ALL
set  CUSTOM_RELEASE_FLAG = 'Y'
where  request_id =  p_request_id
AND  AP_INVOICE_ID = rec.AP_INVOICE_ID
AND ....

End Loop;
*/




/*
For draft invoices that are created based on an invoice distribution rule
 as  COST, there will be a template record  in  PA_PWP_RELEASE_REPORT with
LINK_TYPE as UNLINKED and RELEASE_FLAG as 'X'.
This record can be used as a reference to view all unlinked invoices
that got picked up by the concurrent request.
The PAID_STATUS column indicates wehther the invoice is paid or not.
If a user wants to associate a supplier invoice with any of these draft invoices and release the supplier invoice, they can do so by inserting a record in
the PA_PWP_RELEASE_REPORT_ALL  table with CUSTOM_RELEASE_FLAG set to 'Y'.
Users should not modify the package to update the template record that has
RELEASE_FLAG value as 'X'.


G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID();

SELECT    org_id
     INTO G_ORG_ID
     FROM pa_implementations;

     select fnd_global.user_id into l_user_id from  dual;
     select sysdate  into l_date from  dual;



FOR  rec    IN  c_reported_rec  LOOP

INSERT INTO  PA_PWP_RELEASE_REPORT
(
ORG_ID,
REQUEST_ID,
PROJECT_ID,
DRAFT_INVOICE_NUM,
LINK_TYPE,
CUSTOM_RELEASE_FLAG,
AP_INVOICE_ID ,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE
)values
( l_org_id
  l_request_id
 rec.project_id,
 rec.DRAFT_INVOICE_NUM,
 rec.link_type,
 'Y',
 l_user_id,
 l_date,
 l_user_id,
 l_date
 );

End Loop;


*/

null;

end RELEASE_INV;

END PA_CLIENT_EXTN_PWP;


/
