--------------------------------------------------------
--  DDL for Package Body OKE_CHR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_CHR_PVT" AS
/*$Header: OKEVCHRB.pls 120.0.12010000.2 2008/09/29 10:51:49 rriyer ship $ */

FUNCTION  Validate_Attributes(p_chr_rec IN chr_rec_type)
		RETURN VARCHAR2;

G_NO_PARENT_RECORD CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;
G_CHILD_RECORD_EXISTS CONSTANT VARCHAR2(200) := 'OKE_CANNOT_DELETE_MASTER';
G_TABLE_TOKEN CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKE__CONTRACTS_UNEXPECTED_ERROR';

G_SQLERRM_TOKEN CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN CONSTANT VARCHAR2(200) := 'SQLcode';
G_VIEW		CONSTANT VARCHAR2(200) := 'OKE_K_HEADERS_V';
G_EXCEPTION_HALT_VALIDATION exception;
l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;











/* Bug 7115155 Start */
FUNCTION IS_BOA (P_TYPE_CODE IN OKE_K_TYPES_B.K_TYPE_CODE%type)
RETURN   BOOLEAN
IS
l_type_class_code  OKE_K_TYPES_B.TYPE_CLASS_CODE%TYPE;
BEGIN

SELECT   TYPE_CLASS_CODE
INTO     l_type_class_code
FROM     OKE_K_TYPES_B
WHERE    K_TYPE_CODE=P_TYPE_CODE;

IF l_type_class_code='BOA' THEN
   RETURN TRUE;
ELSE
  RETURN FALSE;
END IF;

END IS_BOA;
/* Bug 7115155 End*/



PROCEDURE validate_program_id (x_return_status OUT NOCOPY VARCHAR2,
			      p_chr_rec	      IN  chr_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';
  CURSOR l_csr IS
  SELECT 'x'
  FROM OKE_PROGRAMS
  WHERE PROGRAM_ID = p_chr_rec.PROGRAM_ID
    AND SYSDATE BETWEEN START_DATE
    AND NVL(END_DATE+1 , SYSDATE )
  ;

BEGIN

  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.program_id <> OKE_API.G_MISS_NUM
     AND p_chr_rec.program_id IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

    IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PROGRAM_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_PROGRAMS');

      x_return_status := OKE_API.G_RET_STS_ERROR;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

  IF l_csr%ISOPEN THEN
    CLOSE l_csr;
  END IF;

END validate_program_id;



PROCEDURE validate_boa_id (x_return_status OUT NOCOPY VARCHAR2,
			      p_chr_rec	      IN  chr_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';
  CURSOR l_csr IS
  SELECT 'x'
  FROM OKE_K_HEADERS
  WHERE K_HEADER_ID = p_chr_rec.BOA_ID;

BEGIN

  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.boa_id <> OKE_API.G_MISS_NUM
     AND p_chr_rec.boa_id IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

    IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'BOA_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>G_VIEW);

      x_return_status := OKE_API.G_RET_STS_ERROR;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

  IF l_csr%ISOPEN THEN
    CLOSE l_csr;
  END IF;

END validate_boa_id;

PROCEDURE validate_project_id (x_return_status OUT NOCOPY VARCHAR2,
			      p_chr_rec	      IN  chr_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';
  CURSOR l_csr IS
  SELECT 'x'
  FROM PA_PROJECTS_ALL
  WHERE PROJECT_ID = p_chr_rec.PROJECT_ID;

BEGIN

  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.project_id <> OKE_API.G_MISS_NUM
     AND p_chr_rec.project_id IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

    IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PROJECT_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'PA_PROJECTS_ALL');

      x_return_status := OKE_API.G_RET_STS_ERROR;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

  IF l_csr%ISOPEN THEN
    CLOSE l_csr;
  END IF;

END validate_project_id;


-- DATE PROBLEM

PROCEDURE validate_priority_code(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';
  CURSOR l_csr IS
  SELECT 'x'  FROM OKE_PRIORITY_CODES_VL
  WHERE PRIORITY_CODE = p_chr_rec.priority_code;

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;


  IF (   p_chr_rec.priority_code <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.priority_code IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

   IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PRIORITY_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_PRIORITY_CODES_VL');

      x_return_status := OKE_API.G_RET_STS_ERROR;
   END IF;
  End If;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_priority_code;




PROCEDURE validate_product_code(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';


  CURSOR l_csr IS
  SELECT 'x'
  FROM FND_LOOKUP_VALUES_VL
  WHERE VIEW_APPLICATION_ID = 777 AND LOOKUP_TYPE = 'PRODUCT_LINE'
  AND NVL(ENABLED_FLAG , 'Y') = 'Y'
  AND LOOKUP_CODE = p_chr_rec.PRODUCT_LINE_CODE
  AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE , SYSDATE - 1)
  AND NVL(END_DATE_ACTIVE , SYSDATE + 1);


BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;


  IF (   p_chr_rec.product_line_code <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.product_line_code IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

   IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PRODUCT_LINE_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'FND_LOOKUP_VALUES_VL');

      x_return_status := OKE_API.G_RET_STS_ERROR;
   END IF;
  End If;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_product_code;




PROCEDURE validate_country_code(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';


  CURSOR l_csr IS
  SELECT 'x'
  FROM FND_TERRITORIES_VL
  WHERE TERRITORY_CODE = p_chr_rec.COUNTRY_OF_ORIGIN_CODE;

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;


  IF (   p_chr_rec.country_of_origin_code <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.country_of_origin_code IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

   IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'COUNTRY_OF_ORIGIN_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'FND_TERRITORIES_VL');

      x_return_status := OKE_API.G_RET_STS_ERROR;
   END IF;
  End If;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_country_code;


PROCEDURE validate_vat_code(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS
  l_dummy_val VARCHAR2(1):= '?';

  CURSOR get_info IS
  SELECT AUTHORING_ORG_ID,BUY_OR_SELL
  FROM OKC_K_HEADERS_B
  WHERE ID = p_chr_rec.K_HEADER_ID;

  l_org NUMBER;
  l_intent VARCHAR2(30);

  CURSOR l_csr IS
  SELECT 'x'
  FROM OKE_TAX_CODES_V
  WHERE ( ORG_ID IS NULL OR ORG_ID = l_org )
  AND BUY_OR_SELL = l_intent
  AND SYSDATE BETWEEN NVL( START_DATE , SYSDATE - 1 )
                AND NVL( END_DATE , SYSDATE + 1 )
  AND ENABLED_FLAG = 'Y'
  AND TAX_CODE = p_chr_rec.VAT_CODE;

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  OPEN get_info;
  FETCH get_info INTO l_org,l_intent;
  CLOSE get_info;

  IF (   p_chr_rec.vat_code <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.vat_code IS NOT NULL) THEN

    OPEN l_csr;
    FETCH l_csr INTO l_dummy_val;
    CLOSE l_csr;

   IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'VAT_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_TAX_CODES_V');

      x_return_status := OKE_API.G_RET_STS_ERROR;
   END IF;
  End If;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_vat_code;





PROCEDURE validate_prime_k_alias(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
  -- call column length utility
 /* OKE_UTIL.CHECK_LENGTH(p_view_name	=>G_VIEW,
			p_col_name	=>'PRIME_K_ALIAS',
			p_col_value	=>p_chr_rec.PRIME_K_ALIAS,
			x_return_status	=>x_return_status);*/

  IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_prime_k_alias;

PROCEDURE validate_prime_k_number(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
  -- call column length utility
 /* OKE_UTIL.CHECK_LENGTH(p_view_name	=>G_VIEW,
			p_col_name	=>'PRIME_K_NUMBER',
			p_col_value	=>p_chr_rec.prime_k_number,
			x_return_status	=>x_return_status);*/



  IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_prime_k_number;


PROCEDURE validate_k_type_code(x_return_status OUT NOCOPY VARCHAR2,
			p_chr_rec	IN  chr_rec_type)IS

  l_dummy_val VARCHAR2(1):= '?';
  CURSOR l_csr IS
  SELECT 'x'  FROM OKE_K_TYPES_B
  WHERE K_TYPE_CODE = p_chr_rec.k_type_code;

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.k_type_code= OKE_API.G_MISS_CHAR
     OR  p_chr_rec.k_type_code IS  NULL) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'K_TYPE_CODE');
     x_return_status := OKE_API.G_RET_STS_ERROR;
     RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;


 open l_csr;
 fetch l_csr into l_dummy_val;
 close l_csr;


   IF (l_dummy_val = '?') THEN
      OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'K_TYPE_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_K_TYPES_B');

      x_return_status := OKE_API.G_RET_STS_ERROR;
   END IF;


EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_k_type_code;



PROCEDURE validate_authorizing_reason(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
  -- call column length utility
 /* OKE_UTIL.CHECK_LENGTH(p_view_name	=>G_VIEW,
			p_col_name	=>'AUTHORIZING_REASON',
			p_col_value	=>p_chr_rec.authorizing_reason,
			x_return_status	=>x_return_status);*/

  IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_authorizing_reason;


PROCEDURE validate_award_cancel_date(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
-- check the date is valid

/*
  IF (   p_chr_rec.award_cancel_date <> OKE_API.G_MISS_DATE
     AND p_chr_rec.award_cancel_date IS NOT NULL) THEN

    IF (   p_chr_rec.award_date <> OKE_API.G_MISS_DATE
       AND p_chr_rec.award_date IS NOT NULL) THEN
      IF (p_chr_rec.award_cancel_date < p_chr_rec.award_date) THEN
        x_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;
    ELSE
      x_return_status := OKE_API.G_RET_STS_ERROR;
    END IF;

  END IF;
*/
  IF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>'OKE_NOT_AWARD_CONTRACT',
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'AWARD_CANCEL_DATE');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_award_cancel_date;



PROCEDURE validate_date_definitized(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
-- check the date is valid
  -- take out the validation, since no requirement specified

/*  IF (   p_chr_rec.date_definitized <> OKE_API.G_MISS_DATE
     AND p_chr_rec.date_definitized IS NOT NULL) THEN

    IF (   p_chr_rec.award_date <> OKE_API.G_MISS_DATE
       AND p_chr_rec.award_date IS NOT NULL)THEN
      IF (p_chr_rec.date_definitized < p_chr_rec.award_date) THEN
        x_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;

    ELSE
      x_return_status := OKE_API.G_RET_STS_ERROR;

    END IF;

  END IF; */




  IF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>'OKE_NOT_AWARD_CONTRACT',
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DATE_DEFINITIZED');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_date_definitized;


PROCEDURE validate_date_received(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
-- check the date is valid

  IF (   p_chr_rec.date_received <> OKE_API.G_MISS_DATE
     AND p_chr_rec.date_received IS NOT NULL) THEN

    IF (   p_chr_rec.date_issued <> OKE_API.G_MISS_DATE
       AND p_chr_rec.date_issued IS NOT NULL)THEN
      IF (p_chr_rec.date_received < p_chr_rec.date_issued) THEN
        x_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;

    END IF;

  END IF;

  IF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>'OKE_ISSUED_FIRST',
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DATE_RECEIVED');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_date_received;



PROCEDURE validate_award_date(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

CURSOR l_getdate IS
SELECT start_date from okc_k_headers_b
WHERE id = p_chr_rec.k_header_id;

l_startdate DATE;

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;
-- check the date is valid
/*
open l_getdate;
fetch l_getdate into l_startdate;
close l_getdate;

  IF (   p_chr_rec.award_date <> OKE_API.G_MISS_DATE
     AND p_chr_rec.award_date IS NOT NULL) THEN

    IF (   l_startdate <> OKE_API.G_MISS_DATE
       AND l_startdate IS NOT NULL) THEN

      IF ( p_chr_rec.AWARD_DATE > l_startdate) THEN
        x_return_status := OKE_API.G_RET_STS_ERROR;
      END IF;
    END IF;
  END IF;
*/
  IF (x_return_status = OKE_API.G_RET_STS_ERROR) THEN
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>'OKE_INVALID_AWARD_DATE');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_award_date;


PROCEDURE validate_booked_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.booked_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.booked_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.booked_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'BOOKED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_booked_flag;

PROCEDURE validate_open_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.open_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.open_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.open_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'OPEN_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_open_flag;

PROCEDURE validate_cfe_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.cfe_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.cfe_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.cfe_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'CFE_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_cfe_flag;

PROCEDURE validate_export_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.export_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.export_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.export_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'EXPORT_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_export_flag;

PROCEDURE validate_human_subject_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.human_subject_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.human_subject_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.human_subject_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'HUMAN_SUBJECT_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_human_subject_flag;

PROCEDURE validate_cqa_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.cqa_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.cqa_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.cqa_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'CQA_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_cqa_flag;

PROCEDURE validate_interim_rpt_req_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.interim_rpt_req_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.interim_rpt_req_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.interim_rpt_req_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'INTERIM_RPT_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_interim_rpt_req_flag;

PROCEDURE validate_penalty_clause_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.penalty_clause_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.penalty_clause_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.penalty_clause_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'PENALTY_CLAUSE_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_penalty_clause_flag;

PROCEDURE validate_reporting_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.reporting_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.reporting_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.reporting_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'REPROTING_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_reporting_flag;

PROCEDURE validate_sb_plan_req_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.sb_plan_req_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.sb_plan_req_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.sb_plan_req_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'SB_PLAN_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_sb_plan_req_flag;

PROCEDURE validate_sb_report_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.sb_report_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.sb_report_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.sb_report_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'SB_REPORT_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_sb_report_flag;

PROCEDURE validate_nte_warning_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.nte_warning_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.nte_warning_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.nte_warning_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'NTE_WARNING_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_nte_warning_flag;


PROCEDURE validate_bill_without_def_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.bill_without_def_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.bill_without_def_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.bill_without_def_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'BILL_WITHOUT_DEF_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_bill_without_def_flag;




PROCEDURE validate_cas_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.cas_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.cas_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.cas_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'CAS_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_cas_flag;

PROCEDURE validate_classified_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.classified_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.classified_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.classified_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'CLASSIFIED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_classified_flag;


PROCEDURE validate_client_approve_req(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.client_approve_req_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.client_approve_req_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.client_approve_req_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'CLIENT_APPROVE_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_client_approve_req;

PROCEDURE validate_dcaa_audit_req_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.dcaa_audit_req_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.dcaa_audit_req_flag IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.dcaa_audit_req_flag) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DCAA_AUDIT_REQ_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_dcaa_audit_req_flag;

PROCEDURE validate_oh_rates_final_flag(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.oh_rates_final_flag <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.OH_RATES_FINAL_FLAG IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.OH_RATES_FINAL_FLAG) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'OH_RATES_FINAL_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_oh_rates_final_flag;




PROCEDURE validate_COST_OF_MONEY(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.COST_OF_MONEY <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.COST_OF_MONEY IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.COST_OF_MONEY) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'COST_OF_MONEY');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_COST_OF_MONEY;

PROCEDURE validate_COST_SHARE_FLAG(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.COST_SHARE_FLAG <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.COST_SHARE_FLAG IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.COST_SHARE_FLAG) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'COST_SHARE_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_COST_SHARE_FLAG;

PROCEDURE validate_PROGRESS_PAYMENT_FLAG(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.PROGRESS_PAYMENT_FLAG <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.PROGRESS_PAYMENT_FLAG IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.PROGRESS_PAYMENT_FLAG) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'PROGRESS_PAYMENT_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_PROGRESS_PAYMENT_FLAG;

PROCEDURE validate_DEFINITIZED_FLAG(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.DEFINITIZED_FLAG <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.DEFINITIZED_FLAG IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.DEFINITIZED_FLAG) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'DEFINITIZED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_DEFINITIZED_FLAG;

PROCEDURE validate_FINANCIAL_CTRL_VERIF(x_return_status OUT NOCOPY VARCHAR2,
				p_chr_rec	IN  chr_rec_type)IS

BEGIN
  x_return_status := OKE_API.G_RET_STS_SUCCESS;

  IF (   p_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG <> OKE_API.G_MISS_CHAR
     AND p_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG IS NOT NULL) THEN
    IF (UPPER(p_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG) NOT IN ('Y','N')) THEN
      OKE_API.SET_MESSAGE(p_app_name		=>g_app_name,
		p_msg_name		=>G_REQUIRED_VALUE,
		p_token1		=>G_COL_NAME_TOKEN,
		p_token1_value		=>'FINANCIAL_CTRL_VERIFIED_FLAG');
      x_return_status := OKE_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
  x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

END validate_FINANCIAL_CTRL_VERIF;


--
-- Derive K_Number_Disp value
--
FUNCTION K_Number_Disp
( X_K_Header_ID   IN   NUMBER
, X_BOA_ID        IN   NUMBER
) RETURN VARCHAR2
IS

Value1  VARCHAR2(120);
Value2  VARCHAR2(120);

CURSOR c ( C_CHR_ID NUMBER ) IS
  SELECT contract_number
  FROM   okc_k_headers_b
  WHERE  ID = C_CHR_ID;

BEGIN

  OPEN c ( X_K_Header_ID );
  FETCH c INTO Value1;
  CLOSE c;

  IF ( X_BOA_ID IS NOT NULL ) THEN

    OPEN c ( X_BOA_ID );
    FETCH c INTO Value2;
    CLOSE c;

    RETURN ( substr(Value2 || '/' || Value1 , 1 , 240) );

  ELSE

    RETURN ( Value1 );

  END IF;

END K_Number_Disp;

/* Bug 7115155 Start*/

PROCEDURE UPDATE_DO(P_BOA_ID IN NUMBER)
IS
L_K_NUMBER_DISP       VARCHAR2(120);
CURSOR c_do
IS
SELECT k_header_id
FROM  oke_k_headers
WHERE boa_id=P_BOA_ID
FOR UPDATE NOWAIT;
BEGIN

FOR l_do_rec IN c_do
LOOP
 L_K_NUMBER_DISP := K_Number_Disp(l_do_rec.k_header_id,p_boa_id);
 UPDATE oke_k_headers
 SET    k_number_disp= L_K_NUMBER_DISP
 WHERE  CURRENT OF c_do;
END LOOP;

END UPDATE_DO;

/* Bug 7115155 End*/

-- Get record from OKE_K_HEADERS

FUNCTION get_rec(
  p_chr_rec		IN chr_rec_type,
  x_no_data_found	OUT NOCOPY BOOLEAN)
RETURN chr_rec_type IS

  CURSOR chr_pk_csr(p_id IN NUMBER) IS
  SELECT
	K_HEADER_ID,
	PROGRAM_ID,
 	PROJECT_ID,
	BOA_ID,
        K_TYPE_CODE,
	PRIORITY_CODE,
	PRIME_K_ALIAS,
	PRIME_K_NUMBER,
	AUTHORIZE_DATE,
	AUTHORIZING_REASON,
	AWARD_CANCEL_DATE,
	AWARD_DATE,
	DATE_DEFINITIZED,
	DATE_ISSUED,
	DATE_NEGOTIATED,
	DATE_RECEIVED,
	DATE_SIGN_BY_CONTRACTOR,
	DATE_SIGN_BY_CUSTOMER,
	FAA_APPROVE_DATE,
	FAA_REJECT_DATE,
	BOOKED_FLAG,
	OPEN_FLAG,
	CFE_FLAG,
	VAT_CODE,
	COUNTRY_OF_ORIGIN_CODE,
	EXPORT_FLAG,
	HUMAN_SUBJECT_FLAG,
	CQA_FLAG,
	INTERIM_RPT_REQ_FLAG,
	NO_COMPETITION_AUTHORIZE,
	PENALTY_CLAUSE_FLAG,
	PRODUCT_LINE_CODE,
	REPORTING_FLAG,
	SB_PLAN_REQ_FLAG,
	SB_REPORT_FLAG,
	NTE_AMOUNT,
	NTE_WARNING_FLAG,
	BILL_WITHOUT_DEF_FLAG,
	CAS_FLAG,
	CLASSIFIED_FLAG,
	CLIENT_APPROVE_REQ_FLAG,
	COST_OF_MONEY,
	DCAA_AUDIT_REQ_FLAG,
	COST_SHARE_FLAG,
	OH_RATES_FINAL_FLAG,
	PROGRESS_PAYMENT_FLAG,
	PROGRESS_PAYMENT_LIQ_RATE,
	PROGRESS_PAYMENT_RATE,
	ALTERNATE_LIQUIDATION_RATE,
	PROP_DELIVERY_LOCATION,
	PROP_DUE_DATE_TIME,
        PROP_DUE_TIME,
	PROP_EXPIRE_DATE,
	COPIES_REQUIRED,
	SIC_CODE,
	TECH_DATA_WH_RATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	FINANCIAL_CTRL_VERIFIED_FLAG,
	DEFINITIZED_FLAG,
	COST_OF_SALE_RATE,
	LINE_VALUE_TOTAL,
	UNDEF_LINE_VALUE_TOTAL,
--	END_DATE,
	OWNING_ORGANIZATION_ID,
	DEFAULT_TASK_ID
  FROM OKE_K_HEADERS
  WHERE K_HEADER_ID = p_id;

  l_chr_pk	chr_pk_csr%ROWTYPE;
  l_chr_rec	chr_rec_type;
  l_temp	VARCHAR2(1) := 'Y';
BEGIN
  x_no_data_found := TRUE;

-- Get current database values

  OPEN chr_pk_csr(p_chr_rec.k_header_id);
  FETCH chr_pk_csr INTO

	l_chr_rec.K_HEADER_ID,
	l_chr_rec.PROGRAM_ID,
 	l_chr_rec.PROJECT_ID,
	l_chr_rec.BOA_ID,
        l_chr_rec.K_TYPE_CODE,
	l_chr_rec.PRIORITY_CODE,
	l_chr_rec.PRIME_K_ALIAS,
	l_chr_rec.PRIME_K_NUMBER,
	l_chr_rec.AUTHORIZE_DATE,
	l_chr_rec.AUTHORIZING_REASON,
	l_chr_rec.AWARD_CANCEL_DATE,
	l_chr_rec.AWARD_DATE,
	l_chr_rec.DATE_DEFINITIZED,
	l_chr_rec.DATE_ISSUED,
	l_chr_rec.DATE_NEGOTIATED,
	l_chr_rec.DATE_RECEIVED,
	l_chr_rec.DATE_SIGN_BY_CONTRACTOR,
	l_chr_rec.DATE_SIGN_BY_CUSTOMER,
	l_chr_rec.FAA_APPROVE_DATE,
	l_chr_rec.FAA_REJECT_DATE,
	l_chr_rec.BOOKED_FLAG,
	l_chr_rec.OPEN_FLAG,
	l_chr_rec.CFE_FLAG,
	l_chr_rec.VAT_CODE,
	l_chr_rec.COUNTRY_OF_ORIGIN_CODE,
	l_chr_rec.EXPORT_FLAG,
	l_chr_rec.HUMAN_SUBJECT_FLAG,
	l_chr_rec.CQA_FLAG,
	l_chr_rec.INTERIM_RPT_REQ_FLAG,
	l_chr_rec.NO_COMPETITION_AUTHORIZE,
	l_chr_rec.PENALTY_CLAUSE_FLAG,
	l_chr_rec.PRODUCT_LINE_CODE,
	l_chr_rec.REPORTING_FLAG,
	l_chr_rec.SB_PLAN_REQ_FLAG,
	l_chr_rec.SB_REPORT_FLAG,
	l_chr_rec.NTE_AMOUNT,
	l_chr_rec.NTE_WARNING_FLAG,
	l_chr_rec.BILL_WITHOUT_DEF_FLAG,
	l_chr_rec.CAS_FLAG,
	l_chr_rec.CLASSIFIED_FLAG,
	l_chr_rec.CLIENT_APPROVE_REQ_FLAG,
	l_chr_rec.COST_OF_MONEY,
	l_chr_rec.DCAA_AUDIT_REQ_FLAG,
	l_chr_rec.COST_SHARE_FLAG,
	l_chr_rec.OH_RATES_FINAL_FLAG,
        l_chr_rec.PROGRESS_PAYMENT_FLAG,
	l_chr_rec.PROGRESS_PAYMENT_LIQ_RATE,
	l_chr_rec.PROGRESS_PAYMENT_RATE,
	l_chr_rec.ALTERNATE_LIQUIDATION_RATE,
	l_chr_rec.PROP_DELIVERY_LOCATION,
	l_chr_rec.PROP_DUE_DATE_TIME,
        l_chr_rec.PROP_DUE_TIME,
	l_chr_rec.PROP_EXPIRE_DATE,
	l_chr_rec.COPIES_REQUIRED,
	l_chr_rec.SIC_CODE,
	l_chr_rec.TECH_DATA_WH_RATE,
	l_chr_rec.CREATED_BY,
	l_chr_rec.CREATION_DATE,
	l_chr_rec.LAST_UPDATED_BY,
	l_chr_rec.LAST_UPDATE_LOGIN,
	l_chr_rec.LAST_UPDATE_DATE,
	l_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG,
	l_chr_rec.DEFINITIZED_FLAG,
	l_chr_rec.COST_OF_SALE_RATE,
	l_chr_rec.LINE_VALUE_TOTAL,
	l_chr_rec.UNDEF_LINE_VALUE_TOTAL,
--	l_chr_rec.END_DATE,
	l_chr_rec.OWNING_ORGANIZATION_ID,
	l_chr_rec.DEFAULT_TASK_ID;


  x_no_data_found := chr_pk_csr%NOTFOUND;

  close chr_pk_csr;

  IF x_no_data_found = TRUE THEN
    l_temp := 'N';
  END IF;

  RETURN(l_chr_rec);

END get_rec;

FUNCTION get_rec(

  p_chr_rec	IN chr_rec_type)
RETURN chr_rec_type IS

  l_row_notfound	BOOLEAN := TRUE;

BEGIN

  RETURN(get_rec(p_chr_rec, l_row_notfound));

END get_rec;

FUNCTION null_out_defaults(
	    p_chr_rec IN chr_rec_type) RETURN chr_rec_type IS
  x_chr_rec chr_rec_type := p_chr_rec;

BEGIN

    IF x_chr_rec.PROGRAM_ID = OKE_API.G_MISS_NUM THEN
      x_chr_rec.PROGRAM_ID := NULL;
    END IF;

    IF (x_chr_rec.PROJECT_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.PROJECT_ID := NULL;
    END IF;


    IF (x_chr_rec.BOA_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.BOA_ID := NULL;
    END IF;

    IF (x_chr_rec.K_TYPE_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.K_TYPE_CODE := NULL;
    END IF;

    IF (x_chr_rec.PRIORITY_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PRIORITY_CODE := NULL;
    END IF;

    IF (x_chr_rec.PRIME_K_ALIAS = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PRIME_K_ALIAS := NULL;
    END IF;

    IF (x_chr_rec.PRIME_K_NUMBER = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PRIME_K_NUMBER := NULL;
    END IF;

    IF (x_chr_rec.AUTHORIZE_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.AUTHORIZE_DATE := NULL;
    END IF;

    IF (x_chr_rec.AUTHORIZING_REASON = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.AUTHORIZING_REASON := NULL;
    END IF;

    IF (x_chr_rec.AWARD_CANCEL_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.AWARD_CANCEL_DATE := NULL;
    END IF;

    IF (x_chr_rec.AWARD_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.AWARD_DATE := NULL;
    END IF;

    IF (x_chr_rec.DATE_DEFINITIZED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_DEFINITIZED := NULL;
    END IF;

    IF (x_chr_rec.DATE_ISSUED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_ISSUED := NULL;
    END IF;

    IF (x_chr_rec.DATE_NEGOTIATED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_NEGOTIATED := NULL;
    END IF;

    IF (x_chr_rec.DATE_RECEIVED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_RECEIVED := NULL;
    END IF;

    IF (x_chr_rec.DATE_SIGN_BY_CONTRACTOR = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_SIGN_BY_CONTRACTOR := NULL;
    END IF;

    IF (x_chr_rec.FAA_APPROVE_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.FAA_APPROVE_DATE := NULL;
    END IF;

    IF (x_chr_rec.FAA_REJECT_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.FAA_REJECT_DATE := NULL;
    END IF;

    IF (x_chr_rec.BOOKED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.BOOKED_FLAG := NULL;
    END IF;

    IF (x_chr_rec.OPEN_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.OPEN_FLAG := NULL;
    END IF;

    IF (x_chr_rec.CFE_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CFE_FLAG := NULL;
    END IF;

    IF (x_chr_rec.VAT_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.VAT_CODE := NULL;
    END IF;

    IF (x_chr_rec.COUNTRY_OF_ORIGIN_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.COUNTRY_OF_ORIGIN_CODE := NULL;
    END IF;

    IF (x_chr_rec.EXPORT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.EXPORT_FLAG := NULL;
    END IF;

    IF (x_chr_rec.HUMAN_SUBJECT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.HUMAN_SUBJECT_FLAG := NULL;
    END IF;

    IF (x_chr_rec.CQA_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CQA_FLAG := NULL;
    END IF;

    IF (x_chr_rec.INTERIM_RPT_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.INTERIM_RPT_REQ_FLAG := NULL;
    END IF;

    IF (x_chr_rec.NO_COMPETITION_AUTHORIZE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.NO_COMPETITION_AUTHORIZE := NULL;
    END IF;

    IF (x_chr_rec.PENALTY_CLAUSE_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PENALTY_CLAUSE_FLAG := NULL;
    END IF;

    IF (x_chr_rec.PRODUCT_LINE_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PRODUCT_LINE_CODE := NULL;
    END IF;

    IF (x_chr_rec.REPORTING_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.REPORTING_FLAG := NULL;
    END IF;

    IF (x_chr_rec.SB_PLAN_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.SB_PLAN_REQ_FLAG := NULL;
    END IF;

    IF (x_chr_rec.SB_REPORT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.SB_REPORT_FLAG := NULL;
    END IF;

    IF (x_chr_rec.NTE_AMOUNT = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.NTE_AMOUNT := NULL;
    END IF;

    IF (x_chr_rec.NTE_WARNING_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.NTE_WARNING_FLAG := NULL;
    END IF;

    IF (x_chr_rec.BILL_WITHOUT_DEF_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.BILL_WITHOUT_DEF_FLAG := NULL;
    END IF;

    IF (x_chr_rec.CAS_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CAS_FLAG := NULL;
    END IF;

    IF (x_chr_rec.CLASSIFIED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CLASSIFIED_FLAG := NULL;
    END IF;

    IF (x_chr_rec.CLIENT_APPROVE_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CLIENT_APPROVE_REQ_FLAG := NULL;
    END IF;

    IF (x_chr_rec.COST_OF_MONEY = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.COST_OF_MONEY := NULL;
    END IF;

    IF (x_chr_rec.DCAA_AUDIT_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.DCAA_AUDIT_REQ_FLAG := NULL;
    END IF;

    IF (x_chr_rec.COST_SHARE_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.COST_SHARE_FLAG := NULL;
    END IF;

    IF (x_chr_rec.OH_RATES_FINAL_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.OH_RATES_FINAL_FLAG := NULL;
    END IF;

    IF (x_chr_rec.PROGRESS_PAYMENT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PROGRESS_PAYMENT_FLAG := NULL;
    END IF;

    IF (x_chr_rec.PROGRESS_PAYMENT_LIQ_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.PROGRESS_PAYMENT_LIQ_RATE := NULL;
    END IF;

    IF (x_chr_rec.PROGRESS_PAYMENT_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.PROGRESS_PAYMENT_RATE := NULL;
    END IF;

    IF (x_chr_rec.ALTERNATE_LIQUIDATION_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.ALTERNATE_LIQUIDATION_RATE := NULL;
    END IF;

    IF (x_chr_rec.PROP_DELIVERY_LOCATION = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PROP_DELIVERY_LOCATION := NULL;
    END IF;

    IF (x_chr_rec.PROP_DUE_DATE_TIME = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.PROP_DUE_DATE_TIME := NULL;
    END IF;

    IF (x_chr_rec.PROP_DUE_TIME = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PROP_DUE_TIME := NULL;
    END IF;

    IF (x_chr_rec.PROP_EXPIRE_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.PROP_EXPIRE_DATE := NULL;
    END IF;

    IF (x_chr_rec.COPIES_REQUIRED = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.COPIES_REQUIRED := NULL;
    END IF;

    IF (x_chr_rec.SIC_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.SIC_CODE := NULL;
    END IF;

    IF (x_chr_rec.TECH_DATA_WH_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.TECH_DATA_WH_RATE := NULL;
    END IF;


    IF (x_chr_rec.CREATED_BY = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.CREATED_BY := NULL;
    END IF;

    IF (x_chr_rec.CREATION_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.CREATION_DATE := NULL;
    END IF;

    IF (x_chr_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF (x_chr_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    IF (x_chr_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF (x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG := NULL;
    END IF;

    IF (x_chr_rec.DEFINITIZED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.DEFINITIZED_FLAG := NULL;
    END IF;

    IF (x_chr_rec.COST_OF_SALE_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.COST_OF_SALE_RATE := NULL;
    END IF;

    IF (x_chr_rec.LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.LINE_VALUE_TOTAL := NULL;
    END IF;

    IF (x_chr_rec.UNDEF_LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.UNDEF_LINE_VALUE_TOTAL := NULL;
    END IF;

--    IF (x_chr_rec.END_DATE = OKE_API.G_MISS_DATE) THEN
--      x_chr_rec.END_DATE := NULL;
--    END IF;

    IF (x_chr_rec.OWNING_ORGANIZATION_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.OWNING_ORGANIZATION_ID := NULL;
    END IF;

    IF (x_chr_rec.DEFAULT_TASK_ID = OKE_API.G_MISS_NUM) THEN
	x_chr_rec.DEFAULT_TASK_ID := NULL;
    END IF;

  RETURN(x_chr_rec);

END null_out_defaults;



FUNCTION validate_attributes(
	p_chr_rec IN chr_rec_type)
RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

BEGIN

  validate_program_id (x_return_status => l_return_status,
			      p_chr_rec	      =>  p_chr_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_boa_id (x_return_status => l_return_status,
			      p_chr_rec	      =>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_project_id (x_return_status => l_return_status,
			      p_chr_rec	      =>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_k_type_code(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_priority_code(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_product_code(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_country_code(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_vat_code(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;




  validate_prime_k_alias(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;



  validate_prime_k_number(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_authorizing_reason(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_award_cancel_date(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_date_definitized(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_date_received(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;

  END IF;

  validate_booked_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;

  END IF;

  validate_open_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;

  END IF;

  validate_cfe_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_export_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_human_subject_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_cqa_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_interim_rpt_req_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_penalty_clause_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_reporting_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_sb_plan_req_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_sb_report_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_nte_warning_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_bill_without_def_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_cas_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_classified_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_client_approve_req(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_dcaa_audit_req_flag(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_client_approve_req(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_OH_RATES_FINAL_FLAG(x_return_status => l_return_status,
				p_chr_rec	=>  p_chr_rec);

  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  RETURN(x_return_status);

END validate_attributes;

FUNCTION validate_record(
     p_chr_rec IN chr_rec_type) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

BEGIN
  RETURN(l_return_status);

END validate_record;

-- Insert row into OKE_K_HEADERS

PROCEDURE insert_row(
  p_api_version 	IN NUMBER,
  p_init_msg_list	IN 	VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_chr_rec		IN	chr_rec_type,
  x_chr_rec		OUT	NOCOPY chr_rec_type)IS

  l_api_version		CONSTANT NUMBER :=1;
  l_api_name		CONSTANT VARCHAR2(30) := 'B_insert_row';
  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_chr_rec		chr_rec_type := p_chr_rec;
  l_def_chr_rec		chr_rec_type;

  l_k_number_disp       VARCHAR2(120);

  FUNCTION fill_who_column(
    		p_chr_rec IN chr_rec_type) RETURN chr_rec_type IS

    l_chr_rec chr_rec_type := p_chr_rec;

  BEGIN

    l_chr_rec.CREATED_BY := FND_GLOBAL.USER_ID;
    l_chr_rec.CREATION_DATE := SYSDATE;
    l_chr_rec.LAST_UPDATE_DATE := SYSDATE;
    l_chr_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    l_chr_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

    RETURN(l_chr_rec);

  END fill_who_column;

--Set Attributes for OKE_K_HEADERS

  FUNCTION set_attributes(
    p_chr_rec IN chr_rec_type,
    x_chr_rec OUT NOCOPY chr_rec_type) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    x_chr_rec := p_chr_rec;



    x_chr_rec.BOOKED_FLAG := UPPER(x_chr_rec.BOOKED_FLAG);
    x_chr_rec.OPEN_FLAG := UPPER(x_chr_rec.OPEN_FLAG);
    x_chr_rec.CFE_FLAG := UPPER(x_chr_rec.CFE_FLAG);
    x_chr_rec.EXPORT_FLAG := UPPER(x_chr_rec.EXPORT_FLAG);
    x_chr_rec.HUMAN_SUBJECT_FLAG := UPPER(x_chr_rec.HUMAN_SUBJECT_FLAG);
    x_chr_rec.CQA_FLAG := UPPER(x_chr_rec.CQA_FLAG);
    x_chr_rec.INTERIM_RPT_REQ_FLAG := UPPER(x_chr_rec.INTERIM_RPT_REQ_FLAG);
    x_chr_rec.PENALTY_CLAUSE_FLAG := UPPER(x_chr_rec.PENALTY_CLAUSE_FLAG);
    x_chr_rec.REPORTING_FLAG := UPPER(x_chr_rec.REPORTING_FLAG);
    x_chr_rec.NTE_WARNING_FLAG := UPPER(x_chr_rec.NTE_WARNING_FLAG);
    x_chr_rec.BILL_WITHOUT_DEF_FLAG := UPPER(x_chr_rec.BILL_WITHOUT_DEF_FLAG);
    x_chr_rec.CAS_FLAG := UPPER(x_chr_rec.CAS_FLAG);
    x_chr_rec.CLASSIFIED_FLAG := UPPER(x_chr_rec.CLASSIFIED_FLAG);
    x_chr_rec.CLIENT_APPROVE_REQ_FLAG := UPPER(x_chr_rec.CLIENT_APPROVE_REQ_FLAG);
    x_chr_rec.DCAA_AUDIT_REQ_FLAG := UPPER(x_chr_rec.DCAA_AUDIT_REQ_FLAG);
    x_chr_rec.COST_SHARE_FLAG := UPPER(x_chr_rec.COST_SHARE_FLAG);
    x_chr_rec.OH_RATES_FINAL_FLAG := UPPER(x_chr_rec.OH_RATES_FINAL_FLAG);
    x_chr_rec.PROGRESS_PAYMENT_FLAG := UPPER(x_chr_rec.PROGRESS_PAYMENT_FLAG);
    x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG := UPPER(x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG);
    x_chr_rec.DEFINITIZED_FLAG := UPPER(x_chr_rec.DEFINITIZED_FLAG);


    RETURN(l_return_status);

  END set_attributes;

BEGIN

  l_return_status := OKE_API.START_ACTIVITY(
			l_api_name,
			p_init_msg_list,
			'_PVT',
			x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;


  l_chr_rec := null_out_defaults(p_chr_rec);

-- Get primary key
  -- l_chr_rec.K_HEADER_ID := get_id;


  l_return_status := set_attributes(l_chr_rec, l_def_chr_rec);



  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  l_def_chr_rec := fill_who_column(l_def_chr_rec);

-- Validate all non-missing attributes(Item level validation)
  l_return_status := validate_attributes(l_def_chr_rec);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;


  l_return_status := validate_record(l_def_chr_rec);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  l_k_number_disp := K_Number_Disp( l_def_chr_rec.K_HEADER_ID
                                  , l_def_chr_rec.BOA_ID );


  INSERT INTO OKE_K_HEADERS(

  	K_HEADER_ID,
	PROGRAM_ID,
 	PROJECT_ID,
	BOA_ID,
        K_NUMBER_DISP,
        K_TYPE_CODE,
	PRIORITY_CODE,
	PRIME_K_ALIAS,
	PRIME_K_NUMBER,
	AUTHORIZE_DATE,
	AUTHORIZING_REASON,
	AWARD_CANCEL_DATE,
	AWARD_DATE,
	DATE_DEFINITIZED,
	DATE_ISSUED,
	DATE_NEGOTIATED,
	DATE_RECEIVED,
	DATE_SIGN_BY_CONTRACTOR,
	DATE_SIGN_BY_CUSTOMER,
	FAA_APPROVE_DATE,
	FAA_REJECT_DATE,
	BOOKED_FLAG,
	OPEN_FLAG,
	CFE_FLAG,
	VAT_CODE,
	COUNTRY_OF_ORIGIN_CODE,
	EXPORT_FLAG,
	HUMAN_SUBJECT_FLAG,
	CQA_FLAG,
	INTERIM_RPT_REQ_FLAG,
	NO_COMPETITION_AUTHORIZE,
	PENALTY_CLAUSE_FLAG,
	PRODUCT_LINE_CODE,
	REPORTING_FLAG,
	SB_PLAN_REQ_FLAG,
	SB_REPORT_FLAG,
	NTE_AMOUNT,
	NTE_WARNING_FLAG,
	BILL_WITHOUT_DEF_FLAG,
	CAS_FLAG,
	CLASSIFIED_FLAG,
	CLIENT_APPROVE_REQ_FLAG,
	COST_OF_MONEY,
	DCAA_AUDIT_REQ_FLAG,
	COST_SHARE_FLAG,
	OH_RATES_FINAL_FLAG,
	PROGRESS_PAYMENT_FLAG,
	PROGRESS_PAYMENT_LIQ_RATE,
	PROGRESS_PAYMENT_RATE,
	ALTERNATE_LIQUIDATION_RATE,
	PROP_DELIVERY_LOCATION,
	PROP_DUE_DATE_TIME,
	PROP_DUE_TIME,
	PROP_EXPIRE_DATE,
	COPIES_REQUIRED,
	SIC_CODE,
	TECH_DATA_WH_RATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	LAST_UPDATE_DATE,
	FINANCIAL_CTRL_VERIFIED_FLAG,
	DEFINITIZED_FLAG,
	COST_OF_SALE_RATE,
	LINE_VALUE_TOTAL,
	UNDEF_LINE_VALUE_TOTAL,
--	END_DATE,
	OWNING_ORGANIZATION_ID,
	DEFAULT_TASK_ID
	)
  VALUES(
	l_def_chr_rec.K_HEADER_ID,
	l_def_chr_rec.PROGRAM_ID,
 	l_def_chr_rec.PROJECT_ID,
	l_def_chr_rec.BOA_ID,
        l_k_number_disp,
	l_def_chr_rec.K_TYPE_CODE,
	l_def_chr_rec.PRIORITY_CODE,
	l_def_chr_rec.PRIME_K_ALIAS,
	l_def_chr_rec.PRIME_K_NUMBER,
	l_def_chr_rec.AUTHORIZE_DATE,
	l_def_chr_rec.AUTHORIZING_REASON,
	l_def_chr_rec.AWARD_CANCEL_DATE,
	l_def_chr_rec.AWARD_DATE,
	l_def_chr_rec.DATE_DEFINITIZED,
	l_def_chr_rec.DATE_ISSUED,
	l_def_chr_rec.DATE_NEGOTIATED,
	l_def_chr_rec.DATE_RECEIVED,
	l_def_chr_rec.DATE_SIGN_BY_CONTRACTOR,
	l_def_chr_rec.DATE_SIGN_BY_CUSTOMER,
	l_def_chr_rec.FAA_APPROVE_DATE,
	l_def_chr_rec.FAA_REJECT_DATE,
	l_def_chr_rec.BOOKED_FLAG,
	l_def_chr_rec.OPEN_FLAG,
	l_def_chr_rec.CFE_FLAG,
	l_def_chr_rec.VAT_CODE,
	l_def_chr_rec.COUNTRY_OF_ORIGIN_CODE,
	l_def_chr_rec.EXPORT_FLAG,
	l_def_chr_rec.HUMAN_SUBJECT_FLAG,
	l_def_chr_rec.CQA_FLAG,
	l_def_chr_rec.INTERIM_RPT_REQ_FLAG,
	l_def_chr_rec.NO_COMPETITION_AUTHORIZE,
	l_def_chr_rec.PENALTY_CLAUSE_FLAG,
	l_def_chr_rec.PRODUCT_LINE_CODE,
	l_def_chr_rec.REPORTING_FLAG,
	l_def_chr_rec.SB_PLAN_REQ_FLAG,
	l_def_chr_rec.SB_REPORT_FLAG,
	l_def_chr_rec.NTE_AMOUNT,
	l_def_chr_rec.NTE_WARNING_FLAG,
	l_def_chr_rec.BILL_WITHOUT_DEF_FLAG,
	l_def_chr_rec.CAS_FLAG,
	l_def_chr_rec.CLASSIFIED_FLAG,
	l_def_chr_rec.CLIENT_APPROVE_REQ_FLAG,
	l_def_chr_rec.COST_OF_MONEY,
	l_def_chr_rec.DCAA_AUDIT_REQ_FLAG,
	l_def_chr_rec.COST_SHARE_FLAG,
	l_def_chr_rec.OH_RATES_FINAL_FLAG,
	l_def_chr_rec.PROGRESS_PAYMENT_FLAG,
	l_def_chr_rec.PROGRESS_PAYMENT_LIQ_RATE,
	l_def_chr_rec.PROGRESS_PAYMENT_RATE,
	l_def_chr_rec.ALTERNATE_LIQUIDATION_RATE,
	l_def_chr_rec.PROP_DELIVERY_LOCATION,
	l_def_chr_rec.PROP_DUE_DATE_TIME,
	l_def_chr_rec.PROP_DUE_TIME,
	l_def_chr_rec.PROP_EXPIRE_DATE,
	l_def_chr_rec.COPIES_REQUIRED,
	l_def_chr_rec.SIC_CODE,
	l_def_chr_rec.TECH_DATA_WH_RATE,
	l_def_chr_rec.CREATED_BY,
	l_def_chr_rec.CREATION_DATE,
	l_def_chr_rec.LAST_UPDATED_BY,
	l_def_chr_rec.LAST_UPDATE_LOGIN,
	l_def_chr_rec.LAST_UPDATE_DATE,
	l_def_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG,
	l_def_chr_rec.DEFINITIZED_FLAG,
	l_def_chr_rec.COST_OF_SALE_RATE,
	l_def_chr_rec.LINE_VALUE_TOTAL,
	l_def_chr_rec.UNDEF_LINE_VALUE_TOTAL,
--	l_def_chr_rec.END_DATE,
	l_def_chr_rec.OWNING_ORGANIZATION_ID,
	l_def_chr_rec.DEFAULT_TASK_ID);

-- Set OUT values

  x_chr_rec := l_def_chr_rec;


  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END insert_row;



PROCEDURE insert_row(
  p_api_version 	IN NUMBER,
  p_init_msg_list	IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT NOCOPY VARCHAR2,
  x_msg_count		OUT NOCOPY NUMBER,
  x_msg_data		OUT NOCOPY VARCHAR2,
  p_chr_tbl		IN chr_tbl_type,
  x_chr_tbl		OUT NOCOPY chr_tbl_type) IS

  l_api_version 	CONSTANT NUMBER := 1;
  l_api_name 		CONSTANT VARCHAR2(30) := 'TBL_insert_row';

  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_overall_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  i 			NUMBER := 0;
  l_chr_rec		chr_rec_type;

BEGIN

  OKE_API.init_msg_list(p_init_msg_list);

  IF (p_chr_tbl.COUNT > 0) THEN
    i := p_chr_tbl.FIRST;
    LOOP
      x_return_status := OKE_API.G_RET_STS_SUCCESS;
      l_chr_rec := p_chr_tbl(i);

      insert_row(
	p_api_version	=>p_api_version,
        p_init_msg_list	=>p_init_msg_list,
     	x_return_status	=>x_return_status,
 	x_msg_count	=>x_msg_count,
	x_msg_data	=>x_msg_data,
	p_chr_rec	=>l_chr_rec,
	x_chr_rec	=>x_chr_tbl(i));

    IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
	l_overall_status := x_return_status;
      END IF;
    END IF;

    EXIT WHEN (i = p_chr_tbl.LAST);
    i := p_chr_tbl.NEXT(i);

    END LOOP;

    x_return_status := l_overall_status;

  END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END insert_row;

PROCEDURE update_row(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN 	VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_chr_rec		IN	chr_rec_type,
  x_chr_rec		OUT	NOCOPY chr_rec_type)IS

  l_api_version 	CONSTANT NUMBER := 1;
  l_api_name 		CONSTANT VARCHAR2(30) := 'B_update_row';

  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_chr_rec		chr_rec_type;

  l_def_chr_rec		chr_rec_type;
  l_row_nofound		BOOLEAN := TRUE;

  l_k_number_disp       VARCHAR2(120);
  l_k_number_disp_old   VARCHAR2(120);

  FUNCTION get_k_number_disp(P_HEADER_ID IN NUMBER) RETURN VARCHAR2 IS
  l_k_number VARCHAR2(120);
  BEGIN
  select k_number_disp into l_k_number
  from oke_k_headers
  where k_header_id=P_HEADER_ID;

  return l_k_number;
  exception
  when others then
   null;
  END get_k_number_disp;

  FUNCTION populate_new_record(
    p_chr_rec	IN chr_rec_type,
    x_chr_rec	OUT NOCOPY chr_rec_type) RETURN VARCHAR2 IS

    l_chr_rec chr_rec_type;
    l_row_notfound BOOLEAN := TRUE;

    l_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    x_chr_rec := p_chr_rec;
--  Get current database value
    l_chr_rec := get_rec(p_chr_rec, l_row_notfound);

    IF (l_row_notfound) THEN
      l_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    IF (x_chr_rec.K_HEADER_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.K_HEADER_ID := l_chr_rec.K_HEADER_ID;
    END IF;

    IF (x_chr_rec.PROGRAM_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.PROGRAM_ID := l_chr_rec.PROGRAM_ID;
    END IF;

    IF (x_chr_rec.PROJECT_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.PROJECT_ID := l_chr_rec.PROJECT_ID;
    END IF;


    IF (x_chr_rec.BOA_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.BOA_ID := l_chr_rec.BOA_ID;
    END IF;

    IF (x_chr_rec.K_TYPE_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.K_TYPE_CODE := l_chr_rec.K_TYPE_CODE;
    END IF;

    IF (x_chr_rec.PRIORITY_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PRIORITY_CODE := l_chr_rec.PRIORITY_CODE;
    END IF;

    IF (x_chr_rec.PRIME_K_ALIAS = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PRIME_K_ALIAS := l_chr_rec.PRIME_K_ALIAS;
    END IF;

    IF (x_chr_rec.AUTHORIZE_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.AUTHORIZE_DATE := l_chr_rec.AUTHORIZE_DATE;
    END IF;

    IF (x_chr_rec.AUTHORIZING_REASON = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.AUTHORIZING_REASON := l_chr_rec.AUTHORIZING_REASON;
    END IF;

    IF (x_chr_rec.AWARD_CANCEL_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.AWARD_CANCEL_DATE := l_chr_rec.AWARD_CANCEL_DATE;
    END IF;

    IF (x_chr_rec.AWARD_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.AWARD_DATE := l_chr_rec.AWARD_DATE;
    END IF;

    IF (x_chr_rec.DATE_DEFINITIZED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_DEFINITIZED := l_chr_rec.DATE_DEFINITIZED ;
    END IF;

    IF (x_chr_rec.DATE_ISSUED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_ISSUED := l_chr_rec.DATE_ISSUED;
    END IF;

    IF (x_chr_rec.DATE_NEGOTIATED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_NEGOTIATED := l_chr_rec.DATE_NEGOTIATED;
    END IF;

    IF (x_chr_rec.DATE_RECEIVED = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_RECEIVED := l_chr_rec.DATE_RECEIVED;
    END IF;

    IF (x_chr_rec.DATE_SIGN_BY_CONTRACTOR = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.DATE_SIGN_BY_CONTRACTOR := l_chr_rec.DATE_SIGN_BY_CONTRACTOR ;
    END IF;

    IF (x_chr_rec.FAA_APPROVE_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.FAA_APPROVE_DATE := l_chr_rec.FAA_APPROVE_DATE;
    END IF;

    IF (x_chr_rec.FAA_REJECT_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.FAA_REJECT_DATE := l_chr_rec.FAA_REJECT_DATE ;
    END IF;

    IF (x_chr_rec.BOOKED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.BOOKED_FLAG := l_chr_rec.BOOKED_FLAG ;
    END IF;

    IF (x_chr_rec.OPEN_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.OPEN_FLAG := l_chr_rec.OPEN_FLAG ;
    END IF;

    IF (x_chr_rec.CFE_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CFE_FLAG := l_chr_rec.CFE_FLAG ;
    END IF;

    IF (x_chr_rec.VAT_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.VAT_CODE := l_chr_rec.VAT_CODE;
    END IF;

    IF (x_chr_rec.COUNTRY_OF_ORIGIN_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.COUNTRY_OF_ORIGIN_CODE := l_chr_rec.COUNTRY_OF_ORIGIN_CODE ;
    END IF;

    IF (x_chr_rec.EXPORT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.EXPORT_FLAG := l_chr_rec.EXPORT_FLAG;
    END IF;

    IF (x_chr_rec.HUMAN_SUBJECT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.HUMAN_SUBJECT_FLAG := l_chr_rec.HUMAN_SUBJECT_FLAG;
    END IF;

    IF (x_chr_rec.CQA_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CQA_FLAG := l_chr_rec.CQA_FLAG;
    END IF;

    IF (x_chr_rec.INTERIM_RPT_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.INTERIM_RPT_REQ_FLAG := l_chr_rec.INTERIM_RPT_REQ_FLAG ;
    END IF;

    IF (x_chr_rec.NO_COMPETITION_AUTHORIZE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.NO_COMPETITION_AUTHORIZE := l_chr_rec.NO_COMPETITION_AUTHORIZE ;
    END IF;

    IF (x_chr_rec.PENALTY_CLAUSE_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PENALTY_CLAUSE_FLAG := l_chr_rec.PENALTY_CLAUSE_FLAG;
    END IF;

    IF (x_chr_rec.PRODUCT_LINE_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PRODUCT_LINE_CODE := l_chr_rec.PRODUCT_LINE_CODE ;
    END IF;

    IF (x_chr_rec.REPORTING_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.REPORTING_FLAG := l_chr_rec.REPORTING_FLAG;
    END IF;

    IF (x_chr_rec.SB_PLAN_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.SB_PLAN_REQ_FLAG := l_chr_rec.SB_PLAN_REQ_FLAG;
    END IF;

    IF (x_chr_rec.SB_REPORT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.SB_REPORT_FLAG := l_chr_rec.SB_REPORT_FLAG;
    END IF;

    IF (x_chr_rec.NTE_AMOUNT = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.NTE_AMOUNT := l_chr_rec.NTE_AMOUNT;
    END IF;

    IF (x_chr_rec.NTE_WARNING_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.NTE_WARNING_FLAG := l_chr_rec.NTE_WARNING_FLAG;
    END IF;

    IF (x_chr_rec.BILL_WITHOUT_DEF_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.BILL_WITHOUT_DEF_FLAG := l_chr_rec.BILL_WITHOUT_DEF_FLAG;
    END IF;

    IF (x_chr_rec.CAS_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CAS_FLAG := l_chr_rec.CAS_FLAG;
    END IF;


    IF (x_chr_rec.CLASSIFIED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CLASSIFIED_FLAG := l_chr_rec.CLASSIFIED_FLAG;
    END IF;

    IF (x_chr_rec.CLIENT_APPROVE_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.CLIENT_APPROVE_REQ_FLAG := l_chr_rec.CLIENT_APPROVE_REQ_FLAG;
    END IF;

    IF (x_chr_rec.COST_OF_MONEY = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.COST_OF_MONEY := l_chr_rec.COST_OF_MONEY;
    END IF;

    IF (x_chr_rec.DCAA_AUDIT_REQ_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.DCAA_AUDIT_REQ_FLAG := l_chr_rec.DCAA_AUDIT_REQ_FLAG;
    END IF;

    IF (x_chr_rec.COST_SHARE_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.COST_SHARE_FLAG := l_chr_rec.COST_SHARE_FLAG;
    END IF;

    IF (x_chr_rec.OH_RATES_FINAL_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.OH_RATES_FINAL_FLAG := l_chr_rec.OH_RATES_FINAL_FLAG;
    END IF;

    IF (x_chr_rec.PROGRESS_PAYMENT_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PROGRESS_PAYMENT_FLAG := l_chr_rec.PROGRESS_PAYMENT_FLAG;
    END IF;

    IF (x_chr_rec.PROGRESS_PAYMENT_LIQ_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.PROGRESS_PAYMENT_LIQ_RATE := l_chr_rec.PROGRESS_PAYMENT_LIQ_RATE;
    END IF;

    IF (x_chr_rec.PROGRESS_PAYMENT_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.PROGRESS_PAYMENT_RATE := l_chr_rec.PROGRESS_PAYMENT_RATE;
    END IF;

    IF (x_chr_rec.ALTERNATE_LIQUIDATION_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.ALTERNATE_LIQUIDATION_RATE := l_chr_rec.ALTERNATE_LIQUIDATION_RATE;
    END IF;

    IF (x_chr_rec.PROP_DELIVERY_LOCATION = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PROP_DELIVERY_LOCATION := l_chr_rec.PROP_DELIVERY_LOCATION;
    END IF;

    IF (x_chr_rec.PROP_DUE_DATE_TIME = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.PROP_DUE_DATE_TIME := l_chr_rec.PROP_DUE_DATE_TIME;
    END IF;

    IF (x_chr_rec.PROP_DUE_TIME = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.PROP_DUE_TIME := l_chr_rec.PROP_DUE_TIME;
    END IF;


    IF (x_chr_rec.PROP_EXPIRE_DATE = OKE_API.G_MISS_DATE) THEN
      x_chr_rec.PROP_EXPIRE_DATE := l_chr_rec.PROP_EXPIRE_DATE;
    END IF;

    IF (x_chr_rec.COPIES_REQUIRED = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.COPIES_REQUIRED := l_chr_rec.COPIES_REQUIRED;
    END IF;

    IF (x_chr_rec.SIC_CODE = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.SIC_CODE := l_chr_rec.SIC_CODE;
    END IF;

    IF (x_chr_rec.TECH_DATA_WH_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.TECH_DATA_WH_RATE := l_chr_rec.TECH_DATA_WH_RATE;
    END IF;

    IF (x_chr_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.LAST_UPDATE_LOGIN := l_chr_rec.LAST_UPDATE_LOGIN;
    END IF;

    IF (x_chr_rec.COST_OF_SALE_RATE = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.COST_OF_SALE_RATE := l_chr_rec.COST_OF_SALE_RATE;
    END IF;

    IF (x_chr_rec.LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.LINE_VALUE_TOTAL := l_chr_rec.LINE_VALUE_TOTAL;
    END IF;

    IF (x_chr_rec.UNDEF_LINE_VALUE_TOTAL = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.UNDEF_LINE_VALUE_TOTAL := l_chr_rec.UNDEF_LINE_VALUE_TOTAL;
    END IF;

--    IF (x_chr_rec.END_DATE = OKE_API.G_MISS_DATE) THEN
--      x_chr_rec.END_DATE := l_chr_rec.END_DATE;
--    END IF;

    IF (x_chr_rec.OWNING_ORGANIZATION_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.OWNING_ORGANIZATION_ID := l_chr_rec.OWNING_ORGANIZATION_ID;
    END IF;

    IF (x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG := l_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG;
    END IF;

    IF (x_chr_rec.DEFINITIZED_FLAG = OKE_API.G_MISS_CHAR) THEN
      x_chr_rec.DEFINITIZED_FLAG := l_chr_rec.DEFINITIZED_FLAG;
    END IF;

    IF (x_chr_rec.DEFAULT_TASK_ID = OKE_API.G_MISS_NUM) THEN
      x_chr_rec.DEFAULT_TASK_ID := l_chr_rec.DEFAULT_TASK_ID;
    END IF;

  RETURN(l_return_status);
  END populate_new_record;

  FUNCTION fill_who_column(
  		p_chr_rec IN chr_rec_type) RETURN chr_rec_type IS
    l_chr_rec chr_rec_type := p_chr_rec;
  BEGIN

    l_chr_rec.LAST_UPDATE_DATE := SYSDATE;
    l_chr_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    l_chr_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

    RETURN(l_chr_rec);

  END fill_who_column;


  FUNCTION set_attributes(

    p_chr_rec IN chr_rec_type,
    x_chr_rec OUT NOCOPY chr_rec_type) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

  BEGIN

    x_chr_rec := p_chr_rec;

    x_chr_rec.BOOKED_FLAG := UPPER(x_chr_rec.BOOKED_FLAG);
    x_chr_rec.OPEN_FLAG := UPPER(x_chr_rec.OPEN_FLAG);
    x_chr_rec.CFE_FLAG := UPPER(x_chr_rec.CFE_FLAG);
    x_chr_rec.EXPORT_FLAG := UPPER(x_chr_rec.EXPORT_FLAG);
    x_chr_rec.HUMAN_SUBJECT_FLAG := UPPER(x_chr_rec.HUMAN_SUBJECT_FLAG);
    x_chr_rec.CQA_FLAG := UPPER(x_chr_rec.CQA_FLAG);
    x_chr_rec.INTERIM_RPT_REQ_FLAG := UPPER(x_chr_rec.INTERIM_RPT_REQ_FLAG);
    x_chr_rec.PENALTY_CLAUSE_FLAG := UPPER(x_chr_rec.PENALTY_CLAUSE_FLAG);
    x_chr_rec.REPORTING_FLAG := UPPER(x_chr_rec.REPORTING_FLAG);
    x_chr_rec.NTE_WARNING_FLAG := UPPER(x_chr_rec.NTE_WARNING_FLAG);
    x_chr_rec.BILL_WITHOUT_DEF_FLAG := UPPER(x_chr_rec.BILL_WITHOUT_DEF_FLAG);
    x_chr_rec.CAS_FLAG := UPPER(x_chr_rec.CAS_FLAG);
    x_chr_rec.CLASSIFIED_FLAG := UPPER(x_chr_rec.CLASSIFIED_FLAG);
    x_chr_rec.CLIENT_APPROVE_REQ_FLAG := UPPER(x_chr_rec.CLIENT_APPROVE_REQ_FLAG);
    x_chr_rec.DCAA_AUDIT_REQ_FLAG := UPPER(x_chr_rec.DCAA_AUDIT_REQ_FLAG);
    x_chr_rec.COST_SHARE_FLAG := UPPER(x_chr_rec.COST_SHARE_FLAG);
    x_chr_rec.OH_RATES_FINAL_FLAG := UPPER(x_chr_rec.OH_RATES_FINAL_FLAG);
    x_chr_rec.PROGRESS_PAYMENT_FLAG := UPPER(x_chr_rec.PROGRESS_PAYMENT_FLAG);
    x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG := UPPER(x_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG);
    x_chr_rec.DEFINITIZED_FLAG := UPPER(x_chr_rec.DEFINITIZED_FLAG);

    RETURN(l_return_status);

  END set_attributes;

BEGIN

  l_return_status := OKE_API.START_ACTIVITY(
			l_api_name,
			p_init_msg_list,
			'_PVT',
			x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  l_return_status := set_attributes(
			p_chr_rec,
			l_chr_rec);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;


  l_return_status := populate_new_record(
			l_chr_rec,
			l_def_chr_rec);


  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;


  l_def_chr_rec := fill_who_column(l_def_chr_rec);

-- Validate all non_missing attributes (Item level validation)

  l_return_status := validate_attributes(l_def_chr_rec);


  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

   END IF;

  l_return_status := validate_record(l_def_chr_rec);


  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  l_k_number_disp_old := get_k_number_disp( l_def_chr_rec.K_HEADER_ID);
  l_k_number_disp := K_Number_Disp( l_def_chr_rec.K_HEADER_ID
                                  , l_def_chr_rec.BOA_ID );

  UPDATE OKE_K_HEADERS
  SET	PROGRAM_ID		= l_def_chr_rec.PROGRAM_ID,
 	PROJECT_ID		= l_def_chr_rec.PROJECT_ID,
	BOA_ID			= l_def_chr_rec.BOA_ID,
        K_NUMBER_DISP           = l_k_number_disp,
	K_TYPE_CODE		= l_def_chr_rec.K_TYPE_CODE,
	PRIORITY_CODE		= l_def_chr_rec.PRIORITY_CODE,
	PRIME_K_ALIAS		= l_def_chr_rec.PRIME_K_ALIAS,
	PRIME_K_NUMBER		= l_def_chr_rec.PRIME_K_NUMBER,
	AUTHORIZE_DATE		= l_def_chr_rec.AUTHORIZE_DATE,
	AUTHORIZING_REASON	= l_def_chr_rec.AUTHORIZING_REASON,
	AWARD_CANCEL_DATE	= l_def_chr_rec.AWARD_CANCEL_DATE,
	AWARD_DATE		= l_def_chr_rec.AWARD_DATE,
	DATE_DEFINITIZED	= l_def_chr_rec.DATE_DEFINITIZED,
	DATE_ISSUED		= l_def_chr_rec.DATE_ISSUED,
	DATE_NEGOTIATED		= l_def_chr_rec.DATE_NEGOTIATED,
	DATE_RECEIVED		= l_def_chr_rec.DATE_RECEIVED,
	DATE_SIGN_BY_CONTRACTOR	= l_def_chr_rec.DATE_SIGN_BY_CONTRACTOR,
	DATE_SIGN_BY_CUSTOMER	= l_def_chr_rec.DATE_SIGN_BY_CUSTOMER,
	FAA_APPROVE_DATE	= l_def_chr_rec.FAA_APPROVE_DATE,
	FAA_REJECT_DATE		= l_def_chr_rec.FAA_REJECT_DATE,
	BOOKED_FLAG		= l_def_chr_rec.BOOKED_FLAG,
	OPEN_FLAG		= l_def_chr_rec.OPEN_FLAG,
	CFE_FLAG		= l_def_chr_rec.CFE_FLAG,
	VAT_CODE		= l_def_chr_rec.VAT_CODE,
	COUNTRY_OF_ORIGIN_CODE	= l_def_chr_rec.COUNTRY_OF_ORIGIN_CODE,
	EXPORT_FLAG		= l_def_chr_rec.EXPORT_FLAG,
	HUMAN_SUBJECT_FLAG	= l_def_chr_rec.HUMAN_SUBJECT_FLAG,
	CQA_FLAG		= l_def_chr_rec.CQA_FLAG,
	INTERIM_RPT_REQ_FLAG	= l_def_chr_rec.INTERIM_RPT_REQ_FLAG,
	NO_COMPETITION_AUTHORIZE = l_def_chr_rec.NO_COMPETITION_AUTHORIZE,
	PENALTY_CLAUSE_FLAG	= l_def_chr_rec.PENALTY_CLAUSE_FLAG,
	PRODUCT_LINE_CODE	= l_def_chr_rec.PRODUCT_LINE_CODE,
	REPORTING_FLAG		= l_def_chr_rec.REPORTING_FLAG,
	SB_PLAN_REQ_FLAG	= l_def_chr_rec.SB_PLAN_REQ_FLAG,
	SB_REPORT_FLAG		= l_def_chr_rec.SB_REPORT_FLAG,
	NTE_AMOUNT		= l_def_chr_rec.NTE_AMOUNT,
	NTE_WARNING_FLAG	= l_def_chr_rec.NTE_WARNING_FLAG,
	BILL_WITHOUT_DEF_FLAG	= l_def_chr_rec.BILL_WITHOUT_DEF_FLAG,
	CAS_FLAG		= l_def_chr_rec.CAS_FLAG,
	CLASSIFIED_FLAG		= l_def_chr_rec.CLASSIFIED_FLAG,
	CLIENT_APPROVE_REQ_FLAG	= l_def_chr_rec.CLIENT_APPROVE_REQ_FLAG,
	COST_OF_MONEY		= l_def_chr_rec.COST_OF_MONEY,
	DCAA_AUDIT_REQ_FLAG	= l_def_chr_rec.DCAA_AUDIT_REQ_FLAG,
	COST_SHARE_FLAG		= l_def_chr_rec.COST_SHARE_FLAG,
	OH_RATES_FINAL_FLAG	= l_def_chr_rec.OH_RATES_FINAL_FLAG,
        PROGRESS_PAYMENT_FLAG   = l_def_chr_rec.PROGRESS_PAYMENT_FLAG,
	PROGRESS_PAYMENT_LIQ_RATE = l_def_chr_rec.PROGRESS_PAYMENT_LIQ_RATE,
        PROGRESS_PAYMENT_RATE   = l_def_chr_rec.PROGRESS_PAYMENT_RATE,
	ALTERNATE_LIQUIDATION_RATE = l_def_chr_rec.ALTERNATE_LIQUIDATION_RATE,
	PROP_DELIVERY_LOCATION	= l_def_chr_rec.PROP_DELIVERY_LOCATION,
	PROP_DUE_DATE_TIME		= l_def_chr_rec.PROP_DUE_DATE_TIME,
	PROP_DUE_TIME		= l_def_chr_rec.PROP_DUE_TIME,
	PROP_EXPIRE_DATE		= l_def_chr_rec.PROP_EXPIRE_DATE,
	COPIES_REQUIRED	= l_def_chr_rec.COPIES_REQUIRED,
	SIC_CODE		= l_def_chr_rec.SIC_CODE,
	TECH_DATA_WH_RATE	= l_def_chr_rec.TECH_DATA_WH_RATE,
	FINANCIAL_CTRL_VERIFIED_FLAG = l_def_chr_rec.FINANCIAL_CTRL_VERIFIED_FLAG,
	DEFINITIZED_FLAG		= l_def_chr_rec.DEFINITIZED_FLAG,
	COST_OF_SALE_RATE	= l_def_chr_rec.COST_OF_SALE_RATE,
	LINE_VALUE_TOTAL	= l_def_chr_rec.LINE_VALUE_TOTAL,
	UNDEF_LINE_VALUE_TOTAL  = l_def_chr_rec.UNDEF_LINE_VALUE_TOTAL,
--	END_DATE		= l_def_chr_rec.END_DATE,
	OWNING_ORGANIZATION_ID  = l_def_chr_rec.OWNING_ORGANIZATION_ID,
	DEFAULT_TASK_ID		= l_def_chr_rec.DEFAULT_TASK_ID

  WHERE K_HEADER_ID = l_def_chr_rec.K_HEADER_ID;

  x_chr_rec := l_def_chr_rec;

  -- bug 7115155
  IF ( l_k_number_disp<>l_k_number_disp_old
        and
       IS_BOA(x_chr_rec.k_type_code)
     )
  THEN
   update_do(x_chr_rec.k_header_id);
  END IF;


  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END update_row;

PROCEDURE change_version IS
BEGIN
  null;
END;

PROCEDURE api_copy IS
BEGIN
  null;
END;

PROCEDURE update_row(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN 	VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_chr_tbl		IN	chr_tbl_type,
  x_chr_tbl		OUT	NOCOPY chr_tbl_type)IS

  l_api_version 	CONSTANT NUMBER := 1;
  l_api_name 		CONSTANT VARCHAR2(30) := 'TBL_update_row';

  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_overall_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  i 			NUMBER      := 0;

BEGIN
  IF (p_chr_tbl.COUNT > 0) THEN
    i := p_chr_tbl.FIRST;
    LOOP

      update_row(
        p_api_version	=>p_api_version,
        p_init_msg_list =>OKE_API.G_FALSE,
        x_return_status =>x_return_status,
        x_msg_count	=>x_msg_count,
        x_msg_data	=>x_msg_data,
        p_chr_rec	=>p_chr_tbl(i),
        x_chr_rec	=>x_chr_tbl(i));

      IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
	  l_overall_status := x_return_status;
        END IF;
      END IF;

    EXIT WHEN (i = p_chr_tbl.LAST);
    i := p_chr_tbl.NEXT(i);

    END LOOP;

    x_return_status := l_overall_status;

  END IF;

EXCEPTION

    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

 END update_row;

PROCEDURE delete_row(

  p_api_version		IN	NUMBER,
  p_init_msg_list	IN 	VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_chr_rec		IN	chr_rec_type)IS

  l_api_version 	CONSTANT NUMBER := 1;
  l_api_name 		CONSTANT VARCHAR2(30) := 'B_delete_row';

  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_chr_rec		chr_rec_type := p_chr_rec;
  l_row_notfound	BOOLEAN := TRUE;

BEGIN

  l_return_status := OKE_API.START_ACTIVITY(
			l_api_name,
			p_init_msg_list,
			'_PVT',
			x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  DELETE FROM OKE_K_HEADERS
  WHERE K_HEADER_ID = l_chr_rec.K_HEADER_ID;

  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END delete_row;

PROCEDURE delete_row(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN 	VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_chr_tbl		IN	chr_tbl_type)IS

  l_api_version 	CONSTANT NUMBER := 1;
  l_api_name 		CONSTANT VARCHAR2(30) := 'TBL_delete_row';

  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_overall_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  i 			NUMBER      := 0;
  l_dummy_val		NUMBER;
  CURSOR l_csr IS
    SELECT COUNT(1)
    FROM OKE_K_HEADERS
    WHERE OKE_K_HEADERS.K_HEADER_ID = p_chr_tbl(i).K_HEADER_ID;

BEGIN

  OKE_API.init_msg_list(p_init_msg_list);

  IF (p_chr_tbl.COUNT > 0) THEN
    i := p_chr_tbl.FIRST;
    LOOP
      -- Check whether detail record exists
      OPEN l_csr;
      FETCH l_csr INTO l_dummy_val;
      CLOSE l_csr;

      IF (l_dummy_val = 0) THEN

        delete_row(
        p_api_version	=>p_api_version,
        p_init_msg_list =>OKE_API.G_FALSE,
        x_return_status =>x_return_status,
        x_msg_count	=>x_msg_count,
        x_msg_data	=>x_msg_data,
        p_chr_rec	=>p_chr_tbl(i));

        IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
          IF l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
	    l_overall_status := x_return_status;
          END IF;
        END IF;

      ELSE
	OKE_API.SET_MESSAGE(
          p_app_name	=>g_app_name,
          p_msg_name	=>G_CHILD_RECORD_EXISTS);
        x_return_status := OKE_API.G_RET_STS_ERROR;

        IF l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
	  l_overall_status := x_return_status;
        END IF;

      END IF;

    EXIT WHEN(i = p_chr_tbl.LAST);
    i := p_chr_tbl.NEXT(i);

    END LOOP;

    x_return_status := l_overall_status;

  END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END delete_row;

PROCEDURE validate_row(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN 	VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_chr_rec		IN	chr_rec_type)IS

  l_api_version 	CONSTANT NUMBER := 1;
  l_api_name 		CONSTANT VARCHAR2(30) := 'B_validate_row';

  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_chr_rec		chr_rec_type := p_chr_rec;
  l_row_notfound	BOOLEAN := TRUE;

BEGIN

  l_return_status := OKE_API.START_ACTIVITY(l_api_name,
			G_PKG_NAME,
			p_init_msg_list,
			l_api_version,
			p_api_version,
			'_PVT',
			x_return_status);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  l_return_status := validate_attributes(l_chr_rec);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  l_return_status := validate_record(l_chr_rec);

  IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

    RAISE OKE_API.G_EXCEPTION_ERROR;

  END IF;

  OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END validate_row;


PROCEDURE validate_row(
  p_api_version		IN	NUMBER,
  p_init_msg_list	IN 	VARCHAR2 DEFAULT OKE_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_chr_tbl		IN	chr_tbl_type)IS

  l_api_version 	CONSTANT NUMBER := 1;
  l_api_name 		CONSTANT VARCHAR2(30) := 'TBL_validate_row';

  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  l_overall_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  i 			NUMBER      := 0;


BEGIN

  OKE_API.init_msg_list(p_init_msg_list);

  IF (p_chr_tbl.COUNT > 0) THEN
    i := p_chr_tbl.FIRST;
    LOOP
      validate_row(
        p_api_version	=>p_api_version,
        p_init_msg_list =>OKE_API.G_FALSE,
        x_return_status =>x_return_status,
        x_msg_count	=>x_msg_count,
        x_msg_data	=>x_msg_data,
        p_chr_rec	=>p_chr_tbl(i));
      IF x_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
	  l_overall_status := x_return_status;
        END IF;
      END IF;

    EXIT WHEN(i = p_chr_tbl.LAST);
    i := p_chr_tbl.NEXT(i);

    END LOOP;

    x_return_status := l_overall_status;

  END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OKE_API.G_RET_STS_UNEXP_ERROR',
	x_msg_count,
	x_msg_data,
	'_PVT');

    WHEN OTHERS THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
	l_api_name,
	G_PKG_NAME,
	'OTHERS',
	x_msg_count,
	x_msg_data,
	'_PVT');

END validate_row;


END OKE_CHR_PVT;


/
