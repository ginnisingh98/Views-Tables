--------------------------------------------------------
--  DDL for Package OKE_FUNDING_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FUNDING_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: OKEFUTLS.pls 115.16 2002/11/21 20:46:43 syho ship $ */

--
-- Global Variables
--

G_APP_NAME			CONSTANT	VARCHAR2(3)   := OKE_API.G_APP_NAME;
G_SQLCODE_TOKEN			CONSTANT	VARCHAR2(200) := 'SQLcode';
G_SQLERRM_TOKEN			CONSTANT	VARCHAR2(200) := 'SQLerrm';
G_UNEXPECTED_ERROR		CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';

--
-- Proj_Sum_Type
--

TYPE proj_sum_type is RECORD
(project_id		NUMBER		,
 project_number		VARCHAR2(25)	,
 amount			NUMBER		,
 org_id			NUMBER
);

--
-- Proj_Sum_Tbl_Type
--

TYPE proj_sum_tbl_type is TABLE of proj_sum_type
index by binary_integer;

--
-- Task_Sum_Type
--

TYPE task_sum_type is RECORD
(task_id		NUMBER		,
 project_id		NUMBER		,
 project_number		VARCHAR2(25)	,
 amount			NUMBER		,
 org_id			NUMBER
);

--
-- Task_Sum_Tbl_Type
--

TYPE task_sum_tbl_type is TABLE of task_sum_type
index by binary_integer;

--
-- Funding_Level_Type
--

TYPE funding_level_type is RECORD
(project_id		NUMBER		,
 funding_level		VARCHAR2(1)
);

--
-- Funding_Level_Tbl_Type
--

TYPE funding_level_tbl_type is TABLE of funding_level_type
index by binary_integer;


--
-- Functions and Procedures
--

--
-- Procedure  : validate_source_pool_amount
--
-- Purpose    : check if there is enough funding from the pool party to be allocated
--
-- Parameters :
--         (in) x_first_amount		number 		amount
--		x_source_id		number		funding_source_id
--		x_pool_party_id		number		pool_party_id
--		x_new_flag		varchar2 	new funding source record
--							Y : new funding source
--
--        (out) x_return_status		varchar2	return status
--							Y : valid
--							N : invalid
--

PROCEDURE validate_source_pool_amount(x_first_amount			number		,
  			   	      x_source_id			number		,
  			   	      x_pool_party_id			number		,
  			   	      x_new_flag			varchar2	,
  			              x_return_status	OUT	NOCOPY	varchar2	);



--
-- Procedure  : validate_source_pool_date
--
-- Purpose    : check if
--		 1) funding source start date assocated w/ the pool party >= pool party start date
--               2) funding source end date associated w/ the pool party <= pool party end date
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_pool_party_id			number		pool party id
--		x_date				date		date to be validated
--
--        (out) x_return_status		varchar2		return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_source_pool_date(x_start_end				varchar2	,
  				    x_pool_party_id			number		,
  		         	    x_date				date		,
  		          	    x_return_status	OUT	NOCOPY	varchar2	);



--
-- Procedure  : validate_alloc_source_amount
--
-- Purpose    : check if the new funding source amount >= sum of its allocations
--
-- Parameters :
--         (in) x_source_id			number 		funding source id
--		x_allocation_id			number		funding allocation id
--		x_amount			number		allocation amount
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_alloc_source_amount(x_source_id				number		,
  				       x_allocation_id				number		,
  				       x_amount					number		,
  			   	       x_return_status		OUT	NOCOPY	varchar2	);



--
-- Procedure  : validate_alloc_source_limit
--
-- Purpose    : check if
--		  w/ allocation_id passed in :
--		    there is enough funding source hard limit to be allocated for the newly allocated
--		    hard limit
--
--		  w/o allocaiton_id passed in
--		    the new funding source hard limit is >= sum of its hard limit allocations
--
-- Parameters :
--         (in) x_source_id			number 		funding source id
--		x_allocation_id			number		funding allocation id (optional)
--		x_amount			number		limit amount
--		x_revenue_amount		number		revenue hard limit
--
--        (out) x_type				varchar2	hard limit type (INVOICE/REVENUE)
--		x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_alloc_source_limit(x_source_id				number		,
  				      x_allocation_id				number		,
  				      x_amount					number		,
  				      x_revenue_amount				number		,
  				      x_type		OUT		NOCOPY	varchar2	,
  			   	      x_return_status	OUT		NOCOPY	varchar2	);



--
-- Procedure  : validate_pool_party_date
--
-- Purpose    : check if
--		 1) pool party start date <= the earliest funding source start date associated w/ the pool party
--		 2) pool party end >= the latest funding source end date associated w/ the pool party
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_pool_party_id			number		pool party id
--		x_date				date		date to be validated
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_pool_party_date(x_start_end					varchar2	,
  				   x_pool_party_id				number		,
  		         	   x_date					date		,
  		          	   x_return_status	OUT		NOCOPY	varchar2	);



--
-- Function   : allocation_exist
--
-- Purpose    : check if funding has been allocated for particular funding pool party or not
--
-- Parameters : x_pool_party id		number	pool party id
--
-- Return     : Y     -- allocation exists
-- values       N     -- no allocation exists
--

FUNCTION allocation_exist(x_pool_party_id		number) return varchar2;




--
-- Procedure  : validate_pool_party_amount
--
-- Purpose    : check if the new pool party amount >= the allocated amount
--
-- Parameters :
--         (in) x_pool_party_id			number 		pool party id
--		x_amount			number		new funding amount
--
--        (out) x_allocated_amount		number		calculated allocated amount
--		x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_pool_party_amount(x_pool_party_id				number		,
  				     x_amount					number		,
  				     x_allocated_amount		OUT	NOCOPY	number		,
  				     x_return_status		OUT	NOCOPY	varchar2	);



--
-- Procedure  : validate_source_alloc_date
--
-- Purpose    : check if
--		 1) funding source start date <= the earliest funding allocation start date
--		 2) funding source end date >= the latest funding allocation end date
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_funding_source_id		number		funding source id
--		x_date				date		date to be validated
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_source_alloc_date(x_start_end				varchar2	,
  				     x_funding_source_id			number		,
  		         	     x_date					date		,
  		          	     x_return_status		OUT	NOCOPY	varchar2	);



--
-- Procedure  : validate_alloc_source_date
--
-- Purpose    : check if
--		  1) funding allocation start date >= funding source start date
--		  2) funding allocation end date <= funding source end date
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_funding_source_id		number		funding source id
--		x_date				date		date to be validated
--
--	  (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_alloc_source_date(x_start_end				varchar2	,
  				     x_funding_source_id			number		,
  		         	     x_date					date		,
  		          	     x_return_status		OUT	NOCOPY	varchar2	);



--
-- Procedure  : multi_customer
--
-- Purpose    : find out how many customers associated with particular project
--
-- Parameters :
--         (in) x_project_id		number		project id
--
--        (out) x_count			number		number of customers
--		x_project_number	varchar2		project number
--

PROCEDURE multi_customer(x_project_id					number	,
			 x_project_number	OUT		NOCOPY	varchar2,
  			 x_count		OUT    		NOCOPY	number	);




--
-- Procedure  : save_user_profile
--
-- Purpose    : save user profile on the preference of showing funding wizard or not
--
-- Parameters :
--         (in) x_profile_name	varchar2	profile name
--		x_value		varchar2	profile value
--

PROCEDURE save_user_profile(x_profile_name	varchar2		,
  			    x_value		varchar2		);




--
-- Procedure  : validate_start_end_date
--
-- Purpose    : check if start date <= end date
--
-- Parameters :
--         (in) x_start_date			date 		start date
--		x_end_date			date		end date
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : not valid
--

PROCEDURE validate_start_end_date(x_start_date					date		,
  				  x_end_date			  		date		,
  			          x_return_status		OUT	NOCOPY	varchar2	);




--
-- Procedure  : validate_source_alloc_limit
--
-- Purpose    : check if funding source invoice/revenue hard limit >= sum(funding allocations invoice/revenue hard limit)
--		(for MCB change)
--
-- Parameters :
--         (in) x_source_id			number 		funding source id
--		x_amount			number		limit amount
--		x_revenue_amount		number		revenue hard limit amount
--
--        (out) x_type				varchar2	hard limit type
--		x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_source_alloc_limit(x_source_id					number		,
  				      x_amount						number		,
  				      x_revenue_amount					number		,
  				      x_type			OUT		NOCOPY	varchar2	,
  			   	      x_return_status		OUT		NOCOPY	varchar2	);



--
-- Procedure  : validate_source_alloc_amount
--
-- Purpose    : validate if funding source amount >= sum(funding allocations amount)
--
-- Parameters :
--         (in) x_source_id			number			funding source id
--		x_amount			number			amount
--
--	  (out) x_return_status			varchar2		return status
--								        Y : valid
--								        N : not valid
--

PROCEDURE validate_source_alloc_amount(x_source_id					number		,
  				       x_amount						number		,
  			   	       x_return_status		OUT	NOCOPY		varchar2	);


--
-- Procedure  : validate_hard_limit
--
-- Purpose    : validate if hard limit <= funding amount
--
-- Parameters :
--         (in) x_fund_amount			number			funding amount
--		x_hard_limit			number			hard limit
--
--	  (out) x_return_status			varchar2		return status
--								        Y : valid
--								        N : not valid
--

PROCEDURE validate_hard_limit(x_fund_amount						number		,
			      x_hard_limit						number		,
  			      x_return_status		OUT		NOCOPY		varchar2	);


--
-- Procedure  : get_conversion_rate
--
-- Purpose    : get the conversion rate for the particular conversion type and date
--
-- Parameters :
--         (in) x_from_currency			varchar2		conversion from currency
--		x_to_currency			varchar2		conversion to currency
--		x_conversion_type		varchar2		conversion type
--		x_conversion_date		date			conversion date
--
--        (out) x_conversion_rate		number			conversion rate
--		x_return_status			varchar2		return status
--								        Y : exist
--								        N : not exist
--

PROCEDURE get_conversion_rate(x_from_currency				varchar2	,
           		      x_to_currency				varchar2	,
           		      x_conversion_type				varchar2	,
           		      x_conversion_date				date		,
           		      x_conversion_rate		out 	NOCOPY	number		,
           		      x_return_status		out 	NOCOPY	varchar2
           	             );


--
-- PROCEDURE  : check_agreement_exist
--
-- Purpose    : check if agreement exist for the funding source
--
-- Parameters :
--         (in) x_funding_source_id		number			funding_source_id
--
--	  (out) x_return_status			varchar2		return status
--								        Y : exist
--								        N : not exist
--

PROCEDURE check_agreement_exist(x_funding_source_id			number		,
				x_return_status		out 	NOCOPY	varchar2	);



--
-- Function   : get_project_currency
--
-- Purpose    : get the project currency
--
-- Parameters :
--         (in) x_project_id		number		project_id
--

FUNCTION get_project_currency(x_project_id 	number) return varchar2;



--
-- Function   : get_owned_by
--
-- Purpose    : get the owned_by_person_id
--
-- Parameters :
--         (in) x_user_id			number		user id
--

FUNCTION get_owned_by(x_user_id		number) return number;



--
-- PROCEDURE  : get_agreement_info
--
-- Purpose    : get existing agreement_type, customer_id for the existing funding_source_id
--
-- Parameters :
--         (in) x_funding_source_id		number		funding_source_id
--
--	  (out) x_agreement_type		varchar2	agreement_type
--		x_customer_id			number		customer_id
--		x_return_status			varchar2	return status
--								   Y : exist
--								   N : not exist
--

PROCEDURE get_agreement_info(x_funding_source_id			number		,
  			     x_agreement_type		out	NOCOPY	varchar2	,
  			     x_customer_id		out	NOCOPY	number		,
  			     x_return_status		out	NOCOPY	varchar2
  			    );



--
-- Procedure   : update_alloc_version
--
-- Description : This procedure is used to update agreement_version and insert_update_flag of OKE_K_FUND_ALLOCATIONS table
--
-- Parameters  :
--	    (in)  x_fund_allocation_id		number			fund_allocation_id
--		  x_version_add			number			version increment
--		  x_commit			varchar2		commit flag
--

PROCEDURE update_alloc_version(x_fund_allocation_id		IN	NUMBER				,
			       x_version_add			IN	NUMBER				,
  			       x_commit				IN	VARCHAR2 := OKE_API.G_FALSE
		               );


--
-- Procedure   : update_source_flag
--
-- Description : This procedure is used to update agreement_flag of OKE_K_FUNDING_SOURCES table
--
-- Parameters  :
--	    (in)  x_funding_source_id		number			funding_source_id
--		  x_commit			varchar2		commit flag
--

PROCEDURE update_source_flag(x_funding_source_id		IN	NUMBER				,
  			     x_commit				IN	VARCHAR2 := OKE_API.G_FALSE
		            );


--
-- Procedure   : funding_mode
--
-- Description : This procedure is used to check the funding mode is vaild or not
--
-- Parameters  :
--	    (in)  x_proj_sum_tbl		proj_sum_tbl_type		allocation amount by project
--		  x_task_sum_tbl		task_sum_tbl_type		allocation amount by task
--
--	   (out)  x_funding_level_tbl		funding_level_tbl_type		funding level by project
--		  x_return_status		varchar2			return_status
--										S: successful
--										E: error
--		  x_project_err			varchar2			project number with funding mode error
--

PROCEDURE funding_mode(x_proj_sum_tbl				IN		PROJ_SUM_TBL_TYPE		,
  		       x_task_sum_tbl				IN		TASK_SUM_TBL_TYPE		,
  		       x_funding_level_tbl			OUT     NOCOPY	FUNDING_LEVEL_TBL_TYPE		,
  		       x_return_status				OUT	NOCOPY	VARCHAR2			,
  		       x_project_err				OUT	NOCOPY	VARCHAR2
		      );



--
-- Procedure   : get_converted_amount
--
-- Description : This function is used to calculate the allocated amount
--
-- Parameters  :
--	    (in)  x_funding_source_id			number		funding_source_id
--		  x_project_id				number		project_id
--		  x_project_number			varchar2	project number
--		  x_amount				number		original amount
--		  x_conversion_type			varchar2	currency conversion type
--		  x_conversion_date			date		currency conversion date
--		  x_conversion_rate			number		currency conversion rate
--
--	   (out)  x_converted_amount			number		converted amount
--		  x_return_status			varchar2	return status
--									S: successful
--							      	        E: error
--							       	        U: unexpected error
--

PROCEDURE get_converted_amount(x_funding_source_id			IN		NUMBER					,
			       x_project_id				IN 		NUMBER					,
			       x_project_number				IN		VARCHAR2				,
			       x_amount					IN		NUMBER					,
			      -- x_org_id					IN	NUMBER					,
			       x_conversion_type			IN		VARCHAR2				,
			       x_conversion_date			IN		DATE					,
			       x_conversion_rate			IN		NUMBER					,
			       x_converted_amount			OUT	NOCOPY	NUMBER					,
			       x_return_status				OUT	NOCOPY	VARCHAR2
			      );


--
-- Procedure   : get_calculate_amount
--
-- Description : This procedure is used to get the converted amount
--
-- Parameters  :
--	    (in)  x_conversion_type			varchar2	currency conversion type
--		  x_conversion_date			date		currency conversion date
--		  x_conversion_rate			number		currency conversion rate
--		  x_org_amount				number		original amount
--		  x_min_unit				number		minimum amount unit of the currency
--		  x_fund_currency			varchar2	funding source currency
--		  x_project_currency			varchar2	project currency
--
--	   (out)  x_amount				number		converted amount
--		  x_return_status			varchar2	return status
--									S: successful
--							      	        E: error
--							       	        U: unexpected error
--

PROCEDURE get_calculate_amount(x_conversion_type			VARCHAR2		,
			       x_conversion_date			DATE			,
			       x_conversion_rate			NUMBER			,
			       x_org_amount				NUMBER			,
			       x_min_unit				NUMBER			,
			       x_fund_currency				VARCHAR2		,
			       x_project_currency			VARCHAR2		,
      			       x_amount			OUT 	NOCOPY	NUMBER			,
      			       x_return_status		OUT	NOCOPY	VARCHAR2
      			      );

END OKE_FUNDING_UTIL_PKG;

 

/
