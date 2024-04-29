--------------------------------------------------------
--  DDL for Package CAC_SYNC_CONTACT_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_CONTACT_MAPPINGS_PKG" AUTHID CURRENT_USER AS
/* $Header: cacvscms.pls 120.1 2005/07/02 02:20:25 appldev noship $ */

    PROCEDURE INSERT_ROW
    ( x_rowid                   IN OUT NOCOPY  VARCHAR2
    , x_sync_contact_mapping_id IN  NUMBER
    , x_contact_party_id        IN  NUMBER
    , x_org_party_id            IN  NUMBER
    , x_person_party_id         IN  NUMBER
    , x_party_site_id           IN  NUMBER
    , x_work_contact_point_id   IN  NUMBER
    , x_home_contact_point_id   IN  NUMBER
    , x_fax_contact_point_id    IN  NUMBER
    , x_cell_contact_point_id   IN  NUMBER
    , x_pager_contact_point_id  IN  NUMBER
    , x_email_contact_point_id  IN  NUMBER
    , x_created_by              IN  NUMBER
    , x_creation_date           IN  DATE
    , x_last_updated_by         IN  NUMBER
    , x_last_update_date        IN  DATE
    , x_last_update_login       IN  NUMBER
    );

    PROCEDURE UPDATE_ROW
    ( x_sync_contact_mapping_id IN  NUMBER
    , x_contact_party_id        IN  NUMBER
    , x_org_party_id            IN  NUMBER
    , x_person_party_id         IN  NUMBER
    , x_party_site_id           IN  NUMBER
    , x_work_contact_point_id   IN  NUMBER
    , x_home_contact_point_id   IN  NUMBER
    , x_fax_contact_point_id    IN  NUMBER
    , x_cell_contact_point_id   IN  NUMBER
    , x_pager_contact_point_id  IN  NUMBER
    , x_email_contact_point_id  IN  NUMBER
    , x_last_updated_by         IN  NUMBER
    , x_last_update_date        IN  DATE
    , x_last_update_login       IN  NUMBER
    );

    PROCEDURE DELETE_ROW(x_sync_contact_mapping_id IN NUMBER);

end CAC_SYNC_CONTACT_MAPPINGS_PKG;

 

/
