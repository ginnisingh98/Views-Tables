--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCOUNT_MERGE_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCOUNT_MERGE_V2PVT" AUTHID CURRENT_USER AS
/*$Header: ARHACTMS.pls 120.1 2005/06/16 21:08:21 jhuang noship $ */


  --------------PARTY------------------------------------------------------

  g_miss_content_source_type               VARCHAR2(30) := 'USER_ENTERED';
  g_miss_party_rec                         hz_party_v2pub.party_rec_type;

  procedure get_party_rec (
    p_init_msg_list               IN      VARCHAR2 := fnd_api.g_false,
    p_party_id                    IN      NUMBER,
    x_party_rec                   OUT     NOCOPY hz_party_v2pub.party_rec_type,
    x_return_status               OUT     NOCOPY VARCHAR2,
    x_msg_count                   OUT     NOCOPY NUMBER,
    x_msg_data                    OUT     NOCOPY VARCHAR2
  );

  --------------relationship------------------------------------------------

  g_miss_rel_rec                              hz_relationship_v2pub.relationship_rec_type;

  PROCEDURE create_relationship (
    p_init_msg_list        IN   VARCHAR2:= fnd_api.g_false,
    p_relationship_rec     IN   hz_relationship_v2pub.relationship_rec_type,
    p_direction_code       IN   VARCHAR2,
    x_relationship_id      OUT  NOCOPY NUMBER,
    x_party_id             OUT  NOCOPY NUMBER,
    x_party_number         OUT  NOCOPY VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2,
    x_msg_count            OUT  NOCOPY NUMBER,
    x_msg_data             OUT  NOCOPY VARCHAR2
  );


  PROCEDURE get_relationship_rec (
    p_init_msg_list    IN   VARCHAR2 := fnd_api.g_false,
    p_relationship_id  IN   NUMBER,
    p_directional_flag IN   VARCHAR2 := 'F',
    x_rel_rec          OUT  NOCOPY hz_relationship_v2pub.relationship_rec_type,
    x_direction_code   OUT  NOCOPY VARCHAR2,
    x_return_status    OUT  NOCOPY VARCHAR2,
    x_msg_count        OUT  NOCOPY NUMBER,
    x_msg_data         OUT  NOCOPY VARCHAR2
  );

  --------------------PARTY_CONTACT--------------------------------------------
  PROCEDURE create_org_contact (
    p_init_msg_list   IN    VARCHAR2 := fnd_api.g_false,
    p_org_contact_rec IN    hz_party_contact_v2pub.org_contact_rec_type,
    p_direction_code  IN    VARCHAR2,
    x_org_contact_id  OUT   NOCOPY NUMBER,
    x_party_rel_id    OUT   NOCOPY NUMBER,
    x_party_id        OUT   NOCOPY NUMBER,
    x_party_number    OUT   NOCOPY VARCHAR2,
    x_return_status   OUT   NOCOPY VARCHAR2,
    x_msg_count       OUT   NOCOPY NUMBER,
    x_msg_data        OUT   NOCOPY VARCHAR2);



  PROCEDURE get_org_contact_rec (
    p_init_msg_list   IN  VARCHAR2 := fnd_api.g_false,
    p_org_contact_id  IN  NUMBER,
    x_org_contact_rec OUT NOCOPY hz_party_contact_v2pub.org_contact_rec_type,
    x_direction_code  OUT NOCOPY VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
  );

  --------------------PARTY_SITE-----------------------------------------------
  PROCEDURE create_party_site (
    p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false,
    p_party_site_rec     IN     hz_party_site_v2pub.party_site_rec_type,
    p_actual_cont_source IN     VARCHAR2,
    x_party_site_id      OUT    NOCOPY NUMBER,
    x_party_site_number  OUT    NOCOPY VARCHAR2,
    x_return_status      OUT    NOCOPY VARCHAR2,
    x_msg_count          OUT    NOCOPY NUMBER,
    x_msg_data           OUT    NOCOPY VARCHAR2
  );

  PROCEDURE get_party_site_rec (
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_false,
    p_party_site_id       IN     NUMBER,
    x_party_site_rec      OUT    NOCOPY hz_party_site_v2pub.party_site_rec_type,
    x_actual_cont_source  OUT    NOCOPY VARCHAR2,
    x_return_status       OUT    NOCOPY VARCHAR2,
    x_msg_count           OUT    NOCOPY NUMBER,
    x_msg_data            OUT    NOCOPY VARCHAR2
  );

  ------------------account_site-----------------------------------------------

  PROCEDURE create_cust_acct_site (
    p_init_msg_list      IN  VARCHAR2 := fnd_api.g_false,
    p_cust_acct_site_rec IN  hz_cust_account_site_v2pub.cust_acct_site_rec_type,
    p_org_id             IN     NUMBER DEFAULT null,
    x_cust_acct_site_id  OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  );

  PROCEDURE create_cust_site_use (
    p_init_msg_list      IN  VARCHAR2 := fnd_api.g_false,
    p_cust_site_use_rec  IN  hz_cust_account_site_v2pub.cust_site_use_rec_type,
    p_customer_profile_rec IN  hz_customer_profile_v2pub.customer_profile_rec_type,
    p_create_profile     IN     VARCHAR2 := fnd_api.g_true,
    p_create_profile_amt IN     VARCHAR2 := fnd_api.g_true,
    p_org_id             IN     NUMBER DEFAULT null,
    x_site_use_id        OUT    NOCOPY NUMBER,
    x_return_status      OUT    NOCOPY VARCHAR2,
    x_msg_count          OUT    NOCOPY NUMBER,
    x_msg_data           OUT    NOCOPY VARCHAR2
  );
  ----------------CUST_PROFILE-------------------------------------------------
  PROCEDURE create_customer_profile (
    p_init_msg_list        IN     VARCHAR2 := fnd_api.g_false,
    p_customer_profile_rec IN     hz_customer_profile_v2pub.customer_profile_rec_type,
    p_create_profile_amt   IN     VARCHAR2 := fnd_api.g_true,
    x_cust_account_profile_id  OUT    NOCOPY NUMBER,
    x_return_status            OUT    NOCOPY VARCHAR2,
    x_msg_count                OUT    NOCOPY NUMBER,
    x_msg_data                 OUT    NOCOPY VARCHAR2
  );


  PROCEDURE create_cust_profile_amt (
    p_init_msg_list               IN     VARCHAR2 := fnd_api.g_false,
    p_check_foreign_key           IN     VARCHAR2 := fnd_api.g_true,
    p_cust_profile_amt_rec        IN     hz_customer_profile_v2pub.cust_profile_amt_rec_type,
    x_cust_acct_profile_amt_id    OUT    NOCOPY NUMBER,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
  );

  ------------------------CONTACT_POINTS------------------------

  g_miss_edi_rec                        hz_contact_point_v2pub.edi_rec_type;
  g_miss_eft_rec                        hz_contact_point_v2pub.eft_rec_type;
  g_miss_email_rec                      hz_contact_point_v2pub.email_rec_type;
  g_miss_phone_rec                      hz_contact_point_v2pub.phone_rec_type;
  g_miss_telex_rec                      hz_contact_point_v2pub.telex_rec_type;
  g_miss_web_rec                        hz_contact_point_v2pub.web_rec_type;

  PROCEDURE create_contact_point (
    p_init_msg_list     IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec           IN  hz_contact_point_v2pub.edi_rec_type := g_miss_edi_rec,
    p_eft_rec           IN  hz_contact_point_v2pub.eft_rec_type := g_miss_eft_rec,
    p_email_rec         IN  hz_contact_point_v2pub.email_rec_type := g_miss_email_rec,
    p_phone_rec         IN  hz_contact_point_v2pub.phone_rec_type := g_miss_phone_rec,
    p_telex_rec         IN  hz_contact_point_v2pub.telex_rec_type := g_miss_telex_rec,
    p_web_rec           IN  hz_contact_point_v2pub.web_rec_type := g_miss_web_rec,
    x_contact_point_id  OUT NOCOPY NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_contact_point_rec (
    p_init_msg_list     IN     VARCHAR2 := fnd_api.g_false,
    p_contact_point_id  IN     NUMBER,
    x_contact_point_rec OUT    NOCOPY hz_contact_point_v2pub.contact_point_rec_type,
    x_edi_rec           OUT    NOCOPY hz_contact_point_v2pub.edi_rec_type,
    x_eft_rec           OUT    NOCOPY hz_contact_point_v2pub.eft_rec_type,
    x_email_rec         OUT    NOCOPY hz_contact_point_v2pub.email_rec_type,
    x_phone_rec         OUT    NOCOPY hz_contact_point_v2pub.phone_rec_type,
    x_telex_rec         OUT    NOCOPY hz_contact_point_v2pub.telex_rec_type,
    x_web_rec           OUT    NOCOPY hz_contact_point_v2pub.web_rec_type,
    x_return_status     OUT    NOCOPY VARCHAR2,
    x_msg_count         OUT    NOCOPY NUMBER,
    x_msg_data          OUT    NOCOPY VARCHAR2
  );

----- Party Site Uses --------------------

PROCEDURE create_party_site_use (
    p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_rec    IN     HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE,
    x_party_site_use_id     OUT    NOCOPY NUMBER,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
);

PROCEDURE get_party_site_use_rec (
    p_init_msg_list                 IN          VARCHAR2 := FND_API.G_FALSE,
    p_party_site_use_id             IN          NUMBER,
    x_party_site_use_rec            OUT         NOCOPY HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE,
    x_return_status                 OUT         NOCOPY VARCHAR2,
    x_msg_count                     OUT         NOCOPY NUMBER,
    x_msg_data                      OUT         NOCOPY VARCHAR2
);

END hz_cust_account_merge_v2pvt;

 

/
