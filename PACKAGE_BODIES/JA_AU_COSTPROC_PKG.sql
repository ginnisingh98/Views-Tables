--------------------------------------------------------
--  DDL for Package Body JA_AU_COSTPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_AU_COSTPROC_PKG" as
/* $Header: jaauicpb.pls 120.2 2003/11/04 23:01:46 ykonishi ship $ */

-- *
-- ** Create JA_AU_LOCAL_ACCOUNT procedure
-- *

PROCEDURE JA_AU_LOCAL_ACCOUNT (x_org_id         IN
           mtl_material_transactions.organization_id%TYPE,
           x_subinv             IN
           mtl_material_transactions.subinventory_code%TYPE,
           x_item_id            IN
           mtl_material_transactions.inventory_item_id%TYPE,
           x_transaction_id     IN      number)
IS

   l_po_imp_req_flag  	VARCHAR2(1);
   l_req_line_id    	po_req_distributions.requisition_line_id%TYPE;
   l_ccid         	gl_code_combinations.code_combination_id%TYPE;

   req_line_id_zero    	exception;

BEGIN

   -- JA_AU_PO_IMP_REQ_FLAG profile controls execution of this program.

   FND_PROFILE.GET('JA_AU_PO_IMP_REQ_FLAG',l_po_imp_req_flag);

   IF nvl(l_po_imp_req_flag,'N') <> 'Y' THEN

      return;

   END IF;
   --

   /* Retrieve requisition_line_id from table RCV_TRANSACTIONS */

   begin
      SELECT nvl(requisition_line_id,0)
        INTO l_req_line_id
        FROM rcv_transactions
       WHERE inv_transaction_id = x_transaction_id
         AND transaction_type = 'RECEIVE'
         AND organization_id = x_org_id;

      /* Call other package for null returned - Bug 2729703 */
      IF l_req_line_id = 0 THEN
         ja_au_ccid_pkg.ja_au_autoaccounting(x_org_id,
                                             x_subinv,
                                             x_item_id,
                                             x_transaction_id);
      END IF;

   exception
      WHEN NO_DATA_FOUND THEN
         ja_au_ccid_pkg.ja_au_autoaccounting(x_org_id,
	                                     x_subinv,
	                                     x_item_id,
                                             x_transaction_id);
         goto end_trigger;
      WHEN OTHERS THEN
         -- dbms_output.put_line('* ERROR retrieving REQUISITION_LINE_ID *');
         -- dbms_output.put_line(sqlerrm);
         goto end_trigger;
   end;


   /* Get the code_combination_id for this req. Field is NOT NULL
      therefore must return a value. */
   BEGIN
    IF l_req_line_id <> 0 THEN
      SELECT code_combination_id
        INTO l_ccid
        FROM po_req_distributions_all
       WHERE requisition_line_id = l_req_line_id;
    END IF;

   exception
      WHEN NO_DATA_FOUND THEN
         -- dbms_output.put_line('* ERROR - Could not retrieve CODE_COMBINATION_ID *');
         goto end_trigger;
      WHEN OTHERS THEN
         -- dbms_output.put_line('* ERROR retrieving CODE_COMBINATION_ID *');
         -- dbms_output.put_line(sqlerrm);
         goto end_trigger;
   END;

   /* Update reference_account field in mtl_transaction_accounts */

    IF l_req_line_id <> 0 THEN
     UPDATE mtl_transaction_accounts
        SET reference_account = l_ccid
      WHERE transaction_id = x_transaction_id
        AND accounting_line_type = 2 ;
    END IF;


<<end_trigger>>
   null;

END JA_AU_LOCAL_ACCOUNT;


END JA_AU_COSTPROC_PKG;

/
