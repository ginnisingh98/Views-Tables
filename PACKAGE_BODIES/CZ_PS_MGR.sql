--------------------------------------------------------
--  DDL for Package Body CZ_PS_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PS_MGR" as
/*  $Header: czpsmgrb.pls 120.4 2006/06/29 16:06:59 skudryav ship $	*/


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
CZ_BASE_MGR.REDO_STATISTICS('PS');
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure TRIGGERS_ENABLED
(Switch in varchar2) is
begin
  CZ_BASE_MGR.TRIGGERS_ENABLED('PS',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure CONSTRAINTS_ENABLED
(Switch in varchar2) is
begin
  CZ_BASE_MGR.CONSTRAINTS_ENABLED('PS',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2 , -- default '0',
 incr           in integer default null) is
begin
  CZ_BASE_MGR.REDO_SEQUENCES('PS',RedoStart_Flag,incr);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_Orphaned_Nodes IS
    TYPE t_arr      IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
    t_devl_project_id t_arr;
    t_ps_node_id      t_arr;
    t_intl_text_id    t_arr;
    t_rule_id         t_arr;
    t_reason_id       t_arr;
BEGIN

    BEGIN

        SELECT DISTINCT devl_project_id
        BULK COLLECT INTO t_devl_project_id
        FROM CZ_PS_NODES a WHERE NOT EXISTS
        (SELECT devl_project_id FROM CZ_DEVL_PROJECTS WHERE devl_project_id=a.devl_project_id
         AND deleted_flag='0') AND devl_project_id NOT IN(0,1);

        DECLARE
          CURSOR C1 IS
          SELECT ps_node_id,intl_text_id
          FROM CZ_PS_NODES a WHERE NOT EXISTS
          (SELECT devl_project_id FROM CZ_DEVL_PROJECTS WHERE devl_project_id=a.devl_project_id
           AND deleted_flag='0') AND devl_project_id NOT IN(0,1);
        BEGIN
          OPEN C1;
          LOOP
             t_ps_node_id.delete; t_intl_text_id.delete;
             FETCH C1 BULK COLLECT INTO t_ps_node_id,t_intl_text_id LIMIT CZ_BASE_MGR.BATCH_SIZE;
             EXIT WHEN C1%NOTFOUND AND t_ps_node_id.COUNT = 0;
             IF t_ps_node_id.Count>0 THEN
               FORALL i IN t_ps_node_id.First..t_ps_node_id.Last
                  UPDATE CZ_PS_NODES SET deleted_flag='1'
                  WHERE ps_node_id=t_ps_node_id(i);
               COMMIT;
             END IF;
             IF t_intl_text_id.Count>0 THEN
               FORALL i IN t_intl_text_id.First..t_intl_text_id.Last
                  DELETE FROM CZ_LOCALIZED_TEXTS a
		  WHERE a.intl_text_id=t_intl_text_id(i)  AND a.seeded_flag<>'1'
		  AND not exists (SELECT null FROM CZ_PS_NODES b
		                  WHERE b.deleted_flag='0'
		                  and b.intl_text_id = a.intl_text_id);
               COMMIT;
             END IF;
             IF t_ps_node_id.Count>0 THEN
               FORALL i IN t_ps_node_id.First..t_ps_node_id.Last
                  UPDATE CZ_LCE_HEADERS SET deleted_flag='1'
                  WHERE component_id=t_ps_node_id(i);
               COMMIT;
             END IF;
          END LOOP;
          CLOSE C1;
        END;
        IF t_devl_project_id.Count>0 THEN
              FORALL i IN t_devl_project_id.First..t_devl_project_id.Last
                  UPDATE CZ_RULES SET deleted_flag='1'
                  WHERE devl_project_id=t_devl_project_id(i);
           COMMIT;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            CZ_BASE_MGR.LOG_REPORT('CZ_PS_MGR.delete_Orphaned_Nodes',SQLERRM );
            raise;
    END;

    DECLARE
       CURSOR C1 IS
       SELECT rule_id,reason_id
       FROM CZ_RULES a
       WHERE NOT EXISTS
       (SELECT devl_project_id FROM CZ_DEVL_PROJECTS WHERE devl_project_id=a.devl_project_id
        AND deleted_flag='0') AND a.seeded_flag<>'1' AND devl_project_id NOT IN(0,1);

    BEGIN
       OPEN C1;
       LOOP
         t_rule_id.delete; t_reason_id.delete;
         FETCH C1 BULK COLLECT INTO t_rule_id,t_reason_id
         LIMIT CZ_BASE_MGR.BATCH_SIZE;
         EXIT WHEN C1%NOTFOUND AND t_rule_id.COUNT = 0;

         IF t_reason_id.Count>0 THEN
            FORALL i IN t_reason_id.First..t_reason_id.Last
                   DELETE FROM CZ_LOCALIZED_TEXTS
                   WHERE intl_text_id=t_reason_id(i) AND seeded_flag<>'1';
            COMMIT;
         END IF;

         IF t_rule_id.Count>0 THEN
            FORALL i IN t_rule_id.First..t_rule_id.Last
                   UPDATE CZ_RULES SET deleted_flag='1'
                   WHERE rule_id=t_rule_id(i) AND seeded_flag<>'1';
            COMMIT;
         END IF;
       END LOOP;
       ClOSE C1;
    EXCEPTION
         WHEN OTHERS THEN
             CZ_BASE_MGR.LOG_REPORT('CZ_PS_MGR.delete_Orphaned_Nodes',SQLERRM );
                 raise;
    END;

         CZ_BASE_MGR.exec('CZ_PS_NODES','WHERE NOT EXISTS '||
         '(SELECT devl_project_id FROM CZ_DEVL_PROJECTS WHERE devl_project_id=cz_ps_nodes.devl_project_id)',
         'ps_node_id', FALSE);

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE update_deleted_flag(p_ps_node_id IN NUMBER) IS
BEGIN
  FOR child IN (SELECT ps_node_id FROM cz_ps_nodes WHERE parent_id = p_ps_node_id
                   AND deleted_flag = '0') LOOP

    UPDATE cz_ps_nodes SET deleted_flag = '1' WHERE ps_node_id = child.ps_node_id;
    update_deleted_flag(child.ps_node_id);
  END LOOP;
END update_deleted_flag;

procedure Propogate_DeletedFlag is

begin

CZ_BASE_MGR.exec('CZ_MODEL_REF_EXPLS','where deleted_flag='''||'0'||''' AND '||
                 'model_id in(select devl_project_id from cz_devl_projects where deleted_flag='''||'1'||''')',
                 'model_ref_expl_id',FALSE);

CZ_BASE_MGR.exec('CZ_PS_NODES','where deleted_flag='''||'0'||''' AND '||
                 'devl_project_id in(select devl_project_id from cz_devl_projects where deleted_flag='''||'1'||''')',
                 'ps_node_id',FALSE);

-- necessary?
/*
for n in(select ps_node_id from cz_ps_nodes where deleted_flag='1')
  loop
     update cz_ps_nodes
     set deleted_flag='1' where deleted_flag='0' and ps_node_id in
     (select  ps_node_id from cz_ps_nodes
      start with ps_node_id=n.ps_node_id
      connect by prior ps_node_id=parent_id);
     commit;
  end loop;
*/

CZ_BASE_MGR.exec('CZ_RULE_FOLDERS','where deleted_flag='''||'0'||''' AND '||
                 'devl_project_id in(select devl_project_id from cz_devl_projects where deleted_flag=''1'' and devl_project_id NOT IN(0,1))',
                 'rule_folder_id','object_type',FALSE);


CZ_BASE_MGR.exec('CZ_RULES','where deleted_flag='''||'0'||''' AND seeded_flag<>'''||'1'||''' AND '||
                 'devl_project_id in(select devl_project_id from cz_devl_projects where deleted_flag=''1'' and devl_project_id NOT IN(0,1))',
                 'rule_id',FALSE);

CZ_BASE_MGR.exec('CZ_GRID_DEFS','where deleted_flag='''||'0'||''' AND '||
                 'devl_project_id in(select devl_project_id from cz_devl_projects where deleted_flag='''||'1'||''')',
                 'grid_id',FALSE);

CZ_BASE_MGR.exec('CZ_FUNC_COMP_SPECS','where deleted_flag='''||'0'||''' AND '||
                 'devl_project_id in(select devl_project_id from cz_devl_projects where deleted_flag='''||'1'||''')',
                 'func_comp_id',FALSE);

CZ_BASE_MGR.exec('CZ_COMBO_FEATURES','where deleted_flag='''||'0'||''' AND '||
                 'rule_id in(select rule_id from cz_rules where deleted_flag='''||'1'||''')',
                 'feature_id','model_ref_expl_id','rule_id',FALSE);

CZ_BASE_MGR.exec('CZ_POPULATORS','where deleted_flag='''||'0'||'''  AND seeded_flag<>'''||'1'||''' AND '||
                 'owned_by_node_id in(select ps_node_id from CZ_PS_NODES where deleted_flag='''||'1'||''')',
                 'populator_id',FALSE);

CZ_BASE_MGR.exec('CZ_PS_PROP_VALS','where deleted_flag='''||'0'||''' AND '||
                 'ps_node_id in(select ps_node_id from CZ_PS_NODES where deleted_flag='''||'1'||''')',
                 'property_id','ps_node_id',TRUE);

CZ_BASE_MGR.exec('CZ_SUB_CON_SETS','where deleted_flag='''||'0'||''' AND '||
                 'sub_cons_id in(select sub_cons_id from CZ_PS_NODES where deleted_flag='''||'1'||''')',
                 'sub_cons_id',FALSE);

CZ_BASE_MGR.exec('CZ_FILTER_SETS','where deleted_flag='''||'0'||''' AND '||
                 'rule_id in(select rule_id from CZ_RULES where deleted_flag='''||'1'||''')',
                 'filter_set_id',FALSE);

CZ_BASE_MGR.exec('CZ_EXPRESSION_NODES','where deleted_flag='''||'0'||''' AND seeded_flag<>'''||'1'||''' AND '||
                 'rule_id in(select rule_id from CZ_RULES where deleted_flag='''||'1'||''')',
                 'expr_node_id',TRUE);

CZ_BASE_MGR.exec('CZ_LCE_HEADERS','where deleted_flag='''||'0'||''' AND '||
                 'component_id in(select ps_node_id from CZ_PS_NODES where deleted_flag='''||'1'||''')',
                 'lce_header_id',FALSE);

CZ_BASE_MGR.exec('CZ_LCE_LOAD_SPECS','where deleted_flag='''||'0'||''' AND '||
                 'lce_header_id in(select lce_header_id from CZ_LCE_HEADERS where deleted_flag='''||'1'||''')',
                 'lce_header_id','attachment_expl_id','required_expl_id',TRUE);

CZ_BASE_MGR.exec('CZ_LCE_TEXTS','where '||
                 'lce_header_id in(select lce_header_id from CZ_LCE_HEADERS where deleted_flag='''||'1'||''')',
                 'lce_header_id','seq_nbr',TRUE);

CZ_BASE_MGR.exec('CZ_LOCALIZED_TEXTS','where deleted_flag=''0''  AND seeded_flag<>'''||'1'||''' AND '||
                 ' EXISTS(select NULL from CZ_PS_NODES where intl_text_id=cz_localized_texts.intl_text_id and deleted_flag=''1'''||
                 ') and not exists(select null from CZ_PS_NODES where intl_text_id=cz_localized_texts.intl_text_id and '||
                 ' deleted_flag=''0'')',
                 'language','intl_text_id',TRUE);

CZ_BASE_MGR.exec('CZ_LOCALIZED_TEXTS','where deleted_flag='''||'0'||'''  AND seeded_flag<>'''||'1'||''' AND '||
                 'exists (select reason_id from CZ_RULES where reason_id = cz_localized_texts.intl_text_id and deleted_flag='''||'1'||''') and '||
                 'not exists(select reason_id from CZ_RULES where reason_id=cz_localized_texts.intl_text_id and deleted_flag='''||'0'||''')',
                 'language','intl_text_id',TRUE);

CZ_BASE_MGR.exec('CZ_DES_CHART_CELLS','where deleted_flag='''||'0'||''' AND '||
                 'rule_id in(select rule_id from CZ_RULES where deleted_flag='''||'1'||''')',
                 'RULE_ID','PRIMARY_OPT_ID','SECONDARY_OPT_ID','SECONDARY_FEAT_EXPL_ID',TRUE);

CZ_BASE_MGR.exec('CZ_DES_CHART_COLUMNS','where '||
                 'rule_id in(select rule_id from CZ_RULES where deleted_flag='''||'1'||''')',
                 'rule_id','option_id',TRUE);

CZ_BASE_MGR.exec('CZ_DES_CHART_FEATURES','where deleted_flag='''||'0'||''' AND '||
                 'rule_id in(select rule_id from CZ_RULES where deleted_flag='''||'1'||''')',
                 'RULE_ID', 'FEATURE_ID', 'MODEL_REF_EXPL_ID', FALSE);

CZ_BASE_MGR.exec('CZ_ARCHIVE_REFS','where deleted_flag='''||'0'||''' AND '||
                 'archive_id in (select archive_id from cz_archives where deleted_flag='''||'1'||''')',
                 'DEVL_PROJECT_ID', 'SEQ_NBR', 'ARCHIVE_ID', FALSE);

CZ_BASE_MGR.exec('CZ_ARCHIVE_REFS','where deleted_flag='''||'0'||''' AND '||
                 'devl_project_id in (select devl_project_id from cz_devl_projects where deleted_flag='''||'1'||''')',
                 'DEVL_PROJECT_ID', 'SEQ_NBR', 'ARCHIVE_ID', FALSE);

CZ_BASE_MGR.exec('CZ_LOCALIZED_TEXTS','where deleted_flag='''||'0'||''' AND '||
                 'exists (select intl_text_id from CZ_DEVL_PROJECTS where intl_text_id = cz_localized_texts.intl_text_id and deleted_flag=''1'' and devl_project_id NOT IN(0,1))',
                 'language','intl_text_id',TRUE);

CZ_BASE_MGR.exec('CZ_LOCALIZED_TEXTS','where deleted_flag='''||'0'||''' AND '||
                 'exists (select violation_text_id from CZ_PS_NODES where violation_text_id = cz_localized_texts.intl_text_id and deleted_flag='''||'1'||''')',
                 'language','intl_text_id',TRUE);

CZ_BASE_MGR.exec('CZ_LOCALIZED_TEXTS','where deleted_flag='''||'0'||''' AND '||
                 'exists (select unsatisfied_msg_id from CZ_RULES where unsatisfied_msg_id = cz_localized_texts.intl_text_id and deleted_flag='''||'1'||''')',
                 'language','intl_text_id',TRUE);

CZ_BASE_MGR.exec('CZ_LOCALIZED_TEXTS','where deleted_flag='''||'0'||''' AND '||
                 'exists (select devl_project_id from CZ_DEVL_PROJECTS where devl_project_id = cz_localized_texts.model_id and deleted_flag=''1'' and devl_project_id NOT IN(0,1))',
                 'language','intl_text_id',TRUE);

delete_Orphaned_Nodes;

commit;

exception
when others then
     --null;
     raise;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure PURGE is


  TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -- changes for bug #5093264
  -- this cursor returns model nodes which refer to a  model that does not exist.
  -- ( such nodes will be deleted )
  CURSOR del_nodes_cur IS
    SELECT a.ps_node_id
      FROM CZ_PS_NODES a WHERE a.reference_id IS NOT NULL AND NOT EXISTS
         (SELECT NULL FROM CZ_DEVL_PROJECTS b
          WHERE b.devl_project_id=a.reference_id AND b.deleted_flag='0');

  t_ps_node_id   number_tbl_type;

begin
    --
    -- propogate deleted_flag for all subschema's tables
    --
    Propogate_DeletedFlag;

    --
    -- delete views associated with the deleted Populators --
    --
    for i in(select view_name from cz_populators where deleted_flag='1')
    loop
       begin
           execute immediate 'drop view '||i.view_name;
       exception
           when others then
                CZ_BASE_MGR.LOG_REPORT('CZ_PS_MGR.Purge','View "'||i.view_name||'" error :'||SQLERRM );
       end;
    end loop;

    --
    -- apply Purge --
    --
    CZ_BASE_MGR.PURGE('PS');

    OPEN del_nodes_cur;

    LOOP
      FETCH del_nodes_cur BULK COLLECT INTO t_ps_node_id
      LIMIT 10000;
      EXIT WHEN del_nodes_cur%NOTFOUND AND t_ps_node_id.COUNT = 0;

      IF t_ps_node_id.Count>0 THEN
        FORALL i IN t_ps_node_id.First..t_ps_node_id.Last
          DELETE FROM CZ_PS_NODES
           WHERE ps_node_id=t_ps_node_id(i);
        COMMIT;
      END IF;
    END LOOP;

    CLOSE del_nodes_cur;

exception
    when OTHERS then
         raise;
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
CZ_BASE_MGR.MODIFIED('PS',AS_OF);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

end;

/
