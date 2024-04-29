--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_DUP_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_DUP_CHECK" AS
/*$Header: ARHMDUPB.pls 120.15.12010000.2 2008/09/08 07:06:18 kguggila ship $ */

FUNCTION check_cust_account_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
  x_to_id := FND_API.G_MISS_NUM;
  RETURN FND_API.G_FALSE;
END check_cust_account_dup;

FUNCTION check_cust_account_role_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
  x_to_id := FND_API.G_MISS_NUM;
  RETURN FND_API.G_FALSE;
END check_cust_account_role_dup;

FUNCTION check_cust_account_site_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
  x_to_id := FND_API.G_MISS_NUM;
  RETURN FND_API.G_FALSE;
END check_cust_account_site_dup;

FUNCTION check_financial_profile_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
        FINANCIAL_PROFILE_ID
  FROM HZ_FINANCIAL_PROFILE
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND   TO_CHAR(ACCESS_AUTHORITY_DATE, 'DD/MM/YYYY') ||
	ACCESS_AUTHORITY_GRANTED ||
	TO_CHAR(BALANCE_AMOUNT) ||
	TO_CHAR(BALANCE_VERIFIED_ON_DATE, 'DD/MM/YYYY') ||
 	FINANCIAL_ACCOUNT_NUMBER ||
	FINANCIAL_ACCOUNT_TYPE  ||
	FINANCIAL_ORG_TYPE ||
	FINANCIAL_ORGANIZATION_NAME = (
           SELECT TO_CHAR(ACCESS_AUTHORITY_DATE, 'DD/MM/YYYY') ||
	        ACCESS_AUTHORITY_GRANTED ||
        	TO_CHAR(BALANCE_AMOUNT) ||
        	TO_CHAR(BALANCE_VERIFIED_ON_DATE, 'DD/MM/YYYY') ||
        	FINANCIAL_ACCOUNT_NUMBER ||
        	FINANCIAL_ACCOUNT_TYPE  ||
        	FINANCIAL_ORG_TYPE ||
        	FINANCIAL_ORGANIZATION_NAME
	   FROM HZ_FINANCIAL_PROFILE
  	   WHERE  financial_profile_id = p_from_id);

l_record_id NUMBER;
BEGIN
  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_financial_profile_dup;

FUNCTION check_contact_point_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  p_owner_table_name IN     VARCHAR2,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck (source_type VARCHAR2) IS
  SELECT
     CONTACT_POINT_ID
  FROM HZ_CONTACT_POINTS
  WHERE owner_table_name = p_owner_table_name
  AND owner_table_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
   CONTACT_POINT_TYPE ||
   STATUS ||
   EDI_TRANSACTION_HANDLING ||
   EDI_ID_NUMBER ||
   EDI_PAYMENT_METHOD ||
   EDI_PAYMENT_FORMAT ||
   EDI_REMITTANCE_METHOD ||
   EDI_REMITTANCE_INSTRUCTION ||
   EDI_TP_HEADER_ID ||
   EDI_ECE_TP_LOCATION_CODE ||
   EMAIL_FORMAT ||
   TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD/MM/YYYY') ||
   TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD/MM/YYYY') ||
   PHONE_CALLING_CALENDAR ||
   DECLARED_BUSINESS_PHONE_FLAG ||
   PHONE_PREFERRED_ORDER ||
   TELEPHONE_TYPE ||
   TIME_ZONE ||
   PHONE_TOUCH_TONE_TYPE_FLAG ||
   PHONE_AREA_CODE ||
   PHONE_COUNTRY_CODE ||
   PHONE_NUMBER ||
   PHONE_EXTENSION ||
   PHONE_LINE_TYPE ||
   TELEX_NUMBER ||
   WEB_TYPE ||
   DECODE (source_type,'P',actual_content_source,'S')
       = (SELECT
   		CONTACT_POINT_TYPE ||
   		STATUS ||
   		EDI_TRANSACTION_HANDLING ||
   		EDI_ID_NUMBER ||
   		EDI_PAYMENT_METHOD ||
   		EDI_PAYMENT_FORMAT ||
   		EDI_REMITTANCE_METHOD ||
   		EDI_REMITTANCE_INSTRUCTION ||
   		EDI_TP_HEADER_ID ||
   		EDI_ECE_TP_LOCATION_CODE ||
   		EMAIL_FORMAT ||
   		TO_CHAR(BEST_TIME_TO_CONTACT_START, 'DD/MM/YYYY') ||
   		TO_CHAR(BEST_TIME_TO_CONTACT_END, 'DD/MM/YYYY') ||
   		PHONE_CALLING_CALENDAR ||
   		DECLARED_BUSINESS_PHONE_FLAG ||
   		PHONE_PREFERRED_ORDER ||
   		TELEPHONE_TYPE ||
   		TIME_ZONE ||
   		PHONE_TOUCH_TONE_TYPE_FLAG ||
   		PHONE_AREA_CODE ||
   		PHONE_COUNTRY_CODE ||
   		PHONE_NUMBER ||
   		PHONE_EXTENSION ||
   		PHONE_LINE_TYPE ||
   		TELEX_NUMBER ||
   	        WEB_TYPE ||
                DECODE (source_type,'P',actual_content_source,'S')
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = p_from_id)
   AND upper(nvl(EMAIL_ADDRESS,'NOEMAIL')) = ( --7294111 Added Upper
           SELECT upper(nvl(EMAIL_ADDRESS,'NOEMAIL')) --7294111 Added Upper
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = p_from_id)
   AND nvl(URL, 'NOURL') = (
           SELECT nvl(URL, 'NOURL')
           FROM HZ_CONTACT_POINTS
           WHERE contact_point_id = p_from_id);

CURSOR c_cont_source IS
  SELECT ACTUAL_CONTENT_SOURCE
  FROM HZ_CONTACT_POINTS
  WHERE contact_point_id = p_from_id;

l_record_id NUMBER;
l_cont_source VARCHAR2(255);
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_temp NUMBER;
l_cont_source_type VARCHAR2(255);
l_source_type VARCHAR2(1) :='S';
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN c_cont_source;
  FETCH c_cont_source INTO l_cont_source;
  CLOSE c_cont_source;

  IF l_cont_source = 'DNB' THEN
    RETURN FND_API.G_FALSE;
 ELSE---Find Whether Purchased or Spoke
  SELECT orig_system_type INTO l_cont_source_type
    FROM HZ_ORIG_SYSTEMS_B WHERE orig_system = l_cont_source;
    IF l_cont_source_type = 'PURCHASED' THEN
       l_source_type :='P';
    END IF;
  END IF;
 ----Bug 4114254. USE ACS column for dup check if the l_cont_source is PURCHASED otherwise dont use it.
  OPEN dupcheck(l_source_type);
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_contact_point_dup;

FUNCTION check_references_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    REFERENCE_ID
  FROM HZ_REFERENCES
  WHERE referenced_party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    TO_CHAR(COMMENTING_PARTY_ID) ||
    EXTERNAL_ACCOUNT_NUMBER ||
    TO_CHAR(REFERENCE_DATE, 'DD/MM/YYYY') =
       (SELECT
		TO_CHAR(COMMENTING_PARTY_ID) ||
    		EXTERNAL_ACCOUNT_NUMBER ||
    		TO_CHAR(REFERENCE_DATE, 'DD/MM/YYYY')
	FROM HZ_REFERENCES
	WHERE reference_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_references_dup;


FUNCTION check_certification_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    CERTIFICATION_ID
  FROM HZ_CERTIFICATIONS
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    CERTIFICATION_NAME ||
    CURRENT_STATUS ||
    TO_CHAR(EXPIRES_ON_DATE, 'DD/MM/YYYY') ||
    GRADE ||
    ISSUED_BY_AUTHORITY ||
    TO_CHAR(ISSUED_ON_DATE, 'DD/MM/YYYY') =
	(SELECT
		CERTIFICATION_NAME ||
    		CURRENT_STATUS ||
    		TO_CHAR(EXPIRES_ON_DATE, 'DD/MM/YYYY') ||
    		GRADE ||
    		ISSUED_BY_AUTHORITY ||
    		TO_CHAR(ISSUED_ON_DATE, 'DD/MM/YYYY')
  	FROM HZ_CERTIFICATIONS
	WHERE certification_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_certification_dup;


FUNCTION check_credit_ratings_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck (source_type VARCHAR2) IS
  SELECT
    CREDIT_RATING_ID
  FROM HZ_CREDIT_RATINGS
  WHERE party_id = p_to_fk_id
  AND
    TO_CHAR(RATED_AS_OF_DATE, 'DD/MM/YYYY') ||
    RATING_ORGANIZATION ||
    DECODE (source_type,'P',actual_content_source,'S')  =
	(SELECT
    		TO_CHAR(RATED_AS_OF_DATE, 'DD/MM/YYYY') ||
    		RATING_ORGANIZATION ||
              DECODE (source_type,'P',actual_content_source,'S') FROM HZ_CREDIT_RATINGS
  	WHERE credit_rating_id = p_from_id);

CURSOR c_cont_source IS
  SELECT ACTUAL_CONTENT_SOURCE
  FROM HZ_CREDIT_RATINGS
  WHERE credit_rating_id = p_from_id;

l_cont_source VARCHAR2(255);
l_record_id NUMBER;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_temp NUMBER;
l_cont_source_type VARCHAR2(255);
l_source_type VARCHAR2(1) :='S';
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN c_cont_source;
  FETCH c_cont_source INTO l_cont_source;
  CLOSE c_cont_source;

  IF l_cont_source = 'DNB'  THEN
  RETURN FND_API.G_FALSE;
  ELSE---Find Whether Purchased or Spoke
  SELECT orig_system_type INTO l_cont_source_type
    FROM HZ_ORIG_SYSTEMS_B WHERE orig_system = l_cont_source;
    IF l_cont_source_type = 'PURCHASED' THEN
      l_source_type :='P';
    END IF;
  END IF;
 ----Bug 4114254. USE ACS column for dup check if the l_cont_source is PURCHASED otherwise dont use it.
  OPEN dupcheck(l_source_type);
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;

  RETURN FND_API.G_TRUE;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_credit_ratings_dup;


FUNCTION check_security_issued_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    SECURITY_ISSUED_ID
  FROM HZ_SECURITY_ISSUED
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    TO_CHAR(ESTIMATED_TOTAL_AMOUNT) ||
    TO_CHAR(STOCK_EXCHANGE_ID) ||
    SECURITY_ISSUED_CLASS ||
    SECURITY_ISSUED_NAME ||
    TOTAL_AMOUNT_IN_A_CURRENCY ||
    STOCK_TICKER_SYMBOL ||
    SECURITY_CURRENCY_CODE ||
    TO_CHAR(BEGIN_DATE,'DD/MM/YYYY') ||
    TO_CHAR(END_DATE,'DD/MM/YYYY') =
       (SELECT
	    TO_CHAR(ESTIMATED_TOTAL_AMOUNT) ||
	    TO_CHAR(STOCK_EXCHANGE_ID) ||
	    SECURITY_ISSUED_CLASS ||
	    SECURITY_ISSUED_NAME ||
	    TOTAL_AMOUNT_IN_A_CURRENCY ||
	    STOCK_TICKER_SYMBOL ||
	    SECURITY_CURRENCY_CODE ||
	    TO_CHAR(BEGIN_DATE,'DD/MM/YYYY') ||
	    TO_CHAR(END_DATE,'DD/MM/YYYY')
        FROM HZ_SECURITY_ISSUED
        WHERE   security_issued_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_security_issued_dup;

FUNCTION check_financial_reports_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck (source_type VARCHAR2) IS
  SELECT
    FINANCIAL_REPORT_ID
  FROM HZ_FINANCIAL_REPORTS
  WHERE party_id = p_to_fk_id
  AND
    TO_CHAR(DATE_REPORT_ISSUED, 'DD/MM/YYYY') ||
    DOCUMENT_REFERENCE ||
    ISSUED_PERIOD ||
    TYPE_OF_FINANCIAL_REPORT ||
    TO_CHAR(REPORT_START_DATE, 'DD/MM/YYYY') ||
    TO_CHAR(REPORT_END_DATE, 'DD/MM/YYYY') ||
    DECODE (source_type,'P',actual_content_source,'S')  =
	(SELECT
	    TO_CHAR(DATE_REPORT_ISSUED, 'DD/MM/YYYY') ||
	    DOCUMENT_REFERENCE ||
	    ISSUED_PERIOD ||
	    TYPE_OF_FINANCIAL_REPORT ||
	    TO_CHAR(REPORT_START_DATE, 'DD/MM/YYYY') ||
	    TO_CHAR(REPORT_END_DATE, 'DD/MM/YYYY') ||
            DECODE (source_type,'P',actual_content_source,'S')
           FROM HZ_FINANCIAL_REPORTS
	WHERE financial_report_id = p_from_id);

CURSOR c_cont_source IS
  SELECT ACTUAL_CONTENT_SOURCE
  FROM HZ_FINANCIAL_REPORTS
  WHERE financial_report_id = p_from_id;

CURSOR dnb_dup_check IS  --5396227
  SELECT financial_report_id
  FROM HZ_FINANCIAL_REPORTS
  WHERE party_id = p_to_fk_id
  AND actual_content_source = 'DNB'
  AND nvl(status, 'A') = 'A'
  AND type_of_financial_report= (SELECT type_of_financial_report
                                 FROM HZ_FINANCIAL_REPORTS
                                 WHERE financial_report_id = p_from_id);

l_cont_source VARCHAR2(255);
l_cont_source_type VARCHAR2(255);
l_record_id NUMBER;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_temp NUMBER;
l_temp1 NUMBER;

l_source_type VARCHAR2(1) :='S';

BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN c_cont_source;
  FETCH c_cont_source INTO l_cont_source;
  CLOSE c_cont_source;

  IF l_cont_source = 'DNB' THEN
-- 5396227
        OPEN dnb_dup_check;
        FETCH dnb_dup_check INTO l_record_id;
        IF dnb_dup_check%NOTFOUND THEN
            CLOSE dnb_dup_check;
            RETURN FND_API.G_FALSE;
        END IF;
        x_to_id := l_record_id;
        CLOSE dnb_dup_check;
        RETURN FND_API.G_TRUE;

  ELSE---Find Whether Purchased or Spoke
  SELECT orig_system_type INTO l_cont_source_type
    FROM HZ_ORIG_SYSTEMS_B WHERE orig_system = l_cont_source;
    IF l_cont_source_type = 'PURCHASED' THEN
       l_source_type :='P';
    END IF;
  END IF;

----Bug 4114254. USE ACS column for dup check if the l_cont_source is PURCHASED otherwise dont use it.

  OPEN dupcheck(l_source_type);
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;

  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_financial_reports_dup;


FUNCTION check_org_indicators_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    ORGANIZATION_INDICATOR_ID
  FROM HZ_ORGANIZATION_INDICATORS
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    INDICATOR ||
    TO_CHAR(START_DATE, 'DD/MM/YYYY') ||
    TO_CHAR(END_DATE, 'DD/MM/YYYY') =
	(SELECT
		INDICATOR ||
		TO_CHAR(START_DATE, 'DD/MM/YYYY') ||
		TO_CHAR(END_DATE, 'DD/MM/YYYY')
	FROM HZ_ORGANIZATION_INDICATORS
	WHERE organization_indicator_id = p_from_id)
  AND
    nvl(DESCRIPTION	, 'NODESC') =
       (SELECT nvl(DESCRIPTION, 'NODESC')
        FROM HZ_ORGANIZATION_INDICATORS
        WHERE organization_indicator_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_org_indicators_dup;

FUNCTION check_ind_reference_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    INDUSTRY_REFERENCE_ID
  FROM HZ_INDUSTRIAL_REFERENCE
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    INDUSTRY_REFERENCE ||
    ISSUED_BY_AUTHORITY ||
    NAME_OF_REFERENCE ||
    TO_CHAR(RECOGNIZED_AS_OF_DATE,'DD/MM/YYYY') =
	(SELECT
		INDUSTRY_REFERENCE ||
		ISSUED_BY_AUTHORITY ||
		NAME_OF_REFERENCE ||
		TO_CHAR(RECOGNIZED_AS_OF_DATE,'DD/MM/YYYY')
	FROM HZ_INDUSTRIAL_REFERENCE
	WHERE industry_reference_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_ind_reference_dup;

FUNCTION check_per_interest_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    PERSON_INTEREST_ID
  FROM HZ_PERSON_INTEREST
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    INTEREST_TYPE_CODE ||
    SUB_INTEREST_TYPE_CODE =
	(SELECT
		INTEREST_TYPE_CODE ||
		SUB_INTEREST_TYPE_CODE
	FROM HZ_PERSON_INTEREST
	WHERE person_interest_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_per_interest_dup;


FUNCTION check_citizenship_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    CITIZENSHIP_ID
  FROM HZ_CITIZENSHIP
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    BIRTH_OR_SELECTED ||
    COUNTRY_CODE ||
    TO_CHAR(DATE_DISOWNED, 'DD/MM/YYYY') ||
    TO_CHAR(DATE_RECOGNIZED, 'DD/MM/YYYY') ||
    DOCUMENT_REFERENCE ||
    TO_CHAR(END_DATE, 'DD/MM/YYYY') ||
    DOCUMENT_TYPE =
	(SELECT
		BIRTH_OR_SELECTED ||
		COUNTRY_CODE ||
		TO_CHAR(DATE_DISOWNED, 'DD/MM/YYYY') ||
		TO_CHAR(DATE_RECOGNIZED, 'DD/MM/YYYY') ||
		DOCUMENT_REFERENCE ||
		TO_CHAR(END_DATE, 'DD/MM/YYYY') ||
		DOCUMENT_TYPE
	FROM HZ_CITIZENSHIP
	WHERE citizenship_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_citizenship_dup;


FUNCTION check_education_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    EDUCATION_ID
  FROM HZ_EDUCATION
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    COURSE_MAJOR ||
    DEGREE_RECEIVED ||
    TO_CHAR(LAST_DATE_ATTENDED, 'DD/MM/YYYY') ||
    TO_CHAR(START_DATE_ATTENDED, 'DD/MM/YYYY') ||
    TYPE_OF_SCHOOL ||
    SCHOOL_ATTENDED_NAME ||
    SCHOOL_PARTY_ID=
	(SELECT
		COURSE_MAJOR ||
		DEGREE_RECEIVED ||
		TO_CHAR(LAST_DATE_ATTENDED, 'DD/MM/YYYY') ||
		TO_CHAR(START_DATE_ATTENDED, 'DD/MM/YYYY') ||
		TYPE_OF_SCHOOL ||
                SCHOOL_ATTENDED_NAME ||
                SCHOOL_PARTY_ID
	FROM HZ_EDUCATION
	WHERE education_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_education_dup;

FUNCTION check_work_class_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS
CURSOR dupcheck IS
  SELECT
    WORK_CLASS_ID
  FROM HZ_WORK_CLASS
  WHERE employment_history_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    WORK_CLASS_NAME =
        (SELECT
	    WORK_CLASS_NAME
        FROM HZ_WORK_CLASS
        WHERE work_class_id = p_from_id);
l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_work_class_dup;


FUNCTION check_emp_history_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    EMPLOYMENT_HISTORY_ID
  FROM HZ_EMPLOYMENT_HISTORY
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    TO_CHAR(BEGIN_DATE, 'DD/MM/YYYY') ||
    EMPLOYED_AS_TITLE ||
    EMPLOYED_BY_DIVISION_NAME ||
    EMPLOYED_BY_NAME_COMPANY ||
    TO_CHAR(END_DATE, 'DD/MM/YYYY') ||
    SUPERVISOR_NAME ||
    BRANCH ||
    MILITARY_RANK ||
    SERVED  ||
    STATION =
	(SELECT
		TO_CHAR(BEGIN_DATE, 'DD/MM/YYYY') ||
		EMPLOYED_AS_TITLE ||
		EMPLOYED_BY_DIVISION_NAME ||
		EMPLOYED_BY_NAME_COMPANY ||
		TO_CHAR(END_DATE, 'DD/MM/YYYY') ||
		SUPERVISOR_NAME ||
		BRANCH ||
		MILITARY_RANK ||
		SERVED ||
                STATION
	FROM HZ_EMPLOYMENT_HISTORY
	WHERE employment_history_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_emp_history_dup;


FUNCTION check_languages_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT LANGUAGE_USE_REFERENCE_ID
  FROM   HZ_PERSON_LANGUAGE
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND
    LANGUAGE_NAME =
	(SELECT
		LANGUAGE_NAME
	FROM HZ_PERSON_LANGUAGE
	WHERE language_use_reference_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_languages_dup;

FUNCTION check_party_site_use_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

 ---Bug:2619948 remove comments, begin_date and end_date from duplicate check

CURSOR dupcheck IS
  SELECT
   PARTY_SITE_USE_ID
  FROM HZ_PARTY_SITE_USES
  WHERE party_site_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND SITE_USE_TYPE =
         	(SELECT
		SITE_USE_TYPE
	FROM HZ_PARTY_SITE_USES
	WHERE party_site_use_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_party_site_use_dup;

FUNCTION check_party_site_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
   PARTY_SITE_ID
  FROM HZ_PARTY_SITES
  WHERE party_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND LOCATION_ID = (
	SELECT LOCATION_ID
	FROM HZ_PARTY_SITES
  	WHERE party_site_id = p_from_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_party_site_dup;

FUNCTION check_code_assignment_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  p_owner_table_name IN     VARCHAR2,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    CODE_ASSIGNMENT_ID
  FROM HZ_CODE_ASSIGNMENTS
  WHERE owner_table_name = p_owner_table_name
  AND owner_table_id = p_to_fk_id
  --AND (status IS NULL OR status = 'A')--Commented for Bug#3016319.
  AND CLASS_CATEGORY || CLASS_CODE  = (
        SELECT  CLASS_CATEGORY ||
		CLASS_CODE
        FROM HZ_CODE_ASSIGNMENTS
        WHERE code_assignment_id = p_from_id);

CURSOR c_cont_source IS
  SELECT CONTENT_SOURCE_TYPE
  FROM HZ_CODE_ASSIGNMENTS
  WHERE code_assignment_id = p_from_id;

l_cont_source VARCHAR2(255);
l_record_id NUMBER;
l_from_last_upd_date DATE;
l_to_last_upd_date DATE;
l_temp NUMBER;

BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN c_cont_source;
  FETCH c_cont_source INTO l_cont_source;
  CLOSE c_cont_source;

  IF l_cont_source = 'DNB' THEN
    RETURN FND_API.G_FALSE;
  END IF;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

END check_code_assignment_dup;

FUNCTION check_financial_number_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    FINANCIAL_NUMBER_ID
  FROM HZ_FINANCIAL_NUMBERS
  WHERE financial_report_id = p_to_fk_id
  AND NVL(FINANCIAL_NUMBER_NAME,'NONAME') = (
        SELECT
          NVL(FINANCIAL_NUMBER_NAME,'NONAME')
        FROM HZ_FINANCIAL_NUMBERS
        WHERE financial_number_id = p_from_id);

l_record_id NUMBER;

BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

END check_financial_number_dup;

FUNCTION check_org_contact_role_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    ORG_CONTACT_ROLE_ID
  FROM HZ_ORG_CONTACT_ROLES
  WHERE org_contact_id = p_to_fk_id
  AND ROLE_TYPE = (
        SELECT ROLE_TYPE
        FROM   HZ_ORG_CONTACT_ROLES
        WHERE  ORG_CONTACT_ROLE_ID = p_from_id);

l_record_id NUMBER;

BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

END check_org_contact_role_dup;

FUNCTION check_contact_preference_dup(
  p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  p_owner_table_name IN     VARCHAR2,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT
    CONTACT_PREFERENCE_ID
  FROM HZ_CONTACT_PREFERENCES
  WHERE contact_level_table = p_owner_table_name
  AND contact_level_table_id = p_to_fk_id
  AND (status IS NULL OR status = 'A')
  AND --Bug:4390508 - contact_type || preference_code || preference_topic_type ||
  		contact_type || preference_topic_type ||
        preference_topic_type_id || preference_topic_type_code =
        (SELECT
                 --Bug:4390508 - contact_type || preference_code ||
                 contact_type ||
                 preference_topic_type ||
                 preference_topic_type_id ||
                 preference_topic_type_code
         FROM HZ_CONTACT_PREFERENCES
         WHERE contact_preference_id = p_from_id)
  AND NOT (
            ( preference_end_date is not null and
             preference_end_date <= ( SELECT preference_start_date
                                      FROM HZ_CONTACT_PREFERENCES
                                      WHERE contact_preference_id = p_from_id))
            OR
            ( exists (SELECT 1
              FROM HZ_CONTACT_PREFERENCES
              WHERE contact_preference_id = p_from_id
              AND preference_end_date is not null)  AND
              preference_start_date >= ( SELECT preference_end_date
                                      FROM HZ_CONTACT_PREFERENCES
                                      WHERE contact_preference_id = p_from_id))
          )
   AND NOT (
      (
       (decode(preference_start_time_hr, null, 0, preference_start_time_hr) * 60 +
        decode(preference_start_time_mi, null, 0, preference_start_time_mi)) >
         ( select (decode(preference_end_time_hr, null, 24, preference_end_time_hr) * 60 +
                  decode (preference_end_time_mi, null, 60, preference_end_time_mi))
           from HZ_CONTACT_PREFERENCES
           WHERE contact_preference_id = p_from_id)
       ) OR (
      (decode(preference_end_time_hr, null, 24, preference_end_time_hr ) * 60 +
       decode(preference_end_time_mi, null, 60, preference_end_time_mi)) <
         (select (decode(preference_start_time_hr, null, 0, preference_start_time_hr) * 60 +
                 decode(preference_start_time_mi, null, 0, preference_start_time_mi ))
          FROM HZ_CONTACT_PREFERENCES
           WHERE contact_preference_id = p_from_id)
      )
   );

l_record_id NUMBER;

BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_contact_preference_dup;

--Bug No: 4577535 fix checking for duplicate addresses

FUNCTION check_address_dup(
  p_from_location_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id         IN OUT NOCOPY  NUMBER,
  p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status IN OUT NOCOPY  VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT PARTY_SITE_ID
          FROM HZ_PARTY_SITES ps,
               HZ_LOCATIONS   l
         WHERE ps.party_id = p_to_fk_id
           AND ps.location_id = l.location_id
           AND (ps.status IS NULL OR ps.status = 'A')
           AND UPPER(TRIM(ADDRESS1) ||
                     TRIM(ADDRESS2) ||
                     TRIM(ADDRESS3) ||
                     TRIM(ADDRESS4) ||
                     TRIM(COUNTRY)  ||
                     TRIM(STATE)    ||
                     TRIM(CITY)     ||
                     TRIM(PROVINCE) ||
                     TRIM(COUNTY)   ||
                     TRIM(POSTAL_CODE)) =
       (SELECT UPPER(TRIM(ADDRESS1) ||
                     TRIM(ADDRESS2) ||
                     TRIM(ADDRESS3) ||
                     TRIM(ADDRESS4) ||
                     TRIM(COUNTRY)  ||
                     TRIM(STATE)    ||
                     TRIM(CITY)     ||
                     TRIM(PROVINCE) ||
                     TRIM(COUNTY)   ||
                     TRIM(POSTAL_CODE))
	 FROM HZ_LOCATIONS
	WHERE LOCATION_ID = p_from_location_id);

l_record_id NUMBER;
BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_address_dup;

END HZ_MERGE_DUP_CHECK;

/
