--------------------------------------------------------
--  DDL for Package Body OKL_FORMULAEVALUATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FORMULAEVALUATE_PVT" AS
/* $Header: OKLREVAB.pls 120.1 2005/10/30 04:33:36 appldev noship $ */


-- Start of comments
--
-- Function Name  : EVA_IsFormulaExists
-- Description    : Function checks whether the formula
--                  exists in the system or not.
-- Business Rules :
-- Parameters     : fma_id - formula identifier.
--		     Returns boolean - TRUE/FALSE
-- Version        : 1.0
--
-- End of comments

FUNCTION EVA_IsFormulaExists(
 p_fma_id IN NUMBER )
RETURN BOOLEAN
IS
	CURSOR fma_cur
	IS
	SELECT
		'1'
	FROM
		okl_formulae_v
	WHERE
		id = p_fma_id;

	l_result_var	VARCHAR2(1) := '0';
	l_retcode	BOOLEAN := FALSE;
BEGIN
	/** SBALASHA001 -
			INFO: Close if the cursor is already open. **/
	IF fma_cur%ISOPEN
	THEN
		CLOSE fma_cur;
	END IF;

	/** SBALASHA001 -
			INFO: Check whether the given fma_id exists,
			based on the results update the boolean flag
			and return it to the calling API. **/
	OPEN fma_cur;
	FETCH fma_cur INTO l_result_var;
	IF ( l_result_var <> '1' )
	THEN
		l_retcode := FALSE;
	ELSE
		l_retcode := TRUE;
	END IF;
	CLOSE fma_cur;
	RETURN l_retcode;

END EVA_IsFormulaExists;


-- Start of comments
--
-- Function Name  : EVA_GetAllFunctions
-- Description    : Function populates function id, name, source and type
--		    in Function_tbl.
-- Business Rules :
-- Parameters     :
--			p_fma_id - formula identifier.
--			x_function_tbl - function table.
-- 			Returns NUMBER.
-- Version        : 1.0
--
-- End of comments

FUNCTION EVA_GetAllFunctions(
 p_fma_id IN NUMBER
, x_function_tbl OUT NOCOPY Function_tbl )
RETURN NUMBER
IS
	CURSOR dsf_fma_cur
	IS
	SELECT
		dsfv.id,
		dsfv.name,
		dsfv.source,
		dsfv.fnctn_code
	FROM
		okl_formulae_v fmav,
		okl_data_src_fnctns_v dsfv,
		okl_operands_v opdv,
		okl_fmla_oprnds_v fodv
	WHERE
		fmav.id = p_fma_id
	AND	fmav.id = fodv.fma_id
	AND	fodv.opd_id = opdv.id
	AND	opdv.dsf_id = dsfv.id;

	l_Count	NUMBER := 1;

BEGIN

	FOR dsf_fma_rec in dsf_fma_cur
	LOOP
		x_function_tbl(l_Count).function_id :=
						dsf_fma_rec.id;
		x_function_tbl(l_Count).function_name :=
						dsf_fma_rec.name;
		x_function_tbl(l_Count).function_source :=
						dsf_fma_rec.source;
		x_function_tbl(l_Count).function_code :=
						dsf_fma_rec.fnctn_code;
		l_Count := l_Count + 1;
	END LOOP;

END EVA_GetAllFunctions;


-- Start of comments
--
-- Function Name  : EVA_GetParameterIDs
-- Description    : Function populates parameter id and parameter name
--		    in parameter table.
-- Business Rules :
-- Parameters     : p_fma_id - formula identifier.
--			p_ctx_parameter_tbl - Context parameter table.
--		     Returns NUMBER.
-- Version        : 1.0
--
-- End of comments

FUNCTION EVA_GetParameterIDs(
 p_fma_id IN NUMBER,
 p_ctx_parameter_tbl OUT NOCOPY CtxParameter_tbl )
RETURN NUMBER
IS
	CURSOR parameters_cur
	IS
	SELECT
		cgrpv.pmr_id, pmrv.name
	FROM
		okl_formulae_v fmav,
		okl_context_groups_v cgrv,
		okl_cntx_grp_prmtrs_v cgrpv,
		okl_parameters_v pmrv
	WHERE
		fmav.id = p_fma_id
	AND	cgrv.id = fmav.cgr_id
	AND	fmav.cgr_id = cgrpv.cgr_id
	AND	pmrv.id = cgrpv.pmr_id;

	l_count 	NUMBER := 1;
BEGIN

	/** SBALASHA001 -
			INFO: Loop thru' the parameter cursor to populate
			parameter table with parameter id and name. **/
	FOR l_parameter_rec in parameters_cur
	LOOP
		p_ctx_parameter_tbl(l_count).parameter_id :=
						l_parameter_rec.pmr_id;
		p_ctx_parameter_tbl(l_count).parameter_name :=
						l_parameter_rec.name;
		l_count := l_count + 1;
	END LOOP;

	RETURN l_count;

END EVA_GetParameterIDs;

-- Start of comments
--
-- Function Name  : EVA_ExecuteFunction
-- Description    : Prepares a dynamic SQL and executes a given function.
--		    Expects a SCALAR NUMERIC value to be returned from
--		    the executed function.
--		    This is a generic API used by both parameter
--		    evaluator and operand/function evaluator.
--		    This has been made as a seperate function inorder to
--		    give the flexibility for the future developer to change
--		    the way it executes a function.
--
-- Business Rules :
-- Parameters     :
--		     p_FunctionString - Function to be executed.
--		     Returns NUMBER.
-- Version        : 1.0
--
-- End of comments

FUNCTION EVA_ExecuteFunction(
 p_function_string IN VARCHAR2)
RETURN NUMBER
IS
	l_QueryString	VARCHAR2(720);
	l_RetValue	NUMBER;
BEGIN

	/** SBALASHA001 -
			INFO: execute the function **/

	l_QueryString := 'select ' || p_function_string || ' from dual';

	EXECUTE IMMEDIATE l_QueryString INTO l_RetValue;

	return l_RetValue;

END EVA_ExecuteFunction;

-- Start of comments
--
-- Function Name  : EVA_GetFunctionString
-- Description    : To get the PL/SQL function name
-- Business Rules :
-- Parameters     :
--		     p_dsf_id - Data Source Function identifier.
--		     p_contract_id - Contract identifier.
--		     p_line_id - Line identifier.
--		     p_ctx_parameter_tbl - Parameter Table.
--		     Returns CtxParameter_tbl.
-- Version        : 1.0
--
-- End of comments

FUNCTION EVA_GetFunctionString(
 p_function_rec	Function_rec
 ,p_contract_id	NUMBER
 ,p_line_id	NUMBER
 ,p_ctx_parameter_tbl	CtxParameter_tbl )
RETURN VARCHAR2
IS
	CURSOR dsf_pmr_cur
	IS
	SELECT
		fprv.pmr_id, fprv.sequence_number
	FROM
		okl_parameters_v pmrv,
		okl_data_src_fnctns_v dsfv,
		okl_fnctn_prmtrs_v fprv
	WHERE
		dsfv.id = p_function_rec.function_id
	AND	dsfv.id = fprv.dsf_id
	AND	fprv.pmr_id = pmrv.id
	ORDER BY
		fprv.sequence_number;
	l_FunctionString 	VARCHAR2(720);
	l_count 		NUMBER;

BEGIN

	/** SBALASHA001 -
			INFO: Build a function string for a given data
			      source function.
				ex:  <function_name>(<contract_id>, <line_id>,
				     and other parameters...). **/


	l_FunctionString := p_function_rec.function_source || '(' ||
				TO_CHAR(p_contract_id) || ', ' ||
				TO_CHAR(p_line_id);
	FOR dsf_pmr_rec in dsf_pmr_cur
	LOOP
		FOR l_count IN 1 .. p_ctx_parameter_tbl.count
		LOOP
			l_FunctionString := l_FunctionString || ', ';
			IF ( p_ctx_parameter_tbl(l_count).parameter_id
					= dsf_pmr_rec.pmr_id)
			THEN
				l_FunctionString :=
					l_FunctionString ||
					p_ctx_parameter_tbl(l_count).parameter_value;
				EXIT;
			END IF;
		END LOOP;
	END LOOP;

	l_FunctionString := l_FunctionString || ')';

	RETURN ( l_FunctionString );

END EVA_GetFunctionString;

-- Start of comments
--
-- Function Name  : EVA_EvaluateParameters
-- Description    : Function populates parameter value in parameter table
-- Business Rules :
-- Parameters     :
--		     p_fma_id - formula identifier.
--		     p_contract_id - contract id.
--		     p_line_id - line id.
--		     p_ctx_parameter_tbl - Parameter Table.
--		     Returns CtxParameter_tbl.
-- Version        : 1.0
--
-- End of comments

FUNCTION EVA_EvaluateParameters(
 p_contract_id IN NUMBER
 ,p_line_id IN NUMBER DEFAULT NULL
 ,p_ctx_parameter_tbl IN OUT NOCOPY CtxParameter_tbl )
RETURN CtxParameter_tbl
IS
	l_FunctionString	VARCHAR2(720);
	l_count			NUMBER;
	x_ctx_parameter_tbl	CtxParameter_tbl;
BEGIN

	/** SBALASHA001 -
			INFO: Loop thru' the parameter table to execute
			the parameter function and to populate the parameter
			value. **/
	FOR l_count IN 1 .. p_ctx_parameter_tbl.count
	LOOP
		l_FunctionString :=
			 G_FNCT_PKG_NAME || '.' || G_FNCT_PREFIX ||
			 p_ctx_parameter_tbl(l_count).parameter_name ||
				G_FNCT_SUFFIX;

		IF ( p_line_id IS NOT NULL )    -- CHG001
		THEN
			l_FunctionString := l_FunctionString || '(' ||
					TO_CHAR(p_contract_id) || ', ' ||
					TO_CHAR(p_line_id) || ')';
		ELSE
			l_FunctionString := l_FunctionString || '(' ||
					TO_CHAR(p_contract_id) ||','||''''||''''||')';
		END IF;
		p_ctx_parameter_tbl(l_count).parameter_value :=
												EVA_ExecuteFunction(
													p_function_string => l_FunctionString);

	END LOOP;

	RETURN (p_ctx_parameter_tbl);

END EVA_EvaluateParameters;

-- Start of comments
--
-- Procedure Name : EVA_GetParameterValues
-- Description    : Evaluates value for all the context
--                  parameters attached to a formula.
-- Business Rules :
-- Parameters     : fma_id - formula identifier
--		    x_ctx_parameter_tbl - Parameter table
--		    that will have the evaluated values.
-- Version        : 1.0
--
-- End of comments

PROCEDURE EVA_GetParameterValues(
  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_fma_id                       IN NUMBER
  ,p_contract_id                  IN NUMBER
  ,x_ctx_parameter_tbl            OUT NOCOPY CtxParameter_tbl
  ,p_line_id                      IN NUMBER DEFAULT NULL )
IS
	l_formula_exist	BOOLEAN := FALSE;
	l_count	NUMBER;
BEGIN
	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	/** SBALASHA001 -
			INFO: Validate whether the formula
		             has context and the formula exists in
			     the system or not **/
	l_formula_exist := EVA_IsFormulaExists(p_fma_id => p_fma_id);

	IF ( l_formula_exist = TRUE )
	THEN
		/** SBALASHA001 -
			 INFO: Formula Exists, now call
 				EVA_GetParameterIDs function to populate
				just the parameter ids and not the values **/

		l_count := EVA_GetParameterIDs(
					p_fma_id => p_fma_id,
					p_ctx_parameter_tbl => x_ctx_parameter_tbl );
	ELSE
		/** SBALASHA001 -
			INFO: raise formula not found exception **/
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
				p_msg_name	=>	G_FORMULA_NOT_FOUND,
				p_token1	=>	G_EVALUATE_TOKEN,
				p_token1_value	=>	p_fma_id);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_ERROR;
	END IF;

	/** SBALASHA001 -
			INFO: Call Evaluate Parameter function to
			     actually do the evaluation and populate
  			     parameter table with values **/
	IF ( x_return_status = OKL_API.G_RET_STS_SUCCESS )
	THEN
		x_ctx_parameter_tbl :=
			EVA_EvaluateParameters(
				p_contract_id => p_contract_id,
				p_line_id => p_line_id,
				p_ctx_parameter_tbl => x_ctx_parameter_tbl);
	END IF;

EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
		-- no processing necessary;
		NULL;
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
END EVA_GetParameterValues;


-- Start of comments
--
-- Procedure Name : EVA_GetFunctionValue
-- Description    : Evaluates value for a given function using
--                  the evaluated context parameters.
-- Business Rules :
-- Parameters     : p_dsf_id - Data Source Function identifier.
--		    x_ctx_parameter_tbl - Parameter table
--		    that will have the evaluated values.
-- Version        : 1.0
--
-- End of comments

PROCEDURE EVA_GetFunctionValue(
  p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,p_fma_id                       IN NUMBER
  ,p_contract_id                  IN NUMBER
  ,p_line_id                      IN NUMBER
  ,p_ctx_parameter_tbl            IN CtxParameter_tbl
  ,x_function_tbl                 OUT NOCOPY Function_tbl)
IS
	l_FunctionString	VARCHAR2(720);
	l_dummy			NUMBER;
BEGIN
	x_return_status := OKL_API.G_RET_STS_SUCCESS;

	/** SBALASHA001 -
			INFO: Get all the PL/SQL function name for the given
			      formula identifier. **/

	l_dummy := EVA_GetAllFunctions( p_fma_id => p_fma_id,
					x_function_tbl => x_function_tbl );

	FOR l_Count IN 1 .. x_function_tbl.count
	LOOP
		l_FunctionString :=
			EVA_GetFunctionString(
			  	p_function_rec => x_function_tbl(l_Count),
				p_contract_id => p_contract_id,
				p_line_id => p_line_id,
				p_ctx_parameter_tbl => p_ctx_parameter_tbl);
		x_function_tbl(l_Count).function_value :=
			EVA_ExecuteFunction(
				p_function_string => l_FunctionString);
	END LOOP;

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
END EVA_GetFunctionValue;

END OKL_FORMULAEVALUATE_PVT;

/
