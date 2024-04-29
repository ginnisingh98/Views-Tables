--------------------------------------------------------
--  DDL for Package IGS_SC_BULK_ASSIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SC_BULK_ASSIGN" AUTHID CURRENT_USER AS
/* $Header: IGSSC07S.pls 120.1 2005/09/08 15:40:26 appldev noship $ */

Procedure Assign_User_Attributes (
          ERRBUF out NOCOPY VARCHAR2,
          RETCODE out NOCOPY NUMBER,
          P_ORGUNIT_STR IN VARCHAR2 DEFAULT NULL,
          P_LOCATIONS_STR IN VARCHAR2 DEFAULT NULL,
          P_PGMTYPES_STR IN VARCHAR2 DEFAULT NULL,
          P_UNITMODE_STR IN VARCHAR2 DEFAULT NULL,
          P_USERROLES_STR_ONE IN VARCHAR2 DEFAULT NULL,
	  P_USERROLES_STR_TWO IN VARCHAR2 DEFAULT NULL,
          P_PRSNGRP_STR IN VARCHAR2);

procedure BulkSecAssignment(
            retValue OUT NOCOPY NUMBER,
            orgUnitStr IN VARCHAR2,
            locStr IN VARCHAR2,
            pgmStr IN VARCHAR2,
            unitMdStr IN VARCHAR2,
            userRolesStr_one IN VARCHAR2,
            userRolesStr_two IN VARCHAR2,
            prsnGrpStr IN VARCHAR2);

END IGS_SC_BULK_ASSIGN;


 

/
