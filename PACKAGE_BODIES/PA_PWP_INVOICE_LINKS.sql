--------------------------------------------------------
--  DDL for Package Body PA_PWP_INVOICE_LINKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PWP_INVOICE_LINKS" AS
 /* $Header: PAAPINVB.pls 120.0.12010000.3 2008/12/18 12:59:19 jjgeorge noship $ */
PROCEDURE del_invoice_link
        (PA_LINK_TAB  IN  PA_PWP_INVOICE_LINKS.LINK_TAB
         ,x_return_status  OUT NOCOPY VARCHAR2
         ,x_msg_count     OUT NOCOPY NUMBER
         ,x_msg_data      OUT NOCOPY VARCHAR2 )
IS


Cursor C1(P_Invoice_Id Number, P_Project_Id Number) Is
	Select distinct draft_invoice_num,link_type From (
    Select   draft_invoice_num, 'M' link_type From PA_PWP_LINKED_INVOICES PWP
      Where  PWP.AP_INVOICE_ID = p_invoice_id
      And    PWP.PROJECT_ID = p_project_id
    UNION ALL
    Select   pdii.draft_invoice_num, 'A' From PA_DRAFT_INVOICE_ITEMS PDII ,
                                                  PA_CUST_REV_DIST_LINES CRDL ,
                                                  PA_EXPENDITURE_ITEMS EI
        Where    PDII.project_id          = crdl.project_id
             And pdii.draft_invoice_num   = crdl.draft_invoice_num
             And pdii.line_num            = crdl.draft_invoice_item_line_num
             And crdl.expenditure_item_id = ei.expenditure_item_id
             And ei.system_linkage_function  = 'VI'
             And ei.document_header_id =p_invoice_id
             And ei.transaction_source like 'AP%'
             And ei.project_id =p_project_id);

	l_draft_inv_number                        Varchar2(2000):='';
        l_draft_inv_link_type                     Varchar2(2000):='';

BEGIN
 x_return_status := 'S';
 x_msg_data := 'PA_INV_HOLD_RELEASE';

 --Bug 7650431  Changed the  FORALL to normal For Loop.
 FOR  i in  PA_LINK_TAB.first..PA_LINK_TAB.last Loop
        DELETE
        FROM   PA_PWP_LINKED_INVOICES
        WHERE  project_id        = PA_LINK_TAB(i).PROJECT_ID
           AND draft_invoice_num = PA_LINK_TAB(i).DRAFT_INVOICE_NUM
           AND ap_invoice_id     = PA_LINK_TAB(i).AP_INVOICE_ID;

End Loop;

 FOR i in PA_LINK_TAB.first..PA_LINK_TAB.last LOOP
    l_draft_inv_number := '';
    FOR DRAFTINV_REC IN C1(PA_LINK_TAB(i).AP_INVOICE_ID,PA_LINK_TAB(i).PROJECT_ID) LOOP
        IF l_draft_inv_number IS NULL THEN
            l_draft_inv_number:=DRAFTINV_REC.draft_invoice_num;
            l_draft_inv_link_type :=DRAFTINV_REC.link_type;
        ELSE
		    l_draft_inv_number:=l_draft_inv_number||','||DRAFTINV_REC.draft_invoice_num;
            l_draft_inv_link_type := l_draft_inv_link_type||','||DRAFTINV_REC.link_type;
        END IF;
    END LOOP;

    UPDATE PA_PWP_AP_INV_HDR
        SET LINKED_DRAFT_INVOICE_NUM = l_draft_inv_number,
            LINKED_DRFAT_INV_TYPE = l_draft_inv_link_type
       WHERE INVOICE_ID = PA_LINK_TAB(i).AP_INVOICE_ID
       AND PROJECT_ID = PA_LINK_TAB(i).PROJECT_ID;
 END LOOP;
 COMMIT;
EXCEPTION
WHEN OTHERS THEN
x_return_status := 'U';
X_msg_data := SQLERRM;
      -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END del_invoice_link ;


PROCEDURE add_invoice_link
        (PA_LINK_TAB  IN PA_PWP_INVOICE_LINKS.LINK_TAB
	    ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count     OUT NOCOPY NUMBER
            ,x_msg_data      OUT NOCOPY VARCHAR2 )
IS
        l_sysdate DATE;
        l_created_by number;
		l_orgid  number;
BEGIN
x_return_status := 'S';
x_msg_data :=  'PA_PWP_LINK_INV';

        SELECT sysdate
        INTO   l_sysdate
        FROM   dual;
l_CREATED_BY :=FND_GLOBAL.user_id;

  If PA_LINK_TAB.count > 0  then
      SELECT org_id
        INTO   l_orgid
        FROM   pa_projects where  project_id =  PA_LINK_TAB(1).PROJECT_ID ;
   End if;


 --Bug 7650431  Changed the  FORALL to normal For Loop.
FOR i in  PA_LINK_TAB.first..PA_LINK_TAB.last Loop

        INSERT
        INTO   PA_PWP_LINKED_INVOICES
               (      ORG_ID,
                      PROJECT_ID        ,
                      DRAFT_INVOICE_NUM ,
                      AP_INVOICE_ID     ,
                      CREATED_BY        ,
                      CREATION_DATE     ,
                      LAST_UPDATED_BY   ,
                      LAST_UPDATE_DATE
               )
               VALUES
               (      l_orgid,
                      PA_LINK_TAB(i).PROJECT_ID        ,
                      PA_LINK_TAB(i).DRAFT_INVOICE_NUM ,
                      PA_LINK_TAB(i).AP_INVOICE_ID     ,
                      l_CREATED_BY        ,
                      l_sysdate           ,
                      l_CREATED_BY        ,
                      l_sysdate
               );
End Loop;

FOR i in  PA_LINK_TAB.first..PA_LINK_TAB.last Loop
        UPDATE PA_PWP_AP_INV_HDR
               SET LINKED_DRAFT_INVOICE_NUM = DECODE(LINKED_DRAFT_INVOICE_NUM, NULL,
                                                     to_char(PA_LINK_TAB(i).DRAFT_INVOICE_NUM),
                                                     LINKED_DRAFT_INVOICE_NUM|| ',' ||
                                                     to_char(PA_LINK_TAB(i).DRAFT_INVOICE_NUM)),
                   LINKED_DRFAT_INV_TYPE = DECODE(LINKED_DRFAT_INV_TYPE,NULL,'M',
                                                  LINKED_DRFAT_INV_TYPE||','||'M')
            WHERE INVOICE_ID = PA_LINK_TAB(i).AP_INVOICE_ID
            AND PROJECT_ID = PA_LINK_TAB(i).PROJECT_ID;
End Loop;

COMMIT;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'U';
  X_msg_data := SQLERRM;
 -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END add_invoice_link;

END PA_PWP_INVOICE_LINKS;

/
