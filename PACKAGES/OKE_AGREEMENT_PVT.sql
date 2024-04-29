--------------------------------------------------------
--  DDL for Package OKE_AGREEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_AGREEMENT_PVT" AUTHID CURRENT_USER as
/* $Header: OKEVKAGS.pls 115.15 2002/11/21 21:17:55 syho ship $ */


--
-- Global Variables
--

G_PKG_NAME			CONSTANT	VARCHAR2(50)  := 'OKE_AGREEMENT_PVT';
G_API_VERSION_NUMBER				NUMBER 	      := 1.0;
G_DESCRIPTION					VARCHAR2(100) := 'Created by Oracle Project Contracts';
G_APP_NAME			CONSTANT	VARCHAR2(3)   := OKE_API.G_APP_NAME;
G_SQLCODE_TOKEN			CONSTANT	VARCHAR2(200) := 'SQLcode';
G_SQLERRM_TOKEN			CONSTANT	VARCHAR2(200) := 'SQLerrm';
G_UNEXPECTED_ERROR		CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';
G_PRODUCT_CODE			CONSTANT	VARCHAR2(3)   := 'OKE';
G_PA_DESC_FLEX_NAME		CONSTANT	VARCHAR2(50)  := 'PA_AGREEMENTS_DESC_FLEX';
G_PROJ_FUND_DESC_FLEX_NAME	CONSTANT	VARCHAR2(50)  := 'PA_PROJECT_FUNDINGS_DESC_FLEX';
G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
G_RESOURCE_BUSY			EXCEPTION;
PRAGMA EXCEPTION_INIT(G_RESOURCE_BUSY, -54);


--
-- Agreement_Rec_Type
--

TYPE agreement_rec_type is RECORD
(object_id			NUMBER		:= OKE_API.G_MISS_NUM	,
 org_total_amount		NUMBER		:= OKE_API.G_MISS_NUM	,
 total_amount			NUMBER		:= OKE_API.G_MISS_NUM	,
 agreement_currency_code	VARCHAR2(15)	:= OKE_API.G_MISS_CHAR  ,
 --negative_amount		NUMBER		:= OKE_API.G_MISS_NUM
 agreement_id			NUMBER		:= OKE_API.G_MISS_NUM
);

--
-- Agreement_Tbl_Type
--

TYPE agreement_tbl_type is TABLE of agreement_rec_type
index by binary_integer;

--
-- Pa_Agreement_Tbl_Type
--

TYPE pa_agreement_tbl_type is TABLE of PA_AGREEMENT_PUB.AGREEMENT_REC_IN_TYPE
index by binary_integer;


--
-- Procedure: create_agreement
--
-- Description: This procedure is used to create pa agreement
--
--

PROCEDURE create_agreement(p_api_version		IN		NUMBER						,
   			   p_init_msg_list		IN     	        VARCHAR2 := OKE_API.G_FALSE			,
   			   p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			   p_msg_count			OUT  NOCOPY	NUMBER						,
   			   p_msg_data			OUT  NOCOPY	VARCHAR2					,
   			   p_agreement_type		IN		VARCHAR2 					,
			   p_funding_in_rec		IN		OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE		,
			--   p_allocation_in_tbl		IN	OKE_ALLOCATION_PVT.ALLOCATION_IN_TBL_TYPE	,
			   p_return_status   		OUT  NOCOPY	VARCHAR2
			  );

--
-- Procedure: update_agreement
--
-- Description: This procedure is used to update pa agreement
--
--

PROCEDURE update_agreement(p_api_version		IN		NUMBER						,
   			   p_init_msg_list		IN    		VARCHAR2 := OKE_API.G_FALSE			,
   			   p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			   p_msg_count			OUT  NOCOPY	NUMBER						,
   			   p_msg_data			OUT  NOCOPY	VARCHAR2					,
   			   p_agreement_type		IN		VARCHAR2 					,
			   p_funding_in_rec		IN		OKE_FUNDSOURCE_PVT.FUNDING_REC_IN_TYPE		,
			--   p_allocation_in_tbl		IN	OKE_ALLOCATION_PVT.ALLOCATION_IN_TBL_TYPE	,
			   p_return_status   		OUT  NOCOPY	VARCHAR2
			  );


--
-- Procedure: update_pa_funding
--
-- Description: This procedure is used to update/insert record in pa project funding table
--
--

PROCEDURE update_pa_funding(p_api_version		IN		NUMBER						,
   			    p_init_msg_list		IN      	VARCHAR2 := OKE_API.G_FALSE			,
   			    p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_msg_count			OUT  NOCOPY	NUMBER						,
   			    p_msg_data			OUT  NOCOPY	VARCHAR2					,
			    p_allocation_in_rec		IN		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE	,
			    p_return_status		OUT  NOCOPY     VARCHAR2
			   );


--
-- Procedure: add_pa_funding
--
-- Description: This procedure is used to add funding line to PA_PROJECT_FUNDINGS table
--
--

PROCEDURE add_pa_funding(p_api_version			IN		NUMBER						,
   			 p_init_msg_list		IN     	 	VARCHAR2 := OKE_API.G_FALSE			,
   			 p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count			OUT  NOCOPY	NUMBER						,
   			 p_msg_data			OUT  NOCOPY	VARCHAR2					,
			 p_allocation_in_rec		IN		OKE_ALLOCATION_PVT.ALLOCATION_REC_IN_TYPE	,
		         p_return_status		OUT  NOCOPY	VARCHAR2
		        );


end OKE_AGREEMENT_PVT;

 

/
