--------------------------------------------------------
--  DDL for Package Body PA_CC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_UTILS" as
-- $Header: PAXCCUTB.pls 120.0.12010000.2 2008/08/08 06:45:21 jravisha ship $

  /*
   * Package body global variables.
   *
   * g_function_stack holds the name of the called functions in a stack format.
   * g_counter is used to mark the current location in the function stack.
   * g_space is used to provide indentation in the stack of function calls
   */
  g_function_stack               PA_PLSQL_DATATYPES.Char50TabTyp;
  g_function_counter             NUMBER := 0;
  g_space                        VARCHAR2(1000);

-- $Header: PAXCCUTB.pls 120.0.12010000.2 2008/08/08 06:45:21 jravisha ship $
--
--  FUNCTION
--              is_receiver_control_setup
--
--
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

Function is_receiver_control_setup (x_provider_org_id  IN number,
x_receiver_org_id	 IN number) return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_cc_org_relationships
                        where  prvdr_org_id = x_provider_org_id
                        and    recvr_org_id = x_receiver_org_id
                        and    vendor_site_id is not null);

        c1_rec c1%rowtype;
begin

   if (x_provider_org_id is null and x_receiver_org_id is null) then
      return(null);
   end if;

   open c1;
   fetch c1 into c1_rec;
   if c1%notfound then
      close c1;
      return(0);
   else
      close c1;
      return(1);
   end if;

exception
   when others then
      return(SQLCODE);
end is_receiver_control_setup;

--  FUNCTION
--              check_pvdr_rcvr_control_exist
--
--
Function check_pvdr_rcvr_control_exist (x_project_id  IN number)
return number
is
        cursor c1 is
                SELECT 1
                FROM    sys.dual
                where exists (SELECT NULL
                        FROM   pa_cc_org_relationships
                        where  prvdr_project_id = x_project_id);

        c1_rec c1%rowtype;
begin

   if (x_project_id is null) then
      return(null);
   end if;

   open c1;
   fetch c1 into c1_rec;
   if c1%notfound then
      close c1;
      return(0);
   else
      close c1;
      return(1);
   end if;

exception
   when others then
      return(SQLCODE);
end check_pvdr_rcvr_control_exist;
-------------------------------------------------------------

-------------------------------------------------------------------------------
--              log_message
-------------------------------------------------------------------------------

/*PROCEDURE log_message( p_message    IN VARCHAR2,
                       p_write_mode IN NUMBER DEFAULT 0) IS
		       bug 2681003 -- removed the default for the GSCC complaince*/
PROCEDURE log_message( p_message    IN VARCHAR2,
                       p_write_mode IN NUMBER ) IS
  l_function    VARCHAR2(50) := NULL;
BEGIN
   IF  g_function_stack.exists(g_function_counter) THEN
     l_function := g_function_stack(g_function_counter);
   END IF;
   IF g1_debug_mode  = 'Y' THEN
   pa_debug.write_file('LOG',
	    to_char(sysdate,'HH:MI:SS:') || g_space ||
	    l_function || ': '  ||p_message, p_write_mode);
   END IF;

EXCEPTION

WHEN OTHERS
 THEN
   raise;

END log_message;

-------------------------------------------------------------------------------
--              set_curr_function
-------------------------------------------------------------------------------

PROCEDURE set_curr_function(p_function IN VARCHAR2) IS
BEGIN
   /*
    * Push the current function in the stack.
    * Also add an extra space for indentation.
    */
   g_function_counter := g_function_counter + 1;
   g_function_stack(g_function_counter) := p_function;
   g_space   := g_space || ' ';
   if g_function_counter = 1 then
     pa_debug.init_err_stack(p_function);
   else
     pa_debug.set_err_stack(p_function);
   end if;
END set_curr_function;

-------------------------------------------------------------------------------
--              reset_curr_function
-------------------------------------------------------------------------------

PROCEDURE reset_curr_function IS
BEGIN
    /*
     * Pop the function from the current stack.
     * Remove the extra space.
     */
    g_function_stack.delete(g_function_counter);
    g_function_counter := g_function_counter -1;
    g_space   := substr(g_space,1,length(g_space)-1);
    pa_debug.Reset_err_stack;
END reset_curr_function;

END PA_CC_UTILS ;

/
