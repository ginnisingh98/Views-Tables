--------------------------------------------------------
--  DDL for Package Body ECX_PRINT_LOCAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_PRINT_LOCAL" as
-- $Header: ECXLXMLB.pls 120.4.12010000.2 2008/08/22 20:00:06 cpeixoto ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;


-- fix for bug 6900831: max number of loops before we consider infinite loop
l_loop_max           PLS_INTEGER := 5;

-- Pointer to keep track of last printed node, used for supressing empty node.
last_node_printed	PLS_INTEGER := 0;
-- Boolean value to hold profile value ECX_SUPPRESS_EMPTY_TAGS
suppress_profile	Boolean := false;

/**
As per XML 1.0 Spec.
**/
i_amp 	varchar2(1) := '&';
i_lt 	varchar2(1) := '<';
i_gt 	varchar2(1) := '>';
i_apos 	varchar2(1) := '''';
i_quot 	varchar2(1) := '"';
i_xmldoc CLOB;
i_var_pos pls_integer;
/** Change required for Clob Support -- 2263729 ***/
g_split_threshold pls_integer := 4000;

function  has_fragment(var_pos IN pls_integer) return boolean;
function has_fragment_value (var_pos IN pls_integer) return boolean;
procedure print_xml_fragment (var_pos IN pls_integer,
                              print_tag IN boolean);
procedure append_clob is

   i_method_name   varchar2(2000) := 'ecx_print_local.append_clob';
   i_writeamount           number;
   i_length                number;
   i_temp                  varchar2(32767);

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   i_writeamount :=0;
   i_length :=0;
   i_temp:='';

   if i_xmldoc is null then
      dbms_lob.createtemporary(i_xmldoc,TRUE,DBMS_LOB.SESSION);
   end if;

   for i in 1..i_tmpxml.COUNT loop
      -- check for the element length
      i_writeamount := length(i_tmpxml(i));
      -- set append status to true
      -- check if temp buffer is full
      if(i_writeamount+i_length > 10000) then
         if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Buffer Length', to_char(i_length),i_method_name);
	 end if;
         dbms_lob.writeappend(i_xmldoc,i_length, i_temp);
         if(l_statementEnabled) then
           ecx_debug.log(l_statement, i_temp,i_method_name);
	 end if;
         i_temp:='';
         i_length:=i_writeamount;
         i_temp:=i_tmpxml(i);
      else
         i_length:=i_length+i_writeamount;
         -- add new entry
         i_temp:=concat(i_temp, i_tmpxml(i));
      end if;
   end loop;

   if(i_tmpxml.COUNT > 0)
   then
     dbms_lob.writeappend(i_xmldoc,i_length, i_temp);
     if(l_statementEnabled) then
        ecx_debug.log(l_statement, i_temp,i_method_name);
     end if;
  end if;
   i_tmpxml.DELETE;

 if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
exception
   when value_error then
	ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;

   when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;

   when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_PRINT_LOCAL.APPEND_CLOB');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected, 'ECX', SQLERRM || '- ECX_PRINT_LOCAL.APPEND_CLOB',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end append_clob;


procedure element_value
	(
        clob_value          IN      clob,
	value		    IN	varchar2
	)
is

i_method_name   varchar2(2000) := 'ecx_print_local.element_value';

begin

       If clob_value is not null Then
               get_chunks(clob_value);
       elsif value is not null Then
               get_chunks(value);
       End if;

exception
when value_error then
	ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_PRINT_LOCAL.ELEMENT_VALUE');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM || '- ECX_PRINT_LOCAL.ELEMENT_VALUE',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end element_value;



procedure cdata_element_value
        (
        clob_value      IN      clob,
        value           IN      varchar2
        )
is

i_method_name   varchar2(2000) := 'ecx_print_local.cdata_element_value';

begin

if (clob_value is not null) or
   (value is not null ) Then
       i_tmpxml(i_tmpxml.COUNT +1) := i_cdatastarttag;
       If clob_value is not null Then
               get_chunks(clob_value,true);
       elsif value is not null Then
               get_chunks(value,true);
       End if;
       -- close CDATA tag
	i_tmpxml(i_tmpxml.COUNT + 1) := i_cdataendtag;
End if;

exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
        ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_PRINT_LOCAL.CDATA_ELEMENT_VALUE');
        if(l_unexpectedEnabled) then
               ecx_debug.log(l_unexpected, 'ECX', SQLERRM || '- ECX_PRINT_LOCAL.CDATA_ELEMENT_VALUE',
	                    i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
end cdata_element_value;

procedure print_node_stack
is

i_method_name   varchar2(2000) := 'ecx_print_local.print_node_stack';

begin

if (l_node_stack.COUNT > 0)
then
   if (l_node_stack.count <> 0)
   then
      for i in l_node_stack.first..l_node_stack.last
      loop
	 if(l_statementEnabled) then
            ecx_debug.log(l_statement,'Counter'||i,l_node_stack(i),i_method_name);
	 end if;
      end loop;
   end if;
end if;
end print_node_stack;


/*
  This procedure will pop elements from l_node_stack until the element that was
  last on the stack before print_discont_elements was called (represented by
  i_last_stack_id) is restored.
*/

procedure pop_discont_elements
        (
        i_last_stack_id         IN      pls_integer
        )
is

i_method_name   varchar2(2000) := 'ecx_print_local.pop_discont_elements';


begin

if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'i_last_stack_id', i_last_stack_id,i_method_name);
  ecx_debug.log(l_statement, 'l_node_stack.LAST', l_node_stack(l_node_stack.LAST),i_method_name);
end if;

if (i_last_stack_id <> l_node_stack(l_node_stack.LAST))
then
loop
exit when (l_node_stack(l_node_stack.LAST) <= i_last_stack_id);

	if(last_node_printed = l_node_stack.LAST)
	then
		/** Change required for Clob Support -- 2263729 ***/
		if ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).is_clob is not null Then
        		cdata_element_node_close
	                (
		        ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name,
			ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).value,
	                ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).clob_value
		        );
		else
			element_node_close
        		(
	        	ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name
			);
		end if;

		if(l_statementEnabled) then
		         ecx_debug.log(l_statement,'</'|| ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name||'>',i_method_name);
		end if;
	end if;
        xmlPOP;
end loop;
end if;

if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;

exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' -  ECX_PRINT_LOCAL.POP_DISCONT_ELEMENTS');
	if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' -  ECX_PRINT_LOCAL.POP_DISCONT_ELEMENTS',i_method_name);
	end if;
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ECX_UTILS.PROGRAM_EXIT;
end pop_discont_elements;


/*
  This procedure prints the discontinuous elements for an element (if any).
  It will go through g_target starting from i_start_pos till i_end_pos looking
  for elements that are children of this element and that belong to the same level
  as this element. When it encounters first such discontinuous element, it will note
  the attribute id and then invoke print_new_level with this atribute_id and the level#.
  This call to print_new_level will print all the elements starting from the supplied
  attribute id till it encounters elements that do not belong to the level
*/

procedure print_discont_elements
        (
        i_start_pos             IN      pls_integer,
        i_end_pos               IN      pls_integer,
        i_parent_attr_id        IN      pls_integer,
        i_ext_level             IN      pls_integer
        )
is

i_method_name   varchar2(2000) := 'ecx_print_local.print_discont_elements';

curr_parent_id  pls_integer;
curr_id         pls_integer;
curr_level      pls_integer;
print_id        pls_integer;
k               pls_integer;
elements_found  boolean := false;
descendant_found boolean := false;

begin
if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'i_start_pos', i_start_pos,i_method_name);
  ecx_debug.log(l_statement, 'i_end_pos', i_end_pos,i_method_name);
  ecx_debug.log(l_statement, 'i_parent_attr_id', i_parent_attr_id,i_method_name);
  ecx_debug.log(l_statement, 'i_ext_level', i_ext_level,i_method_name);
end if;

for k in i_start_pos..i_end_pos
loop
        -- get element details
        curr_parent_id := ecx_utils.g_target(k).parent_attribute_id;
        curr_id := ecx_utils.g_target(k).attribute_id;
        curr_level := ecx_utils.g_target(k).external_level;

        descendant_found := is_descendant(i_parent_attr_id, curr_id);
        if (descendant_found AND curr_level = i_ext_level)
        then
                -- elements belong to this parent so need to be printed
                if (not elements_found)
                then
                        print_id := curr_id;
                        if(l_statementEnabled) then
                          ecx_debug.log(l_statement, 'print_id', print_id,i_method_name);
			end if;
                        elements_found := true;
                end if;
        end if;

        if( (not descendant_found) OR (curr_level <> i_ext_level) OR (k = i_end_pos))
        then
                -- elements belong to a new level under ext_level.
                -- Print any discontinuous_elements that were found. These elements
                -- probably were not printed as their data never arrived
                if (elements_found)
                then
                        print_new_level(i_ext_level, print_id);
                        elements_found := false;
                end if;
        end if;
        exit when not descendant_found;
end loop;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM ||' - ECX_PRINT_LOCAL.PRINT_DISCONT_ELEMENTS');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX', SQLERRM ||' - ECX_PRINT_LOCAL.PRINT_DISCONT_ELEMENTS',i_method_name);
	end if;
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ECX_UTILS.PROGRAM_EXIT;
end print_discont_elements;


/*
  evaluates if i_element_id is a descendant of i_parent_id
*/
function is_descendant (
	i_parent_id	IN	pls_integer,
	i_element_id	IN	pls_integer
	) return 		boolean
is

        i_method_name   varchar2(2000) := 'ecx_print_local.is_descendant';
	curr_pid	pls_integer;
begin
        if (l_procedureEnabled) then
          ecx_debug.push(i_method_name);
        end if;

	curr_pid := ecx_utils.g_target(i_element_id).parent_attribute_id;
	loop
		if (curr_pid = i_parent_id)
		then
			if(l_statementEnabled) then
                          ecx_debug.log(l_statement,'Returning true',i_method_name);
			end if;
		        if (l_procedureEnabled) then
                         ecx_debug.pop(i_method_name);
                        end if;
			return (true);
		elsif (curr_pid < i_parent_id)
		then
			if(l_statementEnabled) then
                          ecx_debug.log(l_statement,'Returning false',i_method_name);
			end if;
		        if (l_procedureEnabled) then
                         ecx_debug.pop(i_method_name);
                        end if;
			return (false);
		else
			curr_pid := ecx_utils.g_target(curr_pid).parent_attribute_id;
		end if;
	exit when curr_pid = 0;
	end loop;

        -- for the special case where 0 is the ancestor
        if (curr_pid = 0 AND curr_pid = i_parent_id)
        then
        	if(l_statementEnabled) then
                	ecx_debug.log(l_statement,'Returning true: 0 is the ancestor',i_method_name);
                end if;
                if (l_procedureEnabled) then
                	ecx_debug.pop(i_method_name);
                end if;
                return (true);
	end if;

	if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Returning false',i_method_name);
	end if;
        return (false);
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
        ecx_debug.setErrorInfo(2, 30, SQLERRM ||' - ECX_PRINT_LOCAL.IS_DESCENDANT');
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM ||' - ECX_PRINT_LOCAL.IS_DESCENDANT',i_method_name);
	end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
        raise ECX_UTILS.PROGRAM_EXIT;
end is_descendant;


procedure xmlPOPALL(
   x_xmldoc OUT NOCOPY  clob)
is

i_method_name   varchar2(2000) := 'ecx_print_local.xmlPOPALL';

last_stack_id   pls_integer;

begin
	if(l_statementEnabled) then
		print_node_stack;
	end if;

	while (l_node_stack.COUNT > 0)
	loop
                /*
                  before closing the current element print its discontinuous elements, if any
                  Since we don't have current_position, we need to find the end position
                  of the the level to which this element belongs and look for discont elements
                  from last_printed to the element level's file_end_pos
                */
                last_stack_id := l_node_stack(l_node_stack.LAST);

                print_discont_elements (last_printed + 1,
                                        ecx_utils.g_target_levels(ecx_utils.g_target
                                        (l_node_stack(l_node_stack.LAST)).external_level).file_end_pos,
                                        l_node_stack(l_node_stack.LAST),
                                        ecx_utils.g_target(l_node_stack
                                        (l_node_stack.LAST)).external_level);
		/*
                  if at all any discontinuous elements were printed we need to once again
                  ensure if the last element on the stack is the one which we were trying to close
                  so keep popping the discont elements till you reach this element
		*/
                pop_discont_elements(last_stack_id);

		-- close this element only if it was opened
		if(last_node_printed = l_node_stack.LAST)
		then
       	        	/** Change required for Clob Support -- 2263729 ***/
			if  ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).is_clob is not null  Then
				cdata_element_node_close
				(
				 ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name,
				 ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).value,
				 ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).clob_value
				);
			else
				element_node_close
				(
				ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name
				);
			end if;
			if(l_statementEnabled) then
        			ecx_debug.log(l_statement,'</'||ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name||'>', i_method_name);
		        end if;
		end if;
	xmlPOP;
	end loop;
        append_clob;
        ecx_utils.g_xml_frag.delete;
        x_xmldoc := i_xmldoc;

        if dbms_lob.istemporary(i_xmldoc) = 1 then
           dbms_lob.freetemporary(i_xmldoc);
           i_xmldoc := null;
        end if;

exception
   when ecx_utils.program_exit then
        if dbms_lob.istemporary(i_xmldoc) = 1 then
           dbms_lob.freetemporary(i_xmldoc);
           i_xmldoc := null;
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;

   when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_PRINT_LOCAL.xmlPOPALL');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM || '- ECX_PRINT_LOCAL.xmlPOPALL',i_method_name);
	end if;
        if dbms_lob.istemporary(i_xmldoc) = 1 then
           dbms_lob.freetemporary(i_xmldoc);
           i_xmldoc := null;
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end xmlPOPALL;

procedure xmlPUSH
	(
	i	pls_integer
	)
	is

begin
	l_node_stack(l_node_stack.COUNT) := i;
end xmlPUSH;

procedure xmlPOP
is
begin
	if l_node_stack.COUNT > 0
	then
		-- if last_node_printed is pointing to the last node we need to reset it
		if(last_node_printed = l_node_stack.LAST)
		then
			last_node_printed := l_node_stack.LAST - 1;
		end if;
		l_node_stack.delete(l_node_stack.LAST);
	end if;
end xmlPOP;

procedure element_open
	(
	tag_name        IN      varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.element_open';
begin
	i_tmpxml(i_tmpxml.COUNT+1) := i_elestarttag||tag_name||' ';
exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_PRINT_LOCAL.ELEMENT_OPEN');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX', SQLERRM || '- ECX_PRINT_LOCAL.ELEMENT_OPEN',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end;

procedure element_close
is

i_method_name   varchar2(2000) := 'ecx_print_local.element_close';
begin
	i_tmpxml(i_tmpxml.COUNT+1) := i_eleendtag;
exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, ecx_utils.i_errbuf, i_method_name);
	 end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_CLOSE');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_CLOSE',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end element_close;

procedure element_node_open
	(
	tag_name	IN	varchar2,
	value		IN	varchar2,
        clob_value	IN	clob
	)
is

i_method_name   varchar2(2000) := 'ecx_print_local.element_node_open';

begin
     if (clob_value is not null) or
           (value is not null ) Then
        	i_tmpxml(i_tmpxml.COUNT +1) := i_elestarttag||tag_name||i_eleendtag;
              	If clob_value is not null Then
                	get_chunks(clob_value);
              	elsif value is not null Then
                	get_chunks(value);
              	End if;
        else
		i_tmpxml(i_tmpxml.COUNT+1) := i_elestarttag||tag_name||i_eleendtag;
	End if;

exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_NODE_OPEN');
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_NODE_OPEN',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end element_node_open;


procedure element_node_close
	(
	tag_name	IN	varchar2
	)
	is
i_method_name   varchar2(2000) := 'ecx_print_local.element_node_close';

begin
	i_tmpxml(i_tmpxml.COUNT+1) := i_eleclosetag||tag_name||i_eleendtag;
exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_NODE_CLOSE');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_NODE_CLOSE',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end element_node_close;

/**  Change required for Clob Support -- 2263729 ***/
procedure cdata_element_node_open
	(
	tag_name	IN	varchar2,
        value           IN      varchar2,
	clob_value	IN	clob
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.cdata_element_node_open';

i      pls_integer:=1;
begin
        if (clob_value is not null) or
           (value is not null ) Then
        	i_tmpxml(i_tmpxml.COUNT +1) := i_elestarttag||tag_name||i_eleendtag||i_cdatastarttag;
              	If clob_value is not null Then
                	get_chunks(clob_value,true);
              	elsif value is not null Then
                	get_chunks(value,true);
              	End if;
          -- close CDATA tag
	   i_tmpxml(i_tmpxml.COUNT + 1) := i_cdataendtag;
        else
		i_tmpxml(i_tmpxml.COUNT+1) := i_elestarttag||tag_name||i_eleendtag;
	End if;
exception
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.CDATA_ELEMENT_NODE_OPEN');
	if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.CDATA_ELEMENT_NODE_OPEN',
	              i_method_name);
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end;

/** Change required for Clob Support -- 2263729 ***/
procedure cdata_element_node_close
	(
	tag_name	IN	varchar2,
        value           IN      varchar2,
	clob_value	IN	clob
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.cdata_element_node_close';

begin
	i_tmpxml(i_tmpxml.COUNT+1) := i_eleclosetag||tag_name||i_eleendtag;

exception
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.CDATA_ELEMENT_NODE_CLOSE');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.CDATA_ELEMENT_NODE_CLOSE',
	                 i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end;


procedure element_node
	(
	tag_name	IN	varchar2,
	value		IN	varchar2
	)
	is

i_method_name   varchar2(2000) := 'ecx_print_local.element_node';
i_temp		varchar2(32767);

begin
i_temp	:= value;
i_tmpxml(i_tmpxml.COUNT+1) := i_elestarttag||tag_name||i_eleendtag;
if value is not null
then
	/*
	Changed as per XML 1.0 spec.
	*/
        escape_spec_char(value, i_temp);

        if (length(i_tmpxml(i_tmpxml.COUNT)) + length(i_temp) > ecx_utils.G_VARCHAR_LEN)
        then
           i_tmpxml(i_tmpxml.COUNT + 1) := i_temp;
        else
           i_tmpxml(i_tmpxml.COUNT) := i_tmpxml(i_tmpxml.COUNT) || i_temp;
        end if;
end if;
	i_tmpxml(i_tmpxml.COUNT+1) := i_eleclosetag||tag_name||i_eleendtag;
exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_NODE');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.ELEMENT_NODE',
	                i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end element_node;

procedure attribute_node
	(
	attribute_name	IN	varchar2,
	attribute_value	IN	varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.attribute_node';
i_temp	varchar2(32767);
begin
	i_temp	:= attribute_value;
	/**
	Changed as per XML 1.0 spec.
	**/
	if i_temp is null
	then
		return;
	end if;
        escape_spec_char(attribute_value, i_temp);

 	i_tmpxml(i_tmpxml.COUNT + 1) := ' ' || attribute_name || ' = "';

        if(length(i_tmpxml(i_tmpxml.COUNT)) + length(i_temp) < ecx_utils.G_VARCHAR_LEN)
        then
           i_tmpxml(i_tmpxml.COUNT) := i_tmpxml(i_tmpxml.COUNT) || i_temp || '"';
        else -- > or =
           i_tmpxml(i_tmpxml.COUNT + 1) := i_temp;
           i_tmpxml(i_tmpxml.COUNT + 1) := '"';
        end if;
exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.ATTRIBUTE_NODE');
	if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.ATTRIBUTE_NODE',i_method_name);
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end;

procedure attribute_node_close
	(
	attribute_name	IN	varchar2,
	attribute_value	IN	varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.attribute_node_close';
i_temp	varchar2(32767);

begin
	i_temp := attribute_value;
	/**
	Changed as per XML 1.0 spec.
	**/
if i_temp is not null
then
        escape_spec_char(attribute_value, i_temp);

        i_tmpxml(i_tmpxml.COUNT + 1) := ' ' || attribute_name || ' = "';

        if(length(i_tmpxml(i_tmpxml.COUNT)) + length(i_temp) < ecx_utils.G_VARCHAR_LEN)
        then
           i_tmpxml(i_tmpxml.COUNT) := i_tmpxml(i_tmpxml.COUNT) || i_temp || '">';
        elsif(length(i_temp) < ecx_utils.G_VARCHAR_LEN)
        then
           i_tmpxml(i_tmpxml.COUNT + 1) :=  i_temp || '">';
        else
           i_tmpxml(i_tmpxml.COUNT + 1) :=  i_temp;
	   i_tmpxml(i_tmpxml.COUNT + 1) := '">';
        end if;
else
	i_tmpxml(i_tmpxml.COUNT+1) := '>';
end if;
exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.ATTRIBUTE_NODE_CLOSE');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.ATTRIBUTE_NODE_CLOSE',
	                i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end;

procedure pi_node
	(
	pi			IN	varchar2,
	attribute_string	in	varchar2 :=NULL
	)
	is

i_method_name   varchar2(2000) := 'ecx_print_local.pi_node';
begin
	i_tmpxml(i_tmpxml.COUNT+1) := i_pistart||pi||' '||attribute_string||' '||i_piend;
exception
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.PI_NODE');
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.PI_NODE',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end pi_node;

procedure document_node
	(
	root_element	in	varchar2,
	filename	IN	varchar2,
	dtd_url		IN	varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.document_node';
begin
	if filename is not null
	then
		i_tmpxml(i_tmpxml.COUNT+1) := '<!DOCTYPE  '||root_element;

		if dtd_url is null
		then
			if filename is null
			then
				i_tmpxml(i_tmpxml.COUNT) := i_tmpxml(i_tmpxml.COUNT)|| ' >';
			else
				i_tmpxml(i_tmpxml.COUNT) := i_tmpxml(i_tmpxml.COUNT)||' SYSTEM ' ||i_quot||filename||i_quot||' >';
			end if;
		else
			i_tmpxml(i_tmpxml.COUNT) := i_tmpxml(i_tmpxml.COUNT)||' SYSTEM ' ||i_quot||dtd_url||filename||i_quot||' >';
		end if;
	end if;
exception
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.DOCUMENT_NODE');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.DOCUMENT_NODE',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end document_node;

procedure comment_node
	(
	value	IN	varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.comment_node';
begin
	i_tmpxml(i_tmpxml.COUNT+1) := i_commstart||' '||value||' '||i_commend;
exception
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.COMMENT_NODE');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.COMMENT_NODE',i_method_name);
	end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end comment_node;


-- This procedure prints any nodes waiting to be printed on l_node_stack
procedure print_waiting_nodes
is
i_method_name   varchar2(2000) := 'ecx_print_local.print_waiting_nodes';
i_last_node_printed  pls_integer;
begin
if(l_procedureEnabled) then
  ecx_debug.PUSH(i_method_name);
end if;

i_last_node_printed := last_node_printed + 1;

if(l_node_stack.COUNT > 0)
then
  for i in i_last_node_printed..l_node_stack.LAST
  loop
      if  ecx_utils.g_target(l_node_stack(i)).is_clob is not null
      Then
        cdata_element_node_open
        (
  	  ecx_utils.g_target(l_node_stack(i)).attribute_name,
	  ecx_utils.g_target(l_node_stack(i)).value,
          ecx_utils.g_target(l_node_stack(i)).clob_value
	);
      else
        i_var_pos := l_node_stack(i);
        if (has_fragment(i_var_pos)) then
         print_xml_fragment(i_var_pos,true);
        else
	element_node_open
	(
  	  ecx_utils.g_target(l_node_stack(i)).attribute_name,
	  ecx_utils.g_target(l_node_stack(i)).value,
          ecx_utils.g_target(l_node_stack(i)).clob_value
	);
        end if;
      end if;
  end loop;
end if;
last_node_printed := l_node_stack.LAST;

if(l_procedureEnabled) then
  ecx_debug.POP(i_method_name);
end if;

exception
when ecx_utils.program_exit
then
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
  raise ECX_UTILS.PROGRAM_EXIT;
when others then
  ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_WAITING_NODES');
  if(l_statementEnabled) then
    ecx_debug.log(l_statement, 'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_WAITING_NODES',
     i_method_name);
    ecx_debug.log(l_statement, 'resetting first_time',i_method_name);
  end if;
  ecx_print_local.first_time_printing := true;
  if (l_procedureEnabled)
  then
    ecx_debug.pop(i_method_name);
  end if;
  raise ECX_UTILS.PROGRAM_EXIT;
end print_waiting_nodes;

-- This procedure prints any nodes waiting to be printed on l_node_stack. This procedure is called by an attribute.
procedure print_waiting_nodes_attr
is
i_method_name   varchar2(2000) := 'ecx_print_local.print_waiting_nodes_attr';
i_last_node_printed  pls_integer;
begin
if(l_procedureEnabled) then
  ecx_debug.PUSH(i_method_name);
end if;

i_last_node_printed := last_node_printed + 1;

if(l_node_stack.COUNT > 0)
then
  for i in i_last_node_printed..l_node_stack.LAST
  loop
    if(i = l_node_stack.LAST)
    then
      element_open(ecx_utils.g_target(l_node_stack(i)).attribute_name);
    else
      if  ecx_utils.g_target(l_node_stack(i)).is_clob is not null
      Then
        cdata_element_node_open
        (
  	  ecx_utils.g_target(l_node_stack(i)).attribute_name,
	  ecx_utils.g_target(l_node_stack(i)).value,
          ecx_utils.g_target(l_node_stack(i)).clob_value
	);
      else
        i_var_pos := l_node_stack(i);
        if (has_fragment(i_var_pos)) then
         print_xml_fragment(i_var_pos,true);
        else
	element_node_open
	(
  	  ecx_utils.g_target(l_node_stack(i)).attribute_name,
	  ecx_utils.g_target(l_node_stack(i)).value,
          ecx_utils.g_target(l_node_stack(i)).clob_value
	);
        end if;
      end if;
    end if;
  end loop;
end if;
last_node_printed := l_node_stack.LAST;

if(l_procedureEnabled) then
  ecx_debug.POP(i_method_name);
end if;

exception
when ecx_utils.program_exit
then
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
  raise ECX_UTILS.PROGRAM_EXIT;
when others then
  ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_WAITING_NODES_ATTR');
  if(l_statementEnabled) then
    ecx_debug.log(l_statement, 'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_WAITING_NODES_ATTR',
     i_method_name);
    ecx_debug.log(l_statement, 'resetting first_time',i_method_name);
  end if;
  ecx_print_local.first_time_printing := true;
  if (l_procedureEnabled)
  then
    ecx_debug.pop(i_method_name);
  end if;
  raise ECX_UTILS.PROGRAM_EXIT;
end print_waiting_nodes_attr;

Function get_suppress_profile return boolean is

i_string   varchar2(2000);
l_suppress varchar2(1) := 'N';
i_method_name   varchar2(2000) := 'ecx_print_local.get_suppress_profile';
begin
if (l_procedureEnabled) then
	ecx_debug.push(i_method_name);
end if;
if (ecx_utils.g_install_mode is null) then
  ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
end if;

if ecx_utils.g_install_mode = 'EMBEDDED'
then
  i_string := 'begin fnd_profile.get('||'''ECX_SUPPRESS_EMPTY_TAGS'''||',
    :l_suppress);end;';
  execute immediate i_string USING OUT l_suppress;
else
  l_suppress := wf_core.translate('ECX_SUPPRESS_EMPTY_TAGS');
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'ECX_SUPPRESS_EMPTY_TAGS',l_suppress,i_method_name);
end if;
/* if profile option is not set assume empty tags should not be suppressed */
if (l_suppress is null) then
  return false;
end if;

if(l_procedureEnabled) then
  ecx_debug.POP(i_method_name);
end if;

return (l_suppress = 'Y') OR (l_suppress = 'y');

exception
when ecx_utils.program_exit
then
  if (l_procedureEnabled)
  then
    ecx_debug.pop(i_method_name);
  end if;
  raise ECX_UTILS.PROGRAM_EXIT;
when others
then
  ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.GET_SUPPRESS_PROFILE');
  if(l_unexpectedEnabled)
  then
    ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.GET_SUPPRESS_PROFILE',
      i_method_name);
    ecx_debug.log(l_unexpected, 'resetting first_time',i_method_name);
  end if;
  ecx_print_local.first_time_printing := true;
  if (l_procedureEnabled)
  then
    ecx_debug.pop(i_method_name);
  end if;
  raise ECX_UTILS.PROGRAM_EXIT;

end get_suppress_profile;

procedure print_new_level
	(
	i_level		IN	pls_integer,
	i_index		IN	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_print_local.print_new_level';
i		pls_integer := i_index;
j		pls_integer :=1;
k		pls_integer :=0;
do_printing 	Boolean	    := false;
current_position        pls_integer;
last_stack_id           pls_integer;
start_pos               pls_integer;
end_pos                 pls_integer;

-- fix for bug 6900831
loop_count         pls_integer :=  0;
w_note_stack_last  pls_integer := -1;
w_i                pls_integer := -1;
w_start_pos        pls_integer := -1;
w_current_position pls_integer := -1;

begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_level',i_level,i_method_name);
  ecx_debug.log(l_statement,'i_index',i_index,i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'count',ecx_utils.g_xml_frag.count,i_method_name);
end if;
if (ecx_utils.g_xml_frag.count >0)  then
for i in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
   loop
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'var_pos',ecx_utils.g_xml_frag(i).variable_pos,i_method_name);
  ecx_debug.log(l_statement,'value',ecx_utils.g_xml_frag(i).value,i_method_name);
end if;
end loop;
end if;

if (ecx_utils.g_target(i).external_level <> i_level)
then
	return;
end if;

loop
	exit when i = ecx_utils.g_target.COUNT;
	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'Current DTD Node=>'||i,ecx_utils.g_target(i).attribute_name,i_method_name);
	  print_node_stack;
	end if;

        current_position := i;
        if(l_statementEnabled) then
          ecx_debug.log(l_statement,'Set current position to', current_position,i_method_name);
	end if;

	if ecx_utils.g_target(i).attribute_type = 2
	then
		begin
		if(ecx_utils.g_target(i).value is not null)
		then
			if(l_statementEnabled) then
			       ecx_debug.log(l_statement,'Attribute Value is not null',i_method_name);
			end if;

			print_waiting_nodes_attr;

			if ecx_utils.g_target(i+1).attribute_type = 1
			then
				attribute_node_close
					(
					ecx_utils.g_target(i).attribute_name,
					ecx_utils.g_target(i).value
					);
				 if(l_statementEnabled) then
                                    ecx_debug.log(l_statement,ecx_utils.g_target(i).value,i_method_name);
				    ecx_debug.log(l_statement,ecx_utils.g_target(i).attribute_name||'="">',
				                 i_method_name);
			         end if;
                                if  ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).is_clob is not null Then
                                    cdata_element_value(
                                     ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).clob_value,
                                     ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value);
                                else
                                    if (has_fragment(ecx_utils.g_target(i).parent_attribute_id)) then
                                          print_xml_fragment(ecx_utils.g_target(i).parent_attribute_id,false);
                                    else
				    element_value(ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).clob_value,
                                          ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value);
                                    end if;
                                     if(l_statementEnabled) then
                                         ecx_debug.log(l_statement,ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value,
					              i_method_name);
				     end if;
                                end if;

			elsif ecx_utils.g_target(i+1).attribute_type = 2
			then
				attribute_node
					(
					ecx_utils.g_target(i).attribute_name,
					ecx_utils.g_target(i).value
					);
				if(l_statementEnabled) then
                                    ecx_debug.log(l_statement,ecx_utils.g_target(i).attribute_name||'=""',i_method_name);
		        	    ecx_debug.log(l_statement,ecx_utils.g_target(i).value,i_method_name);
				end if;
			end if;
		else -- to close the parent if none of the attributes are to be printed.
			if(last_node_printed = l_node_stack.LAST) -- if parent is on top stack and has been printed
			then
				if( i = ecx_utils.g_target.LAST  OR ecx_utils.g_target(i+1).attribute_type = 1)
				then
					element_close;
					if  ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).is_clob is not null
					Then
						cdata_element_value(
		                                ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).clob_value,
				                ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value);
					else
                                                if (has_fragment(ecx_utils.g_target(i).parent_attribute_id)) then
                                                print_xml_fragment(ecx_utils.g_target(i).parent_attribute_id,false);
                                                else
						element_value(ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).clob_value,
	                                        ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value);
                                                end if;
			                        if(l_statementEnabled)
						then
							ecx_debug.log(l_statement,ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value,i_method_name);
						end if;
					end if;
				end if;
			end if;
		end if;
		exception
		when no_data_found
		then
			attribute_node_close
				(
				ecx_utils.g_target(i).attribute_name,
				ecx_utils.g_target(i).value
				);
			if(l_unexpectedEnabled) then
                             ecx_debug.log(l_unexpected,ecx_utils.g_target(i).value,i_method_name);
			     ecx_debug.log(l_unexpected,ecx_utils.g_target(i).attribute_name||'="">',i_method_name);
			end if;
                        if  ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).is_clob is not null Then
                        	cdata_element_value(
                                ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).clob_value,
                                ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value);
                     	else
                                if (has_fragment(ecx_utils.g_target(i).parent_attribute_id)) then
                                    print_xml_fragment(ecx_utils.g_target(i).parent_attribute_id,false);
                                else
                        	element_value(ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).clob_value,
                                            ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value);
                                end if;
                                if(l_statementEnabled) then
                                  ecx_debug.log(l_statement,ecx_utils.g_target(ecx_utils.g_target(i).parent_attribute_id).value,
				               i_method_name);
			        end if;
                    	end if;

		end;

                last_printed := ecx_utils.g_target(i).attribute_id;
                if(l_statementEnabled) then
                    ecx_debug.log(l_statement, 'last_printed 1', last_printed,i_method_name);
		end if;

	elsif ecx_utils.g_target(i).attribute_type = 1
	then
                if (ecx_print_local.first_time_printing)
		then
		   do_printing := true;
		   ecx_print_local.first_time_printing := false;
		   suppress_profile := get_suppress_profile;
		   /* Reinitialize the clob, so that it would not have left over
                      data from previous run */
                   if dbms_lob.istemporary(i_xmldoc) = 1 then
                      dbms_lob.freetemporary(i_xmldoc);
                   end if;
                   i_xmldoc := null;
		else
		   if ecx_utils.g_target(i).parent_attribute_id =
		      l_node_stack(l_node_stack.LAST)
		   then
      		      if(l_statementEnabled) then
                        ecx_debug.log(l_statement,  'condition true',i_method_name);
	              end if;
		      do_printing := true;
		   else
		      do_printing := false;
		      if(l_statementEnabled) then
                        ecx_debug.log(l_statement,  'condition false',i_method_name);
	              end if;
		   end if;
		end if;
		if (do_printing)
		then
                        /*
                          before we put the current element on the stack, if this element's parent has
                          any discontinuous elements that were not printed we need to print these
                        */

                        if (l_node_stack.COUNT <> 0)
                        then
                        	print_discont_elements(last_printed + 1, current_position - 1,
                                	               l_node_stack(l_node_stack.LAST),
                                        	       ecx_utils.g_target(l_node_stack
                                                       (l_node_stack.LAST)).external_level);
				/*
	                          if at all any discontinuous elements were printed we need to once
                                  again ensure if the last element on the stack is the current
                                  element's parent. if not we need to pop till this condition is
                                  satisfied
				*/
	                        pop_discont_elements(ecx_utils.g_target(i).parent_attribute_id);
                        end if;
					if(l_statementEnabled) then
						ecx_debug.log(l_statement,'value:',ecx_utils.g_target(i).value,
				                 i_method_name);
						ecx_debug.log(l_statement,'flag:',ecx_utils.g_target(i).required_flag,
				                 i_method_name);
						ecx_debug.log(l_statement,'attribute name:',ecx_utils.g_target(i).attribute_name,
				                 i_method_name);
					end if;

			-- if suppress profile is true and node is optional and does not have a value then push it on the stack .
			-- Do not print it.
			if (suppress_profile AND
			    ecx_utils.g_target(i).value is null AND
                            ecx_utils.g_target(i).required_flag = 'N' AND NOT has_fragment_value(i))
			then
                                xmlPUSH(ecx_utils.g_target(i).attribute_id);
			else

			 	-- This means that either the node has a value or attributes or
                                -- that it was required. In this case we need to both print and push
				-- it.Also we will advance our the last_node_printed pointer

				print_waiting_nodes;

			  	if ecx_utils.g_target(i).has_attributes > 0
				then
					element_open(ecx_utils.g_target(i).attribute_name);
					if(l_statementEnabled) then
						ecx_debug.log(l_statement,'<'||ecx_utils.g_target(i).attribute_name,
				                 i_method_name);
					end if;
				else
 					/** Change required for Clob Support -- 2263729 ***/
                		       	if  ecx_utils.g_target(i).is_clob is not null Then
                        	        	cdata_element_node_open
                               		        (
						ecx_utils.g_target(i).attribute_name,
						ecx_utils.g_target(i).value,
                	                       	ecx_utils.g_target(i).clob_value
                        	               	);
                        		else
                                                if (has_fragment(i)) then
                                                  print_xml_fragment(i,true);
                                                else
						element_node_open
						(
						ecx_utils.g_target(i).attribute_name,
						ecx_utils.g_target(i).value,
	                	                ecx_utils.g_target(i).clob_value
						);
                                                end if;
               	 	        	end if;
		    			if(l_statementEnabled) then
	                                    ecx_debug.log(l_statement,'<'||ecx_utils.g_target(i).attribute_name||'>',
					                 i_method_name);
					end if;
				end if;
			  	xmlPUSH(ecx_utils.g_target(i).attribute_id);
				last_node_printed := l_node_stack.LAST;
			    	if(l_statementEnabled) then
                                	ecx_debug.log(l_statement,'last_node_printed = ', last_node_printed, i_method_name);
				end if;
			end if;
        	        ecx_print_local.last_printed := ecx_utils.g_target(i).attribute_id;
                        if(l_statementEnabled) then
                           ecx_debug.log(l_statement,'last_printed ', last_printed,i_method_name);
			end if;

		elsif ecx_utils.g_target(i).parent_attribute_id <> l_node_stack(l_node_stack.LAST)
		then
                        loop_count := 0;
			loop
				exit when l_node_stack(l_node_stack.LAST) =
					ecx_utils.g_target(i).parent_attribute_id;
                                --     or loop_count >= l_loop_max;
                                if loop_count >= l_loop_max then
                                    ecx_debug.log(l_statement,'Abnormal Termination, Node Stack:','stack',i_method_name);
                                    print_node_stack;
                                    ecx_debug.log(l_statement,'Value for i: ',i,i_method_name);
                                    ecx_debug.log(l_statement,'Start position: ',start_pos,i_method_name);
                                    ecx_debug.log(l_statement,'Current position: ',current_position,i_method_name);
                                    ecx_debug.log(l_statement,'Current target element: ',ecx_utils.g_target(i).attribute_name,i_method_name);
                                    raise_application_error(-20000,'Abnormal condition encountered, infinite loop detected');
                                end if;

                        	/*
                          	before we close the current element if this element has any discontinuous
                          	elements that were not printed we need to print these
                          	since we are closing this elment we know need to look for discont elements
                         	only till the file_end_pos of this element's level and not the current_pos
                        	*/
                        	start_pos := last_printed + 1;

                                if (is_descendant(l_node_stack(l_node_stack.LAST), i))
                                then
                                        if ( l_node_stack.LAST = w_note_stack_last and
                                             i                 = w_i and
                                             start_pos         = w_start_pos and
                                             current_position  = w_current_position)
                                        then
                                             loop_count := loop_count + 1;
                                        else
                                             loop_count := 0;
                                             w_note_stack_last := l_node_stack.LAST;
                                             w_i := i;
                                             w_start_pos := start_pos;
                                             w_current_position := current_position;
                                        end if;

                                        end_pos := current_position;
                                        print_discont_elements (start_pos, end_pos,
                                                 l_node_stack(l_node_stack.LAST),
                                                 ecx_utils.g_target(l_node_stack
                                                 (l_node_stack.LAST)).external_level);
				else
                                        loop_count := 0;
                        		end_pos := ecx_utils.g_target_levels(ecx_utils.g_target(l_node_stack
                                	   (l_node_stack.LAST)).external_level).file_end_pos;

       	                		print_discont_elements (start_pos, end_pos,
               	                        	l_node_stack(l_node_stack.LAST),
                        	               	ecx_utils.g_target(l_node_stack
                                               	(l_node_stack.LAST)).external_level);

                                        if (not (is_descendant(l_node_stack(l_node_stack.LAST), i)))
                                        then

						-- check if an element needs to be closed.
						-- element will need to be closed only if it was opened.
						-- if it were opened then the last_node_printed id should be set to the last
						-- on stack
						if(last_node_printed = l_node_stack.LAST)
						then
  					    		/** Change required for Clob Support -- 2263729 ***/
                        		    		if ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).is_clob is not null Then
								cdata_element_node_close
                                				(
								ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name,
								ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).value,
								ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).clob_value
                        	        			);
                        			    	else
			   					element_node_close
								(
								ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name
								);
                	        		    	end if;

						    	if(l_statementEnabled) then
                                	              		ecx_debug.log(l_statement,'</'||ecx_utils.g_target(l_node_stack(l_node_stack.LAST)).attribute_name||'>',
						               i_method_name);
					    		end if;
						end if;
						xmlPOP;
					end if;
				end if;  -- NOT an ancestor
			end loop;
                        if ( loop_count >= l_loop_max )
                        then
				if(l_statementEnabled)
				then
                                        ecx_debug.log(l_statement,'l_loop_max reached: '||l_loop_max, i_method_name);
				end if;
                        end if;

                	/*
                  	before we push the current element if this element's parent has any
                  	discontinuous elements that were not printed we need to print these
                	*/

                	print_discont_elements (last_printed + 1, current_position - 1,
                                               l_node_stack(l_node_stack.LAST),
                                               ecx_utils.g_target(l_node_stack
                                               (l_node_stack.LAST)).external_level);
			/*
                          if at all any discontinuous elements were printed we need to once again
                          ensure if the last element on the stack is the current element's parent
                          if not we need to pop till this condition is satisfied
			*/
                        pop_discont_elements(ecx_utils.g_target(i).parent_attribute_id);

			-- Move this one on the Stack.
			-- Check for the next Node whether it is Attribute Node or not

			-- if suppress profile is true and node is optional and does not have a value
			-- just push it on the stack . do not print it
			if (suppress_profile AND
			    ecx_utils.g_target(i).value is null AND
			    ecx_utils.g_target(i).required_flag = 'N')
			then
				  xmlPUSH(ecx_utils.g_target(i).attribute_id);
			else

			 	-- Either the node has a value or attributes or that
				-- it was required. in this case we need to both print and push it.
				-- Also we will advance our the last_node_printed pointer print_waiting_nodes;
				print_waiting_nodes;

			  	if ecx_utils.g_target(i).has_attributes > 0
			  	then
		  			element_open(ecx_utils.g_target(i).attribute_name);
					if(l_statementEnabled)
					then
	                                        ecx_debug.log(l_statement,'<'||ecx_utils.g_target(i).attribute_name, i_method_name);
					end if;
			  	else
 					/** Change required for Clob Support -- 2263729 ***/
                        		if ecx_utils.g_target(i).is_clob is not null Then
	                               		cdata_element_node_open
                                       		(
						ecx_utils.g_target(i).attribute_name,
						ecx_utils.g_target(i).value,
                	                       	ecx_utils.g_target(i).clob_value
        	                               	);
                        		else
                                                if (has_fragment(i)) then
                                                  print_xml_fragment(i,true);
                                                else
						element_node_open
						(
						ecx_utils.g_target(i).attribute_name,
						ecx_utils.g_target(i).value,
	                        	        ecx_utils.g_target(i).clob_value
						);
                                                end if;
	                        	end if;
					if(l_statementEnabled) then
                                    		ecx_debug.log(l_statement,'<'||ecx_utils.g_target(i).attribute_name||'>',
				                 i_method_name);
					end if;
				end if;
				xmlPUSH(ecx_utils.g_target(i).attribute_id);
                                last_node_printed := l_node_stack.LAST;
				if(l_statementEnabled) then
	                           ecx_debug.log(l_statement, 'last_node_printed = ', last_node_printed,i_method_name);
				end if;
			end if;
	                ecx_print_local.last_printed := ecx_utils.g_target(i).attribute_id;
                	if(l_statementEnabled) then
                           ecx_debug.log(l_statement, 'last_printed', last_printed,i_method_name);
			end if;
                 end if;
	end if;
	exit when ecx_utils.g_target.LAST = i;
	i := ecx_utils.g_target.NEXT(i);
	exit when ecx_utils.g_target(i).external_level <> i_level;
end loop;

append_clob;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	ecx_print_local.suppress_profile := false;
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
	ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_NEW_LEVEL');
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_NEW_LEVEL',
	                 i_method_name);
	    ecx_debug.log(l_unexpected, 'resetting first_time',i_method_name);
	end if;
	ecx_print_local.first_time_printing := true;
	ecx_print_local.suppress_profile := false;
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	raise ECX_UTILS.PROGRAM_EXIT;
end print_new_level;


procedure escape_spec_char(
   p_value     IN          Varchar2,
   x_value     OUT  NOCOPY Varchar2
   ) is

i_method_name   varchar2(2000) := 'ecx_print_local.escape_spec_char';

begin
   if (p_value is null) then
      return;
   end if;
   x_value := p_value;
   x_value := replace(x_value,i_amp, i_amp||'amp;');
   x_value := replace(x_value,i_lt, i_amp||'lt;');
   x_value := replace(x_value,i_gt, i_amp||'gt;');
   x_value := replace(x_value,i_apos, i_amp||'apos;');
   x_value := replace(x_value,i_quot, i_amp||'quot;');
exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.escape_spec_char');
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.escape_spec_char',i_method_name);
      end if;
      raise ecx_utils.program_exit;
end escape_spec_char;

procedure replace_spec_char(
   p_value     IN          Varchar2,
   x_value     OUT  NOCOPY Varchar2
   ) is

i_method_name   varchar2(2000) := 'ecx_print_local.replace_spec_char';

begin
   if(l_statementEnabled) then
     ecx_debug.log(l_statement, 'p_value',  p_value,i_method_name);
   end if;
   if (p_value is null) then
      return;
   end if;
   x_value := p_value;
   x_value := replace(x_value,i_amp||'amp;', i_amp);
   x_value := replace(x_value,i_amp||'lt;', i_lt);
   x_value := replace(x_value,i_amp||'gt;', i_gt);
   x_value := replace(x_value,i_amp||'apos;', i_apos);
   x_value := replace(x_value,i_amp||'quot;', i_quot);

   x_value := replace(x_value,i_amp||'#38;', i_amp);
   x_value := replace(x_value,i_amp||'#60;', i_lt);
   x_value := replace(x_value,i_amp||'#62;', i_gt);
   x_value := replace(x_value,i_amp||'#39;', i_apos);
   x_value := replace(x_value,i_amp||'#34;', i_quot);

   x_value := replace(x_value,i_amp||'#x26;', i_amp);
   x_value := replace(x_value,i_amp||'#x3c;', i_lt);
   x_value := replace(x_value,i_amp||'#x3e;', i_gt);
   x_value := replace(x_value,i_amp||'#x27;', i_apos);
   x_value := replace(x_value,i_amp||'#x22;', i_quot);

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'x_value',  x_value,i_method_name);
   end if;
exception
   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_PRINT_LOCAL.replace_spec_char');
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, 'ECX', SQLERRM || ' - ECX_PRINT_LOCAL.replace_spec_char',i_method_name);
      end if;
      raise ecx_utils.program_exit;
end replace_spec_char;
procedure get_chunks
        (
         clob_value    IN clob,
         is_cdata      IN boolean
        )
is

i_method_name   varchar2(2000) := 'ecx_print_local.get_chunks';

i       pls_integer:=1;
clength pls_integer:=0;
i_temp varchar2(32767);
--i_temp1 varchar2(32767);
Begin
	clength := dbms_lob.getlength(clob_value);
        while clength >= i loop
        	i_temp := dbms_lob.substr(clob_value,g_split_threshold,i);
/*
                if (not is_cdata) then
                    escape_spec_char(i_temp, i_temp1);
                else
                    i_temp1 := i_temp;
                end if;
                i_tmpxml(i_tmpxml.COUNT+1) := i_temp1;
*/
		get_chunks(i_temp, is_cdata);
                i := i+ g_split_threshold;
 	end loop;
Exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
When Others Then
	ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.GET_CHUNKS');
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.GET_CHUNKS',
	               i_method_Name);
	end if;
        raise ecx_utils.program_exit;
End;



procedure get_chunks
        (
          value    IN varchar2,
          is_cdata      IN boolean
        )
is

i_method_name   varchar2(2000) := 'ecx_print_local.get_chunks';

i       pls_integer:=1;
clength pls_integer:=0;
i_temp  varchar2(32767);
i_temp1 varchar2(4000);
Begin
	if (not is_cdata) then
	    escape_spec_char(value, i_temp);
	else
	    i_temp := value;
	end if;
	clength := lengthb(i_temp);
        while clength >= i loop
		i_temp1 := substrb(i_temp,i,g_split_threshold);
                i_tmpxml(i_tmpxml.COUNT+1) := i_temp1;
                i := i+ g_split_threshold;
	end loop;
Exception
when value_error then
        ecx_debug.setErrorInfo(1, 30, 'ECX_INVALID_VARCHAR2_LEN');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
	end if;
        raise ECX_UTILS.PROGRAM_EXIT;
when ecx_utils.program_exit then
	raise ECX_UTILS.PROGRAM_EXIT;
When Others Then
	ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.GET_CHUNKS');
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.GET_CHUNKS',
	               i_method_name);
	end if;
        raise ecx_utils.program_exit;
End;


FUNCTION has_fragment (var_pos IN pls_integer) return boolean
is
  i_method_name   varchar2(2000) := 'ecx_print_local.has_fragment';
  flag varchar2(1):= 'N';
BEGIN

  if (ecx_utils.g_xml_frag.count >0 and ecx_utils.g_target(var_pos).value is
       null and ecx_utils.g_target(var_pos).clob_value is null) then

   for i in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
   loop
      if (var_pos = ecx_utils.g_xml_frag(i).variable_pos) then

      flag := 'Y';
      exit;
      end if;
   end loop;
  else
     return FALSE;
  end if;

  if  (flag = 'Y') then
   return TRUE;
  else
    return FALSE;
  end if;
exception
 When Others Then
        ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.HAS_FRAGMENT');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.HAS_FRAGMENT',
                       i_method_name);
        end if;
        raise ecx_utils.program_exit;

end;

FUNCTION has_fragment_value (var_pos IN pls_integer) return boolean
is
 i_method_name   varchar2(2000) := 'ecx_print_local.has_fragment_value';
 flag varchar2(1):= 'N';
BEGIN
  if (ecx_utils.g_xml_frag.count >0 and ecx_utils.g_target(var_pos).value is
  null and ecx_utils.g_target(var_pos).clob_value is null) then

   for i in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
   loop
     if (var_pos = ecx_utils.g_xml_frag(i).variable_pos and
          ecx_utils.g_xml_frag(i).value is not null) then
     flag := 'Y';
     exit;
     end if;
   end loop;
  else
     return FALSE;
  end if;
  if  (flag = 'Y') then
   return TRUE;
  else
    return FALSE;
  end if;
EXCEPTION
 When Others Then
        ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' -
                                ECX_PRINT_LOCAL.HAS_FRAGMENT_VALUE');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', ecx_utils.i_errbuf || SQLERRM || ' -
                                  ECX_PRINT_LOCAL.HAS_FRAGMENT_VALUE',
                                   i_method_name);
        end if;
        raise ecx_utils.program_exit;

end;

PROCEDURE print_xml_fragment (var_pos IN pls_integer,
                              print_tag IN boolean)
is
i_method_name   varchar2(2000) := 'ecx_print_local.print_xml_fragment';
begin
 if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
 end if;

 if(l_statementEnabled) then
     ecx_debug.log(l_statement,'attribute_name',
       ecx_utils.g_target(var_pos).attribute_name,i_method_name);
 end if;

  if (print_tag) then
    i_tmpxml(i_tmpxml.COUNT+1) :=
             i_elestarttag||ecx_utils.g_target(var_pos).attribute_name ||i_eleendtag;
  end if;
  if (ecx_utils.g_xml_frag.count > 0) then
   for i in ecx_utils.g_xml_frag.FIRST .. ecx_utils.g_xml_frag.LAST
   loop
     if (var_pos = ecx_utils.g_xml_frag(i).variable_pos) then
      if (ecx_utils.g_xml_frag(i).value is not null) then
         get_chunks(ecx_utils.g_xml_frag(i).value,true);
      end if;
      exit;
     end if;
   end loop;
  end if;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
EXCEPTION
 When Others Then
        ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_XML_FRAGMENT');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_PRINT_LOCAL.PRINT_XML_FRAGMENT',
                       i_method_name);
        end if;
        raise ecx_utils.program_exit;
end;

end ecx_print_local;

/
