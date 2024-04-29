--------------------------------------------------------
--  DDL for Package Body ECE_AP_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_AP_PAYMENT" AS
-- $Header: ECEPYOB.pls 120.5.12010000.8 2010/02/10 17:59:58 vkarlapu ship $
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ECE_AP_PAYMENT';

  PROCEDURE insert_into_gt  (
   p_payment_instruction_id IN number
  );

  PROCEDURE delete_from_gt;

   /*===========================================================================

    PROCEDURE NAME:      Extract_PYO_Outbound

    PURPOSE:             This procedure initiates the concurrent process to
                         extract the eligible transactions.

   ===========================================================================*/
   PROCEDURE  Extract_PYO_Outbound ( p_api_version       IN number,
                                     p_init_msg_list     IN varchar2,
                                     p_commit            IN varchar2,
                                     x_return_status     OUT NOCOPY varchar2,
                                     x_msg_count         OUT  NOCOPY number,
                                     x_msg_data          OUT  NOCOPY varchar2,
                                     p_payment_instruction_id IN number
                                     )  IS

      xProgress                VARCHAR2(80);
      i_file_id                PLS_INTEGER;
      cOutput_Path             VARCHAR2(120);
      i_Filename               VARCHAR2(50);
      i_Transaction_Type       VARCHAR2(50);
      p_errbuf                 VARCHAR2(32767);
      p_retcode                VARCHAR2(32767);
      l_api_version   CONSTANT        NUMBER  := 1.0;
      l_api_name      CONSTANT        VARCHAR2(30) := 'Extract_PYO_Outbound';
      p_debug_mode             NUMBER;
      BEGIN

        fnd_profile.get('ECE_PYO_DEBUG_MODE', p_Debug_Mode);
        p_debug_mode := 3;

		IF p_Debug_mode IS NULL THEN
                        p_Debug_Mode := 3;
                END IF;


	 ec_debug.enable_debug(p_debug_mode);
         ec_debug.pl ( 0, 'EC', 'ECE_PYO_START', NULL );
         ec_debug.push('ECE_AP_TRANSACTION.Extract_PYO_Outbound');
         ec_debug.pl(3,'Payment Instruction ID ',p_payment_instruction_id );
         ec_debug.pl(3,'Debug Mode: ',p_debug_mode );

	 i_Transaction_Type := 'PYO';

	 /*
	  * Inserting values from iby view to Global Temporary table
	  * For performance.
	  */

          insert_into_gt(p_payment_instruction_id);


	 ec_debug.pl (3, 'comes here');

	 /*
         IF NOT fnd_api.Compatible_API_Call(l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME)
         THEN
             ec_debug.pl (3, 'comes here');
             RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF fnd_api.to_Boolean(p_init_msg_list) THEN
                fnd_msg_pub.initialize;
         END IF;

         x_return_status := fnd_api.g_ret_sts_success;
         ec_debug.pl (3, 'comes here');
	*/

         x_return_status := fnd_api.g_ret_sts_success; -- bug:5512623

         xProgress := 'PYO-10-1004';

         -- Derive output filename
         --  IF fnd_global.conc_request_id IS NOT NULL THEN

	 i_file_id := IBY_EC_OP_FILE_NAME_EXT_PUB.get_File_Id(p_payment_instruction_id);
         ec_debug.pl(3,'File Id returned from ext pub::',i_file_id );


	     IF i_file_id  is null THEN
	       BEGIN
                 SELECT ece_output_runs_s.NEXTVAL INTO i_file_id
                 FROM DUAL;
	       EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  ec_debug.pl ( 0,
                             'EC',
                             'ECE_GET_NEXT_SEQ_FAILED',
                             'PROGRESS_LEVEL',
                              xProgress,
                              'SEQ',
                              'ECE_OUTPUT_RUNS_S'
			      );
               END;
           END IF;

           ec_debug.pl (3, 'comes here');

           ec_debug.pl ( 3, 'File ID ',i_file_id);


           i_Filename := i_Transaction_Type || i_file_id || '.dat';


	   xProgress := 'PYO-10-1005';
           fnd_profile.get ( 'ECE_OUT_FILE_PATH',
                              cOutput_path );
           ec_debug.pl ( 3, 'cOutput_Path: ',cOutput_Path );






           xProgress := 'PYO-10-1030';
           ec_debug.pl ( 0, 'EC', 'ECE_PAYMENT_BATCH', 'PAYMENT INSTRUCTION ID ', p_payment_instruction_id );

	   fnd_file.put_line(fnd_file.log, 'Calling EC Process Outbound :: START ::'||systimestamp);

           ec_document.process_outbound(
                                         errbuf        => p_errbuf,
                                         retcode       => p_retcode,
                                         i_Output_Path => cOutput_Path,
                                         i_Output_Filename  => i_Filename,
                                         i_Transaction_Type => i_Transaction_Type,
                                         i_debug_mode       => p_debug_mode,
                                         parameter1         => p_payment_instruction_id
                                        );

            fnd_file.put_line(fnd_file.log, 'Calling EC Process Outbound :: END ::'||systimestamp);


        -- Standard check of p_commit
        if fnd_api.to_Boolean(p_commit) then
                COMMIT WORK;
        end if;

        -- Standard call to get message count and if count is 1, get message info.
        fnd_msg_pub.count_and_get(
                p_count => x_msg_count,
                p_data  => x_msg_data);


      IF ec_mapping_utils.ec_get_trans_upgrade_status(i_Transaction_Type)  = 'U' THEN
         ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
      END IF;

      delete_from_gt;
      ec_debug.pop ( 'ECE_AP_TRANSACTION.Extract_PYO_Outbound' );
      ec_debug.disable_debug;
  EXCEPTION
       WHEN fnd_api.g_exc_error THEN
               ROLLBACK;
	        fnd_file.put_line(fnd_file.log, 'EXCEPTION :: END ::'||systimestamp);
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
                ec_debug.disable_debug;
        WHEN fnd_api.g_exc_unexpected_error THEN
                ROLLBACK;
		fnd_file.put_line(fnd_file.log, 'EXCEPTION :: END ::'||systimestamp);
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
                ec_debug.disable_debug;
        WHEN OTHERS THEN
                ROLLBACK;
		fnd_file.put_line(fnd_file.log, 'EXCEPTION :: END ::'||systimestamp);
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                IF fnd_msg_pub.Check_Msg_Level
                        (fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
                        fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
                END IF;
                fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);

                ec_debug.disable_debug;
  END Extract_PYO_Outbound;


  PROCEDURE insert_into_gt(p_payment_instruction_id IN NUMBER)
  IS

  BEGIN
    ec_debug.push('ECE_AP_TRANSACTION.insert_into_gt');
    ec_debug.pl (3, 'Fetching Payment data for Instruction',p_payment_instruction_id);
    fnd_file.put_line(fnd_file.log, 'Calling insert_into_gt :: START ::'||systimestamp);

    INSERT INTO IBY_PYO_PAYMENT_GT(COMMUNICATION_METHOD,
                                   TEST_FLAG,
				   DOCUMENT_ID,
				   DOCUMENT_CODE,
				   BK_TP_TRANSLATOR_CODE,
				   BK_TP_LOCATION_CODE_EXT,
				   BK_TP_DESCRIPTION,
				   BK_TP_REFERENCE_EXT1,
				   BK_TP_REFERENCE_EXT2,
				   TRANSACTION_DATE,
				   TPH_ATTRIBUTE_CATEGORY,
				   TPH_ATTRIBUTE1,
				   TPH_ATTRIBUTE2,
				   TPH_ATTRIBUTE3,
				   TPH_ATTRIBUTE4,
				   TPH_ATTRIBUTE5,
				   TPH_ATTRIBUTE6,
				   TPH_ATTRIBUTE7,
				   TPH_ATTRIBUTE8,
				   TPH_ATTRIBUTE9,
				   TPH_ATTRIBUTE10,
				   TPH_ATTRIBUTE11,
				   TPH_ATTRIBUTE12,
				   TPH_ATTRIBUTE13,
				   TPH_ATTRIBUTE14,
				   TPH_ATTRIBUTE15,
				   TPD_ATTRIBUTE_CATEGORY,
				   TPD_ATTRIBUTE1,
				   TPD_ATTRIBUTE2,
				   TPD_ATTRIBUTE3,
				   TPD_ATTRIBUTE4,
				   TPD_ATTRIBUTE5,
				   DOCUMENT_STANDARD,
				   TRANSACTION_HANDLING_CODE,
				   CHECK_AMOUNT,
				   CURRENCY_CODE,
				   EDI_PAYMENT_METHOD,
				   EDI_PAYMENT_FORMAT,
				   BANK_BRANCH_TYPE,
				   BANK_ACCOUNT_TYPE,
				   BANK_ACCOUNT_NUM,
				   BANK_EDI_ID_NUMBER,
				   VENDOR_BANK_BRANCH_TYPE,
				   VENDOR_BANK_ACCOUNT_TYPE,
				   VENDOR_BANK_ACCOUNT_NUM,
				   PAYMENT_DATE,
				   BANK_NUM,
				   VENDOR_BANK_NUM,
				   EDI_REMITTANCE_METHOD,
				   EDI_REMITTANCE_INSTRUCTION,
				   PAYMENT_INSTRUCTION_ID,
				   CHECK_VOUCHER_NUM,
				   SELECTED_CHECK_ID,
				   CHECK_NUMBER,
				   CUSTOMER_NUM,
				   SEGMENT1,
				   VENDOR_EDI_ID_NUMBER,
				   SEGMENT2,
				   SEGMENT3,
				   SEGMENT4,
				   SEGMENT5,
				   BANK_BRANCH_ID,
				   BK_BANK_BRANCH_NAME,
				   BK_ADDRESS_LINE1,
				   BK_ADDRESS_LINE2,
				   BK_ADDRESS_LINE3,
				   BK_CITY,
				   BK_ZIP,
				   BK_COUNTRY,
				   BK_STATE,
				   BK_PROVINCE,
				   BK_CONTACT_FIRST_NAME,
				   BK_CONTACT_MIDDLE_NAME,
				   BK_CONTACT_LAST_NAME,
				   BK_CONTACT_TITLE,
				   BK_CONTACT_PREFIX,
				   BK_CONTACT_AREA_CODE,
				   BK_CONTACT_PHONE,
				   VENDOR_SITE_CODE,
				   VENDOR_NAME,
				   ADDRESS_LINE1,
				   ADDRESS_LINE2,
				   ADDRESS_LINE3,
				   ADDRESS_LINE4,
				   CITY,
				   ZIP,
				   COUNTRY,
				   STATE,
				   PROVINCE,
				   ABA_GLOBAL_ATTRIBUTE_CATEGORY,
				   ABA_GLOBAL_ATTRIBUTE1,
				   ABA_GLOBAL_ATTRIBUTE2,
				   ABA_GLOBAL_ATTRIBUTE3,
				   ABA_GLOBAL_ATTRIBUTE4,
				   ABA_GLOBAL_ATTRIBUTE5,
				   ABA_GLOBAL_ATTRIBUTE6,
				   ABA_GLOBAL_ATTRIBUTE7,
				   ABA_GLOBAL_ATTRIBUTE8,
				   ABA_GLOBAL_ATTRIBUTE9,
				   ABA_GLOBAL_ATTRIBUTE10,
				   ABA_GLOBAL_ATTRIBUTE11,
				   ABA_GLOBAL_ATTRIBUTE12,
				   ABA_GLOBAL_ATTRIBUTE13,
				   ABA_GLOBAL_ATTRIBUTE14,
				   ABA_GLOBAL_ATTRIBUTE15,
				   ABA_GLOBAL_ATTRIBUTE16,
				   ABA_GLOBAL_ATTRIBUTE17,
				   ABA_GLOBAL_ATTRIBUTE18,
				   ABA_GLOBAL_ATTRIBUTE19,
				   ABA_GLOBAL_ATTRIBUTE20,
				   ABAS_GLOBAL_ATTRIBUTE_CATEGORY,
				   ABAS_GLOBAL_ATTRIBUTE1,
				   ABAS_GLOBAL_ATTRIBUTE2,
				   ABAS_GLOBAL_ATTRIBUTE3,
				   ABAS_GLOBAL_ATTRIBUTE4,
				   ABAS_GLOBAL_ATTRIBUTE5,
				   ABAS_GLOBAL_ATTRIBUTE6,
				   ABAS_GLOBAL_ATTRIBUTE7,
				   ABAS_GLOBAL_ATTRIBUTE8,
				   ABAS_GLOBAL_ATTRIBUTE9,
				   ABAS_GLOBAL_ATTRIBUTE10,
				   ABAS_GLOBAL_ATTRIBUTE11,
				   ABAS_GLOBAL_ATTRIBUTE12,
				   ABAS_GLOBAL_ATTRIBUTE13,
				   ABAS_GLOBAL_ATTRIBUTE14,
				   ABAS_GLOBAL_ATTRIBUTE15,
				   ABAS_GLOBAL_ATTRIBUTE16,
				   ABAS_GLOBAL_ATTRIBUTE17,
				   ABAS_GLOBAL_ATTRIBUTE18,
				   ABAS_GLOBAL_ATTRIBUTE19,
				   ABAS_GLOBAL_ATTRIBUTE20,
				   PVS_GLOBAL_ATTRIBUTE_CATEGORY,
				   PVS_GLOBAL_ATTRIBUTE1,
				   PVS_GLOBAL_ATTRIBUTE2,
				   PVS_GLOBAL_ATTRIBUTE3,
				   PVS_GLOBAL_ATTRIBUTE4,
				   PVS_GLOBAL_ATTRIBUTE5,
				   PVS_GLOBAL_ATTRIBUTE6,
				   PVS_GLOBAL_ATTRIBUTE7,
				   PVS_GLOBAL_ATTRIBUTE8,
				   PVS_GLOBAL_ATTRIBUTE9,
				   PVS_GLOBAL_ATTRIBUTE10,
				   PVS_GLOBAL_ATTRIBUTE11,
				   PVS_GLOBAL_ATTRIBUTE12,
				   PVS_GLOBAL_ATTRIBUTE13,
				   PVS_GLOBAL_ATTRIBUTE14,
				   PVS_GLOBAL_ATTRIBUTE15,
				   PVS_GLOBAL_ATTRIBUTE16,
				   PVS_GLOBAL_ATTRIBUTE17,
				   PVS_GLOBAL_ATTRIBUTE18,
				   PVS_GLOBAL_ATTRIBUTE19,
				   PVS_GLOBAL_ATTRIBUTE20,
				   BK_EFT_SWIFT_CODE,
				   SBK_BANK_BRANCH_NUMBER,
				   SBK_BANK_BRANCH_NAME,
				   SBK_ADDRESS_LINE1,
				   SBK_ADDRESS_LINE2,
				   SBK_ADDRESS_LINE3,
				   SBK_CITY,
				   SBK_STATE,
				   SBK_ZIP,
				   SBK_PROVINCE,
				   SBK_COUNTRY,
				   SBK_EFT_SWIFT_CODE,
				   BILL_TO_INT_LOCATION_NAME,
				   BILL_TO_INT_ADDRESS1,
				   BILL_TO_INT_ADDRESS2,
				   BILL_TO_INT_ADDRESS3,
				   BILL_TO_INT_CITY,
				   BILL_TO_INT_POSTAL_CODE,
				   BILL_TO_INT_COUNTRY,
				   FI_VAT_REGISTRATION_NUM,
				   BILL_TO_INT_LOCATION_ID,
				   ECE_TP_LOCATION_CODE,
				   BILL_TO_INT_REGION1,
				   BILL_TO_INT_REGION2,
				   BILL_TO_INT_REGION3,
				   MAP_ID,
				   FUTURE_PAY_DUE_DATE,
				   VENDOR_ALTERNATE_NAME,
				   VENDOR_ALTERNATE_SITE_CODE,
				   SUPPLIER_CHECK_DIGITS,
				   SBK_BANK_NAME,
				   IBAN_NUMBER,
				   VENDOR_IBAN_NUMBER,
				   PAYMENT_MEAN,
				   PAYMENT_CHANNEL,
				   VENDOR_ID,
				   VENDOR_SITE_ID,
				   PAYMENT_REFERENCE_NUMBER,
				   SBK_BANK_CODE,
				   PAYMENT_PROCESS_REQUEST_NAME,
				   PAYMENT_ORG_ID,
				   BANK_NAME,
				   BRANCH_NUMBER,
				   BANK_ACCOUNT_ID,
				   BANK_ACCOUNT_NAME,
				   BK_ACCT_ATTRIBUTE_CATEGORY,
				   BK_ACCT_ATTRIBUTE1,
				   BK_ACCT_ATTRIBUTE2,
				   BK_ACCT_ATTRIBUTE3,
				   BK_ACCT_ATTRIBUTE4,
				   BK_ACCT_ATTRIBUTE5,
				   BK_ACCT_ATTRIBUTE6,
				   BK_ACCT_ATTRIBUTE7,
				   BK_ACCT_ATTRIBUTE8,
				   BK_ACCT_ATTRIBUTE9,
				   BK_ACCT_ATTRIBUTE10,
				   BK_ACCT_ATTRIBUTE11,
				   BK_ACCT_ATTRIBUTE12,
				   BK_ACCT_ATTRIBUTE13,
				   BK_ACCT_ATTRIBUTE14,
				   BK_ACCT_ATTRIBUTE15,
				   VENDOR_BANK_ACCOUNT_ID,
				   SBK_ACCT_ATTRIBUTE_CATEGORY,
				   SBK_ACCT_ATTRIBUTE1,
				   SBK_ACCT_ATTRIBUTE2,
				   SBK_ACCT_ATTRIBUTE3,
				   SBK_ACCT_ATTRIBUTE4,
				   SBK_ACCT_ATTRIBUTE5,
				   SBK_ACCT_ATTRIBUTE6,
				   SBK_ACCT_ATTRIBUTE7,
				   SBK_ACCT_ATTRIBUTE8,
				   SBK_ACCT_ATTRIBUTE9,
				   SBK_ACCT_ATTRIBUTE10,
				   SBK_ACCT_ATTRIBUTE11,
				   SBK_ACCT_ATTRIBUTE12,
				   SBK_ACCT_ATTRIBUTE13,
				   SBK_ACCT_ATTRIBUTE14,
				   SBK_ACCT_ATTRIBUTE15,
				   VEND_SITE_COUNTY,
				   VEND_SITE_ATTRIBUTE_CATEGORY,
				   VEND_SITE_ATTRIBUTE1,
				   VEND_SITE_ATTRIBUTE2,
				   VEND_SITE_ATTRIBUTE3,
				   VEND_SITE_ATTRIBUTE4,
				   VEND_SITE_ATTRIBUTE5,
				   VEND_SITE_ATTRIBUTE6,
				   VEND_SITE_ATTRIBUTE7,
				   VEND_SITE_ATTRIBUTE8,
				   VEND_SITE_ATTRIBUTE9,
				   VEND_SITE_ATTRIBUTE10,
				   VEND_SITE_ATTRIBUTE11,
				   VEND_SITE_ATTRIBUTE12,
				   VEND_SITE_ATTRIBUTE13,
				   VEND_SITE_ATTRIBUTE14,
				   VEND_SITE_ATTRIBUTE15,
				   VENDOR_TYPE_LOOKUP_CODE,
				   VENDOR_ATTRIBUTE_CATEGORY,
				   VENDOR_ATTRIBUTE1,
				   VENDOR_ATTRIBUTE2,
				   VENDOR_ATTRIBUTE3,
				   VENDOR_ATTRIBUTE4,
				   VENDOR_ATTRIBUTE5,
				   VENDOR_ATTRIBUTE6,
				   VENDOR_ATTRIBUTE7,
				   VENDOR_ATTRIBUTE8,
				   VENDOR_ATTRIBUTE9,
				   VENDOR_ATTRIBUTE10,
				   VENDOR_ATTRIBUTE11,
				   VENDOR_ATTRIBUTE12,
				   VENDOR_ATTRIBUTE13,
				   VENDOR_ATTRIBUTE14,
				   VENDOR_ATTRIBUTE15
				   )
                            SELECT 'EDI' communication_method                            ,
                              bktpd.test_flag test_flag                                   ,
                              'PYO' document_id                                           ,
                              ipay.payment_id document_code                               ,
                              bktpd.translator_code bk_tp_translator_code                 ,
                              hcp.edi_ece_tp_location_code bk_tp_location_code_ext        ,
                              bktph.tp_description bk_tp_description                      ,
                              bktph.tp_reference_ext1 bk_tp_reference_ext1                ,
                              bktph.tp_reference_ext2 bk_tp_reference_ext2                ,
                              sysdate transaction_date                                    ,
                              bktph.attribute_category tph_attribute_category             ,
                              bktph.attribute1 tph_attribute1                             ,
                              bktph.attribute2 tph_attribute2                             ,
                              bktph.attribute3 tph_attribute3                             ,
                              bktph.attribute4 tph_attribute4                             ,
                              bktph.attribute5 tph_attribute5                             ,
                              bktph.attribute6 tph_attribute6                             ,
                              bktph.attribute7 tph_attribute7                             ,
                              bktph.attribute8 tph_attribute8                             ,
                              bktph.attribute9 tph_attribute9                             ,
                              bktph.attribute10 tph_attribute10                           ,
                              bktph.attribute11 tph_attribute11                           ,
                              bktph.attribute12 tph_attribute12                           ,
                              bktph.attribute13 tph_attribute13                           ,
                              bktph.attribute14 tph_attribute14                           ,
                              bktph.attribute15 tph_attribute15                           ,
                              bktpd.attribute_category tpd_attribute_category             ,
                              bktpd.attribute1 tpd_attribute1                             ,
                              bktpd.attribute2 tpd_attribute2                             ,
                              bktpd.attribute3 tpd_attribute3                             ,
                              bktpd.attribute4 tpd_attribute4                             ,
                              bktpd.attribute5 tpd_attribute5                             ,
                              bktpd.document_standard document_standard                   ,
                              ipay.bank_instruction2_code transaction_handling_code       ,
                              ipay.payment_amount check_amount                            ,
                              ipay.payment_currency_code currency_code                    ,
                              ipay.payment_method_code edi_payment_method                 ,
                              ipay.bank_instruction1_code edi_payment_format              ,
                              hca1.class_code bank_branch_type                            ,
                              cba.bank_account_type bank_account_type                     ,
                              ipay.int_bank_account_number bank_account_num               ,
                              hcp.edi_id_number bank_edi_id_number                        ,
                              hca.class_code vendor_bank_branch_type                      ,
                              ipay.ext_bank_account_type vendor_bank_account_type         ,
                              ipay.ext_bank_account_number vendor_bank_account_num        ,
                              ipay.payment_date payment_date                              ,
                              ipay.int_bank_branch_number bank_num                        ,  -- Bug 9365065
                              ipay.ext_branch_number vendor_bank_num                      ,  -- Bug 9365065
                              ipay.delivery_channel_code edi_remittance_method            ,
                              ipay.payment_text_message1 edi_remittance_instruction       ,
                              ipay.payment_instruction_id payment_instruction_id          ,
                              NULL check_voucher_num                                      ,
                              NULL selected_check_id                                      ,
                              nvl(ipay.paper_document_number, ipay.payment_reference_number) check_number,   -- Bug 9365065
                              aps.customer_num customer_num                               ,
                              aps.segment1 segment1                                       ,
                              apss.edi_id_number vendor_edi_id_number                     ,
                              aps.segment2 segment2                                       ,
                              aps.segment3 segment3                                       ,
                              aps.segment4 segment4                                       ,
                              aps.segment5 segment5                                       ,
                              ipay.int_bank_branch_party_id bank_branch_id                ,
                              ipay.int_bank_branch_name bk_bank_branch_name               ,
                              ibl.address1 bk_address_line1                               ,
                              ibl.address2 bk_address_line2                               ,
                              ibl.address3 bk_address_line3                               ,
                              ibl.city bk_city                                            ,
                              ibl.postal_code bk_zip                                      ,
                              ibl.country bk_country                                      ,
                              ibl.state bk_state                                          ,
                              ibl.province bk_province                                    ,
                              NULL bk_contact_first_name                                  ,
                              NULL bk_contact_middle_name                                 ,
                              NULL bk_contact_last_name                                   ,
                              NULL bk_contact_title                                       ,
                              NULL bk_contact_prefix                                      ,
                              NULL bk_contact_area_code                                   ,
                              NULL bk_contact_phone                                       ,
                              apss.vendor_site_code vendor_site_code                      ,
                              ipay.payee_name vendor_name                                 ,
                              ipay.payee_address1 address_line1                           ,
                              ipay.payee_address2 address_line2                           ,
                              ipay.payee_address3 address_line3                           ,
                              ipay.payee_address4 address_line4                           ,
                              ipay.payee_city city                                        ,
                              ipay.payee_postal_code zip                                  ,
                              ipay.payee_country country                                  ,
                              ipay.payee_state state                                      ,
                              ipay.payee_province province                                ,
                              NULL aba_global_attribute_category                          ,
                              NULL aba_global_attribute1                                  ,
                              NULL aba_global_attribute2                                  ,
                              NULL aba_global_attribute3                                  ,
                              NULL aba_global_attribute4                                  ,
                              NULL aba_global_attribute5                                  ,
                              NULL aba_global_attribute6                                  ,
                              NULL aba_global_attribute7                                  ,
                              NULL aba_global_attribute8                                  ,
                              NULL aba_global_attribute9                                  ,
                              NULL aba_global_attribute10                                 ,
                              NULL aba_global_attribute11                                 ,
                              NULL aba_global_attribute12                                 ,
                              NULL aba_global_attribute13                                 ,
                              NULL aba_global_attribute14                                 ,
                              NULL aba_global_attribute15                                 ,
                              NULL aba_global_attribute16                                 ,
                              NULL aba_global_attribute17                                 ,
                              NULL aba_global_attribute18                                 ,
                              NULL aba_global_attribute19                                 ,
                              NULL aba_global_attribute20                                 ,
                              NULL abas_global_attribute_category                         ,
                              NULL abas_global_attribute1                                 ,
                              NULL abas_global_attribute2                                 ,
                              ipay.payee_country abas_global_attribute3                   ,
                              NULL abas_global_attribute4                                 ,
                              ipay.payment_reason_code abas_global_attribute5             ,
                              NULL abas_global_attribute6                                 ,
                              NULL abas_global_attribute7                                 ,
                              ipay.bank_charge_bearer abas_global_attribute8              ,
                              NULL abas_global_attribute9                                 ,
                              NULL abas_global_attribute10                                ,
                              NULL abas_global_attribute11                                ,
                              NULL abas_global_attribute12                                ,
                              NULL abas_global_attribute13                                ,
                              NULL abas_global_attribute14                                ,
                              NULL abas_global_attribute15                                ,
                              NULL abas_global_attribute16                                ,
                              NULL abas_global_attribute17                                ,
                              NULL abas_global_attribute18                                ,
                              NULL abas_global_attribute19                                ,
                              NULL abas_global_attribute20                                ,
                              apss.global_attribute_category pvs_global_attribute_category,
                              apss.global_attribute1 pvs_global_attribute1                ,
                              apss.global_attribute2 pvs_global_attribute2                ,
                              apss.global_attribute3 pvs_global_attribute3                ,
                              apss.global_attribute4 pvs_global_attribute4                ,
                              apss.global_attribute5 pvs_global_attribute5                ,
                              apss.global_attribute6 pvs_global_attribute6                ,
                              apss.global_attribute7 pvs_global_attribute7                ,
                              apss.global_attribute8 pvs_global_attribute8                ,
                              apss.global_attribute9 pvs_global_attribute9                ,
                              apss.global_attribute10 pvs_global_attribute10              ,
                              apss.global_attribute11 pvs_global_attribute11              ,
                              apss.global_attribute12 pvs_global_attribute12              ,
                              apss.global_attribute13 pvs_global_attribute13              ,
                              apss.global_attribute14 pvs_global_attribute14              ,
                              apss.global_attribute15 pvs_global_attribute15              ,
                              apss.global_attribute16 pvs_global_attribute16              ,
                              apss.global_attribute17 pvs_global_attribute17              ,
                              apss.global_attribute18 pvs_global_attribute18              ,
                              apss.global_attribute19 pvs_global_attribute19              ,
                              apss.global_attribute20 pvs_global_attribute20              ,
                              ipay.int_eft_swift_code bk_eft_swift_code                   ,
                              ipay.ext_branch_number sbk_bank_branch_number               ,
                              ipay.ext_bank_branch_name sbk_bank_branch_name              ,
                              ebl.address1 sbk_address_line1                              ,
                              ebl.address2 sbk_address_line2                              ,
                              ebl.address3 sbk_address_line3                              ,
                              ebl.city sbk_city                                           ,
                              ebl.state sbk_state                                         ,
                              ebl.postal_code sbk_zip                                     ,
                              ebl.province sbk_province                                   ,
                              ebl.country sbk_country                                     ,
                              ipay.ext_eft_swift_code sbk_eft_swift_code                  ,
                              hr.location_code bill_to_int_location_name                  ,
                              hr.address_line_1 bill_to_int_address1                      ,
                              hr.address_line_2 bill_to_int_address2                      ,
                              hr.address_line_3 bill_to_int_address3                      ,
                              hr.town_or_city bill_to_int_city                            ,
                              hr.postal_code bill_to_int_postal_code                      ,
                              hr.country bill_to_int_country                              ,
                              ipay.payer_tax_registration_num fi_vat_registration_num     ,
                              hr.location_id bill_to_int_location_id                      ,
                              hr.ece_tp_location_code ece_tp_location_code                ,
                              hr.region_1 bill_to_int_region1                             ,
                              hr.region_2 bill_to_int_region2                             ,
                              hr.region_3 bill_to_int_region3                             ,
                              bktpd.map_id map_id                                         ,
                              ipay.payment_due_date future_pay_due_date                   ,
                              aps.vendor_name_alt vendor_alternate_name                   ,
                              apss.vendor_site_code_alt vendor_alternate_site_code        ,
                              ipay.uri_check_digit supplier_check_digits                  ,
                              ipay.ext_bank_name sbk_bank_name                            ,
                              ipay.int_bank_account_iban iban_number                      ,
                              ipay.ext_bank_account_iban_number vendor_iban_number        ,
                              ipm.attribute1 payment_mean                                 ,
                              ipm.attribute2 payment_channel                              ,
                              aps.vendor_id vendor_id                                     ,
                              apss.vendor_site_id vendor_site_id                          ,
                              ipay.payment_reference_number payment_reference_number      ,
                              bapr.bank_code sbk_bank_code                                ,
                              ipay.PAYMENT_PROCESS_REQUEST_NAME PAYMENT_PROCESS_REQUEST_NAME,
			      ipay.ORG_ID			PAYMENT_ORG_ID              ,
                              ipay.INT_BANK_NAME		BANK_NAME                   ,
			      ipay.INT_BANK_BRANCH_NUMBER	BRANCH_NUMBER               ,
			      cba.BANK_ACCOUNT_ID 		BANK_ACCOUNT_ID             ,
			      cba.BANK_ACCOUNT_NAME		BANK_ACCOUNT_NAME           ,
			      cba.ATTRIBUTE_CATEGORY		BK_ACCT_ATTRIBUTE_CATEGORY  ,
			      cba.ATTRIBUTE1        		BK_ACCT_ATTRIBUTE1          ,
			      cba.ATTRIBUTE2        		BK_ACCT_ATTRIBUTE2          ,
			      cba.ATTRIBUTE3        		BK_ACCT_ATTRIBUTE3          ,
                              cba.ATTRIBUTE4                    BK_ACCT_ATTRIBUTE4          ,
                              cba.ATTRIBUTE5                    BK_ACCT_ATTRIBUTE5          ,
                              cba.ATTRIBUTE6                    BK_ACCT_ATTRIBUTE6          ,
                              cba.ATTRIBUTE7                    BK_ACCT_ATTRIBUTE7          ,
                              cba.ATTRIBUTE8                    BK_ACCT_ATTRIBUTE8          ,
                              cba.ATTRIBUTE9                    BK_ACCT_ATTRIBUTE9          ,
                              cba.ATTRIBUTE10                   BK_ACCT_ATTRIBUTE10         ,
                              cba.ATTRIBUTE11                   BK_ACCT_ATTRIBUTE11         ,
                              cba.ATTRIBUTE12                   BK_ACCT_ATTRIBUTE12         ,
                              cba.ATTRIBUTE13                   BK_ACCT_ATTRIBUTE13         ,
                              cba.ATTRIBUTE14                   BK_ACCT_ATTRIBUTE14         ,
                              cba.ATTRIBUTE15  			BK_ACCT_ATTRIBUTE15         ,
			      ieba.EXT_BANK_ACCOUNT_ID 		VENDOR_BANK_ACCOUNT_ID      ,
			      ieba.ATTRIBUTE_CATEGORY		SBK_ACCT_ATTRIBUTE_CATEGORY ,
			      ieba.ATTRIBUTE1        		SBK_ACCT_ATTRIBUTE1         ,
                              ieba.ATTRIBUTE2                   SBK_ACCT_ATTRIBUTE2         ,
                              ieba.ATTRIBUTE3                   SBK_ACCT_ATTRIBUTE3         ,
                              ieba.ATTRIBUTE4                   SBK_ACCT_ATTRIBUTE4         ,
  			      ieba.ATTRIBUTE5        		SBK_ACCT_ATTRIBUTE5         ,
			      ieba.ATTRIBUTE6        		SBK_ACCT_ATTRIBUTE6         ,
			      ieba.ATTRIBUTE7        		SBK_ACCT_ATTRIBUTE7         ,
			      ieba.ATTRIBUTE8        		SBK_ACCT_ATTRIBUTE8         ,
			      ieba.ATTRIBUTE9        		SBK_ACCT_ATTRIBUTE9         ,
			      ieba.ATTRIBUTE10       		SBK_ACCT_ATTRIBUTE10        ,
			      ieba.ATTRIBUTE11       		SBK_ACCT_ATTRIBUTE11        ,
			      ieba.ATTRIBUTE12       		SBK_ACCT_ATTRIBUTE12        ,
			      ieba.ATTRIBUTE13       		SBK_ACCT_ATTRIBUTE13        ,
			      ieba.ATTRIBUTE14       		SBK_ACCT_ATTRIBUTE14        ,
			      ieba.ATTRIBUTE15    		SBK_ACCT_ATTRIBUTE15        ,
			      apss.COUNTY			VEND_SITE_COUNTY            ,
			      apss.ATTRIBUTE_CATEGORY		VEND_SITE_ATTRIBUTE_CATEGORY,
			      apss.ATTRIBUTE1        		VEND_SITE_ATTRIBUTE1        ,
                              apss.ATTRIBUTE2                   VEND_SITE_ATTRIBUTE2        ,
                              apss.ATTRIBUTE3                   VEND_SITE_ATTRIBUTE3        ,
                              apss.ATTRIBUTE4                   VEND_SITE_ATTRIBUTE4        ,
  			      apss.ATTRIBUTE5        		VEND_SITE_ATTRIBUTE5        ,
			      apss.ATTRIBUTE6        		VEND_SITE_ATTRIBUTE6        ,
			      apss.ATTRIBUTE7        		VEND_SITE_ATTRIBUTE7        ,
			      apss.ATTRIBUTE8        		VEND_SITE_ATTRIBUTE8        ,
			      apss.ATTRIBUTE9        		VEND_SITE_ATTRIBUTE9        ,
			      apss.ATTRIBUTE10       		VEND_SITE_ATTRIBUTE10       ,
			      apss.ATTRIBUTE11       		VEND_SITE_ATTRIBUTE11       ,
			      apss.ATTRIBUTE12       		VEND_SITE_ATTRIBUTE12       ,
			      apss.ATTRIBUTE13       		VEND_SITE_ATTRIBUTE13       ,
			      apss.ATTRIBUTE14       		VEND_SITE_ATTRIBUTE14       ,
			      apss.ATTRIBUTE15 			VEND_SITE_ATTRIBUTE15       ,
			      aps.VENDOR_TYPE_LOOKUP_CODE	VENDOR_TYPE_LOOKUP_CODE     ,
			      aps.ATTRIBUTE_CATEGORY		VENDOR_ATTRIBUTE_CATEGORY   ,
			      aps.ATTRIBUTE1        		VENDOR_ATTRIBUTE1           ,
                              aps.ATTRIBUTE2                    VENDOR_ATTRIBUTE2           ,
                              aps.ATTRIBUTE3                    VENDOR_ATTRIBUTE3           ,
                              aps.ATTRIBUTE4                    VENDOR_ATTRIBUTE4           ,
  			      aps.ATTRIBUTE5        		VENDOR_ATTRIBUTE5           ,
			      aps.ATTRIBUTE6        		VENDOR_ATTRIBUTE6           ,
			      aps.ATTRIBUTE7        		VENDOR_ATTRIBUTE7           ,
			      aps.ATTRIBUTE8        		VENDOR_ATTRIBUTE8           ,
			      aps.ATTRIBUTE9        		VENDOR_ATTRIBUTE9           ,
			      aps.ATTRIBUTE10       		VENDOR_ATTRIBUTE10          ,
			      aps.ATTRIBUTE11       		VENDOR_ATTRIBUTE11          ,
			      aps.ATTRIBUTE12       		VENDOR_ATTRIBUTE12          ,
			      aps.ATTRIBUTE13       		VENDOR_ATTRIBUTE13          ,
			      aps.ATTRIBUTE14       		VENDOR_ATTRIBUTE14          ,
			      aps.ATTRIBUTE15 			VENDOR_ATTRIBUTE15
                            FROM iby_payments_all ipay,
                              ce_bank_accounts cba       ,
                              ap_suppliers aps           ,
                              ap_supplier_sites apss     ,
                              hz_contact_points hcp      ,
                              ece_tp_headers bktph       ,
                              ece_tp_details bktpd       ,
                              hr_locations hr            ,
                              hz_locations ebl           ,
                              hz_code_assignments hca    ,
                              hz_locations ibl           ,
                              hz_code_assignments hca1   ,
                              iby_payment_methods_b ipm  ,
                              iby_ext_bank_accounts ieba ,
                              (SELECT party_id           ,
                                bank_code
                                 FROM hz_organization_profiles
                                WHERE sysdate        >= effective_start_date
                              AND(effective_end_date IS NULL
                              OR effective_end_date   > sysdate)
                              ) bapr,
                              financials_system_params_all fi
                            WHERE apss.vendor_site_id = ipay.supplier_site_id
                            AND cba.bank_account_id     = ipay.internal_bank_account_id
                            AND apss.vendor_id          = aps.vendor_id
                            AND bktph.tp_header_id      = hcp.edi_tp_header_id
                            AND bktpd.tp_header_id      = bktph.tp_header_id
                            AND bktpd.document_id       = 'PYO'
                            AND hcp.owner_table_id      = ipay.int_bank_branch_party_id
                            AND hcp.owner_table_name    = 'HZ_PARTIES'
                            AND hcp.contact_point_type  = 'EDI'
                            AND bktpd.edi_flag          = 'Y'
                            AND ipay.org_id             = fi.org_id
                            AND hr.location_id          = fi.bill_to_location_id
                            AND ebl.location_id(+)      = ipay.ext_bank_branch_location_id
                            AND hca.owner_table_id(+)   = ipay.ext_bank_branch_party_id
                            AND hca.owner_table_name(+) = 'HZ_PARTIES'
                            AND hca.class_category(+)   = 'BANK_BRANCH_TYPE'
                            AND hca.status(+)           = 'A'
                            AND sysdate BETWEEN NVL(hca.start_date_active(+), sysdate -1) AND NVL(hca.end_date_active(+), sysdate + 1)
                            AND ibl.location_id(+)       = ipay.int_bank_branch_location_id
                            AND hca1.owner_table_id(+)   = ipay.int_bank_branch_party_id
                            AND hca1.owner_table_name(+) = 'HZ_PARTIES'
                            AND hca1.class_category(+)   = 'BANK_BRANCH_TYPE'
                            AND hca1.status(+)           = 'A'
                            AND sysdate BETWEEN NVL(hca1.start_date_active(+), sysdate -1) AND NVL(hca1.end_date_active(+), sysdate + 1)
                            AND ipay.payment_method_code      = ipm.payment_method_code
                            AND ipay.external_bank_account_id = ieba.ext_bank_account_id(+)
                            AND ieba.branch_id                = bapr.party_id(+)
                            AND ipay.payment_instruction_id   = p_payment_instruction_id;


   ec_debug.pl (3, 'Finished fetching Payment data');
   ec_debug.pl (3, 'Fetching Invoice data');
   fnd_file.put_line(fnd_file.log, 'Finished fetching Payment Data ::'||systimestamp);

   INSERT INTO IBY_PYO_INVOICE_GT(PAYMENT_ID,
                                  PAYMENT_INSTRUCTION_ID,
				  PAY_SELECTED_CHECK_ID,
				  VENDOR_NUM,
				  CUSTOMER_NUM,
				  INVOICE_NUM,
				  INVOICE_DATE,
				  INVOICE_DESCRIPTION,
				  PROPOSED_PAYMENT_AMOUNT,
				  INVOICE_AMOUNT,
				  DISCOUNT_AMOUNT,
				  PRINT_SELECTED_CHECK_ID,
				  ATTRIBUTE_CATEGORY,
				  ATTRIBUTE1,
				  ATTRIBUTE2,
				  ATTRIBUTE3,
				  ATTRIBUTE4,
				  ATTRIBUTE5,
				  ATTRIBUTE6,
				  ATTRIBUTE7,
				  ATTRIBUTE8,
				  ATTRIBUTE9,
				  ATTRIBUTE10,
				  ATTRIBUTE11,
				  ATTRIBUTE12,
				  ATTRIBUTE13,
				  ATTRIBUTE14,
				  ATTRIBUTE15,
				  INV_GLOBAL_ATTRIBUTE_CATEGORY,
				  INV_GLOBAL_ATTRIBUTE1,
				  INV_GLOBAL_ATTRIBUTE2,
				  INV_GLOBAL_ATTRIBUTE3,
				  INV_GLOBAL_ATTRIBUTE4,
				  INV_GLOBAL_ATTRIBUTE5,
				  INV_GLOBAL_ATTRIBUTE6,
				  INV_GLOBAL_ATTRIBUTE7,
				  INV_GLOBAL_ATTRIBUTE8,
				  INV_GLOBAL_ATTRIBUTE9,
				  INV_GLOBAL_ATTRIBUTE10,
				  INV_GLOBAL_ATTRIBUTE11,
				  INV_GLOBAL_ATTRIBUTE12,
				  INV_GLOBAL_ATTRIBUTE13,
				  INV_GLOBAL_ATTRIBUTE14,
				  INV_GLOBAL_ATTRIBUTE15,
				  INV_GLOBAL_ATTRIBUTE16,
				  INV_GLOBAL_ATTRIBUTE17,
				  INV_GLOBAL_ATTRIBUTE18,
				  INV_GLOBAL_ATTRIBUTE19,
				  INV_GLOBAL_ATTRIBUTE20,
				  BANK_CHARGE_BEARER,
				  PAYMENT_REASON_CODE,
				  PAYMENT_REASON_COMMENTS,
				  REMITTANCE_MESSAGE1,
				  REMITTANCE_MESSAGE2,
				  REMITTANCE_MESSAGE3,
				  UNIQUE_REMITTANCE_IDENTIFIER,
				  URI_CHECK_DIGIT,
				  DELIVERY_CHANNEL_CODE,
				  SETTLEMENT_PRIORITY,
				  EXTERNAL_BANK_ACCOUNT_ID,
				  PAYMENT_METHOD_CODE,
				  VENDOR_ID,
				  VENDOR_SITE_ID,
				  PAYMENT_MEAN,
				  PAYMENT_CHANNEL,
				  COUNTRY,
                                  PAYMENT_PROCESS_REQUEST_NAME,
				  BANK_ACCOUNT_ID,
				  VENDOR_BANK_ACCOUNT_ID,
				  PAYMENT_REFERENCE_NUMBER,
				  CHECK_NUMBER
				  )
				  SELECT idpa.payment_id payment_id
				  , ipa.payment_instruction_id payment_instruction_id
				  , NULL pay_selected_check_id
				  , ipa.payee_supplier_number vendor_num
				  , NULL customer_num
				  , idpa.calling_app_doc_ref_number invoice_num
				  , idpa.document_date invoice_date
				  , idpa.document_description invoice_description
				  , idpa.payment_amount proposed_payment_amount
				  , idpa.document_amount invoice_amount
				  , NULL discount_amount
				  , NULL print_selected_check_id
				  , idpa.attribute_category attribute_category
				  , idpa.attribute1 attribute1
				  , idpa.attribute2 attribute2
				  , idpa.attribute3 attribute3
				  , idpa.attribute4 attribute4
				  , idpa.attribute5 attribute5
				  , idpa.attribute6 attribute6
				  , idpa.attribute7 attribute7
				  , idpa.attribute8 attribute8
				  , idpa.attribute9 attribute9
				  , idpa.attribute10 attribute10
				  , idpa.attribute11 attribute11
				  , idpa.attribute12 attribute12
				  , idpa.attribute13 attribute13
				  , idpa.attribute14 attribute14
				  , idpa.attribute15 attribute15
				  , idpa.global_attribute_category inv_global_attribute_category
				  , idpa.global_attribute1 inv_global_attribute1
				  , idpa.global_attribute2 inv_global_attribute2
				  , idpa.global_attribute3 inv_global_attribute3
				  , idpa.global_attribute4 inv_global_attribute4
				  , idpa.global_attribute5 inv_global_attribute5
				  , idpa.global_attribute6 inv_global_attribute6
				  , idpa.global_attribute7 inv_global_attribute7
				  , idpa.global_attribute8 inv_global_attribute8
				  , idpa.global_attribute9 inv_global_attribute9
				  , idpa.global_attribute10 inv_global_attribute10
				  , idpa.global_attribute11 inv_global_attribute11
				  , idpa.global_attribute12 inv_global_attribute12
				  , idpa.global_attribute13 inv_global_attribute13
				  , idpa.global_attribute14 inv_global_attribute14
				  , idpa.global_attribute15 inv_global_attribute15
				  , idpa.global_attribute16 inv_global_attribute16
				  , idpa.global_attribute17 inv_global_attribute17
				  , idpa.global_attribute18 inv_global_attribute18
				  , idpa.global_attribute19 inv_global_attribute19
				  , idpa.global_attribute20 inv_global_attribute20
				  , idpa.bank_charge_bearer bank_charge_bearer
				  , idpa.payment_reason_code payment_reason_code
				  , idpa.payment_reason_comments payment_reason_comments
				  , idpa.remittance_message1 remittance_message1
				  , idpa.remittance_message2 remittance_message2
				  , idpa.remittance_message3 remittance_message3
				  , idpa.unique_remittance_identifier unique_remittance_identifier
				  , idpa.uri_check_digit uri_check_digit
				  , idpa.delivery_channel_code delivery_channel_code
				  , idpa.settlement_priority settlement_priority
				  , idpa.external_bank_account_id external_bank_account_id
				  , idpa.payment_method_code payment_method_code
				  , ipa.payee_supplier_id vendor_id
				  , ipa.supplier_site_id vendor_site_id
				  , ipm.attribute1 payment_mean
				  , ipm.attribute2 payment_channel
				  , ipa.payee_country country
				  , ipa.PAYMENT_PROCESS_REQUEST_NAME
				  , ipa.INTERNAL_BANK_ACCOUNT_ID
				  , ipa.EXTERNAL_BANK_ACCOUNT_ID
				  , ipa.PAYMENT_REFERENCE_NUMBER
				  , ipa.PAPER_DOCUMENT_NUMBER
				FROM iby_docs_payable_all idpa
				  , iby_payments_all ipa
				  , iby_payment_methods_b ipm
				WHERE idpa.payment_id = ipa.payment_id
				AND idpa.payment_method_code = ipm.payment_method_code
				AND ipa.payment_instruction_id = p_payment_instruction_id;

    ec_debug.pop ( 'ECE_AP_TRANSACTION.insert_into_gt');
    fnd_file.put_line(fnd_file.log, 'Calling insert_into_gt :: END ::'||systimestamp);
  END insert_into_gt;


 PROCEDURE delete_from_gt IS
 BEGIN
   ec_debug.push('ECE_AP_TRANSACTION.delete_from_gt');
    fnd_file.put_line(fnd_file.log, 'Calling delete_from_gt :: START ::'||systimestamp);
    delete from IBY_PYO_PAYMENT_GT;
    delete from IBY_PYO_INVOICE_GT;
    fnd_file.put_line(fnd_file.log, 'Calling delete_from_gt :: END ::'||systimestamp);
   ec_debug.pop ( 'ECE_AP_TRANSACTION.delete_from_gt');
 END delete_from_gt;

END ece_ap_payment;


/
