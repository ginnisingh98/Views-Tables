--------------------------------------------------------
--  DDL for Package POS_BANK_PAYEE_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_BANK_PAYEE_BO_PKG" AUTHID CURRENT_USER AS
    /* $Header: POSSPBAPS.pls 120.0.12010000.2 2010/02/08 14:11:29 ntungare noship $ */

      PROCEDURE get_pos_bank_payee_bo_tbl(p_api_version           IN NUMBER DEFAULT NULL,
                                        p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                        p_party_id              IN NUMBER,
                                        p_orig_system           IN VARCHAR2,
                                        p_orig_system_reference VARCHAR2,
                                        x_pos_bank_payee_bo_tbl OUT NOCOPY pos_bank_payee_bo_tbl,
                                        x_return_status         OUT NOCOPY VARCHAR2,
                                        x_msg_count             OUT NOCOPY NUMBER,
                                        x_msg_data              OUT NOCOPY VARCHAR2);

    PROCEDURE create_pos_bank_payee_bo_tbl(p_api_version           IN NUMBER,
                                           p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                           p_pos_bank_payee_bo_tbl IN pos_bank_payee_bo_tbl,
                                           p_party_id              IN NUMBER,
                                           p_orig_system           IN VARCHAR2,
                                           p_orig_system_reference IN VARCHAR2,
                                           p_create_update_flag    IN VARCHAR2,
                                           x_return_status         OUT NOCOPY VARCHAR2,
                                           x_msg_count             OUT NOCOPY NUMBER,
                                           x_msg_data              OUT NOCOPY VARCHAR2);

   /* PROCEDURE update_pos_bank_payee_bo_tbl(p_api_version          IN NUMBER,
                                           p_init_msg_list        IN VARCHAR2 DEFAULT fnd_api.g_false,
                                           p_ext_payee_tab        IN iby_disbursement_setup_pub.external_payee_tab_type,
                                           p_ext_payee_id_tab     IN iby_disbursement_setup_pub.ext_payee_id_tab_type,
                                           x_return_status        OUT NOCOPY VARCHAR2,
                                           x_msg_count            OUT NOCOPY NUMBER,
                                           x_msg_data             OUT NOCOPY VARCHAR2,
                                           x_ext_payee_status_tab OUT NOCOPY iby_disbursement_setup_pub.ext_payee_create_tab_type);*/

END pos_bank_payee_bo_pkg;

/
