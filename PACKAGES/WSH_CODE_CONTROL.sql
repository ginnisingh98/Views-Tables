--------------------------------------------------------
--  DDL for Package WSH_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CODE_CONTROL" AUTHID CURRENT_USER as
/* $Header: WSHCRCNS.pls 115.4 2003/08/05 20:45:01 nparikh ship $ */

   CODE_RELEASE_LEVEL       varchar2(10) := '110510';

   Function Get_Code_Release_Level return varchar2;

End WSH_CODE_CONTROL;

 

/
