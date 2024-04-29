--------------------------------------------------------
--  DDL for Package Body DPP_TRANSACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_TRANSACTION_PVT" AS
    /* $Header: dppvtxnb.pls 120.89.12010000.16 2010/04/26 07:16:05 pvaramba ship $ */
    -- Package name     : DPP_TRANSACTION_PVT
    -- Purpose          : For Validation and Creation of Price Protection Transaction
    -- History          :
    --27-Aug-07  sanagar      Creation
    --29-Jan-08  sanagar      Bug 6773981
    --06-Feb-08  sanagar      Negative Change Value Handled
    --                          suppliername,Supplier site and Ref Doc Number identifies transaction
    --                          Update_claimsApproval claim id included in query.
    --08-Feb-08  sanagar      Included event and subscription test(wf_event.test)
    --                          Rounded change value to 2 decimal
    --08-Feb-08  sanagar      BUG 6806974
    --24-Feb-08  sanagar      BUG 6816594
    --03-Mar-08  sanagar      BUG 6856618
    --22-Apr-08  sanagar      BUG 6988008,      6988312
    --12-May-08  sanagar      Changed ozf_sys_parameters_all to hr_operating_units
    --14-May-08  sanagar      Boundary Conditions for Change Value based on change type
    --04-Jul-08  sanagar      Change value & change type checks only for inbound
    --08-Oct-08  rvkondur     Added code for DPP Price Increase Enhancement
    --19-May-09  anbbalas     prior_price column in the interface table is not being used
    --                          while importing the price protection transaction.
    --22-May-09  rvkondur     Fix for Bug# 7630178
    --25-May-09  anbbalas     Adjustment flow and Parallel Approval - 12.1.2 Project
	 --01-Jun-09  anbbalas		Bug no.8563518 - Validation for negative Prior Price and
    --                         negative Change Value when the change type is Amount Decrease

    -- NOTE             :
    dpp_debug_high_on constant boolean := fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_debug_high);
    dpp_debug_low_on constant boolean := fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_debug_low);
    dpp_debug_medium_on constant boolean := fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_debug_medium);

    g_pkg_name constant VARCHAR2(30) := 'DPP_TRANSACTION_PVT';
    g_debug boolean := fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_debug_high);
    g_file_name constant VARCHAR2(14) := 'dppvtxnb.pls';

    PROCEDURE Update_InterfaceErrSts(
                  p_txn_header_rec_type IN OUT nocopy txn_header_rec,
                  x_return_status OUT nocopy VARCHAR2
                  )
AS

l_api_name constant VARCHAR2(30) := 'Update_InterfaceErrSts';
l_user_id NUMBER :=FND_PROFILE.VALUE('USER_ID');
BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
       IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update InterfaceErrSts');
        END IF;

        --Update Interface Header table with error status
        UPDATE DPP_TXN_HEADERS_INT_ALL dtha
        SET
            dtha.last_update_date           =   SYSDATE,
            dtha.last_updated_by            =    nvl(l_user_id,0),
            dtha.last_update_login          =    nvl(l_user_id,0),
            dtha.interface_status           =      'E',
            dtha.error_code                 =   decode(dtha.error_code,NULL,nvl(p_txn_header_rec_type.error_code,'SQL_PLSQL_ERROR'),'MULTIPLE_ERRORS')
        WHERE transaction_int_header_id = p_txn_header_rec_type.transaction_int_header_id;
             COMMIT;

       IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update InterfaceErrSts');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||sqlerrm);
    END Update_InterfaceErrSts;

    PROCEDURE Validate_OperatingUnit(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,x_msg_count OUT nocopy NUMBER
              ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Validate_OperatingUnit';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_value  NUMBER;


    BEGIN
      IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Operating Unit');
      END IF;
  -- Initialize API return status to sucess
      x_return_status := fnd_api.g_ret_sts_success;
      --BUG 6806974
      IF p_txn_header_rec_type.operating_unit_name IS NULL
      AND p_txn_header_rec_type.org_id IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name( 'DPP',   'DPP_TXN_OPERATING_UNIT_NULL');
            x_msg_data := fnd_message.get();
        END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              p_txn_header_rec_type.error_code := 'DPP_TXN_OPERATING_UNIT_NULL';
      RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      SELECT fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL') into l_value from dual;

      mo_global.set_org_access( null,l_value,'M');


      SELECT hr.organization_id
            ,hr.name
        INTO p_txn_header_rec_type.org_id
            ,p_txn_header_rec_type.operating_unit_name
        FROM hr_operating_units hr
       WHERE hr.name = nvl(p_txn_header_rec_type.operating_unit_name,hr.name) AND
        hr.organization_id =nvl(to_number(p_txn_header_rec_type.org_id),hr.organization_id)
        AND mo_global.check_access(hr.organization_id) = 'Y' ;
  --MOAC
        MO_GLOBAL.set_policy_context('S', p_txn_header_rec_type.org_id);
      IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Validate Operating Unit');
      END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        x_return_status := fnd_api.g_ret_sts_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name( 'DPP',   'DPP_TXN_OPERATING_UNIT_ERR');
            fnd_message.set_token('OPERATING_UNIT', p_txn_header_rec_type.operating_unit_name);
            fnd_message.set_token('ORG_ID', p_txn_header_rec_type.org_id);
            x_msg_data := fnd_message.get();
        END IF;
         p_txn_header_rec_type.error_code := 'DPP_TXN_OPERATING_UNIT_ERR';
         WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',   l_full_name);
            fnd_message.set_token('ERRNO',   SQLCODE);
            fnd_message.set_token('REASON',   sqlerrm);
        END IF;
        x_msg_data := fnd_message.get();
    END Validate_OperatingUnit;


   FUNCTION has_docnum_chars (
     p_docnum    IN  VARCHAR2
 ,   p_docnum_chars        IN  VARCHAR2 DEFAULT 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_'
 )
 RETURN VARCHAR2
 IS
     l_is_valid      VARCHAR2(1);
 BEGIN
     IF (TRANSLATE (UPPER(p_docnum)
         ,          fnd_global.local_chr(1) || p_docnum_chars
         ,          fnd_global.local_chr(1)) IS NULL) THEN
         l_is_valid := 'Y';
     ELSE
         l_is_valid := 'N';
     END IF;
     RETURN (l_is_valid);
 END has_docnum_chars;


    PROCEDURE Validate_RefDocNumber(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,x_msg_count OUT nocopy NUMBER
                          ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Validate_RefDocNumber';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_valid_doc VARCHAR2(1);
    BEGIN
      IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Document Reference Number');
      END IF;
-- Initialize API return status to sucess
      x_return_status := fnd_api.g_ret_sts_success;
      IF p_txn_header_rec_type.ref_document_number IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('DPP',   'DPP_DOC_REF_NUM_NULL');
        END IF;
         x_msg_data := fnd_message.get();
         p_txn_header_rec_type.error_code := 'DPP_DOC_REF_NUM_NULL';
       RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
--Call function to validate the document ref number for special characters other than _ and -.
      l_valid_doc := dpp_transaction_pvt.has_docnum_chars(
                              p_docnum => p_txn_header_rec_type.ref_document_number
                              );

       IF l_valid_doc = 'N'  OR length(p_txn_header_rec_type.ref_document_number) > 40 THEN
        x_return_status := fnd_api.g_ret_sts_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('DPP',   'DPP_DOC_REF_NUM_ERR');
            fnd_message.set_token('DOC_REF_NO',  p_txn_header_rec_type.ref_document_number);
        END IF;
         x_msg_data := fnd_message.get();
         p_txn_header_rec_type.error_code := 'DPP_DOC_REF_NUM_ERR';
      END IF;
        IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Validate Document Reference Number');
        END IF;
    EXCEPTION
      WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
      WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   l_full_name);
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
                x_msg_data := fnd_message.get();
            END IF;
    END Validate_RefDocNumber;

PROCEDURE Validate_SupplierDetails(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,x_msg_count OUT nocopy NUMBER
              ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
AS
        l_api_name constant VARCHAR2(30) := 'Validate_SupplierDetails';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_trunc_sysdate DATE := TRUNC(SYSDATE);

BEGIN
        IF DPP_DEBUG_HIGH_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Supplier Details');
        END IF;
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        --BUG 6806974
      IF (p_txn_header_rec_type.vendor_name IS NULL
         AND p_txn_header_rec_type.vendor_id IS NULL) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name('DPP',   'DPP_TXN_SUPP_INFO_NULL');
        x_msg_data :=fnd_message.get();
      END IF;
        p_txn_header_rec_type.error_code := 'DPP_TXN_SUPP_INFO_NULL';
      RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      --Validate Supplier Name
  BEGIN
   SELECT ap.vendor_id
          ,ap.vendor_name
    INTO  p_txn_header_rec_type.vendor_id
          ,p_txn_header_rec_type.vendor_name
    FROM   ap_suppliers ap
    WHERE (ap.vendor_name = NVL(p_txn_header_rec_type.vendor_name,ap.vendor_name) AND
       ap.vendor_id = NVL(to_number(p_txn_header_rec_type.vendor_id),ap.vendor_id))
       AND ap.enabled_flag = 'Y'
       AND ap.hold_flag = 'N'
       AND TRUNC(sysdate) >= nvl(TRUNC(start_date_active),   TRUNC(sysdate))
       AND TRUNC(sysdate) < nvl(TRUNC(end_date_active),   TRUNC(sysdate) + 1);
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := fnd_api.g_ret_sts_error;
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name('DPP',   'DPP_TXN_SUPP_INFO_ERR');
        fnd_message.set_token('SUPPLIER_NAME', p_txn_header_rec_type.vendor_name);
        fnd_message.set_token('SUPPLIER_ID',  p_txn_header_rec_type.vendor_id);
        x_msg_data :=fnd_message.get();
      END IF;
      p_txn_header_rec_type.error_code := 'DPP_TXN_SUPP_INFO_ERR';
        RAISE Fnd_Api.G_EXC_ERROR;
   END;
   --Validate Supplier Site
   IF (p_txn_header_rec_type.vendor_site_code IS NULL
         AND p_txn_header_rec_type.vendor_site_id IS NULL) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name('DPP',   'DPP_TXN_SUPP_SITE_NULL');
        x_msg_data :=fnd_message.get();
      END IF;
        p_txn_header_rec_type.error_code := 'DPP_TXN_SUPP_SITE_NULL';
      RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
    BEGIN
      SELECT apssa.vendor_site_id
            ,apssa.vendor_site_code
       INTO  p_txn_header_rec_type.vendor_site_id
            ,p_txn_header_rec_type.vendor_site_code
       FROM ap_supplier_sites_all apssa,
            ozf_supp_trd_prfls_all ostp
      WHERE apssa.vendor_id = to_number(p_txn_header_rec_type.vendor_id)
       AND ostp.supplier_id = apssa.vendor_id
       AND ostp.supplier_site_id = apssa.vendor_site_id
       AND ostp.org_id = apssa.org_id
       AND nvl(apssa.rfq_only_site_flag,   'N') = 'N'
       AND nvl(apssa.inactive_date,   l_trunc_sysdate + 1) > l_trunc_sysdate
       AND (apssa.vendor_site_code = nvl(p_txn_header_rec_type.vendor_site_code,apssa.vendor_site_code)
       AND apssa.vendor_site_id = nvl(to_number(p_txn_header_rec_type.vendor_site_id), apssa.vendor_site_id))
       AND apssa.org_id = to_number(p_txn_header_rec_type.org_id);
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_return_status := fnd_api.g_ret_sts_error;
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name('DPP',   'DPP_TXN_SUPP_SITE_ERR');
        fnd_message.set_token('SUPPLIER_SITE',   p_txn_header_rec_type.vendor_site_code);
        fnd_message.set_token('SITE_ID',  p_txn_header_rec_type.vendor_site_id);
        x_msg_data :=fnd_message.get();
      END IF;
      p_txn_header_rec_type.error_code := 'DPP_TXN_SUPP_SITE_ERR';
      RAISE Fnd_Api.G_EXC_ERROR;
   END;
    IF DPP_DEBUG_HIGH_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Validate Supplier Details Vendor Id: '||p_txn_header_rec_type.vendor_id);
    END IF;
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
    WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',   l_full_name);
            fnd_message.set_token('ERRNO',   SQLCODE);
            fnd_message.set_token('REASON',   sqlerrm);
            x_msg_data :=fnd_message.get();
        END IF;
END Validate_SupplierDetails;

--ANBBALAS for 12_1_2
PROCEDURE Validate_SupplierTrdPrfl(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,x_supp_trade_profile_id OUT nocopy NUMBER
              ,x_msg_count OUT nocopy NUMBER
              ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
AS
        l_api_name constant VARCHAR2(30) := 'Validate_SupplierTrdPrfl';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_supp_trade_profile_id  NUMBER;

--Cursor to retrieve the supplier trade profile id
CURSOR get_supp_trd_prfl_csr (p_vendor_id NUMBER, p_vendor_site_id NUMBER, p_org_id NUMBER)
  IS
  SELECT supp_trade_profile_id
  FROM ozf_supp_trd_prfls_all
  WHERE supplier_id = p_vendor_id
    AND supplier_site_id = p_vendor_site_id
    AND org_id = p_org_id;

BEGIN
    IF DPP_DEBUG_HIGH_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Supplier Trade Profile');
    END IF;
    -- Initialize API return status to sucess
    x_return_status := fnd_api.g_ret_sts_success;

   BEGIN
     OPEN get_supp_trd_prfl_csr(p_txn_header_rec_type.vendor_id, p_txn_header_rec_type.vendor_site_id, p_txn_header_rec_type.org_id);
       FETCH get_supp_trd_prfl_csr INTO l_supp_trade_profile_id;
     CLOSE get_supp_trd_prfl_csr;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := fnd_api.g_ret_sts_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('DPP','DPP_SUPP_TRDPRFLS_MISSING_ERR');
          x_msg_data :=fnd_message.get();
        END IF;
        p_txn_header_rec_type.error_code := 'DPP_SUPP_TRDPRFLS_MISSING_ERR';
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier trade profile setup not available');
        FND_FILE.NEW_LINE(FND_FILE.LOG);
        RAISE FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while fetching supp_trade_profile_id: ' || SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   x_supp_trade_profile_id := l_supp_trade_profile_id;

   IF DPP_DEBUG_HIGH_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Validate Supplier Trade Profile for Vendor Id: ' || p_txn_header_rec_type.vendor_id);
   END IF;
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
        x_return_status := Fnd_Api.g_ret_sts_error ;
    WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',   l_full_name);
            fnd_message.set_token('ERRNO',   SQLCODE);
            fnd_message.set_token('REASON',   sqlerrm);
            x_msg_data :=fnd_message.get();
        END IF;
END Validate_SupplierTrdPrfl;

--ANBBALAS for 12_1_2
PROCEDURE Validate_ExecProcessSetup(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,p_supp_trade_profile_id IN OUT nocopy NUMBER
              ,x_msg_count OUT nocopy NUMBER
              ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
AS
    l_api_name constant VARCHAR2(30) := 'Validate_ExecProcessSetup';
    l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

    l_count   NUMBER := 0;

CURSOR get_process_setup_cnt_csr (p_supp_trade_profile_id NUMBER, p_org_id NUMBER)
  IS
  SELECT COUNT(1)
  FROM OZF_PROCESS_SETUP_ALL
  WHERE nvl(supp_trade_profile_id,0) = nvl(p_supp_trade_profile_id,0)
    AND enabled_flag = 'Y'
    AND org_id = p_org_id;

BEGIN
    IF DPP_DEBUG_HIGH_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Execution Process Setup');
    END IF;
    -- Initialize API return status to sucess
    x_return_status := fnd_api.g_ret_sts_success;

    --Check if the Process Setup is done for the Supplier, Supplier site and Operating Unit
    BEGIN
      OPEN get_process_setup_cnt_csr(p_supp_trade_profile_id, p_txn_header_rec_type.org_id);
        FETCH get_process_setup_cnt_csr INTO l_count;
      CLOSE get_process_setup_cnt_csr;

      IF l_count = 0 THEN       --Process Setup does not exist for the Supplier Trade Profile
        p_supp_trade_profile_id := null;
        OPEN get_process_setup_cnt_csr(p_supp_trade_profile_id, p_txn_header_rec_type.org_id);
          FETCH get_process_setup_cnt_csr INTO l_count;
        CLOSE get_process_setup_cnt_csr;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception while fetching from OZF_PROCESS_SETUP_ALL: '||SQLERRM);
         FND_FILE.NEW_LINE(FND_FILE.LOG);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF l_count = 0 THEN  --Process Setup does not exist
      x_return_status := fnd_api.g_ret_sts_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_message.set_name( 'DPP','DPP_PROCESS_SETUP_MISSING_ERR');
        x_msg_data :=fnd_message.get();
      END IF;
      p_txn_header_rec_type.error_code := 'DPP_PROCESS_SETUP_MISSING_ERR';
      FND_FILE.PUT_LINE(FND_FILE.LOG,'No Execution processes setup available for this transaction.');
      FND_FILE.NEW_LINE(FND_FILE.LOG);
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    IF DPP_DEBUG_HIGH_ON THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Validate Execution Process Setup for Vendor Id: ' || p_txn_header_rec_type.vendor_id);
    END IF;
EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
        x_return_status := Fnd_Api.g_ret_sts_error ;
    WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',   l_full_name);
            fnd_message.set_token('ERRNO',   SQLCODE);
            fnd_message.set_token('REASON',   sqlerrm);
            x_msg_data :=fnd_message.get();
        END IF;
END Validate_ExecProcessSetup;

PROCEDURE Validate_lines(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,x_msg_count OUT nocopy NUMBER
              ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
AS
        l_api_name constant VARCHAR2(30) := 'Validate_lines';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_trunc_sysdate DATE := TRUNC(SYSDATE);
        l_duplicate_lines NUMBER;
        l_error_message VARCHAR2(4000) := NULL;
        l_lines NUMBER;

BEGIN
        IF DPP_DEBUG_HIGH_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Lines Details');
        END IF;
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;


--Check for Duplicate Lines in Interface Table
        BEGIN
          BEGIN
            SELECT COUNT(dtlia.supplier_part_num)
              INTO l_duplicate_lines
              FROM dpp_txn_headers_int_all dthia,
                   dpp_txn_lines_int_all dtlia
             WHERE dthia.transaction_int_header_id = dtlia.transaction_int_header_id
               AND dthia.transaction_int_header_id = p_txn_header_rec_type.transaction_int_header_id
             GROUP BY dtlia.supplier_part_num
             HAVING COUNT(dtlia.supplier_part_num) > 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_duplicate_lines := NULL;
                WHEN TOO_MANY_ROWS THEN
                --This exception raises when the transaction has more than one row with distinct supplier part numbers
               NULL;
            END;

            IF l_duplicate_lines < 2  OR l_duplicate_lines IS NULL THEN
             BEGIN
              SELECT COUNT(dtlia.item_number)
                INTO l_duplicate_lines
                FROM dpp_txn_headers_int_all dthia,
                     dpp_txn_lines_int_all dtlia
               WHERE dthia.transaction_int_header_id = dtlia.transaction_int_header_id
                 AND dthia.transaction_int_header_id = p_txn_header_rec_type.transaction_int_header_id
               GROUP BY dtlia.item_number
               HAVING COUNT(dtlia.item_number) > 1;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_duplicate_lines := NULL;
                WHEN TOO_MANY_ROWS THEN
                --This exception raises when the transaction has more than one row with distinct supplier part numbers
                   NULL;
              END;
              END IF;
              IF l_duplicate_lines < 2  OR l_duplicate_lines IS NULL THEN
              BEGIN
              SELECT COUNT(dtlia.inventory_item_id)
                INTO l_duplicate_lines
                FROM dpp_txn_headers_int_all dthia,
                     dpp_txn_lines_int_all dtlia
               WHERE dthia.transaction_int_header_id = dtlia.transaction_int_header_id
                 AND dthia.transaction_int_header_id = p_txn_header_rec_type.transaction_int_header_id
               GROUP BY dtlia.inventory_item_id
               HAVING COUNT(dtlia.inventory_item_id) > 1;
             EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_duplicate_lines := NULL;
                WHEN TOO_MANY_ROWS THEN
                --This exception raises when the transaction has more than one row with distinct supplier part numbers
                   NULL;
              END;
            END IF;
            IF l_duplicate_lines > 1 THEN
                  fnd_message.set_name('DPP',   'DPP_DUPLICATE_TXN_LINES');
                  x_msg_data := fnd_message.get();
                  p_txn_header_rec_type.error_code := 'DPP_DUPLICATE_TXN_LINES';
                   x_return_status := Fnd_Api.g_ret_sts_error ;
                  --RAISE Fnd_Api.G_EXC_ERROR;
                  l_error_message := l_error_message ||x_msg_data;
            END IF;
        END;

      BEGIN
               --get inventory organization id
              SELECT inventory_organization_id
                INTO p_txn_header_rec_type.inventory_organization_id
                FROM financials_system_params_all
              WHERE org_id = to_number(p_txn_header_rec_type.org_id);

              SELECT  gs.currency_code
                INTO    p_txn_header_rec_type.functional_currency
                FROM   gl_sets_of_books gs
                ,      hr_operating_units hr
                WHERE  hr.set_of_books_id = gs.set_of_books_id
                AND    hr.organization_id = p_txn_header_rec_type.org_id;
             EXCEPTION WHEN OTHERS THEN
                    fnd_message.set_name('DPP',   'DPP_TXN_FUNC_CURR_ERR');
                        x_msg_data := fnd_message.get();
                        p_txn_header_rec_type.error_code := 'DPP_TXN_FUNC_CURR_ERR';
                         x_return_status := Fnd_Api.g_ret_sts_error ;
                        --RAISE Fnd_Api.G_EXC_ERROR;
                        l_error_message := l_error_message ||x_msg_data;
                         Update_InterfaceErrSts(
                                        p_txn_header_rec_type => p_txn_header_rec_type
                                        ,x_return_status =>x_return_status
                                        );
             END;
BEGIN
  SELECT 1 INTO l_lines FROM
  dpp_txn_lines_int_all dtla WHERE
  dtla.transaction_int_header_id = p_txn_header_rec_type.transaction_int_header_id;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('DPP',   'DPP_TXN_NO_LINES');
              x_msg_data :=fnd_message.get();
              p_txn_header_rec_type.error_code := 'DPP_TXN_NO_LINES';
              l_error_message := l_error_message ||x_msg_data;
              x_return_status := Fnd_Api.g_ret_sts_error ;
  WHEN TOO_MANY_ROWS THEN
  null;
    END;
 EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
    WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',   l_full_name);
            fnd_message.set_token('ERRNO',   SQLCODE);
            fnd_message.set_token('REASON',   sqlerrm);
            x_msg_data :=fnd_message.get();
        END IF;
   END Validate_lines;

PROCEDURE Get_DaysCovered(
                    p_txn_header_rec_type IN OUT nocopy txn_header_rec
                    ,x_msg_count OUT nocopy NUMBER
                    ,x_msg_data OUT nocopy VARCHAR2
                    ,x_return_status OUT nocopy VARCHAR2)
    AS
    BEGIN

     IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Get Days Covered');
     END IF;
   -- Initialize API return status to sucess
    x_return_status := fnd_api.g_ret_sts_success;
        SELECT default_days_covered
          INTO p_txn_header_rec_type.days_covered
          FROM ozf_supp_trd_prfls_all ostpa
         WHERE ostpa.supplier_id =to_number(p_txn_header_rec_type.vendor_id)
           AND ostpa.supplier_site_id =to_number(p_txn_header_rec_type.vendor_site_id);

     IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Get Days Covered');
     END IF;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
                x_return_status := fnd_api.g_ret_sts_error;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                  fnd_message.set_name('DPP',   'DPP_DAYS_COVRD_ERR');
                  fnd_message.set_token('SUPPLIER_NAME',  p_txn_header_rec_type.vendor_name);
                  x_msg_data :=fnd_message.get();
                END IF;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                p_txn_header_rec_type.error_code := 'DPP_DAYS_COVRD_ERR';
        WHEN others THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
    END  Get_DaysCovered;

    PROCEDURE Validate_Currency(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,x_msg_count OUT nocopy NUMBER
                          ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Validate_Currency';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_error_message VARCHAR2(4000) := NULL;
        l_transaction_number VARCHAR2(55);

        --ANBBALAS for 12_1_2
        l_trunc_eff_start_date    DATE := NULL;
        l_trunc_sys_date          DATE := NULL;
        l_txn_status_lookup_code  VARCHAR2(30) := NULL;

    --Cursor to get the truncated effective start date and system date
    CURSOR get_trunc_dates(effective_start_date DATE)
    IS
      SELECT trunc(effective_start_date), TRUNC(SYSDATE)
      FROM DUAL;

    BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
       IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Currency');
       END IF;
       IF p_txn_header_rec_type.trx_currency IS NULL THEN
            fnd_message.set_name('DPP',   'DPP_TXN_CURR_NULL');
            x_msg_data :=fnd_message.get();
       p_txn_header_rec_type.error_code := 'DPP_TXN_CURR_NULL';
       l_error_message := l_error_message || x_msg_data;
       --RAISE Fnd_Api.G_EXC_ERROR ;
       END IF;
    BEGIN
     SELECT currency_code
       INTO p_txn_header_rec_type.trx_currency
       FROM fnd_currencies
      WHERE currency_flag = 'Y'
        AND enabled_flag = 'Y'
        AND currency_code =p_txn_header_rec_type.trx_currency;
       IF DPP_DEBUG_HIGH_ON THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Validate Currency');
       END IF;
     EXCEPTION WHEN no_data_found THEN
        x_return_status := fnd_api.g_ret_sts_error;
            fnd_message.set_name('DPP',   'DPP_TXN_CURR_ERR');
            fnd_message.set_token('CURRENCY_CODE', p_txn_header_rec_type.trx_currency);
            x_msg_data :=fnd_message.get();
            l_error_message := l_error_message || x_msg_data;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
       p_txn_header_rec_type.error_code := 'DPP_TXN_CURR_ERR';
       END;
        --for only inbound
        IF p_txn_header_rec_type.supplier_approved_by is NULL THEN
       --Validation part in Create Header
        BEGIN
            SELECT dpp_transaction_hdr_id_seq.nextval
            INTO p_txn_header_rec_type.transaction_header_id
            FROM dual;
        EXCEPTION
            WHEN no_data_found THEN
                x_return_status := fnd_api.g_ret_sts_error;
                    fnd_message.set_name('DPP',   'DPP_TXN_SEQ_NO_ERR');
                    fnd_message.set_token('SEQ_NUM', 'Transaction Header Id');
                    x_msg_data := fnd_message.get();
                    l_error_message := l_error_message || x_msg_data;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                l_error_message :=l_error_message|| x_msg_data;
                 p_txn_header_rec_type.error_code := 'DPP_TXN_SEQ_NO_ERR';
                --RAISE Fnd_Api.G_EXC_ERROR;
        END;

        LOOP
            --Get transaction Number from sequence
            BEGIN
                SELECT dpp_transaction_number_seq.nextval
                INTO p_txn_header_rec_type.transaction_number
                FROM dual;

            EXCEPTION
                WHEN no_data_found THEN
                    x_return_status := fnd_api.g_ret_sts_error;
                    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                        fnd_message.set_name('DPP',   'DPP_TXN_SEQ_NO_ERR');
                        fnd_message.set_token('SEQ_NUM', 'Transaction Number');
                    END IF;
                   x_msg_data := fnd_message.get();
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                   p_txn_header_rec_type.error_code := 'DPP_TXN_SEQ_NO_ERR';
                   l_error_message :=l_error_message|| x_msg_data;
                  --RAISE Fnd_Api.G_EXC_ERROR;
            END;
                --Check the transaction number generated is present in the table
                BEGIN
                    --Check Transaction Number
                    SELECT transaction_number
                      INTO l_transaction_number
                      FROM dpp_transaction_headers_all dtha
                     WHERE dtha.transaction_number = p_txn_header_rec_type.transaction_number;
                EXCEPTION
                    WHEN no_data_found THEN
                        l_transaction_number := NULL;
                END;
                --If present get next sequence number else proceed
                EXIT WHEN l_transaction_number IS NULL;
            END LOOP;

        --ANBBALAS for 12_1_2 - Start
        BEGIN
          OPEN get_trunc_dates(p_txn_header_rec_type.effective_start_date);
            FETCH get_trunc_dates INTO l_trunc_eff_start_date, l_trunc_sys_date;
          CLOSE get_trunc_dates;
        EXCEPTION
          WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_error;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
               fnd_message.set_name('DPP',   'DPP_TXN_STS_ERR');
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error while getting the truncated date' || x_msg_data);
            p_txn_header_rec_type.error_code := 'DPP_TXN_STS_ERR';
            l_error_message := l_error_message || x_msg_data;
        END;

        IF l_trunc_eff_start_date <= l_trunc_sys_date THEN
          l_txn_status_lookup_code := 'PENDING_ADJUSTMENT';
        ELSE
          l_txn_status_lookup_code := 'ACTIVE';
        END IF;
        --ANBBALAS for 12_1_2 - End

        --Get Transaction Status from Lookup
        BEGIN
            SELECT lookup_code
              INTO p_txn_header_rec_type.transaction_status
              FROM fnd_lookups
             WHERE lookup_type = 'DPP_TRANSACTION_STATUSES'
               AND lookup_code = l_txn_status_lookup_code; --ANBBALAS for 12_1_2
        EXCEPTION
            WHEN no_data_found THEN
                x_return_status := fnd_api.g_ret_sts_error;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                    fnd_message.set_name('DPP',   'DPP_TXN_STS_ERR');
                END IF;
                 x_msg_data := fnd_message.get();
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                 p_txn_header_rec_type.error_code := 'DPP_TXN_STS_ERR';
                 l_error_message :=l_error_message|| x_msg_data;
                --RAISE Fnd_Api.G_EXC_ERROR;
        END;


        --Get days covered if it is null
        IF p_txn_header_rec_type.days_covered IS NULL THEN
            Get_DaysCovered(p_txn_header_rec_type => p_txn_header_rec_type
                         ,x_msg_count         => x_msg_count
                         ,x_msg_data          => x_msg_data
                         ,x_return_status     => x_return_status
                        );
        END IF;
        IF x_return_status =  Fnd_Api.g_ret_sts_error OR  x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
          l_error_message :=l_error_message|| x_msg_data;
        END IF;
       IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Validating Days Covered');
       END IF;
        --Validate the given days covered should  be between 0 and 9999
        IF p_txn_header_rec_type.days_covered <= 0
                OR p_txn_header_rec_type.days_covered > 9999
                OR p_txn_header_rec_type.days_covered <> ROUND(p_txn_header_rec_type.days_covered)
                THEN
              x_return_status := fnd_api.g_ret_sts_error;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('DPP',   'DPP_TXN_DAYS_COV_ERR');
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
            p_txn_header_rec_type.error_code := 'DPP_TXN_DAYS_COV_ERR';
            l_error_message :=l_error_message|| x_msg_data;
            --RAISE Fnd_Api.g_exc_error;
        END IF;
         IF p_txn_header_rec_type.effective_start_date IS NULL  THEN
              x_return_status := fnd_api.g_ret_sts_error;
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('DPP',   'DPP_EFF_START_DATE_ERR');
              END IF;
              x_msg_data := fnd_message.get();
              FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
              p_txn_header_rec_type.error_code := 'DPP_EFF_START_DATE_ERR';
              l_error_message :=l_error_message|| x_msg_data;
              --RAISE Fnd_Api.g_exc_error;
        END IF;
        END IF; -- end if only for inbound
        IF l_error_message IS NOT NULL THEN
        x_msg_data := l_error_message;
        RAISE Fnd_Api.g_exc_error;
        END IF;
    EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
            x_return_status := Fnd_Api.g_ret_sts_error ;
    WHEN others THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE',  l_full_name);
          fnd_message.set_token('ERRNO',   SQLCODE);
          fnd_message.set_token('REASON',   sqlerrm);
        END IF;
          x_msg_data :=fnd_message.get();
          FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END Validate_Currency;



    PROCEDURE Create_Header(
              p_txn_header_rec_type IN OUT nocopy txn_header_rec
              ,x_msg_count OUT nocopy NUMBER
                          ,x_msg_data OUT nocopy VARCHAR2
              ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Create_Header';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');
        l_transaction_number VARCHAR2(55);
        l_error_message VARCHAR2(4000) := NULL;
    BEGIN
       IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin  Create Header');
       END IF;
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        --Get Transaction Header Id from sequence

        IF DPP_DEBUG_HIGH_ON THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'        Inserting Transaction Header');
        END IF;
        INSERT INTO DPP_TRANSACTION_HEADERS_ALL(
            object_version_number
            ,transaction_header_id
            ,transaction_number
            ,ref_document_number
            ,vendor_id
            ,vendor_contact_id
            ,vendor_contact_name
            ,contact_email_address
            ,contact_phone
            ,vendor_site_id
            ,transaction_source
            ,effective_start_date
            ,days_covered
            ,transaction_status
            ,org_id
            ,orig_sys_document_ref
            ,creation_date
            ,last_refreshed_by
            ,last_refreshed_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,last_update_login
            ,request_id
            ,program_application_id
            ,program_id
            ,program_update_date
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,attribute16
            ,attribute17
            ,attribute18
            ,attribute19
            ,attribute20
            ,attribute21
            ,attribute22
            ,attribute23
            ,attribute24
            ,attribute25
            ,attribute26
            ,attribute27
            ,attribute28
            ,attribute29
            ,attribute30
            ,trx_currency)
        VALUES(
            1.0
            ,p_txn_header_rec_type.transaction_header_id
            ,p_txn_header_rec_type.transaction_number
            ,p_txn_header_rec_type.ref_document_number
            ,p_txn_header_rec_type.vendor_id
            ,p_txn_header_rec_type.vendor_contact_id
            ,p_txn_header_rec_type.vendor_contact_name
            ,p_txn_header_rec_type.contact_email_address
            ,p_txn_header_rec_type.contact_phone
            ,p_txn_header_rec_type.vendor_site_id
            ,p_txn_header_rec_type.transaction_source
            ,TRUNC(p_txn_header_rec_type.effective_start_date)
            ,p_txn_header_rec_type.days_covered
            ,p_txn_header_rec_type.transaction_status
            ,p_txn_header_rec_type.org_id
            ,p_txn_header_rec_type.orig_sys_document_ref
            ,sysdate--creation_date
            ,null--last_refreshed_by
            ,NULL--last_refreshed_date
            ,NVL(l_user_id,0)
            ,SYSDATE
            ,NVL(l_user_id,0)
            ,NVL(l_user_id,0)
            ,p_txn_header_rec_type.REQUEST_ID
            ,p_txn_header_rec_type.PROGRAM_APPLICATION_ID
            ,p_txn_header_rec_type.PROGRAM_ID
            ,p_txn_header_rec_type.PROGRAM_UPDATE_DATE
            ,p_txn_header_rec_type.ATTRIBUTE_CATEGORY
            ,p_txn_header_rec_type.ATTRIBUTE1
            ,p_txn_header_rec_type.ATTRIBUTE2
            ,p_txn_header_rec_type.ATTRIBUTE3
            ,p_txn_header_rec_type.ATTRIBUTE4
            ,p_txn_header_rec_type.ATTRIBUTE5
            ,p_txn_header_rec_type.ATTRIBUTE6
            ,p_txn_header_rec_type.ATTRIBUTE7
            ,p_txn_header_rec_type.ATTRIBUTE8
            ,p_txn_header_rec_type.ATTRIBUTE9
            ,p_txn_header_rec_type.ATTRIBUTE10
            ,p_txn_header_rec_type.ATTRIBUTE11
            ,p_txn_header_rec_type.ATTRIBUTE12
            ,p_txn_header_rec_type.ATTRIBUTE13
            ,p_txn_header_rec_type.ATTRIBUTE14
            ,p_txn_header_rec_type.ATTRIBUTE15
            ,p_txn_header_rec_type.ATTRIBUTE16
            ,p_txn_header_rec_type.ATTRIBUTE17
            ,p_txn_header_rec_type.ATTRIBUTE18
            ,p_txn_header_rec_type.ATTRIBUTE19
            ,p_txn_header_rec_type.ATTRIBUTE20
            ,p_txn_header_rec_type.ATTRIBUTE21
            ,p_txn_header_rec_type.ATTRIBUTE22
            ,p_txn_header_rec_type.ATTRIBUTE23
            ,p_txn_header_rec_type.ATTRIBUTE24
            ,p_txn_header_rec_type.ATTRIBUTE25
            ,p_txn_header_rec_type.ATTRIBUTE26
            ,p_txn_header_rec_type.ATTRIBUTE27
            ,p_txn_header_rec_type.ATTRIBUTE28
            ,p_txn_header_rec_type.ATTRIBUTE29
            ,p_txn_header_rec_type.ATTRIBUTE30
            ,p_txn_header_rec_type.trx_currency);

        IF DPP_DEBUG_HIGH_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Create Header');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Create Header G_EXC_ERROR '||x_msg_data);
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Create Header G_EXC_UNEXPECTED_ERROR' ||x_msg_data||sqlerrm);
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Create Header OTHERS'||sqlerrm);
            x_return_status := Fnd_Api.g_ret_sts_unexp_erroR ;
            IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
            THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END Create_Header;
    PROCEDURE Validate_SupplierPartNum(
                    p_txn_header_rec_type IN OUT nocopy txn_header_rec
                    ,p_txn_lines_tbl_type IN OUT nocopy txn_lines_tbl
                    ,x_msg_count OUT nocopy NUMBER
                    ,x_msg_data OUT nocopy VARCHAR2
                    ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Validate_SupplierPartNum';
        l_api_version constant NUMBER := 1.0;
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status VARCHAR2(10);
        l_supplier_part_num_not_exists  BOOLEAN;
        l_exchange_rate NUMBER;
        l_error_message VARCHAR2(4000) :=NULL;
        l_msg_exceeded  VARCHAR2(10) := 'N';

    BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
      IF DPP_DEBUG_HIGH_ON THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Validate Supplier Part Number');
      END IF;
        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP
         --Get transaction line id from sequence
            BEGIN
                SELECT dpp_transaction_line_id_seq.nextval
                INTO p_txn_lines_tbl_type(i).transaction_line_id
                FROM dual;

            EXCEPTION
                WHEN no_data_found THEN
                    x_return_status := fnd_api.g_ret_sts_error;
                    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                    fnd_message.set_name('DPP',   'DPP_TXN_SEQ_NO_ERR');
                    fnd_message.set_token('SEQ_NUM', 'Transaction Line Id');
                    END IF;
                    x_msg_data := fnd_message.get();
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_SEQ_NO_ERR';
                    IF p_txn_header_rec_type.error_code IS NULL THEN
                        p_txn_header_rec_type.error_code := 'DPP_TXN_SEQ_NO_ERR';
                     ELSE
                       p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                     END IF;
                    l_error_message :=l_error_message|| x_msg_data;

            END;
            --Get line status from lookup
            BEGIN
                SELECT lookup_code
                 INTO p_txn_lines_tbl_type(i).line_status
                 FROM fnd_lookups
                WHERE lookup_code = 'ACTIVE'
                  AND lookup_type = 'DPP_TRANSACTION_STATUSES';
            EXCEPTION
                WHEN no_data_found THEN
                    x_return_status := fnd_api.g_ret_sts_error;
                    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                        fnd_message.set_name('DPP',   'DPP_TXN_STS_ERR');
                    END IF;
                    x_msg_data := fnd_message.get();
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                     p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_STS_ERR';
                     IF p_txn_header_rec_type.error_code IS NULL THEN
                        p_txn_header_rec_type.error_code := 'DPP_TXN_STS_ERR';
                     ELSE
                       p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                     END IF;
                    l_error_message :=l_error_message|| x_msg_data;
                  --RAISE Fnd_Api.G_EXC_ERROR;
            END;
      --BUG 6806974
       IF (p_txn_lines_tbl_type(i).supplier_part_num IS NULL AND p_txn_lines_tbl_type(i).item_number IS NULL
            AND p_txn_lines_tbl_type(i).inventory_item_id IS NULL) THEN
             IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('DPP',   'DPP_TXN_SUP_PART_NO_NULL');
              END IF;
              x_msg_data := fnd_message.get();
              l_error_message :=l_error_message|| x_msg_data;
              FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
              p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_SUP_PART_NO_NULL';

              RAISE Fnd_Api.g_exc_error;
        END IF;


/*If both the supplier part number and item number is not null then both the values
 and the combination should be valid*/
        IF p_txn_lines_tbl_type(i).item_number IS NOT NULL
            OR p_txn_lines_tbl_type(i).inventory_item_id IS NOT NULL THEN
          BEGIN
         IF p_txn_lines_tbl_type(i).item_number IS NOT NULL
          AND p_txn_lines_tbl_type(i).inventory_item_id IS NOT NULL THEN
	   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number Case I');
          SELECT msi.inventory_item_id,
                msi.concatenated_segments,
                msi.primary_uom_code
           INTO p_txn_lines_tbl_type(i).inventory_item_id
               ,p_txn_lines_tbl_type(i).item_number
               ,p_txn_lines_tbl_type(i).uom
          FROM mtl_system_items_kfv msi
         WHERE msi.purchasing_item_flag = 'Y'
           AND msi.shippable_item_flag = 'Y'
           AND msi.enabled_flag = 'Y'
           AND NVL(msi.consigned_flag,2) = 2 -- 2=unconsigned
           AND msi.mtl_transactions_enabled_flag = 'Y'
           AND msi.organization_id = p_txn_header_rec_type.inventory_organization_id
           AND msi.concatenated_segments = p_txn_lines_tbl_type(i).item_number
           AND msi.inventory_item_id = to_number(p_txn_lines_tbl_type(i).inventory_item_id)
           AND msi.primary_uom_code = nvl(p_txn_lines_tbl_type(i).uom,msi.primary_uom_code);
        ELSIF p_txn_lines_tbl_type(i).item_number IS NULL THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number Case II');
        SELECT msi.inventory_item_id,
                msi.concatenated_segments,
                msi.primary_uom_code
           INTO p_txn_lines_tbl_type(i).inventory_item_id
               ,p_txn_lines_tbl_type(i).item_number
               ,p_txn_lines_tbl_type(i).uom
          FROM mtl_system_items_kfv msi
         WHERE msi.purchasing_item_flag = 'Y'
           AND msi.shippable_item_flag = 'Y'
           AND msi.enabled_flag = 'Y'
           AND NVL(msi.consigned_flag,2) = 2 -- 2=unconsigned
           AND msi.mtl_transactions_enabled_flag = 'Y'
           AND msi.organization_id = p_txn_header_rec_type.inventory_organization_id
           AND msi.inventory_item_id = to_number(p_txn_lines_tbl_type(i).inventory_item_id)
           AND msi.primary_uom_code = nvl(p_txn_lines_tbl_type(i).uom,msi.primary_uom_code);
        ELSIF p_txn_lines_tbl_type(i).inventory_item_id IS NULL THEN
	    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number Case III');
        SELECT msi.inventory_item_id,
                msi.concatenated_segments,
                msi.primary_uom_code
           INTO p_txn_lines_tbl_type(i).inventory_item_id
               ,p_txn_lines_tbl_type(i).item_number
               ,p_txn_lines_tbl_type(i).uom
          FROM mtl_system_items_kfv msi
         WHERE msi.purchasing_item_flag = 'Y'
           AND msi.shippable_item_flag = 'Y'
           AND msi.enabled_flag = 'Y'
           AND NVL(msi.consigned_flag,2) = 2 -- 2=unconsigned
           AND msi.mtl_transactions_enabled_flag = 'Y'
           AND msi.organization_id = p_txn_header_rec_type.inventory_organization_id
           AND msi.concatenated_segments = p_txn_lines_tbl_type(i).item_number
           AND msi.primary_uom_code = nvl(p_txn_lines_tbl_type(i).uom,msi.primary_uom_code);
        END IF;
         EXCEPTION
            WHEN no_data_found THEN
                x_return_status := fnd_api.g_ret_sts_error;
                    fnd_message.set_name('DPP',   'DPP_TXN_SUP_PART_NO_ERR');
                    fnd_message.set_token('SUPPLIER_PART_NUM',   p_txn_lines_tbl_type(i).supplier_part_num);
                    fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
                    fnd_message.set_token('INVENTORY_ITEM_ID',   p_txn_lines_tbl_type(i).inventory_item_id);
                    fnd_message.set_token('UOM_CODE',   p_txn_lines_tbl_type(i).uom);
                    x_msg_data := fnd_message.get();
                     p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_SUP_PART_NO_ERR';
                     IF p_txn_header_rec_type.error_code IS NULL THEN
                        p_txn_header_rec_type.error_code := 'DPP_TXN_SUP_PART_NO_ERR';
                     ELSE
                       p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                     END IF;
                    IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                    l_error_message :=l_error_message|| x_msg_data;
                    ELSE
                    l_msg_exceeded := 'Y';
                    fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                    x_msg_data := fnd_message.get();
                    l_error_message := x_msg_data;
                    END IF;
        END;

        BEGIN --to get supplier part number for the item number or inventory item id
        IF p_txn_lines_tbl_type(i).supplier_part_num IS NOT NULL THEN
        BEGIN
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number Case IV');
        SELECT occ.external_code
          INTO p_txn_lines_tbl_type(i).supplier_part_num
          FROM ozf_supp_trd_prfls_all ostpa,
               ozf_supp_code_conversions_all occ
          WHERE occ.internal_code = p_txn_lines_tbl_type(i).inventory_item_id
          AND occ.code_conversion_type = 'OZF_PRODUCT_CODES'
          AND occ.org_id = to_number(p_txn_header_rec_type.org_id)
          AND occ.supp_trade_profile_id = ostpa.supp_trade_profile_id
          AND ostpa.supplier_id = to_number(p_txn_header_rec_type.vendor_id)
          AND ostpa.supplier_site_id = to_number(p_txn_header_rec_type.vendor_site_id)
          AND (trunc(sysdate) between occ.start_date_active and  occ.end_date_active OR occ.end_date_active is null)
          AND occ.external_code =p_txn_lines_tbl_type(i).supplier_part_num;
           EXCEPTION
            WHEN no_data_found THEN
                x_return_status := fnd_api.g_ret_sts_error;
                    fnd_message.set_name('DPP',   'DPP_TXN_SUP_PART_NO_ERR');
                    fnd_message.set_token('SUPPLIER_PART_NUM',   p_txn_lines_tbl_type(i).supplier_part_num);
                    fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
                    fnd_message.set_token('INVENTORY_ITEM_ID',   p_txn_lines_tbl_type(i).inventory_item_id);
                    fnd_message.set_token('UOM_CODE',   p_txn_lines_tbl_type(i).uom);
                    x_msg_data := fnd_message.get();
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_SUP_PART_NO_ERR';
                    IF p_txn_header_rec_type.error_code IS NULL THEN
                        p_txn_header_rec_type.error_code := 'DPP_TXN_SUP_PART_NO_ERR';
                     ELSE
                       p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                     END IF;

                    IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                      l_error_message :=l_error_message|| x_msg_data;
                    ELSE
                     l_msg_exceeded := 'Y';
                      fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                      x_msg_data := fnd_message.get();
                      l_error_message := x_msg_data;
                    END IF;

            WHEN TOO_MANY_ROWS THEN
              fnd_message.set_name('DPP',   'DPP_TXN_DUP_SUP_PART_NUM_ERR');
              fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
              fnd_message.set_token('INVENTORY_ITEM_ID',   p_txn_lines_tbl_type(i).inventory_item_id);
              x_msg_data := fnd_message.get();
              p_txn_header_rec_type.error_code := 'DPP_TXN_DUP_SUP_PART_NUM_ERR';
              FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
              IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                l_error_message :=l_error_message|| x_msg_data;
              ELSE
               l_msg_exceeded := 'Y';
               fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                x_msg_data := fnd_message.get();
                l_error_message := x_msg_data;
              END IF;

        END;
         ELSE
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number Case V');
          SELECT occ.external_code
          INTO p_txn_lines_tbl_type(i).supplier_part_num
          FROM ozf_supp_trd_prfls_all ostpa,
               ozf_supp_code_conversions_all occ
          WHERE occ.internal_code = p_txn_lines_tbl_type(i).inventory_item_id
          AND occ.code_conversion_type = 'OZF_PRODUCT_CODES'
          AND occ.org_id = to_number(p_txn_header_rec_type.org_id)
          AND occ.supp_trade_profile_id = ostpa.supp_trade_profile_id
          AND ostpa.supplier_id = to_number(p_txn_header_rec_type.vendor_id)
          AND ostpa.supplier_site_id = to_number(p_txn_header_rec_type.vendor_site_id)
          AND (trunc(sysdate) between occ.start_date_active and  occ.end_date_active OR occ.end_date_active is null);
        END IF;
         EXCEPTION WHEN NO_DATA_FOUND THEN
           IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Supplier Part Number does not exist for Item Number '|| p_txn_lines_tbl_type(i).item_number ||
                                                  '( Inventory Item ID '|| p_txn_lines_tbl_type(i).inventory_item_id );
           END IF;
        WHEN TOO_MANY_ROWS THEN
              fnd_message.set_name('DPP',   'DPP_TXN_DUP_SUP_PART_NUM_ERR');
              fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
              fnd_message.set_token('INVENTORY_ITEM_ID',   p_txn_lines_tbl_type(i).inventory_item_id);
              x_msg_data := fnd_message.get();
               p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_DUP_SUP_PART_NUM_ERR';
               IF p_txn_header_rec_type.error_code IS NULL THEN
                        p_txn_header_rec_type.error_code := 'DPP_TXN_DUP_SUP_PART_NUM_ERR';
               ELSE
                       p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
               END IF;
              FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
              IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                l_error_message :=l_error_message|| x_msg_data;
              ELSE
               l_msg_exceeded := 'Y';
                fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                x_msg_data := fnd_message.get();
                l_error_message := x_msg_data;
              END IF;

        END;
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number Case V line number  '|| i );
        ELSE
        BEGIN
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number Case VI');
        SELECT occ.external_code
              ,occ.internal_code
          INTO p_txn_lines_tbl_type(i).supplier_part_num
              ,p_txn_lines_tbl_type(i).inventory_item_id
          FROM ozf_supp_trd_prfls_all ostpa,
               ozf_supp_code_conversions_all occ
          WHERE occ.code_conversion_type = 'OZF_PRODUCT_CODES'
          AND occ.org_id = to_number(p_txn_header_rec_type.org_id)
          AND occ.supp_trade_profile_id = ostpa.supp_trade_profile_id
          AND ostpa.supplier_id = to_number(p_txn_header_rec_type.vendor_id)
          AND ostpa.supplier_site_id = to_number(p_txn_header_rec_type.vendor_site_id)
          AND (trunc(sysdate) between occ.start_date_active and  occ.end_date_active OR occ.end_date_active is null)
          AND occ.external_code =p_txn_lines_tbl_type(i).supplier_part_num;
         EXCEPTION WHEN NO_DATA_FOUND THEN
           x_return_status := fnd_api.g_ret_sts_error;
                    fnd_message.set_name('DPP',   'DPP_TXN_SUP_PART_NO_ERR');
                    fnd_message.set_token('SUPPLIER_PART_NUM',   p_txn_lines_tbl_type(i).supplier_part_num);
                    fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
                    fnd_message.set_token('INVENTORY_ITEM_ID',   p_txn_lines_tbl_type(i).inventory_item_id);
                    fnd_message.set_token('UOM_CODE',   p_txn_lines_tbl_type(i).uom);
                    x_msg_data := fnd_message.get();
              p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_SUP_PART_NO_ERR';
              IF p_txn_header_rec_type.error_code IS NULL THEN
                        p_txn_header_rec_type.error_code := 'DPP_TXN_SUP_PART_NO_ERR';
              ELSE
                       p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
              END IF;
              IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                l_error_message :=l_error_message|| x_msg_data;
              ELSE
               l_msg_exceeded := 'Y';
                fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                x_msg_data := fnd_message.get();

                l_error_message := x_msg_data;
              END IF;

        WHEN TOO_MANY_ROWS THEN
              fnd_message.set_name('DPP',   'DPP_TXN_DUP_SUP_PART_NUM_ERR');
              fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
              fnd_message.set_token('INVENTORY_ITEM_ID',   p_txn_lines_tbl_type(i).inventory_item_id);
              x_msg_data := fnd_message.get();
              FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
              p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_DUP_SUP_PART_NUM_ERR';
              IF p_txn_header_rec_type.error_code IS NULL THEN
                        p_txn_header_rec_type.error_code := 'DPP_TXN_DUP_SUP_PART_NUM_ERR';
              ELSE
                       p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
              END IF;
              IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                l_error_message :=l_error_message|| x_msg_data;
              ELSE
               l_msg_exceeded := 'Y';
                fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                x_msg_data := fnd_message.get();
                l_error_message := x_msg_data;
              END IF;



        END;
        END IF;
--only for inbound
    IF p_txn_header_rec_type.supplier_approved_by is NULL THEN
      --Get List Price in Transaction Currency
        BEGIN
        IF l_error_message IS NULL THEN
         IF p_txn_lines_tbl_type(i).prior_price IS NULL THEN
                --get list price for the selected inventory organization id
          SELECT msi.LIST_PRICE_PER_UNIT list_price
            INTO p_txn_lines_tbl_type(i).list_price
            FROM mtl_system_items msi
           WHERE msi.inventory_item_id = to_number(p_txn_lines_tbl_type(i).inventory_item_id)  and
                 msi.organization_id = p_txn_header_rec_type.inventory_organization_id;

               p_txn_lines_tbl_type(i).prior_price := p_txn_lines_tbl_type(i).list_price;




          IF p_txn_header_rec_type.functional_currency <> p_txn_header_rec_type.trx_currency THEN
           --call procedure to get prior price in transaction currency
             DPP_UTILITY_PVT.convert_currency(
                     p_from_currency   => p_txn_header_rec_type.functional_currency
                    ,p_to_currency     => p_txn_header_rec_type.trx_currency
                    ,p_conv_type       => FND_API.G_MISS_CHAR
                    ,p_conv_rate       => FND_API.G_MISS_NUM
                    ,p_conv_date       => SYSDATE
                    ,p_from_amount     => p_txn_lines_tbl_type(i).list_price
                    ,x_return_status   => x_return_status
                    ,x_to_amount       => p_txn_lines_tbl_type(i).prior_price
                    ,x_rate            => l_exchange_rate);

             IF x_return_status <>fnd_api.g_ret_sts_success THEN
                    fnd_message.set_name('DPP',   'DPP_TXN_CONV_PRICE_ER');
                    fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
                    x_msg_data := fnd_message.get();
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_CONV_PRICE_ER';
                    IF p_txn_header_rec_type.error_code IS NULL THEN
                              p_txn_header_rec_type.error_code := 'DPP_TXN_CONV_PRICE_ER';
                    ELSE
                             p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                    END IF;
                    x_return_status := fnd_api.g_ret_sts_error;
                    l_error_message :=l_error_message|| x_msg_data;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
            END IF;
        END IF;
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Prior Price:'||p_txn_lines_tbl_type(i).prior_price);
            IF p_txn_lines_tbl_type(i).prior_price IS NULL THEN
                  fnd_message.set_name('DPP',   'DPP_TXN_SUP_PART_LIST_PRICE_ER');
                  fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
                  x_msg_data := fnd_message.get();
                  p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_SUP_PART_LIST_PRICE_ER';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_SUP_PART_LIST_PRICE_ER';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                  x_return_status := fnd_api.g_ret_sts_error;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                  IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                    l_error_message :=l_error_message|| x_msg_data;
                  ELSE
                   l_msg_exceeded := 'Y';
                    fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                    x_msg_data := fnd_message.get();
                    l_error_message := x_msg_data;
                  END IF;
            END IF;
            END IF;
        END IF;
        EXCEPTION
            WHEN no_data_found THEN
                    fnd_message.set_name('DPP',   'DPP_TXN_SUP_PART_LIST_PRICE_ER');
                    fnd_message.set_token('ITEM_NUMBER',   p_txn_lines_tbl_type(i).item_number);
                  x_msg_data := fnd_message.get();
                  p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_SUP_PART_LIST_PRICE_ER';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_SUP_PART_LIST_PRICE_ER';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                  x_return_status := fnd_api.g_ret_sts_error;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                  IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                    l_error_message :=l_error_message|| x_msg_data;
                  ELSE
                   l_msg_exceeded := 'Y';
                    fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                    x_msg_data := fnd_message.get();
                    l_error_message := x_msg_data;
                  END IF;
         END;

           --Validation for Prior Price --ANBBALAS
            IF p_txn_lines_tbl_type(i).prior_price <= 0 THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'    Prior Price is either zero or negative');
              fnd_message.set_name('DPP',   'DPP_PRIOR_PRICE_ERR');
              x_msg_data := fnd_message.get();
              p_txn_lines_tbl_type(i).error_code := 'DPP_PRIOR_PRICE_ERR';
              IF p_txn_header_rec_type.error_code IS NULL THEN
                p_txn_header_rec_type.error_code := 'DPP_PRIOR_PRICE_ERR';
              ELSE
                p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
              END IF;
              IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                l_error_message :=l_error_message|| x_msg_data;
              ELSE
                l_msg_exceeded := 'Y';
                fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                x_msg_data := fnd_message.get();
                l_error_message := x_msg_data;
              END IF;
            END IF;

           --Validation for Change Value
            IF p_txn_lines_tbl_type(i).change_value IS NULL THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'    Change Value is null');
             fnd_message.set_name('DPP',   'DPP_CHANGE_VALUE_NULL');
             x_msg_data := fnd_message.get();
             p_txn_lines_tbl_type(i).error_code := 'DPP_CHANGE_VALUE_NULL';
            IF p_txn_header_rec_type.error_code IS NULL THEN
                      p_txn_header_rec_type.error_code := 'DPP_CHANGE_VALUE_NULL';
            ELSE
                     p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
            END IF;
             IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                    l_error_message :=l_error_message|| x_msg_data;
             ELSE
                   l_msg_exceeded := 'Y';
                    fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                    x_msg_data := fnd_message.get();
                    l_error_message := x_msg_data;
             END IF;
            END IF;

             IF   p_txn_lines_tbl_type(i).change_type IS NULL  THEN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'    Change type is null');
                  fnd_message.set_name('DPP',   'DPP_CHANGE_TYPE_NULL');
                  x_msg_data := fnd_message.get();
                  p_txn_lines_tbl_type(i).error_code := 'DPP_CHANGE_TYPE_NULL';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_CHANGE_TYPE_NULL';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                  IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                    l_error_message :=l_error_message|| x_msg_data;
                  ELSE
                   l_msg_exceeded := 'Y';
                    fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                    x_msg_data := fnd_message.get();
                    l_error_message := x_msg_data;
                  END IF;
              END IF;



           --Calculate Supplier New Price and Price change columns

            IF p_txn_lines_tbl_type(i).change_type = 'NEW_PRICE' THEN
                  IF p_txn_lines_tbl_type(i).change_value <= 0 THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'    Negative Price Change Value:' || p_txn_lines_tbl_type(i).change_value ||'. Please enter a valid Change value.');
                    fnd_message.set_name('DPP',   'DPP_TXN_CHANGE_VALUE_ERR');
                    fnd_message.set_token('CHANGE_VALUE', p_txn_lines_tbl_type(i).change_value );
                    x_msg_data := fnd_message.get();
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                    IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                      l_error_message :=l_error_message|| x_msg_data;
                    ELSE
                      l_msg_exceeded := 'Y';
                      fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                      x_msg_data := fnd_message.get();
                      l_error_message := x_msg_data;
                    END IF;
                 ELSE
                  p_txn_lines_tbl_type(i).supplier_new_price := p_txn_lines_tbl_type(i).change_value;
                 END IF;
            ELSIF p_txn_lines_tbl_type(i).change_type = 'PERCENT_DECREASE' THEN
                   IF p_txn_lines_tbl_type(i).change_value <= 0 OR p_txn_lines_tbl_type(i).change_value >= 100 THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'    Invalid Price Change Value:' || p_txn_lines_tbl_type(i).change_value || 'for the change type Percent Decrease. Please enter a valid Change value.');
                    fnd_message.set_name('DPP',   'DPP_TXN_CHANGE_VALUE_ERR');
                    fnd_message.set_token('CHANGE_VALUE', p_txn_lines_tbl_type(i).change_value );
                    x_msg_data := fnd_message.get();
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                    IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                      l_error_message :=l_error_message|| x_msg_data;
                    ELSE
                      l_msg_exceeded := 'Y';
                      fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                      x_msg_data := fnd_message.get();
                      l_error_message := x_msg_data;
                    END IF;
                 ELSE
                  p_txn_lines_tbl_type(i).supplier_new_price := (p_txn_lines_tbl_type(i).prior_price-(p_txn_lines_tbl_type(i).prior_price*( p_txn_lines_tbl_type(i).change_value) / 100));
                 END IF;

            ELSIF p_txn_lines_tbl_type(i).change_type = 'PERCENT_INCREASE' THEN
                   IF p_txn_lines_tbl_type(i).change_value <= 0 THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'    Invalid Price Change Value:' || p_txn_lines_tbl_type(i).change_value || 'for the change type Percent Increase. Please enter a valid Change value.');
                    fnd_message.set_name('DPP',   'DPP_TXN_CHANGE_VALUE_ERR');
                    fnd_message.set_token('CHANGE_VALUE', p_txn_lines_tbl_type(i).change_value );
                    x_msg_data := fnd_message.get();
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                    IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                      l_error_message :=l_error_message|| x_msg_data;
                    ELSE
                      l_msg_exceeded := 'Y';
                      fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                      x_msg_data := fnd_message.get();
                      l_error_message := x_msg_data;
                    END IF;
                 ELSE
                  p_txn_lines_tbl_type(i).supplier_new_price := (p_txn_lines_tbl_type(i).prior_price+(p_txn_lines_tbl_type(i).prior_price*( p_txn_lines_tbl_type(i).change_value) / 100));
                 END IF;
            ELSIF p_txn_lines_tbl_type(i).change_type = 'AMOUNT_INCREASE' THEN
                  IF p_txn_lines_tbl_type(i).change_value <= 0 THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'    Invalid Price Change Value:' || p_txn_lines_tbl_type(i).change_value || 'for the change type Amount Increase. Please enter a valid Change value.');
                    fnd_message.set_name('DPP',   'DPP_TXN_CHANGE_VALUE_ERR');
                    fnd_message.set_token('CHANGE_VALUE', p_txn_lines_tbl_type(i).change_value );
                    x_msg_data := fnd_message.get();
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                    IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                      l_error_message :=l_error_message|| x_msg_data;
                    ELSE
                      l_msg_exceeded := 'Y';
                      fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                      x_msg_data := fnd_message.get();
                      l_error_message := x_msg_data;
                    END IF;
                 ELSE
                  p_txn_lines_tbl_type(i).supplier_new_price := p_txn_lines_tbl_type(i).prior_price + p_txn_lines_tbl_type(i).change_value;
                 END IF;
            ELSIF p_txn_lines_tbl_type(i).change_type = 'AMOUNT_DECREASE' THEN
                   IF (p_txn_lines_tbl_type(i).change_value <= 0 OR
                                (p_txn_lines_tbl_type(i).prior_price > 0 AND p_txn_lines_tbl_type(i).change_value >= p_txn_lines_tbl_type(i).prior_price) ) THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'    Invalid Price Change Value:' || p_txn_lines_tbl_type(i).change_value || 'for the change type Amount Decrease. Please enter a valid Change value.');
                    fnd_message.set_name('DPP',   'DPP_TXN_CHANGE_VALUE_ERR');
                    fnd_message.set_token('CHANGE_VALUE', p_txn_lines_tbl_type(i).change_value );
                    x_msg_data := fnd_message.get();
                    p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_CHANGE_VALUE_ERR';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                    IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                      l_error_message :=l_error_message|| x_msg_data;
                    ELSE
                      l_msg_exceeded := 'Y';
                      fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                      x_msg_data := fnd_message.get();
                      l_error_message := x_msg_data;
                    END IF;
                 ELSE
                  p_txn_lines_tbl_type(i).supplier_new_price := p_txn_lines_tbl_type(i).prior_price - p_txn_lines_tbl_type(i).change_value;
                 END IF;

            ELSE
            FND_FILE.PUT_LINE(FND_FILE.LOG,'    Invalid Price Change type:' || p_txn_lines_tbl_type(i).change_type ||'. Please enter a valid Change type.');
            fnd_message.set_name('DPP',   'DPP_TXN_CHANGE_TYPE_ERR');
            fnd_message.set_token('CHANGE_TYPE', p_txn_lines_tbl_type(i).change_type );
            x_msg_data := fnd_message.get();
            p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_CHANGE_TYPE_ERR';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_TXN_CHANGE_TYPE_ERR';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                  IF (l_error_message is null or length(l_error_message) < 2000) and l_msg_exceeded = 'N' THEN
                    l_error_message :=l_error_message|| x_msg_data;
                  ELSE
                   l_msg_exceeded := 'Y';
                    fnd_message.set_name('DPP',   'DPP_ERROR_MSG_STD');
                    x_msg_data := fnd_message.get();
                    l_error_message := x_msg_data;
                  END IF;
            --RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            --Price change field
            p_txn_lines_tbl_type(i).price_change := p_txn_lines_tbl_type(i).prior_price - p_txn_lines_tbl_type(i).supplier_new_price;
--end if;
END IF;

            IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'    Price Change: '||p_txn_lines_tbl_type(i).price_change);
            END IF;
         END LOOP;
           IF l_error_message IS NOT NULL THEN
              x_msg_data := substr(l_error_message,1,2000);
               RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

      IF DPP_DEBUG_HIGH_ON THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Validate Supplier Part Number');
      END IF;
      EXCEPTION
         WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier part number Error: ' || sqlerrm);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                    fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                    fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT VALIDATE SUPPLIER PART NUMBER');
                    fnd_message.set_token('ERRNO',   SQLCODE);
                    fnd_message.set_token('REASON',   sqlerrm);
                END IF;
              x_msg_data := fnd_message.get();
              FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
      END Validate_SupplierPartNum;


    PROCEDURE Create_lines(
            p_txn_header_rec_type IN OUT nocopy txn_header_rec
            ,p_txn_lines_tbl_type IN OUT nocopy txn_lines_tbl
            ,x_msg_count OUT nocopy NUMBER
            ,x_msg_data OUT nocopy VARCHAR2
            ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Create_lines';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_transaction_line_id NUMBER;
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');
        l_error_message VARCHAR2(4000);
        l_rounding  NUMBER;
    BEGIN
    -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Create Lines');
        END IF;


        SELECT fnd_profile.VALUE('DPP_NEW_PRICE_DECIMAL_PRECISION')
        INTO l_rounding
        FROM dual;

        IF l_rounding IS NULL THEN
        l_rounding := 4;
        END IF;


        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP
          IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'       Line');
               FND_FILE.PUT_LINE(FND_FILE.LOG,'         Transaction Header Id'||p_txn_lines_tbl_type(i).transaction_header_id);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'         Supplier Part Num'||p_txn_lines_tbl_type(i).supplier_part_num);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'         Inventory Item ID'||p_txn_lines_tbl_type(i).inventory_item_id);
          END IF;
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Prior Price Create Lines:'||p_txn_lines_tbl_type(i).prior_price);
            -- Insert lines into dpp_transaction_lines_all table
            INSERT INTO dpp_transaction_lines_all(
                                object_version_number
                              , transaction_header_id
                          , transaction_line_id
                          , supplier_part_num
                          , line_number
                          , prior_price
                          , change_type
                          , change_value
                          , price_change
                          , covered_inventory
                          , approved_inventory
                          , uom
                          , org_id
                          , orig_sys_document_line_ref
                          , creation_date
                          , created_by
                          , last_update_date
                          , last_updated_by
                          , last_update_login
                          , request_id
                          , program_application_id
                          , program_id
                          , program_update_date
                          , attribute_category
                          , attribute1
                          , attribute2
                          , attribute3
                          , attribute4
                          , attribute5
                          , attribute6
                          , attribute7
                          , attribute8
                          , attribute9
                          , attribute10
                          , attribute11
                          , attribute12
                          , attribute13
                          , attribute14
                          , attribute15
                          , attribute16
                          , attribute17
                          , attribute18
                          , attribute19
                          , attribute20
                          , attribute21
                          , attribute22
                          , attribute23
                          , attribute24
                          , attribute25
                          , attribute26
                          , attribute27
                          , attribute28
                          , attribute29
                          , attribute30
                          , inventory_item_id
                          , supplier_new_price
                          , last_calculated_by
                          , last_calculated_date
                          , claim_amount
                          , supp_dist_claim_id
                          , update_purchasing_docs
                          , notify_purchasing_docs
                          , update_inventory_costing
                          , update_item_list_price
                          , supp_dist_claim_status
                          , onhand_inventory
                          , manually_adjusted
                          , notify_inbound_pricelist
                          , notify_outbound_pricelist
                              ,notify_promotions_pricelist)
                    VALUES(
                        1.0
                        ,   p_txn_lines_tbl_type(i).transaction_header_id
                    ,   p_txn_lines_tbl_type(i).transaction_line_id
                    ,   p_txn_lines_tbl_type(i).supplier_part_num
                    ,   p_txn_lines_tbl_type(i).line_number
                    ,   ROUND(nvl(p_txn_lines_tbl_type(i).prior_price,0),l_rounding)
                    ,   p_txn_lines_tbl_type(i).change_type
                    ,   ROUND(p_txn_lines_tbl_type(i).change_value,l_rounding)
                    ,   ROUND(p_txn_lines_tbl_type(i).price_change,l_rounding)
                    ,   p_txn_lines_tbl_type(i).covered_inventory
                    ,   p_txn_lines_tbl_type(i).approved_inventory
                    ,   p_txn_lines_tbl_type(i).uom
                    ,   p_txn_lines_tbl_type(i).org_id
                    ,   p_txn_lines_tbl_type(i).orig_sys_document_line_ref
                    ,   sysdate --
                    ,   NVL(l_user_id,0) --created_by
                    ,   sysdate --last_update_date
                    ,   NVL(l_user_id,0)--p_txn_lines_tbl_type(i).last_updated_by
                    ,   NVL(l_user_id,0)--p_txn_lines_tbl_type(i).last_update_login
                    ,   p_txn_lines_tbl_type(i).request_id --request_id
                    ,   p_txn_lines_tbl_type(i).program_application_id --program_application_id
                    ,   p_txn_lines_tbl_type(i).program_id --program_id
                    ,   p_txn_lines_tbl_type(i).program_update_date --program_update_date
                    ,   p_txn_lines_tbl_type(i).attribute_category --attribute_category
                    ,   p_txn_lines_tbl_type(i).attribute1 --attribute1
                    ,   p_txn_lines_tbl_type(i).attribute2 --attribute2
                    ,   p_txn_lines_tbl_type(i).attribute3 --attribute3
                    ,   p_txn_lines_tbl_type(i).attribute4 --attribute4
                    ,   p_txn_lines_tbl_type(i).attribute5 --attribute5
                    ,   p_txn_lines_tbl_type(i).attribute6 --attribute6
                    ,   p_txn_lines_tbl_type(i).attribute7 --attribute7
                    ,   p_txn_lines_tbl_type(i).attribute8 --attribute8
                    ,   p_txn_lines_tbl_type(i).attribute9 --attribute9
                    ,   p_txn_lines_tbl_type(i).attribute10 --attribute10
                    ,   p_txn_lines_tbl_type(i).attribute11 --attribute11
                    ,   p_txn_lines_tbl_type(i).attribute12 --attribute12
                    ,   p_txn_lines_tbl_type(i).attribute13 --attribute13
                    ,   p_txn_lines_tbl_type(i).attribute14 --attribute14
                    ,   p_txn_lines_tbl_type(i).attribute15 --attribute15
                    ,   p_txn_lines_tbl_type(i).attribute16 --attribute16
                    ,   p_txn_lines_tbl_type(i).attribute17 --attribute17
                    ,   p_txn_lines_tbl_type(i).attribute18 --attribute18
                    ,   p_txn_lines_tbl_type(i).attribute19 --attribute19
                    ,   p_txn_lines_tbl_type(i).attribute20 --attribute20
                    ,   p_txn_lines_tbl_type(i).attribute21 --attribute21
                    ,   p_txn_lines_tbl_type(i).attribute22 --attribute22
                    ,   p_txn_lines_tbl_type(i).attribute23 --attribute23
                    ,   p_txn_lines_tbl_type(i).attribute24 --attribute24
                    ,   p_txn_lines_tbl_type(i).attribute25 --attribute25
                    ,   p_txn_lines_tbl_type(i).attribute26 --attribute26
                    ,   p_txn_lines_tbl_type(i).attribute27 --attribute27
                    ,   p_txn_lines_tbl_type(i).attribute28 --attribute28
                    ,   p_txn_lines_tbl_type(i).attribute29 --attribute29
                    ,   p_txn_lines_tbl_type(i).attribute30 --attribute30
                    ,   p_txn_lines_tbl_type(i).inventory_item_id
                    ,   p_txn_lines_tbl_type(i).supplier_new_price
                    ,   null --p_txn_lines_tbl_type(i).last_calculated_by
                    ,   null --p_txn_lines_tbl_type(i).last_calculated_date
                    ,   null --p_txn_lines_tbl_type(i).claim_amount
                    ,   null --p_txn_lines_tbl_type(i).supp_dist_claim_id
                    ,   'N' --p_txn_lines_tbl_type(i).update_purchasing_docs
                    ,   'N' --p_txn_lines_tbl_type(i).notify_purchasing_docs
                    ,   'N' --p_txn_lines_tbl_type(i).update_inventory_costing
                    ,   'N' --p_txn_lines_tbl_type(i).update_item_list_price
                    ,   'N' --p_txn_lines_tbl_type(i).supp_dist_claim_status
                    ,    null--p_txn_lines_tbl_type(i).onhand_inventory
                    ,   'N'--p_txn_lines_tbl_type(i).notify_purchasing_docs
                    ,   'N' --p_txn_lines_tbl_type(i).notify_inbound_pricelist
                    ,   'N'--p_txn_lines_tbl_type(i).notify_outbound_pricelist
                    ,   'N'--p_txn_lines_tbl_type(i).notify_promotions_pricelist
                        );
        END LOOP; --FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
          IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Create Lines');
          END IF;
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'End Create Lines'|| sqlerrm);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Exception Create Lines'||sqlerrm);
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   l_full_name);
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END Create_lines;


    PROCEDURE Update_CoveredInv(
                        p_txn_header_rec_type IN OUT nocopy txn_header_rec
                        ,p_txn_lines_tbl_type IN OUT  nocopy txn_lines_tbl
                        ,x_msg_count OUT nocopy NUMBER
                        ,x_msg_data OUT nocopy VARCHAR2
                        ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Update_CoveredInv';
        l_api_version constant NUMBER := 1.0;
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_init_msg_list VARCHAR2(30) := FND_API.G_TRUE;
        l_commit      VARCHAR2(30) := FND_API.G_FALSE;
        l_validation_level  NUMBER       := FND_API.G_VALID_LEVEL_FULL;
        --Declaration for Covered Inventory Calculation
        l_header_rec_type   dpp_coveredinventory_pvt.dpp_inv_hdr_rec_type;
        l_line_tbl_type     dpp_coveredinventory_pvt.dpp_inv_cov_tbl_type;
        l_inv_cov_wh_tbl_type dpp_coveredinventory_pvt.dpp_inv_cov_wh_tbl_type;
        l_user_id  NUMBER :=FND_PROFILE.VALUE('USER_ID');

        l_price_change_flag     VARCHAR2(20);

    BEGIN
        SAVEPOINT DPP_Update_CoveredInv;

        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update Covered Inventory');
        END IF;
        --Form Header rec to call covered inventory procedure
        l_header_rec_type.transaction_header_id :=p_txn_header_rec_type.transaction_header_id;
        l_header_rec_type.org_id := p_txn_header_rec_type.org_id;
        --BUG 6806974
        IF p_txn_header_rec_type.days_covered IS NULL THEN
          l_header_rec_type.effective_start_date :=  TO_DATE('01/01/1900','DD/MM/YYYY');
        ELSE
          l_header_rec_type.effective_start_date := p_txn_header_rec_type.effective_start_date - p_txn_header_rec_type.days_covered ;
        END IF;
        l_header_rec_type.effective_end_date :=(p_txn_header_rec_type.effective_start_date);
        l_header_rec_type.last_updated_by :=p_txn_header_rec_type.last_updated_by;
        IF DPP_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'        Update_CoveredInv Rec type Transaction Header Id: '||l_header_rec_type.transaction_header_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG,'        Update_CoveredInv Rec type Org_ID'||l_header_rec_type.org_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG,'        Update_CoveredInv Rec type Effective Start Date'|| l_header_rec_type.effective_start_date);
              FND_FILE.PUT_LINE(FND_FILE.LOG,'        Update_CoveredInv Rec type Effective End Date'||l_header_rec_type.effective_end_date);
        END IF;
             --Form Line table to to get covered Inventory Details DPP_UTILITY_PVT.Get_CoveredInventory
        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP

            l_line_tbl_type(i).transaction_line_id := p_txn_lines_tbl_type(i).transaction_line_id;
            l_line_tbl_type(i).inventory_item_id := to_number(p_txn_lines_tbl_type(i).inventory_item_id);
            l_line_tbl_type(i).uom_code := p_txn_lines_tbl_type(i).uom;
            l_line_tbl_type(i).wh_line_tbl := l_inv_cov_wh_tbl_type;

            IF DPP_DEBUG_HIGH_ON THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG,'        Update_CoveredInv TBL type Transaction Line Id'||l_line_tbl_type(i).transaction_line_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG,'        Update_CoveredInv TBL type Inventory Item ID'||l_line_tbl_type(i).inventory_item_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG,'        Update_CoveredInv TBL type UOM Code'||l_line_tbl_type(i).uom_code);
            END IF;
        END LOOP; -- FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        --Update Covered Inventory Value
        DPP_COVEREDINVENTORY_PVT.Select_CoveredInventory(
                      p_api_version         =>    l_api_version
                     ,p_init_msg_list       =>    l_init_msg_list
                     ,p_commit              =>    l_commit
                     ,p_validation_level    =>    l_validation_level
                     ,x_return_status       =>    x_return_status
                     ,x_msg_count           =>    x_msg_count
                     ,x_msg_data            =>    x_msg_data
                     ,p_inv_hdr_rec         =>    l_header_rec_type
                     ,p_covered_inv_tbl     =>    l_line_tbl_type
                     );

		    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Status '||x_return_status|| ' Message '||x_msg_data);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
        --Call Populate Covered Inventory
        dpp_coveredinventory_pvt.Update_CoveredInventory(
                      p_api_version         =>    l_api_version
                     ,p_init_msg_list           =>    l_init_msg_list
                     ,p_commit                  =>    l_commit
                     ,p_validation_level    =>    l_validation_level
                     ,x_return_status           =>    x_return_status
                     ,x_msg_count           =>    x_msg_count
                     ,x_msg_data            =>    x_msg_data
                     ,p_inv_hdr_rec         =>    l_header_rec_type
                     ,p_covered_inv_tbl         =>    l_line_tbl_type
                     );

		    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Status '||x_return_status|| ' Message '||x_msg_data);

        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update Covered Inventory');
        END IF;
        FOR i in l_line_tbl_type.FIRST..l_line_tbl_type.LAST
        LOOP
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'l_line_tbl_type(i).transaction_line_id:'||l_line_tbl_type(i).transaction_line_id);
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'l_line_tbl_type(i).inventory_item_id:'||l_line_tbl_type(i).inventory_item_id);
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'l_line_tbl_type(i).onhand_quantity:'||l_line_tbl_type(i).onhand_quantity);
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'l_line_tbl_type(i).covered_quantity:'||l_line_tbl_type(i).covered_quantity);
           IF DPP_DEBUG_HIGH_ON THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'After get covered Inventory');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'l_line_tbl_type(i).transaction_line_id:'||l_line_tbl_type(i).transaction_line_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'l_line_tbl_type(i).inventory_item_id:'||l_line_tbl_type(i).inventory_item_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'l_line_tbl_type(i).uom_code:'||l_line_tbl_type(i).uom_code);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'l_line_tbl_type(i).onhand_quantity:'||l_line_tbl_type(i).onhand_quantity);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'l_line_tbl_type(i).covered_quantity:'||l_line_tbl_type(i).covered_quantity);
           END IF;
             --BUG 6806974
           UPDATE dpp_transaction_lines_all dtla
              SET dtla.approved_inventory = dtla.covered_inventory,
                  dtla.object_version_number =  dtla.object_version_number +1,
                  dtla.last_updated_by   = nvl(l_user_id,0),
                  dtla.last_update_login = nvl(l_user_id,0),
                  dtla.last_update_date  = sysdate
            WHERE dtla.transaction_header_id = p_txn_header_rec_type.transaction_header_id
              AND dtla.transaction_line_id = l_line_tbl_type(i).transaction_line_id;

          --Added code for DPP Price Increase Enhancement
          --Get the supplier trade profile value to include price increase value for claim or not
          BEGIN
           SELECT nvl(create_claim_price_increase,'N')
             INTO l_price_change_flag
             FROM ozf_supp_trd_prfls_all ostp,
                    dpp_transaction_headers_all dtha
            WHERE ostp.supplier_id = to_number(dtha.vendor_id)
                AND ostp.supplier_site_id = to_number(dtha.vendor_site_id)
                AND ostp.org_id = to_number(dtha.org_id)
                AND dtha.transaction_header_id = p_txn_header_rec_type.transaction_header_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                     fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
                     fnd_message.set_token('ERRNO', sqlcode);
                     fnd_message.set_token('REASON', 'SUPPLIER TRADE PROFILE IS NOT FOUND'); --To be modified
                     FND_MSG_PUB.add;
                 IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                   FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                 END IF;
                 RAISE FND_API.g_exc_error;
              WHEN OTHERS THEN
                  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                     fnd_message.set_token('ROUTINE', 'DPP_BUSINESSEVENTS_PVT');
                     fnd_message.set_token('ERRNO', sqlcode);
                     fnd_message.set_token('REASON', sqlerrm);
                  IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                    FND_MESSAGE.set_name('DPP', 'DPP_BUSEVT_INVALID_EXE_DET_ID'); --To be modified
                    fnd_message.set_token('SEQ_NAME', 'DPP_EXECUTION_DETAIL_ID_SEQ'); --To be modified
                    FND_MSG_PUB.add;
                    FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;

            IF (l_price_change_flag = 'N') THEN   -- Only Price Decrease
                UPDATE dpp_transaction_lines_all dtla
                  SET dtla.claim_amount = dtla.approved_inventory * price_change,
                      dtla.object_version_number =  dtla.object_version_number +1,
                      dtla.last_updated_by   = nvl(l_user_id,0),
                      dtla.last_update_login = nvl(l_user_id,0),
                      dtla.last_update_date  = sysdate
                WHERE dtla.transaction_header_id = p_txn_header_rec_type.transaction_header_id
                  AND dtla.transaction_line_id = l_line_tbl_type(i).transaction_line_id
                  AND dtla.price_change > 0;
            ELSE                                  -- Both Price Increase and Price Decrease
                UPDATE dpp_transaction_lines_all dtla
                  SET dtla.claim_amount = dtla.approved_inventory * price_change,
                      dtla.object_version_number =  dtla.object_version_number +1,
                      dtla.last_updated_by   = nvl(l_user_id,0),
                      dtla.last_update_login = nvl(l_user_id,0),
                      dtla.last_update_date  = sysdate
                WHERE dtla.transaction_header_id = p_txn_header_rec_type.transaction_header_id
                  AND dtla.transaction_line_id = l_line_tbl_type(i).transaction_line_id
                  AND dtla.price_change <> 0;
            END IF;

        END LOOP;
        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
            p_txn_header_rec_type.error_code := 'DPP_UPDATE_COVEREDINV';
            ROLLBACK TO DPP_Update_CoveredInv;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            p_txn_header_rec_type.error_code := 'DPP_UPDATE_COVEREDINV';
            ROLLBACK TO DPP_Update_CoveredInv;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   l_full_name);
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
            ROLLBACK TO DPP_Update_CoveredInv;
    END Update_CoveredInv;


    PROCEDURE Update_Approval(
                    p_txn_header_rec_type IN OUT nocopy txn_header_rec
                    ,p_txn_lines_tbl_type IN OUT  nocopy txn_lines_tbl
                    ,x_msg_count OUT nocopy NUMBER
                    ,x_msg_data OUT nocopy VARCHAR2
                    ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Update_Approval';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_approved_by VARCHAR2(55);
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');
        l_claim_id   VARCHAR2(240);
        l_error_message VARCHAR2(4000) := NULL;
    BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update Approval');
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Values Transaction header id '
                                      ||p_txn_header_rec_type.transaction_header_id
                                      ||'Claim Number'||p_txn_header_rec_type.supp_dist_claim_number);
        END IF;
        --Check whether the claim lines belong to the transaction
        IF (p_txn_header_rec_type.supp_dist_claim_number IS NULL AND
            p_txn_header_rec_type.supp_dist_claim_id IS NULL ) THEN
            x_return_status := fnd_api.g_ret_sts_error;
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                 fnd_message.set_name('DPP',   'DPP_CLAIM_NUMBER_NULL');
                 x_msg_data := fnd_message.get();
                 p_txn_header_rec_type.error_code := 'DPP_CLAIM_NUMBER_NULL';
                 l_error_message := l_error_message || x_msg_data;
                 IF DPP_DEBUG_HIGH_ON THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                 END IF;
             END IF;
             x_return_status := fnd_api.g_ret_sts_error;
        --RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP
         BEGIN
         --BUG 6806974
         IF p_txn_lines_tbl_type(i).inventory_item_id IS NOT NULL THEN
        SELECT dtla.supp_dist_claim_id
            INTO p_txn_lines_tbl_type(i).supp_dist_claim_id
            FROM dpp_transaction_lines_all dtla,
                 ozf_claims_all oca
            WHERE dtla.transaction_header_id = p_txn_header_rec_type.transaction_header_id
              AND to_number(dtla.supp_dist_claim_id) = oca.claim_id
              AND (oca.claim_number = nvl(p_txn_header_rec_type.supp_dist_claim_number,oca.claim_number)
               AND oca.claim_id = nvl(to_number(p_txn_header_rec_type.supp_dist_claim_id),oca.claim_id))
              AND dtla.inventory_item_id = p_txn_lines_tbl_type(i).inventory_item_id
              AND dtla.supplier_approved_by IS NULL;
          END IF;
        EXCEPTION
          WHEN no_data_found THEN
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_message.set_name('DPP',   'DPP_APPROVED_CLAIM_LINES_ERR');
                fnd_message.set_token('CLAIM_NUMBER',  p_txn_header_rec_type.supp_dist_claim_number);
                fnd_message.set_token('CLAIM_ID',  p_txn_header_rec_type.supp_dist_claim_id);
                x_msg_data := fnd_message.get();
                p_txn_lines_tbl_type(i).error_code := 'DPP_APPROVED_CLAIM_LINES_ERR';
                  IF p_txn_header_rec_type.error_code IS NULL THEN
                            p_txn_header_rec_type.error_code := 'DPP_APPROVED_CLAIM_LINES_ERR';
                  ELSE
                           p_txn_header_rec_type.error_code := 'MULTIPLE_ERRORS';
                  END IF;
                l_error_message := l_error_message ||  x_msg_data;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
                RAISE Fnd_Api.G_EXC_ERROR;

        END;

        UPDATE dpp_transaction_headers_all dtha
        SET dtha.last_updated_by = nvl(l_user_id,0),
            dtha.last_update_login = nvl(l_user_id,0),
            dtha.last_update_date = sysdate,
            dtha.object_version_number =  dtha.object_version_number +1
        WHERE dtha.ref_document_number = p_txn_header_rec_type.ref_document_number
        AND dtha.vendor_id = p_txn_header_rec_type.vendor_id;
        -- Check the transaction status if Approved, the lines are not updated.
        BEGIN
            SELECT dtla.supplier_approved_by
              INTO l_approved_by
              FROM dpp_transaction_lines_all dtla
             WHERE  dtla.transaction_header_id = p_txn_lines_tbl_type(i).transaction_header_id
               AND  dtla.inventory_item_id = p_txn_lines_tbl_type(i).inventory_item_id;
            EXCEPTION WHEN NO_DATA_FOUND THEN
            --l_approved_by := NULL;
            p_txn_lines_tbl_type(i).interface_status := 'E';
            END;
           IF l_approved_by IS NOT NULL OR  p_txn_lines_tbl_type(i).approved_inventory < 0 THEN
           p_txn_lines_tbl_type(i).interface_status := 'E';
           p_txn_lines_tbl_type(i).error_code := 'DPP_TXN_APPROVED';
            IF DPP_DEBUG_HIGH_ON THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'      The line (Inventory Item ID '
                   || p_txn_lines_tbl_type(i).inventory_item_id ||'is already approved by '||
                   l_approved_by);
            END IF;
           ELSE
            UPDATE dpp_transaction_lines_all dtla
            SET dtla.supplier_approved_by =p_txn_lines_tbl_type(i).supplier_approved_by,
                dtla.supplier_approval_date =TRUNC(p_txn_lines_tbl_type(i).supplier_approval_date),
                dtla.approved_inventory = p_txn_lines_tbl_type(i).approved_inventory,
                dtla.claim_amount=  p_txn_lines_tbl_type(i).approved_inventory*price_change,
                dtla.last_updated_by = nvl(l_user_id,0),
                dtla.last_update_login = nvl(l_user_id,0),
                dtla.last_update_date = sysdate,
                dtla.object_version_number =  dtla.object_version_number +1
            WHERE dtla.transaction_header_id = p_txn_lines_tbl_type(i).transaction_header_id
            AND dtla.inventory_item_id =p_txn_lines_tbl_type(i).inventory_item_id;
            END IF;
        END LOOP;--FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
       IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update Approval');
        END IF;
    EXCEPTION
      WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
      WHEN others THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END Update_Approval;

    PROCEDURE Update_ClaimsApproval(
                          p_txn_header_rec_type IN OUT nocopy txn_header_rec
                          ,p_txn_lines_tbl_type IN OUT nocopy txn_lines_tbl
                          ,x_msg_count OUT nocopy NUMBER
                          ,x_msg_data OUT nocopy VARCHAR2
                          ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Update_ClaimsApproval';
        l_api_version constant NUMBER := 1.0;
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_init_msg_list VARCHAR2(30) := FND_API.G_TRUE;
        l_commit      VARCHAR2(30) := FND_API.G_FALSE;
        l_validation_level  NUMBER       := FND_API.G_VALID_LEVEL_FULL;
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');
        l_count_lines NUMBER;
        l_count_approved_lines NUMBER;
        l_claim_txn_hdr_rec_type  dpp_businessevents_pvt.dpp_txn_hdr_rec_type;
        l_claim_txn_line_tbl_type dpp_businessevents_pvt.dpp_txn_line_tbl_type;

    BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update Claims Approval');
        END IF;
         --Get the Process code for Update Claim and set in the hdr rec type
            BEGIN
            SELECT fl.lookup_code
            INTO l_claim_txn_hdr_rec_type.Process_code
            FROM fnd_lookups fl
            WHERE fl.lookup_type = 'DPP_EXECUTION_PROCESSES'
              AND fl.lookup_code = 'UPDCLM';
            EXCEPTION
            WHEN no_data_found THEN
             x_return_status := fnd_api.g_ret_sts_error;
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   l_full_name);
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
             END IF;
                x_msg_data := fnd_message.get();
            END;

        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP
        --Get the number of approved lines for the transaction
            SELECT count(dtla.supplier_approved_by)
            INTO l_count_approved_lines
            FROM dpp_transaction_lines_all dtla
            WHERE dtla.transaction_header_id = p_txn_header_rec_type.transaction_header_id
              AND dtla.supp_dist_claim_id = p_txn_lines_tbl_type(i).supp_dist_claim_id
              AND dtla.supplier_approved_by IS NOT NULL;

               IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update Claims Approval l_count_approved_lines:'
                            ||l_count_approved_lines);
               END IF;
        --Get the number of lines for the claim
            SELECT count(transaction_line_id)
            INTO l_count_lines
            FROM dpp_transaction_lines_all dtla
            WHERE transaction_header_id = p_txn_header_rec_type.transaction_header_id
              AND dtla.supp_dist_claim_id = p_txn_lines_tbl_type(i).supp_dist_claim_id;

             IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update Claims Approval l_count_lines:'
                            ||l_count_lines);
             END IF;

        IF l_count_approved_lines = l_count_lines THEN
            UPDATE dpp_transaction_claims_all dtca
               SET dtca.approved_by_supplier = 'Y',
                   dtca.last_updated_by = nvl(l_user_id,0),
                   dtca.last_update_date =sysdate,
                   dtca.last_update_login = nvl(l_user_id,0),
                   dtca.object_version_number =  dtca.object_version_number +1
             WHERE dtca.transaction_header_id = p_txn_header_rec_type.transaction_header_id
              AND dtca.claim_id = p_txn_lines_tbl_type(i).supp_dist_claim_id;


        --Form Record type to call procedure
    l_claim_txn_hdr_rec_type.Transaction_Header_ID :=  p_txn_header_rec_type.transaction_header_id;
    l_claim_txn_hdr_rec_type.Transaction_number    :=  p_txn_header_rec_type.Transaction_number;
    l_claim_txn_hdr_rec_type.claim_id              :=  p_txn_lines_tbl_type(i).supp_dist_claim_id;

   IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Raises Business Event to Update claims:'
                            ||l_count_lines);
   END IF;
        dpp_businessevents_pvt.Raise_Business_Event(
                     p_api_version       => l_api_version
                    ,p_init_msg_list     => l_init_msg_list
                    ,p_commit            => l_commit
                    ,p_validation_level  =>l_validation_level
                    ,x_return_status     => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data          => x_msg_data
                    ,p_txn_hdr_rec       => l_claim_txn_hdr_rec_type
                    ,p_txn_line_id       => l_claim_txn_line_tbl_type
                    );
           IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
                RAISE Fnd_Api.g_exc_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;
            IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Procedure called to raise business event to'
                                      ||' update the claim status.');
            END IF;
        END IF;
      END LOOP;
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update Claims Approval');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   l_full_name);
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END Update_ClaimsApproval;

    PROCEDURE form_line_tbl(
                p_txn_header_rec_type IN OUT nocopy txn_header_rec
                ,p_txn_lines_tbl_type OUT nocopy txn_lines_tbl
                ,x_msg_count OUT nocopy NUMBER
                ,x_msg_data OUT nocopy VARCHAR2
                ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'form_line_tbl';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');
        l_txn_lines_rec_type  txn_lines_rec;

        l_line_number   NUMBER;
        l_duplicate_lines NUMBER;
        l_error_message VARCHAR2(4000) := NULL;



        --Cursor to fetch line information from interface table
        CURSOR fetch_lines_cur(p_transaction_id NUMBER) IS
        SELECT *
        FROM dpp_txn_lines_int_all
        WHERE transaction_int_header_id = p_transaction_id
        order by transaction_int_line_id;

    BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin form line tbl');
        END IF;


           l_line_number := 0;
           --fetch records from dpp_txn_lines_int_all table for the selected header.
       FOR fetch_lines_rec IN fetch_lines_cur(p_txn_header_rec_type.transaction_int_header_id)
       LOOP
             IF p_txn_header_rec_type.org_id <> nvl(fetch_lines_rec.org_id,p_txn_header_rec_type.org_id) THEN
                  x_return_status := fnd_api.g_ret_sts_error;
                  fnd_message.set_name('DPP',   'DPP_TXN_ORG_MISMATCH');
                  fnd_message.set_token('HEADER_ORG_ID',    p_txn_header_rec_type.org_id);
                  fnd_message.set_token('LINE_ORG_ID',  fetch_lines_rec.org_id);
                  x_msg_data :=fnd_message.get();
                  --RAISE Fnd_Api.G_EXC_ERROR;
                  l_txn_lines_rec_type.error_code := 'DPP_TXN_ORG_MISMATCH';
                  x_return_status := Fnd_Api.g_ret_sts_error ;
                  l_error_message := l_error_message ||  x_msg_data;
            END IF;
            l_txn_lines_rec_type.line_number            := l_line_number + 1;
            l_txn_lines_rec_type.transaction_header_id  :=  p_txn_header_rec_type.transaction_header_id;
            l_txn_lines_rec_type.supplier_part_num      :=  fetch_lines_rec.supplier_part_num;
            l_txn_lines_rec_type.inventory_item_id      :=  fetch_lines_rec.inventory_item_id;
            l_txn_lines_rec_type.item_number            :=  fetch_lines_rec.item_number;
                                l_txn_lines_rec_type.prior_price            :=  fetch_lines_rec.prior_price;  --ANBBALAS
            l_txn_lines_rec_type.change_type            :=  fetch_lines_rec.change_type;
            l_txn_lines_rec_type.change_value           :=  fetch_lines_rec.change_value ;
            l_txn_lines_rec_type.covered_inventory      :=  fetch_lines_rec.covered_inventory;
            l_txn_lines_rec_type.approved_inventory     :=  fetch_lines_rec.approved_inventory;
            l_txn_lines_rec_type.uom                    :=  fetch_lines_rec.uom;
            l_txn_lines_rec_type.org_id                 :=  p_txn_header_rec_type.org_id;
            l_txn_lines_rec_type.orig_sys_document_line_ref:=fetch_lines_rec.transaction_int_line_id;
            l_txn_lines_rec_type.transaction_int_line_id   :=fetch_lines_rec.transaction_int_line_id;
            l_txn_lines_rec_type.creation_date             :=sysdate;
            l_txn_lines_rec_type.created_by                := nvl(l_user_id,0);
            l_txn_lines_rec_type.last_update_date          := sysdate;
            l_txn_lines_rec_type.last_updated_by           := nvl(l_user_id,0);
            l_txn_lines_rec_type.last_update_login         := nvl(l_user_id,0);
            l_txn_lines_rec_type.attribute_category        := fetch_lines_rec.attribute_category;
            l_txn_lines_rec_type.attribute1                := fetch_lines_rec.attribute1;
            l_txn_lines_rec_type.attribute2                := fetch_lines_rec.attribute2;
            l_txn_lines_rec_type.attribute3                := fetch_lines_rec.attribute3;
            l_txn_lines_rec_type.attribute4                := fetch_lines_rec.attribute4;
            l_txn_lines_rec_type.attribute5                := fetch_lines_rec.attribute5;
            l_txn_lines_rec_type.attribute6                := fetch_lines_rec.attribute6;
            l_txn_lines_rec_type.attribute7                := fetch_lines_rec.attribute7;
            l_txn_lines_rec_type.attribute8                := fetch_lines_rec.attribute8;
            l_txn_lines_rec_type.attribute9                := fetch_lines_rec.attribute9;
            l_txn_lines_rec_type.attribute10               := fetch_lines_rec.attribute10;
            l_txn_lines_rec_type.attribute11               := fetch_lines_rec.attribute11;
            l_txn_lines_rec_type.attribute12               := fetch_lines_rec.attribute12;
            l_txn_lines_rec_type.attribute13               := fetch_lines_rec.attribute13;
            l_txn_lines_rec_type.attribute14               := fetch_lines_rec.attribute14;
            l_txn_lines_rec_type.attribute15               := fetch_lines_rec.attribute15;
            l_txn_lines_rec_type.attribute16               := fetch_lines_rec.attribute16;
            l_txn_lines_rec_type.attribute17               := fetch_lines_rec.attribute17;
            l_txn_lines_rec_type.attribute18               := fetch_lines_rec.attribute18;
            l_txn_lines_rec_type.attribute19               := fetch_lines_rec.attribute19;
            l_txn_lines_rec_type.attribute20               := fetch_lines_rec.attribute20;
            l_txn_lines_rec_type.attribute21               := fetch_lines_rec.attribute21;
            l_txn_lines_rec_type.attribute22               := fetch_lines_rec.attribute22;
            l_txn_lines_rec_type.attribute23               := fetch_lines_rec.attribute23;
            l_txn_lines_rec_type.attribute24               := fetch_lines_rec.attribute24;
            l_txn_lines_rec_type.attribute25               := fetch_lines_rec.attribute25;
            l_txn_lines_rec_type.attribute26               := fetch_lines_rec.attribute26;
            l_txn_lines_rec_type.attribute27               := fetch_lines_rec.attribute27;
            l_txn_lines_rec_type.attribute28               := fetch_lines_rec.attribute28;
            l_txn_lines_rec_type.attribute29               := fetch_lines_rec.attribute29;
            l_txn_lines_rec_type.attribute30               := fetch_lines_rec.attribute30;
            l_txn_lines_rec_type.request_id                := fetch_lines_rec.request_id;
            l_txn_lines_rec_type.program_application_id    := fetch_lines_rec.program_application_id;
            l_txn_lines_rec_type.program_id                := fetch_lines_rec.program_id ;
            l_txn_lines_rec_type.program_update_date       := fetch_lines_rec.program_update_date;
            l_txn_lines_rec_type.claim_amount              := fetch_lines_rec.claim_amount;
            l_txn_lines_rec_type.supplier_approved_by      := p_txn_header_rec_type.supplier_approved_by;
            l_txn_lines_rec_type.supplier_approval_date    := p_txn_header_rec_type.supplier_approval_date;
            l_txn_lines_rec_type.interface_status          := 'P';

            p_txn_lines_tbl_type(l_line_number) :=l_txn_lines_rec_type;
            l_txn_lines_rec_type :=null;
            l_line_number := l_line_number +1;
        END LOOP;  --FOR fetch_lines_rec IN fetch_lines_cur(p_txn_header_rec_type.transaction_int_header_id)
        --CLOSE fetch_lines_cur;
        IF l_error_message IS NOT NULL THEN
            x_msg_data := l_error_message;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
       IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End form line tbl');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
           x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END form_line_tbl;

    PROCEDURE Update_HeaderLog(
                p_txn_header_rec_type IN OUT nocopy txn_header_rec
                ,x_msg_count OUT nocopy NUMBER
                ,x_msg_data OUT nocopy VARCHAR2
                ,x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(30) := 'Update_HeaderLog';
        l_api_version constant NUMBER := 1.0;
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_return_status VARCHAR2(30);
        l_init_msg_list VARCHAR2(30) := FND_API.G_FALSE;
        l_commit      VARCHAR2(30) := FND_API.G_FALSE;
        l_validation_level  NUMBER       := FND_API.G_VALID_LEVEL_FULL;
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');

        l_txn_hdr_hist_rec dpp_log_pvt.dpp_cst_hdr_rec_type;
        l_txn_hdr_rec      dpp_log_pvt.dpp_cst_hdr_rec_type;
    BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update HeaderLog');
        END IF;

        IF p_txn_header_rec_type.supplier_approved_by IS NULL THEN
             l_txn_hdr_hist_rec.log_mode := 'I';
        ELSE
             l_txn_hdr_hist_rec.log_mode := 'U';
        END IF;
        l_txn_hdr_hist_rec.transaction_header_id     := p_txn_header_rec_type.transaction_header_id;
        l_txn_hdr_hist_rec.ref_document_number       := p_txn_header_rec_type.ref_document_number;
        l_txn_hdr_hist_rec.contact_email_address     := p_txn_header_rec_type.contact_email_address;
        l_txn_hdr_hist_rec.contact_phone             := p_txn_header_rec_type.contact_phone ;
        l_txn_hdr_hist_rec.transaction_source        := p_txn_header_rec_type.transaction_source;
        l_txn_hdr_hist_rec.transaction_creation_date := p_txn_header_rec_type.transaction_creation_date;
        l_txn_hdr_hist_rec.effective_start_date      := p_txn_header_rec_type.effective_start_date;
        l_txn_hdr_hist_rec.days_covered              := p_txn_header_rec_type.days_covered;
        l_txn_hdr_hist_rec.transaction_status        := p_txn_header_rec_type.transaction_status;
        l_txn_hdr_hist_rec.org_id                    := p_txn_header_rec_type.org_id;
        l_txn_hdr_hist_rec.orig_sys_document_ref     := p_txn_header_rec_type.orig_sys_document_ref;
        l_txn_hdr_hist_rec.creation_date          := p_txn_header_rec_type.creation_date;
        l_txn_hdr_hist_rec.created_by           := p_txn_header_rec_type.created_by;
        l_txn_hdr_hist_rec.last_update_date          := p_txn_header_rec_type.last_update_date;
        l_txn_hdr_hist_rec.last_updated_by           := p_txn_header_rec_type.last_updated_by;
        l_txn_hdr_hist_rec.last_update_login         := p_txn_header_rec_type.last_update_login;
        l_txn_hdr_hist_rec.attribute_category        := p_txn_header_rec_type.attribute_category;
        l_txn_hdr_hist_rec.attribute1                := p_txn_header_rec_type.attribute1;
        l_txn_hdr_hist_rec.attribute2                := p_txn_header_rec_type.attribute2;
        l_txn_hdr_hist_rec.attribute3                := p_txn_header_rec_type.attribute3;
        l_txn_hdr_hist_rec.attribute4                := p_txn_header_rec_type.attribute4;
        l_txn_hdr_hist_rec.attribute5                := p_txn_header_rec_type.attribute5;
        l_txn_hdr_hist_rec.attribute6                := p_txn_header_rec_type.attribute6;
        l_txn_hdr_hist_rec.attribute7                := p_txn_header_rec_type.attribute7;
        l_txn_hdr_hist_rec.attribute8                := p_txn_header_rec_type.attribute8;
        l_txn_hdr_hist_rec.attribute9                := p_txn_header_rec_type.attribute9;
        l_txn_hdr_hist_rec.attribute10               := p_txn_header_rec_type.attribute10;
        l_txn_hdr_hist_rec.attribute11               := p_txn_header_rec_type.attribute11;
        l_txn_hdr_hist_rec.attribute12               := p_txn_header_rec_type.attribute12;
        l_txn_hdr_hist_rec.attribute13               := p_txn_header_rec_type.attribute13;
        l_txn_hdr_hist_rec.attribute14               := p_txn_header_rec_type.attribute14;
        l_txn_hdr_hist_rec.attribute15               := p_txn_header_rec_type.attribute15;
        l_txn_hdr_hist_rec.attribute16               := p_txn_header_rec_type.attribute16;
        l_txn_hdr_hist_rec.attribute17               := p_txn_header_rec_type.attribute17;
        l_txn_hdr_hist_rec.attribute18               := p_txn_header_rec_type.attribute18;
        l_txn_hdr_hist_rec.attribute19               := p_txn_header_rec_type.attribute19;
        l_txn_hdr_hist_rec.attribute20               := p_txn_header_rec_type.attribute20;
        l_txn_hdr_hist_rec.attribute21               := p_txn_header_rec_type.attribute21;
        l_txn_hdr_hist_rec.attribute22               := p_txn_header_rec_type.attribute22;
        l_txn_hdr_hist_rec.attribute23               := p_txn_header_rec_type.attribute23;
        l_txn_hdr_hist_rec.attribute24               := p_txn_header_rec_type.attribute24;
        l_txn_hdr_hist_rec.attribute25               := p_txn_header_rec_type.attribute25;
        l_txn_hdr_hist_rec.attribute26               := p_txn_header_rec_type.attribute26;
        l_txn_hdr_hist_rec.attribute27               := p_txn_header_rec_type.attribute27;
        l_txn_hdr_hist_rec.attribute28               := p_txn_header_rec_type.attribute28;
        l_txn_hdr_hist_rec.attribute29               := p_txn_header_rec_type.attribute29;
        l_txn_hdr_hist_rec.attribute30               := p_txn_header_rec_type.attribute30;
        l_txn_hdr_hist_rec.trx_currency              := p_txn_header_rec_type.trx_currency;
        l_txn_hdr_rec :=l_txn_hdr_hist_rec;
  -- Log has Agreement Status, Headers has Transaction Status
        dpp_log_pvt.insert_headerlog(
            p_api_version        => l_api_version
            ,p_init_msg_list     => l_init_msg_list
            ,p_commit            => l_commit
            ,p_validation_level  => l_validation_level
            ,x_return_status     => l_return_status
            ,x_msg_count     =>     x_msg_count
            ,x_msg_data          => x_msg_data
            ,p_txn_hdr_rec   => l_txn_hdr_hist_rec
            );
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update HeaderLog');
        END IF;
        IF l_return_status =  Fnd_Api.g_ret_sts_error THEN
            RAISE Fnd_Api.g_exc_error;
        ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
           x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   l_full_name);
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END Update_HeaderLog;

    PROCEDURE Update_LinesLog(
                p_txn_lines_tbl_type IN OUT nocopy txn_lines_tbl
                ,x_msg_count OUT nocopy NUMBER
                ,x_msg_data OUT nocopy VARCHAR2
                ,x_return_status OUT nocopy VARCHAR2)
    AS

        l_api_name constant VARCHAR2(30) := 'Update_LinesLog';
        l_api_version constant NUMBER := 1.0;
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_init_msg_list VARCHAR2(30) := FND_API.G_FALSE;
        l_commit      VARCHAR2(30) := FND_API.G_FALSE;
        l_validation_level  NUMBER       := FND_API.G_VALID_LEVEL_FULL;

        l_txn_line_hist_tbl  dpp_log_pvt.dpp_txn_line_tbl_type;
    BEGIN
        --SAVEPOINT DPP_Update_LinesLog;
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update LinesLog');
        END IF;
        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP
        IF p_txn_lines_tbl_type(i).approved_inventory IS NULL THEN
             l_txn_line_hist_tbl(i).log_mode := 'I';
        ELSE
             l_txn_line_hist_tbl(i).log_mode := 'U';
        END IF;
            l_txn_line_hist_tbl(i).transaction_header_id  :=  p_txn_lines_tbl_type(i).transaction_header_id;
            l_txn_line_hist_tbl(i).transaction_line_id    :=  p_txn_lines_tbl_type(i).transaction_line_id;
            l_txn_line_hist_tbl(i).supplier_part_num      :=  p_txn_lines_tbl_type(i).supplier_part_num;
            l_txn_line_hist_tbl(i).line_number            :=  p_txn_lines_tbl_type(i).line_number;
            l_txn_line_hist_tbl(i).prior_price            :=  p_txn_lines_tbl_type(i).prior_price ;
            l_txn_line_hist_tbl(i).change_type            :=  p_txn_lines_tbl_type(i).change_type;
            l_txn_line_hist_tbl(i).change_value           :=  p_txn_lines_tbl_type(i).change_value  ;
            l_txn_line_hist_tbl(i).price_change           :=  p_txn_lines_tbl_type(i).price_change  ;
            l_txn_line_hist_tbl(i).covered_inventory      :=  p_txn_lines_tbl_type(i).covered_inventory;
            l_txn_line_hist_tbl(i).approved_inventory     :=  p_txn_lines_tbl_type(i).approved_inventory;
            l_txn_line_hist_tbl(i).org_id                 :=  p_txn_lines_tbl_type(i).org_id;
            l_txn_line_hist_tbl(i).creation_date          :=  p_txn_lines_tbl_type(i).creation_date;
            l_txn_line_hist_tbl(i).created_by             :=  p_txn_lines_tbl_type(i).created_by;
            l_txn_line_hist_tbl(i).last_update_date       :=  p_txn_lines_tbl_type(i).last_update_date;
            l_txn_line_hist_tbl(i).last_updated_by        :=  p_txn_lines_tbl_type(i).last_updated_by;
            l_txn_line_hist_tbl(i).last_update_login      :=  p_txn_lines_tbl_type(i).last_update_login;
            l_txn_line_hist_tbl(i).attribute_category        := p_txn_lines_tbl_type(i).attribute_category;
            l_txn_line_hist_tbl(i).attribute1                := p_txn_lines_tbl_type(i).attribute1;
            l_txn_line_hist_tbl(i).attribute2                := p_txn_lines_tbl_type(i).attribute2;
            l_txn_line_hist_tbl(i).attribute3                := p_txn_lines_tbl_type(i).attribute3;
            l_txn_line_hist_tbl(i).attribute4                := p_txn_lines_tbl_type(i).attribute4;
            l_txn_line_hist_tbl(i).attribute5                := p_txn_lines_tbl_type(i).attribute5;
            l_txn_line_hist_tbl(i).attribute6                := p_txn_lines_tbl_type(i).attribute6;
            l_txn_line_hist_tbl(i).attribute7                := p_txn_lines_tbl_type(i).attribute7;
            l_txn_line_hist_tbl(i).attribute8                := p_txn_lines_tbl_type(i).attribute8;
            l_txn_line_hist_tbl(i).attribute9                := p_txn_lines_tbl_type(i).attribute9;
            l_txn_line_hist_tbl(i).attribute10               := p_txn_lines_tbl_type(i).attribute10;
            l_txn_line_hist_tbl(i).attribute11               := p_txn_lines_tbl_type(i).attribute11;
            l_txn_line_hist_tbl(i).attribute12               := p_txn_lines_tbl_type(i).attribute12;
            l_txn_line_hist_tbl(i).attribute13               := p_txn_lines_tbl_type(i).attribute13;
            l_txn_line_hist_tbl(i).attribute14               := p_txn_lines_tbl_type(i).attribute14;
            l_txn_line_hist_tbl(i).attribute15               := p_txn_lines_tbl_type(i).attribute15;
            l_txn_line_hist_tbl(i).attribute16               := p_txn_lines_tbl_type(i).attribute16;
            l_txn_line_hist_tbl(i).attribute17               := p_txn_lines_tbl_type(i).attribute17;
            l_txn_line_hist_tbl(i).attribute18               := p_txn_lines_tbl_type(i).attribute18;
            l_txn_line_hist_tbl(i).attribute19               := p_txn_lines_tbl_type(i).attribute19;
            l_txn_line_hist_tbl(i).attribute20               := p_txn_lines_tbl_type(i).attribute20;
            l_txn_line_hist_tbl(i).attribute21               := p_txn_lines_tbl_type(i).attribute21;
            l_txn_line_hist_tbl(i).attribute22               := p_txn_lines_tbl_type(i).attribute22;
            l_txn_line_hist_tbl(i).attribute23               := p_txn_lines_tbl_type(i).attribute23;
            l_txn_line_hist_tbl(i).attribute24               := p_txn_lines_tbl_type(i).attribute24;
            l_txn_line_hist_tbl(i).attribute25               := p_txn_lines_tbl_type(i).attribute25;
            l_txn_line_hist_tbl(i).attribute26               := p_txn_lines_tbl_type(i).attribute26;
            l_txn_line_hist_tbl(i).attribute27               := p_txn_lines_tbl_type(i).attribute27;
            l_txn_line_hist_tbl(i).attribute28               := p_txn_lines_tbl_type(i).attribute28;
            l_txn_line_hist_tbl(i).attribute29               := p_txn_lines_tbl_type(i).attribute29;
            l_txn_line_hist_tbl(i).attribute30               := p_txn_lines_tbl_type(i).attribute30;
            l_txn_line_hist_tbl(i).inventory_item_id        := p_txn_lines_tbl_type(i).inventory_item_id  ;
            l_txn_line_hist_tbl(i).supplier_new_price       := p_txn_lines_tbl_type(i).supplier_new_price  ;
            l_txn_line_hist_tbl(i).last_calculated_by       := p_txn_lines_tbl_type(i).last_calculated_by ;
            l_txn_line_hist_tbl(i).last_calculated_date     := p_txn_lines_tbl_type(i).last_calculated_date ;
            l_txn_line_hist_tbl(i).claim_amount             := p_txn_lines_tbl_type(i).claim_amount ;
            l_txn_line_hist_tbl(i).supp_dist_claim_id       := p_txn_lines_tbl_type(i).supp_dist_claim_id;
            l_txn_line_hist_tbl(i).update_purchasing_docs   := p_txn_lines_tbl_type(i).update_purchasing_docs;
            l_txn_line_hist_tbl(i).notify_purchasing_docs   := p_txn_lines_tbl_type(i).notify_purchasing_docs ;
            l_txn_line_hist_tbl(i).update_inventory_costing := p_txn_lines_tbl_type(i).update_inventory_costing ;
            l_txn_line_hist_tbl(i).update_item_list_price   := p_txn_lines_tbl_type(i).update_item_list_price;
            l_txn_line_hist_tbl(i).supp_dist_claim_status   := p_txn_lines_tbl_type(i).supp_dist_claim_status ;
            l_txn_line_hist_tbl(i).onhand_inventory         := p_txn_lines_tbl_type(i).onhand_inventory ;
            l_txn_line_hist_tbl(i).manually_adjusted        := p_txn_lines_tbl_type(i).manually_adjusted ;
            l_txn_line_hist_tbl(i).notify_inbound_pricelist := p_txn_lines_tbl_type(i).notify_inbound_pricelist  ;
            l_txn_line_hist_tbl(i).notify_outbound_pricelist:= p_txn_lines_tbl_type(i).notify_outbound_pricelist ;
            l_txn_line_hist_tbl(i).supplier_approved_by     := p_txn_lines_tbl_type(i).supplier_approved_by  ;
            l_txn_line_hist_tbl(i).supplier_approval_date   := p_txn_lines_tbl_type(i).supplier_approval_date   ;
            l_txn_line_hist_tbl(i).create_on_hand_claim      := null;
            l_txn_line_hist_tbl(i).create_vend_cust_claim    := null;

        END LOOP;--FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST


        dpp_log_pvt.Insert_LinesLog(
            p_api_version        => l_api_version
           ,p_init_msg_list  => l_init_msg_list
           ,p_commit             => l_commit
           ,p_validation_level   => l_validation_level
           ,x_return_status  => x_return_status
           ,x_msg_count          => x_msg_count
           ,x_msg_data           => x_msg_data
           ,p_txn_lines_tbl      =>     l_txn_line_hist_tbl
        );

        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update LinesLog');
        END IF;
        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
             x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   l_full_name);
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END  Update_LinesLog;

    PROCEDURE Update_InterfaceTbl(
                    p_txn_header_rec_type IN OUT nocopy txn_header_rec
                    ,   p_txn_lines_tbl_type IN OUT nocopy txn_lines_tbl
                    ,   x_msg_count OUT nocopy NUMBER
                    ,   x_msg_data OUT nocopy VARCHAR2
                    ,   x_return_status OUT nocopy VARCHAR2)
    AS
        l_date DATE;
        l_api_name constant VARCHAR2(30) := 'Update_InterfaceTbl';
        l_user_id NUMBER :=FND_PROFILE.VALUE('USER_ID');
    BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update InterfaceTbl');
        END IF;
        --Update Interface Header table
        UPDATE DPP_TXN_HEADERS_INT_ALL dtha
        SET
            dtha.org_id                         =   p_txn_header_rec_type.org_id,
            dtha.vendor_id                      =   p_txn_header_rec_type.vendor_id,
            dtha.vendor_site_id                 =   p_txn_header_rec_type.vendor_site_id,
            dtha.last_update_date           =   SYSDATE,
            dtha.last_updated_by            =   nvl(l_user_id,0),
            dtha.last_update_login          =       nvl(l_user_id,0),
            dtha.interface_status           =      'P',
            dtha.currency           =p_txn_header_rec_type.trx_currency
        WHERE TRANSACTION_INT_HEADER_ID = p_txn_header_rec_type.transaction_int_header_id;

        --Update interface lines table
        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP
            UPDATE DPP_TXN_LINES_INT_ALL dtla
            SET
                dtla.supplier_part_num  =   p_txn_lines_tbl_type(i).supplier_part_num,
                dtla.inventory_item_id  =   p_txn_lines_tbl_type(i).inventory_item_id,
                dtla.item_number        =   p_txn_lines_tbl_type(i).item_number,
                dtla.interface_status   =   'P',--p_txn_lines_tbl_type(i).interface_status,
                dtla.org_id             =   p_txn_lines_tbl_type(i).org_id,
                dtla.last_update_date   =   SYSDATE,
                dtla.last_updated_by    =   nvl(l_user_id,0),
                dtla.last_update_login  =   nvl(l_user_id,0)
            WHERE dtla.transaction_int_line_id = p_txn_lines_tbl_type(i).transaction_int_line_id;
        END LOOP;--FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update InterfaceTbl');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;

        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||x_msg_data);
    END Update_InterfaceTbl;



PROCEDURE Update_InterfaceLineErrSts(
                  p_txn_header_rec_type IN OUT nocopy txn_header_rec,
                  p_txn_lines_tbl_type IN OUT NOCOPY txn_lines_tbl,
                  x_return_status OUT nocopy VARCHAR2
                  )
AS

l_api_name constant VARCHAR2(30) := 'Update_InterfaceErrSts';
l_user_id NUMBER :=FND_PROFILE.VALUE('USER_ID');
BEGIN
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
       IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      Begin Update InterfaceErrSts');
        END IF;

        --Update Interface Header table with error status
        UPDATE DPP_TXN_HEADERS_INT_ALL dtha
        SET
            dtha.last_update_date           =   SYSDATE,
            dtha.last_updated_by            =    nvl(l_user_id,0),
            dtha.last_update_login          =    nvl(l_user_id,0),
            dtha.interface_status           =      'E',
            dtha.error_code                 =   decode(dtha.error_code,NULL,nvl(p_txn_header_rec_type.error_code,'SQL_PLSQL_ERROR'),'MULTIPLE_ERRORS')
        WHERE transaction_int_header_id = p_txn_header_rec_type.transaction_int_header_id;

        --Update interface lines table  with error status for all the lines of the error header.
        FOR i in p_txn_lines_tbl_type.FIRST..p_txn_lines_tbl_type.LAST
        LOOP
            UPDATE DPP_TXN_LINES_INT_ALL dtla
            SET
                dtla.last_update_date   =   SYSDATE,
                dtla.last_updated_by    =   nvl(l_user_id,0),
                dtla.last_update_login  =   nvl(l_user_id,0),
                dtla.interface_status   =       'E',
                dtla.error_code         =       p_txn_lines_tbl_type(i).error_code
            WHERE dtla.transaction_int_header_id = p_txn_header_rec_type.transaction_int_header_id
              AND dtla.transaction_int_line_id = p_txn_lines_tbl_type(i).transaction_int_line_id;
              END LOOP;
             COMMIT;

       IF DPP_DEBUG_HIGH_ON THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG,'      End Update InterfaceErrSts');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'      '||sqlerrm);
    END Update_InterfaceLineErrSts;

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    insert_transaction
    --
    -- PURPOSE
    --    Inserts Price protection transaction details to dpp transaction headers and lines all
    --
    -- PARAMETERS
    --
    -- NOTES
    --    1. Transaction_int_header id
    ----------------------------------------------------------------------
    PROCEDURE Insert_Transaction(p_api_version IN NUMBER
            ,   p_init_msg_list IN VARCHAR2 := fnd_api.g_false
            ,   p_commit IN VARCHAR2 := fnd_api.g_false
            ,   p_validation_level IN NUMBER := fnd_api.g_valid_level_full
            ,   p_transaction_int_header_id IN NUMBER
            ,   p_operating_unit IN VARCHAR2 DEFAULT NULL
            ,   x_return_status OUT nocopy VARCHAR2
            ,   x_msg_count OUT nocopy NUMBER
            ,   x_msg_data OUT nocopy VARCHAR2
    )
    IS
        l_api_name constant     VARCHAR2(30) := 'insert_transaction';
        l_api_version constant  NUMBER := 1.0;
        l_full_name constant    VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status         VARCHAR2(30);
        l_user_id               NUMBER :=FND_PROFILE.VALUE('USER_ID');
        l_transaction_status    VARCHAR2(55);
        l_status_cancelled      VARCHAR2(55);
        l_transaction_type  VARCHAR2(100);
        l_log_enabled           VARCHAR2(20);

        l_txn_header_rec_type   txn_header_rec;
        l_txn_lines_rec_type    txn_lines_rec;

        l_txn_lines_tbl_type    txn_lines_tbl;
        l_ins_txn_line_tbl      txn_lines_tbl;
        l_upd_txn_line_tbl      txn_lines_tbl;
        l_txn_hdr_hist_rec      dpp_log_pvt.dpp_cst_hdr_rec_type;
        l_txn_line_hist_tbl     dpp_log_pvt.dpp_txn_line_tbl_type;
        l_supp_trade_profile_id NUMBER := NULL;       --ANBBALAS for 12_1_2
        l_concatenated_error_message VARCHAR2(4000);
        l_msg_data  VARCHAR2(200);

        --Cursor to fetch header information from interface table
        CURSOR fetch_header_cur IS
        SELECT *
        FROM dpp_txn_headers_int_all dthia
        WHERE dthia.transaction_int_header_id = p_transaction_int_header_id;

    BEGIN
        -- Standard begin of API savepoint
        SAVEPOINT DPP_Insert_Transaction;
        IF Fnd_Api.to_boolean(p_init_msg_list) THEN
            Fnd_Msg_Pub.initialize;
        END IF;
      IF NOT Fnd_Api.compatible_api_call
        (
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name
        )
        THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;


        IF DPP_DEBUG_HIGH_ON THEN
          fnd_file.put_line(fnd_file.log,   'Begin Insert Transaction ' );
        END IF;

        SELECT fnd_profile.VALUE('DPP_AUDIT_ENABLED')
        INTO l_log_enabled
        FROM dual;

        IF DPP_DEBUG_HIGH_ON THEN
          fnd_file.put_line(fnd_file.log,   'Audit Enabled '||l_log_enabled );
        END IF;

        --fetch records from dpp_txn_headers_int_all table
        FOR fetch_header_rec IN fetch_header_cur
        LOOP
            --check whether it is an inbound transaction or pre approval transaction by checking Approved by column
            IF fetch_header_rec.supplier_approved_by IS NULL THEN
                l_transaction_type := 'INB';
            ELSE
                l_transaction_type := 'APP';
            END IF;

	  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Insert Transaction:'||l_transaction_type);

            --Form header record type to populate header table
            l_txn_header_rec_type.transaction_int_header_id :=fetch_header_rec.transaction_int_header_id;
            l_txn_header_rec_type.ref_document_number       := fetch_header_rec.ref_document_number;
            l_txn_header_rec_type.contact_email_address     := fetch_header_rec.contact_email_address;
            l_txn_header_rec_type.contact_phone             := fetch_header_rec.contact_phone;
            l_txn_header_rec_type.transaction_source        := fetch_header_rec.transaction_source;
            l_txn_header_rec_type.transaction_creation_date := sysdate;
            l_txn_header_rec_type.effective_start_date      := TRUNC(fetch_header_rec.effective_start_date);
            l_txn_header_rec_type.days_covered              := fetch_header_rec.days_covered;
            l_txn_header_rec_type.transaction_status        := null;
            l_txn_header_rec_type.trx_currency              := fetch_header_rec.currency;
            l_txn_header_rec_type.operating_unit_name       := fetch_header_rec.operating_unit_name;
            l_txn_header_rec_type.org_id                    := fetch_header_rec.org_id;
            l_txn_header_rec_type.vendor_name               := fetch_header_rec.vendor_name;
            l_txn_header_rec_type.vendor_id                 := fetch_header_rec.vendor_id;
            l_txn_header_rec_type.vendor_site_code          := fetch_header_rec.vendor_site;
            l_txn_header_rec_type.vendor_site_id            := fetch_header_rec.vendor_site_id;
            l_txn_header_rec_type.vendor_contact_name       := fetch_header_rec.vendor_contact_name;
            l_txn_header_rec_type.vendor_contact_id         := fetch_header_rec.vendor_contact_id;
            l_txn_header_rec_type.supplier_approved_by      := fetch_header_rec.supplier_approved_by;
            l_txn_header_rec_type.supplier_approval_date    := fetch_header_rec.supplier_approval_date;
            l_txn_header_rec_type.orig_sys_document_ref     := nvl(fetch_header_rec.orig_sys_document_ref,fetch_header_rec.transaction_int_header_id);
            l_txn_header_rec_type.creation_date             := sysdate;
            l_txn_header_rec_type.created_by                := nvl(l_user_id,0);
            l_txn_header_rec_type.last_update_date          := sysdate;
            l_txn_header_rec_type.last_updated_by           := nvl(l_user_id,0);
            l_txn_header_rec_type.last_update_login         := nvl(l_user_id,0);
            l_txn_header_rec_type.request_id                := fetch_header_rec.request_id;
            l_txn_header_rec_type.program_application_id    := fetch_header_rec.program_application_id;
            l_txn_header_rec_type.program_id                := fetch_header_rec.program_id ;
            l_txn_header_rec_type.program_update_date       := fetch_header_rec.program_update_date;
            l_txn_header_rec_type.attribute_category        := fetch_header_rec.attribute_category;
            l_txn_header_rec_type.attribute1                := fetch_header_rec.attribute1;
            l_txn_header_rec_type.attribute2                := fetch_header_rec.attribute2;
            l_txn_header_rec_type.attribute3                := fetch_header_rec.attribute3;
            l_txn_header_rec_type.attribute4                := fetch_header_rec.attribute4;
            l_txn_header_rec_type.attribute5                := fetch_header_rec.attribute5;
            l_txn_header_rec_type.attribute6                := fetch_header_rec.attribute6;
            l_txn_header_rec_type.attribute7                := fetch_header_rec.attribute7;
            l_txn_header_rec_type.attribute8                := fetch_header_rec.attribute8;
            l_txn_header_rec_type.attribute9                := fetch_header_rec.attribute9;
            l_txn_header_rec_type.attribute10               := fetch_header_rec.attribute10;
            l_txn_header_rec_type.attribute11               := fetch_header_rec.attribute11;
            l_txn_header_rec_type.attribute12               := fetch_header_rec.attribute12;
            l_txn_header_rec_type.attribute13               := fetch_header_rec.attribute13;
            l_txn_header_rec_type.attribute14               := fetch_header_rec.attribute14;
            l_txn_header_rec_type.attribute15               := fetch_header_rec.attribute15;
            l_txn_header_rec_type.attribute16               := fetch_header_rec.attribute16;
            l_txn_header_rec_type.attribute17               := fetch_header_rec.attribute17;
            l_txn_header_rec_type.attribute18               := fetch_header_rec.attribute18;
            l_txn_header_rec_type.attribute19               := fetch_header_rec.attribute19;
            l_txn_header_rec_type.attribute20               := fetch_header_rec.attribute20;
            l_txn_header_rec_type.attribute21               := fetch_header_rec.attribute21;
            l_txn_header_rec_type.attribute22               := fetch_header_rec.attribute22;
            l_txn_header_rec_type.attribute23               := fetch_header_rec.attribute23;
            l_txn_header_rec_type.attribute24               := fetch_header_rec.attribute24;
            l_txn_header_rec_type.attribute25               := fetch_header_rec.attribute25;
            l_txn_header_rec_type.attribute26               := fetch_header_rec.attribute26;
            l_txn_header_rec_type.attribute27               := fetch_header_rec.attribute27;
            l_txn_header_rec_type.attribute28               := fetch_header_rec.attribute28;
            l_txn_header_rec_type.attribute29               := fetch_header_rec.attribute29;
            l_txn_header_rec_type.attribute30               := fetch_header_rec.attribute30;
            l_txn_header_rec_type.interface_status          := 'P';
            l_txn_header_rec_type.supp_dist_claim_number    := fetch_header_rec.supp_dist_claim_number;
            l_txn_header_rec_type.supp_dist_claim_id        := fetch_header_rec.supp_dist_claim_id;

               --Validate the Ref Document Number
             Validate_RefDocNumber(p_txn_header_rec_type => l_txn_header_rec_type
                              ,x_msg_count          => x_msg_count
                              ,x_msg_data           => x_msg_data
                              ,x_return_status => l_return_status
                                      );
		   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Ref Doc Num Status :'||l_return_status);
            IF DPP_DEBUG_HIGH_ON THEN
               fnd_file.put_line(fnd_file.log,   'Validate Ref Document Number Return Status: '||l_return_status ||'Error Msg: '||x_msg_data);
            END IF;
                   IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                       Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                   END IF;
            --End Validate the Ref Document Number

            --Validate the Operating Unit
            Validate_OperatingUnit(p_txn_header_rec_type => l_txn_header_rec_type
                              ,x_msg_count          => x_msg_count
                              ,x_msg_data           => x_msg_data
                              ,x_return_status      => l_return_status
                            );
              DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Operating Unit Status :'||l_return_status);
            IF DPP_DEBUG_HIGH_ON THEN
               fnd_file.put_line(fnd_file.log,   'Validate Operating Unit Return Status: '||l_txn_header_rec_type.org_id  ||l_return_status ||'Error Msg: '||x_msg_data);
            END IF;

                   IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                   l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                      RAISE Fnd_Api.g_exc_error;
                   END IF;
            --End Validate the Operating Unit

            --Validate the vendor Details
            Validate_SupplierDetails(p_txn_header_rec_type => l_txn_header_rec_type
                              ,x_msg_count          => x_msg_count
                              ,x_msg_data           => x_msg_data
                              ,x_return_status => l_return_status
                                      );

		  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Supplier Details Status :'||l_return_status);

            IF DPP_DEBUG_HIGH_ON THEN
               fnd_file.put_line(fnd_file.log,   'Validate Supplier Details Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
            END IF;
                  IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                  l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                        RAISE Fnd_Api.g_exc_error;
                   END IF;
            --End Validate the vendor Details

            --ANBBALAS for 12_1_2
            --Validate the Supplier Trade Profile setup
            Validate_SupplierTrdPrfl(p_txn_header_rec_type => l_txn_header_rec_type
                              ,x_supp_trade_profile_id  => l_supp_trade_profile_id
                              ,x_msg_count          => x_msg_count
                              ,x_msg_data           => x_msg_data
                              ,x_return_status => l_return_status
                                      );

		  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Supplier Trade Profile Status :' || l_return_status);
            IF DPP_DEBUG_HIGH_ON THEN
               fnd_file.put_line(fnd_file.log,   'Validate Supplier Trade Profile Return Status:' || l_return_status || 'Error Msg ' || x_msg_data);
            END IF;
            IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              l_concatenated_error_message := l_concatenated_error_message || x_msg_data;
              ROLLBACK TO DPP_Insert_Transaction;
              Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
              RAISE Fnd_Api.g_exc_error;
            END IF;
            --End Validate the Supplier Trade Profile setup

            --Validate the Process Execution Setup at Supplier Trade Profile or System Parameters
            Validate_ExecProcessSetup(p_txn_header_rec_type => l_txn_header_rec_type
                              ,p_supp_trade_profile_id      => l_supp_trade_profile_id
                              ,x_msg_count          => x_msg_count
                              ,x_msg_data           => x_msg_data
                              ,x_return_status => l_return_status
                                      );

		  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Execution Process Setup Status : ' || l_return_status);

            IF DPP_DEBUG_HIGH_ON THEN
               fnd_file.put_line(fnd_file.log,   'Validate Execution Process Setup Status : ' || l_return_status || 'Error Msg ' || x_msg_data);
            END IF;
            IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              l_concatenated_error_message :=l_concatenated_error_message || x_msg_data;
              ROLLBACK TO DPP_Insert_Transaction;
              Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
              RAISE Fnd_Api.g_exc_error;
            END IF;
            --End Validate the Process Execution Setup at Supplier Trade Profile or System Parameters

            --Validate the transaction currency
            Validate_currency(p_txn_header_rec_type => l_txn_header_rec_type
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,x_return_status => l_return_status
                                    );

              DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Currency Status :'||l_return_status);

            IF DPP_DEBUG_HIGH_ON THEN
               fnd_file.put_line(fnd_file.log,   'Validate Currency Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
            END IF;
                  IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                       Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                   END IF;
            --End Validate the transaction currency

            Validate_lines(p_txn_header_rec_type => l_txn_header_rec_type
                              ,x_msg_count          => x_msg_count
                              ,x_msg_data           => x_msg_data
                              ,x_return_status => l_return_status
                                      );

		  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Lines Status :'||l_return_status);
            IF DPP_DEBUG_HIGH_ON THEN
               fnd_file.put_line(fnd_file.log,   'Validate Line Details Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
            END IF;
                  IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      ROLLBACK TO DPP_Insert_Transaction;
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                   END IF;

            --Check transaction status and populate l_transaction_status
            BEGIN
                SELECT dtha.transaction_status,
                     dtha.transaction_header_id
                INTO l_transaction_status
                    ,l_txn_header_rec_type.transaction_header_id
                FROM dpp_transaction_headers_all dtha
                WHERE  dtha.ref_document_number = l_txn_header_rec_type.ref_document_number
                  AND  dtha.vendor_id = l_txn_header_rec_type.vendor_id
                  --Modification to include supplier site reference
                  AND  dtha.vendor_site_id = l_txn_header_rec_type.vendor_site_id
                  AND transaction_status <> 'CANCELLED';

            EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_transaction_status := NULL;
                    WHEN TOO_MANY_ROWS THEN
                      fnd_message.set_name('DPP',   'DPP_TRANSACTION_EXIST');
                      fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
                      fnd_message.set_token('SUPPLIER_SITE',  l_txn_header_rec_type.vendor_site_code);
                      fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
                      x_msg_data := fnd_message.get();
                      l_txn_header_rec_type.error_code := 'DPP_TRANSACTION_EXIST';
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );

            END;
            --END Check transaction status and populate l_transaction_status

             BEGIN
            SELECT lookup_code
              INTO l_status_cancelled
              FROM fnd_lookups
             WHERE lookup_type = 'DPP_TRANSACTION_STATUSES'
               AND lookup_code = 'CANCELLED';
        EXCEPTION
            WHEN no_data_found THEN
                x_return_status := fnd_api.g_ret_sts_error;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                    fnd_message.set_name('DPP',   'DPP_TXN_STS_ERR');
                END IF;
                 x_msg_data := fnd_message.get();
                --RAISE Fnd_Api.G_EXC_ERROR;
                 l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                  Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
        END;
            --Check transaction type
            IF  l_transaction_type = 'INB'  THEN
                IF l_transaction_status IS NULL OR l_transaction_status = l_status_cancelled THEN
                IF DPP_DEBUG_HIGH_ON THEN
                  fnd_file.put_line(fnd_file.log,   '  Inbound Price Protection Transaction ' );
                END IF;
                  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'New Transaction');
                    IF l_concatenated_error_message IS NOT NULL THEN
                    RAISE Fnd_Api.g_exc_error;
                    END IF;
                    -- Create Header record in dpp_transaction_headers_all table
                    Create_Header(p_txn_header_rec_type => l_txn_header_rec_type
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,x_return_status => l_return_status
                            );

		    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Create Header Status :'||l_return_status);
                    IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Create Header Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                    END IF;
                  IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                      RAISE Fnd_Api.g_exc_error;
                   END IF;
                      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Create_Header');
                    --Update Header history log
                    IF l_log_enabled = 'Y' THEN
                        Update_HeaderLog(p_txn_header_rec_type => l_txn_header_rec_type
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
                                    ,x_return_status => l_return_status
                                );
                        IF DPP_DEBUG_HIGH_ON THEN
                           fnd_file.put_line(fnd_file.log,   'Update Header Log Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                        END IF;

                        IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                            l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                        END IF;
                    END IF;
                    --Get the lines in a tbl type
                    form_line_tbl(
                            p_txn_header_rec_type => l_txn_header_rec_type
                            ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,x_return_status => l_return_status
                            );

		    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Form Line Tbl Status :'||l_return_status);
                    IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Form Line Tbl Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                    END IF;
                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
                    END IF;
                      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Form line tbl');
                    --Validate the distributor Part Number
                    Validate_SupplierPartNum(
                        p_txn_header_rec_type =>l_txn_header_rec_type
                        ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,x_return_status => l_return_status
                        );
		    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Supplier Part Num Status :'||l_return_status);
                    IF G_DEBUG THEN
                       fnd_file.put_line(fnd_file.log,   'Validate SupplierPartNum Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                       DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate SupplierPartNum Return Status:'||l_return_status ||'Error Msg'||substr(x_msg_data,1,1000));
                    END IF;

                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
                   END IF;
                   IF l_concatenated_error_message IS NOT NULL THEN
                    x_msg_data:= l_concatenated_error_message;
                    RAISE Fnd_Api.g_exc_error;
                    END IF;
                      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Validate Supplier Part Number');
                    --Call Insert lines procedure
                    Create_lines(  p_txn_header_rec_type => l_txn_header_rec_type
                                   ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_msg_count     => x_msg_count
                                  ,x_msg_data      => x_msg_data
                                  ,x_return_status => l_return_status
                            );
                      DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Create Lines Status :'||l_return_status);
                    IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Create Lines Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                    END IF;
                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
                        RAISE Fnd_Api.g_exc_error;
                    END IF;
                    --Update lines log
                    IF l_log_enabled = 'Y' THEN
                        Update_LinesLog(
                            p_txn_lines_tbl_type => l_txn_lines_tbl_type
                            ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                            ,x_return_status => l_return_status
                            );
                        IF DPP_DEBUG_HIGH_ON THEN
                           fnd_file.put_line(fnd_file.log,   'Update Lines Log Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                        END IF;
                       IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                       l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
                       END IF;
                    END IF;
                    IF l_concatenated_error_message IS NOT NULL THEN
                    x_msg_data:= l_concatenated_error_message;
                    RAISE Fnd_Api.g_exc_error;
                    END IF;
                    --Update Covered Inventory
                    Update_CoveredInv(
                            p_txn_header_rec_type => l_txn_header_rec_type
                            ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data =>x_msg_data
                            ,x_return_status => l_return_status
                            );
		    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Update CoveredInv Status :'||l_return_status);
                    IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Update Covered Inventory Return Status:'||l_return_status);
                    END IF;
                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
		   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Status '||l_return_status|| ' Message '||x_msg_data);

                      RAISE Fnd_Api.g_exc_error;
                   END IF;
                ELSE
                    --The transaction is in Active/.... Status
                      fnd_message.set_name('DPP',   'DPP_TRANSACTION_EXIST');
                      fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
                      fnd_message.set_token('SUPPLIER_SITE',  l_txn_header_rec_type.vendor_site_code);
                      fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
                      x_msg_data := fnd_message.get();
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      l_txn_header_rec_type.error_code := 'DPP_TRANSACTION_EXIST';
                      IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Error:' || x_msg_data);
                      END IF;
                        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Transaction Exist Status :'||l_return_status);
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                        RAISE Fnd_Api.g_exc_error;
                END IF; --l_transaction_status is null

                      fnd_message.set_name('DPP',   'DPP_TRANSACTION_CREATED');
                      fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
                      fnd_message.set_token('SUPPLIER_SITE',  l_txn_header_rec_type.vendor_site_code);
                      fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
                      fnd_message.set_token('TRANSACTION_NUMBER',  l_txn_header_rec_type.transaction_number);
                      fnd_message.set_token('OPERATING_UNIT',  l_txn_header_rec_type.operating_unit_name);
                      x_msg_data := fnd_message.get();
                      fnd_file.put_line(fnd_file.log,   x_msg_data);

                IF l_concatenated_error_message IS NOT NULL THEN
                 x_msg_data := 'The Transaction for the supplier name '||l_txn_header_rec_type.vendor_name ||
                    ',Supplier site '||l_txn_header_rec_type.vendor_site_code ||' and Operating Unit Name '||l_txn_header_rec_type.operating_unit_name || ' failed.' ||l_concatenated_error_message;
                        RAISE Fnd_Api.g_exc_error;
                END IF;
                --ANBBALAS for 12_1_2
                --Populate Execution Processes based on Supplier Trade Profile or System Parameters
                DPP_EXECUTIONPROCESS_PVT.InsertExecProcesses(p_txn_hdr_id => l_txn_header_rec_type.transaction_header_id
                                  ,p_org_id             => l_txn_header_rec_type.org_id
                                  ,p_supp_trd_prfl_id      => l_supp_trade_profile_id
                                  ,x_msg_count          => x_msg_count
                                  ,x_msg_data           => x_msg_data
                                  ,x_return_status      => l_return_status
                                          );
		   DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Insert Execution Processes Status : ' || l_return_status);
                IF DPP_DEBUG_HIGH_ON THEN
                   fnd_file.put_line(fnd_file.log,   'Populate Execution Processes based on Supplier Trade Profile or System Parameters Status : ' || l_return_status || 'Error Msg ' || x_msg_data);
                END IF;
                IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                  l_concatenated_error_message := l_concatenated_error_message || x_msg_data;
                  ROLLBACK TO DPP_Insert_Transaction;
                  Update_InterfaceErrSts(
                                      p_txn_header_rec_type => l_txn_header_rec_type
                                      ,x_return_status  =>  l_return_status
                                      );
                  RAISE Fnd_Api.g_exc_error;
                END IF;
                --End Populate Execution Processes based on Supplier Trade Profile or System Parameters

            --The Transaction is an Approval response
            ELSE
            IF l_transaction_status IS NULL OR l_transaction_status <> 'APPROVED' THEN
                    fnd_message.set_name('DPP',   'DPP_TXN_NOT_EXISTS');
                    x_msg_data := fnd_message.get();
                    l_txn_header_rec_type.error_code := 'DPP_TXN_NOT_EXISTS';
                     l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                    Update_InterfaceErrSts(
                                      p_txn_header_rec_type => l_txn_header_rec_type
                                      ,x_return_status =>l_return_status
                                      );
                        --RAISE Fnd_Api.g_exc_error;
            END IF;
            --Validate Supplier approved date,claim Number
            IF l_txn_header_rec_type.supplier_approval_date IS NULL
            THEN
             fnd_message.set_name('DPP',   'DPP_APP_DETAILS_NOT_EXISTS');
                    fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
                    fnd_message.set_token('SUPPLIER_SITE',  l_txn_header_rec_type.vendor_site_code);
                    fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
                    x_msg_data := fnd_message.get();
                    l_txn_header_rec_type.error_code := 'DPP_APP_DETAILS_NOT_EXISTS';
                     l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                    Update_InterfaceErrSts(
                                      p_txn_header_rec_type => l_txn_header_rec_type
                                      ,x_return_status =>l_return_status
                                      );
                      --  RAISE Fnd_Api.g_exc_error;
            END IF;
             IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Inbound Approval Transaction');
              END IF;
             IF l_concatenated_error_message IS NOT NULL THEN
                    x_msg_data:= l_concatenated_error_message;
                    RAISE Fnd_Api.g_exc_error;
             END IF;
                --Get the lines in a tbl type
                form_line_tbl(
                        p_txn_header_rec_type => l_txn_header_rec_type
                        ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,x_return_status => l_return_status
                        );
                IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Form Line Tbl Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                END IF;
                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                       l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
                        --RAISE Fnd_Api.g_exc_error;
                   END IF;
                Validate_SupplierPartNum(
                      p_txn_header_rec_type =>l_txn_header_rec_type
                      ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,x_return_status => l_return_status
                      );
                  IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Validate SupplierPartNum Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                  END IF;

            IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                    IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Invalid Supplier part number/Item Number/Inventory Item Id.Status:'||l_return_status ||'Error Msg'||x_msg_data);
                    END IF;
                       l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
                        RAISE Fnd_Api.g_exc_error;
                   END IF;

                --Call procedure to update approval details
                Update_Approval(
                       p_txn_header_rec_type =>l_txn_header_rec_type
                      ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,x_return_status => l_return_status
                          );
                IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Update Approval Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                END IF;
                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                       l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceLineErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type,
                                  p_txn_lines_tbl_type => l_txn_lines_tbl_type
                                  ,x_return_status =>l_return_status
                                  );
                        --RAISE Fnd_Api.g_exc_error;
                   END IF;

                   IF  l_concatenated_error_message IS NOT NULL THEN
                   Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                   RAISE Fnd_Api.g_exc_error;
                   END IF;

                --call header history API for log
                IF l_log_enabled = 'Y' THEN
                  Update_HeaderLog(p_txn_header_rec_type => l_txn_header_rec_type
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data
                                ,x_return_status => l_return_status
                                                    );
                  IF DPP_DEBUG_HIGH_ON THEN
                         fnd_file.put_line(fnd_file.log,   'Update Header Log Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                  END IF;
                  IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                    --RAISE Fnd_Api.g_exc_error;
                    l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                  END IF;
                --Call history log for lines
                    Update_LinesLog(
                        p_txn_lines_tbl_type => l_txn_lines_tbl_type
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,x_return_status => l_return_status
                        );
                IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Update Lines Log Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                END IF;
                  IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                    l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                    --RAISE Fnd_Api.g_exc_error;
                    END IF;

                END IF;
               IF  l_concatenated_error_message IS NOT NULL THEN
               Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                   RAISE Fnd_Api.g_exc_error;
                   END IF;
                --Call procedure to update the supplier approved by flag in claims table

                Update_ClaimsApproval  (
                      p_txn_header_rec_type =>l_txn_header_rec_type
                     ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                     ,x_msg_count     => x_msg_count
                     ,x_msg_data      => x_msg_data
                     ,x_return_status => l_return_status
                      );
                IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Update Claims Approval Return Status:'||l_return_status ||'Error Msg'||x_msg_data);
                END IF;
                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                      l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                        --RAISE Fnd_Api.g_exc_error;
                   END IF;
                    fnd_message.set_name('DPP',   'DPP_TRANSACTION_APPROVED');
                    fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
                    fnd_message.set_token('SUPPLIER_SITE',  l_txn_header_rec_type.vendor_site_code);
                    fnd_message.set_token('OPERATING_UNIT',  l_txn_header_rec_type.operating_unit_name);
                    fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
                    x_msg_data := fnd_message.get();
                  fnd_file.put_line(fnd_file.log,   x_msg_data);
            END IF; --l_transaction_type = 'INB'
               --Call procedure to update interface tables (header )
                Update_InterfaceTbl  (
                    p_txn_header_rec_type =>l_txn_header_rec_type
                    ,p_txn_lines_tbl_type => l_txn_lines_tbl_type
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data  =>x_msg_data
                    ,x_return_status => l_return_status
                    );
                IF DPP_DEBUG_HIGH_ON THEN
                       fnd_file.put_line(fnd_file.log,   'Update Interface Table Return Status: '||l_return_status ||'Error Msg '||x_msg_data);
                END IF;
                    IF l_return_status =  Fnd_Api.g_ret_sts_error OR l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
                    l_concatenated_error_message :=l_concatenated_error_message|| x_msg_data;
                      ROLLBACK TO DPP_Insert_Transaction;
                      Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                        --RAISE Fnd_Api.g_exc_error;
                   END IF;
                   IF l_concatenated_error_message IS NOT NULL THEN
                         Update_InterfaceErrSts(
                                  p_txn_header_rec_type => l_txn_header_rec_type
                                  ,x_return_status =>l_return_status
                                  );
                      RAISE Fnd_Api.g_exc_error;
                END IF;
        END LOOP;  --End of loop FOR fetch_header_rec IN fetch_header_cur
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
             x_return_status := Fnd_Api.g_ret_sts_error ;
             fnd_message.set_name('DPP',   'DPP_TRANSACTION_ERROR');
             fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
             fnd_message.set_token('SUPPLIER_ID',  l_txn_header_rec_type.vendor_id);
             fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
             l_msg_data := fnd_message.get();
             x_msg_data := l_msg_data || l_concatenated_error_message;
             DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP G_EXC_ERROR x_msg_data');
             DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Status '||x_return_status|| ' Message '||x_msg_data);


        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            fnd_message.set_name('DPP',   'DPP_TRANSACTION_ERROR');
             fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
             fnd_message.set_token('SUPPLIER_ID',  l_txn_header_rec_type.vendor_id);
             fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
             x_msg_data := fnd_message.get();
             x_msg_data:= x_msg_data ||l_concatenated_error_message;
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
           DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP G_EXC_UNEXPECTED_ERROR Transaction Int header id '||l_txn_header_rec_type.transaction_int_header_id);

        WHEN OTHERS THEN
            fnd_message.set_name('DPP',   'DPP_TRANSACTION_ERROR');
             fnd_message.set_token('SUPPLIER_NAME',  l_txn_header_rec_type.vendor_name);
             fnd_message.set_token('SUPPLIER_ID',  l_txn_header_rec_type.vendor_id);
             fnd_message.set_token('DOC_REF_NO',  l_txn_header_rec_type.ref_document_number);
             x_msg_data := fnd_message.get();
             DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Error:' ||x_msg_data);
             x_msg_data := x_msg_data || l_concatenated_error_message;
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Error after assignment:' ||x_msg_data);
            IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;
    END insert_transaction;

    PROCEDURE Create_IntHeader(
                    p_txn_header_rec_type IN OUT nocopy txn_header_rec,
                    x_rec_count OUT nocopy NUMBER,
                    x_return_status OUT nocopy VARCHAR2)

    AS
        l_api_name constant     VARCHAR2(30) := 'Create_IntHeader';
        l_api_version constant  NUMBER := 1.0;
        l_full_name constant    VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status     VARCHAR2(30);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(4000);

        l_init_msg_list     VARCHAR2(30) := fnd_api.g_false;
        l_commit            VARCHAR2(30) := fnd_api.g_false;
        l_validation_level  NUMBER := fnd_api.g_valid_level_full;
        l_transaction_int_header_id NUMBER;

    BEGIN
        p_txn_header_rec_type.transaction_source := 'WEBADI';
        --  Checks for the doc reference number for same vendor id in header table*/
        BEGIN
            SELECT transaction_int_header_id
            INTO l_transaction_int_header_id
            FROM dpp_txn_headers_int_all dtha
            WHERE dtha.ref_document_number = p_txn_header_rec_type.ref_document_number
            AND dtha.vendor_name = p_txn_header_rec_type.vendor_name
            AND dtha.vendor_site =  p_txn_header_rec_type.vendor_site_code
            AND dtha.interface_status = 'N';

            EXCEPTION
                WHEN no_data_found THEN
                    l_transaction_int_header_id := NULL;
        END;

        IF l_transaction_int_header_id IS NULL THEN
            SELECT dpp_trans_int_hdr_id_seq.nextval
            INTO p_txn_header_rec_type.transaction_int_header_id
            FROM dual;

            INSERT INTO dpp_txn_headers_int_all
                (transaction_int_header_id,
                 ref_document_number,
                 effective_start_date,
                 days_covered,
                 org_id,
                 operating_unit_name,
                 vendor_name,
                 vendor_id,
                 vendor_site,
                 vendor_site_id,
                 vendor_contact_name,
                 contact_email_address,
                 contact_phone,
                 currency,
                 supp_dist_claim_id,
                 supp_dist_claim_number,
                 supplier_approved_by,
                 supplier_approval_date,
                 transaction_source,
                 interface_status,
                 error_code,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 attribute21,
                 attribute22,
                 attribute23,
                 attribute24,
                 attribute25,
                 attribute26,
                 attribute27,
                 attribute28,
                 attribute29,
                 attribute30)
            VALUES(
                p_txn_header_rec_type.transaction_int_header_id,
                p_txn_header_rec_type.ref_document_number,
                p_txn_header_rec_type.effective_start_date,
                p_txn_header_rec_type.days_covered,
                NULL,
                p_txn_header_rec_type.operating_unit_name,
                p_txn_header_rec_type.vendor_name,
                NULL,
                p_txn_header_rec_type.vendor_site_code,
                NULL,
                p_txn_header_rec_type.vendor_contact_name,
                p_txn_header_rec_type.contact_email_address,
                p_txn_header_rec_type.contact_phone,
                p_txn_header_rec_type.trx_currency,
                NULL,
                p_txn_header_rec_type.SUPP_DIST_CLAIM_NUMBER,
                p_txn_header_rec_type.supplier_approved_by,
                p_txn_header_rec_type.supplier_approval_date,
                p_txn_header_rec_type.transaction_source,
                'N',
                NULL,
                sysdate,
                FND_GLOBAL.User_Id ,
                sysdate,
                FND_GLOBAL.User_Id ,
                FND_GLOBAL.User_Id ,
                0,
                0,
                0,
                sysdate,
                p_txn_header_rec_type.attribute_category,
                p_txn_header_rec_type.attribute1,
                p_txn_header_rec_type.attribute2,
                p_txn_header_rec_type.attribute3,
                p_txn_header_rec_type.attribute4,
                p_txn_header_rec_type.attribute5,
                p_txn_header_rec_type.attribute6,
                p_txn_header_rec_type.attribute7,
                p_txn_header_rec_type.attribute8,
                p_txn_header_rec_type.attribute9,
                p_txn_header_rec_type.attribute10,
                p_txn_header_rec_type.attribute11,
                p_txn_header_rec_type.attribute12,
                p_txn_header_rec_type.attribute13,
                p_txn_header_rec_type.attribute14,
                p_txn_header_rec_type.attribute15,
                p_txn_header_rec_type.attribute16,
                p_txn_header_rec_type.attribute17,
                p_txn_header_rec_type.attribute18,
                p_txn_header_rec_type.attribute19,
                p_txn_header_rec_type.attribute20,
                p_txn_header_rec_type.attribute21,
                p_txn_header_rec_type.attribute22,
                p_txn_header_rec_type.attribute23,
                p_txn_header_rec_type.attribute24,
                p_txn_header_rec_type.attribute25,
                p_txn_header_rec_type.attribute26,
                p_txn_header_rec_type.attribute27,
                p_txn_header_rec_type.attribute28,
                p_txn_header_rec_type.attribute29,
                p_txn_header_rec_type.attribute30);

        ELSE

            UPDATE dpp_txn_headers_int_all
                SET
                ref_document_number = p_txn_header_rec_type.ref_document_number,
                effective_start_date = p_txn_header_rec_type.effective_start_date,
                days_covered = p_txn_header_rec_type.days_covered,
                vendor_name = p_txn_header_rec_type.vendor_name,
                vendor_site = p_txn_header_rec_type.vendor_site_code,
                VENDOR_CONTACT_NAME=p_txn_header_rec_type.VENDOR_CONTACT_NAME,
                contact_email_address = p_txn_header_rec_type.contact_email_address,
                contact_phone = p_txn_header_rec_type.contact_phone,
                attribute1 = p_txn_header_rec_type.attribute1,
                attribute2 = p_txn_header_rec_type.attribute2,
                attribute3 = p_txn_header_rec_type.attribute3,
                attribute4 = p_txn_header_rec_type.attribute4,
                attribute5 = p_txn_header_rec_type.attribute5,
                attribute6 = p_txn_header_rec_type.attribute6,
                attribute7 = p_txn_header_rec_type.attribute7,
                attribute8 = p_txn_header_rec_type.attribute8,
                attribute9 = p_txn_header_rec_type.attribute9,
                attribute10 = p_txn_header_rec_type.attribute10,
                attribute11 = p_txn_header_rec_type.attribute11,
                attribute12 = p_txn_header_rec_type.attribute12,
                attribute13 = p_txn_header_rec_type.attribute13,
                attribute14 = p_txn_header_rec_type.attribute14,
                attribute15 = p_txn_header_rec_type.attribute15,
                attribute16 = p_txn_header_rec_type.attribute16,
                attribute17 = p_txn_header_rec_type.attribute17,
                attribute18 = p_txn_header_rec_type.attribute18,
                attribute19 = p_txn_header_rec_type.attribute19,
                attribute20 = p_txn_header_rec_type.attribute20,
                attribute21 = p_txn_header_rec_type.attribute21,
                attribute22 = p_txn_header_rec_type.attribute22,
                attribute23 = p_txn_header_rec_type.attribute23,
                attribute24 = p_txn_header_rec_type.attribute24,
                attribute25 = p_txn_header_rec_type.attribute25,
                attribute26 = p_txn_header_rec_type.attribute26,
                attribute27 = p_txn_header_rec_type.attribute27,
                attribute28 = p_txn_header_rec_type.attribute28,
                attribute29 = p_txn_header_rec_type.attribute29,
                attribute30 = p_txn_header_rec_type.attribute30
            WHERE transaction_int_header_id = l_transaction_int_header_id;

          --Assign transaction int header id value for updated header and for insert/update lines
          p_txn_header_rec_type.transaction_int_header_id := l_transaction_int_header_id;
        END IF;



    EXCEPTION
            WHEN others THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                    fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                    fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                    fnd_message.set_token('ERRNO',   SQLCODE);
                    fnd_message.set_token('REASON',   sqlerrm);
                END IF;

    END Create_IntHeader;

    PROCEDURE Create_IntLines(
                 p_transaction_lines_rec IN OUT nocopy txn_lines_rec,
                 x_msg_count OUT nocopy NUMBER,
                 x_return_status OUT nocopy VARCHAR2)
    AS
        l_api_name constant VARCHAR2(20) := 'Create_IntLines';
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');
        create_IntLines_exception EXCEPTION;
        l_error_message VARCHAR2(4000);
        x_msg_data VARCHAR2(4000);

    BEGIN
            SELECT dpp_trans_int_line_id_seq.nextval
                INTO p_transaction_lines_rec.transaction_int_line_id
            FROM dual;


            INSERT INTO dpp_txn_lines_int_all(
                    transaction_int_header_id,
                    transaction_int_line_id,
                    supplier_part_num,
                    inventory_item_id,
                    item_number,
                    change_type,
                    change_value,
                    covered_inventory,
                    approved_inventory,
                    uom,
                    claim_amount,
                    org_id,
                    interface_status,
                    error_code,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    attribute_category,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    attribute16,
                    attribute17,
                    attribute18,
                    attribute19,
                    attribute20,
                    attribute21,
                    attribute22,
                    attribute23,
                    attribute24,
                    attribute25,
                    attribute26,
                    attribute27,
                    attribute28,
                    attribute29,
                    attribute30)
            VALUES(
                    p_transaction_lines_rec.transaction_int_header_id,
                    p_transaction_lines_rec.transaction_int_line_id,
                    p_transaction_lines_rec.supplier_part_num,
                    null,
                    p_transaction_lines_rec.item_number,
                    p_transaction_lines_rec.change_type,
                    p_transaction_lines_rec.change_value,
                    p_transaction_lines_rec.covered_inventory,
                    p_transaction_lines_rec.approved_inventory,
                    p_transaction_lines_rec.uom,
                    NULL,
                    NULL,
                    'N',
                    NULL,
                    sysdate,
                    FND_GLOBAL.User_Id ,
                    sysdate,
                    FND_GLOBAL.User_Id ,
                    FND_GLOBAL.User_Id ,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    p_transaction_lines_rec.attribute_category,
                    p_transaction_lines_rec.attribute1,
                    p_transaction_lines_rec.attribute2,
                    p_transaction_lines_rec.attribute3,
                    p_transaction_lines_rec.attribute4,
                    p_transaction_lines_rec.attribute5,
                    p_transaction_lines_rec.attribute6,
                    p_transaction_lines_rec.attribute7,
                    p_transaction_lines_rec.attribute8,
                    p_transaction_lines_rec.attribute9,
                    p_transaction_lines_rec.attribute10,
                    p_transaction_lines_rec.attribute11,
                    p_transaction_lines_rec.attribute12,
                    p_transaction_lines_rec.attribute13,
                    p_transaction_lines_rec.attribute14,
                    p_transaction_lines_rec.attribute15,
                    p_transaction_lines_rec.attribute16,
                    p_transaction_lines_rec.attribute17,
                    p_transaction_lines_rec.attribute18,
                    p_transaction_lines_rec.attribute19,
                    p_transaction_lines_rec.attribute20,
                    p_transaction_lines_rec.attribute21,
                    p_transaction_lines_rec.attribute22,
                    p_transaction_lines_rec.attribute23,
                    p_transaction_lines_rec.attribute24,
                    p_transaction_lines_rec.attribute25,
                    p_transaction_lines_rec.attribute26,
                    p_transaction_lines_rec.attribute27,
                    p_transaction_lines_rec.attribute28,
                    p_transaction_lines_rec.attribute29,
                    p_transaction_lines_rec.attribute30);


    EXCEPTION
        WHEN create_IntLines_exception THEN
          x_return_status :=  fnd_api.g_ret_sts_error;
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Create IntLines l_error_message:'||l_error_message || 'sqlerrm'||sqlerrm);
        WHEN others THEN
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'Create IntLines : SQLERRM:'||SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
                fnd_message.set_token('ROUTINE',   'DPP_TRANSACTION_PVT');
                fnd_message.set_token('ERRNO',   SQLCODE);
                fnd_message.set_token('REASON',   sqlerrm);
            END IF;
            x_msg_data := fnd_message.get();
    END Create_IntLines;


    PROCEDURE inbound_transaction(
        p_distributor_operating_unit   IN VARCHAR2,
        p_document_reference           IN VARCHAR2,
        p_supplier_name                IN VARCHAR2,
        p_supplier_site                IN VARCHAR2,
        p_supplier_contact             IN VARCHAR2,
        p_supplier_contact_phone       IN VARCHAR2,
        p_supplier_contact_email       IN VARCHAR2,
        p_effective_date               IN DATE,
        p_days_covered                 IN NUMBER,
        p_currency                     IN VARCHAR2,
        p_hdrattributecontext          IN VARCHAR2,
        p_hdrattribute1                IN VARCHAR2,
        p_hdrattribute2                IN VARCHAR2,
        p_hdrattribute3                IN VARCHAR2,
        p_hdrattribute4                IN VARCHAR2,
        p_hdrattribute5                IN VARCHAR2,
        p_hdrattribute6                IN VARCHAR2,
        p_hdrattribute7                IN VARCHAR2,
        p_hdrattribute8                IN VARCHAR2,
        p_hdrattribute9                IN VARCHAR2,
        p_hdrattribute10               IN VARCHAR2,
        p_hdrattribute11               IN VARCHAR2,
        p_hdrattribute12               IN VARCHAR2,
        p_hdrattribute13               IN VARCHAR2,
        p_hdrattribute14               IN VARCHAR2,
        p_hdrattribute15               IN VARCHAR2,
        p_hdrattribute16               IN VARCHAR2,
        p_hdrattribute17               IN VARCHAR2,
        p_hdrattribute18               IN VARCHAR2,
        p_hdrattribute19               IN VARCHAR2,
        p_hdrattribute20               IN VARCHAR2,
        p_hdrattribute21               IN VARCHAR2,
        p_hdrattribute22               IN VARCHAR2,
        p_hdrattribute23               IN VARCHAR2,
        p_hdrattribute24               IN VARCHAR2,
        p_hdrattribute25               IN VARCHAR2,
        p_hdrattribute26               IN VARCHAR2,
        p_hdrattribute27               IN VARCHAR2,
        p_hdrattribute28               IN VARCHAR2,
        p_hdrattribute29               IN VARCHAR2,
        p_hdrattribute30               IN VARCHAR2,
        p_supplier_part_num            IN VARCHAR2,
        p_item_number                  IN VARCHAR2,
        --p_prior_price                  IN NUMBER,
        p_change_type                  IN VARCHAR2,
        p_change_value                 IN NUMBER,
        p_uom                          IN VARCHAR2,
        p_dtlattributecontext          IN VARCHAR2,
        p_dtlattribute1                IN VARCHAR2,
        p_dtlattribute2                IN VARCHAR2,
        p_dtlattribute3                IN VARCHAR2,
        p_dtlattribute4                IN VARCHAR2,
        p_dtlattribute5                IN VARCHAR2,
        p_dtlattribute6                IN VARCHAR2,
        p_dtlattribute7                IN VARCHAR2,
        p_dtlattribute8                IN VARCHAR2,
        p_dtlattribute9                IN VARCHAR2,
        p_dtlattribute10               IN VARCHAR2,
        p_dtlattribute11               IN VARCHAR2,
        p_dtlattribute12               IN VARCHAR2,
        p_dtlattribute13               IN VARCHAR2,
        p_dtlattribute14               IN VARCHAR2,
        p_dtlattribute15               IN VARCHAR2,
        p_dtlattribute16               IN VARCHAR2,
        p_dtlattribute17               IN VARCHAR2,
        p_dtlattribute18               IN VARCHAR2,
        p_dtlattribute19               IN VARCHAR2,
        p_dtlattribute20               IN VARCHAR2,
        p_dtlattribute21               IN VARCHAR2,
        p_dtlattribute22               IN VARCHAR2,
        p_dtlattribute23               IN VARCHAR2,
        p_dtlattribute24               IN VARCHAR2,
        p_dtlattribute25               IN VARCHAR2,
        p_dtlattribute26               IN VARCHAR2,
        p_dtlattribute27               IN VARCHAR2,
        p_dtlattribute28               IN VARCHAR2,
        p_dtlattribute29               IN VARCHAR2,
        p_dtlattribute30               IN VARCHAR2
    )  AS

        l_api_name    constant    VARCHAR2(30) := 'DPP_TRANSACTION_PVT';
        l_api_version constant    NUMBER := 1.0;
        l_full_name   constant    VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        --l_commit                  VARCHAR2(30) := fnd_api.g_true;
        l_return_status           VARCHAR2(30);
        l_msg_count               NUMBER;
        l_msg_data                VARCHAR2(4000);

        l_transaction_header_rec  txn_header_rec;
        l_transaction_lines_rec   txn_lines_rec;
        l_error_message           VARCHAR2(4000);
        l_message                 VARCHAR2(4000) := NULL;

        l_transaction_int_header_id   NUMBER;
        l_transaction_int_line_id     NUMBER;
        l_transaction_line_id         NUMBER;

        dpp_webadi_error          EXCEPTION;
        l_source                  VARCHAR2(10) := 'WEBADI';

    BEGIN

        SAVEPOINT inbound_transaction;


        --l_return_status := fnd_api.g_ret_sts_success;


        IF p_distributor_operating_unit IS NULL THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP Entered OU in webadi api');
            fnd_message.set_name('DPP', 'DPP_OPERATING_UNIT_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --RAISE DPP_WEBADI_ERROR;
            --raise_application_error( -20000, l_error_message);
        END IF;

        IF p_document_reference IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_DOC_REF_NUM_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;

         IF LENGTH(p_document_reference) > 40 THEN
            fnd_message.set_name('DPP', 'DPP_DOC_REF_NUM');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;


        IF p_supplier_name IS NULL THEN
            fnd_message.set_name ('DPP', 'DPP_SUPPLIER_NAME_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
           -- RAISE DPP_WEBADI_ERROR;
        END IF;

        IF p_supplier_site IS NULL THEN
          fnd_message.set_name('DPP', 'DPP_SUPPLIER_SITE_NULL');
          l_error_message :=  fnd_message.get();
          l_message := l_message || l_error_message;
          --raise_application_error( -20000, l_error_message);
          --RAISE DPP_WEBADI_ERROR;
        END IF;

        IF p_effective_date IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_EFFECTIVE_DATE_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;

        IF p_currency IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_CURRENCY_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;
        IF p_days_covered <0 OR p_days_covered > 9999 OR p_days_covered <> ROUND(p_days_covered) THEN
            l_error_message :=  'Invalid days covered value.Please enter a valid value.';
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;
        -- Line Level Mandatory Field Validation

        IF (p_supplier_part_num IS NULL and p_item_number IS NULL) THEN
            -- TBD: change the DPP_VENDOR_PART_NUM_NULL attribute text to reflect the either or validation
            fnd_message.set_name('DPP', 'DPP_SUPPLIER_PART_NUM_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;

        IF p_change_type IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_CHANGE_TYPE_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;

        IF p_change_value IS NULL OR p_change_value <= 0 THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP Entered VALUE');
            fnd_message.set_name('DPP', 'DPP_CHANGE_VALUE_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;

        IF l_message IS NOT NULL THEN
         RAISE DPP_WEBADI_ERROR;
         END IF;

        --Assign to rec type l_transaction_header_rec
        l_transaction_header_rec.operating_unit_name := p_distributor_operating_unit;
        l_transaction_header_rec.ref_document_number := p_document_reference;
        l_transaction_header_rec.vendor_name := p_supplier_name;
        l_transaction_header_rec.vendor_site_code := p_supplier_site;
        l_transaction_header_rec.vendor_contact_name := p_supplier_contact;
        l_transaction_header_rec.contact_phone := p_supplier_contact_phone;
        l_transaction_header_rec.contact_email_address := p_supplier_contact_email;
        l_transaction_header_rec.effective_start_date := p_effective_date;
        l_transaction_header_rec.days_covered := p_days_covered;
        l_transaction_header_rec.trx_currency := p_currency;
        l_transaction_header_rec.transaction_source := l_source;
        l_transaction_header_rec.attribute_category := p_hdrattributecontext;
        l_transaction_header_rec.attribute1 := p_hdrattribute1;
        l_transaction_header_rec.attribute2 := p_hdrattribute2;
        l_transaction_header_rec.attribute3 := p_hdrattribute3;
        l_transaction_header_rec.attribute4 := p_hdrattribute4;
        l_transaction_header_rec.attribute5 := p_hdrattribute5;
        l_transaction_header_rec.attribute6 := p_hdrattribute6;
        l_transaction_header_rec.attribute7 := p_hdrattribute7;
        l_transaction_header_rec.attribute8 := p_hdrattribute8;
        l_transaction_header_rec.attribute9 := p_hdrattribute9;
        l_transaction_header_rec.attribute10 := p_hdrattribute10;
        l_transaction_header_rec.attribute11 := p_hdrattribute11;
        l_transaction_header_rec.attribute12 := p_hdrattribute12;
        l_transaction_header_rec.attribute13 := p_hdrattribute13;
        l_transaction_header_rec.attribute14 := p_hdrattribute14;
        l_transaction_header_rec.attribute15 := p_hdrattribute15;
        l_transaction_header_rec.attribute16 := p_hdrattribute16;
        l_transaction_header_rec.attribute17 := p_hdrattribute17;
        l_transaction_header_rec.attribute18 := p_hdrattribute18;
        l_transaction_header_rec.attribute19 := p_hdrattribute19;
        l_transaction_header_rec.attribute20 := p_hdrattribute20;
        l_transaction_header_rec.attribute21 := p_hdrattribute21;
        l_transaction_header_rec.attribute22 := p_hdrattribute22;
        l_transaction_header_rec.attribute23 := p_hdrattribute23;
        l_transaction_header_rec.attribute24 := p_hdrattribute24;
        l_transaction_header_rec.attribute25 := p_hdrattribute25;
        l_transaction_header_rec.attribute26 := p_hdrattribute26;
        l_transaction_header_rec.attribute27 := p_hdrattribute27;
        l_transaction_header_rec.attribute28 := p_hdrattribute28;
        l_transaction_header_rec.attribute29 := p_hdrattribute29;
        l_transaction_header_rec.attribute30 := p_hdrattribute30;

        --Assign to rec type l_transaction_header_rec
    DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP Lines Assignment');
        l_transaction_lines_rec.SUPPLIER_PART_NUM := p_supplier_part_num;
        l_transaction_lines_rec.ITEM_NUMBER := P_ITEM_NUMBER;
        l_transaction_lines_rec.CHANGE_TYPE := P_CHANGE_TYPE;
        l_transaction_lines_rec.CHANGE_VALUE := P_CHANGE_VALUE;
        l_transaction_lines_rec.UOM := P_UOM;
        l_transaction_lines_rec.attribute_category := p_dtlattributecontext;
        l_transaction_lines_rec.attribute1 := p_dtlattribute1;
        l_transaction_lines_rec.attribute2 := p_dtlattribute2;
        l_transaction_lines_rec.attribute3 := p_dtlattribute3;
        l_transaction_lines_rec.attribute4 := p_dtlattribute4;
        l_transaction_lines_rec.attribute5 := p_dtlattribute5;
        l_transaction_lines_rec.attribute6 := p_dtlattribute6;
        l_transaction_lines_rec.attribute7 := p_dtlattribute7;
        l_transaction_lines_rec.attribute8 := p_dtlattribute8;
        l_transaction_lines_rec.attribute9 := p_dtlattribute9;
        l_transaction_lines_rec.attribute10 := p_dtlattribute10;
        l_transaction_lines_rec.attribute11 := p_dtlattribute11;
        l_transaction_lines_rec.attribute12 := p_dtlattribute12;
        l_transaction_lines_rec.attribute13 := p_dtlattribute13;
        l_transaction_lines_rec.attribute14 := p_dtlattribute14;
        l_transaction_lines_rec.attribute15 := p_dtlattribute15;
        l_transaction_lines_rec.attribute16 := p_dtlattribute16;
        l_transaction_lines_rec.attribute17 := p_dtlattribute17;
        l_transaction_lines_rec.attribute18 := p_dtlattribute18;
        l_transaction_lines_rec.attribute19 := p_dtlattribute19;
        l_transaction_lines_rec.attribute20 := p_dtlattribute20;
        l_transaction_lines_rec.attribute21 := p_dtlattribute21;
        l_transaction_lines_rec.attribute22 := p_dtlattribute22;
        l_transaction_lines_rec.attribute23 := p_dtlattribute23;
        l_transaction_lines_rec.attribute24 := p_dtlattribute24;
        l_transaction_lines_rec.attribute25 := p_dtlattribute25;
        l_transaction_lines_rec.attribute26 := p_dtlattribute26;
        l_transaction_lines_rec.attribute27 := p_dtlattribute27;
        l_transaction_lines_rec.attribute28 := p_dtlattribute28;
        l_transaction_lines_rec.attribute29 := p_dtlattribute29;
        l_transaction_lines_rec.attribute30 := p_dtlattribute30;

        create_intheader(
                        p_txn_header_rec_type   => l_transaction_header_rec,
                        x_rec_count             => l_msg_count,
                        x_return_status         => l_return_status);

        IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --lines
        --Validate the vendor part number
        l_transaction_lines_rec.transaction_int_header_id :=l_transaction_header_rec.transaction_int_header_id;
        l_transaction_lines_rec.org_id :=l_transaction_header_rec.org_id;
        create_intlines(
                        p_transaction_lines_rec => l_transaction_lines_rec,
                        x_msg_count             => l_msg_count,
                        x_return_status         => l_return_status);


        IF l_return_status = fnd_api.g_ret_sts_error THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP SYSTEM ERROR');
            fnd_message.set_name('DPP',   'DPP_DUPLICATE_RECORDS');
            l_error_message := fnd_message.get();
            RAISE dpp_webadi_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP UNEXPECTED ERROR');
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

    EXCEPTION
        WHEN dpp_webadi_error THEN
            ROLLBACK TO inbound_transaction;
            if l_message is NULL then
              l_message :=  fnd_message.get();
            end if;
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP in DPP_webadi_error:'||l_error_message);
            raise_application_error( -20000, l_message);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP IN FND_API.G_EXC_UNEXPECTED_ERROR BLOCK');
            ROLLBACK TO inbound_transaction;
            IF length( SQLERRM) > 30 THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  substr(SQLERRM,12,30));
                fnd_message.set_name ('DPP', substr(SQLERRM,12,30));
            ELSE
                fnd_message.set_name ('DPP', SQLERRM);
            END IF;
            l_error_message :=  fnd_message.get();
            raise_application_error( -20000, l_error_message);
        WHEN OTHERS THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP IN OTHERS BLOCK');
            ROLLBACK TO inbound_transaction;
            IF length( SQLERRM) > 30 THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  substr(SQLERRM,12,30));
                fnd_message.set_name ('DPP', substr(SQLERRM,12,30));
            ELSE
                fnd_message.set_name ('DPP', SQLERRM);
            END IF;
            l_error_message :=  fnd_message.get();
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP l_error_message:'||l_error_message);
            raise_application_error( -20000, l_error_message);
    END inbound_transaction;

    PROCEDURE create_webadi_transaction(p_document_reference_number IN VARCHAR2
                            ,   p_supplier_name IN VARCHAR2
                            ,   p_supplier_site IN VARCHAR2
                            ,   p_operating_unit IN VARCHAR2
                            ,   x_return_status            OUT NOCOPY VARCHAR2
                            ,   x_msg_data                 OUT NOCOPY VARCHAR2
                            )
    AS
        l_api_name constant VARCHAR2(30) := 'create_webadi_transaction';
        l_api_version constant NUMBER := 1.0;
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_return_status VARCHAR2(30);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
        l_user_name VARCHAR2(30);
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');
        l_init_msg_list VARCHAR2(30) := fnd_api.g_false;
        l_commit VARCHAR2(30) := fnd_api.g_false;
        l_validation_level NUMBER := fnd_api.g_valid_level_full;
        l_transaction_int_header_id NUMBER;
        l_ref_document_number VARCHAR2(40);
        dpp_webadi_importer_error   EXCEPTION;
        l_error_message VARCHAR2(4000);

        CURSOR transaction_cur(cv_doc_ref_no VARCHAR2,   cv_supplier_name VARCHAR2, cv_supplier_site VARCHAR2, cv_operating_unit VARCHAR2 )
        IS
            SELECT transaction_int_header_id
            FROM dpp_txn_headers_int_all dthia
            WHERE dthia.ref_document_number = cv_doc_ref_no
            AND dthia.vendor_name = cv_supplier_name
            AND dthia.vendor_site = cv_supplier_site
            AND dthia.interface_status = 'N'
            AND dthia.operating_unit_name = cv_operating_unit;

    BEGIN
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP Start Time :'||sysdate || 'Time ' ||dbms_utility.get_time());
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Start :'||l_api_name);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP Start :'||l_api_name);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP_INBOUND_PVT_BODY name:'||p_supplier_name);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP_INBOUND_PVT_BODY site:'||p_supplier_site);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP_INBOUND_PVT_BODY ref:'||p_document_reference_number);
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP_INBOUND_PVT_BODY unit: '||p_operating_unit);
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        --open cursor
        OPEN transaction_cur(p_document_reference_number,p_supplier_name,p_supplier_site,p_operating_unit);
        FETCH transaction_cur INTO l_transaction_int_header_id;
        CLOSE transaction_cur;

        --call insert transaction procedure


        --dpp_inbound_pvt.Insert_Transaction(
        DPP_TRANSACTION_Pvt.Insert_Transaction(
                    p_api_version       =>l_api_version
                ,   p_init_msg_list =>l_init_msg_list
                ,   p_commit            =>l_commit
                ,   p_validation_level   =>l_validation_level
                ,   p_transaction_int_header_id =>l_transaction_int_header_id
                ,   p_operating_unit     => p_operating_unit
                ,   x_return_status  =>x_return_status
                ,   x_msg_count          =>l_msg_count
                ,   x_msg_data           =>x_msg_data
                ) ;


        IF x_return_status =  Fnd_Api.g_ret_sts_error THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Create WebADI Transaction Fnd_Api.g_ret_sts_error');
            fnd_message.set_name('DPP',   'DPP_WEBADI_IMPORT_ERROR');
            fnd_message.set_token('MESSAGE',   x_msg_data);
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Create WebADI Transaction Fnd_Api.g_ret_sts_unexp_error');
            fnd_message.set_name('DPP', 'DPP_WEBADI_IMPORT_ERROR');
            fnd_message.set_token('MESSAGE',   x_msg_data);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP ***----*** EXCEPTION G_EXC_ERROR:');
            x_return_status := Fnd_Api.g_ret_sts_error;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP ************EXCEPTION G_EXC_UNEXPECTED_ERROR'||x_msg_data);
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
        WHEN OTHERS THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP EXCEPTION OTHERS'||SQLERRM);
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            --ROLLBACK TO dpp_create_webadi_transaction;
            IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;
    END create_webadi_transaction;

    PROCEDURE Raise_OutBoundEvent(
            p_api_version       IN      NUMBER
           ,p_init_msg_list     IN      VARCHAR2     := FND_API.G_FALSE
           ,p_commit            IN      VARCHAR2     := FND_API.G_FALSE
           ,p_validation_level  IN      NUMBER       := FND_API.G_VALID_LEVEL_FULL
           ,p_party_id      IN      VARCHAR2
           ,p_party_site_id     IN      VARCHAR2
           ,p_claim_id          IN      VARCHAR2
           ,p_party_type        IN      VARCHAR2
           ,x_return_status         OUT NOCOPY  VARCHAR2
           ,x_msg_count         OUT NOCOPY  NUMBER
           ,x_msg_data          OUT NOCOPY  VARCHAR2
         )
     AS
        /****************************************************************
        Hardcoded values from Outbound Transaction
        Map Code              'DPPAPPRO'
        Transaction Tyoe      'DPP'
        Transaction Sub Type  'APRO'
        Event Name            'oracle.apps.dpp.preapp.Outbound'
        ******************************************************************/
        l_api_name    constant          VARCHAR2(30) := 'Raise_OutBoundEvent';
        l_full_name   constant          VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_map_code VARCHAR2(55) := 'DPP_APPROVAL_TXN_OUT';
        l_transaction_type VARCHAR2(55) := 'DPP';
        l_transaction_sub_type VARCHAR2(55) := 'APRO';
        l_event_name VARCHAR2(100) := 'oracle.apps.dpp.preapp.Outbound';

        l_debug_mode NUMBER :=3;
        l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
        l_event_test            VARCHAR2(10);
        evtkey VARCHAR2(100);
        count_def NUMBER;
    BEGIN
        SAVEPOINT DPP_Raise_OutBoundEvent;
        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;
        evtkey := dbms_utility.get_time();
        DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Event Key = ' || evtkey);
        l_event_test := wf_event.test(l_event_name);
        IF l_event_test = 'NONE' THEN
            fnd_message.set_name('DPP',   'DPP_EVENT_SUBS_ERR');
            fnd_message.set_token('CLAIM_NUMBER',  p_claim_id);
            x_msg_data := fnd_message.get();
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'No enabled local subscriptions reference the event, or the event does not exist.');
            RAISE FND_API.g_exc_error;
        END IF;
        -- DEFINE IN WF ATTRIBUTES
        wf_event.addparametertolist(p_name => 'ECX_MAP_CODE',   p_value => l_map_code,   p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name => 'ECX_TRANSACTION_TYPE',   p_value => l_transaction_type,   p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name => 'ECX_PARTY_TYPE',   p_value => p_party_type,   p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name => 'ECX_TRANSACTION_SUBTYPE',   p_value => l_transaction_sub_type,   p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name => 'ECX_PARTY_ID',   p_value => p_party_id,   p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name => 'ECX_PARTY_SITE_ID',   p_value => p_party_site_id,   p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name => 'ECX_DOCUMENT_ID',   p_value => p_claim_id,   p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name => 'ECX_DEBUG_LEVEL',   p_value => l_debug_mode,   p_parameterlist => l_parameter_list);
        wf_event.RAISE(l_event_name,   evtkey,   NULL,   l_parameter_list,   sysdate);

        COMMIT;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_error ;
            ROLLBACK TO DPP_Raise_OutBoundEvent;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error ;
            ROLLBACK TO DPP_Raise_OutBoundEvent;
            Fnd_Msg_Pub.Count_AND_Get
                ( p_count      =>      x_msg_count,
                p_data       =>      x_msg_data,
                p_encoded    =>      Fnd_Api.G_FALSE
                );
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_message.set_name('FND',   'SQL_PLSQL_ERROR');
            fnd_message.set_token('ROUTINE',   l_full_name);
            fnd_message.set_token('ERRNO',   SQLCODE);
            fnd_message.set_token('REASON',   sqlerrm);
        END IF;
            ROLLBACK TO DPP_Raise_OutBoundEvent;
            IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_AND_Get
                ( p_count      =>      x_msg_count,
                p_data       =>      x_msg_data,
                p_encoded    =>      Fnd_Api.G_FALSE
                );
    END Raise_OutBoundEvent;

     PROCEDURE inbound_approval(
                    p_distributor_operating_unit   IN VARCHAR2,
                    p_document_reference           IN VARCHAR2,
                    p_supplier_name                IN VARCHAR2,
                    p_supplier_site                IN VARCHAR2,
                    p_supplier_contact             IN VARCHAR2,
                    p_supplier_contact_phone       IN VARCHAR2,
                    p_supplier_contact_email       IN VARCHAR2,
                    p_effective_date               IN DATE,
                    p_days_covered                 IN NUMBER,
                    p_currency                     IN VARCHAR2,
                    p_supplier_approved_by         IN VARCHAR2,
                    p_supplier_approval_date       IN DATE,
                    p_supp_dist_claim_number       IN VARCHAR2,
                    p_hdrattributecontext          IN VARCHAR2,
                    p_hdrattribute1                IN VARCHAR2,
                    p_hdrattribute2                IN VARCHAR2,
                    p_hdrattribute3                IN VARCHAR2,
                    p_hdrattribute4                IN VARCHAR2,
                    p_hdrattribute5                IN VARCHAR2,
                    p_hdrattribute6                IN VARCHAR2,
                    p_hdrattribute7                IN VARCHAR2,
                    p_hdrattribute8                IN VARCHAR2,
                    p_hdrattribute9                IN VARCHAR2,
                    p_hdrattribute10               IN VARCHAR2,
                    p_hdrattribute11               IN VARCHAR2,
                    p_hdrattribute12               IN VARCHAR2,
                    p_hdrattribute13               IN VARCHAR2,
                    p_hdrattribute14               IN VARCHAR2,
                    p_hdrattribute15               IN VARCHAR2,
                    p_hdrattribute16               IN VARCHAR2,
                    p_hdrattribute17               IN VARCHAR2,
                    p_hdrattribute18               IN VARCHAR2,
                    p_hdrattribute19               IN VARCHAR2,
                    p_hdrattribute20               IN VARCHAR2,
                    p_hdrattribute21               IN VARCHAR2,
                    p_hdrattribute22               IN VARCHAR2,
                    p_hdrattribute23               IN VARCHAR2,
                    p_hdrattribute24               IN VARCHAR2,
                    p_hdrattribute25               IN VARCHAR2,
                    p_hdrattribute26               IN VARCHAR2,
                    p_hdrattribute27               IN VARCHAR2,
                    p_hdrattribute28               IN VARCHAR2,
                    p_hdrattribute29               IN VARCHAR2,
                    p_hdrattribute30               IN VARCHAR2,
                    p_supplier_part_num            IN VARCHAR2,
                    p_item_number                  IN VARCHAR2,
                    p_change_type                  IN VARCHAR2,
                    p_change_value                 IN NUMBER,
                    p_uom                          IN VARCHAR2,
                    p_approved_inventory           IN NUMBER,
                    p_dtlattributecontext          IN VARCHAR2,
                    p_dtlattribute1                IN VARCHAR2,
                    p_dtlattribute2                IN VARCHAR2,
                    p_dtlattribute3                IN VARCHAR2,
                    p_dtlattribute4                IN VARCHAR2,
                    p_dtlattribute5                IN VARCHAR2,
                    p_dtlattribute6                IN VARCHAR2,
                    p_dtlattribute7                IN VARCHAR2,
                    p_dtlattribute8                IN VARCHAR2,
                    p_dtlattribute9                IN VARCHAR2,
                    p_dtlattribute10               IN VARCHAR2,
                    p_dtlattribute11               IN VARCHAR2,
                    p_dtlattribute12               IN VARCHAR2,
                    p_dtlattribute13               IN VARCHAR2,
                    p_dtlattribute14               IN VARCHAR2,
                    p_dtlattribute15               IN VARCHAR2,
                    p_dtlattribute16               IN VARCHAR2,
                    p_dtlattribute17               IN VARCHAR2,
                    p_dtlattribute18               IN VARCHAR2,
                    p_dtlattribute19               IN VARCHAR2,
                    p_dtlattribute20               IN VARCHAR2,
                    p_dtlattribute21               IN VARCHAR2,
                    p_dtlattribute22               IN VARCHAR2,
                    p_dtlattribute23               IN VARCHAR2,
                    p_dtlattribute24               IN VARCHAR2,
                    p_dtlattribute25               IN VARCHAR2,
                    p_dtlattribute26               IN VARCHAR2,
                    p_dtlattribute27               IN VARCHAR2,
                    p_dtlattribute28               IN VARCHAR2,
                    p_dtlattribute29               IN VARCHAR2,
                    p_dtlattribute30               IN VARCHAR2,
                    x_return_status                OUT NOCOPY VARCHAR2
                    ) AS
        l_error_message                 VARCHAR2(4000);
        l_api_name    constant          VARCHAR2(30) := 'DPP_TRANSACTION_PVT';
        l_api_version constant          NUMBER := 1.0;
        l_full_name   constant          VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
        l_return_status                 VARCHAR2(30);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_transaction_header_rec        txn_header_rec;
        l_transaction_lines_rec         txn_lines_rec;
        l_transaction_int_header_id     NUMBER;
        l_transaction_int_line_id       NUMBER;
        l_transaction_line_id           NUMBER;
        dpp_webadi_error                EXCEPTION;
        l_source                        VARCHAR2(10) := 'WEBADI';
        l_message                       VARCHAR2(4000) := NULL;

    BEGIN
         SAVEPOINT inbound_approval;
         x_return_status := fnd_api.g_ret_sts_success;

        IF p_distributor_operating_unit IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_OPERATING_UNIT_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message ||  l_error_message;

        END IF;
         IF p_document_reference IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_DOC_REF_NUM_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;

         IF LENGTH(p_document_reference) > 40 THEN
            fnd_message.set_name('DPP', 'DPP_DOC_REF_NUM');
            l_error_message :=  fnd_message.get();
            l_message := l_message || l_error_message;
            --raise_application_error( -20000, l_error_message);
            --RAISE DPP_WEBADI_ERROR;
        END IF;

    IF  p_supp_dist_claim_number  IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_CLAIM_NUM_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message ||  l_error_message;
            --RAISE DPP_WEBADI_ERROR;
        END IF;

    IF  p_supplier_approved_by  IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_APPROVEDBY_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message ||  l_error_message;
            --RAISE DPP_WEBADI_ERROR;
        END IF;

    IF  p_supplier_approval_date  IS NULL THEN
            fnd_message.set_name('DPP', 'DPP_APPROVED_DATE_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message ||  l_error_message;
            --RAISE DPP_WEBADI_ERROR;
        END IF;

        IF p_supplier_name IS NULL THEN
            fnd_message.set_name ('DPP', 'DPP_SUPPLIER_NAME_NULL');
            l_error_message :=  fnd_message.get();
            --raise_application_error( -20000, l_error_message);
            l_message := l_message ||  l_error_message;
            --RAISE DPP_WEBADI_ERROR;
        END IF;


        IF p_supplier_site IS NULL THEN
          fnd_message.set_name('DPP', 'DPP_SUPPLIER_SITE_NULL');
          l_error_message :=  fnd_message.get();
          --raise_application_error( -20000, l_error_message);
            l_message := l_message ||  l_error_message;
            --RAISE DPP_WEBADI_ERROR;;
        END IF;

        -- Line Level Mandatory Field Validation

        IF (p_supplier_part_num IS NULL and p_item_number IS NULL) THEN
            fnd_message.set_name('DPP', 'DPP_SUPPLIER_PART_NUM_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message ||  l_error_message;
            --RAISE DPP_WEBADI_ERROR;
        END IF;

    IF  p_approved_inventory  IS NULL OR p_approved_inventory  < 0 THEN
            fnd_message.set_name('DPP', 'DPP_APPROVED_QTY_NULL');
            l_error_message :=  fnd_message.get();
            l_message := l_message ||  l_error_message;
            --RAISE DPP_WEBADI_ERROR;
        END IF;
      IF l_message IS NOT NULL THEN
          RAISE DPP_WEBADI_ERROR;
      END IF;
        l_transaction_header_rec.operating_unit_name := p_distributor_operating_unit;
        l_transaction_header_rec.ref_document_number := p_document_reference;
        l_transaction_header_rec.SUPPLIER_APPROVED_BY:= p_supplier_approved_by;
        l_transaction_header_rec.SUPPLIER_APPROVAL_DATE:=p_supplier_approval_date;
        l_transaction_header_rec.SUPP_DIST_CLAIM_NUMBER:= p_supp_dist_claim_number;
        l_transaction_header_rec.vendor_name := p_supplier_name;
        l_transaction_header_rec.vendor_site_code := p_supplier_site;
        l_transaction_header_rec.vendor_contact_name := p_supplier_contact;
        l_transaction_header_rec.contact_phone := p_supplier_contact_phone;
        l_transaction_header_rec.contact_email_address := p_supplier_contact_email;
        l_transaction_header_rec.effective_start_date := p_effective_date;
        l_transaction_header_rec.days_covered := p_days_covered;
        l_transaction_header_rec.trx_currency := p_currency;
        l_transaction_header_rec.transaction_source := l_source;
        l_transaction_header_rec.attribute_category := p_hdrattributecontext;
        l_transaction_header_rec.attribute1 := p_hdrattribute1;
        l_transaction_header_rec.attribute2 := p_hdrattribute2;
        l_transaction_header_rec.attribute3 := p_hdrattribute3;
        l_transaction_header_rec.attribute4 := p_hdrattribute4;
        l_transaction_header_rec.attribute5 := p_hdrattribute5;
        l_transaction_header_rec.attribute6 := p_hdrattribute6;
        l_transaction_header_rec.attribute7 := p_hdrattribute7;
        l_transaction_header_rec.attribute8 := p_hdrattribute8;
        l_transaction_header_rec.attribute9 := p_hdrattribute9;
        l_transaction_header_rec.attribute10 := p_hdrattribute10;
        l_transaction_header_rec.attribute11 := p_hdrattribute11;
        l_transaction_header_rec.attribute12 := p_hdrattribute12;
        l_transaction_header_rec.attribute13 := p_hdrattribute13;
        l_transaction_header_rec.attribute14 := p_hdrattribute14;
        l_transaction_header_rec.attribute15 := p_hdrattribute15;
        l_transaction_header_rec.attribute16 := p_hdrattribute16;
        l_transaction_header_rec.attribute17 := p_hdrattribute17;
        l_transaction_header_rec.attribute18 := p_hdrattribute18;
        l_transaction_header_rec.attribute19 := p_hdrattribute19;
        l_transaction_header_rec.attribute20 := p_hdrattribute20;
        l_transaction_header_rec.attribute21 := p_hdrattribute21;
        l_transaction_header_rec.attribute22 := p_hdrattribute22;
        l_transaction_header_rec.attribute23 := p_hdrattribute23;
        l_transaction_header_rec.attribute24 := p_hdrattribute24;
        l_transaction_header_rec.attribute25 := p_hdrattribute25;
        l_transaction_header_rec.attribute26 := p_hdrattribute26;
        l_transaction_header_rec.attribute27 := p_hdrattribute27;
        l_transaction_header_rec.attribute28 := p_hdrattribute28;
        l_transaction_header_rec.attribute29 := p_hdrattribute29;
        l_transaction_header_rec.attribute30 := p_hdrattribute30;

        --Assign to rec type l_transaction_header_rec


        l_transaction_lines_rec.SUPPLIER_PART_NUM := p_supplier_part_num;
        l_transaction_lines_rec.ITEM_NUMBER := P_ITEM_NUMBER;
        l_transaction_lines_rec.CHANGE_TYPE := P_CHANGE_TYPE;
        l_transaction_lines_rec.CHANGE_VALUE := P_CHANGE_VALUE;
        l_transaction_lines_rec.UOM := P_UOM;
        l_transaction_lines_rec.APPROVED_INVENTORY :=P_APPROVED_INVENTORY;
        l_transaction_lines_rec.attribute_category := p_dtlattributecontext;
        l_transaction_lines_rec.attribute1 := p_dtlattribute1;
        l_transaction_lines_rec.attribute2 := p_dtlattribute2;
        l_transaction_lines_rec.attribute3 := p_dtlattribute3;
        l_transaction_lines_rec.attribute4 := p_dtlattribute4;
        l_transaction_lines_rec.attribute5 := p_dtlattribute5;
        l_transaction_lines_rec.attribute6 := p_dtlattribute6;
        l_transaction_lines_rec.attribute7 := p_dtlattribute7;
        l_transaction_lines_rec.attribute8 := p_dtlattribute8;
        l_transaction_lines_rec.attribute9 := p_dtlattribute9;
        l_transaction_lines_rec.attribute10 := p_dtlattribute10;
        l_transaction_lines_rec.attribute11 := p_dtlattribute11;
        l_transaction_lines_rec.attribute12 := p_dtlattribute12;
        l_transaction_lines_rec.attribute13 := p_dtlattribute13;
        l_transaction_lines_rec.attribute14 := p_dtlattribute14;
        l_transaction_lines_rec.attribute15 := p_dtlattribute15;
        l_transaction_lines_rec.attribute16 := p_dtlattribute16;
        l_transaction_lines_rec.attribute17 := p_dtlattribute17;
        l_transaction_lines_rec.attribute18 := p_dtlattribute18;
        l_transaction_lines_rec.attribute19 := p_dtlattribute19;
        l_transaction_lines_rec.attribute20 := p_dtlattribute20;
        l_transaction_lines_rec.attribute21 := p_dtlattribute21;
        l_transaction_lines_rec.attribute22 := p_dtlattribute22;
        l_transaction_lines_rec.attribute23 := p_dtlattribute23;
        l_transaction_lines_rec.attribute24 := p_dtlattribute24;
        l_transaction_lines_rec.attribute25 := p_dtlattribute25;
        l_transaction_lines_rec.attribute26 := p_dtlattribute26;
        l_transaction_lines_rec.attribute27 := p_dtlattribute27;
        l_transaction_lines_rec.attribute28 := p_dtlattribute28;
        l_transaction_lines_rec.attribute29 := p_dtlattribute29;
        l_transaction_lines_rec.attribute30 := p_dtlattribute30;


        Create_Intheader(
                        p_txn_header_rec_type   => l_transaction_header_rec,
                        x_rec_count             => l_msg_count,
                        x_return_status         => l_return_status);

        IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        l_transaction_lines_rec.transaction_int_header_id :=l_transaction_header_rec.transaction_int_header_id;
        l_transaction_lines_rec.org_id :=l_transaction_header_rec.org_id;

        Create_Intlines(
                        p_transaction_lines_rec => l_transaction_lines_rec,
                        x_msg_count             => l_msg_count,
                        x_return_status         => l_return_status);


        IF l_return_status = fnd_api.g_ret_sts_error THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Create_Intlines fnd_api.g_ret_sts_error'||sqlerrm);
            fnd_message.set_name('DPP',   'DPP_DUPLICATE_RECORDS');
            l_error_message := fnd_message.get();
            RAISE dpp_webadi_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Create_Intlines fnd_api.g_ret_sts_error');
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

    EXCEPTION

            WHEN dpp_webadi_error THEN
            --x_return_status := FND_API.G_RET_STS_ERROR;
            ROLLBACK TO inbound_approval;
            if l_error_message is NULL then
              DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP in DPP_webadi_error l_error_message is null');
              l_error_message :=  fnd_message.get();
            end if;
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP in DPP_webadi_error:'||l_error_message);
            raise_application_error( -20000, l_error_message);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP IN FND_API.G_EXC_UNEXPECTED_ERROR BLOCK');
            ROLLBACK TO inbound_approval;
            IF length( SQLERRM) > 30 THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  substr(SQLERRM,12,30));
                fnd_message.set_name ('DPP', substr(SQLERRM,12,30));
            ELSE
                fnd_message.set_name ('DPP', SQLERRM);
            END IF;
            l_error_message :=  fnd_message.get();
            raise_application_error( -20000, l_error_message);
        WHEN OTHERS THEN
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP IN OTHERS BLOCK');
            ROLLBACK TO inbound_approval;
            IF length( SQLERRM) > 30 THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  substr(SQLERRM,12,30));
                fnd_message.set_name ('DPP', substr(SQLERRM,12,30));
            ELSE
                fnd_message.set_name ('DPP', SQLERRM);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_error_message :=  fnd_message.get();
            DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP l_error_message:'||l_error_message);
            raise_application_error( -20000, l_error_message);
    END inbound_approval;

    PROCEDURE Create_Transaction(
                                errbuf OUT nocopy VARCHAR2
                            ,   retcode OUT nocopy VARCHAR2
                            ,   p_operating_unit           IN VARCHAR2 DEFAULT NULL
                            ,   p_supplier_name            IN VARCHAR2
                            ,   p_supplier_site            IN VARCHAR2 DEFAULT NULL
                            ,   p_document_reference_number IN VARCHAR2 DEFAULT NULL
                    )
    AS
        l_api_name constant VARCHAR2(30) := 'Create_Transaction';
        l_api_version constant NUMBER := 1.0;
        l_full_name constant VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status VARCHAR2(30);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(4000);
        l_user_id           NUMBER :=FND_PROFILE.VALUE('USER_ID');

        l_request_id   NUMBER :=FND_GLOBAL.conc_request_id;
        l_program_id   NUMBER :=FND_GLOBAL.conc_program_id;
        l_prog_app_id NUMBER :=FND_GLOBAL.prog_appl_id;

        l_init_msg_list VARCHAR2(30) := fnd_api.g_false;
        l_commit VARCHAR2(30) := fnd_api.g_false;
        l_validation_level NUMBER := fnd_api.g_valid_level_full;

        l_transaction_int_header_id NUMBER;
        l_line_count NUMBER := 0;
        l_message VARCHAR2(250);
        l_row_count  NUMBER := 0;
        l_supplier_id VARCHAR2(150);
        l_supplier_site_id VARCHAR2(150);
        l_org_id VARCHAR2(150);
        l_value NUMBER;

        CURSOR transaction_cur(cv_doc_ref_no VARCHAR2,   cv_supplier_name VARCHAR2,cv_supplier_id VARCHAR2,
        cv_supplier_site VARCHAR2,cv_supplier_site_id VARCHAR2,cv_operating_unit VARCHAR2,cv_org_id VARCHAR2 )
        IS
            SELECT transaction_int_header_id
            FROM dpp_txn_headers_int_all dtha ,
            hr_operating_units hr
            WHERE  dtha.interface_status = 'N'
            AND nvl(dtha.ref_document_number, -1) = nvl(cv_doc_ref_no,nvl(dtha.ref_document_number,-1))
            AND (dtha.vendor_name = cv_supplier_name OR
            dtha.vendor_id = cv_supplier_id)
            AND (nvl(dtha.vendor_site,-1) = nvl(cv_supplier_site, nvl(dtha.vendor_site,-1)) OR
            nvl(dtha.vendor_site_id,-1) = nvl(cv_supplier_site_id, nvl(dtha.vendor_site_id,-1)))
            AND (nvl(dtha.operating_unit_name,-1) =  nvl(cv_operating_unit,  nvl(dtha.operating_unit_name,-1))
             OR nvl(dtha.org_id,-1) =  nvl(cv_org_id,  nvl( dtha.org_id,-1)))
            AND hr.name = nvl(dtha.operating_unit_name,hr.name)
            AND hr.organization_id =nvl(to_number(dtha.org_id),hr.organization_id)
            AND mo_global.check_access(hr.organization_id) = 'Y'
            ORDER BY transaction_int_header_id;

    BEGIN
    -- Standard begin of API savepoint
        SAVEPOINT dpp_create_txn;
         -- Initialize API return status to sucess
        retcode  := 0;
        ------------------------------------------
        -- Initialization
        ------------------------------------------
         fnd_file.put_line(fnd_file.log,('=================================='));
         fnd_file.put_line(fnd_file.log,('INITIALIZATION'));
         fnd_file.put_line(fnd_file.log,('USER   : ' ||  ' (' || l_user_id || ')'));
         fnd_file.put_line(fnd_file.log,('ORG    : ' || SUBSTR(userenv('CLIENT_INFO'),   1,   10)));
         fnd_file.put_line(fnd_file.log,('=================================='));

   IF DPP_DEBUG_HIGH_ON THEN
        fnd_file.put_line(fnd_file.log,   'Begin Create Transaction');
        fnd_file.put_line(fnd_file.log,   '************************');
        fnd_file.put_line(fnd_file.log,   '     Supplier Name:' || p_supplier_name
                                        ||'     Supplier Site:' || p_supplier_site
                                        ||'     Ref Document Number:' || p_document_reference_number
                                        ||'     Operating Unit: ' || p_operating_unit);
    END IF;
		  DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP_INBOUND_PVT_BODY name:'||p_supplier_name
        ||'DPP_INBOUND_PVT_BODY site:'||p_supplier_site
        ||'DPP_INBOUND_PVT_BODY ref:'||p_document_reference_number
        ||'DPP_INBOUND_PVT_BODY unit: '||p_operating_unit);
--BUG 6806974


      SELECT fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL') into l_value from dual;

      mo_global.set_org_access( null,l_value,'M');


        BEGIN
          SELECT vendor_id
            INTO l_supplier_id
            FROM ap_suppliers
           WHERE vendor_name = p_supplier_name;


          IF p_supplier_site IS NOT NULL THEN
          SELECT vendor_site_id
            INTO l_supplier_site_id
            FROM ap_supplier_sites
           WHERE vendor_id = to_number(l_supplier_id)
             AND vendor_site_code =p_supplier_site;
          END IF;

           IF p_operating_unit IS NOT NULL THEN
          SELECT organization_id
            INTO l_org_id
            FROM hr_operating_units
           WHERE name = p_operating_unit;
          END IF;
           IF DPP_DEBUG_HIGH_ON THEN
                 fnd_file.put_line(fnd_file.log,   'Vendor Id '||l_supplier_id
                                    ||' Supplier Site ID '||l_supplier_site_id
                                    || ' Org ID '||l_org_id);
           END IF;

        EXCEPTION WHEN NO_DATA_FOUND THEN
         fnd_file.put_line(fnd_file.log,   'Error in deriving ID for the parameters');
         RAISE Fnd_Api.G_EXC_ERROR;
        END;

        FOR transaction_rec IN transaction_cur(p_document_reference_number,p_supplier_name,l_supplier_id,
        p_supplier_site,l_supplier_site_id,p_operating_unit,l_org_id)
        LOOP
            IF DPP_DEBUG_HIGH_ON THEN
                 fnd_file.put_line(fnd_file.log,   'Call Insert Transaction p_transaction_int_header_id:'||transaction_rec.transaction_int_header_id);
             END IF;
              BEGIN
               UPDATE dpp_txn_headers_int_all dtha
                  SET dtha.program_id = l_program_id,
                      dtha.program_application_id = l_prog_app_id,
                      dtha.request_id = l_request_id,
                      dtha.program_update_date = sysdate
                WHERE dtha.transaction_int_header_id = transaction_rec.transaction_int_header_id;

                  UPDATE dpp_txn_lines_int_all dtla
                  SET dtla.program_id = l_program_id,
                      dtla.program_application_id = l_prog_app_id,
                      dtla.request_id = l_request_id,
                      dtla.program_update_date = sysdate
                WHERE dtla.transaction_int_header_id = transaction_rec.transaction_int_header_id;
              EXCEPTION WHEN OTHERS THEN
               fnd_file.put_line(fnd_file.log,   'Error in updating request id into the table.');
               RAISE Fnd_Api.G_EXC_ERROR;
              END;
               DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'Call Insert Transaction p_transaction_int_header_id:'||transaction_rec.transaction_int_header_id);
             DPP_TRANSACTION_PVT.Insert_Transaction(
                            p_api_version        =>l_api_version
                        ,   p_init_msg_list      =>l_init_msg_list
                        ,   p_commit             =>l_commit
                        ,   p_validation_level   =>l_validation_level
                        ,   p_transaction_int_header_id =>transaction_rec.transaction_int_header_id
                        ,   p_operating_unit     => p_operating_unit
                        ,   x_return_status      =>l_return_status
                        ,   x_msg_count          =>l_msg_count
                        ,   x_msg_data           =>l_msg_data
                        ) ;

            IF l_return_status IN ('E','U') THEN
             fnd_file.put_line(fnd_file.log,l_msg_data);
             l_line_count := l_line_count + 1;
              /*IF DPP_DEBUG_HIGH_ON THEN
                   fnd_file.put_line(fnd_file.log,   '************************');
                   fnd_file.put_line(fnd_file.log,   '  Message: '||l_msg_data);
                   fnd_file.put_line(fnd_file.log,   '************************');
               END IF;*/
            END IF;
            l_row_count := l_row_count +1;
        END LOOP;
        fnd_file.put_line(fnd_file.log,   '  No of Records Processed : '||l_row_count);
        fnd_file.put_line(fnd_file.log,   '  No of Error Records : '||l_line_count);
        fnd_file.put_line(fnd_file.log,   '  No of Success Records : '||(l_row_count-l_line_count));

         DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  '  No of Records Processed  : '||l_row_count
             ||'  No of Error Records : '||l_line_count
             ||'  No of Success Records : '||(l_row_count-l_line_count));

          IF l_row_count = 0 THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'No Records selected for Processing');
          END IF;
          IF l_line_count = 0 OR l_row_count = 0 THEN
            retcode := 0;
            errbuf :='Normal';
          ELSIF l_line_count = l_row_count THEN
            retcode := 2;
            errbuf :='Error';
          ELSE
            retcode := 1;
            errbuf :='Warning';
          END IF;
          DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_STATEMENT, 'dpp.plsql.' || L_FULL_NAME,  'DPP EXCEPTION l_msg_data:' ||l_msg_data);

       IF DPP_DEBUG_HIGH_ON THEN
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'End Create Transaction');
       END IF;

    EXCEPTION
            WHEN Fnd_Api.G_EXC_ERROR THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP EXCEPTION G_EXC_ERROR');
                ROLLBACK TO dpp_create_txn;
                Fnd_Msg_Pub.Count_AND_Get
                    ( p_count      =>      l_msg_count,
                    p_data       =>      l_msg_data,
                    p_encoded    =>      Fnd_Api.G_FALSE
                    );
            WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP EXCEPTION G_EXC_UNEXPECTED_ERROR');
                ROLLBACK TO dpp_create_txn;
                Fnd_Msg_Pub.Count_AND_Get
                    ( p_count      =>      l_msg_count,
                    p_data       =>      l_msg_data,
                    p_encoded    =>      Fnd_Api.G_FALSE
                    );
            WHEN OTHERS THEN
                DPP_UTILITY_PVT.DEBUG_MESSAGE( FND_LOG.LEVEL_EXCEPTION, 'dpp.plsql.' || L_FULL_NAME,  'DPP EXCEPTION OTHERS'||SQLERRM);
                ROLLBACK TO dpp_create_txn;
                IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR )
                THEN
                    Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                END IF;
                Fnd_Msg_Pub.Count_AND_Get
                    ( p_count      =>      l_msg_count,
                    p_data       =>      l_msg_data,
                    p_encoded    =>      Fnd_Api.G_FALSE
                    );

    END Create_Transaction;
END DPP_TRANSACTION_PVT;

/
