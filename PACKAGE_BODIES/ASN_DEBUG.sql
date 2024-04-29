--------------------------------------------------------
--  DDL for Package Body ASN_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASN_DEBUG" AS
/* $Header: RCVDBUGB.pls 120.0.12010000.5 2010/01/27 18:28:19 vthevark ship $ */

g_product_code constant varchar2(5) := 'p'||'o'||'.';  -- gscc hack
g_debugging_enabled VARCHAR2(1)     := asn_debug.is_debug_on; -- Bug 9152790


/*===========================================================================

  PROCEDURE NAME:	PUT_LINE()

===========================================================================*/

PROCEDURE PUT_LINE (v_line in varchar2,v_level in varchar2, v_inv_debug_level in NUMBER DEFAULT 9) IS /* lcm changes */

    --x_TRACE_ENABLE_FLAG	VARCHAR2(1) := 'N';
    /* FPJ WMS.
     * Insert into fnd_log_messages for online mode.
    */
    l_processing_mode   rcv_transactions_interface.processing_mode_code%type ;
    l_api_name         CONSTANT VARCHAR2(40) := 'PUT_LINE';
    p_module VARCHAR2(255);
    p_procedure VARCHAR2(20);
    p_label VARCHAR2(20);

BEGIN
-- uncomment out the line below if you want to run the preprocessor in
-- sqlplus

    -- dbms_output.put_line(v_line);

  if ( g_debugging_enabled = 'Y') then
    get_calling_module(p_module,p_procedure,p_label);
    -- lcm changes
    debug_msg_ex(v_line,p_module,p_procedure,p_label,v_level, v_inv_debug_level); -- Bug 9152790
  end if;
END PUT_LINE;

PROCEDURE get_calling_module(p_module OUT NOCOPY VARCHAR2,
                             p_procedure OUT NOCOPY VARCHAR2,
                             p_label OUT NOCOPY VARCHAR2,
                             p_stack_depth IN NUMBER) IS
/* p_stack_depth is the rewind depth.  for example
   p_stack_depth = 2 -->  calling procedure name
   p_stack_depth = 1 -->  asn_debug.put_line
   p_stack_depth = 0 -->  get_calling_procedure
   you can override the rewind depth as needed
*/
  stk VARCHAR2(2000);
  len NUMBER;
  p1 NUMBER;
  p2 NUMBER;
  t VARCHAR2(2000);
  r VARCHAR2(2000);
  s VARCHAR2(2000);
  rtn VARCHAR2(1);
BEGIN
  stk:=DBMS_UTILITY.format_call_stack;
  len:=LENGTH(stk);
  rtn:=SUBSTRB(stk,-1); --get the return character
  p1:=INSTRB(stk,rtn,1,p_stack_depth+3)+1;
  p2:=INSTRB(stk,rtn,1,p_stack_depth+4);
  t:=SUBSTRB(stk,p1,p2-p1); --isolated stack line
  t:=trim(substrb(t,instrb(t,' '))); --get rid of object address
  r:=substrb(t,0,instrb(t,' ')-1); --isolate line number
  s:=trim(substrb(t,instrb(t,' '))); --isolate caller
  p1:=INSTRB(s,'.',1,1)+1;
  s:=SUBSTRB(s,p1); --isolate calling procedure
  p_label:=substrb(r,0,20);
  p_procedure:=substrb(s,0,20);
  p_module:=substrb(s,0,255);
END get_calling_module;

FUNCTION get_debugging_enabled return boolean is

  v_value     VARCHAR2(128);

BEGIN

  IF (g_debugging_enabled = 'Y') THEN
   RETURN TRUE;
  ELSE
   RETURN FALSE;
  END IF;

end get_debugging_enabled;

/* set the current module name that you see in the log table */
PROCEDURE set_module_name( module in varchar2) is
  v_module varchar2(255);
BEGIN
  v_module := trim(module);
  if (substr(v_module,0,3)=g_product_code) then --if explicit set then override default
    g_current_module := substr(v_module,0,255);
  elsif (module is not null) then
    if (lower(substr(v_module,-2,2))='.c') then --call from lpc file
      v_module := substr(g_product_code||'src.rvtp.'||substr(v_module,0,length(v_module)-2),0,255);
    else --call from plsql
      v_module := substr(g_product_code||'plsql.'||v_module,0,255);
    end if;
    g_current_module := v_module;
  end if;
END set_module_name;

/* print stack will print out the current procedure calling stack */
PROCEDURE print_stack is
BEGIN
  debug_msg('Current Calling Stack = '||g_procedure_stack);
  debug_msg(DBMS_UTILITY.FORMAT_CALL_STACK);
END;

/* start procedure adds procedure name to the simulated procedure stack */
/* g_procedure_stack is a string that keeps a list of all the stacks    */
/* this works because each procedure name is sure to have exactly 20    */
/* characters so that the substr(g_procedure_stack,60,20) gives you the */
/* name of the third procedure on the stack.  Note that                 */
/* substr(g_procedure_stack,0,20) is level zero which equals '?' or     */
/* the unknown procedure.                                               */
PROCEDURE start_procedure( procedure_name in varchar2) is
BEGIN
  g_current_procedure := rpad(upper(nvl(substrb(procedure_name,0,20),'?')),20,' ');
  debug_msg(RPAD('v--------Procedure Started',37,'-')||'v',FND_LOG.LEVEL_PROCEDURE,'begin');
  g_level := g_level+1;
  g_procedure_stack := g_procedure_stack||g_current_procedure;
EXCEPTION
  WHEN OTHERS THEN
    null;
END start_procedure;

/* stop procedure acts like a pop on the stack.  If the procedure name */
/* equals the name that is currently being used then we can pop the    */
/* topmost element off and we're done.  However, if the name does not  */
/* equal the topmost element then we need to undo the stack all the way*/
/* back to that element - this results in Implicit Procedure Exits     */
/* which are generally caused by unexpected errors when the procedure  */
/* is exited abnormally.  In the very weird situation where we get a   */
/* stop procedure for a procedure name we do not recognize, we do not  */
/* do anything other than mention it was an unknown procedure name     */
/* note the use of instr to search the string in reverse - this is     */
/* necessary in the case of recursion and stuff                        */
/* the pop_this_procedure is a flag to indicate not to pop off the     */
/* current procedure.  Useful for the pro*C commands that do not have  */
/* an explicit procedure termination                                   */
PROCEDURE stop_procedure( procedure_name in varchar2, pop_this_procedure in boolean) is
  l_temp_name VARCHAR2(20);
  l_temp_level NUMBER;
BEGIN
  l_temp_name := rpad(upper(nvl(substrb(procedure_name,0,20),'?')),20,' ');
  IF (g_current_procedure <> l_temp_name) THEN -- we need to jump back on the stack
    l_temp_level := (INSTRB(g_procedure_stack,l_temp_name)-1)/20;
    WHILE (g_level > l_temp_level) LOOP -- to pop off the procedure that didn't get exited
      g_level := g_level - 1;
      debug_msg(RPAD('^--------Implicit Procedure Exit',37,'-')||'^',FND_LOG.LEVEL_PROCEDURE,'end_implicit');
      g_current_procedure := SUBSTRB(g_procedure_stack,g_level*20+1,20);
    END LOOP;
  END IF;
  if (pop_this_procedure = TRUE) then
    IF (g_current_procedure = l_temp_name) then -- now pop off the called procedure
      g_level := g_level-1;
      debug_msg(RPAD('^--------Procedure Ended',37,'-')||'^',FND_LOG.LEVEL_PROCEDURE,'end');
      IF (g_level<0) THEN -- shouldn't happen unless you call stop_procedure('?'), but just to be safe
        g_level := 0;
        g_current_procedure := RPAD('?',20,' ');
      ELSE -- the normal situation, reset the current procedure to the previous procedure on the stack
        g_current_procedure := SUBSTRB(g_procedure_stack,g_level*20+1,20);
      END IF;
    ELSE -- the name given wasn't anywhere on the stack
      debug_msg(RPAD('^--------Unknown Procedure ['||procedure_name||'] Ended',37,'-')||'^',FND_LOG.LEVEL_PROCEDURE,'end_unknown');
    END IF;
  end if;
  g_procedure_stack := substrb(g_procedure_stack,1,(g_level+1)*20);
EXCEPTION
  WHEN OTHERS THEN
    null;
END stop_procedure;

PROCEDURE debug_msg(line in varchar2, level in varchar2, label in varchar2, inv_debug_level in number default 9) is -- Bug 9152790
-- If you do not specify a level then it will default to log level: Statement
-- If you do not specify a module then it will use the last module specified
--   if there is no last module specified then it Will default to module name: RCV
v_level	NUMBER;
BEGIN
  if ( g_debugging_enabled = 'Y' ) then
  -- Bug 9152790: rcv debug enhancement : We will not use fnd logging; instead will write to inv log file.
    /*
    v_level := nvl(level,FND_LOG.LEVEL_STATEMENT);

    -- GSCC HACK: need redundant v_level >= FND_CUR_LEVEL check do not remove
    if( v_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL AND FND_LOG.TEST(v_level, G_CURRENT_MODULE )) then
      FND_LOG.STRING(v_level,
         substrb(G_CURRENT_MODULE||'.'
               ||trim(nvl(G_CURRENT_PROCEDURE,'?'))||'.'
               ||trim(nvl(label,'-1'))
                 ,0,255)
         ,RPAD(' ',2*g_level)||line);
      FND_FILE.PUT_LINE(FND_FILE.LOG , '[' || to_char(sysdate,'DD-MON-YY HH24:MI:SS') || '] '||rpad(SUBSTR(g_current_module,INSTRB(g_current_module,'.',-1)+1,20),20,' ')||' '||LPAD(nvl(label,'-1'),5,' ')||':'||RPAD(' ',2*g_level+1)||line);
    end if;
    */

    inv_trx_util_pub.trace(RPAD(' ',2*g_level)||line,
                           substrb(G_CURRENT_MODULE||'.'||trim(nvl(G_CURRENT_PROCEDURE,'?'))||'.'||trim(nvl(label,'-1')),0,255) ,
                           inv_debug_level);

  end if;
EXCEPTION
  WHEN OTHERS THEN
    null;

END debug_msg;

/* debug_msg_ex is an extended version of the debug_msg procedure which is */
/* specifically designed to facilitate the pro*C calls*/
PROCEDURE debug_msg_ex(message in varchar2, module in varchar2, procedure_name in varchar2, line_num in number,level in varchar2, inv_debug_level in number default 9) is -- Bug 9152790
  v_procedure_name VARCHAR2(20);
begin
  if ( g_debugging_enabled = 'Y') then

    if (procedure_name is not null) then
      v_procedure_name := rpad(upper(nvl(substrb(procedure_name,instrb(procedure_name,'/',-1)+1,20),'?')),20,' ');
      if (v_procedure_name<>g_current_procedure) then
        if (instr(g_procedure_stack,v_procedure_name)>0) then
          stop_procedure(v_procedure_name,false);
          if (module is not null) then
            set_module_name(substrb(module,instrb(module,'/',-1)+1));
          end if;
        else
          if (module is not null) then
            set_module_name(substrb(module,instrb(module,'/',-1)+1));
          end if;
          start_procedure(v_procedure_name);
        end if;
      end if;
    end if;

    debug_msg(message,level,line_num,inv_debug_level);  -- Bug 9152790: rcv debug enhancement
  end if;
EXCEPTION
  WHEN OTHERS THEN
    null;
end debug_msg_ex;

-- Bug 9152790: rcv debug enhancement
FUNCTION is_debug_on RETURN VARCHAR2 IS
BEGIN
   IF (fnd_profile.VALUE('INV_DEBUG_TRACE') = '1') THEN
       return 'Y';
   ELSE
       return 'N';
   END IF;
END;

END ASN_DEBUG;

/
