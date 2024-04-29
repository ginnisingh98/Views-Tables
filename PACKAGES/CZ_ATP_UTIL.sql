--------------------------------------------------------
--  DDL for Package CZ_ATP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_ATP_UTIL" AUTHID CURRENT_USER AS
/* $Header: czatpus.pls 120.0 2005/05/25 06:14:55 appldev noship $ */
-- Start of Comments
-- Package name:  CZ_ATP_UTIL
--
-- Function:	  Package contains all CZ ATP utilities.
--
-- NOTES: 1. item quantities must always be provided in the item's
--           primary unit of measure
--        2. insert_atp_request and get_atp_result currently commit
--           transactions, because "read only" Java side doesn't
--           currently manage transactions
--
-- End Of Comments

--  Global constants holding return status values.

G_RET_STS_SUCCESS CONSTANT CHAR := 'S';
G_RET_STS_ERROR CONSTANT CHAR := 'E';
G_RET_STS_UNEXP_ERROR CONSTANT CHAR := 'U';

-- Procedure insert_atp_request
-- Description:
--   Inserts data into the MTL_DEMAND_INTERFACE table for an ATP check
--   on an item.  The insert_atp_request procedure should be called before
--   calling run_atp_check.
--
--   The p_atp_group_id parameter should be NULL if a new group ID should
--   be created.  Subsequent calls to insert_atp_request can use the group
--   ID returned from this first call.  Note that p_sequence_number must
--   be different for each call for a particular ATP group ID.
--
--   NOTE:  insert_atp_request issues a commit after inserting record

PROCEDURE insert_atp_request (p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER,
  							  p_quantity IN NUMBER, p_atp_group_id IN OUT NOCOPY NUMBER,
							  p_return_status OUT NOCOPY VARCHAR2, p_error_message OUT NOCOPY VARCHAR2,
							  p_sequence_number IN NUMBER,
							  p_atp_rule_id IN NUMBER DEFAULT NULL);


-- Procedure run_atp_check
-- Usage:
--   Called from configurator screen to check ATP for an item
-- Description:
--   Runs the demand interface program (INXATP) to calculate
--   ATP dates for items in ATP group identified by p_atp_group_id.

PROCEDURE run_atp_check (p_return_status OUT NOCOPY VARCHAR2, p_error_message OUT NOCOPY VARCHAR2,
                         p_atp_group_id IN NUMBER, p_user_id IN NUMBER,
                         p_resp_id IN NUMBER, p_appl_id IN NUMBER,
                         p_timeout IN NUMBER);


-- Procedure get_atp_result
-- Description:
--   Retrieves earliest ATP date result from mtl_demand_interface for the
--   item identified by ATP group ID and sequence number.  Deletes the line
--   from mtl_demand_interface after retrieval.
--   NOTE:  insert_atp_request issues a commit after deleting record

PROCEDURE get_atp_result (p_atp_group_id IN NUMBER, p_earliest_atp_date OUT NOCOPY DATE,
                          p_return_status OUT NOCOPY VARCHAR2, p_error_message OUT NOCOPY VARCHAR2,
                          p_sequence_number IN NUMBER);


END CZ_ATP_UTIL;


 

/
