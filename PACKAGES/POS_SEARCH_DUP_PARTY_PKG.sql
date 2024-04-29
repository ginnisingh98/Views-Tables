--------------------------------------------------------
--  DDL for Package POS_SEARCH_DUP_PARTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SEARCH_DUP_PARTY_PKG" AUTHID CURRENT_USER AS
/* $Header: POSDQMS.pls 120.0.12010000.7 2009/12/04 19:03:25 jburugul noship $ */

PROCEDURE find_duplicate_parties
       (p_init_msg_list  IN VARCHAR2  := fnd_api.g_true,
        p_supp_name      IN VARCHAR2,
        p_supp_name_alt  IN VARCHAR2,
        p_tax_payer_id   IN VARCHAR2,
        p_tax_reg_no     IN VARCHAR2,
        p_duns_no        IN VARCHAR2,
        p_sic_code       IN VARCHAR2,
        p_sup_reg_id     IN VARCHAR2,
        x_search_ctx_id  OUT NOCOPY NUMBER,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2);


PROCEDURE pos_create_organization(
    p_supp_name         IN     VARCHAR2,
    p_supp_name_alt     IN     VARCHAR2,
    p_tax_payer_id      IN     VARCHAR2,
    p_tax_reg_no        IN     VARCHAR2,
    p_duns_number       IN     VARCHAR2,
    p_sic_code          IN     VARCHAR2,
    p_url               IN     VARCHAR2,
    p_org_name_phonetic IN     VARCHAR2,
    x_return_status     OUT    NOCOPY VARCHAR2,
    x_msg_count         OUT    NOCOPY NUMBER,
    x_msg_data          OUT    NOCOPY VARCHAR2,
    x_org_party_id      OUT    NOCOPY NUMBER,
    x_org_party_number  OUT    NOCOPY VARCHAR2,
    x_org_profile_id    OUT    NOCOPY NUMBER
);

PROCEDURE update_supp_party_id(
	p_supp_reg_id       IN NUMBER,
	p_party_id          IN NUMBER,
	x_return_status     OUT NOCOPY VARCHAR2
);

PROCEDURE pos_update_organization(
    p_supp_name			IN     VARCHAR2,
    p_supp_name_alt		IN     VARCHAR2,
    p_tax_payer_id		IN     VARCHAR2,
    p_tax_reg_no		IN     VARCHAR2,
    p_duns_number		IN     VARCHAR2,
    p_sic_code			IN     VARCHAR2,
    p_party_id			IN     NUMBER,
--    p_party_obj_version   	IN     NUMBER,
    x_profile_id		OUT    NOCOPY NUMBER,
    x_return_status		OUT    NOCOPY VARCHAR2,
    x_msg_count			OUT    NOCOPY NUMBER,
    x_msg_data			OUT    NOCOPY VARCHAR2
);


PROCEDURE search_duplicate_parties(
    p_init_msg_list IN VARCHAR2 := fnd_api.g_true,
    p_party_name    IN VARCHAR2,
    p_party_number  IN VARCHAR2,
    p_status        IN VARCHAR2,
    p_sic_code      IN VARCHAR2,
    p_address       IN VARCHAR2,
    p_city          IN VARCHAR2,
    p_state         IN VARCHAR2,
    p_country       IN VARCHAR2,
    x_search_ctx_id OUT NOCOPY NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
);


PROCEDURE enable_party_as_supplier(p_party_id       IN NUMBER,
                                   p_vendor_num     IN VARCHAR2,
                                   x_vendor_id      OUT NOCOPY NUMBER,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2);


PROCEDURE  assign_party_usage( p_contact_party_id  IN NUMBER,
                               x_return_status     OUT nocopy VARCHAR2,
                               x_msg_count    	   OUT nocopy NUMBER,
                               x_msg_data      	   OUT nocopy VARCHAR2
                              );

END POS_SEARCH_DUP_PARTY_PKG;

/
