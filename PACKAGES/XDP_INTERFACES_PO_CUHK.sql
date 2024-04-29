--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_PO_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_PO_CUHK" AUTHID CURRENT_USER AS
/* $Header: XDPPOCHS.pls 120.2 2005/07/07 02:04:12 appldev ship $ */

-- PL/SQL Specification
-- Datastructure Definitions


 -- API specifications

 /*
  This procedure is used for the customer to add
  customization PRIOR to the Process_order API
  */

  Procedure Process_order_Pre(  p_order_header IN OUT NOCOPY XDP_TYPES.ORDER_HEADER,
				p_order_parameter IN OUT NOCOPY XDP_TYPES.ORDER_PARAMETER_LIST,
				p_order_line_list IN OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
				p_line_parameter_list IN OUT NOCOPY XDP_TYPES.LINE_PARAM_LIST,
				p_sdp_order_id  IN OUT NOCOPY NUMBER,
				x_data  IN OUT NOCOPY  VARCHAR2,
				x_count  IN OUT NOCOPY NUMBER,
			  	x_return_code  IN OUT NOCOPY VARCHAR2
			      );

 /*
  This procedure is used for the customer to add
  customization AFTER the Process_order API
  */

  Procedure Process_order_Post(  p_order_header       IN OUT NOCOPY XDP_TYPES.ORDER_HEADER,
				 p_order_parameter     IN OUT NOCOPY XDP_TYPES.ORDER_PARAMETER_LIST,
				 p_order_line_list     IN OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
				 p_line_parameter_list IN OUT NOCOPY XDP_TYPES.LINE_PARAM_LIST,
				 p_sdp_order_id        IN OUT NOCOPY NUMBER,
				 x_data                IN OUT NOCOPY VARCHAR2,
				 x_count               IN OUT NOCOPY NUMBER,
			  	 x_return_code         IN OUT NOCOPY VARCHAR2
			       );

 /*
  This function is called prior to generating message
  for Process Order
 */

    Function Ok_to_Generate_msg(p_order_header        XDP_TYPES.ORDER_HEADER,
				   p_order_parameter     XDP_TYPES.ORDER_PARAMETER_LIST,
				   p_order_line_list     XDP_TYPES.ORDER_LINE_LIST,
				   p_line_parameter_list XDP_TYPES.LINE_PARAM_LIST,
				   p_sdp_order_id        NUMBER
				  ) return Boolean;


END XDP_INTERFACES_PO_CUHK;

 

/
