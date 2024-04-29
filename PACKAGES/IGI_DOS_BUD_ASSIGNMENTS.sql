--------------------------------------------------------
--  DDL for Package IGI_DOS_BUD_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_BUD_ASSIGNMENTS" AUTHID CURRENT_USER AS
-- $Header: igidosis.pls 115.7 2002/09/05 12:14:35 dmahajan ship $
FUNCTION CREATE_VIEW    (p_coa_id          IN   number
                                        ) return varchar2;



END IGI_DOS_BUD_ASSIGNMENTS;

 

/
