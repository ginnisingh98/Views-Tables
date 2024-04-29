--------------------------------------------------------
--  DDL for Package OKL_EXECUTE_FORMULA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EXECUTE_FORMULA_PUB" AUTHID CURRENT_USER AS
  /* $Header: OKLPFMLS.pls 120.4 2008/02/29 10:53:31 asawanka ship $ */
/*#
* Execute Formula API validates and executes the formula using the parameters
* and returns the value.
* @rep:scope public
* @rep:product OKL
* @rep:displayname Execute Formula API
* @rep:category BUSINESS_ENTITY OKL_EXECUTE_FORMULA
* @rep:lifecycle active
* @rep:compatibility S
*/


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';

  G_APP_NAME		      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_EXECUTE_FORMULA_PUB';
  --  Type Declarations

  SUBTYPE operand_val_tbl_type IS okl_execute_formula_pvt.operand_val_tbl_type;
  SUBTYPE ctxt_val_tbl_type IS okl_execute_formula_pvt.ctxt_val_tbl_type;
  SUBTYPE ctxt_parameter_tbl_type IS okl_formulaevaluate_pub.ctxparameter_tbl;



  G_ADDITIONAL_PARAMETERS      ctxt_val_tbl_type;
  G_ADDITIONAL_PARAMETERS_NULL ctxt_val_tbl_type;


/*#
 * Execute formula for a lease contract.
 * @param P_API_VERSION api version
 * @param P_INIT_MSG_LIST  initialize message stack
 * @param X_RETURN_STATUS  return status from the api
 * @param X_MSG_COUNT  Message count if error messages are encountered
 * @param X_MSG_DATA  Message date error message
 * @param P_FORMULA_NAME Name of the formula to be executed
 * @param P_CONTRACT_ID Contract identifier
 * @param P_LINE_ID Contract line identifier
 * @param P_ADDITIONAL_PARAMETERS  Additional parameters required to
 * execute the formula
 * @param X_VALUE VALUE RETURNED BY THE FORMULA
 * @rep:displayname EXECUTE FORMULA
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
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

/*#
 * Execute formula for a Lease contract.
 * @param p_api_version API Version
 * @param p_init_msg_list  Initialize the Message Stack
 * @param x_return_status  Return Status from the API
 * @param x_msg_count  Message Count if Error messages are encountered.
 * @param x_msg_data  Message Date Error Message
 * @param p_formula_name Name of the formula to be executed
 * @param p_contract_id Contract Identifier
 * @param p_line_id Contract Line Identifier
 * @param p_additional_parameters Any additional parameters required
 * to execute the formula
 * @param x_operand_val_tbl Value of operands returned by the formula
 * @param x_value Value returned by the formula
 * @rep:displayname Execute Formula
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT_LIFECYCLE
 */
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


END OKL_EXECUTE_FORMULA_PUB;

/
