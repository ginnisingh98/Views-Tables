--------------------------------------------------------
--  DDL for Package WSH_FTE_ENABLED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FTE_ENABLED" AUTHID CURRENT_USER AS
/* $Header: WSHENBLS.pls 115.1 2002/11/12 01:33:40 nparikh ship $ */

/*
** -------------------------------------------------------------------------
** Function:    check_status
** Description: Checks to see if FTE is enabled
** Output:
**      There is no output parameter except return value
** Input:
**      There is no input parameter
** Returns:
**      'Y' if FTE enabled, else 'N'
**
** --------------------------------------------------------------------------
*/

function check_status return varchar2;
end WSH_FTE_ENABLED;

 

/
