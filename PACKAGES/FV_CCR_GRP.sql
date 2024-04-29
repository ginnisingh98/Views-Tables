--------------------------------------------------------
--  DDL for Package FV_CCR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CCR_GRP" AUTHID CURRENT_USER AS
/* $Header: FVGACCRS.pls 120.0.12000000.2 2007/09/28 15:02:39 sasukuma ship $*/
-- Start of comments
--	API name 	: 	FV_IS_CCR
--	Type		: 	Group.
--	Function	:
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN		:	p_api_version		IN NUMBER
--				p_init_msg_list		IN VARCHAR2
--					Default = null
--				p_object_id			IN NUMBER
--				p_object_type		IN VARCHAR2(1)
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT VARCHAR2(2000)
--				x_ccr_id			OUT NUMBER
--				x_error_code		OUT NUMBER
--				x_out_status		OUT VARCHAR2(1)
--
--	Version	: 		Current version	1.0
--			  	Initial version 	1.0
--
--	Notes		: 	This API determines whether a given supplier site
--				represents a CCR vendor and returns its unique
--				identifier and boolean variable showing whether it is
--				CCR or Not and error_code if the object is ccr but some
--				too many rows exist for the object.
--
-- End of comments
PROCEDURE FV_IS_CCR
( 	p_api_version      	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 DEFAULT null,
	p_object_id			IN	NUMBER,
	p_object_type		IN  VARCHAR2,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	x_ccr_id			OUT	NOCOPY NUMBER,
	x_out_status		OUT	NOCOPY VARCHAR2,
	x_error_code		OUT NOCOPY NUMBER
);


-- Start of comments
--	API name 	: 	FV_CCR_REG_STATUS
--	Type		: 	Group.
--	Function	:
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN		:	p_api_version		IN NUMBER
--				p_init_msg_list		IN VARCHAR2
--					Default null
--				p_vendor_site_id	IN NUMBER
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT VARCHAR2(2000)
--				x_ccr_status		OUT VARCHAR2(30)
--				x_error_code		OUT	NUMBER
--
--	Version	: 		Current version	1.0
--			  	Initial version 	1.0
--
--	Notes		: 	This API checks the registration
--				status of a CCR vendor.
--
-- End of comments
PROCEDURE FV_CCR_REG_STATUS
( 	p_api_version      	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 DEFAULT null,
	p_vendor_site_id	IN	NUMBER,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	x_ccr_status		OUT	NOCOPY VARCHAR2,
	x_error_code		OUT	NOCOPY NUMBER
);


-- Start of comments
--	API name   : IS_VENDOR_FEDERAL
--	Type       : Group.
--	Function   :
--	Pre-reqs   : None.
--	Parameters :
--	IN    p_api_version   IN NUMBER
--        p_init_msg_list	IN VARCHAR2
--          Default null
--        p_vendor_id	    IN NUMBER
--
--	OUT   x_return_status OUT	VARCHAR2(1)
--        x_msg_count     OUT	NUMBER
--        x_msg_data      OUT VARCHAR2(2000)
--        x_error_code    OUT	NUMBER
--        x_federal       OUT VARCHAR2(1)
--
--	Version	: Current version	1.0
--            Initial version 1.0
--
--	Notes : This API returns a value of Y if
--          the vendor is FEDERAL or else
--          it returns a value of N
--
-- End of comments
PROCEDURE IS_VENDOR_FEDERAL
(
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 DEFAULT NULL,
  p_vendor_id      IN  NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2,
  x_federal        OUT NOCOPY VARCHAR2,
  x_error_code     OUT NOCOPY NUMBER
);



-- Start of comments
--	API name 	: 	FV_IS_BANK_ACCOUNT_USES_CCR
--	Type		: 	Group.
--	Function	:
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN		:	p_api_version		IN NUMBER
--				p_init_msg_list		IN VARCHAR2
--					Default = null
--				p_vendor_site_id	IN NUMBER
--
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count			OUT	NUMBER
--				x_msg_data			OUT VARCHAR2(2000)
--				x_error_code		OUT NUMBER
--				x_out_status		OUT VARCHAR2(1)
--
--	Version	: 		Current version	1.0
--			  	Initial version 	1.0
--
--	Notes		: 	This API determines whether a given supplier site
--				has bank account use created by ccr or not. It returns
--				Y if bank account use is created by Data Processing
--				program as part of CCR Import.
--
-- End of comments

PROCEDURE FV_IS_BANK_ACCOUNT_USES_CCR
( 	p_api_version      	IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 DEFAULT NULL,
	p_vendor_site_id	IN	NUMBER,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
	x_out_status		OUT	NOCOPY VARCHAR2,
	x_error_code		OUT NOCOPY NUMBER
);

FUNCTION  SELECT_THIRD_PARTY
(
  p_vendor_site_id NUMBER
) RETURN VARCHAR2;
FUNCTION  SELECT_BANK_ACCOUNT
(
  p_bank_account_id IN NUMBER,
  p_vendor_site_id NUMBER
) RETURN NUMBER;

END;

 

/
