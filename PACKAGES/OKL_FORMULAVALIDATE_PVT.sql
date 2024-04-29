--------------------------------------------------------
--  DDL for Package OKL_FORMULAVALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAVALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRVALS.pls 115.2 2002/02/18 20:17:22 pkm ship       $ */

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

  G_FMA_RECURSION		CONSTANT VARCHAR2(200) := 'OKL_FMA_RECURSION';
  G_RECURSION_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_RECURSION_TOKEN';
  G_PRM_MISMATCH		CONSTANT VARCHAR2(200) := 'OKL_PRM_MISMATCH';
  G_PRM_MISMATCH_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_PRM_MISMATCH_TOKEN';
  G_CTX_GROUP_NOTFOUND		CONSTANT VARCHAR2(200) := 'OKL_CTX_GROUP_NOTFOUND';
  G_CTX_GROUP_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_CTX_GROUP_TOKEN';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_FORMULAVALIDATION_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;

  G_RET_STS_RECURSION_ERROR			CONSTANT VARCHAR2(1)   :=  'R';
  G_RET_STS_PRM_MISMATCH_ERROR			CONSTANT VARCHAR2(1)   :=  'P';


  /** SBALASHA001 -
		INFO: Subtype defined for calling EVA APIs **/
  SUBTYPE CtxParameter_rec IS OKL_FORMULAEVALUATE_PVT.CtxParameter_rec;
  SUBTYPE CtxParameter_tbl IS OKL_FORMULAEVALUATE_PVT.CtxParameter_tbl;

  /** SBALASHA001 -
		INFO: Record to hold id. **/
  TYPE fmaopd_rec IS RECORD (
				id	NUMBER
  );

  /** SBALASHA001 -
		INFO: Table to hold fmaopd_rec records. **/
  TYPE FmaOpd_tbl IS TABLE OF fmaopd_rec INDEX BY BINARY_INTEGER;



  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

   PROCEDURE VAL_ValidateFormula(
    p_api_version                  IN NUMBER
    ,p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
	,x_validate_status				OUT NOCOPY VARCHAR2
    ,p_fma_id                     IN NUMBER
    ,p_cgr_id                     IN NUMBER);

END OKL_FORMULAVALIDATE_PVT;

 

/
