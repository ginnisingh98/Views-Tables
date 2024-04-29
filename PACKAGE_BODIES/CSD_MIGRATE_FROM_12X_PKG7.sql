--------------------------------------------------------
--  DDL for Package Body CSD_MIGRATE_FROM_12X_PKG7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MIGRATE_FROM_12X_PKG7" AS
/* $Header: csdmig7b.pls 120.2 2008/04/25 09:53:32 subhat noship $ */

/* Procedure Name: csd_isupport_ssearch_mig7                            */
/* This procedure updates the existing csd_ro_savedsearches table to    */
/* support the iSupport multiparty enhancement. The party_id for the    */
/* existing records will be updated to default party_id corresponding to*/
/* user_id.                                                             */
/* @param. None                                                         */

procedure CSD_ISUPPORT_SSEARCH_MIG7 is

-- collection to hold the user_id, party_id
--usr_party_tbl user_party_id_tbl;
-- bug#6993441 subhat, use two seperate arrays.
l_user_id_tbl user_id_tbl;
l_party_id_tbl party_id_tbl;

-- end bug#6993441 subhat

begin
   if( FND_LOG.LEVEL_PROCEDURE >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'CSD.PLSQL.CSD_Migrate_From_12X_PKG7.csd_isupport_ssearch_mig7',
                          'Before fetching the party for user_id');
   end if;

  -- make use of an implicit cursor to get the customer_id's for the user_ids
  -- in csd_ro_saved_searches table.
  -- The use of implicit cursor may not be a great idea if the savedsearches table
  -- has very huge data (eg. more than 10000 rows, which is highly unlikely)
  -- bug#6993441 subhat
  begin
    select user_id,customer_id
    bulk collect into l_user_id_tbl,l_party_id_tbl
    from fnd_user
    where user_id in ( select distinct user_id from
                     csd_ro_savedsearches where party_id is null )
    and customer_id is not null;
    -- important: Select bulk collect into will never raise no_data_found
    -- no_data_found is raised only when select into is done. We need to explicitly
    -- raise no_data_found if we really want it.
    if l_user_id_tbl.COUNT <= 0 then
          -- there is possibly no user_id's which have party_id as null in
          -- csd_ro_savedsearches table. Literally no need for the update sql to run.
          -- return control to the sql script.
     return;
    end if;
   end;
   -- update all the null party_id's

   if( FND_LOG.LEVEL_PROCEDURE >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                          'CSD.PLSQL.CSD_Migrate_From_12X_PKG7.csd_isupport_ssearch_mig7',
                          'Before bulk update of CSD_RO_SAVEDSEARCHES table');
   end if;

 --forall i in 1 ..usr_party_tbl.COUNT
 FORALL i IN 1 ..l_user_id_tbl.COUNT
     update csd_ro_savedsearches set party_id = l_party_id_tbl(i) --usr_party_tbl(i).party_id
            where user_id = l_user_id_tbl(i) --usr_party_tbl(i).user_id
            and party_id is null;

 if( FND_LOG.LEVEL_PROCEDURE >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                          'CSD.PLSQL.CSD_Migrate_From_12X_PKG7.csd_isupport_ssearch_mig7',
                          'After bulk update of CSD_RO_SAVEDSEARCHES table');
 end if;

commit work;

end CSD_ISUPPORT_SSEARCH_MIG7;

end CSD_MIGRATE_FROM_12X_PKG7;

/
