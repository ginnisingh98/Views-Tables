--------------------------------------------------------
--  DDL for Package CSD_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_PARTIES_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvptys.pls 120.1 2005/08/17 15:09:22 swai noship $ */


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
   p_bill_location_id        IN  NUMBER default null,
   p_ship_loc_rec            IN  CSD_PROCESS_PVT.address_rec_type,
   p_ship_location_id        IN  NUMBER default null,
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
   x_msg_data                OUT NOCOPY VARCHAR2 );

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
/* x_party_number               Party Number gnerated             */
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
   x_msg_data             OUT NOCOPY VARCHAR2 );


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
/* x_party_number               Party Number gnerated             */
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
   x_msg_data             OUT NOCOPY VARCHAR2 );


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
/* x_party_number               Party Number gnerated             */
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
   x_msg_data             OUT NOCOPY VARCHAR2 );


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
   x_msg_data             OUT NOCOPY VARCHAR2 );


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
   x_msg_data             OUT NOCOPY VARCHAR2 );


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
   x_msg_data          OUT NOCOPY VARCHAR2 );


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
   p_location_id        IN  NUMBER DEFAULT NULL,
   x_party_site_rec     IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_rec_type,
   x_party_site_use_rec IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_use_rec_type,
   x_location_id        OUT NOCOPY NUMBER,
   x_party_site_id      OUT NOCOPY NUMBER,
   x_party_site_number  OUT NOCOPY NUMBER,
   x_party_site_use_id  OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2 );


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
   x_msg_data           OUT NOCOPY VARCHAR2 );


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
   x_msg_data           OUT NOCOPY VARCHAR2 );


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
   x_msg_data             OUT NOCOPY VARCHAR2 );


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
   x_msg_data             OUT NOCOPY VARCHAR2 );


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
/*                              The following fields must be set  */
/*                              and are non-updatable:            */
/*                              party_rec.party_id                */
/*                              party_rec.party_number            */
/*                              party_rec.status                  */
/*                              party_rec.orig_system_reference   */
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
   x_msg_data             OUT NOCOPY VARCHAR2 );

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
   x_msg_data           OUT NOCOPY VARCHAR2 );

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
   x_msg_data               OUT NOCOPY VARCHAR2 );


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
   p_location_id           IN  NUMBER default null,
   p_loc_rec               IN  CSD_PROCESS_PVT.address_rec_type,
   p_addr_obj_ver_num      IN  NUMBER,
   p_site_obj_ver_num      IN  NUMBER,
   x_party_site_rec        IN OUT NOCOPY HZ_PARTY_SITE_V2PUB.party_site_rec_type,
   x_addr_obj_ver_num      OUT NOCOPY NUMBER,
   x_site_obj_ver_num      OUT NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2 );

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
/* p_obj_ver_num                Last version num  of the location */
/*                              prior to calling this procedure   */
/* x_obj_ver_num                Last version num  of the location */
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
   x_msg_data         OUT NOCOPY VARCHAR2);


END CSD_PARTIES_PVT ;
 

/
