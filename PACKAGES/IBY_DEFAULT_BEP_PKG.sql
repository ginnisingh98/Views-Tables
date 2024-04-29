--------------------------------------------------------
--  DDL for Package IBY_DEFAULT_BEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DEFAULT_BEP_PKG" AUTHID CURRENT_USER as
/*$Header: ibydbeps.pls 115.5 2002/10/04 20:07:04 jleybovi ship $*/

/*
** Function: modifyBep.
** Purpose:  modifies rule condition information in the database.
*/
procedure modifyBep (
               i_instrtype in iby_default_bep.instrtype%type,
               i_bepid in iby_default_bep.bepid%type,
               i_version in iby_default_bep.object_version_number%type);

end iby_default_bep_pkg;

 

/
