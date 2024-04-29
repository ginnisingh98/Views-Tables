--------------------------------------------------------
--  DDL for Package IBY_ECAPP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ECAPP_PKG" AUTHID CURRENT_USER as
/*$Header: ibyecaps.pls 115.8 2002/11/18 22:04:37 jleybovi ship $*/

/*
** Function: ecappExists.
** Purpose: Check if the specified ecappid exists or not.
*/
function ecappExists(i_ecappid in iby_ecapp.ecappid%type)
return boolean;


/*
** Name : iby_ecapp_pkg
** Purpose : Provides interface to register an ecapp application.
**           Using ecapp id, information about the ecapp can be
**           retrieved.
*/
/*
** Procedure Name : createEcApp
** Purpose : creates an entry in the ecapp table. Returns the id created
**           by the system.
**
** Parameters:
**
**    In  : i_ecappname
**    Out : io_ecappid.
**
*/
procedure createEcApp(i_ecappname iby_ecapp.name%type,
			i_app_short_name iby_ecapp.application_short_name%type,
                      io_ecappid in out nocopy iby_ecapp.ecappid%type);


/*
** Procedure Name : modEcApp
** Purpose : modifies an entry in the ecapp table corresponding to id.
**
** Parameters:
**
**    In  : i_ecappname, i_ecappid
**    Out : None
*/
procedure modEcApp(i_ecappid iby_ecapp.ecappid%type,
                   i_ecappname iby_ecapp.name%type,
		i_app_short_name iby_ecapp.application_short_name%type,
		   i_object_version iby_ecapp.object_version_number%type);
end iby_ecapp_pkg;

 

/
