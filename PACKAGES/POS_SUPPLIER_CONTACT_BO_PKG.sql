--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_CONTACT_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_CONTACT_BO_PKG" AUTHID CURRENT_USER AS
  /* $Header: POSSPCONS.pls 120.0.12010000.2 2010/02/08 14:13:43 ntungare noship $ */

  PROCEDURE get_pos_supp_contact_bo_tbl
  (
    p_api_version            IN NUMBER DEFAULT NULL,
    p_init_msg_list          IN VARCHAR2 DEFAULT NULL,
    p_party_id               IN NUMBER,
    p_orig_system            IN VARCHAR2,
    p_orig_system_reference  IN VARCHAR2,
    x_ap_supplier_contact_bo OUT NOCOPY pos_supplier_contact_bo_tbl,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2
  );

  PROCEDURE create_pos_supp_contact_bo
  (
    p_api_version                 IN NUMBER DEFAULT NULL,
    p_init_msg_list               IN VARCHAR2 DEFAULT NULL,
    p_pos_supplier_contact_bo_tbl IN pos_supplier_contact_bo_tbl,
    p_party_id                    IN NUMBER,
    p_orig_system                 IN VARCHAR2,
    p_orig_system_reference       IN VARCHAR2,
    p_create_update_flag          IN VARCHAR2,
    x_vendor_contact_id           OUT NOCOPY NUMBER,
    x_per_party_id                OUT NOCOPY NUMBER,
    x_rel_party_id                OUT NOCOPY NUMBER,
    x_rel_id                      OUT NOCOPY NUMBER,
    x_org_contact_id              OUT NOCOPY NUMBER,
    x_party_site_id               OUT NOCOPY NUMBER,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2
  );

END pos_supplier_contact_bo_pkg;

/
