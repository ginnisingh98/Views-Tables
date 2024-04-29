--------------------------------------------------------
--  DDL for Package OE_RMA_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RMA_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXGRMAS.pls 120.0 2005/05/31 23:24:07 appldev noship $ */

/*
** Create a Record Type for Passing the Result of Is_Over_Return()
*/
TYPE Over_Return_Err_Rec_Type IS RECORD
(   line_id            NUMBER
,   previous_quantity  NUMBER
,   current_quantity   NUMBER
,   original_quantity  NUMBER
,   return_status      VARCHAR2(30)
,   msg_count          NUMBER
,   msg_data           VARCHAR2(2000)
);

TYPE Over_Return_Err_Tbl_Type IS TABLE OF Over_Return_Err_Rec_Type
INDEX BY BINARY_INTEGER;

/*
** Submit_Ordeer() will progress the return order header forward
** from Awaiting Submission once the user submits the order.
*/
PROCEDURE Submit_Order(
  p_api_version		IN	NUMBER
, p_header_id 		IN 	NUMBER
, x_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
, x_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
, x_msg_data		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

/*
** Is_Over_Return() will check if returned qty matches the original
** ordered qty. If returned qty exceeds the original ordered qty, the
** API will raise an error.
**
** NOTE that this api even looks at Unbooked Return Lines, which is
** different from the Is_Over_Return() procedure in OE_LINE_UTIL Package.
*/
PROCEDURE Is_Over_Return(
  p_api_version		IN	NUMBER
, p_line_tbl		IN 	OE_ORDER_PUB.LINE_TBL_TYPE
, x_error_tbl           OUT NOCOPY /* file.sql.39 change */     OE_RMA_GRP.OVER_RETURN_ERR_TBL_TYPE
, x_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
, x_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
, x_msg_data		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

/*
** Post_Approval_Process() will be called from workflow activity to do
** some post approval steps. For example it will call iStore API that
** sends the notification on approval of the return order to the end user.
*/
PROCEDURE Post_Approval_Process(
  itemtype 	IN 	VARCHAR2
, itemkey 	IN 	VARCHAR2
, actid 	IN 	NUMBER
, funcmode 	IN 	VARCHAR2
, resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);

/*
** Post_Rejection_Process() will set the reason for rejecting the RMA
** into OE_REASONS table. It will also call iStore API that sends the
** notification on rejection of the return order to the end user.
*/
PROCEDURE Post_Rejection_Process(
  itemtype 	IN 	VARCHAR2
, itemkey 	IN 	VARCHAR2
, actid 	IN 	NUMBER
, funcmode 	IN 	VARCHAR2
, resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);

END OE_RMA_GRP;

 

/
