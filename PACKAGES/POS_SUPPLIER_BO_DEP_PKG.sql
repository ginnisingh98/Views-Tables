--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_BO_DEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_BO_DEP_PKG" AUTHID CURRENT_USER AS
   /* $Header: POSSPFINS.pls 120.0.12010000.2 2010/02/08 14:14:46 ntungare noship $ */
    -- Author  : JAYASANKAR
    -- Created : 8/20/2009 9:41:11 AM

    -- Public type declarations
    PROCEDURE get_financial_report_bos(p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
                                       p_organization_id       IN NUMBER,
                                       p_action_type           IN VARCHAR2 := NULL,
                                       x_financial_report_objs OUT NOCOPY hz_financial_bo_tbl,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2);

    PROCEDURE get_organization_bo(p_init_msg_list    IN VARCHAR2 := fnd_api.g_false,
                                  p_organization_id  IN NUMBER,
                                  p_action_type      IN VARCHAR2 := NULL,
                                  x_organization_obj OUT NOCOPY hz_organization_bo,
                                  x_return_status    OUT NOCOPY VARCHAR2,
                                  x_msg_count        OUT NOCOPY NUMBER,
                                  x_msg_data         OUT NOCOPY VARCHAR2);

    FUNCTION get_party_id(p_orig_system           IN VARCHAR2,
                          p_orig_system_reference IN VARCHAR2) RETURN NUMBER;

END pos_supplier_bo_dep_pkg;

/
