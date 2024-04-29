--------------------------------------------------------
--  DDL for Package IBY_BEPKEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BEPKEYS_PKG" AUTHID CURRENT_USER as
/*$Header: ibybepks.pls 115.11 2002/11/16 00:55:14 jleybovi ship $*/


/*
** Precedure: deleteBEPKeys
** Purpose: delete ALL bepkeys associated with a payee
**
**
*/
procedure deleteBEPKeys(i_ownerid in iby_bepkeys.ownerid%type,
			i_ownertype in iby_bepkeys.ownertype%type);


/*
** Procedure: createBEPKey.
** Purpose: creates a SINGLE bep key entry in iby_bepkeys table
** parameters: i_ownerid, i_ownertype identifies the owner of the key.
**             i_bepid, id of the back end payment systems.
*/
procedure createBEPKey(i_bepid in iby_bepinfo.bepid%type,
                      i_ownertype in iby_bepkeys.ownertype%type,
                      i_ownerid in iby_bepkeys.ownerid%type,
                      i_key in iby_bepkeys.key%type,
                      i_default in iby_bepkeys.defaults%type);
end iby_bepkeys_pkg;

 

/
