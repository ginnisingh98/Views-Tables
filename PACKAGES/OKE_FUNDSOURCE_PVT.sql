--------------------------------------------------------
--  DDL for Package OKE_FUNDSOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FUNDSOURCE_PVT" AUTHID CURRENT_USER as
/* $Header: OKEVKFDS.pls 120.0 2005/05/25 17:46:21 appldev noship $ */


--
-- Global variables
--

G_API_VERSION_NUMBER	CONSTANT	NUMBER 	      := 1.0;
G_PKG_NAME		CONSTANT	VARCHAR2(30)  := 'OKE_FUNDSOURCE_PVT';
G_APP_NAME		CONSTANT	VARCHAR2(3)   := OKE_API.G_APP_NAME;
G_SQLCODE_TOKEN		CONSTANT	VARCHAR2(200) := 'SQLcode';
G_SQLERRM_TOKEN		CONSTANT	VARCHAR2(200) := 'SQLerrm';
G_UNEXPECTED_ERROR	CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';
G_OBJECT_TYPE		CONSTANT	VARCHAR2(30)  := 'OKE_K_HEADERS';
G_PRODUCT_CODE		CONSTANT	VARCHAR2(3)   := 'OKE';
G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
G_RESOURCE_BUSY			EXCEPTION;
PRAGMA EXCEPTION_INIT(G_RESOURCE_BUSY, -54);


--
-- Funding_Rec_In_Type
--

TYPE funding_rec_in_type is RECORD
(funding_source_id	NUMBER		:= OKE_API.G_MISS_NUM	,
 object_type		VARCHAR(30)	:= OKE_API.G_MISS_CHAR	,
 object_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 pool_party_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 k_party_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 customer_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 customer_number	VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 amount			NUMBER		:= OKE_API.G_MISS_NUM	,
 hard_limit		NUMBER		:= OKE_API.G_MISS_NUM	,
 funding_status		VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 currency_code		VARCHAR2(15)	:= OKE_API.G_MISS_CHAR	,
 k_conversion_type	VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 k_conversion_date	DATE		:= OKE_API.G_MISS_DATE  ,
 k_conversion_rate      NUMBER		:= OKE_API.G_MISS_NUM	,
 start_date_active	DATE		:= OKE_API.G_MISS_DATE  ,
 end_date_active	DATE		:= OKE_API.G_MISS_DATE  ,
-- agreement_flag		VARCHAR2(1)	:= OKE_API.G_MISS_CHAR	,
 agreement_number	VARCHAR2(50)	:= OKE_API.G_MISS_CHAR	,
-- oke_desc_flex_name	VARCHAR2(240)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute_category	VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute1		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute2		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute3		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute4		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute5		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute6		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute7		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute8		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute9		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute10	VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute11	VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute12	VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute13	VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute14	VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 oke_attribute15	VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute_category	VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute1		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute2		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute3		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute4		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute5		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute6		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute7		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute8		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute9		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute10		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 revenue_hard_limit	NUMBER		:= OKE_API.G_MISS_NUM	,
 agreement_org_id	NUMBER		:= OKE_API.G_MISS_NUM
);


--
-- Funding_Rec_Out_Type
--

TYPE funding_rec_out_type is RECORD
(funding_source_id	NUMBER		:= OKE_API.G_MISS_NUM	,
 return_status		VARCHAR2(1)	:= OKE_API.G_MISS_CHAR
);


--
-- Procedure: create_funding
--
-- Description: This procedure is used to insert record in OKE_K_FUNDING_SOURCES table
--
--

PROCEDURE create_funding(p_api_version		IN		NUMBER						,
   			 p_init_msg_list	IN    		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count		OUT   NOCOPY	NUMBER						,
   			 p_msg_data		OUT   NOCOPY	VARCHAR2					,
		         p_funding_in_rec	IN		FUNDING_REC_IN_TYPE				,
			 p_funding_out_rec	OUT   NOCOPY	FUNDING_REC_OUT_TYPE				,
			 p_return_status	OUT   NOCOPY	VARCHAR2
			);


--
-- Procedure: update_funding
--
-- Description: This procedure is used to update record in OKE_FUNDING_SOURCES table
--
--

PROCEDURE update_funding(p_api_version		IN		NUMBER						,
   			 p_init_msg_list	IN      	VARCHAR2 := OKE_API.G_FALSE			,
   			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count		OUT   NOCOPY	NUMBER						,
   			 p_msg_data		OUT   NOCOPY	VARCHAR2					,
   			 p_funding_in_rec	IN		FUNDING_REC_IN_TYPE				,
			 p_funding_out_rec	OUT   NOCOPY	FUNDING_REC_OUT_TYPE				,
			 p_return_status	OUT   NOCOPY	VARCHAR2
			);


--
-- Procedure: delete_funding
--
-- Description: This procedure is used to delete record in OKE_K_FUNDING_SOURCES and PA_PROJECT_FUNDINGS tables
--
--

PROCEDURE delete_funding(p_api_version		IN		NUMBER						,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_init_msg_list	IN      	VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count		OUT   NOCOPY	NUMBER						,
   			 p_msg_data		OUT   NOCOPY	VARCHAR2					,
			 p_funding_source_id	IN		NUMBER						,
		--	 p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE			,
			 p_return_status	OUT   NOCOPY	VARCHAR2
			);


--
-- Procedure: fetch_create_funding
--
-- Description: This procedure is used to get the existing agreement record
--		and create a funding record in OKE
--
--

PROCEDURE fetch_create_funding(p_init_msg_list			IN		VARCHAR2 := OKE_API.G_FALSE	,
			       p_api_version			IN		NUMBER				,
			       p_msg_count			OUT   NOCOPY	NUMBER				,
   			       p_msg_data			OUT   NOCOPY	VARCHAR2			,
			       p_commit				IN		VARCHAR2 := OKE_API.G_FALSE	,
			       p_pool_party_id			IN		NUMBER				,
			       p_customer_id			IN		NUMBER				,
			       p_customer_number		IN		VARCHAR2			,
			       --p_pool_currency			IN 	VARCHAR2			,
			       --p_source_currency		IN		VARCHAR2			,
			       p_party_id			IN		NUMBER				,
			       p_agreement_id			IN     		NUMBER				,
			       p_org_id				IN      	NUMBER				,
			       p_agreement_number		IN		VARCHAR2			,
			       p_agreement_type			IN		VARCHAR2			,
			       p_amount				IN		NUMBER				,
			       p_revenue_limit_flag		IN		VARCHAR2			,
			       p_agreement_currency		IN 		VARCHAR2			,
			       p_expiration_date		IN		DATE				,
			       p_conversion_type		IN 		VARCHAR2			,
			       p_conversion_date		IN		DATE				,
			       p_conversion_rate		IN		NUMBER				,
			       --p_pa_conversion_type		IN		VARCHAR2			,
			       --p_pa_conversion_date		IN		DATE				,
			       --p_pa_conversion_rate		IN		NUMBER				,
			       p_k_header_id			IN		NUMBER				,
			       p_pa_attribute_category		IN		VARCHAR2			,
			       p_pa_attribute1			IN		VARCHAR2			,
			       p_pa_attribute2			IN		VARCHAR2			,
			       p_pa_attribute3			IN		VARCHAR2			,
			       p_pa_attribute4			IN		VARCHAR2			,
			       p_pa_attribute5			IN		VARCHAR2			,
			       p_pa_attribute6			IN		VARCHAR2			,
			       p_pa_attribute7			IN		VARCHAR2			,
			       p_pa_attribute8			IN		VARCHAR2			,
			       p_pa_attribute9			IN		VARCHAR2			,
			       p_pa_attribute10			IN		VARCHAR2			,
  			       p_owning_organization_id		IN		NUMBER				,
  			       p_invoice_limit_flag		IN		VARCHAR2			,
  			      -- p_functional_currency_code	IN		VARCHAR2			,
  			      -- p_allow_currency_update		IN	VARCHAR2			,
			       p_funding_source_id		OUT   NOCOPY	NUMBER				,
			       p_return_status			OUT   NOCOPY	VARCHAR2
			      );


PROCEDURE fetch_create_funding(p_init_msg_list			IN		VARCHAR2 := OKE_API.G_FALSE	,
			       p_api_version			IN		NUMBER				,
			       p_msg_count			OUT   NOCOPY	NUMBER				,
   			       p_msg_data			OUT   NOCOPY	VARCHAR2			,
			       p_commit				IN		VARCHAR2 := OKE_API.G_FALSE	,
			       p_pool_party_id			IN		NUMBER				,
			       p_party_id			IN		NUMBER				,
			      -- p_source_currency		IN		VARCHAR2			,
			       p_agreement_id			IN      	NUMBER				,
			       p_conversion_type		IN 		VARCHAR2			,
			       p_conversion_date		IN		DATE				,
			       p_conversion_rate		IN 		NUMBER				,
			       --p_pa_conversion_type		IN		VARCHAR2			,
			       --p_pa_conversion_date		IN		DATE				,
			      -- p_pa_conversion_rate		IN		NUMBER				,
			       p_k_header_id			IN		NUMBER				,
			       p_funding_source_id		OUT   NOCOPY	NUMBER				,
			       p_return_status			OUT   NOCOPY	VARCHAR2
			      );


--
-- Function: get_funding_rec
--
-- Description: This function initializes a record of funding_rec_in_type
--

FUNCTION get_funding_rec RETURN FUNDING_REC_IN_TYPE;

end OKE_FUNDSOURCE_PVT;

 

/
