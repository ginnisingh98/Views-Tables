--------------------------------------------------------
--  DDL for Package FF_DEL_GLOBAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_DEL_GLOBAL_PKG" AUTHID CURRENT_USER as
/* $Header: ffglb02t.pkh 120.0 2005/05/27 23:25:36 appldev noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    ff_del_global_pkg
  Purpose
    Package used to support delete operations on ff_globals_f.
  Notes

  History
    04-04-2001 K.Kawol     115.0        Date created.

 ============================================================================*/
--
 PROCEDURE Clear_Count ;
 PROCEDURE Add_Global (p_global_id in ff_globals_f.global_id%TYPE) ;
 PROCEDURE Delete_User_Entity;
--
END FF_DEL_GLOBAL_PKG;

 

/
