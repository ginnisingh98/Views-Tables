--------------------------------------------------------
--  DDL for Package OKC_RENEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_RENEW_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRRENS.pls 120.0 2005/05/26 09:30:10 appldev noship $ */

-- OKC-OC integration changes, added p_context variable.  This variable
-- should be used to perform validation specific to K renewal from Quote
-- like, prevent renewal if a Quote for K renewal exists.

         Type Renew_in_parameters_rec is RECORD
			(
                   p_contract_id              number,
                   p_contract_number          okc_k_headers_v.contract_number%type,
                   p_contract_version         varchar2(9),
                   p_contract_modifier        okc_k_headers_v.contract_number_modifier%type,
                   p_object_version_number    number,
                   p_new_contract_number      okc_k_headers_v.contract_number%type,
                   p_new_contract_modifier    okc_k_headers_v.contract_number_modifier%type,
                   p_start_date               date,
                   p_end_date                 date,
                   p_orig_start_date          date,
                   p_orig_end_date            date,
                   p_uom_code                 okx_units_of_measure_v.uom_code%type,
                   p_duration                 number,
	           p_context                  varchar2(30) DEFAULT OKC_API.G_MISS_CHAR,
		   p_perpetual_flag           varchar2(1) DEFAULT  OKC_API.G_FALSE
		    );


	   Type Renew_in_parameters_tbl is table of Renew_in_parameters_rec
                INDEX BY BINARY_INTEGER;

       Type Renew_out_parameters_rec is RECORD
	  (
           p_old_Contract_id              number,
           p_new_Contract_id              number
	  );

       Type Renew_out_parameters_tbl is table of Renew_out_parameters_rec
             INDEX BY BINARY_INTEGER;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION      EXCEPTION;
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN       	          CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		          CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			          CONSTANT VARCHAR2(200) := 'OKC_RENEW_PVT';
  G_APP_NAME			          CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_FND_APP			          CONSTANT VARCHAR2(200) :=  OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_DNR_MSG         CONSTANT VARCHAR2(200) := 'OKC_DNR_MSG';

  ---------------------------------------------------------------------------

 g_rulv_rec OKC_RULE_PUB.rulv_rec_type;

--------------------------------------------------------------------------------------------
 -- Auto renew is a concurrent program initiated to renew the contracts automatically for
 -- which auto_renew_days is given
--------------------------------------------------------------------------------------------
/*  Procedure Auto_Renew( errbuf out nocopy varchar2,
**        retcode out nocopy varchar2
** 	      ); */
Procedure Auto_Renew(errbuf out nocopy varchar2,
                     retcode out nocopy varchar2,
                     p_chr_id IN Number Default Null,
                     p_duration IN Number Default Null,
                     p_uom_code IN Varchar2 Default Null,
		     p_renewal_called_from_ui    IN VARCHAR2 DEFAULT 'N', /* added for bugfix 2093117 */
                     p_contract_number IN Varchar2 DEFAULT NULL,
                     p_contract_number_modifier IN VARCHAR2 Default Null
		    );


--------------------------------------------------------------------------------------------
--called from launchpad, it runs through certain validations and returns  status
--------------------------------------------------------------------------------------------
 FUNCTION is_renew_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;

--------------------------------------------------------------------------------------------
--called from renew procedure in public, this procedure actually creates a copy of
--of the contract to be renewed and adjust the dates on the various components of this
--copy
--------------------------------------------------------------------------------------------
 Procedure Create_Renewed_Contract( p_api_version             IN  NUMBER,
		                    p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status           OUT NOCOPY VARCHAR2,
                                    x_msg_count               OUT NOCOPY NUMBER,
                                    x_msg_data                OUT NOCOPY VARCHAR2,
                                    x_contract_id	      OUT NOCOPY NUMBER,
	                            p_renew_in_parameters_rec IN  Renew_in_parameters_rec,
	                            x_renew_in_parameters_rec OUT NOCOPY  Renew_in_parameters_rec,
  		                    p_ren_type                IN  varchar2 DEFAULT OKC_API.G_MISS_CHAR,
		                    p_renewal_called_from_ui  IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
	                          );

--function to validate the line
FUNCTION Validate_line(p_contract_id IN NUMBER) RETURN VARCHAR2;

--------------------------------------------------------------------------------------------
--called from renew procedure in public, this procedure sends the notifiactions
-- and a few other things depending on the renew rule defined on the contract
--------------------------------------------------------------------------------------------
PROCEDURE post_renewed_contract(
                 p_api_version                  IN NUMBER,
       	       p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_renew_chr_id                 IN  number,
	            p_renew_in_parameters_rec      IN  Renew_in_parameters_rec,
	            p_ren_type                     IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
	            p_contact                      IN  VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR);

--------------------------------------------------------------------------------------------
-- this procedure runs the validations on the contract to be renewed
--------------------------------------------------------------------------------------------
 Procedure validate( p_api_version             IN  NUMBER,
		     p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status           OUT NOCOPY VARCHAR2,
                     x_msg_count               OUT NOCOPY NUMBER,
                     x_msg_data                OUT NOCOPY VARCHAR2,
	             p_renew_in_parameters_rec IN	 Renew_in_parameters_rec,
		     p_renewal_called_from_ui  IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
		   );

--------------------------------------------------------------------------------------------
-- sets the notification message to be sent after the renewal
--------------------------------------------------------------------------------------------
PROCEDURE set_notify(
                 x_return_status                OUT NOCOPY  VARCHAR2 ,
                 p_old_k                    IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
                 p_old_mod                    IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
                 p_new_k                    IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
                 p_new_mod                    IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
                 p_qa_stat                    IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
                 p_wf_found                     IN VARCHAR2 DEFAULT 'T',
                 p_subj_msg                     IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR,
	            p_ren_type                     IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR);


-- this procedure is called in the OKCRRENB.pls by OKC but exposed
--outside to be called by OKS renew consolidation
PROCEDURE update_renewal_dates(
                 p_api_version                  IN NUMBER,
       	       p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_chr_id                       IN  number,
	            p_parent_cle_id                IN  number DEFAULT OKC_API.G_MISS_NUM,
	            p_parent_new_st_dt             IN  DATE,
	            p_parent_new_end_dt            IN  DATE,
	            p_parent_old_st_dt             IN  DATE,
	            p_cle_id                       IN NUMBER DEFAULT OKC_API.G_MISS_NUM,
	            p_rencon_yn                    IN  VARCHAR2 DEFAULT 'N');

--------------------------------------------------------------------------------
-- This procedure updates Date_Renewed field in headers and lines table
-- The Date_Renewed field for a line is updated when the Date_Renewed field
-- of all its sublines is not null and is updated by the maximum Date_Renewed
-- of all its sublines. True for all the levels. The contract header
-- Date_Renewed is updated when all it's top lines Date_Renewed is not null
-- and is updated by by the maximum Date_Renewed of all the top lines
--------------------------------------------------------------------------------

Procedure Update_Parents_Date_Renewed( p_api_version        IN  NUMBER,
                                       p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_msg_count          OUT NOCOPY NUMBER,
                                       x_msg_data           OUT NOCOPY VARCHAR2,
                                       p_chr_id             IN NUMBER
                                     );

/* This function is_already_not_renewed added for bugfix 2093117 */

--Bug 3386577 Addedd out parameter
--Bug 3560988 Added p_renewal_called_from_ui with default value as 'Y'

FUNCTION is_already_not_renewed(p_chr_id IN NUMBER, p_contract_number IN VARCHAR2, x_msg_name OUT NOCOPY VARCHAR2, p_renewal_called_from_ui IN VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2;

end OKC_RENEW_PVT;

 

/
