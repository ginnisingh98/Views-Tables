--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_SO_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_SO_CUHK" AUTHID CURRENT_USER AS
/* $Header: XDPSOCHS.pls 120.2 2005/07/07 00:52:03 appldev ship $ */

-- PL/SQL Specification
-- Datastructure Definitions


 -- API specifications

  /* For new open interfaces*/

  Procedure Process_order_Pre(
    p_order_header 	        IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_HEADER,
    p_order_param_list      IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    p_order_line_list       IN OUT NOCOPY XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    p_line_param_list       IN OUT NOCOPY XDP_TYPES.SERVICE_LINE_PARAM_LIST,
    p_order_id	            IN OUT NOCOPY NUMBER,
    x_data                  IN OUT NOCOPY VARCHAR2,
    x_count                 IN OUT NOCOPY NUMBER,
    x_return_code           IN OUT NOCOPY VARCHAR2
  );
  Procedure Process_Order_Post(
    p_order_header 	      IN OUT NOCOPY  XDP_TYPES.SERVICE_ORDER_HEADER,
    p_order_param_list    IN OUT NOCOPY  XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    p_order_line_list     IN OUT NOCOPY  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    p_line_param_list     IN OUT NOCOPY  XDP_TYPES.SERVICE_LINE_PARAM_LIST,
    p_order_id	          IN OUT NOCOPY NUMBER,
    x_data                IN OUT NOCOPY  VARCHAR2,
    x_count               IN OUT NOCOPY NUMBER,
    x_return_code         IN OUT NOCOPY VARCHAR2
  );
  Function Ok_to_Generate_msg(
    p_order_header 	      IN OUT NOCOPY  XDP_TYPES.SERVICE_ORDER_HEADER,
    p_order_param_list    IN OUT NOCOPY  XDP_TYPES.SERVICE_ORDER_PARAM_LIST,
    p_order_line_list     IN OUT NOCOPY  XDP_TYPES.SERVICE_ORDER_LINE_LIST,
    p_line_param_list     IN OUT NOCOPY  XDP_TYPES.SERVICE_LINE_PARAM_LIST,
    p_order_id	          IN OUT NOCOPY NUMBER
  ) return Boolean;

END XDP_INTERFACES_SO_CUHK;

 

/
