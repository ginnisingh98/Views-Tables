--------------------------------------------------------
--  DDL for Package PAY_PAYFV_ELEMENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYFV_ELEMENT_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: payfvetp.pkh 115.0 2003/01/13 14:18:22 scchakra noship $ */
-------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 2001 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
        Supporting functions for BIS view PAYFV_ELEMENT_TYPES
Purpose
        To return non-id table information where needed to enhance the
        performance of the view.
History

rem
rem Version Date        Author         Comment
rem -------+-----------+--------------+----------------------------------------
rem 115.0   13-JAN-2003 Scchakra       Date Created
rem ==========================================================================
*/
--------------------------------------------------------------------------------
FUNCTION get_applsys_user (p_user_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
FUNCTION get_event_group_name (p_event_group_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------
END PAY_PAYFV_ELEMENT_TYPES_PKG;

 

/
