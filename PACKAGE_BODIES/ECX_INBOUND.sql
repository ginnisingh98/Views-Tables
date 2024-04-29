--------------------------------------------------------
--  DDL for Package Body ECX_INBOUND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_INBOUND" as
--$Header: ECXINBB.pls 120.4 2006/06/07 07:33:43 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

TYPE l_stack is table of pls_integer index by binary_integer;
i_stack		l_stack;
i_current_depth	pls_integer;
i_xmlclob       clob;

/**
stage 10 - Pre-Processing
stage 20 - In-Processing
stage 30 - Post-Processing
**/

/**
 Updates the DOM for any mappings by refering to the g_node_tbl
**/
procedure updateDOM
	(
	i_target	IN	pls_integer
	)
is

i_method_name   varchar2(2000) := 'ecx_inbound.updatedom';

p_node		     xmlDOM.DOMNode;
l_text_node          xmldom.DOMNode;

begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   for j in ecx_utils.g_target_levels(i_target).file_start_pos..ecx_utils.g_target_levels(i_target).file_end_pos
   loop
      -- update the DOM for each element of this level
      -- get the DOM id for the current attribute
      if ecx_utils.g_target(j).map_attribute_id is not null
      then
         p_node := ecx_utils.g_node_tbl(ecx_utils.g_target(j).attribute_id);

         if (xmlDOM.getNodeType(p_node) = 2)
         then
            l_text_node := p_node;
         else
            l_text_node := xmldom.getFirstChild(p_node);
         end if;

         -- Update the DOM only if the node and its value are not null
         if not (xmldom.isnull(l_text_node))
	 then
            if (ecx_utils.g_target(j).value is not null)
            then
               xmlDOM.setNodeValue(l_text_node,ecx_utils.g_target(j).value);
            end if;
             if(l_statementEnabled) then
               ecx_debug.log(l_statement,'updating dom node', xmlDOM.getNodeValue(l_text_node),
                            i_method_name);
               ecx_debug.log(l_statement, 'with value', ecx_utils.g_target(j).value,i_method_name);
            end if;
         end if;
      end if;
   end loop;

  if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
  end if;
exception
when  others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || ' - ECX_INBOUND.updateDOM');
       if(l_statementEnabled) then
               ecx_debug.log(l_statement,'ECX', SQLERRM || ' - ECX_INBOUND.updateDOM',
                            i_method_name);
       end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end updateDOM;

procedure processTarget
	(
	i_target	in	pls_integer
	)
is

i_method_name   varchar2(2000) := 'ecx_inbound.processTarget';
begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
      ecx_debug.log(l_statement,'i_target',i_target,i_method_name);
   end if;

   -- don't need t execute stage 10, level 0 action for target as this is
   -- already done in the initilization phase
   if (i_target <> 0)
   then
      /** Execute the Pre-processing for the Target **/
      ecx_actions.execute_stage_data (10,i_target, 'T');
   end if;

   /** Move the Data from Source to the Target **/
   for j in ecx_utils.g_target_levels(i_target).file_start_pos..ecx_utils.g_target_levels(i_target).file_end_pos
   loop

      if ecx_utils.g_target(j).map_attribute_id is not null
	then
            /* Just assign the source data as it is to target */
            ecx_utils.g_target(j).clob_value :=
                  ecx_utils.g_source(ecx_utils.g_target(j).map_attribute_id).clob_value;
            ecx_utils.g_target(j).clob_length :=
                  ecx_utils.g_source(ecx_utils.g_target(j).map_attribute_id).clob_length;
            ecx_utils.g_target(j).is_clob :=
                  ecx_utils.g_source(ecx_utils.g_target(j).map_attribute_id).is_clob;
            ecx_utils.g_target(j).value :=
                         ecx_utils.g_source(ecx_utils.g_target(j).map_attribute_id).value;
end if;

      If ecx_utils.g_target(j).clob_value is not null Then
		 if(l_statementEnabled) then
               ecx_debug.log(l_statement,j||'=>'||ecx_utils.g_target(j).parent_attribute_id||'=>'||
		             ecx_utils.g_target(j).attribute_type||'=>'||
	                     ecx_utils.g_target(j).attribute_name,ecx_utils.g_target(j).clob_value,
                           i_method_name);
             end if;
	else
        	-- if clob_value is null this means that it is varchar2
	       /** If the value is null then assign the target default value **/
	        If ecx_utils.g_target(j).value is null
	        then
		        ecx_utils.g_target(j).value := ecx_utils.g_target(j).default_value;
	        End if;
	         if(l_statementEnabled) then
                  ecx_debug.log(l_statement,j||'=>'||ecx_utils.g_target(j).parent_attribute_id||'=>'||
		             ecx_utils.g_target(j).attribute_type||'=>'||
	                     ecx_utils.g_target(j).attribute_name,ecx_utils.g_target(j).value,
                           i_method_name);
               end if;
      End If;
       if(l_statementEnabled) then
               ecx_debug.log(l_statement,'ecx_utils.g_target('||j||') is_clob variable' ,ecx_utils.g_target(j).is_clob,
                            i_method_name);
       end if;

   end loop;


   /** Execute the In-processing for the Target **/
   if (i_target <> 0)
   then
      ecx_actions.execute_stage_data (20,i_target, 'T');
   end if;

   -- check if the data needs to be printed
   if (ecx_utils.dom_printing)
   then
      -- update the DOM
      updateDOM(i_target);
   else
      if (ecx_utils.structure_printing)
      then
         -- call the printing program
         ecx_print_local.print_new_level
		   (
		   i_target,
		   ecx_utils.g_target_levels(i_target).dtd_node_index
		   );
      end if;
   end if;

   /** Execute the Post-processing for the Target **/
   if (i_target <> 0)
   then
      ecx_actions.execute_stage_data (30,i_target, 'T');
   end if;
   if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
   end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;
when others then
	/* Start of bug# 2186635*/
	ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || ' - ECX_INBOUND.processTarget');
	/* End of bug# 2186635 */
         if(l_statementEnabled) then
               ecx_debug.log(l_statement,'ECX', ecx_utils.i_errbuf || ' - ECX_INBOUND.processTarget',
                            i_method_name);
         end if;
	 if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end processTarget;

procedure process_data
	(
	i		IN	pls_integer,
	i_stage		in	pls_integer ,
	i_next		IN	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound. process_data';
begin

if (l_procedureEnabled) then
   ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i',i,i_method_name);
  ecx_debug.log(l_statement,'i_stage',i_stage,i_method_name);
  ecx_debug.log(l_statement,'i_next',i_next,i_method_name);
end if;

if (i < 0)
then
	if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
	return;
end if;

if i_stage = 10
then
	/** Should clean up the Current Source and the down levels first**/
	for k in i..ecx_utils.g_source_levels.last
	loop
	  for j in ecx_utils.g_source_levels(k).file_start_pos..ecx_utils.g_source_levels(k).file_end_pos
       	   loop
              ecx_utils.g_source(j).clob_value := null;
              ecx_utils.g_source(j).is_clob    := null;
              ecx_utils.g_source(j).clob_length := null;
	      if ecx_utils.g_source(j).default_value is null
	      then
       	               ecx_utils.g_source(j).value := null;
	      else
       	               ecx_utils.g_source(j).value := ecx_utils.g_source(j).default_value;
		end if;

   	      if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'Source '||ecx_utils.g_source(j).attribute_name,
		          ecx_utils.g_source(j).value,i_method_name);
	      end if;
	   end loop;
	end loop;


        -- For level 0 this is already done in Initialization
        if (i <> 0)
        then
	   /** Execute the pre-processing for the Source **/
            ecx_actions.execute_stage_data (i_stage, i, 'S');
        end if;
end if;

if i_stage = 20
then
        -- For level 0 this is already done in Initialization
        if (i <> 0)
        then
	   /** Execute the In-processing for the Source **/
           ecx_actions.execute_stage_data (i_stage, i, 'S');
        end if;

	for j in ecx_utils.g_source_levels(i).first_target_level .. ecx_utils.g_source_levels(i).last_target_level
	loop
	 	/** Initialize the Target **/
	        for k in ecx_utils.g_target_levels(j).file_start_pos..ecx_utils.g_target_levels(j).file_end_pos
                loop
                ecx_utils.g_target(k).clob_value := null;
                ecx_utils.g_target(k).clob_length := null;
                ecx_utils.g_target(k).is_clob := null;

                        if ecx_utils.g_target(k).default_value is null
                        then
                                ecx_utils.g_target(k).value := null;
                        else
                                ecx_utils.g_target(k).value := ecx_utils.g_target(k).default_value;
                        end if;

                        if(l_statementEnabled) then
                            ecx_debug.log(l_statement,'target '||ecx_utils.g_target(k).attribute_name,
			                 ecx_utils.g_target(k).value,i_method_name);
			end if;
                end loop;

	end loop;


	/** Check for Collapsion. Do depth checking for Collapsion only **/
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,'Previous Level',i,i_method_name);
	    ecx_debug.log(l_statement,'Current Level',i_next,I_method_name);
        end if;
	if ( ecx_utils.g_source_levels(i).last_source_level -
	ecx_utils.g_source_levels(i).first_source_level > 0 )
	then
		if i_next > i
		then
			if 	( i_next >= ecx_utils.g_source_levels(i).first_source_level )
				and
				( i_next <= ecx_utils.g_source_levels(i).last_source_level )
			then
				if(l_statementEnabled) then
                                  ecx_debug.log(l_statement,'Skipping Source',i,i_method_name);
				end if;
			else
				processTarget(ecx_utils.g_source_levels(i).first_target_level);
			end if;
		end if;

		if i_next <= i
		then
				processTarget(ecx_utils.g_source_levels(i).first_target_level);
		end if;
	else
		/** Else Expansion or 1-1 mapping **/
		for j in ecx_utils.g_source_levels(i).first_target_level .. ecx_utils.g_source_levels(i).last_target_level
		loop
			processTarget(j);
		end loop;
	end if;
end if;

if i_stage = 30
then
        -- For level 0 this is will be done in the end
        if (i <> 0)
        then
	   /** Execute the Post-processing for the Source **/
           ecx_actions.execute_stage_data (30, i, 'S');
        end if;
end if;

if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;

when others then
	 if(l_statementEnabled) then
            ecx_debug.log(l_statement,SQLERRM,i_method_name);
	 end if;
	 if (l_procedureEnabled) then
             ecx_debug.pop(i_method_name);
         end if;
	raise ecx_utils.program_exit;
end process_data;


procedure print_stack
is
  i_method_name   varchar2(2000) := 'ecx_inbound.print_stack';
begin
	if(l_statementEnabled) then
		ecx_debug.log(l_statement,'Stack Status','====',i_method_name);
		for i in 1..i_stack.COUNT
		loop
			  ecx_debug.log(l_statement,i_stack(i),i_method_name);
		end loop;
	end if;
exception
when others then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,SQLERRM,i_method_name);
	end if;
	raise ecx_utils.program_exit;
end print_stack;

procedure pop
	(
	i_next	in	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound.pop';
begin
	if (l_procedureEnabled) then
	     ecx_debug.push(i_method_name);
	end if;
	if(l_statementEnabled) then
	  ecx_debug.log(l_statement,i_next,i_method_name);
	  print_stack;
	end if;

	if i_stack.COUNT = 0
	then
		if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'Stack Error. Nothing to pop','xxxxx',i_method_name);
                end if;
		if (l_procedureEnabled) then
                  ecx_debug.pop(i_method_name);
                end if;
		return;
	end if;

	/** Post Process and then pop. **/
	process_data(i_stack(i_stack.COUNT),30,i_next);

	i_stack.delete(i_stack.COUNT);

	if(l_statementEnabled) then
		print_stack;
	end if;

	if (l_procedureEnabled) then
	    ecx_debug.pop(i_method_name);
	end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;
when others then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,SQLERRM,i_method_name);
	end if;
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end pop;

procedure push
	(
	i	in	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound.push';
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
	if(l_statementEnabled) then
	  ecx_debug.log(l_statement,i,i_method_name);
	  print_stack;
	end if;

	if i_stack.COUNT = 0
	then
		-- Nothing on the Stack. Push the value
		i_stack(i_stack.COUNT+1):=i;

		/** pre stage processing **/
		process_data(i_stack(i_stack.COUNT),10,i);

		if(l_statementEnabled) then
			print_stack;
		end if;

		if (l_procedureEnabled) then
                  ecx_debug.pop(i_method_name);
                end if;
		return;
	end if;

	if i > i_stack(i_stack.COUNT)
	then

		/** In stage processing **/
		process_data(i_stack(i_stack.COUNT),20,i);

		-- Push
		i_stack(i_stack.COUNT+1):=i;

		/** pre stage processing **/
		process_data(i_stack(i_stack.COUNT),10,i);

		if(l_statementEnabled) then
			print_stack;
		end if;

		if (l_procedureEnabled) then
                   ecx_debug.pop(i_method_name);
                end if;
		return;
	end if;

	if i = i_stack(i_stack.COUNT)
	then
		/** In-Processing and then pop the Top Entry. **/
		process_data(i_stack(i_stack.COUNT),20,i);
		pop(i);
	end if;

	if i_stack.COUNT <> 0
	then
		if i < i_stack(i_stack.COUNT)
		then

			/** In-Processing and then pop the Top Entry. **/
			process_data(i_stack(i_stack.COUNT),20,i);
			pop(i);

			/** Pop The rest of the Elements **/
			while ( i <= i_stack(i_stack.COUNT) )
			loop
				pop(i);
				exit when i_stack.COUNT = 0;
			end loop;

		end if;
	end if;

	-- Push the value
	i_stack(i_stack.COUNT+1):=i;
	/** pre stage processing **/
	process_data(i_stack(i_stack.COUNT),10,i);

	if(l_statementEnabled) then
		print_stack;
	end if;

	if (l_procedureEnabled) then
	    ecx_debug.pop(i_method_name);
	end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;
when others then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,SQLERRM,i_method_name);
	end if;
	if (l_procedureEnabled) then
             ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end push;


procedure popall
is
i_method_name   varchar2(2000) := 'ecx_inbound.popall';
begin
if (l_procedureEnabled) then
   ecx_debug.push(i_method_name);
end if;
	/** In-Process the last Level on the Stack **/
	if i_stack.COUNT <> 0
	then
		process_data(i_stack(i_stack.COUNT),20,0);
	end if;

	if(l_statementEnabled) then
		print_stack;
	end if;

	while ( i_stack.COUNT > 0)
	loop
		pop(0);
	end loop;

	if(l_statementEnabled) then
		print_stack;
	end if;

	 if (l_procedureEnabled) then
	    ecx_debug.pop(i_method_name);
	 end if;
exception
when ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;
when others then
        if(l_statementEnabled) then
            ecx_debug.log(l_statement,SQLERRM,i_method_name);
	end if;
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end popall;

procedure start_level(
   p_node_pos       IN      Varchar2) IS

   i_method_name   varchar2(2000) := 'ecx_inbound.start_level';

   l_match          Boolean := false;
   i                pls_integer;

BEGIN

   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
      ecx_debug.log(l_statement,'p_node_pos', p_node_pos,i_method_name);
   end if;

   if (p_node_pos >= 0)
   then
      if (ecx_utils.g_source_levels.count <> 0)
      then
         for i in ecx_utils.g_source_levels.first..ecx_utils.g_source_levels.last
         loop
               if (ecx_utils.g_source_levels(i).dtd_node_index = p_node_pos)
               then
         	   ecx_utils.g_current_level := ecx_utils.g_source_levels(i).level;
	 	   push(ecx_utils.g_source_levels(i).level);
         	   l_match := True;
         	   if(l_statementEnabled) then
                     ecx_debug.log(l_statement,'l_match', l_match,i_method_Name);
		   end if;
         	   exit;
               end if;
         end loop;
      end if;
   end if;
   ecx_utils.g_previous_level := ecx_utils.g_current_level;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION
   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN others then
      if(l_statementEnabled) then
           ecx_debug.log(l_statement, 'ECX', 'ECX_PROGRAM_ERROR',i_method_name,
	               'PROGRESS_LEVEL',
                   'ECX_INBOUND.START_LEVEL');
           ecx_debug.log(l_statement, 'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
           ecx_debug.log(l_statement, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' ECX_INBOUND.START_LEVEL',
	                 i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' ECX_INBOUND.START_LEVEL');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

END start_level;


function get_node_id (
   p_node               IN             xmldom.DOMNode,
   p_node_name          IN             Varchar2,
   p_parent_node_id     IN             pls_integer,
   p_parent_node_pos    IN             pls_integer,
   p_occur              IN             pls_integer,
   x_node_pos           OUT 	NOCOPY pls_integer,
   x_parent_id 		IN OUT 	NOCOPY pls_integer) return pls_integer IS

   i_method_name   varchar2(2000) := 'ecx_inbound.get_node_id';

   i                    pls_integer;
   l_node_id            pls_integer := -1;
   p_cond_node          Varchar2(200);
   p_cond_node_type     pls_integer;
   l_value              Varchar2(4000) := null;

   l_node_list          xmldom.DOMNodeList;
   l_text_node          xmldom.DOMNode;
   l_tmp_node           xmldom.DOMNode;
   l_element            xmldom.DOMElement;
   l_node_parent_map_id pls_integer;
   x_parent_node_map_id	pls_integer;
   i_parent_node_pos	pls_integer;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;


   if(l_statementEnabled) then
      ecx_debug.log(l_statement, 'p_node_name', p_node_name,i_method_name);
      ecx_debug.log(l_statement, 'p_parent_node_id', p_parent_node_id,i_method_name);
      ecx_debug.log(l_statement, 'p_parent_node_pos', p_parent_node_pos,i_method_name);
      ecx_debug.log(l_statement, 'p_occur', p_occur,i_method_name);
      ecx_debug.log(l_statement, 'No of Elements in Source', ecx_utils.g_source.count,i_method_name);
      ecx_debug.log(l_statement, 'parent_node_map_id', x_parent_node_map_id,i_method_name);
   end if;
   x_node_pos := -1;
   i_parent_node_pos := p_parent_node_pos;

   if (p_parent_node_id >= 0) then
	/*
	   for i in p_parent_node_pos+1..ecx_utils.g_source.count loop
	      ecx_debug.log(l_statement, 'Node ',ecx_utils.g_source(i).attribute_name) ;
	      ecx_debug.log(l_statement, 'Parent Attr', ecx_utils.g_source(i).parent_attribute_id);
	   end loop;
	*/
	   if(p_parent_node_pos < 0) then
	     i_parent_node_pos := 0;
	   end if;
	   for i in i_parent_node_pos..ecx_utils.g_source.last
	   loop
	      if (ecx_utils.g_source(i).attribute_name = p_node_name) and
		 (ecx_utils.g_source(i).parent_attribute_id = p_parent_node_id)
	      then
	--          ecx_debug.log(l_statement, 'parent_map_id',
	--			  ecx_utils.g_source(i).parent_node_map_id || ' : ' || i);
		    p_cond_node := ecx_utils.g_source(i).cond_node;
		    p_cond_node_type := ecx_utils.g_source(i).cond_node_type;
	--          l_node_parent_map_id := ecx_utils.g_source(i).parent_node_map_id;

		    if (p_cond_node is not null) then
			       if(l_statementEnabled) then
				       ecx_debug.log(l_statement, 'p_cond_node', p_cond_node,i_method_name);
				       ecx_debug.log(l_statement, 'p_cond_node_type', p_cond_node_type,i_method_name);
			       end if;
			       -- need to get the value for the condition node
			       -- only if we haven't get it.
			       if (l_value is null) then
				  l_element := xmldom.makeElement(p_node);
				  if (p_cond_node_type = 1) then
				     l_node_list := xmldom.getElementsByTagName(l_element, p_cond_node);
				     l_tmp_node := xmldom.item(l_node_list, 0);
				     l_text_node := xmldom.getFirstChild(l_tmp_node);
				     l_value := xmldom.getNodeValue(l_text_node);

				  elsif (p_cond_node_type = 2) then
				     l_value := xmldom.getAttribute(l_element, p_cond_node);
				  end if;
			       end if;

			       if(l_statementEnabled) then
				   ecx_debug.log(l_statement, 'l_value', l_value,i_method_name);
			       end if;
			       -- find the mapping that match the condition.
			       if (l_value = ecx_utils.g_source(i).cond_value) then
				/*
				  if ( x_parent_node_map_id is null) or
				     ( x_parent_node_map_id = l_node_parent_map_id ) then
				*/
				  if ( p_parent_node_id = ecx_utils.g_source(i).parent_attribute_id )
				  then
					--x_parent_node_map_id := ecx_utils.g_source(i).dtd_node_map_id;
				     x_node_pos := i;
				     l_node_id := ecx_utils.g_source(i).attribute_id;
				     exit;
				  end if;
			       end if;

		       -- there is no conditional mapping.  This is a mapping
		       -- depends on the occurrence.
		    elsif
				 /*
				  (x_parent_node_map_id is null) and
				 */
				  ((ecx_utils.g_source(i).occurrence is null) or
				  (p_occur = ecx_utils.g_source(i).occurrence)) then
				  x_node_pos := i;
				  l_node_id := ecx_utils.g_source(i).attribute_id;
				  exit;
		    elsif (l_node_id = p_parent_node_id) then
				  x_node_pos := i;
				  l_node_id := ecx_utils.g_source(i).attribute_id;
				  exit;
		    end if;
	     end if;
	   end loop;

	   if(l_statementEnabled) then
		ecx_debug.log(l_statement, 'l_node_id', l_node_id,i_method_name);
		ecx_debug.log(l_statement, 'x_node_pos', x_node_pos,i_method_name);
		ecx_debug.log(l_statement, 'x_parent_node_map_id', x_parent_node_map_id,i_method_name);
	   end if;
   end if;

  if(l_statementEnabled) then
        ecx_debug.log(l_statement, 'l_node_id', l_node_id,i_method_name);
        ecx_debug.log(l_statement, 'x_node_pos', x_node_pos,i_method_name);
        ecx_debug.log(l_statement, 'x_parent_node_map_id', x_parent_node_map_id,i_method_name);
  end if;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
   return (l_node_id);

EXCEPTION
   WHEN ecx_utils.program_exit then
        if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
        end if;
      raise;

   WHEN others then
      if(l_statementEnabled) then
           ecx_debug.log(l_statement,'ECX', 'ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                   'ECX_INBOUND.GET_NODE_ID');
           ecx_debug.log(l_statement, 'ECX', 'ECX_ERROR_MESSAGE',i_method_name, 'ERROR_MESSAGE', SQLERRM);
           ecx_debug.log(l_statement, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.GET_NODE_ID: ',
	                 i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.GET_NODE_ID: ');
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

END get_node_id;


procedure process_node (
   p_int_col_pos        IN             pls_integer,
   p_node               IN OUT  NOCOPY xmldom.DOMNode,
   p_is_attribute       IN             Boolean) IS


   i_method_name   varchar2(2000) := 'ecx_inbound.process_node';

   l_value              Varchar2(4000);
   l_cat_id             pls_integer;
   l_return_status      Varchar2(1);
   l_msg_count          pls_integer;
   l_msg_data           Varchar2(2000);
   l_text_node          xmldom.DOMNode;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if (p_is_attribute) then
      l_text_node := p_node;
   else
      l_text_node := xmldom.getFirstChild(p_node);
   end if;

   if not (xmldom.isnull(l_text_node))
   then
      l_value := xmldom.getNodeValue(l_text_node);
      if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'p_int_col_pos', p_int_col_pos,i_method_name);
         ecx_debug.log(l_statement, 'node value', l_value,i_method_name);
      end if;

      l_cat_id := ecx_utils.g_source(p_int_col_pos).xref_category_id;

      if (l_cat_id is not null) then
         ecx_code_conversion_pvt.convert_external_value
	  (
	  p_api_version_number => 1.0,
  	  p_return_status      => l_return_status,
	  p_msg_count          => l_msg_count,
	  p_msg_data           => l_msg_data,
	  p_value              => l_value,
       	  p_category_id        => l_cat_id,
      	  p_snd_tp_id          => ecx_utils.g_snd_tp_id,
      	  p_rec_tp_id          => ecx_utils.g_rec_tp_id ,
	  p_standard_id       => ecx_utils.g_standard_id
       	  );

         If l_return_status = 'X' OR l_return_status = 'R' Then
            ecx_utils.g_source(p_int_col_pos).xref_retcode := 1;
         else
            ecx_utils.g_source(p_int_col_pos).xref_retcode := 0;
         end if;

         if(l_statementEnabled) then
               ecx_debug.log(l_statement, 'xref return code',
                       ecx_utils.g_source(p_int_col_pos).xref_retcode,i_method_name);
         end if;

         if (l_return_status = ecx_code_conversion_pvt.G_RET_STS_ERROR) or
            (l_return_status = ecx_code_conversion_pvt.G_RET_STS_UNEXP_ERROR) or
            (l_return_status = ECX_CODE_CONVERSION_PVT.g_xref_not_found) then
            if(l_statementEnabled) then
                ecx_debug.log(l_statement, 'Code Conversion uses the original code.',i_method_name);
            end if;
         else
            if (l_return_status = ECX_CODE_CONVERSION_PVT.g_recv_xref_not_found) then
               if(l_statementEnabled) then
                 ecx_debug.log(l_statement, 'Code Conversion uses the sender converted value', l_value,i_method_name);
	       end if;
            end if;

            -- only update the dom if there is code conversion.
            -- this is only useful for passthrough document and
            -- we only transmit what we receive plus the code conversion
            -- if it is a pass through document.

            if(l_statementEnabled) then
                ecx_debug.log(l_statement, 'node value', l_value,i_method_name);
            end if;
            -- update the DOM only if the valus is not null
            if (l_value is not null) then
               xmldom.setNodeValue (l_text_node, l_value);
            end if;
         end if;
      end if;

      ecx_utils.g_source(p_int_col_pos).value := l_value;

      if(l_statementEnabled) then
          ecx_debug.log(l_statement,ecx_utils.g_source(p_int_col_pos).attribute_name ,
   		ecx_utils.g_source(p_int_col_pos).value||' '||
   		ecx_utils.g_source(p_int_col_pos).base_column_name||' '||' '||
		p_int_col_pos,i_method_name);
      end if;
   end if;
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN value_error then
      ecx_debug.setErrorInfo(2, 30, 'ECX_INVALID_VARCHAR2_LEN');
      if(l_statementEnabled) then
         ecx_debug.log(l_statement, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
   WHEN no_data_found then
	if(l_statementEnabled) then
            ecx_debug.log(l_statement,'Internal Column Position and Level not mapped for',p_int_col_pos,
	                 i_method_name);
	end if;
   	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
        raise ecx_utils.program_exit;
   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise;
   WHEN others then
      if(l_statementEnabled) then
          ecx_debug.log(l_statement, 'ECX', 'ECX_PROGRAM_ERROR', i_method_name,
	               'PROGRESS_LEVEL',
                   'ECX_INBOUND.PROCESS_NODE');
	  ecx_debug.log(l_statement, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.PROCESS_NODE: ',
	                i_method_name);
     end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.PROCESS_NODE: ');

      if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

END process_node;


procedure process_attributes (
   p_node               IN OUT  NOCOPY xmldom.DOMNode,
   p_node_id            IN             pls_integer,
   p_occur              IN             pls_integer,
   p_node_pos           IN             pls_integer,
   x_parent_node_map_id IN OUT  NOCOPY pls_integer) IS


   i_method_name   varchar2(2000) := 'ecx_inbound.process_attributes';

   l_attr_node_name     Varchar2(80);
   l_attr_nodemap       xmldom.DOMNamedNodeMap;
   l_num_of_attr        pls_integer;
   l_attr_node_id       pls_integer;
   l_int_col_pos        pls_integer;
   l_attr_node          xmldom.DOMNode;
   l_attr_node_pos      pls_integer;
   i                    pls_integer := 1;

BEGIN

   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
       ecx_debug.log(l_statement, 'p_node_id', p_node_id,i_method_name);
       ecx_debug.log(l_statement, 'p_occur', p_occur,i_method_name);
       ecx_debug.log(l_statement, 'p_node_pos', p_node_pos,i_method_name);
       ecx_debug.log(l_statement, 'x_parent_node_map_id', x_parent_node_map_id,i_method_name);
   end if;
   l_attr_nodemap := xmldom.getAttributes(p_node);

   l_num_of_attr := xmldom.getLength(l_attr_nodemap);
   if(l_statementEnabled) then
       ecx_debug.log(l_statement,'num_of_attributes', l_num_of_attr,i_method_name);
   end if;

   while (i <= l_num_of_attr) loop
      if(l_statementEnabled) then
       ecx_debug.log(l_statement, 'i', i,i_method_name);
      end if;
      l_int_col_pos := 0;
      l_attr_node := xmldom.item(l_attr_nodemap, i-1);
      l_attr_node_name := xmldom.getNodeName(l_attr_node);
      if(l_statementEnabled) then
       ecx_debug.log(l_statement, 'l_attr_node_name', l_attr_node_name,i_method_name);
      end if;

      l_attr_node_id := get_node_id (l_attr_node, l_attr_node_name,
                                     p_node_id, p_node_pos, p_occur,
                                     l_attr_node_pos, x_parent_node_map_id);
         if(l_statementEnabled) then
           ecx_debug.log(l_statement,  'l_attr_node_id', l_attr_node_id,i_method_name);
	 end if;

      -- if we find a mapping for the attribute node, then
      -- we assign the value
      if (l_attr_node_id > 0)
      then
         process_node (l_attr_node_id, l_attr_node, True);
      end if;
      i := i+1;
   end loop;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;


EXCEPTION
   WHEN ecx_utils.program_exit then
     if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
     end if;
      raise;

   WHEN others then
      if(l_statementEnabled) then
       ecx_debug.log(l_statement,'ECX', 'ECX_PROGRAM_ERROR', i_method_name,'PROGRESS_LEVEL',
                   'ECX_INBOUND.PROCESS_ATTRIBUTES');
      ecx_debug.log(l_statement, 'ECX', 'ECX_ERROR_MESSAGE',  i_method_name,'ERROR_MESSAGE', SQLERRM);
      ecx_debug.log(l_statement, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.PROCESS_ATTRIBUTES: ',
                    i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.PROCESS_ATTRIBUTES: ');
      if (l_procedureEnabled) then
             ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

END process_attributes;


procedure get_root_info (
   p_doc               IN           xmldom.DOMDocument,
   p_map_id            IN           pls_integer,
   x_root_node_id      OUT   NOCOPY pls_integer,
   x_root_node      OUT   NOCOPY xmldom.DOMNode) IS

   i_method_name   varchar2(2000) := 'ecx_inbound.get_root_info';

   cursor get_root_elmt (
          p_map_id    IN  pls_integer) IS
   select eo.root_element,
          0
   from   ecx_mappings em,
          ecx_objects eo
   where  em.map_id = p_map_id
   and    em.map_id = eo.map_id
   and    em.object_id_source = eo.object_id;

   l_root_elmt_name     Varchar2(80);
   l_node_list          xmldom.DOMNodeList;
   l_root_node          xmldom.DOMNode;
   no_map_root          EXCEPTION;

BEGIN
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   -- get the root node.
   open get_root_elmt (p_map_id);
   fetch get_root_elmt into l_root_elmt_name, x_root_node_id;
   if(l_statementEnabled) then
      ecx_debug.log(l_statement,'root_element',l_root_elmt_name,i_method_name);
   end if;

   if get_root_elmt%NOTFOUND then
      raise no_map_root;
   else
      close get_root_elmt;
   end if;

   l_node_list := xmldom.getElementsByTagName (p_doc, l_root_elmt_name);
   x_root_node := xmldom.item (l_node_list, 0);
  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;


EXCEPTION
   WHEN no_map_root then
      ecx_debug.setErrorInfo(1, 30, 'ECX_ROOT_INFO_NOT_FOUND');
      if(l_statementEnabled) then
       ecx_debug.log(l_statement, 'ECX', 'ECX_ROOT_INFO_NOT_FOUND', i_method_name);
      end if;
      close get_root_elmt;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN OTHERS THEN
      if(l_statementEnabled) then
          ecx_debug.log(l_statement, 'ECX', 'ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                     'ECX_INBOUND.GET_ROOT_INFO');
          ecx_debug.log(l_statement, 'ECX', 'ECX_ERROR_MESSAGE',i_method_name ,'ERROR_MESSAGE', SQLERRM);
          ecx_debug.log(l_statement, 'ECX', ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.GET_ROOT_INFO: ',i_method_name);
      end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM || ' - ECX_INBOUND.GET_ROOT_INFO: ');
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
END get_root_info;


/**
 Does the initial setup for structure transformation
**/
procedure structurePrintingSetup
	(
	i_root_name  	IN OUT	NOCOPY varchar2
	)
is

i_method_name   varchar2(2000) := 'ecx_inbound.structurePrintingSetup';

i_filename  	varchar2(200);

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   begin
      SELECT  root_element,
              fullpath
      INTO    i_root_name,
              i_filename
      FROM    ecx_objects eo
      WHERE   eo.map_id = ecx_utils.g_map_id
      AND     eo.object_type in ('DTD','XML')
      AND     eo.object_id = 2;
   exception
   when others then
      ecx_debug.setErrorInfo(2, 30, 'ECX_ROOT_ELEMENT_NOT_FOUND', 'MAP_ID', ecx_utils.g_map_id);
      if(l_statementEnabled) then
          ecx_debug.log(l_statement,'ECX', 'ECX_ROOT_ELEMENT_NOT_FOUND',i_method_name, 'MAP_ID', ecx_utils.g_map_id);
      end if;
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
   end;

   -- initialize the temporary buffers
   ecx_print_local.i_tmpxml.DELETE;
   ecx_print_local.l_node_stack.DELETE;

   -- PI Node
   ecx_print_local.pi_node ('xml', 'version = "1.0" standalone="no" ');

   -- comment node
   ecx_print_local.comment_node('Oracle eXtensible Markup Language Gateway Server');

   -- document node
   ecx_print_local.document_node(i_root_name, i_filename, null);

   if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
   end if;
end structurePrintingSetup;

/**
  Reads the elements from the i_tmpxml stack and writes them
  to a CLOB.
**/
procedure getXMLDoc

is

i_method_name   varchar2(2000) := 'ecx_inbound.getXMLDoc';
i_writeamount		number;
i_temp			varchar2(32767);
apnd_status		Boolean := FALSE;
i_xmlDOc		CLOB;
begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   -- write the xml from the printing program to a CLOB
   dbms_lob.createtemporary(i_xmldoc, TRUE,DBMS_LOB.SESSION);

   i_writeamount := 0;
   i_temp := '';

   for i in 1..ecx_print_local.i_tmpxml.COUNT
   loop
      -- check for the element length
      i_writeamount := length(ecx_print_local.i_tmpxml(i));
      -- set append status to true
      apnd_status := true;
      -- check if temp buffer is full
      if (i_writeamount + length(i_temp) > 32000) then
         if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Buffer Length', to_char(length(i_temp)),i_method_name);
	 end if;
         dbms_lob.writeappend(i_xmldoc,length(i_temp), i_temp);
	 if(l_statementEnabled) then
           ecx_debug.log(l_statement, i_temp,i_method_name);
	 end if;
         apnd_status := false;
         i_temp := '';
         i_temp := ecx_print_local.i_tmpxml(i);
      else
         -- add new entry
         i_temp := i_temp || ecx_print_local.i_tmpxml(i);
      end if;
   end loop;

   -- check if last append is needed
   if (apnd_status) then
      dbms_lob.writeappend(i_xmldoc, length(i_temp), i_temp);
      if(l_statementEnabled) then
          ecx_debug.log(l_statement, i_temp,i_method_name);
      end if;
   end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'inbound clob before parsing',dbms_lob.getLength(i_xmldoc),i_method_name);
  ecx_debug.log(l_statement,'Clob Data is ', i_xmldoc,i_method_name);
   end if;

   -- Parser from the CLOB
   xmlparser.parseCLOB(ecx_utils.g_inb_parser, i_xmldoc);
   ecx_utils.g_xmldoc := xmlDOM.makeNode(xmlparser.getDocument(ecx_utils.g_inb_parser));
   dbms_lob.trim(i_xmldoc, 0);
   xmlDOM.writetoCLOB(ecx_utils.g_xmldoc,i_xmldoc);
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'inbound clob after parsing',dbms_lob.getLength(i_xmldoc),i_method_name);
  ecx_debug.log(l_statement,'Clob Data is ',i_xmldoc,i_method_name);
end if;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

end getXMLDoc;


/**
 ** This procedure is traversing the XML Document tree and
 ** put the value into the ecx_utils.g_file_tbl.
 ** First, it tries to see the tag name match one of the mapped
 ** level start element.
 **    If it doesn't match, then go on to its children.
 **    If it match, then
 **       -- clean up the g_file_tbl from current matched
 **          level to all levels below.
 **       -- assign value from DOM tree to g_file_tbl.
 **       -- call inbound engine when get the next match tag.
 ** For the last level of data, this will never get processed by inbound
 ** engine since it never gets the next match tag.
 ** So, this procedure needs to process the last level at the end.
 **/

procedure process_xml_doc (
   p_doc                   IN      xmldom.DOMDocument,
   p_map_id                IN      pls_integer,
   p_snd_tp_id             IN      pls_integer,
   p_rec_tp_id             IN      pls_integer,
   x_xmlclob               OUT NOCOPY clob,
   x_parseXML              OUT NOCOPY boolean
   ) is

i_method_name   varchar2(2000) := 'ecx_inbound.process_xml_doc';

   l_root_node	        xmldom.DOMNode;
   l_root_element       xmldom.DOMElement;
   l_node_list          xmldom.DOMNodeList;
   l_num_of_nodes       pls_integer;
   node_info_stack      node_info_tbl;
   l_node               xmldom.DOMNode;
   l_node_name          Varchar2(200);
   l_parent_node_map_id pls_integer ;
   l_node_id            pls_integer := -1;
   l_node_pos           pls_integer;
   l_col_pos            pls_integer;
   l_children           xmldom.DOMNodeList;
   l_num_of_child       pls_integer;
   l_tmp_num_child      pls_integer;
   l_child              xmldom.DOMNode;
   l_child_node_type    pls_integer;
   l_stack_indx         pls_integer := 1;
   l_next_pos           pls_integer;
   l_attributes         xmldom.DOMNamedNodeMap;
   l_num_of_attr        pls_integer;
   i                    pls_integer;
   i_root_name		varchar2(200);

BEGIN
    if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'p_map_id', p_map_id,i_method_name);
     ecx_debug.log(l_statement, 'p_snd_tp_id', p_snd_tp_id,i_method_name);
     ecx_debug.log(l_statement, 'p_rec_tp_id', p_rec_tp_id,i_method_name);
  end if;
   ecx_utils.g_snd_tp_id := p_snd_tp_id;
   ecx_utils.g_rec_tp_id := p_rec_tp_id;
   ecx_utils.g_previous_level := 0;
   /** Initialize the Stack for the Levels **/
   i_stack.DELETE;
   i_current_depth :=0;

   -- Execute the Stage 10 for Level 0

   -- In-processing for Document level Source Side
   ecx_actions.execute_stage_data(20,0,'S');

   -- In-processing for Document level
   ecx_actions.execute_stage_data(20,0,'T');

   get_root_info (p_doc, p_map_id, node_info_stack(l_stack_indx).parent_node_id,
                  l_root_node);
   l_root_element := xmldom.makeElement(l_root_node);
   -- if necessary initialize the printing
   if (not (ecx_utils.dom_printing) AND (ecx_utils.structure_printing))
   then
      structurePrintingSetup(i_root_name);
   end if;

   if (node_info_stack(l_stack_indx).parent_node_id is null or
       node_info_stack(l_stack_indx).parent_node_id = 0) then
      l_next_pos := 0;
   else
      l_next_pos := ecx_utils.g_source_levels(1).dtd_node_index - 2;
   end if;

   node_info_stack(l_stack_indx).occur := 1;
--   node_info_stack(l_stack_indx).parent_node_map_id := null;
   node_info_stack(l_stack_indx).pre_child_name := null;
   node_info_stack(l_stack_indx).siblings := 0;

   /* Start of changes for  Bug 4587719. Processing for the root node sepeartely */
     l_node := l_root_node;
  l_node_name := xmldom.getNodeName(l_node);

      if(l_statementEnabled) then
       ecx_debug.log(l_statement,'l_node_name', l_node_name,i_method_name);
       ecx_debug.log(l_statement, 'l_stack_indx', l_stack_indx,i_method_name);
       ecx_debug.log(l_statement, 'pre_child_name', node_info_stack(l_stack_indx).pre_child_name,i_method_name);
     end if;
      node_info_stack(l_stack_indx).parent_node_pos := l_next_pos;
      node_info_stack(l_stack_indx).pre_child_name := l_node_name;

      if(l_statementEnabled) then
		 ecx_debug.log(l_statement, 'Stack(l_stack_indx)', node_info_stack(l_stack_indx).parent_node_id||
    '-'|| node_info_stack(l_stack_indx).parent_node_pos||'-'|| node_info_stack(l_stack_indx).pre_child_name
    ||'-'|| node_info_stack(l_stack_indx).siblings||'-'|| node_info_stack(1).occur, i_method_name);
      end if;

      l_node_id := get_node_id (l_node, l_node_name,
                                node_info_stack(l_stack_indx).parent_node_id,
                                node_info_stack(l_stack_indx).parent_node_pos,
                                node_info_stack(l_stack_indx).occur,
                                l_node_pos,
                                l_parent_node_map_id);
      if(l_statementEnabled) then
       ecx_debug.log(l_statement,'l_node_id', l_node_id,i_method_name);
      end if;

      start_level(l_node_pos);
      l_num_of_child := 0;

       if (ecx_utils.dom_printing)
         then
            -- store the reference to the Node objects that are mapped so that they can
            -- be retrieved later when updating the DOM
            if (ecx_utils.g_source(l_node_id).map_attribute_id is not null)
            then
               ecx_utils.g_node_tbl(l_node_id) := l_node;
               if(l_statementEnabled) then
                 ecx_debug.log(l_statement, 'put on xml node stack', l_node_id,i_method_name);
	       end if;
            end if;
         end if;

         if (ecx_utils.g_source(l_node_pos).has_attributes >0 )
	 then
            process_attributes (l_node, l_node_id,
                               node_info_stack(l_stack_indx).occur, l_node_pos,
                               l_parent_node_map_id);
         end if;

            if(l_statementEnabled) then
              ecx_debug.log(l_statement,'Getting Child Nodes for :',xmldom.getNodeName(l_node),i_method_name);
	    end if;
            l_children := xmldom.getChildNodes(l_node);
            l_num_of_child := xmldom.getLength (l_children);
            l_tmp_num_child := l_num_of_child;
            for i in 0..l_tmp_num_child - 1 loop
              l_child := xmldom.item (l_children, i);
              l_child_node_type := xmldom.getNodeType(l_child);
              if (l_child_node_type <> 1 and l_child_node_type <> 2) then
                l_num_of_child := l_num_of_child - 1;
              end if;
            end loop;
            if(l_statementEnabled) then
              ecx_debug.log(l_statement, 'num of child', l_num_of_child,i_method_name);
	    end if;
         --else
--            l_col_pos := ecx_utils.g_target(l_node_pos).map_attribute_id;
            if (l_node_pos is not null) then
               process_node (l_node_pos, l_node, False);
            end if;
         --end if;


      if(l_statementEnabled) then
       ecx_debug.log(l_statement,'num of siblings: ', node_info_stack(l_stack_indx).siblings,i_method_name);
      end if;
      if (l_num_of_child = 0) then
               l_stack_indx := l_stack_indx -1;
       else
         l_stack_indx := l_stack_indx + 1;
         node_info_stack(l_stack_indx).parent_node_id := l_node_id;
         l_next_pos := l_node_pos;
         node_info_stack(l_stack_indx).occur := 1;
         node_info_stack(l_stack_indx).siblings := l_num_of_child - 1;
--         node_info_stack(l_stack_indx).parent_node_map_id := l_parent_node_map_id;
      end if;

/* End of changes for  Bug 4587719. Processing for the root node sepeartely */

   l_node_list := xmldom.getElementsByTagName (l_root_element, '*');
   l_num_of_nodes := xmldom.getLength (l_node_list);

   for i in 0..l_num_of_nodes-1 loop
      l_node := xmldom.item(l_node_list, i);
      l_node_name := xmldom.getNodeName(l_node);

      if(l_statementEnabled) then
       ecx_debug.log(l_statement,'l_node_name', l_node_name,i_method_name);
       ecx_debug.log(l_statement, 'l_stack_indx', l_stack_indx,i_method_name);
       ecx_debug.log(l_statement, 'pre_child_name', node_info_stack(l_stack_indx).pre_child_name,i_method_name);
     end if;

      if (l_node_name = node_info_stack(l_stack_indx).pre_child_name) then
         node_info_stack(l_stack_indx).occur := node_info_stack(l_stack_indx).occur + 1;
      elsif (l_next_pos is not null) then
         node_info_stack(l_stack_indx).parent_node_pos := l_next_pos;
      end if;

      node_info_stack(l_stack_indx).pre_child_name := l_node_name;

      if(l_statementEnabled) then
		for i in node_info_stack.first..node_info_stack.last
		loop
			ecx_debug.log(l_statement, 'Stack('||i||')', node_info_stack(i).parent_node_id||'-'|| node_info_stack(i).parent_node_pos||'-'|| node_info_stack(i).pre_child_name||'-'|| node_info_stack(i).siblings||'-'|| node_info_stack(i).occur, i_method_name);
		end loop;
      end if;

      l_node_id := get_node_id (l_node, l_node_name,
                                node_info_stack(l_stack_indx).parent_node_id,
                                node_info_stack(l_stack_indx).parent_node_pos,
                                node_info_stack(l_stack_indx).occur,
                                l_node_pos,
                                l_parent_node_map_id);
      if(l_statementEnabled) then
       ecx_debug.log(l_statement,'l_node_id', l_node_id,i_method_name);
      end if;

      start_level(l_node_pos);
      l_num_of_child := 0;

      if (l_node_id >= 0) then
         if (ecx_utils.dom_printing)
         then
            -- store the reference to the Node objects that are mapped so that they can
            -- be retrieved later when updating the DOM
            if (ecx_utils.g_source(l_node_id).map_attribute_id is not null)
            then
               ecx_utils.g_node_tbl(l_node_id) := l_node;
               if(l_statementEnabled) then
                 ecx_debug.log(l_statement, 'put on xml node stack', l_node_id,i_method_name);
	       end if;
            end if;
         end if;

         if (ecx_utils.g_source(l_node_pos).has_attributes >0 )
	 then
            process_attributes (l_node, l_node_id,
                               node_info_stack(l_stack_indx).occur, l_node_pos,
                               l_parent_node_map_id);
         end if;

         --if (ecx_utils.g_source(l_node_pos).leaf_node = 0) then
            if(l_statementEnabled) then
              ecx_debug.log(l_statement,'Getting Child Nodes for :',xmldom.getNodeName(l_node),i_method_name);
	    end if;
            l_children := xmldom.getChildNodes(l_node);
            l_num_of_child := xmldom.getLength (l_children);
            l_tmp_num_child := l_num_of_child;
            for i in 0..l_tmp_num_child - 1 loop
              l_child := xmldom.item (l_children, i);
              l_child_node_type := xmldom.getNodeType(l_child);
              if (l_child_node_type <> 1 and l_child_node_type <> 2) then
                l_num_of_child := l_num_of_child - 1;
              end if;
            end loop;
            if(l_statementEnabled) then
              ecx_debug.log(l_statement, 'num of child', l_num_of_child,i_method_name);
	    end if;
         --else
--            l_col_pos := ecx_utils.g_target(l_node_pos).map_attribute_id;
            if (l_node_pos is not null) then
               process_node (l_node_pos, l_node, False);
            end if;
         --end if;
      else
         l_children := xmldom.getChildNodes(l_node);
         l_num_of_child := xmldom.getLength (l_children);
         l_tmp_num_child := l_num_of_child;
         if(l_statementEnabled) then
           ecx_debug.log(l_statement, 'num of child', l_num_of_child,i_method_name);
	 end if;
/*
         if (l_num_of_child = 1) then
            l_child := xmldom.item (l_children, 0);
            l_child_node_type := xmldom.getNodeType(l_child);
            if (l_child_node_type = 3) then
               l_num_of_child := 0;
            end if;
         end if;
*/
         for i in 0..l_tmp_num_child - 1 loop
            l_child := xmldom.item (l_children, i);
            l_child_node_type := xmldom.getNodeType(l_child);
           if (l_child_node_type <> 1 and l_child_node_type <> 2) then
             l_num_of_child := l_num_of_child - 1;
            end if;
         end loop;
      end if;

      if(l_statementEnabled) then
       ecx_debug.log(l_statement,'num of siblings: ', node_info_stack(l_stack_indx).siblings,i_method_name);
      end if;
      if (l_num_of_child = 0) then

         loop
--            l_parent_node_map_id := node_info_stack(l_stack_indx).parent_node_map_id;
            if (node_info_stack(l_stack_indx).siblings > 0) then
               node_info_stack(l_stack_indx).siblings :=
                   node_info_stack(l_stack_indx).siblings -1;
                   exit;
            else
               l_stack_indx := l_stack_indx -1;
               if (l_stack_indx = 0) then
                  exit;
               end if;
--               l_parent_node_map_id := node_info_stack(l_stack_indx).parent_node_map_id;
            end if;
         end loop;
      else
         l_stack_indx := l_stack_indx + 1;
         node_info_stack(l_stack_indx).parent_node_id := l_node_id;
         l_next_pos := l_node_pos;
         node_info_stack(l_stack_indx).occur := 1;
         node_info_stack(l_stack_indx).siblings := l_num_of_child - 1;
--         node_info_stack(l_stack_indx).parent_node_map_id := l_parent_node_map_id;
      end if;

   end loop;

   popall;

   if (ecx_utils.structure_printing)
   then
       ecx_print_local.xmlPopall(i_xmlclob);
       ecx_util_api.parseXML(ecx_utils.g_inb_parser,
                             x_xmlclob, x_parseXML, ecx_utils.g_xmldoc);
   else
      ecx_utils.g_xmldoc := xmlDom.makeNode(p_doc);
   end if;
  -- At this point g_xmldoc should have the correct dcument

   -- Execute the Stage 30 for Level 0
   -- Post-Processing for Target
   ecx_actions.execute_stage_data(30,0,'T');
   -- Post-Processing for Source
   ecx_actions.execute_stage_data(30,0,'S');

   ecx_utils.g_total_records := ecx_utils.g_total_records + 1;
   if(l_statementEnabled) then
       ecx_debug.log(l_statement,'Total record processed', ecx_utils.g_total_records,i_method_name);
   end if;

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;


EXCEPTION
   WHEN ecx_utils.program_exit then
      if(l_statementEnabled) then
         ecx_debug.log(l_statement, 'Clean-up i_stack, l_node_stack and i_tmpxml',i_method_name);
      end if;
      i_stack.DELETE;
      ecx_print_local.i_tmpxml.DELETE;
      ecx_print_local.l_node_stack.DELETE;
      ecx_utils.g_node_tbl.DELETE;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise;

   WHEN OTHERS THEN
      if(l_statementEnabled) then
        ecx_debug.log(l_statement, 'ECX', 'ECX_PROGRAM_ERROR',i_method_Name,'PROGRESS_LEVEL',
                     'ECX_INBOUND.PROCESS_XML_DOC');
        ecx_debug.log(l_statement, 'ECX', 'ECX_ERROR_MESSAGE', i_method_name,'ERROR_MESSAGE', SQLERRM);
	ecx_debug.log(l_statement, 'Clean-up i_stack, l_node_stack and i_tmpxml', i_method_name);
	ecx_debug.log(l_statement, 'ECX', ecx_utils.i_errbuf || SQLERRM ||
                   ' - ECX_INBOUND.PROCESS_XML_DOC: ', i_method_name);
     end if;
      ecx_debug.setErrorInfo(2, 30, ecx_utils.i_errbuf || SQLERRM ||
                             ' - ECX_INBOUND.PROCESS_XML_DOC: ');

      i_stack.DELETE;
      ecx_print_local.i_tmpxml.DELETE;
      ecx_print_local.l_node_stack.DELETE;
      ecx_utils.g_node_tbl.DELETE;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

END process_xml_doc;

END ecx_inbound;

/
