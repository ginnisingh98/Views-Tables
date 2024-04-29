--------------------------------------------------------
--  DDL for Package Body IBY_SUPP_BANK_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_SUPP_BANK_MERGE_PUB" AS
/* $Header: ibybnkmergb.pls 120.2.12010000.2 2010/04/22 09:45:01 gmaheswa noship $ */
  G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_SUPP_BANK_MERGE_PUB';

  PROCEDURE MERGE_BANKS (
	from_instr_pmt_use_list		IN Id_Tab_Type,
	from_ext_payee_id_list		IN Id_Tab_Type,
	from_bank_account_id_list	IN Id_Tab_Type,
	to_instr_pmt_use_list		IN Id_Tab_Type,
	to_ext_payee_id_list		IN Id_Tab_Type,
	to_bank_account_id_list		IN Id_Tab_Type,
	p_to_ext_payee_id		IN NUMBER,
	p_from_party_id			IN NUMBER,
	P_to_party_id			IN NUMBER,
	p_level				IN VARCHAR2,
	p_last_site_flag		IN VARCHAR2,
	X_return_status			IN     OUT NOCOPY VARCHAR2,
	X_msg_count			IN     OUT NOCOPY NUMBER,
	X_msg_data			IN     OUT NOCOPY VARCHAR2
)   IS

   CURSOR get_from_instr_use_dtls (cp_instrument_payment_use_id IN NUMBER) IS
   SELECT *
   FROM iby_pmt_instr_uses_all
   WHERE instrument_payment_use_id = cp_instrument_payment_use_id;

   CURSOR max_order_of_pref (cp_ext_payee_id IN NUMBER) IS
   SELECT MAX(order_of_preference)
   FROM iby_pmt_instr_uses_all
   WHERE ext_pmt_party_id = cp_ext_payee_id;

   CURSOR cur_is_ownership_exists(cp_to_party_id IN NUMBER, cp_bank_act_id IN NUMBER) IS
   SELECT 'Y'
   FROM iby_account_owners
   WHERE account_owner_party_id = cp_to_party_id
   AND ext_bank_account_id = cp_bank_act_id
   AND NVL(end_date,SYSDATE) > = SYSDATE;

   CURSOR cur_get_primary_ownership (cp_from_party_id IN NUMBER, cp_bank_act_id IN NUMBER) IS
   SELECT Primary_flag
   FROM iby_account_owners
   WHERE ext_bank_account_id = cp_bank_act_id
   AND account_owner_party_id = cp_from_party_id
   AND NVL (end_date, Sysdate)  >= Sysdate;

rec_get_from_instr_use_dtls iby_pmt_instr_uses_all%ROWTYPE;

l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.BANK_ACCOUNTS_MERGE(MERGE_BANKS)';
g_mesg            VARCHAR2(1000) := '';
L_BANK_ACCOUNT_EXITS BOOLEAN;
l_max_order_of_pref NUMBER;
l_is_ownership_exist VARCHAR2(1);
l_is_primary VARCHAR2(1);

BEGIN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	g_mesg := '	Start MERGE_BANKS '  ;
	fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;
     -- For all Bank Accounts for From supplier
     IF (from_bank_account_id_list.COUNT > 0) THEN
	    FOR I IN from_bank_account_id_list.FIRST..from_bank_account_id_list.LAST
	    LOOP
		IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 	        g_mesg := '	Start Processing Bank Account Id => '|| from_bank_account_id_list(I) ;
			fnd_file.put_line(fnd_file.log, g_mesg);
		END IF;
		l_bank_account_exits := FALSE;
		l_max_order_of_pref := 0;
		l_is_primary := 'N';
		l_is_ownership_exist := NULL;

		-- Check whether bank account is already associated to to-Supplier
		IF (to_bank_account_id_list.COUNT > 0) THEN
			IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				g_mesg := '	Check whether the bank account is already existing for to-supplier ' ;
				fnd_file.put_line(fnd_file.log, g_mesg);
			END IF;

			FOR J IN to_bank_account_id_list.FIRST..to_bank_account_id_list.LAST
			LOOP
				IF (from_bank_account_id_list(I) = to_bank_account_id_list(J)) THEN
					l_bank_account_exits := TRUE;
 				        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		 				g_mesg := '	Bank Account exist for Supplier2' ;
						fnd_file.put_line(fnd_file.log, g_mesg);
					END IF;
				END IF;
			END LOOP;
			IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				g_mesg := '	End of To Bank account id list Loop' ;
				fnd_file.put_line(fnd_file.log, g_mesg);
			END IF;
			OPEN max_order_of_pref(p_to_ext_payee_id);
			FETCH max_order_of_pref INTO l_max_order_of_pref;
			CLOSE max_order_of_pref;
		END IF;

		-- If Bank account is not associated to To-Supplier
		IF NOT l_bank_account_exits THEN
			IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				g_mesg := '	Bank Account Does not exist for Supplier2 ' ;
				fnd_file.put_line(fnd_file.log, g_mesg);
			END IF;

			OPEN get_from_instr_use_dtls(from_instr_pmt_use_list(i));
			FETCH get_from_instr_use_dtls INTO rec_get_from_instr_use_dtls;
			CLOSE get_from_instr_use_dtls;
			IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				g_mesg := '	Inserting record into Instruments l_max_order_of_pref => '|| l_max_order_of_pref ;
				fnd_file.put_line(fnd_file.log, g_mesg);
			END IF;
			INSERT INTO iby_pmt_instr_uses_all(
				INSTRUMENT_PAYMENT_USE_ID,
				PAYMENT_FLOW             ,
				EXT_PMT_PARTY_ID         ,
				INSTRUMENT_TYPE          ,
				INSTRUMENT_ID            ,
				PAYMENT_FUNCTION         ,
				ORDER_OF_PREFERENCE      ,
				CREATED_BY               ,
				CREATION_DATE            ,
				LAST_UPDATED_BY          ,
				LAST_UPDATE_DATE         ,
				LAST_UPDATE_LOGIN        ,
				OBJECT_VERSION_NUMBER    ,
				START_DATE               ,
				END_DATE                 ,
				DEBIT_AUTH_FLAG          ,
				DEBIT_AUTH_METHOD        ,
				DEBIT_AUTH_REFERENCE     ,
				DEBIT_AUTH_BEGIN         ,
				DEBIT_AUTH_END           ,
				ATTRIBUTE_CATEGORY       ,
				ATTRIBUTE1               ,
				ATTRIBUTE2               ,
				ATTRIBUTE3               ,
				ATTRIBUTE4               ,
				ATTRIBUTE5               ,
				ATTRIBUTE6               ,
				ATTRIBUTE7               ,
				ATTRIBUTE8               ,
				ATTRIBUTE9               ,
				ATTRIBUTE10              ,
				ATTRIBUTE11              ,
				ATTRIBUTE12              ,
				ATTRIBUTE13              ,
				ATTRIBUTE14              ,
				ATTRIBUTE15
				)
			VALUES(
				IBY_PMT_INSTR_USES_ALL_S.NEXTVAL		     ,
				rec_get_from_instr_use_dtls.PAYMENT_FLOW             ,
				p_to_ext_payee_id				     ,
				rec_get_from_instr_use_dtls.INSTRUMENT_TYPE          ,
				rec_get_from_instr_use_dtls.INSTRUMENT_ID            ,
				rec_get_from_instr_use_dtls.PAYMENT_FUNCTION         ,
				DECODE(l_max_order_of_pref, 0, rec_get_from_instr_use_dtls.order_of_preference,l_max_order_of_pref+1),
				hz_utility_pub.created_by			     ,
				hz_utility_pub.CREATION_DATE			     ,
				hz_utility_pub.LAST_UPDATED_BY			     ,
				hz_utility_pub.LAST_UPDATE_DATE			     ,
				hz_utility_pub.LAST_UPDATE_LOGIN		     ,
				1						     ,
				rec_get_from_instr_use_dtls.START_DATE		     ,
				rec_get_from_instr_use_dtls.END_DATE                 ,
				rec_get_from_instr_use_dtls.DEBIT_AUTH_FLAG          ,
				rec_get_from_instr_use_dtls.DEBIT_AUTH_METHOD        ,
				rec_get_from_instr_use_dtls.DEBIT_AUTH_REFERENCE     ,
				rec_get_from_instr_use_dtls.DEBIT_AUTH_BEGIN         ,
				rec_get_from_instr_use_dtls.DEBIT_AUTH_END           ,
				rec_get_from_instr_use_dtls.ATTRIBUTE_CATEGORY       ,
				rec_get_from_instr_use_dtls.ATTRIBUTE1               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE2               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE3               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE4               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE5               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE6               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE7               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE8               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE9               ,
				rec_get_from_instr_use_dtls.ATTRIBUTE10              ,
				rec_get_from_instr_use_dtls.ATTRIBUTE11              ,
				rec_get_from_instr_use_dtls.ATTRIBUTE12              ,
				rec_get_from_instr_use_dtls.ATTRIBUTE13              ,
				rec_get_from_instr_use_dtls.ATTRIBUTE14              ,
				rec_get_from_instr_use_dtls.ATTRIBUTE15
			);

			-- Check whether bank account , To-Supplier ownership exists.
			OPEN cur_is_ownership_exists(P_to_party_id, from_bank_account_id_list(I));
			FETCH cur_is_ownership_exists INTO l_is_ownership_exist;
			CLOSE cur_is_ownership_exists;

 			IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				g_mesg := '	Processing Bank Account Ownership';
				fnd_file.put_line(fnd_file.log, g_mesg);
			END IF;

			IF p_last_site_flag = 'Y' THEN
				IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
					g_mesg := '	p_last_site_flag := Y ' ;
					fnd_file.put_line(fnd_file.log, g_mesg);
				END IF;

				OPEN cur_get_primary_ownership(p_from_party_id, from_bank_account_id_list(I));
				FETCH cur_get_primary_ownership INTO l_is_primary;
				CLOSE cur_get_primary_ownership;

				IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
					g_mesg := '	Is From Supplier Primary?  '|| l_is_primary;
					fnd_file.put_line(fnd_file.log, g_mesg);
					g_mesg := '	Is To Supplier Ownership Exists?  '|| l_is_ownership_exist;
					fnd_file.put_line(fnd_file.log, g_mesg);
				END IF;


				IF l_is_primary = 'Y' AND  l_is_ownership_exist IS NOT NULL THEN
					IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
						g_mesg := '	From Supplier is Primary and To Supplier Ownership Exists ' ;
						fnd_file.put_line(fnd_file.log, g_mesg);
					END IF;

					UPDATE iby_account_owners
					SET primary_flag = 'N'
					WHERE ext_bank_account_id = from_bank_account_id_list(I)
					AND account_owner_party_id = p_from_party_id;

					UPDATE iby_account_owners
					SET primary_flag = 'Y'
					WHERE ext_bank_account_id = from_bank_account_id_list(I)
					AND account_owner_party_id = P_to_party_id;

				ELSIF l_is_primary = 'Y' AND l_is_ownership_exist IS NULL THEN
					IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
						g_mesg := '	From Supplier is Primary and To Supplier Ownership Does not Exist ' ;
						fnd_file.put_line(fnd_file.log, g_mesg);
					END IF;

					UPDATE iby_account_owners
					SET primary_flag = 'N'
					WHERE ext_bank_account_id = from_bank_account_id_list(I)
					AND account_owner_party_id = p_from_party_id;

					INSERT INTO iby_account_owners(
						ACCOUNT_OWNER_ID        ,
						EXT_BANK_ACCOUNT_ID     ,
						ACCOUNT_OWNER_PARTY_ID  ,
						END_DATE                ,
						PRIMARY_FLAG            ,
						CREATED_BY              ,
						CREATION_DATE           ,
						LAST_UPDATED_BY         ,
						LAST_UPDATE_DATE        ,
						LAST_UPDATE_LOGIN       ,
						OBJECT_VERSION_NUMBER
					)VALUES(
						IBY_ACCOUNT_OWNERS_S.NEXTVAL	       ,
						from_bank_account_id_list(I)	       ,
						P_to_party_id			       ,
						NULL				       ,
						'Y'				       ,
						hz_utility_pub.CREATED_BY              ,
						hz_utility_pub.CREATION_DATE           ,
						hz_utility_pub.LAST_UPDATED_BY         ,
						hz_utility_pub.LAST_UPDATE_DATE        ,
						hz_utility_pub.LAST_UPDATE_LOGIN       ,
						1
					);
				ELSIF l_is_primary = 'N' AND l_is_ownership_exist IS NULL THEN
					IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
						g_mesg := '	From Supplier is non Primary and To Supplier Ownership Does not Exist ' ;
						fnd_file.put_line(fnd_file.log, g_mesg);
					END IF;

					INSERT INTO iby_account_owners(
						ACCOUNT_OWNER_ID        ,
						EXT_BANK_ACCOUNT_ID     ,
						ACCOUNT_OWNER_PARTY_ID  ,
						END_DATE                ,
						PRIMARY_FLAG            ,
						CREATED_BY              ,
						CREATION_DATE           ,
						LAST_UPDATED_BY         ,
						LAST_UPDATE_DATE        ,
						LAST_UPDATE_LOGIN       ,
						OBJECT_VERSION_NUMBER
					)VALUES(
						IBY_ACCOUNT_OWNERS_S.NEXTVAL	       ,
						from_bank_account_id_list(I)	       ,
						P_to_party_id			       ,
						NULL				       ,
						'N'				       ,
						hz_utility_pub.CREATED_BY              ,
						hz_utility_pub.CREATION_DATE           ,
						hz_utility_pub.LAST_UPDATED_BY         ,
						hz_utility_pub.LAST_UPDATE_DATE        ,
						hz_utility_pub.LAST_UPDATE_LOGIN       ,
						1
					);
				END IF;
			ELSIF l_is_ownership_exist IS NULL THEN
				IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
					g_mesg := '	To Supplier Ownership Does not Exist ' ;
					fnd_file.put_line(fnd_file.log, g_mesg);
				END IF;

				INSERT INTO iby_account_owners(
					ACCOUNT_OWNER_ID        ,
					EXT_BANK_ACCOUNT_ID     ,
					ACCOUNT_OWNER_PARTY_ID  ,
					END_DATE                ,
					PRIMARY_FLAG            ,
					CREATED_BY              ,
					CREATION_DATE           ,
					LAST_UPDATED_BY         ,
					LAST_UPDATE_DATE        ,
					LAST_UPDATE_LOGIN       ,
					OBJECT_VERSION_NUMBER
				)VALUES(
					IBY_ACCOUNT_OWNERS_S.NEXTVAL	       ,
					from_bank_account_id_list(I)	       ,
					P_to_party_id			       ,
					NULL				       ,
					'N'				       ,
					hz_utility_pub.CREATED_BY              ,
					hz_utility_pub.CREATION_DATE           ,
					hz_utility_pub.LAST_UPDATED_BY         ,
					hz_utility_pub.LAST_UPDATE_DATE        ,
					hz_utility_pub.LAST_UPDATE_LOGIN       ,
					1
				);
			END IF;
		END IF;
		IF p_level = 'SITE' THEN
		     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			g_mesg := '	Inactivating instruments at site level';
			fnd_file.put_line(fnd_file.log, g_mesg);
		     END IF;

		     UPDATE iby_pmt_instr_uses_all
		     SET end_date = SYSDATE
		     WHERE instrument_payment_use_id = from_instr_pmt_use_list(I);

		     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			g_mesg := '	End Processing for Bank Account Id => '||from_bank_account_id_list(I);
			fnd_file.put_line(fnd_file.log, g_mesg);
		     END IF;
		END IF;
	    END LOOP;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN

     g_mesg :='Unexpected error: ' || SQLERRM;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
     FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END MERGE_BANKS;

PROCEDURE INSERT_PAYEE_ROW(ext_payee_rec	IN IBY_EXTERNAL_PAYEES_ALL%ROWTYPE,
			   P_EXT_PAYEE_ID	IN OUT NOCOPY NUMBER,
                           x_return_status	OUT NOCOPY VARCHAR2 ,
			   X_MSG_COUNT		IN     OUT NOCOPY NUMBER,
			   X_MSG_DATA		OUT NOCOPY VARCHAR2)
IS

CURSOR get_next_ext_payee_id IS
SELECT IBY_EXTERNAL_PAYEES_ALL_S.NEXTVAL
FROM DUAL;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN get_next_ext_payee_id;
    FETCH get_next_ext_payee_id INTO P_EXT_PAYEE_ID;
    CLOSE get_next_ext_payee_id;

    INSERT INTO IBY_EXTERNAL_PAYEES_ALL(
    EXT_PAYEE_ID,
    PAYEE_PARTY_ID,
    PAYMENT_FUNCTION,
    EXCLUSIVE_PAYMENT_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    PARTY_SITE_ID,
    SUPPLIER_SITE_ID,
    ORG_ID,
    ORG_TYPE,
    DEFAULT_PAYMENT_METHOD_CODE,
    ECE_TP_LOCATION_CODE,
    BANK_CHARGE_BEARER,
    BANK_INSTRUCTION1_CODE,
    BANK_INSTRUCTION2_CODE,
    BANK_INSTRUCTION_DETAILS,
    PAYMENT_REASON_CODE,
    PAYMENT_REASON_COMMENTS,
    INACTIVE_DATE,
    PAYMENT_TEXT_MESSAGE1,
    PAYMENT_TEXT_MESSAGE2,
    PAYMENT_TEXT_MESSAGE3,
    DELIVERY_CHANNEL_CODE,
    PAYMENT_FORMAT_CODE,
    SETTLEMENT_PRIORITY,
    REMIT_ADVICE_DELIVERY_METHOD,
    REMIT_ADVICE_EMAIL,
    REMIT_ADVICE_FAX)
    VALUES (
    p_ext_payee_id,
    ext_payee_rec.Payee_Party_Id,
    ext_payee_rec.Payment_Function,
    ext_payee_rec.EXCLUSIVE_PAYMENT_FLAG,
    hz_utility_pub.CREATED_BY,
    hz_utility_pub.CREATION_DATE,
    hz_utility_pub.LAST_UPDATED_BY,
    hz_utility_pub.LAST_UPDATE_DATE,
    hz_utility_pub.LAST_UPDATE_LOGIN,
    1.0,
    ext_payee_rec.PARTY_SITE_ID,
    ext_payee_rec.Supplier_Site_Id,
    ext_payee_rec.Org_Id,
    ext_payee_rec.ORG_TYPE,
    ext_payee_rec.DEFAULT_PAYMENT_METHOD_CODE,
    ext_payee_rec.ECE_TP_LOCATION_CODE,
    ext_payee_rec.Bank_Charge_Bearer,
    ext_payee_rec.BANK_INSTRUCTION1_CODE,
    ext_payee_rec.BANK_INSTRUCTION2_CODE,
    ext_payee_rec.BANK_INSTRUCTION_DETAILS,
    ext_payee_rec.PAYMENT_REASON_CODE,
    ext_payee_rec.PAYMENT_REASON_COMMENTS,
    ext_payee_rec.Inactive_Date,
    ext_payee_rec.PAYMENT_TEXT_MESSAGE1,
    ext_payee_rec.PAYMENT_TEXT_MESSAGE2,
    ext_payee_rec.PAYMENT_TEXT_MESSAGE3,
    ext_payee_rec.DELIVERY_CHANNEL_CODE,
    ext_payee_rec.PAYMENT_FORMAT_CODE,
    ext_payee_rec.Settlement_Priority,
    ext_payee_rec.REMIT_ADVICE_DELIVERY_METHOD,
    ext_payee_rec.REMIT_ADVICE_EMAIL,
    ext_payee_rec.remit_advice_fax);

EXCEPTION
   WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log, 'Exception: insert_payee_row: '||SQLERRM);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     X_MSG_DATA := 'Exception: insert_payee_row: '||SQLERRM;

END INSERT_PAYEE_ROW;

PROCEDURE CREATE_EXTERNAL_PAYEE(
   P_SITE_EXT_PAYEE_ID		IN	NUMBER,
   P_LEVEL			IN	VARCHAR2,
   P_EXT_PAYEE_ID		IN	OUT NOCOPY NUMBER,
   X_RETURN_STATUS		IN	OUT NOCOPY VARCHAR2,
   X_MSG_COUNT			IN	OUT NOCOPY NUMBER,
   X_MSG_DATA			IN	OUT NOCOPY VARCHAR2
)IS

CURSOR cur_get_payee_dtls (cp_ext_payee_id IN NUMBER) IS
SELECT *
FROM IBY_EXTERNAL_PAYEES_ALL
WHERE ext_payee_id = cp_ext_payee_id;

ext_payee_tab               IBY_DISBURSEMENT_SETUP_PUB.External_Payee_Tab_Type;
ext_payee_id_tab            IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Id_Tab_Type;
ext_payee_create_tab        IBY_DISBURSEMENT_SETUP_PUB.Ext_Payee_Create_Tab_Type;

l_Disb_payee_rec	IBY_DISBURSEMENT_SETUP_PUB.EXTERNAL_PAYEE_REC_TYPE;
l_Ext_payee_rec		IBY_EXTERNAL_PAYEES_ALL%ROWTYPE;

l_pay_return_status                 VARCHAR2(50);
l_pay_msg_count                     NUMBER;
l_pay_msg_data                      VARCHAR2(1000);
g_mesg            VARCHAR2(1000) := '';

BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    OPEN cur_get_payee_dtls(P_SITE_EXT_PAYEE_ID);
    FETCH cur_get_payee_dtls INTO l_Ext_payee_rec;
    CLOSE cur_get_payee_dtls;

    IF P_LEVEL = 'ADDRESS_OU' THEN
	-- Address_OU Record
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		g_mesg := 'Creating External Payee Record at Address-OU level';
		fnd_file.put_line(fnd_file.log, g_mesg);
	END IF;
        l_Ext_payee_rec.supplier_site_id := NULL;
	insert_payee_row(l_Ext_payee_rec, P_EXT_PAYEE_ID, x_return_status, X_MSG_COUNT, X_MSG_DATA);
    ELSIF P_LEVEL = 'ADDRESS' THEN
	-- Address Record
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		g_mesg := 'Creating External Payee Record at Address level';
		fnd_file.put_line(fnd_file.log, g_mesg);
	END IF;
	l_Ext_payee_rec.supplier_site_id := NULL;
	l_Ext_payee_rec.Org_Id := NULL;
	l_Ext_payee_rec.Org_Type := NULL;
	insert_payee_row(l_Ext_payee_rec, P_EXT_PAYEE_ID, x_return_status, X_MSG_COUNT, X_MSG_DATA);
    ELSIF P_LEVEL = 'SUPPLIER' THEN
	-- Supplier Record
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		g_mesg := 'Creating External Payee Record at Supplier level';
		fnd_file.put_line(fnd_file.log, g_mesg);
	END IF;
	l_Ext_payee_rec.supplier_site_id := NULL;
	l_Ext_payee_rec.Org_Id := NULL;
	l_Ext_payee_rec.Org_Type := NULL;
	l_Ext_payee_rec.PARTY_SITE_ID := NULL;
	insert_payee_row(l_Ext_payee_rec, P_EXT_PAYEE_ID, x_return_status, X_MSG_COUNT, X_MSG_DATA);
    END IF;
END CREATE_EXTERNAL_PAYEE;

PROCEDURE BANK_ACCOUNTS_MERGE (
   P_from_vendor_id		IN     NUMBER,
   P_to_vendor_id		IN     NUMBER,
   P_from_party_id		IN     NUMBER,
   P_to_party_id		IN     NUMBER,
   P_from_vendor_site_id	IN     NUMBER,
   P_to_vendor_site_id		IN     NUMBER,
   P_from_party_site_id		IN     NUMBER,
   P_to_partysite_id		IN     NUMBER,
   P_from_org_id		IN     NUMBER,
   P_to_org_id			IN     NUMBER,
   P_from_org_type		IN     VARCHAR2,
   P_to_org_type		IN     VARCHAR2,
   p_keep_site_flag		IN     VARCHAR2,
   p_last_site_flag		IN     VARCHAR2,
   X_return_status		IN     OUT NOCOPY VARCHAR2,
   X_msg_count			IN     OUT NOCOPY NUMBER,
   X_msg_data			IN     OUT NOCOPY VARCHAR2
)   IS

--Get Active Bank Accounts assigned to Supplier 1
   CURSOR get_supplier_site_bank_dtls(cp_party_id IN NUMBER, cp_vendor_site_id IN NUMBER, cp_party_site_id IN NUMBER, cp_org_id IN NUMBER, cp_org_type IN VARCHAR2) IS
   SELECT
	Uses.instrument_payment_use_id ,
	Payee.ext_payee_id,
	Uses.instrument_id bank_account_id
   FROM
	Iby_pmt_instr_uses_all uses,
	Iby_external_payees_all payee
   WHERE
	Payee.ext_payee_id = uses.ext_pmt_party_id
	AND uses.payment_function = 'PAYABLES_DISB'
	AND uses.payment_flow = 'DISBURSEMENTS'
	AND uses.instrument_type = 'BANKACCOUNT'
	AND payee.payee_party_id = cp_party_id
	AND (((payee.supplier_site_id IS NULL) AND (cp_vendor_site_id IS NULL)) OR (payee.supplier_site_id = cp_vendor_site_id))
	AND (((payee.party_site_id IS NULL) AND (cp_party_site_id IS NULL)) OR (payee.party_site_id = cp_party_site_id))
	AND (((payee.org_id IS NULL) AND (cp_org_id IS NULL)) OR (payee.org_id = cp_org_id))
	AND (((payee.org_type IS NULL) AND (cp_org_type IS NULL)) OR (payee.org_type = cp_org_type));

   CURSOR cur_get_to_party_site_id(cp_vendor_site_id IN NUMBER) IS
   SELECT party_site_id
   FROM ap_supplier_sites_all
   WHERE vendor_site_id = cp_vendor_site_id;

   CURSOR cur_get_ext_payee_id (cp_party_id IN NUMBER, cp_vendor_site_id IN NUMBER, cp_party_site_id IN NUMBER, cp_org_id IN NUMBER, cp_org_type IN VARCHAR2) IS
   SELECT ext_payee_id
   FROM Iby_external_payees_all payee
   WHERE payee.payee_party_id = cp_party_id
   AND (((payee.supplier_site_id IS NULL) AND (cp_vendor_site_id IS NULL)) OR (payee.supplier_site_id = cp_vendor_site_id))
   AND (((payee.party_site_id IS NULL) AND (cp_party_site_id IS NULL)) OR (payee.party_site_id = cp_party_site_id))
   AND (((payee.org_id IS NULL) AND (cp_org_id IS NULL)) OR (payee.org_id = cp_org_id))
   AND (((payee.org_type IS NULL) AND (cp_org_type IS NULL)) OR (payee.org_type = cp_org_type));

   from_instr_pmt_use_list Id_Tab_Type;
   from_bank_account_id_list Id_Tab_Type;
   from_ext_payee_id_list Id_Tab_Type;

   to_instr_pmt_use_list Id_Tab_Type;
   to_bank_account_id_list Id_Tab_Type;
   to_ext_payee_id_list Id_Tab_Type;

   rec_get_from_instr_use_dtls iby_pmt_instr_uses_all%ROWTYPE;

   l_dbg_mod		VARCHAR2(100) := G_DEBUG_MODULE || '.BANK_ACCOUNTS_MERGE';
   g_mesg		VARCHAR2(1000) := '';
   L_BANK_ACCOUNT_EXITS BOOLEAN;
   l_max_order_of_pref	NUMBER;
   l_is_ownership_exist VARCHAR2(1);
   l_to_ext_payee_id	NUMBER;
   L_TO_PARTY_SITE_ID	NUMBER;
   l_site_payee_id	NUMBER;

   BEGIN
     X_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     -- Log All Parameters
     g_mesg := 'Entering IBY_SUPP_BANK_MERGE.BANK_ACCOUNTS_MERGE ';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'P_FROM_VENDOR_ID : '|| p_from_vendor_id;
     fnd_file.put_line(fnd_file.log, g_mesg );

     g_mesg := 'P_FROM_VENDOR_ID => '||P_from_vendor_id;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_TO_VENDOR_ID => '||P_to_vendor_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_FROM_PARTY_ID => '|| P_from_party_id;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_TO_PARTY_ID => '|| P_to_party_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_FROM_VENDOR_SITE_ID => '|| P_from_vendor_site_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_TO_VENDOR_SITE_ID => '|| P_to_vendor_site_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_FROM_PARTY_SITE_ID => '|| P_from_party_site_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_TO_PARTYSITE_ID => '|| P_to_partysite_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_FROM_ORG_ID => '|| P_from_org_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_TO_ORG_ID => '|| P_to_org_id ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_FROM_ORG_TYPE => '||P_from_org_type ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_TO_ORG_TYPE => '||P_to_org_type ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_KEEP_SITE_FLAG => '||p_keep_site_flag ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     g_mesg := 'P_LAST_SITE_FLAG => '||p_keep_site_flag ;
     fnd_file.put_line(fnd_file.log, g_mesg);

     --Merge Bank Accounts at Supplier Site level
     g_mesg := 'Start Merging Bank Accounts at Suppier Site Level';
     fnd_file.put_line(fnd_file.log, g_mesg);
   END IF;
     -- Incase of COPY, new party site is created. Get the new party site id associated to the To Supplier Site.
     IF p_keep_site_flag = 'Y' THEN
        OPEN cur_get_to_party_site_id(P_to_vendor_site_id);
        FETCH cur_get_to_party_site_id INTO l_to_party_site_id;
        CLOSE cur_get_to_party_site_id;
     ELSE
        l_to_party_site_id := p_to_partysite_id;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	g_mesg := 'l_to_party_site_id: '||l_to_party_site_id;
	fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;

     -- Get the From Supplier Bank Accounts at Supplier Site Level
     OPEN  get_supplier_site_bank_dtls(P_from_party_id, P_from_vendor_site_id, P_from_party_site_id, P_from_org_id, P_from_org_type);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     -- Get the To Supplier Bank Accounts at Supplier Site Level
     OPEN  get_supplier_site_bank_dtls(P_to_party_id, P_to_vendor_site_id, l_to_party_site_id, P_to_org_id, P_to_org_type);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     -- Get the To External Payee ID at  Supplier Site Level. Incase of Copy this record is created by AP.
     OPEN cur_get_ext_payee_id(P_to_party_id, P_to_vendor_site_id, l_to_party_site_id, P_to_org_id, P_to_org_type);
     FETCH cur_get_ext_payee_id INTO l_to_ext_payee_id;
     CLOSE cur_get_ext_payee_id;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'Payee ID => '||l_to_ext_payee_id ;
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;

     l_site_payee_id := l_to_ext_payee_id;

     -- Invoke Merge Banks
     MERGE_BANKS(from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list,to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list,l_to_ext_payee_id,
		P_from_party_id, P_to_party_id,'SITE',p_last_site_flag, X_return_status,  X_msg_count, X_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'End Merging Bank Accounts at Suppier Site Level';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;

     --Merge Bank Accounts at Address OU level
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'Start Merging Bank Accounts at Suppier Address - OU Level';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;
     -- Get the From Supplier Bank Accounts at Address-OU Level
     OPEN  get_supplier_site_bank_dtls(P_from_party_id, null, P_from_party_site_id, P_from_org_id, P_from_org_type);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     -- Get the To Supplier Bank Accounts at Address-OU Level
     OPEN  get_supplier_site_bank_dtls(P_to_party_id, null, l_to_party_site_id, P_to_org_id, P_to_org_type);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     l_to_ext_payee_id := NULL;
     -- Check whether the external Payee is created
     OPEN cur_get_ext_payee_id(P_to_party_id, null, l_to_party_site_id, P_to_org_id, P_to_org_type);
     FETCH cur_get_ext_payee_id INTO l_to_ext_payee_id;
     CLOSE cur_get_ext_payee_id;

     -- If external Payee record is not available and there are bank accounts associated to From Supplier Address-OU Then create External payee at address-OU level.
     IF l_to_ext_payee_id IS NULL AND from_instr_pmt_use_list.Count > 0 THEN
	Create_external_payee(l_site_payee_id, 'ADDRESS_OU', l_to_ext_payee_id, X_RETURN_STATUS, X_MSG_COUNT, X_MSG_DATA);
	IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
	     fnd_file.put_line(fnd_file.log, 'Exception: '||X_MSG_DATA);
	END IF;
     END IF;

     -- Invoke Merge Banks
     MERGE_BANKS(from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list,to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list,l_to_ext_payee_id,
		P_from_party_id, P_to_party_id,'ADDRESS_OU',p_last_site_flag, X_return_status,  X_msg_count, X_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'End Merging Bank Accounts at Suppier Address - OU Level';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;
     --Merge Bank Accounts at Address level
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'Start Merging Bank Accounts at Suppier Address Level';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;
     -- Get the From Supplier Bank Accounts at Address Level
     OPEN  get_supplier_site_bank_dtls(P_from_party_id, null, P_from_party_site_id, null, null);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     -- Get the To Supplier Bank Accounts at Address Level
     OPEN  get_supplier_site_bank_dtls(P_to_party_id, null, l_to_party_site_id, null, null);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     l_to_ext_payee_id := NULL;
     -- Check whether the external Payee is created
     OPEN cur_get_ext_payee_id(P_to_party_id, null, l_to_party_site_id, null, null);
     FETCH cur_get_ext_payee_id INTO l_to_ext_payee_id;
     CLOSE cur_get_ext_payee_id;

     -- If external Payee record is not available and there are bank accounts associated to 'From Supplier' Address Then create External payee at address level.
     IF l_to_ext_payee_id IS NULL AND from_instr_pmt_use_list.Count > 0 THEN
	Create_external_payee(l_site_payee_id, 'ADDRESS', l_to_ext_payee_id, X_RETURN_STATUS, X_MSG_COUNT, X_MSG_DATA);
	IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
	     fnd_file.put_line(fnd_file.log, 'Exception: '||X_MSG_DATA);
	END IF;
     END IF;

     -- Invoke Merge Banks
     MERGE_BANKS(from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list,to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list,l_to_ext_payee_id,
		P_from_party_id, P_to_party_id, 'ADDRESS', p_last_site_flag, X_return_status,  X_msg_count, X_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'End Merging Bank Accounts at Suppier Address Level';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;
     --Merge Bank Accounts at Address level
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'Start Merging Bank Accounts at Suppier Level';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;

     -- Get the From Supplier Bank Accounts at Supplier Level
     OPEN  get_supplier_site_bank_dtls(P_from_party_id, null, null, null, null);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     -- Get the To Supplier Bank Accounts at Supplier Level
     OPEN  get_supplier_site_bank_dtls(P_to_party_id, null, null, null, null);
     FETCH get_supplier_site_bank_dtls BULK COLLECT INTO to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list;
     CLOSE get_supplier_site_bank_dtls;

     l_to_ext_payee_id := NULL;
     -- Check whether the external Payee is created
     OPEN cur_get_ext_payee_id(P_to_party_id, null, null, null, null);
     FETCH cur_get_ext_payee_id INTO l_to_ext_payee_id;
     CLOSE cur_get_ext_payee_id;

     -- If external Payee record is not available and there are bank accounts associated to 'From Supplier' Then create External payee at Supplier level.
     IF l_to_ext_payee_id IS NULL AND from_instr_pmt_use_list.Count > 0 THEN
	Create_external_payee(l_site_payee_id, 'SUPPLIER', l_to_ext_payee_id, X_RETURN_STATUS, X_MSG_COUNT, X_MSG_DATA);
	IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
	     fnd_file.put_line(fnd_file.log, 'Exception: '||X_MSG_DATA);
	END IF;
     END IF;

     -- Invoke Merge Banks
     MERGE_BANKS(from_instr_pmt_use_list, from_ext_payee_id_list, from_bank_account_id_list,to_instr_pmt_use_list, to_ext_payee_id_list, to_bank_account_id_list,
		 l_to_ext_payee_id, P_from_party_id, P_to_party_id, 'SUPPLIER', p_last_site_flag, X_return_status,  X_msg_count, X_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg := 'End Merging Bank Accounts at Suppier Level';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;
     -- If Last Site for the supplier then inactivate bank account associations for from supplier at all levels.
     IF p_last_site_flag = 'Y' THEN
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        g_mesg := 'Inactivating all Bank account associations of From Supplier';
		fnd_file.put_line(fnd_file.log, g_mesg);
	END IF;

	UPDATE iby_pmt_instr_uses_all
	SET end_date = SYSDATE
	WHERE ext_pmt_party_id IN
		(SELECT ext_payee_id
		FROM Iby_external_payees_all
		WHERE payee_party_id = P_from_party_id)
	AND payment_function = 'PAYABLES_DISB'
	AND payment_flow = 'DISBURSEMENTS'
	AND instrument_type = 'BANKACCOUNT'
	AND NVL(end_date,SYSDATE) >= SYSDATE;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     g_mesg :='Exit';
	     fnd_file.put_line(fnd_file.log, g_mesg);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN

     g_mesg :='Unexpected error:=' || SQLERRM;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
     FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END BANK_ACCOUNTS_MERGE;

END IBY_SUPP_BANK_MERGE_PUB;


/
