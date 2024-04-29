--------------------------------------------------------
--  DDL for Package INV_SELECT_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SELECT_INVENTORY_PKG" AUTHID CURRENT_USER as
/* $Header: INVPCKLS.pls 120.1 2005/07/11 09:06:39 methomas noship $ */

  PROCEDURE get_source_info (V_source_type_id IN NUMBER,V_source_line_id IN NUMBER,V_source_id IN NUMBER,
                             X_header_no OUT NOCOPY VARCHAR2, X_line_no OUT NOCOPY NUMBER,
                             X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_details (V_move_order_line_id IN NUMBER,X_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE get_available_inventory (p_mo_line_id            IN NUMBER
  				   , x_return_status         OUT NOCOPY VARCHAR2
   				   , x_msg_count             OUT NOCOPY NUMBER
   				   , x_msg_data              OUT NOCOPY VARCHAR2);




END INV_SELECT_INVENTORY_PKG;

 

/
