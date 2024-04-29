--------------------------------------------------------
--  DDL for Package ONT_CUSTACCEPTOIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_CUSTACCEPTOIP_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVOIPS.pls 120.1 2005/08/31 00:12:14 myerrams noship $ */
-- Start of comments
--	API name 	: Call_OIP_Process_Order
--	Type		: Private.
--	Function	: Calls OE_Order_PVT.Process_Order API after building the appropriate parameters.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:
--                        p_header_id             IN      NUMBER
--                        p_line_id_tbl           IN 	 ont_num_tbl_type
--                        p_reference_document    IN	 VARCHAR2
--                        p_customer_signature    IN	 VARCHAR2
--                        p_signature_date        IN	 DATE
--                        p_customer_comments     IN	 VARCHAR2
--	OUT	        : x_return_status         OUT	 VARCHAR2
--                        x_msg_count             OUT	 NUMBER
--                        x_msg_data              OUT	 VARCHAR2
--	Version	: Current version	1.0
--
--	Notes		: This Package is primarily created to have all the customer acceptance
--                        private procedures and functions related to OIP(Order Information Portal).
--
-- End of comments

PROCEDURE Call_OIP_Process_Order
(
  p_header_id                    IN          NUMBER
, p_line_id_tbl                  IN          ONT_NUM_TBL_TYPE
, p_reference_document           IN          VARCHAR2
, p_customer_signature           IN          VARCHAR2
, p_signature_date               IN          DATE
, p_customer_comments            IN          VARCHAR2
, p_action                       IN          VARCHAR2
, x_return_status                OUT NOCOPY  VARCHAR2
, x_msg_count                    OUT NOCOPY  NUMBER
, x_msg_data                     OUT NOCOPY  VARCHAR2
);

END ONT_CustAcceptOip_PVT;

 

/
