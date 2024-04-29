--------------------------------------------------------
--  DDL for Package POS_MERGE_SUPPLIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_MERGE_SUPPLIER_PKG" AUTHID CURRENT_USER AS
/* $Header: POSMRGSUPS.pls 120.0.12010000.1 2009/12/21 08:13:00 ntungare noship $ */

PROCEDURE buss_class_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE prod_service_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE bank_dtls_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE enable_party_as_supplier
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE party_contact_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE supplier_uda_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE party_site_uda_merge
  (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    x_to_id              IN OUT NOCOPY NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE supplier_site_uda_merge
  (
    p_from_id       IN NUMBER,
    p_from_fk_id    IN NUMBER,
    p_to_fk_id      IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2
  );

END pos_merge_supplier_pkg;

/
