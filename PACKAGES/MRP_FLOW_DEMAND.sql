--------------------------------------------------------
--  DDL for Package MRP_FLOW_DEMAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_FLOW_DEMAND" AUTHID CURRENT_USER AS
/* $Header: MRPFLOWS.pls 115.8 2002/12/04 21:31:16 pshah ship $ */

   TYPE number_arr IS TABLE OF number INDEX BY BINARY_INTEGER;

   TYPE parent_item_type is RECORD (
      inventory_item_id          number_arr,
      planned_quantity           number_arr,
      quantity_completed         number_arr
   );


PROCEDURE Main_Flow_Demand( i_RN             IN NUMBER,
                            o_return_code    OUT NOCOPY NUMBER,
                            o_error_message  OUT NOCOPY VARCHAR2);

PROCEDURE Get_Bill_Change( i_RN             IN NUMBER,
                           o_return_code    OUT NOCOPY NUMBER,
                           o_error_message  OUT NOCOPY VARCHAR2);

PROCEDURE Execute_Remained_JOBS( i_RN             IN NUMBER,
                                 o_return_code    OUT NOCOPY NUMBER,
                                 o_error_message  OUT NOCOPY VARCHAR2);

PROCEDURE Execute_Flow_Demand( i_RN             IN  NUMBER,
                               o_return_code    OUT NOCOPY NUMBER,
                               o_error_message  OUT NOCOPY VARCHAR2);

PROCEDURE Explode_Flow_Demands(    o_return_code      OUT NOCOPY NUMBER,
                                   o_error_message    OUT NOCOPY VARCHAR2);

PROCEDURE ReExplode_Flow_Demands(  o_return_code      OUT NOCOPY NUMBER,
                                   o_error_message    OUT NOCOPY VARCHAR2);

PROCEDURE Get_Phantoms(  i_parent_items     IN  parent_item_type,
                         o_phantom_items    OUT NOCOPY parent_item_type,
                         o_return_code      OUT NOCOPY NUMBER,
                         o_error_message    OUT NOCOPY VARCHAR2);

PROCEDURE Insert_Demands(i_parent_items     IN  PARENT_ITEM_TYPE,
                         i_level            IN  NUMBER,
                         o_return_code      OUT NOCOPY NUMBER,
                         o_error_message    OUT NOCOPY VARCHAR2);

END MRP_FLOW_DEMAND;

 

/
