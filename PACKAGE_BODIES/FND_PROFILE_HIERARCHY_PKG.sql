--------------------------------------------------------
--  DDL for Package Body FND_PROFILE_HIERARCHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROFILE_HIERARCHY_PKG" as
/* $Header: AFPOMPHB.pls 120.1 2005/07/02 04:13:07 appldev noship $ */

/*
**  HIERARCHY_SWITCH_TYPE constants
*/

TYPE_SECURITY_2_SERVRESP CONSTANT  INTEGER := 1;
TYPE_SERVRESP_2_SECURITY CONSTANT  INTEGER := 2;
TYPE_SERVER_2_SERVRESP   CONSTANT  INTEGER := 3;
TYPE_SERVRESP_2_SERVER   CONSTANT  INTEGER := 4;
TYPE_IGNORE              CONSTANT  INTEGER := -1;


/*
** ROW TYPE
ROW_INSERTABLE CONSTANT INTEGER := 1;
ROW_UPDATABLE  CONSTANT INTEGER := 2;
ROW_IGNORABLE  CONSTANT INTEGER := 3;

*/

/*
* Global types to hold the fetched values.
*/

TYPE profile_value is TABLE OF FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE
      INDEX BY BINARY_INTEGER;
TYPE profile_level is TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

/*
** Although similar definitions for CURSOR, One is used for present
** hierarchy type and the other is used for target hierarchy.
** Using the same cursor raises in a nested for loop, cursor_already_open.
*/
CURSOR pov(appl_id number,  prof_id number, lev_id number) IS
   SELECT profile_option_value, level_value, level_value_application_id, level_value2
   FROM fnd_profile_option_values
   WHERE application_id = appl_id
   AND   profile_option_id = prof_id
   AND   level_id = lev_id;


/*
** Collection to hold profile values at target hierarchy level
*/
g_prof_val_4_update profile_value;

/*
** Collection to hold profile values at source hierarchy level
*/
g_prof_val_4_insert profile_value;

/*
** Collection to hold profile level values at target hierarchy level
*/
g_lev_val_4_update  profile_level;

/*
** Collection to hold profile level values at source hierarchy level
*/
g_lev_val_4_insert  profile_level;

/*
** Collection to hold profile level application id values at target hierarchy level
*/
g_lev_val_appl_4_update profile_level;

/*
** Collection to hold profile level application id values at source hierarchy level
*/
g_lev_val_appl_4_insert profile_level;

/*
** define variable to hold the HIERARCHY_SWITCH_TYPE
*/
g_type integer;

/*
** 10003, if g_type = TYPE_SECURITY_2_SERVRESP
** 10007, if g_type = TYPE_SERVRESP_2_SECURITY
** 10005, if g_type = TYPE_SERVER_2_SERVRESP
** 10007, if g_type = TYPE_SERVRESP_2_SERVER
**
*/
g_from_lev_id number;

/*
** 10007, if g_type = TYPE_SECURITY_2_SERVRESP
** 10003, if g_type = TYPE_SERVRESP_2_SECURITY
** 10007, if g_type = TYPE_SERVER_2_SERVRESP
** 10005, if g_type = TYPE_SERVRESP_2_SERVER
**
*/
g_to_lev_id   number;


/*
* RESET - AOL Internal only.
*         resets the global internal package variables.
*/
procedure reset
is
begin
 g_lev_val_4_update.delete;
 g_lev_val_4_insert.delete;
 g_lev_val_appl_4_update.delete;
 g_lev_val_appl_4_insert.delete;
 g_prof_val_4_update.delete;
 g_prof_val_4_insert.delete;

 g_type := null;
 g_from_lev_id := null;
 g_to_lev_id   :=null;

end reset;


/*
** SET_TYPE -  AOL Internal only
**
** Sets g_type, g_from_lev_id and g_to_lev_id values.
** If the switch is ignorable, type is set to TYPE_IGNORABLE.
** A hierarchy switch is  ignorable if either source or destination
** hierarchy types are not in (SERVRESP, SERVER, SECURITY) and one of
** source or target hierarchy levels is not SERVRESP.
*/
procedure set_type( x_profile_option_name varchar2,
                    x_hierarchy_type varchar2
)
is
 l_db_hierarchy_type varchar2(8);
 non_existant_profile exception;
begin
    select hierarchy_type into l_db_hierarchy_type
    from fnd_profile_options
    where profile_option_name = x_profile_option_name;

    if( upper(x_hierarchy_type) = 'SERVRESP') then
        if ( upper(l_db_hierarchy_type) = 'SECURITY') then
               g_type := TYPE_SECURITY_2_SERVRESP;
               g_from_lev_id := 10003;
               g_to_lev_id := 10007;
               return;
        end if;

        if ( upper(l_db_hierarchy_type) = 'SERVER') then
               g_type := TYPE_SERVER_2_SERVRESP;
               g_from_lev_id := 10005;
               g_to_lev_id := 10007;
               return;
        end if;
    end if;

    if( upper(l_db_hierarchy_type) = 'SERVRESP') then
        if ( upper(x_hierarchy_type) = 'SECURITY') then
               g_type := TYPE_SERVRESP_2_SECURITY;
               g_from_lev_id := 10007;
               g_to_lev_id := 10003;
               return;
        end if;
        if ( upper(x_hierarchy_type) = 'SERVER') then
               g_type := TYPE_SERVRESP_2_SERVER;
               g_from_lev_id := 10007;
               g_to_lev_id := 10005;
               return;
        end if;
    end if;

        g_type := TYPE_IGNORE;

exception
  when no_data_found then
           --  g_type := TYPE_IGNORE;
           raise non_existant_profile;
end set_type;


/*
** IS_FROM_ROW_VALID - AOL Internal only.
**
** returns true if the row at source hierarchy level
** has valid values at LEVEL_VALUE, LEVEL_VALUE_APPLICATION_ID and
** LEVEL_VALUE2.
**/
function is_from_row_valid(  x_lev_val number,
                             x_lev_val_appl number,
                             x_lev_val2 number
                               )
return boolean
is
begin
             if( g_type = TYPE_SERVRESP_2_SECURITY) then
                             if(x_lev_val2 = -1)
                             then
                                     return TRUE;
                             end if;
             end if;

             if( g_type = TYPE_SECURITY_2_SERVRESP) then
                             if(x_lev_val2 is null)
                             then
                                     return TRUE;
                             end if;
             end if;

             if( g_type = TYPE_SERVRESP_2_SERVER) then
                           if( x_lev_val = -1) and ( x_lev_val_appl = -1)
                             then
                                     return TRUE;
                             end if;
             end if;
             if( g_type = TYPE_SERVER_2_SERVRESP) then
                            if( x_lev_val2 is null ) and ( x_lev_val_appl is null )
                             then
                                     return TRUE;
                             end if;
             end if;

             return FALSE;

end is_from_row_valid;

/*
** IS_TO_ROW_VALID - AOL Internal only.
**
** returns true if the row at target hierarchy level
** has valid values at LEVEL_VALUE, LEVEL_VALUE_APPLICATION_ID and
** LEVEL_VALUE2.
**/
function is_to_row_valid(  x_lev_val number,
                           x_lev_val_appl number,
                           x_lev_val2 number
                               )
return boolean
is
begin

             if( g_type = TYPE_SERVRESP_2_SECURITY) then
                             if (x_lev_val2 is null)
                             then
                                     return TRUE;
                             end if;
             end if;

             if( g_type = TYPE_SECURITY_2_SERVRESP) then
                             if (x_lev_val2 = -1 )
                             then
                                     return TRUE;
                             end if;
             end if;

             if( g_type = TYPE_SERVRESP_2_SERVER) then
                           if( x_lev_val2 is null and  x_lev_val_appl is null)
                             then
                                     return TRUE;
                             end if;
             end if;
             if( g_type = TYPE_SERVER_2_SERVRESP) then
                            if( x_lev_val = -1  and  x_lev_val_appl = -1 )
                             then
                                     return TRUE;
                             end if;
             end if;

             return FALSE;
end is_to_row_valid;

/*
** IS_ROW_UPDATABLE - AOL Internal only.
**
** returns true if the profile option value
** at the target hierarchy level can be considered
** updatable.
**/
function is_row_updatable(      x_from_lev_val number,
                                x_to_lev_val   number,
                                x_from_lev_val_appl number,
                                x_to_lev_val_appl   number,
                                x_from_lev_val2 number,
                                x_to_lev_val2   number
                               )
return boolean
is
begin
             if( is_to_row_valid (  x_to_lev_val,x_to_lev_val_appl, x_to_lev_val2) )then
                  if(g_type = TYPE_SERVRESP_2_SECURITY or g_type = TYPE_SECURITY_2_SERVRESP) then
                           if (x_from_lev_val = x_to_lev_val and x_from_lev_val_appl = x_to_lev_val_appl)
                           then
                                          return TRUE;
                           end if;
                  end if;

                  if(g_type = TYPE_SERVRESP_2_SERVER ) then
                           if (x_from_lev_val2 = x_to_lev_val) then
                                         return TRUE;
                           end if;
                  end if;

                  if(g_type = TYPE_SERVER_2_SERVRESP ) then
                           if (x_from_lev_val = x_to_lev_val2) then
                                         return TRUE;
                           end if;
                  end if;
             end if;

             return FALSE;

end is_row_updatable;


/*
** ADD_ROWS - AOL INTERNAL ONLY
** The procedure separates insertable and updatable rows and
** collects them into global collections.
*/
procedure add_rows(x_profile_value_c in out nocopy  profile_value ,
                   x_level_value_c  in out nocopy profile_level,
                   x_level_val_appl_id_c  in out nocopy profile_level,
                   x_profile_value varchar2,
                   x_level_value number,
                   x_level_value_appl_id number,
                   x_level_value2 number,
                   x_prof_ind number,
                   x_mode number)
is
begin
                             x_profile_value_c(x_prof_ind) := x_profile_value;

                             if( g_type = TYPE_SERVRESP_2_SECURITY or g_type = TYPE_SECURITY_2_SERVRESP) then
                                    x_level_value_c(x_prof_ind) := x_level_value;
                                    x_level_val_appl_id_c(x_prof_ind):= x_level_value_appl_id;
                             end if;

                             if ( g_type = TYPE_SERVRESP_2_SERVER ) then
                                   if( x_mode = INSERT_ONLY) then
                                       x_level_value_c(x_prof_ind) := x_level_value2;
                                       x_level_val_appl_id_c(x_prof_ind):= null;
                                   end if;

                                   if( x_mode = UPDATE_ONLY) then
                                       x_level_value_c(x_prof_ind) := x_level_value;
                                       x_level_val_appl_id_c(x_prof_ind):= null;
                                   end if;
                             end if;

                             if ( g_type = TYPE_SERVER_2_SERVRESP ) then
                                   if( x_mode = INSERT_ONLY) then
                                       x_level_value_c(x_prof_ind) := x_level_value;
                                       x_level_val_appl_id_c(x_prof_ind):= -1;
                                   end if;

                                   if( x_mode = UPDATE_ONLY) then
                                       x_level_value_c(x_prof_ind) := x_level_value2;
                                       x_level_val_appl_id_c(x_prof_ind):= -1;
                                   end if;
                             end if;
end add_rows;

/*
** COLLECT_INSERTABLE_ROWS - AOL INTERNAL ONLY
** The procedure collects insertable rows.
*/
procedure collect_insertable_rows(x_appl_id number,
               x_prof_id number
)
is
   cursor pov_to(appl_id number,  prof_id number, lev_id number) is
   select profile_option_value, level_value, level_value_application_id, level_value2
   from fnd_profile_option_values
   where application_id = appl_id
   and   profile_option_id = prof_id
   and   level_id = lev_id;

   l_row_type number;
   l_prof_ind number:=0;
   l_is_insertable boolean;
begin
 FOR from_rec IN pov(x_appl_id, x_prof_id, g_from_lev_id) LOOP
           if ( is_from_row_valid(
                                  from_rec.level_value,
                                  from_rec.level_value_application_id,
                                  from_rec.level_value2
                               )
              ) then
                l_is_insertable := TRUE;
                l_prof_ind := l_prof_ind +1;

                FOR to_rec IN pov_to(x_appl_id, x_prof_id, g_to_lev_id) LOOP
                       if ( is_row_updatable (
                                              from_rec.level_value,
                                              to_rec.level_value,
                                              from_rec.level_value_application_id,
                                              to_rec.level_value_application_id,
                                              from_rec.level_value2,
                                              to_rec.level_value2
                                            )
                           )
                       then
                                  l_is_insertable := FALSE;
                                  exit;
                        end if;

               END LOOP;

               if (l_is_insertable) then
                         add_rows(g_prof_val_4_insert,
                                  g_lev_val_4_insert,
                                  g_lev_val_appl_4_insert,
                                  from_rec.profile_option_value,
                                  from_rec.level_value,
                                  from_rec.level_value_application_id,
                                  from_rec.level_value2,
                                  l_prof_ind,
                                  INSERT_ONLY);
               end if;
           end if;
 END LOOP;
end collect_insertable_rows;

/*
** COLLECT_ALL_ROWS - AOL INTERNAL ONLY
** The procedure collects insertable and updatable rows.
*/
procedure collect_all_rows(x_appl_id number,
                        x_prof_id number
)
is
   cursor pov_4_update(appl_id number,  prof_id number, lev_id number) is
   select profile_option_value, level_value, level_value_application_id, level_value2
   from fnd_profile_option_values
   where application_id = appl_id
   and   profile_option_id = prof_id
   and   level_id = lev_id
   for update;

   l_row_type number;
   l_prof_ind number:=0;
   l_is_insertable boolean;
begin
 FOR from_rec IN pov(x_appl_id, x_prof_id, g_from_lev_id) LOOP

           if ( is_from_row_valid(
                                  from_rec.level_value,
                                  from_rec.level_value_application_id,
                                  from_rec.level_value2
                               )
               )
          then
                l_is_insertable := TRUE;
                l_prof_ind := l_prof_ind +1;
                FOR to_rec IN pov_4_update(x_appl_id, x_prof_id, g_to_lev_id) LOOP

                             if ( is_row_updatable (
                                                   from_rec.level_value,
                                                   to_rec.level_value,
                                                   from_rec.level_value_application_id,
                                                   to_rec.level_value_application_id,
                                                   from_rec.level_value2,
                                                   to_rec.level_value2
                                                 )
                             ) then
                                  add_rows(g_prof_val_4_update,
                                       g_lev_val_4_update,
                                       g_lev_val_appl_4_update,
                                       from_rec.profile_option_value,
                                       to_rec.level_value,
                                       to_rec.level_value_application_id,
                                       to_rec.level_value2,
                                       l_prof_ind,
                                       UPDATE_ONLY
                                       );

                                  l_is_insertable := FALSE;
                                  exit;
                             end if;
                END LOOP;

                if (l_is_insertable) then
                              add_rows(g_prof_val_4_insert,
                                       g_lev_val_4_insert,
                                       g_lev_val_appl_4_insert,
                                       from_rec.profile_option_value,
                                       from_rec.level_value,
                                       from_rec.level_value_application_id,
                                       from_rec.level_value2,
                                       l_prof_ind,
                                       INSERT_ONLY);
               end if;

     end if;
 END LOOP;
end collect_all_rows;

/*
** The procedure carries a profile value and other who attributes when
** its hierarchy type is changed. The source and target hierarchy
** types should be from the set (SECURITY, SERVER, SERVRESP).
** Any other hierarchy switch is ignored. The following hierarchy
** switches are possible:
**
** 1. SECURITY TO SERVRESP
**    In this switch all the profile values at level 10003 are considered
**    for carring forward to level 10007.
** 2. SERVER TO SERVRESP
**    In this switch all the profile values at level 10005 are considered
**    for carring forward to level 10007.
** 3. SERVRESP TO SECURITY
**    In this switch all the profile values at level 10007 are considered
**    for carring forward to level 10003.
** 4. SERVRESP TO SERVER
**    In this switch all the profile values at level 10007 are considered
**    for carring forward to level 10005.
**
** what profile values are carried is controlled by the parameter X_MODE.
** profile option value rows can be either updatable rows or insertable rows.
**
** when a profile has rows existing at the target hierarchy level, they are called
** updatable rows. For example, when a profile hierarchy switch is from
** SECURITY to SERVRESP, all rows in FND_PROFILE_OPTION_VALUES for this  profile
** are considered updatable if there exist a valid LEVEL_VALUE2 value at level 10007.
**
** Insertable rows are all rows at source hierarchy level minus rows considered as
** updatable.
**
** 1. UPDATE_ONLY
**    In this mode profile option value and who columns of updatable rows are updated
**    from the similar rows at the source hierarchy level.
** 2. INSERT_ONLY
**    In this mode profile option value and who columns of insertable rows are inserted
**    at the target hierarchy level. Updatable rows are untouched.
** 3. INSERT_UPDATE
**    This mode is combination of both (1) and (2).
*/
procedure carry_profile_values(
         X_PROFILE_OPTION_NAME         in  VARCHAR2,
         X_APPLICATION_ID              in    NUMBER,
         X_PROFILE_OPTION_ID           in    NUMBER,
         X_TO_HIERARCHY_TYPE           in    VARCHAR2,
         X_LAST_UPDATE_DATE            in    DATE,
         X_LAST_UPDATED_BY             in    NUMBER,
         X_CREATION_DATE               in    DATE,
         X_CREATED_BY                  in    NUMBER,
         X_LAST_UPDATE_LOGIN           in    NUMBER,
         X_MODE                        in    NUMBER default INSERT_UPDATE
)
is
begin
    reset;
    set_type(X_PROFILE_OPTION_NAME,X_TO_HIERARCHY_TYPE);

     if (g_type = TYPE_IGNORE) then
         return;
     end if;

     if(X_MODE = INSERT_UPDATE or X_MODE = UPDATE_ONLY) then
             collect_all_rows(X_APPLICATION_ID,X_PROFILE_OPTION_ID);
     end if;

     if(X_MODE = INSERT_ONLY) then
             collect_insertable_rows(X_APPLICATION_ID,X_PROFILE_OPTION_ID);
     end if;

     if(
             (X_MODE = INSERT_UPDATE or X_MODE= UPDATE_ONLY)
              and
             (g_prof_val_4_update.first is not null)
        ) then

                FORALL rec in g_prof_val_4_update.first .. g_prof_val_4_update.last
                      update fnd_profile_option_values
                      set profile_option_value =  g_prof_val_4_update(rec),
                          last_update_date  = x_last_update_date,
                          last_update_login = x_last_update_login,
                          last_updated_by   = x_last_updated_by
                      where level_id = g_to_lev_id
                      and  application_id = x_application_id
                      and  profile_option_id = x_profile_option_id
                      and  level_value =
                           decode( g_type, TYPE_SERVER_2_SERVRESP, -1,g_lev_val_4_update(rec))
                      and   nvl(level_value_application_id,-11111) =
                               nvl(decode(g_type, TYPE_SERVER_2_SERVRESP,-1,
                                                  TYPE_SERVRESP_2_SERVER, null,
                                                  g_lev_val_appl_4_update(rec)
                                         ), -11111
                                )
                      and   nvl(level_value2, -11111)  =
                             nvl(decode(g_type,TYPE_SERVER_2_SERVRESP, g_lev_val_4_update(rec),
                                               TYPE_SECURITY_2_SERVRESP, -1,
                                                                    null
                                       ), -11111
                                );

     end if;

     if(
            (X_MODE = INSERT_UPDATE or X_MODE= INSERT_ONLY)
            and
             (g_prof_val_4_insert.first is not null)
        )
     then
                FORALL rec in g_prof_val_4_insert.first .. g_prof_val_4_insert.last
                    insert into fnd_profile_option_values (
                                      APPLICATION_ID,
                                      PROFILE_OPTION_ID,
                                      LEVEL_ID,
                                      LEVEL_VALUE,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_LOGIN,
                                      PROFILE_OPTION_VALUE,
                                      LEVEL_VALUE_APPLICATION_ID,
                                      LEVEL_VALUE2
                       ) values (
                                      X_APPLICATION_ID,
                                      X_PROFILE_OPTION_ID,
                                      g_to_lev_id,
                             decode(g_type,TYPE_SERVER_2_SERVRESP, -1,
                                           g_lev_val_4_insert(rec)
                                   ),
                                      X_LAST_UPDATE_DATE,
                                      X_LAST_UPDATED_BY,
                                      X_CREATION_DATE,
                                      X_CREATED_BY,
                                      X_LAST_UPDATE_LOGIN,
                                      g_prof_val_4_insert(rec),
                             decode(g_type,TYPE_SERVER_2_SERVRESP, -1,
                                           TYPE_SERVRESP_2_SERVER,null,
                                                             g_lev_val_appl_4_insert(rec)
                                    ),
                             decode(g_type,TYPE_SERVER_2_SERVRESP, g_lev_val_4_insert(rec),
                                           TYPE_SECURITY_2_SERVRESP, -1,
                                                                     null
                                   )
                       );
     end if;
end carry_profile_values;


/*  ------------------  FOR DEBUGGING --------------------- */

procedure display ( value in out nocopy profile_value, name varchar2)
is
 l_ind binary_integer;
begin
  l_ind := value.first;
  while (l_ind is not null)
  loop
  dbms_output.put_line(name||'['||l_ind||']:'|| value(l_ind));
  l_ind:= value.next(l_ind);
  end loop;

end;
procedure display ( value in out nocopy profile_level, name varchar2)
is
 l_ind binary_integer;
begin
  l_ind := value.first;
  while (l_ind is not null)
  loop
  dbms_output.put_line(name||'['||l_ind||']:'|| value(l_ind));
  l_ind:= value.next(l_ind);
  end loop;

end;

end FND_PROFILE_HIERARCHY_PKG;

/
