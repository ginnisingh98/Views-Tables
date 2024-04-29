--------------------------------------------------------
--  DDL for Package GMF_PROCESS_COST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_PROCESS_COST_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPPCPS.pls 120.0 2005/11/21 14:01:49 sschinch noship $ */

/************************************************************************************
  *  PROCEDURE
  *     Get_Prior_Period_Cost
  *
  *  DESCRIPTION
  *     This procedure will return prior period cost for an organization/item for the cost
  *     type defined in fiscal policy.
  *
  *  AUTHOR
  *    Sukarna Reddy Chinchod 21-NOV-2005
  *
  *  INPUT PARAMETERS
  *   p_inventory_item_id
  *   p_organization_id
  *   p_transaction_date
  *
  *  OUTPUT PARAMETERS
  *	Returns Prior cost of an item.
  *	Status 'S' or 'E'
  *
  * HISTORY
  *
  **************************************************************************************/

  PROCEDURE Get_Prior_Period_Cost(p_inventory_item_id IN          NUMBER,
                                  p_organization_id   IN          NUMBER,
                                  p_transaction_date  IN          DATE,
                                  x_unit_cost         OUT NOCOPY  NUMBER,
                                  x_msg_data          OUT NOCOPY  VARCHAR2,
                                  x_return_status     OUT NOCOPY  VARCHAR2
                               );
END GMF_PROCESS_COST_PUB;

 

/
