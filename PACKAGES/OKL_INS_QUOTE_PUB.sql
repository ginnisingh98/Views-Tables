--------------------------------------------------------
--  DDL for Package OKL_INS_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_QUOTE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPINQS.pls 120.8 2008/02/29 10:49:58 nikshah ship $ */
/*#
 * Insurance Quote API creates insurance quotes and policies for a contract.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Insurance Quote
 * @rep:category BUSINESS_ENTITY OKL_RISK_MANAGEMENT
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  SUBTYPE ipyv_rec_type IS Okl_Ipy_Pvt.ipyv_rec_type;
  SUBTYPE iasset_tbl_type IS Okl_Ins_Quote_Pvt.iasset_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'Okl_Ins_Quote_Pub';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';
  G_API_TYPE                      CONSTANT VARCHAR2(30)  := '_PUB';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------

/*#
 * Insurance Quote API creates an optional or lease insurance for a contract.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param px_ipyv_rec Record type of quote details
 * @param x_message Stage of process
 * @rep:displayname Create Insurance Quote
 * @rep:scope public
 * @rep:lifecycle active
 */
 PROCEDURE save_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     px_ipyv_rec                     IN OUT NOCOPY ipyv_rec_type,
    x_message                      OUT NOCOPY VARCHAR2  );
-- Need to have second procedure
-- so that we don't need to recalculate

  PROCEDURE save_accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN  ipyv_rec_type,
     x_message                      OUT NOCOPY  VARCHAR2  );

-- Need to have second procedure
-- so that we don't need to recalculate

/*#
 * Insurance Quote API accepts lease or optional quote and creates policy.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_quote_id Insurance quote identifier
 * @rep:displayname Accept Insurance Quote
 * @rep:scope public
 * @rep:lifecycle active
 */
  PROCEDURE accept_quote(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_quote_id                     IN NUMBER );


PROCEDURE   create_ins_streams(
         p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         );

/*#
 * Insurance Quote API calculates the premium for lease insurance.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param px_ipyv_rec Record type of quote details
 * @param x_message Stage of process
 * @param x_iasset_tbl Premium for each contract financial line
 * @rep:displayname Calculate Lease Insurance Premium
 * @rep:scope public
 * @rep:lifecycle active
 */
	      PROCEDURE   calc_lease_premium(
         p_api_version                   IN NUMBER,
		 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         px_ipyv_rec                    IN OUT NOCOPY ipyv_rec_type,
	     x_message                  OUT NOCOPY VARCHAR2,
         x_iasset_tbl                  OUT  NOCOPY iasset_tbl_type
     );
/*#
 * Insurance Quote API calculates the premium for optional insurance.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_ipyv_rec Record type of quote details
 * @param x_message Stage of process.
 * @param x_ipyv_rec Record type of quote details with calculated premium
 * @rep:displayname Calculate Optional Insurance Premium
 * @rep:scope public
 * @rep:lifecycle active
 */
	 	      PROCEDURE   calc_optional_premium(
         p_api_version                   IN NUMBER,
		 p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                     IN  ipyv_rec_type,
	     x_message                  OUT NOCOPY VARCHAR2,
         x_ipyv_rec                  OUT  NOCOPY ipyv_rec_type
     );
--Skgautam Bug 3967640
 PROCEDURE calc_total_premium(p_api_version                  IN NUMBER,
                             p_init_msg_list                IN VARCHAR2 ,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_pol_qte_id                   IN  VARCHAR2,
                             x_total_premium                OUT NOCOPY NUMBER);

		 PROCEDURE  activate_ins_stream(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type
         );

PROCEDURE  activate_ins_streams(
	errbuf           OUT NOCOPY VARCHAR2,
	retcode          OUT NOCOPY NUMBER
 );

 PROCEDURE  activate_ins_streams(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_contract_id                  IN NUMBER
         );

/*#
 * Insurance Quote API activates lease insurance policy.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Message data error message
 * @param p_ins_policy_id Insurance policy identifier
 * @rep:displayname Activate Insurance Policy
 * @rep:scope public
 * @rep:lifecycle active
 */
	PROCEDURE   activate_ins_policy(
         p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ins_policy_id                     IN NUMBER
         );

     PROCEDURE  create_third_prt_ins(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                  IN   ipyv_rec_type,
     x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
         );
-- Bug: 4567777 PAGARG new procedures for Lease Application Functionality.
     PROCEDURE crt_lseapp_thrdprt_ins(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY  VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_ipyv_rec                     IN ipyv_rec_type,
     x_ipyv_rec                     OUT NOCOPY ipyv_rec_type);

     PROCEDURE lseapp_thrdprty_to_ctrct(
     p_api_version                   IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_lakhr_id                     IN NUMBER,
     x_ipyv_rec                     OUT NOCOPY ipyv_rec_type);

END Okl_Ins_Quote_Pub;

/
