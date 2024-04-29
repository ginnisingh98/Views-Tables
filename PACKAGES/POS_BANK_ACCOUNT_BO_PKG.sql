--------------------------------------------------------
--  DDL for Package POS_BANK_ACCOUNT_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_BANK_ACCOUNT_BO_PKG" AUTHID CURRENT_USER AS
    /* $Header: POSSPBAAS.pls 120.0.12010000.2 2010/02/08 14:10:25 ntungare noship $ */

     PROCEDURE get_pos_bank_account_bo_tbl(p_api_version             IN NUMBER DEFAULT NULL,
                                          p_init_msg_list           IN VARCHAR2 DEFAULT NULL,
                                          p_party_id                IN NUMBER,
                                          p_orig_system             IN VARCHAR2,
                                          p_orig_system_reference   IN VARCHAR2,
                                          x_pos_bank_account_bo_tbl OUT NOCOPY pos_bank_account_bo_tbl,
                                          x_return_status           OUT NOCOPY VARCHAR2,
                                          x_msg_count               OUT NOCOPY NUMBER,
                                          x_msg_data                OUT NOCOPY VARCHAR2);
    PROCEDURE create_pos_bank_account_bo(p_api_version   IN NUMBER,
                                         p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                         p_party_id              IN NUMBER,
                                         p_orig_system           IN VARCHAR2,
                                         p_orig_system_reference IN VARCHAR2,
                                         p_create_update_flag    IN VARCHAR2,
                                         p_pos_bank_account_bo   IN pos_bank_account_bo_tbl,
                                         x_acct_id               OUT NOCOPY NUMBER,
                                         x_return_status         OUT NOCOPY VARCHAR2,
                                         x_msg_count             OUT NOCOPY NUMBER,
                                         x_msg_data              OUT NOCOPY VARCHAR2); /*
    PROCEDURE update_pos_bank_account_bo_tbl(p_api_version       IN NUMBER,
                                             p_init_msg_list     IN VARCHAR2 DEFAULT fnd_api.g_false,
                                             p_ext_bank_acct_rec IN iby_ext_bankacct_pub.extbankacct_rec_type,
                                             x_acct_id           OUT NOCOPY NUMBER,
                                             x_response          OUT NOCOPY iby_fndcpt_common_pub.result_rec_type,
                                             x_return_status     OUT NOCOPY VARCHAR2,
                                             x_msg_count         OUT NOCOPY NUMBER,
                                             x_msg_data          OUT NOCOPY VARCHAR2);*/

END pos_bank_account_bo_pkg;

/
