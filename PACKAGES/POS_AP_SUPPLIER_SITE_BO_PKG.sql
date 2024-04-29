--------------------------------------------------------
--  DDL for Package POS_AP_SUPPLIER_SITE_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_AP_SUPPLIER_SITE_BO_PKG" AUTHID CURRENT_USER AS
  /* $Header: POSSPSTS.pls 120.0.12010000.2 2010/02/08 14:22:21 ntungare noship $ */

  PROCEDURE get_pos_supplier_sites_bo_tbl
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_ap_supplier_sites_bo  OUT NOCOPY pos_supplier_sites_all_bo_tbl,
    --x_ap_supplier_sites_bo  OUT NOCOPY pos_supplier_sites_all_object,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  );

  PROCEDURE create_pos_supplier_site_bo
  (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 := fnd_api.g_false,
    p_pos_supp_sites_all_bo_tbl IN pos_supplier_sites_all_bo_tbl,
    p_party_id                  IN NUMBER,
    p_orig_system               IN VARCHAR2,
    p_orig_system_reference     IN VARCHAR2,
    p_create_update_flag        IN VARCHAR2,
    x_vendor_site_id            OUT NOCOPY NUMBER,
    x_party_site_id             OUT NOCOPY NUMBER,
    x_location_id               OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
  );
END pos_ap_supplier_site_bo_pkg;

/
