--------------------------------------------------------
--  DDL for Package OKL_LA_VALIDATION_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_VALIDATION_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: OKLPDVUS.pls 120.2 2006/11/13 07:33:37 dpsingh noship $ */

--Start of Comments
--API Name    : okl_la_validation_util_pvt
--Description : Fetches item meta data
--End of Comments

---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
G_SERVICED_ASSET_LTY_CODE CONSTANT VARCHAR2(15)   :=  'LINK_SERV_ASSET';
G_FEE_ASSET_LTY_CODE CONSTANT VARCHAR2(15)   :=  'LINK_FEE_ASSET';
G_SERVICE_LTY_CODE CONSTANT VARCHAR2(12)   :=  'SOLD_SERVICE';
G_FEE_LTY_CODE CONSTANT VARCHAR2(12)   :=  'FEE';
G_INVALID_VALUE           CONSTANT  VARCHAR2(2000) := 'OKL_CONTRACTS_INVALID_VALUE';
G_PKG_NAME  CONSTANT VARCHAR2(200) := 'okl_la_validation_util_pvt';
G_APP_NAME  CONSTANT VARCHAR2(3) :=  OKL_API.G_APP_NAME;
G_API_TYPE  CONSTANT VARCHAR2(4) := '_PVT';
G_COL_NAME_TOKEN          CONSTANT  VARCHAR2(2000) := OKL_API.G_COL_NAME_TOKEN;
-- SUBTYPE chrv_rec_type IS		OKL_OKC_MIGRATION_PVT.chrv_rec_type;
-- SUBTYPE khrv_rec_type IS		OKL_CONTRACT_PUB.khrv_rec_type;


Procedure Get_Rule_Jtot_Metadata (p_api_version    IN	NUMBER,
                     p_init_msg_list	   IN	    VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT      NOCOPY	VARCHAR2,
                     x_msg_count	   OUT      NOCOPY	NUMBER,
                     x_msg_data	           OUT      NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	    NUMBER,
                     p_rgd_code            IN       VARCHAR2,
                     p_rdf_code            IN       VARCHAR2,
                     p_name                IN       VARCHAR2,
                     p_id1                 IN       VARCHAR2,
                     p_id2                 IN       VARCHAR2,
                     x_select_clause       OUT   NOCOPY   VARCHAR2,
                     x_from_clause         OUT   NOCOPY   VARCHAR2,
                     x_where_clause        OUT   NOCOPY   VARCHAR2,
                     x_order_by_clause     OUT   NOCOPY   VARCHAR2,
                     x_object_code         OUT   NOCOPY   VARCHAR2);

--Added by dpsingh for LE Uptake
Procedure Validate_Legal_Entity(x_return_status      OUT    NOCOPY    VARCHAR2,
                                                 p_chrv_rec             IN        OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE,
						 p_mode IN VARCHAR2);

Procedure Validate_Rule (p_api_version     IN	NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_rgd_code            IN   VARCHAR2,
                     p_rdf_code            IN   VARCHAR2,
                     p_id1            	   IN OUT NOCOPY VARCHAR2,
                     p_id2                 IN OUT NOCOPY VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_object_code         IN OUT  NOCOPY VARCHAR2,
                     p_ak_region          IN    VARCHAR2,
                     p_ak_attribute         IN    VARCHAR2
                     );


Procedure Validate_Contact (p_api_version     IN	NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_rle_code            IN   VARCHAR2,
                     p_cro_code            IN   VARCHAR2,
                     p_id1            	   IN OUT NOCOPY VARCHAR2,
                     p_id2                 IN OUT NOCOPY VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_object_code         IN OUT NOCOPY  VARCHAR2,
                     p_ak_region          IN    VARCHAR2,
                     p_ak_attribute         IN    VARCHAR2
                     );


Procedure Validate_Link_Asset (p_api_version     IN	NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_parent_cle_id       IN	NUMBER,
                     p_id1            	   IN OUT  NOCOPY VARCHAR2,
                     p_id2                 IN OUT  NOCOPY VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_object_code         IN   VARCHAR2);


Procedure Validate_Party (p_api_version     IN	NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_cle_id       	   IN	NUMBER,
                     p_cpl_id       	   IN	NUMBER,
                     p_lty_code            IN	VARCHAR2,
                     p_rle_code            IN	VARCHAR2,
                     p_id1            	   IN OUT NOCOPY VARCHAR2,
                     p_id2                 IN OUT NOCOPY VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_object_code         IN   VARCHAR2);


Procedure Get_Party_Jtot_data (p_api_version     IN	NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_scs_code            IN	VARCHAR2,
                     p_buy_or_sell         IN	VARCHAR2,
                     p_rle_code            IN	VARCHAR2,
                     p_id1            	   IN OUT NOCOPY VARCHAR2,
                     p_id2                 IN OUT NOCOPY VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_object_code         IN OUT  NOCOPY VARCHAR2,
                     p_ak_region           IN    VARCHAR2,
                     p_ak_attribute        IN    VARCHAR2
                     );

PROCEDURE  validate_deal(
		    p_api_version                  IN NUMBER,
		    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
		    x_return_status                OUT NOCOPY VARCHAR2,
		    x_msg_count                    OUT NOCOPY NUMBER,
		    x_msg_data                     OUT NOCOPY VARCHAR2,
		    p_chr_id			   IN NUMBER,
		    p_scs_code			   IN VARCHAR2,
		    p_contract_number	           IN VARCHAR2,
		    p_customer_id1                 IN OUT NOCOPY VARCHAR2,
		    p_customer_id2                 IN OUT NOCOPY VARCHAR2,
		    p_customer_code                IN OUT NOCOPY VARCHAR2,
		    p_customer_name                IN  VARCHAR2,
		    p_chr_cust_acct_id             OUT NOCOPY NUMBER,
		    p_customer_acc_name            IN  VARCHAR2,
		    p_product_name                 IN  VARCHAR2,
		    p_product_id                   IN OUT NOCOPY VARCHAR2,
		    p_product_desc                 IN OUT NOCOPY VARCHAR2,
		    p_contact_id1                  IN OUT NOCOPY VARCHAR2,
		    p_contact_id2                  IN OUT NOCOPY VARCHAR2,
		    p_contact_code                 IN OUT NOCOPY VARCHAR2,
		    p_contact_name                 IN  VARCHAR2,
 		    p_mla_no                       IN  VARCHAR2,
		    p_mla_id                       IN OUT NOCOPY VARCHAR2,
		    p_program_no                   IN  VARCHAR2,
		    p_program_id                   IN OUT NOCOPY VARCHAR2,
		    p_credit_line_no               IN  VARCHAR2,
		    p_credit_line_id               IN OUT NOCOPY VARCHAR2,
		    p_currency_name                IN  VARCHAR2,
		    p_currency_code                IN OUT NOCOPY VARCHAR2,
		    p_start_date                   IN  DATE,
		    p_deal_type                    IN  VARCHAR2
		    );

Procedure Validate_Service (p_api_version  IN   NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_cle_id              IN	NUMBER,
                     p_lty_code            IN   VARCHAR2,
                     p_item_id1            IN OUT NOCOPY VARCHAR2,
                     p_item_id2            IN OUT NOCOPY VARCHAR2,
                     p_item_name           IN   VARCHAR2,
                     p_item_object_code    IN OUT NOCOPY VARCHAR2,
                     p_cpl_id       	   IN	NUMBER,
                     p_rle_code            IN	VARCHAR2,
                     p_party_id1      	   IN OUT NOCOPY VARCHAR2,
                     p_party_id2           IN OUT NOCOPY VARCHAR2,
                     p_party_name          IN   VARCHAR2,
                     p_party_object_code   IN OUT NOCOPY VARCHAR2,
                     p_amount              IN NUMBER
                     );

Procedure Validate_Fee (p_api_version  IN   NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_cle_id              IN	NUMBER,
                     p_lty_code            IN   VARCHAR2,
                     p_item_id1            IN OUT NOCOPY VARCHAR2,
                     p_item_id2            IN OUT NOCOPY VARCHAR2,
                     p_item_name           IN   VARCHAR2,
                     p_item_object_code    IN OUT NOCOPY VARCHAR2,
                     p_cpl_id       	   IN	NUMBER,
                     p_rle_code            IN	VARCHAR2,
                     p_party_id1      	   IN OUT NOCOPY VARCHAR2,
                     p_party_id2           IN OUT NOCOPY VARCHAR2,
                     p_party_name          IN   VARCHAR2,
                     p_party_object_code   IN OUT NOCOPY VARCHAR2,
                     p_amount              IN NUMBER
                     );

Procedure Validate_Fee (p_api_version  IN   NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_cle_id              IN	NUMBER,
                     p_amount              IN NUMBER,
                     p_init_direct_cost    IN NUMBER
                     );

PROCEDURE  VALIDATE_ROLE_JTOT (p_api_version  	   IN   NUMBER,
                               p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                               x_return_status	   OUT  NOCOPY	VARCHAR2,
                               x_msg_count	   OUT  NOCOPY	NUMBER,
                               x_msg_data	         OUT  NOCOPY	VARCHAR2,
                               p_object_name    IN VARCHAR2,
                               p_id1            IN VARCHAR2,
                               p_id2            IN VARCHAR2);


PROCEDURE  VALIDATE_CONTACT_JTOT (p_api_version  	   IN   NUMBER,
                                  p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                                  x_return_status	   OUT  NOCOPY	VARCHAR2,
                                  x_msg_count	   OUT  NOCOPY	NUMBER,
                                  x_msg_data	         OUT  NOCOPY	VARCHAR2,
                                  p_object_name    IN VARCHAR2,
                                  p_id1            IN VARCHAR2,
                                  p_id2            IN VARCHAR2);


PROCEDURE  VALIDATE_STYLE_JTOT (p_api_version  	   IN   NUMBER,
                               p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                               x_return_status	   OUT  NOCOPY	VARCHAR2,
                               x_msg_count	   OUT  NOCOPY	NUMBER,
                               x_msg_data	         OUT  NOCOPY	VARCHAR2,
                               p_object_name    IN VARCHAR2,
                               p_id1            IN VARCHAR2,
                               p_id2            IN VARCHAR2);

Procedure validate_crdtln_wrng (p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER
                     );

Procedure validate_crdtln_err (p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER
                     );

Procedure validate_creditline (p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER,
                     p_deal_type           IN   VARCHAR2,
                     p_mla_no              IN   VARCHAR2,
                     p_cl_no               IN   VARCHAR2);



end okl_la_validation_util_pvt;

/
