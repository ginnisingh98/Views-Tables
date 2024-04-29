--------------------------------------------------------
--  DDL for Package EAM_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTANTS" AUTHID CURRENT_USER AS
 /* $Header: EAMCONSS.pls 120.0 2005/05/25 15:57:23 appldev noship $ */

  MAX_NUMBER_PRECISION    CONSTANT NUMBER := 38;
  MAX_DISPLAYED_PRECISION CONSTANT NUMBER := 6;

  ------------------
  -- Lookup Codes --
  G_SHUTDOWN_TYPE CONSTANT VARCHAR2(30) := 'BOM_EAM_SHUTDOWN_TYPE';
  G_SUPPLY_TYPE CONSTANT VARCHAR2(30) := 'WIP_SUPPLY';
  G_OBJ_SOURCE CONSTANT VARCHAR2(30) := 'WIP_MAINTENANCE_OBJECT_SOURCE';
  G_OBJ_TYPE CONSTANT VARCHAR2(30) := 'WIP_MAINTENANCE_OBJECT_TYPE';
  G_ACT_SOURCE CONSTANT VARCHAR2(30) := 'MTL_EAM_ACTIVITY_SOURCE';
  G_ACT_CAUSE CONSTANT VARCHAR2(30) := 'MTL_EAM_ACTIVITY_CAUSE';
  G_ACT_TYPE CONSTANT VARCHAR2(30) := 'MTL_EAM_ACTIVITY_TYPE';
  G_WO_TYPE CONSTANT VARCHAR2(30) := 'WIP_EAM_WORK_ORDER_TYPE';
  G_AUTOCHARGE_TYPE CONSTANT VARCHAR2(30) := 'BOM_AUTOCHARGE_TYPE';
  G_ACT_PRIORITY CONSTANT VARCHAR2(30) := 'WIP_EAM_ACTIVITY_PRIORITY';
  G_OBJECT_TYPE CONSTANT VARCHAR2(30) := 'WIP_MAINTENANCE_OBJECT_TYPE';

  ------------------

 --EAM_ESTIMATION_STATUS
  PENDING    CONSTANT NUMBER := 1;
  RUNNING    CONSTANT NUMBER := 2;
  ERROR      CONSTANT NUMBER := 3;
  COMPLETE   CONSTANT NUMBER := 7;
  REESTIMATE CONSTANT NUMBER := 8;
  RUNREEST   CONSTANT NUMBER := 9;

/*=====================================================================+
 | PROCEDURE
 |   GET_ORA_ERROR
 |
 | PURPOSE
 |   Get the values of SQLCODE and SQLERRM and places a message on the
 |   message stack upon error
 |
 | ARGUMENTS
 |   IN
 |     application          Name of application; e.g. EAM, INV
 |     proc_name            Name of procedure or function where error occurred
 |
 | EXCEPTIONS
 |   Sets generic SQL error message and then calls FND_MESSAGE.ERROR to raise
 |   an exception.
 |
 | NOTES
 |
 +=====================================================================*/
  procedure get_ora_error (application VARCHAR2, proc_name VARCHAR2);

/*=====================================================================+
 | PROCEDURE
 |   INITIALIZE
 |
 | PURPOSE
 |   To instantiate the EAM_CONSTANTS package.
 |
 | ARGUMENTS
 |
 | EXCEPTIONS
 |
 | NOTES
 |   This procedure simply returns upon being called.  This is to initialize
 |   all the constants in this package.
 |
 +=====================================================================*/
  procedure initialize;

  --define the records locked exception
  RECORDS_LOCKED  EXCEPTION;
  PRAGMA EXCEPTION_INIT (RECORDS_LOCKED, -0054);

END EAM_CONSTANTS;

 

/
