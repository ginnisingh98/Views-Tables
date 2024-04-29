--------------------------------------------------------
--  DDL for Package CAC_SYNC_CONTACT_MAPPINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_CONTACT_MAPPINGS_PVT" AUTHID CURRENT_USER AS
/* $Header: cacvscvs.pls 120.1 2005/07/02 02:21:03 appldev noship $ */


    PROCEDURE CREATE_CONTACT_MAPPING
    ( p_api_version             IN  NUMBER   DEFAULT 1.0
    , p_init_msg_list           IN  VARCHAR2 DEFAULT NULL
    , p_commit                  IN  VARCHAR2 DEFAULT NULL
    , p_sync_contact_mapping_id IN  NUMBER
    , p_contact_party_id        IN  NUMBER
    , p_org_party_id            IN  NUMBER
    , p_person_party_id         IN  NUMBER
    , p_party_site_id           IN  NUMBER
    , p_work_contact_point_id   IN  NUMBER
    , p_home_contact_point_id   IN  NUMBER
    , p_fax_contact_point_id    IN  NUMBER
    , p_cell_contact_point_id   IN  NUMBER
    , p_pager_contact_point_id  IN  NUMBER
    , p_email_contact_point_id  IN  NUMBER
    , p_last_sync_date          IN  DATE DEFAULT NULL
    , x_sync_contact_mapping_id OUT NOCOPY NUMBER
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    );

    PROCEDURE UPDATE_CONTACT_MAPPING
    ( p_api_version             IN  NUMBER   DEFAULT 1.0
    , p_init_msg_list           IN  VARCHAR2 DEFAULT NULL
    , p_commit                  IN  VARCHAR2 DEFAULT NULL
    , p_sync_contact_mapping_id IN  NUMBER   DEFAULT NULL
    , p_contact_party_id        IN  NUMBER   DEFAULT NULL
    , p_org_party_id            IN  NUMBER   DEFAULT NULL
    , p_person_party_id         IN  NUMBER   DEFAULT NULL
    , p_party_site_id           IN  NUMBER   DEFAULT NULL
    , p_work_contact_point_id   IN  NUMBER   DEFAULT NULL
    , p_home_contact_point_id   IN  NUMBER   DEFAULT NULL
    , p_fax_contact_point_id    IN  NUMBER   DEFAULT NULL
    , p_cell_contact_point_id   IN  NUMBER   DEFAULT NULL
    , p_pager_contact_point_id  IN  NUMBER   DEFAULT NULL
    , p_email_contact_point_id  IN  NUMBER   DEFAULT NULL
    , p_last_sync_date          IN  DATE     DEFAULT NULL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    );

    PROCEDURE DELETE_CONTACT_MAPPING
    ( p_api_version             IN  NUMBER   DEFAULT 1.0
    , p_init_msg_list           IN  VARCHAR2 DEFAULT NULL
    , p_commit                  IN  VARCHAR2 DEFAULT NULL
    , p_sync_contact_mapping_id IN  NUMBER   DEFAULT NULL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    );

END CAC_SYNC_CONTACT_MAPPINGS_PVT;

 

/
