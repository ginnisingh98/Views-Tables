--------------------------------------------------------
--  DDL for Package Body FND_PROFILE_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROFILE_SERVER" as
/* $Header: AFPFPRSB.pls 115.0 99/07/16 23:25:46 porting ship  $ */

/*
** PUT - sets a profile option to a value for this session,
**       but doesn't save to the database
*/
procedure PUT(NAME in varchar2, VAL in varchar2)
is
begin
  fnd_profile.put(name, val);
end PUT;

/*
** DEFINED - returns TRUE if a profile option has been stored
*/
function  DEFINED(NAME in varchar2) return boolean
is
begin
  return(fnd_profile.defined(name));
end DEFINED;

/*
** GET - gets the value of a profile option
*/
procedure GET(NAME in varchar2, VAL out varchar2)
is
begin
  fnd_profile.get(name, val);
end GET;

/*
** VALUE - returns the value of a profile options
*/
function  VALUE(NAME in varchar2) return varchar2
is
begin
  return(fnd_profile.value(name));
end VALUE;

/*
** VALUE_WNPS - returns the value of a profile option without caching it.
**
**            The main usage for this routine would be in a SELECT statement
**            where VALUE() is not allowed since it writes package state.
**
**            This routine does the same thing as VALUE(); it returns
**            a profile value from the profile cache, or from the database
**            if it isn't already in the profile cache already.  The only
**            difference between this and VALUE() is that this will not
**            put the value into the cache if it is not already there, so
**            repeated calls to this can be slower because it will have
**            to hit the database each time for the profile value.
**
**            In most cases, however, you can and should use VALUE() instead
**            of VALUE_WNPS(), because VALUE() will give better performance.
*/
function  VALUE_WNPS(NAME in varchar2) return varchar2
is
begin
  return(fnd_profile.value_wnps(name));
end VALUE_WNPS;


/*
** SAVE_USER - Sets the value of a profile option permanently
**             to the database, at the user level for the current user.
**             Also saves in the profile cache for this database session.
**             Note that this will not save in the profile caches
**             for any other database sessions that may be up, so those
**             could potentially be out of sync. This routine will not
**             actually commit the changes; the caller must commit.
**
**  returns: TRUE if successful, FALSE if failure.
**
*/
function SAVE_USER(
		   X_NAME in varchar2,  /* Profile name you are setting */
		   X_VALUE in varchar2 /* Profile value you are setting */
) return boolean
is
begin
  return(fnd_profile.save_user(x_name, x_value));
end SAVE_USER;

/*
** SAVE - sets the value of a profile option permanently
**        to the database, at any level.  This routine can be used
**        at runtime or during patching.  This routine will not
**        actually commit the changes; the caller must commit.
**        ('SITE', 'APPL', 'RESP', or 'USER').
**        Examples of use:
**        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'SITE');
**        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'APPL', 321532);
**        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'RESP', 321532, 345234);
**        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'USER', 123321);
**
**  returns: TRUE if successful, FALSE if failure.
**
*/
function SAVE(X_NAME in varchar2,  /* Profile name you are setting */
              X_VALUE in varchar2, /* Profile value you are setting */
              X_LEVEL_NAME in varchar2,/* Level that youre setting at: */
                                       /* 'SITE', 'APPL', 'RESP', or 'USER' */
              X_LEVEL_VALUE in varchar2 default NULL,
                  /* Level value that you are setting at. */
                  /*  e.g. user id for 'USER' level.  */
                  /* X_LEVEL_VALUE is not used at site level. */
              X_LEVEL_VALUE_APP_ID in varchar2 default NULL
                                            /* Only used for 'RESP' level; */
                        		    /* Resp Application_Dd. */
) return boolean
is
begin
 return(fnd_profile.save(x_name, x_value, x_level_name, x_level_value,
        x_level_value_app_id));
end SAVE;

/*
** GET_SPECIFIC - Get profile value for a specific user/resp/appl combo
**   Default is user/resp/appl is current login.
*/
procedure GET_SPECIFIC(NAME_Z              in varchar2,
                       USER_ID_Z           in number default null,
                       RESPONSIBILITY_ID_Z in number default null,
                       APPLICATION_ID_Z    in number default null,
                       VAL_Z               out varchar2,
                       DEFINED_Z           out boolean)
is
begin
  fnd_profile.get_specific(name_z, user_id_z, responsibility_id_z,
      application_id_z, val_z, defined_z);
end GET_SPECIFIC;


/*
** VALUE_SPECIFIC - Get profile value for a specific user/resp/appl combo
**   Default is user/resp/appl is current login.
*/
function VALUE_SPECIFIC(NAME              in varchar2,
                        USER_ID           in number default null,
                        RESPONSIBILITY_ID in number default null,
                        APPLICATION_ID    in number default null)
return varchar2
is
begin
  return(fnd_profile.value_specific(name, user_id,
         responsibility_id, application_id));
end VALUE_SPECIFIC;

end FND_PROFILE_SERVER;

/