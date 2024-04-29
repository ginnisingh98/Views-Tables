--------------------------------------------------------
--  DDL for Package Body OKL_FORMULAVALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FORMULAVALIDATE_PVT" AS
/* $Header: OKLRVALB.pls 115.8 2002/12/18 12:52:06 kjinger noship $ */

-- Start of comments
--
-- Function Name  : VAL_GetAllFunctionParameters
-- Description    : Function fetches all the data source function parameter
--                  for a given formula identifier.
-- Business Rules :
-- Parameters     : p_fma_id - Formula identifier.
--		    Returns l_fncpmr_tbl  - List of data source function ids.
-- Version        : 1.0
--
-- End of comments

FUNCTION VAL_GetAllFunctionParameters(
	p_fma_id	IN NUMBER )
RETURN CtxParameter_tbl
IS
	CURSOR fmapmr_cur
	IS
	SELECT
		pmrv.id
	FROM
		okl_fnctn_prmtrs_v fprv,
		okl_parameters_v pmrv
	WHERE
		fprv.dsf_id IN
		( SELECT
			dsfv.id
		FROM
			okl_formulae_v fmav,
			okl_operands_v opdv,
			okl_fmla_oprnds_v fodv,
			okl_data_src_fnctns_v dsfv
		WHERE
			fmav.id = p_fma_id
		AND	fmav.id = fodv.fma_id
		AND	fodv.opd_id = opdv.id
		AND opdv.opd_type = 'FCNT'
		AND	opdv.dsf_id = dsfv.id )
	AND	fprv.pmr_id = pmrv.id;

	l_dsf_parameter_tbl 	CtxParameter_tbl;
	l_Count	NUMBER := 1;

BEGIN

	FOR fmapmr_rec IN fmapmr_cur
	LOOP
		l_dsf_parameter_tbl(l_Count).parameter_id := fmapmr_rec.id;
		l_Count := l_Count + 1;
	END LOOP;

	RETURN l_dsf_parameter_tbl;
END VAL_GetAllFunctionParameters;

-- Start of comments
--
-- Function Name  : VAL_CompareCtxPrmWithFncPrm
-- Description    : Function compares context parameter with data source
--		    function parameter.
-- Business Rules :
-- Parameters     : p_ctx_parameter_tbl - Context Parameter table.
--		    p_fnc_parameter_tbl - Function Parameter table.
--		    Returns boolean - true/false.
-- Version        : 1.0
--
-- End of comments

FUNCTION VAL_CompareCtxPrmWithFncPrm(
	p_ctx_parameter_tbl	IN CtxParameter_tbl
	,p_fnc_parameter_tbl	IN CtxParameter_tbl )
RETURN BOOLEAN
IS
	l_Match		BOOLEAN := FALSE;
	l_outerCount		NUMBER;
	l_innerCount		NUMBER;
BEGIN

-- Added by Santonyr 29-Jul-2002
-- Return TRUE if both the counts are zero.

  IF p_ctx_parameter_tbl.COUNT = 0 AND p_fnc_parameter_tbl.COUNT = 0 THEN
    	RETURN TRUE;
  END IF;

	FOR l_outerCount IN 1 .. p_fnc_parameter_tbl.count
	LOOP
		l_Match := FALSE;
		FOR l_innerCount in 1 .. p_ctx_parameter_tbl.count
		LOOP
			IF ( p_fnc_parameter_tbl(l_outerCount).parameter_id =
				p_ctx_parameter_tbl(l_innerCount).parameter_id )
			THEN
				l_Match := TRUE;
				EXIT;
			END IF;
		END LOOP;

		IF ( l_Match = FALSE )
		THEN
			EXIT;
		END IF;
	END LOOP;

	RETURN l_Match;

END VAL_CompareCtxPrmWithFncPrm;

-- Start of comments
--
-- Function Name  : VAL_IsRecursive
-- Description    : Function checks for recursion in a given 2 PL/SQL tables
--                  it takes the first table as master and compares it with
--		    the 2nd one.
-- Business Rules :
-- Parameters     : p_fma_id - Formula identifier.
--		    Returns l_fncpmr_tbl  - List of data source function ids.
-- Version        : 1.0
--
-- End of comments

FUNCTION VAL_IsRecursive(
	p_allfmaopd_tbl	IN FmaOpd_tbl
	,p_newfmaopd_tbl	IN FmaOpd_tbl )
RETURN BOOLEAN
IS
	l_outerCount	NUMBER;
	l_innerCount	NUMBER;
	l_bRet	BOOLEAN := FALSE;
BEGIN

	FOR l_outerCount in 1 .. p_newfmaopd_tbl.count
	LOOP
		l_bRet := FALSE;
		FOR l_innerCount in 1 .. p_allfmaopd_tbl.count
		LOOP
			IF p_allfmaopd_tbl(l_innerCount).id =
				p_newfmaopd_tbl(l_outerCount).id
			THEN
				l_bRet := TRUE;
				EXIT;
			END IF;
		END LOOP;

		IF ( l_bRet = TRUE )
		THEN
			EXIT;
		END IF;

	END LOOP;
	RETURN l_bRet;
END VAL_IsRecursive;

-- Start of comments
--
-- Function Name  : VAL_GetOperandsOfTypeFma
-- Description    : Function fetches all the formula used by the given
--                  formula identifier, also returns a boolean value for
--		    recursion.
-- Business Rules :
-- Parameters     : p_fma_id - Formula identifier.
--		    x_fma_ids - Array of formula identifier.
--		    Returns boolean - true/false.
-- Version        : 1.0
--
-- End of comments

FUNCTION VAL_GetOperandsOfTypeFma(
  p_fma_id                  IN NUMBER,
  x_fmaopd_tbl		    OUT NOCOPY fmaopd_tbl )
RETURN BOOLEAN
IS
	CURSOR fmaopd_cur(p_l_fma_id IN NUMBER)
	IS
	SELECT opdv.fma_id
	FROM
		okl_formulae_v fmav,
		okl_fmla_oprnds_v fodv,
		okl_operands_v opdv
	WHERE
		fmav.id = p_l_fma_id
	AND	fodv.fma_id = fmav.id
	AND	opdv.id = fodv.opd_id
	AND	opdv.opd_type = 'FMLA';

	l_fma_id	NUMBER;
	l_fmaopd_tbl	FmaOpd_tbl;
	l_newfmaopd_tbl	FmaOpd_tbl;
	l_Count	NUMBER;
	l_xCount	NUMBER;
	l_newCount	NUMBER;
	l_bRet	BOOLEAN := TRUE;
	l_ProceedFlag	BOOLEAN := TRUE;

BEGIN

	l_Count := 1;
	l_xCount := 1;
	l_newCount := 1;

	l_fmaopd_tbl(l_Count).id := p_fma_id;

	WHILE ( l_ProceedFlag = TRUE )
	LOOP
		FOR l_Count IN 1 .. l_fmaopd_tbl.count
		LOOP
			x_fmaopd_tbl(l_xCount).id :=
					l_fmaopd_tbl(l_Count).id;

			l_newCount := 0;
			FOR fmaopd_rec in
				fmaopd_cur(
				l_fmaopd_tbl(l_Count).id )
			LOOP
				l_newCount := l_newCount + 1;
				l_newfmaopd_tbl(l_newCount).id :=
							fmaopd_rec.fma_id;

				/** SBALASHA001 - **/
			END LOOP;
			l_xCount := l_xCount + 1;
			IF ( l_newCount = 0 )
			THEN
				l_ProceedFlag := FALSE;
			END IF;
		END LOOP;
		/** SBALASHA001
			INFO: Check for recursion **/
		l_bRet :=
		 VAL_IsRecursive(p_allfmaopd_tbl => x_fmaopd_tbl,
				 p_newfmaopd_tbl => l_newfmaopd_tbl);
		IF ( l_bRet = TRUE )
		THEN
			/** SBALASHA001
				INFO: Recursion found. **/
			EXIT;
		END IF;
		l_fmaopd_tbl := l_newfmaopd_tbl;

		/** SBALASHA001 -
			INFO: Delete PL/SQL table entries. **/
		l_newfmaopd_tbl.delete;
	END LOOP;
	RETURN l_bRet;

END VAL_GetOperandsOfTypeFma;

-- Start of comments
--
-- Procedure Name : VAL_ValidateFormula
-- Description    :
--		    It does the following validation;
--			1) Check for recursion.
--			2) Check against Context group parameter with
--				data source function parameter.
-- Business Rules :
-- Parameters     :
--		    p_api_version   - API Version.
--		    p_init_msg_list - FND message initializer flag.
--		    x_return_status - Return Status.
--		    x_msg_count - FND message count.
--		    x_msg_data - FND message data.
--		    p_fma_id - Formula identifier.
--		    p_cgr_id - Context group identifier.
-- Version        : 1.0
--
-- End of comments

PROCEDURE VAL_ValidateFormula(
  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_validate_status              OUT NOCOPY VARCHAR2
  ,p_fma_id                       IN NUMBER
  ,p_cgr_id                 	 IN NUMBER )
IS
	l_ctx_parameter_tbl	CtxParameter_tbl;
	l_dsf_parameter_tbl	CtxParameter_tbl;
	l_fmaopd_tbl	FmaOpd_tbl;
	l_FormulaExists		BOOLEAN := FALSE;
	l_Match			BOOLEAN := FALSE;
	l_bRecursion		BOOLEAN;

	l_Count	NUMBER;
BEGIN
	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	/** SBALASHA001 -
			INFO: Get all the formula operands for the given
			      formula identifier. **/
	l_bRecursion :=
		VAL_GetOperandsOfTypeFma( p_fma_id => p_fma_id,
					  x_fmaopd_tbl => l_fmaopd_tbl );


	IF ( l_bRecursion = TRUE )
	THEN
		/** SBALASHA001 -
			INFO: Recursion exception **/
		OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
					p_msg_name => G_FMA_RECURSION,
					p_token1 => G_RECURSION_TOKEN,
					p_token1_value => p_fma_id );
		-- notify error for calling API
		x_return_status := OKL_API.G_RET_STS_ERROR;
		-- notify error for calling API to override the regular exception handling.
		x_validate_status := G_RET_STS_RECURSION_ERROR;
	END IF;


	IF ( x_return_status = OKL_API.G_RET_STS_SUCCESS )
	THEN
		/** SBALASHA001 -
			INFO: Get all the context parameters for the
				given formula. **/
		l_count := OKL_FORMULAEVALUATE_PVT.EVA_GetParameterIDs(
				p_fma_id => p_fma_id,
				p_ctx_parameter_tbl => l_ctx_parameter_tbl );
	END IF;

-- Commented by Santonyr 29-Jul-2002
-- Commenting this as the validation is not necessary.
/*
	IF ( l_ctx_parameter_tbl.count = 0 )
	THEN
		OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
					p_msg_name => G_CTX_GROUP_NOTFOUND,
					p_token1 => G_CTX_GROUP_TOKEN,
					p_token1_value => p_cgr_id );
		-- notify error for calling API
		x_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;
*/


	IF ( x_return_status = OKL_API.G_RET_STS_SUCCESS )
	THEN
		/** SBALASHA001 -
			INFO: Loop thru' the operand that are formula
			      and get all function parameters attached
			      to it.
		**/
		FOR l_Count IN 1 .. l_fmaopd_tbl.count
		LOOP
			/** SBALASHA001 -
				INFO: Get all the function parameter for
					a given formula indentifier **/
			l_dsf_parameter_tbl :=
				VAL_GetAllFunctionParameters(
					p_fma_id => l_fmaopd_tbl(l_Count).id );


			/** SBALASHA001 -
					INFO: Compare context parameter with
					data source function parameter. **/
			l_Match := VAL_CompareCtxPrmWithFncPrm(
				p_ctx_parameter_tbl => l_ctx_parameter_tbl,
				p_fnc_parameter_tbl => l_dsf_parameter_tbl);
			IF ( l_Match = FALSE )
			THEN
				/** SBALASHA001 -
					INFO: Parameter mismatch exception. **/
				OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
					p_msg_name => G_PRM_MISMATCH,
					p_token1 => G_PRM_MISMATCH_TOKEN,
					p_token1_value => p_fma_id );
				-- notify error for calling API
				x_return_status := OKL_API.G_RET_STS_ERROR;
				-- notify error for calling API to override the regular exception handling.
				x_validate_status := G_RET_STS_PRM_MISMATCH_ERROR;
				EXIT;
			END IF;
		END LOOP;
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
		-- no processing necessary;
		null;
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	g_app_name,
				p_msg_name	=>	g_unexpected_error,
				p_token1	=>	g_sqlcode_token,
				p_token1_value	=>	sqlcode,
				p_token2	=>	g_sqlerrm_token,
				p_token2_value	=>	sqlerrm);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
END VAL_ValidateFormula;



END OKL_FORMULAVALIDATE_PVT;

/
