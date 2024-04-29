--------------------------------------------------------
--  DDL for Package Body ICX_TEMPLATE_PARSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_TEMPLATE_PARSER" as
/* $Header: ICXPARSB.pls 115.7 99/07/17 03:19:51 porting ship $ */

-- Declaring the table for replacement meta_tag, replacement character
type table_row is record (
          variable_name		varchar2(200),
          sequence              number,
          value			varchar2(32000),
          related_id            number,
          parent_name           varchar2(200),
          parent_related_id     number
);


type variable_table is table of table_row
   index by binary_integer;

vars variable_table;



procedure clear_variables is

begin
vars.DELETE;
end clear_variables;



procedure add_variable(p_variable_name in varchar2,
                       p_sequence in number,
                       p_value in varchar2,
                       p_related_id in number default null,
                       p_parent_name in varchar2 default null,
                       p_parent_related_id in number default null) is

l_index number;

begin

if vars.COUNT = 0 then
  l_index := 1;
else
  l_index := vars.LAST + 1;
end if;

vars(l_index).variable_name := p_variable_name;
vars(l_index).sequence := p_sequence;
vars(l_index).value := p_value;
vars(l_index).related_id := p_related_id;
vars(l_index).parent_name := p_parent_name;
vars(l_index).parent_related_id := p_parent_related_id;


end add_variable;




procedure parse(p_template_name in varchar2) is

  type tag_var_record is record (tag_var_name varchar2(100),
                                 tag_var_value varchar2(2000));

  type tag_var_table is table of tag_var_record index by binary_integer;


  type tag_loop_table is table of varchar2(2000) index by binary_integer;


  type disabled_tag_record is record(tag_name varchar2(100),
                                     disable_variable varchar2(200),
                                     disable_condition varchar2(100),
                                     disable_value varchar2(32000),
                                     disabled varchar2(1));
  type disabled_tag_table is table of disabled_tag_record index by binary_integer;


  type disabled_data_record is record(tag_name varchar2(100),
                                      disabled_sequence number);
  type disabled_data_table is table of disabled_data_record index by binary_integer;


  type related_tag_record is record(tag_name varchar2(100),
                                    parent varchar2(100));
  type related_tag_table is table of related_tag_record index by binary_integer;


  type replace_text_record is record
                     (replace_text icx_template_tags.replacement_text%type,
                      tag_owner varchar2(200));
  type replace_text_table is table of replace_text_record index by binary_integer;


  cursor tag_text(name varchar2) is
    select replacement_text
    from icx_template_tags
    where tag_name = name;

  TAG_DOES_NOT_EXIST exception;
  TAG_NOT_UNIQUE exception;
  TAG_VAR_NO_END exception;
  TAG_NO_END exception;
  TAG_SYNTAX_ERROR exception;

  VARIABLE number := 1;
  EXECUTABLE number := 2;

  l_html_pieces                 utl_http.html_pieces;  -- ICX
  l_server varchar2(1000) :=  owa_util.get_cgi_env('SERVER_NAME');
  l_port varchar2(20) := owa_util.get_cgi_env('SERVER_PORT');
  l_html_piece                varchar2(32000);


  l_tag_beginning               number;
  l_tag_temp_end                number;
  l_tag_temp_start              number;
  l_tag_current_position        number;
  l_tag_open_count              number;
  l_tag_count                   number;
  l_tag_end                     number;

  l_tag                         varchar2(2000);
  l_sub_tag                     varchar2(2000);
  l_tag_name			varchar2(200);
  l_tag_loop_table              tag_loop_table;
  l_first_group_tag_loop_table  tag_loop_table;
  l_tag_var_table               tag_var_table;
  l_tag_var_start               number;
  l_tag_var_name_start          number;
  l_tag_var_end                 number;
  l_tag_var_num                 number;
  l_replacement_text            icx_template_tags.replacement_text%type;
  l_replace_text_table          replace_text_table;
  l_replace_start               number;
  l_replace_count               number;
  l_replace_end                 number;
  l_replace_start_exec          number;
  l_replace_end_exec            number;
  l_replace_mode                number;
  l_replace_rows                number;
  l_dyn_end		        number;
  l_variable_count              number;
  l_disabled_tags               disabled_tag_table;
  l_disabled_data               disabled_data_table;
  l_dis_tag_num		        varchar2(3);
  l_related_tags                related_tag_table;
  l_dynamic_cursor              integer;
  l_dynamic_call                varchar2(32000);
  l_dynamic_rows                integer;
  l_add_replace_var             boolean;

  function tag_disabled(p_tag in varchar2) return boolean is
  l_dis_tag number;
  begin
    for tag_num in 1..l_disabled_tags.COUNT loop
      if ((p_tag = 'DEFAULT') or
          (l_disabled_tags(tag_num).tag_name = p_tag)) then
        l_dis_tag := tag_num;
        exit;
      end if;
    end loop;
    if l_disabled_tags(l_dis_tag).disabled = 'Y' then
      return TRUE;
    else
      return FALSE;
    end if;
  end;


  procedure write(p_parent_name in varchar2 default null,
                  p_parent_related_id in number default null) is
  l_replace_count_w number;
  l_write_data boolean;
  l_children boolean;
  l_current_tag varchar2(200);
  l_current_related_id number;
  l_dyn_mode number;
  l_data_count number;
  l_disable_data_count number;
  begin

    -- write out tag multiple times as long as data exists
    l_replace_count_w := 1;
    l_write_data := TRUE;
    l_dyn_mode := VARIABLE;

    while l_write_data loop
      -- All tags should print once, unless disabled.
      -- The first time through, find the data iteration numbers for the tag.
      -- If any replace variable data is found, the tag should print
      if l_replace_count_w = 1 then
        -- Find how many times the tag should print
        l_data_count := 0;
        for replace_tab_num in l_replace_text_table.FIRST..l_replace_text_table.LAST loop

          if (substr(l_replace_text_table(replace_tab_num).replace_text, 1, 2) = '*!') then
            for var in 1..vars.COUNT loop
              if (((substr(l_replace_text_table(replace_tab_num).replace_text, 3, length(l_replace_text_table(replace_tab_num).replace_text) - 4) = vars(var).variable_name)
              or (substr(l_replace_text_table(replace_tab_num).tag_owner,4)||'PDISABLE' = vars(var).variable_name))
              and (vars(var).sequence > l_data_count)
              and (nvl(vars(var).parent_name,' ') = nvl(p_parent_name, ' '))
              and (nvl(vars(var).parent_related_id, 0) = nvl(p_parent_related_id, 0))) then
                l_data_count := vars(var).sequence;
              end if;
            end loop;
          end if;
        end loop;

        -- set up disabled data table to store the tag and sequence number
        -- of any data-disabled tags.
        l_disable_data_count := 1;
        l_disabled_data.DELETE;
        for tag in 1..l_disabled_tags.COUNT loop
          for var in 1..vars.COUNT loop
            if ((substr(l_disabled_tags(tag).tag_name,4)||'PDISABLE' = vars(var).variable_name)
            and (vars(var).value = 'TRUE')) then
              l_disabled_data(l_disable_data_count).tag_name := substr(l_disabled_tags(tag).tag_name,4);
              l_disabled_data(l_disable_data_count).disabled_sequence := vars(var).sequence;
              l_disable_data_count := l_disable_data_count + 1;
            end if;
          end loop;
        end loop;

        l_write_data := TRUE;
      else
        if l_replace_count_w <= l_data_count then
          l_write_data := TRUE;
        else
          l_write_data := FALSE;
        end if;
      end if;


      -- write entire tag
      if l_write_data then

        -- record if any tags are disabled for this iteration of data

        -- first set all tags to enabled except for those that do not
        -- have the current parent
        for tag in 1..l_disabled_tags.COUNT loop
          l_disabled_tags(tag).disabled := 'N';
        end loop;

        -- disable all tags that do not have the current parent
        for rel_tag in 1..l_related_tags.COUNT loop
          if ((l_related_tags(rel_tag).tag_name <> 'DEFAULT')
          and (nvl(l_related_tags(rel_tag).parent,' ') <> nvl(p_parent_name,' '))) then
            for dis_tag in 1..l_disabled_tags.COUNT loop
              if (substr(l_disabled_tags(dis_tag).tag_name,4) = l_related_tags(rel_tag).tag_name) then
                l_disabled_tags(dis_tag).disabled := 'Y';
                exit;
              end if;
            end loop;
          end if;
          -- set current tag to the last tag with the current parent
          -- This will be use for related tag recursion later
          if (nvl(l_related_tags(rel_tag).parent,' ') = nvl(p_parent_name,' ')) then
            l_current_tag := l_related_tags(rel_tag).tag_name;
          end if;
        end loop;

        -- check if tag is disabled through tag variables
        for tag in 1..l_disabled_tags.COUNT loop
         if l_disabled_tags(tag).disabled = 'N' then
          if l_disabled_tags(tag).disable_variable is not null then
            if l_disabled_tags(tag).disable_condition = 'EQUAL' then
              if l_disabled_tags(tag).disable_variable = 'PDATACOUNT' then
                if l_replace_count_w = l_disabled_tags(tag).disable_value then
                  l_disabled_tags(tag).disabled := 'Y';
                end if;
              else
                for var in 1..vars.COUNT loop
                  if ((l_disabled_tags(tag).disable_variable = vars(var).variable_name)
                  and (vars(var).value = l_disabled_tags(tag).disable_value)
                  and (vars(var).sequence = l_replace_count_w)) then
                    l_disabled_tags(tag).disabled := 'Y';
                    exit;
                  end if;
                end loop;
              end if;
            elsif l_disabled_tags(tag).disable_condition = 'NOT EQUAL' then
              if l_disabled_tags(tag).disable_variable = 'PDATACOUNT' then
                if l_replace_count_w <> l_disabled_tags(tag).disable_value then
                  l_disabled_tags(tag).disabled := 'Y';
                end if;
              else
                for var in 1..vars.COUNT loop
                  if ((l_disabled_tags(tag).disable_variable = vars(var).variable_name)
                  and (vars(var).value <> l_disabled_tags(tag).disable_value)
                  and (vars(var).sequence = l_replace_count_w)) then
                    l_disabled_tags(tag).disabled := 'Y';
                    exit;
                  end if;
                end loop;
              end if;
            elsif l_disabled_tags(tag).disable_condition = 'LESS THAN' then
              if l_disabled_tags(tag).disable_variable = 'PDATACOUNT' then
                if l_replace_count_w < l_disabled_tags(tag).disable_value then
                  l_disabled_tags(tag).disabled := 'Y';
                end if;
              else
                for var in 1..vars.COUNT loop
                  if ((l_disabled_tags(tag).disable_variable = vars(var).variable_name)
                  and (vars(var).value < l_disabled_tags(tag).disable_value)
                  and (vars(var).sequence = l_replace_count_w)) then
                    l_disabled_tags(tag).disabled := 'Y';
                    exit;
                  end if;
                end loop;
              end if;
            elsif l_disabled_tags(tag).disable_condition = 'MORE THAN' then
              if l_disabled_tags(tag).disable_variable = 'PDATACOUNT' then
                if l_replace_count_w > l_disabled_tags(tag).disable_value then
                  l_disabled_tags(tag).disabled := 'Y';
                end if;
              else
                for var in 1..vars.COUNT loop
                  if ((l_disabled_tags(tag).disable_variable = vars(var).variable_name)
                  and (vars(var).value > l_disabled_tags(tag).disable_value)
                  and (vars(var).sequence = l_replace_count_w)) then
                    l_disabled_tags(tag).disabled := 'Y';
                    exit;
                  end if;
                end loop;
              end if;
            elsif l_disabled_tags(tag).disable_condition = 'DIVISIBLE BY' then
              if l_disabled_tags(tag).disable_variable = 'PDATACOUNT' then
                if (mod(l_replace_count_w, l_disabled_tags(tag).disable_value) <> 0) then
                  l_disabled_tags(tag).disabled := 'Y';
                end if;
              else
                for var in 1..vars.COUNT loop
                  if ((l_disabled_tags(tag).disable_variable = vars(var).variable_name)
                  and (mod(vars(var).value, l_disabled_tags(tag).disable_value) = 0)
                  and (vars(var).sequence = l_replace_count_w)) then
                    l_disabled_tags(tag).disabled := 'Y';
                    exit;
                  end if;
                end loop;
              end if;
            elsif l_disabled_tags(tag).disable_condition = 'NOT DIVISIBLE BY' then
              if l_disabled_tags(tag).disable_variable = 'PDATACOUNT' then
                if (mod(l_replace_count_w, l_disabled_tags(tag).disable_value) = 0) then
                  l_disabled_tags(tag).disabled := 'Y';
                end if;
              else
                for var in 1..vars.COUNT loop
                  if ((l_disabled_tags(tag).disable_variable = vars(var).variable_name)
                  and (mod(vars(var).value, l_disabled_tags(tag).disable_value) <> 0)
                  and (vars(var).sequence = l_replace_count_w)) then
                    l_disabled_tags(tag).disabled := 'Y';
                    exit;
                  end if;
                end loop;
              end if;
            end if;
           end if;
          end if;

          -- if tag is not disabled through tag variable data then
          -- check if tag is disabled through parameter data
          if l_disabled_tags(tag).disabled = 'N' then
            for disabled_data in 1..l_disabled_data.COUNT loop
              if ((substr(l_disabled_tags(tag).tag_name,4) = l_disabled_data(disabled_data).tag_name)
              and ((l_disabled_data(disabled_data).disabled_sequence = l_replace_count_w)
                or (l_disabled_data(disabled_data).disabled_sequence = 0))) then
                l_disabled_tags(tag).disabled := 'Y';
                exit;
              end if;
            end loop;
          end if;

        end loop;  -- end disable check



        -- loop through all pieces of the tag and print them
        for replace_tab_num in l_replace_text_table.FIRST..l_replace_text_table.LAST loop
          -- do not print anything if first tag is disabled.  This provides
          -- for disabling a whole group.
          if l_disabled_tags(1).disabled = 'Y' then
            exit;
          end if;

          if not tag_disabled(l_replace_text_table(replace_tab_num).tag_owner) then
            if substr(l_replace_text_table(replace_tab_num).replace_text, 1, 2) = '#!' then
              -- build the package call to execute
              l_dynamic_call := substr(l_replace_text_table(replace_tab_num).replace_text,3);
              l_dyn_end := instr(l_replace_text_table(replace_tab_num).replace_text, '!#');

              if l_dyn_end <> 0 then
                -- execute dynamic plsql call
                l_dynamic_call := substr(l_dynamic_call,1,length(l_dynamic_call)-2);
                if length(l_dynamic_call) > 0 then
                  begin
                    l_dynamic_cursor  := dbms_sql.open_cursor;
                    dbms_sql.parse(l_dynamic_cursor, 'begin '||l_dynamic_call||'; end;', DBMS_SQL.native);
                    l_dynamic_rows := dbms_sql.execute(l_dynamic_cursor);
                    dbms_sql.close_cursor(l_dynamic_cursor);
                    exception
                      when others then
                        htp.p('SQL being executed was: '||l_dynamic_call||'<BR>');
                        htp.p(SQLERRM);
                  end;
                end if;
              else
                l_dyn_mode := EXECUTABLE;
              end if;

            elsif substr(l_replace_text_table(replace_tab_num).replace_text,1,2) = '*!' then
              for var in 1..vars.COUNT loop
                if ((substr(l_replace_text_table(replace_tab_num).replace_text, 3, length(l_replace_text_table(replace_tab_num).replace_text) - 4) = vars(var).variable_name)
                and  (vars(var).sequence = l_replace_count_w)
                and (nvl(vars(var).parent_name,' ') = nvl(p_parent_name, ' '))
                and (nvl(vars(var).parent_related_id, 0) = nvl(p_parent_related_id, 0))) then
                  if l_dyn_mode = VARIABLE then
                    if vars(var).value is not null then
                      if (replace_tab_num = l_replace_text_table.LAST) then
                        htp.p(vars(var).value);
                      else
                        htp.prn(vars(var).value);
                      end if;
                    end if;
                  else
                    l_dynamic_call := l_dynamic_call||vars(var).value;
                  end if;
                  -- set current related id for use in recursion later
                  l_current_related_id := vars(var).related_id;
                  exit;
                end if;
              end loop;

            else
              if l_dyn_mode = VARIABLE then
                if l_replace_text_table(replace_tab_num).replace_text is not null then
                  if (replace_tab_num = l_replace_text_table.LAST) then
                    htp.p(l_replace_text_table(replace_tab_num).replace_text);
                  else
                    htp.prn(l_replace_text_table(replace_tab_num).replace_text);
                  end if;
                end if;
              else
                l_dyn_end := instr(l_replace_text_table(replace_tab_num).replace_text, '!#');
                if l_dyn_end <> 0 then
                  -- execute dynamic plsql call
                  l_dynamic_call := l_dynamic_call||l_replace_text_table(replace_tab_num).replace_text;
                  l_dynamic_call := substr(l_dynamic_call,1,length(l_dynamic_call)-2);
                  if length(l_dynamic_call) > 0 then
                    begin
                      l_dynamic_cursor  := dbms_sql.open_cursor;
                      dbms_sql.parse(l_dynamic_cursor, 'begin '||l_dynamic_call||'; end;', DBMS_SQL.native);
                      l_dynamic_rows := dbms_sql.execute(l_dynamic_cursor);
                      dbms_sql.close_cursor(l_dynamic_cursor);
                      exception
                        when others then
                        htp.p('SQL being executed was: '||l_dynamic_call||'<BR>');
                        htp.p(SQLERRM);
                    end;
                    l_dyn_mode := VARIABLE;
                  end if;
                else
                  l_dynamic_call := l_dynamic_call||l_replace_text_table(replace_tab_num).replace_text;
                end if;
              end if;
            end if;
          end if;
        end loop;

        -- write loop break text if current row is divisible by break #
        if mod(l_replace_count_w, l_first_group_tag_loop_table(3)) = 0 then
          htp.p(l_first_group_tag_loop_table(4));
        end if;


        -- check for child related tags and recurse if necessary
        for rel_tag in 1..l_related_tags.COUNT loop
          if l_related_tags(rel_tag).parent  = l_current_tag then
            write(l_current_tag, l_current_related_id);
            exit;
          end if;
        end loop;

      end if;

      l_replace_count_w := l_replace_count_w + 1;

    end loop;
  end;  -- write procedure

begin
--bug fix 924513
l_server := fnd_profile.value('WEB_AUTHENTICATION_SERVER');

if l_server is null then
  -- read html template
  l_html_pieces := utl_http.request_pieces(FND_WEB_CONFIG.PROTOCOL ||'//'||l_server||':'||l_port||'/OA_HTML/US/'||p_template_name);
else l_html_pieces := utl_http.request_pieces(l_server||'/OA_HTML/US/'||p_template_name);
end if;
-- end bug fix 924513

  -- parse each html piece
  l_html_piece := '';
  for piece in l_html_pieces.FIRST..l_html_pieces.LAST loop

    -- set l_html_piece to current piece of html
    l_html_piece := l_html_piece||l_html_pieces(piece);

    -- replace all special tags and print the template html
    while length(l_html_piece) > 0  loop
        l_tag_beginning := instr(l_html_piece,'<~!');
        if l_tag_beginning = 0 then
          -- no special tags left, print rest of html and exit loop
          htp.prn(l_html_piece);
          l_html_piece := '';
          exit;
        else
          -- print out and discard html up to the special tag
          htp.prn(substr(l_html_piece, 1, l_tag_beginning - 1));
          l_html_piece := substr(l_html_piece, l_tag_beginning);
        end if;

        -- count number of tags to check for grouped tags
        l_tag_count := 1;
        l_tag_current_position :=2;
        l_tag_open_count := 1;
        while l_tag_open_count > 0 loop
          l_tag_temp_end := instr(l_html_piece, '!~>',l_tag_current_position + 1);
          l_tag_temp_start := instr(l_html_piece, '<~!',l_tag_current_position + 1);
          if l_tag_temp_end = 0 then
            l_tag_end := 0;
            exit;
          elsif ((l_tag_temp_start < l_tag_temp_end) and
                 (l_tag_temp_start <> 0)) then
            l_tag_open_count := l_tag_open_count + 1;
            l_tag_count := l_tag_count + 1;
            l_tag_current_position := l_tag_temp_start;
          else
            l_tag_open_count := l_tag_open_count - 1;
            l_tag_end := l_tag_temp_end;
            l_tag_current_position := l_tag_temp_end;
          end if;
        end loop;

        if l_tag_end = 0 then
            -- tag has no end, raise syntax error if this is the last chunk
            -- or exit the loop for this chunk and the current chunk will
            -- get concatenated with the next chunk and re-evaluated
            if piece =  l_html_pieces.LAST then
              raise TAG_NO_END;
            end if;
            exit;
        end if;


        -- get tag
        l_tag := substr(l_html_piece, 1, l_tag_end + 2);


        -- discard current tag from html template chunk
        l_html_piece := substr(l_html_piece, l_tag_end + 3);


        -- process tag, or group of tags
        l_tag_current_position := 1;
        l_replace_text_table.DELETE;  -- clear replace text table
        l_disabled_tags.DELETE;
        l_related_tags.DELETE;
        l_replace_count := 1;
        for tag in 1..l_tag_count loop
          -- get start and end of current tag (to deal with parts of tag group)
          if l_tag_count = 1 then
            l_tag_temp_start := 1;
            l_tag_temp_end := instr(l_tag, '!~>');
            l_sub_tag := substr(l_tag, l_tag_temp_start, l_tag_temp_end + 3 - l_tag_temp_start);
            l_tag_current_position := l_tag_temp_end + 1;
          elsif ((l_tag_count > 1) and (tag = 1)) then
            l_tag_temp_start := 1;
            l_tag_temp_end := instr(l_tag, '<~!', 2);
            l_sub_tag := substr(l_tag, l_tag_temp_start, l_tag_temp_end - l_tag_temp_start)||'!~>';
            l_tag_current_position := l_tag_temp_end - 1;
          else
            l_tag_temp_start := instr(l_tag, '<~!',l_tag_current_position);
            l_tag_temp_end := instr(l_tag, '!~>',l_tag_current_position);
            l_sub_tag := substr(l_tag, l_tag_temp_start, l_tag_temp_end + 3 - l_tag_temp_start);
            l_tag_current_position := l_tag_temp_end + 1;
          end if;

          -- get tag name
          l_tag_var_end := 4;
          while (l_tag_var_end < length(l_sub_tag)) loop
            if (substr(l_sub_tag, l_tag_var_end, 1) in (' ',',','!')) then
              exit;
            else
              l_tag_var_end := l_tag_var_end + 1;
            end if;
          end loop;
          l_tag_name := substr(l_sub_tag, 4, l_tag_var_end  - 4);

          -- get multiple tag loop formatting data if present
          for i in 1..4 loop
            l_tag_loop_table(i) := '';
          end loop;
          l_tag_var_num := 1;
          if substr(l_sub_tag, l_tag_var_end, 1) = ',' then
            while (l_tag_var_end < length(l_sub_tag)) loop
              l_tag_var_start := instr(l_sub_tag, ',', l_tag_var_end);
              if l_tag_var_start = 0 then
                -- no loop data variable in the tag, exit;
                exit;
              else
                -- read variable into the tag_var_table
                l_tag_var_end := instr(l_sub_tag, ',', l_tag_var_start + 1);
                l_tag_loop_table(l_tag_var_num) := substr(l_sub_tag, l_tag_var_start + 1, l_tag_var_end - l_tag_var_start - 1);
                l_tag_var_num := l_tag_var_num + 1;
              end if;
            end loop;
          end if;
          if (tag = 1) then
            l_first_group_tag_loop_table := l_tag_loop_table;
	  end if;

          -- get tag variables if present
          l_tag_var_num := 1;
          l_tag_var_table.DELETE;
          l_tag_var_table(1).tag_var_value := 'DEFAULT';
          while (l_tag_var_end < length(l_sub_tag)) loop
            l_tag_var_start := instr(l_sub_tag, '"', l_tag_var_end + 1);
            if l_tag_var_start = 0 then
              -- no extra variable in the tag, exit;
              exit;
            else
              -- read variable into the tag_var_table
              l_tag_var_end := instr(l_sub_tag, '"', l_tag_var_start + 1);
              if l_tag_var_end = 0 then
                raise TAG_SYNTAX_ERROR;
              end if;
              l_tag_var_name_start := l_tag_var_start;
              while (l_tag_var_name_start <> 0) loop
                if (substr(l_sub_tag, l_tag_var_name_start, 1) = ' ') then
                  exit;
                else
                  l_tag_var_name_start := l_tag_var_name_start - 1;
                end if;
              end loop;
              l_tag_var_table(l_tag_var_num).tag_var_name := substr(l_sub_tag, l_tag_var_name_start + 1, l_tag_var_start - l_tag_var_name_start - 2);
              l_tag_var_table(l_tag_var_num).tag_var_value := substr(l_sub_tag, l_tag_var_start + 1, l_tag_var_end - l_tag_var_start - 1);

              -- add variable to disabled table if needed
              if l_tag_var_table(l_tag_var_num).tag_var_name = 'DISABLEVAR' then
                l_disabled_tags(tag).disable_variable := l_tag_var_table(l_tag_var_num).tag_var_value;
              elsif l_tag_var_table(l_tag_var_num).tag_var_name = 'DISABLECOND' then
                l_disabled_tags(tag).disable_condition := l_tag_var_table(l_tag_var_num).tag_var_value;
              elsif l_tag_var_table(l_tag_var_num).tag_var_name = 'DISABLEVALUE' then
                l_disabled_tags(tag).disable_value := l_tag_var_table(l_tag_var_num).tag_var_value;
              end if;

              -- add variable to related table if variable name is parent
              if l_tag_var_table(l_tag_var_num).tag_var_name = 'PARENT' then
                l_related_tags(tag).parent := l_tag_var_table(l_tag_var_num).tag_var_value;
              end if;

              l_tag_var_num := l_tag_var_num + 1;
            end if;
          end loop;


          -- add current tag name to disabled table for reference later
          l_dis_tag_num := '001';
          for dis_tag in 1..l_disabled_tags.COUNT loop
            if substr(l_disabled_tags(dis_tag).tag_name, 4) = l_tag_var_table(1).tag_var_value then
              if l_dis_tag_num <= substr(l_disabled_tags(dis_tag).tag_name,1,3) then
                l_dis_tag_num := substr(to_char(to_number(substr(l_disabled_tags(dis_tag).tag_name,1,3)) + 1, '000'),2);
              end if;
            end if;
          end loop;
          l_disabled_tags(tag).tag_name := l_dis_tag_num||l_tag_var_table(1).tag_var_value;


          -- add current tag to related table for reference later
          l_related_tags(tag).tag_name := l_tag_var_table(1).tag_var_value;


          -- get tag replacement text
          open tag_text(l_tag_name);
          l_replace_rows := 0;
          loop
            fetch tag_text into l_replacement_text;
            exit when tag_text%NOTFOUND or tag_text%NOTFOUND is null;
            l_replace_rows := l_replace_rows + 1;
          end loop;
          close tag_text;
          if l_replace_rows < 1 then
            raise TAG_DOES_NOT_EXIST;
          elsif l_replace_rows > 1 then
            raise TAG_NOT_UNIQUE;
          end if;

          -- replace tag vars
          for tag_var in 1..l_tag_var_table.COUNT loop
            l_replacement_text := replace(l_replacement_text, '*!['||l_tag_var_table(tag_var).tag_var_name||']!*', l_tag_var_table(tag_var).tag_var_value);
            l_replacement_text := replace(l_replacement_text, '['||l_tag_var_table(tag_var).tag_var_name||']', l_tag_var_table(tag_var).tag_var_value);
          end loop;

          -- replace un-matched tag variables in replacement text
          -- Tag variables that are not also possibly parameters (wrapped in
          -- '*!' and '!*') should be discarded.  Otherwise, replace tag var
          -- text with tag name variable concatenated with tag var.
          l_replacement_text := replace(l_replacement_text, '*![', '*!'||l_tag_var_table(1).tag_var_value);
          l_replacement_text := replace(l_replacement_text, '#![', '#!'||l_tag_var_table(1).tag_var_value);
          l_replacement_text := replace(l_replacement_text, ']!*', '!*');
          l_replacement_text := replace(l_replacement_text, ']!#', '!#');
          l_replace_start := 1;
          while l_replace_start <> 0 loop
            l_replace_start := instr(l_replacement_text,'[',l_replace_start);
            if l_replace_start <> 0 then
              l_replace_end := instr(l_replacement_text,']',l_replace_start);
              if l_replace_end <> 0 then
                l_replacement_text := substr(l_replacement_text,1,l_replace_start-1)||substr(l_replacement_text,l_replace_end+1,length(l_replacement_text)-l_replace_end);
              else
                raise TAG_VAR_NO_END;
              end if;
            end if;
          end loop;


          -- load pre-tag text
          l_replace_text_table(l_replace_count).replace_text := l_tag_loop_table(1);
     --     l_replace_text_table(l_replace_count).tag_owner := l_disabled_tags(tag).tag_name;
          l_replace_text_table(l_replace_count).tag_owner := 'DEFAULT';
          l_replace_count := l_replace_count + 1;

          -- load tag static text and tag variables into seperate table recs
          l_variable_count := 0;
          l_replace_mode := VARIABLE;
          while length(l_replacement_text) > 0  loop

            l_replace_start_exec := instr(l_replacement_text,'#!');
            l_replace_start := instr(l_replacement_text,'*!');
            if ((l_replace_start_exec <> 0) and (l_replace_start_exec <= l_replace_start)) then
              l_replace_start := l_replace_start_exec;
              l_replace_mode := EXECUTABLE;
            end if;

            if l_replace_start = 0 then
              -- no replacement vars, add to replace table and exit
              l_replace_text_table(l_replace_count).replace_text := l_replacement_text;
              l_replace_text_table(l_replace_count).tag_owner := l_disabled_tags(tag).tag_name;
              l_replace_count := l_replace_count + 1;
              exit;
            elsif l_replace_start > 1 then
              -- add text up to variable to the replace text table
              l_replace_text_table(l_replace_count).replace_text := substr(l_replacement_text, 1, l_replace_start - 1);
              l_replace_text_table(l_replace_count).tag_owner := l_disabled_tags(tag).tag_name;
              l_replacement_text := substr(l_replacement_text, l_replace_start);
              l_replace_count := l_replace_count + 1;
            end if;

            l_replace_end_exec := instr(l_replacement_text,'!#');
            if ((l_replace_mode = EXECUTABLE) and (l_replace_end_exec = 0)) then
              raise TAG_SYNTAX_ERROR;
            end if;

            -- get end of current piece of replacement text
            if l_replace_start_exec <> 0 then
              l_replace_end := instr(l_replacement_text, '*!', 2);
            else
              l_replace_end := instr(l_replacement_text, '!*') + 2;
            end if;
            if ((l_replace_end = 0) or ((l_replace_mode = EXECUTABLE) and (l_replace_end_exec < l_replace_end))) then
              l_replace_end := l_replace_end_exec + 3;
              l_replace_mode := VARIABLE;
            end if;

            if l_replace_end = 0 then
              -- replace var has no end, for now add to table and exit
              -- there may be more in the next html chunk...
              l_replace_text_table(l_replace_count).replace_text := substr(l_replacement_text, 1, l_replace_start - 1);
              l_replace_text_table(l_replace_count).tag_owner := l_disabled_tags(tag).tag_name;
              l_replace_count := l_replace_count + 1;
              exit;
            end if;

            -- add replace var to table if any replacement data is present
            -- for that variable and discard
            if substr(l_replacement_text, 1,1) = '*' then
              l_add_replace_var := FALSE;
              for var in 1..vars.COUNT loop
                if (substr(l_replacement_text, 3, l_replace_end - 5) = vars(var).variable_name) then
                  l_add_replace_var := TRUE;
                  exit;
                end if;
              end loop;
              if l_add_replace_var then
                l_replace_text_table(l_replace_count).replace_text := substr(l_replacement_text, 1, l_replace_end - 1);
                l_replace_text_table(l_replace_count).tag_owner := l_disabled_tags(tag).tag_name;
                l_replace_count := l_replace_count + 1;
                l_variable_count := l_variable_count + 1;
              end if;
            else
              l_replace_text_table(l_replace_count).replace_text := substr(l_replacement_text, 1, l_replace_end - 1);
              l_replace_text_table(l_replace_count).tag_owner := l_disabled_tags(tag).tag_name;
              l_replace_count := l_replace_count + 1;
            end if;
            l_replacement_text := substr(l_replacement_text, l_replace_end);

          end loop;


          -- load post-tag text
          if not ((l_tag_count > 1) and (tag = 1)) then
            l_replace_text_table(l_replace_count).replace_text := l_tag_loop_table(2);
      --      l_replace_text_table(l_replace_count).tag_owner := l_disabled_tags(tag).tag_name;
            l_replace_text_table(l_replace_count).tag_owner := 'DEFAULT';
            l_replace_count := l_replace_count + 1;
          end if;

        end loop;

        -- load post-tag text for grouping tag if needed
        if l_tag_count > 1 then
          l_replace_text_table(l_replace_count).replace_text := l_first_group_tag_loop_table(2);
     --     l_replace_text_table(l_replace_count).tag_owner :=l_first_group_tag_loop_table(2);
          l_replace_text_table(l_replace_count).tag_owner := 'DEFAULT';
          l_replace_count := l_replace_count + 1;
        end if;

        -- write out tag multiple times as long as data exists
        write;

    end loop;

  end loop;

  exception
    when TAG_DOES_NOT_EXIST then
      htp.p(l_tag_name||': Special tag does not exist.');
    when TAG_NOT_UNIQUE then
      htp.p(l_tag_name||': Special tag is not unique.');
    when TAG_VAR_NO_END then
      htp.p(l_tag_name||': Special tag has a tag variable format error.  Each tag variable should start with [ and end with ].');
    when TAG_NO_END then
      htp.p('Special tag has no end.');
    when TAG_SYNTAX_ERROR then
      htp.p(l_tag_name||': Special tag has syntax errors.');
    when others then
      htp.p(SQLERRM);

end parse;




procedure get_HTML_file(p_file_name in varchar2) is

l_html_pieces  utl_http.html_pieces;
l_server varchar2(1000) :=  owa_util.get_cgi_env('SERVER_NAME');
l_port varchar2(20) := owa_util.get_cgi_env('SERVER_PORT');

begin
  if (p_file_name is not null) then
-- fix bug 924513
l_server := fnd_profile.value('WEB_AUTHENTICATION_SERVER');
if l_server is null then
    -- read html file
    l_html_pieces := utl_http.request_pieces(FND_WEB_CONFIG.PROTOCOL || '//'||l_server||':'||l_port||p_file_name);
else
   l_html_pieces := utl_http.request_pieces(l_server||p_file_name);
end if;
-- end fix bug 924513

    -- write out html file
    for piece in l_html_pieces.FIRST..l_html_pieces.LAST loop
      htp.p(l_html_pieces(piece));
    end loop;
  end if;
end get_HTML_file;



procedure get_fnd_message(p_app_code in varchar2,
                          p_message_name in varchar2) is

begin
  FND_MESSAGE.SET_NAME(p_app_code, p_message_name);
  htp.p(FND_MESSAGE.Get);
end;




procedure print_variables is

begin

htp.tableOpen('BORDER=1');
  htp.tableRowOpen;
    htp.tableData('<B>row number</B>');
    htp.tableData('<B>variable_name</B>');
    htp.tableData('<B>sequence</B>');
    htp.tableData('<B>value</B>');
    htp.tableData('<B>related id</B>');
    htp.tableData('<B>parent name</B>');
    htp.tableData('<B>parent related id</B>');
  htp.tableRowClose;

  for i in 1..vars.COUNT loop
    htp.tableRowOpen;
      htp.tableData(i);
      htp.tableData(vars(i).variable_name);
      htp.tableData(vars(i).sequence);
      htp.tableData(vars(i).value);
      htp.tableData(vars(i).related_id);
      htp.tableData(vars(i).parent_name);
      htp.tableData(vars(i).parent_related_id);
    htp.tableRowClose;
  end loop;
htp.tableClose;

end;


procedure tag_list is

cursor tags is
select tag_name, tag_description
from icx_template_tags
order by tag_name;

begin

null;

end tag_list;




procedure tag_details(tag_name in varchar2) is

begin

null;


end tag_details;





end icx_template_parser;


/
