--------------------------------------------------------
--  DDL for Package JL_CO_NIT_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_NIT_LIBRARY_1_PKG" AUTHID CURRENT_USER AS
/*  $Header: jlconl1s.pls 115.0 99/07/16 03:11:44 porting ship $  */

  FUNCTION nit_required (account IN VARCHAR2, sob_id IN NUMBER) return VARCHAR2;

END jl_co_nit_library_1_pkg;

 

/
