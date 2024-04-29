--------------------------------------------------------
--  DDL for Package Body ICX_REQ_TEMPLATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_TEMPLATES" as
/* $Header: ICXRQTMB.pls 115.3 99/07/17 03:23:36 porting sh $ */

--**********************************************************
-- LOCAL PROCEDURES NOT DECLARED IN SPEC
--**********************************************************

------------------------------------------------------------
procedure createDummyPage(p_where number, nodeId varchar2, nodeIndex varchar2, v_string long,v_first_time_flag varchar2) is
------------------------------------------------------------
begin
   -- open html
   htp.htmlOpen;
   htp.headOpen;
   htp.headClose;

   if (v_first_time_flag = 'Y') then
      htp.bodyOpen('','BGCOLOR="#FFCCCC" onLoad="top.openTemplate(''' || icx_util.replace_quotes(nodeId) ||''',document.GetChildren.nodeId,document.GetChildren.nodeIndex)"');
   else
      htp.bodyOpen('','BGCOLOR="#FFCCCC" onLoad="top.addChildren(''' || icx_util.replace_quotes(nodeId) || ''',document.GetChildren.nodeId,document.GetChildren.nodeIndex)"');
   end if;

       htp.formOpen(curl        =>'ICX_REQ_TEMPLATES.GetTemplateChildren',
                    cmethod     => 'POST',
                    cattributes => 'name=''GetChildren'''
                   );

       htp.formHidden('nodeId',  cvalue => v_string);
       htp.formHidden('p_where', cvalue => p_where);
       htp.formHidden('nodeIndex', cvalue => nodeIndex);

       htp.formClose;


   htp.bodyClose;
   htp.htmlClose;

end createDummyPage;


--**********************************************************
-- LOCAL PROCEDURES NOT DECLARED IN SPEC
--**********************************************************


------------------------------------------------------------
function get_default_template( v_emergency varchar2 )
        return varchar2 is
------------------------------------------------------------

v_return_template  varchar2(25);
v_test             number;

begin

    -- get default template
    v_return_template := icx_sec.getID(icx_sec.PV_USER_REQ_TEMPLATE);

    v_test := 0;

    if v_emergency = 'YES' then
           select count(-1) into v_test
           from   po_reqexpress_headers
           where  express_name = v_return_template
           and    (reserve_po_number = 'YES' OR reserve_po_number = 'OPTIONAL');
    else
           select count(-1) into v_test
           from   po_reqexpress_headers
           where  express_name = v_return_template
           and    (reserve_po_number = 'NO' OR reserve_po_number = 'OPTIONAL' OR reserve_po_number is null);
    end if;

    if v_test = 0 then
          v_return_template := null;
    end if;

    return v_return_template;

end get_default_template;

------------------------------------------------------------
procedure GetTemplateTop(v_org_id number,
                         v_emergency varchar2 default NULL ) is
------------------------------------------------------------

-- (MC) remove local variables v_regions_table, v_items_table, and v_results_table

y_table            icx_util.char240_table;
/* Change wrto Bug Fix to implement the Bind Vars **/
  where_clause_binds      ak_query_pkg.bind_tab;
  where_clause_binds_empty     ak_query_pkg.bind_tab;
  where_clause       varchar2(2000);

  v_index             number;
v_node_id          varchar2(240);
v_name             varchar2(240);
v_no_of_children   number;
v_children_loaded  varchar2(100);
p_where            varchar2(240);
counter            number;
i                  number;
v_dcdName          varchar2(240) := owa_util.get_cgi_env('SCRIPT_NAME');
v_default_template  varchar2(25);
v_def_is_top        varchar2(1);

begin


    v_index := 1;


   /* desmond for beta 1 move default template to top for beta no emergency default */
--   v_default_template := get_default_template('NO');
   /* for ups, support emergency po defaulting 5/5/97 */
   v_default_template := get_default_template(v_emergency);
   v_def_is_top := 'N';

/* Change wrto Bug Fix to implement the Bind Vars **/
--  where_clause := 'relationship_type = ''TOP'' ';
    where_clause := 'relationship_type = :rel_type_bin ';
  where_clause_binds(v_index).name := 'rel_type_bin';
  where_clause_binds(v_index).value := 'TOP';
  v_index := v_index + 1;


   if v_emergency = 'YES' then
--            where_clause :=  where_clause  ||  ' AND ( RESERVE_PO_NUMBER = ''YES'' OR RESERVE_PO_NUMBER = ''OPTIONAL'' )';
            where_clause :=  where_clause  ||  ' AND ( RESERVE_PO_NUMBER = :reserve_po_num_bin OR RESERVE_PO_NUMBER = :reserve_po_num1_bin )';
  where_clause_binds(v_index).name := 'reserve_po_num_bin';
  where_clause_binds(v_index).value := 'YES';
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'reserve_po_num1_bin';
  where_clause_binds(v_index).value := 'OPTIONAL';
  v_index := v_index + 1;
   else
--            where_clause :=  where_clause  ||  ' AND (RESERVE_PO_NUMBER = ''NO'' OR RESERVE_PO_NUMBER = ''OPTIONAL'' OR RESERVE_PO_NUMBER is  NULL )';
            where_clause :=  where_clause  ||  ' AND (RESERVE_PO_NUMBER = :reserve_po_num2_bin OR RESERVE_PO_NUMBER = :reserve_po_num3_bin OR RESERVE_PO_NUMBER is  NULL )';
  where_clause_binds(v_index).name := 'reserve_po_num2_bin';
  where_clause_binds(v_index).value := 'NO';
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'reserve_po_num3_bin';
  where_clause_binds(v_index).value := 'OPTIONAL';
  v_index := v_index + 1;
   end if;

   htp.comment(where_clause);

   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                              P_PARENT_REGION_CODE    => 'ICX_RELATED_TEMPLATES_DISPLAY',
                              P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                              P_USER_ID         => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                              P_WHERE_CLAUSE 		=> where_clause,
                              P_RETURN_PARENTS        => 'T',
                              P_RETURN_CHILDREN       => 'F',
                              p_WHERE_BINDS      => where_clause_binds );

   counter := 1;

   where_clause_binds := where_clause_binds_empty;

   v_index := 1;



if ak_query_pkg.g_results_table.count > 0 then
	htp.p('TOP_TEMPLATES = new MakeArray(' || ak_query_pkg.g_results_table.count || ');');
      for i in ak_query_pkg.g_results_table.first .. ak_query_pkg.g_results_table.last loop

/* desmond */
--         v_node_id := ak_query_pkg.g_results_table(i).value2;  -- Template id
--         v_name    := ak_query_pkg.g_results_table(i).value4;  -- Template name

         v_node_id := ak_query_pkg.g_results_table(i).value1;
         v_name := ak_query_pkg.g_results_table(i).value1;

         if v_default_template is not NULL then
            if v_node_id = v_default_template then
               v_def_is_top := 'Y';
            end if;
         end if;

         p_where := icx_call.encrypt2(v_node_id || '*' || v_org_id || '**]');

         select count(-1) into v_no_of_children
         from   icx_related_templates_val_v
         where  express_name = v_node_id
         and    RELATIONSHIP_TYPE <> 'TOP';

         if v_no_of_children > 0 then
                v_children_loaded := 'false';
         else
                v_children_loaded := 'true';
         end if;

         htp.p('TOP_TEMPLATES[' || counter || ']= new node("' || v_node_id || '","' ||
                                v_name || '",' || v_children_loaded || ',"' ||
                                v_dcdName || '/ICX_REQ_TEMPLATES.template_items?p_where=' || p_where  -- Node Link
                                || '","' || p_where || '");');
         counter := counter + 1;

      end loop; -- end i

   else -- No hierchy setup use regular templates

      if v_emergency = 'YES' then
  --          where_clause := '(RESERVE_PO_NUMBER = ''YES'' OR RESERVE_PO_NUMBER = ''OPTIONAL'' )';
            where_clause := '(RESERVE_PO_NUMBER = :reserve_po_num4_bin OR RESERVE_PO_NUMBER = :reserve_po_num5_bin )';
  where_clause_binds(v_index).name := 'reserve_po_num4_bin';
  where_clause_binds(v_index).value := 'YES';
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'reserve_po_num5_bin';
  where_clause_binds(v_index).value := 'OPTIONAL';
  v_index := v_index + 1;
      else
--            where_clause := '(RESERVE_PO_NUMBER = ''NO'' OR RESERVE_PO_NUMBER = ''OPTIONAL'' OR RESERVE_PO_NUMBER is NULL )';
      where_clause := '(RESERVE_PO_NUMBER = :reserve_po_num6_bin OR RESERVE_PO_NUMBER = :reserve_po_num7_bin OR RESERVE_PO_NUMBER is NULL )';
  where_clause_binds(v_index).name := 'reserve_po_num6_bin';
  where_clause_binds(v_index).value := 'NO';
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'reserve_po_num7_bin';
  where_clause_binds(v_index).value := 'OPTIONAL';
  v_index := v_index + 1;

      end if;

      htp.comment(where_clause);

      ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                             P_PARENT_REGION_CODE    => 'ICX_REQ_TEMPLATES',
                             P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                             P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                             P_WHERE_CLAUSE          => where_clause,
                             P_RETURN_PARENTS        => 'T',
                             P_RETURN_CHILDREN       => 'F',
                             P_WHERE_BINDS      =>     where_clause_binds);

      if ak_query_pkg.g_results_table.count > 0 then
         htp.p('TOP_TEMPLATES = new MakeArray(' || ak_query_pkg.g_results_table.count  || ');');
         for i in ak_query_pkg.g_results_table.first .. ak_query_pkg.g_results_table.last loop


            v_node_id := ak_query_pkg.g_results_table(i).value1;  -- template id
            v_name    := ak_query_pkg.g_results_table(i).value1;  -- template id

            if v_default_template is not NULL then
               if v_node_id = v_default_template then
                   v_def_is_top := 'Y';
               end if;
            end if;

            p_where := icx_call.encrypt2(v_node_id || '*' || v_org_id || '**]');

            v_children_loaded := 'true';
            htp.p('TOP_TEMPLATES[' || counter || ']= new node("' || v_node_id || '","' ||
                                  v_name || '",' || v_children_loaded || ',"' ||
                                  v_dcdName || '/ICX_REQ_TEMPLATES.template_items?p_where=' || p_where  -- Node Link
                                || '","' || p_where || '");');
            counter := counter + 1;

         end loop;


      else  -- No TEmplates
--        if v_default_template is not NULL then
--            htp.p('TOP_TEMPLATES = new MakeArray(1);');
--        else
            htp.p('TOP_TEMPLATES = new MakeArray(0);');
--        end if;
      end if;

   end if; -- No hierchy setup


   /* desmond -- move default template to top is not already at top */
   /* allow it to be at children level and dispaly as such in Beta 2 */
   if v_def_is_top = 'N'  AND
      v_default_template is not NULL then

      p_where := icx_call.encrypt2(v_default_template || '*' || v_org_id || '**]');

      select count(-1) into v_no_of_children
      from   icx_related_templates_val_v
      where  express_name = v_default_template
      and    RELATIONSHIP_TYPE <> 'TOP';

      if v_no_of_children > 0 then
         v_children_loaded := 'false';
      else
         v_children_loaded := 'true';
      end if;

      htp.p('new_TOP_TEMPLATES = new MakeArray(' || counter || ');');
      htp.p('for (var i = 1; i <= ' || to_char(counter - 1) || '; i ++) {'
             || 'new_TOP_TEMPLATES[i] = TOP_TEMPLATES[i]; }');
      htp.p('new_TOP_TEMPLATES[' || counter || ']= new node("' || v_default_template || '","' ||
                                v_default_template || '",' || v_children_loaded || ',"' ||
                                v_dcdName || '/ICX_REQ_TEMPLATES.template_items?p_where=' || p_where  -- Node Link
                                || '","' || p_where || '");');
      htp.p('TOP_TEMPLATES = new MakeArray(' || counter || ');');
      htp.p('for (var i = 1; i <= ' || to_char(counter) || '; i ++) {'
             || 'TOP_TEMPLATES[i] = new_TOP_TEMPLATES[i];}');

   end if;



end GetTemplateTop;



------------------------------------------------------------
procedure templates(start_row in number default 1,
                    c_end_row in number default null,
                    p_where   in number) is
------------------------------------------------------------
v_lang           varchar2(5);
v_dcdName        varchar2(1000);
v_frame_location varchar2(1024);
n_temp           number;

begin


    -- get lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

    --get dcd name
    v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

    htp.htmlOpen;
       htp.headOpen;
       htp.headClose;
       htp.framesetOpen('','250,*','BORDER=5');
           htp.framesetOpen('*,0','','BORDER=0');
           htp.frame('/OA_HTML/' || v_lang || '/ICXTEMH.htm', 'left_frame', '0','0', cscrolling=>'auto',cnoresize => '');
                  htp.frame(csrc  =>  v_dcdName || '/ICX_REQ_TEMPLATES.GetTemplateChildren?p_where=' || p_where,  -- URL
                            cname =>  'dummy', 	   --Window Name
                            cmarginwidth   => '0', --    Value in pixels
                            cmarginheight  => '0', --    Value in pixels
--                            cscrolling     => 'NO',--    yes | no | auto
                            cattributes    => 'FRAMEBORDER=NO');
           htp.framesetClose;

           v_frame_location := v_dcdName || '/ICX_REQ_TEMPLATES.template_items?';

           if c_end_row is not null then
               v_frame_location := v_frame_location || 'p_start_row=' || start_row  ||'&p_end_row=' || c_end_row || '&p_where=' || p_where;
           else
               v_frame_location := v_frame_location || 'p_where=' || p_where;
           end if;
           htp.frame( v_frame_location, 'right_frame', '0','0', cscrolling=>'auto');
    htp.framesetClose;
    htp.htmlClose;


end templates;


------------------------------------------------------------
procedure GetTemplateChildren( p_where in number,
                               nodeId  in varchar2  default null,
                               nodeIndex in varchar2 default null) is
------------------------------------------------------------

-- (MC) remove local variables v_regions_table, v_items_table, and v_results_table

y_table            icx_util.char240_table;
where_clause_binds      ak_query_pkg.bind_tab;
where_clause_binds_empty      ak_query_pkg.bind_tab;
where_clause            varchar2(2000);

v_index            number;

v_p_where          number;
-- childrenString     varchar2(2000);
-- Fix for bug 517695
childrenString     long;

v_node_id          varchar2(240);
v_name             varchar2(240);
v_no_of_children   number;
v_org              number;
params             icx_on_utilities.v80_table;

v_dcdName          varchar2(240) := owa_util.get_cgi_env('SCRIPT_NAME');

v_emergency varchar2(10);
v_reserve_po_number varchar2(10);
v_default_template_id varchar2(240);
v_default_top varchar2(240);
v_cont    varchar2(1);
d_nodeid  varchar2(240);
d_relation varchar2(80);
d_inter_nodes varchar2(2000);
v_first_time_flag varchar2(1);

  cursor getTopNode_emg(childnodeId varchar2) is
     select express_name,relationship_type
     from icx_related_templates_val_v
     where related_express_name = childnodeId
     and (reserve_po_number = 'YES'
      or  reserve_po_number = 'OPTIONAL');

  cursor getTopNode(childnodeId varchar2) is
     select express_name,relationship_type
     from icx_related_templates_val_v
     where related_express_name = childnodeId
     and (reserve_po_number = 'NO'
      or  reserve_po_number = 'OPTIONAL'
      or  reserve_po_number is NULL);

  cursor getAnyTop is
     select express_name,relationship_type
     from icx_related_templates_val_v
     where relationship_type = 'TOP'
     order by express_name;

begin


-- Check if session is valid
if (icx_sec.validatesession()) then

    v_index := 1;

  --decrypt2 p_where

  if p_where is not null then
        icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_where), params);
        --template_id := params(1);

--        if nodeId is null then
          v_default_template_id := params(1);

          -- determine top of the default template name and use it to
          -- drill down the default template tree

          if v_default_template_id is not NULL and
             length(v_default_template_id) > 5 then
             if substr(v_default_template_id,1,5) = '(NEW)' and
                v_default_template_id <> '(NEW)none' then

                v_default_top := substr(v_default_template_id,6,length(v_default_template_id) - 5);

                -- v_cont := 'Y';
                --     if v_emergency is not NULL AND v_emergency = 'YES' then
                --          while v_cont = 'Y' loop
                --            open getTopNode_emg(v_default_template_id);
                --            fetch getTopNode_emg into d_nodeid,d_relation;
                --            if getTopNode_emg%NOTFOUND OR
                --               d_relation = 'TOP' OR
                --               v_default_template_id = d_nodeid  then
                --               v_cont := 'N';
                --            end if;
                --            close getTopNode_emg;
                --            v_default_template_id := d_nodeid;
                --          end loop;
                --     else

                v_cont := 'Y';
                d_inter_nodes := v_default_top;
                while v_cont = 'Y' loop
                   open getTopNode(v_default_top);
                   fetch getTopNode into d_nodeid,d_relation;
                   if getTopNode%NOTFOUND OR
                      d_relation = 'TOP' OR
                      v_default_top = d_nodeid  then
                         v_cont := 'N';
                   end if;
                   close getTopNode;
                   if d_nodeid is not NULL then
                      v_default_top := d_nodeid;
                      d_inter_nodes := d_nodeid || '~~' || d_inter_nodes;  -- build hier tree
                   end if;
                end loop;
                if d_inter_nodes = v_default_top then   -- just format it to what showTree js script expects
                   d_inter_nodes := d_inter_nodes || '~~' || d_inter_nodes;
                end if;
--     end if;

--          v_emergency := params(3);
--        else
--          v_default_template_id := NULL;
--          v_emergency := NULL;
--        end if;

           v_default_template_id := substr(v_default_template_id,6,length(v_default_template_id) - 5);
        else
           v_default_template_id := NULL;
           open getAnyTop;
           fetch getAnyTop into d_nodeid,d_relation;
           if getAnyTop%NOTFOUND then
               v_default_top := NULL;
           end if;
           close getAnyTop;
           if d_nodeid is not NULL then
              v_default_top := d_nodeid;
           end if;
        end if;

      end if;


        v_org := params(2);
  end if;

   if nodeId is not null then
--       where_clause := 'express_name = ''' || nodeId || ''' AND ';
         where_clause := 'express_name = :express_name1_bin  AND ';
  where_clause_binds(v_index).name := 'express_name1_bin';
  where_clause_binds(v_index).value := nodeId;
  v_index := v_index + 1;

   else
       if v_default_top is not null then
--          where_clause := 'express_name = ''' || v_default_top || ''' AND ';
          where_clause := 'express_name = :express_name2_bin  AND ';
  where_clause_binds(v_index).name := 'express_name2_bin';
  where_clause_binds(v_index).value := v_default_top;
  v_index := v_index + 1;
       end if;
   end if;

--   where_clause := where_clause || ' relationship_type = ''CHILD''';
   where_clause := where_clause || ' relationship_type = :rel_type_bin ';
  where_clause_binds(v_index).name := 'rel_type_bin';
  where_clause_binds(v_index).value := 'CHILD';
  v_index := v_index + 1;
   -- Query childrens.
   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                              P_PARENT_REGION_CODE    => 'ICX_RELATED_TEMPLATES_DISPLAY',
                              P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                              P_USER_ID               => icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                              P_WHERE_CLAUSE 		=> where_clause,
                              P_RETURN_PARENTS        => 'T',
                              P_RETURN_CHILDREN       => 'F',
                              p_WHERE_BINDS      => where_clause_binds);

   if ak_query_pkg.g_results_table.count > 0 then
   for i in ak_query_pkg.g_results_table.first .. ak_query_pkg.g_results_table.last loop

--         v_node_id := ak_query_pkg.g_results_table(i).value3;  -- Related template id
--         v_namet    := ak_query_pkg.g_results_table(i).value4;  -- Related template name
       v_node_id := ak_query_pkg.g_results_table(i).value2;
       v_name := ak_query_pkg.g_results_table(i).value2;


         v_p_where := icx_call.encrypt2(v_node_id || '*' || v_org || '**]');

         select count(-1) into v_no_of_children
         from   icx_related_templates_val_v
         where  express_name = v_node_id
         and    RELATIONSHIP_TYPE <> 'TOP';


/* desmond -- for beta 1 show default template as a leaf displaying from parent tree and no emergency po case */
--         if v_node_id = get_default_template('NO') then
--            childrenString := childrenString || v_node_id || '~~' || v_name || '~~' || '0' || '~~' || v_dcdName || '/ICX_REQ_TEMPLATES.template_items?p_where=' || v_p_where || '~~' || v_p_where || '~~';
--         else

           childrenString := childrenString || v_node_id || '~~' || v_name || '~~' || v_no_of_children || '~~'||  v_dcdName || '/ICX_REQ_TEMPLATES.template_items?p_where=' || v_p_where  -- Node Link
                                          ||  '~~' || v_p_where || '~~' ;
--         end if;


   end loop; -- end i
   end if;


/* desmond */
  /* In beta2,  explode the template at the child level if default  template is a child */
  /* so get the top node template id, and drill down from there */
   if nodeid is NULL AND
      v_default_template_id is not NULL AND
      v_default_template_id <> 'none' then

      if v_default_top is not NULL then
           d_nodeid := v_default_top;
      else
           d_nodeid := v_default_template_id;
      end if;
      v_first_time_flag := 'Y';
    else
      d_nodeid := nodeId;
      v_first_time_flag := 'N';
    end if;

   /* desmond -- for beta 1, since we have moved default temp */
   /* on top, so show it as a leaf, and do not explode it any more */
   createDummyPage(v_p_where,d_nodeid,nodeIndex,childrenString,v_first_time_flag);



--   createDummyPage(v_p_where, nodeId, childrenString);

end if;


end GetTemplateChildren;




------------------------------------------------------------
procedure template_items(p_start_row in number default 1,
                         p_end_row in number default null,
				 p_where in varchar2) is
------------------------------------------------------------
v_dcdName            varchar2(1000);
v_lang		     varchar2(5);

begin

   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');

    -- get lang code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);


   -- We need to split into 2 frames

   js.scriptOpen;
   htp.p('function openButWin(start_row, end_row, total_row, where) {

         var result = "' || v_dcdName ||
	              '/ICX_REQ_TEMPLATES.template_items_buttons?p_start_row=" +
		      start_row + "&p_end_row=" + end_row + "&p_total_rows=" +
		      total_row + "&p_where=" + where;
	    open(result, ''k_buttons'');
}
  ');

   js.scriptClose;
   htp.p('<FRAMESET ROWS="*,40" BORDER=0>');
   htp.p('<FRAME SRC="' || v_dcdName ||
	 '/ICX_REQ_TEMPLATES.template_items_display?p_start_row=' ||
	 p_start_row || '&p_end_row=' || p_end_row || '&p_where=' ||
	p_where||
	 '"  NAME="data" FRAMEBORDER=NO MARGINWIDTH=0 MARGINHEIGHT=0 NORESIZE>');

   htp.p('<FRAME NAME="k_buttons" SRC="/OA_HTML/' ||
	 v_lang ||
	 '/ICXPINK.htm" MARGINWIDTH=0 MARGINHEIGHT=0 FRAMEBORDER=NO NORESIZE SCROLLING="NO">');

   htp.p('</FRAMESET>');

end;

------------------------------------------------------------
procedure template_items_buttons(p_start_row in number default 1,
                                 p_end_row in number default null,
				 p_total_rows in number,
				 p_where in number) is
------------------------------------------------------------

v_lang              varchar2(30);
c_query_size        number;

begin

IF icx_sec.validateSession THEN

   SELECT QUERY_SET INTO c_query_size FROM ICX_PARAMETERS;

   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     htp.p('<BODY BGCOLOR="#FFCCCC">');

     htp.p('<TABLE BORDER=0>');
     htp.p('<TD>');
   icx_on_utilities2.displaySetIcons(p_language_code   => v_lang,
                                     p_packproc        => 'ICX_REQ_TEMPLATES.template_items',
                                     p_start_row       => p_start_row,
                                     p_stop_row        => p_end_row,
 				     p_encrypted_where => p_where,
                                     p_query_set       => c_query_size,
				     p_target          => 'parent',
                                     p_row_count       => p_total_rows);
     htp.p('</TD>');
     htp.p('<TD width=1000></TD><TD>');
     FND_MESSAGE.SET_NAME('ICX','ICX_ADD_TO_ORDER');
     icx_util.DynamicButton(P_ButtonText      => FND_MESSAGE.GET,
                            P_ImageFileName   => 'FNDBNEW.gif',
                            P_OnMouseOverText => FND_MESSAGE.GET,
                            P_HyperTextCall   => 'javascript:parent.frames[0].submit()',
                            P_LanguageCode    => v_lang,
                            P_JavaScriptFlag  => FALSE);

     htp.p('</TD></TABLE>');
     htp.p('</BODY>');

end if;

end;


------------------------------------------------------------
procedure template_items_display(p_start_row in number default 1,
                         p_end_row in number default null,
                                 p_where in varchar2) is
------------------------------------------------------------

sess_web_user       number(15);
c_title             varchar2(80) := '';
c_prompts           icx_util.g_prompts_table;
v_lang              varchar2(30);
where_clause_binds      ak_query_pkg.bind_tab;
where_clause        varchar2(2000);
v_index   NUMBER;


total_rows          number;
end_row             number;
display_text        varchar2(5000);
-- temp_table          icx_admin_sig.pp_table;
temp_table          varchar2(5000);
c_query_size        number;
v_supplier_url      varchar2(150);
v_supplier_item_url varchar2(150);
v_item_url          varchar2(150);
v_line_id	        varchar2(65);
i                   number := 0;
j                   number := 0;

y_table             icx_util.char240_table;

v_express_name      varchar2(240) := NULL;
v_org               number;
params              icx_on_utilities.v80_table;

counter             number := 0;
V_QUANTITY_LENGTH   NUMBER :=10;

c_currency            varchar2(15);
c_money_precision     number;
c_money_fmt_mask      varchar2(32);
l_encrypted_where     number;
v_dcdName            varchar2(1000);

v_line_id_ind       number;
v_supplier_url_ind  number;
v_item_url_ind      number;
v_supplier_item_url_ind number;
g_reg_ind           number;
l_pos              number := 0;
l_spin_pos         number := 0;


BEGIN


 IF icx_sec.validateSession() THEN

   v_index := 1;

   sess_web_user := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
   v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   v_dcdName := owa_util.get_cgi_env('SCRIPT_NAME');


   -- icx_util.getPrompts(178,'ICX_ITEMS_TEMPLATE',c_title,c_prompts);
   icx_util.getPrompts(601,'ICX_PO_TEMPLATE_ITEMS_R',c_title,c_prompts);
   icx_util.error_page_setup;

   l_encrypted_where := p_where;

    IF p_where IS NOT NULL THEN
        icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_where), params);
        v_express_name := params(1);

        if length(v_express_name) > 5 then
           if substr(v_express_name,1,5) = '(NEW)' then
              v_express_name := substr(v_express_name,6,length(v_express_name) - 5);
           end if;
        end if;
        v_org := params(2);
    END IF;

 -- If no template is selected then display a blank right frame

   IF (v_express_name is NULL or v_express_name = 'none') THEN
      htp.htmlOpen;
        htp.headOpen;
          icx_util.copyright;
          htp.bodyOpen('','BGCOLOR="#FFCCCC" onLoad="top.winOpen(''nav'', ''template'')"');
          htp.bodyClose;
        htp.headClose;
      htp.htmlClose;
      return;
   END IF;

   ICX_REQ_NAVIGATION.get_currency(v_org, c_currency, c_money_precision,
                                   c_money_fmt_mask);

   --  Query against ICX_PO_REQ_TEMPLATE_ITEMS_R and
   --- display only items in this template

   -- where_clause := 'organization_id = ' || v_org || ' and EXPRESS_NAME = ' || '''' || replace(v_express_name,'''','''''') || '''';
--   where_clause := '(organization_id is NULL OR organization_id = ' || v_org || ')' || ' and EXPRESS_NAME = ' || '''' || replace(v_express_name,'''','''''') || '''';
   where_clause := '(organization_id is NULL OR organization_id = :org_id_bin ) and EXPRESS_NAME = :express_name_bin';

  where_clause_binds(v_index).name := 'org_id_bin';
  where_clause_binds(v_index).value := v_org;
  v_index := v_index + 1;
  where_clause_binds(v_index).name := 'express_name_bin';
  where_clause_binds(v_index).value := v_express_name;
  v_index := v_index + 1;

   -- get number of rows to display
   SELECT QUERY_SET INTO c_query_size FROM ICX_PARAMETERS;

   -- set up end rows to display

   IF p_end_row IS NULL THEN
      end_row := c_query_size;
   ELSE
      end_row := p_end_row;
   END IF;

   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                              P_PARENT_REGION_CODE    => 'ICX_PO_TEMPLATE_ITEMS_R',
  			      P_WHERE_CLAUSE          => where_clause,
                              p_WHERE_BINDS      => where_clause_binds,
                              P_RESPONSIBILITY_ID     => icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                              P_USER_ID               => sess_web_user,
                              P_RETURN_PARENTS        => 'T',
                              P_RETURN_CHILDREN       => 'F',
                              P_RANGE_LOW             => p_start_row,
                              P_RANGE_HIGH            => end_row);
   -- Get number of rows to display
    g_reg_ind := ak_query_pkg.g_regions_table.FIRST;

    total_rows := ak_query_pkg.g_regions_table(g_reg_ind).total_result_count;

    IF end_row > total_rows THEN
       end_row := total_rows;
    END IF;


  IF ak_query_pkg.g_results_table.COUNT = 0 then
      htp.bodyOpen('','BGCOLOR="#FFCCCC" onLoad="top.winOpen(''nav'', ''template'')"');
      fnd_message.set_name('EC','ICX_NO_RECORDS_FOUND');
      fnd_message.set_token('NAME_OF_REGION_TOKEN',c_title);
      htp.p('<H3>' || fnd_message.get || '</H3>');
      htp.bodyClose;
      return;
   END IF;

   --- Display the template
   htp.htmlOpen;
   htp.headOpen;
   icx_util.copyright;
   js.scriptOpen;

   htp.p('function submit() {
             document.template_items.cartId.value = parent.parent.parent.cartId;
	     document.template_items.p_emergency.value = parent.parent.parent.emergency;
             document.template_items.submit();
          }');

   htp.p('function get_parent_values(cartId,emerg) {
	     cartId.value = parent.parent.parent.cartId;
             emerg.value = parent.parent.parent.emergency;
           }');

   js.scriptClose;
   htp.title(c_title);
   htp.headClose;


   htp.bodyOpen('','BGCOLOR="#FFCCCC" onLoad="top.winOpen(''nav'', ''template''); top.lastTemplate.start_row='|| p_start_row ||
                        ';top.lastTemplate.end_row='|| end_row ||
		        ';parent.openButWin(' || p_start_row || ',' ||
		        end_row || ',' || total_rows || ',' || p_where || ')"');
   htp.br;



   htp.p('<FORM ACTION="' || v_dcdName || '/ICX_REQ_TEMPLATES.submit_items" METHOD="POST" TARGET="_parent" NAME="template_items" onSubmit="return(false)">');

     htp.formHidden('cartId','');
     htp.formHidden('p_emergency','');
     js.scriptOpen;

     htp.p('get_parent_values(document.template_items.cartId,document.template_items.p_emergency);');
     js.scriptClose;



     htp.formHidden('p_start_row', p_start_row);
     htp.formHidden('p_end_row', p_end_row);
     htp.formHidden('p_where', p_where);
     /* expressName required to identify a cart line uniquely */
     htp.formHidden('v_express_name', v_express_name);
     -- htp.formHidden('p_emergency','');
     htp.formHidden('end_row',end_row,'cols="60" rows ="10"');
     htp.formHidden('p_query_set',c_query_size,'cols="60" rows = "10"');
     htp.formHidden('p_row_count',total_rows,'cols="60" rows="10"');


     l_pos := l_pos + 9;

     -- Print the table column headings
     htp.tableOpen('border=5','','','','bgcolor=#' || icx_util.get_color('TABLE_
DATA_MULTIROW') );

     htp.p('<TR BGColor="#'||icx_util.get_color('TABLE_HEADER_TABS')||'">');

     FOR i IN ak_query_pkg.g_items_table.FIRST .. ak_query_pkg.g_items_table.LAST LOOP
        IF (ak_query_pkg.g_items_table(i).value_id IS NOT NULL
                   AND ak_query_pkg.g_items_table(i).item_style <> 'hidden'
                   AND ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
                   AND ak_query_pkg.g_items_table(i).secured_column <> 'T') or
                   ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' THEN

               IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' THEN
                      --print quantity heading WITH COLSPAN=2
                  htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long,'CENTER','','','','2');
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_UNIT_PRICE' THEN
                  htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long || ' (' || c_currency || ')', 'CENTER','','','','','width=80');
               ELSE
                  htp.tableData(ak_query_pkg.g_items_table(i).attribute_label_long, 'CENTER');
               END IF;
        END IF;

        -- Find line id, urls value id
        if ak_query_pkg.g_items_table(i).value_id is not null then

           --need line_id to call javascript function down() and up()
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_LINE_ID') then
              v_line_id_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
           -- find item_url and supplier_item_url
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_ITEM_URL') then
              v_item_url_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUPPLIER_URL') then
              v_supplier_url_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
           if (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUPPLIER_ITEM_URL') then
              v_supplier_item_url_ind := ak_query_pkg.g_items_table(i).value_id;
           end if;
        end if;

     END LOOP;


     htp.tableRowClose;

     counter := 0;
     -- Print the table data

     -- FOR j IN p_start_row - 1 .. end_row - 1 LOOP
     FOR j IN ak_query_pkg.g_results_table.FIRST .. ak_query_pkg.g_results_table.LAST LOOP

       temp_table := '<TR BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW') || '">';

       icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(j), y_table) ;

       FOR i in ak_query_pkg.g_items_table.FIRST .. ak_query_pkg.g_items_table.LAST LOOP

         -- Print quantity input text box and up button
             IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_QTY' THEN
                v_line_id := y_table(v_line_id_ind);
                display_text := '<TD ROWSPAN=2><CENTER> <INPUT TYPE=''text'' NAME=''Quantity'' '
|| ' SIZE=' || to_char(V_QUANTITY_LENGTH) || ' onChange=''if(!parent.parent.parent.checkNumber(this)){this.focus();this.value="";}''></CENTER></TD>';

                 l_spin_pos := l_pos;

     		 display_text := display_text
		   || '<TD width=18 valign=bottom> <a href="javascript:parent.parent.parent.up(document.template_items.elements['
		   || l_spin_pos
		   || '])" onMouseOver="window.status=''Add Quantity'';return true"><IMG SRC=/OA_MEDIA/'
		   || v_lang
		   || '/FNDISPNU.gif border=0></a></TD>';

                 l_pos := l_pos + 1;

                 temp_table := temp_table ||  display_text;
             END IF;

             /* Sequence number is one of the required attribute to
                to identify a row in the cart line */
             IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SEQUENCE' THEN
                   display_text := '<INPUT TYPE="HIDDEN" NAME="v_sequence_num" VALUE =' || y_table(ak_query_pkg.g_items_table(i).value_id) || '>';
                   l_pos := l_pos + 1;
                   temp_table := temp_table || display_text;
             END IF;

             IF ak_query_pkg.g_items_table(i).value_id IS NOT NULL -- not including ICX_QTY
                  AND ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
                  AND ak_query_pkg.g_items_table(i).secured_column <> 'T'
                  AND ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' THEN

/* Ref Bug #640289 : Changed By Suri. The Standard Requisitions/Emergency Requisitions Unit Price  field should allow more than two decimal places. ***/

                     IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_UNIT_PRICE' THEN
--                        display_text := to_char(to_number(y_table(ak_query_pkg.g_items_table(i).value_id)), c_money_fmt_mask);
                          display_text := to_char(to_number(y_table(ak_query_pkg.g_items_table(i).value_id)));
/* End Change Bug #640289 By Suri ***/
                     ELSE
                        display_text := y_table(ak_query_pkg.g_items_table(i).value_id);
                     END IF;

                     IF display_text is null THEN
                        display_text := htf.br;
                     END IF;
                     IF display_text = '-' THEN
                        display_text := htf.br;
                     END IF;
                     IF display_text = 'null' THEN
                        display_text := htf.br;
                     END IF;
                     IF display_text = '-1' THEN
                        display_text := htf.br;
                     END IF;


                     -- Display item_description as a link and a tabledata
                     IF (ak_query_pkg.g_items_table(i).attribute_code = 'ICX_ITEM_DESCRIPTION') THEN
                        v_item_url := y_table(v_item_url_ind);
                        display_text := ICX_REQ_NAVIGATION.addURL(v_item_url, display_text);
                     END IF;

                      -- Display source_name as a link
                      IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_NAME' THEN
                         v_supplier_url := y_table(v_supplier_url_ind);
                         display_text := ICX_REQ_NAVIGATION.addURL(v_supplier_url, display_text);
                      END IF;

                      -- Display supplier item number as a link
                      IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_SUGGESTED_VENDOR_ITEM_NUM' THEN
                         v_supplier_item_url := y_table(v_supplier_item_url_ind);
                         display_text := ICX_REQ_NAVIGATION.addURL(v_supplier_item_url, display_text);
                      END IF;

                      -- Bold
                      IF ak_query_pkg.g_items_table(i).bold = 'Y' THEN
           	             display_text := htf.bold(display_text);
                      END IF;

                      -- Italics
                      IF ak_query_pkg.g_items_table(i).italic = 'Y' THEN
     	                   display_text := htf.italic(display_text);
           	      END IF;

                      temp_table := temp_table ||
                                       htf.tableData( cvalue   => display_text,
                                                     calign   => ak_query_pkg.g_items_table(i).horizontal_alignment,
                                                     crowspan => '2',
                                                     cattributes => ' VALIGN=' || ak_query_pkg.g_items_table(i).vertical_alignment
                                                   );

             END IF; /* if value_id is not null */
       END LOOP;  -- for i in 1 .. ak_query_pkg.g_items_table.first loop

       temp_table := temp_table || htf.tableRowClose;

       --print the down button
       display_text := htf.tableRowOpen( cattributes => 'BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW')||'"');

       display_text := htf.tableRowOpen( cattributes => 'BGColor="#'||icx_util.get_color('TABLE_DATA_MULTIROW')||'"');


       display_text := display_text
	 || '<TD WIDTH=18 valign=top><a href="javascript:parent.parent.parent.down(document.template_items.elements['
	 || l_spin_pos
	 || '])" onMouseOver="window.status=''Reduce Quantity'';return true"><IMG SRC=/OA_MEDIA/'
	 || v_lang || '/FNDISPND.gif  BORDER=0></a>';

       display_text := display_text || '</TD>';
       display_text := display_text || htf.tableRowClose;
       temp_table := temp_table ||  display_text;

       htp.p(temp_table);

       counter := counter + 1;

     END LOOP;  -- for j in 1 .. g_results_table.COUNT loop

     htp.tableClose;




     htp.p('</FORM>');
     htp.bodyClose;
     htp.htmlClose;

END IF; /* validate session */
EXCEPTION
WHEN OTHERS THEN
   icx_util.add_error(substr(SQLERRM, 12, 512));
   icx_util.error_page_print;

END template_items_display;


PROCEDURE submit_items ( cartId IN NUMBER,
                        p_start_row      IN NUMBER DEFAULT 1,
		        p_end_row        IN NUMBER DEFAULT NULL,
		        p_where          IN VARCHAR2,
                        v_express_name   IN VARCHAR2,
	                p_emergency          IN NUMBER DEFAULT NULL,
                        end_row          IN NUMBER DEFAULT NULL,
                        p_query_set      IN NUMBER DEFAULT NULL,
                        p_row_count      IN NUMBER DEFAULT NULL,
                        Quantity         IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                        v_sequence_num   IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty) IS

  l_cart_id NUMBER := NULL;
  l_emergency varchar2(10);
  l_line_id NUMBER;
  l_num_rows NUMBER;
  l_cart_line_id number;
  l_shopper_id number;
  l_org_id number;
  l_qty number;
  v_org  number;
  params icx_on_utilities.v80_table;
  l_pad number;

  -- temp variables used to query deliver-to-requestor-info
  v_requestor_id number;
  v_requestor_name VARCHAR2(80);
  d_location_id NUMBER;
  d_location_code VARCHAR2(40);
  d_org_id NUMBER;
  d_org_code VARCHAR2(40);


  CURSOR check_cart_line_exists(v_cart_id number,v_sequence_num number,
                                v_org_id number, v_express_name varchar2) IS
  SELECT cart_line_id
  FROM  icx_shopping_cart_lines
  WHERE cart_id = v_cart_id
  AND   line_id = v_sequence_num
  AND   express_name = v_express_name
  AND   NVL(org_id, -9999) = NVL(v_org_id,-9999);

  CURSOR get_cart_header_info(v_cart_id number) IS
  SELECT need_by_date,
         deliver_to_requestor_id,
         deliver_to_location_id,
         destination_organization_id,
         deliver_to_location,
         created_by,
         org_id
  FROM  icx_shopping_carts
  WHERE cart_id = v_cart_id
  FOR UPDATE;

  l_need_by_date date;
  l_deliver_to_location_id number;
  l_dest_org_id number;
  l_rows_added NUMBER := 0;
  l_qty_added NUMBER := 0;
  l_qty_updated NUMBER := 0;
  l_rows_updated NUMBER := 0;
  l_deliver_to_location VARCHAR2(240);
  l_created_by NUMBER := NULL;
  l_order_total NUMBER := 0;
  v_cart_line_number NUMBER := NULL;

  l_emp_id number;
  l_account_id NUMBER := NULL;
  l_account_num VARCHAR2(2000) := NULL;
  l_segments fnd_flex_ext.SegmentArray;

BEGIN

  IF icx_sec.validateSession THEN

    icx_util.error_page_setup;

    l_cart_id := to_number(icx_call.decrypt2(cartId));
    l_emergency := icx_call.decrypt2(p_emergency);
    l_rows_added := 0;
    l_rows_updated := 0;
    l_num_rows := Quantity.COUNT;
    l_shopper_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
    -- l_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);

    IF p_where IS NOT NULL THEN
        icx_on_utilities.unpack_parameters(icx_call.decrypt2(p_where), params);
        v_org := params(2);
    END IF;

    IF cartId IS NOT NULL THEN
       OPEN get_cart_header_info(l_cart_id);
       FETCH get_cart_header_info INTO l_need_by_date, l_emp_id,
                                       l_deliver_to_location_id,
                                       l_dest_org_id, l_deliver_to_location,
                                       l_created_by, l_org_id;
       CLOSE get_cart_header_info;
    END IF;

    /* Select the max of the cart_line_number for ordering */
    SELECT max(cart_line_number) + 1 into v_cart_line_number
    FROM icx_shopping_cart_lines
    WHERE cart_id = l_cart_id;

    IF v_cart_line_number IS NULL THEN
     /* This is the first one  */
     v_cart_line_number := 1;
    END IF;

    FOR i IN 1 .. l_num_rows LOOP

    l_pad := instr(Quantity(i),'.',1,2);
    if (l_pad > 2) then
       l_qty := substr(Quantity(i),1,l_pad - 1);
    elsif (l_pad > 0) then
       l_qty := 0;
    else
       l_qty := Quantity(i);
    end if;

      IF l_qty IS NOT NULL AND l_qty > 0 THEN

        l_cart_line_id := NULL;
        OPEN check_cart_line_exists(l_cart_id, v_sequence_num(i), l_org_id,
                                    v_express_name);
        FETCH check_cart_line_exists into l_cart_line_id;
        CLOSE check_cart_line_exists;


        IF l_cart_line_id IS NULL THEN

          l_line_id := v_sequence_num(i);

--changed by alex for attachment
--          select icx_shopping_cart_lines_s.nextval into l_cart_line_id
--          from dual;
--new code:
          select PO_REQUISITION_LINES_S.nextval into l_cart_line_id
	    from dual;
	  /* get contact id for deliver_to_requestor */
	  v_requestor_id := icx_sec.getID(icx_sec.PV_INT_CONTACT_ID);

	  ICX_REQ_NAVIGATION.shopper_info(v_requestor_id,
					  v_requestor_name,
					  d_location_id,
					  d_location_code,
					  d_org_id,
					  d_org_code);

          INSERT INTO icx_shopping_cart_lines
	    (cart_line_id,
	     cart_id,
	     creation_date,
	     created_by,
	     quantity,
	     line_id,
	     item_id,
	     item_revision,
	     unit_of_measure,
	     unit_price,
	     category_id,
	     line_type_id,
	     item_description,
	     destination_organization_id,
	     deliver_to_location_id,
	     suggested_buyer_id,
	     suggested_vendor_name,
	     suggested_vendor_site,
	     need_by_date,
	     suggested_vendor_contact,
	     suggested_vendor_phone,
	     suggested_vendor_item_num,
	     -- supplier_item_num, Obselate?
	     last_update_date,
	     last_updated_by,
	     org_id,
	     express_name,
	     item_number,
	     deliver_to_location,
	     custom_defaulted,
	     cart_line_number,
	     autosource_doc_header_id,
	     autosource_doc_line_num
	     --	     ,deliver_to_requestor,
	     --	     deliver_to_requestor_id
	     )
	    SELECT /* into icx_shopping_cart_lines */
	    l_cart_line_id,
	    l_cart_id,
	    sysdate,
	    l_shopper_id,
	    l_qty,
	    l_line_id,
	    prl.item_id,
	    prl.item_revision,
	    prl.unit_meas_lookup_code,
	    DECODE(ROUND(NVL(pl.unit_price, 0)*NVL(ph.rate,1),5),0,
		   NVL(prl.unit_price, 0), ROUND(NVL(pl.unit_price,0)*
						 NVL(ph.rate,1), 5)),
	    prl.category_id,
	    prl.line_type_id,
	    prl.item_description,
	    l_dest_org_id,
	    l_deliver_to_location_id,
	    prl.suggested_buyer_id,
	    pv.vendor_name,
	    pvs.vendor_site_code,
	    l_need_by_date,
	    DECODE(prl.suggested_vendor_contact_id, NULL, NULL,
		   pvc.last_name ||',' ||pvc.first_name),
	    pvc.phone,
	    prl.suggested_vendor_product_code,
	    -- supplier item num ?
	    sysdate,
	    l_shopper_id,
	    l_org_id,
	    v_express_name,
	    msi.concatenated_segments,
	    l_deliver_to_location,
	    'N',
	    v_cart_line_number,
	    prl.po_header_id,
	    pl.line_num
--	    ,v_requestor_name
--	    ,v_requestor_id
	    FROM po_reqexpress_headers prh,
	    po_reqexpress_lines prl,
	    mtl_system_items_kfv msi,
	    po_vendor_contacts pvc,
	    po_vendor_sites pvs,
	    po_vendors pv,
	    po_headers ph,
	    po_lines pl
	    WHERE prh.express_name = prl.express_name
	    AND   prl.suggested_vendor_id = pv.vendor_id(+)
	    AND   prl.suggested_vendor_site_id = pvs.vendor_site_id(+)
	    AND   prl.suggested_vendor_contact_id = pvc.vendor_contact_id(+)
	    AND   prl.po_header_id = ph.po_header_id(+)
	    AND   nvl(ph.po_header_id, -1) = nvl(pl.po_header_id, -1)
	    AND   prl.po_line_id = pl.po_line_id(+)
	    AND   prl.source_type_code = 'VENDOR'
	    AND   prl.item_id is not null
	      AND   prl.item_id = msi.inventory_item_id
	      AND   msi.purchasing_enabled_flag = 'Y'
	      AND   prl.express_name = v_express_name
	      AND   prl.sequence_num = to_number(l_line_id)
	      AND   msi.organization_id = v_org
	      UNION
	      SELECT
	      l_cart_line_id,
	      l_cart_id,
	      sysdate,
	      l_shopper_id,
	      l_qty,
	      l_line_id,
	      prl.item_id,
	      prl.item_revision,
	      prl.unit_meas_lookup_code,
	      DECODE(ROUND(NVL(pl.unit_price, 0)*NVL(ph.rate,1),5),0,
		     NVL(prl.unit_price, 0), ROUND(NVL(pl.unit_price,0)*
						   NVL(ph.rate,1), 5)),
	      prl.category_id,
	      prl.line_type_id,
	      prl.item_description,
	      l_dest_org_id,
	      l_deliver_to_location_id,
	      prl.suggested_buyer_id,
	      pv.vendor_name,
	      pvs.vendor_site_code,
	      l_need_by_date,
	      DECODE(prl.suggested_vendor_contact_id, NULL, NULL,
		     pvc.last_name ||',' ||pvc.first_name),
	      pvc.phone,
	      prl.suggested_vendor_product_code,
	      -- supplier item num ?
	      sysdate,
	      l_shopper_id,
	      l_org_id,
	      v_express_name,
	      NULL,
	      l_deliver_to_location,
	      'N',
	      v_cart_line_number,
	      prl.po_header_id,
	      pl.line_num
--	      ,v_requestor_name
--	      ,v_requestor_id
	      FROM po_reqexpress_headers prh,
	      po_reqexpress_lines prl,
	      po_vendor_contacts pvc,
	      po_vendor_sites pvs,
	      po_vendors pv,
	      po_headers ph,
	      po_lines pl
	      WHERE prh.express_name = prl.express_name
	      AND   prl.suggested_vendor_id = pv.vendor_id(+)
	      AND   prl.suggested_vendor_site_id = pvs.vendor_site_id(+)
	      AND   prl.suggested_vendor_contact_id = pvc.vendor_contact_id(+)
	      AND   prl.po_header_id = ph.po_header_id(+)
	      AND   nvl(ph.po_header_id, -1) = nvl(pl.po_header_id, -1)
	      AND   prl.po_line_id = pl.po_line_id(+)
	      AND   prl.source_type_code = 'VENDOR'
	      AND   prl.item_id is null
		AND   prl.express_name = v_express_name
		AND   prl.sequence_num = to_number(l_line_id);
	      /* end of insert into icx_shopping_cart_lines */

          -- Get the default accounts and update distributions
          icx_req_acct2.get_default_account(l_cart_id,l_cart_line_id,
                        l_emp_id,l_org_id,l_account_id,l_account_num);

          l_rows_added := l_rows_added + 1;
          l_qty_added  := l_qty_added + l_qty;
          v_cart_line_number := v_cart_line_number + 1;

         ELSE

           UPDATE icx_shopping_cart_lines
           SET quantity = quantity + l_qty,
               last_update_date = sysdate,
               last_updated_by   = l_shopper_id
           WHERE cart_id = l_cart_id
           AND   cart_line_id = l_cart_line_id;

           l_rows_updated := l_rows_updated + 1;
           l_qty_updated  := l_qty_updated + l_qty;
         END IF;

        END IF;

    END LOOP;

    COMMIT;

    /* Call Custom defaults */
    if l_emergency is not NULL and l_emergency = 'YES' then
       icx_req_custom.reqs_default_lines('YES', l_cart_id);
    else
       icx_req_custom.reqs_default_lines('NO', l_cart_id);
    end if;

    /* get the order total; do this after custom defaults as it clould
       modify the price or quantity */
    SELECT SUM(quantity * unit_price) INTO l_order_total
    FROM  icx_shopping_cart_lines
    WHERE cart_id = l_cart_id;

    total_page(l_rows_added,l_rows_updated, l_qty_added, l_qty_updated,
                l_order_total, l_dest_org_id, v_express_name,
                p_start_row, p_end_row, p_where,
                end_row, p_query_set, p_row_count);

  END IF; /* validate session */

EXCEPTION

 WHEN OTHERS THEN
    -- htp.p('Error in Submit Items.');
    -- htp.br;
    -- htp.p(substr(SQLERRM, 1, 512));
    -- htp.br;
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END submit_items;

PROCEDURE total_page(l_rows_added number default 0,
                     l_rows_updated number default 0,
                     l_qty_added number default 0,
                     l_qty_updated number default 0,
                     l_order_total number default 0,
                     l_dest_org_id number,
                     v_express_name VARCHAR2 default null,
                     p_start_row NUMBER DEFAULT 1,
                     p_end_row NUMBER DEFAULT NULL,
                     p_where   VARCHAR2,
                     end_row NUMBER DEFAULT NULL,
                     p_query_set NUMBER DEFAULT NULL,
                     p_row_count NUMBER DEFAULT NULL) IS

 l_add_message    varchar2(500) := '';
 l_update_message varchar2(500) := '';
 l_print_message  varchar2(1100) := '';
 l_order_total_message  varchar2(1100) := '';

 l_template_selected_message  varchar2(200) := '';
 l_return_to_current_message  varchar2(200) := '';
 l_return_to_next_message  varchar2(200) := '';
 v_icx_template VARCHAR2(200):= NULL;
 l_navigation_message  varchar2(2000) := '';

 v_order_total    varchar2(30) := '';

 l_currency       VARCHAR2(15);
 l_precision      NUMBER(1);
 l_fmt_mask       VARCHAR2(32);
 v_dcd_name       VARCHAR2(1000) := owa_util.get_cgi_env('SCRIPT_NAME');
 next_start_row   NUMBER := NULL;
 next_end_row     NUMBER := NULL;

BEGIN

   /* get the currency code */
   icx_req_navigation.get_currency(l_dest_org_id, l_currency,
                                   l_precision, l_fmt_mask);

   FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_NEW');
   FND_MESSAGE.SET_TOKEN('ITEM_QUANTITY', l_rows_added);
   l_add_message := FND_MESSAGE.GET;
   l_print_message := l_add_message;

   IF l_rows_updated > 0 THEN
      FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_UPDATE');
      FND_MESSAGE.SET_TOKEN('ITEM_QUANTITY', l_rows_updated);
      l_update_message := FND_MESSAGE.GET;
      IF l_rows_added > 0 THEN
         l_print_message := l_add_message || '<BR>' || l_update_message;
      ELSE
         l_print_message := l_update_message;
      END IF;
   END IF;

   /* Build the new order total message */
   FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_TOTAL');
   FND_MESSAGE.SET_TOKEN('CURRENCY_CODE', l_currency);
   v_order_total := to_char(to_number(l_order_total), fnd_currency.get_format_mask(l_currency, 30));
   FND_MESSAGE.SET_TOKEN('REQUISITION_TOTAL', v_order_total);
   l_order_total_message := FND_MESSAGE.GET;

   /* 'Seleted from template' message */
   FND_MESSAGE.SET_NAME('ICX', 'ICX_TEMPLATE');
   v_icx_template := FND_MESSAGE.GET;
   FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_SOURCE');
   FND_MESSAGE.SET_TOKEN('SOURCE_NAME', v_icx_template || ' ' || v_express_name);
   l_template_selected_message := FND_MESSAGE.GET;

   /* 'Return to current set' message */
   FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_RETURN_CURRENT');
   l_return_to_current_message := FND_MESSAGE.GET;

   /* 'Return to next set' message */
   FND_MESSAGE.SET_NAME('ICX','ICX_ITEM_ADD_RETURN_NEXT');
   l_return_to_next_message := FND_MESSAGE.GET;


   htp.bodyOpen('','BGCOLOR="#FFCCCC" onLoad="top.winOpen(''nav'', ''template'')"');

   htp.p('<H3>');
   htp.p(l_print_message);
   htp.br;
   htp.br; -- add line between update and total message
   htp.p(l_order_total_message);
   htp.br;
   htp.br; -- leave two line between the messages
   htp.br;
   htp.p(l_template_selected_message);
   l_navigation_message := '<TABLE BORDER=0><TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="' || v_dcd_name ||
'/ICX_REQ_TEMPLATES.template_items?p_start_row=' || p_start_row || '&p_end_row=' || p_end_row || '&p_where=' || p_where || '">' ||  l_return_to_current_message || '</A></B></TD></TR>';
/*
   htp.p('<DL>');
   htp.p('<DT>' || l_template_selected_message);
   htp.p('<DL>');
   htp.p('<DT>' || '<A HREF="' || v_dcd_name || '/ICX_REQ_TEMPLATES.template_items?p_start_row=' || p_start_row || '&p_end_row='|| p_end_row || '&p_where=' || p_where ||  '">'  || l_return_to_current_message || '</A>');
   htp.p('</DL>');
*/

   /* find next set start row and next set end row */
      if end_row < p_row_count
         and p_query_set is not NULL then

         next_start_row := end_row+1;
         if end_row+p_query_set > p_row_count then
             next_end_row := p_row_count;
         else
             next_end_row := end_row+p_query_set;
         end if;
         l_navigation_message := l_navigation_message || '<TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="' || v_dcd_name ||
'/ICX_REQ_TEMPLATES.template_items?p_start_row=' || next_start_row || '&p_end_row=' || next_end_row || '&p_where=' || p_where || '">' || l_return_to_next_message || '</A></B></TD></TR>';


/*
         htp.p('<DL>');
         htp.p('<DT>' || '<A HREF="' || v_dcd_name || '/ICX_REQ_TEMPLATES.template_items?p_start_row=' || next_start_row || '&p_end_row='|| next_end_row || '&p_where=' || p_where ||  '">'  || l_return_to_next_message || '</A>');

   -- htp.p('<DT>' || l_return_to_next_message);
         htp.p('</DL>');
*/

      end if;

      -- MESSAGE NEEDS TO BE SWITCHED TO REVIEW MY ORDER
      FND_MESSAGE.SET_NAME('ICX','ICX_REVIEW_ORDER');
      l_return_to_next_message := FND_MESSAGE.GET;
      l_navigation_message := l_navigation_message || '<TR><TD><BR></TD><TD><BR></TD><TD><BR></TD><TD NOWRAP>' || '<B><A HREF="javascript:parent.parent.parent.switchFrames(''my_order'')">' || l_return_to_next_message || '</A></B></TD></TR>';


      l_navigation_message := l_navigation_message || '</TABLE>';


   -- htp.p('</DL>');
   htp.p(l_navigation_message);
   htp.p('</H3>');

   htp.bodyClose;


EXCEPTION

 WHEN OTHERS THEN
    -- htp.p('Error in Total print message page.');
    -- htp.br;
    -- htp.p(substr(SQLERRM, 1, 512));
    -- htp.br;
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;
END total_page;

end ICX_REQ_TEMPLATES;

/
