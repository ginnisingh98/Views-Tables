--------------------------------------------------------
--  DDL for Package Body PA_PWP_INVOICE_REL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PWP_INVOICE_REL" AS
--  $Header: PAPWPRIB.pls 120.0.12010000.16 2010/02/23 09:01:42 jjgeorge noship $

-- This  procedure is called by concurrent program  PRC: Release Pay When Paid Holds

PROCEDURE  Release_Invoice (  errbuf          OUT NOCOPY VARCHAR2
                             ,retcode         OUT NOCOPY VARCHAR2
			                       ,p_mode            IN  VARCHAR2
                             ,p_project_type    IN  VARCHAR2
                             ,p_proj_num        IN  VARCHAR2
                             ,P_from_proj_num   IN  VARCHAR2
                             ,p_to_proj_num     IN  VARCHAR2
                             ,p_customer_name   IN  VARCHAR2
                             ,p_customer_number IN  number
                             ,p_rec_date_from   IN  VARCHAR2
                             ,p_rec_date_to     IN  VARCHAR2
			                       ,p_sort            IN  VARCHAR2
			     )
 IS
 req_id             NUMBER;
 rec_date_from      DATE;
 rec_date_to        DATE;
 start_project_num  varchar2(30);
 end_project_num    varchar2(30);
 l_project_id         number;
 l_draft_invoice_num  number;
 l_hold_exists number := 0;
 l_override_flag  varchar2(1) := 'N';
 l_results_flag  varchar2(1)  := 'N';
 l_billed        varchar2(1)  := 'N';
 l_user_id     number(15);
 l_date date ;
 p_return_status   VARCHAR2(5) ;
 l_inv_tab InvoiceId;
 l_return_status   VARCHAR2(1);
 l_msg_count         NUMBER;
 l_msg_data          VARCHAR2(100);
 p_error_message_code      VARCHAR2(2000);
 xml_layout BOOLEAN;

TYPE IdsTab IS TABLE OF PA_EXPENDITURE_ITEMS.DOCUMENT_HEADER_ID%TYPE;
l_unbill_invids  IdsTab;




-- Select all  Supplier Invoices that are
--automatically linked /  Manualy linked and
-- falls in criteria specified by concurrent pogram parameters .

CURSOR sel_inv_autolink IS
        SELECT pdi.project_id
             ,pdi.draft_invoice_num
             ,EI.document_header_id AP_INVOICE_ID
             ,'AUTOLINK' link_type
        FROM   pa_projects prj
             , ra_customer_trx rac
             , pa_draft_invoices pdi
             , pa_draft_invoice_items pdii
             , pa_cust_rev_dist_lines crdl
             , pa_expenditure_items ei
        WHERE  prj.project_type         = NVL(p_project_type ,prj.project_type)
           AND prj.AUTO_RELEASE_PWP_INV = 'Y'
           AND prj.segment1 BETWEEN start_project_num AND end_project_num
           AND prj.project_id                  = pdi.project_id
           AND pdi.customer_id                 = NVL(p_customer_number,pdi.customer_id )
           AND pdi.project_id                  = pdii.project_id
           AND pdi.draft_invoice_num           = pdii.draft_invoice_num
           AND rac.interface_header_attribute1 = prj.segment1
           AND rac.interface_header_attribute2 = TO_CHAR(pdi.draft_invoice_num)
           AND rac.interface_header_context    = ( SELECT NAME
                                                   FROM
                                                     RA_BATCH_SOURCES    RBS
                                                    ,PA_IMPLEMENTATIONS  PI
                                                   WHERE
                                                   PI.INVOICE_BATCH_SOURCE_ID = BATCH_SOURCE_ID
                                                  ) --Bug 8204634
    AND PDII.project_id          = crdl.project_id
    AND pdii.draft_invoice_num   = crdl.draft_invoice_num
    AND pdii.line_num            = crdl.draft_invoice_item_line_num
    AND crdl.expenditure_item_id = ei.expenditure_item_id
    AND ei.document_header_id IS NOT NULL
    AND ei.system_linkage_function = 'VI'
    AND ei.transaction_source      ='AP INVOICE' --AND  prj.project_id = 1027;
	AND ((rec_date_from  IS NULL   AND rec_date_to IS NULL ) OR  --Bug 8294296
     EXISTS                                   -- atleast one reciept applied between   rec start and end date params
     (SELECT 1
		FROM     AR_RECEIVABLE_APPLICATIONS_ALL ARA
		WHERE  ARA.STATUS                  = 'APP'
		AND ara.APPLICATION_TYPE        = 'CASH'
		AND ARA.applied_customer_trx_id = RAC.customer_trx_id
		and  trunc(ARA.APPLY_DATE)  between trunc(nvl(rec_date_from,ARA.APPLY_DATE-1))   and trunc(nvl(rec_date_to,ARA.APPLY_DATE + 1))
    ))
	 and  EXISTS  -- only those  invoice where  a Pay When Paid hold exists .
	 (      SELECT  1
	 FROM    AP_HOLDS_ALL
	 WHERE   invoice_id =   ei.document_header_id
	 AND  hold_lookup_code = 'Pay When Paid'
	 AND release_reason is null )
 UNION
 -- To pickup  manual links
 SELECT pwp.project_id
      , pwp.draft_invoice_num
      , pwp.AP_INVOICE_ID
      ,'MANUAL' link_type
 FROM   pa_projects prj
      , ra_customer_trx rac
      , pa_draft_invoices pdi
      , pa_pwp_linked_invoices pwp
 WHERE  prj.project_type = NVL(p_project_type ,prj.project_type)
    AND prj.segment1 BETWEEN start_project_num AND end_project_num
    AND prj.project_id                  = pdi.project_id
    AND pdi.customer_id                 = NVL(p_customer_number,pdi.customer_id )
    AND pdi.draft_invoice_num           = PWP.draft_invoice_num
    AND pdi.project_id                  = PWP.project_id
    AND rac.interface_header_attribute1 = prj.segment1
    AND rac.interface_header_attribute2 = TO_CHAR(pdi.draft_invoice_num)
    AND rac.interface_header_context    = ( SELECT NAME
                                                   FROM
                                                     RA_BATCH_SOURCES    RBS
                                                    ,PA_IMPLEMENTATIONS  PI
                                                   WHERE
                                                   PI.INVOICE_BATCH_SOURCE_ID = BATCH_SOURCE_ID
                                                  ) --Bug 8204634
    AND ((rec_date_from  IS NULL   AND rec_date_to IS NULL ) OR  --Bug 8294296
	EXISTS -- atleast one reciept applied between   rec start and end date params
        (SELECT 1
			FROM     AR_RECEIVABLE_APPLICATIONS_ALL ARA
			WHERE  ARA.STATUS                  = 'APP'
			AND ara.APPLICATION_TYPE        = 'CASH'
			AND ARA.applied_customer_trx_id = RAC.customer_trx_id
			and  trunc(ARA.APPLY_DATE)  between trunc(nvl(rec_date_from,ARA.APPLY_DATE-1))   and trunc(nvl(rec_date_to,ARA.APPLY_DATE + 1))

		))
        and  EXISTS  -- only those  invoice where  a Pay When Paid hold exists .
        (      SELECT  1
        FROM    AP_HOLDS_ALL
        WHERE   invoice_id =   pwp.AP_INVOICE_ID
        AND  hold_lookup_code = 'Pay When Paid'
        AND release_reason is null)
        ;


-- select all  Draft Invoice Lines that are
-- not linked to any expenditure_item
CURSOR sel_inv_unlink IS
        SELECT pdi.project_id
             ,pdi.draft_invoice_num
             ,'UNLINKED' link_type
             , NVL(
                      CASE
                             WHEN 1 =
                                    (SELECT 1
                                    FROM   dual
                                    WHERE  EXISTS
                                           (SELECT 1
                                           FROM   ar_payment_schedules_all arp
                                           WHERE  /*arp.status          = 'OP' Bug 8284969 */
					           ARP.AMOUNT_DUE_REMAINING <> 0
                                              AND Sign(ARP.AMOUNT_DUE_ORIGINAL) =  Sign(ARP.AMOUNT_DUE_REMAINING )
                                              AND rac.customer_trx_id = arp.customer_trx_id
                                           )
                                    )
                             THEN 'N'
                             ELSE 'Y'
                      END, 'Y') payment_status
        FROM   pa_projects prj
             , ra_customer_trx rac
             , pa_draft_invoices pdi
             , pa_draft_invoice_items pdii
             , pa_events pae
             , pa_event_types pet
        WHERE  prj.project_type         = NVL(p_project_type ,prj.project_type)
           AND prj.AUTO_RELEASE_PWP_INV = 'N'
           AND prj.segment1 BETWEEN start_project_num AND end_project_num
           AND prj.project_id                  = pdi.project_id
           AND pdi.customer_id                 = NVL(p_customer_number,pdi.customer_id )
           AND pdi.project_id                  = pdii.project_id
           AND pdi.project_id                  = pdii.project_id
           AND pdi.draft_invoice_num           = pdii.draft_invoice_num
           AND pdii.project_id                 = pae.project_id
		   AND nvl(pdii.task_id,-999)          = nvl(pae.task_id,-999)
           AND pdii.event_num                  = pae.event_num
           AND pae.event_type                  = pet.event_type
           AND pet.event_type_classification  IN ('AUTOMATIC','MANUAL')
           AND rac.interface_header_attribute1 = prj.segment1
           AND rac.interface_header_attribute2 = TO_CHAR(pdi.draft_invoice_num)
           AND rac.interface_header_context    = ( SELECT NAME
                                                   FROM
                                                     RA_BATCH_SOURCES    RBS
                                                    ,PA_IMPLEMENTATIONS  PI
                                                   WHERE
                                                   PI.INVOICE_BATCH_SOURCE_ID = BATCH_SOURCE_ID
                                                  ) --Bug 8204634
           AND  ((rec_date_from  IS NULL   AND rec_date_to IS NULL ) OR  --Bug 8294296
		   EXISTS -- atleast one reciept applied between   rec start and end date params
               (SELECT 1
				FROM     AR_RECEIVABLE_APPLICATIONS_ALL ARA
				WHERE  ARA.STATUS                  = 'APP'
				AND ara.APPLICATION_TYPE        = 'CASH'
				AND ARA.applied_customer_trx_id = RAC.customer_trx_id
				and  trunc(ARA.APPLY_DATE)  between trunc(nvl(rec_date_from,ARA.APPLY_DATE-1))   and trunc(nvl(rec_date_to,ARA.APPLY_DATE + 1))

			))
			AND NOT EXISTS
			(SELECT 1 FROM  PA_PWP_LINKED_INVOICES
			  WHERE PROJECT_ID =  pdi.project_id
			    AND   DRAFT_INVOICE_NUM  = pdi.draft_invoice_num   );

/*
This  cusrsor  should pick up all  the  Supplier invoices that are totally  non billable  and
falls in the  criteria  specified for  the  concurrent program.
*/
CURSOR cur_inv_unbillable IS
SELECT DISTINCT   EI.DOCUMENT_HEADER_ID
FROM            PA_EXPENDITURE_ITEMS EI
               ,PA_PROJECTS PROJ
               ,PA_TASKS TASK
               ,PA_TASKS TOPTASK
WHERE           proj.project_type         = NVL(p_project_type ,proj.project_type)
            AND proj.AUTO_RELEASE_PWP_INV = 'Y'
            AND proj.segment1 BETWEEN start_project_num AND end_project_num
            AND PROJ.PROJECT_ID = EI.PROJECT_ID
            AND EI.DOCUMENT_HEADER_ID IS NOT NULL
            AND EI.SYSTEM_LINKAGE_FUNCTION = 'VI'
            AND EI.TRANSACTION_SOURCE ='AP INVOICE'
            AND EI.BILLABLE_FLAG = 'N'
            AND NVL(NET_ZERO_ADJUSTMENT_FLAG,'N') <> 'Y'
            AND  PROJ.PROJECT_ID = TASK.PROJECT_ID
            AND TASK.PROJECT_ID = EI.PROJECT_ID
            AND TASK.TASK_ID = EI.TASK_ID
            AND TASK.TOP_TASK_ID = TOPTASK.TASK_ID
            AND TOPTASK.PROJECT_ID = EI.PROJECT_ID
            AND DECODE(PROJ.ENABLE_TOP_TASK_INV_MTH_FLAG, 'Y', TOPTASK.INVOICE_METHOD,PROJ.INVOICE_METHOD) = 'WORK'
            AND NOT EXISTS
                (SELECT  /*+ INDEX(EI2 PA_EXPENDITURE_ITEMS_N27)*/
                  1
                FROM   PA_EXPENDITURE_ITEMS EI2
                     ,PA_PROJECTS PROJ
                     ,PA_TASKS TASK
                     ,PA_TASKS TOPTASK
                WHERE   EI2.DOCUMENT_HEADER_ID =EI.DOCUMENT_HEADER_ID
                   AND EI2.PROJECT_ID = PROJ.PROJECT_ID
                   AND PROJ.PROJECT_ID = TASK.PROJECT_ID
                   AND TASK.PROJECT_ID = EI2.PROJECT_ID
                   AND TASK.TASK_ID = EI2.TASK_ID
                   AND TASK.TOP_TASK_ID = TOPTASK.TASK_ID
                   AND TOPTASK.PROJECT_ID = EI2.PROJECT_ID
                   AND NVL(EI2.NET_ZERO_ADJUSTMENT_FLAG,'N') <> 'Y'
                   AND EI2.DOCUMENT_HEADER_ID IS NOT NULL
                   AND EI2.SYSTEM_LINKAGE_FUNCTION = 'VI'
                   AND EI2.TRANSACTION_SOURCE ='AP INVOICE'
				           AND
                       (( proj.AUTO_RELEASE_PWP_INV = 'Y'  AND
                              (
                                     EI2.BILLABLE_FLAG = 'Y'
                                 AND DECODE(PROJ.ENABLE_TOP_TASK_INV_MTH_FLAG, 'Y', TOPTASK.INVOICE_METHOD,PROJ.INVOICE_METHOD) = 'WORK'
                              )
                           OR DECODE(PROJ.ENABLE_TOP_TASK_INV_MTH_FLAG, 'Y', TOPTASK.INVOICE_METHOD,PROJ.INVOICE_METHOD) = 'COST'
                           OR DECODE(PROJ.ENABLE_TOP_TASK_INV_MTH_FLAG, 'Y', TOPTASK.INVOICE_METHOD,PROJ.INVOICE_METHOD) = 'EVENT'
                       )
					   OR nvl(proj.AUTO_RELEASE_PWP_INV,'N') = 'N'
					   )
                )
    AND NOT EXISTS    -- unpaid manually linked invoices exist
      (SELECT   1
		FROM
          PA_PWP_LINKED_INVOICES PWP
		WHERE
      PWP.AP_INVOICE_ID = EI.DOCUMENT_HEADER_ID
       )
       AND EXISTS -- ONLY THOSE  INVOICE WHERE  A PAY WHEN PAID HOLD EXISTS .
                (SELECT 1
                FROM   AP_HOLDS_ALL
                WHERE  INVOICE_ID = EI.DOCUMENT_HEADER_ID
                   AND HOLD_LOOKUP_CODE = 'Pay When Paid'
                   AND RELEASE_REASON IS NULL
                );


BEGIN
P_DEBUG_MODE  :=   NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

pa_debug.init_err_stack ('Pay When Paid');
pa_debug.set_process(
            x_process => 'PLSQL',
            x_debug_mode => P_DEBUG_MODE);


  write_log (LOG,    '---------------PARAMETERS----------- ');
   write_log (LOG,  'p_mode                            -> ' || p_mode);
  write_log (LOG,   'project_type                      -> ' || p_project_type);
  write_log (LOG,   'p_proj_num                        -> ' || p_proj_num);
  write_log (LOG,   'P_from_proj_num                   -> ' || P_from_proj_num);
  write_log (LOG,   'p_to_proj_num                     -> ' || p_to_proj_num);
  write_log (LOG,   'p_customer_name                   -> ' || p_customer_name);
  write_log (LOG,   'p_customer_number                 -> ' || p_customer_number);
  write_log (LOG,   'p_rec_date_from                   -> ' || p_rec_date_from);
  write_log (LOG,   'p_rec_date_to                     -> ' || p_rec_date_to);
  write_log (LOG,   'p_sort                            -> ' || p_sort);
  write_log (LOG,    '------------------------------------' );

  --process the parameters
G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID();
SELECT    org_id
     INTO G_ORG_ID
     FROM pa_implementations;

     select fnd_global.user_id into l_user_id from  dual;
     select sysdate  into l_date from  dual;


  if  (p_proj_num is null)  then
     if ( P_from_proj_num is  null ) then
      select min(pap.segment1) into  start_project_num from  pa_projects pap where  project_type = nvl(p_project_type,pap.project_type) ;
      else
      start_project_num  :=  P_from_proj_num;
     end if;
     if (p_to_proj_num is  null ) then
         select max(pap.segment1) into  end_project_num from  pa_projects pap where  project_type = nvl(p_project_type,pap.project_type) ;
     else
         end_project_num    :=  p_to_proj_num;
     end if;
  else
      start_project_num  :=  p_proj_num;
      end_project_num    :=  p_proj_num;

  end if;
  write_log (LOG,   'start_project_num->    ' || start_project_num);
  write_log (LOG,   'end_project_num->    ' || end_project_num);

 rec_date_from :=   fnd_date.canonical_to_date(p_rec_date_from);
 rec_date_to   :=   fnd_date.canonical_to_date(p_rec_date_to);
 -- End  parameter processing

-- Pick   the paid draft invoices .
FOR  invrec   IN  sel_inv_autolink  LOOP
    write_log (LOG, '======================================' );
    write_log (LOG, 'Processing Supplier Invoice Id   -> ' || invrec.AP_INVOICE_ID);
    l_billed  := 'N';
    If  (is_processed(invrec.AP_INVOICE_ID) = 'N') THEN


        if   (is_eligible(invrec.AP_INVOICE_ID) = 'Y') THEN
              l_billed      := is_billed(invrec.AP_INVOICE_ID);
              If ( l_billed = 'Y'  )  then

                    write_log (LOG,  'Invoice eligible for release');
                    --Make entry in the report table
                    INSERT INTO  PA_PWP_RELEASE_REPORT
                    (
                    ORG_ID,
                    REQUEST_ID,
                    PROJECT_ID,
                    DRAFT_INVOICE_NUM,
                    AP_INVOICE_ID,
                    LINK_TYPE,
                    RELEASE_FLAG,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                    )values
                    (
                    G_ORG_ID,
                    G_REQUEST_ID,
                    invrec.project_id,
                    invrec.DRAFT_INVOICE_NUM,
                    invrec.AP_INVOICE_ID,
                    invrec.link_type,
                    'Y',
                    l_user_id,
                    l_date,
                    l_user_id,
                    l_date
                    );


              else
                    write_log (LOG,'Billed completly ? ' || l_billed );
                    write_log (LOG, 'Invoice will not be released' );

                    INSERT INTO  PA_PWP_RELEASE_REPORT
                    (
                    ORG_ID,
                    REQUEST_ID,
                    PROJECT_ID,
                    DRAFT_INVOICE_NUM,
                    AP_INVOICE_ID,
                    LINK_TYPE,
                    RELEASE_FLAG,
                    EXCEPTION,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                    )
                    values
                    (
                    G_ORG_ID,
                    G_REQUEST_ID,
                    invrec.project_id,
                    invrec.DRAFT_INVOICE_NUM,
                    invrec.AP_INVOICE_ID,
                    invrec.link_type,
                    'N',
                    'PA_INV_UNREL_UNBILL',
                    l_user_id,
                    l_date,
                    l_user_id,
                    l_date
                    );
                    -- Make exception entry to report table
                    write_log (LOG, 'This  Invoice is not yet paid fully' );
              End if  ; -- is billed

        else -- is  eligible
              write_log (LOG, 'Project on hold' );
              INSERT INTO  PA_PWP_RELEASE_REPORT
                    (
                    ORG_ID,
                    REQUEST_ID,
                    PROJECT_ID,
                    DRAFT_INVOICE_NUM,
                    AP_INVOICE_ID,
                    LINK_TYPE,
                    RELEASE_FLAG,
                    EXCEPTION,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                    )
                    values
                    (
                    G_ORG_ID,
                    G_REQUEST_ID,
                    invrec.project_id,
                    invrec.DRAFT_INVOICE_NUM,
                    invrec.AP_INVOICE_ID,
                    invrec.link_type,
                    'N',
                    'PA_INV_UNREL_FLAG',
                    l_user_id,
                    l_date,
                    l_user_id,
                    l_date
                    );
        End if;

    else
        write_log  (LOG, 'This invoice already processed in the current run ' );
    End If;
End  Loop;
write_log (LOG, 'End of Linked Invoice Processing' );
write_log (LOG, 'Start of Unlinked Invoice Processing' );

 FOR  invrec   IN  sel_inv_unlink  LOOP
INSERT INTO  PA_PWP_RELEASE_REPORT
(
ORG_ID,
REQUEST_ID,
PROJECT_ID,
DRAFT_INVOICE_NUM,
LINK_TYPE,
RELEASE_FLAG,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_DATE
)values
(G_ORG_ID,
 G_REQUEST_ID,
 invrec.project_id,
 invrec.DRAFT_INVOICE_NUM,
 invrec.link_type,
 'X',
 l_user_id,
 l_date,
 l_user_id,
 l_date
 );
 End  Loop;


write_log (LOG, 'End of Unlinked Invoice Processing' );
write_log (LOG, 'Start of Not Billable Invoice Processing' );

  OPEN cur_inv_unbillable;
  FETCH cur_inv_unbillable BULK COLLECT INTO l_unbill_invids;
  CLOSE cur_inv_unbillable;
  if l_unbill_invids.count > 0    then
    FORALL i IN l_unbill_invids.FIRST..l_unbill_invids.LAST
	   INSERT INTO  PA_PWP_RELEASE_REPORT
                    (
                    ORG_ID,
                    REQUEST_ID,
                    AP_INVOICE_ID,
                    LINK_TYPE,
                    RELEASE_FLAG,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                    )values
                    (
                    G_ORG_ID,
                    G_REQUEST_ID,
                    l_unbill_invids(i),
                    'AUTOLINK',
                    'Y',
                    l_user_id,
                    l_date,
                    l_user_id,
                    l_date
                    );

  End  if;
 write_log (LOG, 'End of  Not Billable Invoice Processing' );

commit;
-- Call  client  extension


PA_CLIENT_EXTN_PWP.RELEASE_INV(G_REQUEST_ID,p_project_type,start_project_num,end_project_num,p_customer_name,p_customer_number,
                               p_rec_date_from,p_rec_date_to,p_return_status,p_error_message_code);
--

-- Call release API .
if upper(p_mode) = 'FINAL'  then
write_log(LOG , 'FINAL Mode - Calling API to release hold');

 select ap_invoice_id bulk collect into l_inv_tab
 from PA_PWP_RELEASE_REPORT
 where nvl(CUSTOM_RELEASE_FLAG,RELEASE_FLAG) = 'Y'  and  request_id = G_REQUEST_ID ;

 paap_release_hold ( l_Inv_Tab
                    ,l_return_status
                    ,l_msg_count
                    ,l_msg_data       );

end if;
--  Submitting the  report request  .

G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID();
FND_REQUEST.set_org_id(G_ORG_ID);

write_log(LOG , 'Launching process to generate Audit Report');
xml_layout := FND_REQUEST.ADD_LAYOUT('PA','PAPWPRIREP','en','US','PDF');
req_id := FND_REQUEST.SUBMIT_REQUEST('PA', 'PAPWPRIREP', '', '', FALSE,  G_REQUEST_ID
             ,p_mode,p_project_type,p_proj_num,start_project_num,end_project_num,p_customer_name,
			 p_customer_number,p_rec_date_from,p_rec_date_to,p_sort);

write_log (LOG,'Submitted Request Id' ||req_id );


EXCEPTION
		  WHEN OTHERS THEN
      write_log (LOG,'Exception' ||SQLERRM );
END  Release_Invoice;

Procedure paap_release_hold (P_Inv_Tbl          IN InvoiceId
                              ,X_return_status   OUT NOCOPY VARCHAR2
                              ,X_msg_count       OUT NOCOPY NUMBER
                              ,X_msg_data        OUT NOCOPY VARCHAR2) IS

       l_hold_reason         Varchar2(240):=  'Automatic Release';

     -- Cursor c1 is to fetch hold lookup code
     -- for the invoice being passed if any of the PWP  hold exists.
     Cursor c1(p_invoice_id Number) Is
       select hold_lookup_code from ap_holds_all
       where invoice_id= p_invoice_id
       and hold_lookup_code = 'Pay When Paid'
       and release_reason IS NULL;

	 l_err_msg            Varchar2(4000);

  BEGIN
   x_return_status := 'S';
   X_msg_count :=0;

   IF P_DEBUG_MODE = 'Y' THEN
        write_log(LOG,'Begin: paap_release_hold ');
   END IF;

   IF p_inv_tbl.count > 0 THEN

     FOR Inv_RelHOld_rec in 1..p_inv_tbl.count LOOP
       FOR HoldRec in  c1(p_inv_tbl(Inv_RelHOld_rec)) LOOP
	    BEGIN
         IF P_DEBUG_MODE = 'Y' THEN
            write_log(LOG,'Before calling AP_HOLDS_PKG.release_single_hold API '
                        ||'[Invoice_Id : '||p_inv_tbl(Inv_RelHOld_rec)||'] '
                        ||'[hold_lookup_code: '||HoldRec.hold_lookup_code||'] '
                        ||'[l_hold_reason: '||l_hold_reason||'] ');
         END IF;

         AP_HOLDS_PKG.release_single_hold
               (X_invoice_id => p_inv_tbl(Inv_RelHOld_rec),
                X_hold_lookup_code=> HoldRec.hold_lookup_code,
                X_release_lookup_code =>l_hold_reason);

		EXCEPTION
		  WHEN OTHERS THEN
            l_err_msg:= SQLERRM;

            IF P_DEBUG_MODE = 'Y' THEN
             write_log(LOG,'In When Others Exception  '||SQLERRM);
            END IF;

            x_msg_count := 1;
            x_return_status :='E';
            x_msg_data := SQLERRM;
		END;
      END LOOP;

     END LOOP;

    END IF;
    COMMIT;

    IF P_DEBUG_MODE = 'Y' THEN
        write_log(LOG,'[x_return_status : '||x_return_status||' ]');
    END IF;

    IF x_return_status = 'S' THEN
       X_msg_data := 'PA_INV_HOLD_RELEASE';
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
      IF P_DEBUG_MODE = 'Y' THEN
        write_log(LOG,'In When Others Exception :'||SQLERRM);
      END IF;

       x_msg_count:=1;
       x_return_status := 'U';
       X_msg_data:=SQLERRM;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END paap_release_hold;




PROCEDURE write_log (
   p_message_type IN NUMBER,
   p_message IN VARCHAR2) IS

   buffer_overflow EXCEPTION;
   PRAGMA EXCEPTION_INIT(buffer_overflow, -20000);

    BEGIN
     --FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(sysdate,'HH:MI:SS:   ')|| p_message);
     pa_debug.write_file('LOG', 'pa.plsql.PA_PWP_INVOICE_REL  : '|| p_message , 1);
    EXCEPTION   /* When exception occurs, program needs to be aborted. */
       WHEN OTHERS THEN
       raise;

END write_log;
/*
-- Function            : is_billed
-- Type                : Private
-- Purpose             : To find out if all transactions in Projects
--                       related to a supplier invoice  are completly
--		                   billed(invoiced)  and paid(in AR)
-- Note                 : For ei's  with  distribution rule as  work  , API checks
--                            1.if there are any CRDL lines not yet invoiced
--                            2.Any EI's  not yet  revenue generated.
--                            3.Any Invoices  that still open in AR
--                          For Ei's with   distribution rule as  COST API checks
--                           1.if there are any Draft Invoices linked to the  Supplier Invoice
--                             in  pa_pwp_linked_invoices
-- Assumptions          : For distribution rule 'Cost' , if  User wants to keep  a Pay when paid hold on
--                        the  AP invoice till a draft invoice is paid  , they have to manually link the
--                        draft invoice with the  Supplier  Invoice.
--
-- Parameter            :
-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_invoice_id                NUMBER         YES       Supplier  Invoice Id
*/

FUNCTION is_billed ( p_invoice_id IN NUMBER )
	RETURN VARCHAR2
IS

 v_tmp		VARCHAR2(1) := 'Y';

BEGIN
--cchek the condition of billed but not yet paid .
-- WE may need to check this based of  Distribution rule
   --write_log (LOG,   'is_billed start ');
	SELECT  'N' into v_tmp
	FROM    dual
	WHERE   EXISTS
	        (
            -- revnue generated but unbilled transactions  exist for the AP Invoice
	                 SELECT  1
	                FROM   pa_projects_all proj,
                         pa_tasks   task,
                         pa_tasks toptask,
                         pa_expenditure_items ei,
	                        pa_cust_rev_dist_lines crdl
	                WHERE proj.project_id = task.project_id
                    and    task.top_task_id = toptask.task_id
                    and    toptask.project_id = ei.project_id
                    and    task.project_id = ei.project_id
                    and    task.task_id = ei.task_id
                    and    ei.DOCUMENT_HEADER_ID      = p_invoice_id
					            AND crdl.expenditure_item_id = ei.expenditure_item_id
	                    AND ei.system_linkage_function = 'VI'
                      AND ei.transaction_source in ('AP INVOICE'  ,'AP NRTAX' , 'AP VARIANCE') -- bug 8208422
                      AND nvl(ei.net_zero_adjustment_flag,'N') <> 'Y'
                      AND ei.billable_flag = 'Y'
                      and nvl(crdl.REVERSED_FLAG,'N') <> 'Y'
                      AND crdl.LINE_NUM_REVERSED is  null
	              AND crdl.draft_invoice_num IS NULL
	              AND nvl(crdl.ADDITIONAL_REVENUE_FLAG,'N')  <> 'Y'
                      AND Decode(PROJ.Enable_Top_Task_Inv_Mth_Flag, 'Y', TOPTASK.Invoice_Method,PROJ.INVOICE_METHOD) = 'WORK'

	        )
          OR exists
		    (
        -- Pending revenue generation
        SELECT  1
        FROM
          pa_expenditure_items ei ,
          pa_projects_all proj,
          pa_tasks   task,
          pa_tasks toptask
        WHERE
          ei.DOCUMENT_HEADER_ID      = p_invoice_id
          AND    nvl(ei.net_zero_adjustment_flag,'N') <> 'Y'
          AND ei.system_linkage_function = 'VI'
	  AND EI.TRANSACTION_SOURCE in ('AP INVOICE'  ,'AP NRTAX' , 'AP VARIANCE') -- bug 8208422
          AND ei.revenue_distributed_flag = 'N'
          AND ei.billable_flag = 'Y'
          AND proj.project_id = task.project_id
          and    task.top_task_id = toptask.task_id
          and    toptask.project_id = ei.project_id
          and    task.project_id = ei.project_id
          and    task.task_id = ei.task_id
          AND Decode(PROJ.Enable_Top_Task_Inv_Mth_Flag, 'Y', TOPTASK.Invoice_Method,PROJ.INVOICE_METHOD) = 'WORK'
  )

        OR exists
        --Any invoices that are  not interfaced to AR  or  interfaced but  unpaid   in AR
        (
        SELECT  1
FROM    PA_EXPENDITURE_ITEMS EI
      , PA_CUST_REV_DIST_LINES CRDL
      , PA_DRAFT_INVOICE_ITEMS PDII
      , PA_DRAFT_INVOICES PDI
      , PA_PROJECTS PRJ
      , PA_TASKS TASK
      , PA_TASKS TOPTASK
WHERE   EI.PROJECT_ID = TASK.PROJECT_ID
    AND EI.TASK_ID = TASK.TASK_ID
    AND PRJ.PROJECT_ID = TASK.PROJECT_ID
    AND TASK.TOP_TASK_ID = TOPTASK.TASK_ID
    AND TOPTASK.PROJECT_ID = EI.PROJECT_ID
    AND TASK.PROJECT_ID = EI.PROJECT_ID
    AND EI.DOCUMENT_HEADER_ID = P_INVOICE_ID
    AND EI.SYSTEM_LINKAGE_FUNCTION = 'VI'
    AND EI.BILLABLE_FLAG = 'Y'
    AND EI.TRANSACTION_SOURCE in ('AP INVOICE'  ,'AP NRTAX' , 'AP VARIANCE') -- bug 8208422
    AND CRDL.EXPENDITURE_ITEM_ID = EI.EXPENDITURE_ITEM_ID
    AND PDII.DRAFT_INVOICE_NUM = CRDL.DRAFT_INVOICE_NUM
    AND PDII.LINE_NUM = CRDL.DRAFT_INVOICE_ITEM_LINE_NUM
    AND PDII.PROJECT_ID = CRDL.PROJECT_ID
    AND DECODE(PRJ.ENABLE_TOP_TASK_INV_MTH_FLAG, 'Y', TOPTASK.INVOICE_METHOD,PRJ.INVOICE_METHOD) = 'WORK'
	AND PDI.PROJECT_ID = CRDL.PROJECT_ID                 --BUG 7704332 missing join conditions added.
	AND PDI.DRAFT_INVOICE_NUM =  CRDL.DRAFT_INVOICE_NUM
    AND (PDI.TRANSFER_STATUS_CODE IN ('P' ,'R','X')-- INVOICE NOT YET TRANSFERED TO AR
     OR EXISTS
        (SELECT 1
        FROM    AR_PAYMENT_SCHEDULES_ALL ARP
              ,RA_CUSTOMER_TRX RAC
        WHERE   /* ARP.STATUS = 'OP'   Bug 8284969  */
	         ARP.AMOUNT_DUE_REMAINING <> 0
            AND Sign(ARP.AMOUNT_DUE_ORIGINAL) =  Sign(ARP.AMOUNT_DUE_REMAINING )
            AND RAC.CUSTOMER_TRX_ID = ARP.CUSTOMER_TRX_ID
            AND RAC.INTERFACE_HEADER_ATTRIBUTE1 = PRJ.SEGMENT1
            AND RAC.INTERFACE_HEADER_ATTRIBUTE2 = TO_CHAR(PDII.DRAFT_INVOICE_NUM)
            AND RAC.INTERFACE_HEADER_CONTEXT = ( SELECT NAME
                                                   FROM
                                                     RA_BATCH_SOURCES    RBS
                                                    ,PA_IMPLEMENTATIONS  PI
                                                   WHERE
                                                   PI.INVOICE_BATCH_SOURCE_ID = BATCH_SOURCE_ID
                                                  ) --Bug 8204634
        ) )

        )
      OR exists
      -- unpaid manually linked invoices exist
      (SELECT  1
FROM    PA_PROJECTS PRJ
      , PA_DRAFT_INVOICES PDI
      , PA_PWP_LINKED_INVOICES PWP
WHERE   PRJ.PROJECT_ID             = PDI.PROJECT_ID
    AND  PDI.PROJECT_ID =  PWP.PROJECT_ID  --   Bug 7720228
    AND PDI.DRAFT_INVOICE_NUM      = PWP.DRAFT_INVOICE_NUM
    AND PWP.AP_INVOICE_ID          = P_INVOICE_ID
    AND (PDI.TRANSFER_STATUS_CODE IN ('P' ,'R','X')
     OR EXISTS
        (SELECT 1
        FROM    AR_PAYMENT_SCHEDULES_ALL ARP
              , RA_CUSTOMER_TRX RAC
        WHERE   /*ARP.STATUS                      = 'OP'  Bug  8284969 */
	        ARP.AMOUNT_DUE_REMAINING <> 0
            AND Sign(ARP.AMOUNT_DUE_ORIGINAL) =  Sign(ARP.AMOUNT_DUE_REMAINING )
            AND RAC.CUSTOMER_TRX_ID             = ARP.CUSTOMER_TRX_ID
            AND RAC.INTERFACE_HEADER_ATTRIBUTE1 = PRJ.SEGMENT1
            AND RAC.INTERFACE_HEADER_ATTRIBUTE2 = TO_CHAR(PDI.DRAFT_INVOICE_NUM)
            AND RAC.INTERFACE_HEADER_CONTEXT    = ( SELECT NAME
                                                   FROM
                                                     RA_BATCH_SOURCES    RBS
                                                    ,PA_IMPLEMENTATIONS  PI
                                                   WHERE
                                                   PI.INVOICE_BATCH_SOURCE_ID = BATCH_SOURCE_ID
                                                  )--Bug 8204634
        ) ) )

        ;

	return  v_tmp;
EXCEPTION
 WHEN NO_DATA_FOUND THEN

   v_tmp := 'Y';
 RETURN v_tmp;

END is_billed;

-- Function            : is_processed
-- Type                :Private
-- Purpose             : To find if this Supplier  Invoice is already processed  in the
--                        Current Run .
-- Note                :
-- Assumptions         :
-- Parameter           :
-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_invoice_id                NUMBER         YES       Supplier  Invoice Id


FUNCTION is_processed ( p_invoice_id IN NUMBER )
	RETURN VARCHAR2
IS

v_tmp		VARCHAR2(1) := 'N';

BEGIN
	SELECT  'Y' into  v_tmp
	FROM    dual
	WHERE   EXISTS
	        (     select 1 from  PA_PWP_RELEASE_REPORT
               where request_id = G_REQUEST_ID and AP_INVOICE_ID = p_invoice_id );


	return  v_tmp;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  -- write_log (LOG,  ' EX hold');
 v_tmp := 'N';
 RETURN v_tmp;

END is_processed;
/*
-- Function            : is_eligible
-- Type                 :Private
-- Purpose              : To find if all AUTO_RELEASE_PWP_INV is yes for all
--                          related projects.
-- Note                 : Checks  if  PA_PROJECTS_ALL.AUTO_RELEASE_PWP_INV is Y/N.
-- Assumptions          :
-- Parameter            :
-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_invoice_id                NUMBER         YES       Supplier  Invoice Id
*/

FUNCTION is_eligible  ( p_invoice_id IN NUMBER )
	RETURN VARCHAR2
IS

v_tmp		VARCHAR2(1) := 'Y';

BEGIN

	SELECT  'N' into  v_tmp
	FROM    dual
	WHERE   EXISTS
	        (  select 1 from
pa_projects proj,
pa_expenditure_items_all ei
where
ei.project_id = proj.project_id  and
ei.document_header_id  = p_invoice_id  and
proj.AUTO_RELEASE_PWP_INV = 'N'    );



	return  v_tmp;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
 v_tmp := 'Y';
 RETURN v_tmp;

END is_eligible;
END PA_PWP_INVOICE_REL;

/
