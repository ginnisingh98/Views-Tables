--------------------------------------------------------
--  DDL for Package Body JTM_HANDHELD_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_HANDHELD_WRAPPER_PKG" 
/* $Header: jtmhwrpb.pls 120.1 2006/01/13 01:17:37 utekumal noship $*/
AS
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
/*** Globals ***/
g_debug_level           NUMBER; -- debug level
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_SERVICEP_WRAPPER_PKG';


/***
  This procedure is called by ASG_APPLY.PROCESS_UPLOAD when a publication item for publication SERVICEL
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will detect which publication items got dirty and will execute the wrapper
  procedures which will insert the data that came from mobile into the backend tables using public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name IN VARCHAR2,
           p_tranid    IN NUMBER
         ) IS
BEGIN

null ;
END APPLY_CLIENT_CHANGES;




/**
 *  POPULATE_ACCESS_RECORDS
 *  is the bootstrap procedure called by MDG upon CSM user creation
 *  we need to iterate over the responsibilities assigned to this CSM user
 *  and call the CSM_WF_PKG.User_Resp_Post_Ins(user_id, resp_id)
 */
PROCEDURE POPULATE_ACCESS_RECORDS ( p_userid IN NUMBER)
IS
BEGIN
null ;
END POPULATE_ACCESS_RECORDS;  -- end POPULATE_ACCESS_RECORDS

/**
 *  DELETE_ACCESS_RECORDS
 *  is the bootstrap procedure called by MDG upon CSM user deletion
 *  we need to iterate over the responsibilities assigned to this CSM user
 *  and call the CSM_WF_PKG.User_Resp_Post_Ins(user_id, resp_id)
 */
PROCEDURE DELETE_ACCESS_RECORDS ( p_userid in number)
IS
BEGIN
null ;
END DELETE_ACCESS_RECORDS;  -- end DELETE_ACCESS_RECORDS

/*
  Call back function for ASG. used for create synonyms / grant accesses in mobileadmin schema
  before running installation manager
 */
FUNCTION CHECK_OLITE_SCHEMA RETURN VARCHAR2  IS
  l_count NUMBER;
BEGIN
SELECT count(1) INTO l_count
  FROM all_synonyms
  WHERE SYNONYM_NAME = 'FND_GLOBAL' and owner = 'MOBILEADMIN';
  IF l_count = 0 THEN
    -- csm_util_pkg.log(' synonym mobileadmin.FND_GLOBAL does not exist');
    EXECUTE IMMEDIATE 'create synonym mobileadmin.FND_GLOBAL for FND_GLOBAL';
  END IF;

RETURN 'Y';

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'N';
END  CHECK_OLITE_SCHEMA;

   -- Enter further code below as specified in the Package spec.
END JTM_HANDHELD_WRAPPER_PKG;

/
