--------------------------------------------------------
--  DDL for Package Body OZF_AUTO_WRITEOFF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_AUTO_WRITEOFF_PVT" AS
/* $Header: ozfvcwob.pls 120.5 2006/01/30 07:36:23 sshivali ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Auto_Writeoff_PVT
-- Purpose
--
-- History
--
-- NOTE : This package is created for Bug#:2757570
--
-- End of Comments
-- ===============================================================


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'OZF_Auto_Writeoff_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvcwob.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Populate_Auto_Writeoff_Data
--
-- HISTORY
--                aadhawad  Create.
--
---------------------------------------------------------------------
PROCEDURE Populate_Auto_Writeoff_Data(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY NUMBER,
    p_org_id           IN  NUMBER DEFAULT NULL,
    p_claim_class      IN  VARCHAR2,
    p_cust_account_id  IN  NUMBER,
    p_claim_type_id    IN  NUMBER,
    p_reason_code_id   IN  NUMBER
)
IS

-- Local Variable Declaration
l_retcode                    NUMBER := 0;
l_return_status              VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS ;
l_msg_count                  NUMBER;
l_msg_Data                   VARCHAR2(2000);
l_object_version             NUMBER(9);
l_claim_rec                  OZF_CLAIM_PVT.claim_rec_type;

v_total_writeoff_count       NUMBER := 0;
v_tot_writeoff_processed     NUMBER := 0;
v_tot_writeoff_not_processed NUMBER := 0;

l_claim_class_mean           VARCHAR2(80);
l_claim_type_name            VARCHAR2(80);
l_reason_code_name           VARCHAR2(80);
l_party_name                 VARCHAR2(240);

-- Cursor Declaration
-- Main Auto Writeoff Cursor
CURSOR get_auto_writeoff_claims_csr(p_claim_class     IN VARCHAR2
                                   ,p_cust_account_id IN NUMBER
                                   ,p_claim_type_id   IN NUMBER
                                   ,p_reason_code_id  IN NUMBER) IS
SELECT claim_id,
       object_version_number,
       claim_number,
       payment_method,
       status_code,
       user_status_id
FROM   ozf_claims
WHERE  cust_account_id = NVL(p_cust_account_id , cust_account_id)
AND    claim_type_id   = NVL(p_claim_type_id , claim_type_id)
AND    reason_code_id  = NVL(p_reason_code_id , reason_code_id)
AND    claim_class     = NVL(p_claim_class , claim_class)
AND    claim_class     IN ('DEDUCTION', 'OVERPAYMENT')
AND    status_code in ('OPEN','COMPLETE')
AND    write_off_flag = 'T';

CURSOR get_claim_type_csr(p_claim_type_id IN NUMBER) IS
SELECT name
FROM   ozf_claim_types_all_vl
WHERE  claim_type_id = p_claim_type_id;

CURSOR get_reason_code_csr(p_reason_code_id IN NUMBER) IS
SELECT name
FROM   ozf_reason_codes_all_vl
WHERE  reason_code_id = p_reason_code_id;

CURSOR get_claim_class_csr(p_claim_class IN VARCHAR2) IS
SELECT meaning
FROM   ozf_lookups
WHERE  lookup_code = p_claim_class
AND    lookup_type = 'OZF_CLAIM_CLASS';

CURSOR get_account_name_csr(p_cust_account_id IN NUMBER) IS
SELECT p.party_name
FROM   hz_parties p
,      hz_cust_accounts c
WHERE  p.party_id = c.party_id
AND    c.cust_account_id = p_cust_account_id;

--Multiorg Changes
CURSOR operating_unit_csr IS
    SELECT ou.organization_id   org_id
    FROM hr_operating_units ou
    WHERE mo_global.check_access(ou.organization_id) = 'Y';

m NUMBER := 0;
l_org_id     OZF_UTILITY_PVT.operating_units_tbl;

BEGIN
 	--Multiorg Changes
	MO_GLOBAL.init('OZF');

	IF p_org_id IS NULL THEN
		MO_GLOBAL.set_policy_context('M',null);
		OPEN operating_unit_csr;
		LOOP
		   FETCH operating_unit_csr into l_org_id(m);
		   m := m + 1;
		   EXIT WHEN operating_unit_csr%NOTFOUND;
		END LOOP;
		CLOSE operating_unit_csr;
	ELSE
		l_org_id(m) := p_org_id;
	END IF;

	--Multiorg Changes
	IF (l_org_id.COUNT > 0) THEN
		FOR m IN l_org_id.FIRST..l_org_id.LAST LOOP
		   MO_GLOBAL.set_policy_context('S',l_org_id(m));
           -- Write OU info to OUT file
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '-----------------------------------------------------');
           -- Write OU info to LOG file
           FND_FILE.PUT_LINE(FND_FILE.LOG,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
           FND_FILE.PUT_LINE(FND_FILE.LOG,  '-----------------------------------------------------');

		  -- Get meaning for the names
		  IF p_claim_class is not null then
			 open get_claim_class_csr (p_claim_class);
				fetch get_claim_class_csr into l_claim_class_mean;
			 close get_claim_class_csr;
		  end if;

		  IF p_claim_type_id is not null then
			 open get_claim_type_csr (p_claim_type_id);
				fetch get_claim_type_csr into l_claim_type_name;
			 close get_claim_type_csr;
		  end if;

		  IF p_reason_code_id is not null then
			 open get_reason_code_csr (p_reason_code_id);
				fetch get_reason_code_csr into l_reason_code_name;
			 close get_reason_code_csr;
		  end if;

		  IF p_cust_account_id is not null then
			 open get_account_name_csr (p_cust_account_id);
				fetch get_account_name_csr into l_party_name;
			 close get_account_name_csr;
		  end if;

		  -- Write Batch Initialization summary info to LOG file
		  FND_FILE.PUT_LINE(FND_FILE.LOG, '+------------------- AUTO-WRITEOFF PROCESS START SUMMARY -------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Starts on: '||to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
		  FND_FILE.PUT_LINE(FND_FILE.LOG, '+---------------------------------------------------------------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Parameter1-Claim Class: '||l_claim_class_mean);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Parameter2-Customer   : '||l_party_name);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Parameter3-Claim Type : '||l_claim_type_name);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Parameter4-Reason Code: '||l_reason_code_name);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, '+---------------------------------------------------------------------------+');

		  -- Write Batch Initialization summary info to OUT file
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+------------------- AUTO-WRITEOFF PROCESS START SUMMARY -------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Job Started on: '||to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+---------------------------------------------------------------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Job Parameter1-Claim Class: '||l_claim_class_mean);
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Job Parameter2-Customer   : '||l_party_name);
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Job Parameter3-Claim Type : '||l_claim_type_name);
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Job Parameter4-Reason Code: '||l_reason_code_name);
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+---------------------------------------------------------------------------+');

		  --bug#4940880 Update Payment Method
		  UPDATE ozf_claims
		  SET    payment_method = 'WRITE_OFF'
		  WHERE  cust_account_id = NVL(p_cust_account_id , cust_account_id)
		  AND    claim_type_id   = NVL(p_claim_type_id , claim_type_id)
		  AND    reason_code_id  = NVL(p_reason_code_id , reason_code_id)
		  AND    claim_class     = NVL(p_claim_class , claim_class)
		  AND    claim_class     IN ('DEDUCTION', 'OVERPAYMENT')
		  AND    status_code in ('OPEN','COMPLETE')
		  AND    write_off_flag = 'T';

		  -- Main Cursor
		  FOR l_writeoff_rec in get_auto_writeoff_claims_csr(p_claim_class
															,p_cust_account_id
															,p_claim_type_id
															,p_reason_code_id) LOOP

			FND_MSG_PUB.initialize;
			-- Count total records selected for write off.
			v_total_writeoff_count := v_total_writeoff_count + 1;

			BEGIN
			  SAVEPOINT Populate_Auto_Writeoff_Data;

			  -- Start: Build l_claim_rec.
			  l_claim_rec.claim_id                     := l_writeoff_rec.claim_id;
			  l_claim_rec.object_version_number        := l_writeoff_rec.object_version_number;
			  l_claim_rec.claim_number                 := l_writeoff_rec.claim_number;
			  l_claim_rec.status_code                  := l_writeoff_rec.status_code;
			  l_claim_rec.user_status_id               := l_writeoff_rec.user_status_id;
			  l_claim_rec.payment_method               := l_writeoff_rec.payment_method;
			  -- End: Build l_claim_rec

			  --Assign claim status to 'CLOSED'
			  l_claim_rec.status_code                  := 'CLOSED';
			  l_claim_rec.user_status_id               := null;
			  --FND_FILE.PUT_LINE(FND_FILE.LOG, 'STATUS CODE: '||l_claim_rec.status_code);

			  --Assign Payment Method to 'WRITE OFF'
			  l_claim_rec.payment_method               := 'WRITE_OFF';

			  --
			  -- ************************************************************************************
			  --Call OZF_CLAIM_PVT.Update_Claim to change the status to CLOSE.
			  OZF_CLAIM_PVT.Update_Claim (
				  p_api_version            => 1.0
				 ,p_init_msg_list          => FND_API.g_false
				 ,p_commit                 => FND_API.g_false
				 ,p_validation_level       => FND_API.g_valid_level_full
				 ,x_return_status          => l_return_status
				 ,x_msg_data               => l_msg_data
				 ,x_msg_count              => l_msg_count
				 ,p_claim                  => l_claim_rec
				 ,p_event                  => 'UPDATE'
				 ,p_mode                   => 'AUTO'
				 ,x_object_version_number  => l_object_version
			  );
			  IF l_return_status = FND_API.g_ret_sts_error THEN
				v_tot_writeoff_not_processed := v_tot_writeoff_not_processed + 1;
				ROLLBACK TO Populate_Auto_Writeoff_Data;
				--RAISE FND_API.g_exc_error;
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'Auto Write off Failed for claim Number: '||l_claim_rec.claim_number);
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Auto Write off Failed for claim Number: '||l_claim_rec.claim_number);
				OZF_UTILITY_PVT.write_conc_log;
			  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
				v_tot_writeoff_not_processed := v_tot_writeoff_not_processed + 1;
				ROLLBACK TO Populate_Auto_Writeoff_Data;
				--RAISE FND_API.g_exc_unexpected_error;
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'Auto Write off Failed for claim Number: '||l_claim_rec.claim_number);
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Auto Write off Failed for claim Number: '||l_claim_rec.claim_number);
				OZF_UTILITY_PVT.write_conc_log;
			  ELSE
				v_tot_writeoff_processed := v_tot_writeoff_processed + 1;
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'Auto Write off is Successful for claim Number: '||l_claim_rec.claim_number);
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Auto Write off is Successful for claim Number: '||l_claim_rec.claim_number);
			  END IF;
			  -- ************************************************************************************
			EXCEPTION
			  WHEN OTHERS THEN
				ROLLBACK TO Populate_Auto_Writeoff_Data;
			END;
		  END LOOP;

		  -- Write Batch summary info to LOG file
		  FND_FILE.PUT_LINE(FND_FILE.LOG, '+-------------------- AUTO-WRITEOFF PROCESS END SUMMARY --------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Job Ends on: '||to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
		  FND_FILE.PUT_LINE(FND_FILE.LOG, '+---------------------------------------------------------------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Number of Claims Selected for Write offs........: '||v_total_writeoff_count);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Number of Claims Processed for Write offs.......: '||v_tot_writeoff_processed);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Number of Claims NOT Processed for Write offs...: '||v_tot_writeoff_not_processed);
		  FND_FILE.PUT_LINE(FND_FILE.LOG, '+---------------------------------------------------------------------------+');

		  -- Write Batch summary info to OUT file
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+-------------------- AUTO-WRITEOFF PROCESS END SUMMARY --------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Job Ended on: '||to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+---------------------------------------------------------------------------+');
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Number of Claims Selected for Write offs........: '||v_total_writeoff_count);
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Number of Claims Processed for Write offs.......: '||v_tot_writeoff_processed);
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Number of Claims NOT Processed for Write offs...: '||v_tot_writeoff_not_processed);
		  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '+---------------------------------------------------------------------------+');

	   END LOOP;
	END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Populate_Auto_Writeoff_Data;
    OZF_UTILITY_PVT.write_conc_log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Populate_Auto_Writeoff_Data;
    OZF_UTILITY_PVT.write_conc_log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;
  WHEN OTHERS THEN
    ROLLBACK TO Populate_Auto_Writeoff_Data;
    OZF_UTILITY_PVT.write_conc_log;
    ERRBUF  := substr(sqlerrm, 1, 80);
    RETCODE := 2;

End Populate_Auto_Writeoff_Data;


END OZF_AUTO_WRITEOFF_PVT;

/
