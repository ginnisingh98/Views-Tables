--------------------------------------------------------
--  DDL for Package CSD_MIGRATE_FROM_12X_PKG7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MIGRATE_FROM_12X_PKG7" AUTHID CURRENT_USER AS
/* $Header: csdmig7s.pls 120.3 2008/04/25 09:53:05 subhat noship $ */

/* This record type holds the party_id's corresponding to the user_id   */

/*TYPE user_party_id_rec is record (
user_Id  number(15),
party_Id number(15) );

-- table type corresponding to this record.

--type user_party_id_tbl is table of user_party_id_rec index by binary_integer; */

-- bug#6993441 subhat
-- Associative arrays are not allowed withing forall statement prior 11g
-- two different arrays to hold userid and partyid

TYPE user_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE party_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- end bug#6993441 subhat

/* Procedure Name: csd_isupport_ssearch_mig7                            */
/* This procedure updates the existing csd_ro_savedsearches table to    */
/* support the iSupport multiparty enhancement. The party_id for the    */
/* existing records will be updated to default party_id corresponding to*/
/* user_id.                                                             */
/* @param. None                                                         */

PROCEDURE CSD_ISUPPORT_SSEARCH_MIG7;

END CSD_MIGRATE_FROM_12X_PKG7;

/
