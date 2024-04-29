--------------------------------------------------------
--  DDL for Package PON_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_UTIL_PKG" AUTHID CURRENT_USER as
/*$Header: PONUTILS.pls 115.0 2002/03/15 11:21:24 pkm ship       $ */


PROCEDURE raise_error(p_error in varchar2);

PROCEDURE log_error(p_error in varchar2);

END PON_UTIL_PKG;

 

/
