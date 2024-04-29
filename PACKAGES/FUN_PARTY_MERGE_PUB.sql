--------------------------------------------------------
--  DDL for Package FUN_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_PARTY_MERGE_PUB" AUTHID CURRENT_USER as
/* $Header: funptymerges.pls 120.0 2005/05/13 01:15:06 akwu noship $ */

G_PACKAGE_NAME CONSTANT VARCHAR2(50) := 'FUN_PARTY_MERGE_PUB';

--***************************************************************************--

--========================================================================
-- PROCEDURE : merge_trx_batches        Called by HZ Party merge routine
--                                      Should not be called by any other application
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
--             the corresponding initiator_id needs to be merged
--========================================================================

PROCEDURE merge_trx_batches(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2);


--========================================================================
-- PROCEDURE : merge_trx_headers        Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding initiator_id and recipient_id need to be merged
--========================================================================

PROCEDURE merge_trx_headers(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2);


--========================================================================
-- PROCEDURE : merge_dist_lines         Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding party_id needs to be merged
--========================================================================

PROCEDURE merge_dist_lines(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2);


--========================================================================
-- PROCEDURE : merge_customer_maps      Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding party_id needs to be merged
--========================================================================

PROCEDURE merge_customer_maps(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2);


--========================================================================
-- PROCEDURE : merge_supplier_maps      Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding party_id needs to be merged
--========================================================================

PROCEDURE merge_supplier_maps(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2);


END FUN_PARTY_MERGE_PUB;

 

/
