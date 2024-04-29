--------------------------------------------------------
--  DDL for Package PA_AGREEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AGREEMENT_PUB" AUTHID DEFINER as
/*$Header: PAAFAPBS.pls 120.7 2007/02/07 10:43:16 rgandhi noship $*/
/*#
 * This package contains the public APIs for agreement and funding
 * procedures that are used by the external system.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Create Agreement
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_AGREEMENT
 * @rep:category BUSINESS_ENTITY PA_INVOICE
 * @rep:category BUSINESS_ENTITY PA_REVENUE
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
--Package constant used for package version validation
G_API_VERSION_NUMBER 	CONSTANT NUMBER := 1.0;

--Locking exception
ROW_ALREADY_LOCKED	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED, -54);


-- Agreement_Rec_In_Type
TYPE agreement_rec_in_type is RECORD
(pm_agreement_reference 	VARCHAR2(25) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
agreement_id 			NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
customer_id 			NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
customer_num 			VARCHAR2(30) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
/*  Commented out for enhancement 1593520
 agreement_num 			VARCHAR2(20) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, */
/* Added the new sized agreement_num variable for enhancement  1593520 */
agreement_num 			PA_AGREEMENTS_ALL.agreement_num%TYPE 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
/* Till here */
agreement_type 			VARCHAR2(30) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
amount 				NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
term_id 			NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
revenue_limit_flag 		VARCHAR2(1) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
expiration_date 		DATE 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
description 			VARCHAR2(240) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
owned_by_person_id 		NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
desc_flex_name 			VARCHAR2(240) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute_category		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute1 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute2 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute3 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute4 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute5 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute6 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute7 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute8 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute9 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute10 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
template_flag 			VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
owning_organization_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
agreement_currency_code		VARCHAR2(15)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
invoice_limit_flag		VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
/*Federal*/
customer_order_number           VARCHAR2(240)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
advance_required                VARCHAR2(1)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
start_date                      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
Billing_sequence                NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
line_of_account                 VARCHAR2(240)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute11 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute12 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute13 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute14 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute15 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute16 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute17 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute18 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute19 			VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute20 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute21 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute22 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute23 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute24 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute25 			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

 );
-- Agreement_Rec_Out_Type
TYPE agreement_rec_out_type is RECORD
(
agreement_id 		NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
customer_id		NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
return_status		VARCHAR2(1) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 );


-- Funding_Rec_In_Type
TYPE funding_rec_in_type is RECORD
(
pm_funding_reference 	VARCHAR2(25) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
project_funding_id 	NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
agreement_id 		NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
project_id 		NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
task_id 		NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
allocated_amount 	NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
date_allocated 		DATE 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
desc_flex_name 		VARCHAR2(240) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute_category 	VARCHAR2(30) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute1 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute2 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute3 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute4 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute5		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute6 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute7 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute8 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute9 		VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
attribute10	 	VARCHAR2(150) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
project_rate_type	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
project_rate_date	DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
project_exchange_rate	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
projfunc_rate_type	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
projfunc_rate_date	DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
projfunc_exchange_rate	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
funding_category        VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  /* For Bug2244796 */
 );


-- Funding_Rec_Out_Type
TYPE funding_rec_out_type IS RECORD
(
 project_funding_id     NUMBER 		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 return_status		VARCHAR2(1) 	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 );

-- Funding_In_Tbl_Type
TYPE funding_in_tbl_type is TABLE of funding_rec_in_type
index by binary_integer;

-- Funding_Out_Tbl_Type
TYPE funding_out_tbl_type is TABLE of funding_rec_out_type
index by binary_integer;


--Globals to be used by the LOAD/EXECUTE/FETCH process

--IN types
G_agreement_in_null_rec		agreement_rec_in_type;
G_agreement_in_rec		agreement_rec_in_type;
G_funding_in_tbl		funding_in_tbl_type;
G_funding_tbl_count		NUMBER := 0;

--OUT types
G_agreement_out_null_rec	agreement_rec_out_type;
G_agreement_out_rec		agreement_rec_out_type;
G_funding_out_tbl		funding_out_tbl_type;

/*#
 * This API creates an agreement with associated funds from the external system.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_agreement_in_rec The agreement input record for Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_out_rec The agreement output record from Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_funding_in_tbl The funding input table of records for Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_funding_out_tbl The funding output table of records from Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Agreement
 * @rep:compatibility S
*/
PROCEDURE create_agreement
(p_api_version_number	IN	NUMBER -- :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit	        IN	VARCHAR2 -- := FND_API.G_FALSE
 ,p_init_msg_list	IN	VARCHAR2 -- := FND_API.G_FALSE
 ,P_msg_count	        OUT	NOCOPY NUMBER /*file.sql.39*/
 ,P_msg_data	        OUT	NOCOPY VARCHAR2 /*file.sql.39*/
 ,P_return_status	OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code	IN	VARCHAR2 -- := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_agreement_in_rec	IN	Agreement_Rec_In_Type
 ,p_agreement_out_rec	OUT	NOCOPY Agreement_Rec_Out_Type  /*file.sql.39*/
 ,p_funding_in_tbl	IN	funding_in_tbl_type
 ,p_funding_out_tbl	OUT	NOCOPY funding_out_tbl_type /*file.sql.39*/
 );

/*#
 * This API deletes an agreement with associated funds from the external system.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pm_agreement_reference The reference code that uniquely identifies the agreement in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project Agreement
 * @rep:compatibility S
*/
PROCEDURE delete_agreement
(p_api_version_number	      IN	NUMBER
 ,p_commit	              IN	VARCHAR2
 ,p_init_msg_list	      IN	VARCHAR2
 ,p_msg_count	              OUT NOCOPY	NUMBER  /*file.sql.39*/
 ,p_msg_data	              OUT NOCOPY	VARCHAR2  /*file.sql.39*/
 ,p_return_status	      OUT NOCOPY	VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code	      IN	VARCHAR2
 ,p_pm_agreement_reference    IN	VARCHAR2
 ,p_agreement_id	      IN	NUMBER
 );

/*#
 * This API updates an agreement and associated funds.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_agreement_in_rec The reference code that uniquely identifies the agreement input record in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_out_rec The reference code that uniquely identifies the agreement output record in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_funding_in_tbl The reference code that uniquely identifies the funding input record for Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_funding_out_tbl The reference code that uniquely identifies the funding output record for Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Project Agreement
 * @rep:compatibility S
*/
PROCEDURE update_agreement
(p_api_version_number	IN	NUMBER
 ,p_commit	        IN	VARCHAR2
 ,p_init_msg_list	IN	VARCHAR2
 ,p_msg_count	        OUT NOCOPY	NUMBER /*file.sql.39*/
 ,p_msg_data	        OUT NOCOPY	VARCHAR2  /*file.sql.39*/
 ,p_return_status	OUT NOCOPY VARCHAR2 /*file.sql.39*/
 ,p_pm_product_code	IN	VARCHAR2
 ,p_agreement_in_rec	IN	Agreement_Rec_In_Type
 ,p_agreement_out_rec	OUT NOCOPY	Agreement_Rec_Out_Type  /*file.sql.39*/
 ,p_funding_in_tbl	IN	funding_in_tbl_type
 ,p_funding_out_tbl	OUT NOCOPY	funding_out_tbl_type  /*file.sql.39*/
 );

/*#
 * This API adds funding to an agreement.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pm_funding_reference Unique reference code that identifies the project/agreement funding in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id The reference code that uniquely identifies the funding in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pa_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_allocated_amount The reference code that uniquely identifies the allocated funding amount in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_date_allocated The reference code that uniquely identifies the date allocated in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_desc_flex_name Descriptive flexfield name
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id_out The reference code that uniquely identifies the funding in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_type Exchange rate type to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_date Exchange rate date to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_exchange_rate Exchange rate to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_type Exchange rate type to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_date  Exchange rate date to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_exchange_rate Exchange rate to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_funding_category  Identifier of the funding line
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Project Funding
 * @rep:compatibility S
*/
/* Added MCB2 Columns */
PROCEDURE add_funding
(p_api_version_number	        IN	NUMBER
 ,p_commit	                IN	VARCHAR2
 ,p_init_msg_list	        IN	VARCHAR2
 ,p_msg_count	                OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data	                OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_return_status	        OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code	        IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN OUT 	NOCOPY NUMBER   /*file.sql.39*/
 ,p_pa_project_id	        IN	NUMBER
 ,p_pa_task_id	                IN	NUMBER
 ,p_agreement_id	        IN	NUMBER
 ,p_allocated_amount	        IN	NUMBER
 ,p_date_allocated	        IN	DATE
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_attribute_category	        IN	VARCHAR2
 ,p_attribute1	                IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10	                IN	VARCHAR2
 ,p_funding_id_out	        OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'   /* Added default for bug 2483081- For Bug2244796 */
 );

/*#
 * This API deletes a fund from an agreement.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pm_funding_reference Unique reference code that identifies funding in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id  The reference code that uniquely identifies the funding in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_check_y_n Flag indicating if funding should be validated before deletion
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Project Funding
 * @rep:compatibility S
*/
PROCEDURE delete_funding
(p_api_version_number	        IN	NUMBER
 ,p_commit	                IN	VARCHAR2
 ,p_init_msg_list	        IN	VARCHAR2
 ,p_msg_count	                OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data	                OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_return_status	        OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code	        IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id	                IN	NUMBER
 ,p_check_y_n			IN	VARCHAR2	DEFAULT 'Y'
 );

/*#
 * This API updates a fund for an agreement
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pm_funding_reference The reference code that uniquely identifies the funding in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id The reference code that uniquely identifies the funding in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_task_id The reference code that uniquely identifies the task within a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_allocated_amount The reference code that uniquely identifies the allocated funding amount in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_date_allocated The reference code that uniquely identifies the date allocated in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_desc_flex_name Descriptive flexfield name
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id_out The reference code that uniquely identifies the funding in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_type Exchange rate type to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_date Exchange rate date to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_exchange_rate Exchange rate to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_type Exchange rate type to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_date  Exchange rate date to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_exchange_rate Exchange rate to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_funding_category  Identifier of the funding line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Project Funding
 * @rep:compatibility S
*/
 /* Added MCB2 Columns */
PROCEDURE update_funding
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code		IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_agreement_id		IN	NUMBER
 ,p_allocated_amount		IN	NUMBER
 ,p_date_allocated		IN	DATE
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1	                IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_funding_id_out		OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'   /* Added default for bug 2512483-
For Bug2244796 */
 );

/*#
 * This API creates a new agreement or updates an existing agreement.
 * The API should be executed in the following order:
 * INIT_AGREEMENT, LOAD_AGREEMENT, LOAD_FUNDING, EXECUTE_CREATE_AGREEMENT/EXECUTE_UPDATE_AGREEMENT, FETCH_FUNDING
 * and CLEAR_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Project Agreements-Initialize
 * @rep:compatibility S
*/
PROCEDURE init_agreement;

/*#
 * This API loads an agreement to a PL/SQL record
 * The API should be executed in the following order:
 * INIT_AGREEMENT, LOAD_AGREEMENT, LOAD_FUNDING, EXECUTE_CREATE_AGREEMENT/EXECUTE_UPDATE_AGREEMENT, FETCH_FUNDING
 * and CLEAR_AGREEMENT
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_agreement_reference The reference code that uniquely identifies the agreement in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_customer_id The identification code of the project customer in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_customer_name  Name identifying the project customer in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_customer_num Number identifying the project customer in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_num The reference code that uniquely identifies the agreement number in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_type The reference code that uniquely identifies the agreement type in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_amount The reference code that uniquely identifies the amount of the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_term_id The reference code that uniquely identifies the terms of the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_term_name The name that uniquely identifies the term of the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_revenue_limit_flag Flag indicating whether or not the revenue limit has been exceeded
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_expiration_date The expiration date of the agreement for a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_description Description of the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_owned_by_person_id The reference code that uniquely identifies the person who owns the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_owned_by_person_name The name that uniquely identifies the person who owns the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_template_flag Indicates whether or not the project is a template
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_desc_flex_name Descriptive flexfield name
 * @rep:paraminfo {@rep:required}
 * @param p_owning_organization_id Identifier of the organization that is responsible for the project work
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_currency_code Specifies agreement currency code of the agreement
 * @rep:paraminfo {@rep:required}
 * @param p_invoice_limit_flag Flag indicating whether invoices for projects funded by this agreement can exceed the allocated
 * funding amount
 * @rep:paraminfo {@rep:required}
 * @param p_customer_order_number Represents the Customer Order Number for the reimbursable Agreement
 * @rep:paraminfo {@rep:required}
 * @param p_advance_required Indicates whether agreement amount or receipt amount from AR to be used.
 * @rep:paraminfo {@rep:required}
 * @param p_start_date The Start date of the agreement for a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_billing_sequence Indicates in which order agreement  to be consumed
 * @rep:paraminfo {@rep:required}
 * @param p_line_of_account Represents the accounting string that the customer agency is using to fund the agreement
 * @rep:paraminfo {@rep:required}
 * @param p_attribute11 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute12 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute13 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute14 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute15 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute16 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute17 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute18 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute19 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute20 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute21 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute22 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute23 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute24 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute25 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Project Agreements-Load
 * @rep:compatibility S
*/
PROCEDURE load_agreement
(p_api_version_number		IN	NUMBER
 ,p_init_msg_list		IN	VARCHAR2
 ,p_return_status		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_customer_id			IN	NUMBER
 ,p_customer_name		IN     	VARCHAR2
 ,p_customer_num		IN	VARCHAR2
 ,p_agreement_num		IN	VARCHAR2
 ,p_agreement_type		IN	VARCHAR2
 ,p_amount			IN	NUMBER
 ,p_term_id			IN	NUMBER
 ,p_term_name			IN	VARCHAR2
 ,p_revenue_limit_flag		IN	VARCHAR2
 ,p_expiration_date		IN	DATE
 ,p_description			IN	VARCHAR2
 ,p_owned_by_person_id		IN	NUMBER
 ,p_owned_by_person_name	IN	VARCHAR2
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1			IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_template_flag		IN	VARCHAR2
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_owning_organization_id	IN	NUMBER
 ,p_agreement_currency_code	IN	VARCHAR2
 ,p_invoice_limit_flag		IN	VARCHAR2
 /*Federal*/
 ,p_customer_order_number       IN      VARCHAR2
 ,p_advance_required            IN      VARCHAR2
 ,p_start_date                  IN      DATE
 ,p_billing_sequence            IN      NUMBER
 ,p_line_of_account             IN      VARCHAR2
 ,p_attribute11			IN	VARCHAR2
 ,p_attribute12	                IN	VARCHAR2
 ,p_attribute13	                IN	VARCHAR2
 ,p_attribute14	                IN	VARCHAR2
 ,p_attribute15	                IN	VARCHAR2
 ,p_attribute16	                IN	VARCHAR2
 ,p_attribute17	                IN	VARCHAR2
 ,p_attribute18	                IN	VARCHAR2
 ,p_attribute19	                IN	VARCHAR2
 ,p_attribute20			IN	VARCHAR2
 ,p_attribute21			IN	VARCHAR2
 ,p_attribute22			IN	VARCHAR2
 ,p_attribute23			IN	VARCHAR2
 ,p_attribute24			IN	VARCHAR2
 ,p_attribute25			IN	VARCHAR2
 );

/*#
 * This API loads funding to a PL/SQL table
 * The API should be executed in the following order:
 * INIT_AGREEMENT, LOAD_AGREEMENT, LOAD_FUNDING, EXECUTE_CREATE_AGREEMENT/EXECUTE_UPDATE_AGREEMENT, FETCH_FUNDING
 * and CLEAR_AGREEMENT
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_funding_reference Unique reference code that identifies the funding in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id The reference code that uniquely identifies the funding in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_allocated_amount The reference code that uniquely identifies the allocated funding amount in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_date_allocated The reference code that uniquely identifies the date allocated in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_type Exchange rate type to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_date Exchange rate date to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_exchange_rate Exchange rate to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_type Exchange rate type to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_date  Exchange rate date to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_exchange_rate Exchange rate to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_funding_category  Identifier of the funding line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Project Fundings-load
 * @rep:compatibility S
*/
/* MCB2 columns added */
 PROCEDURE load_funding
(p_api_version_number		IN	NUMBER
 ,p_init_msg_list		IN	VARCHAR2
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*file.sql.39*/
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_agreement_id		IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_allocated_amount		IN	NUMBER
 ,p_date_allocated		IN	DATE
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1			IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'   /*  Added default for bug 2483081- For Bug2244796 */
 );

/*#
 * This API creates an agreement with funding using information that is stored in the global tables during the load phase.
 * The API should be executed in the following order:
 * INIT_AGREEMENT, LOAD_AGREEMENT, LOAD_FUNDING, EXECUTE_CREATE_AGREEMENT/EXECUTE_UPDATE_AGREEMENT, FETCH_FUNDING
 * and CLEAR_AGREEMENT
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_agreement_id_out The reference code that uniquely identifies the agreement in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_customer_id_out The reference code that uniquely identifies the customer in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Project Agreements - Execute Create
 * @rep:compatibility S
*/
PROCEDURE execute_create_agreement
(p_api_version_number	IN	NUMBER
 ,p_commit		IN	VARCHAR2
 ,p_init_msg_list	IN	VARCHAR2
 ,p_msg_count		OUT	NOCOPY NUMBER
 ,p_msg_data		OUT	NOCOPY VARCHAR2
 ,p_return_status	OUT	NOCOPY VARCHAR2
 ,p_pm_product_code	IN	VARCHAR2
 ,p_agreement_id_out	OUT	NOCOPY NUMBER
 ,p_customer_id_out	OUT	NOCOPY NUMBER
 );

/*#
 * This API updates an agreement with funding using the information that is stored in the global tables during the load phase.
 * The API should be executed in the following order:
 * INIT_AGREEMENT, LOAD_AGREEMENT, LOAD_FUNDING, EXECUTE_CREATE_AGREEMENT/EXECUTE_UPDATE_
AGREEMENT, FETCH_FUNDING
 * and CLEAR_AGREEMENT
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Multiple Project Agreements
 * @rep:compatibility S
*/
PROCEDURE execute_update_agreement
(p_api_version_number	IN	NUMBER
 ,p_commit		IN	VARCHAR2
 ,p_init_msg_list	IN	VARCHAR2
 ,p_msg_count		OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_return_status	OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code	IN	VARCHAR2
 );

/*#
 * This API gets the return status during creation of funds and stores this value in a global PL/SQL table.
 * The API should be executed in the following order: INIT_AGREEMENT, LOAD_AGREEMENT, LOAD_FUNDING,
 * EXECUTE_CREATE_AGREEMENT/EXECUTE_UPDATE_AGREEMENT, FETCH_FUNDING and CLEAR_AGREEMENT
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_funding_index Pointer to specific funding amount
 * @rep:paraminfo  {@rep:required}
 * @param p_funding_id The reference code that uniquely identifies the funding in Oracle Projects
 * @rep:paraminfo  {@rep:required}
 * @param p_pm_funding_reference The reference code that uniquely identifies the funding in the external system
 * @rep:paraminfo  {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Project Fundings - Fetch
 * @rep:compatibility S
*/
PROCEDURE fetch_funding
(p_api_version_number		IN	NUMBER
 ,p_init_msg_list		IN	VARCHAR2
 ,p_return_status		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_funding_index		IN	NUMBER
 ,p_funding_id			OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_pm_funding_reference	OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 );

/*#
 * This API clears the global variables that were created during initialization.
 * In order to execute this API the following list of API's should be executed in the order of sequence.
 * INIT_AGREEMENT
 * LOAD_AGREEMENT
 * LOAD_FUNDING
 * EXECUTE_CREATE_AGREEMENT/EXECUTE_UPDATE_AGREEMENT
 * FETCH_FUNDING
 * CLEAR_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Multiple Project Agreements - Clear
 * @rep:compatibility S
*/
PROCEDURE clear_agreement;

/*#
 * This API is used to determine if an agreement can be deleted.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_agreement_reference The reference code that uniquely identifies the agreement in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_del_agree_ok_flag Boolean flag for deleting an agreement
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Project Agreement Deletion
 * @rep:compatibility S
*/
PROCEDURE check_delete_agreement_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_del_agree_ok_flag		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 );

/*#
 * This API is used to determine if a fund can be added.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_agreement_reference The reference code that uniquely identifies the agreement in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_funding_reference The reference code that uniquely identifies the funding in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_add_funding_ok_flag Boolean flag for adding funding
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_funding_amt The reference code that uniquely identifies the allocated funding amount in a project in Oracle Projects
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_project_rate_type Exchange rate type to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_date Exchange rate date to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_exchange_rate Exchange rate to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_type Exchange rate type to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_date  Exchange rate date to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_exchange_rate Exchange rate to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Project Funding Creation
 * @rep:compatibility S
*/
 /* MCB2 columns added */
PROCEDURE check_add_funding_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*file.sql.39*/
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_task_id			IN	NUMBER
 ,p_project_id			IN 	NUMBER
 ,p_add_funding_ok_flag		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_funding_amt			IN	NUMBER
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 );

/*#
 * This API is used to determine if a fund can be deleted.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_funding_reference The reference code that uniquely identifies the funding in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id The reference code that uniquely identifies the funding in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_del_funding_ok_flag Boolean flag for deleting funding
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Project Funding Deletion
 * @rep:compatibility S
*/
PROCEDURE check_delete_funding_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_del_funding_ok_flag		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 );

/*#
 * This API is used to determine if a fund can be updated.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pm_funding_reference The reference code that uniquely identifies the funding in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_funding_id The reference code that uniquely identifies the funding in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_task_reference The reference code that uniquely identifies the task in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_task_id The reference code that uniquely identifies the task in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_agreement_reference  The reference code that uniquely identifies the agreement in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_agreement_id The reference code that uniquely identifies the agreement in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_allocated_amount The reference code that uniquely identifies the allocated funding amount in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_date_allocated The reference code that uniquely identifies the date allocated in a project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_desc_flex_name Descriptive flexfield name
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_update_funding_ok_flag Boolean flag for deleting funding
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_project_rate_type Exchange rate type to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_rate_date Exchange rate date to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_project_exchange_rate Exchange rate to use for conversion from funding currency to project currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_type Exchange rate type to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_rate_date  Exchange rate date to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_projfunc_exchange_rate Exchange rate to use for conversion from funding currency to project functional currency
 * @rep:paraminfo {@rep:required}
 * @param p_funding_category  Identifier of the funding line
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Project Funding Update
 * @rep:compatibility S
*/
 /* MCB2 columns added */
PROCEDURE check_update_funding_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2 /*file.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code		IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_pm_project_reference	IN	VARCHAR2
 ,p_project_id			IN	NUMBER
 ,p_pm_task_reference		IN	VARCHAR2
 ,p_task_id			IN	NUMBER
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_allocated_amount		IN	NUMBER
 ,p_date_allocated		IN	DATE
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1			IN	VARCHAR2
 ,p_attribute2			IN	VARCHAR2
 ,p_attribute3			IN	VARCHAR2
 ,p_attribute4			IN	VARCHAR2
 ,p_attribute5			IN 	VARCHAR2
 ,p_attribute6			IN	VARCHAR2
 ,p_attribute7			IN	VARCHAR2
 ,p_attribute8			IN	VARCHAR2
 ,p_attribute9			IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_update_funding_ok_flag	OUT	NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'
/* Added default for bug 2512483-For Bug2244796 */

);
/* MCB 2 Added to create baselined budget */
/*#
  * This API creates a budget baseline
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_commit API standard (default = F) indicates if transcation will be committed
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_init_msg_list API standard (default = F) indicates if message stack will be initialized
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param p_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000} {@rep:required}
 * @param p_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:precision 1} {@rep:required}
 * @param p_pm_product_code Identifier of the external system from which the project was imported
 * @rep:paraminfo {@rep:precision 25} {@rep:required}
 * @param p_pm_budget_reference The reference code that uniquely identifies the budget in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_pa_project_id The reference code that uniquely identifies the project in Oracle Projects
 * @rep:paraminfo {@rep:required}
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @rep:paraminfo {@rep:required}
 * @param p_change_reason_code Describes the change reason
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute11 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute12 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute13 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute14 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute15 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Baseline Budget
 * @rep:compatibility S
*/
PROCEDURE create_baseline_budget
( p_api_version_number                  IN      NUMBER
 ,p_commit                              IN      VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list                       IN      VARCHAR2        := FND_API.G_FALSE
 ,p_msg_count                           OUT     NOCOPY NUMBER  /*file.sql.39*/
 ,p_msg_data                            OUT     NOCOPY VARCHAR2 /*file.sql.39*/
 ,p_return_status                       OUT     NOCOPY VARCHAR2  /*file.sql.39*/
 ,p_pm_product_code                     IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                       IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference                IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code                  IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category                  IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    );

end PA_AGREEMENT_PUB;

/
