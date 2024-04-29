--------------------------------------------------------
--  DDL for Package Body CZ_PUB_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PUB_MGR" as
/*  $Header: czpmmgrb.pls 120.3 2007/11/26 13:23:24 kdande ship $	*/

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
CZ_BASE_MGR.REDO_STATISTICS('PB');
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure TRIGGERS_ENABLED
(Switch in varchar2) is
begin
CZ_BASE_MGR.TRIGGERS_ENABLED('PB',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure CONSTRAINTS_ENABLED
(Switch in varchar2) is
begin
CZ_BASE_MGR.CONSTRAINTS_ENABLED('PB',Switch);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_SEQUENCES
(RedoStart_Flag in varchar2,
 incr           in integer default null) is
begin
CZ_BASE_MGR.REDO_SEQUENCES('PB',RedoStart_Flag,incr);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure Propogate_DeletedFlag is

TYPE tPublTable IS TABLE OF CZ_MODEL_PUBLICATIONS.PUBLICATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE tModelTable is table of cz_model_ref_expls.component_id%type index by binary_integer;
TYPE tModelTableIndexVC2 is table of cz_model_ref_expls.component_id%type index by VARCHAR2(15);

/* requiredModelTbl		tPublTable; */
requiredModelTbl		tModelTable;

/* hashRequiredModels	tPublTable; */
hashRequiredModels	tModelTableIndexVC2;

deletedPublsTbl		tPublTable;
delPublsTbl			tPublTable;
deletedPubl			CZ_MODEL_REF_EXPLS.COMPONENT_ID%TYPE;

model_found 	NUMBER := 0;

x_error           BOOLEAN:=FALSE;
errbuf 		VARCHAR2(255);

/* All  deleted publications*/

CURSOR cDeletedPublication IS
	SELECT devl_project_id
	FROM cz_devl_projects
	WHERE deleted_flag = '0'
		AND devl_project_id NOT IN (SELECT object_id FROM cz_rp_entries
							WHERE object_type = 'PRJ'
							AND deleted_flag = '0');

begin
	requiredModelTbl.DELETE;
	hashRequiredModels.DELETE;

	/* Get all published models, along with the child models that need to exist (undeleted models) */
	SELECT distinct component_id
	BULK COLLECT
	INTO requiredModelTbl
	FROM cz_model_ref_expls
	WHERE deleted_flag = '0'
	AND model_id IN (SELECT model_id FROM cz_model_publications
			WHERE source_target_flag = 'T'
			AND deleted_flag = '0')
	CONNECT BY PRIOR parent_expl_node_id = model_ref_expl_id
	ORDER BY component_id;

	/* Build a hashtable of required model ids*/
	IF (requiredModelTbl.COUNT > 0) THEN
		FOR i in requiredModelTbl.FIRST .. requiredModelTbl.LAST
		LOOP
			hashRequiredModels(requiredModelTbl(i)) := requiredModelTbl(i);
		END LOOP;
	END IF;

	/* Loop through all deleted models and check if it is not being referenced
	   by other publications. If so, then mark it for deletion */
	BEGIN
		open cDeletedPublication;
		LOOP
			FETCH cDeletedPublication into deletedPubl;
			EXIT WHEN cDeletedPublication%NOTFOUND;

			IF (NOT (hashRequiredModels.EXISTS(deletedPubl))) THEN
				BEGIN
					/* Logically delete model */
					UPDATE cz_devl_projects
					SET deleted_flag = '1'
					WHERE devl_project_id = deletedPubl;
					COMMIT;
				EXCEPTION WHEN OTHERS THEN
				errbuf := cz_utils.get_text('CZ_PUB_MGR_ERR','ERR',SQLERRM);
				END;
			END IF;
		END LOOP;
		close cDeletedPublication;
	EXCEPTION
		WHEN OTHERS THEN
		errbuf := cz_utils.get_text('CZ_PUB_MGR_ERR','ERR',SQLERRM);
	END;

exception
when no_data_found then
	errbuf := cz_utils.get_text('CZ_PUB_MGR_ERR','ERR',SQLERRM);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE PURGE_RP_ENTRIES IS

  TYPE t_arr        IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
  TYPE t_char       IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

  l_end_folder_ids_tbl t_arr;
  l_temp               NUMBER;

  PROCEDURE collect_Folders(p_folder_id IN NUMBER) IS
    l_folders_exist BOOLEAN := FALSE;
  BEGIN

    FOR i IN (SELECT object_id FROM CZ_RP_ENTRIES
              WHERE enclosing_folder=p_folder_id AND object_type='FLD')
    LOOP
      l_folders_exist := TRUE;
      collect_Folders(i.object_id);
    END LOOP;

    IF l_folders_exist=FALSE  THEN
      l_end_folder_ids_tbl(l_end_folder_ids_tbl.COUNT+1) := p_folder_id;
    END IF;
  END collect_Folders;

  PROCEDURE update_Objects_In_Folder(p_folder_id IN NUMBER,x_enclosing_folder OUT NOCOPY NUMBER) IS

    l_object_id_tbl   t_arr;
    l_object_type_tbl t_char;
    l_folders_exist   BOOLEAN := FALSE;

  BEGIN

    SELECT object_id, object_type
    BULK COLLECT INTO l_object_id_tbl, l_object_type_tbl
    FROM CZ_RP_ENTRIES
    WHERE enclosing_folder=p_folder_id;

    IF l_object_id_tbl.COUNT>0 THEN
      FORALL i IN l_object_id_tbl.First..l_object_id_tbl.Last
        DELETE FROM CZ_RP_ENTRIES
         WHERE object_id=l_object_id_tbl(i) AND object_type=l_object_type_tbl(i);
    END IF;

    DELETE FROM CZ_RP_ENTRIES
    WHERE object_id=p_folder_id AND object_type='FLD'
    RETURNING enclosing_folder INTO x_enclosing_folder;

  END update_Objects_In_Folder;

  PROCEDURE goto_Folder(p_folder_id IN NUMBER, p_subroot_folder_id IN NUMBER) IS
    l_enclosing_folder NUMBER;
  BEGIN

    update_Objects_In_Folder(p_folder_id, l_enclosing_folder);

    FOR i IN (SELECT object_id, enclosing_folder FROM CZ_RP_ENTRIES
              WHERE object_id=l_enclosing_folder AND object_type='FLD')
    LOOP
      -- we should stop on this folder
      IF i.object_id=p_subroot_folder_id THEN
        update_Objects_In_Folder(p_folder_id, l_enclosing_folder);
        RETURN;
      ELSE
        goto_Folder(i.object_id, p_subroot_folder_id);
      END IF;
    END LOOP;

  END goto_Folder;

BEGIN

  FOR i IN(SELECT object_id FROM CZ_RP_ENTRIES
           WHERE object_type='FLD' AND deleted_flag='1')
  LOOP
    --
    -- array l_end_folder_ids_tbl will contain all subfolders
    -- of folder i.object_id which have no subfolders
    --
    l_end_folder_ids_tbl.DELETE;

    --
    -- collect all folders which have no subfolders ( array l_end_folder_ids_tbl )
    --
    collect_Folders(i.object_id);

    IF l_end_folder_ids_tbl.COUNT=0 THEN
       RETURN;
    END IF;

    --
    -- go up from folders which have no subfolders ( array l_end_folder_ids_tbl )
    -- and update CZ_RP_ENTRIES level by level
    --
    FOR k IN l_end_folder_ids_tbl.First..l_end_folder_ids_tbl.Last
    LOOP
      IF l_end_folder_ids_tbl(k) <> i.object_id THEN
        goto_Folder(l_end_folder_ids_tbl(k), i.object_id);
      END IF;
    END LOOP;

   DELETE FROM CZ_RP_ENTRIES
   WHERE enclosing_folder=i.object_id;

   DELETE FROM CZ_RP_ENTRIES
    WHERE object_id=i.object_id AND object_type='FLD';

  END LOOP;

END PURGE_RP_ENTRIES;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure PURGE is
begin
Propogate_DeletedFlag;
PURGE_RP_ENTRIES;
CZ_BASE_MGR.PURGE('PB');

 delete from cz_pb_client_apps a
  where not exists ( select null from cz_model_publications b
  where b.publication_id = a.publication_id );
  commit;

  delete from cz_pb_languages a
  where not exists ( select null from cz_model_publications b
  where b.publication_id = a.publication_id );
 commit;

  delete from cz_publication_usages a
  where not exists ( select null from cz_model_publications b
  where b.publication_id = a.publication_id );
 commit;

 --
 -- keep last pb model export record for
 -- server_id / model_id
 --
  for i in(select server_id,model_id,
                 max(export_id) as max_export_id
            from cz_pb_model_exports
            where status='OK'
            group by server_id,model_id)
  loop
    delete from cz_pb_model_exports
    where export_id<>i.max_export_id and model_id=i.model_id and
          server_id=i.server_id;
  end loop;
  commit;

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
CZ_BASE_MGR.MODIFIED('PB',AS_OF);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

end;

/
