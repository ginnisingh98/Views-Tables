--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_UDA_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_UDA_BO_PKG" AUTHID CURRENT_USER AS
     /* $Header: POSSPUDAS.pls 120.0.12010000.2 2010/02/09 05:57:58 ntungare noship $ */

    -- Public type declarations
    PROCEDURE get_uda_data(p_party_id         IN NUMBER,
                           p_party_site_id    IN NUMBER,
                           p_supplier_site_id IN NUMBER,
                           p_supp_data_level  IN VARCHAR2,
                           x_pos_supplier_uda OUT NOCOPY pos_supp_uda_obj_tbl,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2);
    FUNCTION get_uda_for_supplier_site(p_party_id         IN NUMBER,
                                       p_party_site_id    IN NUMBER,
                                       p_supplier_site_id IN NUMBER,
                                       p_supp_data_level  IN VARCHAR2)
        RETURN pos_supp_uda_obj_tbl;

    PROCEDURE process_uda(p_party_id           IN NUMBER,
                          p_supp_data_level    IN VARCHAR2,
                          p_pos_supplier_uda   IN pos_supp_uda_obj_tbl,
                          p_create_update_flag IN VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2);

END pos_supplier_uda_bo_pkg;

/
