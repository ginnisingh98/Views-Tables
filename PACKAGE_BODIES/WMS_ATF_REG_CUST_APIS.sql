--------------------------------------------------------
--  DDL for Package Body WMS_ATF_REG_CUST_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ATF_REG_CUST_APIS" as
 /* $Header: WMSARCAB.pls 115.10 2004/05/04 00:28:57 joabraha noship $ */
--
--
--
-- Oracle Internal DataType, Parameter, Default Codes and New Line Constants
--
c_dtype_undefined constant number        default   0;
c_dtype_varchar2  constant varchar2(10)  default   'VARCHAR2';
c_dtype_number    constant varchar2(10)  default   'NUMBER';
c_dtype_long      constant varchar2(10)  default   'LONG';
c_dtype_date      constant varchar2(10)  default   'DATE';
c_dtype_boolean   constant varchar2(10)  default   'BOOLEAN';
--
c_ptype_in        constant varchar2(10)  default   'IN';
c_ptype_out       constant varchar2(10)  default   'OUT';
c_ptype_in_out    constant varchar2(10)  default   'IN/OUT';
--
--
c_default_defined constant number      default   1;
--
--
-- Error Exceptions which can be raised by dbms_describe.describe_procedure
--
  --
  -- Specified Object does not exist
  --
  Object_Not_Exists  exception;
  Pragma Exception_Init(Object_Not_Exists, -4043);
  --
  -- Package does not exist in the database
  --
  Package_Not_Exists  exception;
  Pragma Exception_Init(Package_Not_Exists, -6564);
  --
  -- Procedure does not exist in the package
  --
  Proc_Not_In_Package  exception;
  Pragma Exception_Init(Proc_Not_In_Package, -20001);
  --
  -- Object is remote
  --
  Remote_Object  exception;
  Pragma Exception_Init(Remote_Object, -20002);
  --
  -- Package is invalid
  --
  Invalid_Package  exception;
  Pragma Exception_Init(Invalid_Package, -20003);
  --
  -- Invalid Object Name
  --
  Invalid_Object_Name  exception;
  Pragma Exception_Init(Invalid_Object_Name, -20004);
--
--
-- Oracle Internal DataType, Parameter, Default Codes and New Line Constants
--
c_valid_varchar2    constant varchar2(10)  default 'VALID';
c_invalid_varchar2  constant varchar2(10)  default 'INVALID';
c_create_mode	    constant varchar2(10)  default 'CREATE';
c_delete_mode	    constant varchar2(10)  default 'DELETE';
--
--
-- Package Variables
--
g_spec_string   varchar2(32767) := null;
g_body_string   varchar2(32767) := null;
--
--
g_hook_parameter_table  hook_parameter_table_type;
--
-- Global variable to hold parameter table information.
--
g_parameter_table          hook_parameter_table_type;
--
--
g_sysgen_custom_package    varchar2(240);
g_sysgen_custom_procedure  varchar2(240);
--
--
-- Oracle Internal DataType, Parameter, Default Codes and New Line Constants
--
--c_dtype_undefined constant number      default   0;
--c_dtype_varchar2  constant number      default   1;
--c_dtype_number    constant number      default   2;
--c_dtype_long      constant number      default   8;
--c_dtype_date      constant number      default  12;
--c_dtype_boolean   constant number      default 252;
--
--c_ptype_in        constant number      default   0;
--c_ptype_out       constant number      default   1;
--c_ptype_in_out    constant number      default   12;
--
--
-- Other Error Exceptions
--
Plsql_Value_Error exception;
Pragma Exception_Init(Plsql_Value_Error, -6502);
--
--  New line variable.
c_new_line        constant varchar2(1) default '
';
l_debug  	  number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
--
--
-- -------------------------------------------------------------------------------------------
-- |--------------------------< trace utility >-----------------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name       Reqd  Type     Description
--   ---------  ----- -------- --------------------------------------------
--   p_message  Yes   varchar2 Message to be displayed in the log file.
--   p_level    No    number   Level default to the lowest(4) if not specified.
--
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number
) is
begin
      INV_LOG_UTIL.trace(p_message, 'WMS_ATF_REG_CUST_APIS', p_level);
end trace;

-- -------------------------------------------------------------------------------------------
-- |------------------------< populate_paramater_table >--------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populate the PL/SQL structure(hook_parameter_table_type) with the
--   parameters of the signature for the Parent Module/Business Process/ PL/SQL
--   Package-Procedure combination
--
-- Prerequisites:
--   p_module_hook_id is set with the proper value.
--
--
-- In Parameters:
--   Name                Reqd Type      Description
--   ------------------  ---- --------  ----------------------------------
--   p_module_hook_id    Yes  varchar2  Unique record identifier for
--                                      the parent Module/Business
--                     			Process/ PL/SQL Package-Procedure
--                                      combination.
--   p_parameter_table   Yes  table     This PL/SQL table contains the
--                                      type signature information for the
--                                      p_module_hook_id.
--   x_return_status     Yes  number    Return Status
--   x_msg_count         Yes  number    Message Stack Count.
--   x_msg_data          Yes  number    Message Stack Data.
--
-- Post Success:
--   Returns true. Returns a PL/SQL of type hook_parameter_table_type.
--
-- Post Failure:
--   Details of the error are added to the AOL message stack. When this
--   function returns false the error has not been raised. It is up to the
--   calling logic to raise or process the error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure populate_parameter_table(
   p_module_hook_id    in  number
,  p_parameter_table   out nocopy hook_parameter_table_type
) is

    l_loop     number:= 0;            -- Loop counter
    l_proc     varchar2(72) := 'populate_parameter_table :';

    cursor c_get_signature is
    select parameter_name, parameter_in_out, parameter_type
    from   wms_api_hook_signatures
    where  module_hook_id = p_module_hook_id;

begin
    if (l_debug = 1) then
       trace(' Entering:'|| l_proc, 1);
       trace(' p_module_hook_id => ' || p_module_hook_id, 4);
    end if;

    for v_get_signature in c_get_signature
    loop
       l_loop := l_loop + 1;
       p_parameter_table(l_loop).parameter_name := v_get_signature.parameter_name;
       p_parameter_table(l_loop).parameter_in_out := v_get_signature.parameter_in_out;
       p_parameter_table(l_loop).parameter_type := v_get_signature.parameter_type;

       -- ### This flag will be used to indicate if a matching parameter has been found
       -- ### in the signature of the call package.procedure. If found, this will be set
       -- ### to 'Y' and hence the comparison while loop in the chk_param_in_hook_proc_call
       -- ### will not traverese this record in the PL/SQL table.
       p_parameter_table(l_loop).parameter_flag := 'N';
    end Loop;

    if (l_debug = 1) then
       trace(' Leaving:'||l_proc, 1);
       for i in 1..p_parameter_table.count
       loop
           trace(' parameter_name'||'('||i||')'||' = '|| p_parameter_table(i).parameter_name
               ||' parameter_type'||'('||i||')'||' = '|| p_parameter_table(i).parameter_type
               ||' parameter_in_out'||'('||i||')'||' = '|| p_parameter_table(i).parameter_in_out
               ||' parameter_flag'||'('||i||')'||' = '|| p_parameter_table(i).parameter_flag, 4);
       end loop;
    end if;
end populate_parameter_table;
--
--
--
--
-- -------------------------------------------------------------------------------------------
-- |------------------------------< add_to_string  >------------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Appends the specified string to the end of the existing string. The intent
--   here is the create separate strings for the spec and the body. Within this
--   routine, based on the string type ('S' or 'B') passed in, seperate strings will be appended.
--   Mode of 'SB' is the string which is required to be appended to both the global
--   variables
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name       Reqd Type     Description
--   ------     ---- -------- ----------------------------------------------------------
--   p_text     Yes  varchar2 Source string to add to the existing string
--                            .
--   p_type	Yes  varchar2 String type being passed in. This determines if the string
--                            passed in should be appended to the spec string or the body
--			      string.
--
-- Post Success:
--   The extra source string is added to the existing string.
--
-- Post Failure:
--   If the source code size limit is exceeded then an application error
--   message is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure add_to_string(
   p_text  in   varchar2
,  p_type  in   varchar2
) is

  l_proc    varchar2(72) := g_package||' add_to_string';
begin
  --trace('Entering:'|| l_proc);
  if p_type = 'S' then
     g_spec_string := g_spec_string || p_text;
  elsif p_type = 'B' then
     g_body_string := g_body_string || p_text;
  elsif p_type = 'SB' then
     g_spec_string := g_spec_string || p_text;
     g_body_string := g_body_string || p_text;
  end if;

  --trace(' Leaving:'||l_proc);
end add_to_string;
--
--
-- -------------------------------------------------------------------------------------------
-- |---------------------------< create_package_header >--------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates the package header and procedure string common to the spec and the .
--   body.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                  Reqd Type      Description
--   -----------------     ---- --------  --------------
--   p_module_hook_id      Yes  varchar2  Module Hook ID..
--   p_parameter_table     Yes  varchar2  Table containing the signature
--                                        definition.
--
-- Post success:
--   The sommon system package header is created in the database.
--
-- Post Failure:
--   None
--
--   Unexpected Oracle errors and serious application errors will be raised
--   as a PL/SQL exception. When these errors are raised this procedure will
--   abort the processing.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
Procedure create_package_header(
   p_module_hook_id     in number
,  p_parameter_table	in hook_parameter_table_type
) is
  --
  l_proc                varchar2(72) := g_package||'create_package_header';
begin
  --trace('Entering:'|| l_proc);
  --
  -- Building comments at the start of the package body
  --
  add_to_string('/*******************************************************************/', 'SB');
  add_to_string(c_new_line, 'SB');
  add_to_string('-- Code generated by the Oracle WMS Custom API Registration Processor', 'SB');
  add_to_string(c_new_line, 'SB');
  add_to_string('-- No user defined procedures allowed in this package.', 'SB');
  add_to_string(c_new_line, 'SB');
  add_to_string('-- Created on ' || to_char(sysdate, 'YY/MM/DD HH24:MI:SS'), 'SB');
  add_to_string(' (YY/MM/DD HH:MM:SS)' || c_new_line, 'SB');
  add_to_string('/*******************************************************************/', 'SB');
  add_to_string(c_new_line, 'SB');
  add_to_string(c_new_line, 'SB');
  --
  -- Building code for the Procedure of the system package
  --
  add_to_string('create or replace package ' || g_sysgen_custom_package, 'S');
  add_to_string(' as' || c_new_line, 'S');
  add_to_string('create or replace package body ' || g_sysgen_custom_package, 'B');
  add_to_string(' as' || c_new_line, 'B');

  add_to_string('-- Procedure for Module Hook ID ' || p_module_hook_id, 'SB');
  add_to_string('-- ' || c_new_line, 'SB');
  --
  --  Creating Procedure definition.
  add_to_string(c_new_line, 'SB');
  add_to_string('Procedure  ' || g_sysgen_custom_procedure || '(', 'SB');
  add_to_string(c_new_line, 'SB');

  for i in 1..p_parameter_table.count
  loop
     add_to_string('            '|| rpad(p_parameter_table(i).parameter_name, 31), 'SB');
     add_to_string('  '|| p_parameter_table(i).parameter_in_out, 'SB');
     -- Adding mandatory nocopy to the OUT parameters.
     -- Added August 21st 2003
     if (p_parameter_table(i).parameter_in_out in ('OUT', 'out')) then
        add_to_string('  NOCOPY', 'SB');
     end if;
     add_to_string('  '|| p_parameter_table(i).parameter_type, 'SB');
     add_to_string(','||c_new_line, 'SB');
  end Loop;
     -- Add the mandatory 'IN' paramter to the end of the list of paramters.
     --
     add_to_string('            '|| rpad('p_hook_call_id', 31), 'SB');
     add_to_string('  IN', 'SB');
     add_to_string('  NUMBER', 'SB');
     add_to_string(c_new_line, 'SB');

  add_to_string('            );'|| c_new_line, 'S');
  add_to_string('            ) is', 'B');
  add_to_string('end '||g_sysgen_custom_package||';'|| c_new_line, 'S');
  add_to_string(c_new_line, 'B');
  add_to_string('begin  '|| c_new_line, 'B');

  --trace(' Leaving:'||l_proc);
end create_package_header;
--
--
-- -------------------------------------------------------------------------------------------
-- |---------------------------< create_package_body >----------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates the package body string.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                   Reqd Type          Description
--   ------------------     ---- --------      -----------------------------------------------
--   p_called_package       Yes  varchar2     Call package Name.
--   p_called_procedure     Yes  varchar2     Call procedure Name.
--   p_module_hook_id       Yes  varchar2     Module Hook ID.
--   p_parameter_table      Yes  table type   Signature table of type hook_parameter_table_type
--   p_iteration	    Yes  number       Iteration counter
--
--
-- Post success:
--   A system package spec is created in the database.
--
-- Post Failure:
--   None
--
--   Unexpected Oracle errors and serious application errors will be raised
--   as a PL/SQL exception. When these errors are raised this procedure will
--   abort the processing.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
Procedure create_package_body(
   p_called_package	in varchar2
,  p_called_procedure	in varchar2
,  p_hook_call_id       in number
,  p_parameter_table	in hook_parameter_table_type
,  p_iteration          in number
) is
  --
  l_proc                varchar2(72) := g_package||'create_package_body';
begin
  --trace('Entering:'|| l_proc);

  -- For the very first iteration of the loop, start with a 'if.. then' and every subsequent
  -- iteration is an elsif...then for further iterations.
  if p_iteration = 1  then
      add_to_string('If p_hook_call_id = ' || p_hook_call_id || '  then'|| c_new_line, 'B');
  else
      add_to_string(c_new_line, 'B');
      add_to_string('elsif p_hook_call_id = ' || p_hook_call_id || '  then'|| c_new_line, 'B');
  end if;

  add_to_string('    '||p_called_package||'.'||p_called_procedure||'('|| c_new_line, 'B');

  for i in 1..p_parameter_table.count
  loop
    add_to_string('            '|| rpad(p_parameter_table(i).parameter_name, 31), 'B');
    add_to_string('  =>  '|| p_parameter_table(i).parameter_name , 'B');

       if i <> p_parameter_table.count then
          add_to_string(','||c_new_line, 'B');
       else
          add_to_string(c_new_line, 'B');
       end if;

  end loop;
  add_to_string('            );', 'B');

  --trace(' Leaving:'||l_proc);
end create_package_body;
--
--
--
--
-- -------------------------------------------------------------------------------------------
-- |----------------------------< execute_source >--------------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Executes the 'create or replace package body...' statement which has
--   been built-up in in the g_spec_string string.
--
-- Prerequisites:
--   The complete valid package body source code has been placed in the source
--   store by calling the 'add_to_string' procedure one or more times.
--
-- In Parameters:
--   None
--
-- Post Success:
--   None
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure execute_source(
   g_string   in varchar2
) is

  l_dynamic_spec_cursor         integer;          -- Dynamic sql cursor
  l_execute_spec                integer;          -- Value returned by
                                                  -- dbms_sql.execute
  l_dynamic_body_cursor         integer;          -- Dynamic sql cursor
  l_execute_body                integer;          -- Value returned by
                                                  -- dbms_sql.execute

  l_proc         varchar2(72) := g_package||'execute_source';
  l_progress     number;
begin
  --
  -- The whole of the new package body code has now been built,
  -- use dynamic SQL to execute the create or replace package statement
  --
  l_dynamic_spec_cursor := dbms_sql.open_cursor;
  if (l_debug = 1) then
     trace(l_proc ||' Entering:'|| l_proc, 1);
     trace(l_proc ||' g_string => ' || g_string, 4);
     trace(l_proc ||' Starting Generation.....'|| l_proc, 4);
     trace(l_proc ||' l_dynamic_spec_cursor = ' || l_dynamic_spec_cursor, 4);
  end if;

  l_progress := 10;
  dbms_sql.parse(l_dynamic_spec_cursor, g_string, dbms_sql.native);

  l_progress := 20;
  l_execute_spec := dbms_sql.execute(l_dynamic_spec_cursor);

  if (l_debug = 1) then
     trace(l_proc ||'l_execute_spec = ' || l_execute_spec, 4);
  end if;

  l_progress := 30;
  dbms_sql.close_cursor(l_dynamic_spec_cursor);

  if (l_debug = 1) then
     trace(l_proc ||' Finished Generating Spec...:'|| l_proc, 1);
  end if;

  if (l_debug = 1) then
     trace(l_proc ||' Leaving:'|| l_proc);
  end if;
exception
  --
  -- In case of an unexpected error close the dynamic cursor
  -- if it was successfully opened.
  --
  when others then
    if (l_debug = 1) then
       trace(l_proc ||' Error message within "When Others" exception  ' || sqlerrm(sqlcode) || '  Progress : ' || l_progress || ' ' || l_proc, 1);
    end if;

    if (dbms_sql.is_open(l_dynamic_spec_cursor)) then
      if (l_debug = 1) then
         trace(l_proc ||' Closing Cursor ....');
      end if;
      dbms_sql.close_cursor(l_dynamic_spec_cursor);
    end if;
end execute_source;
--
--
--
-- -------------------------------------------------------------------------------------------
-- |---------------------------< create_system_package >--------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates the spec and body string for the system generated
--   package. These strings may be used later to generate the spec and the body
--   for the system package.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                Reqd Type     Description
--   ----------------    ---- -------- -------------------
--   p_module_hook_id    Yes  varchar2 Module Hook ID.
--   x_return_status     Yes  number   Return Status
--   x_msg_count         Yes  number   Message Stack Count.
--   x_msg_data          Yes  number   Message Stack Data.
--
--
-- Post success:
--   A system package spec is created in the database.
--
-- Post Failure:
--   Unexpected Oracle errors and serious application errors will be raised
--   as a PL/SQL exception. When these errors are raised this procedure will
--   abort the processing.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
Procedure create_wms_system_objects(
   x_retcode           out nocopy number
,  x_errbuf            out nocopy varchar2
) is

l_number_of_parameters  number;
l_outer_loop            number;
l_inner_loop            number;
l_middle_loop		 number;
l_return_status	 varchar2(240);
l_msg_count             number;
l_msg_data		 varchar2(240);
l_current_package_cntr  number;

-- This variable indicates the number of packages to be created.
l_no_of_packages        number;
l_selected_cntr         number;

-- Required for droppping packages..
l_csr_sql 		integer;
l_rows    		integer;
l_package_name_drop   	varchar2(100);

l_proc         varchar2(72) := 'create_wms_system_objects :';
l_progress     number;

cursor c_api_hooked_entities is
select wahe.module_hook_id, wahe.module_type_id, wahe.business_process_id,
       wahe.short_name_id, wahe.sysgen_custom_package, wahe.sysgen_custom_procedure,
       wahe.hooked_package, wahe.hooked_procedure, wahe.current_package_cntr
from   wms_api_hooked_entities wahe;

cursor c_api_hook_calls(l_module_hook_id number) is
select hook_call_id, enabled_flag, called_package, called_procedure,
       effective_from_date, effective_to_date
from   wms_api_hook_calls
where  module_hook_id = l_module_hook_id
and    enabled_flag = 'Y'
and    (effective_to_date >= sysdate or effective_to_date is null)
order by hook_call_id;

cursor c_drop_sysgen_packages(l_module_hook_id number) is
select sysgen_custom_package, current_package_cntr
from   wms_api_hooked_entities
where  module_hook_id = l_module_hook_id;

begin

         l_outer_loop := 0;
	 for v_api_hooked_entities in c_api_hooked_entities
	 loop
	     l_outer_loop := l_outer_loop + 1;
	     if (l_debug = 1) then
	        trace(l_proc ||' Iteration No ' || l_outer_loop || ' in the outer loop');
	        trace(l_proc ||' ***module hook id ' ||v_api_hooked_entities.module_hook_id|| ' ***');
	        trace(l_proc ||' ***short name ' ||v_api_hooked_entities.short_name_id|| ' ***');
	     end if;

	     -- Check which file currently being used. The idea here is to generate 2 files
	     -- simultaneously at the time of generation so that when one package is being used
	     -- the other one can be updated.
	     if v_api_hooked_entities.current_package_cntr is null then
	         l_current_package_cntr := 1;
	         l_no_of_packages := 2;
	     elsif v_api_hooked_entities.current_package_cntr = 1 then
	         l_current_package_cntr := 2;
	         l_no_of_packages := 1;
	     elsif v_api_hooked_entities.current_package_cntr = 2 then
	         l_current_package_cntr := 1;
	         l_no_of_packages := 1;
	     end if;

	     if (l_debug = 1) then
	        trace(l_proc ||' *** l_current_package_cntr  ' || l_current_package_cntr);
	        trace(l_proc ||' *** module hook id  ' || v_api_hooked_entities.module_hook_id);
	     end if;


	   l_middle_loop := 0;
	   -- Loop to determine the number of set of packages to be created.
	   -- If the current_package_cntr is null then, 2 sets of packages have to be created.
	   -- In all other cses, only one set needs to be updated.
	   for i in 1..l_no_of_packages
	   loop
	     l_middle_loop := l_middle_loop + 1;
	     if (l_debug = 1) then
	        trace(l_proc ||' Iteration No ' || l_middle_loop || ' in the middle loop');
	     end if;

             -- This is not incremented for the first iteration. The numebr of interations
             -- is restricted by the l_no_of_packages in the for loop and so the max value the
             -- l_current_package_cntr can have is 2.
	     if (i <> 1) then
	        l_current_package_cntr := l_current_package_cntr + 1;
	        if (l_debug = 1) then
	           trace(l_proc ||' *** Inside the l_current_package_cntr incrementer if.. end if***');
	        end if;
	     end if;

	      if i = 1 then
	         -- Populate the parameter table with the signature definition for every iteration of the
                 -- outer loop. This will be used to compare the signature of the call
                 -- procedure which is intended to be registered.
                 populate_parameter_table(
                    p_module_hook_id  => v_api_hooked_entities.module_hook_id
                 ,  p_parameter_table => g_hook_parameter_table
                 );

                 If (g_hook_parameter_table.count = 0) then
                    -- Parameter table is empty
                    x_retcode  := 2;
		    x_errbuf   := 'Error';
                    return;
                 else
                    -- Variable to keep count of number of parameters in the parent signature.
                    -- This is used in the code later.
                    l_number_of_parameters := g_hook_parameter_table.count;
                 end if;
              end if;

	      -- Initialise the variables at start.
	      -- Since the intent here is to create a new package spec/body for every
	      -- unique module_hook_id, the variables are reset fro each iteration.
	      g_spec_string := null;
	      g_body_string := null;
	      g_sysgen_custom_package    := v_api_hooked_entities.sysgen_custom_package ||'_'||l_current_package_cntr;
	      g_sysgen_custom_procedure  := v_api_hooked_entities.sysgen_custom_procedure;

	      if (l_debug = 1) then
	         trace(l_proc ||' ***sysgen package name ' ||v_api_hooked_entities.sysgen_custom_package|| ' ***');
	         trace(l_proc ||' ***sysgen procedure name ' ||v_api_hooked_entities.sysgen_custom_procedure|| ' ***');
	      end if;

              -- Call to routine to construct the header string for the spec and the body.
              -- Two separate global string variables are being populated one each for the
              -- spec and the body.
              -- The idea here it to create a new spec/body for every unique module_hook_id.
              -- Every unique module_hook_id will have a unique signature for most cases.
              create_package_header(
                 p_module_hook_id  => v_api_hooked_entities.module_hook_id
              ,  p_parameter_table => g_hook_parameter_table
              );

                 l_inner_loop := 0;
	         for v_api_hook_calls in c_api_hook_calls(v_api_hooked_entities.module_hook_id)
	         loop
	            l_inner_loop := l_inner_loop + 1;
	            if (l_debug = 1) then
	               trace(l_proc ||' Iteration No ' || l_inner_loop || ' in the outer loop');
	               trace(l_proc ||' ***hook call id ' ||v_api_hook_calls.hook_call_id|| ' ***');
	               trace(l_proc ||' ***call package name ' ||v_api_hook_calls.called_package|| ' ***');
	               trace(l_proc ||' ***call procedure name ' ||v_api_hook_calls.called_procedure|| ' ***');
                    end if;

	            -- Call to routine to construct the if ...else clause in the package body
	            -- to call cll package/procedure registered foe a specific module_hook_id.
		    create_package_body(
		       p_called_package	    => v_api_hook_calls.called_package
		    ,  p_called_procedure   => v_api_hook_calls.called_procedure
		    ,  p_hook_call_id       => v_api_hook_calls.hook_call_id
		    ,  p_parameter_table    => g_hook_parameter_table
		    ,  p_iteration          => l_inner_loop
                    );

                    if (l_debug = 1) then
                       trace(l_proc ||' End of Iteration Number ' || l_inner_loop || ' in the Outer Loop');
                    end if;
                  end loop;

                  if l_inner_loop = 0 then
                     -- no records found in wms_api_hook_calls table
                     -- Hence insert a null between the begin and end in the body so that the
                     -- package generation will not fail. There can be cases where all relationships
                     -- for a parent may be disabled and this cursor will not return records.
                     add_to_string(c_new_line, 'B');
                     add_to_string('null;', 'B');
                     add_to_string(c_new_line, 'B');
                  else
                     add_to_string(c_new_line, 'B');
                     add_to_string('end if; '|| c_new_line, 'B');
                  end if;

                  add_to_string('end; '|| c_new_line, 'B');
                  add_to_string(c_new_line, 'B');
                  add_to_string('end '||g_sysgen_custom_package||';'|| c_new_line, 'B');

                  --
                  -- Drop the current package counter to be recreated. Do not drop both the packages because
                  -- the other one may be in use.
                  --
                  for v_drop_sysgen_packages in c_drop_sysgen_packages(v_api_hooked_entities.module_hook_id)
                  loop
                    begin
                      if (l_debug = 1) then
                         trace(l_proc ||' Sysgen_custom_package  : ' ||v_drop_sysgen_packages.sysgen_custom_package);
		         trace(l_proc ||' Current Pkg Counter : ' ||v_drop_sysgen_packages.current_package_cntr);
		      end if;

                      l_package_name_drop := v_drop_sysgen_packages.sysgen_custom_package ||'_'||l_current_package_cntr;

                      if (l_debug = 1) then
                         trace(l_proc ||' drop package name constructed : ' || l_package_name_drop);
                      end if;

  	              l_csr_sql := dbms_sql.open_cursor;
		      dbms_sql.parse
		      (l_csr_sql
		      ,'DROP PACKAGE BODY ' || l_package_name_drop
		      ,dbms_sql.native
		      );
		      l_rows := dbms_sql.execute( l_csr_sql );
		      dbms_sql.close_cursor( l_csr_sql );
		    exception
		       when others then
		       --
		       -- Drop package failed.
		       --
		       if (l_debug = 1) then
		          trace(l_proc ||' Drop package statement failed to drop package');
		          trace(l_proc ||' Drop Package Error Code = ' || sqlcode);
		          trace(l_proc ||' Drop Package Error Message = ' || sqlerrm);
		       end if;

		       if dbms_sql.is_open( l_csr_sql ) then
		          dbms_sql.close_cursor( l_csr_sql );
		       end if;
		    end;
		   end loop;

                  if (l_debug = 1) then
                     trace(l_proc ||' g_spec_string : ' || c_new_line || g_spec_string);
		     trace(l_proc ||' g_body_string : ' || c_new_line || g_body_string);
		  end if;

 		  -- Generate the spec and body for each iteration of the module_hook_id and its associated
                  -- call package(s)/procedure(s)
                  execute_source(g_spec_string);
                  execute_source(g_body_string);

        	  -- Update wms_api_hooked_entities to indicate which is the current package in use
		  -- to avoid being updated when in use.
		  begin
		      update wms_api_hooked_entities
		      set    current_package_cntr = l_current_package_cntr
		      where  module_hook_id = v_api_hooked_entities.module_hook_id;

		      commit;
		  exception
		    when others then
		      if (l_debug = 1) then
		         trace(l_proc ||' Update wms_api_hooked_entities failed with error = ' || sqlerrm(sqlcode));
		      end if;
		      x_retcode  := 2;
		      x_errbuf   := 'Error';
	              return;
		  end;

                  if (l_debug = 1) then
                     trace(l_proc ||' End of Iteration Number ' || l_outer_loop || ' in the Outer Loop');
                  end if;
              end loop;
          end loop;

          if (l_debug = 1) then
             trace(l_proc ||' Final Number of Outer Loops : ' || l_outer_loop);
             trace(l_proc ||' Final Number of Middle Loops : ' || l_middle_loop);
             trace(l_proc ||' Final Number of Inner Loops : ' || l_inner_loop);
          end if;

end create_wms_system_objects;
--
--
-- -------------------------------------------------------------------------------------------
-- |---------------------< chk_param_in_hook_proc_call >--------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is responsible for validating the eligibility of a
--   package.procedure to be hooked to a parent package.procedure. Checks are
--   to ensure that the signature of the custom(in fact called) API conforms
--   to the signature registered witht eh aprent record.
--   If the parameter should be on a procedure checks the call is not to a
--   function. If an error is found AOL error details are set but a PL/SQL
--   exception is not raised.
--
-- Prerequisites:
--   p_number_of_parameters, p_hook_parameter_names and
--   p_hook_parameter_datatypes are set with details of the hook package
--   procedure parameter details.
--
-- In Parameters:
--   Name                        Reqd Type     Description
--   ---------------------       ---- -------- ---------------------------------------------
--   p_call_parameter_name       Yes  varchar2 Parameter in the procedure to be called.
--   p_call_parameter_datatype   Yes  number   The internal code for the parameter datatype.
--   p_call_parameter_in_out     Yes  number   The internal code for the parameter IN/OUT type.
--   p_call_parameter_overload   Yes  number   The overload number for the call procedure parameter.
--   p_previous_overload         Yes  number   The overload number for the previous parameter on the
--                                             call procedure.
--   p_param_valid               Yes  boolean  Indicates if the parameter is valid.
--
-- Post Success:
--   Returns true.
--
-- Post Failure:
--   Details of the error are added to the AOL message stack. When this
--   function returns false the error has not been raised. It is up to the
--   calling logic to raise or process the error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure chk_param_in_hook_proc_call
  ( p_call_parameter_name           in     varchar2
  , p_call_parameter_datatype       in     number
  , p_call_parameter_in_out         in     number
  , p_call_parameter_overload       in     number
  , p_previous_overload             in     number
  , p_parameter_position            in     number
  , p_param_valid                   out    nocopy boolean
  , x_retcode                       out nocopy number
  , x_errbuf                        out nocopy varchar2
  ) is
  --
  -- Variables to store converted values for the paramater table elements.
  --
  l_parameter_type	  number;
  l_parameter_in_out	  number;
  l_number_of_parameters  number:= g_parameter_table.count;
  --
  --
  --
  l_loop             number;            -- Loop counter
  l_param_found      boolean;           -- Indicates if the parameter has been
                                        -- found in the hook parameter list.
  l_param_valid      boolean;           -- Indicates if parameter is valid.

  l_proc             varchar2(72) := 'chk_param_in_hook_proc_call :';
begin
  if (l_debug =1 ) then
     trace('Entering Procedure '|| l_proc ||':' || to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
     trace(l_proc||'p_call_parameter_name = ' || p_call_parameter_name);
     trace(l_proc||'p_call_parameter_datatype = ' || p_call_parameter_datatype);
     trace(l_proc||'p_call_parameter_in_out = ' || p_call_parameter_in_out);
     trace(l_proc||'p_call_parameter_overload = ' || p_call_parameter_overload);
     trace(l_proc||'p_previous_overload  = ' || p_previous_overload);
     trace(l_proc||'l_number_of_parameters = '|| l_number_of_parameters);
  end if;
  --
  -- Assume the parameter is valid until an error is found
  --
  l_param_valid := true;
  --
  -- Validate the call does not have any overload versions by
  -- checking that the overload number for the current parameter is the
  -- same as the previous parameter.
  --
  if p_call_parameter_overload <> p_previous_overload then
    -- Error: A call package procedure cannot have any PL/SQL overloaded
    -- versions. Code to carry out this hook call has not been created.
    if (l_debug =1 ) then
       trace(l_proc ||' Within p_call_parameter_overload <> p_previous_overload');
       trace(l_proc ||' Illegal for Custom procedure to have an overloaded signature');
    end if;
    l_param_valid := false;
    return;
  --
  -- Check the argument name has been set. If it is not set the entry
  -- returned from describe_procedure is for a function
  -- return value. Package functions should not be called.
  --
  elsif p_call_parameter_name is null then
    -- Error: A package function cannot be called. Only package procedures
    -- can be called. Code to carry out this hook call has not been created.
    if (l_debug =1 ) then
       trace(l_proc ||' Within p_call_parameter_name is null');
       trace(l_proc ||' Illegal to call package function,Only package procedures can be hooked as Custom Calls');
    end if;
    l_param_valid := false;
    return;
  else
    if (l_debug =1 ) then
       trace(l_proc ||' Within else - before start of while loop for comparison');
    end if;

    --
    if (l_debug = 1) then
       trace(l_proc||' p_parameter_position passed in => ' || p_parameter_position);
    end if;
    l_param_found := false;
    l_loop       := 0;
    --trace('l_param_found = '|| l_param_found);
    --trace('l_loop = '||  l_loop);
    --
    -- Keep searching through the parameter names table until the parameter
    -- name is found or the end of the list has been reached.
    -- If a match is found, then set the parameter_flag for the PL/SQL record
    -- to 'Y' so that the if condition within the next iteration of the while
    -- loop goes through only thoise records for which a match is not yet found.
    --
    while (not l_param_found) and (l_loop < l_number_of_parameters) loop
      l_loop := l_loop + 1;

      if (l_debug =1 ) then
         trace(l_proc||'Within While loop, Iteration number ' ||l_loop);
         trace(l_proc||'Parameter name in the global table  ' ||g_parameter_table(l_loop).parameter_name);
         trace(l_proc||'Parameter flag in the global table  ' ||g_parameter_table(l_loop).parameter_flag);
         trace(l_proc||'Parameter name in call signature     ' ||p_call_parameter_name);
      end if;

      if (l_debug =1 ) then
         trace(l_proc||' upper(g_parameter_table(l_loop).parameter_name) => '|| upper(g_parameter_table(l_loop).parameter_name));
         trace(l_proc||' upper(p_call_parameter_name) => '|| upper(p_call_parameter_name));
         trace(l_proc||' (g_parameter_table(l_loop).parameter_flag => ' || g_parameter_table(l_loop).parameter_flag);
      end if;

      if (upper(g_parameter_table(l_loop).parameter_name) = upper(p_call_parameter_name)
                                     and (g_parameter_table(l_loop).parameter_flag = 'N')
                                     and l_loop = p_parameter_position )
      then
         if (l_debug =1 ) then
            trace(l_proc||' Within check if parameter name passed in matches global table parameter name and flag is N is true ');
         end if;
         g_parameter_table(l_loop).parameter_flag := 'Y';

         if (l_debug =1 ) then
            trace(l_proc||'Parameter flag in the global table after setting...' ||g_parameter_table(l_loop).parameter_flag);
         end if;
         --l_number_of_parameters := l_number_of_parameters - 1;
         --trace('l_number_of_parameters ' || l_number_of_parameters);
         l_param_found := true;
      else
         if (l_debug =1 ) then
            trace(l_proc||' Within check if parameter name passed in matches global table parameter name and flag is N is false ');
         end if;
         l_param_found := false;
         if not l_param_found then
            trace(l_proc||' l_param_found is set to false...');
         else
            trace(l_proc||' l_param_found is set to true...');
         end if;

      --   p_param_valid := false;
      --   x_retcode := 2;
      --   x_errbuf := 'Error';
      --   return;
      end if;
    end loop;

    --
    -- If the parameter has been found carry out further parameter checks
    --
    if (l_param_found) then
      trace(l_proc||' Now that the parameter has been found......');
      --
      -- Check the datatype of the parameter is the same
      -- as the parameter in the hook package.
      --
      --
      -- Convert the parameter type to its appropriate number value.
      -- This is required since the p_call_parameter_datatype is of type
      -- number.
      if g_parameter_table(l_loop).parameter_type = c_dtype_varchar2 then
            l_parameter_type := 1;
      elsif g_parameter_table(l_loop).parameter_type = c_dtype_number then
            l_parameter_type := 2;
      elsif g_parameter_table(l_loop).parameter_type = c_dtype_long then
            l_parameter_type := 8;
      elsif g_parameter_table(l_loop).parameter_type = c_dtype_date then
            l_parameter_type := 12;
      elsif g_parameter_table(l_loop).parameter_type = c_dtype_boolean then
            l_parameter_type := 252;
      end if;
      --
      -- Convert the parameter in_out to its appropriate number value.
      -- This is required since the p_call_parameter_datatype is of type
      -- number.
      if g_parameter_table(l_loop).parameter_in_out = c_ptype_in then
 	     l_parameter_in_out := 0;
      elsif g_parameter_table(l_loop).parameter_in_out = c_ptype_out then
 	     l_parameter_in_out := 1;
      elsif g_parameter_table(l_loop).parameter_in_out = c_ptype_in_out then
 	     l_parameter_in_out := 256;
      end if;

      if (l_debug =1 ) then
         trace(l_proc||'Global Parameter Type ' || l_parameter_type);
         trace(l_proc||'Call  Parameter Type ' || p_call_parameter_datatype);
         trace(l_proc||'Global Parameter in/out ' || l_parameter_in_out);
         trace(l_proc||'Call  Parameter in/out ' || p_call_parameter_in_out);
      end if;

      if l_parameter_type <> p_call_parameter_datatype then
        -- Error: The *PARAMETER parameter to the call procedure must
        -- have the same datatype as the value available at the hook.
        -- Code to carry out this hook call has not been created.
        if (l_debug =1 ) then
           trace(l_proc||' Parameter types dont match ');
        end if;
        l_param_valid := false;
      --
      -- Check that the parameter to the call
      -- package procedure is of type IN
      --
      elsif l_parameter_in_out <> p_call_parameter_in_out then
        -- Error: At least one OUT or IN/OUT parameter has been specified
        -- on the call procedure. You can only use IN parameters. Code to
        -- carry out this hook call has not been created.
        if (l_debug =1 ) then
           trace(l_proc||' Parameter in_out dont match ');
        end if;
        l_param_valid := false;
       else
       -- Both the Call paramater data type and parameter in/out match
       -- and hence this is an exact match.
        l_param_valid := true;
      end if;
    else
      --
      -- The parameter in the call package procedure could not be
      -- found in the hook package procedure parameter list.
      --
      -- Error: There is a parameter to the call procedure which is not
      -- available at this hook. Check your call procedure parameters.
      -- Code to carry out this hook call has not been created.
      --if (l_debug =1 ) then
      --   trace(l_proc||' Parameter ' || p_call_parameter_name || ' has not been found......');
      --end if;

      l_param_valid := false;
      if not l_param_valid then
         trace(l_proc||' l_param_valid is set to false...');
      else
         trace(l_proc||' l_param_valid is set to true...');
      end if;

    end if;
  end if;
  --
  -- Return the parameter status
  --
  if l_param_valid then
      p_param_valid := true;
      x_retcode := 1;
  else
      p_param_valid := false;
      x_retcode := 2;
      x_errbuf := 'Error';

      if (l_debug =1 ) then
         trace(l_proc||' After setting p_param_valid to false......');
         trace(l_proc||' x_retcode => ' || x_retcode);
         trace(l_proc||' x_errbuf => '|| x_errbuf);
      end if;

  end if;
  --
  if (l_debug =1 ) then
     trace(l_proc||' Leaving:'||l_proc);
  end if;

exception
  when others then
      if (l_debug =1 ) then
         trace(l_proc||' Error Message in when others of validate_call_signature = ' || sqlerrm(sqlcode));
      end if;
end chk_param_in_hook_proc_call;
--
--
-- -------------------------------------------------------------------------------------------
-- |-----------------------< validate_call_signature >----------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates if the call package-procedure signature matches the parent hook's
--   signature.
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                    Reqd Type      Description
--   ---------------------   ---- --------  ---------------------------
--   p_module_hook_id        Yes  number    ID of the module/hook call.
--   p_call_package_name     Yes  varchar2  Name of the package to call.
--   p_call_procedure_name   Yes  varchar2  Name of the procedure within
--                                          p_call_package_name to call.
--   x_signature_valid       No   boolean   True when signature matches
--                                          false for all other cases.
--                                          if invalid code should be
--   x_return_status         Yes  number    Return Status
--   x_msg_count             Yes  number    Message Stack Count.
--   x_msg_data              Yes  number    Message Stack Data.
--
-- Post Success:
--   Validates and returns true .Creates source code for one package procedure call.
--
-- Post Failure:
--   Returns false.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure validate_call_signature(
   p_module_hook_id        in number
,  p_call_package_name     in varchar2
,  p_call_procedure_name   in varchar2
,  x_signature_valid       out nocopy boolean
,  x_retcode               out nocopy number
,  x_errbuf                out nocopy varchar2
) is

  --
  -- Local variables to catch the values returned from
  -- describe_procedure
  --
  l_overload            dbms_describe.number_table;
  l_position            dbms_describe.number_table;
  l_level               dbms_describe.number_table;
  l_argument_name       dbms_describe.varchar2_table;
  l_datatype            dbms_describe.number_table;
  l_default_value       dbms_describe.number_table;
  l_in_out              dbms_describe.number_table;
  l_length              dbms_describe.number_table;
  l_precision           dbms_describe.number_table;
  l_scale               dbms_describe.number_table;
  l_radix               dbms_describe.number_table;
  l_spare               dbms_describe.number_table;

  --
  -- Variable to store the parameter table passed out from the call to
  -- populate_parameter_table
  l_return_status         varchar2(100);
  l_number_of_parameters  number;
  l_called_package        varchar2(100);
  l_called_procedure      varchar2(100);
  l_error_code            number;
  l_error_message         varchar2(240);
  l_object_name		  varchar2(240);

  --
  -- Other local variables
  --
  l_loop                binary_integer;    -- Loop counter.
  l_loop_describe       binary_integer;    -- Loop counter
  l_param_details       varchar2(80);      -- Used to construct the user descriptions
                                           -- for the parameters.
  l_datatype_str        varchar2(20);      -- String equivalent of the parameter
                                           -- datatype.
  l_in_out_str          varchar2(20);      -- String equivalent of the parameter in/out.
  l_pre_overload        number;            -- Overload number for the previous
                                           -- parameter.
  l_param_valid         boolean := true;   -- Indicates if the current
                                           -- parameter is valid for this hook.
  l_describe_error      boolean := false;  -- Indicates if the
                                           -- describe_procedure raised an
                                           -- error for the call package
                                           -- procedure.
  l_encoded_err_text    varchar2(2000);    -- Set to the encoded error text
                                           -- when an error is written to the
                                           -- WMS_API_HOOK_CALLS table. Not in
                                           -- patchset 'J'.
  l_call_code           varchar2(32767) := null;
  l_proc                varchar2(72) := 'VALIDATE_CALL_SIGNATURE :';
  l_prog                float;

begin
  -- Initialize API return code to success
  x_retcode := 1;
  x_errbuf   := null;

  l_prog := 53.1;
  if (l_debug = 1) then
     trace(l_proc||' Passed Progress '|| l_prog);
     trace(l_proc|| ' Module Hook ID : ' || p_module_hook_id);
  end if;

  if (l_debug = 1) then
     trace(l_proc||' Passed Progress :'|| l_prog);
     trace(l_proc||' Before Calling populate_parameter_table...', 4);
  end if;
  -- Populate the global parameter table with the signature definition of the parent
  -- in the begining. This will be used to compare the signature of the call
  -- procedure which is intended to be registered.
  populate_parameter_table(
     p_module_hook_id  => p_module_hook_id
  ,  p_parameter_table => g_parameter_table
  );

  l_prog := 53.2;
  if (l_debug = 1) then
     trace(l_proc||' Passed Progress :'|| l_prog);
     trace(l_proc||' After Calling populate_parameter_table...', 4);
  end if;

  -- Variable to keep count of number of parameters in the parent signature.
  -- This is used in the code later.
  l_number_of_parameters := g_parameter_table.count;

  if (l_debug = 1) then
     trace(l_proc||' Passed Progress :'|| l_prog);
     trace(l_proc||' After Calling populate_parameter_table...', 4);
     trace(l_proc||' No of parameters in the parameter table ' || l_number_of_parameters, 4);
  end if;

  --
  -- Call an custom RDMS procedure to obtain the list of parameters to the call
  -- package procedure. A separate begin ... end block has been specified so
  -- that errors raised by custom_describe_procedure can be trapped and
  -- handled locally.
  --
  l_prog := 53.3;
  begin
     if (l_debug = 1) then
        trace(l_proc||' Passed Progress :'|| l_prog);
        trace(l_proc||' Call Package Name : ' || p_call_package_name);
        trace(l_proc||' Call Procedure Name : ' || p_call_procedure_name);
     end if;

     --
     -- Create the <package>.<procedure> name..
     --
     l_object_name := p_call_package_name || '.' || p_call_procedure_name;

     if (l_debug = 1) then
        trace(l_proc||' Object Name : ' || l_object_name);
     end if;

     if (l_debug = 1) then
        trace(l_proc||' Passed Progress :'|| l_prog);
        trace(l_proc||' Before Calling dbms_describe.describe_procedure...', 4);
     end if;

     l_prog := 53.4;

     dbms_describe.describe_procedure(
        object_name   => l_object_name
     ,  reserved1     => null
     ,  reserved2     => null
     ,  overload      => l_overload
     ,  position      => l_position
     ,  level         => l_level
     ,  argument_name => l_argument_name
     ,  datatype      => l_datatype
     ,  default_value => l_default_value
     ,  in_out        => l_in_out
     ,  length        => l_length
     ,  precision     => l_precision
     ,  scale         => l_scale
     ,  radix         => l_radix
     ,  spare         => l_spare
     );

     --
     -- Loop through the values which have been returned.
     --
     begin
          --
          -- There is separate PL/SQL block for reading from the PL/SQL
          -- tables. We do not know how many parameter exist. So we have to
          -- keep reading from the tables until PL/SQL finds a row when has
          -- not been initialised and raises a NO_DATA_FOUND exception.
          --
          l_loop_describe := 1;
          <<step_through_param_list>>
          loop
            --
            -- Work out the string name of the parameter datatype code
            --
            if l_datatype(l_loop_describe) = 1 then
              l_datatype_str := 'VARCHAR2';
            elsif l_datatype(l_loop_describe) = 2 then
              l_datatype_str := 'NUMBER';
            elsif l_datatype(l_loop_describe) = 12 then
              l_datatype_str := 'DATE';
            elsif l_datatype(l_loop_describe) = 252 then
              l_datatype_str := 'BOOLEAN';
            elsif l_datatype(l_loop_describe) = 8 then
              l_datatype_str := 'LONG';
            end if;

           if l_in_out(l_loop_describe) = 0 then
	      l_in_out_str := 'IN';
	   elsif l_in_out(l_loop_describe) = 1 then
	      l_in_out_str := 'OUT';
	   elsif l_in_out(l_loop_describe) = 12 then
	      l_in_out_str := 'IN/OUT';
	   end if;

            --
            -- Construct parameter details to output
            --
            l_param_details := '  ' || rpad(l_argument_name(l_loop_describe), 31) || l_datatype_str
                             ||' '|| l_in_out_str ||' '|| l_length(l_loop_describe)
                             ||' '|| l_precision(l_loop_describe)||' '|| l_scale(l_loop_describe);

            if (l_debug = 1) then
               trace(l_proc||' l_param_details=' ||l_param_details);
            end if;


            l_loop_describe := l_loop_describe + 1;
          end loop step_through_param_list;
      end;

     l_prog := 53.5;
     if (l_debug = 1) then
        trace(l_proc|| ' Passed Progress :'|| l_prog);
        trace(l_proc|| ' After Calling dbms_describe.describe_procedure...', 4);
     end if;
  exception
    when Package_Not_Exists then
      -- Error: The call_package does not exist in the database. Code to
      -- carry out this hook call has not been created.
      if (l_debug = 1) then
         trace(l_proc|| ' Passed Progress :'|| l_prog);
         trace(l_proc|| ' Call_package does not exist in the database');
      end if;
      l_describe_error := true;
      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;

    when Proc_Not_In_Package then
      -- Error: The call_procedure does not exist in the call_package.
      -- Code to carry out this hook call has not been created.
      if (l_debug = 1) then
         trace(l_proc|| ' Passed Progress :'|| l_prog);
         trace( l_proc|| ' Called Procedure does not exist in the Called Package');
      end if;
      l_describe_error := true;
      l_describe_error := true;
      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;

    when Remote_Object then
      -- Error: Remote objects cannot be called from API User Hooks.
      -- Code to carry out this hook call has not been created.
      if (l_debug = 1) then
         trace(l_proc|| ' Passed Progress :'|| l_prog);
         trace(l_proc|| ' Remote objects cannot be called from API User Hooks');
      end if;
      l_describe_error := true;
      l_describe_error := true;
      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;

    when Invalid_Package then
      -- Error: The call_package code in the database is invalid.
      -- Code to carry out this hook call has not been created.
      if (l_debug = 1) then
         trace(l_proc|| ' Passed Progress :'|| l_prog);
         trace(l_proc|| ' Called Package code in the database is Invalid');
      end if;
      l_describe_error := true;
      l_describe_error := true;
      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;

    when Invalid_Object_Name then
      -- Error: An error has occurred while attempting to parse the name of
      -- the call package and call procedure. Check the package and procedure
      -- names. Code to carry out this hook call has not been created.
      if (l_debug = 1) then
         trace(l_proc|| ' Passed Progress :'|| l_prog);
         trace(l_proc|| ' Error occurred while attempting to compile call package and call procedure');
      end if;
      l_describe_error := true;
      l_describe_error := true;
      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;

    when others then
      if (l_debug = 1) then
         trace(l_proc||' In others');
         trace(l_proc||' User error code = ' || sqlcode);
         trace(l_proc||' User error message = ' || sqlerrm);
      end if;
      --l_describe_error := true;
      if (l_debug = 1) then
         trace(l_proc||' l_loop_describe value after the describe loop => ' || l_loop_describe);
      end if;

      --x_retcode  := 2;
      --x_errbuf   := 'Error';
      --return;
  end;

  --
  -- Only carry out the parameter validation if custom_describe_procedure did not raise an error.
  --
  if not l_describe_error
  then
      l_prog := 53.6;
      if (l_debug = 1) then
         trace(l_proc||' Passed Progress :'|| l_prog);
         trace(l_proc||' Within not l_describe_error');
      end if;
      --
      -- Search through the tables returned to validate the parameter list
      --
      l_loop         := 1;
      l_pre_overload := l_overload(1);
      begin
        if (l_debug = 1) then
           trace(l_proc||' Within begin within not l_describe_error');
           trace(l_proc||' l_number_of_parameters =>'|| l_number_of_parameters);
        end if;
        --
        -- There is separate PL/SQL block for reading from the PL/SQL tables.
        -- We do not know how many parameters exist. So we have to keep reading
        -- from the tables until PL/SQL finds a row when has not been
        -- initialised and raises a NO_DATA_FOUND exception or an invalid
        -- parameter is found.
        --
        l_loop := 1;

        --while l_param_valid and (l_loop <= l_number_of_parameters) loop
        while l_param_valid and (l_loop < l_loop_describe) loop
          --l_loop := l_loop + 1;

          if (l_debug = 1) then
             trace(l_proc||' Within the while loop... l_loop => '|| l_loop);
          end if;
          --
          -- Check that the parameter to the package procedure to be
          -- called exists on the hook package procedure, it is of the same
          -- datatype, the code to call is not a function and there are no
          -- overload versions.
          --
          l_prog := 53.6;
          if (l_debug = 1) then
             trace(l_proc||' Passed Progress :'|| l_prog);
             trace(l_proc||' Before calling procedure chk_param_in_hook_proc_call... ');
             trace(l_proc||' l_argument_name = ' || l_argument_name(l_loop));
             trace(l_proc||' l_datatype      = ' || l_datatype(l_loop));
             trace(l_proc||' l_in_out        = ' || l_in_out(l_loop));
             trace(l_proc||' l_overload      = ' || l_overload(l_loop));
             trace(l_proc||' l_pre_overload  = ' || l_pre_overload);
          end if;

          chk_param_in_hook_proc_call(
             p_call_parameter_name      => l_argument_name(l_loop)
          ,  p_call_parameter_datatype  => l_datatype(l_loop)
          ,  p_call_parameter_in_out    => l_in_out(l_loop)
          ,  p_call_parameter_overload  => l_overload(l_loop)
          ,  p_previous_overload        => l_pre_overload
          ,  p_parameter_position       => l_loop
          ,  p_param_valid              => l_param_valid
          ,  x_retcode                  => x_retcode
          ,  x_errbuf                   => x_errbuf
          );

          if x_retcode <> 1 then
             trace(l_proc||' call to chk_param_in_hook_proc_call returned return code of error....');

             l_param_valid := false;
             x_retcode  := 2;
             x_errbuf   := 'Error';
             exit;
          end if;
          l_prog := 53.7;
          if (l_debug = 1) then
             trace(l_proc||' Passed Progress :'|| l_prog);
             trace(l_proc||' After calling procedure chk_param_in_hook_proc_call for each parameter... ');
          end if;

          --
          -- Prepare loop variables for the next iteration
          --
          l_pre_overload := l_overload(l_loop);
          l_loop := l_loop + 1;
        end loop; -- end of while loop

        -- Check to make sure that the number of parameters in the param table and the signature match.
        --if l_loop <> l_number_of_parameters then
        --   if (l_debug = 1) then
        --      trace(l_proc||' Incorrect number of parameters in Signature.....', 4);
        --   end if;
        --   x_retcode  := 2;
        --   x_errbuf   := 'Error';
        --   return;
        --end if;


        l_prog := 53.8;
        if (l_debug = 1) then
           trace(l_proc||' Passed Progress :'|| l_prog);
           trace(l_proc||' Out of the While loop');
        end if;
      end;
  end if;

  -- l_param_valid = true means that the signature matches. If the signature
  -- doesn't match at any point in the iteration cycle, the l_param_valid will
  -- come out with l_param_valid =  false.
  l_prog := 53.9;
  if l_param_valid then
     x_signature_valid := true;
     if (l_debug = 1) then
        trace(l_proc||' Passed Progress :'|| l_prog);
        trace(l_proc||' Setting Signature  to Valid');
     end if;
     x_retcode  := 1;
     x_errbuf   := null;
     return;
  else
     if (l_debug = 1) then
        --trace(l_proc|| 'Check paramater => '|| p_call_parameter_name);
        trace(l_proc||' Invalid parameter found or signature is missing all the required parameters.....');
     end if;

     x_signature_valid := false;
     if (l_debug = 1) then
        trace(l_proc||' Passed Progress :'|| l_prog);
        trace(l_proc||' Setting Signature to Invalid');
     end if;
     x_retcode  := 2;
     x_errbuf   := 'Error';
     return;
  end if;

exception
    when others then
       if (l_debug = 1) then
          trace(l_proc||' Error Message in when others of validate_call_signature = ' || sqlerrm(sqlcode));
       end if;
      x_retcode  := 2;
      x_errbuf   := 'Error';
      return;
end validate_call_signature;
--
--
-- -------------------------------------------------------------------------------------------
-- |----------------------------< create_delete_api_call >------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Populate the global PL/SQL structure(hook_parameter_table_type) with the
--   parameters of the signature for the Parent Module/Business Process/ PL/SQL
--   Package-Procedure combination
--
-- Prerequisites:
--   p_module_hook_id is set with the proper value.
--
--
-- In Parameters:
--   Name                   Reqd Type      Description
--   --------------------   ---- --------  -------------------------------------
--   p_hook_short_name_id   Yes  varchar2  Short name for parent Module/Business
--                     	                   Process/ PL/SQL Package-Procedure
--                                         combination.
--   p_call_package         Yes  varchar2  Call package to be registered                                                                              --   p_call_procedure       Yes  varchar2  Call procedure to be registered
--   p_effective_to_date    Yes  varchar2  Effective To Date.
--   p_mode 		    Yes  varchar2  Valid Modes are Insert, Update and
--                                         Disable.
-- Post Success:
--   Returns true. Returns a PL/SQL of type hook_parameter_table_type.
--
-- Post Failure:
--   Details of the error are added to the AOL message stack. When this
--   function returns false the error has not been raised. It is up to the
--   calling logic to raise or process the error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- Inserting should check for the following :
-- 1. Check to make sure that the combination does not already exist.
-- 2. If the combination does not exist, then make sure that the application_id
--    matches the one on the parent record.
-- 3. Make sure that the effective date is not less that the system date when
--    the registrtaion program is run.
-- 4. Make sure that
--
Procedure create_delete_api_call(
   p_hook_short_name_id   in  number
,  p_call_package         in  varchar2
,  p_call_procedure       in  varchar2
,  p_call_description     in  varchar2
,  p_effective_to_date    in  date
,  p_mode                 in  varchar2
,  x_retcode              out nocopy number
,  x_errbuf               out nocopy varchar2
) is

     l_module_hook_id			number;
     l_hooked_package			varchar2(100);
     l_hooked_procedure			varchar2(100);
     l_sysgen_custom_package		varchar2(100);
     l_sysgen_custom_procedure		varchar2(100);
     l_application_id                   number;
     l_called_package			varchar2(100);
     l_called_procedure			varchar2(100);
     l_hook_call_id			number;
     l_hook_call_id_seq			number;
     l_status 				varchar2(100);
     l_return_status			varchar2(100);
     l_sign_valid			boolean;
     l_enabled_flag			varchar2(1);

     l_msg_count                        number;
     l_msg_data				varchar2(100);

     l_package 				varchar2(128);
     l_dotpos  				number;
     compile   				boolean := false;
     l_csr_sql 				integer;
     l_rows    				integer;

     l_seed_flag			varchar2(1);

     --
     -- Local variables to catch the values returned from
     -- describe_procedure
     --
     l_overload            dbms_describe.number_table;
     l_position            dbms_describe.number_table;
     l_level               dbms_describe.number_table;
     l_argument_name       dbms_describe.varchar2_table;
     l_datatype            dbms_describe.number_table;
     l_default_value       dbms_describe.number_table;
     l_in_out              dbms_describe.number_table;
     l_length              dbms_describe.number_table;
     l_precision           dbms_describe.number_table;
     l_scale               dbms_describe.number_table;
     l_radix               dbms_describe.number_table;
     l_spare               dbms_describe.number_table;

     l_proc       varchar2(72) := 'CREATE_DELETE_API_CALL :';
     l_prog       float;


     -- This cursor should only return one record always.
     -- The short name for the parent record will be maintained as an mfg_lookup.
     cursor c_call_hook_status is
     select wahe.module_hook_id, wahe.hooked_package, wahe.hooked_procedure,
            wahe.sysgen_custom_package, wahe.sysgen_custom_procedure,
            wahc.called_package, wahc.called_procedure, wahc.hook_call_id,
            wahc.enabled_flag, wahc.seed_flag
     from   wms_api_hooked_entities wahe,
            wms_api_hook_calls wahc
     where  wahe.module_hook_id = wahc.module_hook_id(+)
     and    wahe.short_name_id = p_hook_short_name_id
     and    wahc.called_package(+) = p_call_package
     and    wahc.called_procedure(+) = p_call_procedure;

begin
      -- Initialize API return code to success
      x_retcode := 1;
      x_errbuf   := null;

      l_prog := 10;
      if (l_debug = 1) then
         trace(l_proc||' Passed Progress '|| l_prog);
         trace(l_proc||' Parameter Values.........');
         trace(l_proc||' Short Name ID passed in  '|| p_hook_short_name_id);
         trace(l_proc||' Call Package passed in ' || p_call_package);
         trace(l_proc||' Call Procedure passed in ' || p_call_procedure);
      end if;

      l_prog := 20;
      open  c_call_hook_status;

      l_prog := 30;
      fetch c_call_hook_status
      into  l_module_hook_id, l_hooked_package, l_hooked_procedure,
            l_sysgen_custom_package, l_sysgen_custom_procedure,
            l_called_package, l_called_procedure, l_hook_call_id,
            l_enabled_flag, l_seed_flag;

      if (l_debug = 1) then
         trace(l_proc||' Passed Progress '|| l_prog);
         trace(l_proc||' Derived Values...');
         trace(l_proc||' Module Hook ID derived : '|| l_module_hook_id);
         trace(l_proc||' Hooked Package derived : '|| l_hooked_package);
         trace(l_proc||' Hooked Procedure/function derived : '|| l_hooked_procedure);
         trace(l_proc||' System Generated Package derived : '|| l_sysgen_custom_package);
         trace(l_proc||' System Generated Prodcedure derived : '|| l_sysgen_custom_procedure);
         trace(l_proc||' Application ID derived : '|| l_application_id);
         trace(l_proc||' Called Package : ' || l_called_package);
         trace(l_proc||' Called Procedure  ' || l_called_procedure);
      end if;

	if c_call_hook_status%FOUND then
	   l_prog := 40;
	   --
	   -- Delete Section. Separated from Create on August 18th 2003. Makes it more simpler.
	   --
	   if (l_called_package = p_call_package and l_called_procedure = p_call_procedure) then
	      l_prog := 41;
	      if (l_debug = 1) then
	         trace(l_proc||' Passed Progress '|| l_prog);
	         trace(l_proc||' Within the if condition where the called package/procedure derived and passed in matches');
	      end if;
	      --
	      -- Check mode to take appropriate action.
	      --
	      if p_mode = c_create_mode
	      then
	         l_prog := 42;
	         if (l_debug = 1) then
	            trace(l_proc||' Passed Progress :'|| l_prog);
	            trace(l_proc||' Mode is :' || c_create_mode);
	            trace(l_proc||' This combination is already registered for the given mode  ' || p_mode, 4);
	         end if;
	         close c_call_hook_status;
                 x_retcode  := 2;
                 x_errbuf   := 'Error';
	         return;

	      elsif (p_mode = c_delete_mode  and l_enabled_flag = 'Y' and l_seed_flag = 'Y') then
	         --
	         -- Seeded Hook Calls are not allowed to be deleted...
	         --
	         l_prog := 43;
	         if (l_debug = 1) then
	  	    trace(l_proc||' Passed Progress :'|| l_prog);
	            trace(l_proc||' Mode is :' || c_delete_mode);
	            trace(l_proc||' Delete prohibited, Attempted to Delete Seeded Call.. Aborting  ' || p_mode	                        ||' Module Hook ID :' || l_module_hook_id);
	            trace(l_proc||' Hook Call ID :' || l_hook_call_id, 4);
	         end if;
                 x_retcode  := 2;
                 x_errbuf   := 'Error';
                 return;

	      elsif (p_mode = c_delete_mode  and l_enabled_flag = 'Y' and l_seed_flag <> 'Y')
	      then
	         --
	         -- For deletion, the combination should pre-exist.
	         --
                 l_prog := 44;
	         if (l_debug = 1) then
	            trace(l_proc||' Passed Progress :'|| l_prog);
	            trace(l_proc||' Preparing to  ' || p_mode);
	            trace(l_proc||' Module Hook ID ' || l_module_hook_id);
	            trace(l_proc||' Hook Call ID ' || l_hook_call_id);
	         end if;

                 --
                 -- Delete records in the WMS_API_HOOK_CALLS table..
                 --
                 l_prog := 45;
                 delete from wms_api_hook_calls
	         where  module_hook_id = l_module_hook_id
	         and    hook_call_id = l_hook_call_id
	         and    called_package = p_call_package
	         and    called_procedure = p_call_procedure;

	         commit;

	         if (l_debug = 1) then
	             trace(l_proc||' Passed Progress :'|| l_prog);
	             trace('Deleting Relationship Completed...');
	         end if;
	         --
		 -- Call the package generation API.
		 --
		 l_prog := 46;
	         if (l_debug = 1) then
	            trace(l_proc||' Passed Progress :'|| l_prog);
	            trace(l_proc||' Before Calling create_wms_system_objects within DELETE mode', 4);
	         end if;

		 --
		 -- Calling procedure create_wms_system_objects
		 --
		 create_wms_system_objects(
		    x_retcode        => x_retcode
		 ,  x_errbuf         => x_errbuf
		 );

		l_prog := 47;
	        if (l_debug = 1) then
	           trace(l_proc||' Passed Progress :'|| l_prog);
	           trace(l_proc||' After Calling create_wms_system_objects within DELETE mode', 4);
	        end if;

		if l_return_status <> 'S' then
		   if (l_debug = 1) then
		      trace(l_proc||' Package Generation Failed after Delete', 4);
                      x_retcode  := 2;
                      x_errbuf   := 'Error';
		   end if;
		else
		   if (l_debug = 1) then
		      trace(l_proc||' Package Generation Successfull after Delete ', 4);
		   end if;
		end if;

	        return;
	      end if;
	      return;
	   end if;

	   --
	   -- Create Section. Separated from Delete on August 18th 2003. Makes it more simpler.
	   --
	   l_prog := 50;
	   if ((l_called_package is null and l_called_procedure is null) and p_mode = c_create_mode)
	   then
	      if (l_debug = 1) then
	         trace(l_proc||' Passed Progress :'|| l_prog);
	         trace(l_proc||' Within the if condition where the called package/procedure derived and passed in does not match...');
	         trace(l_proc||' This combination does not exist and hence proceed with the Registration process.......', 4);
	         trace(l_proc||' Before Calling dbms_describe.describe_procedure...', 4);
	      end if;

              --
              -- Check if the call procedure exists in the call package in the database
              -- and if the package is valid. if the call package is invalid, try compiling
              -- it once, If successful proceed with the registration otherwise abort operation.
              l_prog := 51;
	      dbms_describe.describe_procedure(
		 object_name   => p_call_package || '.' || p_call_procedure
	      ,  reserved1     => null
	      ,  reserved2     => null
	      ,  overload      => l_overload
	      ,  position      => l_position
	      ,  level         => l_level
	      ,  argument_name => l_argument_name
	      ,  datatype      => l_datatype
	      ,  default_value => l_default_value
	      ,  in_out        => l_in_out
	      ,  length        => l_length
	      ,  precision     => l_precision
	      ,  scale         => l_scale
	      ,  radix         => l_radix
	      ,  spare         => l_spare
	      );

              --
              -- Attempt to compile the invalid package.
    	      --
    	      l_prog := 52;
    	      if compile then
                 begin
                     l_csr_sql := dbms_sql.open_cursor;
                     dbms_sql.parse(
                        l_csr_sql
                     ,  'ALTER PACKAGE ' || p_call_package || ' COMPILE SPECIFICATION'
                     ,  dbms_sql.native
                     );
                        l_rows := dbms_sql.execute( l_csr_sql );
                        dbms_sql.close_cursor( l_csr_sql );
                  exception
                    when others then
          	      if dbms_sql.is_open( l_csr_sql ) then
            		 dbms_sql.close_cursor( l_csr_sql );

         		 if (l_debug = 1) then
	 		    trace(l_proc||' Compilation of package ' || p_call_package || ' Failed.... ', 4);
	 		 end if;
                      end if;

         	      if (l_debug = 1) then
	 	         trace(l_proc||' Package does not exist... ' || sqlerrm(sqlcode), 4);
	 	      end if;

                      x_retcode  := 2;
    	              x_errbuf   := 'Error';
                      --
                      -- Compilation failed so the package is still invalid.
                      --
                      raise Invalid_package;
                  end;
                     --
                     -- DBMS_DESCRIBE.DESCRIBE_PROCEDURE succeeded so exit the loop.
                     --
               end if;

		  -- Validate the signature of the call procedure before inserting records in the
		  -- wms_api_hooks_table.
		  l_prog := 53;

	          if (l_debug = 1) then
	             trace(l_proc||' Passed Progress :'|| l_prog);
	             trace(l_proc||' Before Calling validate_call_signature within CREATE mode...', 4);
	          end if;


		  validate_call_signature(
		     p_module_hook_id      => l_module_hook_id
		  ,  p_call_package_name   => p_call_package
		  ,  p_call_procedure_name => p_call_procedure
		  ,  x_signature_valid     => l_sign_valid
		  ,  x_retcode             => x_retcode
		  ,  x_errbuf              => x_errbuf
  		  );

		  l_prog := 54;
		  if (x_retcode <> 2) then
	             if (l_debug = 1) then
	                trace(l_proc||' Passed Progress :'|| l_prog
	                         ||' After Calling validate_call_signature within CREATE mode successfully....', 4);
	             end if;
	          else
	             x_retcode  := 2;
	 	     x_errbuf   := 'Error';
	             return;
	          end if;

	          --
	          -- Signature Validity check...
	          --
		  if l_sign_valid then
		     -- Now that all the checks have been done we are ready to create
		     -- a record in the wms_api_hook_calls.
		     l_prog := 55;
		     select wms_api_hook_calls_s.nextval
		     into l_hook_call_id_seq
		     from dual;

		     if (l_debug = 1) then
		        trace(l_proc||' Passed Progress :'|| l_prog);
	                trace(l_proc||' Hook Call ID sequence to be inserted : ' || l_hook_call_id_seq);
		        trace(l_proc||' Inserting records into the wms_api_hook_calls table....', 4);
		     end if;


		     insert into wms_api_hook_calls(
		        hook_call_id
		     ,  module_hook_id
		     ,  enabled_flag
		     ,  called_package
		     ,  called_procedure
		     ,  effective_from_date
		     ,  effective_to_date
		     ,  last_updated_by
		     ,  last_update_date
		     ,  last_update_login
		     ,  creation_date
		     ,  created_by
		     ,  description
		     ,  seed_flag)
		     values(
		        l_hook_call_id_seq
		     ,  l_module_hook_id
		     ,  'Y'
		     ,  p_call_package
		     ,  p_call_procedure
		     ,  sysdate
		     ,  p_effective_to_date
		     ,  1
		     ,  sysdate
		     ,  1
		     ,  sysdate
		     ,  1
		     ,  p_call_description
		     ,  'N');

                     l_prog := 57;
                     if (l_debug = 1) then
		     	trace(l_proc||' Passed Progress :'|| l_prog);
		     	trace(l_proc||' After Calling Insert into wms_api_hook_calls..', 4);
	             end if;

 		     if (l_debug = 1) then
 		        trace(l_proc||' Record Inserted into wms_api_hook_calls successfully.....', 4);
 		     end if;

 		     l_prog := 58;
 		     if (l_debug = 1) then
		     	trace(l_proc||' Passed Progress :'|| l_prog);
		     	trace(l_proc||' Before Committing record...', 4);
	             end if;
	             --
	             -- Committing Record...
	             --
                     commit;

 		     l_prog := 59;
		     if (l_debug = 1) then
		        trace(l_proc||' Commit Complete...');
		      	trace(l_proc||' Passed Progress :'|| l_prog);
		       	trace(l_proc||' After Committing record...', 4);
	             end if;
 		  else
 		     if (l_debug = 1) then
 		     	trace(l_proc||' Signatures do not match. Registration Aborted....', 4);
                        x_retcode  := 2;
 	                x_errbuf   := 'Error';
 		     end if;
  	     	     return;
 		  end if;
 	   end if;

 	   --
 	   -- Taking care of Other Miscellaneous Delete Situations...
 	   --
 	   if (l_called_package is null and l_called_procedure is null) and p_mode = c_delete_mode then
	       --
	       -- Takes care of deleting a non-existent relationship.
	       --
	       l_prog := 70;
	       if (l_debug = 1) then
	          trace(l_proc||' Passed Progress :'|| l_prog);
	          trace(l_proc||' This relationship is non-existent...', 4);
	       end if;
               x_retcode  := 2;
 	       x_errbuf   := 'Error';
	       return;
	   elsif l_enabled_flag = 'N' and p_mode = c_delete_mode then
	       --
	       -- Relationship is already disabled.
	       --
	       l_prog := 80;
	       if (l_debug = 1) then
	          trace(l_proc||' Passed Progress :'|| l_prog);
	          trace(l_proc||' This relationship has been already disabled...', 4);
	       end if;
               x_retcode  := 2;
 	       x_errbuf   := 'Error';
	       return;
 	   end if;
	end if;
	close c_call_hook_status;

	--
	-- Call the package generation process.
	--
 	l_prog := 60;
	if (l_debug = 1) then
	   trace(l_proc||' Passed Progress :'|| l_prog);
	   trace(l_proc||' Before Calling create_wms_system_objects...within CREATE...', 4);
	end if;

	create_wms_system_objects(
	   x_retcode        => x_retcode
	,  x_errbuf         => x_errbuf
	);

 	l_prog := 61;
	if (l_debug = 1) then
	   trace(l_proc||' Passed Progress :'|| l_prog);
	   trace(l_proc||' After Calling create_wms_system_objects...within CREATE...', 4);
	end if;

	if l_return_status <> 'S' then
	   if (l_debug = 1) then
	      trace(l_proc|| ' Create Package Failed', 4);
	   end if;
           x_retcode  := 2;
 	   x_errbuf   := 'Error';
	else
	   if (l_debug = 1) then
	      trace(l_proc|| ' Package Created... ', 4);
	   end if;
	end if;
exception
	when Proc_Not_In_Package then
	   if ((l_debug = 1) and (l_prog = 51))then
	      trace(l_proc||' Invalid package/procedure combination ', 4);
	   end if;
           x_retcode  := 2;
           x_errbuf   := 'Error';
	   return;
	when Invalid_package then
           if not compile then
              compile := true;
           end if;
           if (l_debug = 1) then
              if (l_prog = 51) then
	         trace(l_proc||' Invalid package/procedure combination ', 4);
	      end if;
	   end if;
           x_retcode  := 2;
           x_errbuf   := 'Error';
	   return;
        when others then
       	   if (l_debug = 1) then
       	      if (l_prog = 45) then
                 trace(l_proc||' Error Deleting WMS_API_HOOK_CALLS table due to error: ' || sqlerrm(sqlcode), 4);
              end if;

              if (l_prog = 56) then
	         trace(l_proc||' Insert into wms_api_hook_calls failed with  ' || sqlerrm(sqlcode), 4);
	      end if;

	      if (l_prog = 55) then
	         trace(l_proc||' Select from Sequence wms_api_hook_calls_s failed with ' || sqlerrm(sqlcode), 4);
	      end if;

              if (l_prog = 51) then
	         trace(l_proc||' Invalid package/procedure combination ', 4);
	      end if;

	   end if;
           x_retcode  := 2;
           x_errbuf   := 'Error';
           return;
end create_delete_api_call;

end wms_atf_reg_cust_apis;

/
