--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_CONTACT_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_CONTACT_MAPPINGS_PKG" AS
/* $Header: cacvscmb.pls 120.1 2005/07/02 02:20:21 appldev noship $ */

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
    )
    IS
        CURSOR c_rowid IS
        SELECT ROWID
          FROM cac_sync_contact_mappings
         WHERE sync_contact_mapping_id = x_sync_contact_mapping_id;
    BEGIN
        INSERT INTO cac_sync_contact_mappings
        (sync_contact_mapping_id
        ,contact_party_id
        ,org_party_id
        ,person_party_id
        ,party_site_id
        ,work_contact_point_id
        ,home_contact_point_id
        ,fax_contact_point_id
        ,cell_contact_point_id
        ,pager_contact_point_id
        ,email_contact_point_id
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        )
        VALUES
        (x_sync_contact_mapping_id
        ,x_contact_party_id
        ,x_org_party_id
        ,x_person_party_id
        ,x_party_site_id
        ,x_work_contact_point_id
        ,x_home_contact_point_id
        ,x_fax_contact_point_id
        ,x_cell_contact_point_id
        ,x_pager_contact_point_id
        ,x_email_contact_point_id
        ,x_created_by
        ,x_creation_date
        ,x_last_updated_by
        ,x_last_update_date
        ,x_last_update_login
        );

        OPEN c_rowid;
        FETCH c_rowid INTO x_rowid;

        IF c_rowid%NOTFOUND THEN
           CLOSE c_rowid;
           RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_rowid;

    END INSERT_ROW;

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
    )
    IS
    BEGIN
        UPDATE cac_sync_contact_mappings
        SET contact_party_id        = x_contact_party_id
          , org_party_id            = x_org_party_id
          , person_party_id         = x_person_party_id
          , party_site_id           = x_party_site_id
          , work_contact_point_id   = x_work_contact_point_id
          , home_contact_point_id   = x_home_contact_point_id
          , fax_contact_point_id    = x_fax_contact_point_id
          , cell_contact_point_id   = x_cell_contact_point_id
          , pager_contact_point_id  = x_pager_contact_point_id
          , email_contact_point_id  = x_email_contact_point_id
          , last_updated_by         = x_last_updated_by
          , last_update_date        = x_last_update_date
          , last_update_login       = x_last_update_login
        WHERE sync_contact_mapping_id = x_sync_contact_mapping_id;

        IF SQL%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;

    END UPDATE_ROW;

    PROCEDURE DELETE_ROW(x_sync_contact_mapping_id IN NUMBER)
    IS
    BEGIN

        DELETE cac_sync_contact_mappings
        WHERE sync_contact_mapping_id = x_sync_contact_mapping_id;

        IF SQL%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;

    END DELETE_ROW;

end CAC_SYNC_CONTACT_MAPPINGS_PKG;

/
