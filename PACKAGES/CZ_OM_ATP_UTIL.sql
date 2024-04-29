--------------------------------------------------------
--  DDL for Package CZ_OM_ATP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_OM_ATP_UTIL" AUTHID CURRENT_USER AS
/* $Header: czomatps.pls 115.7 2002/11/27 17:07:31 askhacha ship $ */
-- Start of Comments
-- Package name:  CZ_OM_ATP_UTIL
--
-- Function:	  Package contains all CZ ATP utilities to support
--                Order Management.
--
-- NOTES: 1. item quantities must always be provided in the item's
--           primary unit of measure
--
-- End Of Comments

--  Global constants holding return status values.

G_RET_STS_SUCCESS CONSTANT CHAR := 'S';
G_RET_STS_ERROR CONSTANT CHAR := 'E';
G_RET_STS_UNEXP_ERROR CONSTANT CHAR := 'U';

-- Procedure insert_atp_request
-- Description:
--   Inserts  item data into the PLSQL record set of MRP_ATP_PUB.ATP_Rec_Typ records for an --	ATP check
--   on an item.  The insert_atp_request procedure should be called for
--   each item visible in the Configurator window.
--
--   The p_atp_group_id parameter should be unique if a new group ID should
--   be created.  Subsequent calls to insert_atp_request can use the group
--   ID returned from this first call.  Note that p_sequence_number must
--   be different for each call for a particular ATP group ID.


PROCEDURE insert_atp_request (p_inventory_item_id IN NUMBER,
				p_organization_id IN NUMBER,
  				p_quantity IN NUMBER,
				p_atp_group_id IN OUT NOCOPY NUMBER,
				p_sequence_number IN NUMBER,
				p_item_type_code IN NUMBER,
				p_session_id IN NUMBER,
			        p_return_status OUT NOCOPY VARCHAR2,
				p_error_message OUT NOCOPY VARCHAR2);

-- Procedure run_atp_check
-- Usage:
--   Called from configurator screen to check ATP for a group of items
-- Description:
--   Calls MRP_ATP_PUB.Call_ATP for items in PLSQL record set identified by ATP group ID .
--  Updates records with ATP results for each item

PROCEDURE run_atp_check (p_return_status OUT NOCOPY VARCHAR2,
			 p_error_message OUT NOCOPY VARCHAR2,
                         p_atp_group_id IN NUMBER,
 			 p_session_id IN NUMBER);

-- Procedure get_atp_result
-- Description:
--   Retrieves earliest ATP date result(ship_date) from PLSQL record set for the
--   item identified by ATP group ID sequence_number.

PROCEDURE get_atp_result (p_return_status OUT NOCOPY VARCHAR2,
			p_error_message OUT NOCOPY VARCHAR2,
			p_earliest_atp_date OUT NOCOPY DATE,
                        p_atp_group_id IN NUMBER,
			p_session_id IN NUMBER,
			p_sequence_number IN NUMBER DEFAULT 1);


-- Procedure clear_atp_data
-- Description:
--   Clears local package variables which hold data for an ATP group.

PROCEDURE clear_atp_data (p_return_status OUT NOCOPY VARCHAR2,
			p_error_message OUT NOCOPY VARCHAR2,
                        p_atp_group_id IN NUMBER,
			p_session_id IN NUMBER);

END CZ_OM_ATP_UTIL;

 

/
