--------------------------------------------------------
--  DDL for Package Body IBY_FD_EXTRACT_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FD_EXTRACT_GEN_PVT" AS
/* $Header: ibyfdxgb.pls 120.77.12010000.36 2010/02/24 09:49:06 asarada ship $ */


--============================================================================
-- This package has the following dependencies (compilation) to apps products:
-- AP:
--   1. AP_DOCUMENT_LINES_V. Referenced by function: Get_Doc_DocLineAgg()
--
-- FV:
--   1. FV_FEDERAL_PAYMENT_FIELDS_PKG.get_FEIN(payment_instruction_id).
--        Referenced by the same named function in this package.
--   2. FV_FEDERAL_PAYMENT_FIELDS_PKG.get_Abbreviated_Agency_Code(payment_instruction_id)
--        Referenced by the same named function in this package.
--   3. FV_FEDERAL_PAYMENT_FIELDS_PKG.get_Allotment_Code(payment_id)
--        Referenced by the same named function in this package.
--   4. FV_FEDERAL_PAYMENT_FIELDS_PKG.TOP_Offset_Eligibility_Flag(payment_id)
--        Referenced by the same named function in this package.
--============================================================================

  G_SRA_DELIVERY_METHOD_ATTR CONSTANT NUMBER := 1;
  G_SRA_EMAIL_ATTR CONSTANT NUMBER := 2;
  G_SRA_FAX_ATTR CONSTANT NUMBER := 3;
  G_SRA_REQ_FLAG_ATTR CONSTANT NUMBER := 4;
  G_SRA_PS_LANG_ATTR CONSTANT NUMBER := 5;
  G_SRA_PS_TERRITORY_ATTR CONSTANT NUMBER := 6;

  G_SRA_DELIVERY_METHOD_PRINTED CONSTANT VARCHAR2(30) := 'PRINTED';
  G_SRA_DELIVERY_METHOD_EMAIL CONSTANT VARCHAR2(30) := 'EMAIL';
  G_SRA_DELIVERY_METHOD_FAX CONSTANT VARCHAR2(30) := 'FAX';

  G_EXTRACT_MODE_PMT CONSTANT NUMBER := 1;
  G_EXTRACT_MODE_SRA CONSTANT NUMBER := 2;
  G_EXTRACT_MODE_AUX CONSTANT NUMBER := 3;
  G_EXTRACT_MODE_FV_SMMY CONSTANT NUMBER := 4;
  G_EXTRACT_MODE_PI_RPT  CONSTANT NUMBER := 5;
  G_EXTRACT_MODE_PPR_RPT CONSTANT NUMBER := 6;

  G_Extract_Run_Mode NUMBER;
  G_Extract_Run_Delivery_Method VARCHAR2(30);
  G_Extract_Run_Payment_id NUMBER;
  G_Extract_Run_From_Pmt_Ref NUMBER;
  G_Extract_Run_To_Pmt_Ref NUMBER;

  G_May_Need_HR_Masking BOOLEAN := FALSE;

  G_Is_Reprint VARCHAR2(1);

  G_IS_BRAZIL NUMBER;

  -- temp debugging
  Get_Payee_LegalRegistration_C number := 0;
  Get_Payee_TaxRegistration_C number := 0;
  Get_FP_TaxRegistration_C number := 0;
  Get_PayeeContact_C number := 0;
  Get_PayerContact_C number := 0;
  Get_PayerBankAccount_C number := 0;
  Get_Payer_C number := 0;
  Get_Hz_Address_C NUMBER := 0;
  Get_Hr_Address_C NUMBER := 0;
  format_hz_address_C NUMBER := 0;
  format_hr_address_C NUMBER := 0;

  /* perf bug 6763515 */
  G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;


    -- Performance Fix :  9184059
    l_conc_invalid_chars VARCHAR2(50);
    l_conc_replacement_chars VARCHAR2(50);

  TYPE t_docs_pay_attribs_type IS RECORD(
  IS_BRAZIL NUMBER
   );

  TYPE t_docs_pay_attribs_tbl_type IS TABLE OF t_docs_pay_attribs_type INDEX BY BINARY_INTEGER;
  g_docs_pay_attribs_tbl t_docs_pay_attribs_tbl_type;

  TYPE t_hr_addr_rec_type IS RECORD(
  hr_address  XMLTYPE
   );

  TYPE t_hr_addr_tbl_type IS TABLE OF t_hr_addr_rec_type INDEX BY BINARY_INTEGER;
  g_hr_addr_tbl  t_hr_addr_tbl_type;

  TYPE t_hz_addr_rec_type IS RECORD(
  hz_address  XMLTYPE
   );

  TYPE t_hz_addr_tbl_type IS TABLE OF t_hz_addr_rec_type INDEX BY BINARY_INTEGER;
  g_hz_addr_tbl  t_hz_addr_tbl_type;

  TYPE t_payer_contact_rec_type IS RECORD(
  l_contactinfo  XMLTYPE
   );

  TYPE t_payer_contact_tbl_type IS TABLE OF t_payer_contact_rec_type INDEX BY BINARY_INTEGER;

  g_payer_contact_tbl  t_payer_contact_tbl_type;

  /* Bug 8670295 */
  /* added for caching the account address*/
  TYPE t_account_addr_rec_type IS RECORD(
    account_address  XMLTYPE
   );
  TYPE t_account_addr_tbl_type IS TABLE OF t_account_addr_rec_type INDEX BY VARCHAR2(2000);
  g_account_addr_tbl  t_account_addr_tbl_type;

  /* added for caching the formatted hz address*/

  TYPE t_formatted_hz_addr_rec_type IS RECORD(
    formatted_address  VARCHAR2(4000)
   );
  TYPE t_formatted_hz_addr_tbl_type IS TABLE OF t_formatted_hz_addr_rec_type INDEX BY VARCHAR2(2000);
  g_formatted_hz_addr_tbl  t_formatted_hz_addr_tbl_type;
  /* end of caching the formatted hz address*/

  /* Added for caching the Registration Number */
  TYPE t_registration_rec_type IS RECORD(
    registration_number  VARCHAR2(100)
   );
   TYPE t_registration_tbl_type IS TABLE OF t_registration_rec_type INDEX BY VARCHAR2(2000);
   g_registration_tbl  t_registration_tbl_type;
  /* Bug 8670295 */

  /* Added for caching Payer's Tax Registration Number */
  TYPE t_payer_registration_rec_type IS RECORD(
    registration_number  VARCHAR2(100)
   );
   TYPE t_payer_registration_tbl_type IS TABLE OF t_payer_registration_rec_type INDEX BY VARCHAR2(2000);
   g_payer_registration_tbl  t_payer_registration_tbl_type;
  /* Bug 8760084 */

   /* Bug 9266772*/
  TYPE t_inter_acct_tbl_type IS TABLE OF XMLTYPE INDEX BY varchar2(1000);
  g_inter_accts_tbl  t_inter_acct_tbl_type;
   /* Bug 9266772*/

  FUNCTION Get_Payee_Default_Attribute(p_payment_id IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2;

  PROCEDURE Create_Extract_1_0_Main
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  );

  PROCEDURE Validate_and_Set_Syskey
  (
  p_sys_key                  IN     iby_security_pkg.des3_key_type
  );

  -- for payment format
  PROCEDURE Create_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_format_type              IN     VARCHAR2,
  p_is_reprint_flag          IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  )
  IS
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_Extract_1_0';

  BEGIN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    iby_debug_pub.add(debug_msg => 'Input p_is_reprint_flag: ' || p_is_reprint_flag,
                      debug_level => G_LEVEL_STATEMENT,
                      module => l_Debug_Module);
    END IF;

    G_Is_Reprint := p_is_reprint_flag;

    -- call the one for aux formats
    Create_Extract_1_0
    (
      p_payment_instruction_id   => p_payment_instruction_id,
      p_save_extract_flag        => p_save_extract_flag,
      p_format_type              => p_format_type,
      p_sys_key                  => p_sys_key,
      x_extract_doc              => x_extract_doc
    );

  END Create_Extract_1_0;

  -- for payment and auxiliary formats
  -- Auxiliary formats include:
  -- DISBURSEMENT_ACCOMPANY_LETTER
  -- REGULATORY_REPORTING
  -- REMITTANCE_ADVICE
  -- PAYMENT_INSTRUCTION_REGISTER
  -- FEDERAL_SUMMARY
  -- for FEDERAL_SUMMARY, the p_save_extract_flag
  -- is used for the ecs_dos_seq_num
  PROCEDURE Create_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_format_type              IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  )
  IS
    l_extract_count     NUMBER;
    l_trxn_doc_id       NUMBER;
    l_save_extract_flag   VARCHAR2(255);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_Extract_1_0';

  BEGIN
    iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
                      debug_level => G_LEVEL_STATEMENT,
                      module => l_Debug_Module);
    END IF;

    IF p_format_type = 'FEDERAL_SUMMARY' THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'ECS dos Seq num: ' || p_save_extract_flag,
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    ELSE
      l_save_extract_flag := p_save_extract_flag;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Save extract flag: ' || p_save_extract_flag,
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    END IF;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Format type: ' || p_format_type,
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;

    -- for now there are no differences between different type
    -- of aux formats in terms of extract. So only differenciate
    -- them from payment format
    IF p_format_type = 'OUTBOUND_PAYMENT_INSTRUCTION' THEN
      G_Extract_Run_Mode := G_EXTRACT_MODE_PMT;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'The extract mode is set to: G_EXTRACT_MODE_PMT',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;

    -- to do: confirm the format type code with PM
    ELSIF p_format_type = 'FEDERAL_SUMMARY' THEN
      G_Extract_Run_Mode := G_EXTRACT_MODE_FV_SMMY;

      IF p_save_extract_flag IS NOT NULL THEN
        iby_utility_pvt.set_view_param(G_VP_FV_ECS_SEQ, p_save_extract_flag);
      END IF;

      -- revert the param to its original function
      l_save_extract_flag := 'N';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'The extract mode is set to: G_EXTRACT_MODE_FV_SMMY',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    ELSIF p_format_type = 'PAYMENT_INSTRUCTION_REGISTER' THEN
      G_Extract_Run_Mode := G_EXTRACT_MODE_PI_RPT;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'The extract mode is set to: G_EXTRACT_MODE_PI_RPT',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    ELSE
      G_Extract_Run_Mode := G_EXTRACT_MODE_AUX;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'The extract mode is set to: G_EXTRACT_MODE_AUX',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    END IF;

    IF p_format_type = 'PAYMENT_INSTRUCTION_REGISTER' THEN
      G_May_Need_HR_Masking := TRUE;
    END IF;

    Create_Extract_1_0_Main
    (
    p_payment_instruction_id   => p_payment_instruction_id,
    p_save_extract_flag        => l_save_extract_flag,
    p_sys_key                  => p_sys_key,
    x_extract_doc              => x_extract_doc
    );
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                 debug_level => G_LEVEL_PROCEDURE,
                 module => l_Debug_Module);
  END Create_Extract_1_0;


  -- for separate remittance advice
  -- the p_save_extract_flag and p_format_type
  -- are currently ignored
  PROCEDURE Create_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_format_type              IN     VARCHAR2,
  p_delivery_method          IN     VARCHAR2,
  p_payment_id               IN     NUMBER,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB,
  p_from_pmt_ref             IN     NUMBER,
  p_to_pmt_ref               IN     NUMBER
  )
  IS
    l_extract_count     NUMBER;
    l_trxn_doc_id       NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_Extract_1_0';

  BEGIN

    iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);

	    iby_debug_pub.add(debug_msg => 'Input payment instruction ID: ' || p_payment_instruction_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);

	    iby_debug_pub.add(debug_msg => 'SRA delivery method: ' || p_delivery_method,
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);

	    iby_debug_pub.add(debug_msg => 'payment id: ' || p_payment_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;

    G_Extract_Run_Mode := G_EXTRACT_MODE_SRA;
    G_Extract_Run_Delivery_Method := p_delivery_method;
    G_Extract_Run_Payment_id := p_payment_id;
    G_Extract_Run_From_Pmt_Ref :=   p_from_pmt_ref;
    G_Extract_Run_To_Pmt_Ref := p_to_pmt_ref;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'The extract mode is set to: G_EXTRACT_MODE_SRA',
			    debug_level => G_LEVEL_STATEMENT,
			    module => l_Debug_Module);
    END IF;
    Create_Extract_1_0_Main
    (
    p_payment_instruction_id   => p_payment_instruction_id,
    p_save_extract_flag        => 'N',
    p_sys_key                  => p_sys_key,
    x_extract_doc              => x_extract_doc
    );
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
  END Create_Extract_1_0;


  -- for formats based on extract code: IBY_FD_PAYMENT_INSTRUCTION
  -- i.e., payment, separate remittance advice, acp ltr, etc.
  PROCEDURE Create_Extract_1_0_Main
  (
  p_payment_instruction_id   IN     NUMBER,
  p_save_extract_flag        IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  )
  IS
    l_extract_count     NUMBER;
    l_trxn_doc_id       NUMBER;
    l_ele_channel    VARCHAR2(50);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_Extract_1_0';

    CURSOR l_ece_csr(p_payment_instruction_id IN NUMBER) IS
    SELECT electronic_processing_channel
      FROM
           iby_payment_profiles ppp,
           iby_pay_instructions_all ins
     WHERE
           ins.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_profile_id = ppp.payment_profile_id;

  BEGIN
          iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'ENTER CREATE EXTRACT MAIN -- BEFORE INITIALIZING',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
         END IF;
     initialize;
    iby_utility_pvt.set_view_param(G_VP_INSTR_ID,p_payment_instruction_id);

    Validate_and_Set_Syskey(p_sys_key);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Before XML query ',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;
    CEP_STANDARD.init_security;
     OPEN l_ece_csr(p_payment_instruction_id);
    FETCH l_ece_csr INTO l_ele_channel;
    CLOSE l_ece_csr;
    IF l_ele_channel = 'ECE' AND G_Extract_Run_Mode = G_EXTRACT_MODE_PMT THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Electronic processing channel is ECE',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
      IBY_FD_POST_PICP_PROGS_PVT.Run_ECE_Formatting(p_payment_instruction_id);
      RETURN;
    END IF;

    SELECT XMLType.getClobVal(instruction)
    INTO x_extract_doc
    FROM iby_xml_fd_ins_1_0_v
    WHERE payment_instruction_id = p_payment_instruction_id;

    SELECT count(trxn_document_id)
    INTO l_extract_count
    FROM iby_trxn_documents
    where doctype=100 and trxnmid=p_payment_instruction_id;
--(bug 5970838)    WHERE doctype = 100 and payment_instruction_id = p_payment_instruction_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'After XML query ',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;
    IF p_save_extract_flag = 'Y' and l_extract_count = 0 THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'The save extract flag is Y and there were no extract previously saved ' ||
					     'for the instruction. Saving the extract for reuse.',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;

      iby_trxn_documents_pkg.CreateDocument
    	(
    	p_payment_instruction_id => p_payment_instruction_id,
    	p_doctype => 100,
    	p_doc => x_extract_doc,
  	    docid_out => l_trxn_doc_id
  	    );
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Save successful, iby trxn doc id: ' || l_trxn_doc_id,
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    END IF;

        iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    -- clears out data from global temporary table
    -- frzhang 8/11/2005: commit will be managed by the java CP
    -- COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        -- make sure procedure is not exited before a COMMIT
        -- so as to remove security keys
        -- frzhang 8/11/2005: commit will be managed by the java CP
        -- COMMIT;
        /* bug 6878265 */
	-- when exception occurs, the payment_instruction must be unlocked from the request

        RAISE;

  END Create_Extract_1_0_Main;


  PROCEDURE Validate_and_Set_Syskey
  (
  p_sys_key                  IN     iby_security_pkg.des3_key_type
  )
  IS
    lx_err_code         VARCHAR2(30);
  BEGIN


    IF (NOT p_sys_key IS NULL) THEN
      iby_security_pkg.validate_sys_key(p_sys_key,lx_err_code);
      IF (NOT lx_err_code IS NULL) THEN
       	raise_application_error(-20000,lx_err_code, FALSE);
      END IF;
      iby_utility_pvt.set_view_param(G_VP_SYS_KEY,p_sys_key);
    END IF;

  END Validate_and_Set_Syskey;


  PROCEDURE Create_PPR_Extract_1_0
  (
  p_payment_service_request_id   IN     NUMBER,
  p_sys_key                      IN     iby_security_pkg.des3_key_type,
  x_extract_doc                  OUT NOCOPY CLOB
  )
  IS
    l_extract_count     NUMBER;
    l_trxn_doc_id       NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_PPR_Extract_1_0';
  BEGIN
    iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    iby_utility_pvt.set_view_param(G_VP_INSTR_ID,p_payment_service_request_id);

    iby_utility_pvt.set_view_param(G_VP_FMT_TYPE,'PAYMENT_PROCESS_REQUEST_REPORT');

    Validate_and_Set_Syskey(p_sys_key);

    G_Extract_Run_Mode := G_EXTRACT_MODE_PPR_RPT;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'The extract mode is set to: G_EXTRACT_MODE_PPR_RPT',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;

    G_May_Need_HR_Masking := TRUE;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Before XML query ',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;
    CEP_STANDARD.init_security;

    SELECT XMLType.getClobVal(payment_process_request)
    INTO x_extract_doc
    FROM iby_xml_fd_ppr_1_0_v
    WHERE payment_service_request_id = p_payment_service_request_id;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'After XML query ',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                  debug_level => G_LEVEL_PROCEDURE,
                  module => l_Debug_Module);

    EXCEPTION
      WHEN OTHERS THEN
        RAISE;

  END Create_PPR_Extract_1_0;


  -- for positive pay - bug 5028143
  PROCEDURE Create_Pos_Pay_Extract_1_0
  (
  p_payment_instruction_id   IN     NUMBER,
  p_payment_profile_id       IN     NUMBER,
  p_from_date                IN     VARCHAR2,
  p_to_date                  IN     VARCHAR2,
  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  )
  IS

    type payment_arr is table of number;
    l_paymentid_arr payment_arr;
    l_paymentinstrid_arr payment_arr;

    l_to_date   VARCHAR2(255);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_Pos_Pay_Extract_1_0';

    CURSOR l_pospay_ins_csr IS
    SELECT XMLType.getClobVal(XMLElement("PositivePayDataExtract", XMLAgg(xml_pmt_lvl.payment)))
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl
     WHERE xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
       AND xml_pmt_lvl.payment_status = 'ISSUED'
       AND (xml_pmt_lvl.positive_pay_file_created_flag='N' or xml_pmt_lvl.positive_pay_file_created_flag is NULL);

    CURSOR l_pospay_appp_csr (p_to_date IN VARCHAR2) IS
    SELECT XMLType.getClobVal(XMLElement("PositivePayDataExtract", XMLAgg(xml_pmt_lvl.payment)))
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl
     WHERE xml_pmt_lvl.payment_profile_id = p_payment_profile_id
       AND xml_pmt_lvl.payment_date >= nvl(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'), xml_pmt_lvl.payment_date)
       AND xml_pmt_lvl.payment_date <= nvl(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'), SYSDATE)
       AND xml_pmt_lvl.payment_status = 'ISSUED'
       AND (xml_pmt_lvl.positive_pay_file_created_flag='N' or xml_pmt_lvl.positive_pay_file_created_flag is NULL);

  BEGIN
        iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    Validate_and_Set_Syskey(p_sys_key);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	iby_debug_pub.add(debug_msg => 'Before XML query ',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
    END IF;

    CEP_STANDARD.init_security;

    IF p_payment_instruction_id <> -99 THEN
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'payment instruction id is supplied ',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

	       OPEN l_pospay_ins_csr;
	      FETCH l_pospay_ins_csr INTO x_extract_doc;
	      CLOSE l_pospay_ins_csr;

	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'payment level attribute setting ',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

			/*LKQ POS PAY - PAVAN */
			-- payment level attribute setting
			UPDATE iby_payments_all pmt
			SET pmt.positive_pay_file_created_flag = 'Y'
			   WHERE pmt.payment_instruction_id = p_payment_instruction_id
			   AND pmt.payment_status = 'ISSUED'
			   AND (pmt.positive_pay_file_created_flag='N' or pmt.positive_pay_file_created_flag is NULL);

	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'payment instruction level attribute setting ',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

			/*LKQ POS PAY - PAVAN */
			-- payment instruction level attribute setting

			UPDATE iby_pay_instructions_all
			SET positive_pay_file_created_flag= 'Y'
			WHERE payment_instruction_id = p_payment_instruction_id;

    ELSE
	    IF instr(p_to_date, '00:00:00') <> 0 THEN
	      l_to_date := REPLACE(p_to_date, '00:00:00', '23:59:59');
	    ELSE
	      l_to_date := p_to_date;
	    END IF;

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'payment instruction id is NOT supplied ',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	     END IF;

	     OPEN l_pospay_appp_csr(l_to_date);
	     FETCH l_pospay_appp_csr INTO x_extract_doc;
	     CLOSE l_pospay_appp_csr;

			   SELECT pmt.payment_id,pmt.payment_instruction_id
			   BULK COLLECT INTO l_paymentid_arr,l_paymentinstrid_arr
			   FROM iby_xml_fd_pmt_1_0_v pmt
			   WHERE pmt.payment_profile_id = p_payment_profile_id
			       AND pmt.payment_date >= nvl(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'), pmt.payment_date)
			       AND pmt.payment_date <= nvl(to_date(l_to_date, 'YYYY/MM/DD HH24:MI:SS'), SYSDATE)
			       AND pmt.payment_status = 'ISSUED'
			       AND (pmt.positive_pay_file_created_flag='N' or pmt.positive_pay_file_created_flag is NULL);

	     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 iby_debug_pub.add(debug_msg => 'payment level attribute setting ',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	     END IF;


			/*LKQ POS PAY - PAVAN */
			-- payment level attribute setting
	      iby_debug_pub.add(debug_msg => 'Payment Count : '|| l_paymentid_arr.COUNT,debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      IF (  l_paymentid_arr.COUNT <> 0) THEN
			FOR i IN l_paymentid_arr.FIRST .. l_paymentid_arr.LAST LOOP
				UPDATE iby_payments_all
				SET positive_pay_file_created_flag = 'Y'
				WHERE payment_id = l_paymentid_arr(i);
				iby_debug_pub.add(debug_msg => 'Payment ID : '|| l_paymentid_arr(i),debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
			END LOOP;
	      ELSE
		        iby_debug_pub.add(debug_msg => 'Payment ID : '|| 'Empty',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'payment instruction level attribute setting ',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

			/*LKQ POS PAY - PAVAN */
			-- payment instruction level attribute setting
	      iby_debug_pub.add(debug_msg => 'Payment Instr Count : '|| l_paymentinstrid_arr.COUNT,debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      IF (  l_paymentinstrid_arr.COUNT <> 0) THEN
			FOR i IN l_paymentinstrid_arr.FIRST .. l_paymentinstrid_arr.LAST LOOP
			   IF (l_paymentinstrid_arr(i) IS NOT NULL ) THEN
			       UPDATE iby_pay_instructions_all ins
			       SET ins.positive_pay_file_created_flag = 'Y'
			       WHERE not exists (SELECT 'N'
						FROM iby_payments_all pmt
						WHERE  nvl(pmt.positive_pay_file_created_flag,'N') = 'N'
							     AND  pmt.payment_status IN('ISSUED',    'PAID')
							     AND  pmt.payment_instruction_id = l_paymentinstrid_arr(i))
			       AND ins.payment_instruction_id = l_paymentinstrid_arr(i);
			       iby_debug_pub.add(debug_msg => 'Payment Instr ID : '|| l_paymentinstrid_arr(i),debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
			    END IF;
			END LOOP;
	      ELSE
		     iby_debug_pub.add(debug_msg => 'Payment Instr ID : '|| 'Empty',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'After XML query ',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    EXCEPTION
      WHEN OTHERS THEN
        RAISE;

  END Create_Pos_Pay_Extract_1_0;




-- LKQ POS PAY ISSUE  - PAVAN
  PROCEDURE Create_Pos_Pay_Extract_2_0
  (
  p_payment_instruction_id   IN     NUMBER,

  p_format_name		     IN     VARCHAR2,
  p_internal_bank_account_name     IN     VARCHAR2,
  p_from_date                IN     VARCHAR2,
  p_to_date                  IN     VARCHAR2,
  p_payment_status	     IN     VARCHAR2,
  p_reselect		     IN     VARCHAR2,

  p_sys_key                  IN     iby_security_pkg.des3_key_type,
  x_extract_doc              OUT NOCOPY CLOB
  )
  IS

    type payment_arr is table of number;
    l_paymentid_arr payment_arr;
    l_paymentinstrid_arr payment_arr;
    l_to_date   VARCHAR2(255);
    l_from_date   VARCHAR2(255);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Create_Pos_Pay_Extract_2_0';

    --cursor for - pmt instr id supplied,negotiable payments, reselect - no
    CURSOR l_pospay_ins_csr_1_1 IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl
	WHERE xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
	AND xml_pmt_lvl.payment_status IN ('ISSUED','PAID')
	AND (xml_pmt_lvl.positive_pay_file_created_flag='N' or xml_pmt_lvl.positive_pay_file_created_flag is NULL)
        ;

    --cursor for - pmt instr id supplied,negotiable payments, reselect - yes
    CURSOR l_pospay_ins_csr_1_2 IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl
	WHERE xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
	AND xml_pmt_lvl.payment_status IN ('ISSUED','PAID')
        ;

    --cursor for - pmt instr id supplied,voided payments, reselect - no
    CURSOR l_pospay_ins_csr_2_1 IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl
	WHERE xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
	AND xml_pmt_lvl.payment_status IN('VOID')
	AND (xml_pmt_lvl.positive_pay_file_created_flag='N' or xml_pmt_lvl.positive_pay_file_created_flag is NULL)
        ;

    --cursor for - pmt instr id supplied,voided payments, reselect - yes
    CURSOR l_pospay_ins_csr_2_2 IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl
	WHERE xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
	AND xml_pmt_lvl.payment_status IN('VOID')
        ;

    --cursor for - pmt instr id supplied,negotiable and voided payments, reselect - no
    CURSOR l_pospay_ins_csr_3_1 IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl
	WHERE xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
	AND xml_pmt_lvl.payment_status IN('VOID','ISSUED','PAID')
	AND (xml_pmt_lvl.positive_pay_file_created_flag='N' or xml_pmt_lvl.positive_pay_file_created_flag is NULL)
        ;

    --cursor for - pmt instr id supplied,negotiable and voided payments, reselect - yes
    CURSOR l_pospay_ins_csr_3_2 IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl
	WHERE xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
	AND xml_pmt_lvl.payment_status IN('VOID','ISSUED','PAID')
        ;



    --cursor for - pmt instr id not supplied,negotiable payments, reselect - no
    CURSOR l_pospay_appp_csr_1_1 (p_from_date IN VARCHAR2,p_to_date IN VARCHAR2) IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl,iby_payment_profiles ppp
        WHERE  xml_pmt_lvl.payment_profile_id = ppp.payment_profile_id
	AND ppp.positive_pay_format_code IN
	  (SELECT ppfformat.format_code
	   FROM iby_formats_vl ppfformat
	   WHERE ppfformat.format_name = p_format_name)
	 AND xml_pmt_lvl.payment_date >= nvl(to_date(p_from_date,   'YYYY/MM/DD HH24:MI:SS'),   xml_pmt_lvl.payment_date)
	 AND xml_pmt_lvl.payment_date <= nvl(to_date(p_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate)
	 AND xml_pmt_lvl.payment_status IN('ISSUED',   'PAID')
	 AND(xml_pmt_lvl.positive_pay_file_created_flag = 'N' OR xml_pmt_lvl.positive_pay_file_created_flag IS NULL)
	 AND xml_pmt_lvl.internal_bank_account_id IN
	  (SELECT ba.bank_account_id
	   FROM ce_bank_accounts ba
	   WHERE ba.bank_account_name = p_internal_bank_account_name)
	;

    --cursor for - pmt instr id not supplied,negotiable payments, reselect - yes
    CURSOR l_pospay_appp_csr_1_2 (p_from_date IN VARCHAR2,p_to_date IN VARCHAR2) IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl,iby_payment_profiles ppp
        WHERE  xml_pmt_lvl.payment_profile_id = ppp.payment_profile_id
	AND ppp.positive_pay_format_code IN
	  (SELECT ppfformat.format_code
	   FROM iby_formats_vl ppfformat
	   WHERE ppfformat.format_name = p_format_name)
	 AND xml_pmt_lvl.payment_date >= nvl(to_date(p_from_date,   'YYYY/MM/DD HH24:MI:SS'),   xml_pmt_lvl.payment_date)
	 AND xml_pmt_lvl.payment_date <= nvl(to_date(p_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate)
	 AND xml_pmt_lvl.payment_status IN('ISSUED',   'PAID')
	 AND xml_pmt_lvl.internal_bank_account_id IN
	  (SELECT ba.bank_account_id
	   FROM ce_bank_accounts ba
	   WHERE ba.bank_account_name = p_internal_bank_account_name)
	;

    --cursor for - pmt instr id not supplied,voided payments, reselect - no
    CURSOR l_pospay_appp_csr_2_1 (p_from_date IN VARCHAR2,p_to_date IN VARCHAR2) IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl,iby_payment_profiles ppp
        WHERE  xml_pmt_lvl.payment_profile_id = ppp.payment_profile_id
	AND ppp.positive_pay_format_code IN
	  (SELECT ppfformat.format_code
	   FROM iby_formats_vl ppfformat
	   WHERE ppfformat.format_name = p_format_name)
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) >= nvl(to_date(p_from_date,   'YYYY/MM/DD HH24:MI:SS'),   decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date))
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) <= nvl(to_date(p_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate)
	 AND xml_pmt_lvl.payment_status IN('VOID')
	 AND(xml_pmt_lvl.positive_pay_file_created_flag = 'N' OR xml_pmt_lvl.positive_pay_file_created_flag IS NULL)
	 AND xml_pmt_lvl.internal_bank_account_id IN
	  (SELECT ba.bank_account_id
	   FROM ce_bank_accounts ba
	   WHERE ba.bank_account_name = p_internal_bank_account_name)
	;

    --cursor for - pmt instr id not supplied,voided payments, reselect - yes
    CURSOR l_pospay_appp_csr_2_2 (p_from_date IN VARCHAR2,p_to_date IN VARCHAR2) IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl,iby_payment_profiles ppp
        WHERE  xml_pmt_lvl.payment_profile_id = ppp.payment_profile_id
	AND ppp.positive_pay_format_code IN
	  (SELECT ppfformat.format_code
	   FROM iby_formats_vl ppfformat
	   WHERE ppfformat.format_name = p_format_name)
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) >= nvl(to_date(p_from_date,   'YYYY/MM/DD HH24:MI:SS'),   decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date))
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) <= nvl(to_date(p_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate)
	 AND xml_pmt_lvl.payment_status IN('VOID')
	 AND xml_pmt_lvl.internal_bank_account_id IN
	  (SELECT ba.bank_account_id
	   FROM ce_bank_accounts ba
	   WHERE ba.bank_account_name = p_internal_bank_account_name)
	;

    --cursor for - pmt instr id not supplied,negotiable and voided payments, reselect - no
    CURSOR l_pospay_appp_csr_3_1 (p_from_date IN VARCHAR2,p_to_date IN VARCHAR2) IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl,iby_payment_profiles ppp
        WHERE  xml_pmt_lvl.payment_profile_id = ppp.payment_profile_id
	AND ppp.positive_pay_format_code IN
	  (SELECT ppfformat.format_code
	   FROM iby_formats_vl ppfformat
	   WHERE ppfformat.format_name = p_format_name)
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) >= nvl(to_date(p_from_date,   'YYYY/MM/DD HH24:MI:SS'),   decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date))
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) <= nvl(to_date(p_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate)
	 AND xml_pmt_lvl.payment_status IN('VOID','ISSUED','PAID')
	 AND(xml_pmt_lvl.positive_pay_file_created_flag = 'N' OR xml_pmt_lvl.positive_pay_file_created_flag IS NULL)
	 AND xml_pmt_lvl.internal_bank_account_id IN
	  (SELECT ba.bank_account_id
	   FROM ce_bank_accounts ba
	   WHERE ba.bank_account_name = p_internal_bank_account_name)
	;

    --cursor for - pmt instr id not supplied,negotiable and voided payments, reselect - yes
    CURSOR l_pospay_appp_csr_3_2 (p_from_date IN VARCHAR2,p_to_date IN VARCHAR2) IS
	SELECT xmltype.getclobval(xmlelement("PositivePayDataExtract",   xmlagg(xml_pmt_lvl.payment)))
	FROM iby_xml_fd_pmt_1_0_v xml_pmt_lvl,iby_payment_profiles ppp
        WHERE  xml_pmt_lvl.payment_profile_id = ppp.payment_profile_id
	AND ppp.positive_pay_format_code IN
	  (SELECT ppfformat.format_code
	   FROM iby_formats_vl ppfformat
	   WHERE ppfformat.format_name = p_format_name)
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) >= nvl(to_date(p_from_date,   'YYYY/MM/DD HH24:MI:SS'),   decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date))
	 AND decode(xml_pmt_lvl.payment_status,'VOID',xml_pmt_lvl.void_date,xml_pmt_lvl.payment_date) <= nvl(to_date(p_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate)
	 AND xml_pmt_lvl.payment_status IN('VOID','ISSUED','PAID')
	 AND xml_pmt_lvl.internal_bank_account_id IN
	  (SELECT ba.bank_account_id
	   FROM ce_bank_accounts ba
	   WHERE ba.bank_account_name = p_internal_bank_account_name)
	;

  BEGIN

        iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    -- parameter disp
	    iby_debug_pub.add(debug_msg => 'Parameters 0 ' || ':' || p_payment_instruction_id || ':' ||
	    p_format_name || ':' || p_internal_bank_account_name || ':' || p_payment_status || ':' ||
	    p_reselect || ':' || p_from_date || ':' || p_to_date || ':' ||
	    p_sys_key, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);


		--system key validation
	    iby_debug_pub.add(debug_msg => 'Enter ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);


		--initializing
	    iby_debug_pub.add(debug_msg => 'Before XML query ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
    END IF;



	    Validate_and_Set_Syskey(p_sys_key);
	    CEP_STANDARD.init_security;


	--parameter editing
      l_from_date := p_from_date;
      l_to_date := p_to_date;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'l_from_date 0 : ' || l_from_date, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	      iby_debug_pub.add(debug_msg => 'l_to_date 0 : ' || l_to_date, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
      END IF;

	    /* From date does not need any manipulations, and should not be defaulted to sysdate
	    IF  ( trim(l_from_date) = '' or l_from_date = null or l_from_date = 'null') THEN
	        l_from_date := to_char(sysdate,'YYYY/MM/DD')||' 00:00:00';
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'l_from_date 1 : ' || l_from_date, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
	    END IF;*/
   	    IF  ( trim(l_to_date) = ''  or l_to_date is null or l_to_date = 'null') THEN
	        l_to_date := to_char(sysdate,'YYYY/MM/DD')||' 00:00:00';
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'l_to_date 1 : ' || l_to_date, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
	    END IF;
    /* From date does not need any manipulations, and should not be defaulted to sysdate
    IF instr(l_from_date, '00:00:00') <> 0 THEN
      l_from_date := REPLACE(l_from_date, '00:00:00', '00:00:01');
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'l_from_date 2 : ' || l_from_date, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
      END IF;
    END IF;*/

    IF instr(l_to_date, '00:00:00') <> 0 THEN
      l_to_date := REPLACE(l_to_date, '00:00:00', '23:59:59');
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'l_to_date 2 : ' || l_to_date, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
      END IF;
    END IF;

    -- parameter disp
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Parameters 1 ' || ':' || p_payment_instruction_id || ':' ||
	    p_format_name || ':' || p_internal_bank_account_name || ':' || p_payment_status || ':' ||
	    p_reselect || ':' || l_from_date || ':' || l_to_date || ':' ||
	    p_sys_key, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
    END IF;

	--parameter checks
    IF (p_payment_instruction_id = -99 ) THEN
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		    iby_debug_pub.add(debug_msg => 'Payment Instruction ID not supplied ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    END IF;
	    IF  ((trim(p_format_name) = '' or p_format_name is null or p_format_name = 'null') OR (trim(p_internal_bank_account_name) = '' or p_internal_bank_account_name is null or p_internal_bank_account_name = 'null')) THEN
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Enter the conditional mandatory fields Format Name and Internal Bank Account ID or Payment Instruction ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
    		RAISE FND_API.G_EXC_ERROR;
	    END IF;
    END IF;

    IF (nvl(to_date(l_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate) <  nvl(to_date(l_from_date,   'YYYY/MM/DD HH24:MI:SS'),   nvl(to_date(l_to_date,   'YYYY/MM/DD HH24:MI:SS'),   sysdate)) ) THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'From Payment Date is greater than To Payment Date', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF  (trim(p_payment_status) = '' or p_payment_status is null or p_payment_status = 'null') THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'Cannot proceed since Payment Status attribute is not supplied', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF  (trim(p_reselect) = '' or p_reselect is null or p_reselect = 'null') THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'Cannot proceed since Reselect attribute is not supplied', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    -- edited parameter disp
	    iby_debug_pub.add(debug_msg => 'Parameters 2 ' || ':' || p_payment_instruction_id || ':' ||
	    p_format_name || ':' || p_internal_bank_account_name || ':' || p_payment_status || ':' ||
	    p_reselect || ':' || l_from_date || ':' || l_to_date || ':' ||
	    p_sys_key, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
    END IF;

	--pmt instr supplied
    IF p_payment_instruction_id <> -99 THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'Payment Instruction ID supplied ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;
	IF upper(p_payment_status) = 'NEGOTIABLE' THEN
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'Payment Status is negotiable ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    END IF;
	    IF upper(p_reselect) = 'NO' THEN
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Reselect Option No ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_ins_csr_1_1;
		FETCH l_pospay_ins_csr_1_1 INTO x_extract_doc;
		CLOSE l_pospay_ins_csr_1_1;

                 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'payment level attribute setting ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		 END IF;
		 UPDATE iby_payments_all
		 SET positive_pay_file_created_flag = 'Y'
		    WHERE payment_instruction_id = p_payment_instruction_id
		    AND (positive_pay_file_created_flag='N' or positive_pay_file_created_flag is NULL)
		    AND payment_status IN ('ISSUED','PAID');
	    ELSE
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Reselect Option Yes ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_ins_csr_1_2;
		FETCH l_pospay_ins_csr_1_2 INTO x_extract_doc;
		CLOSE l_pospay_ins_csr_1_2;

                 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 iby_debug_pub.add(debug_msg => 'payment level attribute setting ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		 END IF;
		UPDATE iby_payments_all
		 SET positive_pay_file_created_flag = 'Y'
		    WHERE payment_instruction_id = p_payment_instruction_id
		    AND (positive_pay_file_created_flag='N' or positive_pay_file_created_flag is NULL)
		    AND payment_status IN ('ISSUED','PAID');

	    END IF;
	ELSIF upper(p_payment_status) = 'VOIDED' THEN
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'Payment Status is voided ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    END IF;
	    IF upper(p_reselect) = 'NO' THEN
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Reselect Option No ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_ins_csr_2_1;
		FETCH l_pospay_ins_csr_2_1 INTO x_extract_doc;
		CLOSE l_pospay_ins_csr_2_1;

		 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'payment level attribute setting ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		 END IF;
		 UPDATE iby_payments_all
		 SET positive_pay_file_created_flag = 'Y'
		    WHERE payment_instruction_id = p_payment_instruction_id
		    AND (positive_pay_file_created_flag='N' or positive_pay_file_created_flag is NULL)
		    AND payment_status IN ('VOID');

	    ELSE
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Reselect Option Yes ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_ins_csr_2_2;
		FETCH l_pospay_ins_csr_2_2 INTO x_extract_doc;
		CLOSE l_pospay_ins_csr_2_2;

		 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 iby_debug_pub.add(debug_msg => 'payment level attribute setting ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		 END IF;
		 UPDATE iby_payments_all
		 SET positive_pay_file_created_flag = 'Y'
		    WHERE payment_instruction_id = p_payment_instruction_id
		    AND payment_status IN ('VOID');

	    END IF;
	ELSE
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'Payment Status is negotiable and voided ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    END IF;
	    IF upper(p_reselect) = 'NO' THEN
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Reselect Option No ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_ins_csr_3_1;
		FETCH l_pospay_ins_csr_3_1 INTO x_extract_doc;
		CLOSE l_pospay_ins_csr_3_1;

		 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'payment level attribute setting ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		 END IF;
		 UPDATE iby_payments_all
		 SET positive_pay_file_created_flag = 'Y'
		    WHERE payment_instruction_id = p_payment_instruction_id
		    AND (positive_pay_file_created_flag='N' or positive_pay_file_created_flag is NULL)
		    AND payment_status IN ('VOID','ISSUED','PAID');

	    ELSE
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Reselect Option Yes ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_ins_csr_3_2;
		FETCH l_pospay_ins_csr_3_2 INTO x_extract_doc;
		CLOSE l_pospay_ins_csr_3_2;

		 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 iby_debug_pub.add(debug_msg => 'payment level attribute setting ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		 END IF;
		 UPDATE iby_payments_all
		 SET positive_pay_file_created_flag = 'Y'
		    WHERE payment_instruction_id = p_payment_instruction_id
		    AND payment_status IN ('VOID','ISSUED','PAID');

	    END IF;
	END IF;
	--pmt instr not supplied
    ELSE
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    	iby_debug_pub.add(debug_msg => 'Payment Instruction ID NOT supplied ' , debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;
	IF upper(p_payment_status) = 'NEGOTIABLE' THEN
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            iby_debug_pub.add(debug_msg => 'Payment Status is negotiable ' , debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    END IF;
	    IF upper(p_reselect) = 'NO' THEN
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			iby_debug_pub.add(debug_msg => 'Reselect Option No ' , debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
                END IF;
		OPEN l_pospay_appp_csr_1_1(l_from_date,l_to_date);
		FETCH l_pospay_appp_csr_1_1 INTO x_extract_doc;
		CLOSE l_pospay_appp_csr_1_1;

		SELECT pmt.payment_id,pmt.payment_instruction_id
		BULK COLLECT INTO l_paymentid_arr,l_paymentinstrid_arr
		   FROM iby_xml_fd_pmt_1_0_v pmt,
		     iby_payment_profiles ppp,
		     iby_formats_vl ppfformat,
		     ce_bank_accounts ba
		   WHERE pmt.payment_profile_id = ppp.payment_profile_id
		   AND ppp.positive_pay_format_code = ppfformat.format_code
		   AND pmt.internal_bank_account_id = ba.bank_account_id
		   AND ppfformat.format_name = p_format_name
		   AND ba.bank_account_name = p_internal_bank_account_name
		   AND (pmt.positive_pay_file_created_flag='N' or pmt.positive_pay_file_created_flag is NULL)
		   AND pmt.payment_date >= nvl(to_date(l_from_date,    'YYYY/MM/DD HH24:MI:SS'),    pmt.payment_date)
		   AND pmt.payment_date <= nvl(to_date(l_to_date,    'YYYY/MM/DD HH24:MI:SS'),    sysdate)
		   AND pmt.payment_status IN('ISSUED','PAID');

	    ELSE
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		        iby_debug_pub.add(debug_msg => 'Reselect Option Yes ' , debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_appp_csr_1_2(l_from_date,l_to_date);
		FETCH l_pospay_appp_csr_1_2 INTO x_extract_doc;
		CLOSE l_pospay_appp_csr_1_2;

		SELECT pmt.payment_id,pmt.payment_instruction_id
		BULK COLLECT INTO l_paymentid_arr,l_paymentinstrid_arr
		   FROM iby_xml_fd_pmt_1_0_v pmt,
		     iby_payment_profiles ppp,
		     iby_formats_vl ppfformat,
		     ce_bank_accounts ba
		   WHERE pmt.payment_profile_id = ppp.payment_profile_id
		   AND ppp.positive_pay_format_code = ppfformat.format_code
		   AND pmt.internal_bank_account_id = ba.bank_account_id
		   AND ppfformat.format_name = p_format_name
		   AND ba.bank_account_name = p_internal_bank_account_name
		   AND pmt.payment_date >= nvl(to_date(l_from_date,    'YYYY/MM/DD HH24:MI:SS'),    pmt.payment_date)
		   AND pmt.payment_date <= nvl(to_date(l_to_date,    'YYYY/MM/DD HH24:MI:SS'),    sysdate)
		   AND pmt.payment_status IN('ISSUED','PAID');

	    END IF;
	ELSIF upper(p_payment_status) = 'VOIDED' THEN
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		    iby_debug_pub.add(debug_msg => 'Payment Status is voided ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    END IF;
	    IF upper(p_reselect) = 'NO' THEN
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		        iby_debug_pub.add(debug_msg => 'Reselect Option No ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_appp_csr_2_1(l_from_date,l_to_date);
		FETCH l_pospay_appp_csr_2_1 INTO x_extract_doc;
		CLOSE l_pospay_appp_csr_2_1;

		SELECT pmt.payment_id,pmt.payment_instruction_id
		BULK COLLECT INTO l_paymentid_arr,l_paymentinstrid_arr
		   FROM iby_xml_fd_pmt_1_0_v pmt,
		     iby_payment_profiles ppp,
		     iby_formats_vl ppfformat,
		     ce_bank_accounts ba
		   WHERE pmt.payment_profile_id = ppp.payment_profile_id
		   AND ppp.positive_pay_format_code = ppfformat.format_code
		   AND pmt.internal_bank_account_id = ba.bank_account_id
		   AND ppfformat.format_name = p_format_name
		   AND ba.bank_account_name = p_internal_bank_account_name
		   AND (pmt.positive_pay_file_created_flag='N' or pmt.positive_pay_file_created_flag is NULL)
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) >= nvl(to_date(l_from_date,    'YYYY/MM/DD HH24:MI:SS'),    decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date))
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) <= nvl(to_date(l_to_date,    'YYYY/MM/DD HH24:MI:SS'),    sysdate)
		   AND pmt.payment_status IN('VOID');
	    ELSE
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		        iby_debug_pub.add(debug_msg => 'Reselect Option Yes ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_appp_csr_2_2(l_from_date,l_to_date);
		FETCH l_pospay_appp_csr_2_2 INTO x_extract_doc;
		CLOSE l_pospay_appp_csr_2_2;

		SELECT pmt.payment_id,pmt.payment_instruction_id
		BULK COLLECT INTO l_paymentid_arr,l_paymentinstrid_arr
		   FROM iby_xml_fd_pmt_1_0_v pmt,
		     iby_payment_profiles ppp,
		     iby_formats_vl ppfformat,
		     ce_bank_accounts ba
		   WHERE pmt.payment_profile_id = ppp.payment_profile_id
		   AND ppp.positive_pay_format_code = ppfformat.format_code
		   AND pmt.internal_bank_account_id = ba.bank_account_id
		   AND ppfformat.format_name = p_format_name
		   AND ba.bank_account_name = p_internal_bank_account_name
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) >= nvl(to_date(l_from_date,    'YYYY/MM/DD HH24:MI:SS'),    decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date))
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) <= nvl(to_date(l_to_date,    'YYYY/MM/DD HH24:MI:SS'),    sysdate)
		   AND pmt.payment_status IN('VOID');

	    END IF;
	ELSE
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		    iby_debug_pub.add(debug_msg => 'Payment Status is negotiable and voided ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    END IF;
	    IF upper(p_reselect) = 'NO' THEN
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		        iby_debug_pub.add(debug_msg => 'Reselect Option No ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_appp_csr_3_1(l_from_date,l_to_date);
		FETCH l_pospay_appp_csr_3_1 INTO x_extract_doc;
		CLOSE l_pospay_appp_csr_3_1;

		SELECT pmt.payment_id,pmt.payment_instruction_id
		BULK COLLECT INTO l_paymentid_arr,l_paymentinstrid_arr
		   FROM iby_xml_fd_pmt_1_0_v pmt,
		     iby_payment_profiles ppp,
		     iby_formats_vl ppfformat,
		     ce_bank_accounts ba
		   WHERE pmt.payment_profile_id = ppp.payment_profile_id
		   AND ppp.positive_pay_format_code = ppfformat.format_code
		   AND pmt.internal_bank_account_id = ba.bank_account_id
		   AND ppfformat.format_name = p_format_name
		   AND ba.bank_account_name = p_internal_bank_account_name
		   AND (pmt.positive_pay_file_created_flag='N' or pmt.positive_pay_file_created_flag is NULL)
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) >= nvl(to_date(l_from_date,    'YYYY/MM/DD HH24:MI:SS'),    decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date))
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) <= nvl(to_date(l_to_date,    'YYYY/MM/DD HH24:MI:SS'),    sysdate)
		   AND pmt.payment_status IN('VOID','ISSUED','PAID');

	    ELSE
	        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		        iby_debug_pub.add(debug_msg => 'Reselect Option Yes ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
		END IF;
		OPEN l_pospay_appp_csr_3_2(l_from_date,l_to_date);
		FETCH l_pospay_appp_csr_3_2 INTO x_extract_doc;
		CLOSE l_pospay_appp_csr_3_2;

		SELECT pmt.payment_id,pmt.payment_instruction_id
		BULK COLLECT INTO l_paymentid_arr,l_paymentinstrid_arr
		   FROM iby_xml_fd_pmt_1_0_v pmt,
		     iby_payment_profiles ppp,
		     iby_formats_vl ppfformat,
		     ce_bank_accounts ba
		   WHERE pmt.payment_profile_id = ppp.payment_profile_id
		   AND ppp.positive_pay_format_code = ppfformat.format_code
		   AND pmt.internal_bank_account_id = ba.bank_account_id
		   AND ppfformat.format_name = p_format_name
		   AND ba.bank_account_name = p_internal_bank_account_name
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) >= nvl(to_date(l_from_date,    'YYYY/MM/DD HH24:MI:SS'),    decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date))
		   AND decode(pmt.payment_status,'VOID',pmt.void_date,pmt.payment_date) <= nvl(to_date(l_to_date,    'YYYY/MM/DD HH24:MI:SS'),    sysdate)
		   AND pmt.payment_status IN('VOID','ISSUED','PAID');

	    END IF;
	END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'payment level attribute setting ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;


	      iby_debug_pub.add(debug_msg => 'Payment Count : '|| l_paymentid_arr.COUNT,debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      IF (  l_paymentid_arr.COUNT <> 0) THEN
		FOR i IN l_paymentid_arr.FIRST .. l_paymentid_arr.LAST LOOP
			 UPDATE iby_payments_all
			 SET positive_pay_file_created_flag = 'Y'
			    WHERE payment_id = l_paymentid_arr(i);
			 iby_debug_pub.add(debug_msg => 'Payment ID : '|| l_paymentid_arr(i),debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
		END LOOP;
	      ELSE
		        iby_debug_pub.add(debug_msg => 'Payment ID : '|| 'Empty',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

    END IF;



    --payment instruction level attribute setting

    IF p_payment_instruction_id <> -99 THEN

	--if payment instruction is supplied
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add(debug_msg => 'Setting the payment instruction level positive_pay_file_created_flag ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;
	UPDATE iby_pay_instructions_all
	SET positive_pay_file_created_flag='Y'
	WHERE payment_instruction_id = p_payment_instruction_id;

    ELSE
	--if payment instruction is NOT supplied
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        iby_debug_pub.add(debug_msg => 'Setting the payment instruction level positive_pay_file_created_flag ', debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	END IF;


              iby_debug_pub.add(debug_msg => 'Payment Instr Count : '|| l_paymentinstrid_arr.COUNT,debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      IF (  l_paymentinstrid_arr.COUNT <> 0) THEN
			FOR i IN l_paymentinstrid_arr.FIRST .. l_paymentinstrid_arr.LAST LOOP
			   IF (l_paymentinstrid_arr(i) IS NOT NULL ) THEN
			       UPDATE iby_pay_instructions_all ins
			       SET ins.positive_pay_file_created_flag = 'Y'
			       WHERE not exists (SELECT 'N'
						FROM iby_payments_all pmt
						WHERE  nvl(pmt.positive_pay_file_created_flag,'N') = 'N'
							     AND  pmt.payment_status IN('ISSUED',    'PAID')
							     AND  pmt.payment_instruction_id = l_paymentinstrid_arr(i))
			       AND ins.payment_instruction_id = l_paymentinstrid_arr(i);
			       iby_debug_pub.add(debug_msg => 'Payment Instr ID : '|| l_paymentinstrid_arr(i),debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
			    END IF;
			END LOOP;
	      ELSE
		     iby_debug_pub.add(debug_msg => 'Payment Instr ID : '|| 'Empty',debug_level => G_LEVEL_STATEMENT,module => l_Debug_Module);
	      END IF;

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		--Done
	    iby_debug_pub.add(debug_msg => 'After XML query ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
	    iby_debug_pub.add(debug_msg => 'Exit ' || p_payment_instruction_id, debug_level => G_LEVEL_STATEMENT, module => l_Debug_Module);
    END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    EXCEPTION
      WHEN OTHERS THEN
        RAISE;

  END Create_Pos_Pay_Extract_2_0;
-- LKQ POS PAY ISSUE  - PAVAN



  FUNCTION Get_FP_TaxRegistration(p_legal_entity_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_tax_registration    VARCHAR2(2000);
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_key NUMBER;
    l_registration_number VARCHAR2(2000);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_FP_TaxRegistration';

  BEGIN

  iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
	  l_key := p_legal_entity_id;
          /* If the Registration Number is not found in the cache */
          IF (NOT(g_payer_registration_tbl.EXISTS( l_key ))) THEN

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Payer tax reg number not found in the cache for p_legal_entity_id : '||l_key,
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;

	    XLE_UTILITIES_GRP.Get_FP_VATRegistration_LEID
	    (
	      p_api_version                => 1.0,
	      p_init_msg_list              => fnd_api.g_false,
	      p_commit                     => fnd_api.g_false,
	      p_effective_date             => SYSDATE,
	      x_return_status              => l_return_status,
	      x_msg_count                  => l_msg_count,
	      x_msg_data                   => l_msg_data,
	      p_legal_entity_id            => p_legal_entity_id,
	      x_registration_number        => l_tax_registration
	    );


            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Inserting tax reg number l_tax_registration : '|| l_tax_registration ||' in cache for p_legal_entity_id : '||l_key,
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;

            g_payer_registration_tbl(l_key).registration_number:= l_tax_registration;
	    l_registration_number := g_payer_registration_tbl(l_key).registration_number;

          ELSE

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Reg.No found in the cache for p_legal_entity_id : '||l_key,
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;

            l_registration_number := g_payer_registration_tbl(l_key).registration_number;


            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Fetched tax reg number l_registration_number : '|| l_registration_number ||' in cache for p_legal_entity_id : '||l_key,
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;

          END IF;
         iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    RETURN l_registration_number;

  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;

  END Get_FP_TaxRegistration;



  FUNCTION Get_Payee_LegalRegistration(p_vendor_id IN NUMBER,
                                       p_vendor_site_id IN NUMBER,
                                       p_vendor_site_country IN VARCHAR2)
  RETURN VARCHAR2
  IS

    l_legal_information_rec   XLE_THIRDPARTY.LegalInformation_Rec;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);


BEGIN

    -- old code. XLE descoped third party APIs.
    -- current XLE implementation (xlethpab.pls 116.9) only supports
    -- supplier and is only for IT, ES and GR
    -- the implementation is based on 11i PO schema, rather than TCA
    -- basically the API selects PO_VENDORS.NUM_1099 as the
    -- registration number
    XLE_THIRDPARTY.Get_LegalInformation
    (
      p_api_version                => 1.0,
      p_init_msg_list              => fnd_api.g_false,
      p_commit                     => fnd_api.g_false,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data,
      p_business_entity_type       => 'SUPPLIER',
      p_business_entity_id         => p_vendor_id,
      p_business_entity_site_id    => p_vendor_site_id,
      p_country                    => p_vendor_site_country,
      p_legal_function             => 'STIC',
      p_legislative_category       => null,
      x_legal_information_rec      => l_legal_information_rec
    );
/*
 * frzhang 4/6/05. copied from XLE code
 *

--   *****  Business entity type is SUPPLIER *****
-- For Italy
CURSOR  case1_legal_information_cur IS
  SELECT pvs.vendor_site_code,
  	 pv.num_1099,
	 pv.global_attribute2,
	 pv.global_attribute3,
	 pv.standard_industry_class,
	 pvs.address_line1,
         pvs.address_line2,
         pvs.address_line3,
         pvs.city,
         pvs.zip,
	 pvs.province,
	 pvs.country,
	 pvs.state
  FROM   PO_VENDOR_SITES_ALL pvs,
 	 PO_VENDORS pv
  WHERE  pv.vendor_id=p_business_entity_id
 	 AND pvs.vendor_site_id=p_business_entity_site_id
	 AND pvs.country=p_country
	 AND pv.vendor_id=pvs.vendor_id;

-- For Spain, Greece
CURSOR  case2_legal_information_cur IS
  SELECT decode(pvs.country,'ES',pv.vendor_name,'GR',pvs.vendor_site_code),
	 pv.num_1099,
	 pv.global_attribute2,
	 pv.global_attribute3,
	 pv.standard_industry_class,
	 pvs.address_line1,
  	 pvs.address_line2,
         pvs.address_line3,
         pvs.city,
         pvs.zip,
	 pvs.province,
	 pvs.country,
         pvs.state
  FROM   PO_VENDOR_SITES_ALL pvs,
	 PO_VENDORS pv
  WHERE  pv.vendor_id=p_business_entity_id
         AND pvs.tax_reporting_site_flag='Y'
	 AND pvs.country=p_country
	 AND pv.vendor_id=pvs.vendor_id;



BEGIN

  x_msg_count				:=	NULL;
  x_msg_data				:=	NULL;

  -- Standard Start of API savepoint
  SAVEPOINT	Get_LegalInformation;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
  					p_api_version,
   	       	    	                l_api_name,
		    	                G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   --   ========  START OF API BODY  ============

  --   *****  Business entity type is SUPPLIER *****
  IF p_business_entity_type='SUPPLIER' THEN

    -- Legal Information for Italy
    IF p_country='IT' THEN

      OPEN case1_legal_information_cur;
      FETCH case1_legal_information_cur INTO
      	x_legal_information_rec.legal_name,
        x_legal_information_rec.registration_number,
        x_legal_information_rec.date_of_birth,
        x_legal_information_rec.place_of_birth,
	x_legal_information_rec.company_activity_code,
        x_legal_information_rec.address_line1,
        x_legal_information_rec.address_line2,
        x_legal_information_rec.address_line3,
        x_legal_information_rec.city,
        x_legal_information_rec.zip,
        x_legal_information_rec.province,
        x_legal_information_rec.country,
	x_legal_information_rec.state;

        IF case1_legal_information_cur%NOTFOUND THEN
	  --specific xle message under creation fnd message used as workaround
          FND_MESSAGE.SET_NAME('FND','FND_GRANTS_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


      CLOSE case1_legal_information_cur;


    -- Legal Information for Spain and Greece
    ELSIF p_country in ('ES','GR') THEN

      OPEN case2_legal_information_cur;
      FETCH case2_legal_information_cur INTO
      	x_legal_information_rec.legal_name,
        x_legal_information_rec.registration_number,
        x_legal_information_rec.date_of_birth,
        x_legal_information_rec.place_of_birth,
	x_legal_information_rec.company_activity_code,
        x_legal_information_rec.address_line1,
        x_legal_information_rec.address_line2,
        x_legal_information_rec.address_line3,
        x_legal_information_rec.city,
        x_legal_information_rec.zip,
        x_legal_information_rec.province,
        x_legal_information_rec.country,
	x_legal_information_rec.state;

        IF case2_legal_information_cur%NOTFOUND THEN
	  --specific xle message under creation fnd message used as workaround
          FND_MESSAGE.SET_NAME('FND','FND_GRANTS_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


      CLOSE case2_legal_information_cur;

    END IF;

  END IF;


  -- End of API body.
*/


    RETURN l_legal_information_rec.registration_number;

  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;

  END Get_Payee_LegalRegistration;


 /**
   * This function calls an XLE wrapper API which in turn calls an eTax API
   * to get the VAT registration number.
   *
   * The parameter of this function follows the underlying XLE/ZX APIs.
   * See ZX_TCM_EXT_SERVICES_PUB.get_default_tax_reg()
   *
   * frzhang 4/6/05:
   * XLE scoped out third party LE APIs for R12. As for the Vat reg number
   * XLE was just providing a wrapper around ZX APIs, we will call the
   * ZX API directly.
   *
   *
   */
  FUNCTION Get_Payee_TaxRegistration(p_party_id IN NUMBER,
                                     p_supplier_site_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_registration_number   VARCHAR2(50);
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

    --Bug # 7412315
    l_party_type    VARCHAR2(20);
    l_key VARCHAR2(100);
    l_debug_module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Payee_TaxRegistration';

  BEGIN
          iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

  --Bug # 7412315
  --Bug#  8670295
   IF NVL(p_supplier_site_id,'-1') = '-1' then
          l_party_type := 'THIRD_PARTY';
	  l_key := p_party_id || l_party_type ;
          /* If the Registration Number is not found in the cache */
          IF (NOT(g_registration_tbl.EXISTS( l_key ))) THEN
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Reg.No not found in the cache ',
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;
            g_registration_tbl(l_key).registration_number:=
            ZX_API_PUB.get_default_tax_reg
                                   (
                                    p_api_version  => 1.0 ,
                                    p_init_msg_list => NULL,
                                    p_commit=> NULL,
                                    p_validation_level => NULL,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data  => l_msg_data,
                                    p_party_id => p_party_id,
                                    p_party_type => l_party_type,
                                    p_effective_date => null );
            l_registration_number := g_registration_tbl(l_key).registration_number;
          ELSE
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Reg.No found in the cache ',
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;
            l_registration_number := g_registration_tbl(l_key).registration_number;
          END IF;

         else /* Supplier Site Id is not null */
          l_party_type := 'THIRD_PARTY_SITE';
          l_key := p_supplier_site_id || l_party_type ;
          IF (NOT(g_registration_tbl.EXISTS( l_key ))) THEN
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Reg.No not found in the cache for the supplier ',
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;
            g_registration_tbl(l_key).registration_number:=
            NVL(ZX_API_PUB.get_default_tax_reg
                                (
                            p_api_version  => 1.0 ,
                            p_init_msg_list => NULL,
                            p_commit=> NULL,
                            p_validation_level => NULL,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data  => l_msg_data,
                            p_party_id => p_supplier_site_id,
                            p_party_type => l_party_type,
                            p_effective_date => null ),ZX_API_PUB.get_default_tax_reg
                                   (
                                p_api_version  => 1.0 ,
                                p_init_msg_list => NULL,
                                p_commit=> NULL,
                                p_validation_level => NULL,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data  => l_msg_data,
                                p_party_id => p_party_id,
                                p_party_type => 'THIRD_PARTY',
                                p_effective_date => null ));

            l_registration_number := g_registration_tbl(l_key).registration_number;
          ELSE
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  iby_debug_pub.add(debug_msg => 'Reg.No found in the cache for the supplier ',
                  debug_level => G_LEVEL_STATEMENT, module => l_debug_module);
            END IF;
            l_registration_number := g_registration_tbl(l_key).registration_number;
          END IF;
        END IF;

    -- frzhang 4/6/05
    -- call directly to ZX API. copied from XLE code


	/*l_registration_number := ZX_API_PUB.get_default_tax_reg
                                (
                            p_api_version  => 1.0 ,
                            p_init_msg_list => NULL,
                            p_commit=> NULL,
                            p_validation_level => NULL,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data  => l_msg_data,
                            p_party_id => p_party_id,
                            p_party_type => p_party_type,
                            p_effective_date => null );*/  --Commented as part of Bug# 7412315

	--Bug # 7412315
	/*l_registration_number := NVL(ZX_API_PUB.get_default_tax_reg
                                (
                            p_api_version  => 1.0 ,
                            p_init_msg_list => NULL,
                            p_commit=> NULL,
                            p_validation_level => NULL,
                            x_return_status => l_return_status,
                            x_msg_count => l_msg_count,
                            x_msg_data  => l_msg_data,
                            p_party_id => NVL(p_supplier_site_id,p_party_id),
                            p_party_type => l_party_type,
                            p_effective_date => null ),ZX_API_PUB.get_default_tax_reg
                                   (
                                p_api_version  => 1.0 ,
                                p_init_msg_list => NULL,
                                p_commit=> NULL,
                                p_validation_level => NULL,
                                x_return_status => l_return_status,
                                x_msg_count => l_msg_count,
                                x_msg_data  => l_msg_data,
                                p_party_id => p_party_id,
                                p_party_type => 'THIRD_PARTY',
                                p_effective_date => null ));*/


    /* -- XLE descoped third party APIs
    XLE_THIRDPARTY.Get_TP_VATRegistration_PTY
    (
      p_api_version                => 1.0,
      p_init_msg_list              => fnd_api.g_false,
      p_commit                     => fnd_api.g_false,
      p_effective_date             => SYSDATE,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data,
      p_party_id                   => p_party_id,
      p_party_type                 => p_party_type,
      x_registration_number        => l_registration_number
    );
      */
        iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    RETURN l_registration_number;

  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;

  END Get_Payee_TaxRegistration;


  -- the party is the party that is linked to the LE
  -- on the payments
  FUNCTION Get_PayerContact(p_party_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_contactinfo XMLTYPE;
    l_phone_cp_id NUMBER;
    l_fax_cp_id NUMBER;

    l_email VARCHAR2(2000);
    l_url VARCHAR2(2000);

    l_hr_loc_phone VARCHAR2(60);
    l_hr_loc_fax VARCHAR2(60);


    CURSOR l_email_csr (p_owner_table_id IN NUMBER) IS
    SELECT email_address
      FROM hz_contact_points
     WHERE owner_table_name = 'HZ_PARTIES'
       AND owner_table_id = p_owner_table_id
       AND contact_point_type = 'EMAIL'
       AND primary_flag = 'Y'
       AND status = 'A';

    -- bug 6044338.  Fax and telephone numbers in the TCA data model
    -- are stored under the same contact_point_type PHONE.  The
    -- difference is the phone_line_type.  Since they are stored
    -- under the same contact_point_type the assume that there will
    -- only 1 primary phone or fax does not apply.
    -- The extract will display only 1 phone or fax as follows:
    -- 1.  if the primary flag is set for it
    -- 2.  if none of them are the primary contact point, the latest entered.
    CURSOR l_phone_csr (p_owner_table_id IN NUMBER) IS
    SELECT contact_point_id
      FROM (SELECT t.contact_point_id,
                   t.primary_flag,
                   t.phone_line_type,
                   RANK() OVER (PARTITION BY t.phone_line_type ORDER BY t.primary_flag DESC, t.contact_point_id DESC) primary_phone
              FROM hz_contact_points t
             WHERE t.owner_table_name = 'HZ_PARTIES'
               AND t.owner_table_id = p_owner_table_id
               AND t.contact_point_type = 'PHONE'
               AND t.phone_line_type = 'GEN'
               AND t.status = 'A') x
     WHERE x.primary_phone = 1;

    -- bug 6044338.
    CURSOR l_fax_csr (p_owner_table_id IN NUMBER) IS
    SELECT contact_point_id
      FROM (SELECT t.contact_point_id,
                   t.primary_flag,
                   t.phone_line_type,
                   RANK() OVER (PARTITION BY t.phone_line_type ORDER BY t.primary_flag DESC, t.contact_point_id DESC) primary_phone
              FROM hz_contact_points t
             WHERE t.owner_table_name = 'HZ_PARTIES'
               AND t.owner_table_id = p_owner_table_id
               AND t.contact_point_type = 'PHONE'
               AND t.phone_line_type = 'FAX'
               AND t.status = 'A') x
     WHERE x.primary_phone = 1;


    CURSOR l_web_csr (p_owner_table_id IN NUMBER) IS
    SELECT url
      FROM hz_contact_points
     WHERE owner_table_name = 'HZ_PARTIES'
       AND owner_table_id = p_owner_table_id
       AND contact_point_type = 'WEB'
       AND primary_flag = 'Y'
       AND status = 'A';

    CURSOR l_hr_loc_contact_csr (p_party_id IN NUMBER) IS
    SELECT TELEPHONE_NUMBER_1, TELEPHONE_NUMBER_2
      FROM hr_locations_all hr_loc, xle_firstparty_information_v xle_firstparty
     WHERE hr_loc.location_id = xle_firstparty.location_id
       AND xle_firstparty.party_id = p_party_id;

  BEGIN
     iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || G_Debug_Module || '.get_payer_contact'':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => G_Debug_Module || '.get_payer_contact');

	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             iby_debug_pub.add(debug_msg => 'ENTER get_payer_contact',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.get_payer_contact');
            END IF;
     -- Bug 7253633
     -- Checking to make sure that party_id IS NOT NULL
     -- Skip procedure if p_party_id IS NOT NULL;
     IF(p_party_id IS NOT NULL) THEN
     IF (NOT(g_payer_contact_tbl.EXISTS(p_party_id))) THEN
     OPEN l_email_csr (p_party_id);
    FETCH l_email_csr INTO l_email;
    CLOSE l_email_csr;

     OPEN l_phone_csr (p_party_id);
    FETCH l_phone_csr INTO l_phone_cp_id;
    CLOSE l_phone_csr;

     OPEN l_fax_csr (p_party_id);
    FETCH l_fax_csr INTO l_fax_cp_id;
    CLOSE l_fax_csr;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add(debug_msg => 'After getting mail, phone and fax',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.get_payer_contact');
            END IF;
     OPEN l_web_csr (p_party_id);
    FETCH l_web_csr INTO l_url;
    CLOSE l_web_csr;

     OPEN l_hr_loc_contact_csr (p_party_id);
    FETCH l_hr_loc_contact_csr INTO l_hr_loc_phone, l_hr_loc_fax;
    CLOSE l_hr_loc_contact_csr;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add(debug_msg => 'Before XML query',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.get_payer_contact');
            END IF;
    -- the ContactName is left null
    SELECT
      XMLElement("ContactLocators",
        XMLElement("PhoneNumber", nvl(hz_format_phone_v2pub.get_formatted_phone(l_phone_cp_id), l_hr_loc_phone)),
        XMLElement("FaxNumber", nvl(hz_format_phone_v2pub.get_formatted_phone(l_fax_cp_id), l_hr_loc_fax)),
        XMLElement("EmailAddress", l_email),
        XMLElement("Website", l_url)
      )
    INTO g_payer_contact_tbl(p_party_id).l_contactinfo
    FROM dual;
   END IF;
   ELSE
    RETURN null;
   END IF;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add(debug_msg => 'EXIT get_payer_contact',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.get_payer_contact');
            END IF;

     iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || G_Debug_Module || '.get_payer_contact'':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => G_Debug_Module || '.get_payer_contact');
    RETURN g_payer_contact_tbl(p_party_id).l_contactinfo;


  EXCEPTION
    WHEN OTHERS THEN
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           iby_debug_pub.add(debug_msg => 'EXCEPTION -'||sqlerrm,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.get_payer_contact');
            END IF;

     Raise;

  END Get_PayerContact;


-- Add cache for owner_table_id and owner_Table_name, so this gets reduced
-- will give most bang for the buck.

  FUNCTION Get_PayeeContact(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_contactinfo XMLTYPE;
    l_remit_to_loc_id NUMBER;
    l_party_site_id NUMBER;
    l_payee_party_id NUMBER;
    l_owner_table_name VARCHAR2(30);
    l_owner_table_id NUMBER;
    l_phone_cp_id NUMBER;
    l_fax_cp_id NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayeeContact';

    l_email VARCHAR2(2000);
    l_url VARCHAR2(2000);

    CURSOR l_pmt_csr (p_payment_id IN NUMBER) IS
    SELECT remit_to_location_id, party_site_id, payee_party_id
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;

    CURSOR l_email_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT email_address
      FROM hz_contact_points
     WHERE owner_table_name = p_owner_table_name
       AND owner_table_id = p_owner_table_id
       AND contact_point_type = 'EMAIL'
       AND primary_flag = 'Y'
       AND status = 'A';


    -- bug 6044338.  Fax and telephone numbers in the TCA data model
    -- are stored under the same contact_point_type PHONE.  The
    -- difference is the phone_line_type.  Since they are stored
    -- under the same contact_point_type the assume that there will
    -- only 1 primary phone or fax does not apply.
    -- The extract will display only 1 phone or fax as follows:
    -- 1.  if the primary flag is set for it
    -- 2.  if none of them are the primary contact point, the latest entered.
    CURSOR l_phone_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT contact_point_id
      FROM (SELECT t.contact_point_id,
                   t.primary_flag,
                   t.phone_line_type,
                   RANK() OVER (PARTITION BY t.phone_line_type ORDER BY t.primary_flag DESC, t.contact_point_id DESC) primary_phone
              FROM hz_contact_points t
             WHERE t.owner_table_name = p_owner_table_name
               AND t.owner_table_id = p_owner_table_id
               AND t.contact_point_type = 'PHONE'
               AND t.phone_line_type = 'GEN'
               AND t.status = 'A') x
     WHERE x.primary_phone = 1;

    -- bug 6044338.
    CURSOR l_fax_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT contact_point_id
      FROM (SELECT t.contact_point_id,
                   t.primary_flag,
                   t.phone_line_type,
                   RANK() OVER (PARTITION BY t.phone_line_type ORDER BY t.primary_flag DESC, t.contact_point_id DESC) primary_phone
              FROM hz_contact_points t
             WHERE t.owner_table_name = p_owner_table_name
               AND t.owner_table_id = p_owner_table_id
               AND t.contact_point_type = 'PHONE'
               AND t.phone_line_type = 'FAX'
               AND t.status = 'A') x
     WHERE x.primary_phone = 1;

    CURSOR l_web_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT url
      FROM hz_contact_points
     WHERE owner_table_name = p_owner_table_name
       AND owner_table_id = p_owner_table_id
       AND contact_point_type = 'WEB'
       AND primary_flag = 'Y'
       AND status = 'A';

  BEGIN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
     OPEN l_pmt_csr (p_payment_id);
    FETCH l_pmt_csr INTO l_remit_to_loc_id, l_party_site_id, l_payee_party_id;
    CLOSE l_pmt_csr;

    IF l_party_site_id IS NOT NULL THEN
      l_owner_table_name := 'HZ_PARTY_SITES';
      l_owner_table_id := l_party_site_id;
    ELSE
      l_owner_table_name := 'HZ_PARTIES';
      l_owner_table_id := l_payee_party_id;
    END IF;


     OPEN l_email_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_email_csr INTO l_email;
    CLOSE l_email_csr;

     OPEN l_phone_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_phone_csr INTO l_phone_cp_id;
    CLOSE l_phone_csr;

     OPEN l_fax_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_fax_csr INTO l_fax_cp_id;
    CLOSE l_fax_csr;

     OPEN l_web_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_web_csr INTO l_url;
    CLOSE l_web_csr;

    -- the ContactName is left null
    SELECT
      XMLElement("ContactLocators",
        XMLElement("PhoneNumber", hz_format_phone_v2pub.get_formatted_phone(l_phone_cp_id)),
        XMLElement("FaxNumber", hz_format_phone_v2pub.get_formatted_phone(l_fax_cp_id)),
        XMLElement("EmailAddress", l_email),
        XMLElement("Website", l_url)
      )
    INTO l_contactinfo
    FROM dual;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    RETURN l_contactinfo;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END Get_PayeeContact;


  /* Overloaded Function : Citi Perf */
  /* Also adding caching for Payee Contact. Given type of party or party_site
     we will be able to get the email,phone, fax details.*/
  FUNCTION Get_PayeeContact(p_payment_id IN NUMBER
                            ,p_remit_to_location_id IN iby_payments_all.remit_to_location_id%TYPE
			    ,p_party_site_id IN iby_payments_all.party_site_id%TYPE
			    ,p_payee_party_id IN iby_payments_all.payee_party_id%TYPE)
  RETURN XMLTYPE
  IS
    l_contactinfo XMLTYPE;
    l_remit_to_loc_id NUMBER;
    l_party_site_id NUMBER;
    l_payee_party_id NUMBER;
    l_owner_table_name VARCHAR2(30);
    l_owner_table_id NUMBER;
    l_phone_cp_id NUMBER;
    l_fax_cp_id NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayeeContact';

    l_email VARCHAR2(2000);
    l_url VARCHAR2(2000);

    /*
    CURSOR l_pmt_csr (p_payment_id IN NUMBER) IS
    SELECT remit_to_location_id, party_site_id, payee_party_id
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;
     */

    CURSOR l_email_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT email_address
      FROM hz_contact_points
     WHERE owner_table_name = p_owner_table_name
       AND owner_table_id = p_owner_table_id
       AND contact_point_type = 'EMAIL'
       AND primary_flag = 'Y'
       AND status = 'A';


    -- bug 6044338.  Fax and telephone numbers in the TCA data model
    -- are stored under the same contact_point_type PHONE.  The
    -- difference is the phone_line_type.  Since they are stored
    -- under the same contact_point_type the assume that there will
    -- only 1 primary phone or fax does not apply.
    -- The extract will display only 1 phone or fax as follows:
    -- 1.  if the primary flag is set for it
    -- 2.  if none of them are the primary contact point, the latest entered.
    CURSOR l_phone_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT contact_point_id
      FROM (SELECT t.contact_point_id,
                   t.primary_flag,
                   t.phone_line_type,
                   RANK() OVER (PARTITION BY t.phone_line_type ORDER BY t.primary_flag DESC, t.contact_point_id DESC) primary_phone
              FROM hz_contact_points t
             WHERE t.owner_table_name = p_owner_table_name
               AND t.owner_table_id = p_owner_table_id
               AND t.contact_point_type = 'PHONE'
               AND t.phone_line_type = 'GEN'
               AND t.status = 'A') x
     WHERE x.primary_phone = 1;

    -- bug 6044338.
    CURSOR l_fax_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT contact_point_id
      FROM (SELECT t.contact_point_id,
                   t.primary_flag,
                   t.phone_line_type,
                   RANK() OVER (PARTITION BY t.phone_line_type ORDER BY t.primary_flag DESC, t.contact_point_id DESC) primary_phone
              FROM hz_contact_points t
             WHERE t.owner_table_name = p_owner_table_name
               AND t.owner_table_id = p_owner_table_id
               AND t.contact_point_type = 'PHONE'
               AND t.phone_line_type = 'FAX'
               AND t.status = 'A') x
     WHERE x.primary_phone = 1;

    CURSOR l_web_csr (p_owner_table_name IN VARCHAR2, p_owner_table_id IN NUMBER) IS
    SELECT url
      FROM hz_contact_points
     WHERE owner_table_name = p_owner_table_name
       AND owner_table_id = p_owner_table_id
       AND contact_point_type = 'WEB'
       AND primary_flag = 'Y'
       AND status = 'A';

  BEGIN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    /*
     OPEN l_pmt_csr (p_payment_id);
    FETCH l_pmt_csr INTO l_remit_to_loc_id, l_party_site_id, l_payee_party_id;
    CLOSE l_pmt_csr;
    */
    l_remit_to_loc_id := p_remit_to_location_id;
    l_party_site_id := p_party_site_id;
    l_payee_party_id := p_payee_party_id;


    IF l_party_site_id IS NOT NULL THEN
      l_owner_table_name := 'HZ_PARTY_SITES';
      l_owner_table_id := l_party_site_id;

    ELSE
      l_owner_table_name := 'HZ_PARTIES';
      l_owner_table_id := l_payee_party_id;
    END IF;

   -- Before calling cursors check if we have already fetched
   -- the same values
    IF site_contact_tab.EXISTS(l_party_site_id)
    THEN
     -- PARTY SITE DATA EXISTS
     l_email := site_contact_tab(l_party_site_id).l_email;
     l_phone_cp_id := site_contact_tab(l_party_site_id).l_phone_cp_id;
     l_fax_cp_id := site_contact_tab(l_party_site_id).l_fax_cp_id;
     l_url := site_contact_tab(l_party_site_id).l_url;

    ELSIF party_contact_tab.EXISTS(l_payee_party_id)
    THEN
     -- PARTY DATA exists
     l_email := party_contact_tab(l_payee_party_id).l_email;
     l_phone_cp_id := party_contact_tab(l_payee_party_id).l_phone_cp_id;
     l_fax_cp_id := party_contact_tab(l_payee_party_id).l_fax_cp_id;
     l_url := party_contact_tab(l_payee_party_id).l_url;
    ELSE
    -- New values , must fetch from tables.

    OPEN l_email_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_email_csr INTO l_email;
    CLOSE l_email_csr;

     OPEN l_phone_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_phone_csr INTO l_phone_cp_id;
    CLOSE l_phone_csr;

     OPEN l_fax_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_fax_csr INTO l_fax_cp_id;
    CLOSE l_fax_csr;

     OPEN l_web_csr (l_owner_table_name, l_owner_table_id);
    FETCH l_web_csr INTO l_url;
    CLOSE l_web_csr;

      -- Assign values to cache : for party_site or party
      IF l_party_site_id IS NOT NULL THEN

         site_contact_tab(l_party_site_id).l_email := l_email;
         site_contact_tab(l_party_site_id).l_phone_cp_id := l_phone_cp_id;
         site_contact_tab(l_party_site_id).l_fax_cp_id := l_fax_cp_id;
         site_contact_tab(l_party_site_id).l_url := l_url;

      ELSE
         party_contact_tab(l_payee_party_id).l_email := l_email;
         party_contact_tab(l_payee_party_id).l_phone_cp_id := l_phone_cp_id;
         party_contact_tab(l_payee_party_id).l_fax_cp_id := l_fax_cp_id;
         party_contact_tab(l_payee_party_id).l_url := l_url;

      END IF;

    END IF;
    -- the ContactName is left null
    SELECT
      XMLElement("ContactLocators",
        XMLElement("PhoneNumber", hz_format_phone_v2pub.get_formatted_phone(l_phone_cp_id)),
        XMLElement("FaxNumber", hz_format_phone_v2pub.get_formatted_phone(l_fax_cp_id)),
        XMLElement("EmailAddress", l_email),
        XMLElement("Website", l_url)
      )
    INTO l_contactinfo
    FROM dual;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    RETURN l_contactinfo;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END Get_PayeeContact;
  /*End of Overloaded function : Citi Perf*/


  FUNCTION format_hr_address(p_hr_location_id IN NUMBER,
                             p_style_code			IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS

    l_formatted_address           VARCHAR2(2000);
    l_address_line_1              VARCHAR2(240);
    l_address_line_2              VARCHAR2(240);
    l_address_line_3              VARCHAR2(240);
    l_city                        VARCHAR2(30);
    l_postal_code                 VARCHAR2(30);
    l_state                       VARCHAR2(120);
    l_county                      VARCHAR2(120);
    l_country                     VARCHAR2(60);

    CURSOR l_hr_loc_csr (p_hr_location_id IN NUMBER) IS
    SELECT address_line_1, address_line_2, address_line_3,
           town_or_city, region_1, region_2,
           postal_code, country
      FROM hr_locations_all
     WHERE location_id = p_hr_location_id;

  BEGIN

    format_hr_address_C := format_hr_address_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'format_hr_address() entered. count: ' || format_hr_address_C,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.format_hr_address');
	    iby_debug_pub.add(debug_msg => 'p_hr_location_id: ' || p_hr_location_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.format_hr_address');
    END IF;

    IF p_hr_location_id IS NULL THEN
      RETURN NULL;
    END IF;

     OPEN l_hr_loc_csr (p_hr_location_id);
    FETCH l_hr_loc_csr INTO l_address_line_1, l_address_line_2, l_address_line_3,
                            l_city, l_county, l_state, l_postal_code, l_country;
    CLOSE l_hr_loc_csr;

    l_formatted_address := hz_format_pub.format_address_lov(
     p_address_line_1         => l_address_line_1,
     p_address_line_2         => l_address_line_2,
     p_address_line_3         => l_address_line_3,
     p_address_line_4         => NULL,
     p_city                   => l_city,
     p_postal_code            => l_postal_code,
     p_state                  => l_state,
     p_province               => NULL,
     p_county                 => l_county,
     p_country                => l_country,
     p_address_lines_phonetic => NULL
    );

    RETURN l_formatted_address;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END format_hr_address;


 FUNCTION format_hz_address(p_hz_location_id IN NUMBER,
                             p_style_code			IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS

    l_formatted_address           VARCHAR2(4000);
    l_key                         VARCHAR2(2000);

  BEGIN

    format_hz_address_C := format_hz_address_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		    iby_debug_pub.add(debug_msg => 'format_hz_address() entered. count: ' || format_hz_address_C,
				      debug_level => G_LEVEL_STATEMENT,
				      module => G_Debug_Module || '.format_hz_address');
		    iby_debug_pub.add(debug_msg => 'p_hz_location_id: ' || p_hz_location_id,
				      debug_level => G_LEVEL_STATEMENT,
				      module => G_Debug_Module || '.format_hz_address');
    END IF;

    IF p_hz_location_id IS NULL THEN
      RETURN NULL;
    END IF;

    l_key := p_hz_location_id || nvl(p_style_code,'-') ;

    IF (NOT(g_formatted_hz_addr_tbl.EXISTS( l_key ))) THEN
	iby_debug_pub.add(debug_msg => 'Address not found in the cache.
				Executing the Cursor',
				debug_level => G_LEVEL_STATEMENT,
				module => G_Debug_Module || '.format_hz_address');

	 g_formatted_hz_addr_tbl(l_key).formatted_address := hz_format_pub.format_address(
	     p_location_id         => p_hz_location_id,
	     p_style_code          => p_style_code
	    );

        l_formatted_address := g_formatted_hz_addr_tbl(l_key).formatted_address;

     ELSE
           iby_debug_pub.add(debug_msg => 'Address found in the cache.',
				debug_level => G_LEVEL_STATEMENT,
				module => G_Debug_Module || '.format_hz_address');

	   l_formatted_address := g_formatted_hz_addr_tbl(l_key).formatted_address;

     END IF;

    RETURN l_formatted_address;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END format_hz_address;



  -- CE defines bank contact at three levels: bank, branch
  -- and bank account (internal ba only). Each level can have any number of contact
  -- persons. The contact are always based on contact person;
  -- in other words no contact points (email, phone, etc) linking
  -- directly to the bank/branch parties.
  -- CE uses CPUI to create the contact persons. CE always pass
  -- the bank party as the subject party of the relationship to
  -- create the org contact.
  -- A record in the HZ_RELATIONSHIPS is created with the contact
  -- person party as the subject_id, the bank party as the object_id
  -- and relationship_code = 'CONTACT_OF', directional_flag = 'F'.
  -- A record is created in the HZ_ORG_CONTACTS table
  -- with party_relationship_id = relationship_id
  -- A record is created in the HZ_ORG_CONTACT_ROLES table
  -- with the org_contact_id.
  -- There is a 'BANKING_CONTACT' role type, however CE is not
  -- setting any limit or default on the role type.
  -- The CE_CONTACT_ASSIGNMENTS table stores the contact
  -- assignments to the levels.
  --
  -- CE current primary contact person design is not clear.
  -- Also the bank/branch/account level contact filtering
  -- rule is not clear. Omar wanted to defer the bank contacts
  -- in the extract until the requirement arises.
  --
  -- FUNCTION Get_Int_BankContact(p_bank_account_id IN NUMBER)
  -- RETURN XMLTYPE


  FUNCTION Get_Pmt_DocPayableCount(p_payment_id IN NUMBER)
  RETURN NUMBER
  IS
    l_pmt_docpayablecount NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Pmt_DocPayableCount';
    /* Performance Fix : 9184059
    CURSOR l_pmt_docpayablecount_csr (p_payment_id IN NUMBER) IS
    SELECT count(payment_id)
      FROM iby_xml_fd_doc_1_0_v xml_doc_lvl
     WHERE xml_doc_lvl.formatting_payment_id = p_payment_id; --bug 7006504
   */
   /* Perf Function : 9184059*/
   CURSOR l_pmt_docpayablecount_csr (p_payment_id IN NUMBER) IS
    SELECT count(payment_id)
      FROM iby_docs_payable_all xml_doc_lvl
     WHERE xml_doc_lvl.formatting_payment_id = p_payment_id; --bug 7006504

    /* Performance Fix : 9184059
    CURSOR l_docpayablecount_ppr_rpt_csr (p_payment_id IN NUMBER) IS
    SELECT count(payment_id)
      FROM iby_xml_fd_doc_1_0_v xml_doc_lvl
     WHERE xml_doc_lvl.payment_id = p_payment_id; --bug 7459662
     */
    CURSOR l_docpayablecount_ppr_rpt_csr (p_payment_id IN NUMBER) IS
    SELECT count(payment_id)
      FROM iby_docs_payable_all xml_doc_lvl
     WHERE xml_doc_lvl.payment_id = p_payment_id; --bug 7459662
  BEGIN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

  -- Bug 7459662 Begin
  IF G_Extract_Run_Mode = G_EXTRACT_MODE_PPR_RPT THEN
      OPEN  l_docpayablecount_ppr_rpt_csr (p_payment_id);
      FETCH l_docpayablecount_ppr_rpt_csr INTO l_pmt_docpayablecount;
      CLOSE l_docpayablecount_ppr_rpt_csr;

    ELSE
      OPEN  l_pmt_docpayablecount_csr (p_payment_id);
      FETCH l_pmt_docpayablecount_csr INTO l_pmt_docpayablecount;
      CLOSE l_pmt_docpayablecount_csr;

    END IF;
  -- Bug 7459662 End
    /* Commented as part of Bug 7459662
    OPEN l_pmt_docpayablecount_csr(p_payment_id);
    FETCH l_pmt_docpayablecount_csr INTO l_pmt_docpayablecount;
    CLOSE l_pmt_docpayablecount_csr;*/
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    RETURN l_pmt_docpayablecount;

  END Get_Pmt_DocPayableCount;


  FUNCTION Get_Ins_FVFieldsAgg(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_fv_summary_agg XMLTYPE;
    l_fv_treasury_symbol_agg XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Ins_FVFieldsAgg';

    CURSOR l_fv_treasury_symbol_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT XMLAgg(
             XMLElement("TreasurySymbol",
               XMLElement("Name", fv.treasury_symbol),
               XMLElement("Amount",
                 XMLElement("Value", fv.amount),
                 XMLElement("Currency", XMLElement("Code", iby.payment_currency_code))
               )
             )
           )
      FROM fv_tp_ts_amt_data fv, iby_pay_instructions_all iby
     WHERE iby.payment_instruction_id = fv.payment_instruction_id
       AND iby.payment_instruction_id = p_payment_instruction_id;

    CURSOR l_fv_summary_csr (p_payment_instruction_id IN NUMBER,
                             p_fv_treasury_symbol_agg XMLTYPE) IS
    SELECT XMLElement("FederalInstructionInfo",
             XMLElement("TreasurySymbols", p_fv_treasury_symbol_agg),
             XMLElement("ControlNumber", control_number),
             XMLElement("ECSSummaryDosSeqNumber", iby_utility_pvt.get_view_param('FV_ECS_SEQ'))
           )
      FROM fv_summary_consolidate
     WHERE payment_instruction_id = p_payment_instruction_id;

  BEGIN

    IF G_Extract_Run_Mode = G_EXTRACT_MODE_FV_SMMY THEN

       OPEN l_fv_treasury_symbol_csr(p_payment_instruction_id);
      FETCH l_fv_treasury_symbol_csr INTO l_fv_treasury_symbol_agg;
      CLOSE l_fv_treasury_symbol_csr;

       OPEN l_fv_summary_csr(p_payment_instruction_id, l_fv_treasury_symbol_agg);
      FETCH l_fv_summary_csr INTO l_fv_summary_agg;
      CLOSE l_fv_summary_csr;

      RETURN l_fv_summary_agg;

    ELSE
      RETURN NULL;
    END IF;

  END Get_Ins_FVFieldsAgg;


  FUNCTION Get_Ins_PayerInstrAgg(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payerinstr_agg XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Ins_PayerInstrAgg';
    /* perf bug- 6763515 */


    -- for payment format: normal and reprint entire instruction
    CURSOR l_payerinstr_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT XMLAgg(xml_pmt_lvl.payment)
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl,
           IBY_PAY_INSTRUCTIONS_ALL ins
     WHERE
           xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_instruction_id = xml_pmt_lvl.payment_instruction_id
       AND ((xml_pmt_lvl.payment_status in ('INSTRUCTION_CREATED',
            'VOID_BY_SETUP', 'VOID_BY_OVERFLOW') AND ins.process_type = 'STANDARD') OR
            ins.process_type = 'IMMEDIATE');

    -- for payment format: reprint individual and ranges
    CURSOR l_payerinstr_reprt_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT XMLAgg(xml_pmt_lvl.payment)
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl,
           IBY_PAY_INSTRUCTIONS_ALL ins
     WHERE
           xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_instruction_id = xml_pmt_lvl.payment_instruction_id
       AND ((xml_pmt_lvl.payment_status in ('READY_TO_REPRINT',
            'VOID_BY_SETUP_REPRINT', 'VOID_BY_OVERFLOW_REPRINT') AND ins.process_type = 'STANDARD') OR
            ins.process_type = 'IMMEDIATE');

    -- for payment instruction register
    -- we are extract payments in all statuses
    CURSOR l_payerinstr_rpt_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT XMLAgg(xml_pmt_lvl.payment)
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl
     WHERE
           xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id;

    -- for other auxiliary formats
    CURSOR l_payerinstr_aux_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT XMLAgg(xml_pmt_lvl.payment)
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl
     WHERE
           xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
       AND xml_pmt_lvl.payment_status in ('INSTRUCTION_CREATED', 'READY_TO_REPRINT',
            'SUBMITTED_FOR_PRINTING', 'FORMATTED', 'TRANSMITTED', 'ISSUED', 'PAID');

    -- for separate remittance advice electronic delivery: email and fax
    CURSOR l_payerinstr_sra_ele_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT XMLAgg(xml_pmt_lvl.payment)
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl
     WHERE
           xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
       AND xml_pmt_lvl.payment_id = G_Extract_Run_Payment_id;
       -- note the status qualification is done in Java CP main driver cursor

    -- for separate remittance advice print delivery
    CURSOR l_payerinstr_sra_prt_csr (p_payment_instruction_id IN NUMBER, p_from_pmt_ref IN NUMBER, p_to_pmt_ref IN NUMBER) IS
    SELECT XMLAgg(xml_pmt_lvl.payment)
      FROM
           iby_xml_fd_pmt_1_0_v xml_pmt_lvl
     WHERE
           xml_pmt_lvl.payment_instruction_id = p_payment_instruction_id
       AND xml_pmt_lvl.payment_reference_number between nvl(p_from_pmt_ref,xml_pmt_lvl.payment_reference_number)
                                               and nvl(p_to_pmt_ref,xml_pmt_lvl.payment_reference_number)
       AND (Get_SRA_Attribute(xml_pmt_lvl.payment_id, G_SRA_REQ_FLAG_ATTR) = 'Y' OR xml_pmt_lvl.payment_status ='VOID_BY_OVERFLOW')
       AND Get_SRA_Attribute(xml_pmt_lvl.payment_id, G_SRA_DELIVERY_METHOD_ATTR) = G_SRA_DELIVERY_METHOD_PRINTED
       AND xml_pmt_lvl.payment_status in ('INSTRUCTION_CREATED', 'READY_TO_REPRINT',
            'SUBMITTED_FOR_PRINTING', 'FORMATTED', 'TRANSMITTED', 'ISSUED', 'PAID','VOID_BY_OVERFLOW');


    CURSOR l_rep_debug_pmt_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT ext_pmt_v.payment_id, ext_pmt_v.paper_document_number, ext_pmt_v.payment_status
      FROM
           IBY_EXT_FD_PMT_1_0_V ext_pmt_v,
           IBY_PAY_INSTRUCTIONS_ALL ins
     WHERE
           ext_pmt_v.payment_instruction_id = p_payment_instruction_id
       AND ins.payment_instruction_id = ext_pmt_v.payment_instruction_id;

    CURSOR l_rep_debug_ins_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT ins.payment_instruction_status
      FROM
           IBY_PAY_INSTRUCTIONS_ALL ins
     WHERE
           ins.payment_instruction_id = p_payment_instruction_id;


    l_rep_ins_st     VARCHAR2(30);

  BEGIN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    IF G_Extract_Run_Mode is null OR G_Extract_Run_Mode = G_EXTRACT_MODE_PMT THEN


      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Extract mode is G_EXTRACT_MODE_PMT. ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);

	      iby_debug_pub.add(debug_msg => 'For reprint debugging: ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;

      /* PERF BUG- 6763515 */
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       OPEN l_rep_debug_ins_csr (p_payment_instruction_id);
	      FETCH l_rep_debug_ins_csr INTO l_rep_ins_st;
	      CLOSE l_rep_debug_ins_csr;

	      iby_debug_pub.add(debug_msg => 'instruction id: ' || p_payment_instruction_id
				|| ', instruction status: ' || l_rep_ins_st,
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);

	      iby_debug_pub.add(debug_msg => 'payment id, paper document number, payment status for all payments in the instruction: ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
	END IF;
      /* PERF BUG- 6763515 */
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FOR l_payment IN l_rep_debug_pmt_csr(p_payment_instruction_id) LOOP

		iby_debug_pub.add(debug_msg => 'payment_id: ' || l_payment.payment_id
				  || ', paper_document_number: ' || l_payment.paper_document_number
				  || ', payment_status: '  ||  l_payment.payment_status,
				  debug_level => G_LEVEL_STATEMENT,
				  module => l_Debug_Module);

	      END LOOP;
      END IF;



      IF nvl(G_Is_Reprint, 'N') = 'N' THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          iby_debug_pub.add(debug_msg => 'Before executing the cursor l_payerinstr_csr ',
				  debug_level => G_LEVEL_STATEMENT,
				  module => l_Debug_Module);
	     END IF;
			OPEN l_payerinstr_csr (p_payment_instruction_id);
		       FETCH l_payerinstr_csr INTO l_payerinstr_agg;
		       CLOSE l_payerinstr_csr;
	     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          iby_debug_pub.add(debug_msg => 'After executing the cursor l_payerinstr_csr ',
				  debug_level => G_LEVEL_STATEMENT,
				  module => l_Debug_Module);
	     END IF;

      ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          iby_debug_pub.add(debug_msg => 'Before executing the cursor l_payerinstr_reprt_csr ',
				  debug_level => G_LEVEL_STATEMENT,
				  module => l_Debug_Module);
	     END IF;
			OPEN l_payerinstr_reprt_csr (p_payment_instruction_id);
		       FETCH l_payerinstr_reprt_csr INTO l_payerinstr_agg;
		       CLOSE l_payerinstr_reprt_csr;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          iby_debug_pub.add(debug_msg => 'After executing the cursor l_payerinstr_reprt_csr ',
				  debug_level => G_LEVEL_STATEMENT,
				  module => l_Debug_Module);
	     END IF;

      END IF;

    ELSIF G_Extract_Run_Mode = G_EXTRACT_MODE_AUX THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Extract mode is G_EXTRACT_MODE_AUX. ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
       OPEN l_payerinstr_aux_csr (p_payment_instruction_id);
      FETCH l_payerinstr_aux_csr INTO l_payerinstr_agg;
      CLOSE l_payerinstr_aux_csr;

    ELSIF G_Extract_Run_Mode = G_EXTRACT_MODE_PI_RPT THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Extract mode is G_EXTRACT_MODE_PI_RPT. ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
       OPEN l_payerinstr_rpt_csr (p_payment_instruction_id);
      FETCH l_payerinstr_rpt_csr INTO l_payerinstr_agg;
      CLOSE l_payerinstr_rpt_csr;

    ELSIF G_Extract_Run_Mode = G_EXTRACT_MODE_SRA THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Extract mode is G_EXTRACT_MODE_SRA. ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;

      IF G_Extract_Run_Delivery_Method = G_SRA_DELIVERY_METHOD_PRINTED THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'SRA Delivery method is printed. ',
				  debug_level => G_LEVEL_STATEMENT,
				  module => l_Debug_Module);
        END IF;

         OPEN l_payerinstr_sra_prt_csr (p_payment_instruction_id, G_Extract_Run_From_Pmt_Ref, G_Extract_Run_To_Pmt_Ref);
        FETCH l_payerinstr_sra_prt_csr INTO l_payerinstr_agg;
        CLOSE l_payerinstr_sra_prt_csr;

      ELSIF G_Extract_Run_Delivery_Method = G_SRA_DELIVERY_METHOD_EMAIL OR
            G_Extract_Run_Delivery_Method = G_SRA_DELIVERY_METHOD_FAX   THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		iby_debug_pub.add(debug_msg => 'SRA Delivery method is Email/Fax. ',
				  debug_level => G_LEVEL_STATEMENT,
				  module => l_Debug_Module);
        END IF;

         OPEN l_payerinstr_sra_ele_csr (p_payment_instruction_id);
        FETCH l_payerinstr_sra_ele_csr INTO l_payerinstr_agg;
        CLOSE l_payerinstr_sra_ele_csr;

      END IF;

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    IF l_payerinstr_agg is null THEN
	     iby_debug_pub.add(debug_msg => 'After fetch from payer instrument cursor. l_payerinstr_agg is null',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);

	    ELSE
	     iby_debug_pub.add(debug_msg => 'After fetch from payer instrument cursor. l_payerinstr_agg is not null',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);

	    END IF;

	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    RETURN l_payerinstr_agg;
  EXCEPTION
       WHEN OTHERS THEN
          	    iby_debug_pub.add(debug_msg => 'EXECPTION OCCURED IN : '  || l_Debug_Module || sqlerrm ,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
       RAISE;
  END Get_Ins_PayerInstrAgg;

  FUNCTION Get_Payer(p_legal_entity_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payer XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Payer';
    CURSOR l_payer_csr (p_legal_entity_id IN NUMBER) IS
    SELECT payer
      FROM iby_xml_fd_payer_1_0_v
     WHERE legal_entity_id = p_legal_entity_id;

  BEGIN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;
    Get_Payer_C := Get_Payer_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Get_Payer() entered. count: ' || Get_Payer_C,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Payer');
	    iby_debug_pub.add(debug_msg => 'p_legal_entity_id: ' || p_legal_entity_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Payer');
    END IF;

    IF p_legal_entity_id IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN l_payer_csr (p_legal_entity_id);
    FETCH l_payer_csr INTO l_payer;
    CLOSE l_payer_csr;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;

    RETURN l_payer;

  END Get_Payer;


  FUNCTION Get_PayerBankAccount(p_bank_account_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payer_ba XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayerBankAccount';
    CURSOR l_payer_ba_csr (p_bank_account_id IN NUMBER) IS
    SELECT int_bank_account
      FROM iby_xml_fd_prba_1_0_v
     WHERE bank_account_id = p_bank_account_id;

  BEGIN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;
    Get_PayerBankAccount_C := Get_PayerBankAccount_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Get_PayerBankAccount() entered. count: ' || Get_PayerBankAccount_C,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_PayerBankAccount');
	    iby_debug_pub.add(debug_msg => 'p_bank_account_id: ' || p_bank_account_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_PayerBankAccount');
    END IF;
    IF p_bank_account_id IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN l_payer_ba_csr (p_bank_account_id);
    FETCH l_payer_ba_csr INTO l_payer_ba;
    CLOSE l_payer_ba_csr;


      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;
    RETURN l_payer_ba;

  END Get_PayerBankAccount;


  FUNCTION Get_Payer_Denorm(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payer XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Payer_Denorm';
    CURSOR l_payer_csr (p_payment_id IN NUMBER) IS
    SELECT payer
      FROM iby_xml_fd_payer_1_0_v
     WHERE payment_id = p_payment_id;

  BEGIN

     iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;
    Get_Payer_C := Get_Payer_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Get_Payer_Denorm() entered. count: ' || Get_Payer_C,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Payer');
	    iby_debug_pub.add(debug_msg => 'p_payment_id: ' || p_payment_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Payer');
    END IF;

    OPEN l_payer_csr (p_payment_id);
    FETCH l_payer_csr INTO l_payer;
    CLOSE l_payer_csr;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;

     iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN l_payer;

  END Get_Payer_Denorm;


  FUNCTION Get_PayerBankAccount_Denorm(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payer_ba XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayerBankAccount_Denorm';
    CURSOR l_payer_ba_csr (p_payment_id IN NUMBER) IS
    SELECT int_bank_account
      FROM iby_xml_fd_prba_1_0_v
     WHERE payment_id = p_payment_id;

  BEGIN

      iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;
    Get_PayerBankAccount_C := Get_PayerBankAccount_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Get_PayerBankAccount() entered. count: ' || Get_PayerBankAccount_C,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_PayerBankAccount');
	    iby_debug_pub.add(debug_msg => 'p_payment_id: ' || p_payment_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_PayerBankAccount');
    END IF;
    OPEN l_payer_ba_csr (p_payment_id);
    FETCH l_payer_ba_csr INTO l_payer_ba;
    CLOSE l_payer_ba_csr;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;

     iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN l_payer_ba;

  END Get_PayerBankAccount_Denorm;


  FUNCTION Get_PayerIns_Denorm(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payment_id NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayerIns_Denorm';
    CURSOR l_ins_payment_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT payment_id
      FROM iby_payments_all
     WHERE payment_instruction_id = p_payment_instruction_id
       AND ROWNUM = 1;

  BEGIN
    iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;

    OPEN l_ins_payment_csr (p_payment_instruction_id);
    FETCH l_ins_payment_csr INTO l_payment_id;
    CLOSE l_ins_payment_csr;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;

     iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN Get_Payer_Denorm(l_payment_id);

  END Get_PayerIns_Denorm;


  FUNCTION Get_PayerBankAccountIns_Denorm(p_payment_instruction_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payment_id NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayerBankAccountIns_Denorm';

    /*Bug 8662990 - sort by payment_id to get a non void-by-overflow payment*/
    CURSOR l_ins_payment_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT min(payment_id)
      FROM iby_payments_all
     WHERE payment_instruction_id = p_payment_instruction_id;

  BEGIN
      iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;

    OPEN l_ins_payment_csr (p_payment_instruction_id);
    FETCH l_ins_payment_csr INTO l_payment_id;
    CLOSE l_ins_payment_csr;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN Get_PayerBankAccount_Denorm(l_payment_id);

  END Get_PayerBankAccountIns_Denorm;


  FUNCTION Get_Ins_AccountSettingsAgg(p_bep_account_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_acctsettings_agg XMLTYPE;

    CURSOR l_acctsettings_csr (p_bep_account_id IN NUMBER) IS
    SELECT XMLAgg(account_setting)
      FROM iby_xml_fd_acct_settings_1_0_v
     WHERE bep_account_id = p_bep_account_id;

  BEGIN

    OPEN l_acctsettings_csr (p_bep_account_id);
    FETCH l_acctsettings_csr INTO l_acctsettings_agg;
    CLOSE l_acctsettings_csr;

    RETURN l_acctsettings_agg;

  END Get_Ins_AccountSettingsAgg;



  FUNCTION Get_Pmt_DocPayableAgg(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_docpayable_agg XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Pmt_DocPayableAgg';

    CURSOR l_docpayable_csr (p_payment_id IN NUMBER) IS
    SELECT XMLAgg(doc_payable)
      FROM iby_xml_fd_doc_1_0_v
     WHERE formatting_payment_id = p_payment_id        --bug 7006504
       AND document_status <> 'REMOVED';

    -- for ppr report we need to filter the docs by MOAC accessibility check
    CURSOR l_docpayable_ppr_rpt_csr (p_payment_id IN NUMBER) IS
    SELECT XMLAgg(doc_payable)
      FROM iby_xml_fd_doc_1_0_v xml_doc, iby_docs_payable_all doc, ce_security_profiles_v ce_sp
     WHERE xml_doc.payment_id = p_payment_id        --bug 7459662
       AND xml_doc.document_payable_id = doc.document_payable_id
       AND ce_sp.organization_type = doc.org_type
       AND ce_sp.organization_id = doc.org_id
       AND xml_doc.document_status <> 'REMOVED';

  BEGIN
            iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);

	    iby_debug_pub.add(debug_msg => 'input p_payment_id: ' || p_payment_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;

    IF G_Extract_Run_Mode = G_EXTRACT_MODE_PPR_RPT THEN
      OPEN  l_docpayable_ppr_rpt_csr (p_payment_id);
      FETCH l_docpayable_ppr_rpt_csr INTO l_docpayable_agg;
      CLOSE l_docpayable_ppr_rpt_csr;

    ELSE
      OPEN  l_docpayable_csr (p_payment_id);
      FETCH l_docpayable_csr INTO l_docpayable_agg;
      CLOSE l_docpayable_csr;

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    RETURN l_docpayable_agg;
  EXCEPTION
       WHEN OTHERS THEN
          	    iby_debug_pub.add(debug_msg => 'EXECPTION OCCURED IN : '  || l_Debug_Module || sqlerrm ,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
       RAISE;
  END Get_Pmt_DocPayableAgg;


  FUNCTION Get_Payee(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payee XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Payee';
    l_pmt_func VARCHAR2(1);

    CURSOR l_pmt_func_csr (p_payment_id IN NUMBER) IS
    SELECT nvl(employee_payment_flag, 'N')
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;

    CURSOR l_payee_csr (p_payment_id IN NUMBER) IS
    SELECT payee
      FROM iby_xml_fd_payee_1_0_v
     WHERE payment_id = p_payment_id;

    CURSOR l_payeem_csr (p_payment_id IN NUMBER) IS
    SELECT payee
      FROM iby_xml_fd_payeem_1_0_v
     WHERE payment_id = p_payment_id;

  BEGIN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    OPEN l_pmt_func_csr (p_payment_id);
    FETCH l_pmt_func_csr INTO l_pmt_func;
    CLOSE l_pmt_func_csr;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Before the condition - '  || '  l_pmt_func:' || l_pmt_func,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    IF l_pmt_func = 'Y' AND G_May_Need_HR_Masking THEN

      OPEN l_payeem_csr (p_payment_id);
      FETCH l_payeem_csr INTO l_payee;
      CLOSE l_payeem_csr;

    ELSE

      OPEN l_payee_csr (p_payment_id);
      FETCH l_payee_csr INTO l_payee;
      CLOSE l_payee_csr;

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    RETURN l_payee;

  END Get_Payee;

  /*Perf Fixes : Citi Will add bug tag soon */
  /* Overloaded Function */


  FUNCTION Get_Payee(p_payment_id IN NUMBER,
                     p_pmt_func IN VARCHAR2)
  RETURN XMLTYPE
  IS
    l_payee XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Payee';
    l_pmt_func VARCHAR2(1);

    CURSOR l_pmt_func_csr (p_payment_id IN NUMBER) IS
    SELECT nvl(employee_payment_flag, 'N')
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;

    CURSOR l_payee_csr (p_payment_id IN NUMBER) IS
    SELECT payee
      FROM iby_xml_fd_payee_1_0_v
     WHERE payment_id = p_payment_id;

    CURSOR l_payeem_csr (p_payment_id IN NUMBER) IS
    SELECT payee
      FROM iby_xml_fd_payeem_1_0_v
     WHERE payment_id = p_payment_id;

  BEGIN
    iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    /* Will pass through view
    OPEN l_pmt_func_csr (p_payment_id);
    FETCH l_pmt_func_csr INTO l_pmt_func;
    CLOSE l_pmt_func_csr;
    */
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Before the condition - '  || '  p_pmt_func:' || l_pmt_func,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    IF p_pmt_func = 'Y' AND G_May_Need_HR_Masking THEN

      OPEN l_payeem_csr (p_payment_id);
      FETCH l_payeem_csr INTO l_payee;
      CLOSE l_payeem_csr;

    ELSE

      OPEN l_payee_csr (p_payment_id);
      FETCH l_payee_csr INTO l_payee;
      CLOSE l_payee_csr;

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
       iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    RETURN l_payee;

  END Get_Payee;
 /* End of overloaded function */


  /* TPP - Start */
  FUNCTION Get_InvPayee(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payee XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Payee';

    CURSOR l_payee_csr (p_payment_id IN NUMBER) IS
    SELECT payee
      FROM iby_xml_fd_invpayee_1_0_v
     WHERE payment_id = p_payment_id;

  BEGIN
             iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

      OPEN l_payee_csr (p_payment_id);
      FETCH l_payee_csr INTO l_payee;
      CLOSE l_payee_csr;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
              iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

    RETURN l_payee;

  END Get_InvPayee;



  FUNCTION get_rel_add_info(
   payee_party_id IN NUMBER,
   supplier_site_id IN NUMBER,
   inv_payee_party_id IN NUMBER,
   inv_supplier_site_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_rel_add_info VARCHAR2(255);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.get_rel_add_info';

    CURSOR l_add_info_csr (
   l_party_id IN NUMBER,
   l_supplier_site_id IN NUMBER,
   l_remit_party_id IN NUMBER,
   l_remit_supplier_site_id IN NUMBER) IS
                        SELECT irel.additional_information
			FROM iby_ext_payee_relationships irel
			WHERE irel.party_id = l_party_id
			AND irel.supplier_site_id = l_supplier_site_id
			AND irel.remit_party_id = l_remit_party_id
			AND irel.remit_supplier_site_id = l_remit_supplier_site_id
			AND irel.active = 'Y'
			AND to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') BETWEEN (to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00') AND (to_char(nvl(irel.to_date,sysdate),   'YYYY-MM-DD') || ' 23:59:59')
			;

  BEGIN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

      OPEN l_add_info_csr (inv_payee_party_id, inv_supplier_site_id, payee_party_id, supplier_site_id);
      FETCH l_add_info_csr INTO l_rel_add_info;
      CLOSE l_add_info_csr;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    RETURN l_rel_add_info;

  END get_rel_add_info;





FUNCTION get_relship_id(
   payee_party_id IN NUMBER,
   supplier_site_id IN NUMBER,
   inv_payee_party_id IN NUMBER,
   inv_supplier_site_id IN NUMBER)
  RETURN NUMBER
  IS
    l_relship_id NUMBER := -1;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.get_relship_id';

   CURSOR l_relshipid_csr (
   l_party_id IN NUMBER,
   l_supplier_site_id IN NUMBER,
   l_remit_party_id IN NUMBER,
   l_remit_supplier_site_id IN NUMBER) IS
                        SELECT irel.relationship_id
			FROM iby_ext_payee_relationships irel
			WHERE irel.party_id = l_party_id
			AND irel.supplier_site_id = l_supplier_site_id
			AND irel.remit_party_id = l_remit_party_id
			AND irel.remit_supplier_site_id = l_remit_supplier_site_id
			AND irel.active = 'Y'
			AND to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') BETWEEN (to_char(irel.from_date,   'YYYY-MM-DD') || ' 00:00:00') AND (to_char(nvl(irel.to_date,sysdate),   'YYYY-MM-DD') || ' 23:59:59')
			;

  BEGIN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

      OPEN l_relshipid_csr (inv_payee_party_id, inv_supplier_site_id, payee_party_id, supplier_site_id);
      FETCH l_relshipid_csr INTO l_relship_id;
      CLOSE l_relshipid_csr;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    RETURN l_relship_id;

  END get_relship_id;
  /* TPP - End */


  FUNCTION Get_PayeeBankAccount(p_payment_id IN NUMBER, p_external_bank_account_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payee_ba XMLTYPE;
    l_pmt_func VARCHAR2(1);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayeeBankAccount';

    CURSOR l_pmt_func_csr (p_payment_id IN NUMBER) IS
    SELECT nvl(employee_payment_flag, 'N')
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;

    CURSOR l_payee_ba_csr (p_external_bank_account_id IN NUMBER) IS
    SELECT ext_bank_account
      FROM iby_xml_fd_peba_1_0_v
     WHERE bank_account_id = p_external_bank_account_id;

    CURSOR l_payee_bam_csr (p_external_bank_account_id IN NUMBER) IS
    SELECT ext_bank_account
      FROM iby_xml_fd_pebam_1_0_v
     WHERE bank_account_id = p_external_bank_account_id;

  BEGIN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    -- Added this as a workaround for bug 5293384
    -- The new behavior is this procedure will always be called
    IF (p_external_bank_account_id IS NULL) THEN
	RETURN NULL;
    end if;

    OPEN l_pmt_func_csr (p_payment_id);
    FETCH l_pmt_func_csr INTO l_pmt_func;
    CLOSE l_pmt_func_csr;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Before the condition: '  || ' l_pmt_func:'|| l_pmt_func,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
    IF l_pmt_func = 'Y' AND G_May_Need_HR_Masking THEN

      OPEN l_payee_bam_csr (p_external_bank_account_id);
      FETCH l_payee_bam_csr INTO l_payee_ba;
      CLOSE l_payee_bam_csr;

    ELSE

      OPEN l_payee_ba_csr (p_external_bank_account_id);
      FETCH l_payee_ba_csr INTO l_payee_ba;
      CLOSE l_payee_ba_csr;

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    RETURN l_payee_ba;

  END Get_PayeeBankAccount;


  FUNCTION Get_PayeeBankAccount_Denorm(p_payment_id IN NUMBER, p_external_bank_account_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_payee_ba XMLTYPE;
    l_pmt_func VARCHAR2(1);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayeeBankAccount_Denorm';

    CURSOR l_pmt_func_csr (p_payment_id IN NUMBER) IS
    SELECT nvl(employee_payment_flag, 'N')
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;

    CURSOR l_payee_ba_csr (p_payment_id IN NUMBER) IS
    SELECT ext_bank_account
      FROM iby_xml_fd_peba_1_0_vd
     WHERE payment_id = p_payment_id;

    CURSOR l_payee_bam_csr (p_payment_id IN NUMBER) IS
    SELECT ext_bank_account
      FROM iby_xml_fd_pebam_1_0_vd
     WHERE payment_id = p_payment_id;

  BEGIN

            iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'ENTER: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;
    -- Added this as a workaround for bug 5293384
    -- The new behavior is this procedure will always be called
    IF (p_external_bank_account_id IS NULL) THEN
	    RETURN NULL;
    end if;

    OPEN l_pmt_func_csr (p_payment_id);
    FETCH l_pmt_func_csr INTO l_pmt_func;
    CLOSE l_pmt_func_csr;
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Before  IF : -- l_pmt_func: ' || l_pmt_func ,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;
    IF l_pmt_func = 'Y' AND G_May_Need_HR_Masking THEN

      OPEN l_payee_bam_csr (p_payment_id);
      FETCH l_payee_bam_csr INTO l_payee_ba;
      CLOSE l_payee_bam_csr;

    ELSE

      OPEN l_payee_ba_csr (p_payment_id);
      FETCH l_payee_ba_csr INTO l_payee_ba;
      CLOSE l_payee_ba_csr;

    END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'EXIT: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;
          iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN l_payee_ba;

  END Get_PayeeBankAccount_Denorm;


  /*Overloaded Function .
   For perf issue : Citi. */
  FUNCTION Get_PayeeBankAccount_Denorm(p_payment_id IN NUMBER
                                       , p_external_bank_account_id IN NUMBER
				       ,p_pmt_func IN VARCHAR2)
  RETURN XMLTYPE
  IS
    l_payee_ba XMLTYPE;
    l_pmt_func VARCHAR2(1);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_PayeeBankAccount_Denorm';

    CURSOR l_pmt_func_csr (p_payment_id IN NUMBER) IS
    SELECT nvl(employee_payment_flag, 'N')
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;

    CURSOR l_payee_ba_csr (p_payment_id IN NUMBER) IS
    SELECT ext_bank_account
      FROM iby_xml_fd_peba_1_0_vd
     WHERE payment_id = p_payment_id;

    CURSOR l_payee_bam_csr (p_payment_id IN NUMBER) IS
    SELECT ext_bank_account
      FROM iby_xml_fd_pebam_1_0_vd
     WHERE payment_id = p_payment_id;

  BEGIN

      iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'ENTER: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;
    -- Added this as a workaround for bug 5293384
    -- The new behavior is this procedure will always be called
    IF (p_external_bank_account_id IS NULL) THEN
	    RETURN NULL;
    end if;
    /* For 9184059
    OPEN l_pmt_func_csr (p_payment_id);
    FETCH l_pmt_func_csr INTO l_pmt_func;
    CLOSE l_pmt_func_csr;
    */
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Before  IF : -- l_pmt_func: ' || l_pmt_func ,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;
    IF p_pmt_func = 'Y' AND G_May_Need_HR_Masking THEN

      OPEN l_payee_bam_csr (p_payment_id);
      FETCH l_payee_bam_csr INTO l_payee_ba;
      CLOSE l_payee_bam_csr;

    ELSE

      OPEN l_payee_ba_csr (p_payment_id);
      FETCH l_payee_ba_csr INTO l_payee_ba;
      CLOSE l_payee_ba_csr;

    END IF;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'EXIT: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;
    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN l_payee_ba;

  END Get_PayeeBankAccount_Denorm;
/*End of Overloaded Function*/

  FUNCTION Get_Doc_DocLineAgg(p_document_payable_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_docline_agg XMLTYPE;
    l_conc_invalid_chars VARCHAR2(50);
    l_conc_replacement_chars VARCHAR2(50);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Doc_DocLineAgg';

    -- IBY_XML_FD_DOCLINE_1_0_V is obselete fz 8/30/2005
    -- Bug 6321384 Added nvl to check for NULL values
    CURSOR l_docline_csr (p_document_payable_id IN NUMBER,
                          p_conc_invalid_chars IN VARCHAR2,
			  p_conc_replacement_chars IN VARCHAR2) IS
    SELECT XMLAgg(
             XMLElement("DocumentPayableLine",
               XMLElement("LineNumber", ail.line_number),
               XMLElement("PONumber", ph.segment1),
               XMLElement("LineType",
                 XMLElement("Code", ail.line_type_lookup_code),
                 XMLElement("Meaning", null)),
               XMLElement("LineDescription", TRANSLATE(ail.description, p_conc_invalid_chars, p_conc_replacement_chars)),
               XMLElement("LineGrossAmount",
                 XMLElement("Value", ail.amount),
                 XMLElement("Currency", XMLElement("Code", ibydoc.document_currency_code))),
               XMLElement("UnitPrice", ail.unit_price),
               XMLElement("Quantity", ail.quantity_invoiced),
               XMLElement("UnitOfMeasure",
                 XMLElement("Code", ail.unit_meas_lookup_code),
                 XMLElement("Meaning", null)),
               XMLElement("Tax",
                 XMLElement("TaxCode", ail.tax),
                 XMLElement("TaxRate", ail.tax_rate)
               ),
               IBY_FD_EXTRACT_EXT_PUB.Get_Docline_Ext_Agg(ibydoc.document_payable_id, ail.line_number)
             )
           )
      FROM
           ap_invoice_lines_all ail,
           po_headers_all ph,
           iby_docs_payable_all ibydoc
     WHERE ibydoc.document_payable_id = p_document_payable_id
       AND ail.po_header_id = ph.po_header_id(+)
       AND nvl(ibydoc.calling_app_doc_unique_ref2,-99) = ail.invoice_id
       AND ibydoc.calling_app_id = 200;

  BEGIN
  iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'ENTER: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;
      /* Preparing the concatinated strings of invalid characters
      and corresponding replacement characters.  Bug 7292070 */
      /*
      FOR i in 1..32 LOOP
        l_conc_invalid_chars :=l_conc_invalid_chars||fnd_global.local_chr(i-1);
        l_conc_replacement_chars :=l_conc_replacement_chars||' ';
      END LOOP;
      */
    OPEN l_docline_csr (p_document_payable_id,l_conc_invalid_chars,l_conc_replacement_chars);
    FETCH l_docline_csr INTO l_docline_agg;
    CLOSE l_docline_csr;

                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
	            END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN l_docline_agg;
  EXCEPTION
       WHEN OTHERS THEN
          	    iby_debug_pub.add(debug_msg => 'EXECPTION OCCURED IN : '  || l_Debug_Module || sqlerrm ,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
       RAISE;
  END Get_Doc_DocLineAgg;



  /* Start of overloaded function */
 FUNCTION Get_Doc_DocLineAgg(p_document_payable_id IN NUMBER,
                                p_call_app_doc_unique_ref2 IN ap_invoices_all.invoice_id%TYPE,
				p_doc_currency_code IN iby_docs_payable_all.document_currency_code%TYPE,
				p_calling_app_id  IN iby_docs_payable_all.calling_app_id%TYPE)
    RETURN XMLTYPE
  IS
    l_docline_agg XMLTYPE;
    l_conc_invalid_chars VARCHAR2(50);
    l_conc_replacement_chars VARCHAR2(50);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Doc_DocLineAgg';

    CURSOR l_docline_csr(p_document_payable_id IN NUMBER,
                          p_conc_invalid_chars IN VARCHAR2,
			  p_conc_replacement_chars IN VARCHAR2,
			  p_call_app_doc_unique_ref2 IN ap_invoices_all.invoice_id%TYPE,
			  p_doc_currency_code  IN iby_docs_payable_all.document_currency_code%TYPE,
			  p_calling_app_id IN iby_docs_payable_all.calling_app_id%TYPE)
                      IS
    SELECT XMLAgg(
             XMLElement("DocumentPayableLine",
               XMLElement("LineNumber", ail.line_number),
               XMLElement("PONumber", ph.segment1),
               XMLElement("LineType",
                 XMLElement("Code", ail.line_type_lookup_code),
                 XMLElement("Meaning", null)),
               XMLElement("LineDescription", TRANSLATE(ail.description, p_conc_invalid_chars, p_conc_replacement_chars)),
               XMLElement("LineGrossAmount",
                 XMLElement("Value", ail.amount),
                 XMLElement("Currency", XMLElement("Code", p_doc_currency_code))),
               XMLElement("UnitPrice", ail.unit_price),
               XMLElement("Quantity", ail.quantity_invoiced),
               XMLElement("UnitOfMeasure",
                 XMLElement("Code", ail.unit_meas_lookup_code),
                 XMLElement("Meaning", null)),
               XMLElement("Tax",
                 XMLElement("TaxCode", ail.tax),
                 XMLElement("TaxRate", ail.tax_rate)
               ),
               IBY_FD_EXTRACT_EXT_PUB.Get_Docline_Ext_Agg(p_document_payable_id, ail.line_number)
             )
           )
      FROM
           ap_invoice_lines_all ail,
           po_headers_all ph
     WHERE ail.po_header_id = ph.po_header_id(+)
       AND nvl(p_call_app_doc_unique_ref2,-99) = ail.invoice_id
       AND p_calling_app_id = 200;

  BEGIN
    iby_debug_pub.add(debug_msg => 'Enter:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'ENTER: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
         END IF;

    OPEN l_docline_csr (p_document_payable_id
                        ,l_conc_invalid_chars
                        ,l_conc_replacement_chars
                       ,p_call_app_doc_unique_ref2
			,p_doc_currency_code
                        ,p_calling_app_id);
    FETCH l_docline_csr INTO l_docline_agg;
    CLOSE l_docline_csr;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
	            END IF;

    iby_debug_pub.add(debug_msg => 'Exit:TIMESTAMP:: '  || l_Debug_Module||':: '||systimestamp,
                      debug_level => G_LEVEL_PROCEDURE,
                      module => l_Debug_Module);
    RETURN l_docline_agg;


  EXCEPTION
       WHEN OTHERS THEN
          	    iby_debug_pub.add(debug_msg => 'EXECPTION OCCURED IN : '  || l_Debug_Module || sqlerrm ,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
       RAISE;
  END Get_Doc_DocLineAgg;
  /*End of Overloaded function */





  FUNCTION Get_SRA_Attribute(p_payment_id IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2
  IS
    l_sra_delivery_method          VARCHAR2(30);
    l_override_payee_flag          VARCHAR2(1);
    l_sra_req_flag                 VARCHAR2(1);
    l_pp_sra_delivery_method       VARCHAR2(30);
    l_ps_lang                      VARCHAR2(4);
    l_ps_territory                 VARCHAR2(60);

    CURSOR l_sra_setup_csr (p_payment_id IN NUMBER) IS
    SELECT sra_setup.sra_override_payee_flag, sra_setup.remit_advice_delivery_method
      FROM iby_payments_all pmt, iby_pay_instructions_all ins,
           iby_payment_profiles pp, iby_remit_advice_setup sra_setup
     WHERE pmt.payment_id = p_payment_id
       AND pmt.payment_instruction_id = ins.payment_instruction_id
       AND pp.payment_profile_id = ins.payment_profile_id
       AND pp.system_profile_code = sra_setup.system_profile_code;

    CURSOR l_sra_req_flag_csr (p_payment_id IN NUMBER) IS
    SELECT separate_remit_advice_req_flag
      FROM iby_payments_all
     WHERE payment_id = p_payment_id;

    CURSOR l_lang_territory_csr (p_payment_id IN NUMBER) IS
    SELECT loc.language, loc.country
      FROM hz_party_sites ps, hz_locations loc, iby_payments_all pmt
     WHERE payment_id = p_payment_id
       AND pmt.party_site_id = ps.party_site_id(+)
       AND loc.location_id = ps.location_id;

  BEGIN

    IF p_attribute_type = G_SRA_DELIVERY_METHOD_ATTR THEN

       OPEN l_sra_setup_csr (p_payment_id);
      FETCH l_sra_setup_csr INTO l_override_payee_flag, l_pp_sra_delivery_method;
      CLOSE l_sra_setup_csr;

      IF l_override_payee_flag = 'Y' THEN
        l_sra_delivery_method := l_pp_sra_delivery_method;

      ELSE
         l_sra_delivery_method := Get_Payee_Default_Attribute(p_payment_id, p_attribute_type);

         IF l_sra_delivery_method is null THEN
           l_sra_delivery_method := l_pp_sra_delivery_method;
         END IF;
      END IF;

      return l_sra_delivery_method;

    ELSIF p_attribute_type = G_SRA_REQ_FLAG_ATTR THEN

       OPEN l_sra_req_flag_csr (p_payment_id);
      FETCH l_sra_req_flag_csr INTO l_sra_req_flag;
      CLOSE l_sra_req_flag_csr;

      return l_sra_req_flag;

    ELSIF p_attribute_type = G_SRA_PS_LANG_ATTR OR
          p_attribute_type = G_SRA_PS_TERRITORY_ATTR THEN

       OPEN l_lang_territory_csr (p_payment_id);
      FETCH l_lang_territory_csr INTO l_ps_lang, l_ps_territory;
      CLOSE l_lang_territory_csr;

      IF p_attribute_type = G_SRA_PS_LANG_ATTR THEN
        return l_ps_lang;
      ELSE
        return l_ps_territory;
      END IF;

    ELSE
      return Get_Payee_Default_Attribute(p_payment_id, p_attribute_type);
    END IF;

  END Get_SRA_Attribute;


  FUNCTION Get_Payee_Default_Attribute(p_payment_id IN NUMBER, p_attribute_type IN NUMBER)
  RETURN VARCHAR2
  IS
      l_attribute_val     VARCHAR2(1000);

      CURSOR l_payee_defaulting_cur (p_payment_id NUMBER) IS
      SELECT payee.remit_advice_delivery_method,
             payee.remit_advice_email,
             payee.remit_advice_fax
        FROM iby_external_payees_all payee,
       	     iby_payments_all pmt
       WHERE payee.payee_party_id = pmt.payee_party_id
         AND payee.payment_function = pmt.payment_function
         AND (payee.org_id is NULL OR (payee.org_id = pmt.org_id AND payee.org_type = pmt.org_type))
         AND (payee.party_site_id is NULL OR payee.party_site_id = pmt.party_site_id)
         AND (payee.supplier_site_id is NULL OR payee.supplier_site_id = pmt.supplier_site_id)
         AND pmt.payment_id = p_payment_id
    ORDER BY payee.supplier_site_id, payee.party_site_id, payee.org_id;

  BEGIN

    FOR l_default_rec in l_payee_defaulting_cur(p_payment_id) LOOP
      IF (l_attribute_val is NULL) THEN
        IF p_attribute_type = G_SRA_DELIVERY_METHOD_ATTR THEN
          l_attribute_val := l_default_rec.remit_advice_delivery_method;
        ELSIF p_attribute_type = G_SRA_EMAIL_ATTR THEN
          l_attribute_val := l_default_rec.remit_advice_email;
        ELSIF p_attribute_type = G_SRA_FAX_ATTR THEN
          l_attribute_val := l_default_rec.remit_advice_fax;
        END IF;
      END IF;
    END LOOP;

    return l_attribute_val;
  END Get_Payee_Default_Attribute;


  -- following are four wrappers for the corresponding
  -- federal APIs. The wrappers will swallow any exceptions
  -- from calling the federal code.
  -- comment out actual calls to federal code
  -- as the FV package are not yet available
  -- - in F12MSS2/F12DBS2 8/30/2005
  FUNCTION get_FEIN(payment_instruction_id IN NUMBER)
  RETURN VARCHAR2
  IS
  BEGIN
    return FV_FEDERAL_PAYMENT_FIELDS_PKG.get_FEIN(payment_instruction_id);
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END get_FEIN;

  FUNCTION get_Abbreviated_Agency_Code(payment_instruction_id IN NUMBER)
  RETURN VARCHAR2
  IS
  BEGIN
    return FV_FEDERAL_PAYMENT_FIELDS_PKG.get_Abbreviated_Agency_Code(payment_instruction_id);
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END get_Abbreviated_Agency_Code;

  FUNCTION get_Allotment_Code(payment_id IN NUMBER)
  RETURN VARCHAR2
  IS
  BEGIN
    return FV_FEDERAL_PAYMENT_FIELDS_PKG.get_Allotment_Code(payment_id);
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END get_Allotment_Code;

  FUNCTION TOP_Offset_Eligibility_Flag(payment_id IN NUMBER)
  RETURN VARCHAR2
  IS
  BEGIN
    return FV_FEDERAL_PAYMENT_FIELDS_PKG.TOP_Offset_Eligibility_Flag(payment_id);
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END TOP_Offset_Eligibility_Flag;

  FUNCTION get_SPS_PMT_TS(payment_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_treasury_symbol   VARCHAR2(35);

    CURSOR l_ts_cur (p_payment_id NUMBER) IS
    SELECT fv.treasury_symbol
      FROM FV_TP_TS_AMT_DATA fv,
           iby_payments_all pmt
     WHERE pmt.payment_instruction_id = fv.payment_instruction_id
       AND pmt.payment_id = p_payment_id
       AND ROWNUM = 1;

  BEGIN

     OPEN l_ts_cur (payment_id);
    FETCH l_ts_cur INTO l_treasury_symbol;
    CLOSE l_ts_cur;

    return l_treasury_symbol;
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END get_SPS_PMT_TS;


  FUNCTION Get_Bordero_Bank_Ref(p_doc_payable_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_return_status       VARCHAR2(1);
    l_bordero_bank_ref    VARCHAR2(30);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Bordero_Bank_Ref';
    l_doc_idx            NUMBER;

  BEGIN

    --IF G_IS_BRAZIL IS NULL THEN
      l_doc_idx := p_doc_payable_id;

      /* perf bug 6763515 */
      IF l_doc_idx is NOT NULL THEN
	      IF (NOT(g_docs_pay_attribs_tbl.EXISTS(l_doc_idx))) THEN
		      g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL := JL_BR_AP_PAY_SCHED_GDF_PKG.Check_Brazil(
				       P_Doc_Payable_ID    => p_doc_payable_id,
				       P_RETURN_STATUS     => l_return_status);
		      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			      iby_debug_pub.add(debug_msg => 'Called JL_BR_AP_PAY_SCHED_GDF_PKG.Check_Brazil(). G_IS_BRAZIL: ' || g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL,
					debug_level => G_LEVEL_STATEMENT,
					module => l_Debug_Module);
		      END IF;
	      END IF;
      G_IS_BRAZIL :=g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL;
      END IF;


    --END IF;

    IF G_IS_BRAZIL = 1 THEN
      l_bordero_bank_ref := JL_BR_AP_PAY_SCHED_GDF_PKG.Get_Bordero_Bank_Ref(
                              P_Doc_Payable_ID    => p_doc_payable_id,
                              P_RETURN_STATUS     => l_return_status);

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Called JL_BR_AP_PAY_SCHED_GDF_PKG.Get_Bordero_Bank_Ref(). l_bordero_bank_ref: ' || l_bordero_bank_ref,
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    END IF;

    return l_bordero_bank_ref;
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Bordero_Bank_Ref;


  FUNCTION Get_Bordero_Int_Amt(p_doc_payable_id IN NUMBER)
  RETURN Number
  IS
    l_return_status       VARCHAR2(1);
    l_process_type        VARCHAR2(30);
    l_bordero_int_amt     NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Bordero_Int_Amt';
    l_doc_idx            NUMBER;

  BEGIN

    --IF G_IS_BRAZIL IS NULL THEN
      l_doc_idx := p_doc_payable_id;

       /* perf bug 6763515 */
      IF l_doc_idx is NOT NULL THEN
	      IF (NOT(g_docs_pay_attribs_tbl.EXISTS(l_doc_idx))) THEN
		      g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL := JL_BR_AP_PAY_SCHED_GDF_PKG.Check_Brazil(
				       P_Doc_Payable_ID    => p_doc_payable_id,
				       P_RETURN_STATUS     => l_return_status);

		      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			      iby_debug_pub.add(debug_msg => 'Called JL_BR_AP_PAY_SCHED_GDF_PKG.Check_Brazil(). G_IS_BRAZIL: ' || g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL,
					debug_level => G_LEVEL_STATEMENT,
					module => l_Debug_Module);
		      END IF;
	      END IF;
      G_IS_BRAZIL :=g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL;
      END IF;


    --END IF;

    IF G_IS_BRAZIL = 1 THEN
      l_bordero_int_amt := JL_BR_AP_PAY_SCHED_GDF_PKG.Get_Bordero_Int_Amt(
                             P_Doc_Payable_ID    => p_doc_payable_id,
                             P_Process_Type      => l_process_type,
                             P_RETURN_STATUS     => l_return_status);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Called JL_BR_AP_PAY_SCHED_GDF_PKG.Get_Bordero_Int_Amt(). l_bordero_int_amt: ' || l_bordero_int_amt,
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    END IF;

    return l_bordero_int_amt;
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Bordero_Int_Amt;



  FUNCTION Get_Bordero_Abatement(p_doc_payable_id IN NUMBER)
  RETURN Number
  IS
    l_return_status       VARCHAR2(1);
    l_process_type        VARCHAR2(30);
    l_bordero_abt_amt     NUMBER;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Bordero_Abatement';
    l_doc_idx            NUMBER;

  BEGIN

    --IF G_IS_BRAZIL IS NULL THEN
      l_doc_idx := p_doc_payable_id;

      /* perf bug 6763515 */
      IF l_doc_idx is NOT NULL THEN
	      IF (NOT(g_docs_pay_attribs_tbl.EXISTS(l_doc_idx))) THEN
		      g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL := JL_BR_AP_PAY_SCHED_GDF_PKG.Check_Brazil(
				       P_Doc_Payable_ID    => p_doc_payable_id,
				       P_RETURN_STATUS     => l_return_status);

		       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			       iby_debug_pub.add(debug_msg => 'Called JL_BR_AP_PAY_SCHED_GDF_PKG.Check_Brazil(). G_IS_BRAZIL: ' || g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL,
					debug_level => G_LEVEL_STATEMENT,
					module => l_Debug_Module);
		       END IF;

	      END IF;
      G_IS_BRAZIL :=g_docs_pay_attribs_tbl(l_doc_idx).IS_BRAZIL;
      END IF;


    --END IF;

    IF G_IS_BRAZIL = 1 THEN
      l_bordero_abt_amt := JL_BR_AP_PAY_SCHED_GDF_PKG.Get_Bordero_Abatement(
                             P_Doc_Payable_ID    => p_doc_payable_id,
                             P_Process_Type      => l_process_type,
                             P_RETURN_STATUS     => l_return_status);

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Called JL_BR_AP_PAY_SCHED_GDF_PKG.Get_Bordero_Abatement(). l_bordero_abt_amt: ' || l_bordero_abt_amt,
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    END IF;


    return l_bordero_abt_amt;
  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Bordero_Abatement;


  FUNCTION Get_Payment_Amount_Text(payment_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_amount          NUMBER;
    l_currency_code   VARCHAR2(10);

    CURSOR l_amount_cur (p_payment_id NUMBER) IS
    SELECT pmt.payment_amount,
           pmt.payment_currency_code
      FROM iby_payments_all pmt
     WHERE pmt.payment_id = p_payment_id;

  BEGIN

     OPEN l_amount_cur (payment_id);
    FETCH l_amount_cur INTO l_amount, l_currency_code;
    CLOSE l_amount_cur;

    RETURN IBY_AMOUNT_IN_WORDS.Get_Amount_In_Words(l_amount, l_currency_code);

  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Payment_Amount_Text;

  FUNCTION Get_Payment_Amount_Withheld(payment_id IN NUMBER)
  RETURN NUMBER
  IS
    l_amount_withheld   NUMBER;
    CURSOR l_pmt_amount_withheld_csr (p_payment_id IN NUMBER) IS
    SELECT sum(amount_withheld)
      FROM iby_docs_payable_all
     WHERE payment_id = p_payment_id;
  BEGIN

     OPEN l_pmt_amount_withheld_csr (payment_id);
    FETCH l_pmt_amount_withheld_csr INTO l_amount_withheld;
    CLOSE l_pmt_amount_withheld_csr;

    RETURN l_amount_withheld;
    EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;
  END Get_Payment_Amount_Withheld;



  -- Payment process request extract functions
  FUNCTION Get_Ppr_PmtAgg(p_payment_service_request_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_ppr_pmt_agg XMLTYPE;

    CURSOR l_ppr_pmt_csr (p_payment_service_request_id IN NUMBER) IS
    SELECT XMLAgg(payment)
      FROM iby_xml_fd_pmt_1_0_v
     WHERE payment_service_request_id = p_payment_service_request_id;

  BEGIN

    OPEN l_ppr_pmt_csr (p_payment_service_request_id);
    FETCH l_ppr_pmt_csr INTO l_ppr_pmt_agg;
    CLOSE l_ppr_pmt_csr;

    RETURN l_ppr_pmt_agg;

  END Get_Ppr_PmtAgg;

  FUNCTION Get_Ppr_PmtCount(p_payment_service_request_id IN NUMBER)
  RETURN NUMBER
  IS
    l_ppr_pmt_count NUMBER;

    CURSOR l_ppr_pmt_count_csr (p_payment_service_request_id IN NUMBER) IS
    SELECT count(payment_id)
      FROM iby_xml_fd_pmt_1_0_v
     WHERE payment_service_request_id = p_payment_service_request_id;

  BEGIN

    OPEN l_ppr_pmt_count_csr (p_payment_service_request_id);
    FETCH l_ppr_pmt_count_csr INTO l_ppr_pmt_count;
    CLOSE l_ppr_pmt_count_csr;

    RETURN l_ppr_pmt_count;

  END Get_Ppr_PmtCount;


  FUNCTION Get_Ppr_PreBuildDocAgg(p_payment_service_request_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_docpayable_agg XMLTYPE;

    CURSOR l_baddoc_csr (p_payment_service_request_id IN NUMBER) IS
    SELECT XMLAgg(doc_payable)
      FROM iby_xml_fd_doc_1_0_v
     WHERE payment_service_request_id = p_payment_service_request_id
       AND payment_id is null;
     --  AND document_status in ('REJECTED', 'FAILED_VALIDATION');

  BEGIN

    OPEN l_baddoc_csr (p_payment_service_request_id);
    FETCH l_baddoc_csr INTO l_docpayable_agg;
    CLOSE l_baddoc_csr;

    RETURN l_docpayable_agg;

  END Get_Ppr_PreBuildDocAgg;

  FUNCTION Get_Ppr_PreBuildDocCount(p_payment_service_request_id IN NUMBER)
  RETURN NUMBER
  IS
    l_docpayable_count NUMBER;

    CURSOR l_baddoc_count_csr (p_payment_service_request_id IN NUMBER) IS
    SELECT count(document_payable_id)
      FROM iby_xml_fd_doc_1_0_v
     WHERE payment_service_request_id = p_payment_service_request_id
       AND payment_id is null;
     --  AND document_status in ('REJECTED', 'FAILED_VALIDATION');

  BEGIN

    OPEN l_baddoc_count_csr (p_payment_service_request_id);
    FETCH l_baddoc_count_csr INTO l_docpayable_count;
    CLOSE l_baddoc_count_csr;

    RETURN l_docpayable_count;

  END Get_Ppr_PreBuildDocCount;


  FUNCTION Get_Pmt_PmtErrAgg(p_payment_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_pmterr_agg XMLTYPE;
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Pmt_PmtErrAgg';
    CURSOR l_pmterr_csr (p_payment_id IN NUMBER) IS
    SELECT XMLAgg(payment_error)
      FROM iby_xml_fd_pmt_err_1_0_v
     WHERE payment_id = p_payment_id;

  BEGIN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Get_Pmt_PmtErrAgg  Enter: ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
		    OPEN l_pmterr_csr (p_payment_id);
		    FETCH l_pmterr_csr INTO l_pmterr_agg;
		    CLOSE l_pmterr_csr;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Get_Pmt_PmtErrAgg  Exit: ',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;
    RETURN l_pmterr_agg;

  END Get_Pmt_PmtErrAgg;


  FUNCTION Get_Doc_DocErrAgg(p_document_payable_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_docerr_agg XMLTYPE;

    CURSOR l_docerr_csr (p_document_payable_id IN NUMBER) IS
    SELECT XMLAgg(doc_payable_error)
      FROM iby_xml_fd_doc_err_1_0_v
     WHERE document_payable_id = p_document_payable_id;

  BEGIN

    OPEN l_docerr_csr (p_document_payable_id);
    FETCH l_docerr_csr INTO l_docerr_agg;
    CLOSE l_docerr_csr;

    RETURN l_docerr_agg;

  END Get_Doc_DocErrAgg;


  PROCEDURE Update_Pmt_SRA_Attr_Prt
  (
  p_payment_instruction_id   IN     NUMBER
  )
  IS
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Update_Pmt_SRA_Attr_Prt';

    CURSOR l_pmt_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT payment_id, payment_reference_number
      FROM iby_payments_all
     WHERE payment_instruction_id = p_payment_instruction_id
      -- note: this where clause should be kept
      -- in-sync with the where clause of l_payerinstr_sra_prt_csr
      -- in Get_Ins_PayerInstrAgg()
       AND Get_SRA_Attribute(payment_id, G_SRA_REQ_FLAG_ATTR) = 'Y'
       AND Get_SRA_Attribute(payment_id, G_SRA_DELIVERY_METHOD_ATTR) = G_SRA_DELIVERY_METHOD_PRINTED
       AND payment_status in ('INSTRUCTION_CREATED', 'READY_TO_REPRINT',
            'SUBMITTED_FOR_PRINTING', 'FORMATTED', 'TRANSMITTED', 'ISSUED');

  BEGIN

    FOR l_payment IN l_pmt_csr(p_payment_instruction_id) LOOP

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'updating the SRA delivery method for payment ref number ' ||
				l_payment.payment_reference_number || ' to be PRINTED',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;

      UPDATE
        iby_payments_all
      SET
        remit_advice_delivery_method = 'PRINTED',
        remit_advice_email = null,
        remit_advice_fax = null,
        object_version_number    = object_version_number + 1,
        last_updated_by          = fnd_global.user_id,
        last_update_date         = SYSDATE,
        last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE
        payment_id = l_payment.payment_id;

    END LOOP;


  END Update_Pmt_SRA_Attr_Prt;


  PROCEDURE Update_Pmt_SRA_Attr_Ele
  (
  p_payment_id                   IN     NUMBER,
  p_delivery_method              IN     VARCHAR2,
  p_recipient_email              IN     VARCHAR2,
  p_recipient_fax                IN     VARCHAR2
  )
  IS
  BEGIN

    IF p_delivery_method = 'EMAIL' THEN
      UPDATE
        iby_payments_all
      SET
        remit_advice_delivery_method = p_delivery_method,
        remit_advice_email = p_recipient_email,
        remit_advice_fax = null,
        object_version_number    = object_version_number + 1,
        last_updated_by          = fnd_global.user_id,
        last_update_date         = SYSDATE,
        last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE payment_id = p_payment_id;
    ELSIF p_delivery_method = 'FAX' THEN
      UPDATE
        iby_payments_all
      SET
        remit_advice_delivery_method = p_delivery_method,
        remit_advice_email = null,
        remit_advice_fax = p_recipient_fax,
        object_version_number    = object_version_number + 1,
        last_updated_by          = fnd_global.user_id,
        last_update_date         = SYSDATE,
        last_update_login        = nvl(fnd_global.LOGIN_ID, fnd_global.conc_login_id)
      WHERE payment_id = p_payment_id;
    END IF;
  END Update_Pmt_SRA_Attr_Ele;


  PROCEDURE initialize
  IS
  BEGIN
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      	    iby_debug_pub.add(debug_msg => 'ENTER',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.initialize');
         END IF;
     g_docs_pay_attribs_tbl.DELETE;
     g_hr_addr_tbl.DELETE;
     g_hz_addr_tbl.DELETE;
     g_payer_contact_tbl.DELETE;
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      	    iby_debug_pub.add(debug_msg => 'EXIT',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.initialize');
         END IF;

  END initialize;

  FUNCTION Get_Hz_Address(p_location_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_hz_addr XMLTYPE;

    CURSOR l_hz_addr_csr (p_location_id IN NUMBER) IS
    SELECT address
      FROM IBY_XML_HZ_ADDR_1_0_V
     WHERE location_id = p_location_id;


  BEGIN

    Get_Hz_Address_C := Get_Hz_Address_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Get_Hz_Address() entered. count: ' || Get_Hz_Address_C,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Hz_Address');
	    iby_debug_pub.add(debug_msg => 'p_location_id: ' || p_location_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Hz_Address');
    END IF;
    IF p_location_id IS NULL THEN
      RETURN NULL;
    END IF;

    IF (NOT(g_hz_addr_tbl.EXISTS(p_location_id))) THEN
	    OPEN l_hz_addr_csr (p_location_id);
	    FETCH l_hz_addr_csr INTO g_hz_addr_tbl(p_location_id).hz_address;
	    CLOSE l_hz_addr_csr;
    END IF;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      	    iby_debug_pub.add(debug_msg => 'EXIT',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_HZ_Address');
    END IF;
    RETURN g_hz_addr_tbl(p_location_id).hz_address;

  END Get_Hz_Address;



  FUNCTION Get_Account_Address(p_location_id IN NUMBER, p_country IN VARCHAR2)
  RETURN XMLTYPE
  IS
    l_hz_addr XMLTYPE;

    CURSOR l_hz_addr_csr (p_location_id IN NUMBER) IS
    SELECT address
      FROM IBY_XML_HZ_ADDR_1_0_V
     WHERE location_id = p_location_id;


    CURSOR l_country_csr (p_country IN VARCHAR2) IS
    SELECT XMLConcat( XMLElement("AddressInternalID", null),
    XMLElement("AddressLine1", null), XMLElement("AddressLine2", null),
    XMLElement("AddressLine3", null), XMLElement("AddressLine4", null),
    XMLElement("City", null), XMLElement("County", null), XMLElement("State", null),
    XMLElement("Province", null), XMLElement("Country", te.territory_code),
    XMLElement("ISO3DigitCountry", te.iso_territory_code), XMLElement("CountryName", te.territory_short_name),
    XMLElement("PostalCode", null),
    XMLElement("PreFormattedConcatenatedAddress", null),
    XMLElement("PreFormattedMailingAddress", null) )
    FROM  fnd_territories_vl te
    WHERE te.territory_code = p_country;


  BEGIN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Get_Account_Address() entered. ',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Account_Address');
	    iby_debug_pub.add(debug_msg => 'p_location_id: ' || p_location_id || 'p_country: ' || p_country,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Account_Address');
    END IF;

    IF p_location_id IS NULL THEN
      IF trim(p_country) IS NULL  THEN
           RETURN NULL;
      ELSE
    /* Bug 8658052 */
	  IF (NOT(g_account_addr_tbl.EXISTS(p_country))) THEN
              iby_debug_pub.add(debug_msg => 'Address not found in the cache.
                                Executing the Cursor',
			        debug_level => G_LEVEL_STATEMENT,
			        module => G_Debug_Module || '.Get_Account_Address');
           OPEN l_country_csr (p_country);
              FETCH l_country_csr INTO g_account_addr_tbl(p_country).account_address;
           CLOSE l_country_csr;
           l_hz_addr:=g_account_addr_tbl(p_country).account_address;

        ELSE
            iby_debug_pub.add(debug_msg => 'Address found in the cache.',
			        debug_level => G_LEVEL_STATEMENT,
			        module => G_Debug_Module || '.Get_Account_Address');
            l_hz_addr:=g_account_addr_tbl(p_country).account_address;
        END IF;

	   RETURN l_hz_addr;
      END IF;
    END IF;

    IF (NOT(g_hz_addr_tbl.EXISTS(p_location_id))) THEN
      OPEN l_hz_addr_csr (p_location_id);
      FETCH l_hz_addr_csr INTO g_hz_addr_tbl(p_location_id).hz_address;
      CLOSE l_hz_addr_csr;
      l_hz_addr:=g_hz_addr_tbl(p_location_id).hz_address;
    ELSE
      l_hz_addr:=g_hz_addr_tbl(p_location_id).hz_address;
    END IF;

    /* Bug 8658052 */

    RETURN l_hz_addr;

  END Get_Account_Address;




  FUNCTION Get_Hr_Address(p_location_id IN NUMBER)
  RETURN XMLTYPE
  IS
    l_hr_addr XMLTYPE;

    CURSOR l_hr_addr_csr (p_location_id IN NUMBER) IS
    SELECT address
      FROM IBY_XML_HR_ADDR_1_0_V
     WHERE location_id = p_location_id;

  BEGIN

    Get_Hr_Address_C := Get_Hr_Address_C + 1;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Get_Hr_Address() entered. count: ' || Get_Hr_Address_C,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Hr_Address');
	    iby_debug_pub.add(debug_msg => 'p_location_id: ' || p_location_id,
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Hr_Address');
    END IF;

    IF p_location_id IS NULL THEN
      RETURN NULL;
    END IF;
    IF (NOT(g_hr_addr_tbl.EXISTS(p_location_id))) THEN
	    OPEN l_hr_addr_csr (p_location_id);
	    FETCH l_hr_addr_csr INTO g_hr_addr_tbl(p_location_id).hr_address;
	    CLOSE l_hr_addr_csr;
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      	    iby_debug_pub.add(debug_msg => 'EXIT',
			      debug_level => G_LEVEL_STATEMENT,
			      module => G_Debug_Module || '.Get_Hr_Address');
    END IF;
    RETURN g_hr_addr_tbl(p_location_id).hr_address;

  END Get_Hr_Address;


  FUNCTION Get_Ins_TotalAmt(p_payment_instruction_id IN NUMBER)
  RETURN NUMBER
  IS
    l_amt_total NUMBER;
    l_group_by_curr_flag VARCHAR2(1);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Ins_TotalAmt';

    CURSOR l_ins_group_by_curr_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT GROUP_BY_PAYMENT_CURRENCY
      FROM IBY_EXT_FD_INS_1_0_V
     WHERE payment_instruction_id = p_payment_instruction_id;

    CURSOR l_amt_total_csr (p_payment_instruction_id IN NUMBER) IS
    SELECT SUM(payment_amount)
      FROM iby_payments_all
     WHERE payment_status in ('INSTRUCTION_CREATED', 'READY_TO_REPRINT',
            'SUBMITTED_FOR_PRINTING', 'ISSUED', 'FORMATTED', 'TRANSMITTED')
       AND payment_instruction_id = p_payment_instruction_id;

       -- Bug : 8237325
       -- Changing to decimal type before extract generation.
       -- Will Reset after sending value.
       l_numeric_char_mask  V$NLS_PARAMETERS.value%TYPE;
       l_default_num_mask   VARCHAR2(10) := '.,';


  BEGIN

    -- Get NLS numeric character before calling extract.
    -- Bug: 8237325
    BEGIN
      SELECT value
        INTO l_numeric_char_mask
        FROM V$NLS_PARAMETERS
       WHERE parameter='NLS_NUMERIC_CHARACTERS';
    EXCEPTION
      WHEN others THEN NULL;
    END;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    OPEN l_ins_group_by_curr_csr (p_payment_instruction_id);
    FETCH l_ins_group_by_curr_csr INTO l_group_by_curr_flag;
    CLOSE l_ins_group_by_curr_csr;

    IF NVL(l_group_by_curr_flag, 'N') = 'N' THEN

	      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		      iby_debug_pub.add(debug_msg => 'Instruction is not grouped by currency, so returning null for the total amount.',
					debug_level => G_LEVEL_STATEMENT,
					module => l_Debug_Module);
	      END IF;
	     RETURN NULL;
    END IF;

      -- Bug : 8237325
      -- Changing to decimal type before extract generation.
      -- Will Reset after sending value.
      IF l_numeric_char_mask <> l_default_num_mask THEN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='||'"'||l_default_num_mask||'"';
      END IF;


    OPEN l_amt_total_csr (p_payment_instruction_id);
    FETCH l_amt_total_csr INTO l_amt_total;
    CLOSE l_amt_total_csr;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Instruction total amount: ' || l_amt_total,
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);

	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;
      -- Bug : 8237325
      -- Changing to decimal type before extract generation.
      -- Will Reset after sending value.
      IF l_numeric_char_mask <> l_default_num_mask THEN
	EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '||'"'||l_numeric_char_mask|| '"';
      END IF;


    RETURN l_amt_total;

  END Get_Ins_TotalAmt;


  FUNCTION Get_Expense_Rpt_CC_Num(p_document_payable_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_instrid NUMBER;
    l_card_num VARCHAR2(30);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Expense_Rpt_CC_Num';

  BEGIN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);

	    iby_debug_pub.add(debug_msg => 'Calling iExpense API to get instrid.',
			      debug_level => G_LEVEL_STATEMENT,
			      module => l_Debug_Module);
    END IF;

    l_instrid := AP_WEB_CREDIT_CARD_PKG.get_card_reference_id(p_document_payable_id);

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    iby_debug_pub.add(debug_msg => 'Got instrid: ' || l_instrid,
                      debug_level => G_LEVEL_STATEMENT,
                      module => l_Debug_Module);
     END IF;

    IF l_instrid IS NOT NULL THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      iby_debug_pub.add(debug_msg => 'Getting instr number',
				debug_level => G_LEVEL_STATEMENT,
				module => l_Debug_Module);
      END IF;

      l_card_num := iby_creditcard_pkg.uncipher_ccnumber(l_instrid, iby_utility_pvt.get_view_param('SYS_KEY'));

    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
    END IF;

    RETURN l_card_num;

  EXCEPTION
    -- swallow exceptions
    WHEN OTHERS THEN
      RETURN NULL;

  END Get_Expense_Rpt_CC_Num;

  FUNCTION Replace_Special_Characters(p_base_string IN varchar2)
  RETURN VARCHAR2
  IS
    l_conc_invalid_chars VARCHAR2(50);
    l_conc_replacement_chars VARCHAR2(50);
    l_modified   varchar2(255);
    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Replace_Special_Characters';
  BEGIN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
      END IF;


       /* Preparing the concatinated strings of invalid characters
      and corresponding replacement characters.  Bug 7292070 */
      FOR i in 1..32 LOOP
        l_conc_invalid_chars :=l_conc_invalid_chars||fnd_global.local_chr(i-1);
        l_conc_replacement_chars :=l_conc_replacement_chars||' ';
      END LOOP;

      l_modified := TRANSLATE(p_base_string, l_conc_invalid_chars, l_conc_replacement_chars);

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    iby_debug_pub.add(debug_msg => 'Exit: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
            END IF;
    RETURN l_modified;
  END Replace_Special_Characters;



 /* Bug 9266772*/
FUNCTION Get_Intermediary_Bank_Accts(p_bank_acct_id NUMBER) RETURN XMLTYPE
IS

  l_intermediary_accounts xmltype;
  cursor c_intermediate_bank_accts(p_bank_acct_id number) is
  select XMLCONCAT(
(XMLELEMENT("IntermediaryAccountID", Intermediary_acct_id)),
(XMLELEMENT("BankAccountNumber",Account_Number)),
(XMLELEMENT("IBANNumber",IBAN)),
(XMLELEMENT("BankName",Bank_Name)),
(XMLELEMENT("BankCode", Bank_code)),
(XMLELEMENT("BranchNumber",BRANCH_NUMBER)),
(XMLELEMENT("SwiftCode",BIC)),
(XMLELEMENT("CheckDigits",check_digits)),
(XMLELEMENT("City",city)),
(XMLELEMENT("Country",country_code)),
(XMLELEMENT("Comments",comments))) from iby_intermediary_accts where bank_acct_id = p_bank_acct_id order by Intermediary_acct_id asc;
l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Intermediary_Bank_Accts';
BEGIN

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  	    iby_debug_pub.add(debug_msg => 'Enter: '  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
       END IF;
       IF p_bank_acct_id IS NULL THEN
          RETURN NULL;
       END IF;

       IF (NOT(g_inter_accts_tbl.EXISTS(p_bank_acct_id||'_1') and NOT(g_inter_accts_tbl.EXISTS(p_bank_acct_id||'_2')))) THEN

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  	    iby_debug_pub.add(debug_msg => 'Fecthing Intermediary Accounts from DB:'  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
            END IF;
            OPEN c_intermediate_bank_accts (p_bank_acct_id);
            FETCH c_intermediate_bank_accts INTO g_inter_accts_tbl(p_bank_acct_id||'_1');
            --DBMS_OUTPUT.put_line('RowCount Fetched for '||p_bank_acct_id||' :'||c_intermediate_bank_accts%rowcount);
            FETCH c_intermediate_bank_accts INTO g_inter_accts_tbl(p_bank_acct_id||'_2');
            --DBMS_OUTPUT.put_line('RowCount Fetched for '||p_bank_acct_id||' :'||c_intermediate_bank_accts%rowcount);
	    CLOSE c_intermediate_bank_accts;
       ELSE
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  	    iby_debug_pub.add(debug_msg => 'Using Cached Intermediary Accounts:'  || l_Debug_Module,
			      debug_level => G_LEVEL_PROCEDURE,
			      module => l_Debug_Module);
            END IF;
           Select XMLCONCAT(XMLELEMENT("IntermediaryBankAccount1",g_inter_accts_tbl(p_bank_acct_id||'_1')),XMLELEMENT("IntermediaryBankAccount2",g_inter_accts_tbl(p_bank_acct_id||'_2'))) into l_intermediary_accounts from dual;
           RETURN l_intermediary_accounts;
       END IF;
       Select XMLCONCAT(XMLELEMENT("IntermediaryBankAccount1",g_inter_accts_tbl(p_bank_acct_id||'_1')),XMLELEMENT("IntermediaryBankAccount2",g_inter_accts_tbl(p_bank_acct_id||'_2'))) into l_intermediary_accounts from dual;
       RETURN l_intermediary_accounts;
END Get_Intermediary_Bank_Accts;

 /* Bug 9266772*/


BEGIN
      FOR i in 1..32 LOOP
        l_conc_invalid_chars :=l_conc_invalid_chars||fnd_global.local_chr(i-1);
        l_conc_replacement_chars :=l_conc_replacement_chars||' ';
      END LOOP;
END IBY_FD_EXTRACT_GEN_PVT;




/
