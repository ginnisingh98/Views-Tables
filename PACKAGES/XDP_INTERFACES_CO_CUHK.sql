--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_CO_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_CO_CUHK" AUTHID CURRENT_USER AS
/* $Header: XDPCOCHS.pls 120.2 2005/07/07 02:18:58 appldev ship $ */

-- PL/SQL Specification
-- Datastructure Definitions


 -- API specifications

/* This procedure is used for the customer to add
   customization PRIOR to the Cancel_order API
*/

  Procedure Cancel_order_Pre(   p_caller_name    IN OUT NOCOPY VARCHAR2,
				p_sdp_order_id   IN OUT NOCOPY NUMBER,
				x_data           IN OUT NOCOPY VARCHAR2,
				x_count          IN OUT NOCOPY NUMBER,
			  	x_return_code    IN OUT NOCOPY VARCHAR2
			     );


/* This procedure is used for the customer to add
   customization AFTER the Cancel_order API
*/

  Procedure Cancel_order_Post(   p_caller_name    IN OUT NOCOPY VARCHAR2,
				 p_sdp_order_id    IN OUT NOCOPY NUMBER,
				 x_data            IN OUT NOCOPY VARCHAR2,
				 x_count           IN OUT NOCOPY NUMBER,
			  	 x_return_code     IN OUT NOCOPY VARCHAR2
			     );

 /*
  This function is called prior to generating message
  for Cancel Order
 */

    Function Ok_to_Generate_msg(p_caller_name   VARCHAR2,
				   p_sdp_order_id  NUMBER
				   ) return Boolean;


END XDP_INTERFACES_CO_CUHK;

 

/
