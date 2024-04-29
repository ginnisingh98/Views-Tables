--------------------------------------------------------
--  DDL for Package POS_AP_SUPPLIER_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_AP_SUPPLIER_BO_PKG" AUTHID CURRENT_USER AS
  /* $Header: POSAPSPS.pls 120.0.12010000.2 2010/02/08 14:08:15 ntungare noship $ */
  PROCEDURE create_pos_ap_supplier
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_pos_ap_supplier_bo    IN pos_ap_supplier_bo,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    p_create_update_flag    IN VARCHAR2,
    x_vendor_id             OUT NOCOPY NUMBER,
    x_party_id              OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );
  /* PROCEDURE update_pos_ap_supplier(p_api_version           IN NUMBER DEFAULT NULL,
  p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
  p_pos_ap_supplier_bo    IN pos_ap_supplier_bo,
  p_pos_external_payee_bo IN pos_external_payee_bo,
  p_orig_system           IN VARCHAR2,
  p_orig_system_reference IN VARCHAR2,
  p_vendor_id             OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2)*/
  PROCEDURE get_ap_supplier_bo
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_ap_suplier_bo         OUT NOCOPY pos_ap_supplier_bo,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );

  PROCEDURE is_customer
  (
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
  );

END pos_ap_supplier_bo_pkg;

/
