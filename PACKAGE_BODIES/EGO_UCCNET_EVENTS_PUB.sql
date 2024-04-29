--------------------------------------------------------
--  DDL for Package Body EGO_UCCNET_EVENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_UCCNET_EVENTS_PUB" AS
/* $Header: EGOPGTNB.pls 120.1 2005/12/05 01:16:44 dsakalle noship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOPGTNB.pls';
G_PKG_NAME        CONSTANT  VARCHAR2(30)  :=  'EGO_UCCNET_EVENTS_PUB';


PROCEDURE Update_Event_Disposition (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_cln_id                       IN      NUMBER
        ,p_disposition_code             IN      VARCHAR2
        ,p_disposition_date             IN      DATE
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS

BEGIN

    EGO_UCCNET_EVENTS_PVT.Update_Event_Disposition
    (
      p_api_version                      => p_api_version
     ,p_commit                           => p_commit
     ,p_init_msg_list                    => p_init_msg_list
     ,p_cln_id                           => p_cln_id
     ,p_disposition_code                 => p_disposition_code
     ,p_disposition_date                 => p_disposition_date
     ,x_return_status                    => x_return_status
     ,x_msg_count                        => x_msg_count
     ,x_msg_data                         => x_msg_data
    );

END Update_Event_Disposition;


PROCEDURE Set_Collaboration_Id (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_batch_id                     IN      NUMBER
        ,p_subbatch_id                  IN      NUMBER
        ,p_top_gtin                     IN      NUMBER
        ,p_cln_id                       IN      NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS

BEGIN

    EGO_UCCNET_EVENTS_PVT.Set_Collaboration_Id
    (
       p_api_version                    => p_api_version
      ,p_commit                         => p_commit
      ,p_init_msg_list                  => p_init_msg_list
      ,p_batch_id                       => p_batch_id
      ,p_subbatch_id                    => p_subbatch_id
      ,p_top_gtin                       => p_top_gtin
      ,p_cln_id                         => p_cln_id
      ,x_return_status                  => x_return_status
      ,x_msg_count                      => x_msg_count
      ,x_msg_data                       => x_msg_data
    );

END Set_Collaboration_Id;


PROCEDURE Add_Additional_CIC_Info (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_cln_id                       IN      NUMBER
        ,p_cic_code                     IN      VARCHAR2
        ,p_cic_description              IN      VARCHAR2
        ,p_cic_action_needed            IN      VARCHAR2
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
                                  ) IS
BEGIN
     EGO_UCCNET_EVENTS_PVT.Add_Additional_CIC_Info
    (
       p_api_version                    => p_api_version
      ,p_commit                         => p_commit
      ,p_init_msg_list                  => p_init_msg_list
      ,p_cln_id                         => p_cln_id
      ,p_cic_code                       => p_cic_code
      ,p_cic_description                => p_cic_description
      ,p_cic_action_needed              => p_cic_action_needed
      ,x_return_status                  => x_return_status
      ,x_msg_count                      => x_msg_count
      ,x_msg_data                       => x_msg_data
    );
END Add_Additional_CIC_info;

END EGO_UCCNET_EVENTS_PUB;

/
