--------------------------------------------------------
--  DDL for Package Body IEX_TERR_ASSIGNMENT_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_TERR_ASSIGNMENT_CLEANUP" AS
/* $Header: iexttacb.pls 120.1 2005/10/28 05:06:05 lkkumar noship $ */

---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   IEX_TERR_ASSIGNMENT_CLEANUP
--    ---------------------------------------------------------------------
--    PURPOSE
--
--      Dependent Package for the concurrent program "Generate Access Records".
--      Performs any pre and post territory assignment cleanups
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package to be called from the concurrent program
--      "Generate Access Records"
--
--    HISTORY
--       Copied from AS_TERR_ASSIGNMENT_CLEANUP to remove the dependency
---------------------------------------------------------------------------


/*-------------------------------------------------------------------------+
 |                             PRIVATE CONSTANTS
 +-------------------------------------------------------------------------*/
  G_PKG_NAME  CONSTANT VARCHAR2(30):='IEX_TERR_ASSIGNMENT_CLEANUP';
  G_FILE_NAME CONSTANT VARCHAR2(12):='iexttacb.pls';

  -- ffang 121302, bug 2703096
  -- Number of record to do an incremental commit
  G_NUM_REC  CONSTANT  NUMBER:=10000;
  G_DEL_REC  CONSTANT  NUMBER:=10001;
  deadlock_detected EXCEPTION;
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);


/*-------------------------------------------------------------------------+
 |                             PRIVATE DATATYPES
 +-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE ROUTINES SPECIFICATION
 *-------------------------------------------------------------------------*/

/*------------------------------------------------------------------------*
 |                              PUBLIC ROUTINES
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Cleanup_Duplicate_Resources
 |
 | PURPOSE
 |
 | NOTES
 |
 |
 | HISTORY
 *-------------------------------------------------------------------------*/
PROCEDURE Cleanup_Duplicate_Resources(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS

BEGIN
NULL;
EXCEPTION
WHEN others THEN
    IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_TERR_ASSIGNMENT_CLEANUP::Cleanup_Duplicate_Resources');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;

END Cleanup_Duplicate_Resources;


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Cleanup_Terrritory_Accesses
 |
 | PURPOSE
 |
 |
 | NOTES
 |
 |
 | HISTORY
 *-------------------------------------------------------------------------*/
PROCEDURE Cleanup_Terrritory_Accesses(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS
BEGIN
NULL;
END Cleanup_Terrritory_Accesses;


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Perform_Account_Cleanup
 |
 | PURPOSE
 |      Updates the unqualified account records in as_accesses_all_all
 |      table.
 |
 | NOTES
 |
 |
 | HISTORY
 *-------------------------------------------------------------------------*/


PROCEDURE Perform_Account_Cleanup(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS

TYPE customer_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
l_customer_id      customer_id_list;
l_customer_id_empty      customer_id_list;

TYPE access_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
l_access_id              access_id_list;
l_access_id_empty        access_id_list;

l_flag          BOOLEAN;
l_first         NUMBER;
l_last          NUMBER;
l_var           NUMBER;
l_attempts      NUMBER := 0;

l_worker_id     NUMBER;

l_del_flag      BOOLEAN:=FALSE;
l_limit_flag    BOOLEAN := FALSE;
l_max_fetches   NUMBER  := 10000;
l_loop_count    NUMBER  := 0;


CURSOR del_acct(c_worker_id number) IS
SELECT  distinct trans_object_id
FROM JTF_TAE_1001_ACCOUNT_TRANS
WHERE worker_id=c_worker_id;

BEGIN
  IEX_TERR_WINNERS_PUB.Print_Debug('*** iexttacb.pls::IEX_TERR_ASSIGNMENT_CLEANUP::Perform_Account_Cleanup() ***');

    /** Commented because we are not writing anything into as_access_all_all **/

EXCEPTION
WHEN others THEN
    IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_TERR_ASSIGNMENT_CLEANUP::Perform_Account_Cleanup');
    IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;

END Perform_Account_Cleanup;


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Perform_Chgd_Accts_Cleanup
 |
 | PURPOSE
 |      To delete all the records in as_changed_accounts_all
 |      where request_id is not null ( only in NEW mode )
 |
 | NOTES
 |
 |
 | HISTORY
 *-------------------------------------------------------------------------*/

PROCEDURE Perform_Chgd_Accts_Cleanup(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS
    TYPE customer_id_list       is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE last_update_date_list  is TABLE of DATE INDEX BY BINARY_INTEGER;
    TYPE last_updated_by_list   is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE creation_date_list     is TABLE of DATE INDEX BY BINARY_INTEGER;
    TYPE created_by_list        is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE last_update_login_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE change_type_list       is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE org_id_list            is TABLE of NUMBER INDEX BY BINARY_INTEGER;

    l_customer_id               customer_id_list;
    l_last_update_date          last_update_date_list;
    l_last_updated_by           last_updated_by_list;
    l_creation_date             creation_date_list;
    l_created_by                created_by_list;
    l_last_update_login         last_update_login_list;
    l_change_type               change_type_list;
    l_org_id                    org_id_list;

    l_flag    BOOLEAN;
    l_first   NUMBER;
    l_last    NUMBER;
    l_var     NUMBER;


    l_new_mode_flag    varchar2(1):='Y';

    waiting_for_resource EXCEPTION;
    PRAGMA EXCEPTION_INIT(waiting_for_resource, -54);

    l_attempts         NUMBER := 0;

    l_status            VARCHAR2(2);
    l_industry          VARCHAR2(2);
    l_oracle_schema     VARCHAR2(32) := 'OSM';
    l_schema_return     BOOLEAN;

BEGIN

    l_schema_return := FND_INSTALLATION.get_app_info('IEX', l_status, l_industry, l_oracle_schema);


    IEX_TERR_WINNERS_PUB.g_debug_flag:=p_terr_globals.debug_flag;

    /** Commented because we are not writing anything into as_access_all_all **/

EXCEPTION
WHEN others THEN
    IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_TERR_ASSIGNMENT_CLEANUP::Perform_Chgd_Accts_Cleanup');
    IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      --RAISE;

END Perform_Chgd_Accts_Cleanup;

END IEX_TERR_ASSIGNMENT_CLEANUP;

/
