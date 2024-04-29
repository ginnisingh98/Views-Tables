--------------------------------------------------------
--  DDL for Package INV_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONTROL" AUTHID CURRENT_USER as
/* $Header: INVCNTRLS.pls 120.1 2007/12/15 02:51:26 kajain ship $*/
   G_CURRENT_RELEASE_LEVEL       number := 120001;

   Function Get_Current_Release_Level return number;

End INV_CONTROL;

/
