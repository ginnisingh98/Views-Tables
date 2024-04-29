--------------------------------------------------------
--  DDL for Package Body OKE_PARTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_PARTY_PVT" AS
/* $Header: OKEVFPPB.pls 115.12 2003/10/07 00:48:44 alaw ship $ */


  PROCEDURE validate_currency_code(x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM FND_CURRENCIES
	WHERE CURRENCY_CODE = p_party_rec.CURRENCY_CODE;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_party_rec.currency_code = OKE_API.G_MISS_CHAR
     	OR     p_party_rec.currency_code IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'CURRENCY_CODE');

		x_return_status := OKE_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;


    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'CURRENCY_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'FND_CURRENCIES');

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

    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;

    END validate_currency_code;


  PROCEDURE validate_funding_pool_id (x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_FUNDING_POOLS
	WHERE FUNDING_POOL_ID = p_party_rec.funding_pool_id;

    BEGIN


	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_party_rec.funding_pool_id = OKE_API.G_MISS_NUM
     	OR     p_party_rec.funding_pool_id IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'FUNDING_POOL_ID');

		x_return_status := OKE_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;


    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'FUNDING_POOL_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_FUNDING_POOLS');

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

    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;

    END validate_funding_pool_id;



  PROCEDURE validate_party_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM HZ_PARTIES
	WHERE PARTY_ID = p_party_rec.PARTY_ID
	AND   NVL(STATUS, 'A') = 'A';

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_party_rec.party_id = OKE_API.G_MISS_NUM
     	OR     p_party_rec.party_id IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PARTY_ID');

		x_return_status := OKE_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;


    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PARTY_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'HZ_PARTIES');

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

    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;

    END validate_party_id;


  PROCEDURE validate_initial_amount (x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS
    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_party_rec.initial_amount = OKE_API.G_MISS_NUM
     	OR     p_party_rec.initial_amount  IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'INITIAL_AMOUNT');

		x_return_status := OKE_API.G_RET_STS_ERROR;
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

    END validate_initial_amount;

  PROCEDURE validate_amount (x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS

	l_available	NUMBER;
	l_result	VARCHAR2(1);
    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_party_rec.amount = OKE_API.G_MISS_NUM
     	OR     p_party_rec.amount  IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'AMOUNT');

		x_return_status := OKE_API.G_RET_STS_ERROR;
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

    END validate_amount;

  PROCEDURE validate_available_amount (x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;
	-- check required value - not null

	IF (   p_party_rec.available_amount = OKE_API.G_MISS_NUM
     	OR     p_party_rec.available_amount  IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'AVAILABLE_AMOUNT');

		x_return_status := OKE_API.G_RET_STS_ERROR;
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

    END validate_available_amount;




  PROCEDURE validate_start_date_active (x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS

	l_result	VARCHAR2(1);


    BEGIN


	x_return_status := OKE_API.G_RET_STS_SUCCESS;

	IF  p_party_rec.start_date_active <> OKE_API.G_MISS_DATE
     	AND     p_party_rec.start_date_active  IS NOT NULL THEN

		IF p_party_rec.POOL_PARTY_ID <> OKE_API.G_MISS_NUM
		AND p_party_rec.POOL_PARTY_ID IS NOT NULL THEN
			OKE_FUNDING_UTIL_PKG.validate_pool_party_date(
			x_start_end	=>	'START',
			x_pool_party_id =>	p_party_rec.POOL_PARTY_ID,
			x_date		=>	p_party_rec.start_date_active,
			x_return_status =>	l_result);

			IF(l_result='N') THEN
	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'start_date_active');

			x_return_status := OKE_API.G_RET_STS_ERROR;
			END IF;
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

    END validate_start_date_active;



  PROCEDURE validate_end_date_active (x_return_status OUT NOCOPY VARCHAR2,
			      p_party_rec   IN  party_rec_type)IS

	l_result	VARCHAR2(1);

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	IF    p_party_rec.end_date_active <> OKE_API.G_MISS_DATE
     	AND     p_party_rec.end_date_active  IS NOT NULL THEN

		IF p_party_rec.POOL_PARTY_ID <> OKE_API.G_MISS_NUM
		AND p_party_rec.POOL_PARTY_ID IS NOT NULL THEN

			OKE_FUNDING_UTIL_PKG.validate_pool_party_date(
			x_start_end	=>	'END',
			x_pool_party_id =>	p_party_rec.POOL_PARTY_ID,
			x_date		=>	p_party_rec.end_date_active,
			x_return_status =>	l_result);

			IF(l_result='N') THEN
	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'end_date_active');

			x_return_status := OKE_API.G_RET_STS_ERROR;
			END IF;
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

    END validate_end_date_active;


-- validate record

  FUNCTION validate_record (
    p_party_rec IN party_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_result			   VARCHAR2(1);
    l_parent_currency		   OKE_POOL_PARTIES.CURRENCY_CODE%TYPE;

  CURSOR l_conversion IS
  SELECT CURRENCY_CODE
  FROM OKE_FUNDING_POOLS
  WHERE FUNDING_POOL_ID = p_party_rec.FUNDING_POOL_ID;

  BEGIN



  --  if start and end dates both exist then validate start before end. otherwise skip validation

	IF ((p_party_rec.START_DATE_ACTIVE IS NOT NULL)AND(p_party_rec.START_DATE_ACTIVE <> OKE_API.G_MISS_DATE))
	AND
	   ((p_party_rec.END_DATE_ACTIVE IS NOT NULL)AND(p_party_rec.END_DATE_ACTIVE <> OKE_API.G_MISS_DATE)) THEN
		OKE_FUNDING_UTIL_PKG.validate_start_end_date(p_party_rec.START_DATE_ACTIVE,p_party_rec.END_DATE_ACTIVE,l_result);
			-- if failure then...
		IF(l_result = 'N') THEN

	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'end_date_active');
      	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'start_date_active');


			x_return_status := OKE_API.G_RET_STS_ERROR;
			RETURN(x_return_status);


		END IF;
	END IF;


  -- check if currency the same as in funding pool.
  -- if same, then must conversions must be null
  -- otherwise must be filled.

  -- call validate funding_pool_id first to make sure parent record exist.

	validate_funding_pool_id (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  	IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
      		x_return_status := l_return_status;
		RETURN(x_return_status);
  	END IF;

  -- parent record exists, carry on to find currency_code from parent.
	OPEN l_conversion;
	FETCH l_conversion INTO l_parent_currency;
	CLOSE l_conversion;

  -- call validate_currency_code first to make sure compulsory field is filled.
	validate_currency_code (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  	IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
      		x_return_status := l_return_status;
		RETURN(x_return_status);
  	END IF;

  -- do the checks now.

	IF p_party_rec.CURRENCY_CODE = l_parent_currency THEN
		IF((p_party_rec.CONVERSION_TYPE IS NOT NULL)AND(p_party_rec.CONVERSION_TYPE<>OKE_API.G_MISS_CHAR))
		OR((p_party_rec.CONVERSION_DATE IS NOT NULL)AND(p_party_rec.CONVERSION_DATE<>OKE_API.G_MISS_DATE))
			THEN
	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'conversion_type');
	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'conversion_date');

			x_return_status := OKE_API.G_RET_STS_ERROR;
	--oke_debug.debug('validate record failed on currency compare');
			RETURN(x_return_status);
		END IF;
	ELSE  -- check that they are filled.


		IF((p_party_rec.CONVERSION_TYPE IS NULL)OR(p_party_rec.CONVERSION_TYPE=OKE_API.G_MISS_CHAR))
		OR((p_party_rec.CONVERSION_DATE IS NULL)OR(p_party_rec.CONVERSION_DATE=OKE_API.G_MISS_DATE))
		THEN
	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'conversion_type');
	    		OKE_API.SET_MESSAGE(
	       		p_app_name		=>g_app_name,
	 		p_msg_name		=>g_invalid_value,
			p_token1		=>g_col_name_token,
			p_token1_value		=>'conversion_date');

			x_return_status := OKE_API.G_RET_STS_ERROR;
	--oke_debug.debug('validate record fail on currency compare');
			RETURN(x_return_status);
		END IF;

	END IF;

    RETURN(x_return_status);

  END validate_record;

-- validate individual attributes

  FUNCTION validate_attributes(
    p_party_rec IN  party_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

  BEGIN

  validate_funding_pool_id (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
--IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of funding_pool_id: Success');
--ELSE
--oke_debug.debug('validation of funding_pool_id: Failure');
--END IF;


  validate_party_id (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
--IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of party_id: Success');
--ELSE
--oke_debug.debug('validation of party_id: Failure');
--END IF;


  validate_currency_code (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
--IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of currency_code: Success');
--ELSE
--oke_debug.debug('validation of currency_code: Failure');
--END IF;


  validate_initial_amount (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
--IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of initial_amount: Success');
--ELSE
--oke_debug.debug('validation of initial_amount: Failure');
--END IF;


  validate_amount (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
--IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of amount: Success');
--ELSE
--oke_debug.debug('validation of amount: Failure');
--END IF;



  validate_available_amount (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
--IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of available_amount: Success');
--ELSE
--oke_debug.debug('validation of available_amount: Failure');
--END IF;


  validate_start_date_active (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
 --IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of start_date_active: Success');
--ELSE
--oke_debug.debug('validation of start_date_active: Failure');
--END IF;


  validate_end_date_active (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
--IF l_return_status=OKE_API.G_RET_STS_SUCCESS THEN
--oke_debug.debug('validation of end_date_active: Success');
--ELSE
--oke_debug.debug('validation of end_date_active: Failure');
--END IF;


    /* call individual validation procedure */
	   -- return status to caller
        RETURN(x_return_status);

  END Validate_Attributes;


-- called by insert_row to make unfilled attributes NULL

  FUNCTION null_out_defaults(
	 p_party_rec	IN party_rec_type ) RETURN party_rec_type IS

  l_party_rec party_rec_type := p_party_rec;

  BEGIN

    IF  l_party_rec.POOL_PARTY_ID = OKE_API.G_MISS_NUM THEN
	l_party_rec.POOL_PARTY_ID := NULL;
    END IF;

    IF  l_party_rec.FUNDING_POOL_ID = OKE_API.G_MISS_NUM THEN
	l_party_rec.FUNDING_POOL_ID := NULL;
    END IF;

    IF  l_party_rec.PARTY_ID = OKE_API.G_MISS_NUM THEN
	l_party_rec.PARTY_ID := NULL;
    END IF;

    IF	l_party_rec.CURRENCY_CODE = OKE_API.G_MISS_CHAR THEN
	l_party_rec.CURRENCY_CODE := NULL;
    END IF;

    IF	l_party_rec.CONVERSION_TYPE = OKE_API.G_MISS_CHAR THEN
	l_party_rec.CONVERSION_TYPE := NULL;
    END IF;

   IF	l_party_rec.CONVERSION_DATE = OKE_API.G_MISS_DATE THEN
	l_party_rec.CONVERSION_DATE := NULL;
    END IF;

   IF	l_party_rec.CONVERSION_RATE = OKE_API.G_MISS_NUM THEN
	l_party_rec.CONVERSION_RATE := NULL;
    END IF;

    IF	l_party_rec.INITIAL_AMOUNT = OKE_API.G_MISS_NUM THEN
	l_party_rec.INITIAL_AMOUNT := NULL;
    END IF;

    IF	l_party_rec.AMOUNT = OKE_API.G_MISS_NUM THEN
	l_party_rec.AMOUNT := NULL;
    END IF;

    IF	l_party_rec.AVAILABLE_AMOUNT = OKE_API.G_MISS_NUM THEN
	l_party_rec.AVAILABLE_AMOUNT := NULL;
    END IF;

    IF  l_party_rec.START_DATE_ACTIVE = OKE_API.G_MISS_DATE THEN
	l_party_rec.START_DATE_ACTIVE := NULL;
    END IF;

    IF  l_party_rec.END_DATE_ACTIVE = OKE_API.G_MISS_DATE THEN
	l_party_rec.END_DATE_ACTIVE := NULL;
    END IF;


    IF  l_party_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF  l_party_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	l_party_rec.ATTRIBUTE15 := NULL;
    END IF;

    IF	l_party_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_party_rec.CREATED_BY := NULL;
    END IF;

    IF	l_party_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_party_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_party_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_party_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_party_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_party_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_party_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_party_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    RETURN(l_party_rec);

  END null_out_defaults;


-- gets the record based on a key attribute

  FUNCTION get_rec (
    p_party_rec                      IN party_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN party_rec_type IS

    CURSOR party_pk_csr ( p_party_id NUMBER) IS
    SELECT

 	POOL_PARTY_ID	,
 	FUNDING_POOL_ID,
 	PARTY_ID	,
 	CURRENCY_CODE	,
 	CONVERSION_TYPE,
 	CONVERSION_DATE,
 	CONVERSION_RATE,
 	INITIAL_AMOUNT,
 	AMOUNT		,
 	AVAILABLE_AMOUNT,
 	START_DATE_ACTIVE,
 	END_DATE_ACTIVE,

 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_LOGIN,
 	ATTRIBUTE_CATEGORY,
 	ATTRIBUTE1   ,
 	ATTRIBUTE2   ,
 	ATTRIBUTE3   ,
 	ATTRIBUTE4   ,
 	ATTRIBUTE5   ,
 	ATTRIBUTE6   ,
 	ATTRIBUTE7              ,
 	ATTRIBUTE8              ,
 	ATTRIBUTE9              ,
 	ATTRIBUTE10             ,
 	ATTRIBUTE11             ,
 	ATTRIBUTE12             ,
 	ATTRIBUTE13             ,
 	ATTRIBUTE14             ,
 	ATTRIBUTE15


    FROM OKE_POOL_PARTIES a
    WHERE (a.pool_party_id = p_party_id);

    l_party_pk	party_pk_csr%ROWTYPE;
    l_party_rec   party_rec_type;

  BEGIN
    x_no_data_found := TRUE;

    -- get current database value

    OPEN party_pk_csr(p_party_rec.POOL_PARTY_ID);
    FETCH party_pk_csr INTO

 		l_party_rec.POOL_PARTY_ID	,
 		l_party_rec.FUNDING_POOL_ID,
 		l_party_rec.PARTY_ID	,
 		l_party_rec.CURRENCY_CODE	,
 		l_party_rec.CONVERSION_TYPE,
 		l_party_rec.CONVERSION_DATE,
 		l_party_rec.CONVERSION_RATE,
 		l_party_rec.INITIAL_AMOUNT,
 		l_party_rec.AMOUNT		,
 		l_party_rec.AVAILABLE_AMOUNT,
 		l_party_rec.START_DATE_ACTIVE,
 		l_party_rec.END_DATE_ACTIVE,

		l_party_rec.CREATION_DATE		,
		l_party_rec.CREATED_BY			,
		l_party_rec.LAST_UPDATE_DATE		,
		l_party_rec.LAST_UPDATED_BY		,
		l_party_rec.LAST_UPDATE_LOGIN		,
		l_party_rec.ATTRIBUTE_CATEGORY		,
		l_party_rec.ATTRIBUTE1			,
		l_party_rec.ATTRIBUTE2			,
		l_party_rec.ATTRIBUTE3			,
		l_party_rec.ATTRIBUTE4			,
		l_party_rec.ATTRIBUTE5			,
		l_party_rec.ATTRIBUTE6			,
		l_party_rec.ATTRIBUTE7			,
		l_party_rec.ATTRIBUTE8			,
		l_party_rec.ATTRIBUTE9			,
		l_party_rec.ATTRIBUTE10			,
		l_party_rec.ATTRIBUTE11			,
		l_party_rec.ATTRIBUTE12			,
		l_party_rec.ATTRIBUTE13			,
		l_party_rec.ATTRIBUTE14			,
		l_party_rec.ATTRIBUTE15			;

    x_no_data_found := party_pk_csr%NOTFOUND;
    CLOSE party_pk_csr;
	IF(x_no_data_found) THEN
	RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;
    RETURN(l_party_rec);

  END get_rec;



	-- row level insert
	-- will create using nextVal from sequence OKE_POOL_PARTIES_s

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                      IN party_rec_type,
    x_party_rec                      OUT NOCOPY party_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_party_rec                      party_rec_type;
    l_def_party_rec                  party_rec_type;
    lx_party_rec                     party_rec_type;
    l_seq			   NUMBER;
    l_row_id			RowID;

    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_party_rec	IN party_rec_type
    ) RETURN party_rec_type IS

      l_party_rec	party_rec_type := p_party_rec;

    BEGIN

      l_party_rec.CREATION_DATE := SYSDATE;
      l_party_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_party_rec.LAST_UPDATE_DATE := SYSDATE;
      l_party_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_party_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_party_rec);

    END fill_who_columns;


	-- nothing much here. flags to UPPERCASE

    FUNCTION Set_Attributes (
      p_party_rec IN  party_rec_type,
      x_party_rec OUT NOCOPY party_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

      l_to_currency 	VARCHAR2(15);
      l_rate		NUMBER;
    BEGIN
	x_party_rec := p_party_rec;
	x_party_rec.available_amount:=x_party_rec.amount;
	validate_funding_pool_id (x_return_status => l_return_status,
			      p_party_rec	 =>  p_party_rec);
  	IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    		RETURN (l_return_status);
  	END IF;

	SELECT CURRENCY_CODE INTO l_to_currency
	FROM OKE_FUNDING_POOLS
	WHERE FUNDING_POOL_ID = p_party_rec.FUNDING_POOL_ID;

	IF p_party_rec.CURRENCY_CODE <> l_to_currency THEN

	OKE_FUNDING_UTIL_PKG.GET_CONVERSION_RATE
		( p_party_rec.CURRENCY_CODE,
		l_to_currency,
		p_party_rec.CONVERSION_TYPE,
		p_party_rec.CONVERSION_DATE,
		x_party_rec.CONVERSION_RATE,
		l_return_status);

	END IF;
      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- insert
    --oke_debug.debug('start call oke_party_pvt.insert_row');

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


   IF p_party_rec.pool_party_id <> OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'pool_party_id');
        --oke_debug.debug('must not provide pool_party_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;


   IF p_party_rec.available_amount <> OKE_API.G_MISS_NUM THEN

     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'available_amount');
	--oke_debug.debug('must not provide available_amount');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

   IF p_party_rec.conversion_rate <> OKE_API.G_MISS_NUM THEN

     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'conversion_rate');
	--oke_debug.debug('must not provide conversion_rate');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;


    --oke_debug.debug('start call null out defaults');

    l_party_rec := null_out_defaults(p_party_rec);
	-- overide, since cannot insert id
    l_party_rec.pool_party_id := NULL;

    --oke_debug.debug(' called null out defaults');

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_party_rec,                        -- IN
      l_def_party_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    --oke_debug.debug('attributes set for insert');

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_def_party_rec := fill_who_columns(l_def_party_rec);

    --oke_debug.debug('who column filled for insert');

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_party_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    --oke_debug.debug('attributes validated for insert');

    l_return_status := Validate_Record(l_def_party_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
 --oke_debug.debug('record validated');

    SELECT OKE_POOL_PARTIES_S.nextval  INTO l_seq FROM dual;

	OKE_POOL_PARTIES_PKG.Insert_row
	(	l_row_id,
 	l_seq	,
 	l_def_party_rec.FUNDING_POOL_ID,
 	l_def_party_rec.PARTY_ID	,
 	l_def_party_rec.CURRENCY_CODE	,
 	l_def_party_rec.CONVERSION_TYPE,
 	l_def_party_rec.CONVERSION_DATE,
 	l_def_party_rec.CONVERSION_RATE,
 	l_def_party_rec.INITIAL_AMOUNT,
 	l_def_party_rec.AMOUNT		,
 	l_def_party_rec.AVAILABLE_AMOUNT,
 	l_def_party_rec.START_DATE_ACTIVE,
 	l_def_party_rec.END_DATE_ACTIVE,
 	l_def_party_rec.LAST_UPDATE_DATE     ,
 	l_def_party_rec.LAST_UPDATED_BY      ,

 	l_def_party_rec.CREATION_DATE        ,
 	l_def_party_rec.CREATED_BY           ,
 	l_def_party_rec.LAST_UPDATE_LOGIN    ,
 	l_def_party_rec.ATTRIBUTE_CATEGORY   ,
 	l_def_party_rec.ATTRIBUTE1           ,
 	l_def_party_rec.ATTRIBUTE2           ,
 	l_def_party_rec.ATTRIBUTE3           ,
 	l_def_party_rec.ATTRIBUTE4           ,
 	l_def_party_rec.ATTRIBUTE5           ,
 	l_def_party_rec.ATTRIBUTE6           ,
 	l_def_party_rec.ATTRIBUTE7           ,
 	l_def_party_rec.ATTRIBUTE8           ,
 	l_def_party_rec.ATTRIBUTE9           ,
 	l_def_party_rec.ATTRIBUTE10          ,
 	l_def_party_rec.ATTRIBUTE11          ,
 	l_def_party_rec.ATTRIBUTE12          ,
 	l_def_party_rec.ATTRIBUTE13          ,
 	l_def_party_rec.ATTRIBUTE14          ,
 	l_def_party_rec.ATTRIBUTE15      );

    --oke_debug.debug('record inserted');
    -- Set OUT values
    x_party_rec := l_def_party_rec;
    x_party_rec.POOL_PARTY_ID:=l_seq;
    --oke_debug.debug('end call oke_party_pvt.insert_row');
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
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;   -- row level




	-- table level insert

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                      IN party_tbl_type,
    x_party_tbl                      OUT NOCOPY party_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    --oke_debug.debug('start call oke_party_pvt.insert_row');

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_party_tbl.COUNT > 0) THEN
      i := p_party_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,

          p_party_rec                      => p_party_tbl(i),
          x_party_rec                      => x_party_tbl(i));

		-- store the highest degree of error
	 If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	   End If;
	 End If;

        EXIT WHEN (i = p_party_tbl.LAST);

        i := p_party_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;
   --oke_debug.debug('end call oke_party_pvt.insert_row');
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
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row; -- table level








  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                      IN party_rec_type,
    x_party_rec                      OUT NOCOPY party_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_party_rec                    party_rec_type := p_party_rec;
    l_def_party_rec                party_rec_type;
    lx_party_rec                   party_rec_type;
    l_available			   NUMBER;
    l_result			   VARCHAR2(1);
    l_currency			   VARCHAR2(15);

    l_dummy_val 		VARCHAR2(1):='?';
    l_temp			NUMBER;

    Cursor l_csr_id IS
	select pool_party_id
	from oke_pool_parties
	where pool_party_id=p_party_rec.pool_party_id;

    CURSOR l_csr IS
    SELECT 'x'
    FROM OKE_K_FUNDING_SOURCES
    WHERE pool_party_id = p_party_rec.pool_party_id;


    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_party_rec	IN party_rec_type
    ) RETURN party_rec_type IS

      l_party_rec	party_rec_type := p_party_rec;

    BEGIN
      l_party_rec.LAST_UPDATE_DATE := SYSDATE;
      l_party_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_party_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_party_rec);
    END fill_who_columns;

    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_party_rec	IN party_rec_type,
      x_party_rec	OUT NOCOPY party_rec_type
    ) RETURN VARCHAR2 IS

      l_party_rec                     party_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

    BEGIN

      x_party_rec := p_party_rec;

      l_party_rec := get_rec(p_party_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      END IF;


	IF x_party_rec.FUNDING_POOL_ID = OKE_API.G_MISS_NUM THEN
	  x_party_rec.FUNDING_POOL_ID := l_party_rec.FUNDING_POOL_ID;
    	END IF;

	IF x_party_rec.PARTY_ID = OKE_API.G_MISS_NUM THEN
	  x_party_rec.PARTY_ID := l_party_rec.PARTY_ID;
    	END IF;

	IF x_party_rec.CURRENCY_CODE = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.CURRENCY_CODE := l_party_rec.CURRENCY_CODE;
    	END IF;

	IF x_party_rec.CONVERSION_TYPE = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.CONVERSION_TYPE := l_party_rec.CONVERSION_TYPE;
    	END IF;

	IF x_party_rec.CONVERSION_DATE = OKE_API.G_MISS_DATE THEN
	  x_party_rec.CONVERSION_DATE := l_party_rec.CONVERSION_DATE;
    	END IF;

	IF x_party_rec.CONVERSION_RATE = OKE_API.G_MISS_NUM THEN
	  x_party_rec.CONVERSION_RATE := l_party_rec.CONVERSION_RATE;
    	END IF;

	IF x_party_rec.INITIAL_AMOUNT = OKE_API.G_MISS_NUM THEN
	  x_party_rec.INITIAL_AMOUNT := l_party_rec.INITIAL_AMOUNT;
    	END IF;

	IF x_party_rec.AMOUNT = OKE_API.G_MISS_NUM THEN
	  x_party_rec.AMOUNT := l_party_rec.AMOUNT;
    	END IF;

	IF x_party_rec.AVAILABLE_AMOUNT = OKE_API.G_MISS_NUM THEN
	  x_party_rec.AVAILABLE_AMOUNT := l_party_rec.AVAILABLE_AMOUNT;
    	END IF;

	IF x_party_rec.START_DATE_ACTIVE = OKE_API.G_MISS_DATE THEN
	  x_party_rec.START_DATE_ACTIVE := l_party_rec.START_DATE_ACTIVE;
    	END IF;

	IF x_party_rec.END_DATE_ACTIVE = OKE_API.G_MISS_DATE THEN
	  x_party_rec.END_DATE_ACTIVE := l_party_rec.END_DATE_ACTIVE;
    	END IF;

	IF x_party_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	  x_party_rec.CREATION_DATE := l_party_rec.CREATION_DATE;
    	END IF;

	IF x_party_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	  x_party_rec.CREATED_BY := l_party_rec.CREATED_BY;
    	END IF;

	IF x_party_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	  x_party_rec.LAST_UPDATE_DATE := l_party_rec.LAST_UPDATE_DATE;
    	END IF;

	IF x_party_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	  x_party_rec.LAST_UPDATED_BY  := l_party_rec.LAST_UPDATED_BY ;
    	END IF;

	IF x_party_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	  x_party_rec.LAST_UPDATE_LOGIN := l_party_rec.LAST_UPDATE_LOGIN;
    	END IF;

	IF x_party_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE_CATEGORY := l_party_rec.ATTRIBUTE_CATEGORY;
    	END IF;

	IF x_party_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE1 := l_party_rec.ATTRIBUTE1;
    	END IF;

	IF x_party_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE2 := l_party_rec.ATTRIBUTE2;
    	END IF;

	IF x_party_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE3 := l_party_rec.ATTRIBUTE3;
    	END IF;

	IF x_party_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE4 := l_party_rec.ATTRIBUTE4;
    	END IF;

	IF x_party_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE5 := l_party_rec.ATTRIBUTE5;
    	END IF;

	IF x_party_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE6 := l_party_rec.ATTRIBUTE6;
    	END IF;

	IF x_party_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE7 := l_party_rec.ATTRIBUTE7;
    	END IF;

 	IF x_party_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE8 := l_party_rec.ATTRIBUTE8;
    	END IF;

	IF x_party_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE9 := l_party_rec.ATTRIBUTE9;
    	END IF;

	IF x_party_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE10 := l_party_rec.ATTRIBUTE10;
    	END IF;

	IF x_party_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE11 := l_party_rec.ATTRIBUTE11;
    	END IF;

	IF x_party_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE12 := l_party_rec.ATTRIBUTE12;
    	END IF;

	IF x_party_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE13 := l_party_rec.ATTRIBUTE13;
    	END IF;

	IF x_party_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE14 := l_party_rec.ATTRIBUTE14;
    	END IF;

	IF x_party_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	  x_party_rec.ATTRIBUTE15 := l_party_rec.ATTRIBUTE15;
    	END IF;

    RETURN(l_return_status);

  END populate_new_record;



  FUNCTION set_attributes(
	      p_party_rec IN  party_rec_type,
              x_party_rec OUT NOCOPY party_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
      l_to_currency 	VARCHAR2(15);
      l_rate		NUMBER;
      l_pool_id 	NUMBER;

    BEGIN
	x_party_rec := p_party_rec;

	IF (p_party_rec.CONVERSION_TYPE IS NOT NULL) AND (p_party_rec.CONVERSION_TYPE <> OKE_API.G_MISS_CHAR) AND (p_party_rec.CONVERSION_DATE IS NOT NULL) AND (p_party_rec.CONVERSION_DATE <> OKE_API.G_MISS_DATE) THEN

		SELECT FUNDING_POOL_ID INTO l_pool_id
		FROM OKE_POOL_PARTIES
		WHERE pool_party_id = p_party_rec.pool_party_id;

		SELECT CURRENCY_CODE INTO l_to_currency
		FROM OKE_FUNDING_POOLS
		WHERE FUNDING_POOL_ID = l_pool_id;

		IF p_party_rec.CURRENCY_CODE <> l_to_currency THEN

		OKE_FUNDING_UTIL_PKG.GET_CONVERSION_RATE
		( p_party_rec.CURRENCY_CODE,
		l_to_currency,
		p_party_rec.CONVERSION_TYPE,
		p_party_rec.CONVERSION_DATE,
		x_party_rec.CONVERSION_RATE,
		l_return_status);
		END IF;

	ELSE
		x_party_rec.CONVERSION_RATE := NULL;

	END IF;

      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- update row

    --oke_debug.debug('start call oke_party_pvt.update_row');

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


   IF p_party_rec.pool_party_id = OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'pool_party_id');
        --oke_debug.debug('must provide pool_party_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;


   IF p_party_rec.conversion_rate <> OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'conversion_rate');
	--oke_debug.debug('must not provide conversion_rate');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;


    OPEN l_csr_id;
    FETCH l_csr_id INTO l_temp;
    IF l_csr_id%NOTFOUND THEN
		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'pool_party_id');
        --oke_debug.debug('must provide valid pool_party_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_csr_id;

    l_return_status := Set_Attributes(
      p_party_rec,                        -- IN
      l_party_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

--oke_debug.debug('attributes set');




--check not updatable fields

   IF p_party_rec.funding_pool_id <> OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'funding_pool_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

   IF p_party_rec.initial_amount <> OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'initial_amount');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

   IF p_party_rec.available_amount <> OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'available_amount');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

   IF p_party_rec.currency_code <> OKE_API.G_MISS_CHAR THEN

 	OPEN l_csr;
	FETCH l_csr INTO l_dummy_val;
	CLOSE l_csr;

	IF l_dummy_val = 'x' THEN --child records exist
	--oke_debug.debug('-child records exist');
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'currency_code');
	RAISE OKE_API.G_EXCEPTION_ERROR;
	END IF;


	SELECT a.currency_code INTO l_currency
	FROM oke_funding_pools a,oke_pool_parties b
	WHERE a.funding_pool_id = b.funding_pool_id
	AND b.pool_party_id=p_party_rec.pool_party_id;

	IF l_currency = p_party_rec.currency_code THEN

		IF(p_party_rec.CONVERSION_TYPE IS NOT NULL AND p_party_rec.CONVERSION_TYPE<>OKE_API.G_MISS_CHAR)
		OR(p_party_rec.CONVERSION_DATE IS NOT NULL AND p_party_rec.CONVERSION_DATE<>OKE_API.G_MISS_DATE)

		THEN --error
	--oke_debug.debug('must not specify conversion');
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'conversion_date');
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'conversion_type');

		RAISE OKE_API.G_EXCEPTION_ERROR;
		END IF;

	ELSE
		IF((p_party_rec.CONVERSION_TYPE IS NULL)OR(p_party_rec.CONVERSION_TYPE=OKE_API.G_MISS_CHAR))
		OR((p_party_rec.CONVERSION_DATE IS NULL)OR(p_party_rec.CONVERSION_DATE=OKE_API.G_MISS_DATE))

		THEN --error
	--oke_debug.debug('must specify conversion');
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'conversion_type');
    		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'conversion_date');


		RAISE OKE_API.G_EXCEPTION_ERROR;
		END IF;

	END IF;
  END IF;


---- set available amount

	IF 	(l_party_rec.amount <> OKE_API.G_MISS_NUM) THEN

		OKE_FUNDING_UTIL_PKG.validate_pool_party_amount
			(
			x_pool_party_id	=>	l_party_rec.pool_party_id,
			x_amount	=>	l_party_rec.amount,
			x_allocated_amount=>	l_available,
			x_return_status=> 	l_result	);

		IF l_result='Y' THEN
		l_party_rec.available_amount := l_party_rec.amount-l_available;
		ELSE
    		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'amount');

			--oke_debug.debug('invalid amount');
			RAISE OKE_API.G_EXCEPTION_ERROR;
		END IF;

	END IF;


    l_return_status := populate_new_record(l_party_rec, l_def_party_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

--oke_debug.debug('record populated');

    l_def_party_rec := fill_who_columns(l_def_party_rec);

--oke_debug.debug('who column filled');


    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_party_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

 --oke_debug.debug('attributes validated');

    l_return_status := Validate_Record(l_def_party_rec);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
 --oke_debug.debug('record validated');

    OKE_POOL_PARTIES_PKG.Update_Row(
	l_def_party_rec.POOL_PARTY_ID,
 	l_def_party_rec.PARTY_ID,
	l_def_party_rec.CURRENCY_CODE,
 	l_def_party_rec.CONVERSION_TYPE,
 	l_def_party_rec.CONVERSION_DATE,
 	l_def_party_rec.CONVERSION_RATE,

 	l_def_party_rec.AMOUNT,
 	l_def_party_rec.AVAILABLE_AMOUNT,
 	l_def_party_rec.START_DATE_ACTIVE,
 	l_def_party_rec.END_DATE_ACTIVE,

	l_def_party_rec.LAST_UPDATE_DATE,
	l_def_party_rec.LAST_UPDATED_BY,
	l_def_party_rec.LAST_UPDATE_LOGIN,

	l_def_party_rec.ATTRIBUTE_CATEGORY,
	l_def_party_rec.ATTRIBUTE1,
	l_def_party_rec.ATTRIBUTE2,
	l_def_party_rec.ATTRIBUTE3,
	l_def_party_rec.ATTRIBUTE4,
	l_def_party_rec.ATTRIBUTE5,
	l_def_party_rec.ATTRIBUTE6,
	l_def_party_rec.ATTRIBUTE7,
	l_def_party_rec.ATTRIBUTE8,
	l_def_party_rec.ATTRIBUTE9,
	l_def_party_rec.ATTRIBUTE10,
	l_def_party_rec.ATTRIBUTE11,
	l_def_party_rec.ATTRIBUTE12,
	l_def_party_rec.ATTRIBUTE13,
	l_def_party_rec.ATTRIBUTE14,
	l_def_party_rec.ATTRIBUTE15);

    x_party_rec := l_def_party_rec;
    --oke_debug.debug('end call oke_party_pvt.update_row');
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
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;   -- row level update



  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                     IN party_tbl_type,
    x_party_tbl                     OUT NOCOPY party_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_update_row';


    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

   --oke_debug.debug('start call oke_party_pvt.update_row');

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

    -- Make sure PL/SQL table has records in it before passing
    IF (p_party_tbl.COUNT > 0) THEN
      i := p_party_tbl.FIRST;
      LOOP

        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_party_rec                      => p_party_tbl(i),
          x_party_rec                     => x_party_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_party_tbl.LAST);
        i := p_party_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;
    --oke_debug.debug('end call oke_party_pvt.update_row');
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
        '_PVT'
      );

    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;  -- table level update


	-- deletes by the funding_party_id

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                     IN party_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_party_rec                     party_rec_type := p_party_rec;
    l_temp			NUMBER;

Cursor l_csr_id IS
	select pool_party_id
	from oke_pool_parties
	where pool_party_id=p_party_rec.pool_party_id;

  BEGIN
   --oke_debug.debug('start call oke_party_pvt.delete_row');

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

   IF p_party_rec.pool_party_id = OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'pool_party_id');
        --oke_debug.debug('must provide pool_party_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

    OPEN l_csr_id;
    FETCH l_csr_id INTO l_temp;
    IF l_csr_id%NOTFOUND THEN
		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'pool_party_id');
        --oke_debug.debug('must provide valid pool_party_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_csr_id;

	DELETE FROM OKE_POOL_PARTIES
	WHERE POOL_PARTY_ID = p_party_rec.POOL_PARTY_ID;

    --oke_debug.debug('end call oke_party_pvt.delete_row');
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
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;


-- table level delete

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                     IN party_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
   --oke_debug.debug('start call oke_party_pvt.delete_row');

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

    -- Make sure PL/SQL table has records in it before passing
    IF (p_party_tbl.COUNT > 0) THEN
      i := p_party_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_party_rec                      => p_party_tbl(i));

	-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
          End If;
	End If;

        EXIT WHEN (i = p_party_tbl.LAST);
        i := p_party_tbl.NEXT(i);
      END LOOP;

	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;
    --oke_debug.debug('end call oke_party_pvt.delete_row');
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
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row; -- table level delete


  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                     IN party_rec_type) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_row_notfound                BOOLEAN := FALSE;

    l_pool_party_id		NUMBER;

	E_Resource_Busy		EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);


	CURSOR lock_csr (p IN party_rec_type) IS
	SELECT pool_party_id FROM OKE_POOL_PARTIES a
	WHERE
	  a.pool_party_id = p.pool_party_id
	FOR UPDATE NOWAIT;


BEGIN

--oke_debug.debug('start call oke_party_pvt.lock_row');

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


    BEGIN
      OPEN lock_csr(p_party_rec);
      FETCH lock_csr INTO l_pool_party_id;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;


    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKE_API.set_message(G_APP_NAME,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;


    IF (l_row_notfound) THEN
      OKE_API.set_message(G_APP_NAME,G_FORM_RECORD_DELETED);
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

--oke_debug.debug('end call oke_party_pvt.lock_row');
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
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;


END OKE_PARTY_PVT;


/
