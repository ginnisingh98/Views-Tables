--------------------------------------------------------
--  DDL for Package OE_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CODE_CONTROL" AUTHID CURRENT_USER as
/* $Header: OEXCRCNS.pls 120.2 2008/05/20 09:36:07 nshah noship $ */

   CODE_RELEASE_LEVEL       varchar2(10) := '120100';

   Function Get_Code_Release_Level return varchar2;

End OE_CODE_CONTROL;

/
