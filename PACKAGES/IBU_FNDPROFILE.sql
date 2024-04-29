--------------------------------------------------------
--  DDL for Package IBU_FNDPROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_FNDPROFILE" AUTHID CURRENT_USER as
/* $Header: ibufndps.pls 115.3 2002/11/26 03:30:41 nazhou noship $ */
procedure GET_SPECIFIC (
	name_z              in varchar2,
        user_id_z           in number    default null,
        responsibility_id_z in number    default null,
        application_id_z    in number    default null,
        val_z               out nocopy varchar2,
        defined_z           out nocopy varchar2);
function  SAVE (
	 X_NAME		    in varchar2,
	 X_VALUE	    in varchar2,
	 X_LEVEL_NAME 	    in varchar2,
	 X_LEVEL_VALUE	     in varchar2,
 	 X_LEVEL_VALUE_APP_ID in varchar2)
	return varchar2;


end IBU_FNDPROFILE;

 

/
