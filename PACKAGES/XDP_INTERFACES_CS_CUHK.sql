--------------------------------------------------------
--  DDL for Package XDP_INTERFACES_CS_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INTERFACES_CS_CUHK" AUTHID CURRENT_USER AS
/* $Header: XDPCSCHS.pls 120.2 2005/07/07 02:18:17 appldev ship $ */

-- PL/SQL Specification
-- Datastructure Definitions


 -- API specifications


/* For new open interface   */
  Procedure Cancel_Order_Pre(
        p_caller_name   IN OUT NOCOPY VARCHAR2,
	    p_order_id      IN OUT NOCOPY NUMBER,
        p_order_number 	IN OUT NOCOPY  VARCHAR2,
        p_order_version IN OUT NOCOPY  VARCHAR2,
	    x_data          IN OUT NOCOPY VARCHAR2,
	    x_count         IN OUT NOCOPY NUMBER,
	    x_return_code   IN OUT NOCOPY VARCHAR2
  );

  Procedure Cancel_Order_Post(
        p_caller_name   IN OUT NOCOPY VARCHAR2,
	    p_order_id      IN OUT NOCOPY NUMBER,
        p_order_number 	IN OUT NOCOPY  VARCHAR2,
        p_order_version IN OUT NOCOPY  VARCHAR2,
	    x_data          IN OUT NOCOPY VARCHAR2,
	    x_count         IN OUT NOCOPY NUMBER,
	    x_return_code   IN OUT NOCOPY VARCHAR2
  );

 Function Ok_to_Generate_msg(
        p_caller_name   VARCHAR2,
		p_order_id  NUMBER
 ) return Boolean;


  END XDP_INTERFACES_CS_CUHK;

 

/
