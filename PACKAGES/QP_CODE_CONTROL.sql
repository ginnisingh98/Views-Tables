--------------------------------------------------------
--  DDL for Package QP_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CODE_CONTROL" AUTHID CURRENT_USER as
/* $Header: QPXCTRLS.pls 120.0 2005/06/02 00:18:30 appldev noship $ */

   CODE_RELEASE_LEVEL       varchar2(10) := '110510';

   Function Get_Code_Release_Level return varchar2;

End QP_CODE_CONTROL;

 

/
