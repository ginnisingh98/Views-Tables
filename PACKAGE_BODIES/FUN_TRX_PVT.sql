--------------------------------------------------------
--  DDL for Package Body FUN_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TRX_PVT" AS
/* $Header: funtrxvalpvtb.pls 120.82.12010000.14 2010/02/10 11:59:03 makansal ship $ */

-- Note:
-- SETNAME if used on a namein that is not associated with a message
-- in database, then namein would become the message itself
-- Can use FND_MSG_PUB.get and ask it not to perform the translation for
-- recipient instance to send back message to initiator
--  Special handling when validating invoice_fule flag for 'M'
--  Not a concern anymore.  BC would create a function to get the
--  invoicing rule by trx type and le and trx entry page and webadi
--  needs to call is_ar_valid to determine the invoicing flag
--Problem Need to add validations for all debits or all credits (+ve/-ve)
-- Problem Add details for transaction entry page
NO_RATE EXCEPTION;

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FUN_TRX_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30) := 'FUNTRXVALPVTB.PLS';

G_LE_BSV_GT_INIT BOOLEAN := FALSE;
G_LEDGER_ID NUMBER := -1;
G_CHART_OF_ACCOUNTS_ID NUMBER := -1;
G_BAL_SEG_COLUMN_NAME VARCHAR2(25) := NULL;
G_LE_NAME VARCHAR2(60);
G_DEBUG VARCHAR2(5);

        PROCEDURE Set_Return_Status
(       x_orig_status IN OUT NOCOPY VARCHAR2,
        p_new_status IN VARCHAR2
) IS
        BEGIN
          -- API body
          IF (x_orig_status = FND_API.G_RET_STS_SUCCESS
                AND p_new_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 x_orig_status := p_new_status;
          ELSIF (x_orig_status = FND_API.G_RET_STS_ERROR
                 AND p_new_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_orig_status := p_new_status;
          END IF;
        -- End of API body.
END Set_Return_Status;

--Bug:6998219. validate_org_assignment

PROCEDURE validate_org_assignment
(       x_return_status OUT NOCOPY VARCHAR2  ,
        p_party_id  IN      NUMBER
) IS
  l_assignment_count NUMBER;
  l_party_name VARCHAR2(360);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT PARTY_NAME INTO l_party_name from HZ_PARTIES
WHERE PARTY_ID = p_party_id;

SELECT count(*) into l_assignment_count
FROM  HZ_PARTIES HZP,
      HZ_PARTIES  HZP2,
      HZ_RELATIONSHIPS HZR,
      HZ_ORG_CONTACTS HZC,
      HZ_ORG_CONTACT_ROLES HZCR
WHERE HZR.RELATIONSHIP_CODE='CONTACT_OF'
AND   HZR.RELATIONSHIP_TYPE='CONTACT'
AND   HZR.DIRECTIONAL_FLAG='F'
AND   HZR.SUBJECT_TABLE_NAME='HZ_PARTIES'
AND   HZR.OBJECT_TABLE_NAME='HZ_PARTIES'
AND   HZR.SUBJECT_TYPE='PERSON'
AND   HZR.OBJECT_ID=HZP2.PARTY_ID
AND   HZR.SUBJECT_ID=HZP.PARTY_ID
AND   HZR.OBJECT_ID = p_party_id
AND   HZC.PARTY_RELATIONSHIP_ID = HZR.RELATIONSHIP_ID
AND   HZCR.ORG_CONTACT_ID = HZC.ORG_CONTACT_ID
AND   HZCR.ROLE_TYPE = 'INTERCOMPANY_CONTACT_FOR'
AND   FUN_SECURITY.IS_ACCESS_VALID(HZP.PARTY_ID, HZP2.PARTY_ID)  = 'Y' -- Access1
AND   DECODE(HZR.STATUS,'A','Y','I','N') = 'Y' -- status
AND   HZR.ADDITIONAL_INFORMATION1 = 'Y' -- Notification
AND   sysdate BETWEEN
	nvl(HZR.start_date, sysdate -1)
	AND nvl(HZR.end_date, sysdate + 1);

IF( l_assignment_count = 0) then
 Set_Return_Status(x_orig_status => x_return_status,
                    p_new_status => FND_API.G_RET_STS_ERROR);
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_NO_ORG_ASSIGNMENT');
      FND_MESSAGE.SET_TOKEN('PARTY_NAME', l_party_name);
      FND_MSG_PUB.Add;
  END IF;
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

  Set_Return_Status(x_orig_status => x_return_status,
                    p_new_status => FND_API.G_RET_STS_ERROR);
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_NO_ORG_ASSIGNMENT');
      FND_MESSAGE.SET_TOKEN('PARTY_NAME', l_party_name);
      FND_MSG_PUB.Add;
   END IF;

END;
--Bug:9104801
PROCEDURE adjust_dist_amount
(       p_trx_id          IN NUMBER,
        p_init_amount_cr   IN              NUMBER,
        p_init_amount_dr   IN              NUMBER
) IS
        l_sum_amount_cr NUMBER;
        l_sum_amount_dr NUMBER;
	l_diff_amount NUMBER;
BEGIN
	select sum(amount_cr), sum(amount_dr)
	into l_sum_amount_cr, l_sum_amount_dr
	from fun_dist_lines
	where trx_id = p_trx_id
	and dist_type_flag = 'L'
	and party_type_flag = 'I';

	IF l_sum_amount_cr is not null and l_sum_amount_cr <> 0 THEN
		l_diff_amount :=  p_init_amount_dr - l_sum_amount_cr ;
		update fun_dist_lines dist1
		set dist1.amount_cr = dist1.amount_cr + l_diff_amount
		where dist1.amount_cr = (select max(dist2.amount_cr) from fun_dist_lines dist2
					where dist2.dist_type_flag = 'L'
					and dist2.party_type_flag = 'I'
					and dist2.trx_id = p_trx_id)
		and rownum = 1
		and dist1.dist_type_flag = 'L'
		and dist1.party_type_flag = 'I'
		and dist1.trx_id = p_trx_id;
	END IF;
	IF l_sum_amount_dr is not null and l_sum_amount_dr <> 0 THEN
		l_diff_amount := p_init_amount_cr - l_sum_amount_dr;
		update fun_dist_lines dist1
		set dist1.amount_dr = dist1.amount_dr + l_diff_amount
		where dist1.amount_dr = (select max(dist2.amount_dr) from fun_dist_lines dist2
					where dist2.dist_type_flag = 'L'
					and dist2.party_type_flag = 'I'
					and dist2.trx_id = p_trx_id)
		and rownum = 1
		and dist1.dist_type_flag = 'L'
		and dist1.party_type_flag = 'I'
		and dist1.trx_id = p_trx_id;
	END IF;
EXCEPTION
  WHEN OTHERS THEN
	NULL;
END adjust_dist_amount;

PROCEDURE Print
        (
               P_string                IN      VARCHAR2
        ) IS


BEGIN

IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, p_string);

END IF;

EXCEPTION
  WHEN OTHERS THEN
  APP_EXCEPTION.RAISE_EXCEPTION;
END Print;

PROCEDURE Is_Trx_Num_Unique
 (      x_return_status OUT NOCOPY VARCHAR2,
        p_batch_id  IN      number,
        p_trx_tbl        IN OUT NOCOPY TRX_TBL_TYPE) IS
  l_count NUMBER;
BEGIN
  Debug('IS_TRX_NUM_UNIQUE(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR I IN 1..p_trx_tbl.count LOOP
      l_count :=0;
      FOR J IN 1..p_trx_tbl.count LOOP
         IF p_trx_tbl(J).batch_id=p_batch_id AND p_trx_tbl(J).trx_number = p_trx_tbl(I).trx_number THEN
            l_count := l_count+1;
         END IF;
         IF l_count >  1 THEN
            FND_MESSAGE.SET_NAME('FUN', 'FUN_DUPL_TRX_NUM');
            FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_tbl(J).trx_number);
            FND_MSG_PUB.Add;
            Set_Return_Status(x_orig_status => x_return_status,
                    p_new_status => FND_API.G_RET_STS_ERROR);
            EXIT;
          END IF;
      END LOOP;
  END LOOP;
  Debug('IS_TRX_NUM_UNIQUE(-)');
END;



        PROCEDURE Is_Batch_Num_Unique
(       x_return_status OUT NOCOPY VARCHAR2,
        p_batch_number  IN      VARCHAR2,
        p_initiator_id  IN      NUMBER
) IS
  l_count NUMBER;
  CURSOR batch_num_csr IS
    SELECT COUNT(*)
    FROM fun_trx_batches
    WHERE initiator_id = p_initiator_id
      AND batch_number = p_batch_number;
BEGIN
  Debug('IS_BATCH_NUM_UNIQUE(+)');
  --7.2.1.3
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_count := 0;
  OPEN batch_num_csr;
  FETCH batch_num_csr INTO l_count;
  CLOSE batch_num_csr;
  IF l_count > 0  OR p_batch_number IS NULL THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_API_DUPLICATE_BATCH_NUM');
      FND_MSG_PUB.Add;
    END IF;
  Set_Return_Status(x_orig_status => x_return_status,
                    p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
  Debug('IS_BATCH_NUM_UNIQUE(-)');
END;


PROCEDURE check_invoice_reqd_flag(p_init_party_id      IN  NUMBER,
                                  p_init_le_id         IN NUMBER,
                                  p_reci_party_id      IN NUMBER,
                                  p_reci_le_id         IN NUMBER,
                                  p_ttyp_invoice_flag  IN VARCHAR2,
                                  x_invoice_required   OUT NOCOPY VARCHAR2,
                                  x_return_status      OUT NOCOPY VARCHAR2)
IS

l_ini_le_id        NUMBER;
l_trx_invoice_flag VARCHAR2(1);
l_ini_invoice_flag VARCHAR2(1);
l_rec_invoice_flag VARCHAR2(1);
l_return_status    VARCHAR2(1);
l_le_error         VARCHAR2(2000);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   x_invoice_required := 'N';

   IF p_ttyp_invoice_flag = 'N'
   THEN
       -- Check if initiator requires invoicing
       XLE_UTILITIES_GRP. Check_IC_Invoice_required(
          x_return_status     => l_return_status,
          x_msg_data          => l_le_error,
          p_legal_entity_id   => p_init_le_id,
          p_party_id          => p_init_party_id,
          x_intercompany_inv  => l_ini_invoice_flag);

       IF l_ini_invoice_flag = FND_API.G_TRUE
       THEN
	   x_invoice_required   := 'Y';
       ELSE
           -- check if invoice is required for the recipient
           XLE_UTILITIES_GRP. Check_IC_Invoice_required(
                  x_return_status     => l_return_status,
                  x_msg_data          => l_le_error,
                  p_legal_entity_id   => p_reci_le_id,
                  p_party_id          => p_reci_party_id,
                  x_intercompany_inv  => l_rec_invoice_flag);

          IF l_rec_invoice_flag = FND_API.G_TRUE
          THEN
               -- invoicing is required for the recipient
               x_invoice_required   := 'Y';
          ELSE
               x_invoice_required   := 'N';
          END IF; -- invoicing not required for recipient

       END IF; -- invoicing enabled for inititator
   ELSE
       x_invoice_required   := 'Y';

   END IF; -- invoicing enabled for trx type


EXCEPTION
   WHEN OTHERS
   THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,
                          'fun.plsql.fun_wf_common.check_invoice_reqd_flag',
                          SQLERRM || ' Error occurred ');
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END check_invoice_reqd_flag;

        PROCEDURE Is_Party_Valid
(       x_return_status OUT NOCOPY VARCHAR2  ,
        p_party_id  IN      NUMBER,
        p_le_id      IN      NUMBER,
        p_ledger_id  IN      NUMBER,
        p_instance IN VARCHAR2,
        p_local IN VARCHAR2,
        p_type IN VARCHAR2,
        p_batch_date IN DATE,
        p_trx_number IN VARCHAR2
) IS
l_msr VARCHAR2(240);
l_return_status VARCHAR2(1);
l_count NUMBER;
l_le_start_dt   DATE;
l_le_end_dt     DATE;

CURSOR legal_entity_csr IS
SELECT le.le_effective_from, le.le_effective_to
FROM xle_firstparty_information_v le, hz_parties parties
WHERE parties.party_id = p_party_id
AND EXISTS (SELECT 1
	   FROM  hz_party_usg_assignments hua
	   WHERE hua.party_id = parties.party_id
	   AND   hua.party_usage_code = 'INTERCOMPANY_ORG')
AND fun_tca_pkg.get_le_id(p_party_id) = le.party_id
AND p_le_id = le.legal_entity_id;
--AND transacting_flag = p_instance; Problem here with transacting flag

BEGIN
  Debug('IS_PARTY_VALID(+)');

-- 7.2.2.2
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FUN_TCA_PKG.is_intercompany_org_valid(p_party_id, p_batch_date);
  IF l_return_status = 'N' THEN
  --Bug 5144930. Added new error messages to display the start date and end date.
  FUN_TCA_PKG.get_ic_org_valid_dates(p_party_id,l_le_start_dt, l_le_end_dt);
  IF p_type = 'I' THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        IF l_le_start_dt IS NULL AND l_le_end_dt IS NULL THEN
            FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_INITIATOR');
          ELSE
            FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_INITIATOR_DATE');
            FND_MESSAGE.SET_TOKEN('P_START_DATE',to_char(l_le_start_dt));
            FND_MESSAGE.SET_TOKEN('P_END_DATE',to_char(l_le_end_dt));
        END IF;
        FND_MSG_PUB.Add;
      END IF;
    ELSE
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        IF l_le_start_dt IS NULL AND l_le_end_dt IS NULL THEN
          FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_RECIPIENT');
          FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_number);
        ELSE
          FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_RECIPIENT_DATE');
          FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_number);
          FND_MESSAGE.SET_TOKEN('P_START_DATE',to_char(l_le_start_dt));
          FND_MESSAGE.SET_TOKEN('P_END_DATE',to_char(l_le_end_dt));
        END IF;
        FND_MSG_PUB.Add;
      END IF;
    END IF;

  Set_Return_Status(x_orig_status => x_return_status,
                    p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;


--Problem: LE dependency
  OPEN legal_entity_csr;
  FETCH legal_entity_csr INTO l_le_start_dt, l_le_end_dt;

  IF legal_entity_csr%NOTFOUND  THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      IF p_type = 'I' THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_INITIATOR');
        FND_MSG_PUB.Add;
      ELSE
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_RECIPIENT');
        FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_number);
        FND_MSG_PUB.Add;
      END IF;
    END IF;
    Set_Return_Status(x_orig_status => x_return_status,
                    p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;

  CLOSE legal_entity_csr;

  -- Bug 3173783
  IF NOT ( p_batch_date BETWEEN Nvl(l_le_start_dt, p_batch_date) AND Nvl(l_le_end_dt, p_batch_date))
  THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      IF p_type = 'I' THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INACTIVE_INIT_LE');
        FND_MSG_PUB.Add;
      ELSE
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INACTIVE_RECI_LE');
        FND_MESSAGE.SET_TOKEN('TRX_NUMBER', p_trx_number);
        FND_MSG_PUB.Add;
      END IF;
    END IF;
    Set_Return_Status(x_orig_status => x_return_status,
                    p_new_status => FND_API.G_RET_STS_ERROR);

  END IF;

  IF p_local = 'N' THEN
      l_msr :=  Fun_Tca_Pkg.Get_System_Reference(p_party_id);
      IF l_msr IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('FUN', 'FUN_PARTY_NO_MSR');
              FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;
  END IF;

  Debug('IS_PARTY_VALID(-)');
EXCEPTION WHEN OTHERS THEN -- Problem here: Remove check
  FND_MESSAGE.SET_NAME('FUN', 'ERROR_IN_IS_PARTY_VALID');
  FND_MSG_PUB.ADD;

END;


-- Bidisha S, Modified this procedure to perform distribution validation
-- for the manual mode.
PROCEDURE Is_Init_Trx_Dist_Amt_Valid
(       x_return_status  OUT NOCOPY VARCHAR2,
        p_trx_amount_cr  IN      NUMBER,
        p_trx_amount_dr  IN      NUMBER,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE,
        p_currency_code  IN     VARCHAR2,
        p_trx_date       IN DATE,
        p_auto_proration_flag IN VARCHAR2,
        p_trx_number     IN    VARCHAR2
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'Is_Init_Trx_Dist_Amt_Valid';
  l_boolean       BOOLEAN;
  l_count         NUMBER;

  l_dist_cr_type      NUMBER := 0;
  l_dist_dr_type      NUMBER := 0;
  l_dist_pos_type     NUMBER := 0;
  l_dist_neg_type     NUMBER := 0;
  l_dist_total_cr     NUMBER := 0;
  l_dist_total_dr     NUMBER := 0;

BEGIN
  Debug('Is_Init_Trx_Dist_Amt_Valid(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Perform the following validation only for manual mode
  IF Nvl(p_auto_proration_flag, 'N') = 'N'
  THEN
      l_count := p_dist_lines_tbl.COUNT;
      IF l_count > 0
      THEN
           FOR j IN 1..l_count LOOP
              IF p_dist_lines_tbl(j).party_type = 'I' AND
                 p_dist_lines_tbl(j).dist_type = 'L'
              THEN
                  IF NVL(p_dist_lines_tbl(j).amount_cr, 0) <> 0 THEN
                      l_dist_cr_type := 1;
                      IF p_dist_lines_tbl(j).amount_cr > 0 THEN
                        l_dist_pos_type := 1;
                      ELSE
                        l_dist_neg_type := 1;
                      END IF;
                  END IF;
                  IF NVL(p_dist_lines_tbl(j).amount_dr, 0) <> 0
                  THEN
                      l_dist_dr_type := 1;
                      IF p_dist_lines_tbl(j).amount_dr > 0 THEN
                        l_dist_pos_type := 1;
                      ELSE
                        l_dist_neg_type := 1;
                      END IF;
                  END IF;
                  l_dist_total_cr := l_dist_total_cr + NVL(p_dist_lines_tbl(j).amount_cr, 0);
                  l_dist_total_dr := l_dist_total_dr + NVL(p_dist_lines_tbl(j).amount_dr, 0);
            END IF;
         END LOOP;
      END IF;

      IF (p_trx_amount_cr <> l_dist_total_dr OR
          p_trx_amount_dr <> l_dist_total_cr )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.SET_NAME('FUN', 'FUN_IC_INI_HDR_DIST_MISMATCH');
                   FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_number);
                   FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                                p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;

      IF  l_dist_cr_type  = l_dist_dr_type
      THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.SET_NAME('FUN', 'FUN_IC_INVALID_DRCR_DIST');
              FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_number);
              FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;
   END IF; -- Manual Distribution validation

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN OTHERS THEN
        FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF      FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg
                   (       G_PKG_NAME          ,
                           l_api_name
                           );
             END IF;
  Debug('Is_Init_Trx_Dist_Amt_Valid(-)');
END;

PROCEDURE Is_Init_Trx_Amt_Valid
(       x_return_status  OUT NOCOPY VARCHAR2,
        p_trx_amount_cr  IN      NUMBER,
        p_trx_amount_dr  IN      NUMBER,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE,
        p_currency_code  IN     VARCHAR2,
        p_trx_date       IN DATE,
        p_auto_proration_flag IN VARCHAR2,
        p_trx_number     IN    VARCHAR2
) IS
  l_rate          NUMBER;
  l_min_amt       NUMBER := 0;
  l_min_curr_code VARCHAR2(30);
  l_conv_type     VARCHAR2(30);
  l_api_name      CONSTANT VARCHAR2(30)   := 'IS_INIT_TRX_AMT_VALID';
  l_boolean       BOOLEAN;
  l_count         NUMBER;


BEGIN
  Debug('IS_INIT_TRX_VALID(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_boolean := Fun_System_Options_Pkg.Get_Min_Trx_Amt(l_min_amt, l_min_curr_code);
   l_conv_type := Fun_System_Options_Pkg.Get_Exchg_Rate_Type;
   --No need to perform minimum transaction amount validation if the minimum amount
   --is not entered.
   IF l_min_amt = 0 OR l_min_amt IS NULL THEN
     RETURN;
   END IF;
   IF ABS(NVL(p_trx_amount_cr, p_trx_amount_dr)) <
          gl_currency_api.convert_amount(l_min_curr_code,
                                         p_currency_code,
                                         p_trx_date,
                                         l_conv_type,
                                         l_min_amt)
                                                     THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('FUN', 'FUN_API_LINE_AMT_LESSTN_MIN');
          FND_MESSAGE.SET_TOKEN('MIN_TRX_AMT', l_min_curr_code||' '||l_min_amt);
          FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_number);
          FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
    END IF;
        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;

           WHEN gl_currency_api.NO_RATE THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_API_CONV_RATE_NOT_FOUND');
               FND_MSG_PUB.ADD;
             END IF;
             Set_Return_Status(x_orig_status => x_return_status,
                               p_new_status => FND_API.G_RET_STS_ERROR);
             x_return_status := FND_API.G_RET_STS_ERROR ;

           WHEN gl_currency_api.INVALID_CURRENCY THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_CURRENCY');
               FND_MSG_PUB.ADD;
             END IF;
             Set_Return_Status(x_orig_status => x_return_status,
                               p_new_status => FND_API.G_RET_STS_ERROR);
             x_return_status := FND_API.G_RET_STS_ERROR ;

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME('FUN', 'ERROR_IN_IS_INIT_TRX_AMT_VALID'); -- Problem here: Remove check
  FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF      FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg
                   (       G_PKG_NAME          ,
                           l_api_name
                           );
             END IF;--Bug 3603338
  Debug('IS_INIT_TRX_VALID(-)');
END;


        PROCEDURE Get_Valid_Bsvs
(       p_ledger_id NUMBER,
        p_le_id NUMBER,
        x_valid_bsvs OUT NOCOPY VARCHAR2
) IS
CURSOR valid_bsv_csr IS
SELECT segment_value
FROM GL_LEDGER_LE_BSV_SPECIFIC_V
WHERE ledger_id = p_ledger_id
AND (legal_entity_id = p_le_id or legal_entity_id is null);
l_bal_seg_value VARCHAR2(25);
l_first BOOLEAN;
BEGIN
  l_first := TRUE;
  x_valid_bsvs := NULL;
  OPEN valid_bsv_csr;
  LOOP
    FETCH valid_bsv_csr INTO l_bal_seg_value;
    EXIT WHEN valid_bsv_csr%NOTFOUND;
    IF l_first THEN
      x_valid_bsvs := l_bal_seg_value;
      l_first := FALSE;
    ELSE
      x_valid_bsvs := x_valid_bsvs || ', ' || l_bal_seg_value;
    END IF;
  END LOOP;
  CLOSE valid_bsv_csr;

END;


        PROCEDURE Is_Ccid_Valid
(
        x_return_status OUT NOCOPY VARCHAR2,
        p_ccid IN NUMBER,
        p_le_id IN NUMBER,
        p_ledger_id IN NUMBER
) IS
l_return_status VARCHAR2(1);
l_bal_seg_value VARCHAR2(25);
l_rows_processed INT;
l_count NUMBER;
l_stmt_str VARCHAR2(300);
l_cur_hdl INT;
l_valid_bsvs VARCHAR2(2000);
l_bsv_val VARCHAR2(1);
l_bal_seg_column_name VARCHAR2(30);
CURSOR bsv_csr IS
SELECT COUNT(*)
FROM gl_ledger_le_bsv_gt gt
WHERE bal_seg_value = l_bal_seg_value
AND ledger_id = p_ledger_id
AND legal_entity_id = p_le_id;

BEGIN
Debug('IS_CCID_VALID(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--Validate only if the ledger is set up to have specific BSVs assigned
  SELECT bal_seg_value_option_code, bal_seg_column_name, name
  INTO l_bsv_val, l_bal_seg_column_name, g_le_name
  FROM gl_ledgers
  WHERE ledger_id=p_ledger_id;

  IF l_bsv_val='I' THEN

   execute immediate 'SELECT ' || l_bal_seg_column_name ||
              ' FROM gl_code_combinations WHERE code_combination_id = :1'
   INTO l_bal_seg_value
   using p_ccid;

   Select COUNT(*)
   INTO l_count
   from GL_LEDGER_LE_BSV_SPECIFIC_V
   where segment_value = l_bal_seg_value
   and ledger_id = p_ledger_id
   and (legal_entity_id = p_le_id or legal_entity_id is null);

   IF(l_count<1) THEN
      Get_Valid_Bsvs(p_ledger_id => p_ledger_id,p_le_id => p_le_id,x_valid_bsvs => l_valid_bsvs);
      FND_MESSAGE.SET_NAME('FUN', 'FUN_BSV_LE_NOT_ASSIGNED');
      FND_MESSAGE.SET_TOKEN('LE', g_le_name);
      FND_MESSAGE.SET_TOKEN('BSV', l_bal_seg_value);
      FND_MESSAGE.SET_TOKEN('VALIDBSVS', l_valid_bsvs);
      FND_MSG_PUB.Add;
      Set_Return_Status(x_orig_status => x_return_status,
                       p_new_status => FND_API.G_RET_STS_ERROR);
   END IF;
  END IF;
  Debug('IS_CCID_VALID(-)');
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_CCID');
      FND_MSG_PUB.Add;
   END IF;


-- David Haimes 19 March 2004
-- Commenting out this procedure so it always returns success
-- It was not working for BSV-all Case which is used in FOcus Group
-- so PM requested we remove the check totally (see bug 3480343)
-- we need to handle this case if we want to re implement, but we prefer that
-- the lov are limited to teh appropriate bsv in the key flex UI rather than
-- do check here, if OA can give us that fix/enhance to their kff

  /*
  -- Initialization phase
  IF g_le_bsv_gt_init = FALSE OR p_ledger_id <> g_ledger_id THEN
    l_return_status := GL_MC_INFO.INIT_LEDGER_LE_BSV_GT(p_ledger_id);

    SELECT chart_of_accounts_id, bal_seg_column_name, legal_entity_name
    INTO g_chart_of_accounts_id, g_bal_seg_column_name, g_le_name
    FROM gl_ledger_le_bsv_gt
    WHERE ledger_id = p_ledger_id
    AND ROWNUM < 2;

    g_ledger_id := p_ledger_id;
    g_le_bsv_gt_init := TRUE;
  END IF;
  l_cur_hdl := dbms_sql.open_cursor;
  l_stmt_str := 'SELECT ' || g_bal_seg_column_name ||
              ' FROM gl_code_combinations WHERE code_combination_id = ' ||
              p_ccid;
  dbms_sql.parse(l_cur_hdl, l_stmt_str, dbms_sql.native);
  dbms_sql.define_column(l_cur_hdl, 1, l_bal_seg_value, 25);
  l_rows_processed := dbms_sql.execute(l_cur_hdl);
  IF dbms_sql.fetch_rows(l_cur_hdl) > 0 THEN
    dbms_sql.column_value(l_cur_hdl, 1, l_bal_seg_value);
  ELSE
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_CCID');
      FND_MSG_PUB.Add;
    END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
  dbms_sql.close_cursor(l_cur_hdl); -- close cursor
  OPEN bsv_csr;
  FETCH bsv_csr INTO l_count;
  IF l_count < 1 THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_API.G_RET_STS_UNEXP_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'UNEXP_ERROR_OCCURRED_IN_CCID_CHK');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_UNEXP_ERROR);
  END IF;
  CLOSE bsv_csr;
  Debug('IS_CCID_VALID(-)');
EXCEPTION
  WHEN OTHERS THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               Get_Valid_Bsvs(p_ledger_id => p_ledger_id,p_le_id => p_le_id,x_valid_bsvs => l_valid_bsvs);
               FND_MESSAGE.SET_NAME('FUN', 'FUN_BSV_LE_NOT_ASSIGNED');
               FND_MESSAGE.SET_TOKEN('LE', g_le_name);
               FND_MESSAGE.SET_TOKEN('BSV', l_bal_seg_value);
               FND_MESSAGE.SET_TOKEN('VALIDBSVS', l_valid_bsvs);
               FND_MSG_PUB.Add;
          END IF;
*/
END;

        PROCEDURE Is_Reci_Trx_Balance
(
        x_return_status OUT NOCOPY VARCHAR2,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
) IS
l_pay_dist_total_cr NUMBER := 0;
l_pay_dist_total_dr NUMBER := 0;
l_dist_line_total_cr NUMBER := 0;
l_dist_line_total_dr NUMBER := 0;
l_count NUMBER;
l_type NUMBER := 0;
l_type_success BOOLEAN := true;
l_pay_dist_cr_type NUMBER := 0;
l_dist_lines_cr_type NUMBER := 0;
l_pay_dist_dr_type NUMBER := 0;
l_dist_lines_dr_type NUMBER := 0;
l_pay_dist_pos_type NUMBER := 0;
l_pay_dist_neg_type NUMBER := 0;
l_dist_lines_pos_type NUMBER := 0;
l_dist_lines_neg_type NUMBER := 0;
l_pay_lines_count NUMBER := 0;
l_dist_lines_count NUMBER:= 0;
BEGIN
Debug('IS_RECI_TRX_BALANCE(+)');
-- 7.2.2.9
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_count := p_dist_lines_tbl.COUNT;
  IF l_count > 0 THEN
    FOR j IN 1..l_count LOOP
      IF p_dist_lines_tbl(j).party_type = 'R' THEN
        IF p_dist_lines_tbl(j).dist_type = 'P' THEN
          l_pay_lines_count := l_pay_lines_count + 1;
          IF NVL(p_dist_lines_tbl(j).amount_cr, 0) <> 0 THEN
              l_pay_dist_cr_type := 1;
              IF p_dist_lines_tbl(j).amount_cr > 0 THEN
                l_pay_dist_pos_type := 1;
              ELSE
                l_pay_dist_neg_type := 1;
              END IF;
          ELSE
              l_pay_dist_dr_type := 1;
              IF p_dist_lines_tbl(j).amount_dr > 0 THEN
                l_pay_dist_pos_type := 1;
              ELSE
                l_pay_dist_neg_type := 1;
              END IF;
          END IF;
          l_pay_dist_total_cr := l_pay_dist_total_cr + NVL(p_dist_lines_tbl(j).amount_cr, 0);
          l_pay_dist_total_dr := l_pay_dist_total_dr + NVL(p_dist_lines_tbl(j).amount_dr, 0);
        ELSE IF p_dist_lines_tbl(j).dist_type = 'L' THEN
          l_dist_lines_count := l_dist_lines_count +1;
          IF NVL(p_dist_lines_tbl(j).amount_cr, 0) <> 0 THEN
              l_dist_lines_cr_type := 1;
              IF p_dist_lines_tbl(j).amount_cr > 0 THEN
                l_dist_lines_pos_type := 1;
              ELSE
                l_dist_lines_neg_type := 1;
             END IF;
          ELSE
              l_dist_lines_dr_type := 1;
              IF p_dist_lines_tbl(j).amount_dr > 0 THEN
                l_dist_lines_pos_type := 1;
              ELSE
                l_dist_lines_neg_type := 1;
              END IF;
          END IF;
        l_dist_line_total_cr := l_dist_line_total_cr + NVL(p_dist_lines_tbl(j).amount_cr, 0);
        l_dist_line_total_dr := l_dist_line_total_dr + NVL(p_dist_lines_tbl(j).amount_dr, 0);
        END IF;
      END IF;
     END IF;
    END LOOP;
  END IF;
  IF (l_pay_dist_total_cr <> l_dist_line_total_dr OR
      l_pay_dist_total_dr <> l_dist_line_total_cr) THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INCOMLT_SUM_REC_DIST');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
  IF  l_pay_dist_cr_type = l_pay_dist_dr_type OR
      l_dist_lines_cr_type = l_dist_lines_dr_type OR
      l_pay_dist_pos_type = l_pay_dist_neg_type OR
      l_dist_lines_pos_type = l_dist_lines_neg_type THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_SIGNS_TRX_LINE');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
Debug('IS_RECI_TRX_BALANCE(-)');
END;

        PROCEDURE Is_Batch_Balance
(
        x_return_status OUT NOCOPY VARCHAR2,
        p_init_dist_tbl IN OUT NOCOPY INIT_DIST_TBL_TYPE,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
) IS
l_init_dist_total_cr NUMBER := 0;
l_init_dist_total_dr NUMBER := 0;
l_dist_line_total_cr NUMBER := 0;
l_dist_line_total_dr NUMBER := 0;
l_count NUMBER;
l_type NUMBER := 0;
l_type_success BOOLEAN := true;
l_init_dist_cr_type NUMBER := 0;
l_dist_lines_cr_type NUMBER := 0;
l_init_dist_dr_type NUMBER := 0;
l_dist_lines_dr_type NUMBER := 0;
l_init_dist_pos_type NUMBER := 0;
l_init_dist_neg_type NUMBER := 0;
l_dist_lines_pos_type NUMBER := 0;
l_dist_lines_neg_type NUMBER := 0;
BEGIN
Debug('IS_BATCH_BALANCE(+)');
-- 7.2.2.9
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_count := p_init_dist_tbl.COUNT;
  IF l_count > 0 THEN
  FOR i IN 1..l_count LOOP
    IF NVL(p_init_dist_tbl(i).amount_cr, 0) <> 0 THEN
        l_init_dist_cr_type := 1;
        IF p_init_dist_tbl(i).amount_cr > 0 THEN
          l_init_dist_pos_type := 1;
        ELSE
          l_init_dist_neg_type := 1;
        END IF;
    ELSE
        l_init_dist_dr_type := 1;
        IF p_init_dist_tbl(i).amount_dr > 0 THEN
          l_init_dist_pos_type := 1;
        ELSE
          l_init_dist_neg_type := 1;
        END IF;
    END IF;
    l_init_dist_total_cr := l_init_dist_total_cr + NVL(p_init_dist_tbl(i).amount_cr, 0);
    l_init_dist_total_dr := l_init_dist_total_dr + NVL(p_init_dist_tbl(i).amount_dr, 0);
  END LOOP;
  END IF;
  l_count := p_dist_lines_tbl.COUNT;
  IF l_count > 0 THEN
  FOR j IN 1..l_count LOOP
    IF p_dist_lines_tbl(j).dist_type = 'R' THEN
      IF NVL(p_dist_lines_tbl(j).amount_cr, 0) <> 0 THEN
          l_dist_lines_cr_type := 1;
          IF p_dist_lines_tbl(j).amount_cr > 0 THEN
            l_dist_lines_pos_type := 1;
          ELSE
            l_dist_lines_neg_type := 1;
          END IF;
      ELSE
          l_dist_lines_dr_type := 1;
          IF p_dist_lines_tbl(j).amount_dr > 0 THEN
            l_dist_lines_pos_type := 1;
          ELSE
            l_dist_lines_neg_type := 1;
          END IF;
      END IF;
    l_dist_line_total_cr := l_dist_line_total_cr + NVL(p_dist_lines_tbl(j).amount_cr, 0);
    l_dist_line_total_dr := l_dist_line_total_dr + NVL(p_dist_lines_tbl(j).amount_dr, 0);
    END IF;
  END LOOP;
  END IF;
  IF (l_init_dist_total_cr <> l_dist_line_total_dr OR
      l_init_dist_total_dr <> l_dist_line_total_cr) THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INCOMLT_SUM_INI_DIST');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
  IF  l_init_dist_cr_type = l_init_dist_dr_type OR
      l_dist_lines_cr_type = l_dist_lines_dr_type OR
      l_init_dist_pos_type = l_init_dist_neg_type OR
      l_dist_lines_pos_type = l_dist_lines_neg_type THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_SIGNS_TRX_LINE');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
Debug('IS_BATCH_BALANCE(-)');
END;

-- Procedure added by Bidisha as part of the transaction UI enhancements
PROCEDURE Is_Auto_Batch_Balance (
        x_return_status  OUT    NOCOPY VARCHAR2,
        p_trx_tbl        IN OUT NOCOPY TRX_TBL_TYPE,
        p_init_dist_tbl  IN OUT NOCOPY INIT_DIST_TBL_TYPE,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE,
        p_validate_dist  IN VARCHAR2,
	p_currency_code IN VARCHAR2)
IS

   l_init_dist_total_cr NUMBER := 0;
   l_init_dist_total_dr NUMBER := 0;
   l_dist_line_total_cr NUMBER := 0;
   l_dist_line_total_dr NUMBER := 0;
   l_trx_total_cr       NUMBER := 0;
   l_trx_total_dr       NUMBER := 0;

   l_init_dist_cr_type  NUMBER := 0;
   l_trx_cr_type        NUMBER := 0;
   l_init_dist_dr_type  NUMBER := 0;
   l_trx_dr_type        NUMBER := 0;
   l_init_dist_pos_type NUMBER := 0;
   l_init_dist_neg_type NUMBER := 0;
   l_trx_pos_type       NUMBER := 0;
   l_trx_neg_type       NUMBER := 0;

   l_count              NUMBER := 0;
   l_mau NUMBER; -- minimum accountable units

BEGIN
  Debug('IS_AUTO_BATCH_BALANCE(+)');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Bug: 8712286. Get currency information from FND_CURRENCIES table
  SELECT nvl( minimum_accountable_unit, power( 10, (-1 * precision)))
  INTO l_mau
  FROM   FND_CURRENCIES
  WHERE  currency_code = p_currency_code;


  -- Sum the transaction Amounts
  l_count := p_trx_tbl.COUNT;
  IF l_count > 0
  THEN
      FOR i IN 1..l_count LOOP
         IF NVL(p_trx_tbl(i).init_amount_cr, 0) <> 0
         THEN
             l_trx_cr_type := 1;
             IF p_trx_tbl(i).init_amount_cr > 0 THEN
                 l_trx_pos_type := 1;
             ELSE
                 l_trx_neg_type := 1;
             END IF;
         END IF;
         IF NVL(p_trx_tbl(i).init_amount_dr, 0) <> 0
         THEN
             l_trx_dr_type := 1;
             IF p_trx_tbl(i).init_amount_dr > 0 THEN
                 l_trx_pos_type := 1;
             ELSE
                 l_trx_neg_type := 1;
             END IF;
         END IF;
	 l_trx_total_cr := l_trx_total_cr + NVL(p_trx_tbl(i).init_amount_cr, 0);
         l_trx_total_dr := l_trx_total_dr + NVL(p_trx_tbl(i).init_amount_dr, 0);
      END LOOP;
  END IF;

  -- Sum the Batch Distribution Amounts
  l_count := p_init_dist_tbl.COUNT;
  IF l_count > 0
  THEN
      FOR i IN 1..l_count LOOP
         IF NVL(p_init_dist_tbl(i).amount_cr, 0) <> 0
         THEN
             l_init_dist_cr_type := 1;
             IF p_init_dist_tbl(i).amount_cr > 0 THEN
                 l_init_dist_pos_type := 1;
             ELSE
                 l_init_dist_neg_type := 1;
             END IF;
         END IF;
         IF NVL(p_init_dist_tbl(i).amount_dr, 0) <> 0
         THEN
             l_init_dist_dr_type := 1;
             IF p_init_dist_tbl(i).amount_dr > 0 THEN
                 l_init_dist_pos_type := 1;
             ELSE
                 l_init_dist_neg_type := 1;
             END IF;
         END IF;
	 --Bug: 8712286
	 p_init_dist_tbl(i).amount_cr := ROUND(nvl(p_init_dist_tbl(i).amount_cr, 0)/l_mau)*l_mau;
	 p_init_dist_tbl(i).amount_dr := ROUND(nvl(p_init_dist_tbl(i).amount_dr, 0)/l_mau)*l_mau;

         l_init_dist_total_cr := l_init_dist_total_cr + NVL(p_init_dist_tbl(i).amount_cr, 0);
         l_init_dist_total_dr := l_init_dist_total_dr + NVL(p_init_dist_tbl(i).amount_dr, 0);
      END LOOP;
  END IF;

  -- No validations on dist lines for now.

  IF (p_validate_dist = 'Y') AND (l_trx_total_cr <> l_init_dist_total_dr OR
      l_trx_total_dr <> l_init_dist_total_cr )
  THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INCOMLT_SUM_INI_DIST');
               FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;

  IF  l_trx_cr_type        = l_trx_dr_type OR
      l_trx_pos_type       = l_trx_neg_type
  THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
          FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_SIGNS_TRX_LINE');
          FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
Debug('IS_AUTO_BATCH_BALANCE(-)');
END Is_Auto_Batch_Balance;


        PROCEDURE Is_Curr_Fld_Valid
(       x_return_status OUT NOCOPY VARCHAR2,
        p_curr_code     IN      VARCHAR2,
        p_ledger_id       IN      NUMBER,
        p_trx_date          IN      DATE
) IS
  l_default_currency VARCHAR2(15);
  l_count NUMBER;
  l_conv_type VARCHAR2(30);
  l_rate NUMBER;

  CURSOR currency_csr IS
    SELECT COUNT(*)
    FROM fnd_currencies_vl
    WHERE currency_code = p_curr_code
      AND enabled_flag = 'Y'
      AND nvl(start_date_active, p_trx_date) <= nvl(p_trx_date, sysdate)
      AND nvl(end_date_active, p_trx_date) >= nvl(p_trx_date, sysdate);
  /* use currency API
  CURSOR currency_rate_csr IS
    SELECT COUNT(*)
    FROM GL_DAILY_RATES_V
    WHERE conversion_date = p_trx_date
    AND exchange_rate_type = l_conv_type
    AND from_currency = p_curr_code
    AND to_currency = l_func_curr;
    */
BEGIN
  Debug('IS_CURR_FLD_VALID(+)');
-- 7.2.2.10
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_default_currency := Fun_System_Options_Pkg.Get_Default_Currency;
  l_conv_type := Fun_System_Options_Pkg.Get_Exchg_Rate_Type;
  IF l_default_currency IS NOT NULL THEN
    IF p_curr_code <> l_default_currency THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_CUR_NOTEQUAL_ENTRD_CUR');
        FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
      RETURN;
    END IF;
  END IF;

   OPEN currency_csr;     -- bug 5160257
   FETCH currency_csr INTO l_count;
   CLOSE currency_csr;
   IF l_count < 1 THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_CURRENCY');
        FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
   END IF;
/* Not used, replaced by GL currency API
   OPEN currency_rate_csr;
   FETCH currency_rate_csr INTO l_count;
   CLOSE currency_rate_csr;
   IF l_count < 1 THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_CONV_RATE_NOT_FOUND');
        FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
   END IF;
   */
   l_rate := GL_CURRENCY_API.Get_Rate_Sql(p_ledger_id, p_curr_code, p_trx_date, l_conv_type);

   IF l_rate = -1 THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_CONV_RATE_NOT_FOUND');
        FND_MSG_PUB.Add;
      END IF;
   ELSIF l_rate = -2 THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_CURRENCY');
        FND_MSG_PUB.Add;
      END IF;
   END IF;
   Debug('IS_CURR_FLD_VALID(-)');
END;


        PROCEDURE Is_IC_Relationship_Valid
(       x_return_status OUT NOCOPY VARCHAR2  ,
        p_initiator_id  IN      NUMBER,
        p_from_le_id      IN      NUMBER,
        p_batch_date IN DATE,
        p_trx_tbl       IN OUT NOCOPY TRX_TBL_TYPE
) IS
l_count NUMBER;
i NUMBER := 1;
BEGIN
  Debug('IS_IC_RELATIONSHIP_VALID(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- 7.2.2.1
  l_count := p_trx_tbl.COUNT;
  WHILE l_count <> 0 AND i <= l_count LOOP
    IF p_from_le_id = p_trx_tbl(i).to_le_id THEN
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_IC_RELATIONSHIP');
            FND_MSG_PUB.Add;
       END IF;
       Set_Return_Status(x_orig_status => x_return_status,
                         p_new_status => FND_API.G_RET_STS_ERROR);
    END IF;
    i := i + 1;
  END LOOP;
  Debug('IS_IC_RELATIONSHIP_VALID(-)');
END;

        PROCEDURE Is_Reci_Not_Duplicated
(       x_return_status OUT NOCOPY VARCHAR2  ,
        p_initiator_id  IN      NUMBER,
        p_trx_tbl       IN OUT NOCOPY TRX_TBL_TYPE
) IS
l_count NUMBER;
i NUMBER := 1;
j NUMBER := 2;
BEGIN
Debug('IS_RECI_NOT_DUPLICATED(+)');
x_return_status := FND_API.G_RET_STS_SUCCESS;
-- 7.2.1.4
l_count := p_trx_tbl.COUNT;
WHILE l_count <> 0 AND i <= l_count LOOP
  WHILE l_count <> 0 AND j <= l_count LOOP
      IF p_trx_tbl(i).recipient_id = p_initiator_id
         OR p_trx_tbl(i).recipient_id = p_trx_tbl(j).recipient_id THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_API_DUPLICATE_RECP');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;
      j := j + 1;
  END LOOP;
  i := i + 1;
  j := i + 1;
END LOOP;
Debug('IS_RECI_NOT_DUPLICATED(-)');
END;


        PROCEDURE Is_Trx_Type_Valid
(       x_return_status OUT NOCOPY VARCHAR2  ,
        p_trx_type_id IN      NUMBER
) IS
l_trx_type_code VARCHAR2(25);
l_need_invoice VARCHAR2(1);
l_enabled VARCHAR2(1);
BEGIN
Debug('IS_TRX_TYPE_VALID(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Fun_Trx_Types_Pub.get_trx_type_by_id(p_trx_type_id,
                             l_trx_type_code,
                             l_need_invoice,
                             l_enabled);
  IF l_enabled = 'N' THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN','FUN_API_INVALID_TRX_TYPE');
      FND_MSG_PUB.Add;
    END IF;
    Set_Return_Status(x_orig_status => x_return_status,
                      p_new_status => FND_API.G_RET_STS_ERROR);
  END IF;
Debug('IS_TRX_TYPE_VALID(-)');
END;

        PROCEDURE Is_Init_GL_Date_Valid
(
        x_return_status OUT NOCOPY VARCHAR2,
        p_from_le_id IN NUMBER,
        p_gl_date IN DATE,
        p_trx_type_id IN NUMBER

) IS
  CURSOR period_open_csr IS
    SELECT count(*)
    FROM GL_PERIOD_STATUSES PST
    WHERE pst.application_id = 435
      AND pst.closing_status <> 'N'
      AND pst.adjustment_period_flag <> 'Y'
      AND pst.ledger_id = p_from_le_id;
  l_count NUMBER;
  l_result VARCHAR2(1);
BEGIN
  Debug('IS_INIT_GL_DATE_VALID(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- 7.2.2.3
  /* Problem: good to create a view for the periods
  copy from AR_PERIODS_V
  SELECT PST.PERIOD_NAME
  , PST.PERIOD_YEAR
  , PST.PERIOD_NUM
  , PST.START_DATE
  , PST.END_DATE
  FROM GL_PERIOD_STATUSES PST
  , AR_SYSTEM_PARAMETERS SP
  WHERE PST.SET_OF_BOOKS_ID = SP.SET_OF_BOOKS_ID
  AND PST.APPLICATION_ID = 222
  AND PST.CLOSING_STATUS <> 'N'
  AND PST.ADJUSTMENT_PERIOD_FLAG <> 'Y'

  */
  /* Problem:  Need to wait for Intercompany period to exist
  OPEN period_open_csr;
  FETCH period_open_csr INTO l_count;
  CLOSE period_open_csr;
  IF l_count < 1 THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_PERIOD_NOT_OPEN');
        FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
   END IF;
   */
  l_result := fun_period_status_pkg.get_fun_prd_status(p_gl_date, p_trx_type_id);
  IF l_result <> 'O' THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_PERIOD_NOT_OPEN');
        FND_MSG_PUB.Add;
      END IF;
      Set_Return_Status(x_orig_status => x_return_status,
                        p_new_status => FND_API.G_RET_STS_ERROR);
   END IF;


  Debug('IS_INIT_GL_DATE_VALID(-)');
END;

        PROCEDURE Init_Batch_Validate
(       p_api_version   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY    VARCHAR2,
        p_insert        IN      VARCHAR2 ,
        p_batch_rec     IN OUT NOCOPY BATCH_REC_TYPE,
        p_trx_tbl       IN OUT NOCOPY TRX_TBL_TYPE,
        p_init_dist_tbl IN OUT NOCOPY INIT_DIST_TBL_TYPE,
        p_dist_lines_tbl        IN OUT NOCOPY DIST_LINE_TBL_TYPE

) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'INIT_BATCH_VALIDATE';
        l_api_version   CONSTANT NUMBER         := 1.0;
        l_return_status VARCHAR(1);
        l_local VARCHAR(1) ;
        l_validate_dist   VARCHAR2(1);
        l_msg_count number;
        l_msg_data  varchar2(2000);
        l_intercompany_exception varchar2(1);
        l_from_ou_id number;
	l_invoicing_rule VARCHAR(1);
	l_creation_sign number;
       	l_init_amount_dr number;
	l_init_amount_cr number;
        l_trx_type  varchar2(4);

BEGIN
      l_local  := 'Y';
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE )) THEN
         FND_MSG_PUB.initialize;
      END IF;

       --  Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- API body
       Debug('INIT_BATCH_VALIDATE(+)');
       IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) >= 50 THEN

         l_validate_dist := 'N';

         -- 7.2.1.2 Validate on batch number, initiator, currency, batch type,
         --         GL date, batch date
         IF (p_batch_rec.batch_number IS NULL OR
            p_batch_rec.initiator_id IS NULL OR
            p_batch_rec.currency_code IS NULL OR
            p_batch_rec.trx_type_id IS NULL OR
            p_batch_rec.gl_date IS NULL OR
            p_batch_rec.batch_date IS NULL) THEN
              Set_Return_Status(x_orig_status => x_return_status,
                                       p_new_status => FND_API.G_RET_STS_ERROR);
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('FUN', 'FUN_REQUIRED_FIELDS_INCOMPLETE');
                FND_MSG_PUB.Add;
              END IF;
         END IF;
   IF (nvl(p_insert,FND_API.G_TRUE) = FND_API.G_TRUE) THEN
         Is_Batch_Num_Unique(x_return_status => l_return_status,
                             p_batch_number => p_batch_rec.batch_number,
                             p_initiator_id => p_batch_rec.initiator_id);
         Set_Return_Status(x_orig_status => x_return_status,
                             p_new_status => l_return_status);
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    END IF;

       --check for duplicate transaction number
       Is_trx_Num_Unique( x_return_status => l_return_status,
                             p_batch_id => p_batch_rec.batch_id,
                             p_trx_tbl      => p_trx_tbl
                              );
       Set_Return_Status(x_orig_status => x_return_status,
                             p_new_status => l_return_status);
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


	  /* Start of bug 5284760 */
	  /* Fetch the operating unit id for the initiator party id */
	  /* This is later passed to get_ar_trx_creation_sign to fetch the
	     transaction creation sign */
	  l_from_ou_id := Fun_Tca_Pkg.Get_OU_Id(p_batch_rec.initiator_id,
                                                p_batch_rec.batch_date);
         /* IF l_from_ou_id IS NOT NULL
          THEN
	      -- Fetch the transaction creation sign of
              -- the associated AR transaction type
              l_creation_sign := FUN_TRX_TYPES_PUB.get_ar_trx_creation_sign(
					l_from_ou_id,
					p_batch_rec.trx_type_id,
					p_batch_rec.batch_date);
          END IF; */

	  /* End of bug 5284760 */
          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              FOR i IN 1..p_trx_tbl.COUNT LOOP
                  -- see if any recipient is in local instance
                  -- if yes, then need to check the MSR value

		  IF l_from_ou_id IS NOT NULL
		  THEN
		      -- Fetch the transaction creation sign of
		      -- the associated AR transaction type
                      -- ER: 8288979
                        l_trx_type := 'INV';
                        l_init_amount_dr := p_trx_tbl(i).init_amount_dr;
                        l_init_amount_cr := p_trx_tbl(i).init_amount_cr;
                        IF(l_init_amount_dr is null) THEN
                                l_init_amount_dr := 0;
                        END IF;
                        IF(l_init_amount_cr is null) THEN
                                l_init_amount_cr := 0;
                        END IF;
                        -- Credit memo transaction
                        if( l_init_amount_dr < 0 OR l_init_amount_cr > 0) THEN
                                l_trx_type := 'CM';
                        END IF;

		        l_creation_sign := FUN_TRX_TYPES_PUB.get_ar_trx_creation_sign(
						l_from_ou_id,
						p_batch_rec.trx_type_id,
						p_batch_rec.batch_date,
						l_trx_type);

		  END IF;
                  IF p_trx_tbl(i).recipient_instance = 'N' THEN
                      l_local := 'N';
                  END IF;

		/* For bug 4724672 check if initiator and reci does not
                   break intercompany exceptions */

		  XLE_UTILITIES_GRP.Is_Intercompany_LEID(
                    p_api_version       => l_api_version,
                    p_init_msg_list     => FND_API.G_FALSE,
                    p_commit            => FND_API.G_FALSE,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data,
                    p_legal_entity_id1  => p_batch_rec.from_le_id,
                    p_legal_entity_id2  => p_trx_tbl(i).to_le_id,
                    x_Intercompany      => l_intercompany_exception) ;

                    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    if(l_intercompany_exception = 'N') THEN

                    FND_MESSAGE.SET_NAME('FUN', 'FUN_INTERCOMPANY_EXCEPTION');
                    FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_tbl(i).trx_number);
                    FND_MSG_PUB.Add;
                    Set_Return_Status(x_orig_status => x_return_status,
                                  p_new_status => FND_API.G_RET_STS_ERROR);
                    end if;
                /*  end of bug 4724672 */

		/* Start of bug 5284760 */
		/* Code to validate the sign of the amount entered against the
		   AR transaction creation sign. This validation must be performance
		   if invoicing is enabled at any of the following levels -
		   transaction type, initiator or recipient */

		   /* l_invoicing_rule will be 'Y', if invoicing is enabled at
		       transaction type level */
		    l_invoicing_rule := p_trx_tbl(i).invoicing_rule;

		    /* If invoicing is not enabled at transaction level,
		      check to see if it is enabled at initiator or recipient
		      levels */
		    IF l_invoicing_rule = 'N' THEN
		       check_invoice_reqd_flag(p_init_party_id => p_batch_rec.initiator_id,
                           p_init_le_id       => p_batch_rec.from_le_id,
                           p_reci_party_id    => p_trx_tbl(i).recipient_id,
                           p_reci_le_id       => p_trx_tbl(i).to_le_id,
                           p_ttyp_invoice_flag => 'N',
                           x_invoice_required =>  l_invoicing_rule,
                           x_return_status    => l_return_status);
		       Set_Return_Status(x_orig_status => x_return_status,
                                      p_new_status => l_return_status);
		       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
		       IF l_invoicing_rule IS NULL THEN
		          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		       END IF;
		    END IF;



		    /* If invoicing is enabled then validate the amount against
		       the creation sign */
		    IF l_invoicing_rule = 'Y' THEN

			IF l_creation_sign IS NULL THEN
			  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            IF l_trx_type = 'INV' THEN

                              FND_MESSAGE.SET_NAME('FUN', 'FUN_NO_TRX_TYPE_MAP');
                              FND_MESSAGE.SET_TOKEN('TRX_TYPE','Invoice Type');
                            ELSE

                              FND_MESSAGE.SET_NAME('FUN', 'FUN_NO_TRX_TYPE_MAP');
                              FND_MESSAGE.SET_TOKEN('TRX_TYPE','Credit Memo Type');
                            END IF;
			    FND_MSG_PUB.Add;
			  END IF;
			Set_Return_Status(x_orig_status => x_return_status,
						p_new_status => FND_API.G_RET_STS_ERROR);
			EXIT;
			END IF;
		       /* If creation sign is positive and amount entered is
		          negative, then throw an error*/
		       IF (p_trx_tbl(i).init_amount_cr > 0 or p_trx_tbl(i).init_amount_dr < 0)
		       			    and l_creation_sign = 1 THEN
		          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			     FND_MESSAGE.SET_NAME('FUN', 'FUN_TRX_TYPE_POS_AMT');
			     FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_tbl(i).trx_number);
			     FND_MSG_PUB.Add;
			  END IF;
		          Set_Return_Status(x_orig_status => x_return_status,
	                        p_new_status => FND_API.G_RET_STS_ERROR);
		       END IF;
		       /* If creation sign is negative and amount entered is
		          positive, then throw an error*/
		       IF (p_trx_tbl(i).init_amount_dr > 0 or p_trx_tbl(i).init_amount_cr < 0)
		                            and l_creation_sign = -1 THEN
		          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			     FND_MESSAGE.SET_NAME('FUN', 'FUN_TRX_TYPE_NEG_AMT');
			     FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_tbl(i).trx_number);
			     FND_MSG_PUB.Add;
			  END IF;
		          Set_Return_Status(x_orig_status => x_return_status,
	                        p_new_status => FND_API.G_RET_STS_ERROR);
		       END IF;
		    END IF;
		/* End of bug 5284760 */
              END LOOP;
              Is_Party_Valid(x_return_status => l_return_status,
                             p_party_id => p_batch_rec.initiator_id,
                             p_le_id => p_batch_rec.from_le_id,
                             p_ledger_id => p_batch_rec.from_ledger_id,
                             p_instance => 'Y',
                             p_local => l_local,
                             p_type => 'I',
                             p_batch_date => p_batch_rec.gl_date,
                             p_trx_number => NULL);
             Set_Return_Status(x_orig_status => x_return_status,
                                   p_new_status => l_return_status);
             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             Is_Trx_Type_Valid(x_return_status => l_return_status,
                                 p_trx_type_id => p_batch_rec.trx_type_id);
             Set_Return_Status(x_orig_status => x_return_status,
                                   p_new_status => l_return_status);
             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             Is_Init_GL_Date_Valid(x_return_status => l_return_status,
                                   p_from_le_id => p_batch_rec.from_le_id,
                                   p_gl_date => p_batch_rec.gl_date,
                                   p_trx_type_id => p_batch_rec.trx_type_id);
             Set_Return_Status(x_orig_status => x_return_status,
                                   p_new_status => l_return_status);
             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             -- 7.2.2.6 Note:  Do not need to check at least 1 dist line
             -- as we check total trx amounts = total dist amounts
             IF p_trx_tbl.count < 1 THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.SET_NAME('FUN', 'FUN_API_RECI_LINE_NOT_FOUND');
                -- Problem:  Double check with msg repository
                  FND_MSG_PUB.Add;
                END IF;
                Set_Return_Status(x_orig_status => x_return_status,
                                  p_new_status => FND_API.G_RET_STS_ERROR);
             END IF;

           IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL) >= FND_API.G_VALID_LEVEL_FULL THEN

            l_validate_dist := 'Y';

            Is_Curr_Fld_Valid(x_return_status => l_return_status,
                               p_curr_code => p_batch_rec.currency_code,
                               p_ledger_id => p_batch_rec.from_ledger_id,
                               p_trx_date => p_batch_rec.gl_date);
             Set_Return_Status(x_orig_status => x_return_status,
                                   p_new_status => l_return_status);
             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

           END IF; -- end full validation
          END IF; -- end unique field success
        END IF; --Val level 50

        -- Call a new procedure to validate automatic distribution
        -- mode batch
        IF Nvl(p_batch_rec.automatic_proration_flag,'N') = 'Y'
        THEN
	--Bug: 8712286. Passing currency_code.
           Is_Auto_Batch_Balance
                                 (x_return_status => l_return_status,
                                  p_trx_tbl       => p_trx_tbl,
                                  p_init_dist_tbl => p_init_dist_tbl,
                                  p_dist_lines_tbl => p_dist_lines_tbl,
                                  p_validate_dist  => l_validate_dist,
				  p_currency_code  => p_batch_rec.currency_code);
        END IF;

        Debug('INIT_BATCH_VALIDATE(-)');
        -- End of API body.
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);


END Init_Batch_Validate;


        PROCEDURE Init_Trx_Validate
(       p_api_version   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_trx_rec       IN OUT NOCOPY TRX_REC_TYPE,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE,
        p_currency_code  IN VARCHAR2,
        p_gl_date       IN DATE,
        p_trx_date      IN DATE
) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'INIT_TRX_VALIDATE';
        l_api_version   CONSTANT NUMBER         := 1.0;
        l_return_status VARCHAR(1);
        l_local VARCHAR(1) ;
	default_currency_code VARCHAR2(15) := fun_system_options_pkg.get_default_currency();
BEGIN
        l_local  := 'Y';

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE)) THEN
         FND_MSG_PUB.initialize;
      END IF;

       --  Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- API body
       Debug('INIT_TRX_VALIDATE(+)');
       IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= 50 THEN
          --check trx number
          IF p_trx_rec.trx_number IS NULL THEN
                     Set_Return_Status(x_orig_status => x_return_status,
                                     p_new_status => FND_API.G_RET_STS_ERROR);
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.SET_NAME('FUN', 'FUN_TRX_NUM_NULL');
                     FND_MSG_PUB.Add;
              END IF;
          END IF;
	--Bug No. 5307996. Check for valid Currency code.
        IF (default_currency_code is not null AND default_currency_code <> p_currency_code) THEN
	--Bug No. 6311049.
	          Set_Return_Status(x_orig_status => x_return_status,
                                     p_new_status => FND_API.G_RET_STS_ERROR);
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.SET_NAME('FUN', 'FUN_ADI_INVALID_CURRENCY');
                     FND_MESSAGE.SET_TOKEN('CURRENCY', default_currency_code);
                     FND_MSG_PUB.Add;
                  END IF;
        END IF;
        --End of Bug No. 5307996.
        --7.2.1.2 Validate line number, recipient id, line amount, header amount is null
          IF  p_trx_rec.recipient_id IS NULL
              OR p_trx_rec.to_le_id IS NULL OR
                  NOT ((p_trx_rec.init_amount_dr IS NULL AND
                  p_trx_rec.init_amount_cr IS NOT NULL AND
                  p_trx_rec.init_amount_cr <> 0)
                  OR
                  (p_trx_rec.init_amount_cr IS NULL AND
                   p_trx_rec.init_amount_dr IS NOT NULL AND
                   p_trx_rec.init_amount_dr <> 0)) THEN
                     Set_Return_Status(x_orig_status => x_return_status,
                                       p_new_status => FND_API.G_RET_STS_ERROR);
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 IF(p_trx_rec.init_amount_dr=0) THEN
                     FND_MESSAGE.SET_NAME('FUN', 'FUN_NON_ZERO_AMOUNT');
                     FND_MSG_PUB.Add;
                 ELSE
                     FND_MESSAGE.SET_NAME('FUN', 'FUN_REQUIRED_FIELDS_INCOMPLETE');
                     FND_MESSAGE.SET_TOKEN('TRX_NUMBER',p_trx_rec.trx_number);
                     FND_MSG_PUB.Add;
                 END IF;
              END IF;
          END IF;

          --check initiator and recipeint are not same
           IF p_trx_rec.recipient_id=p_trx_rec.initiator_id THEN
                     Set_Return_Status(x_orig_status => x_return_status,
                                     p_new_status => FND_API.G_RET_STS_ERROR);
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.SET_NAME('FUN', 'FUN_API_CHANGE_INITIATOR');
                     FND_MSG_PUB.Add;
              END IF;
           END IF;

            IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              IF (p_trx_rec.recipient_instance = 'N' OR
                 p_trx_rec.initiator_instance = 'N') THEN
                    l_local := 'N';
              END IF;
              Is_Party_Valid(x_return_status => l_return_status,
                             p_party_id => p_trx_rec.recipient_id,
                             p_le_id => p_trx_rec.to_le_id,
                             p_ledger_id => p_trx_rec.to_ledger_id,
                             p_instance => p_trx_rec.recipient_instance,
                             p_local => l_local,
                             p_type => 'R',
                             p_batch_date => p_gl_date,
                             p_trx_number => p_trx_rec.trx_number);
                 Set_Return_Status(x_orig_status => x_return_status,
                                   p_new_status => l_return_status);
                 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
            END IF;
	    --Bug: 6998219
	    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 validate_org_assignment(x_return_status => l_return_status,
                             p_party_id => p_trx_rec.recipient_id);
                 Set_Return_Status(x_orig_status => x_return_status,
                                   p_new_status => l_return_status);
                 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
            END IF;
            Is_Init_Trx_Amt_Valid(x_return_status => l_return_status,
                                  p_trx_amount_cr => p_trx_rec.init_amount_cr,
                                  p_trx_amount_dr => p_trx_rec.init_amount_dr,
                                  p_dist_lines_tbl => p_dist_lines_tbl,
                                  p_currency_code => p_currency_code,
                                  p_trx_date => p_gl_date,
                                  p_auto_proration_flag => p_trx_rec.automatic_proration_flag,
                                  p_trx_number => p_trx_rec.trx_number);
            Set_Return_Status(x_orig_status => x_return_status, p_new_status => l_return_status);
                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
         END IF;
        IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= FND_API.G_VALID_LEVEL_FULL THEN

            Is_AR_Valid(x_return_status => l_return_status,
                        p_initiator_id => p_trx_rec.initiator_id,
                        p_invoicing_rule => p_trx_rec.invoicing_rule,
                        p_recipient_id => p_trx_rec.recipient_id,
                        p_to_le_id => p_trx_rec.to_le_id,
                        p_trx_date => p_gl_date);

           IF l_return_status like 'L' THEN              -- 6145670
                    FND_MESSAGE.SET_NAME('FUN', 'FND_INTER_TRX_GLDATE');
                    FND_MSG_PUB.Add;
		    Set_Return_Status(x_orig_status => x_return_status, p_new_status => FND_API.G_RET_STS_ERROR);

             END IF;                                  -- 6145670



            Set_Return_Status(x_orig_status => x_return_status, p_new_status => l_return_status);
                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

            -- Validate distributions if level is full
            Is_Init_Trx_Dist_Amt_Valid(x_return_status => l_return_status,
                                  p_trx_amount_cr => p_trx_rec.init_amount_cr,
                                  p_trx_amount_dr => p_trx_rec.init_amount_dr,
                                  p_dist_lines_tbl => p_dist_lines_tbl,
                                  p_currency_code => p_currency_code,
                                  p_trx_date => p_gl_date,
                                  p_auto_proration_flag => p_trx_rec.automatic_proration_flag,
                                  p_trx_number => p_trx_rec.trx_number);
            Set_Return_Status(x_orig_status => x_return_status, p_new_status => l_return_status);
                IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

        END IF;

        Debug('INIT_TRX_VALIDATE(-)');
        -- End of API body.
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
END Init_Trx_Validate;

        PROCEDURE Init_Dist_Validate
(       p_api_version   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        p_le_id IN NUMBER,
        p_ledger_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_init_dist_rec IN OUT NOCOPY INIT_DIST_REC_TYPE
) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'INIT_DIST_VALIDATE';
        l_api_version   CONSTANT NUMBER         := 1.0;
BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE) ) THEN
         FND_MSG_PUB.initialize;
      END IF;

       --  Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- API body
       Debug('INIT_DIST_VALIDATE(+)');
       -- Bug 7012449. Commented the If condition so that the ccid is validated
       -- under all conditions. Also added the negative ccid check.
       --IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= 50 THEN

          IF p_init_dist_rec.ccid IS NULL OR p_init_dist_rec.ccid <= 0 THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     --Bug: 6618396
	       FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_INIT_DIST_AC_CCID');
                -- Problem:  Double check with msg repository
               FND_MSG_PUB.Add;
             END IF;
             Set_Return_Status(x_orig_status => x_return_status,
                               p_new_status => FND_API.G_RET_STS_ERROR);

          ELSE
            Is_Ccid_Valid(x_return_status => x_return_status, p_ccid => p_init_dist_rec.ccid,
                        p_le_id => p_le_id, p_ledger_id => p_ledger_id);
          END IF;
          IF (NOT ((p_init_dist_rec.amount_dr IS NULL OR
                   p_init_dist_rec.amount_dr = 0 )    AND
                   p_init_dist_rec.amount_cr IS NOT NULL AND
                   p_init_dist_rec.amount_cr <> 0)
                  AND
             NOT ((p_init_dist_rec.amount_cr IS NULL  OR
                   p_init_dist_rec.amount_cr = 0 )       AND
                   p_init_dist_rec.amount_dr IS NOT NULL AND
                   p_init_dist_rec.amount_dr <> 0))
                  OR
                   p_init_dist_rec.line_number IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_DRCR_BDIST_LINE');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
          END IF;
       --END IF;
       --IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= FND_API.G_VALID_LEVEL_FULL THEN

         IF p_init_dist_rec.ccid IS NULL OR  p_init_dist_rec.ccid <= 0 THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INCOMPLETE_DIST_ACCTN');
               FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
          END IF;
         --END IF;
        Debug('INIT_DIST_VALIDATE(-)');
        -- End of API body.
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);


END Init_Dist_Validate;

        PROCEDURE Init_IC_Dist_Validate
(       p_api_version   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        p_le_id          IN              NUMBER,
        p_ledger_id          IN              NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_dist_line_rec    IN OUT NOCOPY DIST_LINE_REC_TYPE
) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'INIT_IC_DIST_VALIDATE';
        l_api_version   CONSTANT NUMBER         := 1.0;
        BEGIN
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version,
                                                p_api_version,
                                                l_api_name ,
                                                G_PKG_NAME )
        THEN
	Print ('Debug Init_Dist_Val >>> Unexpected Error 1 ');
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( nvl(p_init_msg_list,FND_API.G_FALSE) ) THEN
          FND_MSG_PUB.initialize;
        END IF;

	Print ('Debug Init_Dist_Val >>> Message List Initiated. ');
	Print ('Debug Init_Dist_Val >>> Return status '|| FND_API.G_RET_STS_SUCCESS );

        --  Initialize API return status to success
          x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- API body
        Debug('INIT_IC_DIST_VALIDATE(+)');

	Print ('Debug Init_Dist_Val >>> API Body Started');

	-- Bug 7012449. Commented the If clause such that the ccid is validated
	-- Under all conditions. Also added negative ccid check.

        --IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= 50 THEN

	Print ('Debug Init_Dist_Val >>> In If 1' );

	  IF p_dist_line_rec.ccid IS NULL OR p_dist_line_rec.ccid <= 0 THEN
			Print ('Debug Init_Dist_Val >>> In If 2' );

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				Print ('Debug Init_Dist_Val >>> In If 3' );
	     --Bug: 6618396
	       FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_INIT_DIST_AC_CCID');
               FND_MESSAGE.SET_TOKEN('TRX_NUMBER', p_dist_line_rec.trx_number);
                -- Problem:  Double check with msg repository
               FND_MSG_PUB.Add;

	Print ('Debug Init_Dist_Val >>> End of  If 3' );
             END IF;
             Set_Return_Status(x_orig_status => x_return_status,
                               p_new_status => FND_API.G_RET_STS_ERROR);

		Print ('Debug Init_Dist_Val >>> End  If 2' );
          ELSE

		Print ('Debug Init_Dist_Val >>> CCID ' ||  p_dist_line_rec.ccid );
		Print ('Debug Init_Dist_Val >>> le_id  ' ||p_le_id);
		Print ('Debug Init_Dist_VAl >> ledger_id ' ||  p_ledger_id);

          Is_Ccid_Valid(x_return_status => x_return_status, p_ccid => p_dist_line_rec.ccid,
                        p_le_id => p_le_id, p_ledger_id => p_ledger_id);

          END IF;

		Print ('Debug Init_Dist_Val >>> End  If 3' );

          IF NOT (p_dist_line_rec.amount_dr IS NULL AND
                   p_dist_line_rec.amount_cr IS NOT NULL AND
                   p_dist_line_rec.amount_cr <> 0)
                  AND
             NOT (p_dist_line_rec.amount_cr IS NULL AND
                   p_dist_line_rec.amount_dr IS NOT NULL AND
                   p_dist_line_rec.amount_dr <> 0) THEN

		Print ('Debug Init_Dist_Val >>> In If 21' );

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

		Print ('Debug Init_Dist_Val >>> In If 22' );

               FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_DRCR_DIST_LINE');
               FND_MESSAGE.SET_TOKEN('TRX_NUMBER', p_dist_line_rec.trx_number);
               FND_MSG_PUB.Add;
             END IF;

	Print ('Debug Init_Dist_Val >>> End  If 22' );

             Set_Return_Status(x_orig_status => x_return_status,
                               p_new_status => FND_API.G_RET_STS_ERROR);
          END IF;

		Print ('Debug Init_Dist_Val >>> End  If 21' );
		Print ('Debug Init_Dist_Val >>> Party Type ' ||  p_dist_line_rec.party_type );
		Print ('Debug Init_Dist_Val >>>  FND_API.G_RET_STS_ERROR ' ||   FND_API.G_RET_STS_ERROR );

          IF p_dist_line_rec.party_type <> 'I' and p_dist_line_rec.party_type <> 'R' THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'Party type for distributions has not been set correctly');
             END IF;
             Set_Return_Status(x_orig_status => x_return_status,
                               p_new_status => FND_API.G_RET_STS_ERROR);
          END IF;
         --END IF;

	Print ('Debug Init_Dist_Val >>> End If');

       --IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= FND_API.G_VALID_LEVEL_FULL THEN
         IF p_dist_line_rec.ccid IS NULL OR p_dist_line_rec.ccid <= 0 THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	  --Bug: 6618396
	       FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_INIT_DIST_AC_CCID');
               FND_MESSAGE.SET_TOKEN('TRX_NUMBER', p_dist_line_rec.trx_number);
          END IF;

		Print ('Debug Init_Dist_Val >>> x_return_status' || x_return_status );
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
          END IF;
         --END IF;
        Debug('INIT_IC_DIST_VALIDATE(-)');
        -- End of API body.
        -- Standard call to get message count and if count is 1, get message info.

		Print ('Debug Init_Dist_Val >>> x_msg_count' || x_msg_count );
		Print ('Debug Init_Dist_Val >>> x_msg_data' || x_msg_data );
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);


        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		Print ('Debug Init_Dist_Val G_EXEC_ERROR >>> x_msg_count' || x_msg_count );
		Print ('Debug Init_Dist_Val G_EXEC_ERROR >>> x_msg_data' || x_msg_data );

            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
		Print ('Debug Init_Dist_Val G_EXEC_ERROR >>>END ' );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		Print ('Debug Init_Dist_Val UNEXPECTED ERROR >>> x_msg_count' || x_msg_count );
		Print ('Debug Init_Dist_Val UNEXPECTED ERROR >>> x_msg_data' || x_msg_data );

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
		Print ('Debug Init_Dist_Val UNEXPECTED ERROR >>>END ' );
          WHEN OTHERS THEN
		Print ('Debug Init_Dist_Val OTHER ERROR >>> x_msg_count' || x_msg_count );
		Print ('Debug Init_Dist_Val OTHER ERROR >>> x_msg_data' || x_msg_data );
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
	Print ('Debug Init_Dist_Val OTHER ERROR >>>END ' );

END Init_IC_Dist_Validate;





        PROCEDURE Is_AR_Valid
(       x_return_status OUT NOCOPY VARCHAR2  ,
        p_initiator_id  IN      NUMBER,
        p_invoicing_rule IN     VARCHAR2,
        p_recipient_id   IN     NUMBER,
        p_to_le_id IN       NUMBER,
        p_trx_date IN DATE
) IS
l_from_le_id NUMBER;
l_from_le_party_id NUMBER;  -- <bug 3450031>
l_from_ou_id NUMBER;
l_to_ou_id NUMBER;
--l_success VARCHAR2(1);
l_cust_acct_id NUMBER;
l_bill_to_site_id NUMBER;
l_bill_site_use_id NUMBER;
l_count NUMBER;
l_msg_data VARCHAR2(2000);
l_success BOOLEAN;
l_invoice_required   VARCHAR2(1);
initiator_name HZ_PARTIES.PARTY_NAME%TYPE;
recipient_name HZ_PARTIES.PARTY_NAME%TYPE;

CURSOR ou_valid_csr IS
  SELECT count(*)
  FROM hr_operating_units ou
  WHERE organization_id = l_from_ou_id
    AND date_from <= p_trx_date
    AND NVL(date_to, p_trx_date) >= p_trx_date;  -- <bug 3450031>
BEGIN
-- 7.2.1.7
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  Debug('IS_AR_VALID(+)');
  l_from_le_party_id := Fun_Tca_Pkg.Get_LE_Id(p_initiator_id, p_trx_date);

  IF l_from_le_party_id IS NOT NULL THEN  -- 6145670

  SELECT legal_entity_id
  INTO l_from_le_id
  FROM xle_firstparty_information_v
  WHERE party_id = l_from_le_party_id;

  check_invoice_reqd_flag(p_init_party_id   => p_initiator_id,
                          p_init_le_id       => l_from_le_id,
                          p_reci_party_id    => p_recipient_id,
                          p_reci_le_id       => p_to_le_id,
                          p_ttyp_invoice_flag => p_invoicing_rule,
                          x_invoice_required =>  l_invoice_required,
                          x_return_status    => x_return_status);

  IF l_invoice_required  = 'Y' THEN

    l_from_ou_id := Fun_Tca_Pkg.Get_OU_Id(p_initiator_id, p_trx_date);
    IF l_from_ou_id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_OU');
        FND_MSG_PUB.Add;
      END IF;
         Set_Return_Status(x_orig_status => x_return_status,
                           p_new_status => FND_API.G_RET_STS_ERROR);
    END IF;
-- 7.2.1.5
    OPEN ou_valid_csr;
    FETCH ou_valid_csr INTO l_count;
    CLOSE ou_valid_csr;
    IF l_count < 1 THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_OU');
        FND_MSG_PUB.Add;
      END IF;
         Set_Return_Status(x_orig_status => x_return_status,
                           p_new_status => FND_API.G_RET_STS_ERROR);
    END IF;
    l_to_ou_id := Fun_Tca_Pkg.Get_OU_Id(p_recipient_id, p_trx_date);

    -- To get the customer association, the transacting LE is the
    -- recipient LE.
    l_success := Fun_Trading_Relation.Get_Customer('INTERCOMPANY', p_to_le_id,
                                      l_from_le_id, l_to_ou_id, l_from_ou_id,
                                      p_recipient_id, p_initiator_id,
                                      l_msg_data,
                                      l_cust_acct_id,
                                      l_bill_to_site_id,
                                      l_bill_site_use_id);

    IF NOT l_success THEN
	-- Bug: 5291584
	SELECT party_name
        INTO initiator_name
        FROM hz_parties
        WHERE party_id=p_initiator_id;

        SELECT party_name
        INTO recipient_name
        FROM hz_parties
        WHERE party_id=p_recipient_id;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_CUSTOMER');
	FND_MESSAGE.SET_TOKEN('INITIATOR_NAME',initiator_name);
        FND_MESSAGE.SET_TOKEN('RECIPIENT_NAME',recipient_name);
        FND_MSG_PUB.Add;
      END IF;
         Set_Return_Status(x_orig_status => x_return_status,
                           p_new_status => FND_API.G_RET_STS_ERROR);
    END IF;

  END IF;
  Debug('IS_AR_VALID(-)');
  Else      -- 6145670
     x_return_status:='L';
  END IF;  -- 6145670
  -- End of API body.
END;





        PROCEDURE Create_Reverse_Batch
(       p_api_version           IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_commit                IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        p_batch_id IN NUMBER,
        p_reversed_batch_number IN VARCHAR2,
        p_reversal_method IN VARCHAR2, -- 'SWITCH' OR 'SIGN'
        p_reversed_batch_date IN DATE,
        p_reversed_gl_date IN DATE,
        p_reversed_description IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_reversed_batch_id IN OUT NOCOPY NUMBER
) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_REVERSE_BATCH';
        l_api_version   CONSTANT NUMBER         := 1.0;
        l_return_status VARCHAR(1);
        l_boolean BOOLEAN;
        l_reversed_batch_number VARCHAR2(20);
        l_initiator_id NUMBER;
        l_reversed_batch_id NUMBER;
        l_control_date_tbl FUN_SEQ.CONTROL_DATE_TBL_TYPE;
        l_control_date_rec FUN_SEQ.CONTROL_DATE_REC_TYPE;
        l_seq_version_id        NUMBER;
        l_assignment_id         NUMBER;
        l_error_code            VARCHAR2(1000);
        l_wf_event_key          VARCHAR2(200);
    --Bug:9104801
	l_trx_total_tbl TRX_TOTAL_TBL_TYPE;
        CURSOR l_trx_total_cursor(p_reversed_batch_id NUMBER) IS
	SELECT trx_id,
               sum(init_amount_cr),
               sum(init_amount_dr)
        FROM fun_trx_headers
        WHERE batch_id = p_reversed_batch_id
	GROUP by trx_id;

BEGIN
Debug('CREATE_REVERSE_BATCH(+)');
--Bug: 6625360.
-- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Verify that no transactions have already been reversed,
  --   and the batch is not a reversed batch itself
  -- Verify the status of the batch
  --Bug: 6625360.
 /* SELECT count(initiator_id) INTO l_initiator_id
  FROM fun_trx_batches batches
  WHERE batch_id = p_batch_id
  AND original_batch_id IS NULL
  AND reversed_batch_id IS NULL
  AND status = 'COMPLETE'
  AND NOT EXISTS (SELECT 'Transaction already reversed'
                  FROM fun_trx_headers hdrs
                  WHERE hdrs.batch_id = p_batch_id
                  AND (hdrs.original_trx_id IS NOT NULL
                       OR
                       hdrs.reversed_trx_id IS NOT NULL));*/
  SELECT count(initiator_id) INTO l_initiator_id
  FROM fun_trx_batches batches
  WHERE batch_id = p_batch_id
  AND original_batch_id IS NULL
  AND reversed_batch_id IS NULL
  AND(
      (status in ('COMPLETE')
         AND NOT EXISTS (SELECT 'Transaction already reversed'
                  FROM fun_trx_headers hdrs
                  WHERE hdrs.batch_id = p_batch_id
                  AND (hdrs.original_trx_id IS NOT NULL
                       OR
                       hdrs.reversed_trx_id IS NOT NULL))
      ) OR
      (
        NOT EXISTS (SELECT 'Transaction not reversed'
                  FROM fun_trx_headers hdrs
                  WHERE hdrs.batch_id = p_batch_id
                  AND (hdrs.original_trx_id IS NOT NULL
                       OR hdrs.reversed_trx_id IS NOT NULL)
                  AND hdrs.status in ('COMPLETE', 'APPROVED'))
      )
      );
  IF l_initiator_id < 1 THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN', 'FUN_REVERSED_BATCH'); -- Problem here:  Whether a msg is needed
      FND_MSG_PUB.Add;
    END IF;
    Set_Return_Status(x_orig_status => x_return_status,
                      p_new_status => FND_API.G_RET_STS_ERROR);
    RETURN;
  END IF;
  -- Check batch numbering type
  l_boolean := fun_system_options_pkg.is_manual_numbering;


  -- Changing for reverse batch as the logic for automatic sequence generation is handled in UI
  IF (p_reversed_batch_number IS NOT NULL) THEN
       l_boolean := true;
  END IF;
  -- End of logic

  IF l_boolean THEN
    l_reversed_batch_number := p_reversed_batch_number;
  ELSE

  l_control_date_rec.date_type := 'CREATION_DATE';
  l_control_date_rec.date_value := sysdate;
  l_control_date_tbl(0) := l_control_date_rec;
  FUN_SEQ.GET_SEQUENCE_NUMBER('INTERCOMPANY_BATCH_SOURCE',
                              'LOCAL',
                              435,
                              'FUN_TRX_BATCHES',
                              'CREATION',
                              null,
                              l_control_date_tbl,
                              'N',
                              l_seq_version_id,
                              l_reversed_batch_number,
                              l_assignment_id,
                              l_error_code);
  END IF;
  -- Check uniqueness of the batch_number provided
  Is_Batch_Num_Unique(l_return_status,l_reversed_batch_number,l_initiator_id);
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Get the next sequence for fun_batch_id
  SELECT fun_trx_batches_s.nextval INTO l_reversed_batch_id FROM dual;
  -- Update original batch with reversed_batch_id
  UPDATE fun_trx_batches
  SET reversed_batch_id = l_reversed_batch_id
  WHERE batch_id = p_batch_id;
  -- Insert into batch with orig_batch_id
  INSERT INTO fun_trx_batches(BATCH_ID,
                              BATCH_NUMBER,
                              INITIATOR_ID,
                              FROM_LE_ID,
                              FROM_LEDGER_ID,
                              CONTROL_TOTAL,
                              RUNNING_TOTAL_CR,
                              RUNNING_TOTAL_DR,
                              CURRENCY_CODE,
                              EXCHANGE_RATE_TYPE,
                              STATUS,
                              DESCRIPTION,
                              NOTE,
                              TRX_TYPE_ID,
                              TRX_TYPE_CODE,
                              GL_DATE,
                              BATCH_DATE,
                              REJECT_ALLOW_FLAG,
                              ORIGINAL_BATCH_ID,
                              REVERSED_BATCH_ID,
                              FROM_RECURRING_BATCH_ID,
                              INITIATOR_SOURCE,
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
                              ATTRIBUTE_CATEGORY,
                              CREATED_BY,
                              CREATION_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATE_LOGIN,
                              auto_proration_flag)
                      SELECT  l_reversed_batch_id,
                              l_reversed_batch_number,
                              INITIATOR_ID,
                              FROM_LE_ID,
                              FROM_LEDGER_ID,
                              NULL,
                              DECODE(p_reversal_method, 'CHANGE', DECODE(RUNNING_TOTAL_CR, NULL, NULL,(-1) * (RUNNING_TOTAL_CR)),
                                                                 RUNNING_TOTAL_DR),
                              DECODE(p_reversal_method, 'CHANGE', DECODE(RUNNING_TOTAL_DR, NULL, NULL,(-1) * (RUNNING_TOTAL_DR)),
                                                                 RUNNING_TOTAL_CR),
                              CURRENCY_CODE,
                              EXCHANGE_RATE_TYPE,
                              'SENT',
                              p_reversed_description,
                              NULL,
                              TRX_TYPE_ID,
                              TRX_TYPE_CODE,
                              p_reversed_gl_date,
                              p_reversed_batch_date,
                              REJECT_ALLOW_FLAG,
                              p_batch_id,
                              NULL,
                              NULL,
                              INITIATOR_SOURCE,
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
                              ATTRIBUTE_CATEGORY,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id,
                              auto_proration_flag
                      FROM fun_trx_batches
                      WHERE batch_id = p_batch_id;
  -- Insert into transaction with status sent, ignore the rejected ones
  INSERT INTO fun_trx_headers(TRX_ID,
                              TRX_NUMBER,
                              INITIATOR_ID,
                              RECIPIENT_ID,
                              TO_LE_ID,
                              TO_LEDGER_ID,
                              BATCH_ID,
                              STATUS,
                              INIT_AMOUNT_CR,
                              INIT_AMOUNT_DR,
                              RECI_AMOUNT_CR,
                              RECI_AMOUNT_DR,
                              AR_INVOICE_NUMBER,
                              INVOICE_FLAG,
                              APPROVER_ID,
                              APPROVAL_DATE,
                              ORIGINAL_TRX_ID,
                              REVERSED_TRX_ID,
                              FROM_RECURRING_TRX_ID,
                              INITIATOR_INSTANCE_FLAG,
                              RECIPIENT_INSTANCE_FLAG,
                              REJECT_REASON,
                              DESCRIPTION,
                              INIT_WF_KEY,
                              RECI_WF_KEY,
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
                              ATTRIBUTE_CATEGORY,
                              CREATED_BY,
                              CREATION_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATE_LOGIN)
                       SELECT fun_trx_headers_s.nextval,
                              TRX_NUMBER, -- Problem: what to use
                              INITIATOR_ID,
                              RECIPIENT_ID,
                              TO_LE_ID,
                              TO_LEDGER_ID,
                              l_reversed_batch_id,
                              'SENT',
                              DECODE(p_reversal_method, 'CHANGE', DECODE(INIT_AMOUNT_CR, NULL, NULL, (-1) *(INIT_AMOUNT_CR)),
                                                                 INIT_AMOUNT_DR),
                              DECODE(p_reversal_method, 'CHANGE', DECODE(INIT_AMOUNT_DR, NULL, NULL, (-1) *(INIT_AMOUNT_DR)),
                                                                 INIT_AMOUNT_CR),
                              DECODE(p_reversal_method, 'CHANGE', DECODE(RECI_AMOUNT_CR, NULL, NULL, (-1) *(RECI_AMOUNT_CR)),
                                                                 RECI_AMOUNT_DR),
                              DECODE(p_reversal_method, 'CHANGE', DECODE(RECI_AMOUNT_DR, NULL, NULL, (-1) *(RECI_AMOUNT_DR)),
                                                                 RECI_AMOUNT_CR),
                              NULL,
                              INVOICE_FLAG,
                              NULL,
                              NULL,
                              TRX_ID,
                              NULL,
                              NULL,
                              INITIATOR_INSTANCE_FLAG,
                              RECIPIENT_INSTANCE_FLAG,
                              NULL,
                              p_reversed_description,
                              NULL,
                              NULL,
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
                              ATTRIBUTE_CATEGORY,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id
                       FROM fun_trx_headers
                       WHERE batch_id = p_batch_id
                       AND STATUS in ('COMPLETE', 'APPROVED'); -- Bug: 6625360. AND STATUS = 'COMPLETE';

  -- Update reversed_trx_id with fun_trx_headers
  UPDATE fun_trx_headers hdrs1
  SET (reversed_trx_id) = (SELECT trx_id
                        FROM fun_trx_headers hdrs2
                        WHERE hdrs2.original_trx_id = hdrs1.trx_id)
  WHERE hdrs1.batch_id = p_batch_id;

  -- Insert into init_dist
  INSERT INTO fun_batch_dists(BATCH_DIST_ID,
                             LINE_NUMBER,
                             BATCH_ID,
                             CCID,
                             AMOUNT_CR,
                             AMOUNT_DR,
                             DESCRIPTION,
                             CREATED_BY,
                             CREATION_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN)
                      SELECT fun_batch_dist_s.nextval,
                             LINE_NUMBER,
                             l_reversed_batch_id,
                             CCID,
                             DECODE(p_reversal_method, 'CHANGE', (-1) *(nvl(AMOUNT_CR,0)),
                                                                AMOUNT_DR),
                             DECODE(p_reversal_method, 'CHANGE', (-1) *(nvl(AMOUNT_DR,0)),
                                                                AMOUNT_CR),
                             DESCRIPTION,
                             fnd_global.user_id,
                             sysdate,
                             fnd_global.user_id,
                             sysdate,
                             fnd_global.user_id
                      FROM   fun_batch_dists dist
                      WHERE  dist.batch_id = p_batch_id;


  -- Insert into trx_lines
  INSERT INTO fun_trx_lines(LINE_ID,
                            TRX_ID,
                            LINE_NUMBER,
                            LINE_TYPE_FLAG,
                            INIT_AMOUNT_CR,
                            INIT_AMOUNT_DR,
                            RECI_AMOUNT_CR,
                            RECI_AMOUNT_DR,
                            DESCRIPTION,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATE_LOGIN)
                     SELECT fun_trx_lines_s.nextval,
                            headers.trx_id,
                            LINE_NUMBER,
                            LINE_TYPE_FLAG,
                            DECODE(p_reversal_method, 'CHANGE',DECODE(lines.INIT_AMOUNT_CR, NULL,NULL, (-1) * (lines.INIT_AMOUNT_CR)),
                                                               lines.INIT_AMOUNT_DR),
                            DECODE(p_reversal_method, 'CHANGE', DECODE(lines.INIT_AMOUNT_DR, NULL, NULL, (-1) *(lines.INIT_AMOUNT_DR)),
                                                               lines.INIT_AMOUNT_CR),
                            DECODE(p_reversal_method, 'CHANGE', DECODE(lines.RECI_AMOUNT_CR, NULL,NULL, (-1) * (lines.RECI_AMOUNT_CR)),
                                                               lines.RECI_AMOUNT_DR),
                            DECODE(p_reversal_method, 'CHANGE', DECODE(lines.RECI_AMOUNT_DR, NULL, NULL, (-1) * (lines.RECI_AMOUNT_DR)),
                                                               lines.RECI_AMOUNT_CR),
                            lines.DESCRIPTION,
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.user_id
                     FROM   fun_trx_headers headers, fun_trx_lines lines
                     WHERE  headers.batch_id = l_reversed_batch_id
                     AND    headers.original_trx_id = lines.trx_id;

  -- Insert into dist_lines
  INSERT INTO fun_dist_lines(DIST_ID,
                             LINE_ID,
                             DIST_NUMBER,
                             PARTY_ID,
                             PARTY_TYPE_FLAG,
                             DIST_TYPE_FLAG,
                             BATCH_DIST_ID,
                             AMOUNT_CR,
                             AMOUNT_DR,
                             CCID,
                             DESCRIPTION,
                             AUTO_GENERATE_FLAG,
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
                             ATTRIBUTE_CATEGORY,
                             CREATED_BY,
                             CREATION_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN,
                             trx_id)
                      SELECT fun_dist_lines_s.nextval,
                             reversed_lines.LINE_ID,
                             orig_dists.DIST_NUMBER,
                             orig_dists.PARTY_ID,
                             orig_dists.PARTY_TYPE_FLAG,
                             orig_dists.DIST_TYPE_FLAG,
                             NULL,
                             DECODE(p_reversal_method, 'CHANGE', DECODE(orig_dists.AMOUNT_CR, NULL, NULL, (-1) *(orig_dists.AMOUNT_CR)),
				orig_dists.AMOUNT_DR),
                             DECODE(p_reversal_method, 'CHANGE', DECODE(orig_dists.AMOUNT_DR, NULL, NULL, (-1) *(orig_dists.AMOUNT_DR)),
				orig_dists.AMOUNT_CR),
                             orig_dists.CCID,
                             orig_dists.DESCRIPTION,
                             orig_dists.AUTO_GENERATE_FLAG,
                             orig_dists.ATTRIBUTE1,
                             orig_dists.ATTRIBUTE2,
                             orig_dists.ATTRIBUTE3,
                             orig_dists.ATTRIBUTE4,
                             orig_dists.ATTRIBUTE5,
                             orig_dists.ATTRIBUTE6,
                             orig_dists.ATTRIBUTE7,
                             orig_dists.ATTRIBUTE8,
                             orig_dists.ATTRIBUTE9,
                             orig_dists.ATTRIBUTE10,
                             orig_dists.ATTRIBUTE11,
                             orig_dists.ATTRIBUTE12,
                             orig_dists.ATTRIBUTE13,
                             orig_dists.ATTRIBUTE14,
                             orig_dists.ATTRIBUTE15,
                             orig_dists.ATTRIBUTE_CATEGORY,
                             fnd_global.user_id,
                             sysdate,
                             fnd_global.user_id,
                             sysdate,
                             fnd_global.user_id,
                             reversed_hdrs.trx_id
                      FROM   fun_trx_headers reversed_hdrs,
                             fun_trx_lines reversed_lines,
                             --fun_batch_dists reversed_b_dists,
                             fun_trx_lines orig_lines,
                             fun_dist_lines orig_dists
                      WHERE  reversed_hdrs.batch_id = l_reversed_batch_id
                      AND    reversed_hdrs.trx_id = reversed_lines.trx_id
                      AND    reversed_hdrs.original_trx_id = orig_lines.trx_id
                      AND    orig_lines.line_id = orig_dists.line_id
                      AND    orig_dists.dist_type_flag='L';

		      --Bug: 9104801

			OPEN l_trx_total_cursor(l_reversed_batch_id);
			FETCH l_trx_total_cursor BULK COLLECT INTO l_trx_total_tbl;
			CLOSE l_trx_total_cursor;

			IF l_trx_total_tbl.COUNT > 0 THEN
			      FOR i IN l_trx_total_tbl.first..l_trx_total_tbl.last LOOP
				adjust_dist_amount(l_trx_total_tbl(i).trx_id,
						   l_trx_total_tbl(i).total_amount_cr,
						   l_trx_total_tbl(i).total_amount_dr);
			      END LOOP;
			END IF;

-- Raise event to send
l_wf_event_key := fun_wf_common.generate_event_key (l_reversed_batch_id, NULL);
fun_wf_common.raise_wf_bus_event(batch_id => l_reversed_batch_id,
                                 event_key => l_wf_event_key);
x_return_status := FND_API.G_RET_STS_SUCCESS;
Debug('CREATE_REVERSE_BATCH(-)');

END;

        PROCEDURE Create_Reverse_Trx
(       p_api_version           IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_commit                IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        p_trx_tbl_id IN number_type,
        p_reversed_batch_number IN VARCHAR2,
        p_reversal_method IN VARCHAR2, -- 'SWITCH' OR 'SIGN'
        p_reversed_batch_date IN DATE,
        p_reversed_gl_date IN DATE,
        p_reversed_description IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_reversed_batch_id IN OUT NOCOPY NUMBER
) IS
l_initiator_id NUMBER;
l_boolean BOOLEAN;
l_reversed_batch_number VARCHAR2(20);
l_control_date_tbl FUN_SEQ.CONTROL_DATE_TBL_TYPE;
l_control_date_rec FUN_SEQ.CONTROL_DATE_REC_TYPE;
l_seq_version_id        NUMBER;
l_assignment_id         NUMBER;
l_error_code            VARCHAR2(1000);
l_return_status VARCHAR2(1);
l_reversed_batch_id NUMBER;
l_wf_event_key          VARCHAR2(200);
l_batch_cr NUMBER;
l_batch_dr NUMBER;
l_total_batch_cr NUMBER :=0;
l_total_batch_dr NUMBER :=0;

    --Bug: 9104801
l_trx_total_tbl TRX_TOTAL_TBL_TYPE;
CURSOR l_trx_total_cursor(p_reversed_batch_id NUMBER) IS
SELECT trx_id,
       sum(init_amount_cr),
       sum(init_amount_dr)
FROM fun_trx_headers
WHERE batch_id = p_reversed_batch_id
GROUP by trx_id;

BEGIN
  Debug('CREATE_REVERSE_TRX(+)');
-- Problem: Still waiting for HLD to complete this section
-- Verify the status of the batch
-- Insert into batch
-- Insert into transaction
-- Insert into init_dist
-- Insert into dist_lines
  SELECT initiator_id INTO l_initiator_id
  FROM fun_trx_headers headers
  WHERE headers.trx_id = p_trx_tbl_id(1)
  AND headers.reversed_trx_id IS NULL
  AND headers.original_trx_id IS NULL
  AND headers.status in ('COMPLETE', 'APPROVED');--Bug: 6625360. AND headers.status = 'COMPLETE';
  IF l_initiator_id IS NULL THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('FUN', 'Trx error'); -- Problem here:  Whether a msg is needed
      FND_MSG_PUB.Add;
    END IF;
    Set_Return_Status(x_orig_status => x_return_status,
                      p_new_status => FND_API.G_RET_STS_ERROR);
    RETURN;
  END IF;
  -- Check batch numbering type
  l_boolean := fun_system_options_pkg.is_manual_numbering;

  -- Added code as when reversing batch number is generated in UI
  IF (p_reversed_batch_number IS NOT NULL) THEN
       l_boolean := true;
  END IF;
  -- End of extra code

  IF l_boolean THEN
    l_reversed_batch_number := p_reversed_batch_number;
  ELSE

  l_control_date_rec.date_type := 'CREATION_DATE';
  l_control_date_rec.date_value := sysdate;
  l_control_date_tbl(0) := l_control_date_rec;
  FUN_SEQ.GET_SEQUENCE_NUMBER('INTERCOMPANY_BATCH_SOURCE',
                              'LOCAL',
                              435,
                              'FUN_TRX_BATCHES',
                              'CREATION',
                              null,
                              l_control_date_tbl,
                              'N',
                              l_seq_version_id,
                              l_reversed_batch_number,
                              l_assignment_id,
                              l_error_code);
  END IF;
  -- Check uniqueness of the batch_number provided
  Is_Batch_Num_Unique(l_return_status,l_reversed_batch_number,l_initiator_id);
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Get the next sequence for fun_batch_id
  SELECT fun_trx_batches_s.nextval INTO l_reversed_batch_id FROM dual;

  -- Loop the trx_id table to get sum of debits and credits for txns to be reversed
  FOR i IN 1..p_trx_tbl_id.COUNT LOOP

    SELECT nvl(h.INIT_AMOUNT_CR,0), nvl(h.INIT_AMOUNT_DR,0)
    INTO l_batch_cr, l_batch_dr
    FROM fun_trx_headers h
    WHERE h.trx_id=p_trx_tbl_id(i);

    l_total_batch_cr:=l_total_batch_cr + l_batch_cr ;
    l_total_batch_dr:=l_total_batch_dr + l_batch_dr ;

  END LOOP;
 -- end of loop to get sum of debits and credits for txns to be reversed

  -- Insert into batch with orig_batch_id
  INSERT INTO fun_trx_batches(BATCH_ID,
                              BATCH_NUMBER,
                              INITIATOR_ID,
                              FROM_LE_ID,
                              FROM_LEDGER_ID,
                              CONTROL_TOTAL,
                              RUNNING_TOTAL_CR,
                              RUNNING_TOTAL_DR,
                              CURRENCY_CODE,
                              EXCHANGE_RATE_TYPE,
                              STATUS,
                              DESCRIPTION,
                              NOTE,
                              TRX_TYPE_ID,
                              TRX_TYPE_CODE,
                              GL_DATE,
                              BATCH_DATE,
                              REJECT_ALLOW_FLAG,
                              ORIGINAL_BATCH_ID,
                              REVERSED_BATCH_ID,
                              FROM_RECURRING_BATCH_ID,
                              INITIATOR_SOURCE,
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
                              ATTRIBUTE_CATEGORY,
                              CREATED_BY,
                              CREATION_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATE_LOGIN,
                              auto_proration_flag)
                      SELECT  l_reversed_batch_id,
                              l_reversed_batch_number,
                              batches.INITIATOR_ID,
                              batches.FROM_LE_ID,
                              batches.FROM_LEDGER_ID,
                              NULL,
                              DECODE(p_reversal_method, 'CHANGE', (-1) *(l_total_batch_cr),
                                                                 l_total_batch_dr),
                              DECODE(p_reversal_method, 'CHANGE', (-1) *(l_total_batch_dr),
                                                                 l_total_batch_cr),
                              batches.CURRENCY_CODE,
                              batches.EXCHANGE_RATE_TYPE,
                              'SENT',
                              p_reversed_description,
                              NULL,
                              batches.TRX_TYPE_ID,
                              batches.TRX_TYPE_CODE,
                              p_reversed_gl_date,
                              p_reversed_batch_date,
                              batches.REJECT_ALLOW_FLAG,
                              batches.batch_id,
                              NULL,
                              NULL,
                              batches.INITIATOR_SOURCE,
                              batches.ATTRIBUTE1,
                              batches.ATTRIBUTE2,
                              batches.ATTRIBUTE3,
                              batches.ATTRIBUTE4,
                              batches.ATTRIBUTE5,
                              batches.ATTRIBUTE6,
                              batches.ATTRIBUTE7,
                              batches.ATTRIBUTE8,
                              batches.ATTRIBUTE9,
                              batches.ATTRIBUTE10,
                              batches.ATTRIBUTE11,
                              batches.ATTRIBUTE12,
                              batches.ATTRIBUTE13,
                              batches.ATTRIBUTE14,
                              batches.ATTRIBUTE15,
                              batches.ATTRIBUTE_CATEGORY,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id,
                              batches.auto_proration_flag
                      FROM fun_trx_batches batches, fun_trx_headers headers
                      WHERE batches.batch_id = headers.batch_id
                      AND   headers.trx_id = p_trx_tbl_id(1);

  -- Loop the trx_id table and insert reversed txns
  FOR i IN 1..p_trx_tbl_id.COUNT LOOP

  -- Insert into transaction with status sent
  INSERT INTO fun_trx_headers(TRX_ID,
                              TRX_NUMBER,
                              INITIATOR_ID,
                              RECIPIENT_ID,
                              TO_LE_ID,
                              TO_LEDGER_ID,
                              BATCH_ID,
                              STATUS,
                              INIT_AMOUNT_CR,
                              INIT_AMOUNT_DR,
                              RECI_AMOUNT_CR,
                              RECI_AMOUNT_DR,
                              AR_INVOICE_NUMBER,
                              INVOICE_FLAG,
                              APPROVER_ID,
                              APPROVAL_DATE,
                              ORIGINAL_TRX_ID,
                              REVERSED_TRX_ID,
                              FROM_RECURRING_TRX_ID,
                              INITIATOR_INSTANCE_FLAG,
                              RECIPIENT_INSTANCE_FLAG,
                              REJECT_REASON,
                              DESCRIPTION,
                              INIT_WF_KEY,
                              RECI_WF_KEY,
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
                              ATTRIBUTE_CATEGORY,
                              CREATED_BY,
                              CREATION_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATE_LOGIN)
                       SELECT fun_trx_headers_s.nextval,
                              TRX_NUMBER, -- Problem: what to use
                              INITIATOR_ID,
                              RECIPIENT_ID,
                              TO_LE_ID,
                              TO_LEDGER_ID,
                              l_reversed_batch_id,
                              'SENT',
                              DECODE(p_reversal_method, 'CHANGE', DECODE(INIT_AMOUNT_CR, NULL, NULL, (-1) *(INIT_AMOUNT_CR)),
                                                                 INIT_AMOUNT_DR),
                              DECODE(p_reversal_method, 'CHANGE', DECODE(INIT_AMOUNT_DR, NULL, NULL, (-1) *(INIT_AMOUNT_DR)),
                                                                 INIT_AMOUNT_CR),
                              DECODE(p_reversal_method, 'CHANGE', DECODE(RECI_AMOUNT_CR, NULL, NULL, (-1) *(RECI_AMOUNT_CR)),
                                                                 RECI_AMOUNT_DR),
                              DECODE(p_reversal_method, 'CHANGE', DECODE(RECI_AMOUNT_DR, NULL, NULL, (-1) *(RECI_AMOUNT_DR)),
                                                                 RECI_AMOUNT_CR),
                              NULL,
                              INVOICE_FLAG,
                              NULL,
                              NULL,
                              TRX_ID,
                              NULL,
                              NULL,
                              INITIATOR_INSTANCE_FLAG,
                              RECIPIENT_INSTANCE_FLAG,
                              NULL,
                              p_reversed_description,
                              NULL,
                              NULL,
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
                              ATTRIBUTE_CATEGORY,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id,
                              sysdate,
                              fnd_global.user_id
                       FROM fun_trx_headers
                       WHERE trx_id = p_trx_tbl_id(i)
                       AND STATUS in ('COMPLETE', 'APPROVED'); --Bug: 6625360. AND STATUS = 'COMPLETE';
  -- Update reversed_trx_id with fun_trx_headers
  UPDATE fun_trx_headers hdrs1
  SET (reversed_trx_id) = (SELECT trx_id
                          FROM fun_trx_headers hdrs2
                          WHERE hdrs2.original_trx_id = hdrs1.trx_id)
  WHERE hdrs1.trx_id = p_trx_tbl_id(i);

 END LOOP;
 --End loop; which is looping trx_id table and inserting reversed txns

  UPDATE fun_trx_batches
  SET RUNNING_TOTAL_CR=(Select SUM(nvl(INIT_AMOUNT_CR,0))
  from fun_trx_headers
  where batch_id=l_reversed_batch_id
  ),
  RUNNING_TOTAL_DR=(Select SUM(nvl(INIT_AMOUNT_DR,0))
  from fun_trx_headers
  where batch_id=l_reversed_batch_id
  )
  where batch_id=l_reversed_batch_id;

  -- Insert into trx_lines.
  INSERT INTO fun_trx_lines(LINE_ID,
                            TRX_ID,
                            LINE_NUMBER,
                            LINE_TYPE_FLAG,
                            INIT_AMOUNT_CR,
                            INIT_AMOUNT_DR,
                            RECI_AMOUNT_CR,
                            RECI_AMOUNT_DR,
                            DESCRIPTION,
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATE_LOGIN)
                     SELECT fun_trx_lines_s.nextval,
                            headers.trx_id,
                            LINE_NUMBER,
                            LINE_TYPE_FLAG,
                            DECODE(p_reversal_method, 'CHANGE', DECODE(lines.INIT_AMOUNT_CR, NULL, NULL, (-1) * (lines.INIT_AMOUNT_CR)),
                                                               lines.INIT_AMOUNT_DR),
                            DECODE(p_reversal_method, 'CHANGE', DECODE(lines.INIT_AMOUNT_DR, NULL, NULL, (-1) * (lines.INIT_AMOUNT_DR)),
                                                               lines.INIT_AMOUNT_CR),
                            DECODE(p_reversal_method, 'CHANGE', DECODE(lines.RECI_AMOUNT_CR, NULL, NULL, (-1) * (lines.RECI_AMOUNT_CR)),
                                                               lines.RECI_AMOUNT_DR),
                            DECODE(p_reversal_method, 'CHANGE', DECODE(lines.RECI_AMOUNT_DR, NULL, NULL, (-1) * (lines.RECI_AMOUNT_DR)),
                                                               lines.RECI_AMOUNT_CR),

                            lines.DESCRIPTION,
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.user_id
                     FROM   fun_trx_headers headers, fun_trx_lines lines
                     WHERE  headers.batch_id = l_reversed_batch_id
                     AND    headers.original_trx_id = lines.trx_id;

  -- Insert into dist_lines
  INSERT INTO fun_dist_lines(DIST_ID,
                             LINE_ID,
                             DIST_NUMBER,
                             PARTY_ID,
                             PARTY_TYPE_FLAG,
                             DIST_TYPE_FLAG,
                             BATCH_DIST_ID,
                             AMOUNT_CR,
                             AMOUNT_DR,
                             CCID,
                             DESCRIPTION,
                             AUTO_GENERATE_FLAG,
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
                             ATTRIBUTE_CATEGORY,
                             CREATED_BY,
                             CREATION_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN,
                             trx_id)
                      SELECT fun_dist_lines_s.nextval,
                             reversed_lines.LINE_ID,
                             orig_dists.DIST_NUMBER,
                             orig_dists.PARTY_ID,
                             orig_dists.PARTY_TYPE_FLAG,
                             orig_dists.DIST_TYPE_FLAG,
                             NULL,
                             DECODE(p_reversal_method, 'CHANGE', DECODE(orig_dists.AMOUNT_CR, NULL, NULL, (-1) *(orig_dists.AMOUNT_CR)),
				orig_dists.AMOUNT_DR),
                             DECODE(p_reversal_method, 'CHANGE', DECODE(orig_dists.AMOUNT_DR, NULL, NULL, (-1) *(orig_dists.AMOUNT_DR)),
				orig_dists.AMOUNT_CR),
                             orig_dists.CCID,
                             orig_dists.DESCRIPTION,
                             orig_dists.AUTO_GENERATE_FLAG,
                             orig_dists.ATTRIBUTE1,
                             orig_dists.ATTRIBUTE2,
                             orig_dists.ATTRIBUTE3,
                             orig_dists.ATTRIBUTE4,
                             orig_dists.ATTRIBUTE5,
                             orig_dists.ATTRIBUTE6,
                             orig_dists.ATTRIBUTE7,
                             orig_dists.ATTRIBUTE8,
                             orig_dists.ATTRIBUTE9,
                             orig_dists.ATTRIBUTE10,
                             orig_dists.ATTRIBUTE11,
                             orig_dists.ATTRIBUTE12,
                             orig_dists.ATTRIBUTE13,
                             orig_dists.ATTRIBUTE14,
                             orig_dists.ATTRIBUTE15,
                             orig_dists.ATTRIBUTE_CATEGORY,
                             fnd_global.user_id,
                             sysdate,
                             fnd_global.user_id,
                             sysdate,
                             fnd_global.user_id,
                             reversed_hdrs.trx_id
                      FROM   fun_trx_headers reversed_hdrs,
                             fun_trx_lines reversed_lines,
                             --fun_batch_dists reversed_b_dists,
                             fun_trx_lines orig_lines,
                             fun_dist_lines orig_dists
                      WHERE  reversed_hdrs.batch_id = l_reversed_batch_id
                      AND    reversed_hdrs.trx_id = reversed_lines.trx_id
                      AND    reversed_hdrs.original_trx_id = orig_lines.trx_id
                      AND    orig_lines.line_id = orig_dists.line_id
                      AND    orig_dists.dist_type_flag='L';

      		      --Bug: 9104801

			OPEN l_trx_total_cursor(l_reversed_batch_id);
			FETCH l_trx_total_cursor BULK COLLECT INTO l_trx_total_tbl;
			CLOSE l_trx_total_cursor;

			IF l_trx_total_tbl.COUNT > 0 THEN
			      FOR i IN l_trx_total_tbl.first..l_trx_total_tbl.last LOOP
				adjust_dist_amount(l_trx_total_tbl(i).trx_id,
						   l_trx_total_tbl(i).total_amount_cr,
						   l_trx_total_tbl(i).total_amount_dr);
			      END LOOP;
			END IF;

-- Raise event to send
l_wf_event_key := fun_wf_common.generate_event_key (l_reversed_batch_id, NULL);
fun_wf_common.raise_wf_bus_event(batch_id => l_reversed_batch_id,
                                 event_key => l_wf_event_key);
x_return_status := FND_API.G_RET_STS_SUCCESS;
Debug('CREATE_REVERSE_TRX(-)');
END;

        PROCEDURE Update_Trx_Status
(       p_api_version           IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_commit                IN      VARCHAR2,
        p_validation_level      IN      NUMBER  ,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_trx_id                IN      NUMBER,
        p_update_status_to      IN      VARCHAR2
) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'UPDATE_TRX_STATUS';
l_api_version   CONSTANT NUMBER         := 1.0;
l_status VARCHAR2(15);
l_batch_id NUMBER;
l_count NUMBER;
CURSOR trx_status_csr IS
SELECT status
FROM fun_trx_headers
WHERE trx_id = p_trx_id FOR UPDATE;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT       Update_Trx_Status;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API body
    Debug('UPDATE_TRX_STATUS(+)');
    OPEN trx_status_csr;
    FETCH trx_status_csr INTO l_status;
    CLOSE trx_status_csr;
    -- This is for resolving issues of initiator and recipient updating
    -- status the same time
    IF (l_status = p_update_status_to OR
        (p_update_status_to = 'RECEIVED' AND l_status <> 'SENT')) THEN
        Debug('CONSISTENT STATUS');
    ELSIF (nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)<> FND_API.G_VALID_LEVEL_FULL) OR
        (l_status = 'NEW' AND p_update_status_to = 'SENT') OR
        (l_status = 'SENT' AND p_update_status_to = 'ERROR') OR
        (l_status = 'RECEIVED' AND p_update_status_to = 'ERROR') OR
        (l_status = 'ERROR' AND p_update_status_to = 'SENT') OR
        (l_status = 'ERROR' AND p_update_status_to = 'DELETED') OR
        (l_status = 'SENT' AND p_update_status_to = 'RECEIVED') OR
        (l_status = 'SENT' AND p_update_status_to = 'APPROVED') OR
        (l_status = 'SENT' AND p_update_status_to = 'REJECTED') OR
        (l_status = 'RECEIVED' AND p_update_status_to = 'APPROVED') OR
        (l_status = 'RECEIVED' AND p_update_status_to = 'REJECTED') OR
        (l_status = 'APPROVED' AND p_update_status_to = 'XFER_INI_GL') OR
        (l_status = 'APPROVED' AND p_update_status_to = 'XFER_RECI_GL') OR
        (l_status = 'APPROVED' AND p_update_status_to = 'XFER_AR') OR
        (l_status = 'APPROVED' AND p_update_status_to = 'COMPLETE') OR
        (l_status = 'XFER_AR' AND p_update_status_to = 'COMPLETE') OR
        (l_status = 'XFER_INI_GL' AND p_update_status_to = 'COMPLETE') OR
        (l_status = 'XFER_RECI_GL' AND p_update_status_to = 'COMPLETE')
      THEN
          UPDATE fun_trx_headers
          SET status = p_update_status_to
          WHERE trx_id = p_trx_id;

          SELECT batch_id
          INTO l_batch_id
          FROM fun_trx_headers
          WHERE trx_id = p_trx_id;

          IF (p_update_status_to = 'ERROR')
          THEN
               -- Update batch to ERROR if all
               -- transactions are at status ERROR
               UPDATE fun_trx_batches
               SET status = 'ERROR'
               WHERE batch_id = l_batch_id
               AND NOT EXISTS (SELECT 'X'
                               FROM   fun_trx_headers
                               WHERE  batch_id = l_batch_id
                               AND    status  <> 'ERROR');

          ELSIF (p_update_status_to IN ('COMPLETE', 'REJECTED'))
          THEN
               -- Update batch to COMPLETE if all
               -- transactions are at status COMPLETE or REJECTTED
               UPDATE fun_trx_batches
               SET status = 'COMPLETE'
               WHERE batch_id = l_batch_id
               AND NOT EXISTS (SELECT 'X'
                               FROM   fun_trx_headers
                               WHERE  batch_id = l_batch_id
                               AND    status  NOT IN ('COMPLETE','REJECTED'));


          END IF;
          -- Standard check of p_commit.
          IF FND_API.To_Boolean( nvl(p_commit,FND_API.G_FALSE) ) THEN
                COMMIT WORK;
          END IF;
     ELSE
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('FUN', 'Can not update status given');
              FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
     END IF;

        -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(  p_count => x_msg_count, p_data => x_msg_data);
    Debug('UPDATE_TRX_STATUS(-)');
 EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Update_Trx_Status;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count => x_msg_count,
                                p_data => x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Update_Trx_Status;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count => x_msg_count,
            p_data => x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK TO Update_Trx_Status;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       G_FILE_NAME,
                                    G_PKG_NAME,
                    l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count => x_msg_count,
                        p_data => x_msg_data
                );



END;

PROCEDURE Is_Payable_Acct_Valid
(
         x_return_status OUT NOCOPY VARCHAR2,
         p_ccid IN NUMBER
) IS
BEGIN
-- Problem.  Need to get more info from PM
return;
END Is_Payable_Acct_Valid;

PROCEDURE Is_Reci_Acct_Valid
(
         p_le_id IN NUMBER,
         p_ledger_id IN NUMBER,
         x_return_status OUT NOCOPY VARCHAR2,
         p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
) IS
l_count NUMBER;
l_return_status VARCHAR(1);
BEGIN
  l_count := p_dist_lines_tbl.COUNT;
   --Bug: 6618396.  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_count >= 1 THEN
    FOR i IN 1..l_count LOOP

      IF p_dist_lines_tbl(i).party_type = 'R' THEN
        IF p_dist_lines_tbl(i).ccid IS NULL THEN
                 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		 --Bug: 6618396
                   FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_RECI_DIST_AC_CCID');
                   FND_MESSAGE.SET_TOKEN('TRX_NUMBER', p_dist_lines_tbl(i).trx_number);
                    -- Problem:  Double check with msg repository
                   FND_MSG_PUB.Add;
                 END IF;
                 Set_Return_Status(x_orig_status => x_return_status,
                                   p_new_status => FND_API.G_RET_STS_ERROR);
	         l_return_status := x_return_status;
        ELSE
        Is_Ccid_Valid(x_return_status => x_return_status,
                       p_ccid => p_dist_lines_tbl(i).ccid,
                      p_le_id => p_le_id,
                      p_ledger_id => p_ledger_id);
	END IF;
      END IF;
    END LOOP;
    IF(l_return_status	= FND_API.G_RET_STS_ERROR) THEN
          x_return_status := l_return_status;
    END IF;
  END IF;
END Is_Reci_Acct_Valid;


PROCEDURE Is_Reci_Trx_Dist_Amt_Valid
(       x_return_status  OUT NOCOPY VARCHAR2,
        p_trx_amount_cr  IN      NUMBER,
        p_trx_amount_dr  IN      NUMBER,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'Is_Reci_Trx_Dist_Amt_Valid';
  l_boolean       BOOLEAN;
  l_count         NUMBER;

  l_dist_cr_type      NUMBER := 0;
  l_dist_dr_type      NUMBER := 0;
  l_dist_pos_type     NUMBER := 0;
  l_dist_neg_type     NUMBER := 0;
  l_dist_total_cr     NUMBER := 0;
  l_dist_total_dr     NUMBER := 0;
  l_trx_number        NUMBER;

BEGIN
  Debug('Is_Init_Trx_Dist_Amt_Valid(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Perform the following validation only for manual mode
      l_count := p_dist_lines_tbl.COUNT;
      IF l_count > 0
      THEN
           FOR j IN 1..l_count LOOP

              IF p_dist_lines_tbl(j).party_type = 'R' AND
                 p_dist_lines_tbl(j).dist_type = 'L'
              THEN
                  IF NVL(p_dist_lines_tbl(j).amount_cr, 0) <> 0 THEN
                      l_dist_cr_type := 1;
                      IF p_dist_lines_tbl(j).amount_cr > 0 THEN
                        l_dist_pos_type := 1;
                      ELSE
                        l_dist_neg_type := 1;
                      END IF;
                  END IF;
                  IF NVL(p_dist_lines_tbl(j).amount_dr, 0) <> 0 THEN
                      l_dist_dr_type := 1;
                      IF p_dist_lines_tbl(j).amount_dr > 0 THEN
                        l_dist_pos_type := 1;
                      ELSE
                        l_dist_neg_type := 1;
                      END IF;
                  END IF;
                  l_dist_total_cr := l_dist_total_cr + NVL(p_dist_lines_tbl(j).amount_cr, 0);
                  l_dist_total_dr := l_dist_total_dr + NVL(p_dist_lines_tbl(j).amount_dr, 0);
            END IF;
         END LOOP;
      END IF;

      IF (p_trx_amount_cr <> l_dist_total_dr OR
          p_trx_amount_dr <> l_dist_total_cr )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INCOMLT_SUM_REC_DIST');
                   FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                                p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;

      IF  l_dist_cr_type  = l_dist_dr_type
      THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_DRCR_BDIST_LINE');
              FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;


   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN OTHERS THEN
        FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF      FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg
                   (       G_PKG_NAME          ,
                           l_api_name
                           );
             END IF;
  Debug('Is_Reci_Trx_Dist_Amt_Valid(-)');
END Is_Reci_Trx_Dist_Amt_Valid;

        PROCEDURE Recipient_Validate
(       p_api_version                   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_batch_rec     IN OUT NOCOPY BATCH_REC_TYPE,
        p_trx_rec       IN OUT NOCOPY TRX_REC_TYPE,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
)
        IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'RECIPIENT_VALIDATE';
        l_api_version   CONSTANT NUMBER         := 1.0;
        l_return_status VARCHAR(1);
        l_result        VARCHAR(1);
        --l_batch_rec     Batch_Rec_Type;
        --l_trx_tab       Trx_Tbl_Type;
        --l_lines_tab     Dist_Line_Tbl_Type;
        l_count NUMBER;
        l_index NUMBER := 0;
        i NUMBER := 1;
        BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    Debug('RECIPIENT_VALIDATE(+)');
    IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= 50 THEN

        is_ap_valid(x_return_status => l_return_status,
                    p_initiator_id => p_batch_rec.initiator_id,
                    p_invoicing_rule => p_trx_rec.invoicing_rule,
                    p_recipient_id => p_trx_rec.recipient_id,
                    p_to_le_id => p_trx_rec.to_le_id,
                    p_trx_date => p_batch_rec.batch_date);
        set_return_status(x_orig_status => x_return_status,
                          p_new_status => l_return_status);
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_count := p_dist_lines_tbl.COUNT;
        IF l_count >= 1 THEN
         FOR  i IN 1..l_count LOOP
              -- There should be atleast one line for recipient distribution
                      Debug('3');
              IF p_dist_lines_tbl(i).dist_type = 'L' THEN
                  l_index := i;
              END IF;
          END LOOP;
        END IF;
        IF l_index = 0 THEN
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.SET_NAME('FUN', 'FUN_TRX_ENTRY_TRX_UP_NODATA');
               FND_MSG_PUB.Add;
             END IF;
			 -- Made changes for bug 9341446
             Set_Return_Status(x_orig_status => x_return_status,
                               p_new_status => 'I');
		     --End Changes bug 9341446
        ELSE
          Is_Payable_Acct_Valid(x_return_status => l_return_status,
                      p_ccid => p_dist_lines_tbl(l_index).ccid);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          Is_Reci_Acct_Valid(x_return_status => l_return_status,
                           p_le_id => p_trx_rec.to_le_id,
                           p_ledger_id => p_trx_rec.to_ledger_id,
                           p_dist_lines_tbl => p_dist_lines_tbl);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          Is_Reci_Trx_Dist_Amt_Valid
            ( x_return_status  => l_return_status,
              p_trx_amount_cr  => p_trx_rec.reci_amount_cr,
              p_trx_amount_dr  => p_trx_rec.reci_amount_dr,
              p_dist_lines_tbl => p_dist_lines_tbl);

		  --Added for bug 9341446
		  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			Set_Return_Status(x_orig_status => x_return_status,
							  p_new_status => 'I');
		  END IF;
		  --End Changes bug 9341446

         Set_Return_Status(x_orig_status => x_return_status,
                           p_new_status => l_return_status);
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
        END IF;
    END IF;
    Debug('RECIPIENT_VALIDATE(-)');
    -- End of API body.
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (       p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data
      );
        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );
           WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF      FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg
                   (       G_PKG_NAME          ,
                           l_api_name
                           );
             END IF;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );

/*
  is_init_party_valid(l_return_status => x_return_status
                      l_batch_rec  => p_batch_rec);
set_return_status(x_return_status => x_orig_status,
                  l_return_status => p_new_status);

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXP_ERROR;
END IF;


is_reci_party_valid(l_return_status => x_return_status
                    l_trx_rec =>
                      p_trx_rec);
set_return_status(x_return_status => x_orig_status,
                  l_return_status => p_new_status);

IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXP_ERROR;
    END IF;


    is_batch_type_valid(l_return_status => x_return_status
                        l_batch_rec
                        => p_batch_rec);
    set_return_status(x_return_status => x_orig_status,
                      l_return_status => p_new_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXP_ERROR;
        END IF;

        is_reci_gl_date_valid(l_return_status =>
                                                    x_return_status,
                              l_batch_rec
                              => p_batch_rec
                                                  l_trx_rec =>
                                p_trx_rec);
        set_return_status(x_return_status => x_orig_status,
                          l_return_status => p_new_status);
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXP_ERROR;
                                END IF;
            END IF;


            IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= FND_API.G_VALID_LEVEL_FULL THEN
            is_curr_fld_valid(l_return_status => x_return_status,
                              l_batch_rec
                              => p_batch_rec);
            set_return_status(x_return_status => x_orig_status,
                                                  l_return_status => p_new_status);
            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXP_ERROR;
                END IF;


*/

        END RECIPIENT_VALIDATE;


PROCEDURE Is_Ini_Reci_Trx_Dist_Amt_Valid
(       x_return_status  OUT NOCOPY VARCHAR2,
        p_trx_amount_cr  IN      NUMBER,
        p_trx_amount_dr  IN      NUMBER,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'Is_Ini_Reci_Trx_Dist_Amt_Valid';
  l_boolean       BOOLEAN;
  l_count         NUMBER;

  l_dist_cr_type      NUMBER := 0;
  l_dist_dr_type      NUMBER := 0;
  l_dist_pos_type     NUMBER := 0;
  l_dist_neg_type     NUMBER := 0;
  l_dist_total_cr     NUMBER := 0;
  l_dist_total_dr     NUMBER := 0;
  l_trx_number        NUMBER;

BEGIN
  Debug('Is_Init_Trx_Dist_Amt_Valid(+)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Perform the following validation only for manual mode
      l_count := p_dist_lines_tbl.COUNT;
      IF l_count > 0
      THEN
           FOR j IN 1..l_count LOOP

              IF p_dist_lines_tbl(j).party_type = 'R' AND
                 p_dist_lines_tbl(j).dist_type = 'L'
              THEN
                  IF NVL(p_dist_lines_tbl(j).amount_cr, 0) <> 0 THEN
                      l_dist_cr_type := 1;
                      IF p_dist_lines_tbl(j).amount_cr > 0 THEN
                        l_dist_pos_type := 1;
                      ELSE
                        l_dist_neg_type := 1;
                      END IF;
                  END IF;
                  IF NVL(p_dist_lines_tbl(j).amount_dr, 0) <> 0 THEN
                      l_dist_dr_type := 1;
                      IF p_dist_lines_tbl(j).amount_dr > 0 THEN
                        l_dist_pos_type := 1;
                      ELSE
                        l_dist_neg_type := 1;
                      END IF;
                  END IF;
                  l_dist_total_cr := l_dist_total_cr + NVL(p_dist_lines_tbl(j).amount_cr, 0);
                  l_dist_total_dr := l_dist_total_dr + NVL(p_dist_lines_tbl(j).amount_dr, 0);
            END IF;
         END LOOP;
      END IF;


      IF (nvl(p_trx_amount_cr,0) < l_dist_total_dr OR
          nvl(p_trx_amount_dr,0) < l_dist_total_cr )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INCOMLT_SUM_REC_DIST');
                   FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                                p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;

      IF  l_dist_cr_type  = l_dist_dr_type
      THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.SET_NAME('FUN', 'FUN_INVALID_DRCR_BDIST_LINE');
              FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status,
                            p_new_status => FND_API.G_RET_STS_ERROR);
      END IF;


   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   WHEN OTHERS THEN
        FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF      FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg
                   (       G_PKG_NAME          ,
                           l_api_name
                           );
             END IF;
  Debug('Is_Reci_Trx_Dist_Amt_Valid(-)');
END Is_Ini_Reci_Trx_Dist_Amt_Valid;


        PROCEDURE Ini_Recipient_Validate
(       p_api_version                   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_batch_rec     IN OUT NOCOPY BATCH_REC_TYPE,
        p_trx_rec       IN OUT NOCOPY TRX_REC_TYPE,
        p_dist_lines_tbl IN OUT NOCOPY DIST_LINE_TBL_TYPE
)
        IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'INI_RECIPIENT_VALIDATE';
        l_api_version   CONSTANT NUMBER         := 1.0;
        l_return_status VARCHAR(1);
        l_result        VARCHAR(1);
        --l_batch_rec     Batch_Rec_Type;
        --l_trx_tab       Trx_Tbl_Type;
        --l_lines_tab     Dist_Line_Tbl_Type;
        l_count NUMBER;
        l_index NUMBER := 0;
        i NUMBER := 1;
        BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    Debug('RECIPIENT_VALIDATE(+)');
    IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= 50 THEN

        l_count := p_dist_lines_tbl.COUNT;
        IF l_count >= 1 THEN
         FOR  i IN 1..l_count LOOP
              -- There should be atleast one line for recipient distribution
                      Debug('3');
              IF p_dist_lines_tbl(i).dist_type = 'L' THEN
                  l_index := i;
              END IF;
          END LOOP;
        END IF;
        IF l_index <= 0 THEN
             null;

        ELSE
          Is_Payable_Acct_Valid(x_return_status => l_return_status,
                      p_ccid => p_dist_lines_tbl(l_index).ccid);
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          Is_Reci_Acct_Valid(x_return_status => l_return_status,
                           p_le_id => p_trx_rec.to_le_id,
                           p_ledger_id => p_trx_rec.to_ledger_id,
                           p_dist_lines_tbl => p_dist_lines_tbl);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          Is_Ini_Reci_Trx_Dist_Amt_Valid
            ( x_return_status  => l_return_status,
              p_trx_amount_cr  => p_trx_rec.reci_amount_cr,
              p_trx_amount_dr  => p_trx_rec.reci_amount_dr,
              p_dist_lines_tbl => p_dist_lines_tbl);

         Set_Return_Status(x_orig_status => x_return_status,
                           p_new_status => l_return_status);
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
        END IF;
    END IF;
    Debug('RECIPIENT_VALIDATE(-)');
    -- End of API body.
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (       p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data
      );
        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );
           WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF      FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg
                   (       G_PKG_NAME          ,
                           l_api_name
                           );
             END IF;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );

/*
  is_init_party_valid(l_return_status => x_return_status
                      l_batch_rec  => p_batch_rec);
set_return_status(x_return_status => x_orig_status,
                  l_return_status => p_new_status);

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXP_ERROR;
END IF;


is_reci_party_valid(l_return_status => x_return_status
                    l_trx_rec =>
                      p_trx_rec);
set_return_status(x_return_status => x_orig_status,
                  l_return_status => p_new_status);

IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXP_ERROR;
    END IF;


    is_batch_type_valid(l_return_status => x_return_status
                        l_batch_rec
                        => p_batch_rec);
    set_return_status(x_return_status => x_orig_status,
                      l_return_status => p_new_status);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXP_ERROR;
        END IF;

        is_reci_gl_date_valid(l_return_status =>
                                                    x_return_status,
                              l_batch_rec
                              => p_batch_rec
                                                  l_trx_rec =>
                                p_trx_rec);
        set_return_status(x_return_status => x_orig_status,
                          l_return_status => p_new_status);
        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXP_ERROR;
                                END IF;
            END IF;


            IF nvl(p_validation_level,FND_API.G_VALID_LEVEL_FULL)>= FND_API.G_VALID_LEVEL_FULL THEN
            is_curr_fld_valid(l_return_status => x_return_status,
                              l_batch_rec
                              => p_batch_rec);
            set_return_status(x_return_status => x_orig_status,
                                                  l_return_status => p_new_status);
            IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXP_ERROR;
                END IF;


*/

        END INI_RECIPIENT_VALIDATE;


PROCEDURE init_Generate_Distributions (
      p_api_version      IN              NUMBER,
      p_init_msg_list    IN              VARCHAR2 ,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      p_batch_id           IN              NUMBER
) IS
        l_batch_rec batch_rec_type;
        CURSOR l_batch_cursor IS SELECT batch_id,
                                             batch_number,
                                             initiator_id,
                                             from_le_id,
                                             from_ledger_id,
                                             control_total,
                                             currency_code,
                                             exchange_rate_type,
                                             status,
                                             description,
                                             trx_type_id,
                                             trx_type_code,
                                             gl_date,
                                             batch_date,
                                             reject_allow_flag,
                                             from_recurring_batch_id,
                                             auto_proration_flag
                                      FROM fun_trx_batches
                                      WHERE batch_id = p_batch_id;
        l_trx_tbl TRX_TBL_TYPE;
        CURSOR l_trx_cursor IS SELECT trx_id,
                                      initiator_id,
                                      recipient_id,
                                      to_le_id,
                                      to_ledger_id,
                                      batch_id,
                                      status,
                                      init_amount_cr,
                                      init_amount_dr,
                                      reci_amount_cr,
                                      reci_amount_dr,
                                      ar_invoice_number,
                                      invoice_flag,
                                      approver_id,
                                      approval_date,
                                      original_trx_id,
                                      reversed_trx_id,
                                      from_recurring_trx_id,
                                      initiator_instance_flag,
                                      recipient_instance_flag,
                                      NULL,
                                      trx_number
                                      FROM fun_trx_headers
                                      WHERE batch_id = p_batch_id;

        l_init_dist_tbl INIT_DIST_TBL_TYPE;
        CURSOR l_init_dist_cursor IS SELECT batch_dist_id,
                                      line_number,
                                      batch_id,
                                      ccid,
                                      amount_cr,
                                      amount_dr,
                                      description
                                      FROM fun_batch_dists
                                      WHERE batch_id = p_batch_id;

        l_dist_lines_tbl DIST_LINE_TBL_TYPE;
        CURSOR l_dist_lines_cursor IS SELECT dists.dist_id,
                                             dists.dist_number,
                                             lines.trx_id,
                                             dists.line_id,
                                             dists.party_id,
                                             dists.party_type_flag,
                                             dists.dist_type_flag,
                                             dists.batch_dist_id,
                                             dists.amount_cr,
                                             dists.amount_dr,
                                             dists.ccid,
                                             hdrs.trx_number
                                             FROM fun_trx_headers hdrs,
                                                  fun_trx_lines lines,
                                                  fun_dist_lines dists
                                             WHERE hdrs.batch_id = p_batch_id
                                             AND   hdrs.trx_id = lines.trx_id
                                             AND   lines.line_id = dists.line_id
                                             AND   dists.party_type_flag = 'I'
                                             AND   dists.dist_type_flag = 'R';

BEGIN
         OPEN l_batch_cursor;
         FETCH l_batch_cursor INTO l_batch_rec;
         CLOSE l_batch_cursor;

         OPEN l_trx_cursor;
         FETCH l_trx_cursor BULK COLLECT INTO l_trx_tbl;
         CLOSE l_trx_cursor;

         OPEN l_init_dist_cursor;
         FETCH l_init_dist_cursor BULK COLLECT INTO l_init_dist_tbl;
         CLOSE l_init_dist_cursor;

         OPEN l_dist_lines_cursor;
         FETCH l_dist_lines_cursor BULK COLLECT INTO l_dist_lines_tbl;
         CLOSE l_dist_lines_cursor;

         init_generate_distributions(p_api_version,
                                     nvl(p_init_msg_list,FND_API.G_FALSE),
                                     x_return_status,
                                     x_msg_count,
                                     x_msg_data,
                                     l_batch_rec,
                                     l_trx_tbl,
                                     l_init_dist_tbl,
                                     l_dist_lines_tbl);
END;

-- Problem: need to add distribution validation and distribution generation
PROCEDURE Init_Generate_Distributions
(       p_api_version   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY    VARCHAR2,
        p_batch_rec     IN OUT NOCOPY BATCH_REC_TYPE,
        p_trx_tbl       IN OUT NOCOPY TRX_TBL_TYPE,
        p_init_dist_tbl IN OUT NOCOPY INIT_DIST_TBL_TYPE,
        p_dist_lines_tbl        IN OUT NOCOPY DIST_LINE_TBL_TYPE

) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'INIT_GENERATE_DISTRIBUTIONS';
        l_api_version   CONSTANT NUMBER         := 1.0;
        l_return_status VARCHAR(1);
        l_gen_dist_lines_tbl DIST_LINE_TBL_TYPE;
        l_init_dist_count NUMBER;
        l_dist_lines_count NUMBER;
        l_mau NUMBER; -- minimum accountable units
        l_currency_code VARCHAR2(15);
        --l_remaining_amts NUMBER_TYPE;
        l_l_l_running_tot NUMBER;-- last line running total
        l_total NUMBER := 0;
        l_amount_cr NUMBER;
        l_amount_dr NUMBER;
        l_running_amount_cr NUMBER;
        l_running_amount_dr NUMBER;
        l_running_amt_tbl init_dist_tbl_type;
        l_line_id           NUMBER;
        l_sign              NUMBER := 1;
        l_sum_amount_cr NUMBER;
        l_sum_amount_dr NUMBER;
	l_diff_amount NUMBER;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    Debug('INIT_GENERATE_DISTRIBUTIONS(+)');
    l_init_dist_count := p_init_dist_tbl.count;
    l_dist_lines_count := p_dist_lines_tbl.count;

     l_currency_code := p_batch_rec.currency_code;
     -- Get currency information from FND_CURRENCIES table
     SELECT nvl( minimum_accountable_unit, power( 10, (-1 * precision)))
     INTO l_mau
     FROM   FND_CURRENCIES
     WHERE  currency_code = l_currency_code;


  -- Delete the distributions generated for the initiator
    IF p_trx_tbl.COUNT > 0 THEN
      FOR i IN p_trx_tbl.first..p_trx_tbl.last LOOP
        DELETE FROM fun_dist_lines
        WHERE party_type_flag = 'I'
        AND dist_type_flag = 'L'
        --AND auto_generate_flag = 'Y'
        AND line_id IN
          (SELECT line_id
           FROM fun_trx_lines trx_lines
           WHERE trx_lines.trx_id = p_trx_tbl(i).trx_id);
       END LOOP;
    END IF;

    -- Find the total amount of the initiator distributions
    FOR i IN 1..l_init_dist_count LOOP
      IF Nvl(p_init_dist_tbl(i).amount_cr,0) < 0
      OR Nvl(p_init_dist_tbl(i).amount_cr,0) < 0
      THEN
          l_sign := -1;
      END IF;

      l_total := l_total + ABS(NVL(p_init_dist_tbl(i).amount_cr,0)) + ABS(NVL(p_init_dist_tbl(i).amount_dr,0));
    END LOOP;

    l_total := l_total * l_sign;


    -- Perform proration for each initiator distributions and roundoff
    -- Simplified the logic as part of the trx entry enhancements
    -- Formula to prorate =
    -- Batch Distribution Amount  x Recipient Amount / Total Batch Distributions

    FOR t IN p_trx_tbl.first..p_trx_tbl.last
    LOOP
        SELECT line_id
        INTO   l_line_id
        FROM   fun_trx_lines
        WHERE  trx_id = p_trx_tbl(t).trx_id;

        FOR i IN 1..l_init_dist_count
        LOOP
            l_amount_cr := ROUND(((p_init_dist_tbl(i).amount_cr * p_trx_tbl(t).init_amount_dr)/l_total)/ l_mau ) * l_mau;
            l_amount_dr := ROUND(((p_init_dist_tbl(i).amount_dr * p_trx_tbl(t).init_amount_cr)/l_total)/ l_mau ) * l_mau;

            INSERT INTO fun_dist_lines(DIST_ID,
                                       LINE_ID,
                                       DIST_NUMBER,
                                       PARTY_ID,
                                       PARTY_TYPE_FLAG,
                                       DIST_TYPE_FLAG,
                                       BATCH_DIST_ID,
                                       AMOUNT_CR,
                                       AMOUNT_DR,
                                       CCID,
                                       DESCRIPTION,
                                       AUTO_GENERATE_FLAG,
                                       CREATED_BY,
                                       CREATION_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATE_LOGIN,
                                       trx_id)
                           VALUES (fun_dist_lines_s.nextval,
                                       l_line_id,
                                       i,
                                       p_trx_tbl(t).initiator_id,
                                       'I',
                                       'L',
                                       p_init_dist_tbl(i).batch_dist_id,
                                       l_amount_cr,
                                       l_amount_dr,
                                       p_init_dist_tbl(i).ccid,
                                       p_init_dist_tbl(i).description,
                                       'Y',
                                       fnd_global.user_id,
                                       sysdate,
                                       fnd_global.user_id,
                                       sysdate,
                                       fnd_global.user_id,
                                       p_trx_tbl(t).trx_id);
        END LOOP; -- batch distributions

	--Bug: 9104801

	adjust_dist_amount(p_trx_tbl(t).trx_id,
			p_trx_tbl(t).init_amount_cr,
			p_trx_tbl(t).init_amount_dr);

    END LOOP; -- recipient

    Debug('INIT_GENERATE_DISTRIBUTIONS(-)');
    -- End of API body.
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (       p_count                 =>      x_msg_count,
              p_data                  =>      x_msg_data
      );

        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );
           WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF      FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 FND_MSG_PUB.Add_Exc_Msg
                   (       G_PKG_NAME          ,
                           l_api_name
                           );
             END IF;
             FND_MSG_PUB.Count_And_Get
               (       p_count                 =>      x_msg_count,
                       p_data                  =>      x_msg_data
               );
END;




-- Problem:  Remove validations for AR period and AP period
PROCEDURE Is_AP_Valid
(       x_return_status OUT NOCOPY VARCHAR2,
        p_initiator_id  IN      NUMBER,
        p_invoicing_rule IN     VARCHAR2,
        p_recipient_id   IN     NUMBER,
        p_to_le_id       IN     NUMBER,
        p_trx_date       IN      DATE
) IS
l_from_le_id NUMBER;
l_from_le_party_id NUMBER;  -- <bug 3450031>
l_from_ou_id NUMBER;
l_to_ou_id NUMBER;
l_success BOOLEAN;
l_supplier_id NUMBER;
l_pay_site_id NUMBER;
l_msg_data VARCHAR2(2000);
l_count NUMBER;
CURSOR ou_valid_csr IS
  SELECT count(*)
    FROM hr_operating_units ou
    WHERE organization_id = l_to_ou_id
    AND date_from <= p_trx_date
    AND NVL(date_to, p_trx_date) >= p_trx_date;  -- <bug 3450031>

    /* Removed as this should not be validated here
  CURSOR period_open_csr IS
    SELECT count(*)
    FROM GL_PERIOD_STATUSES PST
    WHERE pst.application_id = 200
      AND pst.closing_status <> 'N'
      AND pst.adjustment_period_flag <> 'Y'
      AND pst.ledger_id = p_to_le_id; */
BEGIN
    -- 7.3.1.4
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    Debug('IS_AP_VALID(+)');
    IF p_invoicing_rule = 'Y' THEN

        -- 7.3.1.3
        l_to_ou_id := Fun_Tca_Pkg.Get_OU_Id(p_recipient_id, p_trx_date);
        IF l_to_ou_id IS NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_OU');
                FND_MSG_PUB.Add;
            END IF;
            Set_Return_Status(x_orig_status => x_return_status,
                              p_new_status => FND_API.G_RET_STS_ERROR);
            Return;
        END IF;
        OPEN ou_valid_csr;
        FETCH ou_valid_csr INTO l_count;
        CLOSE ou_valid_csr;
        IF l_count < 1 THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_OU');
                FND_MSG_PUB.Add;
            END IF;
            Set_Return_Status(x_orig_status => x_return_status,
                              p_new_status => FND_API.G_RET_STS_ERROR);
            Return;
        END IF;

        -- <bug 3450031 start>
        l_from_le_party_id := Fun_Tca_Pkg.Get_LE_Id(p_initiator_id, p_trx_date);

        SELECT legal_entity_id
          INTO l_from_le_id
          FROM xle_firstparty_information_v
         WHERE party_id = l_from_le_party_id;
        -- <bug 3450031 end>

        l_from_ou_id := Fun_Tca_Pkg.Get_OU_Id(p_initiator_id, p_trx_date);
        IF l_from_ou_id IS NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_OU');
                FND_MSG_PUB.Add;
            END IF;
            Set_Return_Status(x_orig_status => x_return_status,
                              p_new_status => FND_API.G_RET_STS_ERROR);
            Return;
        END IF;

        l_success := Fun_Trading_Relation.Get_Supplier('INTERCOMPANY', l_from_le_id,
                                          p_to_le_id,l_from_ou_id,
                                          l_to_ou_id,
                                          p_initiator_id, p_recipient_id,
                                          p_trx_date, l_msg_data,
                                          l_supplier_id, l_pay_site_id);

        IF NOT l_success  THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('FUN', 'FUN_API_INVALID_SUPPLIER');
                FND_MSG_PUB.Add;
            END IF;
            Set_Return_Status(x_orig_status => x_return_status,
                              p_new_status => FND_API.G_RET_STS_ERROR);
        END IF;
        /* Removed, should not check here  -- Check AP period is open or not
        OPEN period_open_csr;
        FETCH period_open_csr INTO l_count;
        CLOSE period_open_csr;
        IF l_count < 1 THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('FUN', 'FUN_API_AP_PERIOD_NOT_OPEN');
                FND_MSG_PUB.Add;
            END IF;
            Set_Return_Status(x_orig_status => x_return_status,
                              p_new_status => FND_API.G_RET_STS_ERROR);
        END IF;
        */
    END IF;
    Debug('IS_AP_VALID(-)');
    -- End of API body.
END Is_Ap_Valid;



PROCEDURE AR_Transfer_Validate
(       p_api_version                   IN      NUMBER,
        p_init_msg_list IN      VARCHAR2 ,
        p_validation_level      IN      NUMBER  ,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_batch_id     IN NUMBER,
        p_trx_id       IN NUMBER
) IS
        l_api_name      CONSTANT VARCHAR2(30)   := 'AR_TRANSFER_VALIDATE';
        l_api_version   CONSTANT NUMBER         := 1.0;
        l_return_status VARCHAR2(1);
        l_trx_type_id   NUMBER;
        l_initiator_id NUMBER;
        l_trx_date DATE;
        l_memo_line_name   VARCHAR2(100);
        l_ar_trx_type_name VARCHAR2(100);
        l_memo_line_id     NUMBER;
        l_ar_trx_type_id     NUMBER;
        l_default_term_id    NUMBER;
        l_from_ou_id NUMBER;
        l_from_ledger_id NUMBER;
        l_recipient_id NUMBER;
        l_to_ou_id NUMBER;
        l_to_le_id NUMBER;
        l_count NUMBER;
        --ER: 8288979
       	l_init_amount_dr number;
	l_init_amount_cr number;
	l_trx_type  varchar2(4);


        CURSOR period_open_csr (p_trx_date   DATE,
                                p_ledger_id  NUMBER) IS
        SELECT COUNT(*)
        FROM   gl_period_statuses glps,
               gl_periods periods,
               gl_ledgers ledgers
        WHERE  periods.period_set_name = ledgers.period_set_name
        AND    TRUNC(p_trx_date) BETWEEN periods.start_date AND periods.end_date
        AND    glps.period_name = periods.period_name
        AND    glps.application_id = 222
        AND    glps.set_of_books_id = ledgers.ledger_id
        AND    glps.set_of_books_id = p_ledger_id
        AND    ledgers.ledger_id    = p_ledger_id
        AND    glps.adjustment_period_flag <> 'Y'
        AND    glps.closing_status IN ('O','F');

BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME )
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE)) THEN
         FND_MSG_PUB.initialize;
      END IF;

       --  Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- API body
       Debug('AR_TRANSFER_VALIDATE(+)');

       -- Retrieve initiator, transaction type
       SELECT initiator_id, trx_type_id, batch_date, from_ledger_id
       INTO l_initiator_id, l_trx_type_id, l_trx_date, l_from_ledger_id
       FROM fun_trx_batches
       WHERE batch_id = p_batch_id;

       SELECT recipient_id, to_le_id, init_amount_dr, init_amount_cr
       INTO l_recipient_id, l_to_le_id, l_init_amount_dr, l_init_amount_cr
       FROM fun_trx_headers
       WHERE trx_id = p_trx_id;

       -- Retrieve Operating unit
       l_from_ou_id := Fun_Tca_Pkg.Get_OU_Id(l_initiator_id, l_trx_date);
       -- ER:8288979. Passing p_trx_id.
       -- Retrieve memo line, ar trx type
       fun_trx_types_pub.Get_Trx_Type_Map(l_from_ou_id, l_trx_type_id,
                                       l_trx_date, p_trx_id,
                                       l_memo_line_id, l_memo_line_name,
                                       l_ar_trx_type_id, l_ar_trx_type_name,
                                       l_default_term_id);
       IF l_memo_line_name IS NULL OR l_ar_trx_type_name IS NULL THEN

         -- Problem need a message error code here
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          -- ER: 8288979
              l_trx_type := 'INV';
              IF(l_init_amount_dr is null) THEN
                      l_init_amount_dr := 0;
              END IF;
              IF(l_init_amount_cr is null) THEN
                      l_init_amount_cr := 0;
              END IF;
              -- Credit memo transaction
              if( l_init_amount_dr < 0 OR l_init_amount_cr > 0) THEN
                      l_trx_type := 'CM';
              END IF;

              FND_MESSAGE.SET_NAME('FUN', 'FUN_NO_TRX_TYPE_MAP');
              IF l_trx_type = 'INV' THEN
                FND_MESSAGE.SET_TOKEN('TRX_TYPE','Invoice Type');
              ELSE
                FND_MESSAGE.SET_TOKEN('TRX_TYPE','Credit Memo Type');
              END IF;
              FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status, p_new_status => FND_API.G_RET_STS_ERROR);
       END IF;

       OPEN period_open_csr(l_trx_date,
                            l_from_ledger_id);
       FETCH period_open_csr INTO l_count;
       IF l_count < 1 THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('FUN', 'FUN_API_AR_PERIOD_NOT_OPEN');
              FND_MSG_PUB.Add;
          END IF;
          Set_Return_Status(x_orig_status => x_return_status, p_new_status => FND_API.G_RET_STS_ERROR);
       END IF;

       Is_AR_Valid(x_return_status => l_return_status,
                   p_initiator_id => l_initiator_id,
                   p_invoicing_rule => 'Y',
                   p_recipient_id => l_recipient_id,
                   p_to_le_id => l_to_le_id,
                   p_trx_date => l_trx_date);

       Set_Return_Status(x_orig_status => x_return_status, p_new_status => l_return_status);

       Debug('AR_TRANSFER_VALIDATE(-)');
        -- End of API body.
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);


END AR_Transfer_Validate;


        PROCEDURE Debug
(
        p_message               IN      VARCHAR2
) IS
BEGIN
-- API body
-- Problem:  Use FND LOGGING mechanism?
IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)) THEN
    FND_MESSAGE.SET_NAME('FUN', p_message);
    FND_MSG_PUB.Add;
END IF;

-- End of API body.
END Debug;

-- Procedure will be called from the Outbound Search page
-- when a batch is DELETED (p_batch_id is passed)
-- Or it will be called from the Outbound Create page when a
-- transaction is DELETED (p_batch_id and p_trx_id is passed)
PROCEDURE cancel_notifications (p_batch_id        IN NUMBER,
                              p_trx_id          IN NUMBER,
                              p_init_msg_list   IN VARCHAR2 ,
                              x_return_status   OUT NOCOPY VARCHAR2,
                              x_msg_count       OUT NOCOPY NUMBER,
                              x_msg_data        OUT NOCOPY VARCHAR2)
IS

TYPE notList IS TABLE OF NUMBER;
l_notif_tbl          notList;
l_sql               VARCHAR2(2000);
l_api_name          VARCHAR2(30) := 'cancel_notifications';


BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( nvl(p_init_msg_list ,FND_API.G_FALSE))
   THEN
       FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_batch_id IS NULL AND p_trx_id IS NULL
   THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
   END IF;

   -- Some activities may be COMPLETE but the notification would
   -- still be outstanding
   -- Once transactions have gone into GL, AP and AR workflows,
   -- they cannot be deleted
   l_sql := ' SELECT  notif.notification_id ' ||
           ' FROM    wf_item_activity_statuses wias, ' ||
           '         wf_notifications notif          ' ||
           ' WHERE   wias.item_type IN (''FUNRMAIN'', ''FUNIMAIN'', ' ||
           '                            ''FUNRTVAL'') ' ||
           ' AND     wias.notification_id = notif.notification_id ' ||
           ' AND     notif.status = ''OPEN''';

   -- Itemkey is in the format <batch_id>_<trx_id><sequence_number>
   IF p_trx_id IS NULL
   THEN
       l_sql := l_sql ||
                ' AND wias.item_key like '''||p_batch_id||'_%''';
   ELSE
       l_sql := l_sql ||
                ' AND wias.item_key like '''||p_batch_id||'_'||p_trx_id||'%''';
   END IF;

   EXECUTE IMMEDIATE l_sql
   BULK COLLECT INTO l_notif_tbl;


   IF l_notif_tbl.COUNT > 0
   THEN
       FOR i IN l_notif_tbl.FIRST..l_notif_tbl.LAST
       LOOP
          wf_notification.cancel
                  (l_notif_tbl(i),
                   'Transaction Deleted');

       END LOOP;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data  => x_msg_data);

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
END cancel_notifications;

END FUN_TRX_PVT;

/
