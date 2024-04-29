--------------------------------------------------------
--  DDL for Package HZ_BATCH_DUPLICATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BATCH_DUPLICATE" AUTHID CURRENT_USER AS
/* $Header: ARHBDUPS.pls 115.6 2003/05/25 20:13:41 rrangan noship $ */

PROCEDURE find_dup_parties (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_rule_id               IN      VARCHAR2,
        p_num_workers           IN      VARCHAR2,
        p_batch_name            IN      VARCHAR2,
        p_subset_defn           IN      VARCHAR2,
        p_match_within_subset   IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2
);

PROCEDURE find_dup_parties_worker (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_num_workers           IN      VARCHAR2,
        p_worker_number         IN      VARCHAR2,
        p_rule_id               IN      VARCHAR2,
        p_batch_id              IN      VARCHAR2,
        p_subset_defn           IN      VARCHAR2,
        p_match_within_subset   IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2
);

PROCEDURE get_dup_match_details (
        p_init_msg_list IN     VARCHAR2 := FND_API.G_FALSE,
        p_rule_id       IN      NUMBER,
        p_dup_set_id    IN      NUMBER,
        x_return_status OUT NOCOPY    VARCHAR2,
        x_msg_count     OUT NOCOPY    NUMBER,
        x_msg_data      OUT NOCOPY    VARCHAR2
);


PROCEDURE find_party_dups (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,
        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,
        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,
        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list,
        x_search_ctx_id         OUT NOCOPY NUMBER,
        x_num_matches           OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE find_party_dups (
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_party_site_ids        IN      HZ_PARTY_SEARCH.IDList,
        p_contact_ids           IN      HZ_PARTY_SEARCH.IDList,
        p_contact_pt_ids        IN      HZ_PARTY_SEARCH.IDList,
        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,
        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,
        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,
        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list,
        x_search_ctx_id         OUT NOCOPY    NUMBER,
        x_num_matches           OUT NOCOPY    NUMBER,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
);

END;

 

/
