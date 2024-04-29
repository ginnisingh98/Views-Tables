--------------------------------------------------------
--  DDL for Package Body IBU_FNDPROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_FNDPROFILE" as
/* $Header: ibufndpb.pls 115.4 2002/11/26 03:30:23 nazhou noship $ */

procedure GET_SPECIFIC (
	name_z              in varchar2,
        user_id_z           in number,
        responsibility_id_z in number,
        application_id_z    in number,
        val_z               out nocopy varchar2,
        defined_z           out nocopy varchar2)
is
	defined_boolean_z   boolean;
begin
	FND_PROFILE.GET_SPECIFIC (
	name_z => name_z,
	user_id_z => user_id_z,
	responsibility_id_z =>responsibility_id_z,
	application_id_z => application_id_z ,
	val_z => val_z,
	defined_z => defined_boolean_z);

	if (defined_boolean_z) then
		defined_z := FND_API.G_TRUE;
	else
		defined_z := FND_API.G_FALSE;
	end if;

end GET_SPECIFIC;
function  SAVE (
	 X_NAME		    in varchar2,
	 X_VALUE	    in varchar2,
	 X_LEVEL_NAME 	    in varchar2,
	 X_LEVEL_VALUE	     in varchar2,
 	 X_LEVEL_VALUE_APP_ID in varchar2)
	return varchar2
is
	 l_success_boolean   boolean;
begin

	l_success_boolean := FND_PROFILE.SAVE (
	 X_NAME => X_NAME,
	 X_VALUE =>  X_VALUE,
	 X_LEVEL_NAME => X_LEVEL_NAME,
	 X_LEVEL_VALUE=>  X_LEVEL_VALUE,
 	 X_LEVEL_VALUE_APP_ID => X_LEVEL_VALUE_APP_ID);

	if (l_success_boolean) then
		return FND_API.G_TRUE;
	else
		return FND_API.G_FALSE;
	end if;


end SAVE;
end IBU_FNDPROFILE;

/
