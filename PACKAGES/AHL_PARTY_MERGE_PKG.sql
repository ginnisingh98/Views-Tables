--------------------------------------------------------
--  DDL for Package AHL_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PARTY_MERGE_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLPMRGS.pls 115.15 2003/05/16 20:57:25 sracha noship $ */
-- Start of Comments
-- Package name     : AHL_PARTY_MERGE_PKG
-- Purpose          : Merges duplicate parties in Advanced Service
--		      Online tables. The
--                    Tables that need to be considered for
--                    Party Merge are:
--			AHL_DOCUMENTS_B
--			AHL_SUPPLIER_DOCUMENTS
--			AHL_RECIPIENT_DOCUEMTNS
--			AHL_SUBSCRIPTIONS_B
--			AHL_DOC_REVISIONS_B
--			AHL_DOC_REVISION_COPIES
--
--			AHL_OPERATIONS_B
--			AHL_OPERATIONS_H_B
--			AHL_ROUTES_B
--			AHL_ROUTES_H_B
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 07-30-2001    vrankaiy      Created.
-- 12-20-2001    jeli          Added the four entities for RM.
--
--                Refer to bug # 1539248 for party merge registration details.
--
-- 03-Sep-2002    ssurapan      Commented operation party id as per route enhancements
-- 07-Apr-2003    jaramana      Added a routine for OSP (Customer)
-- End of Comments

PROCEDURE AHL_DI_SOURCE_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE AHL_DI_SUPPLIER (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE AHL_DI_RECIPIENT_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE AHL_DI_REQUESTED_BY_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE AHL_DI_SUBSCRIBED_FRM_PARTY(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE AHL_DI_APPROVED_BY_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE AHL_DI_RECEIVED_BY_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);
/*
PROCEDURE AHL_RM_OPER_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);

PROCEDURE AHL_RM_OPER_H_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);
*/
PROCEDURE AHL_RM_ROUTE_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);
/*
PROCEDURE AHL_RM_ROUTE_H_OPERATOR_PARTY (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);
*/
PROCEDURE AHL_OSP_CUSTOMER (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2);
END  AHL_PARTY_MERGE_PKG;

 

/
