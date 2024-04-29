--------------------------------------------------------
--  DDL for Package MSC_ATO_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATO_FORECAST" AUTHID CURRENT_USER AS
/* $Header: MSCATOFS.pls 115.0 2003/07/10 04:10:02 pmotewar noship $ */

    FUNCTION   OC_COM_RT_EXISTS (
			   p_inventory_item_id   IN  NUMBER,
			   p_org_id              IN  NUMBER,
			   p_sr_instance_id      IN  NUMBER,
			   p_routing_sequence_id IN  NUMBER,
			   p_bom_item_type       IN  NUMBER
		      ) RETURN NUMBER;

END;

 

/
