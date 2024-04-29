--------------------------------------------------------
--  DDL for Package JTM_HANDHELD_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_HANDHELD_WRAPPER_PKG" 
/* $Header: jtmhwrps.pls 120.1 2005/08/24 02:15:05 saradhak noship $*/
  AUTHID CURRENT_USER AS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name IN VARCHAR2,
           p_tranid   IN NUMBER
         );


/***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure when a record was successfully
  applied and needs to be deleted from the in-queue.
***/

PROCEDURE POPULATE_ACCESS_RECORDS ( p_userid in number);

PROCEDURE DELETE_ACCESS_RECORDS ( p_userid in number);

/*
  Call back function for ASG. used for create synonyms / grant accesses in mobileadmin schema
  before running installation manager
 */
FUNCTION check_olite_schema RETURN VARCHAR2;

END JTM_HANDHELD_WRAPPER_PKG; -- Package spec

 

/
