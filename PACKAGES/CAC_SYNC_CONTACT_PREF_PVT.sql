--------------------------------------------------------
--  DDL for Package CAC_SYNC_CONTACT_PREF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_CONTACT_PREF_PVT" AUTHID CURRENT_USER AS
/* $Header: cacvscps.pls 120.1 2005/07/02 02:20:32 appldev noship $ */


    PROCEDURE CREATE_CONTACT_PREFERENCE
    ( p_init_msg_list           IN  VARCHAR2 DEFAULT NULL
    , p_party_id                IN  NUMBER
    , p_category                IN  VARCHAR2
    , p_preference_code         IN  VARCHAR2
    , p_module                  IN  VARCHAR2
    , p_value_number            IN  NUMBER
    , p_last_sync_date          IN  DATE     DEFAULT NULL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    );

    PROCEDURE DELETE_CONTACT_PREFERENCE
    ( p_init_msg_list           IN  VARCHAR2 DEFAULT NULL
    , p_party_id                IN  NUMBER
    , p_category                IN  VARCHAR2
    , p_preference_code         IN  VARCHAR2
    , p_value_number            IN  NUMBER
    , p_object_version_number   IN  NUMBER
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    );

END CAC_SYNC_CONTACT_PREF_PVT;

 

/
