--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_OS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_OS_CUHK" AUTHID CURRENT_USER AS
/* $Header: XDPOSCHS.pls 120.2 2005/07/07 02:07:41 appldev ship $ */

 /*
  This procedure is used for the customer to add
  customization PRIOR to the Get_Order_Status API
  */
PROCEDURE Get_Order_Status_Pre(
    p_order_number  	IN OUT NOCOPY VARCHAR2,
    p_order_version	  	IN OUT NOCOPY VARCHAR2,
    p_order_id 		    IN OUT NOCOPY NUMBER,
    x_order_status  	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_STATUS,
    x_data          IN OUT NOCOPY VARCHAR2,
	x_count         IN OUT NOCOPY NUMBER,
	x_return_code   IN OUT NOCOPY VARCHAR2
);

 /*
  This procedure is used for the customer to add
  customization AFTER to the Get_Order_Status API
  */
PROCEDURE Get_Order_Status_Post(
    p_order_number  	IN OUT NOCOPY VARCHAR2,
    p_order_version	  	IN OUT NOCOPY VARCHAR2,
    p_order_id 		    IN OUT NOCOPY NUMBER,
    x_order_status	IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_STATUS,
    x_data          IN OUT NOCOPY VARCHAR2,
	x_count         IN OUT NOCOPY NUMBER,
	x_return_code   IN OUT NOCOPY VARCHAR2
);

END XDP_INTERFACES_OS_CUHK;

 

/
