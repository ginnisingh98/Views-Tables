--------------------------------------------------------
--  DDL for Package GMO_LABEL_MGMT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_LABEL_MGMT_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGLBPS.pls 120.1 2005/09/21 14:01:42 skarimis noship $ */

/* Global Constants */

G_PKG_NAME            CONSTANT            varchar2(30) := 'GMO_LABEL_MGMT_GRP';


/* Record Type Decleration */
TYPE Context_rec IS RECORD (Name VARCHAR2(80), Value VARCHAR2(4000),DISPLAY_SEQUENCE number(2));
TYPE CONTEXT_TABLE is TABLE of CONTEXT_rec INDEX by Binary_INTEGER;


-- Start of comments
-- API name   : PRINT_LABEL
-- Type       : Group.
-- Function   : To Initiate Label Print.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
--              	P_ENTITY_NAME            	IN VARCHAR2 Required
-- 		    	P_ENTITY_KEY             	IN VARCHAR2 Required
-- 			P_WMS_BUSINESS_FLOW_CODE      IN NUMBER   Required
-- 			P_LABEL_TYPE                  IN VARCHAR2 Required
-- 			P_TRANSACTION_ID              IN VARCHAR2 Required
-- 			P_TRANSACTION_TYPE            IN NUMBER   Required
-- 			P_APPLICATION_SHORT_NAME      IN VARCHAR2 Required
-- 			P_REQUESTER                   IN NUMBER   Required
-- 			P_CONTEXT                     IN TABLE OF RECORD of type CONTEXT_TABLE
--    .
-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
--    .           x_Label_ID       OUT NUMBER
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments


PROCEDURE PRINT_LABEL (
			p_api_version		IN 	NUMBER,
			p_init_msg_list		IN 	VARCHAR2,
			x_return_status		OUT 	NOCOPY VARCHAR2,
			x_msg_count			OUT	NOCOPY NUMBER,
			x_msg_data			OUT	NOCOPY VARCHAR2,
			P_ENTITY_NAME 		IN	VARCHAR2,
        		P_ENTITY_KEY      	IN    VARCHAR2,
        		P_WMS_BUSINESS_FLOW_CODE IN NUMBER,
        		P_LABEL_TYPE 		IN VARCHAR2,
        		P_TRANSACTION_ID 		IN VARCHAR2,
        		P_TRANSACTION_TYPE 	IN NUMBER,
        		P_APPLICATION_SHORT_NAME IN VARCHAR2,
        		P_REQUESTER 		IN NUMBER,
        		P_CONTEXT IN GMO_LABEL_MGMT_GRP.CONTEXT_TABLE,
			x_Label_id			OUT	NOCOPY NUMBER);

-- Start of comments
-- API name   : COMPLETE_LABEL_PRINT
-- Type       : Group.
-- Function   : To Complete label printing.
-- Pre-reqs   : PRINT_LABEL should have been called earlier to this API.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
--              	P_ENTITY_NAME            	IN VARCHAR2 Required
-- 		    	P_ENTITY_KEY             	IN VARCHAR2 Required
-- 			P_LABEL_ID                    IN NUMBER   Required
-- 			P_ERECORD_ID                  IN NUMBER
-- 			P_ERECORD_STATUS              IN VARCHAR2

-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
--    .           x_Print_status   OUT VARCHAR2
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE COMPLETE_LABEL_PRINT(
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN 	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count			OUT	NOCOPY NUMBER,
		x_msg_data			OUT	NOCOPY VARCHAR2,
		P_LABEL_ID 	        	IN	NUMBER,
        	P_ERECORD_ID            IN    NUMBER,
        	P_ERECORD_STATUS        IN    VARCHAR2,
		x_print_status	      OUT	NOCOPY VARCHAR2);

-- Start of comments
-- API name   : CANCEL_LABEL_PRINT
-- Type       : Group.
-- Function   : To Cancel label printing.
-- Pre-reqs   : PRINT_LABEL should have been called earlier to this API.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
--              	P_ENTITY_NAME            	IN VARCHAR2 Required
-- 		    	P_ENTITY_KEY             	IN VARCHAR2 Required
-- 			P_LABEL_ID                    IN NUMBER   Required

-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments


PROCEDURE CANCEL_LABEL_PRINT(
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN 	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count			OUT	NOCOPY NUMBER,
		x_msg_data			OUT	NOCOPY VARCHAR2,
		P_LABEL_ID 	        	IN	NUMBER
        );

-- Start of comments
-- API name   : AUTO_PRINT_ENABLED
-- Type       : Group.
-- Function   : Determines if auto matic label printing is enabled or not.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : 	None

-- OUT        : 	Boolean true or false
-- Version    : None
--
-- End of comments

FUNCTION AUTO_PRINT_ENABLED return boolean;

-- Start of comments
-- API name   : GET_PRINT_COUNT
-- Type       : Group.
-- Function   : Returns the no of labels printed for the given input parameters.
-- Pre-reqs   : None.
-- Parameters :
-- IN         : 	p_api_version            	IN NUMBER   Required
--              	p_init_msg_list	     		IN VARCHAR2 Required
-- 			P_WMS_BUSINESS_FLOW_CODE      IN NUMBER   Required
-- 			P_LABEL_TYPE                  IN VARCHAR2 Required
-- 			P_TRANSACTION_ID              IN VARCHAR2 Required
-- 			P_TRANSACTION_TYPE            IN NUMBER   Required
--    .
-- OUT        : 	x_return_status  OUT VARCHAR2(1)
--              	x_msg_count      OUT NUMBER
--              	x_msg_data       OUT VARCHAR2(2000)
--    .           x_print_count    OUT NUMBER
-- Version    : Current version 1.0
--              Initial version  1.0
--
-- End of comments

PROCEDURE GET_PRINT_COUNT(
		p_api_version		IN 	NUMBER,
		p_init_msg_list		IN 	VARCHAR2,
		x_return_status		OUT 	NOCOPY VARCHAR2,
		x_msg_count			OUT	NOCOPY NUMBER,
		x_msg_data			OUT	NOCOPY VARCHAR2,
		P_WMS_BUSINESS_FLOW_CODE IN 	NUMBER,
        	P_LABEL_TYPE 		 IN 	NUMBER,
        	P_TRANSACTION_ID 		 IN 	VARCHAR2,
        	P_TRANSACTION_TYPE 	 IN 	VARCHAR2,
        	x_print_count		 OUT	NOCOPY NUMBER);

end GMO_LABEL_MGMT_GRP;

 

/
