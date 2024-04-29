--------------------------------------------------------
--  DDL for Package Body OE_FEATURES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FEATURES_PVT" AS
/* $Header: OEXVNEWB.pls 115.4 2003/10/20 07:24:49 appldev ship $ */
--------------------------------------------------------------------
--Margin should only avail for pack I
--This is wrapper to a call to OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL
--------------------------------------------------------------------
Function Is_Margin_Avail return Boolean Is
l_release_level Varchar2(15);
l_correct_release Boolean;
Begin
 l_release_level:=Oe_Code_Control.Get_Code_Release_Level;

 If l_release_level >= '110509' Then
  l_correct_release:=True;
 Else
  l_correct_release:=False;
 End If;

 --Always return false first for checkin version. Will turn on
 --Return false;

 IF not l_correct_release then
    Return false;
 ELSE
   Return True;
 End IF;



End;

End OE_FEATURES_PVT;

/
