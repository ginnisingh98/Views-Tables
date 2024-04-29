--------------------------------------------------------
--  DDL for Package OKL_FORMULAEVALUATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAEVALUATE_PUB" AUTHID CURRENT_USER AS
  /* $Header: OKLPEVAS.pls 115.2 2002/02/06 20:28:34 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_FORMULAEVALUATE_PUB';


  G_EXCEPTION_HALT_PROCESSING EXCEPTION;

  --  Type Declarations

  SUBTYPE ctxparameter_tbl IS okl_formulaevaluate_pvt.ctxparameter_tbl;
  SUBTYPE function_tbl IS okl_formulaevaluate_pvt.function_tbl;

  PROCEDURE EVA_GetParameterValues(p_api_version   IN  NUMBER
                   ,p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status OUT NOCOPY VARCHAR2
                   ,x_msg_count     OUT NOCOPY NUMBER
                   ,x_msg_data      OUT NOCOPY VARCHAR2
                   ,p_fma_id  IN  okl_formulae_v.id%TYPE
                   ,p_contract_id   IN  okl_k_headers_v.id%TYPE
                   ,x_ctx_parameter_tbl         OUT NOCOPY ctxparameter_tbl
                   ,p_line_id       IN  okl_k_lines_v.id%TYPE DEFAULT NULL );

  PROCEDURE EVA_GetFunctionValue(p_api_version      IN  NUMBER
                   ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status    OUT NOCOPY VARCHAR2
                   ,x_msg_count        OUT NOCOPY NUMBER
                   ,x_msg_data         OUT NOCOPY VARCHAR2
                   ,p_fma_id     IN  okl_formulae_v.id%TYPE
                   ,p_contract_id      IN  okl_k_headers_v.id%TYPE
                   ,p_line_id          IN  okl_k_lines_v.id%TYPE
                   ,p_ctx_parameter_tbl  IN ctxparameter_tbl
                   ,x_function_tbl            OUT NOCOPY function_tbl
                   );

END OKL_FORMULAEVALUATE_PUB;

 

/
