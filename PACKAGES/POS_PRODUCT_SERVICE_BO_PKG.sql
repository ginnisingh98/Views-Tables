--------------------------------------------------------
--  DDL for Package POS_PRODUCT_SERVICE_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PRODUCT_SERVICE_BO_PKG" AUTHID CURRENT_USER AS
  /* $Header: POSSPPRSS.pls 120.0.12010000.2 2010/02/08 14:19:34 ntungare noship $ */
  PROCEDURE create_pos_product_service
  (
    p_api_version           IN NUMBER DEFAULT NULL,
    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
    p_vendor_prodsrv_rec    IN pos_product_service_bo_tbl,
    p_request_status        IN VARCHAR2,
    p_party_id              IN NUMBER,
    p_orig_system           IN VARCHAR2,
    p_orig_system_reference IN VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  );
  PROCEDURE get_pos_product_service_bo_tbl
  (
    p_api_version                IN NUMBER DEFAULT NULL,
    p_init_msg_list              IN VARCHAR2 DEFAULT NULL,
    p_party_id                   IN NUMBER,
    p_orig_system                IN VARCHAR2,
    p_orig_system_reference      IN VARCHAR2,
    x_pos_product_service_bo_tbl OUT NOCOPY pos_product_service_bo_tbl,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

END pos_product_service_bo_pkg;

/
