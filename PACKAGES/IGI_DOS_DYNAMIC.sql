--------------------------------------------------------
--  DDL for Package IGI_DOS_DYNAMIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_DYNAMIC" AUTHID CURRENT_USER AS
-- $Header: igidosbs.pls 115.7 2002/09/05 12:11:34 dmahajan ship $
FUNCTION CREATE_SOURCE_ACCOUNTS_VIEW    (p_coa_id          IN   number
                                        ) return varchar2;

FUNCTION CREATE_DEST_ACCOUNTS_VIEW      (p_coa_id          IN   number
                                        ) return varchar2;



END IGI_DOS_DYNAMIC;

 

/
