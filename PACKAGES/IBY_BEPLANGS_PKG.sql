--------------------------------------------------------
--  DDL for Package IBY_BEPLANGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BEPLANGS_PKG" AUTHID CURRENT_USER as
/*$Header: ibybepls.pls 115.6 2002/10/02 22:21:29 jleybovi ship $*/

/*
** Procedure: createBEPLangs
** Purpose:  creates the beplang information,
**           replace previous entries, if any
*/
procedure createBEPLangs( i_bepid in iby_beplangs.bepid%type,
                          i_preNLSLang in iby_beplangs.beplang%type,
                          i_opt1NLSLang in iby_beplangs.beplang%type,
                          i_opt2NLSLang in iby_beplangs.beplang%type);

end iby_beplangs_pkg;

 

/
