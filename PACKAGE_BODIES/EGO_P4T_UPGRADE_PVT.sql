--------------------------------------------------------
--  DDL for Package Body EGO_P4T_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_P4T_UPGRADE_PVT" AS
/* $Header: EGOP4TUB.pls 120.1.12010000.4 2009/04/29 10:15:18 chechand noship $ */

  PROCEDURE upgrade_to_pim4telco (start_effective_date IN DATE)
  IS
    cursor non_ver_iccs IS
      select a.item_catalog_group_id as IccID from  mtl_item_catalog_groups_b a
      where a.item_catalog_group_id not in
      (SELECT DISTINCT item_catalog_group_id FROM EGO_MTL_CATALOG_GRP_VERS_B);

     profile_value varchar2(1) := fnd_profile.value('EGO_ENABLE_P4T');
     draft_str VARCHAR2(2000);
     default_ver_str varchar2(2000);

    BEGIN
    if profile_value <> 'Y' then
      return;
    end if;

    SELECT message_text into draft_str
    FROM fnd_new_messages
    WHERE
    application_id = (SELECT application_id
                      FROM fnd_application
                      WHERE application_short_name = 'EGO') AND
    message_name = 'EGO_ICC_DRAFT_VERSION' AND
    language_code = USERENV('LANG') ;

    SELECT message_text into default_ver_str
    FROM fnd_new_messages
    WHERE
    application_id = (SELECT application_id
                      FROM fnd_application
                      WHERE application_short_name = 'EGO') AND
    message_name = 'EGO_ICC_DEFAULT_VERS' AND
    language_code = USERENV('LANG')  ;

    for rec in non_ver_iccs loop
        insert into EGO_MTL_CATALOG_GRP_VERS_B
          (item_catalog_group_id,
          version_seq_id,
          version_description,
          start_active_date,
          end_active_date,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        values
          (rec.IccID,
          0,
          draft_str,
          null,
          null,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.LOGIN_ID);

        insert into EGO_MTL_CATALOG_GRP_VERS_B
          (item_catalog_group_id,
          version_seq_id,
          version_description,
          start_active_date,
          end_active_date,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        values
          (rec.IccID,
          1,
          default_ver_str,
          nvl(start_effective_date, sysdate),
          null,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.LOGIN_ID);

    end loop;
    commit;
    end upgrade_to_pim4telco;

END ego_p4t_upgrade_pvt;

/
