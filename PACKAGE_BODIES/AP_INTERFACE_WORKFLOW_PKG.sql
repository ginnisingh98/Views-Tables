--------------------------------------------------------
--  DDL for Package Body AP_INTERFACE_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INTERFACE_WORKFLOW_PKG" AS
/* $Header: apiiwkfb.pls 120.3 2004/10/28 23:20:13 pjena noship $ */

----------------------------------------------------------------------
PROCEDURE Custom_Validate_Invoice(p_item_type	IN VARCHAR2,
			     	  p_item_key	IN VARCHAR2,
			     	  p_actid	IN NUMBER,
			     	  p_funmode	IN VARCHAR2,
			     	  p_result	OUT NOCOPY VARCHAR2) IS
----------------------------------------------------------------------
  l_invoice_id			NUMBER;
  l_return_error_message	VARCHAR2(2000);
  l_debug_info			VARCHAR2(200);
BEGIN

  IF (p_funmode = 'RUN') THEN

    ------------------------------------------------
    l_debug_info := 'Get INVOICE_ID Item Attribute';
    ------------------------------------------------
    l_invoice_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                p_item_key,
                                                'INVOICE_ID');

    --------------------------------------------
    l_debug_info := 'Call Do_Custom_Validation';
    --------------------------------------------
    Do_Custom_Validation(l_invoice_id,
                         l_return_error_message);

    IF (l_return_error_message IS NULL) THEN

      -----------------------------------------------
      l_debug_info := 'Update Workflow Flag to Done';
      -----------------------------------------------
      UPDATE ap_invoices_interface
      SET    workflow_flag = 'D'
      WHERE  invoice_id = l_invoice_id;

      ---------------------------------------------
      l_debug_info := 'Commit changes to database';
      ---------------------------------------------
      COMMIT;

      p_result := 'COMPLETE:AP_PASS';

    ELSE
      ---------------------------------------------------
      l_debug_info := 'Set ERROR_MESSAGE Item Attribute';
      ---------------------------------------------------
      WF_ENGINE.SetItemAttrText(p_item_type,
                                p_item_key,
                                'ERROR_MESSAGE',
                                l_return_error_message);

      p_result := 'COMPLETE:AP_FAIL';

    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('AP_INTERFACE_WORKFLOW_PKG', 'Custom_Validate_Invoice',
                     p_item_type, p_item_key, to_char(p_actid), l_debug_info);
    RAISE;
END Custom_Validate_Invoice;



---------------------------------------------------------------------------
PROCEDURE Do_Custom_Validation(p_invoice_id           IN NUMBER,
                               p_return_error_message OUT NOCOPY VARCHAR2) IS
---------------------------------------------------------------------------
  l_debug_info			VARCHAR2(200);
BEGIN

  p_return_error_message := NULL;

  --------------------------------------------------------------------
  -- ADD CUSTOM VALIDATION CODE BELOW
  --
  -- Set p_return_error_message to meaningful error message on failure
  --------------------------------------------------------------------


EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('AP_INTERFACE_WORKFLOW_PKG', 'Do_Custom_Validation',
                     null, null, null, l_debug_info);
    RAISE;
END Do_Custom_Validation;


---------------------------------------------------------------------------
PROCEDURE Start_Invoice_Process(p_invoice_id IN NUMBER) IS
---------------------------------------------------------------------------
  l_item_type	VARCHAR2(100) := 'APIMP';
  l_item_key	VARCHAR2(100);
  l_debug_info	VARCHAR2(200);
BEGIN

    -----------------------------------------------
    l_debug_info := 'Generate Unique Item Key';
    -----------------------------------------------
    l_item_key := to_char(p_invoice_id) || to_char(sysdate,'MMDDYYYYHH24MISS');

    -----------------------------------------------
    l_debug_info := 'Create Workflow Process';
    -----------------------------------------------
    WF_ENGINE.CreateProcess(l_item_type,
                            l_item_key,
                            'CUSTOM_VALIDATION_PROCESS');

    ------------------------------------------------
    l_debug_info := 'Set INVOICE_ID Item Attribute';
    ------------------------------------------------
    WF_ENGINE.SetItemAttrNumber(l_item_type,
                                l_item_key,
                                'INVOICE_ID',
                                p_invoice_id);

    ---------------------------------------------------
    l_debug_info := 'Update Workflow Flag to Selected';
    ---------------------------------------------------
    UPDATE ap_invoices_interface
    SET    workflow_flag = 'S'
    WHERE  invoice_id = p_invoice_id;

    ---------------------------------------------
    l_debug_info := 'Commit changes to database';
    ---------------------------------------------
    COMMIT;

    -----------------------------------------
    l_debug_info := 'Start Workflow Process';
    -----------------------------------------
    WF_ENGINE.StartProcess(l_item_type,
			   l_item_key);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'Start_Invoice_Process');
      FND_MESSAGE.SET_TOKEN('PARAMETERS','P_INVOICE_ID='||p_invoice_id);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Start_Invoice_Process;

END AP_INTERFACE_WORKFLOW_PKG;

/
