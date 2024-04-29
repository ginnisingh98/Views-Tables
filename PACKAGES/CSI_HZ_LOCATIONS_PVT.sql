--------------------------------------------------------
--  DDL for Package CSI_HZ_LOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_HZ_LOCATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: csivhzls.pls 120.2 2005/12/09 16:32:10 rmamidip noship $ */
-- start of comments
-- PACKAGE name     : CSI_HZ_LOCATIONS_PVT
-- purpose          :
-- history          :
-- note             :
-- END of comments

-- default NUMBER of records fetch per call
g_default_num_rec_fetch  NUMBER := 30;

--+=================================================================+
--| Create_location procedure written for calling it from CSI forms |
--| This procedure validates for unique clli_code and calls         |
--| hz_location_v2pub.create_location                                 |
--+=================================================================+

PROCEDURE create_location(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2   := fnd_api.g_false,
    p_init_msg_list              IN   VARCHAR2   := fnd_api.g_false,
    p_validation_level           IN   NUMBER     := fnd_api.g_valid_level_full,
    p_country                    IN   VARCHAR2,
    p_address1                   IN   VARCHAR2,
    p_address2                   IN   VARCHAR2,
    p_address3                   IN   VARCHAR2,
    p_address4                   IN   VARCHAR2,
    p_city                       IN   VARCHAR2,
    p_postal_code                IN   VARCHAR2,
    p_state                      IN   VARCHAR2,
    p_province                   IN   VARCHAR2,
    p_county                     IN   VARCHAR2,
    p_clli_code                  IN   VARCHAR2,
    p_description                IN   VARCHAR2,
    p_last_update_date           IN   DATE    ,
    p_last_updated_by            IN   NUMBER  ,
    p_creation_date              IN   DATE    ,
    p_created_by                 IN   NUMBER  ,
    p_created_by_module          IN   VARCHAR2,
    x_location_id                OUT NOCOPY  NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    ) ;

--+=================================================================+
--| Update_location procedure written for calling it from CSI forms |
--| This procedure validates for unique clli_code and calls         |
--| hz_location_v2pub.update_location                                 |
--+=================================================================+

PROCEDURE update_location(
    p_api_version                IN   NUMBER,
    p_commit                     IN   VARCHAR2   := fnd_api.g_false,
    p_init_msg_list              IN   VARCHAR2   := fnd_api.g_false,
    p_validation_level           IN   NUMBER     := fnd_api.g_valid_level_full,
    p_location_id                IN   NUMBER,
    p_country                    IN   VARCHAR2,
    p_address1                   IN   VARCHAR2,
    p_address2                   IN   VARCHAR2,
    p_address3                   IN   VARCHAR2,
    p_address4                   IN   VARCHAR2,
    p_city                       IN   VARCHAR2,
    p_postal_code                IN   VARCHAR2,
    p_state                      IN   VARCHAR2,
    p_province                   IN   VARCHAR2,
    p_county                     IN   VARCHAR2,
    p_clli_code                  IN   VARCHAR2,
    p_description                IN   VARCHAR2,
    p_last_update_date           IN   DATE    ,
    p_last_updated_by            IN   NUMBER  ,
    p_creation_date              IN   DATE    ,
    p_created_by                 IN   NUMBER  ,
    p_created_by_module          IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    ) ;

--+=================================================================+
--| Lock_location procedure written for calling it from CSI forms   |
--+=================================================================+

PROCEDURE Lock_location(
    p_location_id                   NUMBER  ,
    p_last_update_date              DATE    ,
    p_last_updated_by               NUMBER  ,
    p_creation_date                 DATE    ,
    p_created_by                    NUMBER  ,
    p_country                       VARCHAR2,
    p_address1                      VARCHAR2,
    p_address2                      VARCHAR2,
    p_address3                      VARCHAR2,
    p_address4                      VARCHAR2,
    p_city                          VARCHAR2,
    p_postal_code                   VARCHAR2,
    p_state                         VARCHAR2,
    p_province                      VARCHAR2,
    p_county                        VARCHAR2,
    p_clli_code                     VARCHAR2,
    p_description                   VARCHAR2,
    p_created_by_module             VARCHAR2
    ) ;


END CSI_HZ_LOCATIONS_PVT;

 

/
