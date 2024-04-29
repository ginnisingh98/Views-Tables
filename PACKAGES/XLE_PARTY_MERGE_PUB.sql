--------------------------------------------------------
--  DDL for Package XLE_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_PARTY_MERGE_PUB" AUTHID CURRENT_USER as
/* $Header: xleptymerges.pls 120.3 2006/03/29 14:43:01 cjain ship $ */

G_PACKAGE_NAME CONSTANT VARCHAR2(50) := 'XLE_PARTY_MERGE_PUB';

--***************************************************************************--

--========================================================================
-- PROCEDURE : merge_registrations       Called by HZ Party merge routine
--                                       Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding initiator_id and recipient_id need to be merged
--========================================================================

PROCEDURE merge_registrations(
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
-- PROCEDURE : merge_reg_functions         Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             the corresponding party_id needs to be merged
--========================================================================

PROCEDURE merge_reg_functions(
p_entity_name         IN            VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2);

--========================================================================
-- PROCEDURE : merge_legal_entities     Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             It should veto the merging of legal entities.
--========================================================================

PROCEDURE merge_legal_entities(
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
-- PROCEDURE : merge_establishments     Called by HZ Party merge routine
--                                      Should not be called by any other application
--
-- COMMENT   : This procedure is used to perform for following actions
--             When the relationship party merges
--             It should veto the merging of establishments.
--========================================================================

PROCEDURE merge_establishments(
p_entity_name         IN             VARCHAR2,
p_from_id             IN             NUMBER,
p_to_id               IN  OUT NOCOPY NUMBER,
p_from_fk_id          IN             NUMBER,
p_to_fk_id            IN             NUMBER,
p_parent_entity_name  IN             VARCHAR2,
p_batch_id            IN             NUMBER,
p_batch_party_id      IN             NUMBER,
x_return_status       OUT NOCOPY     VARCHAR2);

END XLE_PARTY_MERGE_PUB;


 

/
