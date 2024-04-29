--------------------------------------------------------
--  DDL for Package Body PON_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_UTIL_PKG" as
/*$Header: PONUTILB.pls 115.1 2002/07/16 22:34:40 dawillia noship $ */

PROCEDURE raise_error(p_error in varchar2) is
BEGIN
    raise_application_error(-20101,p_error,true);
END;

PROCEDURE log_error(p_error in varchar2) is
BEGIN
    -- do nothing for now
    null;
END;

END PON_UTIL_PKG;

/
