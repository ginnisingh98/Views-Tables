--------------------------------------------------------
--  DDL for Package OKL_FORMULAEVALUATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAEVALUATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLREVAS.pls 115.4 2002/12/18 12:47:20 kjinger noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKC_SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_ONE_DOI			CONSTANT VARCHAR2(200) := 'OKC_ONE_DOI';
  G_FORMULA_NOT_FOUND		CONSTANT VARCHAR2(200) := 'OKL_FMA_NOTFOUND';
  G_EVALUATE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_EVALUATE_ERR';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_FORMULAEVALUATE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  /** SBALASHA001 -
		INFO: G_FNCT_PKG_NAME will hold a package name, and this
			package will have all the parameter evaluator
			functions written by an individual developer. **/
  G_FNCT_PKG_NAME		CONSTANT VARCHAR2(30)  :=  'OKL_FORMULAFUNCTION_PVT';
  G_FNCT_PREFIX			CONSTANT VARCHAR2(6)  :=  'GET_';
  G_FNCT_SUFFIX			CONSTANT VARCHAR2(6)  :=  '_VALUE';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;


  /** SBALASHA001 -
		INFO: Record to hold parameter value, name and id.
	              This record is used to send the parameter id,
		      name and the value evaluated to the calling API.
							**/
  TYPE CtxParameter_rec IS RECORD (
			parameter_id		NUMBER,
		 	parameter_name	VARCHAR2(155),
		 	parameter_value	NUMBER
  );

  /** SBALASHA001 -
		INFO: Table to hold CtxParameter_rec records
	              This table is used to send the parameter
		      and the value evaluated to the calling API
		      in the form of records.
							**/

  TYPE CtxParameter_tbl IS TABLE OF CtxParameter_rec INDEX BY BINARY_INTEGER;

  /** SBALASHA001 -
		INFO: Record to hold function id, name, source, code and value.
	              This record is used to send the evaluated operands,
		      name and the value evaluated to the calling API.
							**/
  TYPE Function_rec IS RECORD (
			function_id	NUMBER,
			function_name	VARCHAR2(150),
			function_source	VARCHAR2(720),
			function_code	VARCHAR2(30),
			function_value	NUMBER
  );

  /** SBALASHA001 -
		INFO: Table to hold Function_rec records.
	              This table is used to send the operand
		      and the value evaluated to the calling API
		      in the form of records.
							**/
  TYPE Function_tbl IS TABLE OF Function_rec INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  FUNCTION EVA_GetParameterIDs( p_fma_id IN NUMBER,
				p_ctx_parameter_tbl OUT NOCOPY CtxParameter_tbl )
				 RETURN NUMBER;


  PROCEDURE EVA_GetParameterValues(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fma_id                       IN NUMBER,
    p_contract_id                  IN NUMBER,
    x_ctx_parameter_tbl            OUT NOCOPY CtxParameter_tbl,
    p_line_id                      IN NUMBER DEFAULT NULL );


  PROCEDURE EVA_GetFunctionValue(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fma_id		   	   IN NUMBER,
    p_contract_id	   	   IN NUMBER,
    p_line_id		   	   IN NUMBER,
    p_ctx_parameter_tbl            IN CtxParameter_tbl,
    x_function_tbl               OUT NOCOPY Function_tbl);

END OKL_FORMULAEVALUATE_PVT;

 

/
