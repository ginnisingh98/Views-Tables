--------------------------------------------------------
--  DDL for Package QP_AM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_AM_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXAMUTS.pls 120.0 2005/06/02 00:44:06 appldev noship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME               CONSTANT  VARCHAR2(30) := 'QP_AM_UTIL';

/***********************************************************************
   Function to return the status of Attributes Manager Installation.
***********************************************************************/

FUNCTION Attrmgr_Installed RETURN VARCHAR2;

--   Function to return whether Organizer can be used for QUERY FIND from
--   Modifiers Summary and Qualifiers block in Modifier form

FUNCTION Use_Organizer_for_Query_Find RETURN VARCHAR2;

END QP_AM_UTIL;

 

/
