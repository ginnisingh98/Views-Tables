--------------------------------------------------------
--  DDL for Package OKL_EXECUTE_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EXECUTE_FORMULA_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLRFMLS.pls 120.1 2005/06/13 23:58:52 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_EXECUTE_FORMULA_PVT';
  G_INVALID_FORMULA           CONSTANT VARCHAR2(200) := 'OKL_INVALID_FORMULA';
  G_FORMULAE_NO_DML           CONSTANT VARCHAR2(200) := 'OKL_FORMULAE_NO_DML';
  G_INVALID_FORMULA_OPERAND   CONSTANT VARCHAR2(200) := 'OKL_INVALID_FORMULA_OPERAND';
  G_INVALID_OPERAND           CONSTANT VARCHAR2(200) := 'OKL_INVALID_OPERAND';
  G_INVALID_FUNCTION          CONSTANT VARCHAR2(200) := 'OKL_INVALID_FUNCTION';
  G_NO_CONSTANT_OPERAND       CONSTANT VARCHAR2(200) := 'OKL_NO_CONSTANT_FOR_OPERAND';
  G_NO_CONSTANT_FUNCTION      CONSTANT VARCHAR2(200) := 'OKL_NO_CONSTANT_FOR_FUNCTION';
  G_INVALID_FMLA_IN_OPERAND   CONSTANT VARCHAR2(200) := 'OKL_INVALID_FMLA_IN_OPERAND';
  G_VALUE_ERROR               CONSTANT VARCHAR2(200) := 'OKL_FORMULA_VALUE_ERROR';
  G_FUNCTION_DATA_INVALID     CONSTANT VARCHAR2(200) := 'OKL_FUNCTION_DATA_INVALID';
  G_OPERAND_DATA_INVALID      CONSTANT VARCHAR2(200) := 'OKL_OPERAND_DATA_INVALID';
  G_FUNCTION_DOES_NOT_EXIST   CONSTANT VARCHAR2(200) := 'OKL_FUNCTION_DOES_NOT_EXIST';
  G_ERROR_IN_EVALUATE_PARAM   CONSTANT VARCHAR2(200) := 'OKL_ERROR_IN_EVALUATE_PARAM';
  G_DB_ERROR             CONSTANT VARCHAR2(30)  := 'OKL_DB_ERROR';

  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(30)  := 'PROG_NAME';

  G_EXCEPTION_HALT_PROCESSING EXCEPTION;
  G_EXCEPTION_ERROR           EXCEPTION;

  --  Type Declarations

  TYPE operand_val_rec_type IS RECORD(id      okl_operands_v.id%TYPE
                                     ,label   okl_fmla_oprnds.label%TYPE
                                     ,value   okl_fnctn_prmtrs_v.value%TYPE
                                     );
  TYPE operand_val_tbl_type IS TABLE OF operand_val_rec_type
      INDEX BY BINARY_INTEGER;

  TYPE ctxt_val_rec_type IS RECORD(name   okl_context_groups_v.name%TYPE
                                  ,value  okl_fnctn_prmtrs_v.value%TYPE
                                  );
  TYPE ctxt_val_tbl_type IS TABLE OF ctxt_val_rec_type
    INDEX BY BINARY_INTEGER;

  G_ADDITIONAL_PARAMETERS         ctxt_val_tbl_type;
  G_ADDITIONAL_PARAMETERS_NULL    ctxt_val_tbl_type;


  SUBTYPE ctxt_parameter_tbl_type IS okl_formulaevaluate_pub.ctxparameter_tbl;

  PROCEDURE execute(p_api_version           IN  NUMBER
                   ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status         OUT NOCOPY VARCHAR2
                   ,x_msg_count             OUT NOCOPY NUMBER
                   ,x_msg_data              OUT NOCOPY VARCHAR2
                   ,p_formula_name          IN  okl_formulae_v.name%TYPE
                   ,p_contract_id           IN  okl_k_headers_v.id%TYPE
                   ,p_line_id               IN  okl_k_lines_v.id%TYPE DEFAULT NULL
                   ,p_additional_parameters IN  ctxt_val_tbl_type DEFAULT g_additional_parameters_null
                   ,x_value                 OUT NOCOPY NUMBER
                   );

  PROCEDURE execute(p_api_version              IN  NUMBER
                   ,p_init_msg_list            IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status            OUT NOCOPY VARCHAR2
                   ,x_msg_count                OUT NOCOPY NUMBER
                   ,x_msg_data                 OUT NOCOPY VARCHAR2
                   ,p_formula_name             IN  okl_formulae_v.name%TYPE
                   ,p_contract_id              IN  okl_k_headers_v.id%TYPE
                   ,p_line_id                  IN  okl_k_lines_v.id%TYPE DEFAULT NULL
                   ,p_additional_parameters    IN  ctxt_val_tbl_type DEFAULT g_additional_parameters_null
                   ,x_operand_val_tbl          OUT NOCOPY operand_val_tbl_type
                   ,x_value                    OUT NOCOPY NUMBER
                   );

   PROCEDURE execute_eligibility_Criteria(p_api_version       IN  NUMBER
                            ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                            ,x_return_status     OUT NOCOPY VARCHAR2
                            ,x_msg_count         OUT NOCOPY NUMBER
                            ,x_msg_data          OUT NOCOPY VARCHAR2
                            ,p_function_name     IN  okl_data_src_fnctns_v.name%TYPE
                            ,x_value             OUT NOCOPY NUMBER
                            );

END OKL_EXECUTE_FORMULA_PVT;

 

/
