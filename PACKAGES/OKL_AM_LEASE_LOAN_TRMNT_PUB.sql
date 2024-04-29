--------------------------------------------------------
--  DDL for Package OKL_AM_LEASE_LOAN_TRMNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_LEASE_LOAN_TRMNT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPLLTS.pls 120.4 2008/02/29 10:13:35 veramach ship $ */
/*#
 * Terminate API terminates the lease or loan contract.
 * @rep:scope internal
 * @rep:product OKL
 * @rep:displayname Termination API
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT
 * @rep:lifecycle active
 * @rep:compatibility S
 */



 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_LEASE_LOAN_TRMNT_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


  SUBTYPE tcnv_rec_type IS OKL_AM_LEASE_LOAN_TRMNT_PVT.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS OKL_AM_LEASE_LOAN_TRMNT_PVT.tcnv_tbl_type;
  SUBTYPE term_rec_type IS OKL_AM_LEASE_LOAN_TRMNT_PVT.term_rec_type;
  SUBTYPE term_tbl_type IS OKL_AM_LEASE_LOAN_TRMNT_PVT.term_tbl_type;

  PROCEDURE validate_contract(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_contract_id                 IN  NUMBER,
           p_control_flag                IN  VARCHAR2,
           x_contract_status             OUT NOCOPY VARCHAR2);
/*#
 * Termination API supports the partial or full termination of a lease or
 * loan contract.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_term_rec Record type of termination quote details
 * @param p_tcnv_rec Record type of contract details for termination
 * @rep:displayname Terminate Contract
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT
 */

  PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type);


/*#
 * Termination API supports the partial or full termination of multiple
 * lease or loan contracts.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_term_tbl Table of records of termination quote details for termination
 * @param p_tcnv_tbl Table of records of contract details for termination
 * @rep:displayname Terminate Contract
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_CONTRACT
 */


  PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_tbl                    IN  term_tbl_type,
           p_tcnv_tbl                    IN  tcnv_tbl_type);


END OKL_AM_LEASE_LOAN_TRMNT_PUB;

/
