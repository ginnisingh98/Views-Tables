--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_INFO_PUB" AS
/*$Header: ARHPTISB.pls 120.9 2005/12/07 19:33:06 acng ship $ */

G_PKG_NAME CONSTANT                    VARCHAR2(30) := 'HZ_PARTY_INFO_PUB';

-- Bug 2197181: added for mix-n-match project.

g_cre_mixnmatch_enabled                VARCHAR2(1);
g_cre_selected_datasources             VARCHAR2(255);
g_cre_is_datasource_selected           VARCHAR2(1) := 'N';
g_cre_entity_attr_id                   NUMBER;

procedure do_create_credit_ratings(
    p_credit_ratings_rec           IN OUT NOCOPY credit_ratings_rec_type,
    x_credit_rating_id             OUT    NOCOPY NUMBER,
    x_return_status                IN OUT NOCOPY VARCHAR2
);

procedure do_update_credit_ratings(
    p_credit_ratings_rec           IN OUT NOCOPY credit_ratings_rec_type,
    p_last_update_date             IN OUT NOCOPY DATE,
    x_return_status                IN OUT NOCOPY VARCHAR2
);

procedure do_create_financial_profile(
    p_financial_profile_rec        IN OUT NOCOPY financial_profile_rec_type,
    x_financial_profile_id         OUT    NOCOPY NUMBER,
    x_return_status                IN OUT NOCOPY VARCHAR2
);

procedure do_update_financial_profile(
    p_financial_profile_rec        IN OUT NOCOPY financial_profile_rec_type,
    p_last_update_date             IN OUT NOCOPY DATE,
    x_return_status                IN OUT NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              create_credit_ratings
 |
 | DESCRIPTION
 |              Creates credit ratings.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_credit_ratings_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_credit_rating_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                      For non-profile entities, the concept of
 |                                      select/de-select data-sources is obsoleted.
 +===========================================================================

procedure create_credit_ratings(
    p_api_version                  IN      NUMBER,
    p_init_msg_list                IN      VARCHAR2:= FND_API.G_FALSE,
    p_commit                       IN      VARCHAR2:= FND_API.G_FALSE,
    p_credit_ratings_rec           IN      CREDIT_RATINGS_REC_TYPE,
    x_return_status                OUT     NOCOPY VARCHAR2,
    x_msg_count                    OUT     NOCOPY NUMBER,
    x_msg_data                     OUT     NOCOPY VARCHAR2,
    x_credit_rating_id             OUT     NOCOPY NUMBER,
    p_validation_level             IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name                     CONSTANT VARCHAR2(30) := 'create credit ratings';
    l_api_version                  CONSTANT NUMBER := 1.0;
    l_credit_ratings_rec           CREDIT_RATINGS_REC_TYPE := p_credit_ratings_rec;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT create_credit_ratings_pub;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
                     l_api_version,
                     p_api_version,
                     l_api_name,
                     G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity. Then assign the actual_content_source
    -- to the real data source. The value of content_source_type is
    -- depended on if data source is seleted. If it is selected, we reset
    -- content_source_type to user-entered. We also check if user
    -- has the privilege to create user-entered data if mix-n-match
    -- is enabled.

    -- Bug 2444678: Removed caching.

    -- IF g_cre_mixnmatch_enabled IS NULL THEN
* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.

    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_CREDIT_RATINGS',
      p_entity_attr_id                 => g_cre_entity_attr_id,
      p_mixnmatch_enabled              => g_cre_mixnmatch_enabled,
      p_selected_datasources           => g_cre_selected_datasources );

    -- END IF;

    HZ_MIXNM_UTILITY.AssignDataSourceDuringCreation (
      p_entity_name                    => 'HZ_CREDIT_RATINGS',
      p_entity_attr_id                 => g_cre_entity_attr_id,
      p_mixnmatch_enabled              => g_cre_mixnmatch_enabled,
      p_selected_datasources           => g_cre_selected_datasources,
      p_content_source_type            => l_credit_ratings_rec.content_source_type,
      p_actual_content_source          => l_credit_ratings_rec.actual_content_source,
      x_is_datasource_selected         => g_cre_is_datasource_selected,
      x_return_status                  => x_return_status,
      p_api_version                    => 'V1');

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

******** this code is replaced to go via V2 API.
    -- Call to business logic.
    do_create_credit_ratings(
      l_credit_ratings_rec,
      x_credit_rating_id,
      x_return_status );
*********

    -- call to perform everything through V2 API
    HZ_PARTY_INFO_V2PVT.v2_create_credit_rating
        (l_credit_ratings_rec,
         x_return_status,
         x_credit_rating_id);

********* this call will be from V2 API
    -- Invoke business event system.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_cre_is_datasource_selected = 'Y'
    THEN
       HZ_BUSINESS_EVENT_V2PVT.create_credit_ratings_event(l_credit_ratings_rec);
    END IF;
*********

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      Commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_credit_ratings_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_credit_ratings_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_credit_ratings_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END create_credit_ratings;

END obsolete v1 api;
*/
/*===========================================================================+
 | PROCEDURE
 |              update_credit_ratings
 |
 | DESCRIPTION
 |              Updates credit ratings.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_credit_ratings_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                      For non-profile entities, the concept of
 |                                      select/de-select data-sources is obsoleted.
 +===========================================================================

procedure update_credit_ratings(
    p_api_version                  IN     NUMBER,
    p_init_msg_list                IN     VARCHAR2:= FND_API.G_FALSE,
    p_commit                       IN     VARCHAR2:= FND_API.G_FALSE,
    p_credit_ratings_rec           IN     CREDIT_RATINGS_REC_TYPE,
    p_last_update_date             IN OUT NOCOPY DATE,
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2,
    p_validation_level             IN     NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name                     CONSTANT VARCHAR2(30) := 'update credit ratings';
    l_api_version                  CONSTANT NUMBER := 1.0;
    l_credit_ratings_rec           CREDIT_RATINGS_REC_TYPE := p_credit_ratings_rec;
    l_old_credit_ratings_rec       CREDIT_RATINGS_REC_TYPE;

BEGIN

    --Standard start of API savepoint
    SAVEPOINT update_credit_ratings_pub;

    --Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
                     l_api_version,
                     p_api_version,
                     l_api_name,
                     G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    get_current_credit_rating(
      1, FND_API.G_FALSE,
      l_credit_ratings_rec.credit_rating_id,
      l_old_credit_ratings_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Bug 2197181: added for mix-n-match project. first load data
    -- sources for this entity.

    -- Bug 2444678: Removed caching.
* SSM SST Integration and Extension
 * For non-profile entities, the concept of select/de-select data-sources is obsoleted.
 * There is no need to check if the data-source is selected.

    -- IF g_cre_mixnmatch_enabled IS NULL THEN
    HZ_MIXNM_UTILITY.LoadDataSources(
      p_entity_name                    => 'HZ_CREDIT_RATINGS',
      p_entity_attr_id                 => g_cre_entity_attr_id,
      p_mixnmatch_enabled              => g_cre_mixnmatch_enabled,
      p_selected_datasources           => g_cre_selected_datasources );
    -- END IF;

    -- Bug 2197181: added for mix-n-match project.
    -- check if the data source is seleted.

    g_cre_is_datasource_selected :=
      HZ_MIXNM_UTILITY.isDataSourceSelected (
        p_selected_datasources           => g_cre_selected_datasources,
        p_actual_content_source          => l_old_credit_ratings_rec.actual_content_source );

********* replaced the following code to everything via V2 API
    -- Call to business logic.
    do_update_credit_ratings(
      l_credit_ratings_rec,
      p_last_update_date,
      x_return_status );
************

    -- call to perform everything through V2 API
    HZ_PARTY_INFO_V2PVT.v2_update_credit_rating
        (l_credit_ratings_rec,
         p_last_update_date,
         x_return_status);

********* this call will be from V2 API
    -- Invoke business event system.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       -- Bug 2197181: Added below condition for Mix-n-Match
       g_cre_is_datasource_selected = 'Y'
    THEN
      HZ_BUSINESS_EVENT_V2PVT.update_credit_ratings_event( l_credit_ratings_rec);
    END IF;
*************

    --Standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
      Commit;
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_credit_ratings_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_credit_ratings_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO update_credit_ratings_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

END update_credit_ratings;

END Obsolete v1 api

*/

/*===========================================================================+
 | PROCEDURE
 |              create_financial_profile
 |
 | DESCRIPTION
 |              Creates financial profile.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_financial_profile_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_financial_profile_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure create_financial_profile(
        p_api_version             IN      NUMBER,
        p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                  IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_profile_rec   IN      FINANCIAL_PROFILE_REC_TYPE,
        x_return_status           OUT     NOCOPY VARCHAR2,
        x_msg_count               OUT     NOCOPY NUMBER,
        x_msg_data                OUT     NOCOPY VARCHAR2,
        x_financial_profile_id    OUT     NOCOPY NUMBER,
        p_validation_level        IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name                CONSTANT VARCHAR2(30)      := 'create financial profile';
        l_api_version             CONSTANT  NUMBER           := 1.0;
        l_financial_profile_rec   FINANCIAL_PROFILE_REC_TYPE := p_financial_profile_rec;

BEGIN
--Standard start of API savepoint
        SAVEPOINT create_financial_profile_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_party_info_crmhk.create_financial_profile_pre(
                        l_financial_profile_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PARTY_INFO_CRMHK.CREATE_FINANCIAL_PROFILE_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_create_financial_profile( l_financial_profile_rec,
                                     x_financial_profile_id,
                                     x_return_status);
/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_party_info_crmhk.create_financial_profile_post(
                        l_financial_profile_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PARTY_INFO_CRMHK.CREATE_FINANCIAL_PROFILE_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       hz_business_event_v2pvt.create_fin_profile_event(L_FINANCIAL_PROFILE_REC);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_financial_profile(
         p_operation            => 'I',
         p_financial_profile_id => x_financial_profile_id);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_financial_profile_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_financial_profile_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_financial_profile_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_financial_profile;

/*===========================================================================+
 | PROCEDURE
 |              update_financial_profile
 |
 | DESCRIPTION
 |              Updates financial profile.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_financial_profile_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

procedure update_financial_profile(
        p_api_version             IN      NUMBER,
        p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                  IN      VARCHAR2:= FND_API.G_FALSE,
        p_financial_profile_rec   IN      FINANCIAL_PROFILE_REC_TYPE,
        p_last_update_date        IN OUT  NOCOPY DATE,
        x_return_status           OUT     NOCOPY VARCHAR2,
        x_msg_count               OUT     NOCOPY NUMBER,
        x_msg_data                OUT     NOCOPY VARCHAR2,
        p_validation_level        IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL
) IS
        l_api_name      CONSTANT VARCHAR2(30) := 'update financial profile';
        l_api_version   CONSTANT  NUMBER      := 1.0;
        l_financial_profile_rec  FINANCIAL_PROFILE_REC_TYPE := p_financial_profile_rec;

BEGIN
--Standard start of API savepoint
        SAVEPOINT update_financial_profile_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
--Call to User-Hook pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_party_info_crmhk.update_financial_profile_pre(
                        l_financial_profile_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PARTY_INFO_CRMHK.UPDATE_FINANCIAL_PROFILE_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

-- Call to business logic.
-- Call PL/SQL wrapper over table handler
        do_update_financial_profile( l_financial_profile_rec,
                                     p_last_update_date,
                                     x_return_status);

/*
--Call to User-Hook post Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_party_info_crmhk.update_financial_profile_post(
                        l_financial_profile_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PARTY_INFO_CRMHK.UPDATE_FINANCIAL_PROFILE_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('Y', 'EVENTS_ENABLED')) THEN
       hz_business_event_v2pvt.update_fin_profile_event(l_financial_profile_rec);
     END IF;

     IF(HZ_UTILITY_V2PUB.G_EXECUTE_API_CALLOUTS in ('EVENTS_ENABLED', 'BO_EVENTS_ENABLED')) THEN
       -- populate function for integration service
       HZ_POPULATE_BOT_PKG.pop_hz_financial_profile(
         p_operation            => 'U',
         p_financial_profile_id => l_financial_profile_rec.financial_profile_id);
     END IF;
   END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_financial_profile_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_financial_profile_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_financial_profile_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_financial_profile;

/*===========================================================================+
 | PROCEDURE
 |              do_create_creidt_ratings
 |
 | DESCRIPTION
 |              Creates credit ratings.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_credit_rating_id
 |          IN/ OUT:
 |                    p_credit_ratings_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_create_credit_ratings(
    p_credit_ratings_rec           IN OUT NOCOPY credit_ratings_rec_type,
    x_credit_rating_id             OUT    NOCOPY NUMBER,
    x_return_status                IN OUT NOCOPY VARCHAR2
) IS

    l_credit_rating_id             NUMBER:= p_credit_ratings_rec.credit_rating_id;
    l_rowid                        ROWID := NULL;
    l_count                        NUMBER;
    x_msg_count                    NUMBER;
    x_msg_data                     VARCHAR2(2000);

BEGIN

    --Call to User-Hook pre Processing Procedure
    --Bug 1363124: validation#3 of content_source_type
/*
    IF  fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
        -- Bug 2197181: Modifed the condition
        g_cre_is_datasource_selected = 'Y'
    THEN
      hz_party_info_crmhk.create_credit_ratings_pre(
        p_credit_ratings_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE','HZ_PARTY_INFO_CRMHK.CREATE_CREDIT_RATINGS_PRE');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

    -- if credit_rating_id is NULL, then generate PK.

    IF l_credit_rating_id is NULL  OR
       l_credit_rating_id = FND_API.G_MISS_NUM
    THEN
      l_count := 1;
      WHILE l_count > 0 LOOP
        SELECT hz_credit_ratings_s.nextval
        INTO l_credit_rating_id FROM dual;

        SELECT count(*)
        INTO l_count
        FROM hz_credit_ratings
        WHERE  credit_rating_id = l_credit_rating_id;
      END LOOP;
    ELSE
      l_count := 0;

      SELECT count(*)
      INTO l_count
      FROM hz_credit_ratings
      WHERE  credit_rating_id = l_credit_rating_id;

      IF l_count > 0  THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'credit_rating_id');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    x_credit_rating_id := l_credit_rating_id;

    -- validate credit ratings record

    HZ_PARTY_INFO_VAL.validate_credit_ratings(
      p_credit_ratings_rec, 'C', x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- sync obsolete column suit_judge_ind  with new column suit_ind

    IF (p_credit_ratings_rec.suit_judge_ind is not null AND
        p_credit_ratings_rec.suit_judge_ind <> FND_API.G_MISS_CHAR) AND
      ( p_credit_ratings_rec.suit_ind is null OR
        p_credit_ratings_rec.suit_ind = FND_API.G_MISS_CHAR)
    THEN
      p_credit_ratings_rec.suit_ind := p_credit_ratings_rec.suit_judge_ind;
    ELSIF nvl(p_credit_ratings_rec.suit_ind, FND_API.G_MISS_CHAR) <>
          nvl(p_credit_ratings_rec.suit_judge_ind, FND_API.G_MISS_CHAR) THEN
      p_credit_ratings_rec.suit_judge_ind := p_credit_ratings_rec.suit_ind;
    END IF;

    -- Bug 1428526: Should pass updated credit rating info. to caller.
    -- Make sure to use values in p_credit_ratings_rec.* when calling insert table
    -- handler. Need to update p_credit_ratings_rec first.

    p_credit_ratings_rec.credit_rating_id := l_credit_rating_id;
/*
    -- call table handler to insert a row
    HZ_CREDIT_RATINGS_PKG.INSERT_ROW(
      x_rowid                                   => l_rowid,
      x_credit_rating_id                        => p_credit_ratings_rec.credit_rating_id,
      x_description                             => p_credit_ratings_rec.description,
      x_party_id                                => p_credit_ratings_rec.party_id,
      x_rating                                  => p_credit_ratings_rec.rating,
      x_rated_as_of_date                        => p_credit_ratings_rec.rated_as_of_date,
      x_rating_organization                     => p_credit_ratings_rec.rating_organization,
      x_created_by                              => hz_utility_pub.created_by,
      x_creation_date                           => hz_utility_pub.creation_date,
      x_last_update_login                       => hz_utility_pub.last_update_login,
      x_last_update_date                        => hz_utility_pub.last_update_date,
      x_last_updated_by                         => hz_utility_pub.last_updated_by,
      x_request_id                              => hz_utility_pub.request_id,
      x_program_application_id                  => hz_utility_pub.program_application_id,
      x_program_id                              => hz_utility_pub.program_id,
      x_wh_update_date                          => p_credit_ratings_rec.wh_update_date,
      x_comments                                => p_credit_ratings_rec.comments,
      x_det_history_ind                         => p_credit_ratings_rec.det_history_ind,
      x_fincl_embt_ind                          => p_credit_ratings_rec.fincl_embt_ind,
      x_criminal_proceeding_ind                 => p_credit_ratings_rec.criminal_proceeding_ind,
      x_suit_judge_ind                          => p_credit_ratings_rec.suit_judge_ind,
      x_claims_ind                              => p_credit_ratings_rec.claims_ind,
      x_secured_flng_ind                        => p_credit_ratings_rec.secured_flng_ind,
      x_fincl_lgl_event_ind                     => p_credit_ratings_rec.fincl_lgl_event_ind,
      x_disaster_ind                            => p_credit_ratings_rec.disaster_ind,
      x_oprg_spec_evnt_ind                      => p_credit_ratings_rec.oprg_spec_evnt_ind,
      x_other_spec_evnt_ind                     => p_credit_ratings_rec.other_spec_evnt_ind,
      x_content_source_type                     => p_credit_ratings_rec.content_source_type,
      x_program_update_date                     => hz_utility_pub.program_update_date,
      x_status                                  => p_credit_ratings_rec.status,
      x_avg_high_credit                         => p_credit_ratings_rec.avg_high_credit,
      x_credit_score                            => p_credit_ratings_rec.credit_score,
      x_credit_score_age                        => p_credit_ratings_rec.credit_score_age,
      x_credit_score_class                      => p_credit_ratings_rec.credit_score_class,
      x_credit_score_commentary                 => p_credit_ratings_rec.credit_score_commentary,
      x_credit_score_commentary2                => p_credit_ratings_rec.credit_score_commentary2,
      x_credit_score_commentary3                => p_credit_ratings_rec.credit_score_commentary3,
      x_credit_score_commentary4                => p_credit_ratings_rec.credit_score_commentary4,
      x_credit_score_commentary5                => p_credit_ratings_rec.credit_score_commentary5,
      x_credit_score_commentary6                => p_credit_ratings_rec.credit_score_commentary6,
      x_credit_score_commentary7                => p_credit_ratings_rec.credit_score_commentary7,
      x_credit_score_commentary8                => p_credit_ratings_rec.credit_score_commentary8,
      x_credit_score_commentary9                => p_credit_ratings_rec.credit_score_commentary9,
      x_credit_score_commentary10               => p_credit_ratings_rec.credit_score_commentary10,
      x_credit_score_date                       => p_credit_ratings_rec.credit_score_date,
      x_credit_score_incd_default               => p_credit_ratings_rec.credit_score_incd_default,
      x_credit_score_natl_percentile            => p_credit_ratings_rec.credit_score_natl_percentile,
      x_failure_score                           => p_credit_ratings_rec.failure_score,
      x_failure_score_age                       => p_credit_ratings_rec.failure_score_age,
      x_failure_score_class                     => p_credit_ratings_rec.failure_score_class,
      x_failure_score_commentary                => p_credit_ratings_rec.failure_score_commentary,
      x_failure_score_commentary2               => p_credit_ratings_rec.failure_score_commentary2,
      x_failure_score_commentary3               => p_credit_ratings_rec.failure_score_commentary3,
      x_failure_score_commentary4               => p_credit_ratings_rec.failure_score_commentary4,
      x_failure_score_commentary5               => p_credit_ratings_rec.failure_score_commentary5,
      x_failure_score_commentary6               => p_credit_ratings_rec.failure_score_commentary6,
      x_failure_score_commentary7               => p_credit_ratings_rec.failure_score_commentary7,
      x_failure_score_commentary8               => p_credit_ratings_rec.failure_score_commentary8,
      x_failure_score_commentary9               => p_credit_ratings_rec.failure_score_commentary9,
      x_failure_score_commentary10              => p_credit_ratings_rec.failure_score_commentary10,
      x_failure_score_date                      => p_credit_ratings_rec.failure_score_date,
      x_failure_score_incd_default              => p_credit_ratings_rec.failure_score_incd_default,
      x_failure_score_natnl_pcntl               => p_credit_ratings_rec.failure_score_natnl_percentile,
      x_failure_score_override_code             => p_credit_ratings_rec.failure_score_override_code,
      x_global_failure_score                    => p_credit_ratings_rec.global_failure_score,
      x_debarment_ind                           => p_credit_ratings_rec.debarment_ind,
      x_debarments_count                        => p_credit_ratings_rec.debarments_count,
      x_debarments_date                         => p_credit_ratings_rec.debarments_date,
      x_high_credit                             => p_credit_ratings_rec.high_credit,
      x_maximum_credit_currency_code            => p_credit_ratings_rec.maximum_credit_currency_code,
      x_maximum_credit_rcmd                     => p_credit_ratings_rec.maximum_credit_rcmd ,
      x_paydex_norm                             => p_credit_ratings_rec.paydex_norm,
      x_paydex_score                            => p_credit_ratings_rec.paydex_score,
      x_paydex_three_months_ago                 => p_credit_ratings_rec.paydex_three_months_ago,
      x_credit_score_override_code              => p_credit_ratings_rec.credit_score_override_code,
      x_cr_scr_clas_expl                        => p_credit_ratings_rec.cr_scr_clas_expl,
      x_low_rng_delq_scr                        => p_credit_ratings_rec.low_rng_delq_scr,
      x_high_rng_delq_scr                       => p_credit_ratings_rec.high_rng_delq_scr,
      x_delq_pmt_rng_prcnt                      => p_credit_ratings_rec.delq_pmt_rng_prcnt,
      x_delq_pmt_pctg_for_all_firms             => p_credit_ratings_rec.delq_pmt_pctg_for_all_firms,
      x_num_trade_experiences                   => p_credit_ratings_rec.num_trade_experiences,
      x_paydex_firm_days                        => p_credit_ratings_rec.paydex_firm_days,
      x_paydex_firm_comment                     => p_credit_ratings_rec.paydex_firm_comment,
      x_paydex_industry_days                    => p_credit_ratings_rec.paydex_industry_days,
      x_paydex_industry_comment                 => p_credit_ratings_rec.paydex_industry_comment,
      x_paydex_comment                          => p_credit_ratings_rec.paydex_comment,
      x_suit_ind                                => p_credit_ratings_rec.suit_ind,
      x_lien_ind                                => p_credit_ratings_rec.lien_ind,
      x_judgement_ind                           => p_credit_ratings_rec.judgement_ind,
      x_bankruptcy_ind                          => p_credit_ratings_rec.bankruptcy_ind,
      x_no_trade_ind                            => p_credit_ratings_rec.no_trade_ind,
      x_prnt_hq_bkcy_ind                        => p_credit_ratings_rec.prnt_hq_bkcy_ind,
      x_num_prnt_bkcy_filing                    => p_credit_ratings_rec.num_prnt_bkcy_filing,
      x_prnt_bkcy_filg_type                     => p_credit_ratings_rec.prnt_bkcy_filg_type,
      x_prnt_bkcy_filg_chapter                  => p_credit_ratings_rec.prnt_bkcy_filg_chapter,
      x_prnt_bkcy_filg_date                     => p_credit_ratings_rec.prnt_bkcy_filg_date,
      x_num_prnt_bkcy_convs                     => p_credit_ratings_rec.num_prnt_bkcy_convs,
      x_prnt_bkcy_conv_date                     => p_credit_ratings_rec.prnt_bkcy_conv_date,
      x_prnt_bkcy_chapter_conv                  => p_credit_ratings_rec.prnt_bkcy_chapter_conv,
      x_slow_trade_expl                         => p_credit_ratings_rec.slow_trade_expl,
      x_negv_pmt_expl                           => p_credit_ratings_rec.negv_pmt_expl,
      x_pub_rec_expl                            => p_credit_ratings_rec.pub_rec_expl,
      x_business_discontinued                   => p_credit_ratings_rec.business_discontinued,
      x_spcl_event_comment                      => p_credit_ratings_rec.spcl_event_comment ,
      x_num_spcl_event                          => p_credit_ratings_rec.num_spcl_event,
      x_spcl_event_update_date                  => p_credit_ratings_rec.spcl_event_update_date,
      x_spcl_evnt_txt                           => p_credit_ratings_rec.spcl_evnt_txt,
      x_actual_content_source                   => p_credit_ratings_rec.actual_content_source
    );
*/
    --Call to User-Hook post Processing Procedure
/*
    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
       -- Bug 2197181: Modifed the condition
       g_cre_is_datasource_selected = 'Y'
    THEN
      hz_party_info_crmhk.create_credit_ratings_post(
        p_credit_ratings_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE','HZ_PARTY_INFO_CRMHK.CREATE_CREDIT_RATINGS_POST');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

END do_create_credit_ratings;

/*===========================================================================+
 | PROCEDURE
 |              do_update_credit_ratings
 |
 | DESCRIPTION
 |              Updates credit ratings.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_credit_ratings_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_credit_ratings(
    p_credit_ratings_rec            IN OUT NOCOPY credit_ratings_rec_type,
    p_last_update_date              IN OUT NOCOPY DATE,
    x_return_status                 IN OUT NOCOPY VARCHAR2
) IS

    l_rowid                         ROWID := NULL;
    l_last_update_date              DATE;
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(2000);

BEGIN

    -- check required fields:
    IF p_credit_ratings_rec.credit_rating_id is NULL  OR
       p_credit_ratings_rec.credit_rating_id = FND_API.G_MISS_NUM
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'credit_rating_id');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_last_update_date IS NULL OR
       p_last_update_date = FND_API.G_MISS_DATE
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
      FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    BEGIN
      -- check last update date.
      -- Bug 2197181: selecting actual_content_source for  mix-n-match project.

      SELECT rowid, last_update_date
      INTO l_rowid, l_last_update_date
      FROM HZ_CREDIT_RATINGS
      WHERE credit_rating_id = p_credit_ratings_rec.credit_rating_id
      AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
          to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
      FOR UPDATE NOWAIT;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_CREDIT_RATINGS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    --Call to User-Hook pre Processing Procedure
    --Bug 1363124: validation#3 of content_source_type
/*
    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
       -- Bug 2197181: Modifed the condition
       g_cre_is_datasource_selected = 'Y'
    THEN
      hz_party_info_crmhk.update_credit_ratings_pre(
        p_credit_ratings_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE','HZ_PARTY_INFO_CRMHK.UPDATE_CREDIT_RATINGS_PRE');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

    -- validate credit rating record
    HZ_PARTY_INFO_VAL.validate_credit_ratings(
      p_credit_ratings_rec, 'U', x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- sync obsolete column suit_judge_ind  with new column suit_ind
    IF (p_credit_ratings_rec.suit_ind is NULL AND
        p_credit_ratings_rec.suit_judge_ind is not null ) OR
       (p_credit_ratings_rec.suit_ind is not NULL AND
        p_credit_ratings_rec.suit_ind <> FND_API.G_MISS_CHAR  AND
        (p_credit_ratings_rec.suit_judge_ind is null OR
         (p_credit_ratings_rec.suit_judge_ind is not null AND
          p_credit_ratings_rec.suit_ind <> p_credit_ratings_rec.suit_judge_ind ) ) )
    THEN
      p_credit_ratings_rec.suit_judge_ind := p_credit_ratings_rec.suit_ind;
    ELSIF (p_credit_ratings_rec.suit_ind is not NULL AND
           p_credit_ratings_rec.suit_ind = FND_API.G_MISS_CHAR ) AND
          (p_credit_ratings_rec.suit_judge_ind is null OR
           (p_credit_ratings_rec.suit_judge_ind is not null AND
            p_credit_ratings_rec.suit_judge_ind <> FND_API.G_MISS_CHAR) )
    THEN
      p_credit_ratings_rec.suit_ind := p_credit_ratings_rec.suit_judge_ind;
    END IF;

    -- pass back the last update date
    p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

    -- Bug 1428526: Should pass updated credit rating info. to caller.
    -- Make sure to use values in p_credit_ratings_rec.* when calling update table
    -- handler. Need to update p_credit_ratings_rec first.
    NULL;
/*
    -- call table handler to update a row
    HZ_CREDIT_RATINGS_PKG.UPDATE_ROW(
      x_rowid                                   => l_rowid,
      x_credit_rating_id                        => p_credit_ratings_rec.credit_rating_id,
      x_description                             => p_credit_ratings_rec.description,
      x_party_id                                => p_credit_ratings_rec.party_id,
      x_rating                                  => p_credit_ratings_rec.rating,
      x_rated_as_of_date                        => p_credit_ratings_rec.rated_as_of_date,
      x_rating_organization                     => p_credit_ratings_rec.rating_organization,
      x_created_by                              => fnd_api.g_miss_num,
      x_creation_date                           => fnd_api.g_miss_date,
      x_last_update_login                       => hz_utility_pub.last_update_login,
      x_last_update_date                        => p_last_update_date,
      x_last_updated_by                         => hz_utility_pub.last_updated_by,
      x_request_id                              => hz_utility_pub.request_id,
      x_program_application_id                  => hz_utility_pub.program_application_id,
      x_program_id                              => hz_utility_pub.program_id,
      x_wh_update_date                          => p_credit_ratings_rec.wh_update_date,
      x_comments                                => p_credit_ratings_rec.comments,
      x_det_history_ind                         => p_credit_ratings_rec.det_history_ind,
      x_fincl_embt_ind                          => p_credit_ratings_rec.fincl_embt_ind,
      x_criminal_proceeding_ind                 => p_credit_ratings_rec.criminal_proceeding_ind,
      x_suit_judge_ind                          => p_credit_ratings_rec.suit_judge_ind,
      x_claims_ind                              => p_credit_ratings_rec.claims_ind,
      x_secured_flng_ind                        => p_credit_ratings_rec.secured_flng_ind,
      x_fincl_lgl_event_ind                     => p_credit_ratings_rec.fincl_lgl_event_ind,
      x_disaster_ind                            => p_credit_ratings_rec.disaster_ind,
      x_oprg_spec_evnt_ind                      => p_credit_ratings_rec.oprg_spec_evnt_ind,
      x_other_spec_evnt_ind                     => p_credit_ratings_rec.other_spec_evnt_ind,
      -- Bug 2197181 : content_source_type is obsolete and it is non-updateable.
      x_content_source_type                     => fnd_api.g_miss_char,
      x_program_update_date                     => hz_utility_pub.program_update_date,
      x_status                                  => p_credit_ratings_rec.status,
      x_avg_high_credit                         => p_credit_ratings_rec.avg_high_credit,
      x_credit_score                            => p_credit_ratings_rec.credit_score,
      x_credit_score_age                        => p_credit_ratings_rec.credit_score_age,
      x_credit_score_class                      => p_credit_ratings_rec.credit_score_class,
      x_credit_score_commentary                 => p_credit_ratings_rec.credit_score_commentary,
      x_credit_score_commentary2                => p_credit_ratings_rec.credit_score_commentary2,
      x_credit_score_commentary3                => p_credit_ratings_rec.credit_score_commentary3,
      x_credit_score_commentary4                => p_credit_ratings_rec.credit_score_commentary4,
      x_credit_score_commentary5                => p_credit_ratings_rec.credit_score_commentary5,
      x_credit_score_commentary6                => p_credit_ratings_rec.credit_score_commentary6,
      x_credit_score_commentary7                => p_credit_ratings_rec.credit_score_commentary7,
      x_credit_score_commentary8                => p_credit_ratings_rec.credit_score_commentary8,
      x_credit_score_commentary9                => p_credit_ratings_rec.credit_score_commentary9,
      x_credit_score_commentary10               => p_credit_ratings_rec.credit_score_commentary10,
      x_credit_score_date                       => p_credit_ratings_rec.credit_score_date,
      x_credit_score_incd_default               => p_credit_ratings_rec.credit_score_incd_default,
      x_credit_score_natl_percentile            => p_credit_ratings_rec.credit_score_natl_percentile,
      x_failure_score                           => p_credit_ratings_rec.failure_score,
      x_failure_score_age                       => p_credit_ratings_rec.failure_score_age,
      x_failure_score_class                     => p_credit_ratings_rec.failure_score_class,
      x_failure_score_commentary                => p_credit_ratings_rec.failure_score_commentary,
      x_failure_score_commentary2               => p_credit_ratings_rec.failure_score_commentary2,
      x_failure_score_commentary3               => p_credit_ratings_rec.failure_score_commentary3,
      x_failure_score_commentary4               => p_credit_ratings_rec.failure_score_commentary4,
      x_failure_score_commentary5               => p_credit_ratings_rec.failure_score_commentary5,
      x_failure_score_commentary6               => p_credit_ratings_rec.failure_score_commentary6,
      x_failure_score_commentary7               => p_credit_ratings_rec.failure_score_commentary7,
      x_failure_score_commentary8               => p_credit_ratings_rec.failure_score_commentary8,
      x_failure_score_commentary9               => p_credit_ratings_rec.failure_score_commentary9,
      x_failure_score_commentary10              => p_credit_ratings_rec.failure_score_commentary10,
      x_failure_score_date                      => p_credit_ratings_rec.failure_score_date,
      x_failure_score_incd_default              => p_credit_ratings_rec.failure_score_incd_default,
      x_failure_score_natnl_pcntl               => p_credit_ratings_rec.failure_score_natnl_percentile,
      x_failure_score_override_code             => p_credit_ratings_rec.failure_score_override_code,
      x_global_failure_score                    => p_credit_ratings_rec.global_failure_score,
      x_debarment_ind                           => p_credit_ratings_rec.debarment_ind,
      x_debarments_count                        => p_credit_ratings_rec.debarments_count,
      x_debarments_date                         => p_credit_ratings_rec.debarments_date,
      x_high_credit                             => p_credit_ratings_rec.high_credit,
      x_maximum_credit_currency_code            => p_credit_ratings_rec.maximum_credit_currency_code,
      x_maximum_credit_rcmd                     => p_credit_ratings_rec.maximum_credit_rcmd,
      x_paydex_norm                             => p_credit_ratings_rec.paydex_norm,
      x_paydex_score                            => p_credit_ratings_rec.paydex_score,
      x_paydex_three_months_ago                 => p_credit_ratings_rec.paydex_three_months_ago,
      x_credit_score_override_code              => p_credit_ratings_rec.credit_score_override_code,
      x_cr_scr_clas_expl                        => p_credit_ratings_rec.cr_scr_clas_expl,
      x_low_rng_delq_scr                        => p_credit_ratings_rec.low_rng_delq_scr,
      x_high_rng_delq_scr                       => p_credit_ratings_rec.high_rng_delq_scr,
      x_delq_pmt_rng_prcnt                      => p_credit_ratings_rec.delq_pmt_rng_prcnt,
      x_delq_pmt_pctg_for_all_firms             => p_credit_ratings_rec.delq_pmt_pctg_for_all_firms,
      x_num_trade_experiences                   => p_credit_ratings_rec.num_trade_experiences,
      x_paydex_firm_days                        => p_credit_ratings_rec.paydex_firm_days,
      x_paydex_firm_comment                     => p_credit_ratings_rec.paydex_firm_comment,
      x_paydex_industry_days                    => p_credit_ratings_rec.paydex_industry_days,
      x_paydex_industry_comment                 => p_credit_ratings_rec.paydex_industry_comment,
      x_paydex_comment                          => p_credit_ratings_rec.paydex_comment,
      x_suit_ind                                => p_credit_ratings_rec.suit_ind,
      x_lien_ind                                => p_credit_ratings_rec.lien_ind,
      x_judgement_ind                           => p_credit_ratings_rec.judgement_ind,
      x_bankruptcy_ind                          => p_credit_ratings_rec.bankruptcy_ind,
      x_no_trade_ind                            => p_credit_ratings_rec.no_trade_ind,
      x_prnt_hq_bkcy_ind                        => p_credit_ratings_rec.prnt_hq_bkcy_ind,
      x_num_prnt_bkcy_filing                    => p_credit_ratings_rec.num_prnt_bkcy_filing,
      x_prnt_bkcy_filg_type                     => p_credit_ratings_rec.prnt_bkcy_filg_type,
      x_prnt_bkcy_filg_chapter                  => p_credit_ratings_rec.prnt_bkcy_filg_chapter,
      x_prnt_bkcy_filg_date                     => p_credit_ratings_rec.prnt_bkcy_filg_date,
      x_num_prnt_bkcy_convs                     => p_credit_ratings_rec.num_prnt_bkcy_convs,
      x_prnt_bkcy_conv_date                     => p_credit_ratings_rec.prnt_bkcy_conv_date,
      x_prnt_bkcy_chapter_conv                  => p_credit_ratings_rec.prnt_bkcy_chapter_conv,
      x_slow_trade_expl                         => p_credit_ratings_rec.slow_trade_expl,
      x_negv_pmt_expl                           => p_credit_ratings_rec.negv_pmt_expl,
      x_pub_rec_expl                            => p_credit_ratings_rec.pub_rec_expl,
      x_business_discontinued                   => p_credit_ratings_rec.business_discontinued,
      x_spcl_event_comment                      => p_credit_ratings_rec.spcl_event_comment ,
      x_num_spcl_event                          => p_credit_ratings_rec.num_spcl_event,
      x_spcl_event_update_date                  => p_credit_ratings_rec.spcl_event_update_date,
      x_spcl_evnt_txt                           => p_credit_ratings_rec.spcl_evnt_txt,
      x_actual_content_source                   => p_credit_ratings_rec.actual_content_source
    );
*/
/*
    --Call to User-Hook post Processing Procedure
    IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' AND
        -- Bug 2197181: Modifed the condition
       g_cre_is_datasource_selected = 'Y'
    THEN
      hz_party_info_crmhk.update_credit_ratings_post(
        p_credit_ratings_rec,
        x_return_status,
        x_msg_count,
        x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
        FND_MESSAGE.SET_TOKEN('PROCEDURE','HZ_PARTY_INFO_CRMHK.UPDATE_CREDIT_RATINGS_POST');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
*/

END do_update_credit_ratings;

/*===========================================================================+
 | PROCEDURE
 |              do_create_financial_profile
 |
 | DESCRIPTION
 |              Creates financial profile.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_financial_profile_id
 |          IN/ OUT:
 |                    p_financial_profile_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_create_financial_profile(
        p_financial_profile_rec     IN OUT  NOCOPY financial_profile_rec_type,
        x_financial_profile_id      OUT     NOCOPY NUMBER,
        x_return_status             IN OUT  NOCOPY VARCHAR2
) IS
        l_financial_profile_id      NUMBER:= p_financial_profile_rec.financial_profile_id;
        l_rowid                     ROWID := NULL;
        l_count                     NUMBER;
BEGIN
    -- if financial_profile_id is NULL, then generate PK.

    IF l_financial_profile_id is NULL  OR
       l_financial_profile_id = FND_API.G_MISS_NUM  THEN

       l_count := 1;
       WHILE l_count > 0 LOOP
         SELECT hz_financial_profile_s.nextval
         INTO l_financial_profile_id FROM dual;

         SELECT count(*)
         INTO l_count
         FROM hz_financial_profile
         WHERE  financial_profile_id = l_financial_profile_id;
       END LOOP;
     ELSE
       l_count := 0;
       SELECT count(*)
       INTO l_count
       FROM hz_financial_profile
       WHERE  financial_profile_id = l_financial_profile_id;

       if l_count > 0  then
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_profile_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;

     END IF;

     x_financial_profile_id := l_financial_profile_id;

     -- validate credit ratings record

     HZ_PARTY_INFO_VAL.validate_financial_profile(p_financial_profile_rec,'C',
                                                  x_return_status);

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
     END IF;

-- Bug 1428526: Should pass updated financial profile info. to caller.
-- Make sure to use values in p_financial_profile_rec.* when calling insert table
-- handler. Need to update p_financial_profile_rec first.
     p_financial_profile_rec.financial_profile_id := l_financial_profile_id;
     -- call table handler to insert a row
     HZ_FINANCIAL_PROFILE_PKG.INSERT_ROW(
       X_Rowid => l_rowid,
       X_FINANCIAL_PROFILE_ID => p_financial_profile_rec.financial_profile_id,
       X_ACCESS_AUTHORITY_DATE => p_financial_profile_rec.ACCESS_AUTHORITY_DATE,
       X_ACCESS_AUTHORITY_GRANTED => p_financial_profile_rec.ACCESS_AUTHORITY_GRANTED,
       X_BALANCE_AMOUNT => p_financial_profile_rec.BALANCE_AMOUNT,
       X_BALANCE_VERIFIED_ON_DATE => p_financial_profile_rec.BALANCE_VERIFIED_ON_DATE,
       X_FINANCIAL_ACCOUNT_NUMBER => p_financial_profile_rec.FINANCIAL_ACCOUNT_NUMBER,
       X_FINANCIAL_ACCOUNT_TYPE => p_financial_profile_rec.FINANCIAL_ACCOUNT_TYPE,
       X_FINANCIAL_ORG_TYPE => p_financial_profile_rec.FINANCIAL_ORG_TYPE,
       X_FINANCIAL_ORGANIZATION_NAME => p_financial_profile_rec.FINANCIAL_ORGANIZATION_NAME,
       X_CREATED_BY => hz_utility_pub.CREATED_BY,
       X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
       X_PARTY_ID => p_financial_profile_rec.PARTY_ID,
       X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
       X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
       X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
       X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
       X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
       X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
       X_WH_UPDATE_DATE => p_financial_profile_rec.WH_UPDATE_DATE,
       X_STATUS =>p_financial_profile_rec.STATUS
      );

END do_create_financial_profile;

/*===========================================================================+
 | PROCEDURE
 |              do_update_financial_profile
 |
 | DESCRIPTION
 |              Updates financial profile.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_financial_profile_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang 06-OCT-00  Bug 1428526: make *_rec parameters as
 |                      'IN OUT' in order to pass the changed record
 |                      to caller.
 |
 +===========================================================================*/

procedure do_update_financial_profile(
       p_financial_profile_rec     IN OUT  NOCOPY financial_profile_rec_type,
       p_last_update_date          IN OUT  NOCOPY DATE,
       x_return_status             IN OUT  NOCOPY VARCHAR2
) IS
       l_rowid                     ROWID := NULL;
       l_last_update_date          DATE;
BEGIN
      -- check required fields:
      IF p_financial_profile_rec.financial_profile_id is NULL  OR
         p_financial_profile_rec.financial_profile_id = FND_API.G_MISS_NUM  THEN

             FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
             FND_MESSAGE.SET_TOKEN('COLUMN', 'financial_profile_id');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;

       END IF;

       IF p_last_update_date IS NULL OR
           p_last_update_date = FND_API.G_MISS_DATE
        THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'p_last_update_date');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

begin
        -- check last update date.
        SELECT rowid, last_update_date
        INTO l_rowid, l_last_update_date
        FROM HZ_FINANCIAL_PROFILE
        where financial_profile_id = p_financial_profile_rec.financial_profile_id
        AND to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS') =
            to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS')
        FOR UPDATE NOWAIT;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_FINANCIAL_PROFILE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
end;
        -- validate credit rating record
        HZ_PARTY_INFO_VAL.validate_financial_profile(p_financial_profile_rec,'U',
                                                     x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- pass back the last update date
        p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;

-- Bug 1428526: Should pass updated financial profile info. to caller.
-- Make sure to use values in p_financial_profile_rec.* when calling update table
-- handler. Need to update p_financial_profile_rec first.
        NULL;
        -- call table handler to update a row
        HZ_FINANCIAL_PROFILE_PKG.UPDATE_ROW(
          X_Rowid => l_rowid,
          X_FINANCIAL_PROFILE_ID => p_financial_profile_rec.FINANCIAL_PROFILE_ID,
          X_ACCESS_AUTHORITY_DATE => p_financial_profile_rec.ACCESS_AUTHORITY_DATE,
          X_ACCESS_AUTHORITY_GRANTED => p_financial_profile_rec.ACCESS_AUTHORITY_GRANTED,
          X_BALANCE_AMOUNT => p_financial_profile_rec.BALANCE_AMOUNT,
          X_BALANCE_VERIFIED_ON_DATE => p_financial_profile_rec.BALANCE_VERIFIED_ON_DATE,
          X_FINANCIAL_ACCOUNT_NUMBER => p_financial_profile_rec.FINANCIAL_ACCOUNT_NUMBER,
          X_FINANCIAL_ACCOUNT_TYPE => p_financial_profile_rec.FINANCIAL_ACCOUNT_TYPE,
          X_FINANCIAL_ORG_TYPE => p_financial_profile_rec.FINANCIAL_ORG_TYPE,
          X_FINANCIAL_ORGANIZATION_NAME => p_financial_profile_rec.FINANCIAL_ORGANIZATION_NAME,
          X_CREATED_BY => FND_API.G_MISS_NUM,
          X_CREATION_DATE => FND_API.G_MISS_DATE,
          X_PARTY_ID => p_financial_profile_rec.PARTY_ID,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => p_last_update_date,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => p_financial_profile_rec.WH_UPDATE_DATE,
          X_STATUS => p_financial_profile_rec.STATUS
         );

END do_update_financial_profile;


procedure get_current_credit_rating(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_credit_rating_id      IN      NUMBER,
        x_credit_ratings_rec    OUT     NOCOPY CREDIT_RATINGS_REC_TYPE,
        x_return_status         IN OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'get_current_credit_rating';
        l_api_version           CONSTANT  NUMBER       := 1.0;

BEGIN

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--Check whether primary key has been passed in.
        IF p_credit_rating_id IS NULL OR
           p_credit_rating_id = FND_API.G_MISS_NUM THEN

            FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'credit_rating_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        BEGIN /* Just for select statement */

           SELECT
                credit_rating_id,
                description,
                party_id,
                rating,
                rated_as_of_date,
                rating_organization,
                wh_update_date,
                comments,
                det_history_ind,
                fincl_embt_ind,
                criminal_proceeding_ind,
                suit_judge_ind,
                claims_ind,
                secured_flng_ind,
                fincl_lgl_event_ind,
                disaster_ind,
                oprg_spec_evnt_ind,
                other_spec_evnt_ind,
                content_source_type,
                status,
                avg_high_credit,
                credit_score ,
                credit_score_age,
                credit_score_class,
                credit_score_commentary,
                credit_score_commentary2,
                credit_score_commentary3,
                credit_score_commentary4,
                credit_score_commentary5,
                credit_score_commentary6,
                credit_score_commentary7,
                credit_score_commentary8,
                credit_score_commentary9,
                credit_score_commentary10,
                credit_score_date,
                credit_score_incd_default,
                credit_score_natl_percentile,
                failure_score,
                failure_score_age,
                failure_score_class,
                failure_score_commentary,
                failure_score_commentary2,
                failure_score_commentary3,
                failure_score_commentary4,
                failure_score_commentary5,
                failure_score_commentary6,
                failure_score_commentary7,
                failure_score_commentary8,
                failure_score_commentary9,
                failure_score_commentary10,
                failure_score_date,
                failure_score_incd_default,
                failure_score_natnl_percentile,
                failure_score_override_code,
                global_failure_score,
                debarment_ind,
                debarments_count,
                debarments_date,
                high_credit,
                maximum_credit_currency_code,
                maximum_credit_recommendation,
                paydex_norm,
                paydex_score,
                paydex_three_months_ago,
                credit_score_override_code,
                cr_scr_clas_expl,
                low_rng_delq_scr,
                high_rng_delq_scr,
                delq_pmt_rng_prcnt,
                delq_pmt_pctg_for_all_firms,
                num_trade_experiences,
                paydex_firm_days,
                paydex_firm_comment,
                paydex_industry_days,
                paydex_industry_comment,
                paydex_comment,
                suit_ind,
                lien_ind,
                judgement_ind,
                bankruptcy_ind,
                no_trade_ind,
                prnt_hq_bkcy_ind,
                num_prnt_bkcy_filing,
                prnt_bkcy_filg_type,
                prnt_bkcy_filg_chapter,
                prnt_bkcy_filg_date,
                num_prnt_bkcy_convs,
                prnt_bkcy_conv_date,
                prnt_bkcy_chapter_conv,
                slow_trade_expl,
                negv_pmt_expl,
                pub_rec_expl,
                business_discontinued,
                spcl_event_comment,
                num_spcl_event,
                spcl_event_update_date,
                spcl_evnt_txt,
                actual_content_source
           INTO
                x_credit_ratings_rec.credit_rating_id,
                x_credit_ratings_rec.description,
                x_credit_ratings_rec.party_id,
                x_credit_ratings_rec.rating,
                x_credit_ratings_rec.rated_as_of_date,
                x_credit_ratings_rec.rating_organization,
                x_credit_ratings_rec.wh_update_date,
                x_credit_ratings_rec.comments,
                x_credit_ratings_rec.det_history_ind,
                x_credit_ratings_rec.fincl_embt_ind,
                x_credit_ratings_rec.criminal_proceeding_ind,
                x_credit_ratings_rec.suit_judge_ind,
                x_credit_ratings_rec.claims_ind,
                x_credit_ratings_rec.secured_flng_ind,
                x_credit_ratings_rec.fincl_lgl_event_ind,
                x_credit_ratings_rec.disaster_ind,
                x_credit_ratings_rec.oprg_spec_evnt_ind,
                x_credit_ratings_rec.other_spec_evnt_ind,
                x_credit_ratings_rec.content_source_type,
                x_credit_ratings_rec.status,
                x_credit_ratings_rec.avg_high_credit,
                x_credit_ratings_rec.credit_score ,
                x_credit_ratings_rec.credit_score_age,
                x_credit_ratings_rec.credit_score_class,
                x_credit_ratings_rec.credit_score_commentary,
                x_credit_ratings_rec.credit_score_commentary2,
                x_credit_ratings_rec.credit_score_commentary3,
                x_credit_ratings_rec.credit_score_commentary4,
                x_credit_ratings_rec.credit_score_commentary5,
                x_credit_ratings_rec.credit_score_commentary6,
                x_credit_ratings_rec.credit_score_commentary7,
                x_credit_ratings_rec.credit_score_commentary8,
                x_credit_ratings_rec.credit_score_commentary9,
                x_credit_ratings_rec.credit_score_commentary10,
                x_credit_ratings_rec.credit_score_date,
                x_credit_ratings_rec.credit_score_incd_default,
                x_credit_ratings_rec.credit_score_natl_percentile,
                x_credit_ratings_rec.failure_score,
                x_credit_ratings_rec.failure_score_age,
                x_credit_ratings_rec.failure_score_class,
                x_credit_ratings_rec.failure_score_commentary,
                x_credit_ratings_rec.failure_score_commentary2,
                x_credit_ratings_rec.failure_score_commentary3,
                x_credit_ratings_rec.failure_score_commentary4,
                x_credit_ratings_rec.failure_score_commentary5,
                x_credit_ratings_rec.failure_score_commentary6,
                x_credit_ratings_rec.failure_score_commentary7,
                x_credit_ratings_rec.failure_score_commentary8,
                x_credit_ratings_rec.failure_score_commentary9,
                x_credit_ratings_rec.failure_score_commentary10,
                x_credit_ratings_rec.failure_score_date,
                x_credit_ratings_rec.failure_score_incd_default,
                x_credit_ratings_rec.failure_score_natnl_percentile,
                x_credit_ratings_rec.failure_score_override_code,
                x_credit_ratings_rec.global_failure_score,
                x_credit_ratings_rec.debarment_ind,
                x_credit_ratings_rec.debarments_count,
                x_credit_ratings_rec.debarments_date,
                x_credit_ratings_rec.high_credit,
                x_credit_ratings_rec.maximum_credit_currency_code,
                x_credit_ratings_rec.maximum_credit_rcmd,
                x_credit_ratings_rec.paydex_norm,
                x_credit_ratings_rec.paydex_score,
                x_credit_ratings_rec.paydex_three_months_ago,
                x_credit_ratings_rec.credit_score_override_code,
                x_credit_ratings_rec.cr_scr_clas_expl,
                x_credit_ratings_rec.low_rng_delq_scr,
                x_credit_ratings_rec.high_rng_delq_scr,
                x_credit_ratings_rec.delq_pmt_rng_prcnt,
                x_credit_ratings_rec.delq_pmt_pctg_for_all_firms,
                x_credit_ratings_rec.num_trade_experiences,
                x_credit_ratings_rec.paydex_firm_days,
                x_credit_ratings_rec.paydex_firm_comment,
                x_credit_ratings_rec.paydex_industry_days,
                x_credit_ratings_rec.paydex_industry_comment,
                x_credit_ratings_rec.paydex_comment,
                x_credit_ratings_rec.suit_ind,
                x_credit_ratings_rec.lien_ind,
                x_credit_ratings_rec.judgement_ind,
                x_credit_ratings_rec.bankruptcy_ind,
                x_credit_ratings_rec.no_trade_ind,
                x_credit_ratings_rec.prnt_hq_bkcy_ind,
                x_credit_ratings_rec.num_prnt_bkcy_filing,
                x_credit_ratings_rec.prnt_bkcy_filg_type,
                x_credit_ratings_rec.prnt_bkcy_filg_chapter,
                x_credit_ratings_rec.prnt_bkcy_filg_date,
                x_credit_ratings_rec.num_prnt_bkcy_convs,
                x_credit_ratings_rec.prnt_bkcy_conv_date,
                x_credit_ratings_rec.prnt_bkcy_chapter_conv,
                x_credit_ratings_rec.slow_trade_expl,
                x_credit_ratings_rec.negv_pmt_expl,
                x_credit_ratings_rec.pub_rec_expl,
                x_credit_ratings_rec.business_discontinued,
                x_credit_ratings_rec.spcl_event_comment,
                x_credit_ratings_rec.num_spcl_event,
                x_credit_ratings_rec.spcl_event_update_date,
                x_credit_ratings_rec.spcl_evnt_txt,
                x_credit_ratings_rec.actual_content_source

           FROM hz_credit_ratings
           WHERE credit_rating_id = p_credit_rating_id;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
              FND_MESSAGE.SET_TOKEN('RECORD', 'credit rating');
              FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_credit_rating_id));
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
        END;
--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END get_current_credit_rating;

END HZ_PARTY_INFO_PUB;

/
