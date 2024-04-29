--------------------------------------------------------
--  DDL for Package IGI_CHECK_VERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CHECK_VERSION" AUTHID CURRENT_USER AS
-- $Header: igicvers.pls 115.3 2002/09/05 12:10:38 dmahajan ship $
procedure IGI_CHECK_VER;
function igi_check_upg(coreVer IN Varchar2) return Varchar2;

END IGI_CHECK_VERSION;

 

/
