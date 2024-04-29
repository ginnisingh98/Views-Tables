--------------------------------------------------------
--  DDL for Package FTE_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_PARTY_MERGE" AUTHID CURRENT_USER as
/* $Header: FTEPAMRS.pls 115.0 2003/07/21 19:38:35 arguha noship $ */

G_PACKAGE_NAME CONSTANT VARCHAR2(50) := 'FTE_PARTY_MERGE';

--***************************************************************************--

--========================================================================
-- PROCEDURE : merge_facility_contacts    Called by HZ Party merge routine
--                                        Should not be called by any other application
--
-- PARAMETERS: p_entity_name              HZ entity name being merged
--             p_from_id                  Input Facility Id to change
--             p_to_id                    Changed Facility Id
--             p_from_fk_id               Party id before merge
--             p_to_fk_id                 Party id after merge
--             p_parent_entity_name
--             p_batch_id
--             p_batch_party_id
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding facility_contact_id needs to be merged
--========================================================================

PROCEDURE merge_facility_contacts(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       IN  OUT NOCOPY VARCHAR2);

END FTE_PARTY_MERGE;

 

/
