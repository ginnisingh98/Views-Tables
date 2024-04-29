--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_CO_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_CO_VUHK" AUTHID CURRENT_USER AS
/* $Header: XDPCOVHS.pls 120.1 2005/06/15 22:42:40 appldev  $ */

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


END XDP_INTERFACES_CO_VUHK;

 

/
