--------------------------------------------------------
--  DDL for Package Body AZ_PLSQL_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_PLSQL_XML" as
/* $Header: azxmlulb.pls 115.4 2003/03/08 00:05:04 jke noship $ */
--
--
-- Type Definitions
--
type tbl_parameter_name     is table of varchar2(30) index by binary_integer;
type tbl_parameter_datatype is table of number       index by binary_integer;
--
-- Error Exceptions which can be raised by dbms_describe.describe_procedure
--
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
-- Other Error Exceptions
--
Plsql_Value_Error  exception;
Pragma Exception_Init(Plsql_Value_Error, -6502);
--
XMLParserError     exception;
Pragma Exception_Init(XMLParserError, -20100);
--
-- Package Variables
--
g_package  varchar2(33) := '  az_plsql_xml.';
--
g_source         varchar2(32767);
g_error_expected boolean;
--
-- Oracle Internal DataType, Parameter, Default Codes and New Line Constants
--
c_dtype_undefined constant number      default   0;
c_dtype_varchar2  constant number      default   1;
c_dtype_number    constant number      default   2;
c_dtype_long      constant number      default   8;
c_dtype_date      constant number      default  12;
c_dtype_boolean   constant number      default 252;
--
c_ptype_in        constant number      default   0;
--
c_default_defined constant number      default   1;
--
c_new_line        constant varchar2(1) default '
';
--
-- Local Procedures and Functions
--
function parse
  (p_xml                           in     varchar2
  ) return xmldom.DOMDocument is
  l_retDoc xmldom.DOMDocument;
  l_parser xmlparser.parser;
begin
  l_parser := xmlparser.newParser;
  xmlparser.parseBuffer(l_parser,p_xml);
  l_retDoc := xmlparser.getDocument(l_parser);
  return l_retDoc;
exception
  when XMLParserError THEN
    xmlparser.freeParser(l_parser);
    return l_retDoc;
end parse;
--
function tonode(doc xmldom.DOMDocument) return xmldom.DOMNode is
begin
  return xmldom.makenode(doc);
end tonode;
--
function valueOf
  (p_node                            in     xmldom.DOMNode
  ,p_xpath                           in     varchar2
  ) return varchar2 is
begin
  if xmldom.isnull(p_node) or p_xpath is null then
    return null;
  else
    return xslprocessor.valueof(p_node, p_xpath);
  end if;
end valueOf;
--
function valueOf
  (p_doc                             in     xmldom.DOMDocument
  ,p_xpath                           in     varchar2
  ) return varchar2 is
begin
  if xmldom.isnull(p_doc) or p_xpath is null then
    return null;
  else
    return valueof(toNode(p_doc), p_xpath);
  end if;
end valueOf;
--
function selectNodes
  (p_node                            in     xmldom.DOMNode
  ,p_xpath                           in     varchar2
  ) return xmldom.DOMNodeList is
begin
  return xslprocessor.selectNodes(p_node, p_xpath);
end selectNodes;
--
function selectNodes
  (p_doc                             in     xmldom.DOMDocument
  ,p_xpath                           in     varchar2
  ) return xmldom.DOMNodeList is
begin
  return selectNodes(toNode(p_doc), p_xpath);
end selectNodes;
--
procedure execute_source
  (p_source                in      varchar2
  ) is
  l_dynamic_cursor         integer;          -- Dynamic sql cursor
  l_execute                integer;          -- Value returned by
                                             -- dbms_sql.execute
  l_proc                   varchar2(72) := g_package||'execute_source';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- The whole of the new package body code has now been built,
  -- use dynamic SQL to execute the create or replace package statement
  --
  hr_utility.set_location(l_proc, 11);
  l_dynamic_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_dynamic_cursor, p_source, dbms_sql.v7);
  l_execute := dbms_sql.execute(l_dynamic_cursor);
  dbms_sql.close_cursor(l_dynamic_cursor);
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  --
  -- In case of an unexpected error close the dynamic cursor
  -- if it was successfully opened.
  --
  when others then
    if (dbms_sql.is_open(l_dynamic_cursor)) then
      dbms_sql.close_cursor(l_dynamic_cursor);
    end if;
    raise;
end execute_source;
--
-- Public Procedures and Functions
--
procedure call_plsql_api
  (p_xml                           in     varchar2
  ) as
  -- Note this procedure makes many assumptions including.
  -- *) The API to call has at least one parameter reference.
  -- *) API call is a package procedure, no procedure onlys
  --    or functions inside or outside of a package.
  --
  -- Local variables to catch the values returned from
  -- hr_general.describe_procedure
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
  -- Other local variables
  --
  l_xmldoc              xmldom.DOMDocument;
  l_api_name            varchar2(32);
  l_api_pkg             varchar2(32);
  l_param_value         varchar2(200);     -- Value of parameter as listed
                                           -- in xml document.
  l_param_link          varchar2(200);     -- Value of parameter link argument
                                           -- in the xml document. A null
                                           -- indicates the argument has not
                                           -- been defined for this parameter.
  l_var_name            varchar2(30);      -- Holds the variable name used with
                                           -- OUT and IN OUT parameters.
  l_not_first_param     boolean := false;  -- A true value indicates the
                                           -- first parameter has already
                                           -- been added to the code. So
                                           -- for the remaining parameters
                                           -- , need to be included.
  l_loop                binary_integer;    -- Loop counter.
  l_pre_overload        number;            -- Overload number for the previous
                                           -- parameter.
  l_describe_error      boolean := false;  -- Indicates if the hr_general.
                                           -- describe_procedure raised an
                                           -- error for the call package
                                           -- procedure.
  l_call_code           varchar2(32767) := null;
  l_declare_code        varchar2(32767) := null;
  l_api_call_list       xmldom.DOMNodeList; -- List of nodes pointing to each
                                            -- API call in the API Call Set.
  l_print_length        number(15);         -- Length position for printing out
                                            -- source code for execution.
  l_proc                varchar2(72) := g_package||'call_plsql_api';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --hr_utility.set_location(p_xml,11);
  --
  -- Parse the XML Document
  --
  l_xmldoc := parse(p_xml);
  if not xmldom.isnull(l_xmldoc) then
     hr_utility.set_location(l_proc, 12);
     --
     -- Once only set-up for start of PL/SQL block
     --
     l_declare_code := 'declare ' || c_new_line || 'l_proc varchar2(30);'  || c_new_line;
     l_call_code    := 'begin ' || c_new_line;
     hr_utility.set_location(l_proc, 13);
     --
     -- Loop for each APICall in the APICallSet
     --
     l_api_call_list := selectNodes(l_xmldoc, '/APICallSet/APICall');
     for l_num in 1..xmldom.getlength(l_api_call_list) loop
       --
       -- Obtain the Name of the API to call from the XML Document
       --
       l_api_name := valueOf(xmldom.item(l_api_call_list, l_num - 1), 'APIName');
       l_api_pkg  := valueOf(xmldom.item(l_api_call_list, l_num - 1), 'APIPkg');
       --
       -- Above lines before processing sets were:
       --   l_api_name := valueof(l_xmldoc, '/APICallSet/APICall/APIName');
       --   l_api_pkg  := valueof(l_xmldoc, '/APICallSet/APICall/APIPkg');
       --
       hr_utility.trace('Now processing ' || l_api_pkg || '.' || l_api_name);
       hr_utility.set_location(l_proc, 15);
       --
       -- Obtain the API parameter list by calling an RDBMS procedure
       -- to obtain the list of parameters to the call package procedure.
       -- A separate begin ... end block has been specified so that errors
       -- raised by hr_general.describe_procedure can be trapped and
       -- handled locally.
       --
       begin
         hr_general.describe_procedure
           (object_name   => l_api_pkg || '.' || l_api_name
           ,reserved1     => null
           ,reserved2     => null
           ,overload      => l_overload
           ,position      => l_position
           ,level         => l_level
           ,argument_name => l_argument_name
           ,datatype      => l_datatype
           ,default_value => l_default_value
           ,in_out        => l_in_out
           ,length        => l_length
           ,precision     => l_precision
           ,scale         => l_scale
           ,radix         => l_radix
           ,spare         => l_spare
           );
       exception
         when Package_Not_Exists then
           -- Error: The call_package does not exist in the database. Code to
           -- carry out this hook call has not been created.
           hr_utility.set_message(800, 'HR_51950_AHC_CALL_PKG_NO_EXIST');
           l_describe_error := true;
           hr_utility.set_location(l_proc, 20);
         when Proc_Not_In_Package then
           -- Error: The call_procedure does not exist in the call_package.
           -- Code to carry out this hook call has not been created.
           hr_utility.set_message(800, 'HR_51951_AHC_CALL_PRO_NO_EXIST');
           l_describe_error := true;
           hr_utility.set_location(l_proc, 30);
         when Remote_Object then
           -- Error: Remote objects cannot be called from API User Hooks.
           -- Code to carry out this hook call has not been created.
           hr_utility.set_message(800, 'HR_51952_AHC_CALL_REMOTE_OBJ');
           l_describe_error := true;
           hr_utility.set_location(l_proc, 40);
         when Invalid_Package then
           -- Error: The call_package code in the database is invalid.
           -- Code to carry out this hook call has not been created.
           hr_utility.set_message(800, 'HR_51953_AHC_CALL_PKG_INVALID');
           l_describe_error := true;
           hr_utility.set_location(l_proc, 50);
         when Invalid_Object_Name then
           -- Error: An error has occurred while attempting to parse the name of
           -- the call package and call procedure. Check the package and procedure
           -- names. Code to carry out this hook call has not been created.
           hr_utility.set_message(800, 'HR_51954_AHC_CALL_PARSE');
           l_describe_error := true;
           hr_utility.set_location(l_proc, 60);
       end;
       hr_utility.set_location(l_proc, 70);
       if not l_describe_error then
         --
         -- Loop through the API parameter list.
         -- For IN and IN OUT parameters checking to see if the
         -- parameter is mentioned in the XML document. If it then
         -- use the value as an IN parameter.
         -- FOR OUT and IN OUT parameters add a local variable to
         -- catch the returned value.
         --
         l_call_code := l_call_code || l_api_pkg || '.' || l_api_name || '(' || c_new_line;
         hr_utility.set_location(l_proc, 90);
         l_not_first_param := false;
         --
         -- Search through the tables returned to create the parameter list
         --
         l_loop         := 1;
         l_pre_overload := l_overload(1);
         begin
          --
          -- There is separate PL/SQL block for reading from the PL/SQL tables.
          -- We do not know how many parameters exist. So we have to keep reading
          -- from the tables until PL/SQL finds a row when has not been
          -- initialised and raises a NO_DATA_FOUND exception or an invalid
          -- parameter is found.
          -- Assumption: If an API has more than one overloaded version then
          -- the only the first one returned by the DBMS_DESCRIBLE package will
          -- be used. Ideally should do the same as DataPump. When more than
          -- one exists then identify the latest version, by the greater number
          -- of parameters.
          --
          while l_pre_overload = l_overload(l_loop) loop
            --
            -- Find if parameter is has value in the XML document
            --
            l_param_value :=
              valueOf(xmldom.item(l_api_call_list, l_num - 1), l_argument_name(l_loop));
            l_param_link :=
              valueOf(xmldom.item(l_api_call_list, l_num - 1), l_argument_name(l_loop)||'/@LINK');
            --
            -- Processing before sets the above line was:
            -- l_param_value := valueof(l_xmldoc, '/APICall/' || l_argument_name(l_loop));
            --
            -- hr_utility.trace(l_argument_name(l_loop) ||' l_param_value is ' || l_param_value || ' l_param_link is ' || l_param_link);
            -- Process depending on IN, OUT, IN OUT status
            if l_in_out(l_loop) = 0 then
              -- hr_utility.set_location(l_proc, 100);
              -- Parameter is IN
              -- Only add to procedure list if the parameter has
              -- been given a value in the XML document or a link
              -- value has been defined.
              if l_param_value is not null or
                 l_param_link  is not null then
                if l_not_first_param then
                  -- Have already processed the first parameter. Separate this
                  -- parameter from the previous parameter with a ,
                  l_call_code := l_call_code || ',';
                else
                  l_not_first_param := true;
                end if;
                -- Add parameter to list of parameters in call
                l_call_code := l_call_code || l_argument_name(l_loop) || ' => ';
                -- Decide what the parameter value should be set to
                -- depending on whether a link argument has been defined
                if l_param_link is null then
                  -- No link defined. Use data value from XML document
                  if l_datatype(l_loop) = c_dtype_varchar2 then
                    l_call_code := l_call_code || '''' || l_param_value || '''' || c_new_line;
                  else
                    l_call_code := l_call_code || l_param_value || c_new_line;
                  end if;
                else -- Link has been defined
                  -- N.B. This assumes that link has already been
                  -- defined in the local variable list from a previous
                  -- API IN OUT or OUT parameter. This assumption is not
                  -- validated.
                  l_call_code := l_call_code || 'l_' || l_param_link || c_new_line;
                end if;
              end if;
            elsif l_in_out(l_loop) = 1 then
              -- hr_utility.set_location(l_proc, 110);
              -- Parameter is OUT
              -- Add local variable to the declare section with the
              -- same datatype. Add to the procedure list so local
              -- variable catches any return result.
              -- For now just ignore any value in the XML document.
              if l_not_first_param then
                -- Have already processed the first parameter. Separate this
                -- parameter from the previous parameter with a ,
                l_call_code := l_call_code || ',';
              else
                l_not_first_param := true;
              end if;
              --
              -- Name of local variable depends on whether a link has been defined
              -- in the XML document for this parameter.
              if l_param_link is not null then
                l_var_name := 'l_' || l_param_link;
              else
                -- Derive from parameter name change p_ for l_
                l_var_name := 'l' || substr(l_argument_name(l_loop), 2);
              end if;
              -- Only add local variable to delcare section if does not
              -- already exist. This check is required for allow for re-use
              -- of Link names. At the moment their is an assumption that
              -- each instance of the local variable will have the same datatype
              -- length.
              --
              if instr(l_declare_code, l_var_name) = 0 then
                -- hr_utility.set_location(l_proc, 120);
                -- Add local variable name
                l_declare_code := l_declare_code || l_var_name;
                -- Add datatype
                if l_datatype(l_loop) = c_dtype_varchar2 then
                   l_declare_code := l_declare_code || ' varchar2(200);' || c_new_line;
                elsif l_datatype(l_loop) = c_dtype_number then
                   l_declare_code := l_declare_code || ' number(15);' || c_new_line;
                elsif l_datatype(l_loop) = c_dtype_long   then
                   l_declare_code := l_declare_code || ' long;' || c_new_line;
                elsif l_datatype(l_loop) = c_dtype_date   then
                   l_declare_code := l_declare_code || ' date;' || c_new_line;
                elsif l_datatype(l_loop) = c_dtype_boolean  then
                   l_declare_code := l_declare_code || ' boolean;' || c_new_line;
                elsif l_datatype(l_loop) = c_dtype_undefined then
                   -- Unexpected need to raise error;
                   null;
                end if;
              end if;
              -- hr_utility.set_location(l_proc, 130);
              l_call_code := l_call_code || l_argument_name(l_loop) || ' => ';
              l_call_code := l_call_code || l_var_name || c_new_line;
            elsif l_in_out(l_loop) = 2 then
              -- hr_utility.set_location(l_proc, 140);
              -- Parameter is IN OUT
              -- Add local variable to the declare section. If a value
              -- as been given in the XML document then default the
              -- local variable to that value. Also add to the
              -- procedure list so local variable catches any return
              -- result.
              if l_not_first_param then
                -- Have already processed the first parameter. Separate this
                -- parameter from the previous parameter with a ,
                l_call_code := l_call_code || ',';
              else
                l_not_first_param := true;
              end if;
              --
              -- Name of local variable depends on whether a link has been defined
              -- in the XML document for this parameter.
              if l_param_link is not null then
                l_var_name := 'l_' || l_param_link;
              else
                -- Derive from parameter name change p_ for l_
                l_var_name := 'l' || substr(l_argument_name(l_loop), 2);
              end if;
              -- Only add local variable to delcare section if does not
              -- already exist. This check is required for allow for re-use
              -- of Link names. At the moment their is an assumption that
              -- each instance of the local variable will have the same datatype
              -- length.
              --
              if instr(l_declare_code, l_var_name) = 0 then
                -- hr_utility.set_location(l_proc, 150);
                -- Add local variable name
                l_declare_code := l_declare_code || l_var_name;
                -- Add datatype with or without defaulted value
                -- Assumption: When a local variable is being used with
                -- an IN OUT parameter, there is only one default in parameter.
                -- At the moment if an there is a second API call with an IN OUT
                -- parameter of the same name then any further IN values provided
                -- in the XML document will be ignored. So second API call will
                -- actually get the OUT value from the first API call.
                --
                -- When an IN parameter value has been provided include default value
                -- in local variable declare. Otherwise don't mention default in declare.
                if l_param_value is not null then
                  -- hr_utility.set_location(l_proc, 160);
                  if l_datatype(l_loop) = c_dtype_varchar2 then
                     l_declare_code := l_declare_code || ' varchar2(200) := ' || ''''  || l_param_value || '''' ;
                     l_declare_code := l_declare_code || ';' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_number then
                     l_declare_code := l_declare_code || ' number(15) := ' || l_param_value;
                     l_declare_code := l_declare_code || ';' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_long   then
                     l_declare_code := l_declare_code || ' long := ' || l_param_value;
                     l_declare_code := l_declare_code || ';' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_date   then
                     l_declare_code := l_declare_code || ' date := ' || l_param_value;
                     l_declare_code := l_declare_code || ';' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_boolean  then
                     l_declare_code := l_declare_code || ' boolean := ' || l_param_value;
                     l_declare_code := l_declare_code || ';' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_undefined then
                     -- Unexpected need to raise error;
                     null;
                  end if;
                else
                  -- hr_utility.set_location(l_proc, 170);
                  if l_datatype(l_loop) = c_dtype_varchar2 then
                     l_declare_code := l_declare_code || ' varchar2(200);' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_number then
                     l_declare_code := l_declare_code || ' number(15);' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_long   then
                     l_declare_code := l_declare_code || ' long;' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_date   then
                     l_declare_code := l_declare_code || ' date;' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_boolean  then
                     l_declare_code := l_declare_code || ' boolean;' || c_new_line;
                  elsif l_datatype(l_loop) = c_dtype_undefined then
                     -- Unexpected need to raise error;
                     null;
                  end if;
                end if;
              end if; -- instr(l_declare_code ...
              l_call_code := l_call_code || l_argument_name(l_loop) || ' => ';
              l_call_code := l_call_code || l_var_name || c_new_line;
            else
              -- Unexpected need to raise error.
              null;
            end if;
            l_pre_overload := l_overload(l_loop);
            l_loop := l_loop + 1;
            -- hr_utility.set_location(l_proc, 180);
          end loop; -- end of while loop

          -- Following IF statement may be executed when there is
          -- more than one overload for the same API
          if l_loop > 1 then
            -- There must have been at least one parameter in the list. End the
            -- parameter list with a closing bracket. The bracket should not be
            -- included when there are zero parameters.
            l_call_code := l_call_code || ');' || c_new_line;
          end if;
        exception
          when no_data_found then
            -- Trap the PL/SQL no_data_found exception. Know we have already
            -- read the details of the last parameter from the tables.
            if l_loop > 1 then
              -- There must have been at least one parameter in the list. End the
              -- parameter list with a closing bracket. The bracket should not be
              -- included when there are zero parameters.
              l_call_code := l_call_code || ');' || c_new_line;
            end if;
            -- hr_utility.set_location(l_proc, 190);
        end;
       end if;  -- if not l_describe_error
       hr_utility.set_location(l_proc, 200);
     end loop;
     --
     -- Once only end PL/SQL block
     --
     l_call_code := l_call_code || 'end;' || c_new_line;
     hr_utility.set_location(l_proc, 210);
     --
     for l_print IN 0..length(l_declare_code) loop
       if mod(l_print, 200) = 0 then
         hr_utility.trace(substr(l_declare_code, l_print, 200));
       end if;
     end loop;
     for l_print IN 0..length(l_call_code) loop
       if mod(l_print, 200) = 0 then
         hr_utility.trace(substr(l_call_code, l_print, 200));
       end if;
     end loop;
--     l_print_length := 1;
--     while l_print_length < length(l_declare_code) loop
--       hr_utility.trace(substr(l_declare_code, l_print_length, l_print_length + 200));
--       l_print_length := l_print_length + 200;
--     end loop;
--     l_print_length := 1;
--     while l_print_length < length(l_call_code) loop
--       hr_utility.trace(substr(l_call_code, l_print_length, l_print_length + 200));
--       l_print_length := l_print_length + 200;
--     end loop;
     --
     -- Use dynamic SQL to perform the actual API call
     --

     execute_source(l_declare_code || l_call_code);
  end if;  -- not xmldom.isnull
  hr_utility.set_location(' Leaving:'||l_proc, 220);
end call_plsql_api;

end az_plsql_xml;

/
