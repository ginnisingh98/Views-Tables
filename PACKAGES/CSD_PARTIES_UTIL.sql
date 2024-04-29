--------------------------------------------------------
--  DDL for Package CSD_PARTIES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_PARTIES_UTIL" AUTHID CURRENT_USER AS
/* $Header: csdvptus.pls 115.2 2002/12/03 20:37:57 sangigup noship $ */



/*----------------------------------------------------------------*/
/* procedure name: Get_EmailDetails                               */
/* description   : Gets email contact point for a given party     */
/*                 This procedure accepts party id and returns    */
/*                 the email contact point id and last updated    */
/*                 date for that party.                           */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_party_id                   Party ID to get email details for */
/* x_email_cnt_point_id         Email Contact Point ID            */
/* x_email_last_update_date     Last Updated Date for Contact Pt  */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_EmailDetails
(
   p_api_version            IN  NUMBER,
   p_commit                 IN  VARCHAR2 := fnd_api.g_false,
   p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false,
   p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full,
   p_party_id               IN  NUMBER,
   x_email_cnt_point_id     OUT NOCOPY NUMBER,
   x_email_last_update_date OUT NOCOPY DATE,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2 );

/*----------------------------------------------------------------*/
/* procedure name: Get_AddrDetails                                */
/* description   : Gets address location and site for a party     */
/*                 This procedure accepts party id and returns    */
/*                 the address location and site ids and last     */
/*                 updated date of both items for that party.     */
/*                                                                */
/* p_api_version                 Standard IN param                */
/* p_commit                      Standard IN param                */
/* p_init_msg_list               Standard IN param                */
/* p_validation_level            Standard IN param                */
/* p_party_id                    Party ID to get addr details for */
/* x_addr_location_id            Location ID for party            */
/* x_party_site_id               Site ID for location             */
/* x_addr_last_update_date       Last updated date for location   */
/* x_party_site_last_update_date Last updated date for site       */
/* x_return_status               Standard OUT param               */
/* x_msg_count                   Standard OUT param               */
/* x_msg_data                    Standard OUT param               */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_AddrDetails
(
   p_api_version                 IN  NUMBER,
   p_commit                      IN  VARCHAR2 := fnd_api.g_false,
   p_init_msg_list               IN  VARCHAR2 := fnd_api.g_false,
   p_validation_level            IN  NUMBER   := fnd_api.g_valid_level_full,
   p_party_id                    IN  NUMBER,
   x_addr_location_id            OUT NOCOPY NUMBER,
   x_party_site_id               OUT NOCOPY NUMBER,
   x_addr_last_update_date       OUT NOCOPY DATE,
   x_party_site_last_update_date OUT NOCOPY DATE,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2 );


/*----------------------------------------------------------------*/
/* procedure name: Get_PhoneDetails                               */
/* description   : This procedure accepts phone contact point id  */
/*                 and returns the last updated for that contact  */
/*                 point.                                         */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_phone_cnt_point_id         Phone Contact Point ID            */
/* x_phone_last_update_date     Last Updated Date for Contact Pt  */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_PhoneDetails
(
   p_api_version            IN  NUMBER,
   p_commit                 IN  VARCHAR2 := fnd_api.g_false,
   p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false,
   p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full,
   p_phone_cnt_point_id     IN  NUMBER,
   x_phone_last_update_date OUT NOCOPY DATE,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2 );


/*----------------------------------------------------------------*/
/* procedure name: Get_PartyDetails                               */
/* description   : This procedure accepts TCA party id and        */
/*                 returns the last updated for that party.       */
/*                                                                */
/* p_api_version                Standard IN param                 */
/* p_commit                     Standard IN param                 */
/* p_init_msg_list              Standard IN param                 */
/* p_validation_level           Standard IN param                 */
/* p_party_id                   Party ID to get details for       */
/* x_last_update_date           Last Updated Date for Party       */
/* x_return_status              Standard OUT param                */
/* x_msg_count                  Standard OUT param                */
/* x_msg_data                   Standard OUT param                */
/*                                                                */
/*----------------------------------------------------------------*/
PROCEDURE Get_PartyDetails
(
   p_api_version            IN  NUMBER,
   p_commit                 IN  VARCHAR2 := fnd_api.g_false,
   p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false,
   p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full,
   p_party_id               IN  NUMBER,
   x_last_update_date       OUT NOCOPY DATE,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2 );


END CSD_PARTIES_UTIL ;

 

/
