--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_TAX_PROF_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_TAX_PROF_BO_PKG" AUTHID CURRENT_USER AS
    /* $Header: POSSPTXPS.pls 120.0.12010000.2 2010/02/08 14:23:32 ntungare noship $ */
    PROCEDURE create_supp_tax_profile(p_api_version             IN NUMBER DEFAULT NULL,
                                      p_init_msg_list           IN VARCHAR2 DEFAULT NULL,
                                      x_zx_party_tax_profile_bo_tbl IN pos_tax_profile_bo_tbl,
                                      p_party_id                IN NUMBER,
                                      p_orig_system             IN VARCHAR2,
                                      p_orig_system_reference   IN VARCHAR2,
                                      p_create_update_flag      IN VARCHAR2,
                                      x_return_status           OUT NOCOPY VARCHAR2,
                                      x_msg_count               OUT NOCOPY NUMBER,
                                      x_msg_data                OUT NOCOPY VARCHAR2,
                                      x_tax_profile_id          OUT NOCOPY NUMBER);

    PROCEDURE get_pos_sup_tax_prof_bo_tbl(p_api_version                 IN NUMBER DEFAULT NULL,
                                          p_init_msg_list               IN VARCHAR2 DEFAULT NULL,
                                          p_party_id                    IN NUMBER,
                                          p_orig_system                 IN VARCHAR2,
                                          p_orig_system_reference       IN VARCHAR2,
                                          x_zx_party_tax_profile_bo_tbl OUT NOCOPY pos_tax_profile_bo_tbl,
                                          x_return_status               OUT NOCOPY VARCHAR2,
                                          x_msg_count                   OUT NOCOPY NUMBER,
                                          x_msg_data                    OUT NOCOPY VARCHAR2);

END pos_supplier_tax_prof_bo_pkg;

/
