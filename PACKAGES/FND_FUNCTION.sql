--------------------------------------------------------
--  DDL for Package FND_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FUNCTION" AUTHID CURRENT_USER as
/* $Header: AFSCFNSS.pls 120.1.12010000.4 2009/09/25 15:09:13 jvalenti ship $ */

--
-- This boolean is used for performance to prevent the need to call the
-- FAST_COMPILE procedure repeatedly.
-- Other packages that reference FND_COMPILED_MENU_FUNCTIONS should
-- call it like this in their package initialization block:
--
--   if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
--     FND_FUNCTION.FAST_COMPILE;
--   end if;
--
G_ALREADY_FAST_COMPILED varchar2(1) := 'F';

--
-- TEST
--   Test if function is accessible under current responsibility.
--   Only checks static function security, and global object type
--   grants from data security.  Because this routine does not
--   take the object id and instance pks, it cannot test for
--   most data security grants, and therefore it should not
--   be used if the object id and/or instance pks are known.
--   This is here for cases where performance is critical,
--   and for backwards compatibility, but in general new code
--   should use TEST_INSTANCE instead if acting on a particular
--   object instance (database row).
-- IN
--   function_name - function to test
--   TEST_MAINT_AVAILIBILTY-   'Y' (default) means check if available for
--                             current value of profile APPS_MAINTENANCE_MODE
--                             'N' means the caller is checking so it's
--                             unnecessary to check.
-- RETURNS
--  TRUE if function is accessible
--
function TEST(function_name in varchar2,
              TEST_MAINT_AVAILABILITY in varchar2 default NULL)
    return boolean;


--
-- TEST_ID
--   Test if function id is accessible under current responsibility.
--   See comments for TEST() for more information on functionality.
-- IN
--   function_id - function id to test
-- RETURNS
--  TRUE if function is accessible
--
function TEST_ID(function_id in number) return boolean;




--
-- TEST_INSTANCE
--   Test if function is accessible under current resp and user, for
--   the object instance (database row) which is the current instance.
--   This actually checks both the function security
--   and data security system as described at the oracle internal link:
--       http://www-apps.us.oracle.com/atg/plans/r115x/datasec.txt
--
-- IN
--   function_name - function to test
--
--   Generally the user should pass the object_name and whichever
--   of the instance_pkX_values apply to that object.
--   If the user does not pass the object_name param, and
--     does not pass instance_pkX_values then only global
--     object type grants will get picked up from fnd_grants.
--   Passing object_name but not instance_pkXvalues is not supported.
--
--   object_name and pk values- object and primary key values of the current
--      object.  If you pass the object_name, you must pass values for
--      the primary key value(s).
--   user_name- Normally the caller leaves this blank so it will test
--              with the current FND user.  But folks who populate their
--              grants with special "compound" usernames might need
--              to pass the grantee_key (user_name) of the current user.
-- RETURNS
--  TRUE if function is accessible
--  FALSE if function is not accessible or if there was an error.
--
function TEST_INSTANCE(function_name in varchar2,
                       object_name          IN  VARCHAR2 DEFAULT NULL,
                       instance_pk1_value   IN  VARCHAR2 DEFAULT NULL,
                       instance_pk2_value   IN  VARCHAR2 DEFAULT NULL,
                       instance_pk3_value   IN  VARCHAR2 DEFAULT NULL,
                       instance_pk4_value   IN  VARCHAR2 DEFAULT NULL,
                       instance_pk5_value   IN  VARCHAR2 DEFAULT NULL,
                       user_name            IN  VARCHAR2 DEFAULT NULL
) return boolean;


--
-- TEST_ID_SLOW
--   AOL INTERNAL USE ONLY!
--   Does the same thing as TEST_ID, but never uses the compiled table.
--   The only reason this is exposed is for testing the security system;
--   All real code should call TEST_ID.
--
function TEST_ID_SLOW(function_id in number) return boolean;

--
-- IS_FUNCTION_ON_MENU
--   Test if function is on a particular menu.
--   This routine was designed to be called from the SQL statements
--   in data security, as a was of replacing the menu "connect by".
--
--   Since this routine ignores the current context, and ignores
--   exclusions, it should not be used to test whether a particular
--   function is available in the current context.
--
--   The algorithm is that it looks to see if the menu is marked as
--   uncompiled.  If so, it uses the normal search.  If not, it looks
--   at the compiled value.
-- IN
--   p_menu_id     - menu to check
--   p_function_id - function to look for
--   p_check_grant_flag - if TRUE, then we won't return TRUE unless
--                        GRANT_FLAG = 'Y'.  Generally pass FALSE
--                        for Data Security and TRUE for Func Sec.
--
-- RETURNS
--  TRUE if function is on menu
--  FALSE if function is not on menu
--
function IS_FUNCTION_ON_MENU(p_menu_id     IN NUMBER,
                             p_function_id IN NUMBER,
                             p_check_grant_flag IN BOOLEAN default FALSE)
return boolean;

--
-- COMPILE
--   This routine is called by the concurrent request FNDSCMPI.
--   It writes messages out to the log file so it only is for
--   conc requests, not forms or other db code.
--
--  everything is a flag.  'Y' calls COMPILE_ALL_FROM_SCRATCH
--                         'N' calls COMPILE_ALL_MARKED
procedure COMPILE( errbuf out NOCOPY varchar2,
                              retcode  out NOCOPY varchar2,
                              everything in varchar2 /* 'Y' or 'N'*/);

--
-- COMPILE_CHANGES
--   This routine is called by the DBMS_SCHEDULER method of
--   asynchronous execution.
--   It writes messages out to the log file so it only is for
--   conc requests, not forms or other db code.
--
procedure COMPILE_CHANGES;

--
-- COMPILE_ALL_MARKED
--   This is the normal routine used to compile menus.  This will
--   only compile the menus that need compilation.  It should be much
--   quicker than COMPILE_ALL_FROM_SCRATCH
--
--  compile_missing- Normally let this default to 'Y', which means
--     that this will check for menus that are completely missing
--     (neither marked nor compiled), and will compile those.
--     Passing 'N' will only compile marked menus but will not detect
--     lack of mark in any way.  That should only be done when performance
--     is very important; Passing 'N' reduces time to ~.01 second when there
--     is nothing to compile, versus about .14 second when passing 'Y'.
--     If there are menus to compile, time can be significantly longer,
--     up to several minutes if all 40,000 or so rows need recompilation.
--  RETURNS: number of rows processed.
--
function COMPILE_ALL_MARKED(compile_missing in VARCHAR2 default 'Y')
 return NUMBER;


-- FAST_COMPILE-
--
-- Recompiles all the marked menus if and only if they haven't yet
-- been already compiled in this session.
--
-- Other packages that reference FND_COMPILED_MENU_FUNCTIONS should
-- call it like this in their package initialization block:
--
--   if (FND_FUNCTION.G_ALREADY_FAST_COMPILED <> 'T') then
--     FND_FUNCTION.FAST_COMPILE;
--   end if;
--
-- Administrators can also call it from SQL*Plus in order to compile
-- the FND_COMPILED_MENU_FUNCTIONS table, like this:
--
-- execute FND_FUNCTION.FAST_COMPILE;
--
-- That is the preferred way of doing a manual compile.
--
procedure FAST_COMPILE;


--
-- COMPILE_ALL_FROM_SCRATCH
--   This is the compilation routine that is only called when you
--   are unsure of the data integrity of your system and want to
--   recompile from scratch. It can take a long time (several minutes
--   or more) and during that time, some of the compiled menu data
--   will not be available, which is why it is usually suggested
--   to use FAST_COMPILE (normally) or COMPILE_ALL_MARKED('Y') (for
--   more thoroughness) instead.
--  RETURNS: number of rows processed.
function COMPILE_ALL_FROM_SCRATCH return NUMBER;

--
-- COMPILE_MENU_MARKED
--   AOL INTERNAL USE ONLY!
--   Compile a particular menu and its kids, as marked.
--   Note that calling this on a changed menu will _not_ recompile
--   everything that includes this menu.  This should probably never
--   be called by outside callers and is mostly an "internal only" call.
--   Argument P_FORCE='Y' means compile even if not marked.
--   Default for P_FORCE is NULL which means 'N'
--  RETURNS: number of rows processed.
function COMPILE_MENU_MARKED(p_menu_id NUMBER,
                      p_force varchar2 default NULL /* NULL means 'N'*/)
    return NUMBER;

--
-- ADD_QUEUED_MARKS
--   Adds the marks that were queued with QUEUE_MARK to the compiled
--   table.  This does not compile but rather indicates the need for
--   compilation.
procedure ADD_QUEUED_MARKS;

--
-- QUEUE_MARK
--   Adds a mark to a list that will later be applied with QUEUED_MARK
--   This is not normally used; it is a hack for db triggers that don't
--   allow applying a mark on the row triggers, because that would need
--   to read the menu_entry table that is changing.
procedure QUEUE_MARK(p_menu_id in number);

--
-- MARK_MENU
--   This is a public API that needs to be called whenever a menu or
--   especially menu entry has undergone a change.  This marks it
--   so it will be recompiled next time.  This is generally called
--   by the database triggers.
--
procedure MARK_MENU(p_menu_id NUMBER);

--
-- MARK_ALL
--   Marks all the menus as needing recompilation.  Rarely used.
procedure MARK_ALL;


-- AVAILABILITY - This function compares the MAINTENANCE_MODE_SUPPORT
--                of a particular function to the APPS_MAINTENANCE_MODE
--                profile value and determines whether the function is
--                available during that maintenance phase.
--                This does not check function security or data security
--                so it is very rarely used.
--
-- in: MAINTENANCE_MODE_SUPPORT- the value from the database column
--
-- out: 'Y'= available, 'N'= not available
--
function AVAILABILITY(MAINTENANCE_MODE_SUPPORT in varchar2) return varchar2;

--
-- Function get_function_id
--      returns the function id for a function name.
-- in: p_function_name- the developer function name to look up
-- returns: the function id, or NULL if it can't be found.
------------------------------
Function get_function_id(p_function_name in varchar2
                       ) return number;

-- COMPILE_MENU
--
-- Called as a Concurrent Program to compile menu when entries are added
--
--
procedure COMPILE_MENU(errbuf out NOCOPY varchar2, retcode out NOCOPY number, p_menu_id in number, p_force in varchar2);
end FND_FUNCTION;

/
