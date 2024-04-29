--------------------------------------------------------
--  DDL for Package Body ALR_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_PROFILE" as
/* $Header: ALPROFLB.pls 115.1 99/07/16 19:01:22 porting ship $ */

    type VAL_TAB_TYPE    is table of varchar2(2000) index by binary_integer;
    type NAME_TAB_TYPE   is table of varchar2(80)   index by binary_integer;

    /*
    ** define the internal table that will cache the profile values
    ** val_tab(x) is associated with name_tab(x)
    */
    VAL_TAB       VAL_TAB_TYPE;    /* the table of values */
    NAME_TAB      NAME_TAB_TYPE;   /* the table of names */
    TABLE_SIZE    binary_integer := 0;  /* the size of above tables*/


    /*
    ** FIND - find index of an option name
    **
    ** RETURNS
    **    table index if found, TABLE_SIZE if not found.
    */
    function FIND(NAME in varchar2) return binary_integer is
        TAB_INDEX  binary_integer;
        FOUND      boolean;
    begin
        TAB_INDEX := 0;
        FOUND     := false;

        while (TAB_INDEX < TABLE_SIZE) and (not FOUND) loop
            if NAME_TAB(TAB_INDEX) = NAME then
                FOUND := true;
            else
                TAB_INDEX := TAB_INDEX + 1;
            end if;
        end loop;

        return TAB_INDEX;
    end;


    /*
    ** GET_DB - Get profile value from database
    */
    procedure GET_DB(NAME_Z     in varchar2,
                     VAL_Z      out varchar2,
                     DEFINED_Z  out boolean) is

    cursor C1 is
       select profile_option_value
       from   alr_profile_options
       where  profile_option_name = NAME_Z;

    begin

       /* fetch the profile values on out of the database */
       open C1;
       fetch C1 into VAL_Z;

       if (C1%NOTFOUND) then
           VAL_Z     := NULL;
           DEFINED_Z := FALSE;
       else
           DEFINED_Z := TRUE;
       end if;

       close C1;

    end GET_DB;



    /*
    ** PUT - Update or Insert a profile option value
    */
    procedure PUT(NAME in varchar2, VAL in varchar2) is
        TABLE_INDEX binary_integer;
    begin
        /*
        ** search for the option name
        */
        TABLE_INDEX := FIND(NAME);

        if TABLE_INDEX < TABLE_SIZE then
            /*
            ** if found, set the value
            */
            VAL_TAB(TABLE_INDEX)   := VAL;
        else
            /*
            ** if not found, create a new option
            */
            VAL_TAB(TABLE_SIZE)    := VAL;
            NAME_TAB(TABLE_SIZE)   := NAME;
            TABLE_SIZE := TABLE_SIZE + 1;
        end if;

    exception
        when others then
            null;
    end;

    /*
    ** GET - get the value of a profile option
    **
    ** NOTES
    **    If the option cannot be found, the out buffer is set to NULL.
    **    Use the DEFINED function to check if a profile option exists.
    */
    procedure GET(NAME in varchar2, VAL out varchar2) is
        TABLE_INDEX binary_integer;
        DEFINED     boolean;
        OUTVAL      varchar2(2000);
    begin
        /*
        ** search for the option
        */
        TABLE_INDEX := FIND(NAME);

        if TABLE_INDEX < TABLE_SIZE then
            VAL := VAL_TAB(TABLE_INDEX);
        else
            /* Can't find profile in the cached table; look in the db */
            GET_DB(NAME, OUTVAL, DEFINED);
            if (defined) then
               /* put the value into the table */
               VAL_TAB(TABLE_SIZE)    := OUTVAL;
               NAME_TAB(TABLE_SIZE)   := NAME;
               TABLE_SIZE             := TABLE_SIZE + 1;
               VAL := OUTVAL;
            else
               VAL := null;
            end if;
        end if;

    exception
        when others then
            null;
    end;



    /*
    ** value - get profile value, return as function value
    */
    function VALUE(NAME in varchar2) return varchar2 is
        RETVALUE varchar2(2000);
    begin
        GET(NAME, RETVALUE);
        return (RETVALUE);
    end;


begin
    /*
    ** initialization section
    */
    TABLE_SIZE   := 0;

end ALR_PROFILE;

/
