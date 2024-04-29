--------------------------------------------------------
--  DDL for Package OKC_RENEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_RENEW_PUB" AUTHID CURRENT_USER as
/* $Header: OKCPRENS.pls 120.0 2005/05/25 22:49:47 appldev noship $ */


 subtype renew_in_parameters_rec is OKC_RENEW_PVT.renew_in_parameters_rec;
 subtype renew_in_parameters_tbl is OKC_RENEW_PVT.renew_in_parameters_tbl;
 subtype renew_out_parameters_rec is OKC_RENEW_PVT.renew_out_parameters_rec;
 subtype renew_out_parameters_tbl is OKC_RENEW_PVT.renew_out_parameters_tbl;


 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        	CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_RENEW_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

 g_new_contract_id number;
 g_renew_in_parameters_rec Renew_in_parameters_rec;
 g_prerenew_in_parameters_rec Renew_in_parameters_rec;


 -- Procedure Auto_Renew(errbuf out varchar2, retcode out varchar2);

 Procedure Auto_Renew(errbuf out nocopy varchar2,
		      retcode out nocopy varchar2,
		      p_chr_id IN Number Default Null,
		      p_duration IN Number Default Null,
		      p_uom_code IN Varchar2 Default Null,
		      p_renewal_called_from_ui    IN VARCHAR2 DEFAULT 'N',
 /* added for bugfix 2093117 */
                      p_contract_number IN Varchar2 DEFAULT NULL,
                      p_contract_number_modifier IN Varchar2 DEFAULT NULL
		      );

 FUNCTION is_renew_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE PRE_Renew( p_api_version                  IN NUMBER,
    	             p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status                OUT NOCOPY VARCHAR2,
                     x_msg_count                    OUT NOCOPY NUMBER,
                     x_msg_data                     OUT NOCOPY VARCHAR2,
	             p_renew_in_parameters_tbl      IN Renew_in_parameters_tbl,
                     x_renew_out_parameters_tbl     OUT nocopy Renew_out_parameters_tbl,
		     p_do_commit                    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
		     p_renewal_called_from_ui       IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
		     );

PROCEDURE PRE_Renew( p_api_version                  IN NUMBER,
    	             p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status                OUT NOCOPY VARCHAR2,
                     x_msg_count                    OUT NOCOPY NUMBER,
                     x_msg_data                     OUT NOCOPY VARCHAR2,
                     x_contract_id                  OUT NOCOPY number,
	             p_renew_in_parameters_rec      IN Renew_in_parameters_rec,
		     p_do_commit                    IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
		     p_renewal_called_from_ui       IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
		     );


 Procedure Renew( p_api_version                  IN  NUMBER,
		  p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                  x_return_status                OUT NOCOPY VARCHAR2,
                  x_msg_count                    OUT NOCOPY NUMBER,
                  x_msg_data                     OUT NOCOPY VARCHAR2,
	          p_renew_in_parameters_tbl      IN  Renew_in_parameters_tbl,
                  x_renew_out_parameters_tbl     OUT nocopy Renew_out_parameters_tbl,
		  p_do_commit                    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
		  p_renewal_called_from_ui       IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
	       );

 Procedure Renew( p_api_version                 IN NUMBER,
		  p_init_msg_list               IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                  x_return_status               OUT NOCOPY VARCHAR2,
                  x_msg_count                   OUT NOCOPY NUMBER,
                  x_msg_data                    OUT NOCOPY VARCHAR2,
		  x_contract_id			OUT NOCOPY NUMBER,
	          p_renew_in_parameters_rec     IN Renew_in_parameters_rec,
		  p_do_commit                   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
		  p_renewal_called_from_ui      IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */

	       );

FUNCTION Validate_line(p_contract_id IN NUMBER) RETURN VARCHAR2;

Procedure Create_Renewed_Contract( p_api_version            IN  NUMBER,
               			  p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
				  x_return_status           OUT NOCOPY VARCHAR2,
				  x_msg_count               OUT NOCOPY NUMBER,
				  x_msg_data                OUT NOCOPY VARCHAR2,
				  x_contract_id             OUT NOCOPY NUMBER,
				  p_renew_in_parameters_rec IN  Renew_in_parameters_rec,
				  x_renew_in_parameters_rec OUT NOCOPY  Renew_in_parameters_rec,
				  p_ren_type                IN  varchar2 DEFAULT OKC_API.G_MISS_CHAR,
				  p_renewal_called_from_ui  IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
				 );


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

 Procedure validate(
                    p_api_version                  IN  NUMBER,
	  	    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                    x_return_status                OUT NOCOPY VARCHAR2,
                    x_msg_count                    OUT NOCOPY NUMBER,
                    x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_renew_in_parameters_tbl      IN  Renew_in_parameters_tbl,
		    p_renewal_called_from_ui       IN  VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
		   );


 Procedure validate(
                    p_api_version                  IN NUMBER,
		    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                    x_return_status                OUT NOCOPY VARCHAR2,
                    x_msg_count                    OUT NOCOPY NUMBER,
                    x_msg_data                     OUT NOCOPY VARCHAR2,
	            p_renew_in_parameters_rec      IN	Renew_in_parameters_rec,
	            p_renewal_called_from_ui       IN VARCHAR2 DEFAULT 'Y' /* added for bugfix 2093117 */
		   );

 Procedure Update_Parents_Date_Renewed( p_api_version        IN  NUMBER,
                                        p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                        x_return_status      OUT NOCOPY VARCHAR2,
                                        x_msg_count          OUT NOCOPY NUMBER,
                                        x_msg_data           OUT NOCOPY VARCHAR2,
                                        p_chr_id             IN NUMBER
                                      );
 -- Bug 3580442 Overloaded this function since this is used in some of the events.
 FUNCTION is_already_not_renewed(p_chr_id IN NUMBER, p_contract_number IN VARCHAR2) RETURN VARCHAR2;

 -- Bug 3386577 Addedd an OUT parameter.
 FUNCTION is_already_not_renewed(p_chr_id IN NUMBER, p_contract_number IN VARCHAR2, x_msg_name OUT NOCOPY VARCHAR2) RETURN VARCHAR2;


end OKC_RENEW_PUB;

 

/
