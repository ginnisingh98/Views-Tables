--------------------------------------------------------
--  DDL for Package HZ_BES_BO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BES_BO_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHBESUS.pls 120.7 2006/05/01 19:03:42 smattegu noship $ */

----------------------------------------------------------------------------
-- Purpose: Utility package for all the business events code
----------------------------------------------------------------------------
-- Global variable to store the profile value
G_BO_PROF_VAL VARCHAR2(30);
G_ORG_BO_ENABLED      BOOLEAN;
G_PER_BO_ENABLED      BOOLEAN;
G_ORG_CUST_BO_ENABLED BOOLEAN;
G_PER_CUST_BO_ENABLED BOOLEAN;
-- Global variable to store the creation_date that must be populated in BOT
G_CREATION_DATE       DATE;
----------------------------------------------------------------------------
TYPE NUMBER_TBLTYPE       IS TABLE OF NUMBER       INDEX BY PLS_INTEGER;
TYPE VCHAR2_30_TBLTYPE    IS TABLE OF VARCHAR2(30) INDEX BY PLS_INTEGER;
----------------------------------------------------------------------------
PROCEDURE set_prof_var;
----------------------------------------------------------------------------
FUNCTION get_prof_val RETURN VARCHAR2;
----------------------------------------------------------------------------

-- this is called from BOD Update API to figure out the BO_Version_number

PROCEDURE entity_in_bo     (
 p_bo_code        IN VARCHAR2,
 p_ebo_code       IN VARCHAR2,
 p_child_bo_code  IN VARCHAR2,
 p_entity_name    IN VARCHAR2,
 x_return_status  OUT NOCOPY BOOLEAN);

/*
   FUNCTION entity_in_bo
    ( p_bo_code       IN VARCHAR2,
      p_child_bo_code IN VARCHAR2,
      p_entity_name   IN VARCHAR2) RETURN BOOLEAN;
*/
----------------------------------------------------------------------------
/*
The populate_missing_links procedure is an umbrella procedure on top of all
explode entity level procedures.
*/
  PROCEDURE populate_missing_links (p_creation_date IN DATE);
------------------------------------------------------------------------------
/*
Procedure name: upd_bot_evt_id  ()
Scope: external
Purpose: This procedure will update the entire BOT hierarchy with
 event_id	provided. This must be done because, only when the event_id
 is populated,
   1. V2 APIs will wriet new record for any given entity
   2. BO extract API can extract the BO hierarchy
Called From: This is called from HZ_BES_BO_RAISE_PKG
Called By: bes_main()
Input parameters:
p_bulk_evt in BOOLEAN, -- TRUE if bulk event was raised by bes_main()
In case of bulk event raising, there will be 8 distinct event ids for 8 events.
If one event was raised per business object instance, then, event_id
is obtained from the HZ_BES_GT table.
p_per_ins_evt_id IN NUMBER,
p_per_upd_evt_id IN NUMBER,
p_org_ins_evt_id IN NUMBER,
p_org_upd_evt_id IN NUMBER,
p_perc_ins_evt_id IN NUMBER,
p_perc_upd_evt_id IN NUMBER,
p_orgc_ins_evt_id IN NUMBER,
p_orgc_upd_evt_id IN NUMBER

*/
PROCEDURE upd_bot_evt_id (
	 p_bulk_evt in BOOLEAN,
	 p_evt_id IN NUMBER,
	 p_child_id IN NUMBER,
	 p_child_bo_code IN VARCHAR2,
	 p_per_ins_evt_id IN NUMBER,
	 p_per_upd_evt_id IN NUMBER,
	 p_org_ins_evt_id IN NUMBER,
	 p_org_upd_evt_id IN NUMBER,
	 p_perc_ins_evt_id IN NUMBER,
	 p_perc_upd_evt_id IN NUMBER,
	 p_orgc_ins_evt_id IN NUMBER,
	 p_orgc_upd_evt_id IN NUMBER);
------------------------------------------------------------------------------
/*
Procedure name: upd_bot_evtid_dt  ()
Scope: external
Purpose: This procedure will update the entire BOT hierarchy with
 event_id, creation_date provided. This must be done because,
 only when the event_id is populated,
   1. V2 APIs will write new record for any given entity
   2. BO extract API can extract the BO hierarchy
Called From: This is called from HZ_BES_BO_RAISE_PKG
Called By: bes_main()
Input parameters:
p_bulk_evt in BOOLEAN, -- TRUE if bulk event was raised by bes_main()
In case of bulk event raising, there will be 8 distinct event ids for 8 events.
If one event was raised per business object instance, then, event_id
is obtained from the HZ_BES_GT table.
p_creation_date IN DATE, -- used to update the creation_date column in BOT
p_per_ins_evt_id IN NUMBER,
p_per_upd_evt_id IN NUMBER,
p_org_ins_evt_id IN NUMBER,
p_org_upd_evt_id IN NUMBER,
p_perc_ins_evt_id IN NUMBER,
p_perc_upd_evt_id IN NUMBER,
p_orgc_ins_evt_id IN NUMBER,
p_orgc_upd_evt_id IN NUMBER

*/
PROCEDURE upd_bot_evtid_dt (
	 p_bulk_evt in BOOLEAN, -- whether bulk event was raised (TRUE) or not (FALSE)
	 p_evt_id IN NUMBER,  -- only used for one event per object instance
	 p_child_id IN NUMBER,  -- only used for one event per object instance
	 p_child_bo_code IN VARCHAR2, -- only used for one event per object instance
	 p_creation_date IN DATE, -- used to update the creation_date column in BOT
	 p_evt_type IN VARCHAR2, -- this is to pass the event type (Bug4773627)
  	 p_commit  IN BOOLEAN, -- to control commit or rolllback when called from v3 api(Bug4957408)
	 p_per_ins_evt_id IN NUMBER,
	 p_per_upd_evt_id IN NUMBER,
	 p_org_ins_evt_id IN NUMBER,
	 p_org_upd_evt_id IN NUMBER,
	 p_perc_ins_evt_id IN NUMBER,
	 p_perc_upd_evt_id IN NUMBER,
	 p_orgc_ins_evt_id IN NUMBER,
	 p_orgc_upd_evt_id IN NUMBER);
------------------------------------------------------------------------------
/*
Procedure name: upd_hzp_bo_ver  ()
Scope: external
Purpose: This procedure will update the hz_parties table with all the
  latest bo_version_numbers. This must be done to short circuit the
  process for figuring out event type when the object is touched next time.
Called From: This is called from HZ_BES_BO_RAISE_PKG
Called By: bes_main()
Input parameters:
	 p_per_bo_ver IN NUMBER   -- for passing the person bo version number
	 p_org_bo_ver IN NUMBER   -- for passing the org bo version number
	 p_perc_bo_ver IN NUMBER  -- for passing the person cust bo version number
	 p_orgc_bo_ver IN NUMBER  -- for passing the org cust bo version number
*/
PROCEDURE upd_hzp_bo_ver (
	 p_per_bo_ver IN NUMBER,   -- for passing the person bo version number
	 p_org_bo_ver IN NUMBER,   -- for passing the org bo version number
	 p_perc_bo_ver IN NUMBER, -- for passing the person cust bo version number
	 p_orgc_bo_ver IN NUMBER);-- for passing the org cust bo version number
----------------------------------------------------------------------------
/*
Procedure name: del_bot()
Scope: external
Purpose: This procedure will delete the records that were already processed
 by subscriptions.
Called By: Cleanse Concurrent Program
Input parameters:
p_cutoff_dt IN DATE);-- for passing the cutoff date for deleting the recs in BOT
*/
PROCEDURE del_bot (
p_cutoff_dt IN DATE);-- for passing the cutoff date for deleting the recs in BOT
----------------------------------------------------------------------------
/*
Procedure name: del_duplicate_rows()
Scope: external
Purpose: This procedure will delete any duplicate rows that were
 entered by the populate function.
 It is possible for populate function to enter duplicate rows
 in cases where TCA APIs are called from concurrent requests that run in parallel.
 If the parallel running concurrent requests try to create or update the same
 set of data using the same primary keys, then, populate function running in
 different thread will end up writing identical rows from each thread.
 Once the concyurrent requests complete successfully, this will result in
 duplicate rows in BOT table.
 Introducing the Unique Index in BOT will not help because, this would result in
 Concurrent requests to fail.
 The alternative is to delete the duplicate rows.
Called By: Raise Concurrent Program
*/
procedure del_duplicate_rows ;
----------------------------------------------------------------------------
/*
Procedure name: del_obj_hierarchy()
Scope: external
Purpose: Given a root object identifier, this procedure
 will delete the entire hierarchy.
 This procedure is called from
 1. party purge concurrent program
 2. account merge concurrent program with delete option.

In these two cases, as the entire party and its detailed records are
purged, there is no use of maintaining those records in the BOT.
If the purged records are left in BOT without deleting:
 1. There is a chance that an event may be raised for already
    purged record. Functionally, this would be incorrect.
 2. The Raise Events concurrent program may error out
    as it cannot find the party record in TCA Registry.
    This is needed for updating the party BO_VERSION columns to
    be updated after raising the event.

Called By:
 1. party purge concurrent program
 2. account merge concurrent program with delete option.

Input:
  BO Code: PERSON for Person BO,
           ORG for Organization BO,
           PERSON_CUST for Person Customer BO
           ORG_CUST for Organization Customer BO
  Object Identifier: Root Object Id (party id).

*/
procedure del_obj_hierarchy
 ( P_OBJ_ID IN NUMBER);
----------------------------------------------------------------------------
/*
Procedure name: upd_entity_ids()
Scope: external
Purpose: Given a root object identifier, this procedure
 will delete the entire hierarchy.
 This procedure is called from
 1. party merge concurrent program
 2. account merge concurrent program

In these two cases, the entity ids are changed in TCA REgistry by
the above concurrent programs.
This procedure reflects the id changes in the BOT.
This changed ids will enable the BO extraction API to get to the
action types of the changed entities in BOT.
Note - this method does not handle RA_CUST_RECEIPT_METHODS and
       IBY_FNDCPT_PAYER_ASSGN_INSTR_V.
  This method only handles update of identifiers for HZ tables.
Called By:
 1. party merge concurrent program
 2. account merge concurrent program

Input:
  request id: Concurrent Request Identifier
*/
procedure upd_entity_ids
 ( P_request_id IN NUMBER);
----------------------------------------------------------------------------
----------------------------------------------------------------------------
END HZ_BES_BO_UTIL_PKG; -- Package spec

 

/
