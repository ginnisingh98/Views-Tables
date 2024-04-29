--------------------------------------------------------
--  DDL for Package Body CSD_PARTIES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_PARTIES_UTIL" AS
/* $Header: csdvptub.pls 115.3 2002/12/03 20:34:51 sangigup noship $ */
--
-- Package name     : CSD_PARTIES_UTIL
-- Purpose          : This package contains the utilities for managing
--                    TCA parties in Depot Repair.
-- History          :
-- Version       Date       Name        Description
-- 115.9         10/20/02   swai       Created.


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_PARTIES_UTIL';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdvptub.pls';



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
   x_msg_data               OUT NOCOPY VARCHAR2 )
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'Get_EmailDetails';
   l_api_version            CONSTANT NUMBER := 1.0;
   l_party_id               NUMBER := p_party_id;

   CURSOR get_email_details IS
       SELECT contact_point_id,
              last_update_date
       FROM   hz_contact_points
       WHERE  owner_table_id = l_party_id
       AND    owner_table_name = 'HZ_PARTIES'
       AND    contact_point_type='EMAIL'
       AND    primary_flag='Y' ;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_EmailDetails_Utl;

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
    FOR get_email_details_rec IN get_email_details LOOP
          x_email_cnt_point_id:=get_email_details_rec.contact_point_id;
          x_email_last_update_date:=get_email_details_rec.last_update_date;
    END LOOP;

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
          ROLLBACK TO Get_EmailDetails_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_EmailDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_EmailDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_EmailDetails;


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
   x_msg_data                    OUT NOCOPY VARCHAR2 )
IS
   l_api_name          CONSTANT VARCHAR2(30) := 'Get_AddrDetails';
   l_api_version       CONSTANT NUMBER := 1.0;
   l_party_id          NUMBER := p_party_id;

   CURSOR get_address_details IS
       SELECT loc.location_id,
              loc.last_update_date,
              sites.party_site_id,
              sites.last_update_date sites_last_update_date
       FROM   hz_party_sites sites, hz_locations loc
       WHERE  sites.party_id  = l_party_id
       AND    loc.location_id = sites.location_id
       AND    sites.identifying_address_flag='Y' ;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_AddrDetails_Utl;

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
    FOR get_address_details_rec IN get_address_details LOOP
       x_party_site_id:=get_address_details_rec.party_site_id;
       x_addr_location_id:=get_address_details_rec.location_id;
       x_party_site_last_update_date:=get_address_details_rec.sites_last_update_date;
       x_addr_last_update_date:=get_address_details_rec.last_update_date;
    END LOOP;

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
          ROLLBACK TO Get_AddrDetails_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_AddrDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_AddrDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_AddrDetails;


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
   x_msg_data               OUT NOCOPY VARCHAR2 )
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'Get_PhoneDetails';
   l_api_version            CONSTANT NUMBER := 1.0;
   l_phone_cnt_point_id     NUMBER := p_phone_cnt_point_id;

   CURSOR get_phone_details IS
      SELECT LAST_UPDATE_DATE
      FROM   HZ_CONTACT_POINTS
      WHERE  CONTACT_POINT_ID = l_phone_cnt_point_id;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_PhoneDetails_Utl;

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
    FOR get_phone_details_rec IN get_phone_details LOOP
        x_phone_last_update_date:=get_phone_details_rec.last_update_date;
    END LOOP;

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
          ROLLBACK TO Get_PhoneDetails_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_PhoneDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_PhoneDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_PhoneDetails;


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
   x_msg_data               OUT NOCOPY VARCHAR2 )
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'Get_PartyDetails';
   l_api_version            CONSTANT NUMBER := 1.0;
   l_curr_party_id          NUMBER := p_party_id;
   CURSOR get_party_details IS
      SELECT LAST_UPDATE_DATE
      FROM   HZ_PARTIES
      WHERE  PARTY_ID=l_curr_party_id;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Get_PartyDetails_Utl;

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
    FOR get_party_details_rec IN get_party_details LOOP
           x_last_update_date:=get_party_details_rec.last_update_date;
    END LOOP;


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
          ROLLBACK TO Get_PartyDetails_Utl;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Get_PartyDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          ROLLBACK TO Get_PartyDetails_Utl;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
                                       l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get (p_count  =>  x_msg_count,
                                     p_data   =>  x_msg_data );
END Get_PartyDetails;



END CSD_PARTIES_UTIL ;

/
