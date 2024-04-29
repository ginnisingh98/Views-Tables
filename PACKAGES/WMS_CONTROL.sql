--------------------------------------------------------
--  DDL for Package WMS_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONTROL" AUTHID CURRENT_USER as
/* $Header: WMSCNTRLS.pls 120.1 2007/12/15 02:45:14 kajain ship $ */

   G_CURRENT_RELEASE_LEVEL       number := 120001;

   Function Get_Current_Release_Level return number;

End WMS_CONTROL;

/
