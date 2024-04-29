--------------------------------------------------------
--  DDL for Package Body QP_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CODE_CONTROL" as
/* $Header: QPXCTRLB.pls 120.0 2005/06/01 23:54:40 appldev noship $ */

   Function Get_Code_Release_Level
   return varchar2
   is
   Begin
      return QP_CODE_CONTROL.CODE_RELEASE_LEVEL;
   End Get_Code_Release_Level;

End QP_CODE_CONTROL;

/
