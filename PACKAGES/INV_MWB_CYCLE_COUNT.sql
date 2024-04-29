--------------------------------------------------------
--  DDL for Package INV_MWB_CYCLE_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MWB_CYCLE_COUNT" AUTHID CURRENT_USER AS
/* $Header: INVMWBCS.pls 120.2 2005/06/17 04:49:10 appldev  $ */
procedure create_cc_details(
				X_return_status    OUT NOCOPY /* file.sql.39 change */ 	    VARCHAR2,
				X_msg_count        OUT NOCOPY /* file.sql.39 change */      NUMBER,
				X_msg_data         OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
				p_organization_id           NUMBER,
				p_cycle_count_header_id	    NUMBER,
				p_abc_class_id              NUMBER,
				p_schedule_date             DATE,
				p_inventory_item_id	    NUMBER,
				p_revision		    VARCHAR2,
				p_subinventory_code	    VARCHAR2,
				p_locator_id		    NUMBER,
				p_lot_number		    VARCHAR2 ,
				p_serial_number		    VARCHAR2,
				p_userid		    VARCHAR2
			    );

procedure commit_data;
END INV_MWB_CYCLE_COUNT;

 

/
