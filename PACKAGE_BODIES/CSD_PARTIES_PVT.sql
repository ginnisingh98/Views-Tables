--------------------------------------------------------
--  DDL for Package Body CSD_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_PARTIES_PVT" AS
/* $Header: csdvptyb.pls 120.1 2005/08/17 15:14:04 swai noship $ */
--
-- Package name     : CSD_PARTIES_PVT
-- Purpose          : This package contains the private APIs for managing
--                    TCA parties in Depot Repair.
-- History          :
-- Version       Date       Name        Description
-- 115.9         10/14/02   swai       Created.


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_PARTIES_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvptyb.pls';
l_debug       NUMBER := fnd_profile.value('CSD_DEBUG_LEVEL');


/*----------------------------------------------------------------*/
/* procedure name: Create_Customer                                */
/* description   : procedure used to create a Depot Repair        */
/*                 customer in TCA.  Also creates account,        */
/*                 contact points, bill-to and ship-to addresses  */
/*                                                                */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_person_rec                 Person Information                */
/* p_org_rec                    Organization Info                 */
/*                              Required fields for org rec are:  */
/*                              Organization name                 */
/* p_party_type                 'PERSON' or 'ORGANIZATION'        */
/* p_account_rec                Account Info                      */
/* p_cust_profile_rec           Profile Info                      */
/* p_phone_rec                  Phone Info                        */
/* p_email_rec                  Email Info                        */
/* p_web_rec                    Web Info                          */
/* p_create_phone_flag          'Y' to create phone contact point */
/* p_create_email_flag          'Y' to create email contact point */
/* p_create_url_flag            'Y' to create url contact point   */
/* p_bill_loc_rec               Bill-to location                  */
/* p_bill_party_site_rec        Bill-to site                      */
/* p_bill_party_site_use_rec    Bill-to site use                  */
/* p_ship_loc_rec               Ship-to location                  */
/* p_ship_party_site_rec        Ship-to site                      */
/* p_ship_party_site_use_rec    Ship-to site use                  */
/* x_party_id                   Party ID generated                */
/* x_party_number               Party Number gnerated             */
/* x_cust_account_id            Account ID generated              */
/* x_cust_account_number        Account Number generated          */
/* x_phone_id                   Phone contact point ID            */
/* x_email_id                   Email contact point ID            */
/* x_url_id                     URL contact point ID              */
/* x_bill_party_site_rec        Bill-to site                      */
/* x_bill_party_site_use_rec    Bill-to site use                  */
/* x_bill_location_id           Bill-to location ID               */
/* x_bill_party_site_id         Bill-to site id                   */
/* x_bill_party_site_number     Bill-to site number               */
/* x_bill_party_site_use_id     Bill-to site use id               */
/* x_ship_party_site_rec        Ship-to site                      */
/* x_ship_party_site_use_rec    Ship-to site use                  */
/* x_ship_location_id           Ship-to location ID               */
/* x_ship_party_site_id         Ship-to site id                   */
/* x_ship_party_site_number     Ship-to site number               */
/* x_ship_party_site_use_id     Ship-to site use id               */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Customer
(  p_api_version             IN  NUMBER,
   p_commit                  IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list           IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level        IN  NUMBER    := fnd_api.g_valid_level_full,
   p_person_rec              IN  HZ_PARTY_V2PUB.person_rec_type,
   p_org_rec                 IN  HZ_PARTY_V2PUB.organization_rec_type,
   p_party_type              IN  VARCHAR2,
   p_account_rec             IN  HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type,
   p_cust_profile_rec        IN  HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type,
   p_phone_rec               IN  HZ_CONTACT_POINT_V2PUB.phone_rec_type,
   p_email_rec               IN  HZ_CONTACT_POINT_V2PUB.email_rec_type,
   p_web_rec                 IN  HZ_CONTACT_POINT_V2PUB.web_rec_type,
   p_create_phone_flag       IN  VARCHAR2,
   p_create_email_flag       IN  VARCHAR2,
   p_create_url_flag         IN  VARCHAR2,
   p_bill_loc_rec            IN  CSD_PROCESS_PVT.address_rec_type,
   p_bill_location_id        IN  NUMBER := null,
   p_ship_loc_rec            IN  CSD_PROCESS_PVT.address_rec_type,
   p_ship_location_id        IN  NUMBER := null,
   x_party_id                OUT NOCOPY NUMBER,
   x_party_number            OUT NOCOPY VARCHAR2,
   x_cust_account_id         OUT NOCOPY NUMBER,
   x_cust_account_number     OUT NOCOPY VARCHAR2,
   x_phone_id                OUT NOCOPY NUMBER,
   x_email_id                OUT NOCOPY NUMBER,
   x_url_id                  OUT NOCOPY NUMBER,
   x_bill_party_site_rec     IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_rec_type,
   x_bill_party_site_use_rec IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_use_rec_type,
   x_bill_location_id        OUT NOCOPY NUMBER,
   x_bill_party_site_id      OUT NOCOPY NUMBER,
   x_bill_party_site_number  OUT NOCOPY NUMBER,
   x_bill_party_site_use_id  OUT NOCOPY NUMBER,
   x_ship_party_site_rec     IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_rec_type,
   x_ship_party_site_use_rec IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_use_rec_type,
   x_ship_location_id        OUT NOCOPY NUMBER,
   x_ship_party_site_id      OUT NOCOPY NUMBER,
   x_ship_party_site_number  OUT NOCOPY NUMBER,
   x_ship_party_site_use_id  OUT NOCOPY NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Create_Customer';
   l_api_version             CONSTANT NUMBER := 1.0;
   l_person_rec              HZ_PARTY_V2PUB.person_rec_type := p_person_rec;
   l_org_rec                 HZ_PARTY_V2PUB.organization_rec_type := p_org_rec;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Customer_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_org_rec
                   ( p_org_rec => p_org_rec);
          csd_gen_utility_pvt.dump_hz_person_rec
                   ( p_person_rec => p_person_rec);
          csd_gen_utility_pvt.dump_hz_phone_rec
                   ( p_phone_rec => p_phone_rec);
          csd_gen_utility_pvt.dump_hz_email_rec
                   ( p_email_rec => p_email_rec);
          csd_gen_utility_pvt.dump_hz_web_rec
                   ( p_web_rec => p_web_rec);
          csd_gen_utility_pvt.dump_hz_cust_profile_rec
                   ( p_cust_profile_rec => p_cust_profile_rec);
          csd_gen_utility_pvt.dump_hz_acct_rec
                   ( p_account_rec => p_account_rec);

          csd_gen_utility_pvt.add('bill-to information');
          csd_gen_utility_pvt.dump_address_rec
                   ( p_addr_rec => p_bill_loc_rec);
          csd_gen_utility_pvt.dump_hz_party_site_rec
                   ( p_party_site_rec => x_bill_party_site_rec);
          csd_gen_utility_pvt.dump_hz_party_site_use_rec
                   ( p_party_site_use_rec => x_bill_party_site_use_rec);

          csd_gen_utility_pvt.add('ship-to information');
          csd_gen_utility_pvt.dump_address_rec
                   ( p_addr_rec => p_ship_loc_rec);
          csd_gen_utility_pvt.dump_hz_party_site_rec
                   ( p_party_site_rec => x_ship_party_site_rec);
          csd_gen_utility_pvt.dump_hz_party_site_use_rec
                   ( p_party_site_use_rec => x_ship_party_site_use_rec);
    END IF;

    IF (p_party_type = 'PERSON') THEN
        Create_Person( p_api_version      => 1.0,
                       p_commit           => FND_API.G_FALSE,
                       p_validation_level => p_validation_level,
                       p_person_rec       => p_person_rec,
                       x_party_id         => x_party_id,
                       x_party_number     => x_party_number,
                       x_return_status    => x_return_status,
                       x_msg_count        => x_msg_count,
                       x_msg_data         => x_msg_data);

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_Person failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_person_rec.party_rec.party_id := x_party_id;
        l_person_rec.party_rec.party_number := x_party_number;
        Create_Account(p_api_version          => 1.0,
                       p_commit               => FND_API.G_FALSE,
                       p_init_msg_list        => FND_API.G_FALSE,
                       p_validation_level     => p_validation_level,
                       p_account_rec          => p_account_rec,
                       p_person_rec           => l_person_rec,
                       p_cust_profile_rec     => p_cust_profile_rec,
                       x_cust_account_id      => x_cust_account_id,
                       x_cust_account_number  => x_cust_account_number,
                       x_return_status        => x_return_status,
                       x_msg_count            => x_msg_count,
                       x_msg_data             => x_msg_data);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_Account failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    ELSIF (p_party_type = 'ORGANIZATION') THEN
        Create_Organization( p_api_version      => 1.0,
                             p_commit           => FND_API.G_FALSE,
                             p_init_msg_list    => FND_API.G_FALSE,
                             p_validation_level => p_validation_level,
                             p_org_rec          => p_org_rec,
                             x_party_id         => x_party_id,
                             x_party_number     => x_party_number,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data);

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_Organization failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_org_rec.party_rec.party_id := x_party_id;
        l_org_rec.party_rec.party_number := x_party_number;
        Create_Account(p_api_version          => 1.0,
                       p_commit               => FND_API.G_FALSE,
                       p_init_msg_list        => FND_API.G_FALSE,
                       p_validation_level     => p_validation_level,
                       p_account_rec          => p_account_rec,
                       p_org_rec              => l_org_rec,
                       p_cust_profile_rec     => p_cust_profile_rec,
                       x_cust_account_id      => x_cust_account_id,
                       x_cust_account_number  => x_cust_account_number,
                       x_return_status        => x_return_status,
                       x_msg_count            => x_msg_count,
                       x_msg_data             => x_msg_data);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_Account failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    IF (p_create_phone_flag = 'Y') OR
       (p_create_email_flag = 'Y') OR
       (p_create_url_flag = 'Y')
    THEN
        Create_ContactPoints(
                       p_api_version       => 1.0,
                       p_commit            => FND_API.G_FALSE,
                       p_init_msg_list     => FND_API.G_FALSE,
                       p_validation_level  => p_validation_level,
                       p_phone_rec         => p_phone_rec,
                       p_email_rec         => p_email_rec,
                       p_web_rec           => p_web_rec,
                       p_create_phone_flag => p_create_phone_flag,
                       p_create_email_flag => p_create_email_flag,
                       p_create_url_flag   => p_create_url_flag,
                       p_party_id          => x_party_id,
                       x_phone_id          => x_phone_id,
                       x_email_id          => x_email_id,
                       x_url_id            => x_url_id,
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_ContactPoints failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    -- bill to address records
    x_bill_party_site_rec.party_id := x_party_id;
    Create_AddressRecords(
                       p_api_version        => 1.0,
                       p_commit             => FND_API.G_FALSE,
                       p_init_msg_list      => FND_API.G_FALSE,
                       p_validation_level   => p_validation_level,
                       p_loc_rec            => p_bill_loc_rec,
                       p_location_id        => p_bill_location_id,
                       x_party_site_rec     => x_bill_party_site_rec,
                       x_party_site_use_rec => x_bill_party_site_use_rec,
                       x_location_id        => x_bill_location_id,
                       x_party_site_id      => x_bill_party_site_id,
                       x_party_site_number  => x_bill_party_site_number,
                       x_party_site_use_id  => x_bill_party_site_use_id,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data);
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_AddressRecords failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- ship to address records
    x_ship_party_site_rec.party_id := x_party_id;
    Create_AddressRecords(
                       p_api_version        => 1.0,
                       p_commit             => FND_API.G_FALSE,
                       p_init_msg_list      => FND_API.G_FALSE,
                       p_validation_level   => p_validation_level,
                       p_loc_rec            => p_ship_loc_rec,
                       p_location_id        => p_ship_location_id,
                       x_party_site_rec     => x_ship_party_site_rec,
                       x_party_site_use_rec => x_ship_party_site_use_rec,
                       x_location_id        => x_ship_location_id,
                       x_party_site_id      => x_ship_party_site_id,
                       x_party_site_number  => x_ship_party_site_number,
                       x_party_site_use_id  => x_ship_party_site_use_id,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data);
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_AddressRecords failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Customer_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Customer_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Customer_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );

END Create_Customer;


/*----------------------------------------------------------------*/
/* procedure name: Create_Contact                                 */
/* description   : procedure used to create a person contact      */
/*                 in TCA. Also creates contact points.           */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_person_rec                 Person Information                */
/* p_phone_rec                  Phone Info                        */
/* p_email_rec                  Email Info                        */
/* p_web_rec                    Web Info                          */
/* p_create_phone_flag          'Y' to create phone contact point */
/* p_create_email_flag          'Y' to create email contact point */
/* p_create_url_flag            'Y' to create url contact point   */
/* x_party_id                   Party ID generated                */
/* x_party_number               Party Number generated             */
/* x_phone_id                   Phone contact point ID            */
/* x_email_id                   Email contact point ID            */
/* x_url_id                     URL contact point ID              */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Contact
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_person_rec           IN  HZ_PARTY_V2PUB.person_rec_type,
   p_phone_rec            IN  HZ_CONTACT_POINT_V2PUB.phone_rec_type,
   p_email_rec            IN  HZ_CONTACT_POINT_V2PUB.email_rec_type,
   p_web_rec              IN  HZ_CONTACT_POINT_V2PUB.web_rec_type,
   p_create_phone_flag    IN  VARCHAR2,
   p_create_email_flag    IN  VARCHAR2,
   p_create_url_flag      IN  VARCHAR2,
   x_party_id             OUT NOCOPY NUMBER,
   x_party_number         OUT NOCOPY VARCHAR2,
   x_phone_id             OUT NOCOPY NUMBER,
   x_email_id             OUT NOCOPY NUMBER,
   x_url_id               OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Create_Contact';
  l_api_version           CONSTANT NUMBER := 1.0;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Contact_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_person_rec
                   ( p_person_rec => p_person_rec);
          csd_gen_utility_pvt.dump_hz_phone_rec
                   ( p_phone_rec => p_phone_rec);
          csd_gen_utility_pvt.dump_hz_email_rec
                   ( p_email_rec => p_email_rec);
          csd_gen_utility_pvt.dump_hz_web_rec
                   ( p_web_rec => p_web_rec);
    END IF;

    Create_Person(     p_api_version      => 1.0,
                       p_commit           => FND_API.G_FALSE,
                       p_init_msg_list    => FND_API.G_FALSE,
                       p_validation_level => p_validation_level,
                       p_person_rec       => p_person_rec,
                       x_party_id         => x_party_id,
                       x_party_number     => x_party_number,
                       x_return_status    => x_return_status,
                       x_msg_count        => x_msg_count,
                       x_msg_data         => x_msg_data);
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_Person failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_create_phone_flag = 'Y') OR
       (p_create_email_flag = 'Y') OR
       (p_create_url_flag = 'Y')
    THEN
        Create_ContactPoints(
                       p_api_version       => 1.0,
                       p_commit            => FND_API.G_FALSE,
                       p_init_msg_list     => FND_API.G_FALSE,
                       p_validation_level  => p_validation_level,
                       p_phone_rec         => p_phone_rec,
                       p_email_rec         => p_email_rec,
                       p_web_rec           => p_web_rec,
                       p_create_phone_flag => p_create_phone_flag,
                       p_create_email_flag => p_create_email_flag,
                       p_create_url_flag   => p_create_url_flag,
                       p_party_id          => x_party_id,
                       x_phone_id          => x_phone_id,
                       x_email_id          => x_email_id,
                       x_url_id            => x_url_id,
                       x_return_status     => x_return_status,
                       x_msg_count         => x_msg_count,
                       x_msg_data          => x_msg_data);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_ContactPoints failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Contact_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          x_party_id      := NULL;
          x_party_number  := '';
          x_phone_id      := NULL;
          x_email_id      := NULL;
          x_url_id        := NULL;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Contact_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_party_id      := NULL;
          x_party_number  := '';
          x_phone_id      := NULL;
          x_email_id      := NULL;
          x_url_id        := NULL;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Contact_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_party_id      := NULL;
          x_party_number  := '';
          x_phone_id      := NULL;
          x_email_id      := NULL;
          x_url_id        := NULL;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_Contact;


/*----------------------------------------------------------------*/
/* procedure name: Create_Person                                  */
/* description   : procedure used to create                       */
/*                 a person in TCA                                */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_person_rec                 Person Information                */
/* x_party_id                   Party ID generated                */
/* x_party_number               Party Number generated             */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Person
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_person_rec           IN  HZ_PARTY_V2PUB.person_rec_type,
   x_party_id             OUT NOCOPY NUMBER,
   x_party_number         OUT NOCOPY VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )

IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Create_Person';
  l_api_version           CONSTANT NUMBER := 1.0;
  l_profile_id                     NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Person_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_person_rec
                   ( p_person_rec => p_person_rec);
    END IF;

    HZ_PARTY_V2PUB.Create_Person(
                                p_init_msg_list    => FND_API.G_FALSE,
                                p_person_rec       => p_person_rec,
                                x_party_id         => x_party_id,
                                x_party_number     => x_party_number,
                                x_profile_id       => l_profile_id,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data
                              );

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_Person failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Person_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Person_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Person_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_Person;

/*----------------------------------------------------------------*/
/* procedure name: Create_Organization                            */
/* description   : procedure used to create an organization       */
/*                 in TCA                                         */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_org_rec                    Organization Info                 */
/* x_party_id                   Party ID generated                */
/* x_party_number               Party Number generated             */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Organization
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_org_rec              IN  HZ_PARTY_V2PUB.organization_rec_type,
   x_party_id             OUT NOCOPY NUMBER,
   x_party_number         OUT NOCOPY VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Create_Organization';
  l_api_version           CONSTANT NUMBER := 1.0;
  l_profile_id                     NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Organization_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --

    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );

    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_org_rec
                   ( p_org_rec => p_org_rec);
    END IF;


    HZ_PARTY_V2PUB.Create_Organization(
                                      p_init_msg_list    => FND_API.G_FALSE,
                                      p_organization_rec => p_org_rec,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      x_party_id         => x_party_id,
                                      x_party_number     => x_party_number,
                                      x_profile_id       => l_profile_id
                                    );
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_Organization failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Organization_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Organization_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Organization_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_Organization;

/*----------------------------------------------------------------*/
/* procedure name: Create_Account                                 */
/* description   : procedure used to create                       */
/*                 an account for a person                        */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_account_rec                Account Info                      */
/* p_person_rec                 Person Information                */
/* p_cust_profile_rec           Profile Info                      */
/* x_cust_account_id            Account ID generated              */
/* x_cust_account_number        Account Number generated          */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Account
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_account_rec          IN  HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type,
   p_person_rec           IN  HZ_PARTY_V2PUB.person_rec_type,
   p_cust_profile_rec     IN  HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type,
   x_cust_account_id      OUT NOCOPY NUMBER,
   x_cust_account_number  OUT NOCOPY VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Create_Account';
  l_api_version           CONSTANT NUMBER := 1.0;
  l_party_id                       NUMBER;
  l_party_number                   VARCHAR2(30);
  l_profile_id                     NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Account_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_acct_rec
                   ( p_account_rec => p_account_rec);
          csd_gen_utility_pvt.dump_hz_person_rec
                   ( p_person_rec => p_person_rec);
          csd_gen_utility_pvt.dump_hz_cust_profile_rec
                   ( p_cust_profile_rec => p_cust_profile_rec);
    END IF;

    HZ_CUST_ACCOUNT_V2PUB.create_cust_account(
                               p_init_msg_list        => FND_API.G_FALSE,
                               p_cust_account_rec     => p_account_rec,
                               p_person_rec           => p_person_rec,
                               p_customer_profile_rec => p_cust_profile_rec,
                               p_create_profile_amt   => FND_API.G_TRUE,
                               x_cust_account_id      => x_cust_account_id,
                               x_account_number       => x_cust_account_number,
                               x_party_id             => l_party_id,
                               x_party_number         => l_party_number,
                               x_profile_id           => l_profile_id,
                               x_return_status        => x_return_status,
                               x_msg_count            => x_msg_count,
                               x_msg_data             => x_msg_data
                               );

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_Account failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_Account;



/*----------------------------------------------------------------*/
/* procedure name: Create_Account                                 */
/* description   : procedure used to create                       */
/*                 an account for an organization                 */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_account_rec                Account Info                      */
/* p_org_rec                    Organization Info                 */
/* p_cust_profile_rec           Profile Info                      */
/* x_cust_account_id            Account ID generated              */
/* x_cust_account_number        Account Number generated          */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Account
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_account_rec          IN  HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type,
   p_org_rec              IN  HZ_PARTY_V2PUB.organization_rec_type,
   p_cust_profile_rec     IN  HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type,
   x_cust_account_id      OUT NOCOPY NUMBER,
   x_cust_account_number  OUT NOCOPY VARCHAR2,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Create_Account';
  l_api_version           CONSTANT NUMBER := 1.0;
  l_party_id                       NUMBER;
  l_party_number                   VARCHAR2(30);
  l_profile_id                     NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Account_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );

    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_acct_rec
                   ( p_account_rec => p_account_rec);
          csd_gen_utility_pvt.dump_hz_org_rec
                   ( p_org_rec => p_org_rec);
          csd_gen_utility_pvt.dump_hz_cust_profile_rec
                   ( p_cust_profile_rec => p_cust_profile_rec);
    END IF;

    HZ_CUST_ACCOUNT_V2PUB.create_cust_account(
                               p_init_msg_list        => FND_API.G_FALSE,
                               p_cust_account_rec     => p_account_rec,
                               p_organization_rec     => p_org_rec,
                               p_customer_profile_rec => p_cust_profile_rec,
                               p_create_profile_amt   => FND_API.G_TRUE,
                               x_cust_account_id      => x_cust_account_id,
                               x_account_number       => x_cust_account_number,
                               x_party_id             => l_party_id,
                               x_party_number         => l_party_number,
                               x_profile_id           => l_profile_id,
                               x_return_status        => x_return_status,
                               x_msg_count            => x_msg_count,
                               x_msg_data             => x_msg_data
                               );

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_Account failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_Account;


/*----------------------------------------------------------------*/
/* procedure name: Create_ContactPoints                           */
/* description   : procedure used to create                       */
/*                 contact points for a party                     */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_phone_rec                  Phone Info                        */
/* p_email_rec                  Email Info                        */
/* p_web_rec                    Web Info                          */
/* p_create_phone_flag          'Y' to create phone contact point */
/* p_create_email_flag          'Y' to create email contact point */
/* p_create_url_flag            'Y' to create url contact point   */
/* p_party_id                   Party ID for these contact points */
/* x_phone_id                   Phone contact point ID            */
/* x_email_id                   Email contact point ID            */
/* x_url_id                     URL contact point ID              */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_ContactPoints
(  p_api_version       IN  NUMBER,
   p_commit            IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list     IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level  IN  NUMBER    := fnd_api.g_valid_level_full,
   p_phone_rec         IN  HZ_CONTACT_POINT_V2PUB.phone_rec_type,
   p_email_rec         IN  HZ_CONTACT_POINT_V2PUB.email_rec_type,
   p_web_rec           IN  HZ_CONTACT_POINT_V2PUB.web_rec_type,
   p_create_phone_flag IN  VARCHAR2,
   p_create_email_flag IN  VARCHAR2,
   p_create_url_flag   IN  VARCHAR2,
   p_party_id          IN  NUMBER,
   x_phone_id          OUT NOCOPY NUMBER,
   x_email_id          OUT NOCOPY NUMBER,
   x_url_id            OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2 )
IS
   l_api_name          CONSTANT VARCHAR2(30) := 'Create_ContactPoints';
   l_api_version       CONSTANT NUMBER := 1.0;
   l_phone_create_rec  HZ_CONTACT_POINT_V2PUB.phone_rec_type
                                := CSD_PROCESS_PVT.get_phone_rec_type;
   l_email_create_rec  HZ_CONTACT_POINT_V2PUB.email_rec_type
                                := CSD_PROCESS_PVT.get_email_rec_type;
   l_web_create_rec    HZ_CONTACT_POINT_V2PUB.web_rec_type
                                := CSD_PROCESS_PVT.get_web_rec_type;
   l_edi_create_rec    HZ_CONTACT_POINT_V2PUB.edi_rec_type
                                := CSD_PROCESS_PVT.get_edi_rec_type;
   l_telex_create_rec  HZ_CONTACT_POINT_V2PUB.telex_rec_type
                                := CSD_PROCESS_PVT.get_telex_rec_type;
   l_contpt_create_rec HZ_CONTACT_POINT_V2PUB.contact_point_rec_type
                                := CSD_PROCESS_PVT.get_contact_points_rec_type;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_ContactPoints_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_phone_rec
                   ( p_phone_rec => p_phone_rec);
          csd_gen_utility_pvt.dump_hz_email_rec
                   ( p_email_rec => p_email_rec);
          csd_gen_utility_pvt.dump_hz_web_rec
                   ( p_web_rec => p_web_rec);
    END IF;

    IF (p_create_phone_flag = 'Y') THEN
        l_contpt_create_rec.contact_point_type := 'PHONE';
        l_contpt_create_rec.owner_table_name   := 'HZ_PARTIES';
        l_contpt_create_rec.owner_table_id     := p_party_id;

        HZ_CONTACT_POINT_V2PUB.Create_contact_point(
                             p_init_msg_list         => FND_API.G_FALSE,
                             p_contact_point_rec     => l_contpt_create_rec,
                             p_edi_rec               => l_edi_create_rec,
                             p_email_rec             => l_email_create_rec,
                             p_phone_rec             => p_phone_rec,
                             p_telex_rec             => l_telex_create_rec,
                             p_web_rec               => l_web_create_rec,
                             x_contact_point_id      => x_phone_id,
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                             );

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_contact_points failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;  -- end create phone contact point

    IF (p_create_email_flag = 'Y') THEN
        l_contpt_create_rec.contact_point_type := 'EMAIL';
        l_contpt_create_rec.owner_table_name   := 'HZ_PARTIES';
        l_contpt_create_rec.owner_table_id     := p_party_id;

        HZ_CONTACT_POINT_V2PUB.Create_contact_point(
                             p_init_msg_list         => FND_API.G_FALSE,
                             p_contact_point_rec     => l_contpt_create_rec,
                             p_edi_rec               => l_edi_create_rec,
                             p_email_rec             => p_email_rec,
                             p_phone_rec             => l_phone_create_rec,
                             p_telex_rec             => l_telex_create_rec,
                             p_web_rec               => l_web_create_rec,
                             x_contact_point_id      => x_email_id,
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                             );

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_contact_points failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;   -- end create email contact point

    IF (p_create_url_flag = 'Y') THEN
        l_contpt_create_rec.contact_point_type := 'WEB';
        l_contpt_create_rec.owner_table_name   := 'HZ_PARTIES';
        l_contpt_create_rec.owner_table_id     := p_party_id;

        HZ_CONTACT_POINT_V2PUB.Create_contact_point(
                             p_init_msg_list         => FND_API.G_FALSE,
                             p_contact_point_rec     => l_contpt_create_rec,
                             p_edi_rec               => l_edi_create_rec,
                             p_email_rec             => l_email_create_rec,
                             p_phone_rec             => l_phone_create_rec,
                             p_telex_rec             => l_telex_create_rec,
                             p_web_rec               => p_web_rec,
                             x_contact_point_id      => x_url_id,
                             x_return_status         => x_return_status,
                             x_msg_count             => x_msg_count,
                             x_msg_data              => x_msg_data
                             );

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_contact_points failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;  -- end create url contact point

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_ContactPoints_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          x_phone_id := NULL;
          x_email_id := NULL;
          x_url_id   := NULL;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_ContactPoints_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_phone_id := NULL;
          x_email_id := NULL;
          x_url_id   := NULL;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_ContactPoints_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_phone_id := NULL;
          x_email_id := NULL;
          x_url_id   := NULL;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_ContactPoints;



/*----------------------------------------------------------------*/
/* procedure name: Create_AddressRecords                          */
/* description   : procedure used to create                       */
/*                 address records in TCA                         */
/*                 This includes creating a location, site,       */
/*                 and site use.                                  */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_loc_rec                    Location                          */
/* p_location_id                Location ID, if it already exists */
/* x_party_site_rec             Site                              */
/* x_party_site_use_rec         Site use                          */
/* x_location_id                Location ID created/used          */
/* x_party_site_id              Site id                           */
/* x_party_site_number          Site number                       */
/* x_party_site_use_id          Site use id                       */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_AddressRecords
(  p_api_version        IN  NUMBER,
   p_commit             IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level   IN  NUMBER    := fnd_api.g_valid_level_full,
   p_loc_rec            IN  CSD_PROCESS_PVT.address_rec_type,
   p_location_id        IN  NUMBER := NULL,
   x_party_site_rec     IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_rec_type,
   x_party_site_use_rec IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_use_rec_type,
   x_location_id        OUT NOCOPY NUMBER,
   x_party_site_id      OUT NOCOPY NUMBER,
   x_party_site_number  OUT NOCOPY NUMBER,
   x_party_site_use_id  OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2 )
IS
   l_api_name           CONSTANT VARCHAR2(30) := 'Create_AddressRecords';
   l_api_version        CONSTANT NUMBER := 1.0;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_AddressRecords_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_address_rec
                   ( p_addr_rec => p_loc_rec);
          csd_gen_utility_pvt.dump_hz_party_site_rec
                   ( p_party_site_rec => x_party_site_rec);
          csd_gen_utility_pvt.dump_hz_party_site_use_rec
                   ( p_party_site_use_rec => x_party_site_use_rec);
    END IF;


    x_location_id := p_location_id;
    -- Create location if location_id is not passed in
    IF (p_location_id is null) THEN
        Create_Address (  p_api_version      => 1.0,
                          p_commit           => FND_API.G_FALSE,
                          p_init_msg_list    => FND_API.G_FALSE,
                          p_validation_level => p_validation_level,
                          p_address_rec      => p_loc_rec,
                          x_location_id      => x_location_id,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data);

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_Address failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;  -- end create location

    -- Create party site if location is created or if location_id is passed in
    IF (p_location_id is not null) OR (x_location_id is not null) THEN
        -- First, set the location in the site record before creating the site
        IF (p_location_id is not null) THEN
            x_party_site_rec.location_id := p_location_id;
        ELSE
            x_party_site_rec.location_id := x_location_id;
        END IF;

        -- Second, create the site
        HZ_PARTY_SITE_V2PUB.Create_Party_Site(
                          p_init_msg_list       => FND_API.G_FALSE,
                          p_party_site_rec      => x_party_site_rec,
                          x_party_site_id       => x_party_site_id,
                          x_party_site_number   => x_party_site_number,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data
                          );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Create_Party_Site failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        x_party_site_rec.party_site_id := x_party_site_id;
        x_party_site_rec.party_site_number := x_party_site_number;
   END IF;  -- end create party site

   -- Create party site use if party site is created
   IF (x_party_site_id is not null) THEN
       -- IF (x_party_site_use_rec.site_use_type is not null) THEN
           -- First, set the party site id in the use record
           x_party_site_use_rec.party_site_id := x_party_site_id;

           -- Second, create the site use
           HZ_PARTY_SITE_V2PUB.Create_Party_Site_Use (
                          p_init_msg_list       => FND_API.G_FALSE,
                          p_party_site_use_rec  => x_party_site_use_rec,
                          x_party_site_use_id   => x_party_site_use_id,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data
                          );
            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                csd_gen_utility_pvt.ADD('Create_Party_Site_Use failed ');
                RAISE FND_API.G_EXC_ERROR;
            END IF;
       -- END IF;
    END IF;  -- end create site use

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_AddressRecords_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          x_location_id       := NULL;
          x_party_site_id     := NULL;
          x_party_site_number := NULL;
          x_party_site_use_id := NULL;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_AddressRecords_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_location_id       := NULL;
          x_party_site_id     := NULL;
          x_party_site_number := NULL;
          x_party_site_use_id := NULL;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_AddressRecords_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_location_id       := NULL;
          x_party_site_id     := NULL;
          x_party_site_number := NULL;
          x_party_site_use_id := NULL;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_AddressRecords;

/*----------------------------------------------------------------*/
/* procedure name: Create_Address                                 */
/* description   : procedure used to create                       */
/*                 a location in TCA                              */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_address_rec                Location to create                */
/* x_location_id                Location ID created               */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Address
(  p_api_version        IN  NUMBER,
   p_commit             IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level   IN  NUMBER    := fnd_api.g_valid_level_full,
   p_address_rec        IN  CSD_PROCESS_PVT.address_rec_type,
   x_location_id        OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2 )
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Create_Address';
  l_api_version         CONSTANT NUMBER := 1.0;
  -- swai: change to TCA v2
  l_location_rec        HZ_LOCATION_V2PUB.location_rec_type;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Address_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_address_rec
                   ( p_addr_rec => p_address_rec);
    END IF;

    l_location_rec.location_id := p_address_rec.location_id;
    l_location_rec.address1 := p_address_rec.address1;
    l_location_rec.address2 := p_address_rec.address2;
    l_location_rec.address3 := p_address_rec.address3;
    l_location_rec.address4 := p_address_rec.address4;
    l_location_rec.city     := p_address_rec.city;
    l_location_rec.state    := p_address_rec.state;
    l_location_rec.postal_code := p_address_rec.postal_code;
    l_location_rec.province := p_address_rec.province;
    l_location_rec.county   := p_address_rec.county;
    l_location_rec.country  := p_address_rec.country;
    l_location_rec.language := p_address_rec.language;
    l_location_rec.position := p_address_rec.position;
    l_location_rec.address_key := p_address_rec.address_key;
    l_location_rec.postal_plus4_code := p_address_rec.postal_plus4_code;
    l_location_rec.position := p_address_rec.position;
    l_location_rec.delivery_point_code := p_address_rec.delivery_point_code;
    l_location_rec.location_directions := p_address_rec.location_directions;
    -- l_location_rec.address_error_code := p_address_rec.address_error_code;
    l_location_rec.clli_code := p_address_rec.clli_code;
    l_location_rec.short_description := p_address_rec.short_description;
    l_location_rec.description := p_address_rec.description;
    l_location_rec.sales_tax_geocode := p_address_rec.sales_tax_geocode;
    l_location_rec.sales_tax_inside_city_limits := p_address_rec.sales_tax_inside_city_limits;
    l_location_rec.address_effective_date := p_address_rec.address_effective_date;
    l_location_rec.address_expiration_date := p_address_rec.address_expiration_date;
    l_location_rec.address_style := p_address_rec.address_style;
    -- swai: unused fields in TCA, but still avail in v2 (per bug #2863096)
    l_location_rec.po_box_number := p_address_rec.po_box_number;
    l_location_rec.street   := p_address_rec.street;
    l_location_rec.house_number  := p_address_rec.house_number;
    l_location_rec.street_suffix := p_address_rec.street_suffix;
    l_location_rec.street_number := p_address_rec.street_number;
    l_location_rec.floor := p_address_rec.floor;
    l_location_rec.suite := p_address_rec.suite;
    -- swai: new TCA V2 fields --
    l_location_rec.timezone_id := p_address_rec.timezone_id;
    l_location_rec.created_by_module := p_address_rec.created_by_module;
    l_location_rec.application_id := p_address_rec.application_id;
    l_location_rec.actual_content_source := p_address_rec.actual_content_source;
    l_location_rec.delivery_point_code := p_address_rec.delivery_point_code;
    -- end new TCA V2 fields --

    -- swai: use new TCA v2 API
    HZ_LOCATION_V2PUB.create_location (
                          p_init_msg_list     => FND_API.G_FALSE,
                          p_location_rec      => l_location_rec,
                          x_location_id       => x_location_id,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data);

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('create_location failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Address_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Address_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Address_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_Address;

/*----------------------------------------------------------------*/
/* procedure name: Create_Relationship                            */
/* description   : procedure used to create                       */
/*                 a relationship between parties                 */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_party_rel_rec              Party relationship to create      */
/* x_party_rel_id               Relationship ID generated         */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Create_Relationship
(  p_api_version        IN  NUMBER,
   p_commit             IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level   IN  NUMBER    := fnd_api.g_valid_level_full,
   p_party_rel_rec      IN  HZ_RELATIONSHIP_V2PUB.relationship_rec_type,
   x_party_rel_id       OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2 )
IS
   l_api_name           CONSTANT VARCHAR2(30) := 'Create_Relationship';
   l_api_version        CONSTANT NUMBER := 1.0;
   l_party_id           NUMBER;
   l_party_number       VARCHAR2(30);
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Create_Relationship_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );

    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_party_rel_rec
                   ( p_party_rel_rec => p_party_rel_rec);
    END IF;


    HZ_RELATIONSHIP_V2PUB.Create_Relationship(
        p_init_msg_list          => FND_API.G_FALSE,
        p_relationship_rec          => p_party_rel_rec,
        -- p_create_party           => 'N',
        -- p_create_org_contact     => 'Y'
        x_relationship_id        => x_party_rel_id,
        x_party_id               => l_party_id,
        x_party_number           => l_party_number,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
        );

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Create_Party_Relationship failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Relationship_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Relationship_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Create_Relationship_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Create_Relationship;


/*----------------------------------------------------------------*/
/* procedure name: Update_Party                                   */
/* description   : procedure used to update                       */
/*                 a  party in TCA                                */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_person_rec                 Person Information                */
/* p_org_rec                    Organization Info                 */
/* p_party_type                 'PERSON' or 'ORGANIZATION'        */
/* p_obj_ver_num                Last version for party            */
/* x_obj_ver_num                New Last version for party        */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Update_Party
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_person_rec           IN  HZ_PARTY_V2PUB.person_rec_type,
   p_org_rec              IN  HZ_PARTY_V2PUB.organization_rec_type,
   p_party_type           IN  VARCHAR2,
   p_obj_ver_num          IN  NUMBER,
   x_obj_ver_num          OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )
IS
   l_api_name             CONSTANT VARCHAR2(30) := 'Update_Party';
   l_api_version          CONSTANT NUMBER := 1.0;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Party_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_org_rec
                   ( p_org_rec => p_org_rec);
          csd_gen_utility_pvt.dump_hz_person_rec
                   ( p_person_rec => p_person_rec);
    END IF;

    IF (p_party_type = 'PERSON') THEN
        Update_Person( p_api_version      => 1.0,
                       p_commit           => FND_API.G_FALSE,
                       p_init_msg_list    => FND_API.G_FALSE,
                       p_validation_level => p_validation_level,
                       p_person_rec       => p_person_rec,
                       p_obj_ver_num      => p_obj_ver_num,
                       x_obj_ver_num      => x_obj_ver_num,
                       x_return_status    => x_return_status,
                       x_msg_count        => x_msg_count,
                       x_msg_data         => x_msg_data
                     );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Update_Person failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    ELSIF (p_party_type = 'ORGANIZATION') THEN
        Update_Organization( p_api_version      => 1.0,
                             p_commit           => FND_API.G_FALSE,
                             p_init_msg_list    => FND_API.G_FALSE,
                             p_validation_level => p_validation_level,
                             p_org_rec          => p_org_rec,
                             p_obj_ver_num      => p_obj_ver_num,
                             x_obj_ver_num      => x_obj_ver_num,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data
                           );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Update_Organization failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Party_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Party_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Update_Party_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Update_Party;

/*----------------------------------------------------------------*/
/* procedure name: Update_Person                                  */
/* description   : procedure used to update                       */
/*                 a person in TCA                                */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_person_rec                 Person Information                */
/* p_obj_ver_num                Last version for person           */
/* x_obj_ver_num                New Last version for person       */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Update_Person
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_person_rec           IN  HZ_PARTY_V2PUB.person_rec_type,
   p_obj_ver_num          IN  NUMBER,
   x_obj_ver_num          OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Create_Relationship';
   l_api_version         CONSTANT NUMBER := 1.0;
   l_profile_id                   NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Person_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_person_rec
                   ( p_person_rec => p_person_rec);
    END IF;

    x_obj_ver_num := p_obj_ver_num;
    HZ_PARTY_V2PUB.Update_Person(
                    p_init_msg_list                 => FND_API.G_FALSE,
                    p_person_rec                    => p_person_rec,
                    p_party_object_version_number   => x_obj_ver_num,
                    x_profile_id                    => l_profile_id,
                    x_return_status                 => x_return_status,
                    x_msg_count                     => x_msg_count,
                    x_msg_data                      => x_msg_data
                    );
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Update_Person failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Person_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Person_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Update_Person_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );

END Update_Person;


/*----------------------------------------------------------------*/
/* procedure name: Update_Organization                            */
/* description   : procedure used to update                       */
/*                 an organization in TCA                         */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_org_rec                    Organization Info                 */
/* p_obj_ver_num                Last version num for org          */
/* x_obj_ver_num                New Last version num for org      */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Update_Organization
(  p_api_version          IN  NUMBER,
   p_commit               IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list        IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level     IN  NUMBER    := fnd_api.g_valid_level_full,
   p_org_rec              IN  HZ_PARTY_V2PUB.organization_rec_type,
   p_obj_ver_num          IN  NUMBER,
   x_obj_ver_num          OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2 )
IS
   l_api_name             CONSTANT VARCHAR2(30) := 'Create_Relationship';
   l_api_version          CONSTANT NUMBER := 1.0;
   l_profile_id                   NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Organization_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_org_rec
                   ( p_org_rec => p_org_rec);
    END IF;

    x_obj_ver_num:= p_obj_ver_num;
    HZ_PARTY_V2PUB.Update_Organization(
                    p_init_msg_list                 => FND_API.G_FALSE,
                    p_organization_rec              => p_org_rec,
                    p_party_object_version_number   => x_obj_ver_num,
                    x_return_status                 => x_return_status,
                    x_msg_count                     => x_msg_count,
                    x_msg_data                      => x_msg_data,
                    x_profile_id                    => l_profile_id
                    );
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Update_Organization failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Organization_Pvt;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Organization_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Update_Organization_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );

END Update_Organization;


/*----------------------------------------------------------------*/
/* procedure name: Update_Account                                 */
/* description   : procedure used to update                       */
/*                 an account for a party                         */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_cust_acct_rec              Account Info                      */
/* p_obj_ver_num                Last version num for account      */
/* x_obj_ver_num                New Last version num for account  */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Update_Account
(  p_api_version        IN  NUMBER,
   p_commit             IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level   IN  NUMBER    := fnd_api.g_valid_level_full,
   p_cust_acct_rec      IN  HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type,
   p_obj_ver_num        IN  NUMBER,
   x_obj_ver_num        OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2 )
IS
   l_api_name           CONSTANT VARCHAR2(30) := 'Update_Account';
   l_api_version        CONSTANT NUMBER := 1.0;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Account_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );

    x_obj_ver_num:= p_obj_ver_num;
    HZ_CUST_ACCOUNT_V2PUB.Update_Cust_Account(
                          p_init_msg_list          =>  FND_API.G_FALSE,
                          p_cust_account_rec       =>  p_cust_acct_rec,
                          p_object_version_number  =>  x_obj_ver_num,
                          x_return_status          =>  x_return_status,
                          x_msg_count              =>  x_msg_count,
                          x_msg_data               =>  x_msg_data
                          );

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('Update_Account failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Update_Account_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Update_Account;

/*----------------------------------------------------------------*/
/* procedure name: Update_ContactPoints                           */
/* description   : procedure used to update                       */
/*                 contact points for a party                     */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_phone_rec                  Phone Info                        */
/* p_email_rec                  Email Info                        */
/* p_web_rec                    Web Info                          */
/* p_phone_cnt_point_id         ID of phone contact point         */
/* p_email_cnt_point_id         ID of email contact point         */
/* p_url_cnt_point_id           ID of url contact point           */
/* p_phone_obj_ver_num          Last version num for phone        */
/* p_email_obj_ver_num          Last version num for email        */
/* p_url_obj_ver_num            Last version num for url          */
/* p_update_phone_flag          'Y' to update phone contact point */
/* p_update_email_flag          'Y' to update email contact point */
/* p_update_url_flag            'Y' to update url contact point   */
/* x_phone_obj_ver_num          New Last version num for phone    */
/* x_email_obj_ver_num          New Last version num for email    */
/* x_url_obj_ver_num            New Last version num for url      */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Update_ContactPoints
(
   p_api_version            IN  NUMBER,
   p_commit                 IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list          IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level       IN  NUMBER    := fnd_api.g_valid_level_full,
   p_phone_rec              IN  HZ_CONTACT_POINT_V2PUB.phone_rec_type,
   p_email_rec              IN  HZ_CONTACT_POINT_V2PUB.email_rec_type,
   p_web_rec                IN  HZ_CONTACT_POINT_V2PUB.web_rec_type,
   p_phone_cnt_point_id     IN  NUMBER,
   p_email_cnt_point_id     IN  NUMBER,
   p_url_cnt_point_id       IN  NUMBER,
   p_phone_obj_ver_num      IN  NUMBER,
   p_email_obj_ver_num      IN  NUMBER,
   p_url_obj_ver_num        IN  NUMBER,
   p_update_phone_flag      IN  VARCHAR2,
   p_update_email_flag      IN  VARCHAR2,
   p_update_url_flag        IN  VARCHAR2,
   x_phone_obj_ver_num      OUT NOCOPY NUMBER,
   x_email_obj_ver_num      OUT NOCOPY NUMBER,
   x_url_obj_ver_num        OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2 )
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'Update_ContactPoints';
   l_api_version            CONSTANT NUMBER := 1.0;

   -- the following are default records: --
   l_phone_update_rec       HZ_CONTACT_POINT_V2PUB.phone_rec_type
                               := CSD_PROCESS_PVT.get_phone_rec_type;
   l_email_update_rec       HZ_CONTACT_POINT_V2PUB.email_rec_type
                               := CSD_PROCESS_PVT.get_email_rec_type;
   l_web_update_rec         HZ_CONTACT_POINT_V2PUB.web_rec_type
                               := CSD_PROCESS_PVT.get_web_rec_type;
   l_edi_update_rec         HZ_CONTACT_POINT_V2PUB.edi_rec_type
                               := CSD_PROCESS_PVT.get_edi_rec_type;
   l_telex_update_rec       HZ_CONTACT_POINT_V2PUB.telex_rec_type
                               := CSD_PROCESS_PVT.get_telex_rec_type;
   l_contpt_update_rec      HZ_CONTACT_POINT_V2PUB.contact_point_rec_type
                               := CSD_PROCESS_PVT.get_contact_points_rec_type;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_ContactPoints_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_hz_phone_rec
                   ( p_phone_rec => p_phone_rec);
          csd_gen_utility_pvt.dump_hz_email_rec
                   ( p_email_rec => p_email_rec);
          csd_gen_utility_pvt.dump_hz_web_rec
                   ( p_web_rec => p_web_rec);
    END IF;

    x_phone_obj_ver_num:= p_phone_obj_ver_num;
    IF (p_update_phone_flag = 'Y') THEN
        l_contpt_update_rec.contact_point_type := 'PHONE';
        l_contpt_update_rec.owner_table_name   := 'HZ_PARTIES';
        l_contpt_update_rec.contact_point_id   := p_phone_cnt_point_id;

        HZ_CONTACT_POINT_V2PUB.Update_contact_point(
                          p_init_msg_list      => FND_API.G_FALSE,
                          p_contact_point_rec  => l_contpt_update_rec,
                          p_edi_rec            => l_edi_update_rec,
                          p_email_rec          => l_email_update_rec,
                          p_phone_rec          => p_phone_rec,
                          p_telex_rec          => l_telex_update_rec,
                          p_web_rec            => l_web_update_rec,
                          p_object_version_number => x_phone_obj_ver_num,
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data
                          );

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Update_contact_points phone failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    x_email_obj_ver_num := p_email_obj_ver_num;
    IF (p_update_email_flag = 'Y') THEN
        l_contpt_update_rec.contact_point_type := 'EMAIL';
        l_contpt_update_rec.owner_table_name   := 'HZ_PARTIES';
        l_contpt_update_rec.contact_point_id   := p_email_cnt_point_id;

        HZ_CONTACT_POINT_V2PUB.Update_contact_point(
                                p_init_msg_list      => FND_API.G_FALSE,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_contact_point_rec  => l_contpt_update_rec,
                                p_edi_rec            => l_edi_update_rec,
                                p_phone_rec          => l_phone_update_rec,
                                p_email_rec          => p_email_rec,
                                p_telex_rec          => l_telex_update_rec,
                                p_web_rec            => l_web_update_rec,
                                p_object_version_number => x_email_obj_ver_num
                                );

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Update_contact_points email failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    x_url_obj_ver_num := p_url_obj_ver_num;
    IF (p_update_url_flag = 'Y') THEN
        l_contpt_update_rec.contact_point_type := 'WEB';
        l_contpt_update_rec.owner_table_name   := 'HZ_PARTIES';
        l_contpt_update_rec.contact_point_id   := p_url_cnt_point_id;


        HZ_CONTACT_POINT_V2PUB.Update_contact_point(
                                p_init_msg_list      => FND_API.G_FALSE,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_contact_point_rec  => l_contpt_update_rec,
                                p_edi_rec            => l_edi_update_rec,
                                p_phone_rec          => l_phone_update_rec,
                                p_email_rec          => l_email_update_rec,
                                p_telex_rec          => l_telex_update_rec,
                                p_web_rec            => p_web_rec,
                                p_object_version_number => x_url_obj_ver_num
                                );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Update_contact_points url failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_ContactPoints_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          x_phone_obj_ver_num := p_phone_obj_ver_num;
          x_email_obj_ver_num := p_email_obj_ver_num;
          x_url_obj_ver_num   := p_url_obj_ver_num;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_ContactPoints_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_phone_obj_ver_num := p_phone_obj_ver_num;
          x_email_obj_ver_num := p_email_obj_ver_num;
          x_url_obj_ver_num   := p_url_obj_ver_num;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Update_ContactPoints_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_phone_obj_ver_num := p_phone_obj_ver_num;
          x_email_obj_ver_num := p_email_obj_ver_num;
          x_url_obj_ver_num   := p_url_obj_ver_num;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Update_ContactPoints;

/*----------------------------------------------------------------*/
/* procedure name: Update_AddressRecords                          */
/* description   : procedure used to update                       */
/*                 an address record in TCA                       */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_location_id                Location ID, if it already exists */
/* p_loc_rec                    Location                          */
/* p_addr_obj_ver_num           Last version of the location      */
/* p_site_obj_ver_num           Last version of the site          */
/* x_party_site_rec             Site                              */
/* x_addr_obj_ver_num           New Last version of the location  */
/* x_site_obj_ver_num           New Last version of the site      */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Update_AddressRecords
(
   p_api_version           IN  NUMBER,
   p_commit                IN  VARCHAR2 := fnd_api.g_false,
   p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
   p_validation_level      IN  NUMBER   := fnd_api.g_valid_level_full,
   p_location_id           IN  NUMBER := null,
   p_loc_rec               IN  CSD_PROCESS_PVT.address_rec_type,
   p_addr_obj_ver_num      IN  NUMBER,
   p_site_obj_ver_num      IN  NUMBER,
   x_party_site_rec        IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_rec_type,
   x_addr_obj_ver_num      OUT NOCOPY NUMBER,
   x_site_obj_ver_num      OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2 )
IS
   l_api_name              CONSTANT VARCHAR2(30) := 'Update_AddressRecords';
   l_api_version           CONSTANT NUMBER := 1.0;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_AddressRecords_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_address_rec
                   ( p_addr_rec => p_loc_rec);
          csd_gen_utility_pvt.dump_hz_party_site_rec
                   ( p_party_site_rec => x_party_site_rec);
    END IF;

    IF (p_location_id is not null) THEN
        -- Update location
        Update_Address (  p_api_version      => 1.0,
                          p_commit           => FND_API.G_FALSE,
                          p_init_msg_list    => FND_API.G_FALSE,
                          p_validation_level => p_validation_level,
                          p_address_rec      => p_loc_rec,
			              p_obj_ver_num      => p_addr_obj_ver_num,
					      x_obj_ver_num      => x_addr_obj_ver_num,
                          x_return_status    => x_return_status,
                          x_msg_count        => x_msg_count,
                          x_msg_data         => x_msg_data);
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Update_Address failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- Update party sites to make this address as the identifying address.
        x_party_site_rec.location_id  := p_location_id;
        x_site_obj_ver_num := p_site_obj_ver_num;
        HZ_PARTY_SITE_V2PUB.Update_Party_Site (
                          p_init_msg_list       => FND_API.G_FALSE,
                          p_party_site_rec      => x_party_site_rec,
                          p_object_version_number => x_site_obj_ver_num,
                          x_return_status       => x_return_status,
                          x_msg_count           => x_msg_count,
                          x_msg_data            => x_msg_data
                          );
        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            csd_gen_utility_pvt.ADD('Update_Party_Site failed ');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_AddressRecords_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_AddressRecords_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Update_AddressRecords_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Update_AddressRecords;

/*----------------------------------------------------------------*/
/* procedure name: Update_Address                                 */
/* description   : procedure used to update                       */
/*                 a location in TCA                              */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_address_rec                Location to create                */
/* p_obj_ver_num                Last version of the location      */
/*                              prior to calling this procedure   */
/* x_obj_ver_num                Last version of the location      */
/*                              after completing this procedure   */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Update_Address
(
   p_api_version      IN  NUMBER,
   p_commit           IN  VARCHAR2  := fnd_api.g_false,
   p_init_msg_list    IN  VARCHAR2  := fnd_api.g_false,
   p_validation_level IN  NUMBER   := fnd_api.g_valid_level_full,
   p_address_rec      IN  CSD_PROCESS_PVT.address_rec_type,
   p_obj_ver_num      IN  NUMBER,
   x_obj_ver_num      OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2)
IS
   l_api_name         CONSTANT      VARCHAR2(30) := 'Update_Address';
   l_api_version      CONSTANT      NUMBER := 1.0;
   -- swai: change to TCA v2
   -- l_location_rec                   HZ_LOCATION_PUB.location_rec_type;
   l_location_rec        HZ_LOCATION_V2PUB.location_rec_type;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_Address_Pvt;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Begin API Body
    --
    csd_gen_utility_pvt.dump_api_info ( p_pkg_name  => G_PKG_NAME,
                                        p_api_name  => l_api_name );
    IF l_debug > 5 THEN
          csd_gen_utility_pvt.dump_address_rec
                   ( p_addr_rec => p_address_rec);
    END IF;
    l_location_rec.location_id := p_address_rec.location_id;
    l_location_rec.address1 := p_address_rec.address1;
    l_location_rec.address2 := p_address_rec.address2;
    l_location_rec.address3 := p_address_rec.address3;
    l_location_rec.address4 := p_address_rec.address4;
    l_location_rec.city     := p_address_rec.city;
    l_location_rec.state    := p_address_rec.state;
    l_location_rec.postal_code := p_address_rec.postal_code;
    l_location_rec.province := p_address_rec.province;
    l_location_rec.county   := p_address_rec.county;
    l_location_rec.country  := p_address_rec.country;
    l_location_rec.language := p_address_rec.language;
    l_location_rec.position := p_address_rec.position;
    l_location_rec.address_key := p_address_rec.address_key;
    l_location_rec.postal_plus4_code := p_address_rec.postal_plus4_code;
    l_location_rec.position := p_address_rec.position;
    l_location_rec.delivery_point_code := p_address_rec.delivery_point_code;
    l_location_rec.location_directions := p_address_rec.location_directions;
    -- l_location_rec.address_error_code := p_address_rec.address_error_code;
    l_location_rec.clli_code := p_address_rec.clli_code;
    l_location_rec.short_description := p_address_rec.short_description;
    l_location_rec.description := p_address_rec.description;
    l_location_rec.sales_tax_geocode := p_address_rec.sales_tax_geocode;
    l_location_rec.sales_tax_inside_city_limits := p_address_rec.sales_tax_inside_city_limits;
    l_location_rec.address_effective_date := p_address_rec.address_effective_date;
    l_location_rec.address_expiration_date := p_address_rec.address_expiration_date;
    l_location_rec.address_style := p_address_rec.address_style;
    -- swai: unused fields in TCA, but still avail in v2 (per bug #2863096)
    l_location_rec.po_box_number := p_address_rec.po_box_number;
    l_location_rec.street   := p_address_rec.street;
    l_location_rec.house_number  := p_address_rec.house_number;
    l_location_rec.street_suffix := p_address_rec.street_suffix;
    l_location_rec.street_number := p_address_rec.street_number;
    l_location_rec.floor := p_address_rec.floor;
    l_location_rec.suite := p_address_rec.suite;
    -- swai: new TCA V2 fields --
    l_location_rec.timezone_id := p_address_rec.timezone_id;
    l_location_rec.created_by_module := p_address_rec.created_by_module;
    l_location_rec.application_id := p_address_rec.application_id;
    l_location_rec.actual_content_source := p_address_rec.actual_content_source;
    l_location_rec.delivery_point_code := p_address_rec.delivery_point_code;
    -- end new TCA V2 fields --

    -- x_last_upd_date := p_last_upd_date;
    x_obj_ver_num := p_obj_ver_num;

    -- swai: use new TCA v2 API
    HZ_LOCATION_V2PUB.update_location (
                          p_init_msg_list     => FND_API.G_FALSE,
                          p_location_rec      => l_location_rec,
                          p_object_version_number  => x_obj_ver_num,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data);

    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        csd_gen_utility_pvt.ADD('update_location failed ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --
    -- End API Body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Standard call to get message count and IF count is  get message info.
    FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                               p_data   =>  x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Address_Pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Address_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Update_Address_Pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Update_Address;


END CSD_PARTIES_PVT ;

/
