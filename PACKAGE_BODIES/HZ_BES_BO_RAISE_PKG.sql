--------------------------------------------------------
--  DDL for Package Body HZ_BES_BO_RAISE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BES_BO_RAISE_PKG" AS
/*$Header: ARHBESRB.pls 120.9 2006/06/27 13:22:21 smattegu noship $ */
-- ---------   ------  ------------------------------------------

-- Global Variable.
-- This global variable will read the profile that defines whether
-- event raising is to be done in bulk or not.
-- This profile is set at site level only. The value of the profile is set to Y.
-- This is to ensure that, out of the box, event raising is going to be in bulk.
G_BLK_EVT_RAISE CONSTANT VARCHAR2(1):=FND_PROFILE.VALUE('HZ_BO_EVENTS_FORMAT_BULK');
-- Private procedures
-- out() -- This is to write a mesg to out file.
-- log() -- This is to write a mesg to log file
-- outandlog() -- This is to write a mesg to both out and log files.
-- mesglog
-- mesgout
-- mesgoutlog
--
----------------------------------------------
/**
* Procedure to write a message to the out file
**/
----------------------------------------------
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;
----------------------------------------------
/**
* Procedure to write text to the log file
**/
----------------------------------------------
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
   l_prefix VARCHAR2(20) := 'BES_BO_RAISE';
BEGIN
/*
	FND_FILE.LOG = 1 - means log file
	FND_FILE.LOG = 2 - means out file
*/
	IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
			hz_utility_v2pub.DEBUG (
				p_message=>message,
		    p_prefix=>l_prefix,
	    	p_msg_level=>fnd_log.level_procedure);
	END IF ;

  IF newline THEN
    FND_FILE.put_line(FND_FILE.LOG,message);
     FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSE
    FND_FILE.put_line(FND_FILE.LOG,message);
  END IF;
END log;
----------------------------------------------
/**
* Procedure to write a message to the out and log files
**/
----------------------------------------------
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

----------------------------------------------
/**
* procedure to fetch messages of the stack and log the error

----------------------------------------------

PROCEDURE logerr IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;
  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;
 -- FND_MSG_PUB.Delete_Msg;
END logerr;
**/
----------------------------------------------
/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
----------------------------------------------
FUNCTION logerror RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || ' ' || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the log file also.
*/
----------------------------------------------

PROCEDURE mesglog(
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn1_val     IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_val     IN      VARCHAR2 DEFAULT NULL
   ) IS
BEGIN
  FND_MESSAGE.SET_NAME('AR', p_message);
  IF (p_tkn1_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn1_name, p_tkn1_val);
  END IF;
  IF (p_tkn2_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn2_name, p_tkn2_val);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    log(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;

END mesglog;

----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the out file also.
*/
----------------------------------------------

PROCEDURE mesgout(
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn1_val     IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_val     IN      VARCHAR2 DEFAULT NULL
   ) IS
BEGIN
  FND_MESSAGE.SET_NAME('AR', p_message);
  IF (p_tkn1_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn1_name, p_tkn1_val);
  END IF;
  IF (p_tkn2_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn2_name, p_tkn2_val);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    out(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;

END mesgout;

----------------------------------------------
/*
  this procedure takes a message_name and enters into the message stack
  and writes into the out and log file also.
*/
----------------------------------------------

PROCEDURE mesgoutlog(
   p_message      IN      VARCHAR2,
   p_tkn1_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn1_val     IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_name    IN      VARCHAR2 DEFAULT NULL,
   p_tkn2_val     IN      VARCHAR2 DEFAULT NULL
   ) IS
BEGIN
  FND_MESSAGE.SET_NAME('AR', p_message);
  IF (p_tkn1_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn1_name, p_tkn1_val);
  END IF;
  IF (p_tkn2_name IS NOT NULL) THEN
     fnd_message.set_token(p_tkn2_name, p_tkn2_val);
  END IF;
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    outandlog(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
  END LOOP;

END mesgoutlog;
---------------------------------------------------------------------
/*
	 Procedure name: bes_main()
	 Scope: Internal
	 Purpose: This is the umbrella procedure that is used to raise business events
	 for Org, Person, Org Customer and Person Customer business objects in TCA.
	 Called From: Concurrent Manager
	 Called By:
	 Paramaters - brief desc of each parameter:
	  In:
	  Out:
	  In-Out:
*/
--------------------------------------------------------------------------
/* bes_main flow:
. record the start time of the concurrent program in a variable.
. figure out the profile HZ_EXECUTE_API_CALLOUTS value
. if the profile is set to v2/noevents then exit gracefully
. if the business objects for which there are enabled business events with
  valid subscriptions (other than the seeded subscription) -- This step is optional in phase 1
. select and store the BO object versions from BOD
. delete the duplicate rows entered by populate function in BOT. Bug#4957408
. identify and populate missing links in BOT
. for each BO per/org/percust/orgcust
 . select all the root nodes from the BOT for a give BO.
 .   In the same select, identify the nodes for updateBO event based on BO Version comparision.
     (short circuting)
 . Populate the Global Temporary (GT) Table (BO_CODE, ROOT_NODE_ID, EVENT_ID)
   with the above results.
	  Note: event_id cannot be populated for bulk events (G_BLK_EVT_RAISE = Y).
. Select all the Person BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
. Select all the Org BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
. Populate all those Org/Person parties in GT(BO_CODE, ROOT_NODE_ID, EVENT_ID),
  that are not current present as Org/Person Cust BOs in GT; but,
	have an existing account into GT.
	  Note: event_id cannot be populated for bulk events (G_BLK_EVT_RAISE = Y).
	Also populate BOT with two records per each one record that was entered into GT.
	One record is for Per/Org Cust BO root node record.
	The other record is for Per/Org BO as child and Per/Org Cust BO as parent.
. Select all the Person Cust BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
. Select all the Org Cust BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
. populate the event parameter payload with event id (CDH_EVENT_ID).
. If the events must be raised in Bulk,
	. Identify how many types of events to be raised.
	   This is done by doing existence check on GT for a given BO and
		 event type flag combination. Generate as needed, event ids.
	. For Person-Insert Raise One Bulk event
	. For Person-Update Raise One Bulk event
	. For Org-Insert Raise One Bulk event
	. For Org-Update Raise One Bulk event
	. For Person-Cust-Insert Raise One Bulk event
	. For Person-Cust-Update Raise One Bulk event
	. For Org-Cust-Insert Raise One Bulk event
	. For Org-Cust-Update Raise One Bulk event
  . For all the eight events above, Update entire BOT hierarchy with
	  appropriate event_id.
	. commit
	. identify all the Person/Org Child BOs in Person/Org Cust BOs and
	  update the records with appropriate child event ids. -- this step is not done
	  as child_event_id is populated at the time of populating BOT (per/Org EBO rec)
. If the event must be raised per each BO
	. Select all the GT contents, ordered by root_node_id (a.k.a. party_id).
		This would select the all the parties with different BOs together.
		. Per each party
		 . if BO = Person
	     . Raise the create/update event for Person BO
	     . Update entire BOT hierarchy with event_id
	     . store the person bo event_id for later use as child_event_id (per_child_evt_id).
		 . if BO = Person Cust
	     . Raise the  create/update event for Person Cust BO
	     . Update entire BOT hierarchy with event_id
	     . Update the Person as child record child_event_id with per_child_evt_id
		 . if BO = Org
	     . Raise the create/update event for Org BO
	     . Update entire BOT hierarchy with event_id
	     . store the org bo event_id for later use as child_event_id (org_child_evt_id).
		 . if BO = Org Cust
	     . Raise the create/update event for OrgCust BO
	     . Update entire BOT hierarchy with event_id
	     . Update the Person as child record child_event_id with org_child_evt_id
		 . commit; -- As event raising already took place, we need to comminucate to
		   V2 APIs that they must start writing fresh entity records in BOT.
		   This can be acheived with this commit.
 . Write the BO version of BO (taken from BOD) to hz_parties table for all
   parties that were in GT table.
 . Delete the records that were not part of any event from BOT.
	 This is based on creation_date being less that than the start time of the conc program.

some definitions:
Two kinds of the root nodes (parties) that must be evaluated for
completness check and eventtype().
1. First timers: Party records that are processed for the first time.
   In other words, those party records for which BO_VERSION_NUMBER is null
	 on hz_parties table.
2. Second timers: Party records that were processed earlier; but the
	 business object definition changed after that.
   In other words, those party records for which BO_VERSION_NUMBER is different
   from the current Business Object definition in the BOD table.
*/

PROCEDURE bes_main (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2) IS

-- cursor for getting the BO version number for per/org/orgcust/percust BOs
CURSOR c_bo_ver (cp_bo_code VARCHAR2) IS
	SELECT bo_version_number
	FROM hz_bus_obj_definitions
	WHERE business_object_code = cp_bo_code
  AND root_node_flag = 'Y';

CURSOR c_bo_gt IS
   SELECT event_id, party_id, bo_code, event_type_flag
   FROM hz_bes_gt
   ORDER BY bo_code asc ;

 -- debug code start
 CURSOR c_bo_gt_debug IS
   SELECT event_id, party_id, bo_code, event_type_flag
   FROM hz_bes_gt
   ORDER BY event_id, bo_code desc ;

 CURSOR c_bo_gt_debug2 (cp_bo_code VARCHAR2) IS
   SELECT event_id, party_id, event_type_flag
   FROM hz_bes_gt
   WHERE bo_code = cp_bo_code
   ORDER BY event_type_flag, event_id, party_id desc ;
 -- debug code end

/* Cusror to figure out what types of bulk update events to be raised
*/
 CURSOR c_chk_insevt (cp_bo_code VARCHAR2) IS
   SELECT 'Y'
   FROM hz_bes_gt
   WHERE BO_CODE = cp_bo_code
   AND event_type_flag IS NULL
   AND ROWNUM <2;

/* Cusror to figure out what types of bulk insert events to be raised
*/
 CURSOR c_chk_updevt (cp_bo_code VARCHAR2) IS
   SELECT 'Y'
   FROM hz_bes_gt
   WHERE BO_CODE = cp_bo_code
   AND event_type_flag = 'U'
   AND ROWNUM <2;

 -- This is the ER done as part of bug  4997605.
 -- This is to print all the objects that were raised in bulk mode
 CURSOR c_bot_log ( cp_evtid NUMBER, cp_bo_code  VARCHAR2) IS
  SELECT event_id CDH_EVENT_ID,
         child_id CDH_OBJECT_ID,
         parent_event_flag event_type
   FROM hz_bus_obj_tracking
  WHERE event_id = cp_evtid
    AND CHILD_BO_CODE = cp_bo_code
    AND parent_BO_CODE IS NULL
   ORDER BY 2 desc;

-- local variables
-- to store the party ids from BOT(parent_id) for raising the create event.
l_cre_evt_ids NUMBER_TBLTYPE;
-- to store the party ids from BOT(parent_id) for raising the update event.
l_upd_evt_ids NUMBER_TBLTYPE;
-- to store the party ids and last update dates that are to be
-- processed by the coompletness() and evtType()
l_ids NUMBER_TBLTYPE;
l_pids NUMBER_TBLTYPE;
l_ids2 NUMBER_TBLTYPE;
l_evts VCHAR2_1_TBLTYPE;
l_bo_codes VCHAR2_30_TBLTYPE;
l_ct NUMBER := 0; -- temp variable to store count of number of records in GT
l_g_bulk_type BOOLEAN ;

-- to store the event_ids for BO events
l_perbo_c_evtid     NUMBER := 0; -- per bo create event id
l_perbo_u_evtid     NUMBER := 0; -- per bo update event id
l_orgbo_c_evtid     NUMBER := 0; -- org bo create event id
l_orgbo_u_evtid     NUMBER := 0; -- org bo create event id
l_percustbo_c_evtid NUMBER := 0; -- per cust bo create event id
l_percustbo_u_evtid NUMBER := 0; -- per cust bo update event id
l_orgcustbo_c_evtid NUMBER := 0; -- org cust bo create event id
l_orgcustbo_u_evtid NUMBER := 0; -- org cust bo update event id

-- to store the concurrent program start time
-- When storing the missing links in BOT, this is used as creation_date
l_cc_start_time DATE := SYSDATE;
-- The flush spurious records in BOT uses the following date
l_del_cutoff_dt DATE := l_cc_start_time -1;

-- when raising bulk events, flags are needed to know what events to raise.
-- the following 8 flags are used for that purpose.
l_p_ins_flag VARCHAR2(1);-- to raise person bo ins event or not
l_p_upd_flag VARCHAR2(1);-- to raise person bo upd event or not
l_o_ins_flag VARCHAR2(1);-- to raise org bo ins event or not
l_o_upd_flag VARCHAR2(1);-- to raise org bo upd event or not
l_pc_ins_flag VARCHAR2(1);-- to raise person cust bo ins event or not
l_pc_upd_flag VARCHAR2(1);-- to raise person cust bo upd event or not
l_oc_ins_flag VARCHAR2(1);-- to raise org cust bo ins event or not
l_oc_upd_flag VARCHAR2(1);-- to raise org cust bo upd event or not

-- following variables are needed for event raising
l_paramlist      WF_PARAMETER_LIST_T;
--l_param          WF_PARAMETER_T;
l_key            VARCHAR2(240);
l_event_name     VARCHAR2(240);


BEGIN
  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;

  retcode := 0; -- setting the return code to success
-- write debug mesg
  LOG('bes_main(+)');

-- check if the profile is set to v2 and v3 or just v3 events.
-- in cases other than the above there is no need of any processing.
  G_PROF_VAL  := FND_PROFILE.value( 'HZ_EXECUTE_API_CALLOUTS');

  IF G_PROF_VAL = 'N' OR G_PROF_VAL = 'Y' THEN
    -- this means either no vents must be raised or only v2 events must be raised
    -- hence, raise an error.
    mesgoutlog('HZ_BES_BO_RAISE_PROFILE_ERROR');
    RAISE FND_API.G_EXC_ERROR;
--    RETURN;
  END IF;

-- check the bulk profile option
-- if the profile value is set to Y - then raise bulk events
-- if the profile value is set to N - then raise one event per object instance
  IF G_BLK_EVT_RAISE = 'N' OR G_BLK_EVT_RAISE = 'Y' THEN
    null;
  else
     mesgoutlog('HZ_BES_BO_FORMAT_PROF_ERROR');
    RAISE FND_API.G_EXC_ERROR;
--    RETURN;
  END IF;

  IF G_BLK_EVT_RAISE = 'Y' THEN
    l_g_bulk_type := TRUE;
  ELSE
    l_g_bulk_type := FALSE;
  END IF;

  -- . select and store the BO object versions from BOD
	-- select the bo version numbers for all the business objects
	-- This is done irrespective of if the BO is enabled or not.

	LOG('get BO versions from BOD');
 	-- for person BO
  OPEN c_bo_ver(G_PER_BO_CODE);
	FETCH c_bo_ver INTO G_PER_BO_VER;
	CLOSE c_bo_ver;
	-- for org bo
  OPEN c_bo_ver(G_ORG_BO_CODE);
	FETCH c_bo_ver INTO G_ORG_BO_VER ;
	CLOSE c_bo_ver;
	-- for person customer BO
  OPEN c_bo_ver(G_PER_CUST_BO_CODE);
	FETCH c_bo_ver INTO G_PER_CUST_BO_VER ;
	CLOSE c_bo_ver;
	-- for org customer BO
  OPEN c_bo_ver(G_ORG_CUST_BO_CODE);
	FETCH c_bo_ver INTO G_ORG_CUST_BO_VER ;
	CLOSE c_bo_ver;
  -- for person customer BO
  OPEN c_bo_ver(G_PER_CUST_BO_CODE);
  FETCH c_bo_ver INTO G_PER_CUST_BO_VER ;
  CLOSE c_bo_ver;
  -- for org customer BO
  OPEN c_bo_ver(G_ORG_CUST_BO_CODE);
  FETCH c_bo_ver INTO G_ORG_CUST_BO_VER ;
  CLOSE c_bo_ver;

/*
   Changes for Bug#4957408.
   It is possible for Shipping and Lead Import concurrent programs to
   call and write the same TCA info using parallel running conc request threads.
   This will result in duplicate rows in BOT (via populate func).
   The duplicate rows must be deleted to proceed further.
*/
  LOG('delete duplicate rows from BOT');
  HZ_BES_BO_UTIL_PKG.del_duplicate_rows;

/*
  . identify and populate missing links in BOT
  1. Figure out the start time of the concurrent program.
  2. Provide the (start time of the concurrent_program -1)
      as the creation_date for the missing links procedure.
     This will be used as creation_date when BOT is populated by
     missing links procedures.
     This is needed because, V2 APIs, via populate functions
     some times creates the records, that are not part of any event.
     To delete such records, this creation_date column is used.
*/
  LOG('populate missing links');
	HZ_BES_BO_UTIL_PKG.populate_missing_links(l_cc_start_time);

	IF G_BLK_EVT_RAISE = 'Y' THEN
    LOG('get event id sequences for bulk event raising');
    -- select the sequence a.k.a event ids needed
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_orgbo_c_evtid FROM dual;
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_orgbo_u_evtid FROM dual;
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_perbo_c_evtid FROM dual;
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_perbo_u_evtid FROM dual;
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_percustbo_c_evtid FROM dual;
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_percustbo_u_evtid FROM dual;
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_orgcustbo_c_evtid FROM dual;
    SELECT hz_bus_obj_tracking_s.NEXTVAL INTO l_orgcustbo_u_evtid FROM dual;
  END IF;

/*
 . select all the root nodes from the BOT for a give BO.
 .   In the same select, identify the nodes for updateBO event
     based on BO Version comparision (short circuting).
 . Populate the Global Temporary (GT) Table with the above results.

 	Populate the GT ((BO_CODE, ROOT_NODE_ID, EVENT_ID))with
	1. potential candidates for event raising.
	2. (short circuting) - identify all the parties for which an event was raised
	   earlier i.e., candidates for updateBO event (event_type_flag).
*/

 LOG('insert into GT the root nodes with short circuting');
 INSERT INTO hz_bes_gt (event_id, party_id, BO_CODE, event_type_flag)
 SELECT
   DECODE ( G_BLK_EVT_RAISE, 'Y',
      CASE r.bo_code
      WHEN G_PER_BO_CODE THEN
        DECODE (r.event_type_flag, 'U', l_perbo_u_evtid, l_perbo_c_evtid)
      WHEN G_ORG_BO_CODE THEN
        DECODE (r.event_type_flag, 'U', l_orgbo_u_evtid, l_orgbo_c_evtid)
      WHEN G_ORG_CUST_BO_CODE THEN
        DECODE (r.event_type_flag, 'U', l_orgcustbo_u_evtid, l_orgcustbo_c_evtid)
      WHEN G_PER_CUST_BO_CODE THEN
        DECODE (r.event_type_flag, 'U', l_percustbo_u_evtid, l_percustbo_c_evtid)
      ELSE NULL
      END , hz_bus_obj_tracking_s.NEXTVAL),
   r.party_id, r.bo_code, r.event_type_flag
 FROM (
	SELECT
    child_id PARTY_ID, child_bo_code BO_CODE,
    CASE t.child_bo_code
      WHEN G_PER_BO_CODE THEN
        DECODE(p.PERSON_BO_VERSION,G_PER_BO_VER,'U',NULL)
      WHEN G_ORG_BO_CODE THEN
        DECODE(p.ORG_BO_VERSION, G_ORG_BO_VER,'U',NULL)
      WHEN G_ORG_CUST_BO_CODE THEN
        DECODE(p.ORG_CUST_BO_VERSION,G_ORG_CUST_BO_VER,'U',NULL)
      WHEN G_PER_CUST_BO_CODE THEN
        DECODE(p.PERSON_CUST_BO_VERSION,G_PER_CUST_BO_VER,'U',NULL)
      ELSE NULL
    END 	event_type_flag
	FROM hz_bus_obj_tracking t, hz_parties p
	WHERE
	  t.child_bo_code IN
	  (G_PER_BO_CODE, G_ORG_BO_CODE, G_ORG_CUST_BO_CODE,	G_PER_CUST_BO_CODE)
	  AND	p.party_id = t.child_id
	  AND parent_bo_code IS NULL
	  AND t.child_entity_name = 'HZ_PARTIES'
	  AND	t.event_id IS NULL) r;
 COMMIT;
/*
 -- debug code start
  OPEN c_bo_gt_debug;
	FETCH c_bo_gt_debug BULK COLLECT INTO l_ids, l_ids2, l_bo_codes, l_evts ;
	CLOSE c_bo_gt_debug;
	l_ct := l_ids2.COUNT;
  LOG('count is:'||to_char(l_ct));
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' bo_code:'||l_bo_codes(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
/*
. Select all the Person BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
*/
  -- bo_complete_check() deletes all the incomplete Person BO records from GT
  LOG('completness check for Person BO');
  HZ_BES_BO_SITE_UTIL_PKG.bo_complete_check(G_PER_BO_CODE);
/*
 -- debug code start
  OPEN c_bo_gt_debug2(G_PER_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
	l_ct := l_ids2.COUNT;
  LOG('complete '||G_PER_BO_CODE||' BO count is:'||to_char(l_ct));
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
  -- bo_event_check() updates all the Person BO recs in GT
  -- that are complete and are candiates for update event.
  LOG('event type check for Person BO');
  HZ_BES_BO_SITE_UTIL_PKG.bo_event_check(G_PER_BO_CODE);
/*

 -- debug code start
  OPEN c_bo_gt_debug2(G_PER_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
  l_ct := l_ids2.COUNT;
  LOG(G_PER_BO_CODE||' BO count is:'||to_char(l_ct));
  log('Following is the list of '||G_PER_BO_CODE||' objects with potential evt types');
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
  -- All the remaining person bo records in GT with NULL event_type_flag are
  -- complete and candidates for create event

/*
	-- for org bo
. Select all the Org BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
*/

  -- bo_complete_check() deletes all the incomplete Org bo records from GT
  LOG('completness check for Org BO');
  HZ_BES_BO_SITE_UTIL_PKG.bo_complete_check(G_ORG_BO_CODE);
/* -- debug code start
  OPEN c_bo_gt_debug2(G_ORG_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
	l_ct := l_ids2.COUNT;
  LOG('complete '||G_ORG_BO_CODE||' BO count is:'||to_char(l_ct));
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
  -- bo_event_check() updates all the Org bo recs in GT
  -- that are complete and are candiates for update event.
  LOG('event type check for Org BO');
  HZ_BES_BO_SITE_UTIL_PKG.bo_event_check(G_ORG_BO_CODE);
/*
 -- debug code start
  OPEN c_bo_gt_debug2(G_ORG_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
	l_ct := l_ids2.COUNT;
  LOG(G_ORG_BO_CODE||' BO count is:'||to_char(l_ct));
  log('Following is the list of '||G_ORG_BO_CODE||' objects with potential evt types');
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
  -- All the remaining Org bo records in GT with NULL event_type_flag are
  -- complete and candidates for create event

/*
. Populate all those Org/Person parties in GT(BO_CODE, ROOT_NODE_ID, EVENT_ID),
  that are not current present as Org/Person Cust BOs in GT; but,
	have an existing account.
	Also populate BOT with two records per each one record that was entered into GT.
	One record is for Per/Org Cust BO root node record.
	The other record is for Per/Org BO as child and Per/Org Cust BO as parent.
*/
-- the following insert statement writes two records
-- Person/Org Cust and Person/Org (as it's child) into BOT.
-- For this to happen, the following conditions must be met:
-- 1. There is no corresponding PERSON/ORG CUST record already in GT, BOT
-- 2. Account record exists for the party.
-- This will also inser Org/Person Cust Records in GT
-- While populating the records in GT, this SQL will figure out the
-- short circuting for based on the Bo version numbers for cust business object
-- from hz_parties table.
  LOG('insert (in GT) all those related PERSON/ORG CUST BO records that are not in GT');
INSERT ALL
  WHEN  (child_bo_code is null) THEN
	INTO hz_bus_obj_tracking    -- inserting person/org cust bo rec in BOT
	(CHILD_ENTITY_NAME, CHILD_ID,	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, CREATION_DATE)
  VALUES (
   'HZ_PARTIES', party_id, 'U', 'Y',
	 l_cc_start_time, BO_CODE, l_cc_start_time)
	INTO hz_bus_obj_tracking -- inserting person/org bo rec as child of person/org cust bo in BOT
	(CHILD_ENTITY_NAME, CHILD_ID,	 CHILD_OPERATION_FLAG, POPULATED_FLAG,
   LAST_UPDATE_DATE, CHILD_BO_CODE, CREATION_DATE,
 	 PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE, child_event_id)
  VALUES (
   'HZ_PARTIES', party_id, 'U', 'Y',
	 l_cc_start_time, C_BO_CODE, l_cc_start_time,
	 'HZ_PARTIES', party_id, BO_CODE, party_id)
  WHEN  (1=1) THEN
   into HZ_BES_GT ( event_id, party_id, bo_code, event_type_flag)
   VALUES (
     DECODE (G_BLK_EVT_RAISE, 'Y',
      CASE bo_code
        WHEN G_ORG_CUST_BO_CODE THEN
          DECODE (event_type_flag, 'U', l_orgcustbo_u_evtid, l_orgcustbo_c_evtid)
        WHEN G_PER_CUST_BO_CODE THEN
          DECODE (event_type_flag, 'U', l_percustbo_u_evtid, l_percustbo_c_evtid)
        ELSE NULL
     END , hz_bus_obj_tracking_s.NEXTVAL), party_id, bo_code, event_type_flag)
SELECT r.party_id, r.bo_code, r.c_bo_code,
    CASE bo_code
      WHEN G_ORG_CUST_BO_CODE THEN
        DECODE(p.ORG_CUST_BO_VERSION,G_ORG_CUST_BO_VER,'U',NULL)
      WHEN G_PER_CUST_BO_CODE THEN
        DECODE(p.PERSON_CUST_BO_VERSION,G_PER_CUST_BO_VER,'U',NULL)
      ELSE NULL
    END 	event_type_flag,
 bot.child_bo_code
FROM (
  SELECT
    t1.party_id party_id,
  	DECODE (t1.bo_code, 'PERSON', 'PERSON_CUST', 'ORG','ORG_CUST') BO_CODE,
  	t1.bo_code C_BO_CODE
  FROM
    hz_bes_gt t1
  WHERE
    t1.bo_code IN ('PERSON','ORG')
    AND NOT EXISTS
  	 ( SELECT t2.party_id
  	   FROM hz_bes_gt t2
  	   WHERE t2.party_id = t1.party_id
  		 AND t2.bo_code IN ('PERSON_CUST','ORG_CUST'))
  	AND EXISTS
  	( SELECT 1 FROM hz_cust_accounts WHERE party_id = t1.party_id)
  ) r, hz_parties p, HZ_BUS_OBJ_TRACKING bot
where
p.party_id = r.party_id
and bot.event_id(+)  IS NULL
AND bot.CHILD_ENTITY_NAME (+) = 'HZ_PARTIES'
AND bot.CHILD_ID(+) = r.PARTY_ID
AND bot.CHILD_BO_CODE(+) = r.BO_CODE
AND bot.parent_bo_code(+) IS NULL ;
COMMIT;

/* for Person Cust BO
. Select all the Person Cust BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
*/
  -- bo_complete_check() deletes all the incomplete Person Cust BO  records from GT
  LOG('completness check for Person Cust BO');
  HZ_BES_BO_SITE_UTIL_PKG.bo_complete_check(G_PER_CUST_BO_CODE);
/*
 -- debug code start
  OPEN c_bo_gt_debug2(G_PER_CUST_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
	l_ct := l_ids2.COUNT;
  LOG('complete '||G_PER_CUST_BO_CODE||' BO count is:'||to_char(l_ct));
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
  -- bo_event_check() updates all the Person Cust BO recs in GT
  -- that are complete and are candiates for update event.
  LOG('event type check for Person Cust BO ');
  HZ_BES_BO_SITE_UTIL_PKG.bo_event_check(G_PER_CUST_BO_CODE);
/*
  -- All the remaining Person Cust BO recs in GT with NULL event_type_flag are
  -- complete and candidates for create event

 -- debug code start
  OPEN c_bo_gt_debug2(G_PER_CUST_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
	l_ct := l_ids2.COUNT;
  LOG(G_PER_CUST_BO_CODE||' BO count is:'||to_char(l_ct));
  log('Following is the list of '||G_PER_CUST_BO_CODE||' objects with potential evt types');
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
/* for Org Cust BO
. Select all the Org Cust BO records from the GT table for which event type is not identified
  . After checking the completeness of those BOs, delete the rest of the records
	  for which the event type is not specified and not complete.
  . Figure out the event type for the root nodes for which
	  event type is null (BO is complete) from GT. In the same SQL identify the
		Last Update Date applicable for each root node.
		Update the GT with event type based on the above query.
*/
  -- bo_complete_check() deletes all the incomplete Org Cust BO records from GT
  LOG('completness check for Org Cust BO ');
  HZ_BES_BO_SITE_UTIL_PKG.bo_complete_check(G_ORG_CUST_BO_CODE);
/*
 -- debug code start
  OPEN c_bo_gt_debug2(G_ORG_CUST_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
	l_ct := l_ids2.COUNT;
  LOG('complete '||G_ORG_CUST_BO_CODE||' BO count is:'||to_char(l_ct));
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
  -- bo_event_check() updates all the Org Cust BO recs in GT
  -- that are complete and are candiates for update event.
  LOG('event type check for Org Cust BO ');
  HZ_BES_BO_SITE_UTIL_PKG.bo_event_check(G_ORG_CUST_BO_CODE);

  -- All the remaining Org Cust BO records in GT with NULL event_type_flag are
  -- complete and candidates for create event
/*
 -- debug code start
  OPEN c_bo_gt_debug2(G_ORG_CUST_BO_CODE);
	FETCH c_bo_gt_debug2 BULK COLLECT INTO l_ids, l_ids2, l_evts ;
	CLOSE c_bo_gt_debug2;
	l_ct := l_ids2.COUNT;
  LOG(G_ORG_CUST_BO_CODE||' BO count is:'||to_char(l_ct));
  log('Following is the list of '||G_ORG_CUST_BO_CODE||' objects with potential evt types');
	FOR i IN 1.. l_ct LOOP
	 LOG ('evt id:'||l_ids(i)||' party_id:'||l_ids2(i)||' evtType:'||l_evts(i));
	END LOOP;
 -- debug code end
*/
 -- Till now, all the BO records for which an event must be raised or identified
 -- and marked. The main tasks remaing are raising the event(s) and house keeping.

 -- prepare WF BES event parameter object
 -- initialization of object variables
 l_paramlist := WF_PARAMETER_LIST_T();
-- l_param := WF_PARAMETER_T( NULL, NULL );

 -- fill the parameters list
-- l_paramlist.extend;

 -- For raising events, the code forks from here on.

 -- On branch for Bulk Events and the other for raising one event per object
 IF l_g_bulk_type THEN
     ---------------------------------------
     -- Events must be raised in bulk
     ---------------------------------------
     LOG('Events must be raised in bulk.');
     LOG('Figure out the number of events that must be raised');
   -- raise the events in bulk
   -- figure out the number of events that must be raised.
   -- for person insert event
   OPEN c_chk_insevt (G_PER_BO_CODE);
   FETCH c_chk_insevt INTO l_p_ins_flag;
   CLOSE c_chk_insevt;
   -- for org insert event
   OPEN c_chk_insevt (G_ORG_BO_CODE);
   FETCH c_chk_insevt INTO l_o_ins_flag;
   CLOSE c_chk_insevt;
   -- for person cust insert event
   OPEN c_chk_insevt (G_PER_CUST_BO_CODE);
   FETCH c_chk_insevt INTO l_pc_ins_flag;
   CLOSE c_chk_insevt;
   -- for org cust insert event
   OPEN c_chk_insevt (G_ORG_CUST_BO_CODE);
   FETCH c_chk_insevt INTO l_oc_ins_flag;
   CLOSE c_chk_insevt;

   -- for person update event
   OPEN c_chk_updevt (G_PER_BO_CODE);
   FETCH c_chk_updevt INTO l_p_upd_flag;
   CLOSE c_chk_updevt;
   -- for org update event
   OPEN c_chk_updevt (G_ORG_BO_CODE);
   FETCH c_chk_updevt INTO l_o_upd_flag;
   CLOSE c_chk_updevt;
   -- for person cust update event
   OPEN c_chk_updevt (G_PER_CUST_BO_CODE);
   FETCH c_chk_updevt INTO l_pc_upd_flag;
   CLOSE c_chk_updevt;
   -- for org cust update event
   OPEN c_chk_updevt (G_ORG_CUST_BO_CODE);
   FETCH c_chk_updevt INTO l_oc_upd_flag;
   CLOSE c_chk_updevt;


 LOG('Updating BOT object hierarchy with event_id');
  -- update the object hierarchy in BOT, with event id
   HZ_BES_BO_UTIL_PKG.upd_bot_evtid_dt (
	 p_bulk_evt        => l_g_bulk_type,
	 p_evt_id          => NULL,
	 p_child_id        => NULL ,
	 p_child_bo_code   => NULL ,
	 p_creation_date   => l_cc_start_time,
  	 p_evt_type        => NULL,
  	 p_commit          => FALSE,
	 p_per_ins_evt_id  => l_perbo_c_evtid,
	 p_per_upd_evt_id => l_perbo_u_evtid,
	 p_org_ins_evt_id => l_orgbo_c_evtid,
	 p_org_upd_evt_id => l_orgbo_u_evtid,
	 p_perc_ins_evt_id => l_percustbo_c_evtid,
	 p_perc_upd_evt_id => l_percustbo_u_evtid,
	 p_orgc_ins_evt_id => l_orgcustbo_c_evtid,
	 p_orgc_upd_evt_id => l_orgcustbo_u_evtid);

  IF l_p_ins_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.PersonBO.create Event');
     LOG('CDH_EVENT_ID is: '||l_perbo_c_evtid);
    -- Raise oracle.apps.ar.hz.PersonBO.create Event
    l_event_name := 'oracle.apps.ar.hz.PersonBO.create';
    l_key := 'oracle.apps.ar.hz.PersonBO.create'||l_perbo_c_evtid;
    -- add parameters to list
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_perbo_c_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);

    /*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_perbo_c_evtid);
    l_paramlist(l_paramlist.last) := l_param;
    */
    BEGIN
        HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  IF l_o_ins_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.OrgBO.create Event');
     LOG('CDH_EVENT_ID is: '||l_orgbo_c_evtid);
    -- Raise oracle.apps.ar.hz.OrgBO.create Event
    l_event_name := 'oracle.apps.ar.hz.OrgBO.create';
    l_key := 'oracle.apps.ar.hz.OrgBO.create'||l_orgbo_c_evtid;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_orgbo_c_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_orgbo_c_evtid);
    l_paramlist(l_paramlist.last) := l_param;
*/
    BEGIN
      HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  IF l_pc_ins_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.PersonCustBO.create Event');
     LOG('CDH_EVENT_ID is: '||l_percustbo_c_evtid);
    -- Raise oracle.apps.ar.hz.PersonCustBO.create Event
    l_event_name := 'oracle.apps.ar.hz.PersonCustBO.create';
    l_key := 'oracle.apps.ar.hz.PersonCustBO.create'||l_percustbo_c_evtid;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_percustbo_c_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_percustbo_c_evtid);
    l_paramlist(l_paramlist.last) := l_param;
*/
    BEGIN
      HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  IF l_oc_ins_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.OrgCustBO.create Event');
     LOG('CDH_EVENT_ID is: '||l_orgcustbo_c_evtid);
    -- Raise oracle.apps.ar.hz.OrgCustBO.create Event
    l_event_name := 'oracle.apps.ar.hz.OrgCustBO.create';
    l_key := 'oracle.apps.ar.hz.OrgCustBO.create'||l_orgcustbo_c_evtid;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_orgcustbo_c_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_orgcustbo_c_evtid);
    l_paramlist(l_paramlist.last) := l_param;
*/
    BEGIN
      HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  IF l_p_upd_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.PersonBO.update Event');
     LOG('CDH_EVENT_ID is: '||l_perbo_u_evtid);
    -- Raise oracle.apps.ar.hz.PersonBO.update Event
    l_event_name := 'oracle.apps.ar.hz.PersonBO.update';
    l_key := 'oracle.apps.ar.hz.PersonBO.update'||l_perbo_u_evtid;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_perbo_u_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_perbo_u_evtid);
    l_paramlist(l_paramlist.last) := l_param;
*/
    BEGIN
      HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  IF l_o_upd_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.OrgBO.update Event');
     LOG('CDH_EVENT_ID is: '||l_orgbo_u_evtid);
    -- Raise oracle.apps.ar.hz.OrgBO.update Event
    l_event_name := 'oracle.apps.ar.hz.OrgBO.update';
    l_key := 'oracle.apps.ar.hz.OrgBO.update'||l_orgbo_u_evtid;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_orgbo_u_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_orgbo_u_evtid);
    l_paramlist(l_paramlist.last) := l_param;
*/

    BEGIN
      HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  IF l_pc_upd_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.PersonCustBO.update Event');
     LOG('CDH_EVENT_ID is: '||l_percustbo_u_evtid);
    -- Raise oracle.apps.ar.hz.PersonCustBO.update Event
    l_event_name := 'oracle.apps.ar.hz.PersonCustBO.update';
    l_key := 'oracle.apps.ar.hz.PersonCustBO.update'||l_percustbo_u_evtid;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_percustbo_u_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_percustbo_u_evtid);
    l_paramlist(l_paramlist.last) := l_param;
*/
    BEGIN
      HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  IF l_oc_upd_flag = 'Y' THEN
     LOG('Raise oracle.apps.ar.hz.OrgCustBO.update Event');
     LOG('CDH_EVENT_ID is: '||l_orgcustbo_u_evtid);
    -- Raise oracle.apps.ar.hz.OrgCustBO.update Event
    l_event_name := 'oracle.apps.ar.hz.OrgCustBO.update';
    l_key := 'oracle.apps.ar.hz.OrgCustBO.update'||l_orgcustbo_u_evtid;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_orgcustbo_u_evtid,
              p_parameterlist => l_paramlist);
    -- add Q_CORRELATION_ID parameter to the List
    wf_event.addParameterToList
             (p_name  => 'Q_CORRELATION_ID',
              p_value => l_event_name,
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_orgcustbo_u_evtid);
    l_paramlist(l_paramlist.last) := l_param;
*/
    BEGIN
      HZ_EVENT_PKG.raise_event(
          p_event_name        => l_event_name,
          p_event_key         => l_key,
          p_parameters        => l_paramlist);
          l_paramlist.DELETE;
    EXCEPTION
    WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       l_paramlist.DELETE;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  commit; -- explicit commit issued because BOT is stamped with event ids bfr

   -- This is the ER done as part of bug 4997605.
   -- write the objects for which bulk event were raised in bulk
   IF l_p_ins_flag = 'Y' THEN
    OPEN c_bot_log (l_perbo_c_evtid, G_PER_BO_CODE);
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_PER_BO_CODE||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log person.Create event objects end
   IF l_o_ins_flag = 'Y' THEN
    OPEN c_bot_log (l_orgbo_c_evtid, G_ORG_BO_CODE);
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_ORG_BO_CODE||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log Org.Create event objects end
  IF l_pc_ins_flag = 'Y' THEN
    OPEN c_bot_log (l_percustbo_c_evtid, G_PER_CUST_BO_CODE );
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_PER_CUST_BO_CODE ||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log PersonCust.Create event objects end
  IF l_oc_ins_flag = 'Y' THEN
    OPEN c_bot_log (l_orgcustbo_c_evtid, G_ORG_CUST_BO_CODE);
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_ORG_CUST_BO_CODE ||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log OrgCust.Create event objects end
  IF l_p_upd_flag = 'Y' THEN
    OPEN c_bot_log (l_perbo_u_evtid, G_PER_BO_CODE);
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_PER_BO_CODE||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log Person.Update event objects end
  IF l_o_upd_flag = 'Y' THEN
    OPEN c_bot_log (l_orgbo_u_evtid, G_ORG_BO_CODE);
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_ORG_BO_CODE||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log Org.Update event objects end
  IF l_oc_upd_flag = 'Y' THEN
    OPEN c_bot_log (l_orgcustbo_u_evtid, G_ORG_CUST_BO_CODE);
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_ORG_CUST_BO_CODE ||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log OrgCust.Update event objects end
  IF l_pc_upd_flag = 'Y' THEN
    OPEN c_bot_log (l_percustbo_u_evtid, G_PER_CUST_BO_CODE );
    FETCH c_bot_log BULK COLLECT INTO l_ids ,l_pids , l_evts ;
    CLOSE c_bot_log;
    FOR i IN l_ids.FIRST..l_ids.LAST LOOP
       LOG ('evt id:'||l_ids(i)||' party_id:'||l_pids(i)||' BO Code:'||G_PER_CUST_BO_CODE ||' evtType:'||l_evts(i));
    END LOOP;
   END IF; -- check to log PersonCust.Update event objects end

 ELSE
     ---------------------------------------
  -- raise the one event per object instance
     ---------------------------------------
  LOG('raise the one event per object instance');
 	OPEN c_bo_gt;
	FETCH c_bo_gt BULK COLLECT INTO l_ids, l_pids, l_bo_codes, l_evts ;
	CLOSE c_bo_gt;
	l_ct := l_pids.COUNT;
  LOG('Total count in GT is:'||to_char(l_ct));

	FOR i IN 1.. l_ct LOOP
    l_event_name := NULL;
    l_key := NULL;
    wf_event.addParameterToList
             (p_name  => 'CDH_EVENT_ID',
              p_value => l_ids(i),
              p_parameterlist => l_paramlist);
    wf_event.addParameterToList
             (p_name  => 'CDH_OBJECT_ID',
              p_value => l_pids(i),
              p_parameterlist => l_paramlist);
/*
    l_param.SetName( 'CDH_EVENT_ID' );
    l_param.SetValue(l_ids(i));
    l_paramlist.extend;
    l_param.SetName( 'CDH_OBJECT_ID' );
    l_param.SetValue(l_pids(i));
    l_paramlist(l_paramlist.last) := l_param;
*/
    LOG('CDH_EVENT_ID  is: '||l_ids(i));
    LOG('CDH_OBJECT_ID is: '||l_pids(i));
--    LOG(' party_id is:'||l_pids(i));
--    LOG(' event_id is:'||l_ids(i));
  	CASE
  	  WHEN (l_bo_codes(i) = G_PER_BO_CODE ) AND ( l_evts(i) = 'U' ) THEN
        l_event_name := 'oracle.apps.ar.hz.PersonBO.update';
        l_key := 'oracle.apps.ar.hz.PersonBO.update'||l_ids(i);
  	  WHEN (l_bo_codes(i) = G_ORG_BO_CODE ) AND ( l_evts(i) = 'U' ) THEN
        l_event_name := 'oracle.apps.ar.hz.OrgBO.update';
        l_key := 'oracle.apps.ar.hz.OrgBO.update'||l_ids(i);
  	  WHEN (l_bo_codes(i) = G_PER_CUST_BO_CODE ) AND ( l_evts(i) = 'U' ) THEN
        l_event_name := 'oracle.apps.ar.hz.PersonCustBO.update';
        l_key := 'oracle.apps.ar.hz.PersonCustBO.update'||l_ids(i);
  	  WHEN (l_bo_codes(i) = G_ORG_CUST_BO_CODE ) AND ( l_evts(i) = 'U' ) THEN
        l_event_name := 'oracle.apps.ar.hz.OrgCustBO.update';
        l_key := 'oracle.apps.ar.hz.OrgCustBO.update'||l_ids(i);
  	  WHEN (l_bo_codes(i) = G_PER_BO_CODE ) AND ( l_evts(i) IS NULL ) THEN
        l_event_name := 'oracle.apps.ar.hz.PersonBO.create';
        l_key := 'oracle.apps.ar.hz.PersonBO.create'||l_ids(i);
  	  WHEN (l_bo_codes(i) = G_ORG_BO_CODE ) AND ( l_evts(i) IS NULL) THEN
        l_event_name := 'oracle.apps.ar.hz.OrgBO.create';
        l_key := 'oracle.apps.ar.hz.OrgBO.create'||l_ids(i);
  	  WHEN (l_bo_codes(i) = G_PER_CUST_BO_CODE ) AND ( l_evts(i)  IS NULL ) THEN
        l_event_name := 'oracle.apps.ar.hz.PersonCustBO.create';
        l_key := 'oracle.apps.ar.hz.PersonCustBO.create'||l_ids(i);
  	  WHEN (l_bo_codes(i) = G_ORG_CUST_BO_CODE ) AND ( l_evts(i)  IS NULL ) THEN
        l_event_name := 'oracle.apps.ar.hz.OrgCustBO.create';
        l_key := 'oracle.apps.ar.hz.OrgCustBO.create'||l_ids(i);
  	ELSE
  	 LOG('invalid Bo and event_type_flag combination');
  	 LOG('BO code:'||l_bo_codes(i)||' evt type:'||l_evts(i));
  	END CASE;

    IF l_event_name IS NOT NULL THEN

      LOG('Updating BOT object hierarchy with event_id');
      -- update the object hierarchy in BOT, with event id
       HZ_BES_BO_UTIL_PKG.upd_bot_evtid_dt (
    	 p_bulk_evt        => l_g_bulk_type,
    	 p_evt_id          => l_ids(i),
    	 p_child_id        => l_pids(i),
    	 p_child_bo_code   => l_bo_codes(i),
  	 p_creation_date   => l_cc_start_time,
  	 p_evt_type        => nvl(l_evts(i),'C'),
  	 p_commit          => FALSE,
    	 p_per_ins_evt_id  => NULL,
    	 p_per_upd_evt_id => NULL,
    	 p_org_ins_evt_id => NULL,
    	 p_org_upd_evt_id => NULL,
    	 p_perc_ins_evt_id => NULL,
    	 p_perc_upd_evt_id => NULL,
    	 p_orgc_ins_evt_id => NULL,
    	 p_orgc_upd_evt_id => NULL);

      -- add Q_CORRELATION_ID parameter to the List
      wf_event.addParameterToList
               (p_name  => 'Q_CORRELATION_ID',
                p_value => l_event_name,
                p_parameterlist => l_paramlist);
      LOG('Raise '||l_event_name);
      /*
      IF SUBSTR(l_event_name,1,18) <> 'oracle.apps.ar.hz.' THEN
        LOG(' not a tca event ');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */
      BEGIN
      HZ_EVENT_PKG.raise_event(
        p_event_name        => l_event_name,
        p_event_key         => l_key,
        p_parameters        => l_paramlist);
      EXCEPTION
      WHEN OTHERS THEN
       LOG(SQLERRM);
       log('unable to raise event ||'||l_key);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       l_paramlist.DELETE;
      END;
      l_paramlist.DELETE;

     commit; -- explicit commit issued because BOT is stamped with event ids bfr
    END IF; --chk for event name not null ends

  END LOOP; -- end of loop for raising one event per object instance
 END IF; -- end of check to raise bulk event or not

 LOG('Updating hz_parties for future short circuiting');
 LOG( 'Person Business Object bo_version_number is: '||G_PER_BO_VER);
 LOG( 'Organization Business Object bo_version_number is: '||G_ORG_BO_VER);
 LOG( 'Person Customer Business Object bo_version_number is: '||G_PER_CUST_BO_VER);
 LOG( 'Organization Customer Business Object bo_version_number is: '||G_ORG_CUST_BO_VER);
 -- update the hz_parties bo_version number - so that any future
 -- runs of this concurrent program can figure out the event type by short circuiting
 HZ_BES_BO_UTIL_PKG.upd_hzp_bo_ver (
	 p_per_bo_ver   => G_PER_BO_VER,   -- for passing the person bo version number
	 p_org_bo_ver   => G_ORG_BO_VER,   -- for passing the org bo version number
	 p_perc_bo_ver  => G_PER_CUST_BO_VER, -- for passing the person cust bo version number
	 p_orgc_bo_ver  => G_ORG_CUST_BO_VER);-- for passing the org cust bo version number

-- LOG('Delete the records that were not part of any event from BOT');

LOG('Concurrent Program completed successfully.');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    outandlog('Error: Aborting concurrent program');
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    outandlog(SQLERRM);
    outandlog('Error: Aborting concurrent program');
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
  WHEN OTHERS THEN
    outandlog(SQLERRM);
    outandlog('Error: Aborting concurrent program');
    retcode := 2;
    errbuf := errbuf || logerror;
    FND_FILE.close;
END; -- bes_main

-------------------------------------------------------------------------
-------------------------------------------------------------------------
END HZ_BES_BO_RAISE_PKG; -- pkg

/
