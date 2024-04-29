--------------------------------------------------------
--  DDL for Package HZ_MAP_PARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MAP_PARTY_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHMAPSS.pls 120.5 2005/06/24 13:18:08 dmmehta ship $*/

TYPE fin_num_table IS TABLE OF hz_financial_numbers%ROWTYPE
INDEX BY BINARY_INTEGER;

procedure map(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_FALSE,
	p_group_id              IN      NUMBER := NULL,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        p_inactivate_flag       IN      VARCHAR2 := 'Y',
        p_validation_level      IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL

);

procedure map_conc_wrapper(
        errbuf                  OUT     NOCOPY VARCHAR2,
        retcode                 OUT     NOCOPY VARCHAR2,
        p_group_id              IN      VARCHAR2 := NULL
);

procedure store_org(
        p_organization_rec              IN OUT  NOCOPY HZ_PARTY_V2PUB.organization_rec_type,
        x_organization_profile_id       OUT     NOCOPY NUMBER,
        x_return_status                 IN OUT  NOCOPY VARCHAR2
);

procedure store_party_site(
        p_party_site_rec        IN OUT  NOCOPY hz_party_site_v2pub.party_site_rec_type,
        x_return_status         IN OUT  NOCOPY VARCHAR2
);

procedure store_contact_point(
        p_contact_points_rec    IN OUT  NOCOPY hz_contact_point_v2pub.contact_point_rec_type,
        p_phone_rec             IN OUT  NOCOPY hz_contact_point_v2pub.phone_rec_type,
        x_return_status         IN OUT  NOCOPY VARCHAR2
);

procedure store_credit_ratings(
        --p_credit_ratings_rec    IN OUT  NOCOPY hz_party_info_pub.credit_ratings_rec_type,
        p_credit_ratings_rec    IN OUT  NOCOPY HZ_PARTY_INFO_V2PUB.credit_rating_rec_type,
        x_return_status         IN OUT  NOCOPY VARCHAR2
);

procedure do_store_financial_report(
        --p_fin_rep_rec           IN OUT  NOCOPY hz_org_info_pub.financial_reports_rec_type,
        p_fin_rep_rec           IN OUT  NOCOPY HZ_ORGANIZATION_INFO_V2PUB.financial_report_rec_type,
       	x_new_fin_report        OUT     NOCOPY VARCHAR2,
	x_return_status         IN OUT  NOCOPY VARCHAR2
);

procedure do_store_financial_number(
        --p_fin_num_rec           IN OUT NOCOPY hz_org_info_pub.financial_numbers_rec_type       ,
        p_fin_num_rec           IN OUT NOCOPY HZ_ORGANIZATION_INFO_V2PUB.financial_number_rec_type       ,
        p_new_fin_report        IN      VARCHAR2,
        p_fin_num_tab           IN      fin_num_table,
        x_return_status         IN OUT  NOCOPY VARCHAR2
);

procedure store_party_rel(
        p_party_rel_rec         IN OUT     NOCOPY hz_relationship_v2pub.relationship_rec_type,
        x_return_status         IN OUT     NOCOPY VARCHAR2
);

procedure store_business_report(
        p_organization_profile_id       NUMBER,
        p_business_report               CLOB
);

-- Bug 3417357 : Added parameter p_create_new
procedure do_store_location(
        p_location_rec          IN OUT  NOCOPY hz_location_v2pub.location_rec_type,
        p_party_id              IN      NUMBER,
        p_old_party_site_id     IN      NUMBER,
	p_create_new		IN	BOOLEAN,
        x_return_status         IN OUT  NOCOPY VARCHAR2
);

procedure store_classification(
        p_code_assignment_rec   IN OUT  NOCOPY hz_classification_v2pub.code_assignment_rec_type,
        x_return_status         IN OUT  NOCOPY VARCHAR2
);



END HZ_MAP_PARTY_PUB;

 

/
