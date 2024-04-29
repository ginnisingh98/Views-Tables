--------------------------------------------------------
--  DDL for Package CSM_SERVICEP_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SERVICEP_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuspws.pls 120.1 2005/07/25 01:17:38 trajasek noship $ */

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Anurag      06/09/02    Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


/***
  This function accepts a list of publication items and a publication item name and
  returns whether the item name was found within the item list.
  When the item name was found, it will be removed from the list.
***/
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
FUNCTION detect_conflict(p_user_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                                                              p_tran_id IN NUMBER,
                                                                              p_sequence IN NUMBER)
RETURN VARCHAR2 ;

-- End of DDL Script for Package APPS.CSM_SERVICEP_WRAPPER_PKG

END CSM_SERVICEP_WRAPPER_PKG; -- Package spec

 

/
