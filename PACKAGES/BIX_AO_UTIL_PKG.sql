--------------------------------------------------------
--  DDL for Package BIX_AO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_AO_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxaous.pls 115.5 2002/11/27 00:27:02 djambula noship $*/


FUNCTION bix_dm_get_ao_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION bix_dm_get_ao_refresh_date(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION bix_get_ao_a_otcm_footer(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION bix_get_ao_a_otcm_refresh_date(p_context IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

END BIX_AO_UTIL_PKG;

 

/
