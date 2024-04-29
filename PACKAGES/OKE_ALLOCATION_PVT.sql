--------------------------------------------------------
--  DDL for Package OKE_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_ALLOCATION_PVT" AUTHID CURRENT_USER as
/* $Header: OKEVFDAS.pls 120.0 2005/05/25 17:55:18 appldev noship $ */


--
-- Global variables
--

G_API_VERSION_NUMBER	CONSTANT	NUMBER 	      := 1.0;
G_PKG_NAME		CONSTANT	VARCHAR2(30)  := 'OKE_ALLOCATION_PVT';
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
-- Allocation_Rec_In_Type
--

TYPE allocation_rec_in_type is RECORD
(fund_allocation_id	NUMBER		:= OKE_API.G_MISS_NUM	,
 funding_source_id	NUMBER		:= OKE_API.G_MISS_NUM	,
 object_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 k_line_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 project_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 task_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 agreement_id		NUMBER		:= OKE_API.G_MISS_NUM	,
 project_funding_id	NUMBER		:= OKE_API.G_MISS_NUM	,
 amount			NUMBER		:= OKE_API.G_MISS_NUM	,
 hard_limit		NUMBER		:= OKE_API.G_MISS_NUM	,
 fund_type		VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 funding_status		VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 start_date_active	DATE		:= OKE_API.G_MISS_DATE  ,
 end_date_active	DATE		:= OKE_API.G_MISS_DATE  ,
 fiscal_year		NUMBER		:= OKE_API.G_MISS_NUM	,
 reference1		VARCHAR2(80)	:= OKE_API.G_MISS_CHAR	,
 reference2		VARCHAR2(80)	:= OKE_API.G_MISS_CHAR	,
 reference3		VARCHAR2(80)	:= OKE_API.G_MISS_CHAR	,
 pa_conversion_type	VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 pa_conversion_date	DATE		:= OKE_API.G_MISS_DATE  ,
 pa_conversion_rate	NUMBER		:= OKE_API.G_MISS_NUM   ,
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
 revenue_hard_limit	NUMBER		:= OKE_API.G_MISS_NUM	,
 funding_category	VARCHAR2(30)	:= OKE_API.G_MISS_CHAR  ,
 pa_attribute_category	VARCHAR2(30)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute1		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute2		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute3		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute4		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute5		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute6		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute7		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute8		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute9		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR	,
 pa_attribute10		VARCHAR2(150)	:= OKE_API.G_MISS_CHAR
);


--
-- Allocation_Rec_Out_Type
--

TYPE allocation_rec_out_type is RECORD
(fund_allocation_id	NUMBER		:= OKE_API.G_MISS_NUM	,
 return_status		VARCHAR2(1)	:= OKE_API.G_MISS_CHAR
);


--
-- Allocation_In_Tbl_Type
--

TYPE allocation_in_tbl_type is TABLE of allocation_rec_in_type
index by binary_integer;


--
-- Allocation_Out_Tbl_Type
--
TYPE allocation_out_tbl_type is TABLE of allocation_rec_out_type
index by binary_integer;



--
-- Procedure: add_allocation
--
-- Description: This procedure is used to insert record in OKE_K_FUND_ALLOCATIONS table
--

PROCEDURE add_allocation(p_api_version			IN		NUMBER						,
   			 p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			 p_msg_count			OUT NOCOPY	NUMBER						,
   			 p_msg_data			OUT NOCOPY	VARCHAR2					,
			 p_allocation_in_rec		IN		ALLOCATION_REC_IN_TYPE				,
		         p_allocation_out_rec		OUT NOCOPY	ALLOCATION_REC_OUT_TYPE				,
		         p_validation_flag		IN		VARCHAR2 := OKE_API.G_TRUE			,
		         p_return_status	        OUT NOCOPY	VARCHAR2
 			);


--
-- Procedure: update_allocation
--
-- Description: This procedure is used to update record in OKE_K_FUND_ALLOCATIONS table
--

PROCEDURE update_allocation(p_api_version		IN		NUMBER						,
   			    p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_msg_count			OUT NOCOPY	NUMBER						,
   			    p_msg_data			OUT NOCOPY	VARCHAR2					,
			    p_allocation_in_rec		IN		ALLOCATION_REC_IN_TYPE				,
			    p_allocation_out_rec	OUT NOCOPY	ALLOCATION_REC_OUT_TYPE				,
			    p_validation_flag		IN		VARCHAR2 := OKE_API.G_TRUE			,
			    p_return_status		OUT NOCOPY	VARCHAR2
 			   );


--
-- Procedure: delete_allocation
--
-- Description: This procedure is used to delete record in OKE_K_FUND_ALLOCATIONS and PA_PROJECT_FUNDINGS tables
--

PROCEDURE delete_allocation(p_api_version		IN		NUMBER						,
			    p_commit			IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_init_msg_list		IN		VARCHAR2 := OKE_API.G_FALSE			,
   			    p_msg_count			OUT NOCOPY	NUMBER						,
   			    p_msg_data			OUT NOCOPY	VARCHAR2					,
			    p_fund_allocation_id	IN		NUMBER						,
			 --   p_agreement_flag		IN		VARCHAR2 := OKE_API.G_FALSE			,
			    p_return_status		OUT NOCOPY	VARCHAR2
			   );


--
-- Function: get_allocation_tbl
--
-- Description: This function is used to return a initialized OKE_FUNDING_PUB.ALLOCATION_IN_TBL_TYPE
--

FUNCTION get_allocation_tbl RETURN ALLOCATION_IN_TBL_TYPE;


end OKE_ALLOCATION_PVT;

 

/
