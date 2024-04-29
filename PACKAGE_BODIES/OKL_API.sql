--------------------------------------------------------
--  DDL for Package Body OKL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_API" AS
 /* $Header: OKLPAPIB.pls 120.4 2007/10/03 20:51:28 rmunjulu ship $ */
--------------------------------------------------------------------------------
-- MESSAGE CONSTANTS
--------------------------------------------------------------------------------
G_MSG_LEVEL_THRESHOLD		CONSTANT NUMBER := OKL_API.G_MISS_NUM;
--------------------------------------------------------------------------------
-- PROCEDURE init_msg_list
--------------------------------------------------------------------------------
PROCEDURE init_msg_list (
	p_init_msg_list	IN VARCHAR2
) IS
BEGIN
  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END init_msg_list;
--------------------------------------------------------------------------------
-- FUNCTION start_activity
--------------------------------------------------------------------------------
FUNCTION start_activity(
	p_api_name			IN VARCHAR2,
	p_pkg_name			IN VARCHAR2,
	p_init_msg_list			IN VARCHAR2,
	l_api_version			IN NUMBER,
	p_api_version			IN NUMBER,
	p_api_type			IN VARCHAR2,
	x_return_status		 OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
	-- Standard START OF API SAVEPOINT
	DBMS_TRANSACTION.SAVEPOINT(p_api_name || p_api_type);
	IF NOT FND_API.compatible_API_Call( l_api_version,
					    p_api_version,
					    p_api_name,
					    p_pkg_name)
	THEN
	  RETURN(OKL_API.G_RET_STS_UNEXP_ERROR);
	END IF;
	OKL_API.init_msg_list(p_init_msg_list);
	x_return_status := OKL_API.G_RET_STS_SUCCESS;
	RETURN(OKL_API.G_RET_STS_SUCCESS);
END start_activity;
FUNCTION start_activity(
	p_api_name			IN VARCHAR2,
	p_init_msg_list			IN VARCHAR2,
	p_api_type			IN VARCHAR2,
	x_return_status		 OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
	-- Standard START OF API SAVEPOINT
	DBMS_TRANSACTION.SAVEPOINT(p_api_name || p_api_type);
	OKL_API.init_msg_list(p_init_msg_list);
	x_return_status := OKL_API.G_RET_STS_SUCCESS;
	RETURN(OKL_API.G_RET_STS_SUCCESS);
END start_activity;
--------------------------------------------------------------------------------
-- FUNCTION handle_exceptions
--------------------------------------------------------------------------------
FUNCTION handle_exceptions (
	p_api_name		IN VARCHAR2,
	p_pkg_name		IN VARCHAR2,
	p_exc_name		IN VARCHAR2,
	x_msg_count	 OUT NOCOPY NUMBER,
	x_msg_data	 OUT NOCOPY VARCHAR2,
	p_api_type		IN VARCHAR2
) RETURN VARCHAR2 IS
	l_return_value		VARCHAR2(200) := OKL_API.G_RET_STS_UNEXP_ERROR;
BEGIN
	DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(p_api_name || p_api_type);
	IF UPPER(p_exc_name) = 'OKL_API.G_RET_STS_ERROR'  THEN
		FND_MSG_PUB.Count_And_Get
		(
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);
		l_return_value := OKL_API.G_RET_STS_ERROR;
	ELSIF UPPER(p_exc_name) = 'OKL_API.G_RET_STS_UNEXP_ERROR'  THEN
	 	FND_MSG_PUB.Count_And_Get
	 	(
	 		p_count	=>	x_msg_count,
	 		p_data	=>	x_msg_data
	 	);
	ELSE -- WHEN OTHERS EXCEPTION
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg
			(
				p_pkg_name,
	 			p_api_name
			);
		END IF;
		FND_MSG_PUB.Count_And_Get
		(
				p_count	=>	x_msg_count,
				p_data	=>	x_msg_data
		);
	END IF;
	RETURN(l_return_value);
END handle_exceptions;
--------------------------------------------------------------------------------
-- FUNCTION end_activity
--------------------------------------------------------------------------------
PROCEDURE end_activity (
	x_msg_count	 OUT NOCOPY NUMBER,
	x_msg_data	 OUT NOCOPY VARCHAR2
) IS
BEGIN
    --- Standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
END end_activity;
--------------------------------------------------------------------------------
-- PROCEDURE set_message
--------------------------------------------------------------------------------
PROCEDURE set_message (
	p_app_name		IN VARCHAR2 DEFAULT OKL_API.G_APP_NAME,
	p_msg_name		IN VARCHAR2,
	p_token1		IN VARCHAR2 DEFAULT NULL,
	p_token1_value		IN VARCHAR2 DEFAULT NULL,
	p_token2		IN VARCHAR2 DEFAULT NULL,
	p_token2_value		IN VARCHAR2 DEFAULT NULL,
	p_token3		IN VARCHAR2 DEFAULT NULL,
	p_token3_value		IN VARCHAR2 DEFAULT NULL,
	p_token4		IN VARCHAR2 DEFAULT NULL,
	p_token4_value		IN VARCHAR2 DEFAULT NULL,
	p_token5		IN VARCHAR2 DEFAULT NULL,
	p_token5_value		IN VARCHAR2 DEFAULT NULL,
	p_token6		IN VARCHAR2 DEFAULT NULL,
	p_token6_value		IN VARCHAR2 DEFAULT NULL,
	p_token7		IN VARCHAR2 DEFAULT NULL,
	p_token7_value		IN VARCHAR2 DEFAULT NULL,
	p_token8		IN VARCHAR2 DEFAULT NULL,
	p_token8_value		IN VARCHAR2 DEFAULT NULL,
	p_token9		IN VARCHAR2 DEFAULT NULL,
	p_token9_value		IN VARCHAR2 DEFAULT NULL,
	p_token10		IN VARCHAR2 DEFAULT NULL,
	p_token10_value		IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
	FND_MESSAGE.SET_NAME( P_APP_NAME, P_MSG_NAME);
	IF (p_token1 IS NOT NULL) AND (p_token1_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token1,
					VALUE		=> p_token1_value);
	END IF;
	IF (p_token2 IS NOT NULL) AND (p_token2_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token2,
					VALUE		=> p_token2_value);
	END IF;
	IF (p_token3 IS NOT NULL) AND (p_token3_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token3,
					VALUE		=> p_token3_value);
	END IF;
	IF (p_token4 IS NOT NULL) AND (p_token4_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token4,
					VALUE		=> p_token4_value);
	END IF;
	IF (p_token5 IS NOT NULL) AND (p_token5_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token5,
					VALUE		=> p_token5_value);
	END IF;
	IF (p_token6 IS NOT NULL) AND (p_token6_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token6,
					VALUE		=> p_token6_value);
	END IF;
	IF (p_token7 IS NOT NULL) AND (p_token7_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token7,
					VALUE		=> p_token7_value);
	END IF;
	IF (p_token8 IS NOT NULL) AND (p_token8_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token8,
					VALUE		=> p_token8_value);
	END IF;
	IF (p_token9 IS NOT NULL) AND (p_token9_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token9,
					VALUE		=> p_token9_value);
	END IF;
	IF (p_token10 IS NOT NULL) AND (p_token10_value IS NOT NULL) THEN
		FND_MESSAGE.SET_TOKEN(	TOKEN		=> p_token10,
					VALUE		=> p_token10_value);
	END IF;
	FND_MSG_PUB.add;
END set_message;

-- rmunjulu Added function which gets customer baseline
-- Returns H if customer coming from H to R12
-- Returns G if customer coming from G to R12
-- Returns a default of H if cannot find the lookup OKL_CUSTOMER_BASELINE
-- Returns NULL if ERROR
-- Pre-req - customer has to first apply OKLG or OKLH one-off which sets the baseline
FUNCTION get_customer_baseline RETURN VARCHAR2 IS

  -- get the lookup code from lookup - 'OKL_CUSTOMER_BASELINE'
  -- will be H if customer on OKLH, will be G if customer on OKLG
  -- Upon testing found that if G patch is applied and then H patch then both codes (G and H)
  -- exist - so disabling G code in SEED115 and doing the query properly for
  -- enabled code only.
  CURSOR get_cust_baseline_csr  IS
  SELECT lookup_code
  FROM   fnd_lookups
  WHERE  lookup_type = 'OKL_CUSTOMER_BASELINE'
  AND    enabled_flag = 'Y'
  AND    end_date_active IS NULL;

  l_cst_baseline VARCHAR2(3);

BEGIN

  OPEN get_cust_baseline_csr;
  FETCH get_cust_baseline_csr INTO l_cst_baseline;
  CLOSE get_cust_baseline_csr;

  RETURN nvl(l_cst_baseline,'H');

EXCEPTION
  WHEN OTHERS THEN
  IF get_cust_baseline_csr%ISOPEN THEN
     CLOSE get_cust_baseline_csr;
  END IF;
  RETURN NULL;

END get_customer_baseline;

END OKL_API;

/
