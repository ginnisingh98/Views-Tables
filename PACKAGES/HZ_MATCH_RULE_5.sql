--------------------------------------------------------
--  DDL for Package HZ_MATCH_RULE_5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MATCH_RULE_5" AUTHID CURRENT_USER AS
PROCEDURE map_party_rec (
        p_search_ctx IN BOOLEAN,
        p_search_rec IN HZ_PARTY_SEARCH.party_search_rec_type,
        x_entered_max_score OUT NUMBER,
        x_stage_rec IN OUT NOCOPY HZ_PARTY_STAGE.party_stage_rec_type
);
PROCEDURE map_party_site_rec (
      p_search_ctx IN BOOLEAN,
      p_search_list IN HZ_PARTY_SEARCH.party_site_list, 
      x_entered_max_score OUT NUMBER,
      x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.party_site_stage_list
);
PROCEDURE map_contact_rec (
      p_search_ctx IN BOOLEAN,
      p_search_list IN HZ_PARTY_SEARCH.contact_list,
      x_entered_max_score OUT NUMBER,
      x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_stage_list
  );
PROCEDURE map_contact_point_rec (
      p_search_ctx IN BOOLEAN,
      p_search_list IN HZ_PARTY_SEARCH.contact_point_list,
      x_entered_max_score OUT NUMBER,
      x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_pt_stage_list
  );
PROCEDURE get_party_rec (
        p_party_id              IN      NUMBER,
        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type
);
PROCEDURE get_party_site_rec (
        p_party_site_ids        IN      HZ_PARTY_SEARCH.IDList,
        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list
);
PROCEDURE get_contact_rec (
        p_contact_ids           IN      HZ_PARTY_SEARCH.IDList,
        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list
);
PROCEDURE get_contact_point_rec (
        p_contact_point_ids     IN  HZ_PARTY_SEARCH.IDList,
        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list
);
FUNCTION check_prim_cond(
      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,
      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,
      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,
      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list)
   RETURN BOOLEAN;
PROCEDURE check_party_site_cond(
      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,
      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,
      x_secondary             OUT     BOOLEAN,
      x_primary               OUT     BOOLEAN
);
PROCEDURE check_contact_cond(
      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,
      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,
      x_secondary             OUT     BOOLEAN,
      x_primary               OUT     BOOLEAN
);
PROCEDURE check_contact_point_cond(
      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,
      x_secondary             OUT     BOOLEAN,
      x_primary               OUT     BOOLEAN
);
PROCEDURE find_parties (
      p_rule_id               IN      NUMBER,
      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,
      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,
      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,
      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type		   IN      VARCHAR2,
      p_search_merged         IN      VARCHAR2,
      p_dup_party_id          IN      NUMBER,
      p_dup_set_id            IN      NUMBER,
      p_dup_batch_id          IN      NUMBER,
      p_ins_details           IN      VARCHAR2,
      x_search_ctx_id         OUT     NUMBER,
      x_num_matches           OUT     NUMBER
);
PROCEDURE find_persons (
      p_rule_id               IN      NUMBER,
      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,
      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,
      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,
      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type            IN      VARCHAR2,
      p_search_merged         IN      VARCHAR2,
      p_ins_details           IN      VARCHAR2,
      x_search_ctx_id         OUT     NUMBER,
      x_num_matches           OUT     NUMBER
);
PROCEDURE find_party_details (
      p_rule_id               IN      NUMBER,
      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,
      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,
      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,
      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type		   IN      VARCHAR2,
      p_search_merged         IN      VARCHAR2,
      x_search_ctx_id         OUT     NUMBER,
      x_num_matches           OUT     NUMBER
);
PROCEDURE find_duplicate_party_sites(
      p_rule_id               IN      NUMBER,
	   p_party_site_id	   IN	   NUMBER,
	   p_party_id		   IN	   NUMBER,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type            IN      VARCHAR2,
      x_search_ctx_id         OUT     NUMBER,
      x_num_matches           OUT     NUMBER
);
PROCEDURE find_duplicate_contacts(
      p_rule_id               IN      NUMBER,
	   p_org_contact_id	   IN	   NUMBER,
	   p_party_id		   IN	   NUMBER,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type            IN      VARCHAR2,
      x_search_ctx_id         OUT     NUMBER,
      x_num_matches           OUT     NUMBER
);
PROCEDURE find_duplicate_contact_points(
      p_rule_id               IN      NUMBER,
	   p_contact_point_id	   IN	   NUMBER,
	   p_party_id		   IN	   NUMBER,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type            IN      VARCHAR2,
      x_search_ctx_id         OUT     NUMBER,
      x_num_matches           OUT     NUMBER
);
PROCEDURE find_duplicate_parties (
      p_rule_id               IN      NUMBER,
	   p_party_id		   IN	   NUMBER,
      p_restrict_sql          IN      VARCHAR2,
      p_match_type            IN      VARCHAR2,
	   p_dup_batch_id	   IN	   NUMBER,
      p_search_merged         IN      VARCHAR2,
      x_dup_set_id            OUT     NUMBER,
      x_search_ctx_id         OUT     NUMBER,
      x_num_matches           OUT     NUMBER
);
PROCEDURE get_matching_party_sites (
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_party_site_list       IN      HZ_PARTY_SEARCH.PARTY_SITE_LIST,
        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type	     IN      VARCHAR2,
        p_dup_party_site_id     IN      NUMBER, 
        x_search_ctx_id         OUT     NUMBER,
        x_num_matches           OUT     NUMBER
);
PROCEDURE get_matching_contacts (
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_contact_list   	     IN      HZ_PARTY_SEARCH.CONTACT_LIST,
        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type	     IN      VARCHAR2,
        p_dup_contact_id        IN      NUMBER, 
        x_search_ctx_id         OUT     NUMBER,
        x_num_matches           OUT     NUMBER
);

PROCEDURE get_matching_contact_points (
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type	     IN      VARCHAR2,
        p_dup_contact_point_id  IN      NUMBER, 
        x_search_ctx_id         OUT     NUMBER,
        x_num_matches           OUT     NUMBER
);
PROCEDURE get_score_details (
        p_rule_id               IN      NUMBER,
        p_party_id              IN      NUMBER,
        p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,
        p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,
        p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,
        p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,
        x_search_ctx_id         IN OUT  NUMBER
);
PROCEDURE find_parties_dynamic (
        p_rule_id               IN      NUMBER,
        p_attrib_id1            IN      NUMBER,
        p_attrib_id2            IN      NUMBER,
        p_attrib_id3            IN      NUMBER,
        p_attrib_id4            IN      NUMBER,
        p_attrib_id5            IN      NUMBER,
        p_attrib_id6            IN      NUMBER,
        p_attrib_id7            IN      NUMBER,
        p_attrib_id8            IN      NUMBER,
        p_attrib_id9            IN      NUMBER,
        p_attrib_id10           IN      NUMBER,
        p_attrib_id11           IN      NUMBER,
        p_attrib_id12           IN      NUMBER,
        p_attrib_id13           IN      NUMBER,
        p_attrib_id14           IN      NUMBER,
        p_attrib_id15           IN      NUMBER,
        p_attrib_id16           IN      NUMBER,
        p_attrib_id17           IN      NUMBER,
        p_attrib_id18           IN      NUMBER,
        p_attrib_id19           IN      NUMBER,
        p_attrib_id20           IN      NUMBER,
        p_attrib_val1           IN      VARCHAR2,
        p_attrib_val2           IN      VARCHAR2,
        p_attrib_val3           IN      VARCHAR2,
        p_attrib_val4           IN      VARCHAR2,
        p_attrib_val5           IN      VARCHAR2,
        p_attrib_val6           IN      VARCHAR2,
        p_attrib_val7           IN      VARCHAR2,
        p_attrib_val8           IN      VARCHAR2,
        p_attrib_val9           IN      VARCHAR2,
        p_attrib_val10          IN      VARCHAR2,
        p_attrib_val11          IN      VARCHAR2,
        p_attrib_val12          IN      VARCHAR2,
        p_attrib_val13          IN      VARCHAR2,
        p_attrib_val14          IN      VARCHAR2,
        p_attrib_val15          IN      VARCHAR2,
        p_attrib_val16          IN      VARCHAR2,
        p_attrib_val17          IN      VARCHAR2,
        p_attrib_val18          IN      VARCHAR2,
        p_attrib_val19          IN      VARCHAR2,
        p_attrib_val20          IN      VARCHAR2,
        p_restrict_sql          IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        p_search_merged         IN      VARCHAR2,
        x_search_ctx_id         OUT     NUMBER,
        x_num_matches           OUT     NUMBER
);
PROCEDURE call_api_dynamic (
        p_rule_id               IN      NUMBER,
        p_attrib_id1            IN      NUMBER,
        p_attrib_id2            IN      NUMBER,
        p_attrib_id3            IN      NUMBER,
        p_attrib_id4            IN      NUMBER,
        p_attrib_id5            IN      NUMBER,
        p_attrib_id6            IN      NUMBER,
        p_attrib_id7            IN      NUMBER,
        p_attrib_id8            IN      NUMBER,
        p_attrib_id9            IN      NUMBER,
        p_attrib_id10           IN      NUMBER,
        p_attrib_id11           IN      NUMBER,
        p_attrib_id12           IN      NUMBER,
        p_attrib_id13           IN      NUMBER,
        p_attrib_id14           IN      NUMBER,
        p_attrib_id15           IN      NUMBER,
        p_attrib_id16           IN      NUMBER,
        p_attrib_id17           IN      NUMBER,
        p_attrib_id18           IN      NUMBER,
        p_attrib_id19           IN      NUMBER,
        p_attrib_id20           IN      NUMBER,
        p_attrib_val1           IN      VARCHAR2,
        p_attrib_val2           IN      VARCHAR2,
        p_attrib_val3           IN      VARCHAR2,
        p_attrib_val4           IN      VARCHAR2,
        p_attrib_val5           IN      VARCHAR2,
        p_attrib_val6           IN      VARCHAR2,
        p_attrib_val7           IN      VARCHAR2,
        p_attrib_val8           IN      VARCHAR2,
        p_attrib_val9           IN      VARCHAR2,
        p_attrib_val10          IN      VARCHAR2,
        p_attrib_val11          IN      VARCHAR2,
        p_attrib_val12          IN      VARCHAR2,
        p_attrib_val13          IN      VARCHAR2,
        p_attrib_val14          IN      VARCHAR2,
        p_attrib_val15          IN      VARCHAR2,
        p_attrib_val16          IN      VARCHAR2,
        p_attrib_val17          IN      VARCHAR2,
        p_attrib_val18          IN      VARCHAR2,
        p_attrib_val19          IN      VARCHAR2,
        p_attrib_val20          IN      VARCHAR2,
        p_restrict_sql          IN      VARCHAR2,
        p_api_name              IN      VARCHAR2,
        p_match_type            IN      VARCHAR2,
        p_party_id              IN      NUMBER,
        p_search_merged         IN      VARCHAR2,
        x_search_ctx_id         OUT     NUMBER,
        x_num_matches           OUT     NUMBER
);
PROCEDURE get_party_for_search (
        p_party_id              IN      NUMBER,
        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,
        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,
        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,
        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list
);
PROCEDURE get_search_criteria (
        p_party_id              IN      NUMBER,
        p_party_site_ids        IN      HZ_PARTY_SEARCH.IDList,
        p_contact_ids           IN      HZ_PARTY_SEARCH.IDList,
        p_contact_pt_ids        IN      HZ_PARTY_SEARCH.IDList,
        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,
        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,
        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,
        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list
);
FUNCTION check_staged RETURN BOOLEAN;

-- Fix for Bug 4736139
FUNCTION check_staged_var RETURN VARCHAR2;

  g_staged NUMBER := -1;
END HZ_MATCH_RULE_5;

/
