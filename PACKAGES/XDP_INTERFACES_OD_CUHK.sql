--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_OD_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_OD_CUHK" AUTHID CURRENT_USER AS
/* $Header: XDPODCHS.pls 120.2 2005/07/07 02:10:15 appldev ship $ */

 /*
  This procedure is used for the customer to add
  customization PRIOR to the Get_Order_Details API
  */
PROCEDURE Get_Order_Details_Pre(
    p_order_number  	IN OUT NOCOPY VARCHAR2,
    p_order_version	  	IN OUT NOCOPY VARCHAR2,
    p_order_id 		    IN OUT NOCOPY NUMBER,
    x_order_header		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
    x_order_param_list	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    x_line_item_list	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    x_line_param_list	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
    x_data          IN OUT NOCOPY VARCHAR2,
	x_count         IN OUT NOCOPY NUMBER,
	x_return_code   IN OUT NOCOPY VARCHAR2
);

 /*
  This procedure is used for the customer to add
  customization AFTER to the Get_Order_Details API
  */
PROCEDURE Get_Order_Details_Post(
    p_order_number  	IN OUT NOCOPY VARCHAR2,
    p_order_version	  	IN OUT NOCOPY VARCHAR2,
    p_order_id 		    IN OUT NOCOPY NUMBER,
    x_order_header		IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
    x_order_param_list	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    x_line_item_list	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    x_line_param_list	IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
    x_data          IN OUT NOCOPY VARCHAR2,
	x_count         IN OUT NOCOPY NUMBER,
	x_return_code   IN OUT NOCOPY VARCHAR2
);

END XDP_INTERFACES_OD_CUHK;

 

/
