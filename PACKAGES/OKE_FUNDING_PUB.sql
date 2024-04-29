--------------------------------------------------------
--  DDL for Package OKE_FUNDING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FUNDING_PUB" AUTHID CURRENT_USER as
/* $Header: OKEPKFDS.pls 120.0.12000000.1 2007/01/17 06:52:10 appldev ship $ */

--
-- Package constants
--

G_API_VERSION_NUMBER	CONSTANT	NUMBER        := 1.0;
G_PKG_NAME		CONSTANT	VARCHAR2(40)  := 'OKE_FUNDING_PUB';
G_PRODUCT_CODE		CONSTANT	VARCHAR2(3)   := 'OKE';
G_APP_NAME		CONSTANT	VARCHAR2(3)   := OKE_API.G_APP_NAME;
G_SQLCODE_TOKEN		CONSTANT	VARCHAR2(200) := 'SQLcode';
G_SQLERRM_TOKEN		CONSTANT	VARCHAR2(200) := 'SQLerrm';
G_UNEXPECTED_ERROR	CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';
G_EXCEPTION_HALT_VALIDATION		EXCEPTION;

SUBTYPE funding_rec_in_type IS OKE_FUNDSOURCE_PVT.funding_rec_in_type;
SUBTYPE funding_rec_out_type IS OKE_FUNDSOURCE_PVT.funding_rec_out_type;

SUBTYPE allocation_rec_in_type IS OKE_ALLOCATION_PVT.allocation_rec_in_type;
SUBTYPE allocation_rec_out_type IS OKE_ALLOCATION_PVT.allocation_rec_out_type;

SUBTYPE allocation_in_tbl_type IS OKE_ALLOCATION_PVT.allocation_in_tbl_type;
SUBTYPE allocation_out_tbl_type IS OKE_ALLOCATION_PVT.allocation_out_tbl_type;


--
-- Procedure: create_funding
--
-- Description: create funding records in OKE and agreement records in PA if agreement_flag is true
--
--

PROCEDURE create_funding(p_api_version		IN 		NUMBER				,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 x_return_status	OUT  NOCOPY	VARCHAR2			,
			 x_msg_count		OUT  NOCOPY	NUMBER				,
			 x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_agreement_type	IN		VARCHAR2 			,
			 p_funding_in_rec	IN		FUNDING_REC_IN_TYPE		,
			 x_funding_out_rec	OUT  NOCOPY	FUNDING_REC_OUT_TYPE		,
			 p_allocation_in_tbl	IN		ALLOCATION_IN_TBL_TYPE		,
			 x_allocation_out_tbl	OUT  NOCOPY	ALLOCATION_OUT_TBL_TYPE
			);


--
-- Procedure: update_funding
--
-- Description: update funding records in OKE and agreement records in PA if agreement_flag is true
--
--

PROCEDURE update_funding(p_api_version		IN 		NUMBER				,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 x_return_status	OUT  NOCOPY	VARCHAR2			,
			 x_msg_count		OUT  NOCOPY	NUMBER				,
			 x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_agreement_type	IN		VARCHAR2 			,
			 p_funding_in_rec	IN		FUNDING_REC_IN_TYPE		,
			 x_funding_out_rec	OUT  NOCOPY	FUNDING_REC_OUT_TYPE		,
			 p_allocation_in_tbl	IN		ALLOCATION_IN_TBL_TYPE		,
			 x_allocation_out_tbl	OUT  NOCOPY	ALLOCATION_OUT_TBL_TYPE
			);

--
-- Procedure: delete_funding
--
-- Description: delete funding records in OKE and agreement records in PA
--
--

PROCEDURE delete_funding(p_api_version		IN 		NUMBER				,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE	,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
			 x_return_status	OUT  NOCOPY	VARCHAR2			,
			 x_msg_count		OUT  NOCOPY	NUMBER				,
			 x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 p_funding_source_id	IN		NUMBER
			-- p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE
			);


--
-- Procedure: add_allocation
--
-- Description: create funding allocation records in OKE and project funding records in PA if agreement_flag is true
--
--

PROCEDURE add_allocation(p_api_version		IN 		NUMBER					,
			 p_init_msg_list	IN		VARCHAR2 := OKE_API.G_FALSE		,
			 p_commit		IN		VARCHAR2 := OKE_API.G_FALSE		,
			 x_return_status	OUT  NOCOPY	VARCHAR2				,
			 x_msg_count		OUT  NOCOPY	NUMBER					,
			 x_msg_data		OUT  NOCOPY	VARCHAR2				,
			 p_agreement_flag	IN		VARCHAR2 := OKE_API.G_FALSE		,
		         p_allocation_in_rec	IN		ALLOCATION_REC_IN_TYPE			,
		         x_allocation_out_rec	OUT  NOCOPY	ALLOCATION_REC_OUT_TYPE
 			);


--
-- Procedure: update_allocation
--
-- Description: update funding allocation records in OKE and project funding records in PA if agreement_flag is true
--
--

PROCEDURE update_allocation(p_api_version		IN 		NUMBER					,
			    p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE		,
			    p_commit			IN		VARCHAR2 := OKE_API.G_FALSE		,
			    x_return_status		OUT  NOCOPY	VARCHAR2				,
			    x_msg_count			OUT  NOCOPY	NUMBER					,
			    x_msg_data			OUT  NOCOPY	VARCHAR2				,
			    p_agreement_flag		IN		VARCHAR2 := OKE_API.G_FALSE		,
		            p_allocation_in_rec		IN		ALLOCATION_REC_IN_TYPE			,
		            x_allocation_out_rec	OUT  NOCOPY	ALLOCATION_REC_OUT_TYPE
 			   );


--
-- Procedure: delete_allocation
--
-- Description: delete funding records in OKE and project funding records in PA
--
--

PROCEDURE delete_allocation(p_api_version		IN 		NUMBER				,
			    p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE	,
			    p_commit			IN		VARCHAR2 := OKE_API.G_FALSE	,
			    x_return_status		OUT  NOCOPY	VARCHAR2			,
			    x_msg_count			OUT  NOCOPY	NUMBER				,
			    x_msg_data			OUT  NOCOPY	VARCHAR2			,
			    p_fund_allocation_id	IN		NUMBER
		--	    p_agreement_flag		IN		VARCHAR2 := OKE_API.G_FALSE
			   );


--
-- Procedure: create_pa_oke_funding
--
-- Description: create funding records in OKE based on existing agreement records in PA
--
--

PROCEDURE create_pa_oke_funding(p_api_version		IN 		NUMBER				,
				p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE	,
				p_commit		IN		VARCHAR2 := OKE_API.G_FALSE	,
				x_return_status		OUT  NOCOPY	VARCHAR2			,
			 	x_msg_count		OUT  NOCOPY	NUMBER				,
			 	x_msg_data		OUT  NOCOPY	VARCHAR2			,
			 	x_funding_source_id	OUT  NOCOPY	NUMBER				,
			 	--p_source_currency	IN		VARCHAR2			,
			 	p_agreement_id		IN		NUMBER				,
			 	p_party_id		IN		NUMBER				,
			 	p_pool_party_id		IN		NUMBER				,
			 	p_object_id		IN		NUMBER				,
				--p_pa_conversion_type	IN		VARCHAR2			,
			 	--p_pa_conversion_date	IN		DATE				,
		                --p_pa_conversion_rate    IN     	 NUMBER                          ,
				p_oke_conversion_type	IN		VARCHAR2			,
				p_oke_conversion_date	IN		DATE	                        ,
			        p_oke_conversion_rate   IN      	NUMBER
			       );

end OKE_FUNDING_PUB;

 

/
