--------------------------------------------------------
--  DDL for Package Body CZ_UI_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_UI_MGR" as
/*  $Header: czuimgrb.pls 120.2.12010000.2 2008/12/09 14:52:48 lamrute ship $	*/




/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure ASSESS_DATA is
begin
null;
end;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_STATISTICS is
begin
CZ_BASE_MGR.REDO_STATISTICS('UI');
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure TRIGGERS_ENABLED
(Switch in varchar2) is
begin
CZ_BASE_MGR.TRIGGERS_ENABLED('UI',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure CONSTRAINTS_ENABLED
(Switch in varchar2) is
begin
CZ_BASE_MGR.CONSTRAINTS_ENABLED('UI',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2,
 incr           in integer default null) is
begin
CZ_BASE_MGR.REDO_SEQUENCES('UI',RedoStart_Flag,incr);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure Propogate_DeletedFlag is

Type UI_type is table of CZ_UI_DEFS.ui_def_id%TYPE;
UIs  UI_type;
v_ui integer;

begin


for n in(select ui_node_id from cz_ui_nodes where ui_def_id=v_ui and deleted_flag='1')
loop
   for m in(select  ui_node_id from cz_ui_nodes
            start with ui_node_id=n.ui_node_id
            connect by prior ui_node_id=parent_id)
   loop
      update cz_ui_nodes
      set deleted_flag='1' where ui_def_id=v_ui and ui_node_id=m.ui_node_id;

      update cz_ui_node_props
      set deleted_flag='1' where ui_def_id=v_ui and ui_node_id=m.ui_node_id;
      commit;
   end loop;
end loop;

select ui_def_id bulk collect into UIs
from CZ_UI_DEFS where (devl_project_id in(select devl_project_id from cz_devl_projects where
deleted_flag='1' and devl_project_id<>0) or deleted_flag='1') and NVL(seeded_flag,'0')='0' and ui_def_id<>0;

if UIs.Count>0 then
   for i in UIs.First..UIs.Last
   loop
      v_ui:=UIs(i);

      update cz_ui_defs
      set deleted_flag='1' where ui_def_id=v_ui;
      commit;

      update cz_ui_properties
      set deleted_flag='1' where ui_def_id=v_ui;
      commit;

      for n in(select ui_node_id from cz_ui_nodes where ui_def_id=v_ui)
      loop

          update cz_ui_nodes
          set deleted_flag='1' where ui_def_id=v_ui and ui_node_id=n.ui_node_id;

          update cz_ui_node_props
          set deleted_flag='1' where ui_def_id=v_ui and ui_node_id=n.ui_node_id;
          commit;

      end loop;

     update cz_ui_page_elements
     set deleted_flag='1'
     where ui_def_id=v_ui;
     commit;

     update cz_ui_page_sets
     set deleted_flag='1'
     where ui_def_id=v_ui;
     commit;

     update cz_ui_page_refs
     set deleted_flag='1'
     where ui_def_id=v_ui;
     commit;

     update cz_ui_refs
     set deleted_flag='1'
     where ui_def_id=v_ui;
     commit;

     update cz_ui_actions
     set deleted_flag='1'
     where ui_def_id=v_ui and NVL(seeded_flag,'0')='0';
     commit;

     update cz_ui_templates
     set deleted_flag='1'
     where ui_def_id=v_ui and NVL(seeded_flag,'0')='0';
     commit;

     update cz_ui_ref_templates
     set deleted_flag='1'
     where template_ui_def_id=v_ui ;

     /*
     update cz_ui_images
     set deleted_flag='1'
     where ui_def_id=v_ui;
     commit;
     */
     delete from cz_ui_images
     where ui_def_id=v_ui and NVL(seeded_flag,'0')='0';

     update cz_ui_cont_type_templs
     set deleted_flag='1'
     where ui_def_id=v_ui;

     --
     -- drop jrad documents which associated with deleted pages
     --
     for k in(select jrad_doc from cz_ui_pages
              where ui_def_id=v_ui and NVL(seeded_flag,'0')='0' and deleted_flag='0')
     loop
        begin
            jdr_docbuilder.deleteDocument(k.jrad_doc);
        exception
            when others then
                 CZ_BASE_MGR.LOG_REPORT('CZ_UI_MGR.PURGE','deleteDocument "'||k.jrad_doc||'" : '||SQLERRM);
        end;
     end loop;

     update cz_ui_pages
     set deleted_flag='1'
     where ui_def_id=v_ui and NVL(seeded_flag,'0')='0';
     commit;

   end loop;
   commit;

   CZ_BASE_MGR.exec('update CZ_LOCALIZED_TEXTS a set deleted_flag=''1'' where deleted_flag=''0'' and NVL(seeded_flag,''0'')='''||'0'||''' AND '||
    'exists(select null from CZ_UI_NODES where caption_id=a.intl_text_id and deleted_flag=''1'') and '||
    'not exists(select null from CZ_UI_NODES where caption_id=a.intl_text_id and deleted_flag=''0'')');


end if;

CZ_BASE_MGR.exec('CZ_LOCALIZED_TEXTS','where deleted_flag=''0'' and '||
 'exists(select null from CZ_UI_NODES where caption_id=cz_localized_texts.intl_text_id and deleted_flag=''1'') and '||
 'not exists(select null from CZ_UI_NODES where caption_id=cz_localized_texts.intl_text_id and deleted_flag=''0'')',
'language','intl_text_id',TRUE);

COMMIT;

exception
when others then
     CZ_BASE_MGR.LOG_REPORT('CZ_UI_MGR.PURGE',SQLERRM);
end;

---->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----@Propagate_deleted_flag_for_global_entities
-----@This procedure handles the propagation of deleted flag for global entities
-----@global entities are global rules, actions, texts that are referred in
-----@global templates.  The global entities are stored in the table cz_ui_template_elements.
-----@The element type in the table cz_ui_template_elements are as follows:
-----@ element_type : 33,34,700 --- rule_id (cz_rules)
-----@ element_type : 8         --- caption text (cz_localized_texts)
-----@ element_type : 522       --- ui action (cz_ui_actions)

PROCEDURE Propagate_del_flag_gl_entities
IS

TYPE global_templates_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE global_jrad_docs_tbl IS TABLE OF CZ_UI_TEMPLATES.jrad_doc%TYPE INDEX BY BINARY_INTEGER;
l_gl_template_tbl    global_templates_tbl;
l_pb_gl_template_tbl global_templates_tbl;
l_gl_jrad_docs_tbl   global_jrad_docs_tbl;
l_pb_gl_jrad_docs_tbl global_jrad_docs_tbl;
l_element_id_tbl	   global_templates_tbl;
l_element_type_tbl   global_templates_tbl;
l_element_id_ref	   global_templates_tbl;
l_element_type_ref   global_templates_tbl;
l_templ_id_ref	   global_templates_tbl;
l_templ_id_tbl       global_templates_tbl;
rec_count		   NUMBER := 0;
l_return_status      VARCHAR2(1);
l_msg_count          NUMBER := 0;
l_msg_data      	   VARCHAR2(2000);

BEGIN

    ------collect source global templates from cz_ui_templates
    ------where ui_def_id = 0 and deleted_flag = '1' and seeded_flag = '0'
    l_gl_template_tbl.DELETE;
    SELECT template_id, jrad_doc
    BULK
    COLLECT
    INTO   l_gl_template_tbl, l_gl_jrad_docs_tbl
    FROM   cz_ui_templates
    WHERE  cz_ui_templates.deleted_flag = '1'
    AND    cz_ui_templates.seeded_flag  = '0'
    AND    cz_ui_templates.ui_def_id    =  0;

    -----collect published global templates that are candidates
    -----for deletion.
    -----The published global templates that are candidates for
    -----deletion have
    ------ ui_def_id = 1 and have no valid entry (deleted_flag = '0')
    ------ in cz_model_publications


    l_pb_gl_template_tbl.DELETE;
    SELECT template_id  BULK COLLECT
    INTO   l_pb_gl_template_tbl
    FROM   cz_ui_templates
    WHERE  cz_ui_templates.seeded_flag  = '0'
    AND    cz_ui_templates.ui_def_id    =  1
    AND    cz_ui_templates.template_id NOT IN (SELECT object_id
							     FROM   cz_model_publications
							     WHERE  object_type   = 'UIT'
								AND   deleted_flag  = '0'
								AND   ui_def_id     = 1
								AND   source_target_flag = 'T');

    ----gather the published global templates marked for deletion
    ----into a single array
    IF (l_pb_gl_template_tbl.COUNT > 0) THEN
      rec_count := l_gl_template_tbl.COUNT;
	FOR I IN l_pb_gl_template_tbl.FIRST..l_pb_gl_template_tbl.LAST
	LOOP
		rec_count := rec_count + 1;
		l_gl_template_tbl(rec_count) := l_pb_gl_template_tbl(i);
	END LOOP;
    END IF;

    -----collect published template jrad docs that are candidates for deletion and
    -----are not part of valid publication
    SELECT jrad_doc   BULK COLLECT INTO  l_pb_gl_jrad_docs_tbl
    FROM   cz_ui_templates t0
    WHERE  t0.seeded_flag  = '0'
    AND    t0.ui_def_id    =  1
    AND NOT EXISTS (SELECT 1 FROM cz_model_publications
                    WHERE  object_type   = 'UIT'
                    AND   deleted_flag  = '0'
                    AND   ui_def_id     = 1
                    AND   source_target_flag = 'T'
                    AND object_id = t0.template_id)
    AND NOT EXISTS (SELECT 1 FROM   cz_ui_templates t
                    WHERE  t.seeded_flag  = '0'
                    AND    t.ui_def_id    =  1
                    AND EXISTS (SELECT 1 FROM   cz_model_publications
                                WHERE  object_type   = 'UIT'
                                AND   deleted_flag  = '0'
                                AND   ui_def_id     = 1
                                AND   source_target_flag = 'T'
                                AND object_id = t.template_id)
                    AND t.jrad_doc = t0.jrad_doc) ;

    ----gather the published global templates marked for deletion
    ----into a single array
    IF (l_gl_jrad_docs_tbl.COUNT > 0) THEN
      rec_count := l_gl_jrad_docs_tbl.COUNT;
        FOR I IN l_pb_gl_jrad_docs_tbl.FIRST..l_pb_gl_jrad_docs_tbl.LAST
        LOOP
            rec_count := rec_count + 1;
            l_gl_jrad_docs_tbl(rec_count):= l_pb_gl_jrad_docs_tbl(i);
        END LOOP;
    END IF;



    -----For each template id in the array l_gl_template_tbl, collect element id(s)
    -----and element types from cz_ui_template_elements that have seeded_flag = '0'
    IF (l_gl_template_tbl.COUNT > 0) THEN
      l_element_id_ref.DELETE;
	l_element_type_ref.DELETE;
	l_templ_id_ref.DELETE;
	FOR I IN l_gl_template_tbl.FIRST..l_gl_template_tbl.LAST
	LOOP
	    l_element_id_tbl.DELETE;
          l_element_type_tbl.DELETE;
	    l_templ_id_tbl.DELETE;
	    SELECT element_id,element_type,template_id
	     BULK
	    COLLECT
		INTO l_element_id_tbl,l_element_type_tbl,l_templ_id_tbl
	     FROM  cz_ui_template_elements
	    WHERE  cz_ui_template_elements.template_id = l_gl_template_tbl(i)
	     AND   cz_ui_template_elements.seeded_flag = '0';

	    IF (l_element_id_tbl.COUNT > 0) THEN
		 rec_count := l_element_id_ref.COUNT;
		 FOR J IN l_element_id_tbl.FIRST..l_element_id_tbl.LAST
             LOOP
			rec_count := rec_count + 1;
			l_element_id_ref(rec_count)   := l_element_id_tbl(j);
			l_element_type_ref(rec_count) := l_element_type_tbl(j);
			l_templ_id_ref(rec_count)     := l_templ_id_tbl(j);
		 END LOOP;
	    END IF;

          UPDATE cz_ui_template_elements
		 SET deleted_flag = '1'
           WHERE template_id  = l_gl_template_tbl(i)
		     AND seeded_flag = '0';

	END LOOP;
    END IF;

    -- Delete JRAD documents from JDR repository
    IF (l_gl_jrad_docs_tbl.COUNT > 0) THEN
        FOR I IN l_gl_jrad_docs_tbl.FIRST..l_gl_jrad_docs_tbl.LAST
        LOOP
          BEGIN
              jdr_docbuilder.deleteDocument(l_gl_jrad_docs_tbl(i));
          EXCEPTION
              WHEN OTHERS THEN
                 CZ_BASE_MGR.LOG_REPORT('CZ_UI_MGR.PURGE','deleteDocument "'||l_gl_jrad_docs_tbl(i)||'" : '||SQLERRM);
          END;
        END LOOP;
    END IF;


    -----For each element id update the relevant table
    IF (l_element_id_ref.COUNT > 0) THEN
	FOR I IN l_element_id_ref.FIRST..l_element_id_ref.LAST
	LOOP
		IF (l_element_type_ref(i) IN (33,34,700)) THEN
			UPDATE cz_rules
			SET    deleted_flag = '1'
			WHERE  rule_id = l_element_id_ref(i)
			AND seeded_flag = '0';
		ELSIF (l_element_type_ref(i) = 8) THEN
			UPDATE cz_localized_texts
			SET    deleted_flag = '1'
			WHERE  intl_text_id = l_element_id_ref(i)
			AND seeded_flag = '0';
		ELSIF (l_element_type_ref(i) = 522) THEN
			UPDATE cz_ui_actions
			SET    deleted_flag = '1'
			WHERE  ui_action_id = l_element_id_ref(i)
			AND seeded_flag = '0';
		END IF;
	END LOOP;
    END IF;
COMMIT;
exception
when others then
     CZ_BASE_MGR.LOG_REPORT('CZ_UI_MGR.PURGE',SQLERRM);
end;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure PURGE is
begin
Propogate_DeletedFlag;
Propagate_del_flag_gl_entities;
CZ_BASE_MGR.PURGE('UI');
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure RESET_CLEAR is
begin
null;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure MODIFIED
(AS_OF in OUT NOCOPY date) is
begin
CZ_BASE_MGR.MODIFIED('UI',AS_OF);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

end;

/
