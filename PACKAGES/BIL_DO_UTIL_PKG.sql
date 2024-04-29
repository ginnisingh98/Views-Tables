--------------------------------------------------------
--  DDL for Package BIL_DO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_DO_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: bildouts.pls 115.8 2002/01/29 13:55:54 pkm ship      $ */

 PROCEDURE Write_Log (
      p_msg      VARCHAR2
     ,p_stime    DATE DEFAULT NULL
     ,p_etime    DATE DEFAULT NULL
     ,p_debug    VARCHAR2 DEFAULT 'N'
     ,p_force    VARCHAR2 DEFAULT 'N'
    );

 END BIL_DO_UTIL_PKG;


 

/
