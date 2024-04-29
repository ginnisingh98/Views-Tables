--------------------------------------------------------
--  DDL for Package OE_COGS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_COGS_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXGCGSS.pls 120.0 2005/06/24 01:20:26 ddey noship $ */

PROCEDURE get_revenue_event_line
            (
             p_shippable_line_id      IN  NUMBER,
             x_revenue_event_line_id  OUT NOCOPY NUMBER,
             x_return_status          OUT NOCOPY VARCHAR2,
             x_msg_count              OUT NOCOPY NUMBER,
             x_msg_data               OUT NOCOPY VARCHAR2
           );

FUNCTION is_revenue_event_line
          (
 	   p_line_id       IN  NUMBER
 	  ) RETURN VARCHAR2;


END oe_cogs_grp;

 

/
