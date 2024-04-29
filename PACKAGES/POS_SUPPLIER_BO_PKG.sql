--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_BO_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSPBOS.pls 120.0.12010000.3 2010/04/01 09:47:38 ntungare noship $ */

    -- Public type declarations
    PROCEDURE pos_get_supplier_bo(p_api_version           IN NUMBER DEFAULT NULL,
                                  p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                  p_party_id              IN NUMBER,
                                  p_orig_system           IN VARCHAR2,
                                  p_orig_system_reference IN VARCHAR2,
                                  x_pos_supplier_bo       OUT NOCOPY pos_supplier_bo,
                                  x_return_status         OUT NOCOPY VARCHAR2,
                                  x_msg_count             OUT NOCOPY NUMBER,
                                  x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE pos_create_update_supplier_bo(p_api_version           IN NUMBER DEFAULT NULL,
                                            p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                            p_party_id              IN NUMBER,
                                            p_orig_system           IN VARCHAR2,
                                            p_orig_system_reference IN VARCHAR2,
                                            p_create_update_flag    IN VARCHAR2,
                                            p_pos_supplier_bo       IN pos_supplier_bo,
                                            x_return_status         OUT NOCOPY VARCHAR2,
                                            x_msg_count             OUT NOCOPY NUMBER,
                                            x_msg_data              OUT NOCOPY VARCHAR2);

END pos_supplier_bo_pkg;

/
