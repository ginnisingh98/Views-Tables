--------------------------------------------------------
--  DDL for Package CZ_RP_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_RP_MGR" AUTHID CURRENT_USER AS
/*  $Header: czrpmgrs.pls 115.9 2002/11/27 17:16:11 askhacha ship $	*/

   TYPE t_MIN_DELETED_FLAG IS TABLE OF CZ_RP_ENTRIES.DELETED_FLAG%TYPE
     INDEX BY BINARY_INTEGER;
/* This PL/SQL table handles the minimum values of DELETED_FLAG field from all
   object inside non-empty folders */
   V_MIN_DELETED_FLAGS t_MIN_DELETED_FLAG;
END CZ_RP_MGR;

 

/
