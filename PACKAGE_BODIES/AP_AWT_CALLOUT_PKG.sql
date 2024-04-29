--------------------------------------------------------
--  DDL for Package Body AP_AWT_CALLOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AWT_CALLOUT_PKG" AS
 /* $Header: apibyhkb.pls 120.5 2008/02/13 02:07:11 dbetanco ship $ */

PROCEDURE zx_paymentsAdjustHook(
  p_api_version    IN NUMBER,
  p_init_msg_list  IN VARCHAR2,
  p_commit         IN VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2) IS

  l_pay_service_req_code IBY_HOOK_PAYMENTS_T.call_app_pay_service_req_code%TYPE;
  l_payment_id           IBY_HOOK_PAYMENTS_T.payment_id%TYPE;
  l_checkrun_id          IBY_HOOK_DOCS_IN_PMT_T.calling_app_doc_unique_ref1%TYPE;
  l_return_value NUMBER;

   CURSOR C_IBY_PMTS IS
   SELECT UNIQUE call_app_pay_service_req_code, payment_id
   FROM IBY_HOOK_PAYMENTS_T
   WHERE CALLING_APP_ID = 200;

   CURSOR C_IBY_DOCS IS
   SELECT UNIQUE CALLING_APP_DOC_UNIQUE_REF1
   FROM IBY_HOOK_DOCS_IN_PMT_T
   WHERE PAYMENT_ID = l_payment_id
   AND CALLING_APP_ID=200;

 BEGIN
  l_return_value:=0;

  OPEN c_iby_pmts;
  FETCH c_iby_pmts INTO l_pay_service_req_code, l_payment_id;
  CLOSE c_iby_pmts;

  OPEN c_iby_docs;
  FETCH c_iby_docs INTO l_checkrun_id;
  CLOSE c_iby_docs;

   IF AP_EXTENDED_WITHHOLDING_PKG.ap_extended_withholding_active THEN

     l_return_value:=JG_EXTENDED_WITHHOLDING_PKG.JG_DO_EXTENDED_WITHHOLDING
              (P_Invoice_Id  =>        NULL,
               P_Awt_Date    =>        NULL,
               P_Calling_Module =>     'AUTOSELECT',
               P_Amount      =>        NULL,
               P_Payment_Num   =>      NULL,
               P_Checkrun_Name =>      l_pay_service_req_code,
               P_Checkrun_id  =>       l_checkrun_id,
               P_Last_Updated_By =>      fnd_global.user_id,
               P_Last_Update_Login =>    FND_GLOBAL.LOGIN_ID,
               P_Program_Application_Id =>  fnd_global.prog_appl_id,
               P_Program_Id      =>      fnd_global.conc_program_id,
               P_Request_Id      =>      fnd_global.conc_request_id ,
               P_Invoice_Payment_Id  =>    NULL,
               P_Check_Id            =>   NULL);
   END IF;

 END zx_paymentsAdjustHook;

PROCEDURE zx_witholdingCertificatesHook
 ( p_payment_instruction_id IN NUMBER,
   p_calling_module         IN VARCHAR2,
   p_api_version            IN NUMBER,
   p_init_msg_list          IN VARCHAR2 ,
   p_commit                 IN VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2)
IS

BEGIN

 -- Initizating return variable
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF AP_EXTENDED_WITHHOLDING_PKG.ap_extended_withholding_active THEN

  JL_AR_AP_WITHHOLDING_PKG.Jl_Ar_Ap_certificates (p_payment_instruction_id,
   p_calling_module,
   p_api_version,
   p_init_msg_list ,
   p_commit,
   x_return_status,
   x_msg_count,
   x_msg_data);
 END IF;

END;


END AP_AWT_CALLOUT_PKG;

/
