--------------------------------------------------------
--  DDL for Package Body ECX_INBOUND_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_INBOUND_NEW" as
--$Header: ECXINNB.pls 120.2.12000000.5 2007/07/11 12:20:19 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;
p_current_element_pos PLS_INTEGER:=-1;

TYPE attribute_rec is RECORD
(
   attribute_name     varchar2(256),
   element_tag_name   varchar2(256),
   value              varchar2(4000)
);

TYPE attr_tbl is TABLE of attribute_rec index by BINARY_INTEGER;
-- Define the local variable for storing the attributes with the values **/
l_attr_rec      attr_tbl;

TYPE l_stack is table of pls_integer index by binary_integer;

l_docLogsAttrSet   boolean;
l_level_stack      l_stack;
l_next_pos         pls_integer;
node_info_stack    node_info_table;
Load_XML_Exception Exception;

procedure clean_up_tables is
i_method_name   varchar2(2000) := 'ecx_inbound_new.clean_up_tables';

begin
   l_level_stack.DELETE;
   ecx_print_local.i_tmpxml.DELETE;
   ecx_print_local.l_node_stack.DELETE;
   ecx_utils.g_node_tbl.DELETE;

exception
   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.CLEAN_UP_TABLES');
      if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;
end clean_up_tables;


procedure get_element_value (
   p_nodeList       IN         ECX_NODE_TBL_TYPE,
   p_count          IN         pls_integer,
   p_elem_name      IN         varchar2,
   x_found          OUT NOCOPY boolean,
   x_elem_value     OUT NOCOPY varchar2
   ) is

i_method_name   varchar2(2000) := 'ecx_inbound_new.get_element_value';
begin
   x_found := false;
   x_elem_value := null;

   for i in 1..p_count loop
      if (p_nodeList(i).name = p_elem_name) then
         x_elem_value := p_nodeList(i).value;
         x_found := true;
         exit;
      end if;

   end loop;

exception
   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.GET_ELEMENT_VALUE');
       if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;
end get_element_value;


function setDocLogsAttributes (
   p_nodeList       IN    ECX_NODE_TBL_TYPE,
   p_count          IN    pls_integer
   ) return boolean is

   i_method_name   varchar2(2000) := 'ecx_inbound_new.setDocLogsAttributes';
   cursor  get_attributes
   (
      p_standard_id  IN   pls_integer
   )
   is
   select  attribute_name,
           element_tag_name
   from    ecx_standard_attributes esa,
           ecx_standards es
   where   es.standard_id = p_standard_id
   and     esa.standard_id = es.standard_id;

   i_string  varchar2(2000) := ' update ecx_doclogs set ';
   i_found   boolean;
   i_update  boolean;
   i_value   varchar2(4000);
   i_single  varchar2(3):= '''';
begin

   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   i_found := false;
   i_update := false;

   if ecx_utils.g_standard_id is null
   then
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      return true;
   end if;

   /** Get all the Attributes and capture the value **/
   for c1 in get_Attributes(p_standard_id => ecx_utils.g_standard_id)
   loop
      if (c1.attribute_name is not null and c1.element_tag_name is not null) then
          get_element_value (p_nodeList, p_count, c1.element_tag_name, i_found, i_value);

          if (i_found) then
             i_update := true;
             l_attr_rec(l_attr_rec.COUNT + 1).attribute_name := c1.attribute_name;
             l_attr_rec(l_attr_rec.COUNT).element_tag_name := c1.element_tag_name;
             l_attr_rec(l_attr_rec.COUNT).value := i_value;

             -- Search for the attribute in the XML File
             if(l_statementEnabled) then
               ecx_debug.log(l_statement,l_attr_rec(l_attr_rec.COUNT).attribute_name,
                             l_attr_rec(l_attr_rec.COUNT).value,i_method_name);
             end if;
             i_string := i_string ||' '||l_attr_rec(l_attr_rec.COUNT).attribute_name ||
                         ' = '|| i_single||l_attr_rec(l_attr_rec.COUNT).value || i_single||' ,';
         end if;
      end if;
   end loop;

   if i_update
   then
      /** remove the last , and put the statement for the where clause **/
      i_string := substr(i_string,1,length(i_string)-1);
      i_string := i_string || ' where msgid = HEXTORAW('||i_single||ecx_utils.g_msgid||i_single||')';
      if(l_statementEnabled) then
            ecx_debug.log(l_statement,'i_string',i_string,i_method_name);
      end if;
      execute immediate i_string;
   end if;
   if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
   end if;

   return i_update;

exception
   WHEN ecx_utils.program_exit then
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.setDocLogsAttributes');
      if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end setDocLogsAttributes;


procedure print_stack is
i_method_name   varchar2(2000) := 'ecx_inbound_new.print_stack';
begin
   if(l_statementEnabled) then
       ecx_debug.log(l_statement,'Level Stack Status','====',i_method_name);
   end if;
   for i in 1..l_level_stack.COUNT
   loop
       if(l_statementEnabled) then
        ecx_debug.log(l_statement,l_level_stack(i),i_method_name);
       end if;
   end loop;
exception
   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.PRINT_STACK');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;
end print_stack;


procedure popStack
   (
   p_level  in  pls_integer
   ) is
i_method_name   varchar2(2000) := 'ecx_inbound_new.popstack';

begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
	ecx_debug.log(l_statement,'p_level', p_level,i_method_name);
	print_stack;
   end if;

   if l_level_stack.COUNT = 0
   then
      if(l_statementEnabled) then
        ecx_debug.log(l_statement,'Stack Error. Nothing to pop','xxxxx',i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      return;
   end if;

   --Post Process and then pop.
   ecx_inbound.process_data(l_level_stack(l_level_stack.COUNT), 30, p_level);

   l_level_stack.DELETE(l_level_stack.COUNT);

   if(l_statementEnabled) then
	print_stack;
   end if;

    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;

exception
   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.popStack');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end popStack;


procedure pushStack
   (
   i  in   pls_integer
   ) is
i_method_name   varchar2(2000) := 'ecx_inbound_new.pushstack';
begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
      ecx_debug.log(l_statement,i,i_method_name);
      print_stack;
   end if;

   if (l_level_stack.COUNT = 0) or
      (i > l_level_stack(l_level_stack.COUNT)) then
      l_level_stack(l_level_stack.COUNT+1) := i;

      if(l_statementEnabled) then
	print_stack;
      end if;

      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      return;
   end if;

   if (i = l_level_stack(l_level_stack.COUNT)) then
      popStack(i);
      l_level_stack(l_level_stack.COUNT+1) := i;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      return;
   end if;

   if (l_level_stack.COUNT <> 0) then
      while (i <= l_level_stack(l_level_stack.COUNT)) loop
         popStack(i);
         exit when l_level_stack.COUNT = 0;
      end loop;
   end if;

   -- Push the value
   l_level_stack(l_level_stack.COUNT+1):=i;

   if(l_statementEnabled) then
	print_stack;
   end if;

   if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
   end if;

exception
   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.pushStack');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end pushStack;


procedure popall is
i_method_name   varchar2(2000) := 'ecx_inbound_new.popall';
begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

   if(l_statementEnabled) then
	print_stack;
   end if;

   while ( l_level_stack.COUNT > 0)
   loop
       popStack(0);
   end loop;

   if(l_statementEnabled) then
	print_stack;
   end if;

   if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
   end if;
exception
   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.popall');
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end popall;


procedure get_cond_node_value(
   p_nodeList           IN         ECX_NODE_TBL_TYPE,
   p_nodeStartIndex     IN         pls_integer,
   p_node_name          IN         Varchar2,
   p_xmlParentIndex     IN         pls_integer,
   x_node_value         OUT NOCOPY Varchar2
   ) is
i_method_name   varchar2(2000) := 'ecx_inbound_new.get_cond_node_value';
begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   x_node_value := null;

   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'p_nodeStartIndex', p_nodeStartIndex,i_method_name);
     ecx_debug.log(l_statement, 'p_xmlParentIndex', p_xmlParentIndex,i_method_name);
   end if;

   for i in p_nodeStartIndex+1..p_nodeList.COUNT loop
      if (p_nodeList(i).parentIndex > p_xmlParentIndex) then
         if (p_nodeList(i).name = p_node_name) then
            x_node_value := p_nodeList(i).value;
            if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'value', p_nodeList(i).value,i_method_name);
            end if;
            exit;
         end if;
      else
         exit;
      end if;
   end loop;

  if(l_statementEnabled) then
     ecx_debug.log(l_statement, 'cond node value', x_node_value,i_method_name);
  end if;
  if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
  end if;

exception
   WHEN ecx_utils.program_exit then
     if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
     end if;
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.GET_COND_NODE_VALUE');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end get_cond_node_value;


function get_node_id (
   p_nodeList           IN         ECX_NODE_TBL_TYPE,
   p_nodeListIndex      IN         pls_integer,
   p_xmlParentNodeIndex IN         pls_integer,
   p_node_name          IN         Varchar2,
   p_parent_node_id     IN         pls_integer,
   p_parent_node_pos    IN         pls_integer,
   p_occur              IN         pls_integer,
   p_node_value         IN         varchar2,
   x_node_pos           OUT NOCOPY pls_integer
   ) return pls_integer IS

   i_method_name   varchar2(2000) := 'ecx_inbound_new.get_node_id';

   i                    pls_integer;
   l_node_id            pls_integer := -1;
   l_cond_node_value    Varchar2(4000) := null;
   p_cond_node          Varchar2(200);
   p_cond_node_type     pls_integer;
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
      ecx_debug.log(l_statement, 'p_node_value', p_node_value,i_method_name);
      ecx_debug.log(l_statement, 'No of Elements in Source', ecx_utils.g_source.count,i_method_name);
   end if;

   x_node_pos := -1;
   i_parent_node_pos := p_parent_node_pos;

   if (p_parent_node_id >=0) then

      if(p_parent_node_pos < 0) then
        i_parent_node_pos := 0;
      end if;

      for i in i_parent_node_pos..ecx_utils.g_source.last
      loop
         if (ecx_utils.g_source(i).attribute_name = p_node_name) and
            (ecx_utils.g_source(i).parent_attribute_id = p_parent_node_id)
         then
               p_cond_node := ecx_utils.g_source(i).cond_node;
               p_cond_node_type := ecx_utils.g_source(i).cond_node_type;

               if (p_cond_node is not null) then

                if(l_statementEnabled) then
                     ecx_debug.log(l_statement,'p_cond_node', p_cond_node,i_method_name);
                     ecx_debug.log(l_statement, 'p_cond_node_type', p_cond_node_type,
                                   i_method_name);
                 end if;
                 if (p_cond_node <> p_node_name) then
                     get_cond_node_value(p_nodeList,
                                         p_nodeListIndex,
                                         p_cond_node,
                                         p_xmlParentNodeIndex,
                                         l_cond_node_value);
                  else
                     l_cond_node_value := p_node_value;
                  end if;

                  -- find the mapping that match the condition.
                  if (l_cond_node_value = ecx_utils.g_source(i).cond_value) then
                     if ( p_parent_node_id = ecx_utils.g_source(i).parent_attribute_id )
                     then
                        x_node_pos := i;
                        l_node_id := ecx_utils.g_source(i).attribute_id;
                        exit;
                     end if;
                  end if;

               -- there is no conditional mapping.  This is a mapping
               -- depends on the occurrence.
               elsif
                  ((ecx_utils.g_source(i).occurrence is null) or
                   (p_occur = ecx_utils.g_source(i).occurrence)) then
                    x_node_pos := i;
                    l_node_id := ecx_utils.g_source(i).attribute_id;
                    exit;

               elsif (l_node_id = p_parent_node_id) then
                  if(l_statementEnabled) then
                     ecx_debug.log(l_statement,'l_node_id', l_node_id,i_method_name);
                  end if;
                  x_node_pos := i;
                  l_node_id := ecx_utils.g_source(i).attribute_id;
                  exit;
               end if;
            end if;
      end loop;
   end if;

   if(l_statementEnabled) then
         ecx_debug.log(l_statement,'l_node_id', l_node_id,i_method_name);
         ecx_debug.log(l_statement, 'x_node_pos', x_node_pos,i_method_name);
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
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.GET_NODE_ID');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
END get_node_id;


procedure process_node (
   p_int_col_pos        IN            pls_integer,
   p_value              IN OUT NOCOPY varchar2,
   p_clob_value         IN Clob default null,
   p_cdata_flag         IN varchar2 default 'N') IS

   i_method_name   varchar2(2000) := 'ecx_inbound_new.process_node';

   l_cat_id             pls_integer;
   l_return_status      Varchar2(1);
   l_msg_count          pls_integer;
   l_msg_data           Varchar2(4000);
   l_len                number;

BEGIN
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;


  if(l_statementEnabled) then
    ecx_debug.log(l_statement,'p_int_col_pos', p_int_col_pos,i_method_name);
    ecx_debug.log(l_statement, 'node value', p_value,i_method_name);
    ecx_debug.log(l_statement, 'p_cdata_flag',p_cdata_flag,i_method_name);
  end if;

   l_cat_id := ecx_utils.g_source(p_int_col_pos).xref_category_id;

   if (l_cat_id is not null) then
      ecx_code_conversion_pvt.convert_external_value
      (
	  p_api_version_number => 1.0,
  	  p_return_status      => l_return_status,
	  p_msg_count          => l_msg_count,
	  p_msg_data           => l_msg_data,
	  p_value              => p_value,
       	  p_category_id        => l_cat_id,
      	  p_snd_tp_id          => ecx_utils.g_snd_tp_id,
      	  p_rec_tp_id          => ecx_utils.g_rec_tp_id ,
	  p_standard_id        => ecx_utils.g_standard_id
      );

      If l_return_status = 'X' OR l_return_status = 'R' Then
         ecx_utils.g_source(p_int_col_pos).xref_retcode := 1;
      else
         ecx_utils.g_source(p_int_col_pos).xref_retcode := 0;
      end if;


      if(l_statementEnabled) then
            ecx_debug.log(l_statement,'xref return code',
                    ecx_utils.g_source(p_int_col_pos).xref_retcode,
                    i_method_name);
      end if;

      if (l_return_status = ecx_code_conversion_pvt.G_RET_STS_ERROR) or
         (l_return_status = ecx_code_conversion_pvt.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = ECX_CODE_CONVERSION_PVT.g_xref_not_found) then
         if(l_statementEnabled) then
             ecx_debug.log(l_statement, 'Code Conversion uses the original code.',
                          i_method_name);
         end if;
      else
         if (l_return_status = ECX_CODE_CONVERSION_PVT.g_recv_xref_not_found) then
          if(l_statementEnabled) then
             ecx_debug.log(l_statement, 'Code Conversion uses the sender converted value',
                          p_value,i_method_name);
          end if;
         end if;
         if(l_statementEnabled) then
          ecx_debug.log(l_statement, 'node value', p_value,i_method_name);
         end if;
      end if;
   end if;


  if ((p_value is null and p_clob_value is null) OR (p_value is not null) ) then
            ecx_utils.g_source(p_int_col_pos).value := p_value;
  else
            l_len := dbms_lob.getlength(p_clob_value);
            if(l_len <= ecx_utils.G_CLOB_VARCHAR_LEN) Then
                   ecx_utils.g_source(p_int_col_pos).value :=dbms_lob.substr(p_clob_value,l_len,1);
                   ecx_utils.g_source(p_int_col_pos).clob_value := null ;
                   ecx_utils.g_source(p_int_col_pos).clob_length := null ;
            else
                   ecx_utils.g_source(p_int_col_pos).clob_value := p_clob_value;
                   ecx_utils.g_source(p_int_col_pos).clob_length := l_len;
            end if;
end if;
           if (p_cdata_flag = 'Y') then
                    ecx_utils.g_source(p_int_col_pos).is_clob := p_cdata_flag;
           end if;


          if(l_statementEnabled) then
            ecx_debug.log(l_statement,ecx_utils.g_source(p_int_col_pos).attribute_name ,
		ecx_utils.g_source(p_int_col_pos).value||' '||
   		ecx_utils.g_source(p_int_col_pos).base_column_name||' '||' '||
		p_int_col_pos,i_method_name);
          end if;

        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;

EXCEPTION
   WHEN no_data_found then
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected, 'Internal Column Position and Level not mapped for ',
                      p_int_col_pos,i_method_name);
      end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;

   WHEN ecx_utils.program_exit then
       if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
       end if;
      raise ecx_utils.program_exit;

   WHEN others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.PROCESS_NODE');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
END process_node;


procedure printNodeInfoStack
is
i_method_name   varchar2(2000) := 'ecx_inbound_new.printNodeInfoStack';
begin
   for i in node_info_stack.first..node_info_stack.last loop
       if(l_statementEnabled) then
           ecx_debug.log(l_statement,'Stack('||i||')',
                         node_info_stack(i).parent_node_id||'-'||
                         node_info_stack(i).parent_node_pos||'-'||
                         node_info_stack(i).pre_child_name||'-'||
                         node_info_stack(i).parent_xml_node_indx||'-'||
                         node_info_stack(i).occur,i_method_name);
        end if;
   end loop;
exception
   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.printNodeInfoStack');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;
end printNodeInfoStack;


procedure pushNodeInfoStack (
   p_parent_index   IN    pls_integer
   ) is
   i_method_name   varchar2(2000) := 'ecx_inbound_new.pushNodeInfoStack';
   l_stack_indx   pls_integer;

begin
   l_stack_indx := node_info_stack.COUNT + 1;
   node_info_stack(l_stack_indx).parent_node_id := l_next_pos;
   node_info_stack(l_stack_indx).occur := 1;
   node_info_stack(l_stack_indx).parent_xml_node_indx := p_parent_index;

   printNodeInfoStack;
exception
   WHEN ecx_utils.program_exit then
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.pushNodeInfoStack');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;
end pushNodeInfoStack;


procedure popNodeInfoStack (
   p_parent_index   IN    pls_integer
   ) is

   i_method_name   varchar2(2000) := 'ecx_inbound_new.popNodeInfoStack';
   l_stack_indx     pls_integer;

begin
   l_stack_indx := node_info_stack.COUNT;

   -- pop all the entries until find a match one.
   while (p_parent_index <> node_info_stack(l_stack_indx).parent_xml_node_indx) loop
      node_info_stack.DELETE(l_stack_indx);
      l_stack_indx := l_stack_indx -1;

      if (l_stack_indx = 0) then
          exit;
      end if;

   end loop;
   printNodeInfoStack;

exception
   WHEN ecx_utils.program_exit then
      raise ecx_utils.program_exit;

   when others then
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.popNodeInfoStack');
      if(l_unexpectedEnabled) then
       ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;
end popNodeInfoStack;


/* This procedure is called by the Java LoadMap to do level processing. */
procedure processLevel(
   p_nodeList       IN         ECX_NODE_TBL_TYPE,
   p_level          IN         pls_integer,
   p_next           IN         pls_integer,
   p_count          IN         pls_integer,
   x_err_msg        OUT NOCOPY varchar2
   ) is

   i_method_name   varchar2(2000) := 'ecx_inbound_new.processLevel';

   l_node_name          Varchar2(2000);
   l_node_value         Varchar2(4000);

   l_node_type          pls_integer;
   l_parent_index       pls_integer := -1;
   l_node_id            pls_integer := -1;
   l_stack_indx         pls_integer;
   i                    pls_integer;
   l_node_clob_value    clob;
   l_cdata_flag         varchar2(1) := 'N';

begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
      ecx_debug.log(l_statement,'p_level', p_level,i_method_name);
      ecx_debug.log(l_statement, 'p_next', p_next,i_method_name);
      ecx_debug.log(l_statement, 'p_count', p_count,i_method_name);
   end if;
   if not (l_docLogsAttrSet) then
      l_docLogsAttrSet := setDocLogsAttributes(p_nodeList, p_count);
   end if;

   pushStack(p_level);
   ecx_inbound.process_data(p_level, 10, p_next);

   for i in 1..p_count loop
      l_node_name     := p_nodeList(i).name;
      l_node_value    := p_nodeList(i).value;
      l_parent_index  := p_nodeList(i).parentIndex;
      l_node_type     := p_nodeList(i).type;
      l_node_clob_value := p_nodeList(i).clob_value;
      l_cdata_flag      := p_nodelist(i).isCDATA;


      if(l_statementEnabled) then
          ecx_debug.log(l_statement,'l_node_indx', i,i_method_name);
          ecx_debug.log(l_statement, 'l_node_name', l_node_name,i_method_name);
          ecx_debug.log(l_statement, 'l_node_value', l_node_value,i_method_name);
          ecx_debug.log(l_statement, 'l_node_type',  l_node_type,i_method_name);
          ecx_debug.log(l_statement, 'l_parent_index', l_parent_index,i_method_name);
          ecx_debug.log(l_statement, 'l_node_clob_value length',
                        dbms_lob.getLength(l_node_clob_value),i_method_name);
          ecx_debug.log(l_statement, 'l_cdata_flag is',l_cdata_flag,i_method_name);
     end if;
      -- compare the current node parent to the previous node parent.
      -- if current < previous, then it means the new node is at a highter level.
      -- if current > previous, then it means the new xml node is a child of previous.
      -- otherwise, do nothing.

      l_stack_indx := node_info_stack.COUNT;

      if (l_parent_index < node_info_stack(l_stack_indx).parent_xml_node_indx) then
         popNodeInfoStack(l_parent_index);
      else
         if (l_parent_index > node_info_stack(l_stack_indx).parent_xml_node_indx) then
            pushNodeInfoStack(l_parent_index);
         end if;
      end if;

      -- the count of the stack may have change after a pop or push.
      l_stack_indx := node_info_stack.COUNT;

      -- if node name same as the previous node
      -- then it is a repeating node
      if (l_node_name = node_info_stack(l_stack_indx).pre_child_name) then
         node_info_stack(l_stack_indx).occur := node_info_stack(l_stack_indx).occur + 1;
      elsif (l_next_pos is not null) then
         node_info_stack(l_stack_indx).parent_node_pos := l_next_pos;
      end if;

      node_info_stack(l_stack_indx).pre_child_name := l_node_name;

      if(l_node_type=1) then
        if (l_node_name <> node_info_stack(l_stack_indx).pre_child_name) then
         p_current_element_pos:=l_next_pos;
        end if;
         l_node_id := get_node_id (p_nodeList, i, l_parent_index, l_node_name,
                                 node_info_stack(l_stack_indx).parent_node_id,
                                 node_info_stack(l_stack_indx).parent_node_pos,
                                 node_info_stack(l_stack_indx).occur,
                                 l_node_value,
                                 l_next_pos);
      else
         l_node_id := get_node_id (p_nodeList, i, l_parent_index, l_node_name,
                                 node_info_stack(l_stack_indx).parent_node_id,
                                 p_current_element_pos,
                                 node_info_stack(l_stack_indx).occur,
                                 l_node_value,
                                 l_next_pos);
      end if;

     if (l_next_pos is not null) then
         process_node (l_next_pos, l_node_value,l_node_clob_value,l_cdata_flag);
     end if;

   end loop;

   ecx_inbound.process_data(p_level, 20, p_next);
   ecx_utils.g_total_records := ecx_utils.g_total_records + 1;

   if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN ecx_utils.program_exit then
      clean_up_tables;
      x_err_msg := ecx_utils.i_errbuf;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      -- if do a raise here, then java can't get the x_err_msg info.
      -- setErrorInfo has already set and java needs the x_err_msg
      -- to determine if any error occurred.

   when others then
      clean_up_tables;
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.PROCESSLEVEL');
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      x_err_msg := ecx_utils.i_errbuf;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      -- same reason as above in program_exit
end processLevel;


procedure startDocument is

   i_method_name   varchar2(2000) := 'ecx_inbound_new.startDocument';
   i_root_name    varchar2(2000);

BEGIN
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;

   -- Initialize global variable and the Stack for the Levels
   ecx_utils.g_previous_level := 0;
   l_level_stack.DELETE;

   /** Initialize the attr table **/
   l_attr_rec.DELETE;
   l_docLogsAttrSet := false;

   -- initialize the node_info_stack
   node_info_stack(1).parent_node_id := 0;
   node_info_stack(1).parent_node_pos := 0;
   node_info_stack(1).occur := 1;
   node_info_stack(1).pre_child_name := null;
   node_info_stack(1).parent_xml_node_indx := 0;

   l_next_pos := 0;

   -- if necessary initialize the printing
   if (not (ecx_utils.dom_printing) and (ecx_utils.structure_printing))
   then
      ecx_inbound.structurePrintingSetup(i_root_name);
   end if;

   -- Execute the Stage 10 for Level 0
   -- In-processing for Document level Source Side
   ecx_actions.execute_stage_data(20,0,'S');

   -- In-processing for Document level
   ecx_actions.execute_stage_data(20,0,'T');

   if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN OTHERS THEN
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.STARTDOCUMENT');
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
END startDocument;


procedure endDocument (
   x_xmlclob   OUT NOCOPY clob,
   x_parseXML  OUT NOCOPY boolean) is

i_method_name   varchar2(2000) := 'ecx_inbound_new.endDocument';
begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;
   popall;

   if (ecx_utils.structure_printing)
   then
       ecx_print_local.xmlPopall(x_xmlclob);
       ecx_util_api.parseXML(ecx_utils.g_inb_parser, x_xmlclob,
                             x_parseXML, ecx_utils.g_xmldoc);
   end if;

   -- Execute the Stage 30 for Level 0
   -- Post-Processing for Target
   ecx_actions.execute_stage_data(30,0,'T');

   -- Post-Processing for Source
   ecx_actions.execute_stage_data(30,0,'S');

   if(l_statementEnabled) then
       ecx_debug.log(l_statement, 'Total record processed',
                    ecx_utils.g_total_records - 1,i_method_name);
   end if;

   if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN ecx_utils.program_exit then
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN OTHERS THEN
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.ENDDOCUMENT');
      if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
END endDocument;


Function LoadXML
  (
   p_debugLevel       IN         number,
   p_payload          IN         clob,
   p_map_code         IN         varchar2,
   x_err_code         OUT NOCOPY number
  ) return varchar2
is
language java name 'oracle.apps.ecx.process.LoadXML.start(int, oracle.sql.CLOB, java.lang.String, int[]) returns String';


procedure raise_loadxml_err
   (
   p_err_code     IN   pls_integer,
   p_err_msg      IN   Varchar2
   ) is

i_method_name   varchar2(2000) := 'ecx_inbound_new.raise_loadxml_err';

begin
   if (p_err_code = PROCESS_LEVEL_EXCEPTION) then
      raise ecx_utils.program_exit;

   elsif (p_err_code = SAX_EXCEPTION) then
--Since in 10g, XDB XML_PARSE_EXCEPTION is appearing as SAX_EXCEPTION
--incorporating the same exception handling of XML_PARSE_EXCEPTION here,
--otherwise it is appearing as user-defined exception.
--      raise ecx_utils.program_exit;
ecx_debug.setErrorInfo(1, 20, p_err_msg);
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'Error Code: ' ||p_err_code,i_method_name);
         ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;

   elsif (p_err_code = SQL_EXCEPTION) then
      raise Load_XML_Exception;

   elsif (p_err_code = IO_EXCEPTION) then
      raise Load_XML_Exception;

   elsif (p_err_code = XML_PARSE_EXCEPTION) then
      ecx_debug.setErrorInfo(1, 20, p_err_msg);
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'Error Code: ' ||p_err_code,i_method_name);
         ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;

   elsif (p_err_code = OTHER_EXCEPTION) then
      raise Load_XML_Exception;
   end if;

exception
   when Load_XML_Exception then
      ecx_debug.setErrorInfo(2, 30, p_err_msg);
      if(l_unexpectedEnabled) then
         ecx_debug.log(l_unexpected,'Error Code: ' ||p_err_code,i_method_name);
         ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      raise ecx_utils.program_exit;

   when ecx_utils.program_exit then
      raise;
end raise_loadxml_err;


procedure process_xml_doc
   (
   p_payload          IN    clob,
   p_map_id           IN    pls_integer,
   x_xmlclob          OUT NOCOPY clob,
   x_parseXML         OUT NOCOPY boolean
   ) is

   i_method_name   varchar2(2000) := 'ecx_inbound_new.process_xml_doc';
   l_map_code         Varchar2(50);
   l_err_code         pls_integer;
   l_err_msg          Varchar2(2000);

   cursor get_map_code(p_map_id IN pls_integer)
   is
   select  map_code
   from    ecx_mappings
   where   map_id = p_map_id;

begin
   if (l_procedureEnabled) then
      ecx_debug.push(i_method_name);
   end if;

   open    get_map_code(p_map_id);
   fetch   get_map_code
   into    l_map_code;
   close   get_map_code;
   startDocument;


   l_err_msg := LoadXML(ecx_debug.g_debug_level, p_payload, l_map_code, l_err_code);

   if (l_err_code is not null and l_err_code > 0) then
       raise_loadxml_err(l_err_code, l_err_msg);
   end if;
   endDocument (x_xmlclob, x_parseXML);
   if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
   end if;

EXCEPTION
   WHEN ecx_utils.program_exit then
      clean_up_tables;
      if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;

   WHEN OTHERS THEN
      clean_up_tables;
      ecx_debug.setErrorInfo(2, 30, SQLERRM || '- ECX_INBOUND_NEW.PROCESS_XML_DOC');
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      raise ecx_utils.program_exit;
end process_xml_doc;


END ecx_inbound_new;

/
